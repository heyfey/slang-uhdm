# r11v7 — the ADVERSARIAL VERIFIER of r11u7 (§ `ifacePortViewAggregateFlattens`)

Verdict: **ACCEPT WITH FIX.** Every headline number in `r11u7repro/` reproduced
bit for bit on binaries this verifier built itself. Two faces of legal
SystemVerilog were found where the law moved Compare-visible fields AWAY from
golden that our PRISTINE emitter already had right; both are closed by a
conservative gate, and a third (a stolen `else if`) is closed by restoring the
branch it took. The production surface stays `src/ModuleEmit.cpp` +
`src/UhdmExporter.cpp` + `include/UhdmExporter.h`.

Everything here is MEASUREMENT-ONLY; the judge is the official `uhdm-cmp`
through `scripts/verify_golden.py`.

## 0. Binaries (built here, frozen `chmod 555`, audited in every `cmds.txt`)

| binary | md5 | what |
|---|---|---|
| pristine | `0cd3567badf786731e77120ee53a2fdc` | `fe90b885`, the mandated hash |
| r11u7 as shipped | `29e2548414ff96e2b1de997e9b25b3c0` | the implementer's patch, unmodified |
| r11u7 + this fix | `d1b436e3861c871eb244888aa689ee78` | what `r11u7.verified.patch` builds |

## 1. THE THREE BREAKS, each measured on a real Surelog v1.87 golden

`run.sh <pristine> <candidate> [<fixed>]` rebuilds every arm below with real
goldens and scores the Compare-visible `param_assign` census three ways.

### x8 — a `default:` key BEFORE a named one: one object in two operand slots

`'{default: 0, BUS: '{DAT: 32}}` on `{bus_t BUS; int unsigned SCA;}` (slang rc
0, surelog rc 0, `[  ERROR] : 0`).

```
GOLDEN  top.a0.p  op75[ts=-](op75[ts=bus_t](const(UINT:32,sz=32)), const(UINT:0,sz=32))
PRISTINE          op75[ts=cfg_t](op75[ts=bus_t](const(UINT:32,sz=64)), const(UINT:0,sz=64))
r11u7             op75[ts=-](op75[ts=bus_t](const(UINT:32,sz=64)), <elided:operation>)
```

`memberValue7` matched `BUS` by NAME to operand 1, then fell back POSITIONALLY
for `SCA` and landed on operand 1 AGAIN — the SAME aggregate object pushed
twice into one operand list, which `uhdm-dump` prints as `<elided:operation>`.
`ExprEval` does none of that: it matches an unmatched key by TYPESPEC KIND
(`templates/ExprEval.cpp:845-852`), `clone_tree`s the `default:` operand for
each member left over (876-884), and BAILS when a member matches nothing
(886-894). Pristine had the member's KIND and VALUE right; r11u7 lost both.
r11u7's residue R4 states this shape is "excluded by the gate in practice" —
it is not: member 0 is an explicit nested pattern, so the gate fires.

### x4 — an UNSIZED literal member is resized by the producer, not by us

`'{BUS: '{DAT: 32}, M: '1, Z: '0}` on `{bus_t BUS; logic [7:0] M; logic [3:0] Z;}`.

```
GOLDEN  top.a0.p  op75[ts=-](op75[ts=bus_t](const(UINT:32,sz=32)), const(UINT:255,sz=8), const(UINT:0,sz=4))
PRISTINE          op75[ts=cfg_t](op75[...](const sz=64),           const(UINT:255,sz=8), const(UINT:0,sz=4))
r11u7             op75[ts=-](op75[...](const sz=64),               const(BIN:1,sz=-1),   const(BIN:0,sz=-1))
```

`ExprEval` rewrites a `tagged_pattern`'s constant whose `VpiSize` is -1 to the
member's width, value and `vpiConstType` (`ExprEval.cpp:887-906`). Copying the
declaration's tree hands back the raw `'1`/`'0`: three Compare-visible fields
per constant moved away from a golden our pristine emitter already matched.

### x1 `MSK` — the stolen `else if` (face (C) never runs)

The new arm sat in the middle of r11u4's if/else chain, so an
assignment-pattern DEF default whose port-view Rhs our emitter folded to a
CONSTANT no longer reached face (C) ("the reduced operation default drops its
typespec"): it was queued, and the applier then DECLINED it (the Lhs typespec
is a packed vector, not a struct — measured on `parameter logic [7:0] MSK =
'{default: 1'b1}`), so the strip simply never ran. On this arm the constant
carried no typespec anyway, so no byte moved; the hazard is structural, not
hypothetical, and costs one predicate to remove.

### How both breaks hid from every scorer in the pass

`pacen7.py` scores WHOLE ROWS: a row that did not match golden before and does
not match after is `LOST 0 / GAIN 0` no matter how many fields moved inside it.
On x4 and x8 it reads `LOST 0 GAIN 0` for r11u7 — the row was already unequal
because of the outer typespec. The official `uhdm-cmp` is no help either: it
prints ONE head per run and its output on these arms is byte-identical before
and after. Only reading the SHAPES side by side (`pacen7.py <dump>`, three
columns) shows the member value changing from a constant to a duplicated
aggregate. A row-keyed agreement scorer is blind below the row; that is the
census trap in RESUME §9, and it is why these two faces needed the shape
listing and not the score.

## 2. THE FIX (minimal, gated; `src/ModuleEmit.cpp` only)

1. `memberValue7` matches a member BY NAME ONLY — the positional fallback is
   deleted.
2. `wouldFlatten7` additionally requires `operands == declared members`, so a
   `default:` key, a kind-matched key or a key matching nothing all DECLINE.
3. The top-level gate declines when `hasUnsizedConst7(defRhs)` — any constant
   with `VpiSize < 0` anywhere in the def tree.
4. The queue arm additionally requires `pa4->Rhs()` NOT to be a constant, so
   face (C) keeps every constant Rhs it had.

Effect, measured by database bytes (`run.sh`'s last block): the fixed binary is
BYTE-IDENTICAL to r11u7 on x1/x5/x6/x7 and to PRISTINE on x2/x4/x8 — it
declines exactly the three unmodelled faces and nothing else.

## 3. The arms that show the law is RIGHT where it fires

| arm | what it proves |
|---|---|
| x5 | 3 members, keys OUT of declaration order, 3 levels deep: the flatten reproduces golden's declared-member ORDER (pristine had `SEQ` before `BUS`) |
| x6 | a packed-array-of-struct member keeps its `tagged_pattern` children in golden, and the law reproduces that tree exactly (pristine folded it to `const(UINT:4294967298)`) |
| x7 | an OVERRIDDEN instance (`#(q7::OTH)`, DAT=64) — every plain/positional/generate-borne port view shows the DECLARATION's 32, and the named-modport view `m0.q` stays exempt and byte-unchanged |
| x3 | NON-COMPARABLE: slang accepts unqualified TYPE keys, Surelog v1.87 rejects them (`surelog_rc=3`, no golden — its `cmp_rc=0` is a cmp on a missing file and means nothing). Both binaries emit identical bytes, so r11u7's residue R6 type-key face is unreachable through the harness. |

## 4. Residue this verifier adds

**R-A — the port view's inner constant size is not always the declaration's.**
On the two converting corpus tests and on `r11v4repro/v1`, golden's port-view
inner constant is `sz=64`, exactly what the def tree carries, which is why they
convert. On SIX arms here (x1, x2, x4, x5, x6, x7, x8) golden holds `sz=32` —
the member width — while the law copies the def's 64, so those cells stay
unequal. The discriminator is in the producer, not in this law; the candidate
shape is an interface whose own localparam reads the struct FIELD directly
(`localparam int unsigned W = CFG.BUS.DAT;`). No regression either way: the
cells were unequal before and after.

## 5. Reproduce

```bash
bash tools/probe/r11v7repro/run.sh <pristine> <r11u7-binary> <fixed-binary> /tmp/<mine>
```
