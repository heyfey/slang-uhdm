# r10vearl107 — the adversarial verification of r10earl107 (§ `patFlatPortConnUnsizedMember107`)

**VERDICT: ACCEPT.** Every headline number in the implementer's report reproduces
bit for bit on this verifier's own two builds, and seven new adversarial arms —
built to break the law's one structural assumption — find no
pristine-right → patched-wrong cell on legal SystemVerilog. No production change
was needed, so `/tmp/r10earl107.verified.patch` carries the implementer's
`src/ModuleEmit.cpp` diff **byte for byte unchanged** plus this directory.

Everything here is **MEASUREMENT ONLY**. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

* BASE COMMIT `d53fbaad`, branch `auto5h`. Worktrees `/tmp/wt_v107` (patched) and
  `/tmp/wt_v107pris` (pristine), both `git worktree add … d53fbaad`.
* Builds: pristine `fb82059559765e79eee43ee365aa4879` — **byte-identical to the
  main tree's build at `d53fbaad`** — patched `fd2870e34b3081cb23199acbdfdf838d`.
  The patch applied to a FRESH `d53fbaad` and rebuilt there reproduces the
  implementer's patched md5 exactly.
* Full gate battery: `GATES.r10vearl107.txt`. Corpus census: `CENSUS.r10vearl107.txt`
  + `CENSUS_CHANGED_sl.txt`. Mover attribution: `ATTRIB.r10vearl107.txt`.
  Arm grid + three-way scores: `GRID.r10vearl107.txt`. The two non-zero
  MOVED-WRONG cells, decoded: `MOVEDWRONG.r10vearl107.txt`.

---

## 1. THE ASSUMPTION THE LAW RESTS ON, AND THE ARM BUILT TO BREAK IT

The landed loop walks the operand vector and the pattern's `memberSetters`
**in lockstep**, gated only on the two having the same SIZE:

```cpp
if (ov8 && ap8.typeSetters.empty() && ap8.indexSetters.empty() &&
    !ap8.defaultSetter && ov8->size() == ap8.memberSetters.size())
    for (size_t i7 = 0; i7 < ov8->size(); i7++) { … ap8.memberSetters[i7] … }
```

Slang's `memberSetters` are in **WRITTEN** order. Golden's flattened operands are
in **DECLARATION** order — `UHDM::ExprEval::flattenPatternAssignments` walks
`fieldTypes[index]` and pushes into `ordered`. **If our operand vector were also
in declaration order, a size-only gate would silently mis-bind every shuffled
pattern**, and the failure mode is not a residue: a member written with a SIZED
literal (which the law must leave alone) would be OVERWRITTEN with a neighbour's
fill at a neighbour's width — a pristine-right → patched-wrong regression.

**`v1_shuf107.sv`** is that arm: a package packed-struct parameter written OUT OF
declaration order, mixing sized and unsized member values, at a child port.

```systemverilog
typedef struct packed { logic [7:0] m8; logic [1:0] m2; logic [3:0] m4; } t3_t;
parameter t3_t P_SHUF  = '{ m2: '0,  m8: 8'hA5, m4: '1 };   // written m2,m8,m4
parameter t3_t P_SHUF2 = '{ m4: '1,  m2: 2'b10, m8: '0 };   // written m4,m2,m8
parameter t3_t P_DECL  = '{ m8: 8'hA5, m2: '0,  m4: '1 };   // the control
```

**MEASURED** (`dumpop107`, the ELAB port high_conn, LHS golden first):

| | operand 0 | operand 1 | operand 2 |
|---|---|---|---|
| golden, `P_SHUF` | `m8` `8'hA5` HEX sz 8 | `m2` `0` UINT sz 2 | `m4` `15` UINT sz 4 |
| ours, `P_SHUF` | `m2` `0` UINT sz 2 | `m8` `8'hA5` HEX sz 8 | `m4` `15` UINT sz 4 |

**Our operands are in WRITTEN order, golden's in DECLARATION order — so the
lockstep is exact on our side and every member is re-typed at ITS OWN width.**
`m8`'s `8'hA5` is untouched on both `P_SHUF` and `P_SHUF2`; nothing is clobbered.
The ORDER mismatch is pre-existing (pristine has it too, and it is why this arm's
uhdm-cmp count is unchanged at 36/1); the law neither creates nor worsens it.

**Why no shuffle can regress, generally.** A regression at index *i* needs
pristine's operand *i* (written-order member, unmodified) to already EQUAL
golden's operand *i* (declaration-order member, flattened). Re-typing only fires
where the written value is an unbased-unsized literal, so pristine's operand
there is spelled `'0`/`'1` — and golden's flattened operand is never spelled
`'0`/`'1` (it is decimal, or a sized literal's own spelling). Where golden does
NOT flatten (`tagged_pattern` kept — `v4`/`v7`), the two differ by `VpiType`
already. The declaration-order flatten in `ExprEmit.cpp:29313` cannot reach this
arm either: `patFlatTs` is consumed and nulled at `ExprEmit.cpp:29180`, and is
set only at the var-declaration (`ModuleEmit.cpp:8553`) and `cont_assign`
(`ModuleEmit.cpp:24488`) sites, each clearing right after its own `emitExpr`.

---

## 2. THE OTHER SIX ARMS, AND WHAT EACH ONE PUT AT RISK

| arm | face | result |
|---|---|---|
| `v2_hold107` | ONE vs TWO vs THREE holders of the same param at three ports, **and the same param as a `cont_assign` Rhs and a var-declaration initializer in the SAME design** | all three port copies equal golden (`255`@8 + `0`@2); the `cont_assign` and `var` carriers untouched. TO-GOLDEN 6, AWAY 0 |
| `v3_width107` | fill × width on a struct that FITS IN A WORD (32/16/8/2/1), every fill face: `'1` `'0` `'x` `'z`, sized, decimal | ours equals golden in **every** `'1`/`'0`/`'x`/`'z` cell; sized untouched; decimal is R1 and unchanged. TO-GOLDEN 20 |
| `v4_kind107` | member KINDS: an ENUM member (behind an explicit cast), a packed **array** member, a **nested struct** member, 64- and 65-bit members, and a **localparam**-sourced value at a port | `pa`→`4294967295`@32, `x64`→`…615`@64, `b65`→`…615`@**65** (getMask saturation) all equal golden; the CAST operand and the NESTED pattern's own members are left alone. TO-GOLDEN 8 |
| `v5_dpth107` | carriers the law must DECLINE: a `default:` fill, a **type-key** setter, an **array-of-struct** param at a port, and a **parameter OVERRIDE** | all four declined and byte-identical; the one named all-unsized port (`P_PLAIN`) equals golden `[255@8, 0@2, 1@1]`. TO-GOLDEN 3, AWAY 0 |
| `v6_alias107` | **parameterised** package widths (the Earlgrey shape), an ALIAS typedef formal, a **2-state** (`bit`) struct with `'x`/`'z`, the same param at ports of TWO DIFFERENT child modules, and an **unpacked** struct param at a port | every packed cell equals golden, `'x`/`'z` on 2-state → `0` at the member width exactly as golden; the unpacked param is declined by the arm's own `PackedStructType` gate. TO-GOLDEN 6 |
| `v7_edge107` | edge widths 63 / 64 / 4096 / **4097** | `63`→`9223372036854775807`@63, `64` and `4096`→`…615` at their true widths, all equal golden; **4097 is declined by the loop's `mw7 > 4096` guard** — see §4 |

**THREE-WAY SCORE over all seven arms × both views** (`score107.py` on
`cen107 --raw --tagblind`, so a cell whose operand KIND still differs is joined
and its compare-visible payload scored rather than split away):

```
TO_GOLDEN 104   AWAY_GOLDEN 0   MOVED_WRONG 2   (the two v7 4097 cells, §4)
```

**AWAY-GOLDEN is 0 on every arm in every view**, and `MOVED_WRONG` is 0 on six of
the seven.

---

## 3. THE IMPLEMENTER'S NUMBERS, RE-MEASURED

Every one of these was produced on this verifier's own builds and workdirs, not
carried forward. The detail is in `GATES.r10vearl107.txt`.

| claim | re-measured |
|---|---|
| pristine md5 = the main tree at `d53fbaad`; patched md5 | **both exact** |
| the patch rebuilds byte-identically from a FRESH `d53fbaad` | **yes** |
| head decode: `VpiDecompile` fails FIRST, then `VpiSize`, then `VpiConstType` | **confirmed from `expr.cpp:90/95/100` + `constant.cpp:66`**; no location is read |
| pristine head `constant id:704546` dc `0`/sz 2/UINT:0/ct 9 vs ours dc `'0`/sz 16/BIN:0/ct 3 | **exact** |
| owner: golden **VECTOR=2 SINGULAR=0**, ours VECTOR=1, same port chain | **exact** (`own107 … id:704546`) |
| the value rule is `NumUtils::getMask`, saturating at 64 | **read out of `NumUtils.cpp:97-105`**; the patch's `(mw >= 64) ? ~0 : (1<<mw)-1` is that function |
| `'x`/`'z` land in the `uval == 0` arm | **confirmed in source** (`ExprEval.cpp:889-916` never reads `invalidValue`) **and measured** at a port on 4-state (`v3`) and 2-state (`v6`) members |
| grid `g1_home107` 36/1 → **0/0** plain, 32/1 → **0/0** elab | **exact** |
| corpus census: surelog **4 rows, all DIFF → SAME**; u2r **0** | **exact**, and the four rows are the two predicted cells in both modes |
| port carrier 4 DIFF / 34 SAME → **0 / 38** | **exact**; whole census 2360→2356 DIFF, no non-port row moved |
| goldens 23/0, `/bin/false` 0/23, u2r 679/50/2 | **exact** |
| `ct8rows` PASS on all five comparisons, **no row converted** | **exact** |
| movers **3/956 surelog, 0/1358 u2r**, `Scoreboard/default` **0 lines order-blind** | **exact** (92 lines raw = the recorded coin) |
| Earlgrey/default **14** order-blind lines, testflags **22**, zero unrelated | **exact**, line for line |
| heads all byte-identical except Earlgrey/testflags **32 → 122**, one head, new object | **exact** |
| R0 owner: **SINGULAR `param_assign` 9:17-9:31 `Rhs`, VECTOR=0 SINGULAR=1** under `…u_pwrmgr.i_cdc.i_ast_sync` | **exact** (`own107 … id:709890`) |
| wide boundary: only this pass's arms move | **confirmed at LISTED=PROCESSED=4817**; DIFFERING=20 = the four implementer arms + six of this directory's, both views; rc symmetric, ASYMMETRIC=0 |

Two figures differ from the implementer's only because this run's file list is
different: `LISTED=4817` (not 4811 — this directory's arms are in the copy) and
`DIFFERING=20` (not 8 — twelve of the extra cells are this directory's own arms,
which is the wide gate's own positive control that it can see a moved cell).

---

## 4. RANKED RESIDUES

**R1 — the `mw7 > 4096` guard has no golden basis, and half-typing a pattern
perturbs the elaborator's mint.** `v7_edge107`: golden re-types a **4097**-bit
member (`18446744073709551615` at `vpiSize` 4097 — `getMask` saturates at 64 but
the flatten stamps the TRUE width). The loop declines it, and the elaborator then
mints a re-sized replacement for the still-`VpiSize(-1)` constant by copying the
**previous operand's** width — 4096, which the law has just made real. On the
`'1` arm the patched cell is **strictly closer** (it now passes `VpiDecompile`
and fails one field later, at `VpiSize`); on the `'0` arm the move is **behind
the first failure and judge-invisible**. Neither is AWAY-GOLDEN. **Zero corpus
cells** — no packed-struct member wider than 4096 bits exists in either corpus.
Removing the cap is safe arithmetically (`mw >= 64` already guards the shift) but
has no corpus witness, so it is left as a residue rather than widened here.
Decoded in `MOVEDWRONG.r10vearl107.txt`.

**R2 — the operand ORDER at a port is still ours, not golden's.** Golden's port
high_conn carries the flattened vector in DECLARATION order; we carry it in
WRITTEN order (`v1_shuf107`, both views). A pattern written in declaration order
— which is every corpus cell — is unaffected, and the law is order-agnostic, but
a shuffled pattern's port cell stays unequal for this reason alone. Pre-existing,
zero corpus cells, and the implementer's decision to write the loop instead of
turning the `ExprEmit` flatten on is exactly what keeps it that way.

**R3 — the residues the implementer already named, each re-measured here and
each still zero corpus cells**: a plain DECIMAL member value keeps 64 at a port
(`v3` row `f`: golden sizes 7/5/165/1/1 at 32/16/8/2/1, we keep 64 on four);
a NESTED pattern's own members are not re-typed (`v4` `nst`); a `default:` fill
changes the operand COUNT (`v5` `.a`); the TAG axis — golden keeps
`tagged_pattern` operands where the struct carries an enum, a nested struct or is
wider than a word (`v4`, `v7`), we always drop the tags; and the carriers this
arm never reaches — a module-LOCAL param, an INLINE pattern, a POSITIONAL
pattern, an UNPACKED struct param (`v6` `.z`, where golden DOES emit a port op),
an ARRAY-of-struct param and a parameter OVERRIDE (`v5`).

**R4 — an ENUM-typed member cannot be reached from slang.** `en: '1` on an
`enum logic [2:0]` member is rejected by slang without an explicit cast, and an
explicit cast is not an `UnbasedUnsizedIntegerLiteral`, so the gate declines it
(correctly — the cast operand is an `op=67`, not a constant, and golden's
`ExprEval::size` on an `enum_typespec` is unmeasured here). `v4_kind107` `.a`/`.b`
carry the shape for the pass that decodes it.

**R0 (the implementer's, re-verified) —** `Earlgrey_0_1/testflags`, 122 lines,
one head: golden `operation id:709890 op=75` at `pwrmgr_cdc.sv:108:17-108:41`
held **SINGULAR** by `param_assign 9:17-9:31 Rhs` under
`work@top_earlgrey.u_pwrmgr.i_cdc.i_ast_sync`; ours a folded 1-bit `constant
id:557631`. The **PARAMETER-OVERRIDE** carrier of the same substitution this pass
fixed at the **PORT** carrier. `expr::Compare` fails at step 1 (`VpiType`), so it
is a whole-object question.

---

## 5. FILE MAP

| file | what it is |
|---|---|
| `v1_shuf107.sv` | the LOCKSTEP arm — a shuffled named pattern mixing sized and unsized values at a port |
| `v2_hold107.sv` | one/two/three holders + the same param as a port high_conn AND a plain Rhs in one design |
| `v3_width107.sv` | fill × width on a word-sized struct: `'1` `'0` `'x` `'z` sized decimal at 32/16/8/2/1 |
| `v4_kind107.sv` | member kinds: enum (cast), packed array, nested struct, 64/65-bit, localparam-sourced |
| `v5_dpth107.sv` | the declines: `default:` fill, type key, array-of-struct, parameter override |
| `v6_alias107.sv` | parameterised widths, alias typedef formal, 2-state `'x`/`'z`, two child modules, unpacked struct |
| `v7_edge107.sv` | edge widths 63 / 64 / 4096 / 4097 |
| `TOPS.txt`, `gridv107.sh` | the arm `-top` map and the driver (it calls `r10earl107repro`'s own `grid107.sh` / `cen107` / `score107.py`, so the arms are scored on the implementer's instrument, not a second one) |
| `GRID.r10vearl107.txt` | the grid table and the three-way scores |
| `GATES.r10vearl107.txt` | every gate, re-run on this verifier's own builds |
| `CENSUS.r10vearl107.txt`, `CENSUS_CHANGED_sl.txt`, `CENSUS_status_u2r.txt` | the corpus census totals and the four rows that changed |
| `ATTRIB.r10vearl107.txt` | the order-blind whole-dump attribution of all three movers |
| `MOVEDWRONG.r10vearl107.txt` | the two MOVED-WRONG cells decoded against `expr::Compare`'s field order |
| `BOUNDARY_WIDE.*` | the wide boundary: list, tally, rc histogram, rc by side, signals, and the 20 moving cells |
| `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `rowheads.sh` | the shared gate instruments, carried so this directory reproduces on its own |
