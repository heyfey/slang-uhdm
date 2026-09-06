# r10earl105 — § `genCaTopLoopParamPaCopy105`: an elaborated TOP-LEVEL loop-generate cont-assign substitutes a CLONE of the parameter's own `param_assign` Rhs constant, at any instance depth

Everything in this directory is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

`Earlgrey_0_1` **testflags** went from **50 cmp lines / 1 head to 26 / 1** — the
head OBJECT at `pinmux.sv:176` is gone.  `Earlgrey_0_1` **default**'s head log
is **byte-identical**.  Two databases moved by the law and one by the recorded
coin; the census scores **AWAY-GOLDEN 0 / MOVED-WRONG 0 / TO-GOLDEN 238** on
surelog and **0 / 0 / 0** on uhdm2rtlil.

* BASE COMMIT `cd1e4c0a`, branch `auto5h`.  Worktree `/tmp/wt_r10earl105`.
* Pristine binary md5 `f03b9172df4dcc0900ab7af35d35ffa5`, patched
  `44486814fbddd146e2af71c4fddc0310`.  Both frozen `chmod 555` at immutable
  paths before any sweep; every `cmds.txt` audited BY BINARY PATH (**0 of 6070
  name the main-tree binary**).
* Production diff: `src/ExprEmit.cpp` only (+222 / −2 — one helper, one flag,
  two arms in the existing gen-scope loop fold).  Nothing else in `src/` or
  `include/` is touched.  `slang` is NOT patched.  `results/*.csv` were READ
  ONLY.  `GOLDEN_DEFER` unset throughout.

---

## 1. THE HEAD, and its OWNER, decoded before a line of law was written

`rowheads.sh` on this pass's **own pristine build** (not carried forward):
`Earlgrey_0_1` **testflags 50 cmp lines / 1 head**, **default 31 / 1** — and the
two are DIFFERENT OBJECTS.  Only testflags is this pass's.

```
LHS (golden)  constant  176:43-176:64
              |vpiParent  param_assign 53:56-54:59
              |vpiDecompile 32'b11111111111111111111111111111111
              |vpiSize 32   BIN:1111…   vpiConstType 3
              |vpiTypespec ref_typespec {work@top_earlgrey.u_pinmux}
                           |vpiActual  int_typespec  LOC-LESS, UINT:1
RHS (ours)    ref_obj   176:43-176:64
              work@top_earlgrey.u_pinmux.gen_mio_out[0].MioPeriphHasSleepMode
              |vpiActual parameter …u_pinmux.MioPeriphHasSleepMode 53:56-53:77
```

```systemverilog
pinmux.sv:53   localparam logic [pinmux_reg_pkg::NMioPeriphOut-1:0] MioPeriphHasSleepMode
pinmux.sv:54                    = {pinmux_reg_pkg::NMioPeriphOut{1'b1}};
pinmux.sv:169  for (genvar k = 0; k < NMioPads; k++) begin : gen_mio_out
pinmux.sv:176    assign sleep_mux = $bits(sleep_mux)'({MioPeriphHasSleepMode, 1'b1, 1'b1, 1'b1});
```

**THE DIFFERING EDGE.**  The two sides are an `Operands` ELEMENT of the concat
(`op33`) under the `$bits` cast (`op67`), and they are different KINDS, so
`BaseClass::Compare` fails at `VpiType` and the whole object is the head.  The
substituted constant's TYPESPEC — r10earl104's loc-less `int_typespec UINT:1` —
is **NOT reachable on the pristine binary**: Compare stops before
`constant::Compare` reads `Typespec`.  It becomes reachable the moment we emit a
constant, and it must then match, which is why this pass had to get it right
rather than merely emit *a* constant.

### The owner (`own105.cpp`, `OWNER.r10earl105.txt`)

The head print names the object, not who holds it, and here the `vpiParent`
chain is **deliberately misleading**: Surelog's substituted constant keeps the
`param_assign` it was cloned from as its parent, so the dump shows the head under
a `param_assign` 120 lines away from the assignment that holds it.  `own105`
walks the whole arena for every VECTOR or SINGULAR container that actually holds
the object.  **ONE holder, and it is the same one on both sides:**

```
golden  constant#640534   <- operation op33 176:42-176:84  Operands[0]
                          <- operation op67 176:24-176:85     (the $bits cast)
                          <- cont_assign   176:12-176:85
                          <- gen_scope       work@top_earlgrey.u_pinmux.gen_mio_out[0]
                          <- gen_scope_array work@top_earlgrey.u_pinmux.gen_mio_out[0]
                          <- module_inst     work@top_earlgrey.u_pinmux
ours    ref_obj#500233    <- the IDENTICAL chain, object for object
```

So this is an **Operands ELEMENT** question — not a container-size question, and
not a typespec question.

**COUPLING TO r10earl104, ANSWERED.**  The substituted constant does **not**
depend on earl104's positive determination.  Surelog clones *whatever the
`param_assign` Rhs holds*: `g1_enc105`'s `PBIN` / `PHEX` (no replication, no
mint) are copied with their DECLARED `logic_typespec`, and only `PREPL` /
`MioPeriphHasSleepMode` carry the loc-less `int_typespec` because THEIR
`param_assign` does.  **earl104's law is not consulted by this pass and is not
touched by it** — its own arms are re-run in §7 and score AWAY 0 / MOVED-WRONG 0,
with `vb2_genfor` and `vb4_instarr` still **0 cmp lines / 0 heads**.

---

## 2. THE SURELOG DECODE — read out of the source, not guessed

`CompileHelper::compileExpression`, the simple-identifier arm,
`Surelog/src/DesignCompile/CompileExpression.cpp:2918-2975`:

```cpp
if (component && (result == nullptr))
  if (VectorOfparam_assign *pas = component->getParam_assigns())
    for (param_assign *param_ass : *pas)
      if (param_ass->Lhs()->VpiName() == name)
        if ((reduce == Reduce::Yes) || (paramFromPackage && const Rhs))
          if (substituteAssignedValue(param_ass->Rhs(), compileDesign)) {
            result = UHDM::clone_tree(param_ass->Rhs(), &elaboratorContext);
            result->VpiParent(param_ass);                    // the misleading parent
            fC->populateCoreMembers(child, child, result);   // the READ's span
          }
…
if (result == nullptr) { ref = s.MakeRef_obj(); … }           // what WE emit
```

A **CLONE** of the parameter's own `param_assign` Rhs, re-parented at the
`param_assign` and re-anchored at the READ's span; the `ref_obj` we emit is that
arm's `result == nullptr` fallback thirty lines below it.  A clone carries the
source constant's **ENCODING** and its **TYPESPEC**.
`substituteAssignedValue` (`CompileExpression.cpp:83`) refuses only a concat /
assignment-pattern operation when `--parameterssubstitution` is off, which it is
not here.

**It is NOT `UhdmWriter::writeCont_assign`** (`UhdmWriter.cpp:2090`), which is
where the family's earlier laws live.  That path reduces a cont_assign Rhs only
when `bindVariable` finds the Lhs, and `bindVariable`'s scope-walking overload
(`CompileStmt.cpp:3089`) switches on `function` / `task` / `begin` /
`module_inst` **only** — from a `gen_scope` it falls through to the enclosing
`module_inst` and NEVER finds a gen-LOCAL declaration, which `sleep_mux` is.
The substitution is the **generate elaboration's**, compiled with
`Reduce::Yes`, and that is also why the DEF view keeps the `ref_obj` on both
sides (measured: `h1`'s DEF row is `SAME` on both binaries).

---

## 3. THE LAW

> **§ genCaTopLoopParamPaCopy105** — In the ELABORATED view, a continuous
> assignment whose home is a **TOP-LEVEL loop-generate body** of a module or
> interface instance substitutes a **BARE** reference to a parameter declared in
> that **instance body** with a **CLONE of that parameter's own elaborated
> `param_assign` Rhs constant** — its `VpiValue`, `VpiSize`, `VpiConstType`,
> `VpiDecompile` and its typespec, re-anchored at the read's span — and **the
> instance's DEPTH does not matter**: a child instance folds exactly like the top
> module.  The clone's typespec is a FRESH object, one per read.

`src/ExprEmit.cpp`, inside the existing gen-scope loop fold
(§ `genCaLoopSelIdxFold21` / § `genCaChildLoopSelFold21`), three pieces:

```cpp
// (a) THE WINDOW: `genCaChildLoopFold21` is already exactly "a TOP-LEVEL loop
//     body in a CHILD instance" (`parentFull == prefix` is the nesting test);
//     the new window is that flag WITHOUT `caLoopSelPos21`.
const bool loopPlainNew105 =
    !genCaLoopParamFold && genCaChildLoopFold21 && !caLoopSelPos21;

// (b) THE FULL CLONE, when the source constant's typespec ref is ALREADY BOUND
//     and its actual is an int_typespec: encoding copied, typespec MINTED
//     FRESH field for field.  Runs in every window.
// (c) THE ENCODING CLONE, for the NEW window when the typespec ref is bound
//     late: the encoding comes from `adjustCopiedParamConst64` (r10earl64's
//     own decode, REUSED) and the typespec is the mint the arm already built.
```

### The fences, each with a witness

| fence | witness |
|---|---|
| **ELAB only** | `h1`'s DEF row is `SAME` on both binaries; every arm's `plain`/DEF rows agree |
| **TOP-LEVEL gen scope only** — a scope NESTED in another keeps the ref | `g4.gen_n.n6`; `ibex_cs_registers.sv:795` `CSR_OFF_PMP_CFG` in `g_pmp_registers.g_pmp_csrs`; `prim_cipher_pkg::PRINCE_SBOX4` in `gen_outer_round[i].gen_inner[j]`; `GenScopeHierPath3` `CHUNK`/`step` in `steps[i].outer[j]` — **19 corpus cells, all still `ref_obj` on both sides** |
| **the parameter's home is the INSTANCE BODY** — a gen-local localparam and every loop GENVAR keep the ref | `g4.n3`; **1544 corpus genvar cells** still `ref_obj` on both sides |
| **the elaborated `param_assign` Rhs must be a CONSTANT** | `rv_dm.sv:104` `DebugHartInfo` (an assignment pattern) and `PRINCE_SBOX4` keep the ref in golden and in ours |
| **the typespec is MINTED, never shared** | sharing removed 4 weakly-referenced tail entries from uhdm2rtlil `read_remux` and 24 from `multiplier`, moving those rows' dump column `match` → `differ`.  Measured, then fixed; the final sweep has **0 differing rows** |
| **the NEW window is answered ONLY by a clone it can build exactly** — no decimal mint is ever newly applied there | without it, r10earl64's `gA_earl64` (`parameter int unsigned P` instantiated as `4'b0010` / `4'h2` / an expression) went MOVED-WRONG 32 |
| **`baseSpellingOk105`** — decline a source constant whose `VpiDecompile` lacks the base prefix its `vpiConstType` requires | our own elaborated `param_assign` Rhs for `gA_earl64`'s `i_bin.P` reads `0010` where golden reads `4'b0010`; `constant::Compare` READS `VpiDecompile`, so copying that spelling would SPREAD another law's defect.  A forgone win, never a regression (residue R3) |

---

## 4. THE READ POSITIONS AND HOMES, MEASURED ON GOLDEN FIRST

Golden **copies the `param_assign` Rhs verbatim** at EVERY operand position of an
elaborated top-level loop-generate cont_assign.  Measured with non-decimal
parameter encodings so a COPY and a MINT are distinguishable:

| position | arm | golden |
|---|---|---|
| plain concat operand under a `$bits` cast (**the head's own shape**) | `h1`, `h2`, `g2.k1`, `g5.p3` | COPY |
| the LONE Rhs | `g2.k2` | COPY |
| a binary operand beside a signal | `g2.k3`, `g5.p1` | COPY |
| a concat operand beside a signal | `g2.ka` | COPY |
| a unary operand | `g2.kc` | COPY |
| a replication COUNT | `g3.m1`, `g5.p6` | COPY |
| a bit-select INDEX | `g3.m2`, `g5.p4` | COPY |
| an indexed-part-select BASE | `g3.m3`, `g5.p5` | COPY |
| a part-select BOUND / an index written as an OPERATION | `g3.m4`, `g3.m5` | COPY |
| a ternary CONDITION / a comparison | `g3.m7`, `g5.p7` | COPY |
| a SYSTEM-CALL argument | `g2.k8`, `g3.m6` | COPY — **we still keep the ref** (`callArgDepth == 0`, residue R1) |

and **keeps the `ref_obj`** for: a GEN-LOCAL localparam (`g4.n3`), every loop
GENVAR, a gen scope NESTED inside another (`g4.gen_n.n6`), and a parameter whose
elaborated Rhs is still an OPERATION.  A **top-level gen-IF** scope (`g4.gen_top_if`)
already substituted before this pass (§ `genCaLpPaCopy`) — the LOOP body was the
outlier, which is exactly what this law repairs.

---

## 5. THE CENSUS — predicted from PRISTINE, then re-scored

`cen105.cpp` censuses **every NODE inside every `cont_assign` Rhs subtree** on
both sides of both corpora, keyed on
`(view, home, cont_assign Lhs fullname, cont_assign span, node depth, node span,
occurrence index)`.  The node SPAN is the join axis because a SUBSTITUTED
constant and the REF_OBJ it replaces carry the SAME span — precisely the edge
this pass moves.  DEPTH is in the key rather than a path because a path is BLIND
below the slot when one side folds a whole subtree (earl56's 107-cell
regression); the occurrence index makes the join a MULTISET join.  The payload
is the node as a **STRING** — for a constant its `VpiSize` / `VpiConstType` /
`VpiValue` / `VpiDecompile` plus the typespec rendered exactly as r10earl104's
census renders one; for a `ref_obj` its `VpiName` and the KIND of its
`Actual_group` (which `ref_obj::Compare` DOES read).

**CALIBRATION FIRST, golden vs golden:** `h1`/`h2`
`agree=102 disagree=0 only_golden=0 only_ours=0`.

**THE PRISTINE POPULATION** (956 surelog + 1358 uhdm2rtlil databases, before a
line of the law was written) — `ELAB | genloop` cells:

| | cells | |
|---|---:|---|
| `constant > ref_obj` (golden substitutes, we do not) | 499 | 261 genvars (**not touched**), 116 `IDW`, 64 `MioPeriphHasSleepMode`, 58 `STIDW` |
| `constant > constant` (we substitute, typespec missing) | 174 | a select position whose ts ref is bound late — **residue R2** |
| `ref_obj > ref_obj` (a DIFFERENT family) | 200 | name / actual, untouched |
| `ref_obj` SAME — **the must-stay floor** | 1642 | 1544 GENVARS + 19 non-genvars, all named in §3 |
| `constant` SAME | 354 | already correct: golden's payload IS the clone |

Every `ELAB|genloop` cell in the surelog corpus **outside Earlgrey_0_1** is a
SAME `ref_obj`, and every one is a GENVAR or a read from a NESTED gen scope
(`GenScopeHierPath3` 63, `CaseDefault` 4, `CarryAdd` 4,
`GenForIfaceLocalparamBound` 1, `GenForIfaceLocalparamNestedGen` 1) — the law's
two home fences cover all 73.  uhdm2rtlil holds **50** `ELAB|genloop` cells and
**all fifty are SAME constants** (`multiplier`, `read_remux`,
`SumOfParametersInNestedForLoops`,
`ParameterInGenScopeInitializedWithLongConstant`).

**PREDICTION, WRITTEN DOWN BEFORE THE PATCHED SWEEPS WERE READ**
(`PREDICT_R0.txt` §4): exactly TWO databases move — `Earlgrey_0_1` default and
testflags; uhdm2rtlil ZERO; no row converts; AWAY-GOLDEN 0 and MOVED-WRONG 0.

**WHAT ACTUALLY MOVED** (`byteverify.sh SELFCHECK=1`):

```
uhdm2rtlil  MOVERS 0 / 1358   PATH_SETS_IDENTICAL, SELFCHECK 1357/1358
surelog     MOVERS 3 /  956   PATH_SETS_IDENTICAL, SELFCHECK  955/956
    ./default/Earlgrey_0_1    02b37834ae6d <- 5b86d1db45c6   PREDICTED
    ./testflags/Earlgrey_0_1  da7542fd91e5 <- 57e778aad5aa   PREDICTED
    ./default/Scoreboard      6e8702880da6 <- 71d51148be4a   THE COIN
```

**The Scoreboard mover is RESUME.md §9's recorded coin, and it is attributed as
one, not asserted to be one**: 92 raw changed dump lines and **ZERO order-blind
(sorted-dump) changed lines**, and `cen105` finds **ZERO** cont_assign parameter
cells in Scoreboard on either side, so this law cannot reach it.

**THE CENSUS RE-SCORED** (`score105.py` prints `GOLDEN-SIDE-IDENTICAL` first and
refuses to score otherwise) — `CEN_corpus_score.txt`:

| | surelog (12 736 cells) | uhdm2rtlil (264) |
|---|---:|---:|
| **AWAY-GOLDEN** | **0** | **0** |
| **MOVED-WRONG** | **0** | **0** |
| TO-GOLDEN | **238** | 0 |
| UNMOVED-GOOD | 10 331 | 260 |
| UNMOVED-BAD | 1 898 | 4 |
| UNREACHABLE / -CHANGED | 269 / **0** | 0 / 0 |
| ADDED / REMOVED | 0 / 0 | 0 / 0 |

and identically `AWAY 0 / MOVED-WRONG 0` on the `--judge` projection.  The 238
TO-GOLDEN cells are the three predicted families and **nothing else**: 116 `IDW`,
58 `STIDW`, 64 `MioPeriphHasSleepMode`.

**THE WHOLE-DUMP ATTRIBUTION AGREES** (`ATTRIB.r10earl105.txt`,
workdir-normalised, sectioned at the `_weaklyReferenced:` marker): **2470 changed
lines in default** (of 4 717 838; BODY 2023 / TAIL 447) and **2534 in testflags**
(of 6 714 445; BODY 608 / TAIL 1926), and **every one** names
`MioPeriphHasSleepMode`, `IDW` or `STIDW`, or the constant / `ref_typespec` /
`int_typespec` that replaces one.  Nothing else in either database moved.

---

## 6. MOVED-WRONG AND AWAY, SCORED IN BOTH COLUMNS

**Among cells the judge can reach: AWAY-GOLDEN 0 and MOVED-WRONG 0** — on both
corpora, on all 14 grid rows in both views, on all 30 of r10earl104's own arm
rows, and on all 25 cells the wide boundary flagged.  The two columns are scored
separately throughout because that is where a pass in this family was last
convicted.

**The FORGONE WINS — STILL-WRONG, not AWAY.**  Each is a cell where golden
substitutes and we still emit *exactly what pristine emitted*: nothing
regressed, a win was declined.

| class | where | why the law declines it |
|---|---|---|
| a `logic` / `bit` VECTOR parameter whose ts ref is bound late | `g1.w_bin/w_hex/w_bit/w_sgn`, `g2.k1/k2/k3/ka/kc`, `g3.m1…m8`, `g4.n1/n2/IFP` | the clone carries a `logic_`/`bit_typespec` with a RANGE subtree this pass does not build; half-copying it would be MOVED-WRONG |
| a SYSTEM-CALL argument | `g2.k8`, `g3.m6` | the arm's pre-existing `callArgDepth == 0` fence, which another law owns (`read_remux`'s call-arg part-select is its recorded counterexample) |
| the 174 select-position cells with a missing typespec | Earlgrey `u_xbar_main.u_sm1_*` | same late-bound typespec ref; the encoding already matches |
| a source constant whose decompile lacks its base prefix | `gA_earl64.i_bin` (8 cells) | `baseSpellingOk105` — our own `param_assign` Rhs reads `0010` where golden reads `4'b0010`; that defect belongs to another law |

---

## 7. THE GRID — `GRID.r10earl105.txt`

7 arms of this pass × {plain, elab} and **all 15 of r10earl104's arms** × 2,
both binaries, each cell scored three-way against golden.

* **This pass's arms — AWAY-GOLDEN 0 / MOVED-WRONG 0 / UNREACHABLE-CHANGED 0 on
  every row.**  `h1_head105` 32/1 → **0/0**, `h2_child105` 25/1 → **0/0**,
  `g5_int105` 25/1 → **0/0** (and 23/1 → 15/1 plain) — the head shape, its
  child-instance twin and the corpus's `int`-parameter shape all CONVERGE.
  `g1`/`g2` gain 2 cells each (the replication-folded parameter), `g3`/`g4` are
  unchanged (residue R1).
* **r10earl104's OWN arms, re-run here — its law is untouched.**  AWAY-GOLDEN 0
  and MOVED-WRONG 0 on all 30 rows; `g1_form104`…`g7_pos104`, `va1`…`va5` all
  keep their pristine cmp line/head counts, and **the two must-stay-CMP_EQUAL
  controls hold: `vb2_genfor` 0/0 → 0/0 and `vb4_instarr` 0/0 → 0/0**
  (`vb1_netrange` 18/1 → 18/1, `vb3_tdefrange` 24/1 → 24/1).
  `g5_gscope104` gains 4 cells and carries 4 UNREACHABLE-CHANGED (see §8).
* **r10earl55's arms** are covered by the wide boundary rather than the grid,
  and that is the stronger statement: they are **byte-identical between the two
  binaries** and therefore absent from the boundary's differing list.

---

## 8. THE BOUNDARY — `BOUNDARY_WIDE.*`, `BOUNDARY_ARMS.txt`

`wide105.sh` compiles **every `.sv` and `.v` under a copy of this worktree's
`tools/probe` at ANY depth** — subdirectory arms included (path depths 5 to 9) —
on both frozen binaries, both views, and byte-compares the workdir-normalised
`uhdm-dump`.  The file list is read on **fd 3** with children `</dev/null`, and
PROCESSED is asserted against LISTED.

```
LISTED=4715   PROCESSED=4715   identical=9027   DIFFERING=25   no_output=378
rc symmetry (A=patched / B=pristine):  rc=0 8667/8667   rc=3 362/362
                                       rc=4 385/385     rc=139 16/16
FENCED=0 — the four slang-fenced names appear 0 times in the list and were
           never dispatched.
```

The 16 `rc=139` per side are the pre-existing probe segfaults recorded since
earl82, identical on both sides.  The gate demonstrably SEES (25 differing
cells): that is its own positive control.

**All 25 differing cells scored against GOLDEN on both binaries
(`BOUNDARY_ARMS.txt`): AWAY-GOLDEN 0 and MOVED-WRONG 0 on every one.**

* **12 cells are this pass's own arms** (`g1`, `g2`, `g5`, `h1`, `h2`) —
  TO-GOLDEN only.
* **`r10earl64repro/gA_earl64.sv` 23/1 → 18/1 and 25/1 → 20/1, TO-GOLDEN 40** —
  r10earl64's own grid, and the reason `adjustCopiedParamConst64` is reused
  rather than re-derived.
* **`r10v64repro/v4_homes64.sv` TO-GOLDEN 36, cmp unchanged 46/1 and 32/1.**
* **`r10v69repro/v5_inst69.sv` TO-GOLDEN 36**, cmp 94/1 → 134/1 and 110/1 →
  150/1: the head OBJECT MOVED FORWARD, from `arr[i].g[7+:8]` at `18:20` to
  `arr[i].g[7 + i+:8]` at `22:20` — the first head cleared and a later one is
  now first.  Line counts are the new head's print size, not distance
  (RESUME.md §9).
* **`r10earl104repro/g5_gscope104.sv` (4 cells), `r10earl_repro/qg21.sv` (2),
  `r10vearl104repro/w4_pos104.sv` (1)** — cells the judge **cannot reach**:
  golden folds the WHOLE cont_assign Rhs to one constant where we keep an
  operation, so `Compare` stops at the Rhs's `VpiType` on both binaries and
  nothing under it is read.  `score105.py` prints them as
  `UNREACHABLE-CHANGED`; the head OBJECT is **the same object, id for id**, on
  both binaries (`g5_gscope104` `constant id:3871`, `qg21` `constant id:391`),
  and the rising line counts are that head's print growing.
* **`r10earl34repro/a2_shape.sv`, `r10vearl95repro/v95a_ctx.sv`** — TO-GOLDEN
  2 and 3, cmp unchanged.

---

## 9. GATES — all green

| gate | result |
|---|---|
| build both, md5s | pristine `f03b9172df4dcc0900ab7af35d35ffa5`, patched `44486814fbddd146e2af71c4fddc0310` |
| goldens, `SLANG_UHDM` exported to the PATCHED binary explicitly | **PASS 23 / FAIL 0** |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags vs committed `results/gate_uhdm2rtlil.csv` | `ct8rows` **0 differing rows** |
| u2r testflags + default vs this pass's OWN pristine sweep | `ct8rows` **0 differing rows** (status AND dump column) |
| u2r `byteverify SELFCHECK=1` | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL |
| surelog vs committed `results/golden_surelog.csv` (1588 rows) | `ct8rows` **0 differing rows — NO ROW CONVERTS** |
| surelog vs this pass's OWN pristine sweep | `ct8rows` **0 differing rows**; status histogram unchanged (471/466 CMP_EQUAL, 10/9 CMP_NOTEQUAL, 283/284 SLANG_REJECT, 25/23 SURELOG_FAIL) |
| surelog `byteverify SELFCHECK=1` | **MOVERS 3 / 956** — 2 PREDICTED BY NAME, 1 the attributed coin |
| canaries (`canaries.sh`) | surelog `ok=52 changed=0`, u2r `ok=8 changed=0` |
| supplementary canaries (`ctcan2.sh`) | **PASS** both corpora |
| canary audit (`canaudit.sh canaries.sh ctcan2.sh`) | `audited=29 UNCOVERED=0 FENCE-BREACH=0` **PASS** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical both modes; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `ReplicationPassedToInstance` | CMP_EQUAL both modes, byte-unchanged (`48d4b425cfca` / `761e1d318376`) |
| wide boundary | PROCESSED 4715 = LISTED, rc symmetric, all 25 differing cells attributed (§8) |
| `cmds.txt` audit BY BINARY PATH | 2981 of 3035 per sweep name the frozen binary; **0 of 6070 name the main-tree binary** |
| `GOLDEN_DEFER` | unset throughout |

**HEADS** (`rowheads.sh`, this pass's own sweeps):

| row | before | after |
|---|---|---|
| **Earlgrey_0_1 testflags** | 50 / 1 | **26 / 1** |
| Earlgrey_0_1 default | 31 / 1 | 31 / 1 (head log byte-identical) |
| SeqDriver, SimpleUVM (both modes) | 338 / 1 | 338 / 1 |
| BuildUVMPkg (both modes) | 29 / 1 | 29 / 1 |
| Scoreboard default | 95 / 1 | 95 / 1 |
| MiniAmiq (both modes) | 106 / 1 | 106 / 1 |
| Rggen default | 0 / 0 | 0 / 0 |

---

## 10. RESIDUES

* **R0 — the next head is named and measured.**  `Earlgrey_0_1 testflags`, 26
  cmp lines / 1 head (`HEAD_AFTER_Earlgrey_testflags.cmp`):

  ```
  LHS (golden)  constant  NO LOCATION   |vpiDecompile:63 |vpiSize:8
                          UINT:63  vpiConstType:9
  RHS (ours)    constant  39:24-39:38   |no vpiDecompile |vpiSize:64
                          UINT:63  vpiConstType:9
  ```

  Same VALUE and same constType; golden's is **loc-less, sized 8 and carries a
  decompiled spelling**, ours is located, sized 64 and carries none.  `own105`
  names the owner: it is the WHOLE Rhs (a SINGULAR `cont_assign` edge, not an
  operand) of

  ```
  cont_assign 39:12-39:38
    > gen_scope work@top_earlgrey.u_padctrl.gen_generic 37:38-40:6
      > module_inst work@top_earlgrey.u_padctrl

  padctrl.sv:37  if (Impl == prim_pkg::ImplGeneric) begin : gen_generic
  padctrl.sv:39    assign warl_mask = AttrDw'(6'h3F);
  ```

  i.e. a CAST-fold in a **gen-IF** scope: golden's folded constant is loc-less,
  sized at the CAST's width (`AttrDw` = 8) and decompiled, ours keeps the cast
  expression's span, the default 64 and no spelling.  A size-and-spelling law
  on a folded constant, one level below this pass's and in a different home
  (gen-IF, not loop).
  `Earlgrey_0_1 default` still stops at `LHS: <null>` on
  `u_pinmux.gen_mio_periph_in[0].data_mux` — a `logic_var` we emit and golden
  does not, at `pinmux.sv:157` — unchanged by this pass.
* **R1 — the `logic`/`bit` VECTOR clone.**  A parameter whose elaborated
  `param_assign` Rhs constant carries a `logic_typespec` or `bit_typespec` is
  declined, because the clone would need that typespec's RANGE subtree rebuilt.
  Measured in `g1_enc105` (6 encodings), `g2_pos105` (12 positions),
  `g3_sel105` (8 select positions) and `g4_home105` (module / port / interface
  homes).  Cost: those arms' cells; corpus cost **zero** — every corpus cell in
  the window is an `int_typespec`.
* **R2 — the 174 select-position cells** in Earlgrey `u_xbar_main.u_sm1_*`
  where we already substitute the right VALUE but emit no typespec.  The
  `param_assign` Rhs's typespec ref is bound late there, so the full clone
  declines; the encoding half cannot help because the encoding already matches.
  Needs the deferred-typespec seam, not this law.
* **R3 — the base-spelling defect this law refuses to spread.**  Our own
  elaborated `param_assign` Rhs for a non-decimal PORT-PARAMETER OVERRIDE reads
  `vpiDecompile:0010` where golden reads `4'b0010` (`gA_earl64`'s `i_bin`, 8
  cells).  `baseSpellingOk105` declines those reads rather than copy the wrong
  spelling into them.  Fixing the `param_assign` Rhs itself would hand this law
  8 more cells for free.
* **R4 — the SYSTEM-CALL argument position.**  Golden substitutes there
  (`g2.k8`, `g3.m6`); the arm's `callArgDepth == 0` fence, which
  § `genCaLoopSelIdxFold21` owns and whose counterexample is `read_remux`'s
  call-arg part-select, keeps us out.  Separating a SYSTEM call's argument from
  a bare USER call's is what that fence needs.

---

## 11. FILES

| file | what it is |
|---|---|
| `cen105.cpp` | the cont_assign-operand census; key = (view, home, ca fullname, ca span, depth, node span, #idx), payload = the node as a STRING |
| `cenrun105.sh` | runs it over a whole `verify_golden.py` workdir, golden path read from each test's OWN `cmds.txt`, every rc logged |
| `score105.py` | the three-way join; asserts the golden side unchanged first; the `--judge` projection; `UNREACHABLE` for keys golden does not hold |
| `own105.cpp` | the owner finder — every VECTOR and SINGULAR container that holds a named object, plus the misleading `vpiParent` chain beside it |
| `grid105.sh` / `TOPS.txt` | per-arm golden + both binaries, uhdm-cmp lines/heads, cen105 three-way |
| `wide105.sh` | the wide boundary (earl104's, renamed) |
| `h1_head105.sv` `h2_child105.sv` | the head's shape in a TOP module and in a CHILD instance — the minimal reproductions |
| `g1_enc105.sv` | the six ENCODINGS a `param_assign` Rhs can carry |
| `g2_pos105.sv` | 12 READ POSITIONS of a bare reference, top module |
| `g3_sel105.sv` | the 8 SELECT / INDEX / COUNT positions with a non-decimal parameter |
| `g4_home105.sv` | the HOMES: module localparam, port parameter, gen-local, package (qualified and imported), interface, nested gen-if, top-level gen-if |
| `g5_int105.sv` | the CORPUS SHAPE — `int` parameters in a child instance's loop body, seven positions |
| `OWNER.r10earl105.txt` | the owner decode, golden / pristine / patched |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the head logs |
| `PREDICT_R0.txt` | the prediction made from pristine databases and the Surelog decode, and the outcome beside it |
| `CEN_corpus_score.txt` | the corpus three-way score, both payloads, plus the TO-GOLDEN families |
| `ATTRIB.r10earl105.txt` | the workdir-normalised whole-dump diff, both modes, sectioned by the weaklyReferenced marker, every changed line by shape |
| `GRID.r10earl105.txt` | this pass's arms and r10earl104's, three-way scored |
| `BOUNDARY_WIDE.*` | tally / listed+FENCED / diff list / rc histogram / rc by side / signals |
| `BOUNDARY_ARMS.txt` | all 25 boundary cells scored against golden on both binaries |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the gate scripts this pass RAN, carried so the audit passes here |
