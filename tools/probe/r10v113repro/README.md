# r10v113 — ADVERSARIAL VERIFICATION of r10uvm113 (§ classOwnLateMethodBindsPkgFn113)

**VERDICT: ACCEPT WITH FIX.**  Every headline number in the implementer's
report reproduces bit-for-bit from a fresh build at b494676.  No
pristine-right → patched-wrong cell was found on legal SystemVerilog, in eight
purpose-built arms × two views, in the nine corpus row-modes, or in the wide
boundary.  The two fixes shipped here are to the pass's own MEASUREMENT
instruments, not to production: both silently read the implementer's `/tmp`
scratch and one of them reported the wrong side's numbers when re-run.

LHS is always golden (Surelog); RHS is always ours.

---

## 1. Reproduction — both binaries built here, every number re-measured

| | implementer | this verifier |
|---|---|---|
| pristine md5 | `0488d7b62f80e7aecab313abd9320510` | **same** |
| patched md5 | `938cc55348808381f3d31c0dacfc7d64` | **same** |

Worktrees `/tmp/wt_v113` (patched) and `/tmp/wt_v113pris`, both fresh at
b494676; the patch applies clean; surface is `src/ExprEmit.cpp` +
`tools/probe/r10uvm113repro/` only; fence check 0/0/0/0; `results/*.csv`
untouched; main tree clean.  Binaries frozen `chmod 555` at
`/tmp/v113_bin/{pris,pat}` BEFORE any sweep, and **every** `cmds.txt` audited
by binary PATH: 1458/1458 u2r and 1523/1523 surelog name the frozen binary.

| gate | measured here |
|---|---|
| goldens, patched | PASS=23 FAIL=0 |
| goldens, pristine | PASS=23 FAIL=0 |
| goldens, `SLANG_UHDM=/bin/false` | PASS=0 FAIL=23 |
| u2r testflags / default, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| ct8rows u2r vs committed baseline, and vs pristine control, both modes | PASS, 0 differing ROWS (status AND dump column) |
| surelog `--mode both` | 937 CMP_EQUAL, 567 SLANG_REJECT, 48 SURELOG_FAIL, **19 CMP_NOTEQUAL**, 10 DEFERRED, 3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM — identical pristine and patched |
| ct8rows surelog vs `results/golden_surelog.csv` and vs pristine control | PASS, 0 differing rows over 1588. **No conversion is claimed and none happened.** |
| byteverify u2r `SELFCHECK=1` | MOVERS **0 / 1358**, selfcheck 1357/1358 |
| byteverify surelog `SELFCHECK=1` | MOVERS **9 / 956**, selfcheck 955/956 |
| canaries surelog / u2r | ok=52 changed=0 / ok=8 changed=0 |
| ctcan2 surelog / u2r | PASS / PASS |
| canaudit | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| SVSwitch / YosysVerx pins | `4842211c4030` / `6ccda350c24a`, and InterfaceModPort, BlackParrotComplex, YosysOldOr byte-identical |

Heads (`rowheads.sh`, official `uhdm-cmp`, CMPLINES / HEADS):

| row | mode | pristine | patched |
|---|---|---|---|
| SimpleUVM | default | 565 / 1 | **56 / 1** |
| SimpleUVM | testflags | 565 / 1 | **56 / 1** |
| Scoreboard | default | 565 / 1 | **56 / 1** |
| SeqDriver, MiniAmiq | both | 32 / 1 | 32 / 1 |
| BuildUVMPkg | both | 47 / 1 | 47 / 1 |
| Earlgrey_0_1 | both | 36 / 1 | 36 / 1 |
| Rggen | default | 0 / 0 | 0 / 0 |

R0 confirmed from the patched head file: golden's
`ref_var (uvm_pkg::uvm_process_report_message::p)` →
`unsupported_typespec (process)` at `uvm_globals.svh:262`.

## 2. The a-priori mover prediction, re-derived INDEPENDENTLY

`predv113` (this verifier's own predictor, written without reading
`pred113.cpp`) reads a PRISTINE database and names a mover as: a REACHABLE
`func_call` with a **null** `vpiFunction` whose owner chain is
`package > class_defn > function|task` and whose enclosing package declares a
`task_func` of the call's name.

Over **956 pristine surelog databases**: 9 named, 3 cells each —
`BuildUVMPkg`×2, `MiniAmiq`×2, `SimpleUVM`×2, `SeqDriver`×2, `Scoreboard`/default
(Scoreboard/testflags builds no database).  Over **1358 pristine u2r
databases**: 0.  The three cells are exactly

```
uvm_pkg | uvm_report_object::uvm_report   | uvm_process_report_message
uvm_pkg | uvm_sequence_item::set_id_info  | uvm_report_fatal
uvm_pkg | uvm_sequence_item::uvm_report   | uvm_process_report_message
```

**MEASURED movers: 9/956 and 0/1358 — the predicted set exactly.**
Order-blind attribution (uhdm-dump, workdir path normalised, SORTED, because
Scoreboard/default is a ~50/50 coin): every one of the nine is
**removed=0 added=6** = three `|vpiFunction:` edges naming
`uvm_pkg::uvm_report_fatal` once and `uvm_pkg::uvm_process_report_message`
twice.  Nothing else.

## 3. THE AWAY HUNT — the report's structural argument is wrong, the conclusion is not

The report says: *"The fix can only fill a null — it never re-points a bound
call, which is why no AWAY is structurally possible."*  The first clause is
true (the arm builds a fresh `func_call`, `protoBound12` still wins, and the
new gate only writes `Function()` where it was unset).  **The conclusion does
not follow.**  Filling a null where GOLDEN is also null turns a SAME cell into
a DIFF cell, and that is an AWAY.  The claim needs the shape "golden leaves a
bare class-method call unbound while its package declares a subroutine of that
name" not to exist.

That shape was hunted, not assumed:

* `v113_ord.sv` puts the package free function **BELOW** the class that calls
  it, and adds an `extern` prototype declared below the caller, a
  `pure virtual` prototype below the caller, and a `virtual` method below the
  caller — with `sord2` as the face-matched above-the-class control.  Golden
  binds the package function in **every** cell; TO-GOLDEN 6, AWAY 0.
* `predv113` run against **GOLDEN** databases asks the same question design-wide:
  **0 hits over 1516 surelog goldens, 1458 uhdm2rtlil goldens and the 18
  purpose-built grid goldens.**  Not one golden `func_call` anywhere in either
  corpus is null-bound where its package declares that name.

So the conclusion holds — empirically, and much more strongly than the
structural sentence claims.  The sentence itself should be corrected.

## 4. THE GRID — eight arms, both views, `CELLS-WORSE = 0`

Built with `grid113v.sh` (golden = Surelog, ours = both binaries, rc recorded
per cell, DEF and ELAB run separately), scored two ways: `score113.py`
(the implementer's elementwise scorer) and `mscore113v.py` (this verifier's
MULTISET scorer, see §6).

| arm | what it varies | default | elab |
|---|---|---|---|
| `v113_ctx.sv` | constructor, in-body, static, out-of-body, task body, `foreach` header, `with`-clause, cast, concat, `this.`-qualified, recursive free function, default arguments called with fewer actuals, free task beside the free function, property + static-property initializers, constraint, callers below the collision | TG 11, **AWAY 0** | TG 8, **AWAY 0** |
| `v113_inh.sv` | base class, `super.`/`this.`-qualified, parameterised base, nested class, class property shadowing the name, explicitly scoped `pkg::name` | TG 3, **AWAY 0** | TG 0, **AWAY 0** |
| `v113_enc.sv` | module / program / interface / `$unit` enclosures, class nested in each | TG 0, **AWAY 0** | TG 0, **AWAY 0** |
| `v113_imp.sv` | wildcard-import clone, explicit single-symbol import, a module importing both | TG 0, **AWAY 0** | TG 0, **AWAY 0** |
| `v113_ord.sv` | package function declared AFTER the class; `extern`, `pure virtual`, `virtual` prototypes below the caller; above-the-class control package | TG 6, **AWAY 0** | TG 0, **AWAY 0** |
| `v113_ctl.sv` | the call in an `if` CONDITION, an `if` body, a `case` expression, a case item, `while`, a `for` bound, `repeat`, a ternary, a named nested block, a delay control, a task body | TG 10, **AWAY 0** | TG 14, **AWAY 0** |
| `v113_top.sv` | two tops, an import-only module, an import-nothing module, three instances of the carrier | TG 1, **AWAY 0** | TG 0, **AWAY 0** |
| `v113_dpi.sv` | a DPI-C import of the colliding name, a covergroup with `option.per_instance`, two specialisations of a parameterised class | TG 4, **AWAY 0** | TG 4, **AWAY 0** |

Totals over the sixteen cells: **TO-GOLDEN 61, ALREADY-RIGHT 118,
AWAY-GOLDEN 0.**  `v113_ctl` matters most: the emitter's `classMethodNoBind`
flag is switched OFF inside an `if`/`case` condition (StmtEmit:2408), which
once made one call bind two ways one line apart — the widened gate reads
`curSubClassScope9`, not that flag, and all ten control positions land on
golden together.

`g113_b.sv` (the implementer's discriminator) re-scored here reads
**TO-GOLDEN 3 / ALREADY-RIGHT 10 / AWAY-GOLDEN 0 / STILL-WRONG 1** in the
default view — GRID.txt's row, exactly.

## 5. THE NINE ROW-MODES — owner-keyed census, TO-GOLDEN / AWAY / STILL

`ct113cen` + `cen113.py` re-run over both sweeps:

| | PRISTINE | PATCHED |
|---|---|---|
| SAME | 144430 | **144457** |
| **OURS-NULL** | **27** | **0** |
| DIFF | 8226 | 8226 |
| ONLY-G / ONLY-O | 294 / 211 | 294 / 211 |

Reproduced exactly.  The 27 are 3 cells × 9 row-modes, the same three in every
one.  `SAME` rises by exactly 27 and nothing else moves, so no cell went
SAME → DIFF.  `cenglob113.py` (uvm_globals free subroutines only, after the fix
in §7): pristine SAME 24088 / OURS-NULL 27 / DIFF 7982, patched SAME 24115 /
OURS-NULL 0 / DIFF 7982 — R-tf111's DIFF column byte-identical either side.

`mscore113v.py` on the real targets (`MSCORE.uvm9.txt`), the per-slot question
the brief asks: **CELLS-BETTER=3, CELLS-WORSE=0** in each of the nine, over
~104 000 cells.

## 6. Why a MULTISET scorer was needed

`score113.py` sorts each cell's callee list and pairs the two sides
ELEMENTWISE.  In the ELAB view our emitter puts TWO `func_call`s in cells
golden fills with one (the class copy that is also uvm111's R-tf111 family), so
a cell whose patched multiset is strictly closer to golden still prints two
`CHANGED-STILL-WRONG` lines.  46 of the grid's rows are that artefact.
`mscore113v.py` compares multiset intersections instead — `|G ∩ Q| < |G ∩ P|`
is the only definition of a regression that survives duplicate emission — and
reports **CELLS-WORSE = 0 in all sixteen arm/view combinations**
(`MSCORE.grid.txt`).

## 7. THE FIX — two measurement instruments that read another run's `/tmp`

Both are in `tools/probe/r10uvm113repro/`; production is untouched.

* **`cenglob113.py` ignored its argument** and globbed the hard path
  `/tmp/r10uvm113_scratch/cen_pris/*.g.tsv`.  On this machine that scratch
  still existed, so pointing the script at a PATCHED census printed the
  PRISTINE totals — the same `TOTAL` line for both sides, silently.  On any
  other machine it prints nothing at all.  Now `sys.argv[1]`, with a FATAL when
  no `*.g.tsv` is there.
* **`cenall113.sh`** defaults `CEN` to `/tmp/r10uvm113_scratch/ct113cen`.  Where
  that is absent, `ct113cen` never runs, every census file is empty, and the
  join prints all-zero counts — a driver that reaches nothing reading as
  perfection.  Now it exits 3 with `FATAL: no ct113cen at …`.

Not fixed, reported: **`GRID.txt` has no committed generator.**  Nothing in
`r10uvm113repro/` builds the goldens for `g113_a…d.sv` or scores them, so the
grid table cannot be re-derived from the patch.  `grid113v.sh` here is that
driver, and writing it turned up a trap worth recording: the `surelog` on
`$PATH` is `sv-tests/third_party/tools/Surelog/build/bin/surelog`, a DIFFERENT
build from the one `scripts/verify_golden.py` uses
(`~/git-repos/Surelog/build/bin/surelog`).  Goldens made with the `$PATH` copy
have `func_call`s carrying **no `vpiParent`** on small designs; every census
row is then dropped as unreachable and the whole grid reads `G=<absent>` —
a silent all-green.  `grid113v.sh` pins the harness binary and says why.

## 8. BOUNDARY — a COPY of the whole probe tree, no path filter, four combinations

`bound113.sh` over `/tmp/v113_probecopy` (3491 arms; the tree plus this
verifier's first five):

```
file def   PROCESSED=3491 LISTED=3491 DIFFER=8 PRIS_REJECT=133 PATCHED_REJECT=133
file elab  PROCESSED=3491 LISTED=3491 DIFFER=8 PRIS_REJECT=145 PATCHED_REJECT=145
dir  def   PROCESSED=1509 LISTED=1509 DIFFER=5 PRIS_REJECT=118 PATCHED_REJECT=118
dir  elab  PROCESSED=1509 LISTED=1509 DIFFER=6 PRIS_REJECT=124 PATCHED_REJECT=124
```

PROCESSED == LISTED everywhere and PRIS_REJECT == PATCHED_REJECT everywhere.

* **file mode, both views**: the 8 differing arms are this pass's four
  `g113_*.sv` and four of this verifier's.  Every one is `removed=0` with only
  added `|vpiFunction:` lines, and the count per arm equals that arm's grid
  cell count exactly (g113_a 4, g113_b 3, g113_c 1, g113_d 1, v113_ctx 11,
  v113_inh 3, v113_ord 6, v113_imp 1).  The gate is its own positive control.
* **dir mode, both views**: this pass's directory (+18 lines = 9 edges) and this
  verifier's (+42 / +40).
* **acquitted, independently**: `r10uvm75repro`, `r10uvm76repro`,
  `r10v109repro` in both views, and — **an arm the implementer's acquittal does
  not name** — `r10uvm88repro` in dir/elab (`removed=2 added=2`, a
  `p3::base3::oob_base` `vpiTaskFunc` listing moving two lines).  For all four:
  the SORTED dumps are byte-identical pristine vs patched, and the PRISTINE
  binary ALONE produced 4/4 distinct dumps on the first three and **6/6
  distinct dumps on `r10uvm88repro`**.  These directories are coins before any
  patch exists; the acquittal list is a property of a run, not of the tree, and
  `BOUNDARY.acquittal.txt` states it as the latter.
* A targeted file+dir boundary over all EIGHT verifier arms (they were written
  after the big copy was taken) is symmetric: 7 of 8 differ, `v113_enc.sv` — the
  module/program/interface/`$unit` arm — does not, which is the law's own
  negative cell.

## 9. RESIDUES CONFIRMED, and one correction

* **R0** — confirmed from the patched head, verbatim (§1).
* **R-mod113** — confirmed twice over: `v113_enc.sv` shows golden binding the
  MODULE's, the PROGRAM's and `$unit`'s free function while we bind nothing,
  pristine and patched alike; `v113_enc` is the one arm the boundary does not
  move.
* **R-expimp113** — confirmed: `v113_imp.sv`'s `himp2::C2::first/second` call an
  explicitly imported `quill`; golden binds `hsrc::quill`, we bind nothing
  before and after.
* **R-clone113** — confirmed: `v113_imp.sv`'s `himp1::C1::above` binds the
  importer's clone where golden binds the home function.  It is a MISS that
  replaced a null, never an AWAY, and `Compare` reads no `VpiParent`.
* **R-unitimp113** — not re-derived here; `g113_c.sv` reproduces it.
* **The "no AWAY is structurally possible" sentence is wrong** and should be
  replaced by the measurement in §3 before the law is quoted forward.

## 10. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `grid113v.sh` — the missing grid driver: golden + both binaries, DEF and ELAB,
  rc per cell, pinned to the harness's Surelog.
* `mscore113v.py` — the multiset cell scorer; `|G∩Q| < |G∩P|` is the regression.
* `predv113.cpp` — the
  independent a-priori predictor, run over pristine databases AND over goldens.
* `MSCORE.uvm9.txt`, `MSCORE.grid.txt`, `GRID.v113.txt`, `raw/BOUND.*.txt`,
  `raw/PREDICTION.v113.txt`.
