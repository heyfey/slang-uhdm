# r10sd8 — ADVERSARIAL VERIFICATION of § importCopyElemVarTsNoInstance8

**VERDICT: ACCEPT AND LAND — with the LAW STATEMENT NARROWED.** Every number in
the implementer's report reproduced, most of them bit-exact, on a fresh
`3a7a6a6` worktree of my own. Both binaries came out with the implementer's own
md5s. The five gates are green, the head advances on both target rows, and the
wall really does collapse from 1 422 687 cmp lines to 56.

**But the law as WRITTEN is refuted by a cell the grid does not contain.** A new
verifier cell (`vgrid8/v1`) — an import copy whose element type is a **typedef
of a CLASS** — has golden **STAMPED** (`ALL:qa`) exactly where the coded gate
NULLS. This is the same over-fire §5.1 claims `g6` caught, on the spelling `g6`
does not cover. It costs nothing on either corpus (measured: the shape does not
occur) and it moves no gate, so it does not block the patch — but the sentence
"what golden never carries is the stamp the clone merely INHERITED" is FALSE as
a general statement, and it must not be carried forward as a law.

Two of the pass's own instruments are also shown to be blind in ways that
matter to its refutations (F2, F3).

| | |
|---|---|
| verifier worktrees | `/tmp/wt_vsd8` (patched), `/tmp/wt_vsd8pris` (pristine) |
| BASE both | `3a7a6a6ebfaa4614cb28ca99c557a5a51a4ae75f`, grep-checked `=1` |
| build | `cmake --build build -j 2`, `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen before any md5 was read, ` error:` count **0** |
| delivered md5 | **`97462111685cc4e7a22ca1bf91cd0e5b`** — identical to the implementer's |
| pristine md5 | **`3925b8fe80afa09d524f7d42ac0f468c`** — identical to the implementer's |
| pristine `git status --porcelain` | 0 lines |
| `results/` | `git status --porcelain -- results` = **0**, read only |
| `GOLDEN_DEFER` | printed `[UNSET]` before every sweep |
| patch verified | `/tmp/r10sd8.patch`, md5 `7c51b8bcba32174a72a45c7537f8d5cf`, `git apply --check` clean on a fresh `3a7a6a6`; touches `src/ModuleEmit.cpp` + `tools/probe/r10sd8repro/` and nothing else |

---

## 1. WHAT REPRODUCED — every claim, re-run, never cited

### 1.1 The five gates

| gate | claimed | measured HERE |
|---|---|---|
| **1 BUILD** | md5s, BASE, 0 errors | **identical md5s both binaries**, BASE grep-checked, 0 errors, link line before md5 |
| **2 GOLDENS** | 23/0, `/bin/false` 0/23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 / 23** |
| **3 u2r** | 679/50/2, dump 496/183/52, 0 rows | default **679/50/2**, testflags **679/50/2**, both binaries; dump testflags **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (testflags-filtered) **0 differing ROWS**; pristine-vs-delivered **0 rows** |
| **4 surelog** | 469/11 + 465/8, FAIL 25/23, DEFER 5/5, histograms unchanged, 0 rows | default **469 / 11 / 25 / 5 / 284**, testflags **465 / 8 / 23 / 5 / 286 (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM)**, both binaries; all four dump histograms identical to committed (default 225/244/325, testflags 165/300/329); `ct8rows` vs committed `results/golden_surelog.csv` **0 differing ROWS** — the `Google,testflags` drift did **not** recur; pristine-vs-delivered **0 rows** |
| **5 BYTE VERIFIER** | u2r 0/1358, surelog 5/953, SELFCHECK1 1 and 6 | u2r **0 / 1358**, surelog **5 / 953**, `PATH_SETS_IDENTICAL` both, SELFCHECK **1357/1358** and **952/953**, SELFCHECK1 **1** and **6** |

`SLANG_UHDM` pin verified exhaustively by reading `cmds.txt` on **all four**
sweep trees: surelog 1573 files / **1523 `slang:` lines, 1523 name the right
binary, 0 name any other**; u2r 1462 / **1458, 1458 / 0**. All sweeps
`--jobs 2` with private `--out` / `--workdir`.

### 1.2 The head and the wall — both target rows

| row | pristine | delivered |
|---|---|---|
| `default/SeqDriver` | `r=-1 visited=1653` `<null>` / `package(uvm_pkg)@28:1-39:11`, cmp **1 422 687** lines, 1 head | `r=-3 visited=1861` `class_var(access_record)@483:34-483:47` / `struct_var(access_record)@483:34-483:47`, cmp **56** lines, 1 head |
| `testflags/SeqDriver` | `r=-1 visited=1665`, cmp **1 422 687** | `r=-3 visited=1873`, cmp **56** |

`ct8head --brute` re-run on the pristine database: **`brute pool=13464
ADVANCING=1 REGRESSING=34 (baseline restored)`**, 3.3 s, and the single
advancing object is exactly

```
class_typespec(uvm_seed_map)@328:1-328:13 < ref_typespec@0:0-0:0
  < class_var@328:14-328:42 < array_var(uvm_random_seed_table_lookup)@328:14-328:42
  < class_defn(adpcm_seq_item)@18:1-73:25 < package(adpcm_pkg)@10:1-207:22
```

`ct8bis`'s refutation also reproduces (`pool=10304`, `POOL_ALL_NULLED r=1
visited=150`), so R7 ("`|visited|` is not monotone, use `--brute`") stands.
`ct8sim`'s pre-patch simulation reproduces (`TO_NULL=9`, SIMULATED tuple ==
the delivered binary's actual tuple, baseline RESTORED).

### 1.3 The movers

Byte verifier found **exactly** the five predicted databases, name for name,
and `ct8pred` re-run over the 953 PRISTINE databases predicted exactly those
five with exactly those counts (`Scoreboard 2, SeqDriver 5, SimpleUVM 2` ×
modes) — and **0** over all 1358 u2r databases. Re-run over the 953 DELIVERED
databases it scores **0**, golden's own score. All sizes nonzero:

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 021 287 | 18 021 249 | **−38** |
| `testflags/SeqDriver` | 18 021 718 | 18 021 667 | **−51** |
| `default/Scoreboard` | 11 145 436 | 11 145 422 | **−14** |
| `default/SimpleUVM` | 11 141 362 | 11 141 350 | **−12** |
| `testflags/SimpleUVM` | 11 141 682 | 11 141 670 | **−12** |
| `BuildUVMPkg` both modes | 11 105 247 | 11 105 247 | **byte-identical** |

`testflags/Scoreboard` is `SLANG_REJECT` at baseline (verified in the CSV) —
a SKIP, not an agreement.

Per-shape multiset (`ct7shape.py`, `sed 1d` on all three dumps) reproduces
exactly: `SeqDriver` `vpiInstance` ADDED 0 / REMOVED 5, `package` 0 / 5, **every
other shape 0/0 (130 shapes)**; `SimpleUVM` and `Scoreboard` 0/2 and 0/2.
The **COST is real and was stated honestly**: msdist worsens
359 613 → **359 623**, 140 236 → **140 240**, 130 538 → **130 542**.

### 1.4 The object census and the grid

`ct8pop` on `SeqDriver`: `d1 var/ts` SET **17 → 12**, `<null>` **123 → 128**;
golden 19 / 121. The **whole** census output differs between the two binaries in
**5 rows and 4 summary lines and nothing else**, and the 5 rows are the five
`uvm_random_seed_table_lookup` element typespecs going `TOP:uvm_pkg` → `<null>`
— which is what golden reads at the identical keys. Depth-0 control 1139/63
unmoved. `ct7pkgsub` on the package listing: pristine == delivered modulo
pointers, and **golden == delivered** on all four views.

Grid, both binaries, every cell re-run:

| cell | golden `d1 var/ts` | pris | del | cmp pris → del | content |
|---|---|---|---|---|---|
| `g1` assoc, class elem | `<null>` | `TOP:p1` | **`<null>` == golden** | **CMP_FAIL → PASS_CMP** | 133 → 131 |
| `g2` assoc, `int` elem | `<null>` | `TOP:p2` | **== golden** | CMP_FAIL → CMP_FAIL | 135 → 133 |
| `g3` dynarray, class elem | `<null>` | `TOP:p3` | **== golden** | **CMP_FAIL → PASS_CMP** | 92 → 90 |
| `g4` class's own assoc | `<null>` | same | same | PASS → PASS | 28 → 28 |
| `g5` no import | (no copy — verified: the class listing carries only `own5`) | — | — | PASS → PASS | 68 → 68 |
| `g6` typedef **struct** elem | **`ALL:q6`** | `ALL:q6` | **`ALL:q6` HELD** | PASS → PASS | 167 → 167 |

`detcheck.sh` on `g1` with the delivered binary: **3 runs, 1 distinct sha256, 0
NO_OUTPUT**.

**I independently confirmed that `g6`'s over-fire report is REAL and not a
story.** A new probe (`vsd8elem.cpp`, in this directory) prints every
`array_var`'s element variable and element typespec with a USER COUNT. On `g6`
the class copy's element typespec is a **distinct pointer with users=1**
(`ts=0x…ee20`), so neither the `ce == se` nor the `cts == sts` guard would have
skipped it: without the `srcPkgName` gate it would indeed have been nulled where
golden reads `ALL:q6`. The first patch really was wrong and the grid really did
catch it.

### 1.5 Boundaries and canaries

* `ct7pop` (sd7's own census), `ct5cls`, `ct6clsref`, `ct7loc` — all four
  **`diff`-EMPTY** between the pristine and the delivered `SeqDriver` database
  (1331 / 2452 / 53 / 14945 lines each).
* **sd4 q-grid**: all 13 cells re-run on both binaries, verdict and dump content
  **identical**, and the counts are the claimed ones
  (26/4/26/36/6/2/16/2/56/42/70/86/56). `BuildUVMPkg` byte-identical both modes.
* **grid6**: `diff`-IDENTICAL between the two binaries.
* **grid7** moves in sd7's own direction: `g1` and `g2` **CMP_FAIL → PASS_CMP**,
  `g5` 133 → 131, `g6` 287 → 285; the two no-copy controls `g3`/`g4` unchanged.
* `canaries.sh` surelog **ok=52 changed=0 absent=0** vs committed AND vs this
  pass's pristine sweep; u2r **ok=8** vs committed, **ok=16** vs pristine.
* `ctcan2.sh` **PASS** both (`EXPECT_UNKNOWN=1` ok=58; `EXPECT_UNKNOWN=6` ok=1).
* `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**, the four fenced names
  dispatched by no driver.
* `InterfaceModPort` and `BlackParrotComplex` **by name**: `CMP_EQUAL` in both
  modes on both binaries.
* `ct8cens` **`SHARED_KEYS=21152 MATCH=17303 OURS_ONLY=25 GOLD_ONLY=0
  VIEW_DIFF=3824 GOLD_NOTWIN_STAMPED=8182`** — reproduced exactly (but see F3).
* `ct8own`: golden `24 class_typespec NAMED PARENTED inst=TOP:uvm_pkg <-
  class_var in TOPPKG:uvm_pkg` (and the same 24 for the other three views);
  ours `24 … NAMED ORPHAN` with the identical stamp and referrer. **§4.2's
  re-ranking of sd7 R2 as a VpiParent residue is correct.**
* `ct7cand` = **25 on both binaries** — "still exactly 25" confirmed.

---

## 2. FINDINGS

### F1 — MEDIUM, NEW COUNTEREXAMPLE: the law over-fires on the CLASS-TYPEDEF element spelling (`vgrid8/v1`)

The stated law's discriminator is *"null it only while its `vpiInstance` still
names the SOURCE package … what golden never carries is the stamp the clone
merely INHERITED from the package it was copied OUT of."* The grid separates
`class`/`int` elements (`g1`,`g2`,`g3`, golden null) from a **struct** typedef
element (`g6`, golden `ALL:q6`). It does not contain a **typedef of a class**.

```systemverilog
package pa; class ka; int xa; endclass  typedef ka ta;  ta ma [string]; endpackage
package qa; import pa::*; class ca; int owna; endclass endpackage
module topa; qa::ca ha; endmodule
```

| | `d1 var/ts` on the class copy |
|---|---|
| **GOLDEN** | `class_typespec(pa::ta)@8:11-8:13` **`inst=ALL:qa`** — STAMPED, with the IMPORTING package |
| ours pristine | `class_typespec(ka)@9:3-9:5` `inst=TOP:pa` — the inherited SOURCE stamp |
| **ours delivered** | `class_typespec(ka)@9:3-9:5` **`inst=<null>`** — the patch NULLS it |

Golden **does** carry a stamp at a slot where our clone merely inherited one, so
the law's premise is false there. The `g6` gate cannot save this cell, because
our pristine stamp names the SOURCE package (`TOP:pa`), not the importer —
§ pkgImportCloneLastWriter32 re-stamps the shared **struct** clone and does not
re-stamp this one.

**What it costs: nothing measurable, today.** Both binaries stay `CMP_FAIL` with
the identical head (`logic_var (pa::ma)`); dump content **improves** 148 → 146
and msdist **improves** 78 → 76, because the surplus `|vpiInstance:` line we
delete was on an object golden does not have anyway. And the shape **does not
occur on either corpus**: I measured that `uvm_random_seed_table_lookup` is the
**only** package-listed array variable in `SeqDriver` (`vsd8elem`, PKG rows),
so `importVarCopy5`'s array arm reaches exactly the five copies and nothing else.

**Why it still matters:** this pass nominates the OBJECT CENSUS as the authority
over the byte measures (§6.4). On that authority `v1` is a new
golden-SET/ours-null row created by the patch. The patch should land; the
*sentence* must be scoped to what was measured — "the element typespec resolves
to a bare class or a built-in" — and `v1` carried as the named counterexample.

Two more verifier cells are delivered with it, and **one is a new positive**:

* `vgrid8/v3` — the element class lives in a **third** package (`pd`), reached
  through `pc`, imported into `qc`. golden `<null>`, pristine `TOP:pc`,
  **delivered `<null>` == golden, CMP_FAIL → PASS_CMP.** The law generalises
  correctly across an intermediate package; this is evidence the grid did not have.
* `vgrid8/v2` — `g6`'s struct typedef in the **dynamic-array** spelling.
  golden `ALL:qb`, pristine `ALL:qb`, delivered `ALL:qb` HELD, PASS_CMP
  throughout. The `g6` gate is spelling-independent.

### F2 — MEDIUM, INSTRUMENT: `ct8pop`/`ct8sim`'s key hides the converse direction in this very cell

§3.3 reports the `d1 var/ts` disagreement as *"9 rows, all in one direction …
GOLD-STAMPED-ONLY (ours null) 0"*. That is a property of the KEY, not of the
data. The key is *(class full name + span, variable name, **typespec kind +
name**)*, and 13 of the 140 slots have a typespec whose NAME differs between the
two sides, so they never join at all:

```
golden  uvm_pkg::uvm_report_handler :: severity_id_actions
          class_typespec(uvm_pkg::uvm_id_actions_array)   ALL:adpcm_pkg
ours    uvm_pkg::uvm_report_handler :: severity_id_actions
          class_typespec(uvm_pool)                        <null>
```

An `array_var` has exactly **one** element variable on both sides (measured:
147 rows each), so *(class, variable)* is the physically correct pairing. Under
it, on the PRISTINE `SeqDriver`:

```
GOLD SET / OURS NULL : 11        <- the direction §3.3 and §4.1 report as ZERO
OURS SET / GOLD NULL :  9        <- the 5 this pass fixes + R1's 4
BOTH SET, view differs: 0
```

The 11 are `uvm_callbacks_base::m_this_type`, `uvm_port_base::m_imp_list` /
`m_provided_by` / `m_provided_to`, `uvm_enum_wrapper::map`,
`uvm_report_handler`'s four `severity_id_*` / `sev_id_overrides` plus
`severity_actions` / `severity_file_handles`. In every one of them golden
resolves the element type to the package **typedef** (`adpcm_pkg::this_type`,
`uvm_pkg::uvm_id_actions_array`, `uvm_action`, `UVM_FILE`) and stamps it, and we
resolve it to the underlying class (`uvm_callbacks_base`, `uvm_pool`,
`int_typespec`) and leave it null. **That is F1's shape, on the corpus.**

None of the 11 is touched by this patch (all 5 rows the patch moves join
cleanly and golden is null at all 5), so this is a measurement correction, not
a regression.

### F3 — MEDIUM, REFUTATION: `ct8cens`'s `GOLD_ONLY=0` cannot support §4.1

§4.1 concludes from `GOLD_ONLY=0` on 21 152 shared keys that *"the converse
direction does not exist as a stamp decision at all"*. The instrument is
demonstrably blind to the object this pass fixes. Running `ct8cens` on the
pristine and the delivered database:

```
pristine  MATCH=17303 OURS_ONLY=25 GOLD_ONLY=0 OURS_NOTWIN_STAMPED=273 GOLD_NOTWIN_STAMPED=8182
delivered MATCH=17303 OURS_ONLY=25 GOLD_ONLY=0 OURS_NOTWIN_STAMPED=268 GOLD_NOTWIN_STAMPED=8182
```

`MATCH`, `OURS_ONLY` and `GOLD_ONLY` do not move at all; the whole effect lands
in `OURS_NOTWIN_STAMPED`, **273 → 268**. The five stamps whose removal collapses
a 1.4-million-line compare were in the census's NO-TWIN bucket the entire time.
A key that cannot see the head is not a key that can prove a direction empty.
§4.1's *evidence* (R7's deficit is `GOLD_NOTWIN_STAMPED=8182`, a span/keying
problem) is sound and useful; its *conclusion* over-reaches, and F2 exhibits 11
counterexamples in the one cell that was re-keyed by hand.

### F4 — LOW: the guard-coverage table understates the unexercised guards

§2.1 says three of five guards are unexercised. On the corpora it is **four**:
the `srcPkgName` gate never rejects there either, because `importVarCopy5`'s
array arm reaches exactly the five `uvm_random_seed_table_lookup` copies
(measured: it is the only package-listed array variable in `SeqDriver`, and all
five carry `TOP:uvm_pkg` == the source package, so all five are accepted). The
gate is exercised **only** by grid cell `g6` and by verifier cells `v1`/`v2`.
That is not a defect in the code — it is exactly what a synthetic grid is for —
but §2.1 is the pass's STATED-GATE-==-CODE-GATE declaration and should say it.

### F5 — LOW, DOC: `+63 lines, no line deleted` is wrong

`git diff 3a7a6a6 --numstat -- src/ModuleEmit.cpp` = **86 insertions, 2
deletions** (the two are `importVarCopy5`'s signature line and its single call
site). The final report states `+86/−2` correctly; README §2 contradicts it.

### F6 — LOW, DOC: "every grid7 cell drops by exactly 2 lines" is not what grid7 does

Four of six do (`g1` 133→131, `g2` 92→90, `g5` 133→131, `g6` 287→285). The two
no-copy control cells are unchanged (`g3` 28, `g4` 68) — which is the correct
and desirable behaviour, and is the reason they are controls.

### F7 — LOW, DOC: `testflags/SimpleUVM`'s head is not "same" in the numeric sense

The head OBJECT is identical (`ref_obj(status)` / `method_func_call(status)`
@664:87, `r=-40`), but `visited` is **8881**, not the 8869 of the default row.
Both binaries agree; nothing moved.

### F8 — LOW, DOC: two different candidate counts under one sentence

§4.2 says "after the fix the candidate set is still exactly 25". `ct7cand` is
25 → 25 (confirmed). `ct8head --cand`'s own probe count is **32 → 36**, because
the deeper walk exposes four more visited golden objects. `ADVANCING=0` on both.
The claim is true of the instrument it names and false of the one whose output
is quoted next to it.

---

## 3. WHAT I COULD NOT BREAK

* **No shared-object backfire.** `vsd8elem` counts users per element typespec.
  All five objects the patch nulls have **users=1** in the pristine database,
  and the package listings hold four *different* pointers, one per view — which
  is why `ct7pkgsub` is untouched. Golden has the identical shape (five class
  copies null, four package listings stamped per view).
* **R1's four struct stamps really are SHARED.** `m_verbosity_settings` /
  `m_time_settings` share one `struct_typespec` (users=2) and
  `m_uvm_applied_cl_action` / `m_uvm_applied_cl_sev` share another. The
  implementer's "nulling them blind is a backfire risk" is a measurement, not a
  hedge. They are also unreachable from `importVarCopy5` (they are class
  members, not package variables), so the patch cannot touch them by accident.
* **The recursion is inert here.** `importCopyTsSub7(cts, sts, 0)` does not null
  at depth 0 (`if (depth > 0)`), and the element typespecs reached are
  `class_typespec` / `int_typespec` / `struct_typespec`, none of which has an
  `Index_`/`Elem_typespec` arm — so the call is a no-op on both corpora, as
  claimed.
* **No hidden corpus movement.** Whole-row CSV diffs are 0 rows against the
  committed baselines AND binary-to-binary, on both corpora; the byte verifier
  sees exactly 5 databases and 0; the per-shape multiset sees exactly two shapes
  and 130 zeroes.

---

## 4. RESIDUES, RANKED (verifier's list)

1. **V-R1 — the element-typespec IDENTITY defect, which is upstream of the stamp
   question.** Golden resolves an array's element type to the package
   **typedef** (`pa::ta`, `adpcm_pkg::this_type`, `uvm_pkg::uvm_id_actions_array`,
   `uvm_action`) and we resolve it to the underlying class or built-in (`ka`,
   `uvm_callbacks_base`, `uvm_pool`, bare `int_typespec`). **13 slots on
   `SeqDriver`** (F2) and it is what makes `v1` (F1) both mis-named and
   mis-stamped. Fixing the identity would convert 11 golden-SET/ours-null rows
   and would very likely dissolve F1 rather than needing a second gate.
2. **V-R2 — `vgrid8/v1` as a standing counterexample cell.** Until V-R1 lands,
   any future refinement of § …8 must score `v1`, not just `g1`…`g6`.
3. **V-R3 — `SeqDriver`'s new head**, `class_var` vs `struct_var(access_record)`
   @`uvm_resource.svh:483:34` inside `function(record_read_access)` of
   `class_defn(uvm_resource_base)`, `r=-3`, visited 1861/1873. Confirmed as the
   cheapest next item on both rows.
4. **V-R4 — `d2 var/ts/alias`: golden 11, ours 6.** Unmentioned by the pass, in
   the same census it introduces, and unmoved by it. A second element-subtree
   cell with a real deficit.
5. **V-R5 — `ct8cens` needs a parent-and-span-independent key** before any
   claim about a direction being empty is made from it again (F3). The 8182
   `GOLD_NOTWIN_STAMPED` bucket is where every such claim currently hides.
6. **V-R6 — sd7 R2 is a `VpiParent` residue**, confirmed independently by
   `ct8own`: 24 objects per view, same count, same stamp, same referrer, golden
   PARENTED and ours ORPHAN. Re-file as parent linkage.
7. **V-R7 — the multiset instrument regresses on every correct deletion**
   (+10 / +4 / +4 here) until the `TOP:`-view deficit closes. Unchanged, and
   the pass paired it with the object census as required.
8. **V-R8 — four of five guards unexercised on the corpora** (F4). Either add a
   corpus-shaped cell that exercises the pointer-identity guards or accept that
   the grid is their only coverage and say so.

---

## 5. OPS

Sweep workdirs (`/tmp/vsd8_wd_sl_*`, `/tmp/vsd8_wd_u2r_*`) deleted after the
last measurement. Grid and arm scratch dirs are all `vsd8`-prefixed. No file
outside `/tmp/wt_vsd8`, `/tmp/wt_vsd8pris` and `/tmp/vsd8_*` was written;
`/tmp/claude-1000` untouched; `results/*.csv` never written; no `git stash`;
slang not patched; the four fenced tests never dispatched.

**COLLISION** — the implementer's report of a textual overlap with `r10earl48`
in `src/ModuleEmit.cpp` is accurate and stands: this patch's hunks are a
file-static immediately above `importVarCopy5` (~4383) plus one call inside it,
and one argument at its single call site (~4700, in
`classInheritsContainerImports23`). Merge, do not cherry-pick. `r10uvm77`
(`ExprEmit`) does not overlap.

**Re-cut**: `/tmp/r10sd8.verified.patch` is `/tmp/r10sd8.patch` plus this file,
`vgrid8/v1…v3.sv` and `vsd8elem.cpp`. **No production line was changed by the
verifier** — `src/ModuleEmit.cpp` is byte-identical between the two patches.
