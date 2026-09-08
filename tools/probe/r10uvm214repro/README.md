# r10uvm214 — § `pkgCloneBodyBindsOwnListingRhs214` — **A PACKAGE'S *DEF* LISTING OF AN OUT-OF-BODY CLASS METHOD BINDS A PACKAGE-PARAMETER REFERENCE TO *THAT LISTING'S OWN* `param_assign` Rhs — UNLESS A COMPILATION-UNIT IMPORT HOISTS THE NAME INTO THE DESIGN** — the SeqDriver/MiniAmiq head clears on all four row-modes and the def-listing binding population of every UVM row is now exactly golden's

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; the corpus predictor walks a sweep workdir that contains
them, so `scrub214.sh` redacts their names out of every artifact — reading the
fence list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s
own `FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `adbec035` |
| pristine binary | md5 `e087ade1fc9236ff2aa79057ce5d262d`, built `-j 2` from this pass's OWN worktree at a clean `adbec035` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `49b83611ebc24e7155c5e62e6c8e23e2`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` (the binding arm, inside § `pkgParamRefKeepsCloneBare178`'s own block), `src/UhdmExporter.cpp` (three lines of condition inside § `unitImportHoistsPkgParams146`'s existing re-point loop) and one `std::set` member in `include/UhdmExporter.h`. **+179 / −2 lines, of which 150 are the decoded comment. No new pass, no new phase, nothing minted, nothing removed, one pointer moved per cell.** |
| probe surface | `tools/probe/r10uvm214repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **SeqDriver ×2 and MiniAmiq ×2, 50 cmp lines / ONE head each** — the last workable head in the corpus. Every other row at BASE: SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. |
| the head after | **THE OBJECT IS GONE.** SeqDriver ×2 read 209 lines / 1 head and MiniAmiq ×2 read 838 / 1 — a NEW head object each (RESUME §7: a line count going up with a CHANGED object is the new head's decompile size). The old pair's objects appear nowhere in the new logs. R0. |
| the brief's law | **CONFIRMED, decoded to Surelog `file:line`, and closed on every UVM row** — with a SECOND CONJUNCT this pass had to decode after a first cut regressed three row-modes (§ 4). |
| the blast radius (question 2) | **59 reads of the two package view flags; 34 fire on the head row; NINETEEN fire INSIDE the clone driver's window**, measured with a throwaway tap binary. `src/ExprEmit.cpp:13534` — this pass's site — fires **17** times in-window, **exactly the 17 divergent cells the binding census names**. The other eighteen are recorded by `file:line` as a residue: firing in the window is necessary, not sufficient, and the census says every one of them decides correctly today. |
| the reference population (question 2) | In the home DEF listing `package[ALLPKG:uvm_pkg]` SeqDriver holds **36** package-parameter references on both sides. GOLDEN binds **22 operations, 13 constants, 1 ref_obj**; we bound **11 operations, 25 constants**. The 17 that differ are ALL and ONLY the ones in out-of-body class-method clone bodies; the 14 under `param_assign` initialisers, the 4 under typespec ranges and the 3 in FREE-function bodies already agreed. The elaborated listing (197 refs, 178 `<null>` on both sides) and the two import-clone listings (19 refs, all `<null>`) already agreed. **After the patch our column reads `constant=13 operation=22 ref_obj=1` — golden's, exactly.** |
| the golden grid (question 3) | **8 arms × 2 views = 16 arm-views, one REAL Surelog golden each, 0 NO-DATABASE, golden-vs-golden CALIBRATION null in all 16.** In the corpus (parse) view arms **A**, **D**, **E**, **F** close their law cells (A: AGREE 16→33, D: 5→10, E: 1→2, F: 3→4) and arms **B**, **C**, **G**, **H** are **census-identical on the two binaries**. **No `ONLY-GOLDEN` and no `ONLY-OURS` row is ADDED in any arm in either view: AWAY-GOLDEN 0, MOVED-WRONG 0.** |
| the a-priori prediction (question 5) | Written from PRISTINE databases alone, BEFORE the patched sweep existed: **exactly SIX row-modes over 956 surelog databases** — `SeqDriver` ×2 and `MiniAmiq` ×2 (17 cells each) and `BuildUVMPkg` ×2 (8 cells each) — **TO-GOLDEN on every cell, AWAY 0, MOVED-WRONG 0, UNSEEN 0** — and **none of the 1358** uhdm2rtlil databases. |
| byte movers | **6 / 956** surelog — EXACTLY the six predicted BY NAME — and **0 / 1358** uhdm2rtlil. SELFCHECK controls fire at 955/956 and 1357/1358. |
| the protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `SimpleUVM` ×2, `Earlgrey_0_1` ×2 and `Scoreboard`/default — **all seven CMP_EQUAL on BOTH binaries at judge rc = 0, both columns scored** (§ 7). `BuildUVMPkg` ×2 are byte movers **by design**: eight cells each, every one landing on golden's own value (the r10uvm213 precedent, predicted by name first). |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` negative control 23 FAIL; uhdm2rtlil **679 / 50 / 2 in BOTH modes on both binaries**, `ct8rows` PASS, `byteverify` 0/1358; surelog 1588 rows, status histogram **475/6 default + 469/6 testflags UNCHANGED — no row converted in either direction**; wide boundary **LISTED 5489 = PROCESSED 5489, RC_DIFFS 0, 18 moved arms, all 36 arm-views re-scored against real goldens: parse-view TO-GOLDEN 96, AWAY-GOLDEN 0, MOVED-WRONG 0**. |

---

## 1. THE HEAD, AND THE PRISTINE BASELINE, MEASURED FIRST

This pass built its own pristine binary from a clean `adbec035` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`e087ade1…`). Before a line was written: `check_goldens.sh` 23 PASS / 0 FAIL
with the `/bin/false` control at 23 FAIL; both uhdm2rtlil sweeps 679/50/2 with
`ct8rows` PASS against the committed baseline; the surelog sweep reproducing the
committed status histogram exactly (475/6 + 469/6), the only cell differing from
the committed CSV being the recorded informational `Earlgrey_0_1` uhdm-dump
TIMEOUT.

`rowheads.sh` on that sweep:

```
SeqDriver ×2 50/1 · MiniAmiq ×2 50/1 · SimpleUVM ×2 0/0 · Scoreboard/default 0/0
BuildUVMPkg ×2 0/0 · Earlgrey_0_1 ×2 0/0 · Rggen/default 0/0
```

The head pair, both objects named (`head_pris_SeqDriver.default.cmp`):

```
LHS  ref_obj (uvm_pkg::UVM_SET) id=61413 @217:31, parent param_assign @217:11,
     vpiActual = operation @216:31
RHS  constant 131078 size 32 @217:31, parent param_assign @217:11
```

`ct214bind --one` puts golden's object in `package[ALLPKG:uvm_pkg]` and ours in
`package[TOPPKG:uvm_pkg]` — a DEF/ELAB crossing — and `ref_obj::Compare` reads
`Actual_group`, so the link that carries the judge across is the body reference
`__m_uvm_field_automation(null, UVM_SETINT, field_name)` (uvm_object.svh:933) in
the DEF listing's clone of `uvm_object::set_int_local`. r10uvm213's R0,
confirmed object for object.

## 2. QUESTION (2) — THE BLAST RADIUS, AND THE POPULATION

`BLASTRADIUS.r10uvm214.txt` carries the tap. A **throwaway** instrumented binary
(never part of the patch) rewrote every read of `pkgEmitTopView` and
`pkgTopEmit` — 59 reads over the five emitter TUs — into
`(r214tap(site, pkgClassTfClone, pkgImportCloneEmit), <flag>)` and counted, per
site, the fires inside the clone driver's window. On SeqDriver 34 sites fire and
**19 fire in-window**; `src/ExprEmit.cpp:13534` fires **37 times, 17 of them
in-window**, and the binding census independently names **17** divergent cells.
The other eighteen in-window sites are recorded by `file:line`; they are a map
for a later pass, not a claim — the census says the def-listing population of
every UVM row is now exactly golden's, so none of them is wrong today.

`POPULATION.r10uvm214.txt` carries the population table by listing × referent
kind for golden, pristine and patched. The separation is total: in the home DEF
listing every reference in an out-of-body class-method clone body diverged (17 of
17) and every other reference in that same listing already agreed (21 of 21) —
which is exactly the window `pkgClassTfClone && !pkgImportCloneEmit` names.

## 3. QUESTION (3) — THE GOLDEN GRID

`grid214.sh` + `grid214/`, eight arms × two views, one REAL Surelog golden each
(`~/git-repos/Surelog/build/bin/surelog`, the one `scripts/verify_golden.py`
names), `-parse -d coveruhdm -nobuiltin -nocache` and again with `-elabuhdm`.
The per-arm `uhdm-cmp` verdict is RECORDED and is NOT the scorer (r10uvm210's
caution: `-nobuiltin` makes golden's `AllPackages` one entry shorter than ours,
so every arm's head is that vector-size mismatch). The scorer is the binding
census, golden-vs-golden CALIBRATED FIRST in every cell (null in all 16).
Full transcript: `GRID.pristine.r10uvm214.txt`, `GRID.patched.r10uvm214.txt`.

| arm | what it varies | parse AGREE pris→pat | verdict |
|---|---|---|---|
| **A** `g214_a_oob` | THE LAW — out-of-body class methods reading the package's own parameters, one per REFERENT KIND (literal constant, bare param ref, operation, string, typed vector) × one per READ POSITION (call argument, assignment Rhs, operation operand, return expression, condition, task body) | **16 → 33** | 17 cells close; **no position conjunct and no kind conjunct** |
| **B** `g214_b_inbody` | the IN-BODY control — the same reads with the methods defined inside the class body | 7 → 7 | census-identical |
| **C** `g214_c_freefunc` | the package FREE-SUBROUTINE control — already view-correct (written in the package's own def pass) | 14 → 14 | census-identical: must-stay held |
| **D** `g214_d_pkgimp` | THE CORPUS TOPOLOGY — an importing package, so both importer listings carry a `clone_tree` copy | **5 → 10** | the 5 HOME cells close; the import-clone cells do not move (§ 178's fence) |
| **E** `g214_e_foreign` | a FOREIGN package's parameter read from a def clone body, qualified and wildcard-imported, beside the package's own | **1 → 2** | only the OWN-parameter cell moves; golden holds no reference at all for the foreign reads (the fold family's residue) |
| **F** `g214_f_muststay` | THE MUST-STAY CONTROL — class parameter, subroutine-scope localparam, formal, body local, class constant, enum member, plus ONE own package parameter as the positive control | **3 → 4** | only the package-parameter cell moves |
| **G** `g214_g_nonpkg` | the NON-PACKAGE HOMES — a module-homed and a `$unit`-scope class with out-of-body methods | 1 → 1 | census-identical: the window never opens |
| **H** `g214_h_unitimp` | THE `$unit` CONJUNCT — arm A's shape plus a compilation-unit `import P::*;` | 5 → 5 | census-identical: the law stands down, as golden asks |

**ONLY-GOLDEN never rises and ONLY-OURS never rises, in any arm, in either
view: AWAY-GOLDEN 0, MOVED-WRONG 0.** In the `-elabuhdm` column every arm is
census-identical between the two binaries except for the law's own cells, which
change payload while staying `ONLY-OURS` — golden's elaborated database binds
design-level `parameter` objects throughout, a pre-existing gap this law does
not touch and does not widen (AGREE never falls).

## 4. QUESTION (4) — THE DECODE, AND THE CONJUNCT A FIRST CUT MISSED

`DECODE.r10uvm214.txt` carries it with `file:line`. In one paragraph:
`UhdmWriter::lateBinding` (UhdmWriter.cpp:3294) walks each component's own
late-binding list and answers a name in a fixed ORDER — (1) a `::`-qualified
spelling, (2) **the reference's PARENT CHAIN, whose `uhdmdesign` case binds
`d->Parameters()` BY NAME** (UhdmWriter.cpp:3358), then nets and variables, then
(3) `m->Param_assigns()` with `m` **the component being written**, which for a
package binds `p->Rhs()`. A package is compiled and written TWICE
(CompilePackage.cpp:60-72), so step (3) hands each listing its own Rhs. Our
class-method clone listing is written by `emitPackageClassMethodClones`, which
runs inside `emitPackage`'s `if (topView)` block, so `pkgEmitTopView` is TRUE
while the DEF listing is written and the arm bound the ELABORATED Rhs
(r10uvm213's R5). The window is `pkgClassTfClone && !pkgImportCloneEmit`, the
home test is step (3)'s own `m->Param_assigns()`, and
`pkgParamDefRhsDefView17` is the one map the top pass never overwrites.

**THE SECOND CONJUNCT WAS NOT IN THE BRIEF AND IS RECORDED HERE BECAUSE A FIRST
CUT WITHOUT IT REGRESSED THREE ROW-MODES.** Step (2) runs BEFORE step (3): where
a COMPILATION-UNIT `import P::*;` hoists P's parameters into
`design->Parameters()`, golden binds the DESIGN-LEVEL PARAMETER OBJECT and not
the listing's Rhs. `SimpleUVM` (`import uvm_pkg::*` on line 1 of testbench.sv)
and `Scoreboard` (`import svunit_pkg::*` on line 2) are that shape;
`SeqDriver` — whose imports sit inside `package adpcm_pkg` and inside
`module top_tb` — is not, and golden binds the Rhs there. In the SAME
`uvm_object::set_int_local` clone at 933:34 of the SAME uvm-1.2 source with the
SAME surelog flags:

```
SimpleUVM golden    vpiActual: parameter (UVM_SETINT), line:217:11
Scoreboard golden   vpiActual: parameter (UVM_SETINT), line:217:11
SeqDriver golden    vpiActual: ref_obj (uvm_pkg::UVM_SET), line:217:31
```

The first cut moved that one cell on `SimpleUVM` ×2 and `Scoreboard`/default and
the census scored it **AWAY-GOLDEN 1** on each — nine byte movers where six were
predicted. Grid arm H was built for the shape afterwards and reproduces it.

**AND THE SECOND CUT IS RECORDED AS REFUTED TOO.** Testing the conjunct at the
site — `cu->lookupName(sym.name)` over `comp.getCompilationUnits()` — suppressed
the law correctly and **forced AST binding during the def phase**: with the law
standing down on `SimpleUVM` exactly as intended that row's database still
moved, and the order-blind whole-dump diff pinned it to four lines that have
nothing to do with this law — `uvm_report_message.svh:337`'s
`queue_of_element[$]` right bound going `0` → `1475` where golden holds `$`, a
MOVED-WRONG cell. RESUME §9 records exactly this Heisenbug. What shipped instead
needs no lookup at all: the bind is recorded in `cloneRhsBound214` and
§ `unitImportHoistsPkgParams146`'s existing post-emission re-point accepts a ref
from that pool exactly as it accepts one bound to a constant or an operation —
which reproduces Surelog's own precedence, the parent-chain walk winning over
`m->Param_assigns()`, with no second decision and no new phase. (The maps § 146
fills do not exist while packages are emitted, and the name set is not spellable
from the imports either: `Scoreboard` hoists `UVM_SETINT` through
`import svunit_pkg::*`, one package further out than the parameter's home.)
With the pool, `SimpleUVM`'s database is **byte-identical** to the pristine one.

## 5. QUESTION (5) — THE PREDICTION AND THE CENSUS

`predict214.py` defines the fire set FROM OUR DATABASE ALONE — a reference in a
`package[ALLPKG:P]<function|task:C::m` holder whose actual lives in
`package[TOPPKG:P]`, for which our own ALLPKG listing holds a `param_assign` of
that name — and reads that `param_assign`'s Rhs as the PREDICTED POST-PATCH
PAYLOAD, so every cell's new value is named before the patched binary exists.
Only then is golden read, for the verdict. `predictall214.sh` walks a whole
sweep workdir. `PREDICT.surelog.r10uvm214.txt` /
`PREDICT.uhdm2rtlil.r10uvm214.txt`:

```
surelog     956 databases   rows with FIRE>0 = 6
              SeqDriver ×2   FIRE=17 TO-GOLDEN=17 AWAY=0 MOVED-WRONG=0 UNSEEN=0
              MiniAmiq  ×2   FIRE=17 TO-GOLDEN=17 AWAY=0 MOVED-WRONG=0 UNSEEN=0
              BuildUVMPkg ×2 FIRE=8  TO-GOLDEN=8  AWAY=0 MOVED-WRONG=0 UNSEEN=0
uhdm2rtlil 1358 databases   rows with FIRE>0 = 0
```

The `[package[TOPPKG:P]]` clause in that predicate IS the `$unit` conjunct: a
design-hoisted cell already binds a `parameter` object, so it never fires — which
is why the predicate named six rows while the first cut moved nine, and how the
over-fire was caught.

`cen214.sh` + `score214.py` score the rows cell by cell against their own
goldens, golden-vs-golden calibrated first on every row
(`CENSUS.r10uvm214.txt`). The def-listing scope, four columns:

| row-mode | RIGHT-BOTH | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG |
|---|---|---|---|---|
| `SeqDriver` default / testflags | 17 | **17** | 0 | 0 |
| `MiniAmiq` default / testflags | 17 | **17** | 0 | 0 |
| `BuildUVMPkg` default / testflags | 0 | **8** | 0 | 0 |
| `SimpleUVM` default / testflags | 17 | 0 | 0 | 0 |
| `Scoreboard` default | 17 | 0 | 0 | 0 |
| `Earlgrey_0_1` default / testflags | — | — | — | — (population 0) |

and the whole def-listing census after the patch reads **ONLY-GOLDEN 0 /
ONLY-OURS 0 on every one of the nine UVM row-modes** (51 cells on SeqDriver and
MiniAmiq, 8 on BuildUVMPkg, 17 on SimpleUVM and Scoreboard).

## 6. QUESTION (6) — THE GATES

Full transcript in `GATES.r10uvm214.txt`; the boundary in
`BOUNDARY.r10uvm214.txt` and `ARMSCORE.r10uvm214.txt`.

* **binaries.** pristine `e087ade1…` (byte-identical to the main tree's
  `build/slang-uhdm` at `adbec035`), patched `49b83611…`, both frozen
  `chmod 555` before any sweep. Every `cmds.txt` in all four sweep workdirs
  names EXACTLY ONE binary and it is the right one, audited BY PATH
  (`/tmp/r10uvm214_pris.bin` in the two pristine workdirs,
  `/tmp/r10uvm214_pat.bin` in the two patched ones).
* **goldens.** 23 PASS / 0 FAIL on BOTH binaries with `SLANG_UHDM` exported
  explicitly; `SLANG_UHDM=/bin/false` gives 0 PASS / 23 FAIL.
* **uhdm2rtlil, both modes, both binaries.** 679 CMP_EQUAL / 50 SLANG_REJECT /
  2 SURELOG_FAIL. `ct8rows` PASS against the committed baseline and against
  this pass's own pristine testflags and default sweeps. `byteverify`
  **0 / 1358**, SELFCHECK control 1357/1358.
* **surelog, `--mode both`, 1588 rows.** Status histogram **475/6 default,
  469/6 testflags on BOTH binaries — NO ROW CONVERTED IN EITHER DIRECTION.**
  `ct8rows` patched vs this pass's own pristine sweep: **one** differing row —
  `Earlgrey_0_1,default` dump column `differ` → empty, status `CMP_EQUAL` on
  both, the recorded uhdm-dump TIMEOUT under sweep load; that database is **not
  a byte mover**. Against the committed baseline the same cell plus its
  testflags twin, which this pass's PRISTINE sweep reads the same way.
* **byte movers.** **6 / 956** surelog, EXACTLY the six predicted BY NAME;
  **0 / 1358** uhdm2rtlil; SELFCHECK controls fire at 955/956 and 1357/1358.
* **canaries.** surelog `ok=50 changed=2` against the committed baseline (those
  Earlgrey dump-column cells) and `ok=51 changed=1` against this pass's own
  pristine sweep (the one that flips with sweep load); uhdm2rtlil
  `ok=8 changed=0`; `ctcan2` PASS ×2; `canaudit` PASS. All protected databases
  byte-identical between the binaries, including the two pinned digests
  **SVSwitch `4842211c4030`** and **YosysVerx `6ccda350c24a`**.
* **rowheads, both binaries.** SeqDriver ×2 50→**209**, MiniAmiq ×2 50→**838**
  (a NEW head object each), and SimpleUVM ×2 / Scoreboard/default /
  BuildUVMPkg ×2 / Earlgrey_0_1 ×2 / Rggen/default **0 lines, 0 heads at judge
  rc = 0 on both binaries**.
* **the wide boundary.** `LISTED=5489 PROCESSED=5489 PRODUCED_DBS=5296
  MOVED_ARMS=18 RC_DIFFS=0`, with this pass's own four moving grid arms in the
  mover list as the POSITIVE CONTROL. All 18 re-scored against REAL Surelog
  goldens in both views (36 arm-views, 0 not scored, calibration null in all
  36): **parse view TO-GOLDEN 96 / AWAY-GOLDEN 0 / MOVED-WRONG 0**. In the
  `-elabuhdm` column AWAY-GOLDEN is 0 as well; the MOVED-WRONG cells there are
  the law's own, wrong before and after against an elaborated golden that binds
  design-level `parameter` objects throughout. **No `r10uvm205` / `r10uvm207` /
  `r10uvm208` / `r10uvm210` / `r10uvm213` arm is in the mover list at all, and
  no `sd8-12` arm moved.** The `uvm82-91` range contributes `g88_a2_bound`
  (parse TO-GOLDEN 2) and `g95_a5_oob` (2), the `buvm3-15` range contributes
  `g30_a_shapes` (1) and `vg30_h_macro` (1), and § 178's own `g178_e_oob` moves
  3 cells TO-GOLDEN — every one with AWAY-GOLDEN 0 and MOVED-WRONG 0 in the
  corpus view.

**The seven protected CMP_EQUAL row-modes, both columns, explicitly:**

| row-mode | status pris → pat | rowheads pris → pat | census |
|---|---|---|---|
| `BuildUVMPkg` default | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | TO-GOLDEN 8, AWAY 0, MOVED-WRONG 0 |
| `BuildUVMPkg` testflags | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | TO-GOLDEN 8, AWAY 0, MOVED-WRONG 0 |
| `SimpleUVM` default | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | not a mover — database byte-identical |
| `SimpleUVM` testflags | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | not a mover — database byte-identical |
| `Scoreboard` default | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | not a mover — database byte-identical |
| `Earlgrey_0_1` default | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | not a mover — database byte-identical |
| `Earlgrey_0_1` testflags | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | not a mover — database byte-identical |

**TWO of the seven are byte movers BY DESIGN** — said loudly, because a
CMP_EQUAL row changing bytes is exactly what a gate exists to catch.
`BuildUVMPkg` ×2, eight cells each, every cell landing on **golden's own
value** (including the two whose size goes 32→64 and the four whose kind goes
`constant`→`operation`), both staying CMP_EQUAL at judge rc = 0 with rowheads
0 lines / 0 heads. Predicted BY NAME from pristine databases before the patched
sweep existed.

## 7. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct214bind.cpp` | THE BINDING READER: `--refs` / `--keycount` every package-parameter reference with what its `Actual_group` names and THE LISTING that object lives in, `--pop` the population table by listing × referent kind, `--parhs` every `param_assign`'s Rhs in the same payload form (what a def listing's own reference must land on), `--one` a single object with its chain. |
| `ct214route.cpp` | r10uvm213's ROUTE FINDER, copied unchanged: the official generated `design::Compare` with golden objects pre-seeded into `m_visited`, so "which link produced this pair" is answerable. |
| `ct213ts.cpp` | r10uvm213's per-view placeholder reader, copied unchanged so its readings reproduce here. |
| `cen214.py`, `cen214.sh`, `score214.py` | the multiset census join, the row driver and the four-column scorer. |
| `predict214.py`, `predictall214.sh` | the a-priori prediction from pristine databases alone. |
| `grid214.sh`, `grid214/` | the 8-arm golden grid, both views, real Surelog goldens. |
| `bound214.sh`, `armscore214.sh` | the wide boundary gate over a COPY of the whole probe tree, and the re-score of every mover against a real golden. |
| `scrub214.sh` | the fence scrub (reads `FENCED=` out of `canaudit.sh`; never spells a fenced name). |
| `BLASTRADIUS.r10uvm214.txt` | question (2): the view-flag tap, per `file:line`. |
| `POPULATION.r10uvm214.txt` | question (2): the reference population by listing × referent kind, three databases. |
| `GRID.pristine.r10uvm214.txt`, `GRID.patched.r10uvm214.txt` | question (3). |
| `DECODE.r10uvm214.txt` | question (4), with Surelog `file:line` and both refuted cuts. |
| `PREDICT.*.r10uvm214.txt`, `CENSUS.r10uvm214.txt` | question (5). |
| `GATES.r10uvm214.txt`, `BOUNDARY.r10uvm214.txt`, `ARMSCORE.r10uvm214.txt` | question (6). |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the head on both binaries. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged. |

## 8. RESIDUES

* **R0 — THE NEW SeqDriver / MiniAmiq HEAD IS THE INTERFACE FAMILY.** With the
  binding repaired, `uhdm-cmp` stops on a different object in all four
  row-modes:
  * `SeqDriver` ×2, 209 lines, one head — **`LHS: <null>`** with a full RHS
    `interface_inst work@adpcm_if` (design.sv:1) whose `vpiParent` is the
    `design`. RESUME §9: a `<null>` LHS with a full RHS is the SINGULAR mirror
    (or a design-level VECTOR whose `<null>` prints the CONTAINER) — decode
    which before naming a field, and read `design::Compare`'s order first.
  * `MiniAmiq` ×2, 838 lines, one head — `function
    work@svaunit_vpi_interface.pass_info_to_sv_dpi` (svaunit_vpi_interface.sv:72)
    inside an `interface_inst`: a DPI import listed in an interface.
  Both are `interface_inst` members at design level, a family this campaign has
  not opened; `head_pat_*.cmp` carry them.
* **R1 — EIGHTEEN MORE VIEW-FLAG READS FIRE IN THE CLONE WINDOW.** Named by
  `file:line` in `BLASTRADIUS.r10uvm214.txt` (six in ExprEmit, two in StmtEmit,
  eight in TaskFuncEmit, three in TypeEmit). Every one of them decides correctly
  today by the def-listing census, so this is a MAP, not a defect list — and the
  tap that produced it is thirty lines of throwaway instrumentation that any
  later pass can re-apply.
* **R2 — THE `$unit` DESIGN LISTING IS A SECOND BINDING AUTHORITY, AND IT IS
  ONLY HALF MODELLED.** § 146's re-point accepts a constant, an operation and
  (now) this law's own `ref_obj`; Surelog's step (2) accepts ANY reference whose
  parent chain reaches the design. A reference bound to something else entirely
  in a `$unit`-import design would keep our binding where golden takes the
  design parameter. No corpus cell of that shape was found (the def-listing
  census is exact on all nine UVM rows), so it is recorded, not taken.
* **R3 — THE FOREIGN-PARAMETER READ IN A CLONE BODY IS THE FOLD FAMILY'S.**
  Grid arm E: golden holds NO reference at all for
  `pf214src::fa214` / wildcard-imported `fa214` read from a def clone body — the
  read is FOLDED — while we emit a bound `ref_obj`. 9 cells in the arm, and the
  same shape sits behind SeqDriver's remaining `logic_typespec` residues. That
  is § `fcArgPkgParamValueFolds32` / § 178's second gate term, not this law.
* **R4 — THE ELABORATED-VIEW GOLDEN BINDS DESIGN PARAMETERS EVERYWHERE.** With
  `-elabuhdm`, UHDM's own `ElaboratorListener` re-binds by name and golden's
  def-listing cells all name design-level `parameter` objects (grid arms A/C/D
  elab, and `armscore214`'s elab column). Our `--elabuhdm` databases are
  byte-identical between the two binaries on every boundary arm but one, so the
  635-of-761 elaborated half of the corpus is structurally untouched — but a
  pass that ever widens this law must measure that column first.
* **R5 — `SimpleUVM` and `Scoreboard` NOW PIN THE `$unit` HALF.** Their
  def-listing cells are RIGHT-BOTH 17 and their databases are byte-identical
  across this pass. Any future change to § 146's re-point, to `unitParamMap`, or
  to this law's pool must re-measure those two rows and grid arm H together —
  they are the only corpus rows that exercise step (2) over step (3).
