# r10uvm216 — § `dpiExportListedAtExportItem216` — **AN `export "DPI-C"` ITEM CREATES THE SUBROUTINE'S LISTING ENTRY *AT THE EXPORT ITEM'S POSITION*, STAMPED `vpiDPIExportAcc` / `vpiDPIC`, AND THE LATER DEFINITION FILLS THAT SAME OBJECT IN PLACE** — the MiniAmiq ×2 head clears and the subroutine-listing population of every UVM row is now exactly golden's

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; they are named only inside `canaudit.sh`'s `FENCED=` list,
`scrub216.sh` redacts them out of every artifact, and `canaudit.sh`'s own
`FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b7eb7ff3` |
| pristine binary | md5 `49b83611ebc24e7155c5e62e6c8e23e2`, built `-j 2` from this pass's OWN worktree at a clean `b7eb7ff3` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `4db85bc0e24d58654a133cb7c318140b`, frozen `chmod 555`. The deliverable patch applied to a FRESH `b7eb7ff3` worktree and built there comes out **byte-identical to it** — the gates below were run on the binary the patch reproduces. |
| two throwaway CONTROL binaries (never committed, no part of the patch) | a LAYOUT-NULL control (two unused members of the law's shape) and an ALLOCATION-ONLY control (the law's memo built for every holder and every member, `dpiExportItem216` forced to return null so the law can never fire). §6 uses them to attribute three byte movers the prediction did not name. |
| production surface | `src/TaskFuncEmit.cpp` and `include/UhdmExporter.h` only. **+351 / −1 lines, of which 165 are the decoded comment. No new pass, no new phase, nothing minted, nothing removed; one listing permuted per holder that has an export item, and an IDENTITY permutation is a no-op.** |
| probe surface | `tools/probe/r10uvm216repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **MiniAmiq ×2, 838 cmp lines / ONE head each** — the r10uvm214 R0. Every other row at BASE: SeqDriver ×2 **209/1**, SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. |
| the head after | **THE OBJECT IS GONE.** MiniAmiq ×2 read **29 lines / 1 head**, a NEW object: `ref_obj::Actual_group` on a formal-argument reference *inside the exported function's body* (`RHS: <null>`; golden binds the `io_decl`, we leave it unbound). R0. |
| the brief's shape question, answered | The brief calls the head "a DPI-C **import** function inside an interface instance". It is an **EXPORT** (`vpiAccessType:3` = `vpiDPIExportAcc`), and it is not a `<null>` on either side: both hold a full object at index **[900]** of the SAME `interface_inst`'s 931-entry `Task_funcs`. golden's is `pass_info_to_sv_dpi` (the `export "DPI-C"` item at svaunit_vpi_interface.sv:72), ours was `set_test_name` (:113). |
| the law | **CONFIRMED and decoded to Surelog `file:line`** (`CompileModule.cpp:1181-1186`, `CompilePackage.cpp:288-293`, `CompileProgram.cpp:346-351` → `compileFunctionPrototype`; `CompileStmt.cpp:2353-2358` is the bare-name reuse that makes the definition fill that object in place). TWO independent divergences, both closed: POSITION and FLAGS (§3). |
| the population (question 2) | The interface holds **931** entries on both sides — 21 DPI IMPORTs, 3 DPI EXPORTs and 907 plain on golden; **21 / 1 / 909** on pristine ours; **21 / 3 / 907** after. The separation is total: of the interface's own 37 entries the **two** that diverged are exactly the two whose export item is SEPARATED from its definition, and the 35 that agreed are exactly the ones with no export item or an adjacent one. |
| the golden grid (question 3) | **6 arms × 2 views = 12 arm-views, one REAL Surelog golden each, 0 NO-DATABASE, golden-vs-golden CALIBRATION null in all 12.** Every arm closes: the shift-immune order scorer reads **RANK-GOLDEN 0 / RANK-OURS 0 in all twelve** (pristine 5/5, 8/8, 6/6, 0/0, 3/3, 2/2). Arms A–E also close the absolute-index census to **0 / 0**. **No `ONLY-GOLDEN` and no `ONLY-OURS` row is ADDED in any arm in either view: AWAY-GOLDEN 0, MOVED-WRONG 0.** |
| the a-priori prediction (question 5) | Written from PRISTINE databases and sources alone, BEFORE the patched binary existed: the FIRE set is **15 of 956** surelog row-modes and **4 of 1358** uhdm2rtlil ones, and of those exactly **TWO** can move — `MiniAmiq` default and testflags, 9 cells each, all TO-GOLDEN. |
| byte movers | **6 / 956** surelog and **0 / 1358** uhdm2rtlil. TWO are the law — `MiniAmiq` ×2, exactly the two predicted, cell for cell. THREE the prediction did NOT name (`BuildUVMPkg` ×2, `SeqDriver`/default): §6 proves with an ALLOCATION-ONLY control binary that they move for the law's memo ALLOCATION and not for the law — the control reproduces their patched md5s EXACTLY while leaving MiniAmiq at the pristine md5. The sixth is `Scoreboard`/default, **THE COIN** (RESUME §9): 92 raw dump lines, **0 order-blind**, and the replay control reads pristine = patched = layout-null on the same command line. |
| the protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `SimpleUVM` ×2, `Earlgrey_0_1` ×2 and `Scoreboard`/default — **all seven CMP_EQUAL on BOTH binaries at judge rc = 0, both columns scored** (§7). One informational cell moved and is decomposed there: `Earlgrey_0_1`/default's uhdm-dump comparison cell went blank because the sweep ran concurrently with the 5511-arm boundary gate; its database md5 is identical on both binaries and a clean single-row re-run reproduces the committed row exactly. |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` negative control 23 FAIL; uhdm2rtlil **679 / 50 / 2 in BOTH modes on both binaries**, `ct8rows` PASS, `byteverify` 0/1358; surelog 1588 rows, status histogram **475/6 default + 469/6 testflags UNCHANGED, cell for cell — no row converted in either direction**; wide boundary LISTED = PROCESSED = 5511, MOVED_ARMS 12, RC_DIFFS 0, all 24 moved arm-views re-scored against real goldens at **TO-GOLDEN 108 / AWAY-GOLDEN 0 / STILL-WRONG 0**. |

---

## 1. THE HEAD, AND THE PRISTINE BASELINE, MEASURED FIRST

This pass built its own pristine binary from a clean `b7eb7ff3` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`49b83611…`). Before a line was written: `check_goldens.sh` 23 PASS / 0 FAIL
with the `/bin/false` control at 23 FAIL; both uhdm2rtlil sweeps 679/50/2 with
`ct8rows` PASS; the surelog sweep reproducing the committed status histogram
exactly (475/6 + 469/6). Every `cmds.txt` in both pristine sweeps names
`/tmp/r10uvm216_bin/pris` by PATH and **none** names the main-tree binary
(audited by binary path, not by the string `slang-uhdm`, which also matches
`slang-uhdm-goldens/`).

`rowheads.sh` on that sweep:

```
MiniAmiq  ×2 838/1 · SeqDriver ×2 209/1 · SimpleUVM ×2 0/0 · Scoreboard/default 0/0
BuildUVMPkg ×2 0/0 · Earlgrey_0_1 ×2 0/0 · Rggen/default 0/0
```

The head object, both sides named (`head_pris_MiniAmiq.default.cmp`):

```
LHS  function work@svaunit_vpi_interface.pass_info_to_sv_dpi @72:4-72:48
     vpiAccessType 3 (vpiDPIExportAcc), vpiDPICStr 2 (vpiDPIC),
     7 io_decls (spanning :255), a full body, parent = the interface_inst
RHS  function work@svaunit_vpi_interface.set_test_name @113:4-117:15
     no vpiAccessType, no vpiDPICStr, 1 io_decl, a full body, same parent
```

Neither side is `<null>`, so this is the SINGULAR overload naming an
element-wise mismatch inside a VECTOR — and `ct216if` confirms it: BOTH sides'
`Task_funcs` hold 931 entries and BOTH have a full object at index [900].

## 2. QUESTION (2) — EVERY INTERFACE-SCOPED SUBROUTINE, BOTH SIDES

`POPULATION.r10uvm216.txt` carries the table; `ct216if` and `ct216cen` produced
it. Keyed by DPI-ness × view × holder:

* **VIEW is not a distinguisher for this holder.** Surelog lists a
  never-instantiated interface once, in the design's `AllInterfaces`, and we
  match that (`src/UhdmExporter.cpp:4883-4896`,
  `InstanceSymbol::createDefault`). There is no second, instance-view copy on
  either side.
* **The 21 DPI IMPORTs were never wrong** — 15 hoisted from `uvm_pkg`, six the
  interface's own (:33 :40 :48 :54 :59 :62) — every field (`vpiDPICStr`,
  `vpiDPIContext`, `vpiDPIPure`, io_decl count, has-body) agreeing on both
  binaries.
* **The 3 DPI EXPORTs are the whole story.** `uvm_pkg::m__uvm_report_dpi`,
  hoisted at index [354], we already carried correctly — because its export and
  its definition are ADJACENT items (`uvm_globals.svh:161/162`), so neither the
  position nor the flags question was ever asked of it. The interface's own two
  (:72 and :78, defined at :218 and :255, and in the OPPOSITE order) were the
  head.
* Across the whole MiniAmiq database — every `module_inst`, `interface_inst`,
  `package` and `class_defn` listing, 37151 census cells — exactly **NINE**
  cells differed on the pristine binary and all nine sit in this one holder.
  After: **zero**.

## 3. QUESTION (4) — THE DECODE, AND THE TWO CAUSES

Full transcript in `DECODE.r10uvm216.txt`. In one sentence:

> An `export "DPI-C"` item is handled in the holder's FIRST
> (`CollectType::FUNCTION`) item pass and pushes a NAMED `UHDM::function` right
> there — `CompileModule.cpp:1181-1186` (modules AND interfaces),
> `CompilePackage.cpp:288-293`, `CompileProgram.cpp:346-351`, each
> `compileFunctionPrototype` + `insertFunction`. `setFuncTaskQualifiers`
> (`CompileStmt.cpp:1868-1896`) stamps `vpiAccessType(vpiDPIExportAcc)` and
> `vpiDPICStr(vpiDPIC)` from that node and `populateCoreMembers` gives it the
> EXPORT ITEM'S SPAN. The definition item then runs `compileFunction`, whose
> FIRST act (`CompileStmt.cpp:2353-2358`) is a BARE-NAME scan of
> `component->getTask_funcs()`; it FINDS that object, so it never pushes a
> second entry and never re-populates the core members. Position and span stay
> the export's; `Io_decls` and `Stmt` come from the definition.

We diverged for two independent reasons:

**(P) POSITION.** We emit one entry per `body.members()` item and an `export`
item adds NO slang member, so our entry landed at the DEFINITION's item.
Holder-independent — grid arm B (package) and arm C (module, top AND nested)
diverge exactly like the interface.

**(F) FLAGS.** `Compilation::getDPIExports()` is resolved ONCE, inside
`Compilation::elaborate()` (`checkDPIMethods`, Compilation.cpp:1518-1519), over
the scopes reachable from `getRoot()`. slang auto-instantiates only MODULES and
PROGRAMS as tops (Compilation.cpp:340-366, "Modules and programs"); a
never-instantiated INTERFACE definition goes to `unreferencedDefs`. We still
LIST it, so its body is elaborated AFTER that resolution:
`Scope::elaborate` calls `noteDPIExportDirective` (Scope.cpp:468-470), the
directive reaches `dpiExportDirectives`, and nothing ever resolves it into
`dpiExports`. That is exactly `svaunit_vpi_interface`, and exactly grid arm D.
slang is out of scope to patch, so the export item is read from the SYNTAX —
which is where Surelog reads it too.

## 4. THE PATCH, AND THE ONE THING IT DELIBERATELY DOES NOT DO

`include/UhdmExporter.h` — the law and the `DpiExportOrder216` memo (the
holder's item table plus its exported-name table, keyed on the holder
DECLARATION SyntaxNode; an ITEM-INDEX discipline, never a raw `SourceLocation`
compare across macro/include buffers, RESUME §9).

`src/TaskFuncEmit.cpp` —
`dpiItemListHolder216` / `dpiExportOrder216For` / `dpiExportItem216` /
`dpiExportListingPerm216` / `applyDpiExportPerm216`; ONE fallback beside the
existing `comp.getDPIExports()` scan; ONE key-recording block beside the
existing `tfs->push_back(tf)`; ONE permutation applied after the walk; and ONE
key substitution in `pkgTfOrder9` (the export item's location instead of the
definition's) so the package DEF-listing re-sort and `materializedPkgTfGroup` —
the hoisted copy every wildcard IMPORTER of the package carries — agree with it.

**THE LISTING IS PERMUTED; THE EMISSION WALK IS NOT.** A first cut reordered
`emitTaskFuncs`'s `items` walk instead. That is wrong twice over, and the
measurement said so: creation order is load-bearing for binding (the package
listing's own re-sort says so in `ParamEmit.cpp`), and a package with classes
re-sorts its DEF listing afterwards anyway. So only the finished listing is
permuted — `*tfs` and, for a module/interface view, the `DefInfo::taskFuncs`
copy the views are rebuilt from (arm C fails without that second one).

The permutation is an INSERTION, not a sort by effective item index. The
listing also receives entries that are not members of this holder at all
(MiniAmiq's interface carries 894 subroutines hoisted from `uvm_pkg` and
`svaunit_pkg` ahead of its own 37), and an entry with no item index must never
migrate. An exported entry is re-inserted before the FIRST remaining entry
whose item index is >= the export's; nothing else moves and an unknown index is
never a barrier. **An ADJACENT export/definition pair therefore returns to the
slot it already held**, and an identity permutation is reported as "nothing to
do" so no listing is rewritten that does not change.

Three fences, all measured:
* the subroutine's top-level item must be its OWN `FunctionDeclaration` /
  `TaskDeclaration` — otherwise a CLASS method would match an enclosing
  module's export of the same bare name (the item found by walking up from a
  class method is the CLASS declaration);
* the export's `function`/`task` keyword must match the subroutine kind
  (slang's own check, Compilation.cpp:1959-1968);
* a DPI IMPORT is never also an export (slang: `DPIExportImportedFunc`).

## 5. QUESTION (3) — THE GOLDEN GRID

`grid216.sh` + `grid216/`, six arms × two views, one REAL Surelog golden each
(`~/git-repos/Surelog/build/bin/surelog`, the one `scripts/verify_golden.py`
names), `-parse -d coveruhdm -nobuiltin -nocache` and again with `-elabuhdm`.
The per-arm `uhdm-cmp` verdict is RECORDED and is NOT the scorer (r10uvm210's
caution: `-nobuiltin` makes golden's `AllPackages` shorter than ours, so every
arm's head is that vector-size mismatch). The scorer is the subroutine-listing
census, golden-vs-golden CALIBRATED FIRST in every cell (null in all 12).

| arm | what it varies | rank pris→pat | verdict |
|---|---|---|---|
| **A** `g216_a_iface_export` | THE LAW — an interface whose two exports sit far ahead of their definitions and in the OPPOSITE order, with plain functions and a DPI import between (the MiniAmiq shape, reduced) | **5/5 → 0/0** | closes; absolute-index census 0/0 too |
| **B** `g216_b_pkg_export` | the PACKAGE control — the same shape, separated. `uvm_pkg::m__uvm_report_dpi` only ever agreed because its export is ADJACENT, so this arm asks the question the corpus never asked | **8/8 → 0/0** | closes, package listing AND the importing module's hoisted copy |
| **C** `g216_c_module_export` | the MODULE control, a TOP module and a NESTED instance | **6/6 → 0/0** | closes; the arm that convicted the `DefInfo::taskFuncs` copy |
| **D** `g216_d_iface_top` | THE CORPUS TOPOLOGY — a portless interface no module instantiates, i.e. the (F) shape | 0/0 → 0/0 (RANK-BOTH 4→6) | the FLAGS half: absolute-index census **6/6 → 0/0** |
| **E** `g216_e_iface_variants` | a TASK export, an export with an explicit C identifier, an ADJACENT export, an export beside a `modport` | **3/3 → 0/0** | closes; the task and the c-identifier cells were already right and stay right |
| **F** `g216_f_muststay` | THE MUST-STAY CONTROL — DPI imports (context/plain/pure), plain functions, a task, a modport, an `extern` prototype, a class with an out-of-body method, plus ONE export as the POSITIVE control | **2/2 → 0/0** | only the export cell moves |

**ONLY-GOLDEN never rises and ONLY-OURS never rises, in any arm, in either
view: AWAY-GOLDEN 0, MOVED-WRONG 0.**

Arm F is where the absolute-index census had to be replaced by a shift-immune
one. Golden hoists an out-of-body class-method definition (`f216_cls::get`)
into the interface listing and we do not — a PRE-EXISTING residue of a
different family, unchanged by this pass — so one entry that only golden holds
shifts every later index and an absolute-index census reads the arm as WORSE
while its relative order became exactly golden's. `rank216.py` ranks each side
among only the entries both sides hold and reads the truth: 2/2 → 0/0.

## 6. QUESTION (5) — THE PREDICTION, AND THE THREE MOVERS IT DID NOT NAME

`PREDICT.r10uvm216.txt` was written from PRISTINE databases and PRISTINE
sources alone, before the patched binary existed. `predict216.sh` takes each
database's own `VpiFile` set (`cmds.txt` does not list `include`d files) and
greps it: a database that never compiled a file carrying an `export "DPI-C"`
item is untouchable by construction.

* FIRE SET: **15 of 956** surelog row-modes, **4 of 1358** uhdm2rtlil.
* Of those, only `MiniAmiq` ×2 has a SEPARATED export item
  (svaunit_vpi_interface.sv:72/:78 vs :218/:255); every other export in the
  corpus is adjacent to its definition (uvm-1.2 `uvm_globals.svh:161/162`,
  1800.2-2017 `pp_output/uvm_pkg.sv:9577/9578`, and the five small tests).
* PREDICTION: **exactly two** surelog byte movers, `MiniAmiq` ×2, 9 cells each,
  TO-GOLDEN 18 / AWAY 0 / MOVED-WRONG 0 / UNSEEN 0; **zero** uhdm2rtlil movers.

**MEASURED: 6 / 956 and 0 / 1358.** MiniAmiq ×2 land exactly as predicted, cell
for cell (`CENSUS.r10uvm216.txt`). `BuildUVMPkg` ×2 and `SeqDriver`/default were
NOT predicted, and this pass says so rather than dressing it up. The sixth,
`Scoreboard`/default, is THE COIN and not a mover at all: its raw dump diff is
92 lines — the documented `svunit_pkg` `vpiTaskFunc` order flip — and **0 lines
ORDER-BLIND**, and the replay control reads pristine = patched = layout-null
(`61ee9cb4f6c1`) on the same command line, so the binary does not decide the
face.

They are attributed, not argued. Two throwaway control binaries were built from
a clean `b7eb7ff3`:

* the **LAYOUT-NULL** control — two unused members of exactly the law's shape,
  so the binary's static layout changes and its behaviour cannot. It does NOT
  reproduce the movement, so this is not the campaign's known static-address
  class.
* the **ALLOCATION-ONLY** control — the full patch with `dpiExportItem216`
  forced to return `nullptr` after building the memo, so the memo is populated
  for every holder and every member (uvm_pkg alone has thousands of items) and
  the law can NEVER fire. It reproduces `BuildUVMPkg`/default and
  `SeqDriver`/default **at exactly the patched md5s**, and leaves
  `MiniAmiq`/default **at exactly the pristine md5**.

So those three databases move for the memo's heap ALLOCATION — which perturbs
object-creation order — and not for the law. Independently:

* `BuildUVMPkg` ×2: `uhdm-dump` output **byte-identical** between the two
  binaries (raw diff 0 lines), `uhdm-cmp` output byte-identical at 0 lines, the
  listing census identical and already exactly golden's on both binaries.
* `SeqDriver`/default: `uhdm-cmp` output **byte-identical** (209 lines, the same
  head object); the dump differs in 26 lines that are object ids plus the
  position of ONE `logic_typespec (uvm_hdl_data_t)` block inside a Typespecs
  listing — **0** lines once the dumps are sorted and `id:` is normalised.
  `SeqDriver`/testflags does not move at all.

An earlier cut of this pass reordered the emission WALK rather than the LISTING,
and that is how the memo's allocation was found: with the walk reordered these
same three databases moved to the SAME md5s, which is what made "it must be
allocation, not order" testable at all. §4 records the fix; R1 records the
cheap way for a later pass to remove the churn (build the memo lazily, only
once a `DPIExport` item is seen in the holder's member list).

## 7. QUESTION (6) — THE GATES AND THE BOUNDARY

`GATES.r10uvm216.txt` carries every number. Headlines: goldens 23/0 on both
binaries with the `/bin/false` control at 23 FAIL; uhdm2rtlil 679/50/2 in both
modes on both binaries with `ct8rows` PASS three ways and `byteverify` 0/1358;
surelog 475/6 + 469/6 on both binaries with `ct8rows` PASS against the committed
baseline AND against this pass's own pristine — **0 differing rows over 1588,
status column and dump column, NO ROW CONVERTED IN EITHER DIRECTION**.

The seven protected CMP_EQUAL row-modes, both columns scored explicitly, judge
rc = 0 on both binaries: `BuildUVMPkg` ×2, `SimpleUVM` ×2, `Earlgrey_0_1` ×2,
`Scoreboard`/default — all HELD.

Canaries: `canaries.sh` ok=51 changed=1 (surelog — the ONE changed row is the
`Earlgrey_0_1`/default dump-timeout cell decomposed just above) and ok=8
changed=0 (u2r);
`ctcan2.sh` PASS on both with the expected UNKNOWN counts; `canaudit.sh
canaries.sh ctcan2.sh` audited=29 UNCOVERED=0 **FENCE-BREACH=0**.
Protected databases by name: `InterfaceModPort` (an INTERFACE test) SAME,
`BlackParrotComplex` SAME, `YosysOldOr` SAME, `SVSwitch` pinned at
`4842211c4030`, `YosysVerx` pinned at `6ccda350c24a`.

The one informational cell that moved is decomposed in `GATES.r10uvm216.txt`:
`Earlgrey_0_1`/default's uhdm-dump comparison cell came back BLANK because this
sweep ran concurrently with the 5511-arm boundary gate and that row's dump timed
out. Its STATUS is CMP_EQUAL on both sides, its database md5 is identical on
the pristine sweep, the patched sweep and a clean re-run, `rowheads.sh` reads it
at 0 cmp lines / rc 0 on both binaries, and re-running that single row alone on
the patched binary reproduces the committed row exactly. It is the same
informational TIMEOUT r10uvm214 recorded on its own pristine run.

Wide boundary over a COPY of the whole probe tree (subdirectories included, both
views, both binaries, children `</dev/null`, the file list on fd 3, scratch
keyed on the RELATIVE path): **LISTED = PROCESSED = 5511, MOVED_ARMS 12,
RC_DIFFS 0**. Six are this pass's own grid arms — the POSITIVE CONTROL that
proves the gate can see. All 24 moved arm-views are re-scored against REAL
Surelog goldens by `armscore216.sh` (calibration null in every arm-view):
**TO-GOLDEN 108, AWAY-GOLDEN 0, STILL-WRONG 0**.
`r10v170repro/v170_p_export.sv` — § 170's own export-ordering arm, the only
earlier-pass arm carrying an export item — moves TOWARD golden. The other five
are the layout class, proved on five tells in `FALSEMOVER.r10uvm216.txt`, whose
TELL 5 (order-blind + id-normalised + address-normalised whole-dump diff) reads
ZERO differing lines on all ten of their arm-views. **No § 214 arm, no § 213
arm, no § 207/208/211 arm, no uvm82-91 (113 arms), no buvm3-15 (119) and no
sd8-12 arm (347, subdirectories included) moved.**

## 8. THE FILES

| file | what it is |
|---|---|
| `ct216if.cpp` | THE SHAPE DECODER — every interface's `Task_funcs` listing, in index order, with vpiAccessType / vpiDPICStr / vpiDPIContext / vpiDPICIdentifier / #io / has-body per entry. |
| `ct216cen.cpp`, `cen216.py`, `list216.py` | THE CENSUS — `POS|` (holder × index × payload) and `MEM|` (order-blind) key families, the multiset join, and the per-holder pretty printer. `--files` is the corpus predictor's input; `--nobuiltin` is for the grid only. |
| `rank216.py` | THE SHIFT-IMMUNE ORDER SCORER — ranks each side among ONLY the entries both sides hold, so one entry that only golden holds cannot read as N moved cells. |
| `predict216.sh`, `PREDICT.r10uvm216.txt` | question (5), written before the patched binary existed. |
| `cen216.sh`, `CENSUS.r10uvm216.txt` | the corpus census, both corpora × both modes. |
| `grid216.sh`, `grid216/`, `GRID.pristine.*`, `GRID.patched.*` | question (3). |
| `DECODE.r10uvm216.txt`, `POPULATION.r10uvm216.txt` | questions (1), (2), (4). |
| `bound216.sh`, `armscore216.sh`, `falsemover216.sh`, `nullctl216.sh` | question (6): the wide boundary, the against-golden re-score, the five false-mover tells, and the layout-null / allocation-only control driver. |
| `BOUNDARY.r10uvm216.txt`, `ARMSCORE.r10uvm216.txt`, `FALSEMOVER.r10uvm216.txt`, `NULLCTL.r10uvm216.txt`, `GATES.r10uvm216.txt` | their transcripts. |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the head on both binaries. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` `scrub216.sh` | the standing gate scripts, copied unchanged. |

## 9. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD IS `ref_obj::Actual_group` INSIDE THE EXPORTED
  FUNCTION'S BODY.** 29 lines, one head, both row-modes. Golden's
  `ref_obj (…pass_info_to_sv_dpi.a_sva_type)` at
  `svaunit_vpi_interface.sv:258:10` carries `vpiActual -> io_decl a_sva_type`
  (:255:103); ours carries none, so the SINGULAR overload prints golden's value
  with `RHS: <null>` (RESUME §9, the buvm13/15 shape). A FORMAL-ARGUMENT
  reference in a DPI-EXPORTED function's body binds its `io_decl` on golden and
  stays unbound on ours. `head_pat_MiniAmiq.default.cmp` carries it.
* **R1 — THE MEMO'S ALLOCATION MOVES THREE DATABASES' BYTES.** `BuildUVMPkg` ×2
  and `SeqDriver`/default, proved with the allocation-only control (§6). The
  memo is built for every holder and every member; a later pass that wants a
  zero-byte-churn version can build it lazily (only once a `DPIExport` item is
  seen in the holder's member list) — the law's cells are unaffected either way.
* **R2 — AN EXPORT WRITTEN *BELOW* ITS DEFINITION MAKES GOLDEN EMIT TWO
  ENTRIES.** Grid-adjacent evidence from `r10v170repro/v170_p_export.sv`:
  `epsil7` is defined at :55 and exported at :58, and golden lists BOTH the
  definition (UNSTAMPED, at its own slot) AND a second, EMPTY
  `vpiAccessType=EXPORT` prototype at the export's slot. We emit one, stamped.
  Unchanged pristine to patched, and no corpus row has that shape (every corpus
  export is written ABOVE or ADJACENT to its definition), so it is recorded, not
  taken. It is the other half of `CompileStmt.cpp:2353-2358`: the reuse scan
  lives in `compileFunction`, not in `compileFunctionPrototype`.
* **R3 — AN OUT-OF-BODY CLASS-METHOD DEFINITION IS NOT HOISTED INTO AN
  INTERFACE LISTING.** Grid arm F: golden's `work@f216_if` listing carries
  `f216_cls::get`, ours does not. A different family (§ `classOobTfs` hoists it
  into a MODULE and a PACKAGE listing but not an interface's), unchanged by this
  pass, and the reason arm F needs the shift-immune scorer.
* **R4 — A TASK EXPORT KEEPS THE DEFINITION'S SPAN.** Golden emits
  `export "DPI-C" task t;` as a `function` object (we match) but leaves its span
  at the DEFINITION, unlike the function case where the span is the export's
  (grid arm E, `e216_task` @31:4-33:11). We already match that asymmetry — the
  existing `setLoc` arm is gated on `SubroutineKind::Function` — but the
  asymmetry itself is unexplained and is recorded, not modelled.
* **R5 — GOLDEN STAMPS NO `vpiDPICIdentifier`.** Even for
  `export "DPI-C" cid = function f;` golden leaves it empty (arm E, `e216_cid`,
  `cid=-` on both sides). Already agreeing; untouched.
