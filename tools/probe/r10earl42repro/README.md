# r10earl42 — § importedConcatNoMdimReorder42

**THE HEADLINE: the 154-line Earlgrey head is CLEARED and the row ADVANCES.
Our design-wide `vpiReordered` population goes `6 → 0`, landing EXACTLY on
golden's `0`; the operand-ORDER divergence population goes `6 → 0` on a
span-keyed join of 5 254 shared concat/pattern operations; the whole-design
multiset distance falls `308773 → 308767 (−6)`, which is the number the census
PREDICTED BEFORE the edit. Five gates green, ZERO byte movers in the
1 358-database uhdm2rtlil corpus, and the change is ONE token of code
(`!isImported`).**

**And the pass's most useful product is TWO REFUTATIONS of a citation that has
been in this file since the rule was written.** The comment on the reordering
site named `UhdmWriter.cpp:2214` as the Surelog code that reorders a module's
`param_assign`s. That call sits in the CONT_ASSIGN loop and passes a
`cont_assign`'s `Lhs`, and `reorderAssignmentPattern` reverses **only** when
`lhs->UhdmType() == uhdmparameter` — so the cited call **can never reorder
anything at all**. Reading *every* call site instead of the one that was
remembered is what produced the law below. The neighbouring
§ `modParamPatternReorder` carries the same false citation; its gate is
measured-correct and is left alone, but the mechanism it names is corrected in
the code comment and in § 6 here.

---

## 0. THE LAW

> **§ importedConcatNoMdimReorder42 — the multi-dimensional CONCAT reorder is a
> property of a module's OWN DECLARED parameter list. A package localparam
> MATERIALIZED into a module by a wildcard import keeps SOURCE ORDER and
> carries NO `vpiReordered`, no matter how many packed dimensions it has, how
> its outer range runs, or how deeply its concat nests.**
>
> The separating pair is one module, one import, two parameters of the
> IDENTICAL type carrying the IDENTICAL concat (`v42_overfire.sv`):
>
> ```systemverilog
> module mixed42 ...
>   import p42v::*;                          // brings in E0_PKG_CC
>   localparam logic [3:0][31:0] E1_MIX_OWN = {32'h5000_0000, ... };
> ```
> ```
> topModules  work@topv42.u_mix.E0_PKG_CC    golden SOURCE ORDER, no flag
> topModules  work@topv42.u_mix.E1_MIX_OWN   golden REVERSED   + vpiReordered
> ```
>
> `isImported` is a PER-PARAMETER property (`ps.getParentScope() != &body`),
> never a per-scope one — the probe above exists precisely so that a future
> "this scope imports something" reading of the gate cannot pass silently.

### Why, from Surelog's own source — EVERY call site of `reorderAssignmentPattern`

| site | what it passes / how it is gated | can a top-level CONCAT reorder there? |
|---|---|---|
| `CompileExpression.cpp:944` | gated `opType == vpiAssignmentPatternOp` | **no** |
| `CompileExpression.cpp:1015` | gated `opType == vpiAssignmentPatternOp` | **no** |
| `CompileExpression.cpp:1117` | gated `opType == vpiAssignmentPatternOp` | **no** |
| `NetlistElaboration.cpp:286` | gated `opType == vpiAssignmentPatternOp \|\| vpiMultiAssignmentPatternOp` | **no** |
| `NetlistElaboration.cpp:1455` | `lhs` = a port's `Actual_group` (net/port) | **no** — the callee needs `uhdmparameter` |
| `UhdmWriter.cpp:2214` | `lhs` = a `cont_assign`'s Lhs | **no** — same reason |
| `DesignElaboration.cpp:2348` | the overridden-param `complexV` path | yes |
| `DesignElaboration.cpp:2592` | the **"Regular params"** loop — the module's OWN declared parameters, ANY operation value | **yes** |

`reorderAssignmentPattern` itself (`CompileExpression.cpp:5888`) accepts both
`vpiConcatOp` and `vpiAssignmentPatternOp` and RECURSES into operand
operations, which is why a concat *nested under* a reordered pattern still
reverses. A top-level concat therefore reaches the reverse through exactly one
door: the module's own parameter list. An imported copy is not in that list.

### STATED GATE == CODE GATE

| § | file, site | the gate, verbatim |
|---|---|---|
| `importedConcatNoMdimReorder42` | `src/ParamEmit.cpp`, the `mdimPatternReorderRec` entry (§ `multiDimPackedParamNoFold`, other half) | `if (topView && !inPackage && !isImported && rhs && rhs->UhdmType() == UHDM::uhdmoperation && ((UHDM::operation*)rhs)->VpiOpType() == vpiConcatOp && writtenPackedDimCount(ps) >= 2)` |

`isImported` is the existing `bool isImported = ps.getParentScope() != &body;`
declared earlier in the same parameter loop. **`!isImported` is the ONLY code
token added.** Everything else in the diff is the decode above, written where
it is enforced: 1 line changed in the condition, 4 comment lines corrected,
50 comment lines added.

---

## 1. THE CENSUS, BOTH SIDES, DESIGN-WIDE, SPAN-KEYED, BEFORE ANY CODE

`census42.py` walks both `uhdm-dump` trees by indentation, skipping
`vpiParent:` (a BACK-reference printed in exactly the same shape as a child),
and keys every concat/pattern operation on `(dump section, enclosing scope,
op span)`. It classifies the operand SPAN SEQUENCE as `ASC` (source order),
`DESC` (reversed), `MIXED` or `SINGLE`, and it counts `vpiReordered`
separately, unfiltered by op type.

**A defect this script had, found and fixed before it was believed:** its first
draft used `94/95` for the assignment-pattern op types. The real values
(`sv_vpi_user.h`) are `vpiConcatOp 33`, `vpiMultiConcatOp 34`,
`vpiAssignmentPatternOp 75`, `vpiMultiAssignmentPatternOp 76`, so the first
run SILENTLY MISSED 1 917 golden operations. The numbers below are from the
corrected script; the correction is recorded in the script's own header so it
cannot be re-guessed.

```
Q1  vpiReordered population, design-wide          PRISTINE (d8ca1291)
    section      golden   ours
    allModules        0      2
    topModules        0      4
    TOTAL             0      6
```

**GOLDEN CARRIES ZERO `vpiReordered` IN THE WHOLE OF Earlgrey_0_1.** Every one
of our six is therefore a divergence with no counter-population anywhere in the
design to protect — question (a) of the brief, answered before any code.

```
Q2  operand ORDER, tallied                        PRISTINE
             golden (5271 ops)          ours (5482 ops)
    33  ASC      1802  rd=False    1795  rd=False
    33  DESC        —              →  6  rd=True
    33  SINGLE   1498              1599
    34  ASC      1441              1542
    75  ASC       441               446
    75  MIXED      23                22
    75  SINGLE     66                72

Q3  SPAN-KEYED JOIN (section, scope, op span): 5254 common keys
    golden ASC    -> ours ASC     3661
    golden ASC    -> ours DESC       6      <-- THE WHOLE DEFECT
    golden MIXED  -> ours MIXED     22
    golden MIXED  -> ours SINGLE     1      <-- unrelated, pre-existing (R2)
    golden SINGLE -> ours SINGLE  1564
```

The six divergent cells, named:

```
allModules  work@top_earlgrey                        13:59-18:4   ASC/False -> DESC/True
allModules  work@top_earlgrey                        32:58-37:4   ASC/False -> DESC/True
topModules  work@top_earlgrey                        13:59-18:4   ASC/False -> DESC/True
topModules  work@top_earlgrey                        32:58-37:4   ASC/False -> DESC/True
topModules  work@top_earlgrey.u_xbar_main            13:59-18:4   ASC/False -> DESC/True
topModules  work@top_earlgrey.u_xbar_main            32:58-37:4   ASC/False -> DESC/True
```

Six dump OCCURRENCES of FOUR objects — `top_earlgrey`'s two are the SAME object
seen from both listings (golden id 194130 appears in both LHS decompiles of the
head; ours, id 59785, likewise). The spans resolve to

```
tl_main_pkg.sv:13   localparam logic [3:0][31:0] ADDR_SPACE_PERI = { 32'h40000000, ... };
tl_main_pkg.sv:32   localparam logic [3:0][31:0] ADDR_MASK_PERI  = { 32'h00020fff, ... };
```

materialized into `work@top_earlgrey` and `work@top_earlgrey.u_xbar_main` by
`import tl_main_pkg::*` (top_earlgrey.sv:62, xbar_main.sv:122). **Those are the
only two modules in Earlgrey that import that package, and those are the only
two multi-dim concat localparams in it — the population is closed.**

### THE PREDICTION, made from the pristine dumps alone, before the edit

1. exactly **6 dump occurrences** change and **4 objects**;
2. reversing a list back does not change the MULTISET of dump lines, so the only
   multiset movement is the **6 removed `|vpiReordered:1` lines** →
   **`msdist` must fall by EXACTLY 6, `golden-only` must not move at all**;
3. our line count must fall by exactly 6;
4. the `vpiReordered` population must land on **0**, golden's number, not near it.

### THE MEASUREMENT, after the edit (patched 586af916)

```
                          PRISTINE      PATCHED     delta   PREDICTED
vpiReordered (ours)             6            0        -6      0
order-divergent cells           6            0        -6      0
golden-only line instances 238510       238510         0      0
ours-only   line instances  70263        70257        -6     -6
MULTISET DISTANCE          308773       308767        -6     -6
o.dump lines              4655201      4655195        -6     -6
```

All four predictions land. `golden-only` is unmoved, which is the assertion
that nothing was DELETED that golden wants.

---

## 2. THE GRID, CELL FOR CELL

`a1_earl42.sv` is 15 cells across four POSITIONS (package listing, module's own
param, materialized import copy, module var / cont-assign / procedural / port
connection) and six SHAPES. `grid42.py` keys each row on the `param_assign`'s
Lhs parameter NAME, so a row survives span drift, and prints `GOLDEN_ONLY` /
`OURS_ONLY` rather than dropping a row either side lacks.

`g.ord`/`o.ord` = operand span order; `g.rd`/`o.rd` = `vpiReordered`;
`g.op`/`o.op` = `vpiOpType` (33 concat, 75 assignment pattern).
**LHS is ALWAYS golden.**

### topModules — the elaborated listing, where the whole question lives

| scope | cell | source | golden | pristine | patched |
|---|---|---|---|---|---|
| `u_imp` (import copy) | `B1_PKG_CC` | `logic [3:0][31:0] = {c,c,c,c}` | ASC / — | DESC / flag ❌ | ASC / — ✔ |
| `u_imp` | `B6_PKG_NEST` | `logic [1:0][1:0][31:0] = {{c,c},{c,c}}` | ASC / — | DESC / flag ❌ | ASC / — ✔ |
| `u_imp` | `B9_PKG_SYM` | `logic [NW-1:0][31:0] = {c,c,c,c}` | ASC / — | DESC / flag ❌ | ASC / — ✔ |
| `u_imp` | `B3_PKG_ASC` | `logic [0:3][31:0] = {c,c,c,c}` | ASC / — | ASC / — ✔ | ASC / — ✔ |
| `u_imp` | `B4_PKG_FLAT` | `logic [31:0] = {8'h..×4}` | ASC / — | ASC / — ✔ | ASC / — ✔ |
| `u_imp` | `B5_PKG_CR` | `logic [3:0][31:0] = {R0,R1,R2,R3}` **ref-headed** | **DESC / flag** | DESC / flag ✔ | DESC / flag ✔ |
| `u_imp` | `B7_PKG_UP` | `int [4] = '{...}` ascending unpacked | ASC / — (op 75) | ASC / — ✔ | ASC / — ✔ |
| `u_imp` | `B8_PKG_UPD` | `int [3:0] = '{...}` descending unpacked | **DESC / flag** (op 75) | DESC / flag ✔ | DESC / flag ✔ |
| `u_m` (own localparam) | `C1_MOD_CC` | `logic [3:0][31:0] = {c,c,c,c}` | **DESC / flag** | DESC / flag ✔ | DESC / flag ✔ |
| `u_own` (own **parameter**) | `D1_OWN_NEST` | `bit [1:0][4:0][4:0] = {{..},{..}}` (StrictXY shape) | **DESC / flag** | DESC / flag ✔ | DESC / flag ✔ |
| `u_ownb` (own **parameter**) | `D2_OWN_FLAT` | `logic [3:0][31:0] = {c,c,c,c}` | **DESC / flag** | DESC / flag ✔ | DESC / flag ✔ |

### the other three positions — all MATCH on both binaries

| section | rows | verdict |
|---|---|---|
| `allPackages` / `topPackages` (q42) | 10 + 10 | every row MATCH, pristine and patched |
| `allModules` (def listings of m42 / mimp42 / mown42 / mown42b) | 17 | every row MATCH, pristine and patched |
| module var `C3_MOD_VAR`, cont-assign `c4_net`, procedural `c5_reg`, port conn `c6` | — | no `param_assign` row exists on either side; none is reordered by either side, and the patch does not reach them |

**Whole-grid verdict: pristine 4 DIFFER rows → patched 0 DIFFER, 0 OURS_ONLY,
0 GOLDEN_ONLY.** The eight golden cells that DO reverse still reverse.

### the over-fire / under-fire probe, `v42_overfire.sv`

Both kinds in the SAME module, same type, same concat:

```
                            golden        pristine        patched
u_mix.E0_PKG_CC (imported)  ASC  / —      DESC / flag ❌  ASC  / — ✔
u_mix.E1_MIX_OWN (own)      DESC / flag   DESC / flag ✔   DESC / flag ✔
u_mix.E2_PKG_CR (imported,
                 ref-headed) DESC / flag  DESC / flag ✔   DESC / flag ✔
```

and the whole file goes `CMP_FAIL` (head 182 lines) → **`PASS_CMP`, head 0
lines**. This is the positive control that the gate is a PER-PARAMETER test:
had `isImported` been read as "this scope imports something", `E1_MIX_OWN`
would have stopped reordering and the pass would have UNDER-fired invisibly.

---

## 3. THE HEAD

Pristine, the target head, byte-identical to the committed witness
`tools/probe/r10earl40repro/r6_nexthead.cmp` (verified by `diff`, 154 lines):

```
LHS: operation 13:59-18:4  |vpiOpType:33   operands @14:5 @15:5 @16:5 @17:5, NO vpiReordered
RHS: operation 13:59-18:4  |vpiOpType:33  |vpiReordered:1  operands @17:5 @16:5 @15:5 @14:5
```

Patched, the row ADVANCES to a NEW head of 46 lines:

```
LHS: constant 290:28-290:42  32'h00008000, with a ref_typespec -> logic_typespec 9:14-9:26
RHS: ref_obj  290:28-290:42  work@top_earlgrey.u_rv_core_ibex.boot_addr_i.ADDR_SPACE_ROM
```

A different mechanism entirely (a PORT high_conn that golden FOLDS to a typed
constant and we keep as a ref) — ranked as R1 in § 7.

---

## 4. THE FIVE GATES

Binary under test **`/tmp/wt_r10earl42/build/slang-uhdm` md5
`586af9165bf7b68f82284334a928ee5b`**; PRISTINE `02b28ca`, built by me in a
clean worktree, **`/tmp/wt_r10earl42pris/build/slang-uhdm` md5
`d8ca12914c36904a8565bf68e9b5d074`**. Both bases printed and grep-checked.

**A note on the md5, because it is the kind of thing that silently invalidates a
gate:** after gates 2, 3 and the uhdm2rtlil half of 5 had been run, a
COMMENT-ONLY edit was made to `ParamEmit.cpp` (the second refutation). The tree
was rebuilt with `-j 2` from an absolute path and the linked binary's md5 is
**identical** — `586af9165bf7b68f82284334a928ee5b` before and after — so every
gate already run stands on the FINAL source. Had it differed, the gates would
have been re-run; it is asserted here rather than assumed.

| gate | result |
|---|---|
| 1 BUILD | `cmake --build /tmp/wt_r10earl42/build -j 2`, waited for `Linking CXX executable`, md5 asserted separately, 32 hex |
| 2 GOLDENS | `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `PASS=0 FAIL=23` |
| 3 u2r testflags | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`; dump `496 match / 183 differ / 52 blank`; `ct8rows.sh` vs committed `results/gate_uhdm2rtlil.csv`: **0 differing ROWS** |
| 4 surelog both modes | see § 4.1 |
| 5 BYTE VERIFIER | see § 4.2 |

Both u2r sweeps ran `--jobs 2` with their own `--out`/`--workdir`;
`GOLDEN_DEFER` left UNSET; the binary each sweep actually invoked was read back
out of `cmds.txt`, not assumed:

```
pat : /tmp/wt_r10earl42/build/slang-uhdm dut.sv --single-unit --nobuiltin -o .../slang.uhdm
pris: /tmp/wt_r10earl42pris/build/slang-uhdm dut.sv --single-unit --nobuiltin -o .../slang.uhdm
```

`diff <(sort u2r_pat.csv) <(sort u2r_pris.csv)` is **empty** — independent
confirmation that every number in gate 3 is a property of the corpus and not of
the machine.

### 4.1 GATE 4 — surelog corpus, BOTH modes, ONE INVOCATION PER MODE

Run strictly sequentially, one `verify_golden.py` per mode per binary, so the
documented SURELOG_FAIL detail-row race under concurrent sweeps cannot fire.

```
[default]   794 tests  CMP_EQUAL 469  CMP_NOTEQUAL 11  SURELOG_FAIL 25  DEFERRED 5   -> 469/11  EXPECTED
[testflags] 794 tests  CMP_EQUAL 465  CMP_NOTEQUAL  8  SURELOG_FAIL 23  DEFERRED 5   -> 465/8   EXPECTED
```

`ct8rows.sh` against the committed `results/golden_surelog.csv` (the two modes
concatenated into one 1 588-row CSV):

```
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
---- per-mode STATUS histogram (baseline -> fresh)
  default   base/fresh: 469 CMP_EQUAL  11 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
  testflags base/fresh: 465 CMP_EQUAL   8 CMP_NOTEQUAL  5 DEFERRED    3 NO_DATABASE   1 NO_UHDM
                        286 SLANG_REJECT 23 SURELOG_FAIL 1 TIMEOUT    2 UNTRANSLATABLE
---- per-mode DUMP-column histogram (baseline -> fresh)
  default   base/fresh: 325 blank  244 differ  225 match
  testflags base/fresh: 329 blank  300 differ  165 match
PASS: every row byte-identical to the committed baseline
```

Both histograms UNCHANGED, 0 rows moved. The target's own rows are byte-identical
to the baseline — **its ROW does not move, its BYTES do**:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,
```

`diff <(sort sl_pat.csv) <(sort sl_pris.csv)` is **empty**.

### 4.2 GATE 5 — BYTE VERIFIER, both corpora, both modes, vs PRISTINE

```
uhdm2rtlil : databases patched=1358 pristine=1358  PATH_SETS_IDENTICAL  MOVERS: 0 / 1358
             SELFCHECK=1 -> 1357 / 1358 flagged    SELFCHECK1=1 -> 1
```

```
surelog    : databases patched= 953 pristine= 953  PATH_SETS_IDENTICAL  MOVERS: 2 /  953
  MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=db70c71278dd pristine=db5d5f79efc7
  MOVER ./default/Scoreboard-59431470/slang.uhdm    patched=b78dc8dde46e pristine=f92eb58f4bd0
             SELFCHECK=1 ->  952 /  953 flagged    SELFCHECK1=1 -> 3
```

`SELFCHECK1 = 3 = the one corrupted file + the two movers`, which is what that
control's own message says to expect. Both controls fire on both corpora.

#### The two movers, arbitrated PER SHAPE — because SIZE DELTA IS ZERO FOR BOTH

```
SIZE  Earlgrey_0_1  patched 49941318  pristine 49941318  -> 0
      Scoreboard    patched 11122855  pristine 11122855  -> 0
```

**Zero size-delta proves nothing** (the stated rule), so both were arbitrated on
content against the multiset-0 noise floor.

**Earlgrey_0_1 — REAL, and it is the target, named by the verifier itself.**
Per-shape multiset of the two dumps, ADDED and REMOVED separately:

```
REMOVED    4  [      |vpiReordered:1]
REMOVED    2  [        |vpiReordered:1]
ADDED      0
```

Six lines removed at exactly the two indents the census predicted, nothing
added, and golden's count of BOTH shapes is **0** — so all six removals move
toward golden. The database size is unchanged because `vpiReordered` is a fixed
field in the serialized object either way; only the DUMP loses lines. The
whole-design distance moves `308773 → 308767`.

**Scoreboard — FLAKE, by BOTH halves of the stated test.**

```
PER-SHAPE MULTISET, patched vs pristine dumps:  MULTISET DISTANCE 0
   (1094836 lines each side, golden-only 0, ours-only 0)

3 REPS OF THE UNMODIFIED PRISTINE BINARY, run by hand from the test dir:
   rep1 f92eb58f4bd0b20aeda06f491e27ff07   size 11122855
   rep2 f92eb58f4bd0b20aeda06f491e27ff07   size 11122855
   rep3 b78dc8dde46e94496849db8f0f4df321   size 11122855
```

**rep3's md5 IS the "patched" md5 the verifier reported.** The pristine binary
reaches the patched value on its own, at constant size, with a per-shape
multiset distance of zero — the documented emitter nondeterminism (SourceLocation
compares across macro buffers flip per run under parallel parse). Its CSV row is
byte-identical in every sweep.

**The one REAL mover in 2 311 databases is `Earlgrey_0_1/default`**, accounted
for object-for-object in §§ 1 and 3.

---

## 5. CANARIES

```
canaries.sh  u2r (testflags projection) : rows ok=8  changed=0 absent=0 unknown-names=25
canaries.sh  SL                          : rows ok=52 changed=0 absent=0 unknown-names=7
ctcan2.sh    u2r  EXPECT_UNKNOWN=6       : rows ok=1  changed=0 absent=0 unknown-patterns=6  PASS
ctcan2.sh    SL   EXPECT_UNKNOWN=1       : rows ok=58 changed=0 absent=0 unknown-patterns=1  PASS
canaudit.sh                              : audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
```

Both `ctcan2` runs take the COMMITTED baseline as their FIRST argument and are
mode-matched to the corpus, per that script's own contract. **Its guard was
exercised, not assumed:** re-running the SL check with `EXPECT_UNKNOWN=0` exits
**6**, so an unaccounted unmatched pattern can never read as green.

**BY NAME, fresh vs committed baseline — every one IDENTICAL:**

```
InterfaceModPort     default   CMP_EQUAL ,,differ      IDENTICAL
InterfaceModPort     testflags CMP_EQUAL ,,differ      IDENTICAL
BlackParrotComplex   default   CMP_EQUAL ,,differ      IDENTICAL
BlackParrotComplex   testflags CMP_EQUAL ,,differ      IDENTICAL
YosysOldOr           default   CMP_EQUAL ,,differ      IDENTICAL
YosysOldOr           testflags CMP_EQUAL ,,differ      IDENTICAL
SVSwitch             default   CMP_EQUAL ,,differ      IDENTICAL
SVSwitch             testflags CMP_EQUAL ,,differ      IDENTICAL
Earlgrey_0_1         default   CMP_NOTEQUAL decompile: IDENTICAL
Earlgrey_0_1         testflags SLANG_REJECT            IDENTICAL
```

`BlackParrotComplex` is `CMP_EQUAL`+`differ`, so **its row is blind to byte
changes** — the guarantee that the StrictXY witness did not move comes from the
BYTE VERIFIER, which lists it among the 951 surelog databases that are
byte-identical to pristine. That is the correct instrument for it and it is
named here for that reason.

**PROTECTED genscope canaries, BY NAME, u2r testflags, fresh vs committed
baseline — all IDENTICAL:**

```
gen_test9              CMP_EQUAL ,,match     IDENTICAL
genvar_loop_decl_2     CMP_EQUAL ,,differ    IDENTICAL
genvar_loop_decl_3     CMP_EQUAL ,,differ    IDENTICAL
paramod_genscope_child CMP_EQUAL ,,match     IDENTICAL
genscope_cells         CMP_EQUAL ,,differ    IDENTICAL
gen_test4              CMP_EQUAL ,,differ    IDENTICAL
indexed_partsel_array  CMP_EQUAL ,,match     IDENTICAL
EnumConcat             CMP_EQUAL ,,differ    IDENTICAL
```

**BOUNDARIES held.** `§ pkgWrittenQualSelBase41`'s `a1_earl41` grid,
`earl40`'s `a1_sel40` and the `v41v` probes live in `TypeEmit`/`ExprEmit`/
`EmitHelpers`; this pass touches ONE condition in `ParamEmit` and does not
enter any of them. `§ caTernOperandRead1` (ParamEmit, cont-assign ternary
operand reads) is a different site; `YosysOldOr` is protected BY NAME above and
is byte-identical. `r10uvm71` (TaskFuncEmit/ModuleEmit) and `r10buvm1`
(ExprEmit) share no file with this change — **the diff touches `ParamEmit.cpp`
and nothing else**, so there is no collision to report. No ancestor operation
is read mid-emit: the reorder site runs AFTER the whole Rhs is built, on the
finished operation, which is why `ternTrueArmOps31`'s hazard does not apply.

---

## 6. REFUTATIONS, STATED PLAINLY

**R-1. `UhdmWriter.cpp:2214` does not reorder module `param_assign`s, and never
did.** It is in the CONT_ASSIGN loop; `reorderAssignmentPattern` reverses only
when `lhs->UhdmType() == uhdmparameter`. The comment that carried this claim is
the reason the rule was written with a `topView && !inPackage` gate and no
notion of *whose* parameter it is. Corrected in the code, with every call site
tabulated so the next reader does not have to re-derive it.

**R-2. § `modParamPatternReorder`'s mechanism is wrong too (its gate is not).**
It says a materialized import copy reorders because "UhdmWriter's
`reorderAssignmentPattern` fires on all of them". The measured behaviour is
INHERITANCE, not an independent decision: in `v42_overfire.sv` golden's
`E2_PKG_CR` is `DESC`+flagged in `allPackages`, `topPackages` **and**
`work@mixed42`, while `E0_PKG_CC` is `ASC`+unflagged in all four — the module
copy is whatever the package listing already is. That code is left untouched
(its gate reproduces the inheritance correctly for the ref_obj-headed case and
holds cell-for-cell on B5/E2) and the correction is recorded next to it.

**R-3. "The reorder exists for unpacked-array concat semantics somewhere" —
NOT in this design.** The brief asked for a census before deleting anything.
Golden prints `vpiReordered` **ZERO times in Earlgrey_0_1**, and on the
span-keyed join of 5 254 shared concat/pattern operations there is not one cell
where golden accepts a reversed order that we would have lost. The reorder is
real (eight golden cells in the probes reverse) but it is a MODULE-OWN-PARAM
and DESCENDING-UNPACKED-PATTERN mechanism, and the Earlgrey design contains no
instance of it.

**R-4. `!isImported` was reached only after `writtenPackedDimCount >= 3` and
"has an operation operand" were both available and both REJECTED.** Either
would have cleared the Earlgrey head: Earlgrey's parameter has 2 written dims
and flat constant operands, BlackParrot's StrictXY shape has 3 and nested ops.
Both are accidents of the two witnesses, neither is a property Surelog reads,
and cell `D2_OWN_FLAT` (a module's OWN `logic [3:0][31:0] = {c,c,c,c}` — 2 dims,
flat constants, IDENTICAL to Earlgrey's in every respect except ownership)
**reverses in golden**, which refutes both directly. Ownership is the only
property that separates the grid.

**R-5. The census's own first draft was wrong and was caught by a control, not
by luck.** Op types `94/95` were guessed; the real ones are `33/34/75/76`. The
wrong set reported 3 354 golden operations, the right one 5 271 — 1 917
assignment patterns and multi-concats were invisible, including every `op 75`
cell in the grid. Checked against `sv_vpi_user.h`, and the episode is written
into `census42.py`'s header.

---

## 7. RANKED RESIDUES

**R1 — the NEW Earlgrey head (46 lines), `top_earlgrey.sv:290:28`.** A port
`high_conn` naming an imported package localparam: golden FOLDS it to
`constant 32'h00008000` carrying a `ref_typespec → logic_typespec 9:14-9:26`
instanced at `work@top_earlgrey`; we keep `ref_obj
work@top_earlgrey.u_rv_core_ibex.boot_addr_i.ADDR_SPACE_ROM`. Same family as
this pass (imported package params seen from a module) but a different
mechanism (port-connection folding, not operand order). Highest value: it is
the row's head.

**R2 — `work@top_earlgrey.u_hmac.u_hmac` 119:5-119:19, golden `MIXED` → ours
`SINGLE`.** The one order-family cell the patch does not touch: golden's
`op 75` there has several operands whose spans are not monotonic and we emit
one. Pre-existing, present identically on both binaries, unrelated to
ownership. It is the only remaining entry in the whole span-keyed order join.

**R3 — the 17 `golden-only` and 228 `ours-only` concat/pattern KEYS.** The join
in § 1 matches 5 254 of golden's 5 271 operations; the unmatched keys are
objects one side has at a span the other does not. They are not order defects
by construction (there is nothing to compare) and they are the natural next
census: 228 concat/pattern operations we mint that golden does not.

**R4 — `golden-only line instances: 238510` is unmoved by this pass and is the
dominant term in the 308 767 distance.** Ours-only is 70 257. Earlgrey's
remaining distance is overwhelmingly *things golden has that we do not emit*,
not things we emit wrongly.

---

## 8. FILES

| file | what it is |
|---|---|
| `census42.py` | design-wide, span-keyed, section-separated concat/pattern order + `vpiReordered` census, BOTH sides |
| `grid42.py` | per-`param_assign` grid keyed on the parameter NAME, BOTH sides, with GOLDEN_ONLY/OURS_ONLY guards |
| `a1_earl42.sv` | the 15-cell grid: 4 positions × 6 shapes |
| `v42_overfire.sv` | the per-parameter over-fire/under-fire probe (own + imported in ONE module) |
| `arm42.sh` | single-file arm driver (carried forward; `SLANG_UHDM` has no default, md5 printed, `sed 1d` both dumps) |
| `earl42.sh` | Earlgrey_0_1 default-mode driver against the immutable golden cache |
| `msdist.sh` | resync-immune multiset dump distance (carried forward) |
| `byteverify42.sh` | GATE 5 comparator with both mandatory negative controls |
| `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the row gate and the canary set (carried forward verbatim) |

`README.verifier.md` is the VERIFIER's to author. It is deliberately not
written here.

---

## 9. THE NEW HEAD, COMMITTED AS A WITNESS

`r6_nexthead42.cmp` is the patched binary's Earlgrey `cmp.log` verbatim (46
lines), so the NEXT pass can assert byte-identity against it exactly as this
pass asserted byte-identity against `r10earl40repro/r6_nexthead.cmp` (154
lines) before starting.
