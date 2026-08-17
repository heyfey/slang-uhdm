# r10uvm81 — ADVERSARIAL VERIFIER'S REPORT

**VERDICT: ACCEPT WITH A FIX.** Every headline number in the implementer's
report reproduces **bit-for-bit** from independently-built binaries at a fresh
7f31e65. Two **real over-fires** survived the implementer's census — invisible
to it because the corpus contains no instance of either shape — and are fixed
here. The fix is **byte-neutral on both corpora**: same 10 movers, same md5s.

Binaries (all `-j 2`, md5 taken separately, my own worktrees):

| tag | md5 | agrees with implementer? |
|---|---|---|
| pristine 7f31e65 | `4339982c4a4547d0f8e3d9ae35e82d2d` | **yes** |
| law2-only | `ef1dcff4de60f3e4933f26a6d9e77455` | **yes** |
| implementer's final | `fbe701bf6eca45dbb73f1fb9b0fbeb8b` | **yes** |
| **verified (final + the fix)** | `06482686b5585303581c7e47d80e2033` | new |

The law2-only binary was built from a **hand-transcribed one-line edit** with no
comment block, and still md5-matched the implementer's law2-only binary — so the
build is reproducible and the law-2 hunk is byte-identical to the committed
`r10uvm80repro/law2_selIdxNestPrefixJoinsByScope80.diff` (verified line by line).

---

## THE TWO OVER-FIRES — pristine-RIGHT → patched-WRONG on legal SV

Both are `§ pkgSubRefBindsPkgVarOverFormal81` firing where Surelog binds EARLY
and therefore keeps the formal. `condPredEarlyBound81` named only two of the
**four** sites at which Surelog compiles an expression against the ENCLOSING
statement (`pstmt`) instead of the statement object it is building.

```
CompileStmt.cpp:1322   compileConditionalStmt        the `if` PREDICATE      MODELLED
CompileStmt.cpp:1445   compileCaseStmt               the CASE CONDITION      MODELLED
CompileStmt.cpp:1505   compileCaseStmt               the CASE **ITEM** EXPR  MISSED
CompileAssertion.cpp:284 compileSimpleImmediateAssertion  the ASSERTION EXPR MISSED
CompileAssertion.cpp:392 compileDeferredImmediateAssertion  ditto            MISSED
```

The implementer's code read the third of those as *proof of the opposite*:

```cpp
else if (p->kind == SyntaxKind::CaseStatement) {
    if (prev != …CaseStatementSyntax>().expr)
        return false;  // a case ITEM, not the case expression   <-- WRONG
```

**OF-1 — a `case` ITEM expression.** `case (gate) val: …` in a package
subroutine whose formal `val` shadows a package variable: golden keeps the
`io_decl`, the patch re-pointed it at the package variable.

**OF-2 — an immediate-assertion expression.** `assert (val != 0) …`: same.
`assert`, `assume`, `cover`, plain and deferred (`#0` / `final`) all take this
path, and so does the SAME expression one plain `begin` deep.

Measured on arm `v81d_earlybound.sv`: **16 reference bindings BROKEN** (8 objects
× the package/module-hoist pair), plus 4 more on `v81c_positions.sv`. Neither
shape occurs in either corpus, which is why the implementer's census — correctly
run, correctly calibrated — read `FOVER 0`. **A zero over-fire count over 1 632
databases is not a boundary proof; the boundary has to be built.**

### THE FIX (`src/ExprEmit.cpp`, `condPredEarlyBound81` only)

Three clauses, each **measured on a purpose-built golden**, none derived:

1. **A `case` ITEM EXPRESSION is early-bound exactly as the condition is** —
   `compileCaseStmt` hands both `pstmt`. A new `StandardCaseItem` arm records
   which half of the item we walked out of; only the EXPRESSION list counts.
2. **An item's CLAUSE (its statement) is NOT** — `compileStmt(…, case_item)`
   at `:1512` passes the case_item, whose own parent chain is still open.
3. **`case … inside` is the EXCEPTION** — its items are compiled against the
   synthesized `inside` OPERATION (`:1541`), which is parentless, so BOTH a
   range item `[0:val]` **and a plain item `val:`** fall to late binding. Gated
   on `matchesOrInside`. Arm `v81g` cells G1/G2 measure both halves.
4. **The immediate-assertion EXPRESSION is early-bound; its ACTION BLOCK is
   not** — `compileSimpleImmediateAssertion` hands `pstmt` to both, but the
   action block goes through `compileStmt`, which builds a statement object
   whose parent is set after its operands are compiled. Arm `v81d` D7/D10
   (expression → formal) against D8/D9/D11 (then/else action → package var).

After the fix, arms `v81c`, `v81d` and `v81g` report **0 BROKEN** with **every
one of the implementer's repairs retained**.

### THE FIX IS BYTE-NEUTRAL ON THE CORPUS

`mv81.sh <implementer-final workdir> <verified workdir>` over all ten movers:
**0 bindings changed, 0 names changed, on every one.** Nine of the ten databases
are md5-identical; `default/Scoreboard` differs by the documented ~50/50 coin —
92 dump lines, `svunit_pkg` `vpiTaskFunc` reorder, **MULTISET DISTANCE 0**.

---

## WHAT REPRODUCED, MEASURED INDEPENDENTLY

| claim | implementer | verifier |
|---|---|---|
| three binary md5s | (table) | **identical** |
| goldens | 23/0, `/bin/false` 0/23 | **identical** |
| GATE 0 pristine vs committed baselines | 0 rows both corpora | **identical** |
| u2r rows | 731, 679/50/2, 0 differing | **identical** |
| surelog rows | 1588, 0 differing | **identical** |
| byteverify u2r | 0/679, SELFCHECK 678/679, SELFCHECK1 1 | **identical** |
| byteverify surelog | 10/953, SELFCHECK 952/953, SELFCHECK1 11 | **identical** |
| the 30 mover md5s (pristine/law2-only/final) | (C.1 table) | **all 30 identical** |
| law 2 per-NAME, 6 rows | 5348→4930/79 · 5307→4889/79 · 13806→13028/141 · 4900→4608/65 · 74→64/4 · 18727→18667/15, lacks=0 | **identical** |
| law 1 alone | 7 dbs, 13 keys / 26 objects, all `-> GOLDEN` | **identical** |
| census base | FMISS 17/30, FOVER 0, XDIFF 36 313 | **identical** |
| census final | FMISS 4/4 (the `addr` four), FOVER 0, XDIFF 35 167 | **identical** |
| census u2r | FMISS 0, FOVER 0 over 679 | **identical** |
| heads | 60→52 ×3, SeqDriver 52, BuildUVMPkg 94, SVSwitch 0 | **identical** |
| canaries / ctcan2 / canaudit | 52·9 / 58·1 / audited=31 UNCOVERED=0 | **identical** |
| arm c3 law 2 | 64→16, lacks=0, 11 golden names | **identical** |
| R0 (five rows share one head) | md5-shared | **confirmed** (`class_var` vs `ref_var`) |

### THE CANARY AMENDMENT — verified against its exact wording

```
default/SVSwitch + testflags/SVSwitch
  NAME-multiset distance to golden      74 -> 64
  names-golden-LACKS                    0
  GOLDEN names newly produced           4   -- and EXACTLY these four:
      work@Receiver::start::bytes::size          <- joinRef comment-table cell C
      work@packet::byte_pack::bytes::i
      work@packet::byte_unpack::bytes::size
      work@packet::byte_unpack::bytes::i
  BINDINGS CHANGED                      0   -- law 1 contributes nothing
  bytes                                 == the LAW2-ONLY sweep's, exactly
  CSV row                               byte-identical to the committed baseline
InterfaceModPort / BlackParrotComplex / YosysOldOr  BYTE-IDENTICAL, both modes
```

Held on the implementer's binary **and** on the verified one.

---

## THE VERIFIER'S ARMS

| arm | what it probes | result on the VERIFIED binary |
|---|---|---|
| `v81a_pkgvarkinds.sv` | 24 package-variable KINDS + init + all five formal DIRECTIONS (`input/output/inout/ref/const ref`), a default-valued formal, a task formal | 112 bindings, **50 FIXED, 0 BROKEN**; `byte_t td_v` is a `logic_net` in BOTH sides and correctly does NOT fire |
| `v81b_scopekinds.sv` | `$unit`, INTERFACE, PROGRAM, MODULE, module-scope class oob method, CHECKER, GENERATE scope, package control | the pristine→patched dump delta is **exactly 4 lines = the 2 package objects**; every other scope byte-identical. Golden leaves interface/`$unit` refs unbound, so the immunity is golden's too |
| `v81c_positions.sv` | 27 statement positions c5/c6/c7 do not reach (`repeat`, `do..while`, `foreach`, ternary, `case inside`/`unique`/`priority`/`casez`, `unique if`, `else if`, named block, `assert`, `$display`, index, `$bits`, `return` under `if`) | **found OF-1 and OF-2**; after the fix 30 FIXED / **0 BROKEN** |
| `v81d_earlybound.sv` | the whole early-bound family: case items × 4 flavours, assertion expression vs THEN/ELSE action, bare assert, `begin`-deep and if-branch-deep twins, module twin | **found 16 BROKEN**; after the fix 16 FIXED / **0 BROKEN** |
| `v81e_joint.sv` | LAW 2 at depth **5 and 6**, part-select and indexed-part-select indices, package-qualified / `this.`-qualified / class-property bases, queue and dynamic-array bases, lvalues and call arguments at each, module twins | EXCESS 74→**40**, MISSING 77→**43**; **every** "new" name is a `.`→`::` respelling of a name pristine already got wrong; **module twins: 0 of 40 names move** |
| `v81f_home.sv` | the home-package gate: wildcard vs EXPLICIT import, a class EXTENDED across packages, parameterized and nested classes | 22 FIXED / **0 BROKEN**; reproduces c8's three-way split independently |
| `v81g_caseedge.sv` | the fix's own new clauses: plain item under `case … inside`, range item, operation item, `randcase`, nested case, `if` inside an item clause | 8 FIXED / **0 BROKEN** |
| `v81h_lvbase.sv` | LAW 2 at LVALUE bases: two-level lvalue bases, nested index on either step or both, depth-3 lvalue, package-qualified and `this.`-qualified lvalue bases, part-select lvalue, and the module twin of each | class scope EXCESS 22→**8**, MISSING 19→**5**; the 4 "new" names are again 1-for-1 `.`→`::` respellings of names pristine already got wrong; **module twin: 0 of its names move** |
| uvm77–80 arms (23 files) | regression fence | 20 byte-identical; the 3 that move are r10uvm79's `v79v1/v79v4/v79v5` — law 2 IS their residue V-R1 — each with **distance down, lacks=0, +3 golden names** |

`v81bind.sh` is the per-BINDING judge (golden + both binaries in one scratch dir,
multiset join on `(ref line:col, ref fullname)`, classifying every key as
AGREE_PRE / FIXED / **BROKEN** / STILL / CHANGED_BOTH_WRONG / ONESIDED — a
verifier that cannot say "pristine was right here and you broke it" is not one).
`v81names.sh` is the per-NAME judge with an EXCESS/MISSING split, because
`namecmp80.py`'s `new-names-golden-lacks` counts a **respelling** of an
already-wrong name as new.

`ct81gate.py` gains **7 rows** for the fix's clauses: 24/24 on the verified
source, **17/24 on the implementer's** (the seven new rows FAIL — a real negative
control), `AUDIT CANNOT RUN` on pristine.

---

## RESIDUES FOUND BY THE VERIFIER (ranked, none blocking)

**V-R1 — `randcase` weights carry no `vpiActual` at all on our side.** Arm
`v81g` G4: golden binds `pg97::val`, we emit no binding. A missing object, not a
mis-binding — outside this law's instrument (the census only sees references
that HAVE an actual).

**V-R2 — an EXPLICIT (non-wildcard) import does not clone.** Arm `v81f`:
`import pf96::fv;` then a formal `fv` in `ph96` — golden binds `ph96::fv` (the
explicit-import clone in ph96's `Variables()`), we keep the `io_decl` because we
never mint that clone. A FMISS of the same family as the head, one gate further
out. Unreached by the corpus.

**V-R3 — an import CLONE displaces a same-named OWN variable in golden.** Arm
`v81f`: inside `pg96`'s own function, `sink` binds in golden to the clone at
`9:8` (pf96's line) rather than pg96's own `sink` at `30:8`. Surelog's
last-writer-wins again, one listing further in. Pristine and patched agree with
each other and differ from golden — pre-existing, untouched.

**V-R4a — an lvalue's base name interpolates its index text.** Arm `v81h` h3:
golden writes `…::m[].mi::idx::i`, we write `…::m[].mi[idx[idx[i]]]::idx::i` —
the whole index expression's source text appears inside the name. Pristine and
patched produce it identically; law 2 only re-joins its tail. A naming family of
its own, and the largest single residue this arm sees.

**V-R4 — the doubled part-select base.** Arm `v81e` cell e5: golden writes
`…::warr::warr::midx::i` for a nested index inside a part-select whose base is
itself an element select. Neither binary produces it. r10uvm78's family.

**V-R5 — a `fork` above an `if` predicate stays unmeasured**, as the implementer
states (R2). `assert`/`assume`/`cover` are now measured and deliberately NOT in
the reject switch: arm `v81d` D12 shows an `if` predicate inside an assertion
ACTION BLOCK keeps the formal in golden, which is what the code does.

The implementer's R0/R1/R3 all reproduce and are correctly characterised.
