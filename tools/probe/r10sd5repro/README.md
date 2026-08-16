# r10sd5 — the SeqDriver WALL, CLEARED: § importedClassVarIsOwnCopyNoInstance5

**The SeqDriver wall is CLEARED — 1 416 183 cmp lines → 43, on BOTH rows — by
one CLONE at one push.** sd4's R1 named the site, the owner and the golden shape;
this pass verified that localization against the artifact, **read golden's clone
DEPTH one level at a time**, and closed it. Two designs sd4 did not predict —
`SimpleUVM` and `Scoreboard` — moved as well, and the artifact census named them
**before** the sweeps ran.

| | |
|---|---|
| BASE | `511725d` (grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd5` (delivered), `/tmp/wt_r10sd5pris` (pristine control, `git status` clean) |
| delivered binary | md5 `98e696e9785f4edd2a3a9da9e8ba55fa` |
| pristine binary | md5 `4535fc6e3d47177635c1278c4954bf20` |
| production files | `src/ModuleEmit.cpp` only (+85 −1) |
| probe files | `tools/probe/r10sd5repro/` |

Both binaries were **rebuilt from scratch by this pass** (`touch` on the source,
`-j 2`) and **both reproduced their md5 bit-for-bit**. That is stronger than the
gate asks for and it retires the usual doubt: every number below was measured on
a binary the delivered patch provably builds.

---

## 1. THE LAW

> **§ importedClassVarIsOwnCopyNoInstance5** — a package VARIABLE listed into an
> IMPORTING CLASS is **that class's OWN object**, never the package's. The copy
> carries the **NAME span**, its own `ref_typespec`, its own actual typespec and
> its own init expr; the package's own listing keeps the shared, package-stamped
> original.
>
> The clone stops at the actual typespec: **L0/L1/L2 are DISTINCT, L3 is
> SHARED** (a `class_typespec`'s `Class_defn` is a whole class and golden shares
> it, 117 of 117).

**What it is NOT** (both phrasings were tested and both are false — §6):

* not "a class-listing typespec has no instance" — golden stamps **63** of them
  and we stamp the **same 63**, per kind, cell for cell;
* not "shrink the span" — the span is the **NAME node's**, which coincides with
  the declarator span whenever the declaration has no initializer.

---

## 2. STATED GATE == CODE GATE

**STATED:** at the class-import VARIABLE push — and **only** there — push a
`clone_tree` COPY instead of the package's own object; re-parent it to the class,
re-name it `<class fullname>::<name>`, set the NAME span, and null the instance
on the copy's actual typespec. Nothing else changes: the parameter /
param_assign / typedef / task_func arms of the same function, the package's own
listing, and every other `Instance()` consumer are untouched.

**CODE** (`src/ModuleEmit.cpp`, one new file-static + one token at one call site):

```cpp
static UHDM::variables* importVarCopy5(UHDM::Serializer& s, UHDM::variables* src,
                                       UHDM::class_defn* cd) {
    if (!src || !cd) return src;
    UHDM::ElaboratorContext ctx5(&s, false, /*muteErrors=*/true);
    auto* cp = (UHDM::variables*)UHDM::clone_tree(src, &ctx5);
    if (!cp) return src;
    const std::string nm(src->VpiName()), fn(cd->VpiFullName());
    cp->VpiParent(cd);
    if (!fn.empty() && !nm.empty()) cp->VpiFullName(fn + "::" + nm);
    if (!nm.empty()) {                       // the NAME span
        cp->VpiEndLineNo(cp->VpiLineNo());
        cp->VpiEndColumnNo(cp->VpiColumnNo() + (uint32_t)nm.size());
    }
    if (auto* rt5 = cp->Typespec()) {
        rt5->VpiParent(cp);
        if (!fn.empty() && !nm.empty()) rt5->VpiFullName(fn + "::" + nm);
        if (auto* at5 = rt5->Actual_typespec()) at5->Instance(nullptr);
    }
    if (auto* e5 = cp->Expr()) e5->VpiParent(cp);
    return cp;
}

// the ONE call site — classInheritsContainerImports23's VARIABLE arm
 if (auto* v23 = pv23->Variables())
     for (auto* x23 : *v23)
         if (x23 && (!only23 || x23->VpiName() == on23))
-            vars23->push_back(x23);
+            vars23->push_back(importVarCopy5(s, x23, cd));
```

The `only23` guard is **inside** the arm and untouched, so the explicit-import
path (`import p::v`) takes the copy too — measured as grid cell `v4`, not assumed.

**`DeepClone` was NOT used** (`UhdmExporter.h`:490 — it recurses forever through
the self-referential `Typedef_alias`), and a hand-written per-kind shallow copy
was NOT used either: it would have had to enumerate every `variables` subtype
reaching this site, and every kind it missed would have failed **silently** by
falling back to the shared push. `clone_tree` stops exactly where golden stops,
and that was **measured** (§4.2), not assumed.

---

## 3. THE LOCALIZATION, VERIFIED BEFORE IT WAS BUILT ON

sd4's R1 was taken as a hypothesis and re-measured with `ct5cls`, which answers
every question by **POINTER IDENTITY** against the set of objects the four
package listings own — never by span key, because sharing is invisible to a key
census (sd4 §3.4).

`ct5cls`, SeqDriver `default`, **1206 class-listing variable entries on each
side**:

| cell | GOLDEN | OURS pristine `511725d` | OURS delivered |
|---|---|---|---|
| entries | 1206 | 1206 | 1206 |
| `V=own` | **1206** | 1041 | **1206** |
| `V=SHARED` | 0 | **165** | **0** |
| `span=NAME` | **1206** | 1126 | **1206** |
| `span=other` | 0 | 80 | **0** |
| `T=own` / `A=own` | 1202 / 1202 | 1040 / 1040 | 1205 / 1205 |
| `E=own` | **315** | 230 | **315** |
| **`X own named INST`** | **63** | **63** | **63** |
| `X SHARED anon INST` | — | 45 | **0** |
| `X SHARED named INST` | — | 115 | **0** |
| `X SHARED anon null` | — | 5 | **0** |

**The defect is confirmed exactly as sd4 stated it, and the `X own named INST 63`
row agreeing cell for cell BEFORE the patch is what forbids the tempting law.**
Golden stamps 63 class-listing typespecs with a package; so do we; a blanket null
would have destroyed all 63. The entire surplus (45 + 115 = 160 instanced, plus 5
null) is **SHARED**, and only the import arm makes a shared entry.

### 3.1 The whole census, golden vs delivered

30 census rows; **24 are EXACT**, including every `INST` row, `span=NAME 1206`,
`V=own 1206` and `E=own 315`:

```
kind=array_typespec/anon/null 143   ==   kind=bit_typespec/anon/null 164   ==
kind=bit_typespec/named/INST    8   ==   kind=class_typespec/named/INST 6  ==
kind=class_typespec/named/null 409  ==   kind=class_typespec/…/pkgTs/INST 12 ==
kind=enum_typespec/…/pkgTs/INST 29  ==   kind=int_typespec/anon/null 206   ==
kind=int_typespec/named/INST    5   ==   kind=int_typespec/named/null 12   ==
kind=logic_typespec/named/INST  2   ==   kind=string_typespec/anon/null 185 ==
kind=struct_typespec/…/pkgTs/INST 1 ==   kind=time_typespec/anon/null 11   ==   …
```

The 6 rows that still differ are **two residues, both pre-existing** (R2, R3).

---

## 4. DECODING GOLDEN'S CLONE — and the instrument that could not do it

### 4.1 The depth, read one level at a time

`ct5deep` pairs (package-listing entry, class-listing entry) by name and reports
SAME / DIFF per level. On **golden**:

| level | golden | count |
|---|---|---|
| `L0.var` | **DIFF** | 117 class_var + 30 string_var + 10 int_var + 5 bit_var |
| `L1.ref_typespec` | **DIFF** | all |
| `L1.expr` | **DIFF** | 55 (+2 one-null) |
| `L2.actual` | **DIFF** | all |
| **`L3.Class_defn`** | **SAME** | **117 / 117** |

So golden duplicates down to the actual typespec and **shares** below it. That
is exactly `clone_tree`'s split, and the delivered binary reproduces golden's
table **line for line**:

```
diff <golden ct5deep table> <delivered ct5deep table>   ->   IDENTICAL
```

### 4.2 …but that table is IDENTICAL ON THE PRISTINE BINARY TOO — REFUTATION

Run on pristine `511725d`, `ct5deep` prints the **same table**, `L0.var DIFF`
on all 167 pairs — while `ct5cls` proves 165 of those entries are SHARED. **The
instrument is blind to the defect it was written beside.** The cause is in its
pairing:

```cpp
for (auto* x : *p->Variables()) pkgVar.emplace(name, x);   // walkPkg(AllPackages)
                                                           // walkPkg(TopPackages)
```

`emplace` keeps the FIRST insertion and `AllPackages()` is walked first, so the
map holds the **ALL-view** copy — while our shared class entries share the
**TOP-view** copy (sd4's head was "our TOP-view copy"). `pv == x` is therefore
false for a genuinely shared entry, and it reports DIFF.

**This is sd4 §3.2's duplicate-view trap recurring in a brand-new instrument**,
and it must be recorded, because "golden and delivered agree" was true here for
a reason that has nothing to do with the fix. `ct5deep` is a valid DEPTH
instrument **only where sharing is already known to be zero** — which `ct5cls`
independently establishes for golden and for the delivered binary (`V=own 1206`
on both), and only then does §4.1 mean anything. `ct5cls` is immune because its
`collectPkg` builds a **set over all four package listings** and tests
membership, instead of picking one view's representative.

---

## 5. THE GRID — golden's rule, cell for cell

`grid5/v1…v6`, LHS always golden, `sed 1d` both dumps, private scratch per arm.
The scored cell is the class listing's entry, read with `ct5cls` (`V=` own or
SHARED, the `vpiInstance`, and the span form).

| cell | shape | GOLDEN | OURS pris | OURS new | whole-design cmp | ours dump pris → new (golden) |
|---|---|---|---|---|---|---|
| **`v1_wild_import_bit`** | THE CORE CELL: pkg var of an anon builtin type, wildcard-imported into a pkg declaring a class | `own 2`, `inst=<null> 2`, `NAME 2` | `SHARED 1`+`own 1`, `inst=p1 1`, `other 1` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 728 → **752** (760) |
| **`v3_no_initializer`** | the SPAN control: no init, so declarator span already IS the name span | `own 2`, `inst=<null> 2`, `NAME 2` | `SHARED 1`+`own 1`, `inst=p3 1` | **== GOLDEN** | **CMP_FAIL → PASS_CMP** | 704 → **722** (730) |
| **`v5_class_in_module`** | container is a MODULE, not a package | — (not scorable, §7 R5) | — | — | **CMP_FAIL → PASS_CMP** | 706 → **732** (738) |
| `v4_explicit_import` | `import p4::v4`, the `only23` filter path | `own 2`, `inst=<null> 2`, `NAME 2` | `SHARED 1`+`own 1`, `inst=p4 1`, `other 1` | **== GOLDEN** | CMP_FAIL → CMP_FAIL, **head byte-identical (1950 B)** | 736 → **762** (830) |
| `v2_named_pkg_typedef` | element type is a package-homed TYPEDEF | `own 2`, `inst=<null> 1` + `inst=p2 1`, `NAME 2` | `own 1` — **we emit a NET** | unchanged | CMP_FAIL → CMP_FAIL, head byte-identical (3578 B) | 736 → 736 (957) |
| **`v6_no_import_control`** | **NEGATIVE CONTROL**: same pkg var, same class, NO import | `own 1`, `inst=p6 1` | identical | **identical** | CMP_FAIL → CMP_FAIL, byte-identical | **707 → 707** (777) |

**Three cells flip from `CMP_FAIL` to a full whole-design `PASS_CMP`** — not a
smaller head, an empty one (`cmp.log` size 0). The three that do not are each
explained by measurement, not by assertion:

* **`v6` is the negative control and it holds.** After normalising the arm's own
  path out of the dump, its output is **byte-identical** before and after. The
  fix provably does nothing where nothing was imported.
* **`v4`'s scored cell reaches golden exactly**; its residual head is a
  *different, pre-existing* defect in package `q4`'s **own** listing, and that
  head is byte-identical between the two binaries.
* **`v2` cannot exercise the arm at all**: we emit the imported
  package-typedef'd variable as a `logic_net` in `q2`, not a variable, so it
  never reaches the Variables push. Golden emits it as
  `bit_var (q2::c2::v2)`. Its dump is byte-identical before/after — the arm
  never ran. **This cell also validated the naming rule**: golden's copy is
  `q2::c2::v2` = `<class fullname>::<name>`, exactly what the code writes, and
  its `ref_typespec` carries the same fullname.

**EMPTY PRODUCT HUNT — clean.** Every cell produced both a golden and an ours
database; every cell carries at least one class-listing entry on the thinner
side (`v5` excepted and scored by whole-design compare instead), so no
`unchanged` verdict is agreement that costs nothing.

---

## 6. THE MOVERS

### 6.1 Census-predict, made FIRST and from the ARTIFACT

`ct5pred` reads **every pristine database** in both corpora and counts
class-listing entries that are **pointer-identical** to a package-listed variable
— the defect itself, not a source-text proxy (sd4 F1: a source predicate cannot
see this). Run **before** the delivered sweeps:

| corpus | databases scanned | predicted movers |
|---|---|---|
| surelog | **953** | **5** — `default/{Scoreboard, SeqDriver, SimpleUVM}`, `testflags/{SeqDriver, SimpleUVM}` |
| uhdm2rtlil | **1358** | **0** |

```
./default/Scoreboard-59431470   shared=66   sharedInst=64   entries=1103  classes=336
./default/SeqDriver-32af76aa    shared=165  sharedInst=160  entries=1206  classes=336
./default/SimpleUVM-1dc93a62    shared=66   sharedInst=64   entries=1094  classes=332
./testflags/SeqDriver-32af76aa  shared=165  sharedInst=160  entries=1206  classes=336
./testflags/SimpleUVM-1dc93a62  shared=66   sharedInst=64   entries=1094  classes=332
```

**The byte verifier then found EXACTLY those five, name for name, and exactly
zero in uhdm2rtlil.** Predicted set == observed set, on both corpora.

`BuildUVMPkg` is **`shared=0`** and correctly does **not** move — its databases
are byte-identical (11 097 834 both). **sd4's R1 under-predicted: it named
SeqDriver only. The artifact census found the other two before the sweeps.**

### 6.2 The MOVER RULE — size delta on every mover

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 17 962 880 | 18 005 485 | **+42 605** |
| `testflags/SeqDriver` | 17 963 307 | 18 005 916 | **+42 609** |
| `default/Scoreboard` | 11 123 420 | 11 138 388 | **+14 968** |
| `default/SimpleUVM` | 11 119 038 | 11 133 735 | **+14 697** |
| `testflags/SimpleUVM` | 11 119 350 | 11 134 052 | **+14 702** |
| `default/BuildUVMPkg` (control) | 11 097 834 | 11 097 834 | **0** |

All five nonzero: **REAL movers** by the standing law. Every mover is also
size-stable ×3 reps on both binaries (`r10sd5_reps`: 17 962 880 ×3 pristine,
18 005 485 ×3 delivered).

### 6.3 Per-shape movers by MULTISET, ADDED and REMOVED separately

`msdist.sh`, `default/SeqDriver`, `sed 1d` both dumps. **Distance to GOLDEN:**

| | golden-only | ours-only | MULTISET DISTANCE |
|---|---|---|---|
| pristine `511725d` | 263 513 | 101 126 | **364 639** |
| delivered | 259 965 | 101 313 | **361 278** (**−3 361**) |

Per shape, delivered vs pristine — **ADD-dominant, as a clone must be**:

| shape | ADDED | REMOVED | | shape | ADDED | REMOVED |
|---|---|---|---|---|---|---|
| `vpiParent` | 610 | 0 | | `vpiTypespec` | 170 | 0 |
| `vpiFullName` | 370 | 0 | | `vpiVisibility` | 165 | 0 |
| `ref_typespec` | 350 | 0 | | `vpiAutomatic` | 120 | 0 |
| `vpiName` | 345 | 0 | | `vpiClassDefn` | 120 | 0 |
| `class_var` | 298 | 113 | | `string_var` | 75 | 30 |
| `class_defn` | 285 | 0 | | `vpiExpr` | 85 | 0 |
| `class_typespec` | 240 | 0 | | `string_typespec` | 70 | 0 |
| `vpiActual` | 180 | 0 | | **TOTAL** | **3 898** | **163** |

Per shape, **distance to golden**, delivered vs pristine:

```
shapes IMPROVED 39      shapes WORSENED 4      unchanged 162
biggest gains : vpiParent -610  class_var -375  vpiName -341  vpiFullName -290
                class_defn -285  class_typespec -222  vpiTypespec -170
worst losses  : ref_obj +25  ref_typespec +20  vpiOpType +1  array_typespec +1
TOTAL         : 364 639 -> 361 278   (-3 361)
```

**Every mover converges toward golden; none regresses:**

| row | msdist pristine | msdist delivered |
|---|---|---|
| `SeqDriver` | 364 639 | **361 278** (−3 361) |
| `SimpleUVM` | 142 411 | **141 293** (−1 118) |
| `Scoreboard` | 132 771 | **131 537** (−1 234) |

`SimpleUVM` and `Scoreboard` keep their heads **byte-identical** (50 lines) while
their bytes and their distance to golden both improve — they advance without
their head moving.

### 6.4 The seven live UVM rows

| row | pristine `511725d` | delivered | head |
|---|---|---|---|
| **`default/SeqDriver`** | **1 416 183** | **43** | was `<null>` / `package uvm_pkg`; now `<null>` / `class_var(uvm_pkg::uvm_default_table_printer)` |
| **`testflags/SeqDriver`** | **1 416 183** | **43** | same shape (ids differ only) |
| `default/BuildUVMPkg` | 94 | 94 | unchanged, databases byte-identical |
| `testflags/BuildUVMPkg` | 94 | 94 | unchanged, byte-identical |
| `default/SimpleUVM` | 50 | 50 | head byte-identical, bytes moved (§6.3) |
| `testflags/SimpleUVM` | 50 | 50 | head byte-identical, bytes moved |
| `default/Scoreboard` | 50 | 50 | head byte-identical, bytes moved |

`testflags/Scoreboard` is `SLANG_REJECT` at baseline, produces no database, and
is counted as SKIP — never as agreement. Every head is `grep -c '^LHS:' == 1`.

**The target row-pair fell by four orders of magnitude and nothing regressed.**

---

## 7. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex baseline | both worktrees `BASE 511725d…` grep-checked **=1**; both ` error:` count **0**; both `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`98e696e9785f4edd2a3a9da9e8ba55fa`**, pristine **`4535fc6e3d47177635c1278c4954bf20`** — 32 hex each, different. **Both REBUILT from touched source by this pass and both reproduced their md5 bit-for-bit.** Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | testflags j2 679/50/2, dump 496/183/52, `ct8rows` 0 rows | default **679/50/2**, testflags **679/50/2**; dump testflags **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` → **0 differing ROWS (0 row-sides)**, `PASS: every row byte-identical` |
| **4 surelog** | both j2 469/11 + 465/8 (FAIL 25/23, DEFER 5/5), histograms unchanged, 0 rows | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM); `ct8rows` vs committed `results/golden_surelog.csv` → **0 differing ROWS**; all 4 dump histograms identical (default 225/244/325, testflags 165/300/329) |
| **5 BYTE VERIFIER** | both corpora both modes vs PRISTINE built here, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | u2r **0 / 1358** movers, surelog **5 / 953**; `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **6** — arithmetic consistent (1 corruption + 0 real; 1 corruption + 5 real). The 5 are **exactly the predicted set** (§6.1), all with nonzero SIZE-DELTA (§6.2), all converging (§6.3) |

`GOLDEN_DEFER` printed **`[UNSET]`** before the sweeps. All sweeps `--jobs 2`
with private `--out`/`--workdir`. **`SLANG_UHDM` pin verified by reading
`cmds.txt` exhaustively** (r10sd2-verifier F4): all **1573 + 1462** files in each
tree name exactly **one** binary, the right one, in all four sweeps.
`results/*.csv` READ ONLY (`git status --porcelain -- results` = 0). No
`git stash`. slang not patched.

**GATE-3 trap, re-encoded and hit:** `results/gate_uhdm2rtlil.csv` holds
**testflags rows only**; the fresh both-modes CSV was filtered to testflags
(731 rows) before `ct8rows.sh` saw it, or all 731 default rows read as ADDED.

### CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names **7** (documented u2r-only names) |
| `canaries.sh` u2r | at baseline | **ok=8 changed=0 absent=0**, unknown-names **25** (documented) |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST, mode-matched | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS** |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` (the sd4 F6-fixed one) | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | all four **not dispatched by any driver** (they are deliberately **not spelled anywhere in this directory**, so `canaudit` stays 0 here — sd4's ops note) |
| `InterfaceModPort`, `BlackParrotComplex` **by name** | at baseline | both **CMP_EQUAL in BOTH modes**, pristine and delivered identical |
| the four UVM names **by name** | at baseline | `SeqDriver`/`SimpleUVM`/`BuildUVMPkg` **CMP_NOTEQUAL both modes**; `Scoreboard` CMP_NOTEQUAL (default) / SLANG_REJECT (testflags) |

### BOUNDARIES

* **`§ classHomedTypeTsNoPkgInstance4`** (sd4, `TaskFuncEmit.cpp` 1155/1345) — its
  **q1–q11 grid HOLDS**: `TaskFuncEmit.cpp` is **not in this patch's file set**,
  and `BuildUVMPkg`'s two rows (the designs that pass owns) are **byte-identical**
  between the two binaries, so nothing in that family can have moved.
* **`§ retNameLocalInstIsHomeNotClass3`** (`ModuleEmit.cpp` drainFuncRet ~20876) —
  same file, **far from this pass's hunks** (~14, ~4014, ~4264) and untouched;
  return-local instances are not read or written here.
* **sd2-verifier F3** (`design.Parameters` NULL vs 45 on SimpleUVM/Scoreboard) —
  **not disturbed**: this patch's only slot writes are `VpiParent` / `VpiFullName`
  / span / `Instance` **on freshly cloned objects**, never on a `design` vector.
* **`r10uvm73`** (class-property kind) and **`r10earl44`** (`ModuleEmit.cpp`
  `emitModuleDefPorts`) have both **LANDED above this BASE** (`61d5e36`,
  `dcf67d7`). `r10earl44` added **127 lines at `ModuleEmit.cpp:2893`** — *above*
  all three of this pass's hunks, with **no textual overlap**; the patch applies
  to current `HEAD` (verified, §9). **Reported as the standing rules require.**

---

## 8. RESIDUES, RANKED

1. **R1 — the new SeqDriver head, 43 lines, both rows.**
   `LHS: <null>` / `RHS: class_var(uvm_pkg::uvm_default_table_printer)@610:19-610:52`,
   parented to `package uvm_pkg`, with a `method_func_call(new)` initializer: we
   list a package-scope `class_var` in a vector where golden lists nothing. Four
   orders of magnitude cheaper than the wall it replaces, and the whole failing
   subtree is quoted in `r10sd5_heads_new/`. Largest item left on these rows.
2. **R2 — 7 class-listing typespecs are stamped `adpcm_pkg` where golden stamps
   `uvm_pkg`.** The TOTAL is exactly right (golden 63, ours 63, and every per-kind
   `INST` row matches), but the split is `42/21` golden vs `49/14` ours. **This is
   PRE-EXISTING** — pristine is also `adpcm_pkg 49` — so it is an instance-identity
   defect, not an artefact of this patch's null. A ready-made 7-object target.
3. **R3 — 3 entries carry an `enum_typespec` where golden carries no typespec at
   all** (`kind=none/anon/null` 4 golden vs 1 ours; `enum_typespec/named/null` 1
   vs 4; `A=none`/`T=none` 4 vs 1). Also pre-existing and unchanged by this pass.
4. **R4 — `v2`'s upstream defect: an imported package variable whose type is a
   package-homed TYPEDEF is emitted as a `logic_net`, not a variable.** It never
   reaches this pass's arm, so § 5's copy is never made and the class lists
   nothing where golden lists `bit_var (q2::c2::v2)`. A 14-line reproducer already
   sits in `grid5/v2_named_pkg_typedef.sv`. Fixing it will *feed* this pass's arm,
   so the two compose.
5. **R5 — `ct5cls` does not cover the MODULE-container arm.** It walks
   `class_defn`s under packages and `AllClasses()`, so `v5` scores empty and had
   to be judged by whole-design compare (which passed). Any future decode of the
   module arm needs the walk extended first — an empty score there would read
   exactly like agreement.
6. **R6 — `ct5deep` cannot detect SHARING and must never be used as that test**
   (§4.2). Its `emplace`-keeps-first pairing holds the ALL-view package copy while
   the shared entries share the TOP-view copy, so it prints `L0.var DIFF` on a
   fully shared pristine database. Kept, with this header, as the record of a
   method that is right for depth and wrong for identity.
7. **R7 — the `TOP:`-view instance deficit is untouched and is still the biggest
   number on these designs** (sd2 R3 / sd3 R3 / sd4 R3): whole-design
   `vpiInstance` dump lines are golden **16 759** vs ours **13 024**
   (`uvm_pkg` 14 779 vs 10 083; `adpcm_pkg` runs long, 1 979 vs 2 940). This pass
   moved it **+10 toward golden** and did **not** damage it — the unconditional
   null on the copy's actual typespec provably costs no package-listed stamp.
8. **R8 — `v4`'s residual head**: package `q4`'s **own** listing of an explicitly
   imported variable differs from golden, independently of the class copy (whose
   scored cell now equals golden). 12-line reproducer in `grid5/`.

---

## 9. REFUTATIONS, STATED PLAINLY

1. **"golden and the delivered binary have identical clone-depth tables, so the
   clone depth is right" — INSUFFICIENT AS STATED, and caught here.** The
   PRISTINE binary has the identical table too (§4.2). The depth conclusion
   survives only because `ct5cls` independently proves `V=own 1206` on golden and
   on the delivered binary, which is what makes `ct5deep`'s pairs meaningful on
   those two sides. A pass quoting §4.1 without §3 is quoting a control that
   passes on the broken binary.
2. **sd4 R1's mover prediction is REFUTED as incomplete.** It named SeqDriver and
   said the other UVM designs "may" also carry the shape. Measured: **five** rows
   move — `SimpleUVM` and `Scoreboard` carry 66 shared entries each — while
   `BuildUVMPkg`, the design sd4 *did* fix, carries **zero** and does not move.
   The artifact census (§6.1) got this right before the sweeps; no source-text
   predicate could have.
3. **"The class copy's typespec never carries a `vpiInstance`" is NOT the law**
   and would have been a disaster. Golden stamps **63** class-listing typespecs
   with a package on SeqDriver, and cell `v2` shows golden stamping `p2` on a
   class copy whose element type is a package-homed named typedef. The null
   belongs to the **COPY the import arm makes**, and the 63 survive it.
4. **"Use the declarator span" is REFUTED; "shrink the span" is the wrong
   mechanism.** Golden writes the **NAME node's** span. On SeqDriver the two
   coincide on 1126 of 1206 entries, so 80 entries — not 1206 — read as
   span-wrong; cell `v3` (no initializer) is the case where they coincide by
   construction and the copy correctly does not move.
5. **A `<null>` head does not mean "we emit an extra object" in general.** The
   pristine head printed the whole `package uvm_pkg` subtree (1 416 183 lines) and
   the defect was a *shared pointer* three levels inside a class's `Variables`
   vector. Head SIZE is the failing object's subtree, not the size of the defect —
   sd4 §3.1's cost model, re-confirmed: the fix is one clone and it removed
   1 416 140 lines.
6. **The four target row-modes were never one head, and still are not.** sd4 split
   them into two defects; this pass closes the second. What remains on SeqDriver
   (R1) is a **third**, unrelated to both.

---

## 10. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct5cls.cpp` | **THE INSTRUMENT THAT DECIDES.** Per class-listing variable entry, on both sides: own-or-SHARED by POINTER IDENTITY against a **set over all four package listings**, plus span form, typespec kind and `vpiInstance`. Immune to the duplicate-view trap by construction. Carries a hard-error guard on an empty population. |
| `ct5deep.cpp` | Clone-DEPTH reader, L0…L3, SAME/DIFF by pointer identity. **Valid only where sharing is known to be zero — see R6 and §4.2**, which its header now records. |
| `ct5pred.cpp` | **Artifact-based** mover prediction: counts pointer-identical class/package entries in every pristine database of a corpus. Predicted 5 and 0; observed 5 and 0. |
| `ct5clone.cpp` | `clone_tree` cost/shape probe — objects added per clone and which children come out shared. |
| `ct5vec.cpp` | Vector-arm check on the class `Variables` container. |
| `grid5/v1…v6.sv` | the six cells of §5, including the negative control `v6`. |
| `ct4bt.cpp` `ct4bt.gdb` `ct4scan.cpp` `ct4key.cpp` `ct4law.cpp` `ct4reach.cpp` | sd4's watchpoint + exhaustive-scan kit, carried forward unchanged. |
| `byteverify.sh` `msdist.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `TAP.md` | carried forward from `r10sd2repro`/`r10sd3repro`/`r10sd4repro` unchanged. |

---

## 11. THE PATCH

`/tmp/r10sd5.patch` — `git diff` vs `511725d`, `src/` + `tools/probe/r10sd5repro`
only. Reproducible with:

```sh
cd /tmp/wt_r10sd5 && git add -A tools/probe/r10sd5repro
git diff 511725d --binary -- include src tools/probe/r10sd5repro > /tmp/r10sd5.patch
md5sum /tmp/r10sd5.patch
```

md5 is delivered with the pass's final report and NOT written here: this file is
inside the patch, so any md5 recorded here is stale the moment it is written
(`r10sd3` §10's rule, kept).
