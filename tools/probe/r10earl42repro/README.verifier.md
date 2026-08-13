# r10earl42 — ADVERSARIAL VERIFICATION of § importedConcatNoMdimReorder42

**VERDICT: PASS.** Every number in the implementer's report reproduces EXACTLY
on binaries I built myself from a FRESH `02b28ca`, including both md5s. The
five gates are green independently. The 154-line Earlgrey head is cleared and
the row advances to the committed 46-line witness.

**Two STATED claims are refuted by measurement, both with benign or favourable
code consequences, and both are corrected below rather than in the code:**

1. **The boundary claim "the diff … does not enter [earl41's arms]" is FALSE.**
   `a1_earl41.sv` and `v41v_overfire.sv` BOTH move — their heads go
   `154 → 30` and `154 → 44` lines, their `vpiReordered` populations go
   `2 → 0` onto golden's `0`. The movement is an IMPROVEMENT and earl41's own
   select-shape table is byte-identical, but it was asserted by argument and
   never measured. (Finding **F1**.)
2. **The LAW SENTENCE over-claims and a REAL CORPUS TEST refutes it.** SL test
   `IntegerConcat` wildcard-imports a 2-dim packed concat localparam into a
   module and **golden carries `vpiReordered` on the imported copy in
   `allModules` AND `topModules`**. The "regardless of packed-dim count,
   outer-range direction, or concat nesting" clause omits the axis that
   actually carves the population: the **operand HEAD KIND**. The code is
   unaffected — the ref_obj-headed case is owned by the earlier
   § `modParamPatternReorder`, which is not gated on `!isImported` — and the
   grid cells `B5_PKG_CR`/`E2_PKG_CR` and the code comment do record the
   exception. The prose does not. (Finding **F2**.)

Neither changes the landing decision. Everything else in the report is
confirmed, and one part of it (the Scoreboard flake) is confirmed *more*
strongly than it was claimed.

---

## 0. WHAT I RAN, AND ON WHAT

| | path | base | md5 |
|---|---|---|---|
| patched | `/tmp/wt_v42/build/slang-uhdm` | `02b28caf4db89d9ef8840543603823b8f0f2a8d3` | `586af9165bf7b68f82284334a928ee5b` |
| pristine | `/tmp/wt_v42pris/build/slang-uhdm` | `02b28caf4db89d9ef8840543603823b8f0f2a8d3` | `d8ca12914c36904a8565bf68e9b5d074` |

Both worktrees created fresh with `git worktree add --detach … 02b28ca`, both
`git rev-parse HEAD` PRINTED and checked, pristine `git status --porcelain`
EMPTY. Configured and built with `~/.local/bin/cmake --build <abs> -j 2`,
`Linking CXX executable slang-uhdm` waited for, `md5sum` asserted in a separate
command, 32 hex each.

**Both md5s are bit-for-bit the values the implementer reported.** The build is
reproducible from the delivered patch, which also settles the report's
"a later comment-only edit rebuilt to the identical md5" note: my single build
of the FINAL source lands on that md5.

`git apply --check /tmp/r10earl42.patch` is clean on `02b28ca` **and on the
current branch head `dbb1b5a`** (which touched `ExprEmit.cpp` only) — so there
is no collision with r10buvm1's landed work, and none with r10uvm71
(`TaskFuncEmit`/`ModuleEmit`). The production diff in my worktree is
BYTE-IDENTICAL to the `src/ParamEmit.cpp` hunk of the delivered patch.

### STATED GATE == CODE GATE

`src/ParamEmit.cpp:11496`, read out of my built tree, verbatim:

```c++
if (topView && !inPackage && !isImported && rhs &&
    rhs->UhdmType() == UHDM::uhdmoperation &&
    ((UHDM::operation*)rhs)->VpiOpType() == vpiConcatOp &&
    writtenPackedDimCount(ps) >= 2) {
```

Character-for-character the gate the README states. `!isImported` is the only
added code token (`bool isImported = ps.getParentScope() != &body;` at
line 3387 of the same `emitParameters` body); the idiom already appears five
times in pristine `ParamEmit.cpp`.

**Patch hygiene:** 1848 lines, md5 `af9fada390f50c228ec412bd546f1be1`, touching
`src/ParamEmit.cpp` and `tools/probe/r10earl42repro/` and nothing else.
`README.verifier.md` is NOT in it (its only occurrence is one sentence of
`README.md` reserving it) — correctly left to me. This file is that document,
and `/tmp/r10earl42.verified.patch` re-cuts the patch with it included.

---

## 1. EVERY NUMBER, REPRODUCED

LHS is ALWAYS golden. Every row below is a command I ran, not a citation.

| measurement | claimed | mine | |
|---|---|---|---|
| patched md5 | `586af916…` | `586af916…` | ✔ |
| pristine md5 | `d8ca1291…` | `d8ca1291…` | ✔ |
| GOLDENS | 23 PASS / 0 FAIL | 23 / 0 | ✔ |
| GOLDENS `/bin/false` | 0 PASS / 23 FAIL | 0 / 23 (exit 1) | ✔ |
| u2r testflags | 679 / 50 / 2 | 679 / 50 / 2 | ✔ |
| u2r dump column | 496 match / 183 differ / 52 blank | 496 / 183 / 52 | ✔ |
| u2r `ct8rows` | 0 rows | 0 rows, both histograms unchanged | ✔ |
| SL default | 469 / 11, FAIL 25, DEFER 5 | idem (+284 SLANG_REJECT) | ✔ |
| SL testflags | 465 / 8, FAIL 23, DEFER 5 | idem | ✔ |
| SL `ct8rows` (1588 rows) | 0 rows | 0 rows, both histograms unchanged | ✔ |
| byteverify u2r | 0 / 1358 | 0 / 1358 | ✔ |
| … SELFCHECK / SELFCHECK1 | 1357/1358 · 1 | 1357/1358 · 1 | ✔ |
| byteverify SL | 2 / 953 | 2 / 953, same two paths | ✔ |
| … SELFCHECK / SELFCHECK1 | 952/953 · 3 | 952/953 · 3 | ✔ |
| Earlgrey head, pristine | 154, `== r10earl40repro/r6_nexthead.cmp` | 154, byte-identical | ✔ |
| Earlgrey head, patched | 46, `== r6_nexthead42.cmp` | 46, byte-identical | ✔ |
| `msdist` pristine | 238510 / 70263 / **308773** | identical | ✔ |
| `msdist` patched | 238510 / 70257 / **308767** | identical | ✔ |
| o.dump lines | 4655201 → 4655195 | identical | ✔ |
| census `vpiReordered` | golden 0, ours 6 → 0 | identical | ✔ |
| census ops | golden 5271, ours 5482 | identical | ✔ |
| census join | 5254 common / 17 g-only / 228 o-only | identical | ✔ |
| order-divergent cells | 6 → 0 (+1 pre-existing R2) | 6 → 0 (+1 R2) | ✔ |
| grid a1_earl42 | 4 DIFFER → 0 | 48 MATCH+4 DIFFER → **52 MATCH, 0/0/0** | ✔ |
| `v42_overfire` | CMP_FAIL(182) → PASS_CMP | 182 → PASS_CMP, heads 0 | ✔ |
| per-shape mover | REMOVED 4+2 `vpiReordered`, ADDED 0 | identical | ✔ |
| Earlgrey db md5s | `db70c71278dd` / `db5d5f79efc7` | identical | ✔ |
| Scoreboard msdist | 0 over 1094836 lines | identical | ✔ |
| `canaudit` | audited 29, UNCOVERED 0, BREACH 0 | identical | ✔ |
| `canaries` u2r / SL | ok 8 / ok 52, changed 0 | identical | ✔ |
| `ctcan2` u2r / SL | ok 1 unk 6 / ok 58 unk 1, PASS | identical | ✔ |
| `ctcan2` guard control | `EXPECT_UNKNOWN=0` → exit 6 | exit 6, BOTH corpora | ✔ |

`diff <(sort u2r_pat.csv) <(sort u2r_pris.csv)` and the same for the 1588-row
SL CSV are both EMPTY, so every status number above is a property of the
corpus, not of my machine.

### The five gates, run by me

1. **BUILD** — absolute path, `-j 2`, link line waited for, md5 asserted
   separately, base printed and grep-checked on both trees.
2. **GOLDENS** — `23/0`; `SLANG_UHDM=/bin/false` → `0/23`, exit 1.
3. **u2r** — `679/50/2`; dump `496/183/52`; `ct8rows.sh` vs the committed
   `results/gate_uhdm2rtlil.csv` → **0 differing ROWS, 0 diff row-sides**.
4. **SURELOG, both modes, STRICTLY SEQUENTIAL** (one `verify_golden.py` per
   mode per binary, four runs, so the documented SURELOG_FAIL detail-row race
   under concurrent sweeps cannot fire) — `469/11` + `465/8`, `ct8rows.sh` vs
   the committed `results/golden_surelog.csv` → **0 differing ROWS**, both
   per-mode STATUS and DUMP histograms unchanged. Each sweep's binary read
   back out of `cmds.txt`, not assumed.
5. **BYTE VERIFIER**, both corpora, both modes, vs the PRISTINE `02b28ca` I
   built — `0/1358` and `2/953`, both mandatory controls fired on both corpora.

`GOLDEN_DEFER` left UNSET throughout. `results/*.csv` read-only. No `git stash`.
None of `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` dispatched.

### The two SL movers, arbitrated on CONTENT (size delta is ZERO for both)

**Earlgrey_0_1 — REAL, and REAL BY BOTH INSTRUMENTS.** Per-shape multiset of
the two 4.65 M-line dumps:

```
REMOVED      4  [      |vpiReordered:1]
REMOVED      2  [        |vpiReordered:1]
ADDED        0
golden's count of both shapes: 0
```

Six removals at exactly the two indents the census predicted, nothing added,
every removal toward golden. And — the check the report did not run — **the
pristine binary is byte-DETERMINISTIC on Earlgrey**: three independent runs all
give `db5d5f79efc7` at 49941318 bytes, while patched gives `db70c71278dd` at the
same size. So the md5 delta is real on its own terms too, not only on content.

**Scoreboard — FLAKE, and worse than reported.** Per-shape multiset distance
patched-vs-pristine is **0** over 1094836 lines each side. Six hand reps of the
**UNMODIFIED PRISTINE** binary on the exact `cmds.txt` command line, run from
the test dir, at constant size 11122855:

```
rep1 afc9f35ef000   rep2 f92eb58f4bd0   rep3 9c8a8b7bf8ba
rep4 f92eb58f4bd0   rep5 f92eb58f4bd0   rep6 f92eb58f4bd0
```

Three distinct md5s from one unmodified binary — and my own sweep's PRISTINE
value was `afc9f35ef000` while the report's was `f92eb58f4bd0`, so across the
two verifications the same binary has produced **four** distinct databases at
identical size. This is the documented `SourceLocation`-across-macro-buffers
nondeterminism. Its CSV row is byte-identical in every sweep.

**One real mover in 2311 databases, and it is the target.**

### Canaries, by name

`InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch`,
`Earlgrey_0_1` — all rows byte-identical to the committed SL baseline; all eight
protected genscope canaries (`gen_test9`, `genvar_loop_decl_2`,
`genvar_loop_decl_3`, `paramod_genscope_child`, `genscope_cells`, `gen_test4`,
`indexed_partsel_array`, `EnumConcat`) byte-identical in u2r testflags.

The report notes `BlackParrotComplex` is `CMP_EQUAL`+`differ` and therefore
row-blind. **So are the other three** — `InterfaceModPort`, `YosysOldOr` and
`SVSwitch` are all `CMP_EQUAL`+`differ` in both modes, so their ROWS cannot see
a byte change either (F8). I closed that by naming their DATABASES:

```
YosysOldOr         default/testflags  BYTE_IDENTICAL (14783104 B)
SVSwitch           default/testflags  BYTE_IDENTICAL (247237 B)
InterfaceModPort   default/testflags  BYTE_IDENTICAL (38003 B)
BlackParrotComplex default 48433 B / testflags 50584 B  BYTE_IDENTICAL
YosysBigSimReed / YosysOldOpen        BYTE_IDENTICAL (both modes)
```

---

## 2. FINDINGS

### F1 — MATERIAL. The earl41 boundary was asserted, not measured, and it MOVES.

The report says: *"`§ pkgWrittenQualSelBase41`'s `a1_earl41` grid … live in
TypeEmit/ExprEmit/EmitHelpers; this pass touches ONE condition in ParamEmit and
does not enter any of them."* That is an argument about FILES, and it is wrong
about BEHAVIOUR. `a1_earl41.sv` line 31 is

```systemverilog
package q41;
  parameter logic [3:0][7:0] A = {8'h9, 8'ha, 8'hb, 8'hc};
endpackage
module a1_earl41 …;
  import q41::*;                       // <-- squarely in earl42's population
```

Ran with both binaries:

```
arm41.sh a1_earl41.sv      pristine CMP_FAIL head 154  DUMP_DIFF 1160
                           patched  CMP_FAIL head  30  DUMP_DIFF 1110
arm41.sh v41v_overfire.sv  pristine CMP_FAIL head 154  DUMP_DIFF  900
                           patched  CMP_FAIL head  44  DUMP_DIFF  850
```

Both arms' `vpiReordered` go `ours 2 → 0` against `golden 0`; the whole
per-shape delta of each arm's own dump is the 2 removed `|vpiReordered:1` lines
plus the operand re-order of the same four `8'h9…8'hc` constants. The pristine
head at `31:34` WAS this defect; patched, it advances to an unrelated
`ref_obj (p41::A)` vs folded-constant divergence at `37:16`.

**The boundary HOLDS in substance** — I ran earl41's own `cells41.py` select-
shape census on both binaries and OUR cell table is byte-identical
(`OURS_CELLS_UNCHANGED`), golden's likewise, and the golden-vs-ours diff is 76
lines on both. So § `pkgWrittenQualSelBase41` is untouched cell-for-cell. But
the claim as written is false, the movement is favourable-by-luck-of-measurement,
and a boundary asserted from a file list is not a boundary that was checked.

Also run, both binaries, ALL byte-identical (`OURS_DUMP_IDENTICAL`, same heads,
same `DUMP_DIFF`): earl38 `a1_chain` / `a2_fence` / `v1_outside`; earl39
`a1_argts` / `v1_r2sep`; earl40 `a1_sel40` (head 78) / `v40_overfire` (30) /
`v40_orphan` (104) / `bnd_a1_argts` / `bnd_a1_chain` / `bnd_a2_fence`; earl41
`v41v_comment` (PASS_CMP) / `v41_orphan` (104).

### F2 — MATERIAL. `IntegerConcat` refutes the LAW SENTENCE (not the code).

The law says an imported copy keeps source order and carries no flag
*"regardless of packed-dim count, outer-range direction, or concat nesting"*.
`~/git-repos/Surelog/tests/IntegerConcat/dut.sv`:

```systemverilog
package pkg;
  parameter logic [NumSeeds-1:0][InfoPageW-1:0] SeedInfoPageSel =
  { CreatorInfoPage, OwnerInfoPage };
endpackage
module dut(); import pkg::*; test #(.p(SeedInfoPageSel)) t(); endmodule
```

Two written packed dims, descending outer range, wildcard-imported into a
module. Dumping the cached golden and our database:

```
golden vpiReordered = 3   ours = 3
sections carrying a mark, BOTH sides: topPackages, allModules, topModules
the marked param_assign, all three:   8:47-12:2  (SeedInfoPageSel)
```

**Golden reorders the imported copy in `work@dut` — in both module listings.**
The row is `CMP_EQUAL` and BYTE-IDENTICAL across the patch, so nothing broke;
the reason is that this concat is `ref_obj`-headed and its reversal is produced
by the earlier § `modParamPatternReorder` block, which is NOT gated on
`!isImported`. That is exactly the carve-out the report's own grid records at
`B5_PKG_CR` / `E2_PKG_CR` and the code comment names — but the LAW in § 0 and
the headline claim omit it, and no real-corpus witness for it was cited.

**The sentence that survives measurement is:**

> The multi-dimensional CONCAT reorder that § `multiDimPackedParamNoFold`'s
> other half applies is a property of a module's OWN DECLARED parameter list.
> A package localparam MATERIALIZED by a wildcard import is not in that list
> and does not reorder THERE. It may still arrive already-reversed by
> INHERITANCE from the package listing when its operands are `ref_obj`-headed
> (§ `modParamPatternReorder`) — `B5_PKG_CR`, `E2_PKG_CR`, and the corpus
> witness `IntegerConcat`.

This is the report's own SECOND REFUTATION (inheritance, not independent
decision) stated so that it does not contradict the FIRST.

### F3 — INSTRUMENT. `grid42.py` silently drops 32 of the 84 rows it parses.

`rows.setdefault(key, r)` keeps only the FIRST row per
`(section, scope, parameter-name)`. On `a1_earl42.sv` the parser produces **84
distinct `param_assign` records** and prints **52**:

```
('allPackages','q42 (q42::)', None)               9 distinct rows, 9 distinct spans
('topPackages','q42 (q42::)', None)               9
('allModules','work@mimp42 (work@mimp42)', None)  9
('topModules','work@mimp42 (work@top42.u_imp)',None) 8
… 42 named keys hold exactly 1 row each; 42 more rows collapse into 10 `None` keys
```

The `None` rows are `param_assign`s whose `vpiLhs` parameter the parser did not
capture; each is a SECOND dump occurrence of a cell that also has a named row,
so on THIS arm nothing is lost. I proved that rather than assuming it: an
independent re-join of all 84 rows keyed on `(section, scope, op span)` finds
exactly the same verdict — pristine 3 real order divergences (`B1_PKG_CC`,
`B6_PKG_NEST`, `B9_PKG_SYM` in `work@top42.u_imp`), patched 0; the other
entries the span key flags are pure end-column drift (`59:63` vs `59:65`) with
IDENTICAL order and flag on both sides. **The grid's conclusion stands.** The
collapse is nonetheless unguarded, and it is the same defect `cells32`/`cells40`
were rewritten to avoid; the `None` rows are printed as if they were cells.

### F4 — EMPTY PRODUCT CELL. The u2r half of gate 5 cannot see this law at all.

"ZERO byte movers in 1358 uhdm2rtlil databases" is a headline of the report. A
source census of `~/git-repos/uhdm2rtlil/test` (multi-line regex over every
`.sv`/`.v`/`.svh`) finds **ZERO** multi-dim packed parameters with a BARE-CONCAT
initializer. The five hits that exist —

```
ParameterPackedArray, ParameterPackedArraySurelogSubstitution,
ParameterUnpackedArray, param_packed_array_subst, ParameterUnpackedLogicArray
```

— are ALL `'{…}` assignment patterns (`VpiOpType != vpiConcatOp`) and none is a
wildcard-imported package parameter. The changed gate therefore has an **empty
population in the entire uhdm2rtlil corpus**: its `0/1358` is a blast-radius
negative control and proves nothing about the law. It should be stated as such.

The SL corpus is where the population lives: 101 such declarations across 17
tests. Of those with a database, `IntegerConcat` (F2) and `BlackParrotComplex`
(the protected `StrictXY` 3-dim own-module witness) are both `CMP_EQUAL` and
BYTE-IDENTICAL — the two nearest real neighbours of the gate, unmoved.

### F5 — EMPTY PRODUCT CELL. The arm's PORT-CONNECTION position is unmeasured.

`a1_earl42.sv:121` writes `sub42 #(.P({32'h…,…})) u_sub (…)` for the brief's
"port conn" cell. Neither side produces a concat/pattern operation key there:
golden gives `work@top42.u_m.u_sub.P` the value `BIN:0` — the port's DEFAULT
`'0` — so the override never becomes a comparable operation. The README lists
c6 under "no `param_assign` row exists on either side", which is true, but the
reason is that the cell is EMPTY, not that the position declines to reorder.
The brief asked for that position; the arm has a source line for it and no
measurement.

The three positions that ARE measured are measured in ONE view each: the
design-wide census finds `C3_MOD_VAR` (95:34) only in `topModules`, and
`c4_net` (104:19) and `c5_reg` (113:24) only in `allModules` — all `ASC/False`
on both sides, both binaries.

### F6 — EMPTY PRODUCT CELL inside the report's own grid table.

`B2_PKG_PC` (imported, packed, assignment-pattern) and `C2_MOD_PC` (own,
packed, assignment-pattern) have rows in `allPackages`/`allModules` and **no
row in `topModules` on either side** — both sides fold them to constants in the
elaborated view. The report's `topModules` table simply omits them. Consequence:
the grid carries **no elaborated-view evidence for PACKED `op 75` cells at all**;
the only elaborated `op 75` evidence is the UNPACKED `B7_PKG_UP` / `B8_PKG_UPD`.
Since the gate is `vpiConcatOp`-only this does not endanger the law, but the
grid is one axis thinner than it reads.

### F7 — INSTRUMENT, pre-existing. "0 GOLDEN_ONLY / 0 OURS_ONLY" is narrower than it sounds.

Raw `param_assign` populations in the `a1_earl42` arm, IDENTICAL on both
binaries:

```
             golden   ours
allModules       54     51
topModules       38     40
allPackages      28     28
topPackages      28     28
```

The grid reports `0 GOLDEN_ONLY / 0 OURS_ONLY` because it only ever creates a
row for an operation-Rhs `param_assign` and then name-keys it. The asymmetry is
pre-existing and unmoved by the patch (a residue, not a regression), but the
grid's zero is a statement about operation-Rhs named rows, not about the
`param_assign` population.

### F8 — MINOR. Row-blindness is not unique to `BlackParrotComplex`.

Stated in § 1 above; closed by naming the databases byte-identical.

### F9 — POSITIVE. Both mover arbitrations get STRONGER under re-measurement.

Stated in § 1: Earlgrey is byte-deterministic across three pristine runs (so the
real mover is real by md5 as well as by content), and Scoreboard's flake spans
four distinct md5s at constant size from one unmodified binary.

---

## 3. RANKED RESIDUES

**R1 — the new 46-line Earlgrey head, `top_earlgrey.sv:290:28`.** Confirmed
byte-identical to the committed `r6_nexthead42.cmp`. Golden folds a port
`high_conn` to `constant 32'h00008000` under `param_assign 9:27-9:66`; we keep
`ref_obj …u_rv_core_ibex.boot_addr_i.ADDR_SPACE_ROM`. Same family (imported
package params seen from a module), different mechanism (port-connection
folding). It is the row's head — highest value.

**R2 — `work@hmac_core (work@top_earlgrey.u_hmac.u_hmac) 119:5-119:19`,
golden MIXED → ours SINGLE.** Confirmed: the ONLY remaining entry in the
span-keyed order join after the patch, present identically on both binaries,
pre-existing and unrelated to ownership.

**R3 — 17 golden-only and 228 ours-only concat/pattern KEYS.** Confirmed
(5254 of golden's 5271 join). 228 concat/pattern operations we mint at spans
golden has nothing at. The natural next census.

**R4 — `golden-only 238510` vs `ours-only 70257`.** Confirmed unmoved by this
pass. Earlgrey's remaining distance is overwhelmingly things golden emits that
we do not.

**R5 (mine) — restate the law with its operand-head carve-out** (F2), so the
next pass does not read § 0 as licence to widen `!isImported` over the
`ref_obj`-headed cells and silently un-reverse `B5`/`E2`/`IntegerConcat`.

**R6 (mine) — `grid42.py`'s `setdefault` collapse** (F3): capture the Lhs
parameter name for every occurrence, or key on the span, and make a key
collision LOUD instead of silent.

**R7 (mine) — the port-connection cell** (F5) and the elaborated packed-pattern
cells (F6) are empty. If a future pass needs either position, the arm must be
extended first; today it would report MATCH on nothing.

**R8 (mine) — the u2r corpus cannot exercise this rule** (F4). Any future pass
in this family should say so out loud rather than quoting `0/1358` as evidence.

---

## 4. HOW TO RE-RUN THIS VERIFICATION

```sh
git worktree add --detach /tmp/wt_v42     02b28ca && git -C /tmp/wt_v42 apply /tmp/r10earl42.patch
git worktree add --detach /tmp/wt_v42pris 02b28ca
for w in /tmp/wt_v42 /tmp/wt_v42pris; do
  ~/.local/bin/cmake -S $w -B $w/build -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
     -DUHDM_DIR=$HOME/.local/lib64/cmake/UHDM -Dslang_DIR=$HOME/.local/lib64/cmake/slang
  ~/.local/bin/cmake --build $w/build -j 2; md5sum $w/build/slang-uhdm
done
cd /tmp/wt_v42 && SLANG_UHDM=/tmp/wt_v42/build/slang-uhdm ./tests/check_goldens.sh | grep -c '^PASS'
cd /tmp/wt_v42/tools/probe/r10earl42repro
for b in /tmp/wt_v42 /tmp/wt_v42pris; do SLANG_UHDM=$b/build/slang-uhdm bash ./earl42.sh /tmp/v42_earl_$(basename $b); done
~/git-repos/UHDM/build/bin/uhdm-dump ~/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm | sed 1d > /tmp/v42_earl_g.dump
bash msdist.sh /tmp/v42_earl_g.dump /tmp/v42_earl_wt_v42/o.dump
python3 census42.py /tmp/v42_earl_g.dump /tmp/v42_earl_wt_v42/o.dump
for b in /tmp/wt_v42 /tmp/wt_v42pris; do SLANG_UHDM=$b/build/slang-uhdm bash ./arm42.sh a1_earl42.sv /tmp/v42arm_$(basename $b); done
python3 grid42.py /tmp/v42arm_wt_v42/g.dump /tmp/v42arm_wt_v42/o.dump
# and the earl41 boundary that the report did not run:
SLANG_UHDM=/tmp/wt_v42/build/slang-uhdm bash ../r10earl41repro/arm41.sh a1_earl41.sv /tmp/v42bnd_pat
```

All sweep workdirs (`/tmp/v42_wd_u2r_*`, `/tmp/v42_wd_sl_*`) and arm scratch
directories were deleted after measurement.
