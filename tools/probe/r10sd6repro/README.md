# r10sd6 — the 43-line SeqDriver head, CLEARED: § importCopyInitRefIsOwnedAndUnbound6

**The head sd5 left behind is gone.** It was not what the brief modelled: the
brief's hypothesis — that golden omits `uvm_default_table_printer` from package
`uvm_pkg`'s `Variables` listing, or emits it without its `vpiExpr`, or orders the
vector differently — is **REFUTED by measurement in every one of its four
branches** (§3). The two vectors are the same size and agree entry for entry, in
both views. The failing slot was three levels away: the **class-listing COPY** of
a *different* package variable (`uvm_default_printer`) kept its initialiser
reference **bound to the package's object**, and golden leaves that reference
**unbound** and **re-named onto the copy's own owner chain**.

| | |
|---|---|
| BASE | `e07cb9c` (grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd6` (delivered), `/tmp/wt_r10sd6pris` (pristine control, `git status --porcelain` = 0) |
| delivered binary | md5 `032d68d611c8fc7154c7a367d1abe24d` |
| pristine binary | md5 `1831781597e37e8817f84e1e6d225dd4` |
| production files | `src/ModuleEmit.cpp` only (+77 −0, one file) |
| probe files | `tools/probe/r10sd6repro/` |

---

## 1. THE LAW

> **§ importCopyInitRefIsOwnedAndUnbound6** — the COPY that
> § importedClassVarIsOwnCopyNoInstance5 pushes into an importing CLASS owns its
> **initialiser's references** as well. Every `ref_obj`/`ref_var` in the copied
> initialiser is **re-named onto the copy's owner chain**
> (`<copy fullname>::<ref name>`) and is **left UNBOUND** — its `vpiActual` is
> null. Only the package's OWN listing keeps the binding.
>
> It holds **at depth**: a reference that is an OPERAND of the initialiser, not
> the initialiser itself, is treated identically (grid `g2`).

**What it is NOT:**

* not "a class listing's initialiser reference is unbound" — golden's class
  listings carry **52** such references on SeqDriver and **27 of ours already
  spell them correctly**, because those are the classes' OWN variables. The law
  belongs to the COPY, and grid `g3` is the control that says so.
* not "golden omits package class-handle variables with `new()` inits" — the
  brief's leading hypothesis. Golden lists all **33**, `uvm_default_table_printer`
  included, with its `vpiExpr -> method_func_call(new)` and `vpiAutomatic:1`
  (§3.1). § packageVarAutomaticIsDataDeclShape26 already measured that shape.

---

## 2. STATED GATE == CODE GATE

**STATED:** on the freshly cloned copy — and only there — walk the copy's `Expr`
subtree; for every `ref_obj`/`ref_var` found, set `VpiFullName` to
`<copy fullname>::<ref name>` and set `Actual_group` to null. Nothing else
changes: the package's own listing, the binding `bindListingInitRefs47` made on
it, the parameter/param_assign/typedef/task_func arms of the same function, and
every non-reference node in the initialiser are untouched.

**CODE** (`src/ModuleEmit.cpp`, one new file-static + one call at the end of
`importVarCopy5`):

```cpp
static void importCopyRefs6(UHDM::any* e, const std::string& owner, int depth) {
    if (!e || depth > 12) return;
    if (auto* ro6 = any_cast<UHDM::ref_obj*>(e)) {
        if (!ro6->VpiName().empty())
            ro6->VpiFullName(owner + "::" + std::string(ro6->VpiName()));
        ro6->Actual_group(nullptr);
        return;
    }
    if (auto* rv6 = any_cast<UHDM::ref_var*>(e)) { /* same, via ref_var's own type */ }
    switch (e->UhdmType()) {           // operation / bit_select / part_select
        ...
    }
    if (auto* tc6 = any_cast<UHDM::tf_call*>(e))   // and call arguments
        ...
}

// the ONE call site, at the tail of importVarCopy5
     if (auto* e5 = cp->Expr())
         e5->VpiParent(cp);
+    if (!fn.empty() && !nm.empty())
+        importCopyRefs6(cp->Expr(), fn + "::" + nm, 0);
     return cp;
```

`ref_obj` and `ref_var` are reached through **their own static types**: `ref_var`
is `final : public variables`, `ref_obj` is `: public simple_expr` — unrelated
hierarchies, and pass 47's type-punning defect is the record of what a C-style
cast between them writes.

**The rename is cmp-INERT and is included anyway, knowingly.**
`ref_obj::Compare` (`generated/src/ref_obj.cpp`:135-155) compares `VpiName`,
`VpiDefName`, `VpiGeneric`, `Actual_group`, `VpiStructMember` — **not
`VpiFullName`**. So the `Actual_group` null is what clears the head; the rename
is a dump/byte convergence item, measured at 50 lines on SeqDriver (§6.3) and
required by golden on **52 of 52** rows.

---

## 3. THE BRIEF'S HYPOTHESIS, REFUTED IN ALL FOUR BRANCHES

The brief's MEASUREMENT LAW was followed literally: census package `uvm_pkg`'s
`Variables` vector **by name, both sides, both views, FIRST** (`ct6pkgv`).

```
GOLDEN   ALL VARIABLES size=33      TOP VARIABLES size=33
OURS     ALL VARIABLES size=33      TOP VARIABLES size=33
diff <golden ALL rows> <ours ALL rows>   ->  EMPTY
diff <golden TOP rows> <ours TOP rows>   ->  EMPTY
```

Entry `[2]` on both sides, both views:

```
class_var  uvm_default_table_printer  @610:19-610:52  expr=method_func_call
           ts=class_typespec(uvm_table_printer)  auto=1 vis=1
```

* **"golden omits the ENTRY"** — false, it is there, at the same slot.
* **"golden emits it WITHOUT the vpiExpr(new)"** — false, `expr=method_func_call`
  on both sides.
* **"golden emits a different KIND"** — false, `class_var` on both sides.
* **"a missing EARLIER sibling shifts slots"** — false, 33 == 33 and every one of
  the 33 rows matches on kind, name, span, expr kind, typespec, `vpiAutomatic`
  and `vpiVisibility`.

`ct6ref` then read every initialiser REFERENCE in that listing (10 per view) and
found those identical too, `uvm_default_printer`'s binding included. **The
package listing is not the defect, in any respect this pass can measure.**

### 3.1 Where the slot actually is

`ct6path` walks a `sed 1d` dump and prints the ancestor PATH of every print of a
named object, **full prints and back-references counted separately** — because an
object is not a dump occurrence. On the `uvm_pkg::uvm_default_table_printer`
`class_var`: full prints **2 vs 2** (the two package views, in agreement), back
references **10 golden vs 13 ours**. The three extra, and two more found with the
same tool, are all of one shape:

```
package(uvm_pkg::) / vpiClassDefn->class_defn(uvm_pkg::uvm_component)
  / vpiDerivedClasses->class_defn(adpcm_pkg::adpcm_driver)
  / vpiVariables->class_var(adpcm_pkg::adpcm_driver::uvm_default_printer)
  / vpiExpr->ref_obj(uvm_pkg::uvm_default_printer::uvm_default_table_printer)
  / vpiActual->class_var(uvm_pkg::uvm_default_table_printer)     <- OURS ONLY
```

Golden's copy at the same path ends at the `ref_obj` — **no `vpiActual` line at
all** — and spells it
`adpcm_pkg::adpcm_driver::uvm_default_printer::uvm_default_table_printer`.

### 3.2 The population, not the cell

`ct6clsref` prints EVERY reference in EVERY class-listing entry's initialiser, on
both sides. SeqDriver `default`, 336 classes, 1206 listing entries, **52
references each side**:

| | GOLDEN | OURS pristine `e07cb9c` | OURS delivered |
|---|---|---|---|
| rows | 52 | 52 | 52 |
| `full == <class>::<var>::<refname>` | **52** | 27 | **52** |
| `full == uvm_pkg::<var>::<refname>` | **0** | **25** | **0** |
| `vpiActual` non-null | **0** | **5** | **0** |

`diff <golden ct6clsref> <delivered ct6clsref>` → **IDENTICAL, line for line**,
and the same holds on `SimpleUVM` (37 rows) and `Scoreboard` (38 rows), each of
which was 20 diff-sides away before.

The `27` row is what forbids the blanket phrasing: those are the classes' own
variables, which this arm never touches.

---

## 4. THE NEW HEAD IS THE NEXT ONE, NOT A NEW ONE — PROVEN, NOT ARGUED

SeqDriver's cmp goes **43 lines → 1 421 701**. The standing law says head SIZE is
the failing object's SUBTREE and not the size of the defect, but "it got bigger
because it advanced" is exactly the kind of claim that must be measured.

`ct6mask` measures it. Every generated `Compare` body opens with
`m_visited.insert(this)` keyed on the LHS, so a head can be SUPPRESSED by seeding
`m_visited` with its golden-side owner and the comparison then continues to
whatever would have been next:

```
== golden vs PRISTINE
BASELINE   r=-1  LHS=<null>  RHS=class_var(uvm_default_table_printer)@610:19-610:52
-- seed (golden class-listing initialiser refs) = 52 objects
SEEDED     r=-1  LHS=<null>  RHS=package(uvm_pkg)@28:1-39:11
== golden vs DELIVERED
BASELINE   r=-1  LHS=<null>  RHS=package(uvm_pkg)@28:1-39:11
```

**The head the delivered binary reports is bit-for-bit the head the PRISTINE
binary reports once this pass's 52 objects are masked.** It was already there,
behind the one this pass fixed. `ct4scan` (sd4's exhaustive `visited`-pool scan,
carried forward) names its neighbourhood: 21 singleton killers, the deepest being
`class_typespec@199:3-199:20` in `function(uvm_report_warning)`'s `begin` block —
a **statement-local** variable's typespec, i.e. the sd3/sd4 `vpiInstance` family
(R1), not this one.

Three further facts keep that from being a story:

* the whole-design **multiset distance to golden IMPROVES** on all three movers
  (§6.3) — a real regression cannot do that;
* `ct6clsref` on the delivered database **equals golden line for line** (§3.2), so
  the pair that used to fail now genuinely agrees rather than being skipped;
* `ct6pred`, the artifact predicate, scores the delivered SeqDriver **0/0** —
  exactly golden's score.

---

## 5. THE GRID — golden's rule, cell for cell

`grid6/g1…g6`, LHS always golden, `sed 1d` both dumps, private scratch per arm,
scored with `ct6clsref` (the class copy's initialiser ref: its fullname and its
`vpiActual`). Ours-dump comparisons are **path-normalised** — the dump embeds the
arm's workdir in every `file:` field, and an un-normalised comparison reports 86
"changed" lines on a control that did not move (caught here, §9.3).

| cell | shape | GOLDEN | OURS pris | OURS new | whole-design cmp | ours dump pris → new |
|---|---|---|---|---|---|---|
| **`g1_direct_ref`** | THE CORE CELL: `int b1 = a1;` in a wildcard-imported package | `full=q1::c1::b1::a1`, `actual=<null>` | `full=p1::b1::a1`, `actual=int_var(p1::a1)` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 6 lines (3 in / 3 out) |
| **`g6_class_handle_new`** | **THE TARGET'S OWN SHAPE**: `k6 tbl6 = new(); k6 dfl6 = tbl6;` | `full=q6::c6::dfl6::tbl6`, `actual=<null>` | `full=p6::dfl6::tbl6`, `actual=class_var(p6::tbl6)` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 6 lines |
| **`g2_nested_in_operation`** | DEPTH: `int b2 = a2 + 1;` — the ref is an OPERAND | `full=q2::c2::b2::a2`, `actual=<null>` | `full=p2::b2::a2`, `actual=int_var(p2::a2)` | CMP_FAIL → CMP_FAIL, **head byte-identical** | **== GOLDEN** | 6 lines |
| **`g5_explicit_import`** | `import p5::b5;` — the `only23` filter path | `full=q5::c5::b5::a5`, `actual=<null>` | `full=p5::b5::a5`, `actual=int_var(p5::a5)` | CMP_FAIL → CMP_FAIL, **head identical modulo the workdir path** | **== GOLDEN** | 6 lines |
| `g3_class_own_var_control` | **NEGATIVE CONTROL 1**: a class's OWN var initialised with a ref | `full=q3::c3::ref3::own3`, `actual=<null>` | identical | **identical** | PASS_CMP → PASS_CMP | **BYTE-IDENTICAL** |
| `g4_no_import_control` | **NEGATIVE CONTROL 2**: same packages and class, NO import | (scores empty both sides) | — | — | PASS_CMP → PASS_CMP | **BYTE-IDENTICAL** |

**Two cells flip to a full whole-design `PASS_CMP`** (`cmp.log` size 0), including
`g6`, which is literally uvm_pkg's `uvm_default_table_printer` /
`uvm_default_printer` pair in 14 lines. The two that do not flip reach golden **in
the scored cell** and keep a residual head that is a *different, pre-existing*
defect: `g2`'s is a `constant`+`vpiDecompile` inside the operation, `g5`'s is
`package q5` itself — each byte-identical between the two binaries.

**EMPTY-PRODUCT HUNT.** `g4` is the one cell that scores empty, on **both** sides;
it is judged by whole-design compare (PASS_CMP both binaries) and by
byte-identity of its dump, never by an "unchanged" that costs nothing. Every
other cell carries a scored row on both sides.

**DETERMINISM.** `detcheck.sh` on `g6` with the delivered binary: 3 runs,
**1 distinct sha256**, 0 NO_OUTPUT.

---

## 6. THE MOVERS

### 6.1 Census-predict, made FIRST and from the ARTIFACT

`ct6pred` restores every database the PRISTINE sweeps produced and counts exactly
what the patch rewrites (a class-listing initialiser reference whose fullname is
not already `<entry fullname>::<ref name>`, or whose `vpiActual` is non-null).
Run **before** any delivered mover was read:

| corpus | databases scanned | predicted movers |
|---|---|---|
| surelog | **953** | **5** |
| uhdm2rtlil | **1358** | **0** |

```
./default/Scoreboard-59431470    rename=10  unbind=2  entries=1103  classes=336
./default/SeqDriver-32af76aa     rename=25  unbind=5  entries=1206  classes=336
./default/SimpleUVM-1dc93a62     rename=10  unbind=2  entries=1094  classes=332
./testflags/SeqDriver-32af76aa   rename=25  unbind=5  entries=1206  classes=336
./testflags/SimpleUVM-1dc93a62   rename=10  unbind=2  entries=1094  classes=332
```

The predicate is calibrated on the target state itself: **golden scores 0/0** on
SeqDriver, and the delivered database scores 0/0 too. `BuildUVMPkg` scores zero
and correctly does not move.

**The byte verifier then found EXACTLY those five, name for name, and exactly
zero in uhdm2rtlil.**

### 6.2 The MOVER RULE — size delta on every mover

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 005 301 | 18 007 157 | **+1 856** |
| `testflags/SeqDriver` | 18 005 739 | 18 007 597 | **+1 858** |
| `default/Scoreboard` | 11 138 212 | 11 138 552 | **+340** |
| `default/SimpleUVM` | 11 133 572 | 11 133 857 | **+285** |
| `testflags/SimpleUVM` | 11 133 889 | 11 134 170 | **+281** |
| `default/BuildUVMPkg` (control) | 11 097 662 | 11 097 662 | **0, byte-identical** |
| `testflags/BuildUVMPkg` (control) | 11 097 662 | 11 097 662 | **0, byte-identical** |

All five nonzero: **REAL movers** by the standing law. (The bytes grow because
the copy's fullname is longer than the package's, not because objects were added
— §6.3's ADDED/REMOVED shows no new object kinds.)

### 6.3 Per-shape movers by MULTISET, ADDED and REMOVED separately

`ct6shape.py`, `default/SeqDriver`, `sed 1d` both dumps:

| shape | ADDED | REMOVED |
|---|---|---|
| `ref_obj` | 25 | 25 |
| `vpiFullName` | 25 | 25 |
| `vpiActual` | 0 | **5** |
| `class_var` | 0 | **5** |
| **TOTAL** | **50** | **60** |

That is the transcription and nothing else: 25 references re-spelled (in and out),
5 `|vpiActual:` labels and their 5 `class_var` back-reference lines gone. **No
other shape moves at all.**

Distance to golden, per shape:

```
ref_obj      17777 -> 17727   -50
vpiFullName  22883 -> 22833   -50
class_var     4087 -> 4082     -5
vpiActual     5025 -> 5028     +3      <- see the caveat below
shapes IMPROVED 3  WORSENED 1  unchanged 128
TOTAL        361257 -> 361155  (-102)
```

**The `vpiActual +3` is a multiset ARTIFACT, and it is named rather than
buried.** The multiset key is the exact line text; `        |vpiActual:` occurs
thousands of times at that indentation and the instrument cannot tell one
occurrence from another. Removing our 5 raises the golden-only surplus for that
key by 3. The **object-level** census is the authority and it is unambiguous:
golden has **0** non-null actuals in class listings, we now have **0** (§3.2).

| row | msdist pristine | msdist delivered |
|---|---|---|
| `SeqDriver` | 361 257 | **361 155** (−102) |
| `SimpleUVM` | 141 284 | **141 244** (−40) |
| `Scoreboard` | 131 518 | **131 478** (−40) |

**Every mover converges toward golden; none regresses.**

### 6.4 The seven live UVM rows

| row | pristine `e07cb9c` | delivered | head |
|---|---|---|---|
| **`default/SeqDriver`** | **43** | **1 421 701** | the 43-line pair now AGREES; the head shown is the next one, proven pre-existing (§4) |
| **`testflags/SeqDriver`** | **43** | **1 421 701** | same shape |
| `default/SimpleUVM` | 42 | 42 | head byte-identical, bytes and msdist moved |
| `testflags/SimpleUVM` | 42 | 42 | head byte-identical, bytes and msdist moved |
| `default/Scoreboard` | 42 | 42 | head byte-identical, bytes and msdist moved |
| `default/BuildUVMPkg` | 94 | 94 | database byte-identical |
| `testflags/BuildUVMPkg` | 94 | 94 | database byte-identical |

`testflags/Scoreboard` is `SLANG_REJECT` at baseline, produces no database, and is
counted as SKIP — never as agreement. Every head is `grep -c '^LHS:' == 1`.

---

## 7. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex baseline | both worktrees `BASE e07cb9c` grep-checked **=1**; both ` error:` count **0**; both `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`032d68d611c8fc7154c7a367d1abe24d`**, pristine **`1831781597e37e8817f84e1e6d225dd4`** — 32 hex each, different. Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679/50/2**, testflags **679/50/2**; dump testflags **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (filtered to testflags first — the 731-row trap) → **0 differing ROWS (0 row-sides)**, `PASS` |
| **4 surelog** | both j2 469/11 + 465/8 (FAIL 25/23, DEFER 5/5), histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 24 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 NO_UHDM). All four dump histograms **identical** to the committed baseline (default 225/244/325, testflags 165/300/329). `ct8rows` vs committed `results/golden_surelog.csv` → **1 differing ROW**, `Google,testflags`, `TIMEOUT` → `SURELOG_FAIL`, **identical on BOTH binaries** — see §7.1 |
| **5 BYTE VERIFIER** | both corpora both modes vs PRISTINE built here, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | u2r **0 / 1358** movers, surelog **5 / 953**; `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **6** — arithmetic consistent (1 corruption + 0 real; 1 corruption + 5 real). The 5 are **exactly the predicted set** (§6.1), all with nonzero SIZE-DELTA (§6.2), all converging (§6.3) |

### 7.1 The one moved row, and why it is not this patch

`Google,testflags` reads `TIMEOUT` in the committed baseline and `SURELOG_FAIL`
in this pass's sweeps. It is a **GOLDEN-SIDE** (Surelog) outcome, it is
**identical in the PRISTINE sweep and the DELIVERED sweep**
(`SURELOG_FAIL,[   NOTE] : 0` in both), and this pass ran with `--timeout 600`
where the baseline used a shorter one — which is precisely the difference between
those two classifications. The decisive control is the binary-to-binary one:

```
ct8rows.sh <pristine surelog csv> <delivered surelog csv>   -> 0 differing ROWS
ct8rows.sh <pristine u2r csv>     <delivered u2r csv>       -> 0 differing ROWS
```

**Zero rows move between the two binaries on either corpus.** The row is reported
here rather than summarised away, per the standing rule.

### CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** (documented u2r-only names) — vs the committed baseline AND vs this pass's pristine run, both |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0**, unknown-names **25** (documented) |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS** |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` (the sd4 F6-fixed one) | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` — all four **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex` **by name** | at baseline | both **CMP_EQUAL, cmp rc=0, 0 heads, in BOTH modes**, on both binaries |
| the four UVM names **by name** | at baseline | `SeqDriver`/`SimpleUVM`/`BuildUVMPkg` CMP_NOTEQUAL both modes; `Scoreboard` CMP_NOTEQUAL (default) / SLANG_REJECT (testflags) |

`GOLDEN_DEFER` printed **`[UNSET]`** before every sweep. All sweeps `--jobs 2`
with private `--out`/`--workdir`. **`SLANG_UHDM` pin verified by reading
`cmds.txt` exhaustively**: of 1573 + 1462 files per tree, every one that carries a
`slang:` line (1523 + 1458; the rest are SLANG_REJECT/SURELOG_FAIL and have none)
names **exactly the right binary**, and **zero** name any other. `results/*.csv`
READ ONLY (`git status --porcelain -- results` = 0 lines). No `git stash`. slang
not patched.

### BOUNDARIES

* **`§ importedClassVarIsOwnCopyNoInstance5`** (this patch's own function) — its
  census is **UNCHANGED, cell for cell**: `diff` of `ct5cls`'s 30-row summary
  between the pristine and the delivered SeqDriver database is **EMPTY**
  (`V=own 1206`, `span=NAME`, `X own named INST 63`, `E=own 315`, every
  `kind=…` row). Its **grid5 `v1`–`v6` all hold identically on both binaries**
  (`v1`/`v3`/`v5` PASS_CMP, `v2`/`v4`/`v6` CMP_FAIL with identical dump-content
  counts 38/319/48/108/36/146). The only golden-vs-ours difference left in that
  census is pass 5's own documented residue R2 (`inst=adpcm_pkg 49 / uvm_pkg 14`
  against golden's 42/21), untouched by this pass.
* **`§ declInitWrittenNewNoStmt66`** (StmtEmit, decl-init `new` suppression in
  STATEMENTS), **`§ ctorBodyLocalsNotOnFunc71`** (ctor variables),
  **`§ invalidNewCallFromSyntax55`** (new-call binds) — this patch never touches a
  `new` call, a statement, or a constructor body; `StmtEmit.cpp` and
  `TaskFuncEmit.cpp` are **not in this patch's file set**, and grid `g6` shows the
  package's `k6 tbl6 = new()` and its `method_func_call` unchanged on both sides.
* **`uvm73` R1-widened** (pkg/$unit/module VARIABLES with class-scoped-typedef
  types) — **MEASURED, not assumed**: the target's type `uvm_table_printer` is a
  plain class name, and the package listing census (§3) shows our 33 entries equal
  golden's 33 entry for entry, so this variable is not of that family and nothing
  in that family moved (its rows' databases are byte-identical unless they are one
  of the 5 named movers).
* **`bindListingInitRefs47`** — its binding is made on the PACKAGE's own listing
  and is **preserved**: `ct6ref` shows golden and ours agreeing on all 10 package
  initialiser references after the patch, `uvm_default_printer`'s
  `actual=class_var(uvm_default_table_printer) [OWN-PKG-VAR]` included.
* **live passes** `r10uvm74` (ExprEmit/StmtEmit) and `r10earl46`
  (ParamEmit/ExprEmit) — **no file overlap**; this patch is `src/ModuleEmit.cpp`
  only. **No collision to report.** `r10uvm74` **LANDED while this pass ran**
  (`bd4b122`, SimpleUVM 42 -> 17 x2, Scoreboard 42 -> 26); the patch was
  re-checked and **applies clean at `bd4b122`** as well as at this pass's BASE.
  Every number in this file is measured at BASE `e07cb9c`, as the brief pins it,
  so the SimpleUVM/Scoreboard head numbers in §6.4 are pre-`bd4b122` values —
  the MOVERS and the ct6clsref equality are properties of the class listings and
  are untouched by that pass's expression work.

---

## 8. RESIDUES, RANKED

1. **R1 — SeqDriver's next head: the statement-local `vpiInstance` family.**
   `LHS:<null>` / `RHS: package(uvm_pkg)`, proven pre-existing (§4). `ct4scan`'s
   `visited` pool gives 21 singleton killers; the deepest, with no killer below
   it, is `class_typespec@199:3-199:20` inside
   `function(uvm_report_warning)`'s `begin` block, owner `class_var(cs)@199:21`.
   This is sd3's `§ retNameLocalInstIsHomeNotClass3` / sd4's
   `§ classHomedTypeTsNoPkgInstance4` neighbourhood, one layer further in — the
   largest item left on these rows, and a ready-made next pass.
2. **R2 — pass 5's instance split, still 7 objects wide.** Class-listing
   typespecs: golden `adpcm_pkg 42 / uvm_pkg 21`, ours `49 / 14`. Total right,
   split wrong; pre-existing and unchanged here.
3. **R3 — `g2`'s residual head**: a `constant` with `vpiDecompile:1`/`vpiSize:32`
   inside the initialiser's `operation`, on a 14-line reproducer
   (`grid6/g2_nested_in_operation.sv`). Cheapest live cell in this directory.
4. **R4 — `g5`'s residual head**: `package q5` itself diverges on an explicit
   single-name import, independently of the class copy (whose scored cell now
   equals golden). 13-line reproducer in `grid6/`.
5. **R5 — the multiset instrument is position-blind** (§6.3). It is the right
   tool for "did anything else move", and the wrong tool for judging a change of
   ±5 lines on a shape that occurs thousands of times. Any pass quoting a small
   per-shape delta must pair it with an object-level census.
6. **R6 — `ct6clsref` does not cover the MODULE-container arm**, exactly as
   `ct5cls` does not (sd5 R5). A class declared in a module would score empty and
   read like agreement; grid `g4`'s empty score is handled by whole-design
   compare, but a future module-arm decode needs the walk extended first.
7. **R7 — the `TOP:`-view instance deficit** (sd2 R3 / sd3 R3 / sd4 R3 / sd5 R7):
   whole-design `vpiInstance` dump lines, golden 16 759 vs ours 13 024. Untouched
   by this pass — and R1 is almost certainly one of its cells.

---

## 9. REFUTATIONS, STATED PLAINLY

1. **The brief's hypothesis is REFUTED in all four of its branches** (§3). The
   package `uvm_pkg` Variables vector is 33 entries on both sides, in both views,
   agreeing on every field this pass can read — the entry is not omitted, not
   stripped of its `new()`, not a different kind, and not shifted by a missing
   sibling. Following the brief's own MEASUREMENT LAW (census the vector by name
   FIRST) is what refuted it, in the first ten minutes.
2. **"A `<null>` head on a `class_var` means we emit an extra variable."** No.
   Both sides emit it, at the same slot, with the same fields. The extra thing was
   a POINTER to it from a slot three levels away in a different class's listing.
   Head = subtree, and the named object is not necessarily the wrong one.
3. **"The head grew 33 000×, so the patch regressed."** REFUTED by `ct6mask`
   (§4): seeding the pristine comparison with this pass's 52 golden objects
   produces the delivered binary's head exactly. The size is the next failing
   object's SUBTREE — a whole `package uvm_pkg` — and says nothing about the
   defect's size, which is what sd4 §3.1's cost model already established in the
   other direction (a 1 416 140-line head that was one shared pointer).
4. **"The rename is part of what fixes the head."** It is not, and saying so
   would have been wrong: `ref_obj::Compare` never reads `VpiFullName`. The
   `Actual_group` null clears the head alone. The rename is included because
   golden requires it on 52 of 52 rows and it converges 50 dump lines — a byte
   item, declared as one.
5. **"Golden leaves class-listing initialiser references unbound."** Too broad:
   golden's 52 rows are all unbound, but 27 of them are the classes' OWN
   variables, which our emitter already gets right by a different path. Applying
   the null to class listings generally, instead of to the copy, would have been a
   rule with no measurement behind the other 27 and is exactly the shape of
   over-fire this campaign keeps paying for. Grid `g3` is the control that
   distinguishes them and it does not move.
6. **A path-normalisation trap, hit and fixed inside this pass** (§5): the first
   pristine-vs-delivered dump comparison of the two NEGATIVE CONTROLS reported 86
   and 92 changed lines. Every one of them was the arm's own workdir inside a
   `file:` field. Normalised, both controls are BYTE-IDENTICAL. An un-normalised
   control that "changed" would have been read as a blast-radius finding.

---

## 10. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct6pkgv.cpp` | **THE CENSUS THAT REFUTED THE BRIEF.** A named package's whole `Variables` vector, in order, in EVERY view, with kind/name/span/expr-kind/typespec/automatic/visibility per entry. Hard-errors on a package that matches nothing. |
| `ct6ref.cpp` | Every `ref_obj`/`ref_var` in a package listing's initialisers, with what its `vpiActual` points at and whether that is one of the package's own variables. Prints `noref` for an initialiser that reaches no reference, so silence is never inferred. |
| `ct6path.py` | Ancestor PATH of every print of a matching object in a `sed 1d` dump, FULL prints and BACK-REFERENCES counted separately (`BACKREFS=1`). This is what found the slot. |
| `ct6clsref.cpp` | **THE POPULATION CENSUS THAT DECIDES.** Every initialiser reference of every class-listing entry, both sides: class / var / ref name / ref fullname / actual. Empty population = exit 5. |
| `ct6mask.cpp` | **THE MASKING EXPERIMENT** (§4): seeds `m_visited` with this law's golden objects and re-runs the comparison, proving the new head is the next one and not a new one. Empty seed = exit 5. |
| `ct6pred.cpp` | **Artifact-based** mover prediction, calibrated on golden (0/0). Predicted 5 and 0; observed 5 and 0. |
| `ct6shape.py` | Per-shape movers by MULTISET, ADDED and REMOVED never summed, plus per-shape distance to golden before/after. |
| `ct6grid.sh` `ct6arm.sh` `grid6/g1…g6.sv` | the six cells of §5, including both negative controls. |
| `ct4scan.cpp` `ct2rels.inc` `ct4key.cpp` `ct4law.cpp` `ct4reach.cpp` `ct5cls.cpp` `ct5deep.cpp` | sd4/sd5's kit, carried forward unchanged; `ct4scan` located R1's neighbourhood and `ct5cls` re-measured pass 5's boundary. |
| `byteverify.sh` `msdist.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `TAP.md` | carried forward from `r10sd2repro`…`r10sd5repro` unchanged. |

---

## 11. THE PATCH

`/tmp/r10sd6.patch` — `git diff` vs `e07cb9c`, `src/` + `tools/probe/r10sd6repro`
only. Reproducible with:

```sh
cd /tmp/wt_r10sd6 && git add -A tools/probe/r10sd6repro
git diff e07cb9c --binary -- include src tools/probe/r10sd6repro > /tmp/r10sd6.patch
md5sum /tmp/r10sd6.patch
```

md5 is delivered with the pass's final report and NOT written here: this file is
inside the patch, so any md5 recorded here is stale the moment it is written
(`r10sd3` §10's rule, kept).
