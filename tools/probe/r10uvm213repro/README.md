# r10uvm213 — § `oobClassTypeParamPlaceholderPerView213` — **THE HOME PACKAGE'S OWN *DEF* LISTING OF AN OUT-OF-BODY CLASS METHOD STAMPS ITS TYPE-PARAMETER PLACEHOLDER WITH THE *DEF* PACKAGE** — the family closes corpus-wide, and the SeqDriver head's attribution is **REFUTED** and re-decoded with the object named on both sides

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; the corpus predictor walks a sweep workdir that contains
them, so `scrub213.sh` redacts their names out of every artifact — reading the
fence list out of `canaudit.sh` rather than spelling it — and `canaudit.sh`'s
own `FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `4269c371` |
| pristine binary | md5 `049fa251053375ef129df1158bd07521`, built `-j 2` from this pass's OWN worktree at a clean `4269c371` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `14e1af66d4a4df833cfcbdf873b0465a`, frozen `chmod 555` |
| production surface | `src/TaskFuncEmit.cpp` ONLY — one block inside the existing `oobDeclPkg31` computation. **+54 / −1 lines, one file, no header change, no new exporter state, no new flag, no new member function, nothing minted, nothing removed, one pointer moved.** |
| probe surface | `tools/probe/r10uvm213repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **SeqDriver default and testflags, 50 cmp lines / ONE head each** — exactly what r10uvm210 recorded, on a binary byte-identical to the main tree's at BASE. |
| every other row's head | SimpleUVM ×2 **0**, Scoreboard/default 95, MiniAmiq ×2 **112**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. |
| the brief's law | **CONFIRMED, decoded to Surelog file:line, and CLOSED corpus-wide.** Golden mints a placeholder PER VIEW because a package is COMPILED twice, and the placeholder takes `component->getUhdmInstance()` of its own compile. We stamped both views with the elaborated twin because our class_defn — the only one we build — is parented at it. |
| the SIXTEEN keys, arity and view (SeqDriver, both modes) | six body-local keys: golden **6 copies (1 ALLPKG + 5 TOPPKG)**, ours **4 (4 TOPPKG)** → patched **4 (1 ALLPKG + 3 TOPPKG)**; ten formal keys: golden **4 (1 ALLPKG + 3 TOPPKG)**, ours **4 (4 TOPPKG)** → patched **4 (1 ALLPKG + 3 TOPPKG)**. On every one of the sixteen the divergent copy is the SAME one — the home package's DEF listing — and it is now golden's. |
| the sharing, by identity | **`NREFS=1` on all 204 copies** (76 golden + 64 pristine + 64 patched): no copy of any of the sixteen keys is shared by two declarations, on either side, on either binary. **The repair is a stamp, never a split.** |
| arity, both directions | **ONLY-OURS is EMPTY**: we mint no copy golden does not. The two extra copies golden holds per body-local key are function-level `ref_var` duplicates in the two IMPORT-clone listings, recorded as R1 — a copy we never had, not one we moved. |
| the golden grid (9 arms × 2 views, one REAL Surelog golden each) | **18 arm-views scored, 0 NO-DATABASE, golden-vs-golden CALIBRATION null in all 18.** Arms **A**, **C**, **D** close their law cells in BOTH views (A: AGREE 7→12, C: 11→13, D: 4→6); arms **B**, **E**, **F**, **G**, **H**, **I** are **census-identical on the two binaries in both views** — the in-body control, the module-homed and `$unit`-homed classes, the package free function, the ordinary-type must-stay and the OTHER placeholder kinds in the very same listing. **AWAY-GOLDEN 0 in every arm in every view.** |
| the a-priori prediction, from PRISTINE databases alone | **exactly NINE row-modes over 956 scanned surelog databases** — `SeqDriver` ×2, `SimpleUVM` ×2, `MiniAmiq` ×2, `BuildUVMPkg` ×2 and `Scoreboard`/default — **16 cells each, TO-GOLDEN 16 / AWAY 0 / UNSEEN 0 on every one**, and **none of the 1358** uhdm2rtlil databases. Written before the patched sweep existed. |
| byte movers | **9 / 956** surelog — EXACTLY the nine predicted BY NAME, including `Scoreboard`/default, the ~50/50 COIN, whose dump is attributed ORDER-BLIND. **0 / 1358** uhdm2rtlil. |
| the six protected CMP_EQUAL row-modes | `BuildUVMPkg` ×2, `Earlgrey_0_1` ×2 and `SimpleUVM` ×2 — **CMP_EQUAL on BOTH binaries, both columns scored** (§ 7). Four of them (`BuildUVMPkg` ×2, `SimpleUVM` ×2) are byte movers by design: sixteen cells each, every one landing on golden's own value. |
| **THE HEAD'S ATTRIBUTION — REFUTED** | r10uvm210's R0 said the head is the def-view placeholder's `Instance`. The repair lands, the crossing shape it owns goes to **zero cells corpus-wide**, and **the head is BYTE-IDENTICAL between the two binaries**. `ct213route` (mask-and-rerun on the OFFICIAL `design::Compare`) and `uhdm-dump` name the real link: a class-method body `ref_obj` to a package parameter whose `vpiActual` is golden's **DEF-listing `param_assign` Rhs** and our **elaborated folded constant**, in the same listing, at the same dump line. `ref_obj::Compare` reads `Actual_group`; that IS the printed pair. R0, with the site located. |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` negative control **23 FAIL**; uhdm2rtlil **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in BOTH modes** on both binaries, `ct8rows` PASS, `byteverify` 0/1358; surelog 1588 rows, status histogram **474/7 default + 469/6 testflags** unchanged. |

---

## 1. THE HEAD, AND THE PRISTINE BASELINE, MEASURED FIRST

This pass built its own pristine binary from a clean `4269c371` worktree; it
came out **byte-identical** to the main tree's binary at that commit
(`049fa251…`). Before a line was written: `check_goldens.sh` 23 PASS / 0 FAIL
with the `/bin/false` control at 23 FAIL; both uhdm2rtlil sweeps 679/50/2 with
`ct8rows` PASS against the committed baseline; the surelog sweep reproducing
the committed status histogram exactly (474/7 + 469/6) with only the two
recorded informational `Earlgrey_0_1` dump-column cells differing.

`rowheads.sh` on that sweep (`GATES.r10uvm213.txt`):

```
SeqDriver ×2 50 · SimpleUVM ×2 0 · Scoreboard/default 95 · MiniAmiq ×2 112
BuildUVMPkg ×2 0 · Earlgrey_0_1 ×2 0 · Rggen/default 0
```

and `ct210inst --tsinst`, the instrument r10uvm210 committed, reproduced its
reading: golden holds a DEF-view `unsupported_typespec REQ@164:3` whose
`Instance` is the DEF `uvm_pkg`; every one of ours named the ELABORATED one.

---

## 2. QUESTION (1) — THE SIXTEEN KEYS, EVERY COPY, BY VIEW × INSTANCE-VIEW × HOLDER

`ct213ts --copies` prints one block per placeholder OBJECT: its key
(`kind|name|line:col`), its `Instance` VIEW, and every `ref_typespec` that
points at it with that reference's ancestor chain — the HOLDER. The outermost
step of a chain carries its own view label, so a def-view holder and an
elaborated holder of the same package never collapse. Full table for all
sixteen keys, both sides, both binaries: `COPIES.SeqDriver.r10uvm213.txt`.

`unsupported_typespec|REQ|164:3` (uvm-1.2 `seq/uvm_sequencer.svh:164`,
`REQ t;` in `uvm_sequencer::stop_sequences`), **golden**:

```
INST=TOPPKG:uvm_pkg  package[TOPPKG:uvm_pkg]<class_defn:uvm_sequencer<function:stop_sequences<begin:<ref_var:t
INST=ALLPKG:uvm_pkg  package[ALLPKG:uvm_pkg]<function:uvm_sequencer::stop_sequences<begin:<ref_var:t
INST=TOPPKG:uvm_pkg  package[TOPPKG:adpcm_pkg]<function:uvm_sequencer::stop_sequences<ref_var:t
INST=TOPPKG:uvm_pkg  package[TOPPKG:adpcm_pkg]<function:uvm_sequencer::stop_sequences<begin:<ref_var:t
INST=TOPPKG:uvm_pkg  package[ALLPKG:adpcm_pkg]<function:uvm_sequencer::stop_sequences<ref_var:t
INST=TOPPKG:uvm_pkg  package[ALLPKG:adpcm_pkg]<function:uvm_sequencer::stop_sequences<begin:<ref_var:t
```

**ours, pristine** — four copies, the same four holders minus golden's two
`<ref_var` duplicates, and **every one naming `TOPPKG:uvm_pkg`**. **ours,
patched** — the same four copies, with the `package[ALLPKG:uvm_pkg]` one now
`INST=ALLPKG:uvm_pkg`, i.e. golden's.

The ten FORMAL keys have the same shape at arity 4/4: golden
`1 ALLPKG + 3 TOPPKG`, ours `4 TOPPKG` → `1 ALLPKG + 3 TOPPKG`.

**So the whole divergence is ONE COPY PER KEY — the one the home package's DEF
listing holds — and the arity difference is confined to the six body-local keys
and to the IMPORT clones, where golden holds a copy we never mint (R1).**

## 3. QUESTION (2) — THE SHARING, BY IDENTITY

`NREFS` in `--copies` is the number of `ref_typespec`s whose `Actual_typespec`
IS that object. **It is 1 on all 204 copies** — 76 golden, 64 ours pristine, 64
ours patched. Nothing in this family is shared by two declarations on either
side, so the repair is a STAMP and never a split-mint. (Contrast r10uvm207 and
r10uvm208, where the arity itself was the law.)

Sharing is invisible to the judge in any case — no generated `Compare` reads
`VpiParent` — but the arity is not, because each holder reaches its own copy.

## 4. QUESTION (3) — THE GOLDEN GRID, SCORED WITH THE INSTRUMENT

`grid213.sh` + `grid213/`, nine arms × two views, one REAL Surelog golden each
(`~/git-repos/Surelog/build/bin/surelog`, the one `scripts/verify_golden.py`
names), `-parse -d coveruhdm -nobuiltin -nocache` and again with `-elabuhdm`.
**The per-arm `uhdm-cmp` verdict is RECORDED and is NOT the scorer** —
r10uvm210's recorded caution: `-nobuiltin` makes golden's
`design->AllPackages()` one entry shorter than ours, so every arm's head is that
vector-size mismatch. The scorer is the placeholder-copy census, with
golden-vs-golden CALIBRATION run FIRST in every cell (`TOTAL CALIB non-null: 0`,
18/18 scored, 0 NO-DATABASE). Full transcript: `GRID.r10uvm213.txt`.

| arm | what it varies | AGREE parse pris→pat | AGREE elab pris→pat |
|---|---|---|---|
| **A** `g213_a_oob` | THE LAW — a package class with type parameters and out-of-body methods: a type-parameter FORMAL, a subroutine-body LOCAL and a named-block local | **7 → 12** | **7 → 12** |
| **B** `g213_b_inbody` | the IN-BODY control — the same declarations defined inside the class body | 2 → 2 | 2 → 2 |
| **C** `g213_c_pkgimp` | THE CORPUS TOPOLOGY — an importing PACKAGE, so both importer views carry an import clone | **11 → 13** | **11 → 13** |
| **D** `g213_d_modimp` | the MODULE importer control for C | **4 → 6** | **4 → 6** |
| **E** `g213_e_modclass` | a MODULE-homed class with out-of-body methods (`getUhdmInstance()` is not a package) | 0 → 0 | 0 → 0 |
| **F** `g213_f_unitclass` | a `$unit`-scope class, the other non-package home | 1 → 1 | 1 → 1 |
| **G** `g213_g_freefunc` | the PACKAGE FREE SUBROUTINE control, re-measuring r10uvm183's view-correct claim in the same run | 6 → 6 | 6 → 6 |
| **H** `g213_h_muststay` | THE MUST-STAY CONTROL — ordinary resolvable formals and locals (package typedef, int, string, queue) | 10 → 10 | 10 → 10 |
| **I** `g213_i_scopedtd` | THE OVER-FIRE CONTROL — the OTHER placeholder kinds in the SAME def listing (`Owner::td` and a statement-scope typedef), which take `tsInst`/`pkgScopeInst` and already agree | 9 → 9 | 9 → 9 |

**ONLY-OURS never rises and AGREE never falls in any arm in either view:
AWAY-GOLDEN 0, MOVED-WRONG 0.**

What the grid decided, before any code:

* golden's import-clone copies keep the **ELABORATED** home package in BOTH
  importer views (arm C), so the law must be fenced OUT of the import driver;
* the home DEF listing takes the DEF package for BOTH the formal and the
  body-local site (arm A, 5 cells);
* an in-body method produces no placeholder at all (arm B) and a non-package
  home produces one with no instance (arms E, F) — the law must not fire;
* the other placeholder kinds in the very same listing already agree (arm I),
  so the fix must be at `oobDeclPkg31` and nowhere wider.

## 5. QUESTION (4) — THE DECODE

`DECODE.r10uvm213.txt` carries it with file:line. In one paragraph:
`FunctorCompilePackage::operator()` (CompilePackage.cpp:60-72) compiles a
package **twice**, as two DesignComponents — the elaborated `Package` with
`Reduce::Yes` and `getUnElabPackage()` with `Reduce::No`. An out-of-body class
method is package text (`paFunction_declaration`, CompilePackage.cpp:213-218),
so BOTH compiles walk its body. `compileTypespec`'s catch-all closes with
`result->Instance(component->getUhdmInstance())` (CompileType.cpp:2135-2136),
and the unelaborated component's UHDM object is exactly the `AllPackages` entry
(`UhdmWriter.cpp:4958-4979`). **Per-view compile, per-view mint, per-view
stamp** — not a split of one object. Our package classes ride the elaborated
view only, so the DEF listing is a re-emission over the same class_defn, whose
`VpiParent` is the TOP package in every listing; `oobDeclPkg31` read that
parent. The fix takes `pkgClassTfClone` — the DEF package the clone driver is
already writing into — in exactly the window
`pkgClassTfClone && !pkgImportCloneEmit`, with an identity test and a name test.

## 6. QUESTION (5) — THE PREDICTION AND THE CENSUS

`predict213.py` defines the fire set FROM OUR DATABASE ALONE (an
`unsupported_typespec` copy in a `package[ALLPKG:P]<function|task:C::m` holder
whose `Instance` is `TOPPKG:P`) and reads golden for the verdict;
`predictall213.sh` walks a whole sweep workdir. `PREDICT.r10uvm213.txt`:

```
surelog     956 databases   rows with FIRE>0 = 9    FIRE=16 TO-GOLDEN=16 AWAY=0 UNSEEN=0 on every one
uhdm2rtlil 1358 databases   rows with FIRE>0 = 0
```

named: `SeqDriver` ×2, `SimpleUVM` ×2, `MiniAmiq` ×2, `BuildUVMPkg` ×2 and
`Scoreboard`/default.

**THE KIND CONJUNCT IS LOAD-BEARING AND WAS MEASURED, NOT ASSUMED.** Without
`unsupported_typespec` in the predicate the same holder+instance test also
catches the `class_typespec` copies a DEF listing holds for a class-handle local
(`uvm_reg_field_cb_iter cbs`, `uvm_event_pool ep`, …) and an `enum_typespec` —
and **golden stamps those `TOPPKG:P` too** (20 such cells on SimpleUVM and on
Scoreboard, 23 on BuildUVMPkg). They do not go through `oobDeclPkg31`, the patch
does not touch them, and the first cut of the predicate predicted 20-23
AWAY-GOLDEN cells that never move. That is recorded here because a predictor
that over-fires is a predictor that would have failed the pass on a phantom.

`cen213.sh` + `score213.py` score the nine row-modes cell by cell against their
own goldens, golden-vs-golden calibrated first on every row
(`CENSUS.r10uvm213.txt`).

## 7. QUESTION (6) — THE GATES, AND BOTH COLUMNS OF THE PROTECTED ROWS

Full transcript in `GATES.r10uvm213.txt`; the boundary in
`BOUNDARY.r10uvm213.txt`.

* **binaries.** pristine `049fa251…` (byte-identical to the main tree's
  `build/slang-uhdm` at `4269c371`), patched `14e1af66…`, both frozen
  `chmod 555` before any sweep. Every `cmds.txt` in all four sweep workdirs
  names EXACTLY ONE binary and it is the right one, audited BY PATH
  (`/tmp/r10uvm213_pris.bin` in the two pristine workdirs,
  `/tmp/r10uvm213_pat.bin` in the two patched ones, one distinct path each).
* **goldens.** 23 PASS / 0 FAIL on BOTH binaries with `SLANG_UHDM` exported
  explicitly; `SLANG_UHDM=/bin/false` gives 0 PASS / 23 FAIL.
* **uhdm2rtlil, both modes, both binaries.** 679 CMP_EQUAL / 50 SLANG_REJECT /
  2 SURELOG_FAIL. `ct8rows` against the committed baseline PASS; against this
  pass's own pristine testflags and default sweeps PASS. `byteverify`
  **0 / 1358**, SELFCHECK control 1357/1358.
* **surelog, `--mode both`, 1588 rows.** Status histogram **474/7 default,
  469/6 testflags on BOTH binaries — NO ROW CONVERTED IN EITHER DIRECTION.**
  `ct8rows` patched vs this pass's own pristine sweep: **0 differing ROWS**,
  status AND dump column. Against the committed baseline, exactly the two
  recorded informational `Earlgrey_0_1` dump-column cells
  (`CMP_EQUAL/differ` → `CMP_EQUAL/`), which **this pass's PRISTINE sweep reads
  the same way** — the recorded uhdm-dump TIMEOUT under sweep load, status
  `CMP_EQUAL` on both, before and after.
* **byte movers.** **9 / 956** surelog, EXACTLY the nine predicted BY NAME;
  **0 / 1358** uhdm2rtlil; SELFCHECK controls fire at 955/956 and 1357/1358.
  The census scores all nine at **TO-GOLDEN 16 / AWAY-GOLDEN 0 /
  MOVED-WRONG 0**, golden-vs-golden calibrated first on every row, with all
  sixteen cells named (`CENSUS.r10uvm213.txt`).
* **canaries.** surelog `ok=50 changed=2` against the committed baseline (those
  same two dump-column cells) and **`ok=52 changed=0` against this pass's own
  pristine sweep**; uhdm2rtlil `ok=8 changed=0`; `ctcan2` PASS ×2; `canaudit`
  PASS `audited=29 UNCOVERED=0 FENCE-BREACH=0`. All 10 protected databases
  byte-identical between the binaries, including the two pinned digests
  `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a`.
* **rowheads, both binaries.** SeqDriver ×2 **50 / 1 head**, MiniAmiq ×2 112,
  Scoreboard/default 95, SimpleUVM ×2 / BuildUVMPkg ×2 / Earlgrey_0_1 ×2 /
  Rggen/default **0 lines, 0 heads at judge rc=0**. The SeqDriver head cmp logs
  are **byte-identical between the two binaries in both modes**.
* **the wide boundary.** `LISTED=5443 PROCESSED=5443 PRODUCED_DBS=5258
  MOVED_ARMS=44 RC_DIFFS=0`, with this pass's own three grid arms in the mover
  list as the POSITIVE CONTROL. All 44 re-scored against REAL Surelog goldens
  in both views (88 arm-views, 0 not scored, golden-vs-golden calibration null
  in all 88): **parse view TO-GOLDEN 196 / AWAY-GOLDEN 0 / MOVED-WRONG 0; elab
  view TO-GOLDEN 202 / AWAY-GOLDEN 0 / MOVED-WRONG 0** on the view set. The
  strict MULTISET scoring reads 184 MOVED-WRONG cells, all in the ELAB view,
  and **every one has the patched view set exactly equal to golden's** — only
  golden's elaborated MULTIPLICITY (two or three copies where we mint one)
  differs, before and after, a pre-existing arity residue this law does not
  touch. **No `r10uvm205` / `r10uvm207` / `r10uvm208` / `r10uvm202` /
  `r10uvm163` arm is in the mover list at all, and no `buvm3-15` or `sd8-12`
  arm moved.** The three arms inside the `uvm82-91` range that did move
  (`g87_a1_order`, `v87_a3_oob`, `v91_a3_order`) score TO-GOLDEN 6 / 7 / 1 with
  AWAY-GOLDEN 0 and MOVED-WRONG 0 in both views, and so does § 185's
  `g185_b_notmove` arm (TO-GOLDEN 1, its own law's cells untouched).

**The six protected CMP_EQUAL row-modes, both columns, explicitly:**

| row-mode | status pris → pat | rowheads pris → pat | census |
|---|---|---|---|
| `BuildUVMPkg` default | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | TO-GOLDEN 16, AWAY 0, MOVED-WRONG 0 |
| `BuildUVMPkg` testflags | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | TO-GOLDEN 16, AWAY 0, MOVED-WRONG 0 |
| `SimpleUVM` default | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | TO-GOLDEN 16, AWAY 0, MOVED-WRONG 0 |
| `SimpleUVM` testflags | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | TO-GOLDEN 16, AWAY 0, MOVED-WRONG 0 |
| `Earlgrey_0_1` default | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | not a mover — database byte-identical |
| `Earlgrey_0_1` testflags | CMP_EQUAL → CMP_EQUAL | 0/0 → 0/0 | not a mover — database byte-identical |

**FOUR of the six are byte movers BY DESIGN** — this is said loudly because a
CMP_EQUAL row changing bytes is exactly the thing a gate exists to catch.
Sixteen cells each, every cell landing on **golden's own value**, and all four
stay CMP_EQUAL at judge rc = 0 with rowheads 0 lines / 0 heads.

## 8. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct213ts.cpp` | the placeholder-copy reader: `--copies` every copy with its Instance VIEW and its holder chain and its NREFS (the sharing), `--keycount` the census row form, `--arity` the arity question, `--holders` one object's chain. |
| `ct213route.cpp` | the ROUTE FINDER. Runs the OFFICIAL generated `design::Compare`; `--head` the pair, `--mask` the same with golden objects pre-seeded into `m_visited`, `--vec` each design-level vector element on its own fresh context, `--pair` any two objects, `--pa` a scope's param_assign object ids. This is what refuted the head's attribution. |
| `ct210inst.cpp`, `ct210sub.cpp`, `ct210own.cpp` | r10uvm210's committed instruments, copied unchanged so this directory runs on its own and so its readings can be reproduced here. |
| `cen213.py`, `cen213.sh`, `score213.py` | the multiset census join, the row driver and the four-column scorer. |
| `predict213.py`, `predictall213.sh` | the a-priori prediction from pristine databases alone. |
| `grid213.sh`, `grid213/` | the 9-arm golden grid, both views, real Surelog goldens. |
| `bound213.sh` | the wide boundary gate over a COPY of the whole probe tree. |
| `scrub213.sh` | the fence scrub (reads `FENCED=` out of `canaudit.sh`; never spells a fenced name). |
| `COPIES.SeqDriver.r10uvm213.txt` | questions (1)+(2): every copy of the sixteen keys, both sides, both binaries, with NREFS. |
| `GRID.r10uvm213.txt` | question (3). |
| `DECODE.r10uvm213.txt` | question (4), with Surelog file:line. |
| `PREDICT.r10uvm213.txt`, `CENSUS.r10uvm213.txt` | question (5). |
| `ROUTE.r10uvm213.txt` | **the refutation**: where the head actually comes from, with the object named on both sides. |
| `GATES.r10uvm213.txt`, `BOUNDARY.r10uvm213.txt`, `MOVERS.r10uvm213.txt` | question (6). |
| `head_pris_SeqDriver.*.cmp`, `head_pat_SeqDriver.*.cmp` | the head on both binaries, both modes. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged. |

## 9. RESIDUES

* **R0 — THE REAL SeqDriver HEAD: A CLASS-METHOD BODY REFERENCE TO A PACKAGE
  PARAMETER BINDS THE PARAM_ASSIGN RHS *OF THE LISTING BEING WRITTEN*.**
  SeqDriver ×2, 50 cmp lines, one head, both modes, **unchanged by this pass and
  byte-identical between its two binaries**. `ROUTE.r10uvm213.txt` carries the
  proof: `ct213route --vec` puts the head inside `AllPackages[1] uvm_pkg`;
  `ct213route --pair 61409 349` shows the two DEF-listing `param_assign` cells
  the log names are EQUAL object for object; and `uhdm-dump` on the SAME listing
  (the DEF `uvm_pkg`'s clone of `uvm_object::set_int_local`, uvm_object.svh:933)
  reads
  golden `ref_obj UVM_SETINT` → `vpiActual: ref_obj (uvm_pkg::UVM_SET) @217:31`
  against ours → `vpiActual: constant @217:31`.
  `ref_obj::Compare` reads `Actual_group`, so that link IS the printed pair.
  **THE SITE IS LOCATED.** `src/ExprEmit.cpp` ~13530, inside
  § `pkgParamRefKeepsCloneBare178`'s own arm, already has a VIEW-LOCAL chain:
  ```
  auto pit2 = pkgParamDefRhs.find(&nv.symbol);
  if (pkgEmitTopView && pit2 != pkgParamDefRhs.end()) ref->Actual_group(pit2->second);
  else if (auto pit = pkgParamConst.find(&nv.symbol); …) ref->Actual_group(pit->second);
  ```
  and the wrinkle is exactly this pass's: `emitPackageClassMethodClones` runs
  inside `emitPackage`'s `if (topView)` block (it needs the class_defns), so
  `pkgEmitTopView` is **true while the DEF listing is being written**. The window
  is the one this pass decoded — `pkgClassTfClone && !pkgImportCloneEmit` — and
  the object our DEF listing must bind already exists (`ct213route --pa o 146 35`
  reads `rhs=ref_obj rhsid=350`, the analogue of golden's 61413). Surelog's own
  producer is `UhdmWriter::lateBinding` (UhdmWriter.cpp:3814-3821,
  `ref->Actual_group(p->Rhs())` with `m` the component being written), which
  r10uvm178 already transcribed. **Decide the def/elab binding on a golden grid
  before code**, and expect the population to be every package-parameter
  reference in every def-view class-method clone body, not sixteen cells.
* **R1 — the IMPORT-CLONE DUPLICATE DECLARATION.** For each of the six
  BODY-LOCAL keys golden holds SIX copies where we hold four: the two extra sit
  in the two `adpcm_pkg` import-clone listings and are held by a `ref_var`
  declared DIRECTLY under the subroutine, beside the one inside its `begin`
  (`package[*:adpcm_pkg]<function:uvm_sequencer::stop_sequences<ref_var:t` with
  no `begin:` step). The same shape appears on fourteen other names in the same
  listing (`process`, `uvm_reg_cb_iter`, `uvm_resource_types::rsrc_q_t`, …),
  twenty ONLY-GOLDEN cells in all on SeqDriver. **ONLY-OURS is empty**, so this
  is a copy we never mint, not one we misplace — an arity residue for a
  declaration-listing pass, not this one.
* **R2 — the NAMED-BLOCK type-parameter local.** Grid arm A, cell
  `unsupported_typespec|U213|23:7`: a type-parameter-typed local declared inside
  `begin : blk213` in an out-of-body method gets a placeholder in golden in BOTH
  the def clone (instance = the DEF package) and the class_defn method (instance
  = the elaborated one), and we mint NEITHER. The subroutine-body site
  (§ 105) and the block-item site (StmtEmit) are different code, and only the
  first has the type-parameter arm. Corpus population zero on the nine UVM rows
  (every corpus body-local of this family is at subroutine level), which is why
  it is recorded rather than taken.
* **R3 — THE DUMP IS BLIND TO THIS LAW; THE CENSUS SEES ALL OF IT.** All nine
  moved databases are byte movers with **an order-blind whole-dump diff of ZERO
  lines and an identical file size**: `uhdm-dump` prints `|vpiInstance:` by
  NAME, and a package's two views share the name. r10uvm208 recorded that the
  dump and the census each see one half of a change; this is the extreme case,
  and it is why the attribution here is BY CENSUS, cell by cell, and why
  `Scoreboard`/default — the ~50/50 coin — is attributable at all: its
  order-blind dump diff is 0 lines, so the coin sat out and the byte move is the
  law's sixteen pointer swaps.
* **R4 — golden stamps the ELABORATED package on the def listing's OTHER
  typespec kinds.** In the same DEF listing, a class-handle local's
  `class_typespec` and an `enum_typespec` carry `TOPPKG:P` in GOLDEN as well as
  in ours (20 cells on SimpleUVM and Scoreboard, 23 on BuildUVMPkg). The
  per-view rule is therefore NOT "everything in the def listing takes the def
  package": it is the placeholder's rule, because the placeholder is minted by
  the compile while every one of those is a REGISTERED type reached by name.
  A future pass widening this law must re-measure that column first.
* **R5 — the class-method clone driver runs in the TOP-VIEW pass.**
  `emitPackageClassMethodClones` is called from `emitPackage` under
  `if (topView)`, so `pkgTopEmit`/`pkgEmitTopView` are TRUE while the DEF
  listing is written. Every view-conditioned decision reached from that driver
  is therefore reading the wrong view flag unless it uses
  `pkgClassTfClone && !pkgImportCloneEmit` instead. This pass fixed one such
  decision; R0 is another; there may be more, and the window is now named.
