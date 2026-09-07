# r10earl116 — § `patCaFlatLhsWholeName116` — **AN ASSIGNMENT-PATTERN CONTINUOUS ASSIGN IS FLATTENED ONLY WHEN ITS Lhs IS A WHOLE-NAME REFERENCE, BECAUSE UHDM'S ELABORATOR GATES THE FLATTEN ON `Actual_group<struct_var>` AND A SELECT'S ACTUAL IS THE ARRAY** — the Earlgrey_0_1 testflags tagged-pattern head CLEARED, the judge's next object named

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `65d82256` |
| pristine binary | md5 `4712b6510fb09e231f72919d866820c9`, built from this pass's OWN worktree at a clean `65d82256` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary (SHIPPED) | md5 `50c2e7ca6b5d392f177d89f98e9dba64`, frozen `chmod 555` |
| TWO EARLIER CUTS WERE BUILT AND CONVICTED BEFORE THIS ONE | `fb910456e0afdae5b243908408446a47` — "suppress the early flatten and let the clone do it", refuted before it ever reached a sweep (§3); `f0b1d2e57f85587e588e04e40aa26176` — a SINGLE gate on the whole `flattenPatternCaRhs` site, which cleared the head, scored `AWAY 0` on all eight of this pass's own arm/views AND on both corpora in this pass's own family — **and the WIDE BOUNDARY convicted it anyway** (§6c) |
| production surface | `src/ModuleEmit.cpp` ONLY |
| probe surface | `tools/probe/r10earl116repro/` only |
| the head | **Earlgrey_0_1/testflags, 92 cmp lines, ONE head → 36 cmp lines, ONE head, on a DIFFERENT object.**  Before: golden's `tagged_pattern` at `tlul_socket_m1.sv:241:17` (its `Pattern` a `bit_select` on `gen_idrouting[0].hfifo_rspvalid`, its `Typespec` a `string_typespec('d_valid')`) against OUR flattened bare `bit_select` operand — `operation::Compare`'s VECTOR SafeCompare over `Operands`, element 0, failing on `VpiType`.  After: the SAME `bit_select`'s `VpiIndex`, golden's folded `constant 0` against our unfolded `ref_obj('i')` bound to the genvar `parameter`.  **THE LINE COUNT IS THE HEAD OBJECT'S DECOMPILE SIZE, NOT A DISTANCE** (RESUME.md §9) — a `tagged_pattern` carrying a `bit_select`, a constant and a `ref_typespec` decompiles larger than a bare `constant` |
| Earlgrey_0_1/default | **31 lines, 1 head, cmp log BYTE-IDENTICAL** — r10earl107's pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null, untouched.  Its DATABASE moves (predicted, §5) |
| goldens | 23 PASS / 0 FAIL on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |
| arm grid | 4 NEW arms + every arm the wide boundary flagged (r10earl113/114/115, r10vearl112/113/115), **14 arm files × 2 views = 28 arm/views**, scored in TWO census families of this pass AND in BOTH of r10earl115's, calibrated golden-vs-golden with all cells `SAME_AGREE` and 0 phantoms in every one: **AWAY 0 and MOVED-WRONG 0 IN EVERY ARM/VIEW OF EVERY FAMILY** — the string `AWAY` does not occur once in `GRID.r10earl116.txt` or `BOUNDARY_arms.txt`, and `MOVEDWRONG` does not either — with TO-GOLDEN **112** across the 28 arm/views of this pass's two families and **100** in r10earl115's `PX`.  **TWO arms go from a head to fully CMP-EQUAL**: r10vearl115's `w1_memlhs` **428 cmp lines / 1 head → 0 / 0** and `w4_selmem` **428 / 1 → 0 / 0** |
| corpus census | 2314 databases, both corpora × both modes, golden halves asserted byte-identical between the two sweeps: surelog **FX TO-GOLDEN 2 / AWAY 0 / MOVED-WRONG 0 / NOGOLD-MOVED 0**, `F0` identical; uhdm2rtlil **not one cell of either family moved, STILLWRONG 0** |

---

## 1. THE JUDGE, DECODED FIRST

RESUME.md §9's head-decode discipline: read the generated `Compare` ORDER before
naming a field.  `operation::Compare` (UHDM generated `operation.cpp:98-129`)
runs

```
operation::Compare
  -> expr::Compare -> BaseClass::Compare  VpiType, VpiName, VpiDefName
                   -> VpiDecompile, VpiSize, Typespec
  -> VpiOpType            (int subtraction)
  -> VpiReordered         (bool)
  -> VpiFlattened         (bool)
  -> VpiOpStrong          (bool)
  -> Operands             (SafeCompare, VECTOR)     <-- THIS PASS
  -> Attributes           (SafeCompare, VECTOR)
```

and the VECTOR SafeCompare descends into each operand with that operand's own
generated `Compare`, where `BaseClass::Compare`'s **VpiType** is the first field
read.  `HEAD_BEFORE_Earlgrey_testflags.cmp` is exactly that: LHS a
`tagged_pattern`, RHS a `bit_select`, same span, `-1` on VpiType.

**`VpiFlattened` is READ but is NOT the distinguisher.**  It is compared three
fields before `Operands`, and it is `false` on both sides everywhere:
`ExprEval::flattenPatternAssignments` declares `bool flatten = false;`
(ExprEval.cpp:795) and never assigns it, so its `if (flatten)
opres->VpiFlattened(true);` (ExprEval.cpp:936-938) is dead.  Named because a
reader of the `Compare` order would otherwise reach for it first.

---

## 2. THE DECODE — UHDM'S OWN SOURCE, READ, NOT INFERRED

Both emitters hand the SAME code the same job: `uhdm_main.cpp` mirrors
Surelog's `UhdmWriter.cpp:5195-5199` argument for argument, so any divergence is
in the TREE the elaborator is handed, not in the elaborator (r10earl115's §2,
which this section extends).

### 2a. THE FLATTEN AND ITS GATE

The flatten is not something Surelog's WRITER does.  It is what UHDM's
ELABORATOR does while deep-cloning a continuous assign, and it is gated on the
SHAPE OF THE Lhs — `cont_assign::DeepClone`
(`~/git-repos/UHDM/templates/clone_tree.cpp:803-820`):

```cpp
    clone->Rhs(rhs);
    if (ref_obj* ro = any_cast<ref_obj*>(lhs)) {
      if (struct_var* stv = ro->Actual_group<struct_var>()) {
        if (ref_typespec* rt = stv->Typespec()) {
          if (typespec* ts = rt->Actual_typespec()) {
            ExprEval eval(elaboratorContext->m_elaborator.muteErrors());
            if (expr* res = eval.flattenPatternAssignments(
                    *context->m_serializer, ts, rhs)) {
              if (res->UhdmType() == UHDM_OBJECT_TYPE::uhdmoperation) {
                ((operation*)rhs)->Operands(((operation*)res)->Operands());
```

Four exits, and each one leaves the tagged-pattern operand list ALONE:

1. **`any_cast<ref_obj*>(lhs)` fails.**  `any_cast` is IS-A, so this is not the
   test it looks like: `bit_select` and `var_select` DERIVE from `ref_obj`
   (`~/.local/include/uhdm/bit_select.h:41`, `var_select.h:41`) and pass it.
   What fails here is a `hier_path` Lhs — a MEMBER access, `x.sub = '{…}`.
2. **`ro->Actual_group<struct_var>()` fails.**  This is the one a SELECT Lhs
   trips: `hrsp_fifo_i[i]`'s `Actual_group` is the `array_var hrsp_fifo_i`, not
   a `struct_var`.  It is also what a whole-name Lhs onto a `struct_net` trips.
3. **`stv->Typespec()` / `rt->Actual_typespec()` null.**  Reached in the
   NON-elaborated (`-parse` only) database — §7 R1.
4. **`flattenPatternAssignments` itself returns its argument** — §2b.

### 2b. THE OPERAND-LOOP BAIL, AND WHY IT IS NOT THIS HEAD

`ExprEval::flattenPatternAssignments` (ExprEval.cpp:750-947) walks the operand
list and bails outright at the first operand that is neither a `tagged_pattern`
nor a plain value:

```cpp
      } else if (oper->UhdmType() == UHDM_OBJECT_TYPE::uhdmoperation) {
        return result;
      } else if (oper->UhdmType() == UHDM_OBJECT_TYPE::uhdmconstant) {
        return result;
      } else {
        if (index < (int32_t)tmp.size()) tmp[index] = oper;
```

**THE PASS BRIEF'S FRAMING IS REFUTED, AND THIS IS THE FIRST THING MEASURED.**
The brief says golden keeps the tagged pattern at 241 because "its flatten
bailed at a non-tagged operand".  It did not bail — **it never ran**.  All TEN
of golden's operands at `tlul_socket_m1.sv:241` ARE `tagged_pattern`s
(`sig116`'s `OPK` column, `CENSUS_sl.txt`), and the Lhs gate of §2a exit 2
refused the call before the loop existed.  The bail is a real condition with an
EMPTY population in golden's gen-scope keyed-pattern census; arm `q3_mix116`
gives it its own cells anyway (§4).

### 2c. WHAT THE TWO EMITTERS ACTUALLY DO — ELEVEN LINES APART IN ONE MODULE

The corpus head row carries both carriers in one file, differing ONLY in the
Lhs.  `sig116` on the two databases
(`R|<side>|SPAN|LNAME|LK|LACT|SC|GD|CAR|NOPS|TAG|FLAT|OPK`):

```
  tlul_socket_m1.sv:108   assign hreq_fifo_i    = '{ … }   Lhs ref_obj/struct_var
    G  108:26-119:6 hreq_fifo_i ref_obj    struct_var gen_scope 1 cont_assign 10  0 FLAT
    O  108:26-119:6 hreq_fifo_i ref_obj    struct_var gen_scope 1 cont_assign 10  0 FLAT

  tlul_socket_m1.sv:240   assign hrsp_fifo_i[i] = '{ … }   Lhs bit_select/array_var
    G  240:29-251:6 hrsp_fifo_i bit_select array_var  gen_scope 1 cont_assign 10 10 TAGGED
    O  240:29-251:6 hrsp_fifo_i bit_select array_var  gen_scope 1 cont_assign 10  0 FLAT
```

and the whole-row histogram, keyed by `Lhs kind / Lhs actual kind / scope`, is
the cleanest statement of the law there is:

| Lhs kind / actual / scope | golden | ours, pristine | ours, patched |
|---|---|---|---|
| `bit_select / array_var / gen_scope` | **TAGGED 29** | FLAT 29 | **TAGGED 29** |
| `ref_obj / struct_var / gen_scope` | FLAT 29 | FLAT 29 | FLAT 29 |
| `ref_obj / struct_var / module_inst` | FLAT 50 | FLAT 50 | FLAT 50 |
| `ref_obj / struct_net / module_inst` | FLAT 9, TAGGED 1 | same | same |
| `ref_obj / logic_net / module_inst` | FLAT 3, TAGGED 7 | same | same |
| `ref_obj / array_var / module_inst` | FLAT 3 | same | same |

One class diverges, it is the class §2a exit 2 names, and it is the class the
judge stopped on.

### 2d. WHAT THE FLATTEN IS **NOT** RESPONSIBLE FOR

This is the half the first cut got wrong, and it is decoded in Surelog's own
source rather than inferred.  `hier_path::Root_value`, the hung `ref_typespec`
(r10earl114's § `patHierPathRootTs114`) and a select constant's `vpiParent` are
written by `CompileHelper::compileSelectExpression`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5455-5496`) at
COMPILE time, `if (instance && (reduce == Reduce::Yes))`.  That has nothing to
do with `cont_assign::DeepClone` and fires whether or not the pattern is ever
flattened — **golden carries `Root_value` on the `hier_path`s INSIDE its
`tagged_pattern`s** (`sig115`'s `RV=array_var` on r10earl115's `p3_fence115`
x7 cell, both views).  `hier_path::Compare` READS `Root_value`, so dropping it
is an AWAY on a judged field.  §6c is what that cost.

---

## 3. THE THREE CANDIDATE SHAPES, ALL BUILT, ALL MEASURED

The pass brief requires both of its two candidate shapes to be measured before
either is chosen.  Both were BUILT as real binaries and run against golden; the
shipped cut is a third that the wide boundary forced.

**CUT A — suppress our early flatten entirely and rely on the clone flatten**
(`patFlat9 = false`, md5 `fb910456e0afdae5b243908408446a47`).  It is not absurd:
UHDM's own flatten DOES fire on our whole-name cells, and cut A's arm census
shows `q1` c1 and c6 still FLAT.  REFUTED by two independent measurements,
neither of them a line count:

* **it loses r10earl114's landed law.**  Cut A's Earlgrey_0_1/testflags head
  (`HEAD_CUTA_Earlgrey_testflags.cmp`) is a `ref_typespec` on the `hier_path`
  `tl_h_i[0].a_valid` at `tlul_socket_m1.sv:109` with **`RHS: <null>`** — the
  singular SafeCompare naming OUR missing object.  That `ref_typespec` is
  written by `flattenPatternCaRhs`'s § `patHierPathRootTs114` site, which cut A
  never calls.  A landed law goes AWAY.
* **it moves an arm cell away from golden.**  Arm `q1_lhs116` cell c5 (a
  `wire`-declared gen-local struct): golden FLAT, pristine FLAT, **cut A
  TAGGED**.  Surelog models a `wire`-declared packed struct as a `struct_var`
  and flattens it; OUR Lhs actual there is a `logic_net` (a pre-existing,
  unrelated divergence — §7 R3), so UHDM's clone flatten does not fire on our
  side where it fires on golden's.  Cut A is hostage to a field this law does
  not own.

**THE FIRST CUT — clone the bail condition onto the whole site**
(md5 `f0b1d2e57f85587e588e04e40aa26176`).  One conjunct on `patFlat9`, which
gated both the flatten AND `flattenPatternCaRhs`.  It cleared the head to 36
lines, scored `AWAY 0 / MOVED-WRONG 0` on all eight of this pass's arm/views and
on both corpora in this pass's own two families — **and the wide boundary
convicted it** (§6c): it dropped `hier_path::Root_value` on every non-flattened
operand, which §2d says golden carries.

**CUT C — narrow ONLY the flatten** (SHIPPED, md5
`50c2e7ca6b5d392f177d89f98e9dba64`).  The `StructuredAssignmentPattern` gate is
split in two: `patStruct9` keeps the old reach and still runs
`flattenPatternCaRhs` (which now descends through a `tagged_pattern` wrapper to
reach the `hier_path` underneath), while `patFlat9` — `patStruct9` AND the Lhs
is an `ExpressionKind::NamedValue` — gates `reemitting` (the flatten itself) and
the two things that exist ONLY because of the flatten: the arena orphan
(r10earl113) and r10earl115's element-unbind record.  It takes r10vearl115's
`w1_memlhs` and `w4_selmem` from a head to FULLY CMP-EQUAL, which the first cut
did not.

---

## 4. THE LAW

> **§ `patCaFlatLhsWholeName116`.**  An assignment-pattern continuous assign in
> a generate scope is pre-flattened by this emitter ONLY when its Lhs is a
> WHOLE-NAME reference.  A SELECT Lhs (`arr[i] = '{…}`, `arr[i][j] = '{…}`) and
> a MEMBER Lhs (`s.sub = '{…}`) keep their `tagged_pattern` operand list,
> because `cont_assign::DeepClone` cannot answer `Actual_group<struct_var>` for
> either and never calls `ExprEval::flattenPatternAssignments` on them.
>
> **The `hier_path` work under the wrapper is NOT part of the flatten** and
> keeps its old reach: `Root_value`, the hung `ref_typespec` and the select
> constants' `vpiParent` are written by `compileSelectExpression` at compile
> time, and golden has them on the un-flattened carrier too.

### STATED GATE == CODE GATE

**STATED:** `patStruct9` — the continuous assign is emitted in the gen-scope arm
of `emitBlock`, its Rhs is a STRUCTURED assignment pattern and its Lhs type is a
packed struct (the pre-existing three halves) — still drives
`flattenPatternCaRhs`.  `patFlat9` = `patStruct9` **AND the Lhs is a whole-name
reference (not a select, not a member access)** drives `reemitting`, the
`pendingPatternOrphans` push and r10earl115's record.

**CODE:** `bool patStruct9 = <the three old halves>;` and `bool patFlat9 =
patStruct9 && stripImplicitConv(ae.left()).kind == ExpressionKind::NamedValue;`
`flattenPatternCaRhs`'s operand loop and its `fix()` recursion unwrap a
`tagged_pattern` to its `Pattern()`.  There is no condition in the code that is
absent from the prose and none in the prose that is absent from the code.

### the fences, each of them a measured cell

| fence | what it keeps out | the cell that measures it |
|---|---|---|
| (a) the SITE (`patStruct9`'s own three halves, untouched) | every carrier we never pre-flattened — the POSITIONAL pattern, the `always_comb`/`initial` pattern, the plain Rhs, the module-scope CA | `q2` d1/d2/d3/d4/d8, all UNCHANGED |
| (b) `NamedValue` on the FLATTEN | a whole-name Lhs, which golden DOES flatten — the AWAY risk | `q1` c1 (gen-local struct var), c5 (gen-local struct NET), c6 (module-scope var written from a gen scope = r10earl115's fence (d)); all three UNCHANGED and all three golden-FLAT |
| (c) the SPLIT — `patStruct9`, not `patFlat9`, gates `flattenPatternCaRhs` | the loss of `Root_value` / the hung `ref_typespec` / a select constant's parent on the un-flattened carrier | r10earl115's `p3_fence115` x7 and r10vearl115's `w1_memlhs` / `w4_selmem`, whose `RV=array_var` the first cut dropped and this cut keeps — §6c |
| (d) the pattern kind (`StructuredAssignmentPattern`, pre-existing) | a POSITIONAL pattern, where the operand list is untagged on BOTH sides and §2b's operand-loop bail lives | `q3` e1–e5 — all five UNCHANGED, on both sides, with golden's own `OPK` reproduced exactly |

### the hypotheses this pass REFUTED

| candidate | refuted by |
|---|---|
| "golden's flatten bailed at a non-tagged operand at 241" (the brief's framing) | `sig116` on golden: all TEN operands at 240:29-251:6 are `tagged_pattern`s.  The function was never called |
| "the axis is the SCOPE (gen vs module)" | the head row's own histogram: `ref_obj/struct_var/module_inst` 50 cells FLAT in golden, and `bit_select/array_var/gen_scope` TAGGED — the scope does not separate them, the Lhs shape does |
| "the axis is the pattern's operand mix" | `q3` e1–e5: five operand mixes under a whole-name Lhs, golden flattens all five, we match all five, pristine and patched |
| "suppress the early flatten and let the clone do it" (cut A) | §3 — a landed law goes AWAY on the corpus head, and arm `q1` c5 moves AWAY |
| "one gate on the whole site is enough" (the first cut) | §6c — the wide boundary, on nine arms of five earlier passes |
| "a `struct_net` Lhs behaves like a `struct_var`" | `q3` e6/e7: golden leaves a gen-local `struct_net` target TAGGED (exit 2 again) and we flatten it — §7 R2, deliberately left |
| "the def listing is inert for this law" | every arm's PLAIN view moves: golden never flattens before elaboration, and this law is an EMISSION-time gate |

---

## 5. THE CORPUS CENSUS AND THE PREDICTION

`censweep116.sh` runs `sig116` over every database of all four sweeps with an
ACCOUNTING PASS on each (surelog LISTED 1573 / PROCESSED 956 / SKIPPED 617 /
TOOLFAIL 0; uhdm2rtlil LISTED 1462 / PROCESSED 1358 / SKIPPED 104 / TOOLFAIL 0 —
identical for the pristine and the patched sweep), and **the two sweeps' GOLDEN
halves are asserted byte-identical before anything is scored** (`cmp -s`: they
are, for both corpora).  `cen116.py` joins them as a MULTISET per database.

| corpus | family | TO-GOLDEN | AWAY | MOVED-WRONG | NOGOLD-MOVED | SAME_AGREE | STILLWRONG |
|---|---|---|---|---|---|---|---|
| surelog | **FX** | **2** | **0** | **0** | **0** | 54 | 1 |
| surelog | **F0** | **2** | **0** | **0** | **0** | 31 | 1 |
| uhdm2rtlil | **FX** | 0 | **0** | **0** | **0** | 74 | **0** |
| uhdm2rtlil | **F0** | 0 | **0** | **0** | **0** | 56 | **0** |

The two moved keys are `240:29-251:6 | hrsp_fifo_i` in `testflags/Earlgrey_0_1`
and in `default/Earlgrey_0_1`, each carrying **29 payload copies** (the 29
unrolled `gen_idrouting` instances), `TAGGED` on golden, `FLAT` on the pristine
and `TAGGED` on the patched binary.  The single `STILLWRONG` is §7 R1.

**AND THE SAME CORPUS IS RE-SCORED IN r10earl115's FAMILY**, because that is the
family the first cut broke: `cen115corpus.py` over `sig115`'s census of all 956
surelog databases of both sweeps (`CENSUS115_sl.txt`):

```
PX  TOGOLD=10  AWAY=0  MOVEDWRONG=0  NOGOLD_MOVED=0  SAME_AGREE=169998  STILLWRONG=2311
P0  TOGOLD=4   AWAY=0  MOVEDWRONG=0  NOGOLD_MOVED=0  SAME_AGREE=108879  STILLWRONG=118
ROWS WITH MOVED CELLS (both families): 1 — testflags/Earlgrey_0_1
```

The `STILLWRONG` counts are byte for byte r10earl115's own R1/R2/R3 residues,
unchanged by this pass.

### THE PREDICTION, made from the PRISTINE databases FIRST

`predict116.py` reads only the PRISTINE sweep's censuses — it never sees a
patched database — and applies the law's gate in UHDM terms (gen_scope +
cont_assign + assignment-pattern Rhs with NO tagged operand + Lhs kind not
exactly `ref_obj`).  `PREDICT_sl.txt` / `PREDICT_u2r.txt`:

```
surelog     CANDIDATE cells (upper bound)          : 58
            CANDIDATE rows                         : 2
              default/Earlgrey_0_1-71da2fd7    cells=29
              testflags/Earlgrey_0_1-71da2fd7  cells=29
            GOLDEN-CONFIRMED cells (golden TAGGED) : 58   (rows 2)
            FENCED-KEEP cells (whole-name, stay flat): 62 in 6 rows
uhdm2rtlil  CANDIDATE cells 0, rows 0, over 1358 databases
```

**THE CELL COUNT IS AN UPPER BOUND AND THIS IS STATED, NOT HIDDEN.**  A
POSITIONAL pattern is emitted with untagged operands too and is
indistinguishable from an already-flattened keyed one in the pristine database —
arm `q2` d2 is a real instance of that pair — so a positional cell counts as a
candidate here and does not move.  In this corpus the ambiguity is empty: every
one of the 58 candidates is GOLDEN-CONFIRMED.  **The predicted ROW set is
exactly what `byteverify.sh` measured** (§6), including `default/Earlgrey_0_1`,
whose cmp log is byte-identical but whose DATABASE moves.

---

## 6. THE GATES — ALL GREEN

Both binaries were built from THIS pass's own worktree at a clean `65d82256`
and frozen `chmod 555` BEFORE any sweep; every `cmds.txt` in all four workdirs
was audited BY BINARY PATH — the two control workdirs name
`/tmp/r10earl116_bin/pristine` in all 2981 slang invocations and the two patched
workdirs name `/tmp/r10earl116_bin/cutC` in all 2981, one distinct path per
workdir pair and no other.

| gate | result |
|---|---|
| (1) build both, md5s | pristine `4712b6510fb09e231f72919d866820c9` (byte-identical to the main tree's `build/slang-uhdm`), patched `50c2e7ca6b5d392f177d89f98e9dba64` |
| (2) goldens | **23 PASS / 0 FAIL** on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| (3) uhdm2rtlil, testflags AND default | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2** on both binaries, identical histograms; `ct8rows` **PASS** against the committed baseline AND against this pass's own pristine control, in BOTH modes |
| (4) surelog, `--mode both`, 1588 rows | identical status histograms on both binaries (default CMP_EQUAL 471 / SLANG_REJECT 283 / SURELOG_FAIL 25 / CMP_NOTEQUAL 10 / DEFERRED 5; testflags CMP_EQUAL 466 / SLANG_REJECT 284 / SURELOG_FAIL 23 / CMP_NOTEQUAL 9 / DEFERRED 5 / NO_DATABASE 3 / UNTRANSLATABLE 2 / TIMEOUT 1 / NO_UHDM 1); `ct8rows` **PASS — 0 differing rows** — against the committed baseline AND against the pristine control.  **NO ROW CONVERTED**, in either direction |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358**; surelog **MOVERS 3 / 956** — the two rows `predict116.py` named from pristine data (`default/Earlgrey_0_1`, `testflags/Earlgrey_0_1`) plus `default/Scoreboard`, **the documented ~50/50 parallel-parse COIN**: its ORDER-BLIND whole-dump diff is TWO lines, being one header line on each side naming the workdir path, ZERO content, and its `uhdm-cmp` log is BYTE-IDENTICAL to the pristine one.  SELFCHECK flagged 1357/1358 and 955/956, so the comparator can see |
| rowheads | **Earlgrey_0_1 testflags 92 → 36 cmp lines, ONE head, on a DIFFERENT object**; every other row unchanged and its cmp log **byte-identical**: SeqDriver 55/55, SimpleUVM at the depth artifact, Scoreboard/default 95, MiniAmiq 55/55, BuildUVMPkg 33/33, Earlgrey_0_1 default 31, Rggen/default 0 |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, uhdm2rtlil **ok=8 changed=0**; `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs, by name | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c` — all SAME as pristine in both modes; `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**, both pins met (10 pins, all SAME) |
| the four slang-fenced tests | never dispatched; no probe file in this directory spells any of the four outside `canaudit.sh`'s own `FENCED=` line |

### 6a. THE TWO BYTE MOVERS, ATTRIBUTED

`attrib116.sh` (r10earl114's sectioned, path-normalised, ORDER-BLIND whole-dump
diff, whose three-region cut keeps the weaklyReferenced TAIL out of the count)
on both moving databases (`ATTRIB_Earlgrey.txt`).  Every line of both sides is
this law, and the field the first cut lost is visibly KEPT:

```
testflags   ORDER-BLIND 21074, all in ONE ELAB section
  ADDED    1160 \_tagged_pattern:            <- the wrappers golden has
            783 \_operation:  580 |vpiOperand:  290 |vpiPattern:
            290 |vpiTypespec: + 290 \_ref_typespec: (…gen_idrouting[N])
            203 |vpiExpr: + 203 \_struct_var: (…drsp_fifo_o)
  REMOVED     0 tagged_pattern of any kind
            203 |vpiExpr: + 203 \_struct_var: (…drsp_fifo_o)   <- the SAME 203
            116 x7 \_hier_path: (drsp_fifo_o.d_{opcode,param,size,sink,data,user,error})
                   against 145 x7 in the pristine — FEWER stray copies (R5)

default     ORDER-BLIND 14174, all in ONE ELAB section
  ADDED     870 \_tagged_pattern:  290 \_ref_typespec:  203 |vpiExpr:
  REMOVED     0 tagged_pattern;   203 |vpiExpr:  (the SAME 203)
```

`|vpiExpr:` is the dump's name for `hier_path::Root_value`.  It appears **203
times on the added side and 203 on the removed side in both modes** — the edge
is re-parented under the tagged wrapper and NOT dropped.  The first cut's
attribution (`ATTRIB_FIRSTCUT.txt`) has the same 203 on the REMOVED side and
**none** on the added: that is §6c in one line.

### 6c. THE REGRESSION THE WIDE BOUNDARY CAUGHT, AND THE FENCE IT BOUGHT

The first cut put the new conjunct on `patFlat9`, which gated BOTH the flatten
and `flattenPatternCaRhs`.  It cleared the head, it scored `AWAY 0 /
MOVED-WRONG 0` on all eight of this pass's own arm/views and on both corpora in
BOTH of this pass's families — **and the wide boundary convicted it anyway**,
because it re-scores every OTHER pass's arms in THEIR family:

```
first cut  f0b1d2e5...   in r10earl115's PX family, on the nine arms the
                         boundary flagged:
   p3_fence115  elab AWAY 6 MOVEDWRONG 6   plain AWAY 12
   s1_scope113  elab AWAY 6 MOVEDWRONG 6   plain AWAY 12
   t4_fence114  elab AWAY 6 MOVEDWRONG 6   plain AWAY 12
   v2_hier112   elab AWAY 12 MOVEDWRONG 6  plain AWAY 18
   v3_lhs113    elab AWAY 4 MOVEDWRONG 12  plain AWAY 16
   va1_lhs115   elab AWAY 12 MOVEDWRONG 40 plain AWAY 52
   w1/w3/w4     elab MOVEDWRONG 4/8/12     plain AWAY 4/24/12
final   50c2e7ca...   AWAY 0 / MOVED-WRONG 0 / NOGOLD-MOVED 0 on ALL of them,
                      in BOTH r10earl115 families and in BOTH of this pass's
```

Read off the census rows themselves (`sig115`'s `RV` column), every one of those
cells is the same thing: golden's `hier_path` at r10earl115's `p3_fence115` x7
cell carries `RV=array_var`, the pristine binary carries `RV=array_var`, and the
first cut carried **`RV=<null>`** — `hier_path::Root_value`, a field
`hier_path::Compare` READS, dropped on legal SV.  The corpus attribution of the
first cut says the same at scale: its order-blind whole-dump diff REMOVED **203
`|vpiExpr:` edges** (`ATTRIB_FIRSTCUT.txt`).  §2d is the decode that explains
why, §4's fence (c) is the fix, and with it `w1_memlhs` and `w4_selmem` go from
a head to **0 cmp lines / 0 heads, fully CMP-EQUAL**.

### 6b. THE WIDE BOUNDARY

`widerun116.sh` stages a COPY of the whole committed `tools/probe` tree (plus
this pass's own arms), lists every `.sv`/`.v` at ANY depth, filters the four
fenced names out of the list BEFORE a single child runs (the list is read from
`canaudit.sh`'s own `FENCED=` line, so the filter cannot drift from the audit),
and compares the workdir-normalised `uhdm-dump` of both frozen binaries in BOTH
views.

```
LISTED (BOUNDARY_WIDE.listsummary): 5127     FENCED-NAME HITS IN THE LIST : 0
PROCESSED=5127  identical=9834  DIFFERING=28  no_output=392
PROCESSED == LISTED (5127), every listed file with exactly its four invocations
rc by side:  A/0 9471  A/3 376  A/4 391  A/139 16
             B/0 9471  B/3 376  B/4 391  B/139 16   <- perfectly SYMMETRIC
```

**The 28 differing cells are 14 arm files × 2 views**: this pass's own four, and
ten belonging to r10earl113, r10earl114, r10earl115, r10vearl112, r10vearl113
and r10vearl115.  **Every one of the ten is re-scored in the family of the pass
that OWNS it** (`BOUNDARY_arms.txt`): r10earl115's `PX` and `P0` — AWAY 0,
MOVED-WRONG 0, NOGOLD-MOVED 0, TO-GOLDEN 100 in `PX` — and again in this pass's
`FX`/`F0`.  This pass's own four arms are re-scored in r10earl115's families
too, with the same verdict.  r10earl110's and r10earl111's arms are not in the
differing list at all, so those laws are untouched by construction.  No file
differs in only one view and no arm rejects on one binary and not the other; the
16 `rc=139` segfaults are the same 16 on both sides.

---

## 7. RESIDUES, and R0

* **R0 — THE UNFOLDED GENVAR IN A PATTERN OPERAND'S SELECT INDEX, READ not
  predicted.**  The patched Earlgrey_0_1/testflags head is the `VpiIndex` of the
  `bit_select` on `gen_idrouting[0].hfifo_rspvalid` inside golden's
  `tagged_pattern` at `tlul_socket_m1.sv:241:32`: golden a folded `constant`
  (`vpiDecompile:0`, `UINT:0`, `vpiSize:64`, `vpiConstType:9`), ours a
  `ref_obj('i')` bound to the gen instance's genvar `parameter`.  It is
  PRE-EXISTING, not created here — `HEAD_BEFORE_Earlgrey_testflags.cmp`'s RHS
  shows the same unfolded `ref_obj` under the pristine binary's flattened
  operand, one level below where the judge then stopped.  It is r10earl112's
  genvar-value family, one carrier over: the same file FOLDS the genvar in
  `tl_h_i[i]` at line 109 (a hier_path element's index) and does not fold it in
  `hfifo_rspvalid[i]` at 241 (a bit-select on a packed vector).
  `HEAD_AFTER_Earlgrey_testflags.cmp` holds it.
* **R1 — THE DEF LISTING NEVER FLATTENS, AND WE STILL DO.**  The `default` mode
  runs Surelog WITHOUT `-elabuhdm`, so `cont_assign::DeepClone` never runs and
  golden's operand list is `TAGGED` for EVERY Lhs shape.  That is the one
  `STILLWRONG` cell of §5: `default/Earlgrey_0_1 | 108:26-119:6 | hreq_fifo_i |
  ref_obj | struct_var`, golden TAGGED against our FLAT, identical before and
  after.  The law shipped here fixes the select-Lhs half of it in both views;
  the whole-name half needs a VIEW-gated suppression (flatten in the elaborated
  emission only) and is a law of its own, with the whole def listing as its
  regression surface.  It cannot be reached by widening this gate — widening it
  is cut A, and §3 says what cut A costs.
* **R2 — THE `struct_net` Lhs.**  Arm `q3` cells e6/e7: a gen-local target
  Surelog models as a `struct_net` fails §2a exit 2 exactly as a select does, so
  golden leaves it TAGGED and we flatten it.  Not shipped, because Surelog's
  `struct_var`/`struct_net` choice is not a function of the slang symbol kind —
  arm `q1` c5's `wire`-declared struct is a `struct_var` in golden while `q3`
  e6's plain variable is a `struct_net` — so there is no emission-time predicate
  for it.  Two measured cells, no corpus population (the corpus's gen-scope
  population is `struct_var` 29 and `array_var` 29 and nothing else).
* **R3 — OUR `wire`-DECLARED STRUCT IS A `logic_net`.**  Arm `q1` c5: golden's
  Lhs actual is a `struct_var`, ours a `logic_net`.  Pre-existing, unchanged
  here, and the reason cut A could not be trusted (§3).
* **R4 — THE NEW ARMS' OWN HEADS ARE NOT THIS LAW'S.**  None of `q1`–`q4` goes
  to 0 cmp lines (460, 79, 58, 58) and **the cmp log is byte-identical between
  the two binaries on all four**.  Each arm's head is an unrelated pre-existing
  divergence above this field — `q4`'s is a module-scope `logic_net` shadow of
  an unpacked array of packed structs in the DEF listing.  The new arms'
  instrument is the CENSUS; the arms that go to fully CMP-EQUAL here are
  r10vearl115's `w1_memlhs` and `w4_selmem`.  Stated rather than dressed up.
* **R5 — the MULTIPLICITY residue** (r10earl112's R6 / r10earl115's R1) is
  unchanged in kind and smaller in size: on `q1`/`q3` the patched tree's payload
  set goes from `{<null>, array_var}` to `{array_var}` at the `NOGOLD_MOVED`
  keys, i.e. fewer stray bare copies, in the direction r10earl115 named.
* **R6 — r10earl110–115's laws are untouched**, re-scored by the wide boundary
  over every committed arm and, for the nine it flagged, in r10earl115's own two
  families with AWAY 0 / MOVED-WRONG 0.

---

## 8. FILES

| file | what it is |
|---|---|
| `sig116.cpp` | the census: one row per assignment-pattern `operation` in the LIVE design (a `module_inst`/`gen_scope_array` walk, plus the `AllModules` def listing), with the Lhs kind, the Lhs `Actual_group` kind, the scope, the generate depth, the carrier, the operand count, the tagged-operand count and the sorted operand-kind multiset.  Prints its own `CENRC 0` accounting line |
| `sig116.py` | the TWO-FAMILY arm scorer (`FX` the law's surface, `F0` the coarse key) with SHAPE `TOGOLD`/`AWAY`/`MOVEDWRONG`/`STILLWRONG`/`NOGOLD_MOVED` |
| `cen116.py` | the same scorer over a whole-corpus census, per database, naming the rows whose cells moved |
| `predict116.py` | the BY-ROW mover prediction from PRISTINE censuses only, with its upper-bound caveat stated in the code |
| `censweep116.sh` | the corpus sweep driver with its ACCOUNTING PASS (LISTED / PROCESSED / SKIPPED / TOOLFAIL) |
| `grid116.sh`, `TOPS.txt` | the arm grid driver (rc recorded per producer, children `</dev/null`, `-top` from `TOPS.txt`, `CENRC` asserted) and its `-top` table |
| `q1_lhs116.sv` | THE Lhs-SHAPE AXIS: whole-name var / select on a module array / select on a gen-local array / member Lhs / whole-name NET / module-scope target from a gen scope / 2-D select |
| `q2_car116.sv` | THE CARRIER AXIS and THE DEPTH AXIS: module scope, positional, `always_comb`, `initial`, depth 2, generate-IF, gen-local at depth 2, plain Rhs |
| `q3_mix116.sv` | THE OPERAND-MIX AXIS: the `flattenPatternAssignments` bail at a constant/operation operand in first, middle and last position, plus `default:` keys, a nested pattern, and the same mixes under a select Lhs |
| `q4_head116.sv` | THE HEAD REPRODUCER: `tlul_socket_m1.sv:240-251` cut to three members, with the array element also feeding an instance port |
| `attrib116.sh`, `secattr116.py` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution (the weaklyReferenced TAIL is never counted) |
| `wide116.sh`, `widerun116.sh` | the wide boundary over every `.sv`/`.v` in `tools/probe` at any depth, both views, both binaries |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the landing gates (copied verbatim from their owning pass dirs) |
| `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp` / `HEAD_CUTA_*.cmp` | the official `uhdm-cmp` output on the head row, on the pristine, the shipped and the cut-A binaries |
| `ARM_*_BEFORE.cmp` / `ARM_*_AFTER.cmp` | the official `uhdm-cmp` output on each arm's elaborated view, both binaries — including the two that go to 0 |
| `GRID.r10earl116.txt`, `CALIB.r10earl116.txt` | the arm/view two-family score with its per-cell moved rows, and its golden-vs-golden calibration |
| `BOUNDARY_arms.txt`, `BOUNDARY_arms_FIRSTCUT.txt` | the two-family re-score, in r10earl115's OWN families, of every arm the wide boundary flagged — on the shipped binary and on the FIRST CUT (the AWAY that bought fence (c)) |
| `CENSUS_sl.txt`, `CENSUS_u2r.txt`, `CENSUS115_sl.txt`, `PREDICT_sl.txt`, `PREDICT_u2r.txt` | the corpus census scores in both this pass's family and r10earl115's, and the frozen prediction |
| `ATTRIB_Earlgrey_*.txt`, `ATTRIB_FIRSTCUT.txt`, `ATTRIB_Scoreboard_coin.txt` | the order-blind whole-dump attribution of the two moving databases, of the FIRST CUT's `|vpiExpr:` loss, and of the documented Scoreboard/default coin |
| `BOUNDARY_WIDE.*` | the wide boundary's independent accounting (`.out`), tally, per-side rc histogram, differing list, and the listed-file summary by directory |
| `cen115corpus.py` | the corpus re-score in r10earl115's OWN two element-binding families, keyed per database — the instrument that would have caught the first cut without the arms |

**Build the C++ instrument with**

```
g++ -O2 -std=c++17 sig116.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o sig116
```
