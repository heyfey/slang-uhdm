# r10sd8 — the SeqDriver wall COLLAPSED: § importCopyElemVarTsNoInstance8

**`uhdm-cmp` on `SeqDriver` goes from 1 422 687 lines to 56, on BOTH rows.** The
head that has stood since sd2 — `LHS: <null>` / `RHS: package(uvm_pkg)` — is
gone, and `m_visited` goes **1653 → 1861** (default) and **1665 → 1873**
(testflags). Five objects moved on `SeqDriver`, two each on `SimpleUVM` and
`Scoreboard`, and nothing else moved anywhere in either corpus.

The law is one more link of sd5/sd7's import-copy family, and the link is one
that no instrument in this campaign had ever walked: an unpacked-array variable
owns an **ELEMENT VARIABLE**, the element variable owns a typespec, and that
typespec is the copy's too.

| | |
|---|---|
| BASE | `3a7a6a6` (grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd8` (delivered), `/tmp/wt_r10sd8pris` (pristine control, `git status --porcelain` = 0) |
| delivered binary | md5 `97462111685cc4e7a22ca1bf91cd0e5b` |
| pristine binary | md5 `3925b8fe80afa09d524f7d42ac0f468c` |
| production files | `src/ModuleEmit.cpp` only |
| probe files | `tools/probe/r10sd8repro/` |

---

## 1. THE LAW

> **§ importCopyElemVarTsNoInstance8** — the COPY that
> § importedClassVarIsOwnCopyNoInstance5 pushes into an importing CLASS owns its
> array variable's **ELEMENT VARIABLE** as well as its typespec, and the element
> variable's typespec is **UNSTAMPED** — but only while its `vpiInstance` still
> names the **SOURCE PACKAGE**. A stamp that already names the importing scope
> was written by the import machinery (§ pkgImportCloneLastWriter32) and **golden
> carries it too**.

sd7 §2.1 concluded that its `Elem_typespec` arm never fires because "zero
`ts/elem` rows exist on either side". That is **true and misleading**: an
associative array's element TYPE is not reached through
`array_typespec::Elem_typespec` in these databases at all. It is reached through
`array_var::Variables()` — the element variable — and `ct8pop` is the first
census in this campaign to walk there.

**What it is NOT:**

* not "an element variable's typespec carries no `vpiInstance`". Golden **stamps
  19** of the 140 element-variable typespecs in `SeqDriver`'s class listings, and
  ours agrees with it on the 8 that are key-matched. A blanket rule destroys
  those eight, and grid cell `g6` **caught exactly that over-fire in this pass's
  own first patch** (§5.1).
* not "the head is one of sd7 R2's 25 candidate keys". It is not. All 25 survive
  the fix unchanged, and every one of them is provably **cmp-inert** (§4.2).

---

## 2. STATED GATE == CODE GATE

**STATED:** inside `importVarCopy5`, on the freshly cloned copy and only there —
if BOTH the copy and its source are `array_var`, pair their `Variables()`
vectors POSITIONALLY, and only when the two vectors are the same size. For each
pair: skip it if the copy's element variable is pointer-identical to the
source's (SHARED — not the copy's to rewrite); take the copy's element
variable's `Typespec()->Actual_typespec()`; skip it if that is pointer-identical
to the source element's actual typespec (SHARED with the package listing); skip
it if its `vpiInstance` is null **or names anything other than the SOURCE
PACKAGE** (compared by NAME, because a package has two objects — the def view
and the elaborated one — and the clone can carry either); otherwise set
`vpiInstance` to null and hand it to sd7's `importCopyTsSub7` at depth 0 so the
levels below it get the same rule. Nothing else changes: no name, span, parent
or expression is touched, and the package listings are not reached at all.

**CODE** (`src/ModuleEmit.cpp`, one new file-static + one call inside
`importVarCopy5`, +63 lines, no line deleted):

```cpp
static void importCopyElem8(UHDM::variables* cp, UHDM::variables* src,
                            std::string_view srcPkgName) {
    if (!cp || !src || srcPkgName.empty()) return;
    if (cp->UhdmType() != UHDM::uhdmarray_var ||
        src->UhdmType() != UHDM::uhdmarray_var) return;
    auto* cvs = ((UHDM::array_var*)cp)->Variables();
    auto* svs = ((UHDM::array_var*)src)->Variables();
    if (!cvs || !svs || cvs->size() != svs->size()) return;
    for (size_t i = 0, n = cvs->size(); i < n; ++i) {
        UHDM::variables* ce = (*cvs)[i];
        UHDM::variables* se = (*svs)[i];
        if (!ce || !se || ce == se) continue;        // SHARED with the source
        auto* crt = ce->Typespec();  auto* srt = se->Typespec();
        if (!crt || !srt) continue;
        auto* cts = crt->Actual_typespec();
        auto* sts = srt->Actual_typespec();
        if (!cts || cts == sts) continue;            // SHARED: the listing's
        auto* in8 = cts->Instance();
        if (!in8 || in8->VpiName() != srcPkgName) continue;   // the g6 gate
        cts->Instance(nullptr);
        importCopyTsSub7(cts, sts, 0);
    }
}

// the ONE call site, in importVarCopy5, after § …7's typespec block
+    importCopyElem8(cp, src, srcPkgName);
// and the source package's name threaded in from the ONE caller
-  vars23->push_back(importVarCopy5(s, x23, cd));
+  vars23->push_back(importVarCopy5(s, x23, cd, pv23->VpiName()));
```

### 2.1 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | does it fire on the corpus? | what proves it |
|---|---|---|
| `cvs->size() != svs->size()` | never observed to reject | all 143 `array_var`s carry exactly one element variable on **both** sides (`ct8par`-style element census, §3.3) |
| `ce == se` (element var SHARED) | never observed to reject | if it did, the row would not appear in the 5 movers; the byte verifier finds exactly the 5 predicted |
| `cts == sts` (typespec SHARED) | never observed to reject | as above |
| **`in8->VpiName() != srcPkgName`** | **FIRES** | grid `g6`: without it the delivered database read `<null>` where golden reads `ALL:q6` (§5.1) |
| `importCopyTsSub7(cts, sts, 0)` recursion | never fires below depth 0 | the element typespecs reached are `class_typespec` / `int_typespec` / `struct_typespec`, none of which has an `Index_/Elem_typespec` arm; the byte verifier finds exactly the predicted objects and nothing else |

Three of the five guards are **carried but unexercised on these corpora**. They
are in the code because they are the faithful transcription of "the copy's own
objects", and they are named here because an unexercised guard that goes
unmentioned is how a stated gate stops being the code gate.

---

## 3. THE DECODE

### 3.1 The head, named EXHAUSTIVELY — `ct8head --brute`

sd7 R8 diagnosed why `ct7mut` under-counted (it judged movement by
`m_failedRhs`'s POINTER, and every failure in this neighbourhood reports the same
`package(uvm_pkg)`). This pass replaces the whole method rather than patch the
metric:

* `m_visited` holds **LHS (golden) objects only** — measured, not assumed:
  `ct8head` prints `visited: ours=0 golden=1653`.
* `design::Compare` bails at the first failure, so **only 1653 of 317 210
  objects are on the path at all**.
* Therefore nulling every stamped `vpiInstance` slot in our database one at a
  time is affordable: **13 464 whole-design compares in 3.4 seconds.**

```
BASELINE r=-1 visited=1653 failedLhs=<null> failedRhs=package(uvm_pkg)@28:1-39:11
ADVANCE  r=-3 visited=1861  ours=TOP:uvm_pkg
  class_typespec(uvm_seed_map)@328:1-328:13 < ref_typespec@0:0-0:0
    < class_var@328:14-328:42
    < array_var(uvm_random_seed_table_lookup)@328:14-328:42
    < class_defn(adpcm_seq_item)@18:1-73:25 < package(adpcm_pkg)@10:1-207:22
[S] BRUTE_PROBED=13464 ADVANCING=1 REGRESSING=34
```

**One object out of 13 464.** `uvm_misc.svh:328` is
`uvm_seed_map uvm_random_seed_table_lookup [string];` — the package associative
array sd7 already worked on. sd7 nulled its `[string]` INDEX typespec; the
`uvm_seed_map` ELEMENT typespec sitting next to it kept the package stamp.

### 3.2 THE ATTEMPTED BISECTION, AND WHY IT IS REFUTED — `ct8bis`

The cheap instrument was tried first and it **fails**, which is why the brute
force exists:

```
BASELINE          r=-1 visited=1653  failedRhs=package(uvm_pkg)
POOL_ALL_NULLED   r=1  visited=150   failedLhs=package(uvm_pkg)
[S] HEAD_NOT_IN_POOL  visited 1653 -> 150
```

Nulling all 10 304 slots that point at `uvm_pkg` moves the compare **backwards**,
because the pool is mostly CORRECT stamps. `|visited|` is **not monotone** in the
pool, so a set-bisection driven by it reports "the head is not here" on a pool
that contains it. `ct8bis` is kept in this directory precisely so the next pass
does not re-derive that.

### 3.3 The population, by PATH — `ct8pop`, both sides

`ct7pop` walks `ts`, `ts/index`, `ts/elem`, `ts/alias`. `ct8pop` adds `var/ts`
— the element variable's typespec — and that column is where the whole story is:

| path | GOLDEN | OURS pristine | OURS delivered |
|---|---|---|---|
| `d0 ts` `<null>` / SET | 1139 / **63** | 1139 / **63** | 1139 / **63** |
| `d1 ts/index` `<null>` / SET | 81 / 10 | 81 / 10 | 81 / 10 |
| `d1 ts/alias` SET | 29 | 29 | 29 |
| **`d1 var/ts` `<null>` / SET** | 121 / **19** | 123 / **17** | **128 / 12** |
| `d2 ts/index/alias` SET | 3 | 3 | 3 |

Joined row by row on (class full name + span, variable name, typespec
kind+name), the disagreement is **9 rows, all in one direction**:

```
OURS-STAMPED-ONLY (golden null)      5  d1 var/ts  class_typespec(uvm_seed_map)     TOP:uvm_pkg
                                     2  d1 var/ts  struct_typespec(m_verbosity_setting)      TOP:adpcm_pkg
                                     2  d1 var/ts  struct_typespec(uvm_cmdline_parsed_arg_t) TOP:adpcm_pkg
GOLD-STAMPED-ONLY (ours null)        0
```

The **5** are this pass's; the **4** are R1 (§8), a different mechanism, and
`ct8sim` shows them to be **cmp-inert** (nulling all 6 struct stamps leaves the
head at `visited=1653` exactly).

Element VARIABLES themselves already agreed exactly before this pass: **143
`array_var`s, all `Instance()` null, all element vars parented to their
`array_var`, all unnamed, same kind histogram (75 `class_var`, 27 `bit_var`,
17 `int_var`, 8 `string_var`, 6 `struct_var`, …) on both sides.** Only the
element variable's TYPESPEC's stamp differed.

### 3.4 The prediction, made from the ARTIFACT before the patch — `ct8sim`

```
TO_NULL=9   (golden stamps, ours agrees: 8)   (ours stamped, no golden twin: 0)
BASELINE  r=-1 visited=1653 failedLhs=<null>              failedRhs=package(uvm_pkg)
SIMULATED r=-3 visited=1861 failedLhs=class_var(access_record)@483:34
                                                          failedRhs=struct_var(access_record)@483:34
RESTORED  r=-1 visited=1653 …
```

and, restricted to the `class_typespec` shape alone (the shape a patch confined
to `importVarCopy5` can reach), **5 objects give the identical advance**, while
the 6 `struct_typespec` ones give **no movement at all**. The delivered binary
reproduces the simulated tuple exactly.

---

## 4. REFUTATIONS OF THE BRIEF, STATED PLAINLY

### 4.1 The CONVERSE family does not exist — `ct8cens`

The brief's stated hypothesis was that sd7 R2's 25 candidates and sd7 R7's
`TOP:`-view deficit (golden 390 `enum_typespec TOP:uvm_pkg` to our 12) are **one
decode with two firing directions**, and that the direction should be chosen
from the census. The census was built to answer exactly that — every one of the
**six** classes in the installed UHDM that declares `instance* Instance`
(`typespec`, `variables`, `task_func`, `ports`, `clocking_block`, `instance`;
`ct7cand` read two of the six), multiset-compared per key:

```
[S] SHARED_KEYS=21152 MATCH=17303 OURS_ONLY=25 GOLD_ONLY=0 VIEW_DIFF=3824
    OURS_NOTWIN_STAMPED=273  GOLD_NOTWIN_STAMPED=8182
```

**`GOLD_ONLY = 0`.** On every key the two sides share, there is not one object
golden stamps and we leave null. **The converse direction does not exist as a
stamp decision at all.** R7's deficit lives entirely in
`GOLD_NOTWIN_STAMPED = 8182` — golden objects whose key has NO counterpart of
ours — and those are a SPAN problem, not a stamp problem: our twins are there
and carry `@0:0-0:0` where golden carries a real span
(`class_typespec(uvm_typeid_base)@0:0-0:0` vs golden's `@110:3-110:18`, and 10
more like it in the element-variable cell alone). A pass aimed at "the converse
family" would have been aimed at nothing.

### 4.2 sd7 R2's 25 candidate keys are NOT the head — and are cmp-INERT

`ct8head --cand` takes every visited GOLDEN object whose own `vpiInstance` is
null, finds our twin by ct7cand's key, and PROBES it — nulls it and re-runs the
whole-design compare:

```
[S] CANDIDATES=32 ADVANCING=0
```

Thirty-two objects (the 8 distinct keys that are on the compare path × their 4
view copies), **none of which advances the walk**; several REGRESS, because
golden needs the stamp earlier. And after the fix the candidate set is
**still exactly 25** — unchanged — while the head has moved anyway.

The 25 are a **KEY-JOIN ARTIFACT**. Every one of them is PARENTLESS, so the key
carries no parent hops, and our parentless copy joins against a golden
parentless object that is not the one the compare pairs it with. The measured
proof that the key is the problem and not the data:

```
golden : 24 class_typespec NAMED PARENTED inst=TOP:uvm_pkg   <- class_var in TOPPKG:uvm_pkg
ours   : 24 class_typespec NAMED ORPHAN   inst=TOP:uvm_pkg   <- class_var in TOPPKG:uvm_pkg
         (…and the same 24 for ALL:uvm_pkg, TOP:adpcm_pkg, ALL:adpcm_pkg)
```

Same count, same stamp, same referrer, on both sides — **the only difference is
`VpiParent`**. `ct8own` (the reverse-edge census: every `ref_typespec`'s
`Actual_typespec` back to the object that uses the type) is what shows it, and
it re-ranks R2 as a PARENT residue rather than an instance residue (§8 R2).

### 4.3 "The head is reached from the PACKAGE's Typespecs listing"

The brief names R1 as `class_typespec(uvm_seed_map)@328:1-328:13` "reached from
the PACKAGE's Typespecs listing, ours `vpiInstance ALL:uvm_pkg`, golden NULL".
The span and the name are right and **the reach and the view are both wrong**:
the head is reached through `class_var < array_var < class_defn(adpcm_seq_item)
< package(adpcm_pkg)` — an IMPORT COPY inside a class — and its stamp is
`TOP:uvm_pkg`. The PACKAGE's own listing is untouched by this pass and equals
golden on all four views, which is what makes this the copy's law and not the
array emitter's (`ct7pkgsub`, §7.2).

---

## 5. THE GRID — golden's rule, cell for cell

`ct8grid.sh` over `grid8/g*.sv`; LHS is **always** golden; `sed 1d` on both
dumps; one scratch dir per arm; every cell scored on BOTH the CLASS listing
(`ct8pop`, the cell that must move) and the PACKAGE listing (`ct7pkgsub`, the
cell that must not).

| cell | shape | GOLDEN `d1 var/ts` | OURS pris | OURS new | cmp pris → new | dump content |
|---|---|---|---|---|---|---|
| **`g1_assoc_class_elem_import`** | **THE CORE CELL**: `k1 m1 [string]` in a wildcard-imported package | `inst=<null>` | `TOP:p1` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 133 → 131 |
| **`g2_assoc_int_elem_import`** | element type is built-in `int` — a different typespec CLASS | `inst=<null>` | `TOP:p2` | **== GOLDEN** | CMP_FAIL → CMP_FAIL | 135 → 133 |
| **`g3_dynarray_class_elem_import`** | `k3 m3 []` — the spelling sd7 scored on `Elem_typespec` and found empty | `inst=<null>` | `TOP:p3` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 92 → 90 |
| `g4_class_own_assoc_control` | **NEGATIVE CONTROL 1**: the class's OWN `k4 own4 [string]`, no import | `inst=<null>` | identical | identical | PASS_CMP → PASS_CMP | 28 → 28 |
| `g5_no_import_control` | **NEGATIVE CONTROL 2**: same packages, same class, NO import | (no class copy) | — | — | PASS_CMP → PASS_CMP | 68 → 68 |
| **`g6_typedef_elem_import`** | **THE DISCRIMINATOR**: element type is a package TYPEDEF | **`inst=ALL:q6`** | `ALL:q6` | **`ALL:q6` — HELD** | PASS_CMP → PASS_CMP | 167 → 167 |

`g1` is the head in 22 lines of SystemVerilog. `g2` proves the law is not read
off `class_typespec`. `g3` proves the dynamic-array spelling is the same law —
which is what sd7's "the elem arm never fires" hid.

**EMPTY-PRODUCT HUNT.** `g5` is the only cell that scores nothing in the moved
column, and it is judged by something that costs: whole-design `PASS_CMP` on
both binaries **and** an unchanged dump content count. `g4`'s class listing is
scored on both sides and its rows printed, so its "unchanged" is a measurement.

**DETERMINISM.** `detcheck.sh` on `g1` with the delivered binary: 3 runs, **1
distinct sha256**, 0 NO_OUTPUT.

### 5.1 THE OVER-FIRE THE GRID CAUGHT, FIXED BEFORE LANDING

The first version of this patch had no `srcPkgName` gate: it nulled every
element typespec `clone_tree` had duplicated. It passed every corpus gate —
identical sweep numbers, identical 5 movers, identical head advance — and it was
**WRONG**, and `g6` is the only thing in this pass that says so:

```
g6  GOLDEN  struct_typespec(p6::t6)@8:11-8:37  inst=ALL:q6
    OURS pristine                              inst=ALL:q6      <- agreed
    OURS first patch                           inst=<null>      <- OVER-FIRE
    OURS delivered                             inst=ALL:q6      <- held
```

When the element type is a package TYPEDEF, the import machinery has already
re-stamped the shared clone onto the IMPORTING package
(§ pkgImportCloneLastWriter32) and golden carries that stamp too. What golden
never carries is the stamp the clone merely INHERITED from the package it was
copied OUT of. Hence the gate in §2. The narrowing is **corpus-neutral** —
`SeqDriver` is byte-identical between the two patched binaries (18 021 249 both,
same head, same census) — so the corpus could not have found this. The grid did.

---

## 6. THE MOVERS

### 6.1 Census-predict, made FIRST and from the ARTIFACT — `ct8pred`

`ct8pred` restores a database and counts exactly what the code rewrites: a
class-listing `array_var` whose NAME some package also lists (sd5's import-copy
signature), whose ELEMENT VARIABLE's typespec carries a `vpiInstance` naming a
package other than the class's own home package. **Calibrated on the target
state before it was used**: golden `SeqDriver` **0**, ours pristine **5**, ours
delivered **0**.

Run over every database the PRISTINE sweeps produced, before any delivered
database was compared:

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

**The byte verifier found EXACTLY those five databases, name for name, and
exactly zero in uhdm2rtlil.** Re-running `ct8pred` over the 953 DELIVERED
databases scores **0** — golden's own score.

### 6.2 The MOVER RULE — size delta on every mover

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 021 287 | 18 021 249 | **−38** |
| `testflags/SeqDriver` | 18 021 718 | 18 021 667 | **−51** |
| `default/Scoreboard` | 11 145 436 | 11 145 422 | **−14** |
| `default/SimpleUVM` | 11 141 362 | 11 141 350 | **−12** |
| `testflags/SimpleUVM` | 11 141 682 | 11 141 670 | **−12** |
| `default/BuildUVMPkg` (control) | 11 105 247 | 11 105 247 | **0, byte-identical** |
| `testflags/BuildUVMPkg` (control) | 11 105 247 | 11 105 247 | **0, byte-identical** |

All five nonzero: **REAL movers** by the standing law. `testflags/Scoreboard` is
`SLANG_REJECT` at baseline, produces no database, and is a **SKIP** — never
agreement.

### 6.3 Per-shape movers by MULTISET, ADDED and REMOVED separately

`ct7shape.py`, `sed 1d` on all three dumps:

| design | shape | ADDED | REMOVED |
|---|---|---|---|
| `SeqDriver` | `vpiInstance` | 0 | **5** |
| | `package` | 0 | **5** |
| | **every other shape (130)** | **0** | **0** |
| `SimpleUVM` | `vpiInstance` / `package` | 0 / 0 | **2 / 2** |
| `Scoreboard` | `vpiInstance` / `package` | 0 / 0 | **2 / 2** |

That is the transcription and nothing else: the `|vpiInstance:` labels and their
`\_package:` back-reference lines, gone, at exactly the positions where golden
has none.

### 6.4 THE COST, STATED PLAINLY: the multiset distance goes the WRONG WAY

| design | msdist to golden pris → new |
|---|---|
| `SeqDriver` | 359 613 → **359 623** (+10) |
| `SimpleUVM` | 140 236 → **140 240** (+4) |
| `Scoreboard` | 130 538 → **130 542** (+4) |

sd7 §6.4's mechanism, unchanged: golden runs **3744 lines LONG** on
`|vpiInstance:` whole-design, so deleting five of ours increases the golden-only
surplus by five no matter where they were. The authority is the OBJECT census
(§3.3) and the compare itself (§6.5), and both are unambiguous. **This pass pairs
its byte measure with an object census precisely because the byte measure lies
here.**

### 6.5 The seven live UVM rows — head tuples on BOTH binaries

| row | pristine `(r, visited)` head | delivered `(r, visited)` head | cmp lines |
|---|---|---|---|
| **`default/SeqDriver`** | `r=-1 v=1653` `<null>` / `package(uvm_pkg)` | **`r=-3 v=1861`** `class_var(access_record)@483:34` / `struct_var(…)` | **1 422 687 → 56** |
| **`testflags/SeqDriver`** | `r=-1 v=1665` same shape | **`r=-3 v=1873`** same new shape | **1 422 687 → 56** |
| `default/SimpleUVM` | `r=-40 v=8869` `ref_obj(status)@664:87` / `method_func_call` | **identical** | 26 → 26 |
| `testflags/SimpleUVM` | same | **identical** | 26 → 26 |
| `default/Scoreboard` | `r=-40 v=8871` same shape | **identical** | 26 → 26 |
| `default/BuildUVMPkg` | `r=-3 v=1022` `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)` / `logic_typespec` | **identical**, database byte-identical | 94 → 94 |
| `testflags/BuildUVMPkg` | same | **identical**, byte-identical | 94 → 94 |

Every head is `grep -c '^LHS:' == 1`. `SimpleUVM` and `Scoreboard` move BYTES
without moving their head — the two objects each are past the head — and that is
reported rather than claimed as an advance.

---

## 7. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex | both worktrees `BASE 3a7a6a6` grep-checked **=1**; both ` error:` count **0**; both `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`97462111685cc4e7a22ca1bf91cd0e5b`**, pristine **`3925b8fe80afa09d524f7d42ac0f468c`** — 32 hex each, different. Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679/50/2**, testflags **679/50/2**; dump testflags **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (testflags-filtered first — the 731-row trap) → **0 differing ROWS (0 row-sides)**, `PASS`; pristine-vs-delivered CSV → **0 rows** |
| **4 surelog** | both j2 469/11 + 465/8, FAIL 25/23, DEFER 5/5, histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM). All four dump histograms **identical** to the committed baseline (default 225/244/325, testflags 165/300/329). `ct8rows` vs committed `results/golden_surelog.csv` → **0 differing ROWS** (sd6/sd7's `Google,testflags` drift did NOT recur); pristine-vs-delivered → **0 rows** |
| **5 BYTE VERIFIER** | both corpora both modes vs PRISTINE built here, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | u2r **0 / 1358** movers, surelog **5 / 953**; `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **6** — arithmetic consistent (1 corruption + 0 real; 1 corruption + 5 real). The 5 are **exactly the predicted set** (§6.1), all with nonzero SIZE-DELTA (§6.2); per-shape movers are the transcription and nothing else (§6.3) |

### 7.1 CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** (documented u2r-only names) — vs the committed baseline **and** vs this pass's pristine sweep, both |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0** vs committed (testflags-filtered), **ok=16** vs pristine (both modes), unknown-names **25** (documented) |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS** |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` (the sd4 F6-fixed one) | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` — all four **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex` **by name** | at baseline | both **CMP_EQUAL, cmp rc=0, 0 heads, in BOTH modes**, on **both** binaries |

`GOLDEN_DEFER` printed **`[UNSET]`** before every sweep. All sweeps `--jobs 2`
with private `--out`/`--workdir`. **`SLANG_UHDM` pin verified by reading
`cmds.txt` exhaustively**: surelog 1573 files per tree, 1523 carry a `slang:`
line and **all 1523 name exactly the right binary, 0 name any other**; u2r 1462
files, 1458 with a `slang:` line, same result — on all **four** trees.
`results/*.csv` READ ONLY (`git status --porcelain -- results` = 0 lines). No
`git stash`. slang not patched.

### 7.2 BOUNDARIES — every one RE-RUN, none cited

* **`§ classHomedTypeTsNoPkgInstance4`** (sd4, `TaskFuncEmit`). Its **q-grid is
  re-run on BOTH binaries and is `diff`-IDENTICAL**, all 13 cells, verdict and
  dump-content count: `q1 26, q2 4, q3 26, q4 36, q5 6, q6 2, q7 16, q8 2,
  q9 56, q10 42, q11 70, qv12 86, qv13 56`. Its wall, `BuildUVMPkg`, is
  **byte-identical** between the two binaries in both modes.
* **`§ importedClassVarIsOwnCopyNoInstance5`** (sd5). `ct5cls` is `diff`-EMPTY
  between the pristine and the delivered `SeqDriver` database.
* **`§ importCopyInitRefIsOwnedAndUnbound6`** (sd6). `ct6clsref` is `diff`-EMPTY
  between the two binaries, and **grid6's six cells are `diff`-IDENTICAL** on
  both.
* **`§ importCopyTsSubtreeNoInstance7`** (sd7). `ct7pop` — sd7's OWN census — is
  **`diff`-EMPTY** between the two binaries: the `ts/index` cell it owns does not
  move. sd7's **grid7 MOVES, and in sd7's own direction**: `g1` and `g2` go
  **CMP_FAIL → PASS_CMP** and every cell's dump content drops by exactly 2 lines.
  Scored on `g1`, golden / pristine / delivered all read `d1 ts/index inst=<null>`
  while `d1 var/ts` goes `TOP:p1` → `<null>` == golden, i.e. **the delivered
  database is now identical to golden on that cell's entire class listing.**
* **`§ retNameLocalInstIsHomeNotClass3`** (sd3). `ct7loc` — every function-body
  local of every package/class routine with its typespec's instance — is
  `diff`-EMPTY between the two binaries. This patch never reaches a subroutine.
* **THE PACKAGE LISTING**, which is what makes this the copy's law: `ct7pkgsub`
  on `uvm_random_seed_table_lookup` is identical between the two binaries modulo
  arena POINTERS, and **golden == delivered** on all four listings
  (`ALL`/`TOP` × `uvm_pkg`/`adpcm_pkg`) after stripping `ptr=`/`id=`.
* **live passes.** `r10uvm77` is `ExprEmit` — **no file overlap**.
  **`r10earl48` (ModuleEmit gen naming) OVERLAPS THIS PATCH'S ONLY FILE,
  `src/ModuleEmit.cpp` — COLLISION REPORTED.** This pass's change is two hunks:
  a new file-static immediately above `importVarCopy5` (~4383) plus one call
  inside it, and one argument added at `importVarCopy5`'s single call site
  (~4700, inside `classInheritsContainerImports23`). `r10earl48`'s is generate-block
  naming. The overlap is textual, not semantic, but the integrator must merge,
  not cherry-pick blindly.

---

## 8. RESIDUES, RANKED

1. **R1 — the 4 `struct_typespec` element stamps this pass deliberately did not
   take.** `uvm_component`'s `m_verbosity_settings` / `m_time_settings`
   (`m_verbosity_setting`) and `m_uvm_applied_cl_action` / `m_uvm_applied_cl_sev`
   (`uvm_cmdline_parsed_arg_t`) carry `TOP:adpcm_pkg` on `SeqDriver` (and
   `TOP:uvm_pkg` on `SimpleUVM`/`Scoreboard`) where golden is null. They do NOT
   come through `importVarCopy5` — they are the shared AGGREGATE import clone
   owned by the last importer (§ pkgImportCloneLastWriter32) — and `ct8sim`
   measures them **cmp-inert** (nulling all six leaves the head at `visited=1653`
   exactly). They are 4 of the 9 rows in §3.3 and the cheapest next object-level
   item, but they need the clone-ownership law, not this one. **Nulling them
   blind is a shared-object backfire risk (sd7 §9.7).**
2. **R2 — sd7 R2's 25 keys are a PARENT residue, not an instance residue.** §4.2:
   golden's package-scope class-variable declaration typespecs are **PARENTED**
   (24 per view × 4 views, `<- class_var in <PKG>`), ours are **ORPHANS** with the
   identical stamp and referrer. That is the real difference and it is a
   `VpiParent` defect in the package-scope data-declaration emitter, not a
   `vpiInstance` one. Every one of the 25 is cmp-inert today. Re-file as a
   parent-linkage item.
3. **R3 — `SeqDriver`'s new head: `class_var(access_record)` vs
   `struct_var(access_record)` @`uvm_resource.svh:483:34`,** inside
   `function(record_read_access)`'s `begin`, in `class_defn(uvm_resource_base)`.
   `r=-3`, a KIND mismatch: golden makes the local a `class_var`, we make it a
   `struct_var`. `visited` 1861/1873. It was already visible in `cmptool`'s
   `TopPkg[2]` line before this pass and is now the whole-design head. Cheapest
   live item on both `SeqDriver` rows and a ready-made next pass.
4. **R4 — the `@0:0-0:0` SPAN family is the real content of sd7 R7.** §4.1:
   `GOLD_NOTWIN_STAMPED=8182` and `GOLD_ONLY=0`. Golden's stamps we "lack" are
   overwhelmingly stamps on objects whose SPAN we leave at `0:0`, so the key
   join cannot pair them. Fixing spans there would convert a large block of
   `NO_TWIN` into `MATCH` at no instance-policy cost. This re-frames R7 from
   "3292 missing stamps" to "8182 mis-keyed objects", which is a different and
   more tractable pass.
5. **R5 — `SimpleUVM` / `Scoreboard` move bytes without moving their head**
   (§6.5). Their head, `ref_obj(status)` vs `method_func_call(status)` @664:87,
   is `r=-40` and untouched by anything in this family.
6. **R6 — the multiset instrument regresses by 10 / 4 / 4 lines** (§6.4) on a
   shape golden runs 3744 long. Unchanged from sd7 R5, and it will keep
   regressing for every correct deletion until the `TOP:`-view deficit closes.
   Any pass quoting a small per-shape delta must pair it with an object census.
7. **R7 — `|visited|` is NOT monotone under slot suppression** (§3.2), so the
   cheap set-bisection is unsound on this design. `ct8head --brute` costs 3.4
   seconds on 13 464 slots and is exact; use it. The reason it is affordable is
   that `Compare` bails early — a design whose head sits deep would need the
   bisection to be repaired, not the brute force to be scaled.
8. **R8 — three of `importCopyElem8`'s five guards are unexercised** (§2.1): the
   size-mismatch guard and both pointer-identity guards never reject on either
   corpus. They are carried on the byte verifier and on the grid alone. Either
   find a cell that exercises them or cut them.

---

## 9. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct8head.cpp` | **THE INSTRUMENT THAT NAMES THE HEAD.** `--dump` prints `m_visited` (and measures that it holds GOLDEN objects only); `--cand` probes the key-joined candidates; **`--brute` nulls every stamped `vpiInstance` slot in the database one at a time and re-runs the whole-design compare** — 13 464 probes in 3.4 s, judged by the tuple `(r, failedLhs, failedRhs, visited)`, baseline asserted restored at the end. |
| `ct8bis.cpp` | The set-bisection that DOES NOT WORK, kept because its refutation is the reason `--brute` exists (§3.2). |
| `ct8pop.cpp` | **THE POPULATION CENSUS THAT DECIDES.** sd7's `ct7pop` plus the `var/ts` path — the element variable's typespec subtree. Depth 0 printed as the control that must not move. Empty population = exit 5. |
| `ct8cens.cpp` | The TWO-DIRECTION instance census over all six `vpiInstance`-bearing classes, multiset per key, with NO_TWIN reported in both directions. This is what refutes the CONVERSE-family hypothesis (§4.1). |
| `ct8own.cpp` | **THE REVERSE-EDGE CENSUS.** Every `ref_typespec`'s `Actual_typespec` back to the object that uses the type, so a PARENTLESS typespec can still be attributed to its declaration scope. This is what re-ranked sd7 R2 as a parent residue (§4.2). |
| `ct8par.cpp` | Parentless-vs-parented typespec census by kind × named × instance view. |
| `ct8sim.cpp` | **ARTIFACT-BASED SIMULATION.** Nulls exactly the element stamps golden leaves null and re-runs the compare, so the patch has a predicted tuple to be judged against (§3.4). |
| `ct8pred.cpp` | **Artifact-based mover prediction**, calibrated on golden (0), pristine (5) and delivered (0). Predicted 5 and 0; observed 5 and 0. |
| `ct8grid.sh` `ct8arm.sh` `grid8/g1…g6.sv` | the six cells of §5, both negative controls and the `g6` discriminator that caught this pass's own over-fire. |
| `ct7pop.cpp` `ct7pkgsub.cpp` `ct7sub.cpp` `ct7cand.cpp` `ct7vec.cpp` `ct7loc.cpp` `ct7inst.cpp` `ct7mut.cpp` `ct7bt.cpp` `ct7bt.gdb` `ct7grid.sh` `grid7/` `grid7v/` | sd7's kit, carried forward unchanged and RE-RUN as the boundary checks of §7.2. |
| `ct4*.cpp` `ct5cls.cpp` `ct5deep.cpp` `ct6*.cpp` `ct6grid.sh` `grid6/` `qgrid4/` | sd4/sd5/sd6's kit, same treatment. |
| `byteverify.sh` `msdist.sh` `ct7shape.py` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `TAP.md` | carried forward from `r10sd2repro`…`r10sd7repro` unchanged. |

---

## 10. THE PATCH

`/tmp/r10sd8.patch` — `git diff` vs `3a7a6a6`, `src/` + `tools/probe/r10sd8repro`
only. Reproducible with:

```sh
cd /tmp/wt_r10sd8 && git add -A tools/probe/r10sd8repro
git diff 3a7a6a6 --binary -- include src tools/probe/r10sd8repro > /tmp/r10sd8.patch
md5sum /tmp/r10sd8.patch
```

md5 is delivered with the pass's final report and NOT written here: this file is
inside the patch, so any md5 recorded here is stale the moment it is written
(`r10sd3` §10's rule, kept).
