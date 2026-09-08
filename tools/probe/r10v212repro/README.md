# r10v212 — ADVERSARIAL VERIFICATION of r10uvm212 (§ `classTdCloneTakesTheBasesEmptyListing212`)

**VERDICT: ACCEPT.** Every headline number in the implementer's report
reproduces on this verifier's own binaries, built from its own worktrees at
`59767284`. Nothing was found that is pristine-right and patched-wrong. No
production line was changed by this verifier; `/tmp/r10uvm212.patch` ships as
submitted.

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` are **READ ONLY** and were **NOT EDITED**; `GOLDEN_DEFER` stayed
unset; the four slang-fenced tests were never dispatched by any driver here and
are not spelled in any file in this directory.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table and every
script.

| | |
|---|---|
| BASE | `59767284` (both worktrees; the main tree had rotated to `4269c371`, which is **probe- and doc-only** — `git diff 59767284 4269c371 -- ':!tools/probe'` is 3 lines of `RESUME.md`, so the two commits build the same binary) |
| pristine binary | md5 `049fa251053375ef129df1158bd07521` — **the implementer's number, bit-for-bit** |
| patched binary | md5 `97b4a36beefdc33cafe8d0f127ccf7b4` — **the implementer's number, bit-for-bit** |
| production files | byte-identical to the implementer's worktree (`57cb217b9cca695d5710b8b49cfaf6c7` / `a61bd138fbedf975d24fdb95bff1725a`) |
| both binaries | frozen `chmod 555` at `/tmp/v212_bin/` BEFORE any sweep; every `cmds.txt` audited FILE BY FILE by binary PATH (u2r 1462/1462, surelog 1573/1573, 0 mismatched, on both sides) |

---

## 1. THE HEADLINE NUMBERS, RE-MEASURED

| | implementer | this verifier |
|---|---|---|
| pristine / patched binary md5 | `049fa25…` / `97b4a36…` | **identical** |
| goldens, patched | 23 PASS / 0 FAIL | **23 / 0** (pristine also 23 / 0) |
| `SLANG_UHDM=/bin/false` | 0 PASS / 23 FAIL | **0 / 23** |
| uhdm2rtlil, both modes | 679 / 50 / 2 | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, both modes, both binaries |
| `ct8rows` u2r vs committed gate, and vs own pristine, both modes | 0 differing rows | **PASS, 0 differing rows** (3 comparisons) |
| `byteverify SELFCHECK=1`, u2r | 0 / 1358 | **0 / 1358**, PATH_SETS_IDENTICAL |
| surelog default | 474/7 -> **475/6** | **474/7 -> 475/6** |
| surelog testflags | 469/6 unchanged | **469/6 unchanged** |
| `ct8rows` surelog vs own pristine | 1 differing row of 1588 | **1 differing ROW of 1588** |
| `byteverify SELFCHECK=1`, surelog | 1 / 956, Scoreboard/default | **1 / 956, `./default/Scoreboard-59431470/slang.uhdm`** |
| coin, order-blind | 1100449 -> 1100422 lines, 82 diff lines | **1100449 -> 1100422, 82 diff lines** |
| Scoreboard/default head | 95 / 1 -> 0 / 0 | **95 / 1 -> 0 / 0** |
| SeqDriver ×2 / MiniAmiq ×2 | 50/1 and 112/1, unchanged | **identical, unchanged** |
| `grid/c9` def / elab | 95/1 -> 0/0 and 117/1 -> 0/0 | **95/1 -> 0/0 and 117/1 -> 0/0** |
| prediction, pristine | surelog 1 of 956 named; u2r 0 of 1358 | **1 of 956, the same object; 0 of 1358** |
| prediction, patched | 0 / 956 and 0 / 1358 | **0 / 956 and 0 / 1358** |
| protected databases | compared=20 NOFILE=0 MOVED=0 | **20 / 0 / 0**, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` |

**THE ONE CONVERTING ROW, quoted, not summarised** (`ct8rows.sh` against this
verifier's own pristine sweep at the same BASE):

```
< Scoreboard,default,CMP_NOTEQUAL,decompile:,,
> Scoreboard,default,CMP_EQUAL,,,differ
```

`results/golden_surelog.csv` was NOT edited. The master promotes that row.

**One counting note, recorded because it cost half an hour.** `grid/c9`'s
"95 / 117" are `rowheads.sh`'s convention — uhdm-cmp's stdout AND stderr into
ONE file, `wc -l`. Counting stdout alone gives 46 / 57 for the same run. Both
readings agree on the verdict (0 lines, 0 heads, `uhdm-cmp` rc 0 = CMP_EQUAL,
in BOTH views); only the magnitude differs. `gridv212v.sh` follows rowheads.

---

## 2. THE HEAD DECODE, RE-DERIVED FROM THE SOURCE

Read, not carried forward:

* `~/.local/include/uhdm/BaseClass.h:206-225` — the **VECTOR** `SafeCompare`.
  On `lhs == nullptr && rhs != nullptr && !rhs->empty()` it sets
  **`m_failedRhs = rhs_obj`, the OWNER**, and never touches `m_failedLhs`. That
  is why the head prints `LHS: <null>` with a whole `class_typespec` on the
  right: a vector verdict wearing a singular verdict's face. The implementer's
  reading is correct and the brief's "singular link" framing is wrong.
* Both null-vs-non-null arms are guarded by `!empty()`, so **a NULL vector and
  an EMPTY one are the SAME answer to the judge.** The patch writes
  `nullptr`; either would have compared equal. (The header comment's "so the two
  are different answers" is true of the DUMP, not of `Compare`.)
* `~/git-repos/UHDM/build/generated/src/class_typespec.cpp:228-229` — `Parameters`
  is reached one line before `Param_assigns`, so the field is `Parameters`.
* `ct212own` (the mirror owner-finder), re-run here on this verifier's own
  pristine Scoreboard database: the ONLY non-`vpiParent` edge landing on the
  head is `class_defn(work@my_scoreboard)`'s typespec vector at index 3, and
  **golden's counterpart vector has the same size (124) and the same face at
  [3]**. The object is not shared with any other owner, so clearing it cannot
  reach a second reader — the uvm202 sharing face is answered directly, not by
  analogy.
* This verifier's own pristine head file is byte-identical (modulo `/tmp` paths)
  to the implementer's committed `head_pris_Scoreboard.default.txt`.

---

## 3. THE FILLS LEDGER — an independent instrument, both whole corpora

The patch only ever CLEARS, so the ONE regression shape is *a listing golden has
that ours loses*. `ctv212fills.cpp` (this directory) does NOT use the alias walk
the implementer's census uses: it pairs every `class_typespec` in golden with
its counterpart in ours by FACE — `(VpiName, owner kind:name, Class_defn name,
clone-or-base)` — as a **MULTISET** (a last-writer dict drops the 50+ repeats of
the registry family), folds `NUL` and `n0` together because the judge cannot
tell them apart, and scores `FILL_LOST` / `FILL_EXTRA` / `FILL_SIZE`.

Calibrated golden-vs-golden FIRST: `FILL_LOST=0 FILL_EXTRA=0 FILL_SIZE=0
UNPAIRED=0/0` on Scoreboard's golden against itself.

| sweep | rows | FILL_LOST | FILL_EXTRA | FILL_SIZE |
|---|---|---|---|---|
| surelog, **pristine** | 956 | **0** | **1** (`type_id \| owner=class_defn:work@my_scoreboard \| defn=uvm_component_registry \| CLONE`) | 0 |
| surelog, **patched** | 956 | **0** | **0** | 0 |
| uhdm2rtlil, pristine | 1358 | 0 | 0 | 0 |
| uhdm2rtlil, patched | 1358 | 0 | 0 | 0 |

`NOGOLD=0` on all four — every row's golden database was resolved and scored.
**Corpus-wide, across 2314 database pairs, the patch removes exactly one wrong
fill and loses none.**

---

## 4. THE PACKAGE-LIBRARY FACE (the brief's "FILLS must stay filled")

Re-run against real uvm-1.2 with both binaries, scored by the fills ledger AND
by a listing count, so the two instruments have to agree:

| arm | golden listings | pristine | patched | FILL_LOST pris/pat | FILL_EXTRA pris/pat |
|---|---|---|---|---|---|
| `g1_unit_comp` (compilation-unit registered class) | 0 | **1** | **0** | 0 / 0 | 1 / 0 |
| `g2_pkg_comp` (package library) | 9 | 9 | 9 | 0 / 0 | 0 / 0 |
| `g4_pkg_obj` (package library) | 50 | 50 | 50 | 0 / 0 | 0 / 0 |
| `g7_unit_and_pkg` (the control: a cu AND a package registered class) | 10 | 10 | 10 | 0 / 0 | 0 / 0 |

The implementer's g-table reproduces exactly. **No package-library listing is
touched by the patch**, and `g7` still shows that a cu class DOES get a listing
when the group's base has one — the library is not the variable, clone-hood is.

---

## 5. TWELVE ADVERSARIAL ARMS, BOTH VIEWS, official judge (`gridv212v.sh`)

Each arm is compared against TWO goldens: `surelog -parse -sv` (definition view)
and `surelog -parse -elabuhdm -sv` (elaborated view). `l/h` is
lines/heads in `rowheads.sh`'s counting; `rc` is uhdm-cmp's own exit status
(0 = CMP_EQUAL).

| arm | shape probed | DEF pris -> pat | ELAB pris -> pat | verdict |
|---|---|---|---|---|
| `v1_ordersplit` | c9 with the package renamed so OUR key picks the **compilation-unit** member as the group base | 0/0 -> 0/0 | 0/0 -> 0/0 | EQUAL, untouched |
| `v2_namedargs_base` | base written with **NAMED** arguments (Surelog's ordered-only loop) | 95/1 -> **0/0** | 117/1 -> **0/0** | CONVERTS |
| `v3_threemember` | one suppressed base, **TWO** cu clones with different arguments | 95/1 -> **0/0** | 117/1 -> **0/0** | CONVERTS |
| `v4_scopedname_base` | base spelled `rp::regb #(...)` (r10sd1's b18 as the BASE) | 0/0 -> 0/0 | 0/0 -> 0/0 | EQUAL, untouched |
| `v5_paramarg_base` | base's argument names a **parameter of its own class** (b19/b5) | 95/1 -> 386/1 | 117/1 -> 117/1 | law object fixed, head cascades |
| `v6_nestedouter_base` | target generic in an **ENCLOSING CLASS** (b28 / finding F1) | 305/1 -> 305/1 | 305/1 -> 305/1 | law object fixed behind a mask |
| `v7_macro_clone` | the clone's typedef comes out of a **MACRO** | 95/1 -> **0/0** | 117/1 -> **0/0** | CONVERTS |
| `v8_bothforeign_twopkg` | **MUST-STAY**: two package classes, both foreign targets | 0/0 -> 0/0 | 0/0 -> 0/0 | EQUAL, untouched |
| `v9_cu_base_pkg_clone` | **MUST-STAY**: suppressed base + package clone | 0/0 -> 0/0 | 0/0 -> 0/0 | EQUAL, untouched |
| `v10_deepchain` | a three-deep `extends` chain, four group members | 95/1 -> **0/0** | 117/1 -> **0/0** | CONVERTS |
| `v11_moduleclass` | CLASS KIND: a class declared inside a **MODULE** | 182/1 -> 118/1 | 204/1 -> 118/1 | law object fixed, head cascades |
| `v12_virtualbase` | CLASS KIND: a **VIRTUAL** base class (the `uvm_object` shape) | 95/1 -> **0/0** | 117/1 -> **0/0** | CONVERTS |

**Five arms convert to CMP_EQUAL in BOTH views. Four MUST-STAY arms hold at
CMP_EQUAL. Three have their law object corrected behind a pre-existing mask.
NO ARM MOVES AWAY, and `FILL_LOST` is 0 on every one of the twelve.**

For the three cascade arms the "worse" line count is a HEAD MOVE, not a
regression, and it is proved as one rather than asserted: the order-blind
`uhdm-dump` diff pristine-vs-patched contains ONLY the removed listing plus
indentation-only re-prints of the shared subtree, and the patched head is a
DIFFERENT object (`module_inst work@topb`'s `vpiTypedef` list for `v5`;
`class_defn pb::outerb` for `v6`, which is also the PRISTINE head there).
A cmp line count is the head object's decompile size and is not comparable
across a change that removes a cascade mask (RESUME §9, ladder facts).

### `v1` is a finding, and it CORROBORATES the law

The implementer wrote that Surelog picks the group's base by walking
`Design::m_classDefinitions`, "which is why the answer is uniform". `v1` is c9
with the package renamed `rp` -> `zp`, so that `work@ub` now sorts BEFORE
`zp::zcb` where it sorted after `rp::rcb`. **Golden's base flips with it**: in
c9 golden's base is the package class and both members get NUL; in `v1` golden's
base is the COMPILATION-UNIT class and **both members get `n1/n1`**. Our
emitter's `stable_sort` on `(owner, name)` picks the same member both times, so
`ct212alias` reports 0 mismatches on both sides of `v1` and the cell is
CMP_EQUAL before and after. The base-selection rule is name-ordered, not
library-ordered — a diagonal the implementer's grid never measured, and our key
already agrees with it.

---

## 6. THE WIDE BOUNDARY — 5446 committed arms, both views, TWICE

`bound212.sh` (the implementer's own gate, unmodified) over the **WHOLE**
`tools/probe` tree, not the 665-arm subset the implementer chose.

```
run 1 (verifier worktree, incl. this pass's arms):
  LISTED=5446 PROCESSED=5446 PRODUCED_DBS=5253 MOVED_ARMS=10 RC_DIFFS=0
run 2 (PRISTINE tree at 59767284, i.e. COMMITTED arms only):
  LISTED=5418 PROCESSED=5418 PRODUCED_DBS=5233 MOVED_ARMS=2  RC_DIFFS=0
```

Every family the brief names is byte-identical in BOTH views, run 1 and run 2:
`r10uvm163repro` (3 arms) + `r10v163repro` (8) — the § 163 arms and the
`ownTypeFormalArgPushesNothing163v` fence; `r10uvm202repro` (5) + `r10v202repro`
(6); `r10uvm205repro` (6) + `r10v205repro` (7); `r10uvm207repro` (10);
`r10uvm208repro` (7) + `r10v208repro` (10); `r10uvm82repro`, `r10uvm91repro`,
`r10buvm3repro`, `r10buvm15repro`, `r10sd8repro` (37), `r10sd12repro` (108),
`r10sd1repro` (29), `r10uvm112repro` (12) — **MOVERS=0 in every one.**

Of run 1's ten movers, seven are this pass's own arms (`grid/c9`, the positive
control, plus six of this verifier's `gridv/` arms). The other three are the
finding below.

### TWO COMMITTED ARMS THE IMPLEMENTER'S BOUNDARY DID NOT COVER

`r10v112repro/grid/g6_baseplain.sv` and `g8_paramclass.sv` — the § 112
VERIFIER's own arms, i.e. the sibling law's cells — MOVE in both views. Both
were adjudicated with the official judge against a freshly built golden:

| arm | shape | DEF pris -> pat | ELAB pris -> pat | FILL_LOST | FILL_EXTRA |
|---|---|---|---|---|---|
| `g6_baseplain` | the base takes the generic's DEFAULTS (no `#(...)` at all) | 46/1 -> **0/0, rc 0** | 1414/1 -> 1328/1 | 0 / 0 | — |
| `g8_paramclass` | the base is a PARAMETERIZED class whose argument names its own `W8` | 46/1 -> 103/1 | 1680/1 -> 1594/1 | **0 / 0** | **2 -> 0** |

(`g6`/`g8` counts here are stdout-only; the verdicts are uhdm-cmp's own rc.)
On `g8`, golden gives BOTH clones NUL, pristine gave both `n1` (wrong), patched
gives both NUL (right); the line count rises only because the head cascades to
`work@g8top`'s `vpiTypedef` list, and the order-blind dump diff between our two
binaries contains only the removed listings. **`g6` converts to CMP_EQUAL.**
Both are moves TOWARD golden; neither is a regression.

### ONE FALSE MOVER, named and disposed of

Run 1 also flagged `r10vrgg3repro/xi_iface_param_type/dut.sv` with
`def=SAME elab=MOVED`. That arm contains **no class and no typedef at all**, so
the law cannot reach it. Disposed of three ways: the elaborated database is
byte-identical between the two binaries when the arm is re-run in isolation;
**80 runs** (40 pristine, 40 patched) all produce the single hash `6c3534fb5232`;
and the arm is **NOT a mover in run 2**, which reached it (line 4998 of that
run's LISTED). A transient, not an attribution. Recorded rather than dropped,
because a boundary gate that is silently flaky is a boundary gate that cannot
convict.

---

## 7. THE COIN, ATTRIBUTED ORDER-BLIND

Scoreboard/default is the ~50/50 coin row, so the single byte mover is
attributed ONLY by path-normalised SORTED dumps:

```
1100449 -> 1100422 lines, 82 diff lines
38 lines only in pristine, 11 only in patched
zero `svunit_pkg` lines
```

Every one of the 38 pristine-only lines is the removed listing
(`|vpiParameter:`, `|vpiParamAssign:`, `work@my_scoreboard::type_id::T` and its
`ref_typespec`, the `param_assign` with its `vpiLhs`/`vpiRhs`, the
`my_scoreboard` actual). **All 11 patched-only lines are the SAME shared
`uvm_pkg::uvm_component_registry::T` subtree re-printed at a shallower
indentation** — no new content whatsoever. Zero `svunit_pkg` task/func lines
means the coin did not flip between the two runs, and the sorted diff would have
been blind to it if it had. `COIN.orderblind.r10v212.txt` is the whole diff.

---

## 8. THE EARLGREY DUMP-COLUMN BLANK — independently confirmed as pre-existing

Against the COMMITTED `results/golden_surelog.csv`, `Earlgrey_0_1` default and
testflags show dump column `differ` -> blank. This verifier's OWN PRISTINE sweep
shows the SAME blank in BOTH modes, so `ct8rows.sh <own pristine> <own patched>`
reports **1 differing row, not 3**. Third proof: `protdb212.sh` gives
`Earlgrey_0_1` default `8c2ba25c4d7f` and testflags `92bf7b7facdc`, **identical
patched vs pristine**, and byteverify calls it a non-mover. Cause, read out of
`verify_golden.py:625-635`: when a row has no cached golden dump hash the harness
runs `dump_verdict`, whose `uhdm-dump` of that database exceeds the timeout under
load and leaves `dump` as `''`. Harness artifact, not a demotion — STATUS stays
`CMP_EQUAL` on both sides.

---

## 9. THE OTHER GATES

* goldens **23 PASS / 0 FAIL** patched, 23 / 0 pristine, **0 / 23** with
  `SLANG_UHDM=/bin/false`; `SLANG_UHDM` exported explicitly per binary.
* canaries surelog vs OWN pristine: `ok=51 changed=1`, the one change being the
  conversion. Against the committed baseline `ok=49 changed=3`, the extra two
  being the Earlgrey blanks above. canaries u2r `ok=8 changed=0`.
* `ctcan2` PASS on both corpora (`EXPECT_UNKNOWN=1` / `=6`).
* `canaudit.sh canaries.sh ctcan2.sh`: **audited=29 UNCOVERED=0 FENCE-BREACH=0
  PASS**. The four fenced names appear in **0 files** of either probe directory.
* the SIX CMP_EQUAL row-modes (BuildUVMPkg ×2, Earlgrey_0_1 ×2, SimpleUVM ×2)
  scored in both columns AND re-judged directly: **`uhdm-cmp` rc = 0 on all
  six**, rows identical pristine to patched.
* patch surface: `include/UhdmExporter.h`, `src/UhdmExporter.cpp`,
  `tools/probe/r10uvm212repro/` — 55 paths, nothing else. `results/` untouched.
  No `rm -rf`, no `/tmp/ctl_*` read, no other pass's path hard-coded in any of
  the implementer's scripts.

---

## 10. RESIDUES (ranked)

* **RV1 — the implementer's boundary set was too narrow.** 665 arms of a 5418-arm
  committed tree; two real movers (`r10v112repro/grid/g6`, `g8`) lay outside it
  and had to be adjudicated here. Both move toward golden, so the verdict is
  unchanged — but the next pass on this family should run the boundary over the
  whole `tools/probe` tree, which costs about 90 minutes and convicts what a
  subset cannot.
* **RV2 — `bound212.sh` can report a transient MOVER.** One arm with no class in
  it was flagged in run 1 and cleared by 80 re-runs plus run 2. A `cmp`-based
  gate over 5446 arms while three other jobs sweep will occasionally read a
  partially written database. Re-run a mover in isolation before attributing it.
* **RV3 — R2 is weaker than stated, in the pass's favour.** The implementer
  recorded the cleared listing's `type_parameter`/`param_assign` as "left in the
  weakly-referenced tail". They do not reach the FILE either: the patched
  Scoreboard database is 11163150 bytes against pristine's 11163173, i.e.
  SMALLER, and the objects are absent from the dump.
* **RV4 — an EMPTY base listing is still not handled, and is unreachable today.**
  `copyClassTdSpecParams1` clears the destination only when
  `base->Parameters()` is NULL; a base with a present-but-EMPTY vector still
  falls through to the copy loop, which returns before assigning and leaves the
  clone's own `#(...)`. Our emitter never produces an empty `Parameters`
  (`emitClassTdSpecParams1` returns false before setting when `ok1` is empty, and
  `copyClassTdSpecParams1` returns before assigning when `params1` is empty), so
  the cell cannot be reached from our side; the judge could not see it anyway
  (`BaseClass.h:217-222` folds NULL and empty together). Recorded, not fixed.
* **RV5 — the group's BASE OBJECT still differs from golden's** on several arms
  (`v3`, `v10`: golden aliases both clones to an object owned by the LAST cu
  class, we alias to the suppressed package one; `v8`, `v9`: golden parents the
  base at a `module_inst` with an empty name, we parent it at its own
  `class_defn`). The judge does not read `vpiParent`, and the listing VALUES
  agree, so none of it is visible today — it is the same residue the implementer
  filed as R3 and the R0 line names.
* **RV6 — the pass-50 package-anchor call site (`overwrite1 = false`) is still
  unmeasured**, exactly as the implementer's R1 says. Re-read here and confirmed
  behaviourally unchanged by the patch: with `overwrite1` false the new branch
  returns immediately, which is what the old first line did.

## FILES

`ctv212fills.cpp` (the fills ledger), `fillsweep212.sh` (it over a whole
workdir), `gridv212.sh` + `gridv212v.sh` (the adversarial grid, census form and
two-view judge form), `gridv/` (12 arms), `GRIDV.r10v212.txt`,
`FILLS.{sl,u2r}.{pris,pat}.txt`, `COIN.orderblind.r10v212.txt`,
`BOUNDARY_MOVERS.run1.r10v212.txt`, `head_pris_Scoreboard.default.r10v212.txt`,
`GATES.r10v212.txt`.
