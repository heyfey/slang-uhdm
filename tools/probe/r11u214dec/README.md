# r11u214dec: map 13's ground-B heads and families decoded and scratch-verified (analyst pass, measurement only)

**Base, rebased twice.** The pass started at `6dcc0818` (branch matrix-1.87); pair A's pass 210 landed at `a727b8c7`
(ExprEmit / ParamEmit / StmtEmit / EmitHelpers.h only: none of this pass's files) and pair B's pass 212 at `745f66ab`
(ModuleEmit, TypeEmit, UhdmExporter) while it ran. Every final measurement below is at **`745f66ab`** (round 3);
round 1 (`a727b8c7` + the first seven laws) and round 2 (`745f66ab` + the laws before the N0682 pair) are kept in
[evidence/round1_a727b8c7/](evidence/round1_a727b8c7/) and [evidence/round2_745f66ab/](evidence/round2_745f66ab/).
Pass 212 landed one law of this pass independently (law sizeDimOvrFileAtDim212 = this pass's sizeDimOvrFileAtDim214,
the same rule at the same two sites; dropped here) and the no-importer cell of the UVM_SEQ_ARB_TYPE family (law 
pkgEnumAliasListingParent212, map 13's N0778, which this pass's law composes with, section 3.1); pass 210 converted
none of this pass's clusters (its README: N0540 / N0689 and the UVM_MACRO_* names not attempted).

Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited by this directory; the laws are
delivered as ONE ground patch for pair B to land: [law_typeemit.patch](law_typeemit.patch) (UhdmExporter.cpp,
TypeEmit.cpp, ModuleEmit.cpp, TaskFuncEmit.cpp; applies clean on a fresh `745f66ab`). No ground-A half was needed to
measure a joint row, so there is no law_exprstmt.patch (the ground-A halves this pass decoded are named in section 4
with their sites). Law names are written `law <name>` in this README (the source comments carry the section sign). A
probe case is called a case throughout. The four slang-fenced tests are never named here; every driver reads them
from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails closed (section 10).

## 0. Verdicts (per cluster family; final round, `745f66ab` + law_typeemit.patch)

| family (map 13 clusters) | rule golden follows | law, ground, switch | row-modes | cases | away census |
|---|---|---|---|---|---|
| (a) the UVM_SEQ_ARB_TYPE importing-context family, both halves (N0778 N0582 N0900 N1424) | the enum typedef object's parent is its LAST writer in UhdmWriter::write's writeDataTypes order: packages (elaborated, then unelaborated), programs, interfaces, modules (by name), then the `$unit` classes (by name); the alias ref's name is ComputeFullName over it | law enumTdLastWriter214, B, `R11U214_SEQARBNAME_OFF` (+4 sub-switches) | no conversion; the object's every record matches on all nine UVM row-modes; heads: SeqDriver d/t, SimpleUVM d/t, Scoreboard d move (below) | grid A: 18 of 64 case-views convert (26 already equal at 745f66ab, pass 212 took the no-importer cells), 0 leave EQUAL; probe e08_explicit_import | 0 lost |
| (a') its class face: uvm_event_pool (N0540 N0689) and class-scope typedefs (N1910 N1911) | the same writer order for a specialization typedef Surelog aliases, and the package listing parenting a class-scope typedef it holds | laws classTdAliasLastWriter214 (`R11U214_CLASSTDW_OFF`), classScopeTdPkgListingParent214 (`R11U214_CLSSCOPETD_OFF`), B | SeqDriver d/t `fullname(61)` -> `endline(59)` (its head #10090 cleared) | grid C: 9 case-views convert; probe 12 conversions (11 + a8_single) and 15 changes onto a pre-existing structural record | 0 lost |
| (a'') the clone-formal copy (3 / 2 records of MiniAmiq / SeqDriver) | the clone's formal gets its own bare enum copy under the io_decl, at the formal's type token | law cloneAliasFormalOwnChain214, B (TaskFuncEmit), `R11U214_CLONENAME_OFF` | part of MiniAmiq d/t `file(75)` -> `file(73)` | - (the shape is stage 1 in small cases) | 0 lost |
| (b) Earlgrey's N0073, ground-B half | a folded `pkg::NAME` spans the qualifier (Package_scope node) | law modStructMemberQualSpan214, B (TypeEmit), `R11U214_QUALSPAN_OFF` | Earlgrey_0_1 d/t `endcol(45)` -> `endcol(39)` | grid B e03 (2 case-views) | 0 lost |
| (b) Rggen's N0727 | the override literal takes the dimension's file | law sizeDimOvrFileAtDim214 = pass 212's law sizeDimOvrFileAtDim212 (landed during this pass; dropped here) | Rggen d `file(4)` -> `file(3)` (round 1, section 2; now pass 212's) | grid B f01 (2) | 0 lost (round 1) |
| (c) N0682, the head of SimpleUVM d/t and Scoreboard d | the design listing's copy of a `$unit`-imported parameter owns its ref_typespec (no stored name) | law unitImportCopyOwnTsRef214, B (UhdmExporter), `R11U214_UNITCOPYTS_OFF` | SimpleUVM d/t `fullname(236)` -> `endline(135)`, Scoreboard d `fullname(188)` -> `endline(111)` (with the others) | grid D g01-g03; probe 11 changes shrinking | 0 lost |
| (c) N0151 (120 objects each on SimpleUVM and Scoreboard) | golden's extra refs ARE those copies' own refs | the same law | cleared | - | 0 lost |
| (d) N0691 N0692 (value INT vs UINT) | the design copy carries the package parameter's final value | law unitImportCopyValueFollowsPkg214, B, `R11U214_VALENC_OFF` | part of the SimpleUVM / Scoreboard moves | grid D (value records of the design copies); probe c5_clone, g201_* shrink | 0 lost |
| (e) the class-inherited array-variable copies (N0503 N0504 N0732 N0734 N0288) | the copy's element variables take the copy's name, its array typespec stays free | law importVarElemOwnName214, B (ModuleEmit), `R11U214_IMPVARELEM_OFF` | part of MiniAmiq / SeqDriver / SimpleUVM / Scoreboard | grid E k02 (2 case-views); probe 7 conversions (r10sd10 / r10sd6) + 2 shrinking | 0 lost |
| (c) the design param_assign's right-side copy (N0008 face) | golden clones the right side AS COMPILED | law unitImportPaRhsOwnCopy214 **WITHDRAWN** (its census read 3 stage-1 regressions, section 3.7) | - | - | - |
| (e) the svaunit clone return-variable names (N0480 N0485 N0510-N0516) | undecoded split (544 / 597 golden names by package) | no law (section 4.5) | - | - | - |
| (b) Earlgrey's N0073 ground-A half, Rggen's #23164, MiniAmiq #899, (f), (g), (h) rest | section 4 | no law | - | - | - |

**Final gates** (`tests/sweep.sh --jobs 3`, `745f66ab` + the patch, against the committed baselines): **probe
regressions=0 conversions=20 changes=35; surelog regressions=0 conversions=0 changes=9 (every one shrinking or
moving its first field to a record the pristine database already differs on); uhdm2rtlil 0 / 0 / 0; downstream
803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdicts identical row for row with the pristine sweep.**
No corpus row-mode converts: every UVM row still carries the sister's preprocessor-model and expression families,
Earlgrey its ground-A records, Rggen the Surelog rebinding (section 4). The byte movers (32 corpus databases, 62
probe databases) are exactly the frozen prediction; the away census reads 0 records lost (chain-keyed and flat)
against 2437 / 2355 toward golden, its reversed positive control 2437 lost; R11U214_OFF restores the pristine bytes
on all 118 case-views of the grid.

## 1. Binaries (frozen `chmod 555` before measurement)

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `1c73361d93c3e8341119c293b7d76ab1` | worktree at `6dcc0818`, system-deps config, `-j 2`: byte-identical to the main tree's build at that HEAD |
| `pristine.h` | `11b349f41c8453bbb85b792816e5e5a1` | worktree at `a727b8c7` (pass 210): byte-identical to the main tree's build then (round 1's pristine) |
| `law.h10` | `6c3130336f9390cd6bb4c9a9f42499d7` | `a727b8c7` + [evidence/round1_a727b8c7/law_typeemit_on_a727b8c7.patch](evidence/round1_a727b8c7/law_typeemit_on_a727b8c7.patch) (round 1: laws 3.1-3.3, 3.4, 3.6, the class sub-laws) |
| `pristine.p` | `8c724b6404258a8d5c9648ea1c376823` | worktree at `a727b8c7` + pass 212's verified patch (src only), built before pass 212 landed; **the landed `745f66ab`'s src diff equals it (`b880e626` both) and the main tree's `build/slang-uhdm` reads the same md5**: the final pristine |
| `law.p` | `b93adee2c95f456831518cd42a406081` | `745f66ab` + [evidence/round2_745f66ab/law_round2.patch](evidence/round2_745f66ab/law_round2.patch) (round 2: the rebased laws + importVarElemOwnName214) |
| **`law.fin`** | **`d80858c7b4b14233cac0c8cb53c30a45`** | **`745f66ab` + [law_typeemit.patch](law_typeemit.patch)**: the final law binary (rebuilt from the patched worktree after the withdrawal, byte-identical to the round-3 draft `law.p2` built before it) |
| `law.final` | `e5a592ee81e347a050bcd3cf0ba3076b` | law.fin + the withdrawn right-side law (its census read 3 regressions; evidence/withdrawn/) |
| `law.v2.g1` | `39f6d98983a69b066e99f08069ff3610` | `6dcc0818` + the first law draft with `-DCMAKE_CXX_FLAGS=-g1`: gdb pins on this pass's own cases only |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's `build/uhdm-strictcmp` (not edited: no comparator defect found) |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's variant (tools/probe/r11u211map/drivers/cc.sh): identical md5 to map 13's |
| `objrank` | `3e213a154aab7f619443de5f11646f0a` | map 13's drivers/objrank.cpp (gdb rank lookup) |

Sweeps (all 15-character workdirs, `tests/sweep.sh --jobs 3`): pristine `<scratch>/r11u214_pP` (745f66ab), law
`<scratch>/r11u214_fL`; every one of the 3273 `slang:` lines of the law sweep's `cmds.txt` names `law.fin` (and
of the pristine sweep `pristine.p`). Round 1: `<scratch>/r11u214_hP` / `_hL` (`pristine.h` / `law.h10`); round 2:
`_pP` / `_pL` (`law.p`). Every sweep's EXIT=1 is tests/LAWS.md's staleness alone (section 10); every compare
stage reads regressions=0.

## 2. Rounds and rebases

* **Round 1 (`a727b8c7` + law.h10)**: probe regressions=0 conversions=13 changes=19; surelog 0 / 0 / 12 (BuildUVMPkg
  d/t `endcol(57)` -> `(53)`, Earlgrey d/t `(45)` -> `(39)`, MiniAmiq d/t `file(77)` -> `(75)`, Rggen d `file(4)` ->
  `(3)`, Scoreboard d `fullname(193)` -> `(156)`, SeqDriver d/t `fullname(63)` -> `endline(61)`, SimpleUVM d/t
  `fullname(241)` -> `(180)`); uhdm2rtlil 0 / 0 / 0; downstream 803/66/2/0; 32 corpus + 39 probe byte movers =
  the frozen prediction exactly; away census 0 lost / 1529 toward (control 1529 lost).
* **Pass 212 landed** (`745f66ab`): its law sizeDimOvrFileAtDim212 is this pass's Rggen law (dropped from the patch),
  its law pkgEnumAliasListingParent212 the no-importer cell of 3.1 (BuildUVMPkg's N0778 and the grid's a05 / a08 /
  b01 cells are now pristine-equal; the rest of 3.1 composes, section 3.1). The patch was rebased (TypeEmit's
  declaration hunk and the fillSizeDimRange hunks re-cut) and applies clean on a fresh `745f66ab`.
* **Round 2 (`745f66ab` + law.p)**: probe 0 / 20 / 21; surelog 0 / 0 / 9; uhdm2rtlil 0 / 0 / 0; downstream
  803/66/2/0 ([evidence/round2_745f66ab/](evidence/round2_745f66ab/)).
* **Round 3 (final, law.fin)**: + law unitImportCopyOwnTsRef214 (the N0682 head). A draft also carrying the
  right-side copy law was caught by its own firing census (3 surelog stage-1 regressions) and withdrawn before the
  final census.

## 3. The decodes and the laws (per cluster family)

### 3.1 law enumTdLastWriter214 — the UVM_SEQ_ARB_TYPE importing-context family, both halves, one decode (N0778 N0582 N0900 N1424)

**Heads** (`uhdm-strictcmp --max 50`; raw names from the variant comparator, whose 15th column carries the name the
tool canonicalises to `<in>...` inside a typespec copy): the `ref_typespec` under uvm_pkg's enum alias `typedef
uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE;` (the enum_typespec copy's typedef-alias reference) reads, on every one of
its listings in one design, ONE golden name:

| row | golden (every record) | ours at 745f66ab (pristine) | with the law |
|---|---|---|---|
| BuildUVMPkg d/t | `uvm_pkg::uvm_pkg::UVM_SEQ_ARB_TYPE` (7) | the same since pass 212 (law pkgEnumAliasListingParent212) | the same |
| MiniAmiq d/t | `work@svaunit_vpi_interface.uvm_pkg::UVM_SEQ_ARB_TYPE` (24) + 3 clone-formal copies `svaunit_pkg::uvm_sequencer_base::set_arbitration::val::UVM_SEQ_ARB_TYPE` | `uvm_pkg::UVM_SEQ_ARB_TYPE` (28) | 25 + 3, every name golden's (one listing more: an identity record) |
| SeqDriver d/t | `work@top_tb.uvm_pkg::UVM_SEQ_ARB_TYPE` (21) + 2 clone-formal copies | 22 right, 2 bare (the first, #24900, and a twin) | 22 + 2, every name golden's |
| SimpleUVM d/t | `work@env::uvm_pkg::UVM_SEQ_ARB_TYPE` (15) | `work@top.` (15) | golden's (15) |
| Scoreboard d | `work@my_scoreboard::uvm_pkg::UVM_SEQ_ARB_TYPE` (11) | `uvm_pkg::uvm_pkg::` (11: pass 212 parents the parentless copy at uvm_pkg) | golden's (11) |

The same five rows' `uvm_event_pool` (N0540 / N0689, the class face below) read golden's importer name on every
record with the law (3 / 4 / 4 / 3 / 2 records; ours at the base `uvm_pkg::` or `uvm_pkg::uvm_pkg::`):
[evidence/final/name_tallies.txt](evidence/final/name_tallies.txt).

**Decode.** Surelog stores no full name on that reference: UHDM's generated `VpiFullName()` getter computes
`BaseClass::ComputeFullName` over the parent chain on first read (third_party/Surelog/third_party/UHDM/scripts/
classes.py, templates/BaseClass.cpp:100), so the name is the chain `ref -> enum_typespec 'uvm_pkg::UVM_SEQ_ARB_TYPE'
-> <its vpiParent>`, joined with `::` once a package or class_defn is on it and `.` otherwise. The enum object's
parent is written by `UhdmWriter::writeDataTypes(map, parent, .., setParent=true)` (third_party/Surelog/src/
DesignCompile/UhdmWriter.cpp:775, `if (setParent) tps->VpiParent(parent);` :803) for every datatype of the
component's DataTypeMap, and `UhdmWriter::write` (:4840) calls it in a fixed order: the elaborated packages
(`writePackage(pack, p, s, true)` :4993, getOrderedPackageDefinitions), the unelaborated packages (:5028), the
programs (:5043), the interfaces (:5071) and the modules (:5100), each loop over getModuleDefinitions (a std::map by
name), and LAST the compilation-unit classes (:5181, `writeClass(classDef, v4, s, d)` :5190 for a class with no
package parent; getClassDefinitions is a multimap by name). A component's DataTypeMap holds what
`CompileHelper::importPackage` (CompileHelper.cpp:127, `insertDataType` :168) copied into it: a package or design
element by its own `import`, a class by its FILE's import items and its container's (CompileClass.cpp:140-158). The
LAST writer owns the object for the whole design, so the seven contexts of the brief read:

| context (grid cases/A) | golden name of the alias ref | what decides it |
|---|---|---|
| (i) the package's own subroutine io_decl, (ii) a package class method, (iii) a class variable, with no importer (a05 a07 a08 b01) | `p::p::ALIAS_T` | the elaborated home package is the only writer (the unelaborated listing never holds an alias) |
| (iv) a module importing the package (a06 a11 a13 b05 c02) | `work@<module>.p::ALIAS_T`, the module last by NAME (a13: `zz` over `aa`) | modules write after packages and interfaces |
| an interface importing it (a09 b03 c04 = MiniAmiq's svaunit_vpi_interface) | `work@<ifc>.p::ALIAS_T` | interfaces write after packages; a module importer wins over it (a15) |
| (vi) a second package importing it (a10 b02 c01) | `q::p::ALIAS_T` | packages write in dependency order; a class inside q is NOT the last writer (c01: the unelaborated q is written after the elaborated q's classes) |
| a `$unit` import with a `$unit` class (a12 b04 c03 c05 = SimpleUVM's env, Scoreboard's my_scoreboard) | `work@<class>::p::ALIAS_T`, the class last by name (c03: `zz_c`) | classes write after every module |
| an explicit `$unit` import of a literal (c06) | `p::p::ALIAS_T` | `importPackage` copies only the named item (CompileHelper.cpp:166) |
| (v) a package parameter's typespec, (vii) a copy the importer holds | the same object, the same name | one object per alias in golden |

The same rule names the base-type ref of a non-alias package enum with an explicit base (`typedef enum logic [1:0]
{..}`, grid b01-b05: `q::p::mode_e`, `work@env::p::mode_e`) and the typedef-alias ref of a CLASS specialization
typedef Surelog aliases to an earlier one (uvm_pkg's `uvm_event_pool` -> `uvm_barrier_pool`, map 13's N0540 / N0689,
grid cases/C i01-i05), and the parent of a class-scope specialization typedef the package listing holds (N1910 /
N1911, grid C j01-j04, 13 probe cases).

**Ours.** law enumImportParentLastWriter180 (ModuleEmit) models the interface and module writers of an enum object from
the AST; nothing models the package writers (an import clone and an alias object are left without a parent: `p::` in
a10, b02) or the `$unit` class writers (ours kept the module: `work@top.` in a12); the interface branch re-scopes the
base ref but not the alias ref (a09); and an enum alias is up to three objects of ours (the definition-view object, the
elaborated one, the import clone: the twin a formal binds stays parentless, SeqDriver's #24900, c04).

**The law** (UhdmExporter.cpp, design-final right after enumImportParentDrain180, ground B): replay the listing
writers on our own listings (the judge compares every listing, so ours list what golden lists): for each package enum
object (one unit per object; the objects of one enum-ALIAS typedef form one unit) the winner is the last `$unit`
class listing it (by AllClasses order), else the interface / module the 180 drain parented it at, else the last
package listing it (TopPackages, then AllPackages); the objects take the winner as parent and their base / alias refs'
stored full names the ComputeFullName of the new chain. Sub-switches: `R11U214_ENUMPKGW_OFF` (package writers),
`R11U214_ENUMCLSW_OFF` ($unit class writers), `R11U214_ENUMALIASGRP_OFF` (an alias's objects moved as one),
`R11U214_ENUMALIASNAME_OFF` (an interface-parented alias's alias-ref name refreshed), `R11U214_CLASSTDW_OFF` (law
classTdAliasLastWriter214: the class specialization-alias typedefs, with the interface and module listings replayed
too since no pass of ours parents a class typedef there), `R11U214_CLSSCOPETD_OFF` (law
classScopeTdPkgListingParent214: a class-scope typedef held by its package's listing parented at the package, the
stored names of its own parameters moved with the chain); `R11U214_SEQARBNAME_OFF` drops the whole function.
Composition with pass 212's law pkgEnumAliasListingParent212 (typedefParentModel134, later): that law parents an alias
copy left parentless at its package; this one runs first and parents every alias copy, so the later law fires only
with this one switched off (grid a05 a08: either law alone gives `p::p::ALIAS_T`).

### 3.2 law cloneAliasFormalOwnChain214 — the clone-formal copy (the second half of the UVM_SEQ_ARB_TYPE records; family (e))

Golden MiniAmiq / SeqDriver hold 3 / 2 more records of the name `svaunit_pkg::` / `adpcm_pkg::uvm_sequencer_base::
set_arbitration::val::UVM_SEQ_ARB_TYPE`: the importing package's clone of uvm_pkg's out-of-block method
`set_arbitration(UVM_SEQ_ARB_TYPE val)` gets its OWN bare enum copy per formal (compileTfPortList compiles the type in
the subroutine; populateCoreMembers(type, type, ts) places it at the formal's type token, uvm_sequencer_base.svh
1381:51-67), under the io_decl, with its own alias ref (no stored name). Ours already mints the bare copy (law 
importCloneAliasEnumBareName36 / aggImportCloneCopy32) but shares the listing object's alias ref (stored importer name)
and keeps the base typedef's span. The law (TaskFuncEmit, the alias-of-alias branch) parents the copy at the io_decl, gives
it a private alias ref to the same target and the type token's span and file. No small case reaches this branch judge-
equal (an out-of-block class method definition in a small package is stage-1 unequal at the base: cases A a02 a03), so
it is measured on the two UVM rows only (section 5: every record of the name matches; ours keeps one extra listing of
the shared object, 25 vs 24 / 22 vs 21 records, an identity family).

### 3.3 law modStructMemberQualSpan214 — Earlgrey's N0073, the ground-B half

Earlgrey_0_1's first records at the base (endcol(45)): 12 folded constants of a package-qualified name spanning the
QUALIFIER in golden (`dm::` 91:52-56, `top_pkg::` 56:12-21) where ours spans the whole name. Surelog's
compileExpression folds a `paPackage_scope` reference in elaboration mode by cloning the package parameter's value
and locating it with `fC->populateCoreMembers(child, child, result)` on the Package_scope node (CompileExpression.cpp
:2748), which spans `pkg::`. Pinned with gdb on our own cases (evidence/decode/pins_qualspan.txt):
* the struct member range bound inside a module-declared typedef (tlul_adapter_sram.sv:56-57, 6 records) is TypeEmit
  `modStructMemberPkgSubst9` < `emitSyntaxExpr` (the qualified spelling of law modStructMemberPkgFold): ground B, this
  law anchors it at the scope qualifier (the ScopedName's `::` token), grid B e03 converts in both views;
* the module localparam initializer operands (dm_csrs.sv:91-92 `dm::dm_csr_e'((dm::Data0 + {4'b0, dm::DataCount}))`,
  dm_mem.sv:64-67 `(dm::DataAddr + 4*dm::DataCount)`, 6 records) are ExprEmit `emitExpr` < ParamEmit `emitParameters`:
  ground A, the nested-operand generalisation of law pkgQualFoldSpanByView124 / law enumQualDefaultDefSpan147 (which fire
  only on a WHOLE initializer); grid B e01 reproduces it in both views; no law written here (the sister's file).

### 3.4 law unitImportCopyValueFollowsPkg214 — the value-encoding face N0691 / N0692 (family (d))

Scoreboard d / SimpleUVM d/t: the design listing's copies of `$unit`-imported `UVM_LARGE_STRING` / `UVM_SMALL_STRING`
(`parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1`, untyped) read `INT:115199` / `INT:959` in golden and
`UINT:` in ours, while the package's own elaborated parameter reads `INT:` on both sides. Decode (gdb on our own case
D/g01, evidence/decode/valenc_writers.txt): the package parameter is written `UINT:` at emission (ParamEmit
emitParameters), the `$unit` hoist (law unitImportHoistsPkgParams146, UhdmExporter designImportParamCopy146) copies that
value into the design's vpiParameter entry and its param_assign's Lhs, and only then does law paramValueIsDefRhs124
(ParamEmit, design-final) rewrite the package's object to its Rhs constant's `INT:` encoding. Surelog's importPackage
copies the parameter the package already holds (CompileHelper.cpp:127), whose value is the definition's. The law
(UhdmExporter, after drainShareDefParamTs, ground B) syncs every `vpiImported` copy in the design listing (and its
param_assigns' Lhs) to the elaborated package parameter's final value, the first same-named parameter winning as
importPackage's map keeps the first. Grid D g01: the design copies convert (`value=6 -> 4`); what is left there is
the module's own imported copies (`work@top.L` without a value in the definition view: map 13's N0685 / N0827,
ParamEmit emitParameters, ground A) and the ref_typespec names `p::W` vs `W` (N0682, ground A).

The rest of family (d), decoded without a law here:
* r11u204's B3 named / empty-slot omission (the missing formal read as `INT:0` and the call folded): decoded in full
  by r11u205 section 4.1 (CompileHelper::compileTfCallArguments :4524-4560, ExprEval::evalFunc); the fold is ExprEmit's
  `constCallFold` (ground A) and the downstream faces DF/e06 e08 stay IDENTICAL on the kept call;
* N0742 (Earlgrey 1 record, 16 probe cases, `value|constant|UINT->UINT+decompile|under:range`): the `sha_word_t`
  range bound of a typedef moved to a use site (the same record carries N0141 / N0696 / N0697: hmac_pkg.sv 17 vs
  sha2.sv 27), the writer-order family of MiniAmiq #899, not a value encoder;
* N0853 (OutputSize...'s `BIN->UINT` constant under a cont_assign): ModuleEmit emitContAssigns, pass 43's
  unbased-fill law; carried by map 13's pair-B route, not reached.

### 3.5 law importVarElemOwnName214 — the class-inherited array-variable copies (N0503 N0504 N0732 N0734 N0288; family (e))

A class inherits its container's and its file's imports (CompileClass.cpp:140-158), and Surelog re-elaborates each
imported package VARIABLE as the class's own declaration: golden names the copy of `uvm_random_seed_table
uvm_random_seed_table_lookup [string]` `work@my_scoreboard::` / `svaunit_pkg::svaunit_sequencer::
uvm_random_seed_table_lookup` on the array variable AND on its element class_var and that var's ref, and leaves the
array typespec a free object (its index-type ref unnamed). Ours (ModuleEmit `importVarCopy5` <
`classInheritsContainerImports23`) deep-clones the package's array variable with `clone_tree`, renames only the array
variable and its own ref, keeps the element's cloned `uvm_pkg::` name, and parents the cloned array typespec at the
copy's ref (so its index ref read the copy's name). Grid E: k02 (a class of an importing package) converts in both
views; k01 (a `$unit` class) keeps one record family unrelated to the names (the importing module's int-array element
typespec ending at the type keyword, `5:3-5:6` vs golden's `5:3-5:20`, also k03-k05 at the base). Switch
`R11U214_IMPVARELEM_OFF`.

### 3.6 law sizeDimOvrFileAtDim214 — Rggen's N0727: superseded by pass 212

Rggen d's head at 6dcc0818 (`rggen_apb_adapter.sv 18:39-48` the interface-array bound `register_if[REGISTERS]`
overridden by `.REGISTERS(25)` in block_0.sv; golden the dimension's file, ours the literal's): ModuleEmit
fillSizeDimRange re-located the override literal with setLoc, which fills a file only when empty. This pass wrote the
law (grid B f01, a two-file case, converts in both views; measured in round 1, section 6) and pass 212 landed the
same rule at the same two sites as law sizeDimOvrFileAtDim212 while this pass ran; the rebased patch drops it.

### 3.7 law unitImportCopyOwnTsRef214 — the head of SimpleUVM d/t and Scoreboard d (map 13's N0682)

SimpleUVM #458 and Scoreboard #466 at the base: uvm_pkg's own param_assign `UVM_MACRO_EXTRAS = ... UVM_MACRO_NUMFLAGS
...` reads a `ref_obj UVM_MACRO_NUMFLAGS` whose actual is the DESIGN listing's copy of the parameter (a `$unit`
`import uvm_pkg::*;` hoists every package parameter into the design, law unitImportHoistsPkgParams146, and Surelog's
lateBinding reaches that copy first, law unitImportHoistsPkgParams146v); the copy's `ref_typespec` reads
`UVM_MACRO_NUMFLAGS` in golden and `uvm_pkg::UVM_MACRO_NUMFLAGS` in ours (81 objects on Scoreboard: `UVM_SET`,
`UVM_LINE_WIDTH`, ...). Pass 210 listed the family as "ModuleEmit importPaCopy82" (not attempted) and map 13 pinned
it to ParamEmit emitParameters; the object the head record is is UhdmExporter's `designImportParamCopy146`, which
builds the design copy SHARING the package parameter's ref (`cp->Typespec(sp->Typespec())`, with its stored
`uvm_pkg::` name) where importPackage's copy is a new parameter with its own ref, on which Surelog stores no name, so
ComputeFullName reads the copy's chain: the bare name under the design. The law (UhdmExporter, design-final after
drainShareDefParamTs, ground B): a design copy still sharing its source's ref takes a private ref to the same actual,
unnamed (evidence: the `UVM_MACRO_NUMFLAGS` ref records of SimpleUVM default are golden's multiset exactly with the
law, the int_typespec record count moves 5295 -> 5341 = golden's 5341). Grid D g01-g03 (a `$unit` wildcard import,
with a `$unit` class, an explicit import of one parameter): the ref-name records convert and g02's and g03's
structural records vanish with them (the private ref gives the walk golden's object); what is left there is the
module's own imported copies without a value (map 13's N0685 / N0827, ParamEmit, ground A) and the right-side half
below. The rows' new first record is the macro method-call span (`phase_state_change`, uvm_callback_defines.svh
168:11-29 vs ours -169:9: the preprocessor model family F1, the sister's). Switch `R11U214_UNITCOPYTS_OFF`.

**The right-side half, WITHDRAWN (law unitImportPaRhsOwnCopy214).** The design param_assign's right side is a
clone_tree copy in golden (its refs read the design chain: empty, grid D g01 `#277`-`#312`), ours shares the package's
(`p`). A law cloning our elaborated package right side into the design param_assign converted g01's records but the
firing census of its binary read three surelog REGRESSIONS (SimpleUVM d/t, Scoreboard d at stage 1): golden's copy
is the right side AS COMPILED (an unsized based literal `'hf000000` keeps size -1 and a ref_typespec with no actual)
while ours cloned the elaborated object (size 32, an int_typespec actual). It was removed before the final census and
sweep ([evidence/withdrawn/unitparhs_stage1_break.txt](evidence/withdrawn/unitparhs_stage1_break.txt)); writing it
needs the unelaborated right side (map 13's N0008, 45 objects on Scoreboard, is the same face).

## 4. Decoded without a law (the rule, the site, and why no law here)

### 4.1 Earlgrey_0_1 after the laws (family (b))

Its first records at `745f66ab` (map 13's analyzer and ids, [evidence/final/clusters_final.txt](evidence/final/clusters_final.txt)):
N0073 was 72 objects in the default database, 60 of them the struct-member range bounds this pass's law
modStructMemberQualSpan214 anchors (tlul_adapter_sram.sv and its copies; ground B), and 12 the module localparam
operands (dm_csrs.sv:91-92, dm_mem.sv:64-67): **ground A** (pinned: ExprEmit `emitExpr` < ParamEmit
`emitParameters`, the nested-operand extension of law pkgQualFoldSpanByView124 / law enumQualDefaultDefSpan147, grid B
e01 in both views, not written here). The next records are ground A too (N0001 / N1023 / N1012: the `dmi_req_i.addr[..]`
hier_path in dm_csrs 362 / 417; N0812 / N0415 / N0807: indexed-part-select base names) with ground-B clusters further
in: N1184 / N1181 (ours-only definition cont_assign copies, ModuleEmit), N0525, N0040 (the logic typespec span,
map 13's harness-flag cluster), N0727 (`datasize: dm::DataCount` in rv_dm.sv:100, a folded pattern member whose file
is the package's: the same setLoc-keeps-the-file mechanism as sizeDimOvrFileAtDim212 in another mint, the pattern
member fold; not pinned here).

### 4.2 Rggen d: `file(3)`, a Surelog rebinding (pass 212's residue 3, confirmed)

`#23164`: the elaborated modport io_decl `address` of `rggen_bus_if`, whose logic_var's typespec golden holds as the
function FORMAL's (`rggen_adapter_common.sv 43:5-10`, the unfolded `[ADDRESS_WIDTH-1:0]` of `pre_decode(logic
[ADDRESS_WIDTH-1:0] address)`) where ours holds the interface's own declaration (`rggen_bus_if.sv 9:3-28`, folded to
15): the call `pre_decode(bus_if.address)` re-types the actual's variable with the formal's typespec (a shared object
mutated by the call binder). The other two records are that object's range and bound (operation vs constant). No law:
it needs the binder's mutation of a shared interface variable.

### 4.3 Scoreboard d, the nearest real row (family (c))

After the laws Scoreboard d reads `endline(111)` (section 5): its first records are now the macro method-call spans
(`phase_state_change` 168:11-29 vs ours 168:11-169:9; `get_full_name` in uvm_message_defines.svh 116 vs ours from
115:89 to 1346), map 13's F1 preprocessor-output family (UhdmExporter's pp166 model and ExprEmit's call spans: the
sister's, decoded by r11u166). Per named cluster:

| cluster | the rule golden follows | status |
|---|---|---|
| N0007 (hier_path ref name, golden empty) | the UVM records are ExprEmit's `parensLessCallIsPathRefObj` mint (map 13 section 1.5) | ground A, not written |
| N0008 (45 objects: a design-level param_assign constant's ref_typespec named `uvm_pkg` where golden stores none) | the same shared-object face as law unitImportPaRhsOwnCopy214, which was WITHDRAWN (section 7): golden's design copy clones the right side as compiled (an unsized literal keeps size -1 and a ref with no actual), ours the elaborated package object | open: the copy must be built from the unelaborated right side |
| N0151 (120: golden's extra ref_typespec copies of `UVM_CHECK_FIELDS` read in the field-automation calls) | golden gives each read of a package parameter in a `__m_uvm_field_automation` call its own copy of the parameter (clone_tree per reference); ours shares the one object | identity: needs copying objects golden holds per use; no law |
| N0447 (`uvm_analysis_port` param_assign, golden no file) | the class specialization's param_assign is compiled without a FileContent (Surelog writes no file) | ModuleEmit / UhdmExporter `copyClassTdSpecParams1`; not written |
| N0458 / N0144 / N0321 (enum typespec file `uvm_globals.svh 532:52-53` vs ours `uvm_object_globals.svh 147`) | the enum typedef relocated to the last subroutine-formal writer (the MiniAmiq #899 family below) | not written |
| N0467 (ours-only array_typespec copies) | ours mints a per-use array typespec where golden shares | identity; no law |
| N0691 / N0692 (value INT vs UINT) | **law unitImportCopyValueFollowsPkg214** | converted |
| N0732 / N0734 / N0288 (`uvm_random_seed_table_lookup`'s class copy names) | **law importVarElemOwnName214** | converted |
| N1424 (UVM_SEQ_ARB_TYPE via my_scoreboard) and N0689 (uvm_event_pool) | **law enumTdLastWriter214** (+ classTdAliasLastWriter214) | converted |
| N0682 (UVM_MACRO_* names, the row's old head) | **law unitImportCopyOwnTsRef214** | converted |

### 4.4 MiniAmiq #899: the enum typedef's formal writer order (MiniAmiq's head; BuildUVMPkg #3245's family)

Golden relocates `uvm_pkg::uvm_severity` to `uvm_globals.svh 271:61-73`, the type token of the LAST package-level
subroutine formal typed by it (`uvm_string_to_severity(string sev_str, output uvm_severity sev)`,
CompileHelper::compileTfPortList `populateCoreMembers(type, type, ts)`), and a second object to
`uvm_sequence_item.svh 352:37-49` (a class method formal); ours relocates in SeqDriver / SimpleUVM / Scoreboard but
never in MiniAmiq (194 records at the declaration 242:1-248:16). The struct / union branch of that relocation is ParamEmit
`emitPackage`'s (pkgImportAggCloneLastWriter32 family: ground A); pass 212 and r11u205 (section 4.3) left it "not
attempted / decoded, no law". Not written here either: the branch lives in ParamEmit.

### 4.5 The svaunit class-method clone names (family (e): N0480 N0485 N0510-N0516 N0467 N0478 N0479)

The clone of a uvm_pkg out-of-block class method in an importing package (`svaunit_pkg::uvm_object::get_name`) lists
a return variable golden names by EITHER package: of the 1141 golden clone return variables in MiniAmiq default, 544
read `uvm_pkg::<class>::<method>` and 597 `svaunit_pkg::...` (by kind: bit_var 160 / 57, class_var 186 / 261, int_var
96 / 69, string_var 56 / 90, and every enum / integer / real / long_int one `uvm_pkg::`), where ours names all 1413
`svaunit_pkg::` and holds more of them (N0480 / N0510: ours-only copies). The split is not the kind, the class or the
return type alone (evidence/decode/clone_retvar_split.txt); golden's comment in our own source (ParamEmit, the
class-method clone loop: "Surelog mints a fresh one ... two objects") is the r10uvm3 measurement. Undecoded here;
site: TaskFuncEmit `emitTaskFuncs` (the return var's `fullName`) under ParamEmit `emitImportedPkgClassMethodClones`.
N0478 / N0479 (golden's extra type_parameter / class_typespec copies under a param_assign): the class specialization
copies golden makes per use (identity family). The clone FORMAL copy of the UVM_SEQ_ARB_TYPE alias is this pass's
law cloneAliasFormalOwnChain214 (section 3.2).

### 4.6 Pass 209's hand-offs on ground B (family (f))

Pass 212 (pair B) took pass 209's hand-offs in its brief; at `745f66ab` its README lists as not attempted: the scalar
/ enum typedef formal writer order (4.4), the svaunit clone names (4.5), the class param_assign copies in
importPaCopy82, OutputSize, cfg_func_width_loop, struct_param_func_config. Of pass 209's own list (the kept-reduced
connection operation, the genvar-based indexed part-select target, the two-dimension port declaration, the
redeclared-typedef port, the non-logic modport view object, the zero-width var local, the unfolded generate-connection
index text) none is reached by this pass's laws (no firing in the census on any row they head); not re-decoded.

### 4.7 r11u213's under-reaches of pass 206's laws (family (g))

Re-run at `745f66ab` with the pristine binary (tools/probe/r11u213verify/cases, both views,
[evidence/decode/underreach_745f66ab.txt](evidence/decode/underreach_745f66ab.txt)): TC/c02, TC/c06, TA/a02, TA/a05,
GV/v04, GV/v07, NC/n04, NC/n05 are judge-unequal (stage 1) in both views; TC/c03 is `endline` (parse view, rc 4) and
stage 1 (elaborated); TA/a03 `endline` in both; TC/c05 is now STRICT_EQUAL in both views (moved by a landing since
r11u213). A reach extension is a name/span law; on the stage-1 cases the first difference is a judged field, so
extending the law cannot be measured on them, and no case shows the law's own field as its first difference. Not
extended.

### 4.8 The probe-only OPEN clusters of ground B (family (h))

* N1910 / N1911 (14 cases each, UhdmExporter `emitClassTdSpecParams1`): **law classScopeTdPkgListingParent214**
  clears the name records of all 14 (`pk8use::pk8use::sid8::Q`): a8_single converts, g19_builtin moves to its
  pre-existing file record, and the other 12 move to the structural record each already carried (`depth(1)` at
  #48 / #83 / #46 / #50 / #35 / #38 / #33, identical index in the pristine database: an unmasking, section 5).
* N0094 / N1899 (30 cases each after r11u205's law, landed by pass 209): the rest are other writers
  (pkgTdOfNamedDimsListing111 / defPkgMemberTdOfNamedShares108), as r11u205 found; not re-decoded.
* N1905 / N1906 / N1907 / N1908 (14-17 cases, the package vector typedef with named dimensions and its interface
  listing: TypeEmit makeTypespec < ParamEmit / ModuleEmit): not attempted.
* The seven r10sd10 / r10sd6 cases **law importVarElemOwnName214** converts (section 5) were not in map 13's probe-only
  ranking (their clusters carry UVM rows).

## 5. The gates (final round: `745f66ab` + law_typeemit.patch; [evidence/final/](evidence/final/))

1. **Builds**: `pristine.p` `8c724b640425` (= the main tree's build of `745f66ab`), `law.fin` `d80858c7b4b1`.
2. **Probe** (`tests/sweep.sh --corpus probe` stage): `EQUAL 3430 / STRICT_NOTEQUAL 657` against the baseline's
   3410 / 677: **regressions=0 conversions=20 changes=35**. The 20 conversions by law (each case re-run with every
   switch alone): law importVarElemOwnName214 7 (r10sd10repro g1_assoc_class_elem_import, g1_assoc_index_import,
   g2_dynarray_elem_import, g3_dynarray_class_elem_import, v1_fixedarray_elem_import, v3_elem_class_of_importing,
   r10sd6repro v8_unpacked_sel); law classTdAliasLastWriter214 11 (r10uvm202repro g202_e_head, r10uvm206repro
   g206_b_dedup, r10uvm49repro a3 a4 a5 a6, r10uvm50repro a1 a7, r10v136repro v136_g_param, r10v202repro
   v202_6_twotd, r10v206repro v206_d_selfname); law classScopeTdPkgListingParent214 1 (r10uvm112repro a8_single);
   law enumTdLastWriter214's package writer 1 (r11u111repro/grid/f5/e08_explicit_import). The 35 changes: 15 move
   their first field to a STRUCTURAL record (`depth(1)`) and 5 to a `value` / `file` record that the pristine
   database already carried at the same index with the same field (checked record by record,
   [probe_changes_unmasking_check.txt](evidence/final/probe_changes_unmasking_check.txt): the name records in front
   of them are gone, the structural and value records are pre-existing); the other 15 keep their first field with
   a smaller count (fullname 215 -> 210 ... 4 -> 1, value 7 -> 3). No change GAINS a structural record, and 15 LOSE
   the one the pristine database carried (`depth=1 type=1 ... (walk diverged)` in the pristine tally, gone with the
   law: every `$unit`-hoist case of r10uvm201 / r10uvm210 / r10uvm67 c5_clone / r10v146 / r10v199 / r10v201): the
   private design-copy ref gives the walk golden's object.
3. **Corpora** (`--corpus "surelog uhdm2rtlil"`): surelog **regressions=0 conversions=0 changes=9**:

   | row-mode | pristine (745f66ab) | law | laws |
   |---|---|---|---|
   | Earlgrey_0_1 default / testflags | `endcol(45)` | `endcol(39)` | modStructMemberQualSpan214 (the 6 tlul_adapter_sram constants) |
   | MiniAmiq default / testflags | `file(75)` | `file(73)` | classTdAliasLastWriter214 (#10107 uvm_event_pool), enumTdLastWriter214 |
   | Scoreboard default | `fullname(188)` | `endline(111)` | unitImportCopyOwnTsRef214 (the head, N0682), enumTdLastWriter214, classTdAliasLastWriter214, unitImportCopyValueFollowsPkg214, importVarElemOwnName214 |
   | SeqDriver default / testflags | `fullname(61)` | `endline(59)` | classTdAliasLastWriter214 (the head #10090) |
   | SimpleUVM default / testflags | `fullname(236)` | `endline(135)` | as Scoreboard |

   BuildUVMPkg d/t `col(51)` and Rggen d `file(3)` move bytes only (the package writer re-parents objects whose
   names were already golden's). uhdm2rtlil 0 / 0 / 0 (12 databases move bytes only: PackageCast,
   TypedefAliasInPackage, TypedefEnum, VarPassedTo2Submodules, ibex_branch_predict, ibex_decoder in both modes).
   Per-law attribution (drivers/attrib.sh: the law binary re-run on these rows under each switch alone,
   [evidence/final/attribution.txt](evidence/final/attribution.txt)): `R11U214_OFF` restores every pristine cell
   (Earlgrey `endcol(45)`, MiniAmiq `file(75)`, Scoreboard `fullname(188)`, SeqDriver `fullname(61)`, SimpleUVM
   `fullname(236)`); alone, `R11U214_QUALSPAN_OFF` gives Earlgrey back its 6 records; on MiniAmiq
   `R11U214_CLASSTDW_OFF` and `R11U214_ENUMALIASGRP_OFF` each give back one record (`file(74)`), the umbrella two;
   on SeqDriver `R11U214_CLASSTDW_OFF` restores the head (`fullname(60)`) and `R11U214_ENUMALIASGRP_OFF` one record;
   on Scoreboard `R11U214_UNITCOPYTS_OFF` restores the head (`fullname(151)`), `R11U214_CLASSTDW_OFF` gives `(142)`,
   `R11U214_ENUMCLSW_OFF` `(148)`; on SimpleUVM `(175)`, `(166)` and `(196)` likewise. VALENC, IMPVARELEM and
   CLONENAME move records past the tool's walk divergence on these rows (their strict cells are unchanged when they
   are switched off; the analyzer and the away census see them).
4. **Downstream** (`--corpus downstream`): **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**, the
   verdicts identical to the pristine sweep row for row; the six uhdm2rtlil downstream lanes whose slang database
   moves (the six tests above) keep byte-identical RTLIL (`*_nohier.il` and `*.il` of the slang lane). The 59 case
   dirs of this pass through the gate's own `one()` (fresh GOLDEN_CACHE, both binaries): 59 IDENTICAL on both.
5. **uhdm-cmp** on every touched row: 0 lines (every changed row stays STRICT_NOTEQUAL, i.e. judge-equal).
6. **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, on hard-link mirrors without the 8 fenced
   row-mode databases): `PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS 32 / 2560**, SELFCHECK 2559 / 2560 flagged
   (the fixed reference file equals itself). Canary battery: section 5.1.

### 5.1 Canaries

`tools/probe/r11u107repro/canaries.sh` on the law sweep: surelog **ok=45 changed=7 absent=0 unknown-names=7** (the
seven changed canaries are exactly seven of the nine CHANGE lines of the gate: Earlgrey_0_1 d/t, SimpleUVM d/t,
SeqDriver d/t, Scoreboard d; MiniAmiq is not a canary; the pristine sweep reads ok=52 changed=0 against the same
baseline, so the canary list sees the laws), uhdm2rtlil **ok=16 changed=0**; `EXPECT_UNKNOWN=1 ctcan2.sh
results/golden_surelog.csv` **PASS** (ok=58 changed=0), `EXPECT_UNKNOWN=6 ctcan2.sh results/golden_uhdm2rtlil.csv`
**PASS** (ok=2 changed=0) ([evidence/final/canaries.txt](evidence/final/canaries.txt)).

## 6. Movers, predicted by name before the law sweep

The firing census (drivers/census.sh: the law binary with `R11U214_TRACE=<dir>` over every non-fenced row-mode and
every probe case) was reduced to a prediction by drivers/predict.py and frozen with its md5 before the gate sweep:
[evidence/final/census/prediction.txt](evidence/final/census/prediction.txt) (md5 `2eac7a8023c8e669487bc49cb3c2ab12`,
stamped 17:37:59, the law sweep started 17:38): **94 predicted movers = 20 surelog + 12 uhdm2rtlil row-modes + 62
probe cases**. The sweep's byte movers are **exactly** that set: 32 / 32 corpus databases (byteverify) and 62 / 62
probe databases, none unpredicted, none predicted and unmoved
([prediction_vs_movers.txt](evidence/final/prediction_vs_movers.txt)). Round 1 read the same (32 + 39 = 71 / 71).
Per law (census firings): ENUMPKGW on 23 row-modes (Earlgrey d/t 8, BuildUVMPkg d/t 4, EnumVar, PackedEnumPort,
TypedefPack, Rggen d, the six uhdm2rtlil tests: one firing each), ENUMCLSW 33 on SimpleUVM d/t and Scoreboard d,
ENUMALIASGRP on MiniAmiq, SeqDriver and BlackBePipeInt (d/t, bytes only), ENUMALIASNAME 3 on MiniAmiq, CLASSTDW 60 /
26 on the four UVM rows, CLONENAME 2 on MiniAmiq and SeqDriver, IMPVARELEM 24 / 10 / 4 on MiniAmiq / SeqDriver /
SimpleUVM and Scoreboard, VALENC 4 and UNITCOPYTS on SimpleUVM and Scoreboard, QUALSPAN 2 on Earlgrey.

## 7. The away-moved-record census (map 13's method, raw full names)

drivers/awayrows.py is map 13's awayrows.py with one change: its records are the variant comparator's and the
full-name field is the RAW full name, since a name moved inside a canonicalised typespec copy (every law of family
(a)) prints `<in>...` on both sides of the tool's own record. Over the 94 databases that differ between the pristine
and the law sweep: **0 records lost, chain-keyed and flat**; 2437 records toward golden chain-keyed (2355 flat). The
reversed comparison (the law sweep as the "off" side), the positive control, reads **2437 lost**
([away.txt](evidence/final/away.txt), [away_control_reversed.txt](evidence/final/away_control_reversed.txt)). By
database (toward, chain-keyed): SimpleUVM d/t 479 each, Scoreboard d 406, MiniAmiq d/t 192 each, SeqDriver d/t 141
each, Earlgrey d 69 / t 23, then the probe cases (g201_c_uvmshape 36, v201_c_localparam 17, ...). Round 1: 0 lost,
1529 toward, control 1529.

## 8. The UVM rows: first records, distances, families

**First records** ([first_records.txt](evidence/final/first_records.txt)):

| row-mode | pristine (745f66ab) | law |
|---|---|---|
| MiniAmiq d/t | #899 `file` uvm_severity (the formal writer order, 4.4) | #899 unchanged (its #10107 uvm_event_pool record cleared) |
| SeqDriver d / t | #10090 / #10102 `fullname` uvm_event_pool | #11289 / #11301 `endline`: the macro method-call span (F1, the sister's) |
| SimpleUVM d / t | #458 / #470 `fullname` UVM_MACRO_NUMFLAGS | #11376 / #11388 `endline`: the macro method-call span |
| Scoreboard d | #466 `fullname` UVM_MACRO_NUMFLAGS | #11384 `endline`: the macro method-call span |
| BuildUVMPkg d/t | #26067 `col` (ground A) | unchanged |

After this pass the first record of every UVM row-mode but MiniAmiq's is the preprocessor-output span family
(UhdmExporter's pp166 model with ExprEmit's call spans: the sister's), and MiniAmiq's is the formal writer order.

**Order-blind distance** (drivers/uvmdist.sh = map 13's, canonical records; drivers/uvmdistraw.sh with raw names;
dist = records ours holds that golden lacks, total = both directions):

| row-mode | pristine dist / total | law dist / total | pristine raw dist / total | law raw dist / total |
|---|---|---|---|---|
| MiniAmiq d/t | 6528 / 14780 | 6510 / 14744 | 8332 / 18388 | 8164 / 18052 |
| SeqDriver d/t | 5071 / 10928 | 5062 / 10910 | 6400 / 13586 | 6271 / 13328 |
| SimpleUVM d/t | 1983 / 3812 | 1876 / 3478 | 3245 / 6336 | 2888 / 5502 |
| Scoreboard d | 1453 / 2829 | 1362 / 2527 | 2361 / 4645 | 2077 / 3957 |
| BuildUVMPkg d/t | 713 / 1371 | 713 / 1371 | 812 / 1569 | 812 / 1569 |

(the pristine figures equal pass 212's published ones.)

**Family census** (r11u175's uvmcensus.py through map 13's uvmcensus9.sh, the analyzer on the five default
databases, [evidence/final/uvmcensus/](evidence/final/uvmcensus/)): F5 reference full names **8062 -> 7214**, F9
value / order / depth 283 -> 275, F6 1934 -> 1933, F4 429 -> 433, F2 11416 -> 11972. The F2 growth is Scoreboard's
svunit listing-order coin (+676 objects, the four keys `golden-only / ours-only:elsewhere function / task
under:design`; the law sweep drew the other order, section 9) less SimpleUVM's N0151 (-120); F4's +4 are two
N0067 / N0068 records on each of SimpleUVM and Scoreboard (the `m_last_req_buffer` element class_typespec without a
file) that the analyzer now aligns (the chain-keyed census reads no record lost). By cluster (law minus pristine):
N0682 -81 / -97, N0151 -120 / -120, N0689 -57 / -83, N0900 -169 (SimpleUVM), N1424 -21 (Scoreboard), N0540 -78 / -104
(MiniAmiq / SeqDriver), N0582 -60 / -2, N0503 N0504 N0288 -12 each (MiniAmiq) / -5 each (SeqDriver), N0732 N0734
N0288 -2 each, N0691 N0692 -2 each, N0529 -6 / -8 and its type_parameter twin -6 / -8, N0121 -3 / -2.

## 9. Determinism and downstream

**Determinism** (drivers/det.sh: three concurrent harness runs per binary, Earlgrey_0_1 and the five UVM rows, both
modes; [determinism.txt](evidence/final/determinism.txt)): every row-mode one hash per binary and mode, equal to the
gate sweep's (Earlgrey d `6a8fcde9f0f9` / t `dc6bc45475ff` with the law), **except Scoreboard default: two hashes in
BOTH binaries** (law `70cd785b08c9` x2, `631d1de69d57` x1; pristine `50f1e9cd5845` x2, `de42a8e468b9` x1), the two
law draws 92 uhdm-dump lines apart unsorted and 0 sorted: the known svunit listing-order coin. MiniAmiq drew one
hash in all runs. No new coin.

**Downstream**: section 5.4. Map 13's downstream faces (section 7b) are not moved by any of these laws (none fires on
a uhdm2rtlil lane outside the six enum-writer tests, whose RTLIL is byte-identical).

## 10. Fence and process

* Every driver that reads corpus sources or databases reads the four fenced names from the `FENCED=` line of
  `tools/probe/r11u107repro/canaudit.sh` (drivers/env.sh, fail closed when the line does not hold four names) and
  refuses them by word boundary: case.sh / pin1.sh / aliasnames.sh / dscases.py (a path holding a fenced name is
  refused), census.sh (`--filter '^(?!(<fenced>)$)'`), predict.py (exits on a fenced row), awayrows.py (skips fenced
  rows unread), bvmirror.sh (byteverify ran on hard-link mirrors without the 8 fenced row-mode databases,
  `fenced_skipped=8`), tallyname.sh / an.sh / uvmdistraw.sh / det.sh / attrib.sh (fixed test lists checked against
  the fence). uvmdist.sh reads the fence through tools/probe/r11u211map/drivers/common.py. The gate sweeps
  (`tests/sweep.sh`) dispatched every row, as the gate mandates. **No binary, gdb run or script touched a fenced
  test's sources or databases outside those gate sweeps**; gdb ran only on this pass's own cases (pin1.sh) and on
  cases/D g01 (the value writers). A grep of this directory for the four names reads 0.
* Drivers resolve every path from the checkout (`REPO` from their own location); the binaries' directory (`$B`) and
  the scratch root (`$S`) are exported by the caller; no driver hard-codes a worktree or scratch path, and none writes
  relative to its current directory.
* The binaries were frozen `chmod 555` before measurement; every `slang:` line of every sweep's `cmds.txt` names the
  binary of its sweep (section 1). No src edit happened while a build of that worktree compiled.
* The mover prediction of each round was frozen with its md5 and a time stamp BEFORE that round's law sweep.
* The tests/LAWS.md staleness (every sweep's EXIT=1) is this directory and the law names in the worktree's source,
  as map 13 found for its own directory; the landing regenerates the index (`python3 scripts/law_index.py`).
* Live pairs: none of their worktrees was touched; pass 212's patch was read (`/tmp/r11u212.verified.patch`) to
  pre-build the landing's pristine, which the landed commit reproduced byte for byte (`8c724b640425`).

## 11. Residues, ranked (what is left and why)

1. **The preprocessor-output spans** (F1, 720 objects over the four UVM rows): now the first record of SeqDriver d/t,
   SimpleUVM d/t and Scoreboard d (`phase_state_change` 168:11-29 vs ours -169:9; `get_full_name` 116:13-26 vs ours
   115:89-1346:16). UhdmExporter's pp166 model with ExprEmit's macro-argument call spans: the sister's (pass 207
   and 209 residues), untouched here.
2. **MiniAmiq #899, the formal writer order** (section 4.4): an enum typedef relocated to the last package
   subroutine formal typed by it; ours never relocates on MiniAmiq. ParamEmit emitPackage's relocation branch (ground A);
   decoded, not written.
3. **The svaunit clone return-variable names** (N0480 N0485 N0510-N0516; MiniAmiq ~700 objects, SeqDriver ~350):
   golden splits 544 / 597 between the home and the importing package with no single discriminator found (4.5).
4. **N0008 / the design param_assign right side** (45 objects on Scoreboard; grid D g01 #277-#312): the withdrawn
   law's face; needs the right side as compiled (unelaborated), not the elaborated package object.
5. **Earlgrey's ground-A records** (the 12 dm_csrs / dm_mem qualifier spans, the hier_path and indexed-part-select
   names; 4.1) and **Rggen's Surelog rebinding** (4.2).
6. **The module's own imported parameter copies without a value** (N0685 / N0827, grid D g01-g03 value records,
   ParamEmit emitParameters, ground A).
7. **Identity families**: the one extra listing of the UVM_SEQ_ARB_TYPE object on MiniAmiq / SeqDriver (25 vs 24,
   22 vs 21 records), N0151's twin on other shapes, N0467 / N0478 / N0479 (per-use copies).
8. **The module-imported int array's element typespec span** (grid E k01 / k03-k05 `5:3-5:6` vs golden `5:3-5:20`):
   pre-existing, not this pass's.
9. **The class specialization-alias structural records** the class-scope law unmasks (12 probe cases `depth(1)`,
   the r10uvm112 / r10v112 / r10v212 grids: golden binds the group's type parameter to the first-sorting class, pass
   112's own residue) and g19_builtin's type_parameter file.
10. **Programs as writers** (grid A a14 is stage 1): the program listing branch of the writer order is not replayed.

## 12. Files

* **law_typeemit.patch**: the laws (`git diff` of src vs `745f66ab`: UhdmExporter.cpp +511, TypeEmit.cpp +34 / -3,
  ModuleEmit.cpp +44, TaskFuncEmit.cpp +44); applies clean on a fresh `745f66ab`; building it reproduces `law.fin`.
* **cases/**: A (the enum writer grid, 32 cases), B (qualifier span and interface-array bound file, 5), C (class
  specialization-alias and class-scope typedefs, 14), D (the `$unit` hoist copies, 3), E (the class-inherited array
  variable copies, 5); every case's first line names its law with the section sign; a LAW file in every case dir a
  law moves.
* **drivers/**: env.sh (pins, fence), case.sh, grid.sh, switches.sh, aliasnames.sh, tallyname.sh, pin1.sh (gdb
  on own cases), census.sh + predict.py (the frozen prediction), bvmirror.sh, awayrows.py (raw names), uvmdist.sh,
  uvmdistraw.sh, an.sh + clusters.py (map 13's analyzer and ids), det.sh, attrib.sh, dscases.py.
* **evidence/final/**: census/ (prediction + md5 stamp), sweep summaries, byteverify, movers vs prediction, away +
  reversed control, uvmdist, uvmcensus/, clusters (pristine / law), first records, name tallies, determinism,
  downstream (sweep csvs, cases), grid, switch reach, canaries, the probe-change unmasking check, attribution;
  **evidence/round1_a727b8c7/**, **evidence/round2_745f66ab/**; **evidence/decode/** (gdb pins, the value writers, the
  clone return-variable split, the under-reach re-run); **evidence/withdrawn/** (the right-side law's break).
* tests/LAWS.md must be regenerated at landing (`python3 scripts/law_index.py`); this directory adds one row.
