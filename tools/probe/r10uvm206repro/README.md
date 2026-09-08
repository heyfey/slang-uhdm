# r10uvm206 — § `importedClassTsRideTheFileUnit206` — **A FILE-SCOPE `import pkg::*` CARRIES THE PACKAGE'S CLASS DEFINITIONS INTO THE DESIGN'S TYPESPEC LISTING, UNDER THE CLASS'S NAME AND WEARING THE FIRST TYPEDEF THAT NAMED IT** — the SimpleUVM ×2 4177864-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here and are not spelled in any artifact; `canaudit.sh`'s own `FENCE-BREACH=0`
is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `a74e2df3` |
| pristine binary | md5 `4f5f59ff040bbe46f92e4222a881637e`, built from this pass's OWN worktree at a clean `a74e2df3` and frozen `chmod 555` before any sweep. **Byte-identical to the main tree's binary at `a74e2df3`, measured when it was frozen.** Its 956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduce the committed baselines row for row, the one informational dump-column cell of R5 excepted. |
| patched binary | md5 `ed8d69ac8043b84d7036b4e6c21224e0`, frozen `chmod 555`. The patch applied to a **FRESH `a74e2df3` worktree** (`cmake -DCMAKE_BUILD_TYPE=Release`) and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on. |
| the head | **SimpleUVM default and testflags, 4177864 / 4178104 cmp lines, ONE head each → CLEARED.** The head object is the `design` itself (`work@top`), on its `vpiTypespec` VECTOR: golden **123** entries / ours **89**. After the patch that vector is 123 on both sides and every one of the 123 positions agrees. The head falls to **86 cmp lines** on both modes. |
| the census | nine UVM databases × both modes, design typespec listing by identity: **MOVED-WRONG 0, AWAY-GOLDEN 0**. |
| the grid | six arms × two views, real Surelog goldens: CALIB 226/0/0/0, PRIS `AGREE 180 TS-DIFF 28 ONLY-GOLDEN 18 ONLY-OURS 12`, PATCHED `AGREE 216 TS-DIFF 6 ONLY-GOLDEN 4 ONLY-OURS 12`. **ONLY-OURS did not move.** |
| the boundary | `LISTED=5341 PROCESSED=5341 PRODUCED_DBS=5156 MOVED_ARMS=48 RC_DIFFS=0`; every moved arm rebuilt against a real Surelog golden in both views: `SCORED views=95 MISSING-ARMS=0 NODB-views=1 TO-GOLDEN=170 AWAY-GOLDEN=0`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

The brief's target was re-measured, not inherited. This pass's own worktree at a
clean `a74e2df3` builds a binary byte-identical to the main tree's, and its own
five-row surelog sweep gives

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default        112      1
SeqDriver      testflags      112      1
SimpleUVM      default    4177864      1
SimpleUVM      testflags  4178104      1
Scoreboard     default         95      1
MiniAmiq       default        112      1
MiniAmiq       testflags      112      1
BuildUVMPkg    default          0      0
BuildUVMPkg    testflags        0      0
```

ONE head per SimpleUVM mode, and the ladder names it exactly:

```
RUNG 1  KINDL=design KINDR=design KINDP=<root> FIELD=Typespecs SHAPE=VEC:G>O
   G= 123   O= 89
```

`design::Compare` (`~/git-repos/UHDM/build/generated/src/design.cpp:303`) reads
`Typespecs()` one line after `AllModules` (`:302`). The 4.18 M cmp lines are the
`design`'s own decompile size, not a distance.

**IS THE COMPARE ORDER-SENSITIVE ON THIS VECTOR? YES, STRICTLY.** The vector
overload of `BaseClass::SafeCompare`
(`~/.local/include/uhdm/BaseClass.h:202-224`) checks the SIZE, records both
OWNERS on a mismatch, and then walks `lhs->at(i)` against `rhs->at(i)`:

```cpp
      if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) { … return 1; }
      for (size_t i = 0, n = lhs->size(); i < n; ++i) {
        if ((r = SafeCompare(lhs->at(i), rhs->at(i), context)) != 0) return r;
      }
```

So adding the missing 34 is only half the law: the 89 we already had must also
be in golden's ORDER. That question was settled BEFORE any code was cut, and it
is what forced the by-object dedup rule in § 5.

## 2. QUESTION 1 — THE 34, BY IDENTITY, BOTH ONE-SIDED SETS

`ct206ts` prints the vector by identity — kind, name, span, `vpiInstance` face,
`vpiTypedefAlias` face — WITH THE INDEX, so "missing" and "present but
misplaced" are told apart. `VECTORS.SimpleUVM.r10uvm206.txt` holds all three
listings in full; `cen206.py` joins them:

```
PRISTINE  AGREE=7  TS-DIFF=82  ONLY-GOLDEN=34  ONLY-OURS=0  GLEN=123 OLEN=89
```

Keyed by `kind × name`, the two one-sided sets are

```
ONLY-GOLDEN:  26 class_typespec|this_type
               5 class_typespec|this_subtype
               2 class_typespec|type_id
               1 class_typespec|super_type
ONLY-OURS:    (empty)
```

**ONLY-OURS IS EMPTY BEFORE AND AFTER.** The gap is purely additive plus an
ordering.

Every one of the 34 is the typespec built at a `typedef <SomeClass>#(…) <alias>;`
— `THE34.r10uvm206.txt` lists each with the exact source line at its span:

```
comps/uvm_pair.svh          this_type      typedef uvm_built_in_pair #(T1,T2) this_type;
base/uvm_callback.svh       this_type      typedef uvm_callbacks_base this_type;
base/uvm_callback.svh       super_type     typedef uvm_typed_callbacks#(T) super_type;
macros/uvm_object_defines.svh type_id      typedef uvm_component_registry #(T) type_id;
base/uvm_resource_specializations.svh this_subtype  typedef uvm_int_rsrc this_subtype;
…
```

**THE POSITIONS DECODE THE KEY.** Golden's 123 are NOT one alphabetical run over
their own names: a longest-increasing-subsequence over the name sequence leaves
exactly **37** entries out of order — the 34 above **plus three we already had**:

| entry (our name for it) | golden's position | the key it actually sorts under |
|---|---|---|
| `uvm_pkg::uvm_mem_cb_iter` | 14, between `uvm_byte_rsrc` and `uvm_callbacks` | the CLASS `uvm_callback_iter` |
| `uvm_pkg::uvm_heartbeat_cbs_t` | 15 | the CLASS `uvm_callbacks` |
| `uvm_pkg::uvm_table_printer_knobs` | 62, between `uvm_predict_e` and `uvm_printer_row_info` | the CLASS `uvm_printer_knobs` |

and every one of the 34 sorts under ITS OWN target class's name
(`this_type`@`uvm_algorithmic_comparator.svh:74` sits between
`uvm_active_passive_enum` and `uvm_apprepend`; `super_type`@`uvm_callback.svh:486`
sits between `uvm_tree_printer_knobs` and `uvm_verbosity`, i.e. at
`uvm_typed_callbacks`). The three re-keys are the reason a size-only fix could
not have cleared the head.

**THE OBJECTS ALREADY EXIST IN OUR DATABASE.** `ct206ts --scan` finds 34
`class_typespec`s named `this_type` in golden's arena and 35 in ours, with the
same `Class_defn` faces. Nothing had to be MINTED; the listing simply never
carried them.

## 3. QUESTION 2 — DECODING SURELOG

Three functions, in the order they run.

**(a) The import inserts the CLASSES, not only the typedefs.**
`CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp:127`), the
class arm at `:150-161`, BEFORE the typespec arm at `:162-169`:

```cpp
    auto& classSet = def->getObjects(VObjectType::paClass_declaration);
    for (const auto& cls : classSet) {
      …
      DesignComponent* comp = packageFile->getComponentDefinition(fullName);
      scope->addNamedObject(name, fnid, comp);
      scope->insertDataType(name, (ClassDefinition*)comp);   // keyed by the CLASS name
    }
```

`CompileFileContent.cpp:84` is the call that makes a FILE-scope import use the
**FileContent** as that scope — which is the map the design reads.

**(b) The class's typespec is the FIRST typedef that named it.**
`ElaborationStep::bindTypedefs_` (`src/DesignCompile/ElaborationStep.cpp`) walks
every typedef of every package (by package name, then typedef name), then
modules, then programs, then classes, and at `:259-263` back-fills the TARGET
DataType, first-writer-wins:

```cpp
        typd->setTypespec(ts);
        if (DataType* dt = (DataType*)typd->getDataType()) {
          if (dt->getTypespec() == nullptr) {
            dt->setTypespec(ts);          // ts->VpiName(typd->getName()) above
          }
        }
```

That is why the entry is named `this_type` / `type_id` / `super_type` /
`this_subtype` and not after its class, and why `uvm_callbacks` wears
`uvm_heartbeat_cbs_t` (the alphabetically first of uvm_pkg's ten typedefs that
target it) rather than its own in-class `this_type`: the PACKAGE group runs
before the CLASS group.

**(c) The design's listing is the union of the FileContent maps, deduped BY
OBJECT.** `UhdmWriter` (`src/DesignCompile/UhdmWriter.cpp:4866-4872`):

```cpp
    VectorOftypespec* typespecs = s.MakeTypespecVec();
    d->Typespecs(typespecs);
    for (auto& fileIdContent : m_design->getAllFileContents()) {
      writeDataTypes(fileIdContent.second->getDataTypeMap(), d, typespecs, s, true);
```

and `writeDataTypes` (`:775-810`):

```cpp
  std::set<uint64_t> ids;
  for (const auto& entry : datatypeMap) {           // std::map -> KEY ORDER
    …
    typespec* tps = dtype->getTypespec();
    if (tps) {
      if (!tps->Instance()) { if (parent->UhdmType() != uhdmclass_defn) tps->Instance((instance*)parent); }
      if (setParent) tps->VpiParent(parent);
      if (ids.find(tps->UhdmId()) == ids.end()) { dest_typespecs->push_back(tps); ids.insert(tps->UhdmId()); }
    }
  }
```

Three facts fall out of those nine lines and all three are law:
* the vector is in **DataTypeMap KEY order** — the class name for a class entry,
  the typedef name for a typedef entry;
* `ids` is a **by-OBJECT** dedup, so when one typespec is reachable under both a
  typedef key and a class key the **alphabetically first key holds it** — which
  is exactly `uvm_callbacks` < `uvm_heartbeat_cbs_t` (moves) against
  `uvm_barrier_pool` < `uvm_object_string_pool` (stays);
* `if (!tps->Instance())` is why golden's class-key entries read
  `vpiInstance -> design` while the typedef entries keep `package:uvm_pkg`.

## 4. QUESTION 3 — DECODING SLANG, AND WHAT WE REGISTERED

Our design listing is built in `UhdmExporter::exportDesign`
(`src/UhdmExporter.cpp`, the `byName` block around `:6180-6310`). It already
models (c): the `$unit` typedefs, the nettypes, the group-by-root-file stable
sort, and — since an earlier pass — the file-scope import's TYPEDEF half:

```cpp
                for (auto& pm : ipkg->members()) {
                    if (pm.kind != SymbolKind::TypeAlias) continue;
                    …
                    if (byName.emplace(std::string(pm.name), tit->second).second)
                        declLoc9[std::string(pm.name)] = mem.location;
                }
```

The CLASS half was simply absent, and with it the by-object dedup that reorders
three of the entries we did have. Two consequences, and they are the 34 plus the
82 misplacements.

**We do not need a new stamp table.** § `importPublishesPackageClasses24`
already computes exactly Surelog's (b): `buildClassRep25`
(`src/ModuleEmit.cpp:3561`) scans package listings by name, then modules by
name, then every class definition, taking the FIRST `class_typespec` whose
`Class_defn` is a given class — and `pkgClassKeys24` (`:3635`) turns that into
`<class bare name> -> <typespec>` for one package. § 24 uses it for the PACKAGE
arm and § 45 for the MODULE arm; the DESIGN arm is what this pass adds.

`classRep25` also already carries the one eligibility rule this face needs:
§ `classRepresentativeSkipsTypeParamAlias25` skips a `typedef T elem_type;`
whose target is written as a TYPE PARAMETER, because Surelog's back-fill hands
that typespec to the PARAMETER (`typd->getDataType()`), never to the class the
parameter resolves to. Grid arm C is that rule's own witness.

## 5. THE LAW, AS ONE GATED REGISTRATION

> **§ `importedClassTsRideTheFileUnit206`.** A FILE-SCOPE `import pkg::*` puts
> the package's CLASS DEFINITIONS into that compilation unit's DataTypeMap
> beside its typedefs, keyed by the CLASS's own bare name, and the design's
> typespec listing is the union of every unit's map. What a class key
> contributes is the `class_typespec` of the FIRST typedef that named that
> class, so the entry keeps THAT TYPEDEF's name while sorting under the
> CLASS's, and carries the DESIGN as its `vpiInstance` when it has none. The
> union is de-duplicated BY OBJECT: when one typespec is reachable under both
> its own typedef key and a class key, the ALPHABETICALLY FIRST of the two keys
> is the one that holds it.

`fileUnitPublishesPackageClasses206` (`src/ModuleEmit.cpp`) is that sentence, run
DESIGN-FINAL after § 24 / § 23 / § 45 (so `classRep25` reads finished listings)
and before § 38 (which is pinned dead last). It writes `design->Typespecs()` and
nothing else — a vector no other tail pass reads or writes.

| file | edit |
|---|---|
| `include/UhdmExporter.h` | the law, `fileUnitPublishesPackageClasses206`, and the three members it needs: the design listing's own ordered keys, each key's root-file location, and the file-scope wildcard imports. |
| `src/UhdmExporter.cpp` | the design block RECORDS its keys, their root-file locations and the file-unit imports (the guard moved from the bookkeeping to the publish, so a unit whose import brings ONLY class keys can still gain a listing — grid arm C); the tail calls the new pass. |
| `src/ModuleEmit.cpp` | `fileUnitPublishesPackageClasses206`: merge `pkgClassKeys24` per import, dedup by object with the first key winning, stamp the design as `vpiInstance` when there is none, re-run the SAME stable sort, republish. |

**AND ONE GATE CORRECTION, NOT A SECOND LAW.**
`src/ParamEmit.cpp` — `emitPkgArrayVar`'s INDEX typespec now honours the caller's
`stampTsInstance`, the flag § `oobCtorLocalsRideTheImport203` already threads
through the ELEMENT arm eleven lines above:

```cpp
            if (fresh44 && stampTsInstance)
                its->Instance(up);
```

§ 203's own sentence — *"the MODULE copy re-creates its typespec outside the
package's scope and carries NO vpiInstance"* — was implemented for the element
and left unmeasured for the index. It is measured now: with the design listing
matched, SimpleUVM's next head was `LHS: <null>` against
`RHS: module_inst(work@top)`, and the whole of it was **two** `string_typespec`s
— the `[string]` index of `uvm_random_seed_table_lookup`'s two import copies —
the only typespecs in the database carrying `vpiInstance -> module_inst work@top`
where golden has none. The flag is false at exactly one call site
(`src/ModuleEmit.cpp:8877`, the module's materialized import copy), so nothing at
package scope can move; the predictor in § 6 names its whole possible reach.

## 6. THE PREDICTION, MADE ON PRISTINE DATABASES BEFORE THE PATCHED SWEEP

`ct206pred` computes, from a PRISTINE database alone, every class key the law
could add or move; `ct206pred2` does the same for the gate correction (an
`array_var` under a `module_inst` whose index typespec carries an instance).
Neither can read the file-scope `import` itself, so both are UPPER BOUNDS: a
database they call CLEAN cannot move.

```
§ 206  surelog  SCANNED=956  MAYBE=11  → BuildUVMPkg ×2, ClassExtends ×2,
                                          MiniAmiq ×2, Scoreboard/default,
                                          SeqDriver ×2, SimpleUVM ×2
§ 206  u2r      SCANNED=1358 MAYBE=0
gate   surelog  SCANNED=956  MAYBE=4   → SeqDriver ×2, SimpleUVM ×2
                (all four: work@…​.uvm_random_seed_table_lookup:string_typespec)
gate   u2r      SCANNED=1358 MAYBE=0
```

Reading the sources discharges four of the eleven by hand: `BuildUVMPkg` has no
file-scope import at all, and `ClassExtends`' `import p1::*;` is written inside
`package p2`. **PREDICTED MOVERS: SimpleUVM ×2, SeqDriver ×2, Scoreboard/default
— and NOTHING in uhdm2rtlil (0 of 1358).**

## 7. THE CENSUS — MOVED-WRONG 0 / AWAY-GOLDEN 0

`cenrows206.sh` joins golden × pristine × patched on the design typespec listing
for the nine UVM rows plus `ClassExtends`, both modes
(`CENSUS.r10uvm206.txt`):

| row | pristine | patched |
|---|---|---|
| SimpleUVM default | `AGREE 7 TS-DIFF 82 ONLY-GOLDEN 34 ONLY-OURS 0` (123/89) | **`AGREE 123`, everything else 0** |
| SimpleUVM testflags | identical | **identical** |
| Scoreboard default | `AGREE 7 TS-DIFF 84 ONLY-GOLDEN 34 ONLY-OURS 0` (125/91) | **`AGREE 125`, everything else 0** |
| SeqDriver ×2, MiniAmiq ×2, BuildUVMPkg ×2, ClassExtends ×2 | golden's listing is EMPTY and so is ours | **unchanged, still 0/0** |

```
-- ROWS=11 SKIP-NOFILE=1
-- PATCHED  MOVED-WRONG(=TS-DIFF) 0  AWAY-GOLDEN(=SET-ONLY-OURS) 0
```

`SKIP-NOFILE=1` is `Scoreboard/testflags`, which slang rejects on both binaries.

## 8. THE HEAD AFTER — AND R0

```
TEST           MODE      CMPLINES  HEADS      (pristine -> patched)
SimpleUVM      default    4177864 -> 86    1
SimpleUVM      testflags  4178104 -> 86    1
SeqDriver      default/testflags   112     unchanged
Scoreboard     default              95     unchanged
MiniAmiq       default/testflags   112     unchanged
BuildUVMPkg    default/testflags     0     unchanged (CMP_EQUAL)
ClassExtends   default/testflags     0     unchanged (CMP_EQUAL)
```

After the patch the ladder reaches `vis=187115 / 188084` — **99.5 % of golden's
objects proven equal** — and every remaining rung is ONE family:

```
RUNG 1..8  KINDL=class_var KINDR=class_var KINDP=module_inst
           FIELD=VpiAutomatic  SHAPE=INT:G>O
```

**R0 — A MATERIALIZED-IMPORT `class_var` IS `vpiAutomatic` IN GOLDEN.** The
whole 86-line head is one bit:

```
LHS  class_var: (work@top.clp) … |vpiAutomatic:1 |vpiVisibility:1
RHS  class_var: (work@top.clp) …                 |vpiVisibility:1
```

`clp` is `uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();`, an
out-of-body constructor local that § 203's law hoists into `work@top`. Golden
stamps `vpiAutomatic` on the module's copy of such a handle; we do not. It is
the next head on both SimpleUVM modes and it is a `class_var` FAMILY (at least
eight distinct objects, one masked rung each), not a single object — so it wants
its own gate and its own grid, which is why this pass stopped at the listing and
did not reach for it.

## 9. THE GRID

`grid206.sh`, six arms × two views (`-parse` and `-parse -elabuhdm`), one REAL
Surelog golden per arm-view built by the canonical
`~/git-repos/Surelog/build/bin/surelog` that `scripts/verify_golden.py` itself
names. `ct206cen` censuses EVERY typespec listing in the database — the design's,
each package's, each module's def and elab views, each class's — plus the
`vpiInstance` of every `array_var`'s index and element typespec, so BOTH edits
are scored. Calibration is golden-vs-golden and must be perfect.

```
-- CALIB    12 arm-views, AGREE 226, TS-DIFF  0, ONLY-GOLDEN  0, ONLY-OURS  0
-- PRIS     12 arm-views, AGREE 180, TS-DIFF 28, ONLY-GOLDEN 18, ONLY-OURS 12
-- PATCHED  12 arm-views, AGREE 216, TS-DIFF  6, ONLY-GOLDEN  4, ONLY-OURS 12
-- NONZERO RCs: 0
```

The grid is the brief's asked-for cross: **source kind × view.**

| arm | what it isolates | patched verdict |
|---|---|---|
| `g206_a_selftd` | the class key itself, four context kinds in one package: a class with its OWN self-typedef, a PARAMETERIZED class with one, a class NO typedef ever names, and a class named only by ANOTHER class's typedef | **AGREE 30 = GCELLS** per view (pristine 26), TS-DIFF **0**, ONLY-GOLDEN **0**. The un-named class is correctly ABSENT on both sides. |
| `g206_b_dedup` | the by-object dedup in BOTH directions — a package typedef whose name sorts BEFORE its target class (`aa206_early` < `cb206_late`, stays at the typedef key) and one that sorts AFTER (`zz206_late` > `cb206_mid`, moves to the class key) — plus first-writer-wins between two package typedefs of one class | **AGREE 28 = GCELLS** per view (pristine 25), TS-DIFF 3 → **0**. |
| `g206_c_tparam` | § `classRepresentativeSkipsTypeParamAlias25`: a class whose only typedef targets a TYPE PARAMETER must NOT get a key, beside a class named by a plain typedef that must | the DESIGN listing is **EXACT** (the `D#0` cell agrees; pristine had it missing). AGREE 6 → **7**, ONLY-GOLDEN 3 → **2**; the two that remain are golden's copy of the same entry in the MODULE's listing, which is § `modulePublishesPackageClasses45`'s face and identical on both binaries (R2). |
| `g206_d_modimport` | **NEGATIVE CONTROL** — the same package, the same class, but the import written INSIDE the module | **PATCHED identical to PRISTINE**, cell for cell (AGREE 6, TS-DIFF 3, ONLY-GOLDEN 0). It is correctly **absent** from the wide boundary's moved list. |
| `g206_e_two` | TWO file-scope imports of two packages: both class key sets join the same unit group and the listing is ONE alphabetical run over typedef and class names together | **AGREE 24 = GCELLS** per view (pristine 20), TS-DIFF 2 → **0**, ONLY-GOLDEN 2 → **0**. |
| `g206_f_mixed` | the SOURCE-KIND CROSS: the unit's own `enum` / packed `struct` / packed-vector typedefs and a `nettype` in the same map as the import's typedefs and class keys | **AGREE 14 = GCELLS** per view (pristine 8), TS-DIFF 5 → **0**, ONLY-GOLDEN 1 → **0**. The class key merges in without displacing any kind the listing already carried. |

`ONLY-OURS 12` is one cell × 12 arm-views: the `builtin` package's own
`work@process::state` enum, which golden's `-nobuiltin` run has no scope for. It
is **identical on both binaries, before and after** — this law adds not one
one-sided cell.

## 10. THE BOUNDARY AND THE FLOOR

```
LISTED=5341 PROCESSED=5341 PRODUCED_DBS=5156 MOVED_ARMS=48 RC_DIFFS=0
```

Subdirectory arms are compiled (the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, PROCESSED is asserted
against LISTED). **Five of this pass's six `grid206/g206_*.sv` are in the moved
list — the POSITIVE CONTROL, without which a green gate would prove nothing —
and `g206_d_modimport` is correctly absent.**

Every moved arm was rebuilt with a REAL Surelog golden in BOTH views and scored
(`bscore206.sh`, `BOUNDARY_SCORES.r10uvm206.txt`):

```
-- SCORED views=95 MISSING-ARMS=0 NODB-views=1 TO-GOLDEN=170 AWAY-GOLDEN=0
```

The one unscored view is `r10vbuvm31repro/gv31a5.sv elab`, where Surelog itself
fails (`grc=4`) and BOTH our binaries segfault — **identically**, `arc=139
brc=139`, which is why the boundary's own `RC_DIFFS` is 0. The counter records it
rather than hiding it. (r10uvm203 recorded the same cell.)

**The FLOOR the brief names, checked BY NAME against
`BOUNDARY_MOVERS.r10uvm206.txt`:**

| boundary | arms in the moved list |
|---|---|
| § `pkgClassTdImportCopyLocalUnsupported202` + its type-param fence (`r10uvm202repro`) | **0** |
| § `impFoldRhsMirrorsLhsTs201` (`r10uvm201repro`) | **0** |
| § `impUnsizedBasedLhsNoTs199` + the paren-cast arm (`r10uvm199repro`, `r10v199repro`) | **0** |
| § `impCopyStringConstSize` (`r10uvm197repro`) | **0** |
| § `modUnitImportParamsTwice196` (`r10uvm196repro`) | **0** |
| buvm3–15 | **0** |
| uvm82–91 | **0** |
| § `oobCtorLocalsRideTheImport203` + its packed-struct fence (`r10uvm203repro`) | **2** — `grid203/g203_b_cont.sv` (AGREE 11→**13**, TS-DIFF 2→**0**, AWAY **0**, both views) and `grid203/g203_f_pkstruct.sv`, the fence's own arm (AGREE 22→**24**, TS-DIFF 2→**0**, ONLY-GOLDEN **0→0**, AWAY **0**, both views). Both are the gate correction's own shape — a module's materialized copy of a package container — and both move TOWARD golden. The packed-struct exception still holds: the arm's ONLY-GOLDEN and ONLY-OURS are unchanged. |
| sd8–12 | **6** — `sd9/10/11/12 grid9/g3_pkgvar_module.sv` (AGREE 9→**10**, TS-DIFF 1→**0**, AWAY **0**) and `sd11/12 vgrid11/v1_nonsubroutine_sites.sv` (AGREE 11→**12**, TS-DIFF 5→**4**, AWAY **0**) |

Every one of those is an arm whose subject IS the materialized-import listing,
every one moves TOWARD golden, and none of them moves away.

## 11. THE GATES

| gate | result |
|---|---|
| build both, md5s | pristine `4f5f59ff040bbe46f92e4222a881637e` (byte-identical to the main tree at `a74e2df3`), patched `ed8d69ac8043b84d7036b4e6c21224e0`; both frozen `chmod 555` before any sweep, and every `cmds.txt` audited BY BINARY PATH |
| goldens | **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false` → **23 FAIL / 0 PASS** |
| uhdm2rtlil testflags + default | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in both modes; `ct8rows` against the committed baseline AND against this pass's own pristine control: **0 differing rows** each |
| uhdm2rtlil byte identity | `SELFCHECK=1 byteverify` — `PATH_SETS_IDENTICAL (1358 paths)`, **MOVERS 0 / 1358**, selfcheck 1357/1358 flagged (the tool can see) |
| surelog `--mode both` | **940 CMP_EQUAL / 16 CMP_NOTEQUAL** and the same histogram as the pristine control; `ct8rows` over 1588 rows: **exactly ONE differing row**, `Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` → `CMP_EQUAL,,,` — **the STATUS is CMP_EQUAL on both sides and the two binaries' databases for that row are BYTE-IDENTICAL** (`92bf7b7facdcf4fca15d5710960e8c64`), so the flip is in the harness's informational dump column, not in our emission. NOT A CONVERSION. See § 12. |
| surelog byte identity | `SELFCHECK=1 byteverify` — `PATH_SETS_IDENTICAL (956 paths)`, **MOVERS 5 / 956**, and the five are **exactly the predicted set**: `SimpleUVM ×2`, `Scoreboard/default` (the class-key law) and `SeqDriver ×2` (the gate correction). Selfcheck 955/956 flagged. |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0`; `ctcan2` PASS both corpora |
| fence | `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`; the four fenced names appear in no artifact here and are dispatched by no driver |

## 12. THE ONE MOVED ROW — AND WHY IT IS NOT A CONVERSION

The surelog sweep's `ct8rows`, against the committed baseline AND against this
pass's own pristine control, moves **exactly one row of 1588**, quoted in full:

```
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ
> Earlgrey_0_1,testflags,CMP_EQUAL,,,
```

**The STATUS column does not move — CMP_EQUAL on both sides — and the four
CMP_EQUAL row-modes the brief protects (`BuildUVMPkg` ×2, `Earlgrey_0_1`
testflags, and `Earlgrey_0_1`/`Rggen` default) all stay CMP_EQUAL, scored in
both columns.** What moved is the harness's INFORMATIONAL `uhdm-dump` column,
and three measurements say it is not ours:

1. **The two binaries' databases for that row are BYTE-IDENTICAL** —
   `92bf7b7facdcf4fca15d5710960e8c64` under both `slp/testflags/Earlgrey_0_1-…`
   and `slq/testflags/Earlgrey_0_1-…`. `byteverify` agrees: the row is not in
   its 5-database mover list. Identical bytes in cannot make our emission the
   cause of a different cell out.
2. **An ISOLATED single-row re-run gives the empty cell on the PRISTINE binary
   too**, four runs, alternating binaries:
   ```
   /tmp/r10uvm206_pris.bin    : Earlgrey_0_1,testflags,CMP_EQUAL,,,
   /tmp/r10uvm206_patched.bin : Earlgrey_0_1,testflags,CMP_EQUAL,,,
   /tmp/r10uvm206_pris.bin    : Earlgrey_0_1,testflags,CMP_EQUAL,,,
   /tmp/r10uvm206_patched.bin : Earlgrey_0_1,testflags,CMP_EQUAL,,,
   ```
3. **The official judge reads it as equal**: `rowheads.sh` over the patched
   sweep workdir gives `Earlgrey_0_1 testflags 0 cmp lines, 0 heads, rc=0`.

This is R5, the cell r10uvm197 / 199 / 201 / 203 each recorded; this pass adds
the byte-identity proof. `results/*.csv` were READ ONLY and nothing was
promoted.

## 13. HOW TO REPRODUCE

```bash
git worktree add /tmp/wt_r10uvm206 a74e2df3
cd /tmp/wt_r10uvm206 && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 2
cp build/slang-uhdm /tmp/pris && chmod 555 /tmp/pris          # md5 4f5f59ff…
git apply /tmp/r10uvm206.patch && cmake --build build -j 2
cp build/slang-uhdm /tmp/pat && chmod 555 /tmp/pat            # md5 ed8d69ac…

cd tools/probe/r10uvm206repro
for t in ct206ts ct206cen ct206pred ct206pred2 ct206vec; do
  g++ -O2 -std=c++17 $t.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
      -luhdm -lcapnp -lkj -o /tmp/$t; done

# the head, both binaries, on YOUR OWN pinned workdir
SLANG_UHDM=/tmp/pris python3 ../../../scripts/verify_golden.py --corpus surelog --mode both \
  --jobs 2 --filter 'SimpleUVM|SeqDriver|Scoreboard|MiniAmiq|BuildUVMPkg|ClassExtends' \
  --out /tmp/pris.csv --workdir /tmp/wdA
SLANG_UHDM=/tmp/pat  python3 ../../../scripts/verify_golden.py --corpus surelog --mode both \
  --jobs 2 --filter 'SimpleUVM|SeqDriver|Scoreboard|MiniAmiq|BuildUVMPkg|ClassExtends' \
  --out /tmp/pat.csv  --workdir /tmp/wdB
bash ../r10uvm67repro/rowheads.sh /tmp/wdA /tmp/hA SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg
bash ../r10uvm67repro/rowheads.sh /tmp/wdB /tmp/hB SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg

# the prediction (pristine only), the census, the grid, the boundary
PRED=/tmp/ct206pred  bash pred206.sh /tmp/wdA /tmp/PRED.txt
TS=/tmp/ct206ts JOIN=$PWD/cen206.py bash cenrows206.sh /tmp/wdA /tmp/wdB /tmp/CEN.txt \
  SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg ClassExtends
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=/tmp/ct206cen JOIN=$PWD/join206.py \
  bash grid206.sh grid206 /tmp/gridscr /tmp/GRID.txt
cp -r ../../probe /tmp/bsrc
PRIS=/tmp/pris PATCHED=/tmp/pat bash bound206.sh /tmp/bsrc /tmp/bout
PRIS=/tmp/pris PATCHED=/tmp/pat CEN=/tmp/ct206cen JOIN=$PWD/join206.py \
  bash bscore206.sh /tmp/bsrc /tmp/bout/MOVERS /tmp/bscore
```

## 14. RESIDUES, ranked

* **R0 — a MATERIALIZED-IMPORT `class_var` is `vpiAutomatic` in golden** (§ 8).
  The whole of SimpleUVM's remaining 86-line head, both modes, one bit; at least
  eight distinct `class_var` objects under `module_inst work@top`, so it is a
  family and wants its own gate. The ladder reads `vis=187115/188084` with it as
  the only remaining shape.
* **R1 — the MODULE arm of the class-key law on a bare package.** Grid arm C's
  remaining `ONLY-GOLDEN 2`: golden lists `named_type` in `work@gc206`'s own
  typespec listing as well as the design's. That is
  § `modulePublishesPackageClasses45`'s face and it is identical on BOTH
  binaries, before and after; this pass deliberately did not reach into it.
* **R2 — the module-scope import's class-typespec `vpiInstance`.** Grid arm D's
  three TS-DIFF cells: golden gives `cd206_self`'s `this_type` an instance
  (`module_inst:`) where we give none, in the module's listing, the package
  class's listing and the elab view. Identical on both binaries; the negative
  control's own residue, untouched by this pass.
* **R3 — the design listing's SPANS.** Nine of the 123 entries carry a
  different span in golden than in ours (`UVM_SEQ_ARB_TYPE` 332:40 vs 359:1,
  `uvm_apprepend` 246:55 vs 43:1, …): golden's is the span of the FIRST USE that
  compiled the typespec, ours the declaration's. It is judge-INVISIBLE — no
  generated `Compare` reads `VpiLineNo`/`VpiColumnNo` — and therefore not a
  head, but it is a dump-text difference.
* **R4 — the `builtin` package's `work@process::state`.** One ONLY-OURS cell in
  every grid arm-view, on both binaries: golden's `-nobuiltin` run has no such
  scope. Not this pass's and not a corpus face.
* **R5 — the `Earlgrey_0_1/testflags` dump-column cell.** An isolated run gives
  `CMP_EQUAL,,,` on BOTH binaries where `results/golden_surelog.csv` records
  `…,CMP_EQUAL,,,differ`; the STATUS agrees and the two binaries' databases for
  that row are byte-identical (§ 12). r10uvm197, 199, 201 and 203 recorded the
  same cell. Not this pass's; nothing was promoted; `results/*.csv` were read
  only.
* **R6 — five wide-census cells on SimpleUVM and Scoreboard that this law does
  not reach.** After the patch the wide census leaves `TS-DIFF 5` on those rows,
  all of one shape: the ELEMENT `class_typespec` of a queue declared inside a
  `begin` block is named `uvm_component` in golden and UNNAMED in ours
  (§ `localClassTsUnnamed15`'s face). Present on both binaries, below the
  current head.
