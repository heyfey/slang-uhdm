# r10sd7 — the SeqDriver wall ADVANCED: § importCopyTsSubtreeNoInstance7

**The head is one level deeper than every instrument this campaign had.** sd5
and sd6 taught the import copier to own its variable, its typespec and its
initialiser's references; all three censuses then read the class listings as
converged, and they were right about everything they could see. They stop at the
variable's own typespec. The head sat on the typespec **that typespec points
at** — the `[string]` INDEX typespec of the package's associative array
`uvm_random_seed_table_lookup`, which the clone duplicates faithfully and which
therefore inherits the package stamp golden does not have there.

The wall is **not cleared**. It **advanced**, and the advance is measured rather
than asserted: `m_visited` after the whole-design compare goes **1650 → 1653** on
both rows, and the depth-keyed class-listing census now equals golden **cell for
cell on all three UVM designs**. The remaining head is named and ranked (R1).

| | |
|---|---|
| BASE | `f0d93e1` (grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd7` (delivered), `/tmp/wt_r10sd7pris` (pristine control, `git status --porcelain` = 0) |
| delivered binary | md5 `f46ccffff0fa29f838a5701882a685ba` |
| pristine binary | md5 `2ecf28a8494750468a6edcd435b8f874` |
| production files | `src/ModuleEmit.cpp` only |
| probe files | `tools/probe/r10sd7repro/` |

---

## 1. THE LAW

> **§ importCopyTsSubtreeNoInstance7** — the COPY that
> § importedClassVarIsOwnCopyNoInstance5 pushes into an importing CLASS owns its
> typespec's **whole subtree**, not just the top typespec, and every level of it
> is **UNSTAMPED**. § …5 nulls the copy's actual typespec (depth 0); the
> typespecs that typespec points at through `vpiIndexTypespec` /
> `vpiElemTypespec` keep the package stamp `clone_tree` copied into them, and
> golden carries none there.
>
> **The PACKAGE's own listing keeps its stamp**, view-matched
> (`ALL:pkg` on the def view, `TOP:pkg` on the elaborated one). That is what
> makes this the COPY's law and not the array emitter's.

**What it is NOT:**

* not "an associative array's index typespec carries no `vpiInstance`". All four
  package listings — `ALL`/`TOP` × `uvm_pkg`/`adpcm_pkg` — stamp it, on **both
  sides, identically** (§3.2). That phrasing would have moved four correct cells
  to fix five wrong ones.
* not "a nested class-listing typespec has no instance". Golden stamps **39** of
  them at depth 1 and we stamp the same 39 (§3.1); they belong to the classes'
  OWN variables, which the import arm never touches. A blanket null would have
  destroyed all 39.

---

## 2. STATED GATE == CODE GATE

**STATED:** on the freshly cloned copy — and only there — walk down from the
copy's actual typespec through `vpiIndexTypespec` and `vpiElemTypespec`
(`array_typespec`) and `vpiElemTypespec` (`packed_array_typespec`), to a depth of
4, and set `vpiInstance` to null on every typespec found **below depth 0**.
Depth 0 is § …5's and is left exactly as § …5 leaves it. A typespec is touched
**only if `clone_tree` actually duplicated it** — if the copy's object is
pointer-identical to the source's, it is SHARED with the package's own listing
and is not this copy's to rewrite. Walking stops if the two sides' kinds diverge.
Nothing else changes: `Typedef_alias` is **not** walked, no name, span, parent or
expression is touched, and the package listings are not reached at all.

**CODE** (`src/ModuleEmit.cpp`, one new file-static + one call inside
`importVarCopy5`):

```cpp
static void importCopyTsSub7(UHDM::typespec* cpTs, UHDM::typespec* srcTs, int depth) {
    if (!cpTs || !srcTs || depth > 4) return;
    if (cpTs == srcTs) return;        // SHARED with the source: not the copy's to rewrite
    if (depth > 0) cpTs->Instance(nullptr);   // depth 0 is § …5's
    if (cpTs->UhdmType() != srcTs->UhdmType()) return;   // divergent: stop rather than guess
    auto sub7 = [&](UHDM::ref_typespec* a, UHDM::ref_typespec* b) {
        if (a && b) importCopyTsSub7(a->Actual_typespec(), b->Actual_typespec(), depth + 1);
    };
    if (cpTs->UhdmType() == UHDM::uhdmarray_typespec) { ... Index_typespec, Elem_typespec ... }
    else if (cpTs->UhdmType() == UHDM::uhdmpacked_array_typespec) { ... Elem_typespec ... }
}

// the ONE call site, inside importVarCopy5's existing typespec block
     if (auto* at5 = rt5->Actual_typespec()) {
         at5->Instance(nullptr);
+        UHDM::typespec* st7 = nullptr;
+        if (auto* srt7 = src->Typespec()) st7 = srt7->Actual_typespec();
+        importCopyTsSub7(at5, st7, 0);
     }
```

### 2.1 COVERAGE OF THE CODE'S OWN ARMS — declared, not assumed

`ct7pop` prints the PATH of every typespec in the subtree. On SeqDriver, both
sides, the paths that exist at all are:

```
   29  d1 ts/alias        <- Typedef_alias; the code does NOT walk it, and the
   91  d1 ts/index           two sides already agree on all 29 + all 3
    3  d2 ts/index/alias
    0  d1 ts/elem         <- NO SUCH ROW EXISTS, on either side
```

So the **`Elem_typespec` arm and the `packed_array_typespec` arm never fire** —
not on SeqDriver, and not anywhere in either corpus (the byte verifier finds
exactly the five index-only movers the predicate predicted, §6, and nothing
else). They are in the code because they are the faithful transcription of "the
subtree", and the pointer-identity guard makes them safe; they are named here
because an unexercised arm that goes unmentioned is how a stated gate stops being
the code gate. Grid `g2` is the cell that shows WHY: a dynamic array's
`Elem_typespec` is `<null>` on **both** sides, so there is nothing there to stamp.

---

## 3. THE DECODE

### 3.1 The population, by DEPTH — `ct7pop`, both sides, all 1206 entries

`ct5cls` (sd5) and `ct6clsref` (sd6) stop at depth 0. At depth 0 the two sides
already agree exactly, which is why the listing read as converged. Keyed by
depth, the whole typespec subtree of every class-listing variable:

| | GOLDEN | OURS pristine `f0d93e1` | OURS delivered |
|---|---|---|---|
| depth 0 `<null>` | 1139 | 1139 | 1139 |
| depth 0 **SET** | **63** | **63** | **63** |
| depth 1 `<null>` | 81 | 76 | **81** |
| depth 1 **SET** | **39** | **44** | **39** |
| depth 2 SET | 3 | 3 | 3 |

**The whole surplus is 5 objects**, and they are one shape — the `[string]`
index typespec of `uvm_seed_map uvm_random_seed_table_lookup [string]`, the
package's associative array, copied into the five `adpcm_*` classes:

```
- adpcm_pkg::adpcm_seq_item :: uvm_random_seed_table_lookup | d1 ts/index
      | string_typespec@328:44-328:50 | inst=<null>        <- GOLDEN
+ adpcm_pkg::adpcm_seq_item :: uvm_random_seed_table_lookup | d1 ts/index
      | string_typespec@328:44-328:50 | inst=TOP:uvm_pkg   <- OURS
```

(`-` is golden, `+` is ours, every time in this file.) The **`depth 1 SET 39`**
row is the control that forbids the blanket rule, and it does not move.

The same census on the other two UVM designs, delivered vs golden:

| design | GOLDEN d1 `<null>`/SET | OURS pristine | OURS delivered |
|---|---|---|---|
| `SeqDriver` | 81 / 39 | 76 / 44 | **81 / 39** |
| `SimpleUVM` | 78 / 39 | 76 / 41 | **78 / 39** |
| `Scoreboard` | 78 / 39 | 76 / 41 | **78 / 39** |

**Delivered equals golden cell for cell on all three.**

### 3.2 The cell that decides WHICH patch — `ct7pkgsub`

Two different laws fit the observation above, and they are two different
patches. The package's own listing separates them, and it was read **before any
code was written**:

```
GOLDEN                                   OURS (pristine)
[ALL] uvm_pkg   index inst=ALL:uvm_pkg   [ALL] uvm_pkg   index inst=ALL:uvm_pkg
[TOP] uvm_pkg   index inst=TOP:uvm_pkg   [TOP] uvm_pkg   index inst=TOP:uvm_pkg
[ALL] adpcm_pkg index inst=ALL:adpcm_pkg [ALL] adpcm_pkg index inst=ALL:adpcm_pkg
[TOP] adpcm_pkg index inst=TOP:adpcm_pkg [TOP] adpcm_pkg index inst=TOP:adpcm_pkg
```

Four listings, both sides, **identical, view-matched**. So "the index typespec
carries no instance" is refuted on its own evidence, and the law belongs to the
copy.

### 3.3 The copy's nested typespec is ALREADY a distinct object

`ct7sub` prints pointers. Our five class copies hold five **distinct**
`string_typespec` objects, none of them the package listing's:

```
OURS  adpcm_driver    index ptr=0x1a127fe0    adpcm_seq_item ptr=0x1a127d40
      adpcm_sequencer index ptr=0x1a128280    adpcm_test     ptr=0x1a1289d0
      adpcm_tx_seq    index ptr=0x1a128730    [TOP] uvm_pkg  ptr=0x15ca9b80
```

`clone_tree` was already cloning deep enough; only the **stamp** was inherited.
Golden's five are distinct too, and all null. This is why the fix is one null and
not a new clone — and it is why the pointer-identity guard in §2 has something to
guard: `clone_tree` keeps *some* children shared (sd5 measured
`class_typespec.Class_defn` SHARED), and nulling a shared object would destroy
the package's stamp at the same time.

---

## 4. HOW IT WAS LOCALIZED — and the two instruments that LIED

The brief pointed at sd6's residue R1: `ct4scan`'s deepest singleton killer,
`class_typespec@uvm_globals.svh:199:3-199:20` inside
`function(uvm_report_warning)`'s `begin`, owner `class_var(cs)`. That is the
`cs` statement-local of a package-scope function, and the brief's hypothesis was
that this head is sd3's return-name-local law extended to other statement-locals.

**That hypothesis is REFUTED by measurement.** `ct7loc` censuses every
function-body local of every package and class routine, with its typespec and
that typespec's `vpiInstance`, on both sides. On `uvm_report_warning`: **36 rows
each side, all `inst=<null>`, `diff`-identical.** The statement-locals are not
the defect, in any respect this pass can measure. The killer is an ANCESTOR on
the path — `class_typespec@199:3` points at `class_defn(uvm_coreservice_t)`, and
the compare descends through it — exactly sd4 R6's warning that the deepest-killer
heuristic is unsound.

Two more instruments returned confident wrong answers, and both are recorded
because the next pass will otherwise re-derive them:

**(a) gdb's `bt` mis-symbolised the frames.** The sd4 method (`ct4bt`, a hardware
watchpoint on `CompareContext::m_failedRhs`) is still the right way to learn the
ARM, and it was re-run here. Its backtrace named

```
#0 typespec::Compare   #1 array_typespec::Compare   #2 variables::Compare
#3 array_var::Compare  #4 SafeCompare<variables>    #5 scope::Compare
#6 class_defn::Compare
```

`array_typespec::Compare` starts at `0x779190` in this non-PIE executable.
Frame #1's return address is `0x778f6e`, and `info symbol 0x778f6e` on the very
same binary resolves it to **`logic_typespec::Compare + 142`** — two symbols
earlier. Acting on the frame name cost three census instruments
(`ct7own`, `ct7ats`, `ct5cls`), each of which came back "the two sides agree",
which they do. **Cross-check every gdb frame name against `info symbol` before
building an instrument on it.**

**(b) `ct4bt`'s stack scrape names dead words.** Its oracle prints any of 4096
stack words that is a live UHDM object; it named
`array_var(uvm_random_seed_table_lookup)` — which is the right *variable*, by
luck, and whose own typespec `ct7own` proves AGREES on both sides. The object was
a leftover from an earlier, successful compare. `ct7bt` replaces the scrape with
labelled reads of the object's own `vpiParent` chain and `Instance()` slot; those
cannot go stale. It also fixes two ops traps in `ct4bt.gdb` (§9.4).

**What actually localized it** was reading `SafeCompare` instead of the stack.
`BaseClass.h`:194 writes `m_failedRhs` and leaves `m_failedLhs` unset in exactly
one branch, `lhs == nullptr && rhs != nullptr`, and `ct7bt` prints
`failedLhs=(nil)`. So the head is a singular slot whose golden twin is null. The
only singular slot in these databases that can hold a package is `vpiInstance`
(sd2's 154-relation census, re-confirmed here by `ct4ref`: our failing package is
referenced by `.vpiInstance` slots and by `design.uhdmtopPackages[]`, and by
nothing else). `ct4scan`'s `visited` pool then names
`array_var(uvm_random_seed_table_lookup)` as a killer with the deepest real
chain, and `ct7sub` walks that one variable's typespec subtree on both sides —
which is where the `index` row is, in the first line that differs.

---

## 5. THE GRID — golden's rule, cell for cell

`ct7grid.sh` over `grid7/g*.sv`; LHS is **always** golden; `sed 1d` on both
dumps; one scratch dir per arm. Every cell is scored with **two** instruments:
`ct7pop` (the CLASS listing — the cell that must move) and `ct7pkgsub` (the
PACKAGE listing — the cell that must not).

| cell | shape | GOLDEN class copy | OURS pris | OURS new | PKG listing pris→new | cmp | ours dump content |
|---|---|---|---|---|---|---|---|
| **`g1_assoc_index_import`** | **THE CORE CELL**: `k1 m1 [string]` in a wildcard-imported package | `index inst=<null>` | `index inst=TOP:p1` | **== GOLDEN** | **IDENTICAL** (4 listings, view-matched) | CMP_FAIL → CMP_FAIL, head byte-identical | 135 → **133** |
| **`g5_int_index_import`** | the index typespec is `int`, not `string` — a different typespec CLASS, same arm | `index inst=<null>` | `index inst=TOP:p5` | **== GOLDEN** | **IDENTICAL** | CMP_FAIL → CMP_FAIL | 135 → **133** |
| **`g6_two_level_import`** | `int m6 [string][string]` | `index inst=<null>` | `index inst=TOP:p6` | **== GOLDEN** | **IDENTICAL** | CMP_FAIL → CMP_FAIL | 289 → **287** |
| `g2_dynarray_elem_import` | `k2 m2 []` — the ELEM arm | **no elem typespec at all**, either side | — | — | IDENTICAL | CMP_FAIL → CMP_FAIL | 92 → 92 |
| `g3_class_own_assoc_control` | **NEGATIVE CONTROL 1**: the class's OWN `k3 own3 [string]`, no import | `index inst=<null>` | identical | identical | (no package listing) | PASS_CMP → PASS_CMP | **BYTE-IDENTICAL** |
| `g4_no_import_control` | **NEGATIVE CONTROL 2**: same packages, same class, NO import | (no class copy) | — | — | **IDENTICAL** | PASS_CMP → PASS_CMP | **BYTE-IDENTICAL** |

`g1` is the head in **20 lines of SystemVerilog**, package listings included.
`g5` proves the law is not read off `string_typespec`. `g6` says the two-level
spelling still produces one level of nesting, so the recursion is not exercised
there either (§2.1).

**EMPTY-PRODUCT HUNT.** `g2` and `g4` are the two cells that score nothing in the
moved column, and both are judged by something that costs: `g4` by whole-design
`PASS_CMP` **and** byte-identity of its dump on both binaries, `g2` by its
package listing being scored on both sides and by golden's own `elem` being
`<null>` — which is a measured fact, not an absence of output.

**PATH NORMALISATION.** The two control dumps are compared with the arm's own
workdir stripped from every `file:` field. Un-normalised they report dozens of
"changed" lines on a cell that did not move (sd6 §9.3's trap, avoided here by
construction).

**DETERMINISM.** `detcheck.sh` on `g1` with the delivered binary: 3 runs,
**1 distinct sha256**, 0 NO_OUTPUT.

---

## 6. THE MOVERS

### 6.1 Census-predict, made FIRST and from the ARTIFACT

`ct7pred` restores every database the PRISTINE sweeps produced and counts exactly
what the patch rewrites: a class-listing variable whose NAME some package also
lists (the import-copy signature), carrying a typespec at depth ≥ 1 with a
non-null `vpiInstance`. **Calibrated on the target state**: golden SeqDriver
scores **0**, pristine ours **5**, delivered ours **0**.

Run **before** any delivered database was compared:

| corpus | databases scanned | predicted movers |
|---|---|---|
| surelog | **953** | **5** |
| uhdm2rtlil | **1358** | **0** |

```
PREDICT ./default/Scoreboard-59431470    stamped=2  classes=336
PREDICT ./default/SeqDriver-32af76aa     stamped=5  classes=336
PREDICT ./default/SimpleUVM-1dc93a62     stamped=2  classes=332
PREDICT ./testflags/SeqDriver-32af76aa   stamped=5  classes=336
PREDICT ./testflags/SimpleUVM-1dc93a62   stamped=2  classes=332
```

**The byte verifier then found EXACTLY those five, name for name, and exactly
zero in uhdm2rtlil.** Re-running `ct7pred` over the 953 DELIVERED databases
scores **0 movers** — the same score golden gets.

### 6.2 The MOVER RULE — size delta on every mover

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 021 074 | 18 021 021 | **−53** |
| `testflags/SeqDriver` | 18 021 497 | 18 021 453 | **−44** |
| `default/Scoreboard` | 11 145 455 | 11 145 436 | **−19** |
| `default/SimpleUVM` | 11 141 095 | 11 141 083 | **−12** |
| `testflags/SimpleUVM` | 11 141 412 | 11 141 400 | **−12** |
| `default/BuildUVMPkg` (control) | 11 105 247 | 11 105 247 | **0, byte-identical** |
| `testflags/BuildUVMPkg` (control) | 11 105 247 | 11 105 247 | **0, byte-identical** |

All five nonzero: **REAL movers** by the standing law. `BuildUVMPkg` was
predicted to score zero and is byte-identical.

### 6.3 Per-shape movers by MULTISET, ADDED and REMOVED separately

`ct7shape.py`, `sed 1d` on both dumps:

| design | shape | ADDED | REMOVED |
|---|---|---|---|
| `SeqDriver` | `vpiInstance` | 0 | **5** |
| | `package` | 0 | **5** |
| | **every other shape** | **0** | **0** |
| `SimpleUVM` | `vpiInstance` / `package` | 0 / 0 | **2 / 2** |
| `Scoreboard` | `vpiInstance` / `package` | 0 / 0 | **2 / 2** |

That is the transcription and nothing else: on SeqDriver, five `|vpiInstance:`
labels and their five `\_package:` back-reference lines gone, **no other shape
moves at all** (130 shapes unchanged).

### 6.4 THE COST, STATED PLAINLY: the byte measures go the WRONG WAY

| design | msdist to golden pris → new | positional `diff -u` content pris → new |
|---|---|---|
| `SeqDriver` | 359 631 → **359 641** (+10) | 503 005 → **503 007** (+2) |
| `SimpleUVM` | 140 250 → **140 254** (+4) | — |
| `Scoreboard` | 130 534 → **130 538** (+4) | — |

**This pass makes the multiset distance WORSE, and that is reported rather than
buried.** The mechanism is sd6 R5's, in the direction that hurts: the multiset
key is the exact line text, `        |vpiInstance:` occurs thousands of times,
and golden runs **3735 lines long** on that shape whole-design (R7, the `TOP:`
view instance deficit). Deleting five of ours therefore *increases* the
golden-only surplus by five, no matter where they were.

The authority is the object-level census, and it is unambiguous: at the five
positions in question golden's `vpiInstance` is **null**, ours **was** the
package and now is null, and the depth-keyed census equals golden exactly on all
three designs (§3.1). The removed lines are visible one by one in our own dump:

```
--- ours PRISTINE                        --- ours DELIVERED
\_string_typespec: , line:328:44         \_string_typespec: , line:328:44
  |vpiParent:                              |vpiParent:
  \_ref_typespec: (adpcm_pkg::…)           \_ref_typespec: (adpcm_pkg::…)
  |vpiInstance:                          \_class_typespec: (uvm_seed_map)…
  \_package: uvm_pkg (uvm_pkg::)…
```

Per PLAYBOOK's priorities this is a **priority-2 cmp-advance** bought for ten
dump lines on a shape we are 3735 short of golden on anyway.

### 6.5 The seven live UVM rows

| row | pristine | delivered | head |
|---|---|---|---|
| **`default/SeqDriver`** | **1 422 659** | **1 422 659** | ADVANCED: `m_visited` **1650 → 1653**; the printed cmp is byte-identical because the RHS is the same `package(uvm_pkg)` object and the head IS its subtree dump (§6.6) |
| **`testflags/SeqDriver`** | **1 422 659** | **1 422 659** | same shape |
| `default/SimpleUVM` | 17 | 17 | head UNMOVED (`logic_net(SEQ_TYPE_LOCK)@664:54`, visited 8864 both); bytes moved |
| `testflags/SimpleUVM` | 17 | 17 | same |
| `default/Scoreboard` | 26 | 26 | head UNMOVED (`ref_obj(status)@664:87` vs `method_func_call`, visited 8871 both); bytes moved |
| `default/BuildUVMPkg` | 94 | 94 | database byte-identical |
| `testflags/BuildUVMPkg` | 94 | 94 | database byte-identical |

`testflags/Scoreboard` is `SLANG_REJECT` at baseline, produces no database, and
is counted as SKIP — never as agreement. Every head is `grep -c '^LHS:' == 1`.

### 6.6 "The cmp line count did not change" is not "the head did not move"

`SeqDriver`'s `cmp.log` is **byte-identical** before and after. That proves
nothing here and saying otherwise would have been the pass's biggest available
error: `uhdm-cmp` prints `LHS:` and `RHS:` and then the RHS object's **subtree
dump**, and the RHS is the same `package(uvm_pkg)` object in both cases, so any
head anywhere whose RHS is that package prints the same 1 422 659 lines.

The position is measured directly instead, with `ct7mut`'s baseline read:

```
PRISTINE   r=-1  failedLhs=<null>  failedRhs=package(uvm_pkg)  visited=1650
                 candidate pool (our objects stamped with that package) = 5934
DELIVERED  r=-1  failedLhs=<null>  failedRhs=package(uvm_pkg)  visited=1653
                 candidate pool                                        = 5929
```

**+3 objects compared before the first failure, and exactly −5 stamped objects.**

---

## 7. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex | both worktrees `BASE f0d93e1` grep-checked **=1**; both ` error:` count **0**; both `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`f46ccffff0fa29f838a5701882a685ba`**, pristine **`2ecf28a8494750468a6edcd435b8f874`** — 32 hex each, different. Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679/50/2**, testflags **679/50/2**; dump testflags **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (filtered to testflags first — the 731-row trap) → **0 differing ROWS (0 row-sides)**, `PASS` |
| **4 surelog** | both j2 469/11 + 465/8, DEFER 5/5, histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 24 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 NO_UHDM). All four dump histograms **identical** to the committed baseline (default 225/244/325, testflags 165/300/329). `ct8rows` vs committed `results/golden_surelog.csv` → **1 differing ROW**, `Google,testflags`, `TIMEOUT` → `SURELOG_FAIL` — see §7.1 |
| **5 BYTE VERIFIER** | both corpora both modes vs PRISTINE built here, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | u2r **0 / 1358** movers, surelog **5 / 953**; `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **6** — arithmetic consistent (1 corruption + 0 real; 1 corruption + 5 real). The 5 are **exactly the predicted set** (§6.1), all with nonzero SIZE-DELTA (§6.2), per-shape movers are the transcription and nothing else (§6.3) |

The brief pins gate 4's `SURELOG_FAIL` at 25/23; this pass measures **25/24**,
and so does the PRISTINE sweep of the same corpus with the same timeout. It is a
golden-side count, identical on both binaries, and it is reported as measured
rather than as briefed.

### 7.1 The one moved row, and why it is not this patch

`Google,testflags` reads `TIMEOUT` in the committed baseline and `SURELOG_FAIL`
in this pass's sweeps. It is a **GOLDEN-SIDE** (Surelog) outcome and it is
**identical in the PRISTINE sweep and the DELIVERED sweep**. The decisive control
is the binary-to-binary one:

```
ct8rows.sh <pristine surelog csv> <delivered surelog csv>   -> 0 differing ROWS
ct8rows.sh <pristine u2r csv>     <delivered u2r csv>       -> 0 differing ROWS
```

**Zero rows move between the two binaries on either corpus.** sd6 reported the
same row for the same reason; it is reported here rather than summarised away.

### 7.2 CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** (documented u2r-only names) — vs the committed baseline **and** vs this pass's pristine run, both |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0**, unknown-names **25** (documented) |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS** |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` (the sd4 F6-fixed one) | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` — all four **not dispatched by any driver** (`canaudit.sh`) |
| `InterfaceModPort`, `BlackParrotComplex` **by name** | at baseline | both **CMP_EQUAL, cmp rc=0, 0 heads, in BOTH modes**, on both binaries |

`GOLDEN_DEFER` printed **`[UNSET]`** before every sweep. All sweeps `--jobs 2`
with private `--out`/`--workdir`. **`SLANG_UHDM` pin verified by reading
`cmds.txt` exhaustively**: surelog 1573 files per tree, 1523 carry a `slang:`
line and **all 1523 name exactly the right binary, 0 name any other**; u2r 1462
files, 1458 with a `slang:` line, same result. `results/*.csv` READ ONLY
(`git status --porcelain -- results` = 0 lines). No `git stash`. slang not
patched.

### 7.3 BOUNDARIES — every one MEASURED, none assumed

* **`§ classHomedTypeTsNoPkgInstance4`** (sd4, `TaskFuncEmit` 1155/1345). Its
  **q-grid is re-run on BOTH binaries and is `diff`-IDENTICAL**, cell for cell
  and content-count for content-count: `q1 26`, `q2 4`, `q3 26`, `q4 36`,
  `q5 6`, `q6 2`, `q7 16`, `q8 2`, `q9 56`, `q10 42`, `q11 70`, `qv12 86`,
  `qv13 56` — the same numbers sd4 recorded. Its wall, `BuildUVMPkg`, is
  **byte-identical** between the two binaries in both modes.
* **`§ importedClassVarIsOwnCopyNoInstance5`** (sd5). `ct5cls`'s 30-row summary
  is `diff`-EMPTY between the pristine and the delivered SeqDriver database,
  `X own named INST 63` included — the row a blanket null would have destroyed.
* **`§ importCopyInitRefIsOwnedAndUnbound6`** (sd6). `ct6clsref` on the delivered
  database is `diff`-identical to the PRISTINE one **and** to GOLDEN, line for
  line. sd6's **grid6 `g1`–`g6` is `diff`-IDENTICAL on both binaries**.
* **`§ retNameLocalInstIsHomeNotClass3`** (sd3) — the brief's stated sibling
  hypothesis. **Measured and REFUTED as this head's cause** (§4): every
  function-body local of `uvm_report_*`, 36 rows per side, all `<null>`,
  `diff`-identical. sd3's law is untouched because this patch never reaches a
  subroutine.
* **sd2's unsound-bisection laws** hold: the head was localized by reading
  `SafeCompare`'s branches and by a 154-relation reference sweep, never by
  suppression alone — and §4 records the two suppression-derived answers that
  were wrong.
* **live passes.** `r10uvm76` is ExprEmit — **no file overlap**. **`r10earl47`
  (ParamEmit/ModuleEmit gen) OVERLAPS THIS PATCH'S ONLY FILE, `src/ModuleEmit.cpp`
  — COLLISION REPORTED.** This pass's change is confined to `importVarCopy5` and
  one new file-static immediately above it (the class-import copier, `~4144`–
  `~4400`); `r10earl47`'s is generate-block work. The overlap is textual, not
  semantic, but the integrator must merge, not cherry-pick blindly.

---

## 8. RESIDUES, RANKED

1. **R1 — SeqDriver's next head, one link over: `class_typespec(uvm_seed_map)`.**
   `LHS:<null>` / `RHS: package(uvm_pkg)`, `m_visited` 1653. `ct4scan` on the
   DELIVERED database returns 24 singleton killers (was 21) and the new one is
   **`class_typespec(uvm_seed_map)@328:1-328:13`**, the ELEMENT type of the same
   associative array — reached not through the array's `Elem_typespec` (which is
   `<null>` on both sides) but from the package's own `Typespecs` listing.
   `ct7cand` already lists it as a candidate with `ALL:uvm_pkg` where golden is
   null. Cheapest live item on these two rows and a ready-made next pass.
2. **R2 — the 25-key candidate set `ct7cand` returns is unconsumed.** All 25 are
   `class_typespec`/`string_typespec` keys where golden's `vpiInstance` is null on
   every copy and at least one of ours is not, all in the `ALL:` (def) view.
   `uvm_seed_map` (R1) is one of them; the other 24 are a queue.
3. **R3 — the `Elem_typespec` and `packed_array_typespec` arms are unexercised**
   (§2.1). Zero `ts/elem` rows exist in either corpus, so they are carried on the
   pointer-identity guard and the byte verifier alone. Either find a cell that
   exercises them or cut them.
4. **R4 — `Typedef_alias` is not walked.** 29 `d1 ts/alias` + 3 `d2
   ts/index/alias` rows exist and the two sides already agree on all 32, so the
   link is out of scope by measurement — but the law says "the subtree" and the
   code says "index/elem". If a future corpus disagrees there, the law is the
   thing that was right.
5. **R5 — the byte measures regress by 10 lines on SeqDriver** (§6.4), and the
   multiset instrument cannot tell a correctly-deleted line from a missing one on
   a shape golden runs 3735 long. Any pass quoting a small per-shape delta must
   pair it with an object-level census; this one does.
6. **R6 — gdb's live `bt` mis-symbolises `libuhdm` frames in this build** (§4a).
   `ct4bt`/`ct7bt` remain the right method for learning the ARM; their FRAME NAMES
   must be cross-checked with `info symbol` before anything is built on them.
   sd4's recorded frame list should be re-checked the same way.
7. **R7 — the `TOP:`-view instance deficit** (sd2 R3 / sd3 R3 / sd4 R3 / sd5 R7 /
   sd6 R7): golden 13 184 instanced objects on SeqDriver to our 9 892, with
   `enum_typespec TOP:uvm_pkg` 390 vs 12 and `struct_typespec TOP:uvm_pkg` 90 vs
   2 the two widest cells (`ct7inst`). Untouched, and it is what makes §6.4's
   arithmetic point the wrong way.
8. **R8 — `ct7mut` under-counts movers by construction.** It judges "the head
   moved" by `m_failedRhs` changing POINTER, and on these designs many different
   failures report the same `package(uvm_pkg)`. It found 15 movers, all
   `INTRODUCED` (r=1); the object this pass fixed was in its pool and was NOT
   reported. Judge by `(r, failedLhs, failedRhs, visited)` as a tuple, not by the
   RHS pointer.

---

## 9. REFUTATIONS, STATED PLAINLY

1. **The brief's stated hypothesis is REFUTED.** "This head is sd3's
   return-name-local law extended to the `cs`/`l` statement-locals of the
   `uvm_report_*` wrappers" — `ct7loc` censuses exactly that population on both
   sides and finds **36 rows each, every one `inst=<null>`, `diff`-identical**.
   The statement-local's typespec carries no instance on either side. The killer
   at `uvm_globals.svh:199` is an ANCESTOR on the compare path, not the owner.
2. **"The deepest singleton killer names the owner."** REFUTED again, in a new
   way: sd4 R6 killed it with a class whose `Compare` cannot issue the arm; here
   it is a `class_typespec` that CAN carry an instance, does not, and is simply
   the first hop of the path that reaches the failure. A killer is an ancestor.
3. **"`LHS:<null>` / `RHS: package` means a `vpiInstance` slot."** True, but only
   after `m_failedLhs` is read: `SafeCompare`'s VECTOR overload writes
   `m_failedRhs = rhs_obj` (the OWNER) too. `ct7vec` closed that branch by
   measurement — all 25 vectors of `uvm_pkg` in both views agree in size on both
   sides — before the singular branch was pursued.
4. **"The cmp line count is unchanged, so nothing happened."** REFUTED by §6.6:
   the count is the RHS object's subtree dump, and the RHS is the same package
   for any head in that neighbourhood. `visited` 1650 → 1653 is the measurement
   that has content.
5. **"An associative array's index typespec carries no `vpiInstance`."** REFUTED
   by the package listings, four of them, both sides, view-matched (§3.2). This
   is the phrasing the head invites and it would have broken four correct cells.
6. **"Golden leaves nested class-listing typespecs unstamped."** Too broad:
   golden stamps **39** at depth 1 and we stamp the same 39 (§3.1). The law
   belongs to the import COPY, and grid `g3` is the control that separates them.
7. **A pointer-identity trap, hit and guarded**: nulling a nested typespec that
   `clone_tree` did NOT duplicate would destroy the package listing's stamp at
   the same time. `ct7mut` measures that backfire directly — 15 of our slots
   flip the whole-design compare from `r=-1` to `r=1` when nulled, because they
   are shared. The `cpTs == srcTs` guard is the whole safety argument, and it is
   there because that measurement exists.

### 9.4 Two ops traps in `ct4bt.gdb`, fixed in `ct7bt.gdb`

* **`break <symbol>` SKIPS THE PROLOGUE** when there is no DWARF, and gdb guesses
  where the prologue ends. By the breakpoint, `$rsi` — the `other` argument — can
  already be clobbered, so the RHS read back is silently wrong. Caught here
  printing a typespec whose `Instance` is NULL on both sides, which cannot be the
  object that stored a package. `break *<symbol>` breaks at the true entry.
* **The inferior is `kill`ed at the stop**, so anything the oracle `printf`s sits
  unflushed in its buffer and prints nothing — indistinguishable from "no output".
  `SHOWL`/`SHOWCHAIN`/`SHOWINST` `fflush(stdout)` on every call. `ct4bt.gdb` also
  printed its LABELS with gdb's own unbuffered `printf` while the values came from
  the buffered inferior, so every label landed before every value and no value
  could be attributed to the register it came from; `ct7bt` passes the label INTO
  the oracle so there is one stream.

---

## 10. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct7pop.cpp` | **THE POPULATION CENSUS THAT DECIDES.** Every typespec in the typespec SUBTREE of every class-listing variable, keyed by DEPTH and path, with its `vpiInstance` view. Depth 0 is printed as the control that must not move. Empty population = exit 5. |
| `ct7pkgsub.cpp` | **THE CELL THAT CHOSE THE PATCH.** The same subtree on the PACKAGE's own listing, all views, with pointers. This is what made the law the copy's rather than the array emitter's. |
| `ct7sub.cpp` | One named variable's whole typespec subtree with POINTERS, so object sharing is visible instead of inferred. |
| `ct7bt.cpp` `ct7bt.gdb` | sd4's watchpoint method with the stack SCRAPE replaced by labelled reads of the object's own `vpiParent` chain and `Instance()` slot, and the two gdb ops traps of §9.4 fixed. |
| `ct7mut.cpp` | Single-slot mutation over every object stamped with the head's own RHS pointer — typespec, variables **and** `task_func`, the pool taken from `ct4ref`'s sweep rather than from memory. Its under-count is R8. |
| `ct7cand.cpp` | The candidate join: every instance-bearing object keyed by (kind, name, span, parent chain), golden against ours, reporting the keys where golden is null and ours is not. Its unconsumed 25 rows are R2. |
| `ct7vec.cpp` | Every vector `package::Compare` walks, both views, both sides — the instrument that closed `SafeCompare`'s VECTOR branch by measurement. |
| `ct7loc.cpp` | **THE INSTRUMENT THAT REFUTED THE BRIEF.** Every function-body local of every package/class routine, with its typespec and that typespec's instance. |
| `ct7inst.cpp` | Whole-database singular-`vpiInstance` census by object KIND and instance VIEW (`ALL:`/`TOP:`). R7's numbers come from here. |
| `ct7ats.cpp` `ct7own.cpp` | The two censuses that came back "the sides agree" — kept because they are what REFUTES the mis-symbolised frame (§4a), and `ct7own` is order-preserving so it also rules out a vector-order mismatch. |
| `ct7pred.cpp` | **Artifact-based** mover prediction, calibrated on golden (0) and on the delivered database (0). Predicted 5 and 0; observed 5 and 0. |
| `ct7grid.sh` `ct7arm.sh` `grid7/g1…g6.sv` | the six cells of §5, both negative controls included, each scored on BOTH the class and the package listing. |
| `qgrid4/q*.sv` | sd4's q-grid, carried in so the § classHomedTypeTsNoPkgInstance4 boundary is re-RUN here rather than cited. |
| `ct4scan.cpp` `ct4ref.cpp` `ct4key.cpp` `ct4law.cpp` `ct4reach.cpp` `ct5cls.cpp` `ct5deep.cpp` `ct6clsref.cpp` `ct6mask.cpp` `ct6pkgv.cpp` `ct6ref.cpp` `ct6grid.sh` `grid6/` | sd4/sd5/sd6's kit, carried forward unchanged and RE-RUN as the boundary checks of §7.3. |
| `byteverify.sh` `msdist.sh` `ct7shape.py` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `TAP.md` | carried forward from `r10sd2repro`…`r10sd6repro` unchanged. |

---

## 11. THE PATCH

`/tmp/r10sd7.patch` — `git diff` vs `f0d93e1`, `src/` + `tools/probe/r10sd7repro`
only. Reproducible with:

```sh
cd /tmp/wt_r10sd7 && git add -A tools/probe/r10sd7repro
git diff f0d93e1 --binary -- include src tools/probe/r10sd7repro > /tmp/r10sd7.patch
md5sum /tmp/r10sd7.patch
```

md5 is delivered with the pass's final report and NOT written here: this file is
inside the patch, so any md5 recorded here is stale the moment it is written
(`r10sd3` §10's rule, kept).
