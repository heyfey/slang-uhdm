# r10sd1 — § classTdSpecParamsForeignHome1

**The SeqDriver head, both modes, CLEARED.** The shared 85-line `RHS: <null>`
head on `default/SeqDriver` and `testflags/SeqDriver` is gone; **3 movers**, all
three census-predicted before the sweep; five gates green; zero row changes in
either corpus.

| | |
|---|---|
| BASE | `df0cdae` (printed and grep-checked in both worktrees) |
| worktrees | `/tmp/wt_r10sd1` (patched), `/tmp/wt_r10sd1pris` (pristine control) |
| patched binary | md5 `9c01498a4f709a336d5b0c43399da7d3` |
| pristine binary | md5 `fc59a2414877316104c88c8c1fe43b77` |
| patch | `/tmp/r10sd1.patch`, md5 in §9 |
| production files touched | `include/UhdmExporter.h`, `src/UhdmExporter.cpp` |

---

## 1. THE LAW

> **§ classTdSpecParamsForeignHome1** — a **class-scope class-handle typedef**
> whose target is written as an **unqualified `C #(<ordered args>)`** carries the
> SPECIALIZATION (one `vpiParameter` `type_parameter` + one `vpiParamAssign` per
> ordered argument that names a concrete type) **exactly when Surelog's three
> `getClassDefinition` probes all MISS** — i.e. the target generic class is
> **neither nested in the referencing class nor a sibling of it in the
> referencing class's immediate PACKAGE scope**. A target homed in the
> compilation unit always qualifies. Every later typedef of the same target is a
> **clone** and carries the **BASE's** specialization verbatim, not the one its
> own `#(...)` text would produce.

### 1.1 Where the law comes from (transcribed, not guessed)

A class_typespec's `Parameters`/`Param_assigns` have **exactly one writer** in
Surelog: `CompileHelper::compileDatastructureTypespec`'s `ClassDefinition` arm,
`src/DesignCompile/CompileType.cpp:904-1000`. It walks the written
`Parameter_value_assignment` and pushes one `type_parameter` + one `param_assign`
per **ordered** argument.

That arm is the **last resort** of `compileTypespec`'s `slStringConst` case.
Three probes run first (`CompileType.cpp:1896-1918`):

```cpp
ClassDefinition* cl = design->getClassDefinition(typeName);
if (!cl) cl = design->getClassDefinition(component->getName() + "::" + typeName);
if (!cl) cl = design->getClassDefinition(parentScope->getName() + "::" + typeName);
if (cl) { /* bare class_typespec: Name + Class_defn, NO parameters */ }
```

A **hit** mints a bare class_typespec and the specialization is never built.
Surelog keys a package class `pkg::C` and a compilation-unit class `work@C`, so
probe 3 can only ever hit when the reference's immediate parent scope is the
**package that declares the target** — which is why a `$unit` class referencing a
`$unit` generic **does** carry the specialization (cell `b13`).

The clone half is `ElaborationStep::bindTypedefs_`
(`src/DesignCompile/ElaborationStep.cpp:193-200`): a later typedef of an
already-bound target takes `clone_tree` of the base object, so it inherits the
base's parameters wholesale.

### 1.2 What the head actually was — and the brief's law REFUTED

The brief instructed: *"a missing-SLOT head means census the parent VECTOR both
sides FIRST — the r10uvm52-era law: `RHS: <null>` names a SLOT, and
head-is-an-object means every recursive vector before it passed."*

**That law is FALSE, and following it would have wasted this pass.** The census
was run as instructed and REFUTED the premise:

```
work@top_tb Typespecs (vpiTypedef), span-keyed, BOTH views, BOTH sides
    GOLDEN 125    OURS 125
    `class_typespec adpcm_pkg::type_id 440:12-440:31` PRESENT on OUR side,
    at the SAME index, with the right vpiName, vpiInstance and vpiClassDefn.
```

We were not missing the object. `RHS: <null>` here is the `rhs == nullptr` arm of
UHDM's **vector** `SafeCompare` (`templates/BaseClass.h:216-220`):

```cpp
} else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
    context->m_failedLhs = lhs_obj;   // the CONTAINER
    return 1;                          // m_failedRhs left UNSET -> "RHS: <null>"
}
```

so a **NULL vector on an object both sides emit** prints byte-for-byte the same
cmp.log text as a **missing singular object**. Head-is-an-object does **not**
imply every vector before it passed. The deficit was `Parameters` (then
`Param_assigns`) on a class_typespec we already had.

The `slots.py` census is what named it: golden holds the object in 84 slots and we
in 78, and the six golden-only slots are exactly the back-pointers of the missing
children (`param_assign . vpiParent` ×2, `type_parameter . vpiParent` ×2) plus two
`ref_typespec (…::get_type) . vpiActual` slots which we DO fill (with an
anonymous class_typespec) — the second refutation: that slot is not null on our
side either, so it is not the head.

---

## 2. STATED GATE == CODE GATE

`emitClassTdSpecParams1` is one declaration, one definition, one call site;
`copyClassTdSpecParams1` is one declaration, one definition, two call sites.

```sh
grep -rn "classTdSpecParamsForeignHome1\|emitClassTdSpecParams1\|copyClassTdSpecParams1" include/ src/
#  include/UhdmExporter.h:3535  NOTE  (the law's block comment)
#  include/UhdmExporter.h:3545  bool emitClassTdSpecParams1(...)      declaration
#  include/UhdmExporter.h:3553  void copyClassTdSpecParams1(...)      declaration
#  src/UhdmExporter.cpp:2592    NOTE  (the law + the grid)
#  src/UhdmExporter.cpp:2654    bool UhdmExporter::emitClassTdSpecParams1  definition
#  src/UhdmExporter.cpp:2817    void UhdmExporter::copyClassTdSpecParams1  definition
#  src/UhdmExporter.cpp:3090    copyClassTdSpecParams1(m54.ts, bts54)  no-anchor group drain
#  src/UhdmExporter.cpp:3154    emitClassTdSpecParams1(cts, ct, cls, typeSyn)  THE mint site
#  src/UhdmExporter.cpp:3203    copyClassTdSpecParams1(cts, bts50)     package-anchored clone
```

The **stated** gate is, in order: (1) unqualified `ClassNameSyntax` written
spelling; (2) all arguments `OrderedParamAssignment`, at least one present;
(3) the target's generic home is neither the referencing class itself nor the
referencing class's immediate **Package** parent scope; (4) per formal, the
ordered argument at that index must not be a bare identifier naming a parameter
of the referencing class or of a class enclosing it. The **code** gate is those
four tests and nothing else — each is a single `return false` in
`emitClassTdSpecParams1`, in that order, and each is witnessed by a named grid
cell (§3). No other predicate is read and none is written.

**Nothing else in the emitter changed.** Proved directly rather than argued:

```sh
uhdm-cmp <pristine SeqDriver db> <patched SeqDriver db>
#   rc=255, 85 lines, ONE head:
#   LHS: <null>
#   RHS: class_typespec (adpcm_pkg::type_id), id:184168, line:440:12, endln:440:31
```

The **entire** footprint of this patch on the target database is the
`Parameters`/`Param_assigns` of that class_typespec family. This is also the
proof that the new golden-vs-ours head (§5.2) is pre-existing.

---

## 3. THE GRID — cell for cell, one cell PER FILE

`grid/b*.sv`, driven by `ct1grid.sh`. Reading = **PA**: does the cell's
`class_typespec` carry BOTH `vpiParameter` and `vpiParamAssign`, read from the
object's FULL print (`pacells.py` — uhdm-dump prints a body once and every later
appearance is a header line, so a naive grep sees "no children" for 200 of 206
copies).

> **A CONFOUND THIS PASS PAID FOR, recorded because the first arm is kept in the
> directory as the refutation.** `a1_registry.sv` put all cells in ONE file and
> its reading was **worthless**: every typedef of one generic class joins ONE
> Surelog typedef GROUP, so the package-scope cell became the group BASE and all
> nine class-scope cells were reported as clones of it — every cell read `--`,
> including the ones that are `PA` when isolated. One cell per file is not
> tidiness, it is correctness.

LHS is always golden.

| cell | typedef scope | target home | written args | GOLDEN | OURS pris | OURS pat | verdict |
|---|---|---|---|---|---|---|---|
| `b1_selfclass` | class | OWN pkg | ordered, self + string | -- | -- | -- | SAME |
| `b2_otherclass` | class | OWN pkg | ordered, other class | -- | -- | -- | SAME |
| `b12_macro` | class, via MACRO | OWN pkg | ordered | -- | -- | -- | SAME (macro IRRELEVANT) |
| `b3_pkgtd` | package | OWN pkg | ordered | -- | -- | -- | SAME |
| `b10_bothtd` | class + package | OWN pkg | ordered | -- | -- | -- | SAME |
| `b8_twoclasses` | 2 × class | OWN pkg | ordered | -- | -- | -- | SAME |
| `b5_ownparam` | class in a generic | OWN pkg | own type param | -- | -- | -- | SAME |
| `b6_noparams` | class | OWN pkg | none | -- | -- | -- | SAME |
| `b7_named` | class | OWN pkg | named | -- | -- | -- | SAME |
| `b18_qualified` | class | foreign, **`rp::regb`** | ordered | -- | -- | -- | SAME |
| `b19_foreign_ownparam` | class in a generic | foreign | **own type param** | -- | -- | -- | SAME |
| `b20_foreign_named` | class | foreign | **named** | -- | -- | -- | SAME |
| `b21_foreign_noparams` | class | foreign | **none** | -- | -- | -- | SAME |
| `b11_foreignpkg` | class | **foreign, wildcard import** | ordered | **PA** | -- | **PA** | **DIFF → SAME** |
| `b17_explicitimport` | class | **foreign, explicit import** | ordered | **PA** | -- | **PA** | **DIFF → SAME** |
| `b14_foreignmacro` | class, via MACRO | **foreign** | ordered | **PA** | -- | **PA** | **DIFF → SAME** |
| `b23_foreign_onearg` | class | **foreign** | ONE ordered arg | **PA** | -- | **PA** | **DIFF → SAME** |
| `b13_cuclass` | class (`$unit`) | **`$unit`** | ordered | **PA** | -- | **PA** | **DIFF → SAME**, and `CMP_FAIL → PASS_CMP` |
| `b22_foreign_two` | 2 × class | **foreign** | ordered | **PA ×2** | -- | **PA ×2** | **DIFF → SAME** (the clone half) |
| `b4_modtd` | **module** | foreign (import) | ordered | PA | -- | -- | DIFF — **residue R3** |
| `b16_modtd_foreign` | **module** | foreign | ordered | PA | -- | -- | DIFF — **residue R3** |
| `b15_pkgtd_foreign` | **package** | foreign | ordered | PA | -- | -- | DIFF — **residue R3** |
| `b9_inline` | inline decl (module) | foreign | ordered | PA ×2 | PA ×2 | PA ×2 | SAME (other site, already right) |
| `b24_inline_class_own` | inline decl (class prop) | OWN pkg | ordered | -- | -- | -- | SAME |
| `b25_inline_pkgvar_own` | inline decl (pkg var) | OWN pkg | ordered | PA ×2 | -- | -- | DIFF — **residue R4** |
| `b26_inline_method_own` | inline decl (method local) | OWN pkg | ordered | -- | -- | -- | SAME |
| `b27_inline_method_foreign` | inline decl (method local) | foreign | ordered | -- | -- | -- | SAME |

```
cells=27   golden-PA-cells=11
PRISTINE   SAME=17  DIFF=10
PATCHED    SAME=23  DIFF=4        SAME -> DIFF regressions: 0
```

### 3.1 Per-cell cmp and dump, pristine → patched

Not one cell's dump got worse and no cell went `PASS_CMP → CMP_FAIL`:

| cell | cmp heads | cmp lines | dump content |
|---|---|---|---|
| `b13_cuclass` | 1 → **0** | 81 → **PASS_CMP** | 53 → **10** |
| `b22_foreign_two` | 1 → 1 | 85 → **32** (head advanced) | 140 → **104** |
| `b11_foreignpkg` | 1 → 1 | 85 → 266 (head MOVED, §3.2) | 73 → **48** |
| `b14_foreignmacro` | 1 → 1 | 85 → 266 | 91 → **68** |
| `b17_explicitimport` | 1 → 1 | 85 → 266 | 73 → **48** |
| `b23_foreign_onearg` | 1 → 1 | 85 → 266 | 73 → **48** |
| every other cell | unchanged | unchanged | unchanged |

### 3.2 `b11`'s new head is PRE-EXISTING — measured, not asserted

`b11`'s new head is the module's own Typespecs vector, and the deficit is
identical under BOTH binaries:

```
census work@topb vpiTypedef       GOLDEN 2   PRISTINE-OURS 1   PATCHED-OURS 1
```

We never publish a **foreign** package class's class-name key to the importing
module (§ importPublishesPackageClasses24 walks the imported package's own
listings). Arm-only: SeqDriver's real listing censuses 125 == 125. Residue **R5**.

---

## 4. THE FIVE GATES

### GATE 1 — BUILD

Both binaries built at `-j3` in their own worktrees, link line read **before** any
md5, md5s asserted in **separate** commands against `^[0-9a-f]{32}$`.

```
[100%] Linking CXX executable slang-uhdm
[100%] Built target slang_uhdm            errors: 0
md5 patched  9c01498a4f709a336d5b0c43399da7d3   (32-hex asserted)
md5 pristine fc59a2414877316104c88c8c1fe43b77   (32-hex asserted)
BASE printed and grep-checked in each worktree: df0cdae
```

### GATE 2 — GOLDENS

```
SLANG_UHDM=/tmp/wt_r10sd1/build/slang-uhdm ./tests/check_goldens.sh   PASS 23  FAIL 0
SLANG_UHDM=/bin/false                      ./tests/check_goldens.sh   PASS  0  FAIL 23
```

### GATE 3 — uhdm2rtlil, `--jobs 2`, own `--out`/`--workdir`

731 rows per mode, both modes:
**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; testflags dump column
**496 match / 183 differ / 52 blank**.

```
ct8rows.sh results/gate_uhdm2rtlil.csv <my testflags rows>
    0 differing ROWS (0 diff row-sides); both histograms identical
    PASS: every row byte-identical to the committed baseline
diff <(sort u2r_pat.csv) <(sort u2r_pris.csv)   -> IDENTICAL
```

### GATE 4 — Surelog suite, both modes, `--jobs 2`

1588 rows. **default 469 CMP_EQUAL / 11 CMP_NOTEQUAL / 5 DEFERRED / 25
SURELOG_FAIL**; **testflags 465 / 8 / 5 DEFERRED / 23 SURELOG_FAIL**.
`GOLDEN_DEFER` `[UNSET]`.

```
ct8rows.sh results/golden_surelog.csv sl_pat.csv
    0 differing ROWS; all four histograms (status × mode, dump × mode) identical
    PASS: every row byte-identical to the committed baseline
diff <(sort sl_pat.csv) <(sort sl_pris.csv)     -> IDENTICAL
```

### GATE 5 — BYTE VERIFIER, both corpora, both modes, both controls

**Census-prediction, stated BEFORE the sweep** (§5.1): exactly **3** surelog
databases — `default/SeqDriver`, `testflags/SeqDriver`, `default/Scoreboard` —
and **0** uhdm2rtlil databases.

```
SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched wd> <pristine wd>
```

| corpus | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|
| surelog | **3 / 953** | 952 / 953 | 4 = 3 + 1 |
| uhdm2rtlil | **0 / 1358** | 1357 / 1358 | 1 |

Path sets identical on both. **The three movers are exactly the three predicted,
by name.** Prediction and measurement agree with no residual.

### Canaries

```
canaries.sh  surelog   ok=52 changed=0 absent=0 unknown-names=7
canaries.sh  u2r(tf)   ok= 8 changed=0 absent=0 unknown-names=25
ctcan2.sh  EXPECT_UNKNOWN=1 (surelog, baseline FIRST)  ok=58 changed=0  PASS
ctcan2.sh  EXPECT_UNKNOWN=6 (u2r,     baseline FIRST)  ok= 1 changed=0  PASS
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0
```

`InterfaceModPort`, `BlackParrotComplex`, `SimpleConstraint`, `SVSwitch`,
`ApbSlave`, `SeqDriver`, `BuildUVMPkg`, `SimpleUVM`, `Scoreboard` checked **by
name**, both modes: all 18 rows `== baseline`. The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched by
no driver here and their rows are byte-identical to the baseline.

### Determinism / multi-stability

`detcheck.sh`, SeqDriver, 3 reps per binary:

```
PRISTINE  3 runs, 1 distinct hash, all 17 947 327 bytes
PATCHED   3 runs, 1 distinct hash, all 17 960 950 bytes    delta = +13 623 B
```

Both binaries fully deterministic on this input; the delta is a **size delta**,
therefore **real** and in the ADD direction — not the flake class.

---

## 5. THE MEASUREMENTS

### 5.1 The head — CLEARED on BOTH target rows

LHS always golden.

| row | PRISTINE | PATCHED |
|---|---|---|
| `default/SeqDriver` | **85 lines**, head `class_typespec (adpcm_pkg::type_id) @440:12-440:31`, `RHS: <null>` | head **GONE**; new head `LHS: <null>` / `RHS: package uvm_pkg` |
| `testflags/SeqDriver` | **85 lines**, same head (id 317881) | same as above |
| `default/SimpleUVM` | 58, `int_var …m_set_attribute::file@1038:18` | **unchanged** |
| `testflags/SimpleUVM` | 58, same | **unchanged** |
| `default/BuildUVMPkg` | 58, same | **unchanged** |
| `testflags/BuildUVMPkg` | 58, same | **unchanged** |
| `default/Scoreboard` | 58, same | **unchanged** |

Only the two target rows' heads moved; the other five sit on pass-67's residue-1
head (`vpiSigned` on an `int_var`) and are untouched.

The **census-prediction** was derived before the sweep from the whole-design PA
count per design, which is why the mover set was known in advance:

| design | golden PA objects | ours pristine | ours patched |
|---|---|---|---|
| SeqDriver | 62 | 0 | **62** |
| Scoreboard | 3 | 2 | **3** |
| SimpleUVM | **0** | 0 | 0 |
| BuildUVMPkg | **0** | 0 | 0 |

SimpleUVM and BuildUVMPkg have **no** cell of this shape at all, so they were
predicted not to move — and they did not, byte for byte.

### 5.2 The new head is PRE-EXISTING — proved two ways

1. `uhdm-cmp <pristine db> <patched db>` reports **one** head and it is the
   `class_typespec (adpcm_pkg::type_id)` family (§2). The patch adds nothing else
   to the database, so it cannot have created a `package`-valued divergence.
2. The per-shape ADDED census (§5.3) contains **zero** `vpiInstance` lines and
   zero package-valued fields of any kind — the only shapes added are
   `class_typespec` / `type_parameter` / `param_assign` / `ref_typespec` and
   their labels.

It is therefore the **next** divergence in the same traversal, revealed by
`m_visited` once the old head cleared. Ranked **R1**.

### 5.3 Movers, per shape, ADDED and REMOVED never netted

**`default/SeqDriver` and `testflags/SeqDriver`** (identical figures):

```
multiset distance to GOLDEN: pristine=366866  patched=365888   GAIN 978
ADDED line instances=1340   REMOVED line instances=8
ADDED shapes:  class_typespec (type_id) / (this_type) / (adpcm_pkg::type_id)
               type_parameter, param_assign, ref_typespec, and their labels
REMOVED (8):   ref_typespec (uvm_pkg::uvm_*_registry::T), class_typespec
               (uvm_object) / (uvm_component), class_defn (uvm_pkg::uvm_*_registry)
               -- a RE-INDENT, not a deletion: the same objects now print inside
               the new param_assign's Lhs, at a deeper indent, and the ADDED list
               carries them at those indents.
three-way count, the two texts that carry the claim:
    class_typespec (adpcm_pkg::type_id) @440:12-440:31   golden 2  pris 0  pat 2
    class_typespec (adpcm_pkg::type_id) @468:12-468:34   golden 2  pris 0  pat 2
```

**`default/Scoreboard`**:

```
multiset distance to GOLDEN: pristine=134013  patched=134032   gain -19
ADDED line instances=38   REMOVED line instances=11
three-way count:
    class_typespec (type_id) @483:12-483:34   golden 9  pris 6  pat 8   (toward)
    |vpiName:my_scoreboard                    golden 3  pris 2  pat 3   (exact)
```

The **-19** is the multiset instrument's documented blindness, not a regression:
indentation is part of the key, and the added lines land at depths where our tree
already carried at least as many instances as golden. The authoritative per-object
reading is the cell grid: Scoreboard's PA objects go **2 → 3 == golden's 3**, and
the whole-design cell grid shows `SAME→non-SAME = 0`.

### 5.4 Whole-design cell grid, SeqDriver — the deficit closed exactly

Keyed `(vpiName, span)` over every `class_typespec` full print, both sides:

```
PRISTINE  keys=4080  SAME=3133  DIFF=6   GOLDEN-ONLY=694  OURS-ONLY=247
PATCHED   keys=4085  SAME=3139  DIFF=0   GOLDEN-ONLY=694  OURS-ONLY=252
```

The **six** DIFF keys — and they are the complete deficit, measured before any
code was written — were:

```
adpcm_pkg::type_id  468:12-468:34   G=PA  O=--
adpcm_pkg::type_id  440:12-440:31   G=PA  O=--
type_id             468:12-468:34   G=PA  O=--
type_id             440:12-440:31   G=PA  O=--
this_type           468:12-468:34   G=PA  O=--
this_type           440:12-440:31   G=PA  O=--
```

All six now agree. `SAME → DIFF` regressions: **0**. `GOLDEN-ONLY` unchanged.
`OURS-ONLY` grows by 5 — the argument typespecs at spans golden does not use
(residue R2).

The grid is honest by construction: a key present on one side only is
`GOLDEN-ONLY`/`OURS-ONLY` and is **never** counted `SAME`, so no empty-product
cell can inflate the agreement column.

---

## 6. REFUTATIONS, STATED PLAINLY

1. **The brief's r10uvm52-era law is FALSE for a NULL vector.** "head-is-an-object
   means every recursive vector before it passed" — the vector `SafeCompare`'s
   `rhs == nullptr` arm reports the CONTAINER with `RHS: <null>`, identically to a
   missing singular object. The parent-vector census (125 == 125, object present
   on our side) is what caught it. Had the census been skipped, this pass would
   have hunted a typespec-minting owner that already existed.
2. **The MACRO is irrelevant.** SeqDriver's typedef comes from
   `` `uvm_object_utils ``, and the obvious hypothesis was that the macro's
   cross-file span drives the behaviour. Cell `b12` (same shape, macro, own
   package) is `--` and cell `b14` (macro, foreign package) is `PA`: the macro
   moves nothing. The FOREIGN HOME does.
3. **"Class-scope typedef" is not the discriminator either.** `b1`/`b2`/`b12` are
   class-scope and golden gives them nothing; `b4`/`b15`/`b16` are module- and
   package-scope and golden gives them the specialization. Scope alone predicts
   the wrong answer in six cells.
4. **The single-file arm was worthless** (§3): Surelog's typedef GROUP collapses
   every cell of one generic class onto one base object. `a1_registry.sv` is kept
   in this directory as the refutation, not as an instrument.
5. **The second `RHS: <null>` candidate was not the head.** `ref_typespec
   (adpcm_pkg::adpcm_seq_item::get_type) . vpiActual` is one of the six
   golden-only slots, but our side fills it (with an anonymous class_typespec at
   `441:20-441:27`), so it cannot produce `RHS: <null>`. Reading our side out of
   the dump instead of theorising is what settled it.
6. **The distance metric disagrees with the cell metric on Scoreboard** (-19 vs
   +1 correct cell). Reported, not hidden; the cell metric is the authority and
   the instrument's own header says why.

---

## 7. RESIDUES, RANKED

1. **R1 — the NEW head on both SeqDriver rows: `LHS: <null>` / `RHS: package
   uvm_pkg (uvm_pkg::)`, 1 414 891 cmp lines.** Proved pre-existing two ways
   (§5.2). It is **not** a `vpiInstance` divergence (checked: 0 typespecs where
   golden is null and ours is `uvm_pkg`) and not a printed package vector
   (uvm_pkg's dumped label census is identical across golden / pristine /
   patched). The remaining candidates are vectors uhdm-dump does not print, or
   `instance::Instance()`; **cmptool** is the instrument for the next pass.
   Largest item left on these rows.
2. **R2 — the argument typespec's SPAN.** Golden spans the actual at the whole
   `#(...)` text INCLUDING the macro EXPANSION (`440:31-440:65`, past the 51-char
   source line); we span it at the macro DEFINITION text (`440:31-440:54`).
   cmp-invisible (no `Compare` body reads `VpiLineNo`), dump-only, and it is what
   makes `OURS-ONLY` grow by 5. Same family as the campaign's
   `getFullyOriginalLoc` note.
3. **R3 — MODULE-scope and PACKAGE-scope typedefs of a FOREIGN generic
   (`b4`, `b15`, `b16`).** Golden carries the specialization; we do not. A
   DIFFERENT emission site, deliberately untouched: the whole-design cell grid
   shows **zero corpus reach** (every differing key in all four UVM designs is a
   class-scope one), so implementing it would be blast radius with no measured
   gain. The three cells are ready-made witnesses.
4. **R4 — a PACKAGE-level VARIABLE declared inline with an OWN-package generic
   (`b25`) gets `PA ×2` in golden and nothing from us.** A third site again
   (variable declaration, `§ classPkgGenericSpecListing53` territory). Note
   `b24`/`b26`/`b27` show that site does **not** over-fire anywhere else.
5. **R5 — a foreign package class's class-name key is not published to the
   importing MODULE's Typespecs** (`b11`: golden 2, ours 1, identical under both
   binaries). This is `b11`'s new head. Arm-only; SeqDriver's own listing is
   125 == 125.
6. **R6 — `vpiParent` of the base object.** Golden re-parents
   `adpcm_pkg::type_id` to `module_inst work@top_tb` (last-writer, from the module
   listing); ours keeps `class_defn adpcm_seq_item`. cmp-invisible (`VpiParent` is
   read by no `Compare` body) but it is why our `ComputeFullName` prints
   `adpcm_pkg::adpcm_seq_item::adpcm_pkg::type_id::T` where golden prints
   `work@top_tb.adpcm_pkg::type_id.T`. Fixing R6 fixes both fullnames for free —
   which is precisely why this pass writes **no** `VpiFullName` at the new site.
7. **R7 — `Scoreboard`'s surviving DIFF cell**, `uvm_analysis_imp @9:3-9:19`
   (`G=PA O=--`), unchanged by this pass. Same family as R4 (inline declaration).
8. **R8 — the package-anchored clone arm is UNMEASURED.** `copyClassTdSpecParams1`
   is called there for symmetry and is a provable no-op today (no grid cell and no
   corpus row reaches a package-anchored group whose base is a foreign generic; the
   function returns immediately when the base has no `Parameters`).

---

## 8. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `census.py` | span-keyed census of ONE collection under ONE named object, BOTH views reported separately (the SeqDriver dump carries two column-0 `work@top_tb` sections) |
| `slots.py` | every slot a named object occupies, keyed `(enclosing object, field label)` — this is what named the deficit |
| `cells.py` | whole-design `(name, span) → (P,A)` grid; one-sided keys are never `SAME` |
| `pacells.py` | every `class_typespec` FULL print with its PA state, parent and class_defn |
| `ct1arm.sh` | single-arm driver (LHS always golden; `sed 1d`; missing-input guards) |
| `ct1grid.sh` | the grid driver, one row per cell |
| `mv1.sh` | per-shape mover analysis: multiset distance + ADDED/REMOVED never netted + three-way counts |
| `grid/b*.sv` | 27 one-cell files |
| `a1_registry.sv` | **the refuted single-file arm**, kept as the record of the group confound |
| `byteverify.sh` `manifest.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `msdist.sh` `rowheads.sh` `dumptree.py` | carried forward from `r10uvm67repro` unchanged |

---

## 9. THE PATCH

`/tmp/r10sd1.patch` — `git diff` vs `df0cdae`, production (`include/UhdmExporter.h`,
`src/UhdmExporter.cpp`) plus `tools/probe/r10sd1repro/` only. md5 recorded in the
final report and reproducible with:

```sh
cd /tmp/wt_r10sd1 && git add -A tools/probe/r10sd1repro
git diff df0cdae --binary -- include src tools/probe/r10sd1repro > /tmp/r10sd1.patch
md5sum /tmp/r10sd1.patch
```
