# r10v214 — the ADVERSARIAL VERIFICATION of r10uvm214, § `pkgCloneBodyBindsOwnListingRhs214`

**VERDICT: ACCEPT.** Every headline number in the pass reproduces bit for bit on
binaries this verifier built itself, and 46 arm-views (15 new adversarial arms +
the pass's own 8 grid arms, both views) plus all 18 boundary movers re-scored
against **real Surelog goldens** find **zero** cells that agreed with golden
before the patch and disagree after. No production change was needed.

**MEASUREMENT ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py` are
the only authorities. slang was NOT patched; `results/*.csv` were READ ONLY and
NOT EDITED; nothing was promoted; NO CORPUS ROW CONVERTED in either direction;
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
and are not named in any artifact here (`canaudit.sh` FENCE-BREACH=0).
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `adbec035` |
| pristine binary, built by the verifier | md5 `e087ade1fc9236ff2aa79057ce5d262d` — the pass's digest, and byte-identical to the main tree's `build/slang-uhdm` |
| patched binary, built by the verifier | md5 `49b83611ebc24e7155c5e62e6c8e23e2` — the pass's digest |
| the patch | regenerated from the verifier's own worktree, byte-identical to the delivered file (md5 `4700894db803074361acbf9cbd7e8810`); `git apply --check` rc=0 on a FRESH `adbec035`; surface = 3 production files + `tools/probe/r10uvm214repro/`, **0 files elsewhere**; fence check 0/0/0/0 |

---

## 1. What reproduced, bit for bit

Both binaries, both md5s. `check_goldens.sh` 23 PASS / 0 FAIL on each with
`SLANG_UHDM` exported per binary, `/bin/false` 0 PASS / 23 FAIL. uhdm2rtlil
679/50/2 in both modes on both binaries, `ct8rows` PASS three ways, byteverify
**0 / 1358**. Surelog corpus `--mode both`, 1588 rows, **475/6 default and
469/6 testflags on BOTH binaries — no row converted**, and `ct8rows` patched vs
the verifier's own pristine sweep is **0 differing rows** in status AND dump
column. Rowheads: SeqDriver ×2 **50 → 209**, MiniAmiq ×2 **50 → 838**, one
`^LHS:` head each, the old head object (`ref_obj (uvm_pkg::UVM_SET)` id 61413
@217:31) absent from the patched logs; the seven protected CMP_EQUAL row-modes
all **0 lines / 0 heads at judge rc = 0 on both binaries**. Population table,
grid, boundary mover list, BuildUVMPkg's eight cells: all reproduced.
Full transcript in `GATES.r10v214.txt`, `CENSUS.r10v214.txt`.

Surelog's decode was checked at source in the tree `scripts/verify_golden.py`
names: `UhdmWriter::lateBinding` at `UhdmWriter.cpp:3294`, its
`if (ref->Actual_group()) continue;` guard, the `::`-qualified early-out, the
parent-chain walk whose `uhdmdesign` case binds `d->Parameters()` **by name with
`break` on the first hit**, and — nearly 450 lines later — the
`if (m && m->Param_assigns()) … if (m->UhdmType() == uhdmpackage)
ref->Actual_group(p->Rhs());` branch. `CompilePackage.cpp:60-72` does compile a
package twice (`Reduce::Yes`, then `getUnElabPackage()` with `Reduce::No`).
**The decoded order — design parameters before the listing's Rhs — is real, and
it is what forces the `$unit` conjunct.**

## 2. What the verifier broke, and what held

Fifteen new arms (`arms214/`, `varms214.sh`), each with ONE REAL Surelog golden
per view, golden-vs-golden calibration null in all 30 cells:

| arm | the face it attacks | parse AGREE | right→wrong |
|---|---|---|---|
| `va1_enumconst` | enum members and a package `localparam` in a def clone body | 3→5 | 0 |
| `va2_tsrange` | formal / body-local / return **typespec ranges** in the clone | 2→3 | 0 |
| `va3_expimport` | the `!importCloneEmit` conjunct: an **explicit `import p::C;`** clone beside the wildcard one | 1→5 | 0 |
| `va4_unitclash` | a `$unit` import whose package declares a parameter of the **same name** as the reference's home | 2→3 | 0 |
| `va5_modctx` | module body, **interface** body, package free function, package-variable init, `param_assign` init | 5→7 | 0 |
| `va6_shapes` | concatenation / replication / unpacked assignment-pattern parameters (the fold family's) | 6→9 | 0 |
| `va7_generic` | a parameterized class with two specializations | 3→5 | 0 |
| `va8_elabtwin` | a parameter whose def and elab constants differ in size | 2→5 | 0 |
| `va9_unitother` | a `$unit` import of an **unrelated** package (§ 146's loop runs, nothing matches) | 1→3 | 0 |
| `va10_taskstmt` | for-bound, case item, array index, concat operand, `$clog2` arg, nested user call | 8→14 | 0 |
| `va11_qualified` | the **fully-qualified `pkg::NAME` spelling**, which Surelog answers at step (1) | 2→4 | 0 |
| `va12_nested` | a derived class and a `super.` call, out of body | 1→4 | 0 |
| `va13_reexport` | `export p::*` through two importing packages | 1→5 | 0 |
| `va14_paramtypes` | `type` / `real` / `string` / signed-vector / ternary / `$clog2` parameters | 5→10 | 0 |
| `va15_taskbody` | tasks, an out-of-body **constructor**, a static method, and a **default argument** | 4→10 | 0 |

**Zero right→wrong cells in all 30 arm-views; 41 wrong→right in the parse
column.** The order-blind whole-dump diff on each arm shows every changed line
is the `vpiActual` of a package-parameter reference in a def clone body moving
from a folded constant to that listing's own `ref_obj`/`operation`/`constant`
— nothing else moves.

**The sharpest cell is `va4_unitclash`, and the patch gets it exactly right.**
With `import pv4q::*;` at compilation-unit scope and BOTH `pv4q` and `pv4p`
declaring `ca4`, golden binds *both* `ca4` references — including the one in
`pv4p`'s own def clone body — to the **design-level `parameter ca4` @10:17,
which is pv4q's**, i.e. step (2) matches by NAME ACROSS PACKAGES and wins over
step (3); and it binds `cb4` (whose def Rhs is a `ref_obj`) to
`ref_obj@15:19[package[ALLPKG:pv4p]]`, the listing's own Rhs. The patched
binary produces golden's row for both, the pristine one for neither.

**`va11_qualified` found a residue the pass does not name** (R3 below).

## 3. THE ONE METHODOLOGICAL DEFECT FOUND — the pass's `elab` column never elaborated our side

`r10uvm214repro/grid214.sh` and `armscore214.sh` give golden `-elabuhdm` in
their `elab` column but run **our** binary with no flag, so that column compares
our PARSE database against golden's ELABORATED one.
`scripts/verify_golden.py:369-370` maps a test's `-elabuhdm` to `--elabuhdm` on
our side, so that is not the comparison the corpus makes. Consequence: every
`elab MOVED-WRONG` cell in `ARMSCORE.r10uvm214.txt` and the README's claim that
the elab column's cells are "wrong before and after" are **artifacts of the
instrument**, not properties of the patch.

`varms214.sh` and `score_movers214.sh` fix it (`--elabuhdm` on both sides), and
the corrected reading is *better* than the pass claimed:

* the pass's own 8 grid arms: the parse column reproduces exactly (A 16→33,
  D 5→10, E 1→2, F 3→4; B/C/G/H census-identical), and **every arm is
  `bytes=SAME` in the elab view**, census-identical, 0 right→wrong
  (`GRID.recheck.r10v214.txt`);
* the 15 verifier arms: **`bytes=SAME` in the elab view on all 15**;
* the corpus: **all 636 `--elabuhdm` databases are byte-identical between the
  two binaries** — none of the seven byte movers is an elaborated row.

So the elaborated half of the corpus is not merely "untouched on every boundary
arm but one"; it is byte-inert everywhere except the single arm below, and there
the patch moves TOWARD golden. This is a defect in the pass's *instrument*, not
in its patch: the shipped code is fine, but a later pass that copies
`grid214.sh` or `armscore214.sh` inherits a scorer that cannot see the
elaborated view.

## 4. The boundary, re-run and re-scored

`bound214.sh` over a copy of the whole probe tree, both binaries, both views:
**`LISTED=5490 PROCESSED=5490 PRODUCED_DBS=5297 MOVED_ARMS=18 RC_DIFFS=0`**, and
the mover set is **identical** to the pass's own 18. **No `r10uvm205` /
`r10uvm207` / `r10uvm208` / `r10uvm210` / `r10uvm213` arm and no `sd8`-`sd12`
arm is in it** (those families contribute 402 of the 5490 arms the gate
compiled). The pass's four grid arms are in the list as the positive control.

All 18 re-scored against real goldens in both views, 36 arm-views, calibration
null in all 36, our side properly elaborated in the elab column
(`MOVSCORE.r10v214.txt`):

> **TO-GOLDEN 49, AWAY-GOLDEN / MOVED-WRONG 0.**

17 of the 18 are `bytes=SAME` in the elab view. The one that is not,
`r10v179repro/v179_b_arg.sv`, moves **TO-GOLDEN there too**: its `SHARED_P`
cell at 95:18 in the def clone body goes from the TOPPKG constant (sz=32) to
golden's ALLPKG constant (sz=64), AGREE 7→8, and its residual ONLY-GOLDEN pair
is a pre-existing name-shadowing cell bound to a `logic_net`.

## 5. The extra byte mover, attributed

The verifier's sweeps showed **7** surelog movers, not 6: `Scoreboard/default`
in addition to the predicted six. `COIN.r10v214.txt` attributes it: the two
databases are the same size, their sorted path-normalised dumps differ in
**0 of 1100422 lines**, and four low-load runs of EACH binary on the test's own
sources with the sweep's exact command line produce the **byte-identical**
database `61ee9cb4f6c1…` — the pristine sweep's own digest. It is the documented
Scoreboard coin (RESUME §9), not the patch. **The real mover set is exactly the
six the pass predicted by name: SeqDriver ×2, MiniAmiq ×2, BuildUVMPkg ×2.**

`BuildUVMPkg` ×2 are byte movers on a CMP_EQUAL row **by design**, and all eight
cells were checked individually against golden: four go
`constant[TOPPKG]{sz=32}` → `constant[ALLPKG]{sz=64}` and four go
`constant[TOPPKG]` → `operation[ALLPKG]{op=22}`, every one landing on golden's
own value, AGREE 114→122, LOST 0. (The README's prose says "two … and four";
it is four and four. The committed `CENSUS.r10uvm214.txt` names all eight
correctly.)

## 6. Residues the verifier is handing on

* **R1 — the pass's own `elab` scorers are blind** (§3). Anyone copying
  `grid214.sh` / `armscore214.sh` must add `--elabuhdm` to our side, as
  `varms214.sh` does.
* **R2 — `pkg::NAME` read from its OWN package's def clone body is a fold cell
  we do not model.** `va11_qualified`: golden holds **no reference at all** for
  `pv11::qa11` / `pv11::qb11` / `pv11::qc11` read from `Q11::q_qual11`, where it
  binds the def Rhs for the same parameters spelled bare in `Q11::q_bare11`.
  Surelog's `lateBinding` skips a `::`-qualified name outright
  (`UhdmWriter.cpp` ~:3300), so the value was substituted at compile time. We
  emit bound references either way — 3 ONLY-OURS rows before and after, no
  regression. This is the fold family (§ `fcArgPkgParamValueFolds32` / § 178's
  second gate term) reaching a shape the pass's arm E (a FOREIGN package) does
  not cover, and it is the nearest neighbour of the law just landed.
* **R3 — the pass's stated window is looser than the shipped one.** The report
  and the ExprEmit comment summarise the window as
  `pkgClassTfClone && !pkgImportCloneEmit`; the shipped predicate also carries
  `!importCloneEmit` and the home test `curPkgEmitSym == &scope->asSymbol()`
  (the comment does describe the home test). The blast-radius tap was keyed on
  the LOOSER pair, so its "17 in-window at ExprEmit.cpp:13534" is an upper bound
  on the shipped gate's fires — the safe direction, and the census confirms 17
  cells actually move. Worth restating exactly if the window is ever widened.
* **R4 — the `$unit` half now has three corpus-independent pins**, not two:
  the pass's grid arm H, plus `va4_unitclash` (the cross-package name clash,
  which is the only artifact anywhere that shows step (2) matching a FOREIGN
  package's design parameter) and `va9_unitother` (§ 146's loop running with
  nothing to match). Any future change to § 146's re-point, to `unitParamMap`
  or to `cloneRhsBound214` must re-run those three with `SimpleUVM` and
  `Scoreboard`.
* **R5 — the necessity of the `UhdmExporter.cpp` half is arm H's `ub214` cell.**
  That is the only measured cell whose def Rhs is a `ref_obj` *and* whose name a
  `$unit` import hoists; golden binds the design `parameter` there, and nothing
  else in the emitter re-points a `ref_obj` actual. Without
  `cloneRhsBound214` that cell would be AWAY-GOLDEN.

## 7. What is in this directory

| file | what it is |
|---|---|
| `arms214/` | the verifier's 15 adversarial arms |
| `varms214.sh` | the arm runner with the CORRECTED elab column (`--elabuhdm` on both sides), the `ct214bind --keycount` multiset census, and golden-vs-golden calibration per cell |
| `score_movers214.sh` | the same scorer driven off a `bound214.sh` MOVERS file |
| `ARMS.r10v214.txt` | §2 — the 30 arm-views and the per-cell right→wrong subset check |
| `GRID.recheck.r10v214.txt` | §3 — the pass's 8 grid arms re-run, plus arm H cell by cell |
| `MOVSCORE.r10v214.txt` | §4 — all 18 boundary movers, 36 arm-views |
| `BOUNDARY.r10v214.txt` | §4 — the wide gate's own counters and mover list |
| `COIN.r10v214.txt` | §5 — the Scoreboard attribution |
| `CENSUS.r10v214.txt` | §1/§5 — corpus census, population table, BuildUVMPkg's eight cells, SeqDriver's residues |
| `GATES.r10v214.txt` | §1 — the full gate transcript on the verifier's own binaries |
