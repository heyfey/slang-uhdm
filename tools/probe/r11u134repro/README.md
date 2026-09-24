# r11u134 — the module/type ground on the strict axis, second round: the typedef parent model, anonymous member names, definition-net typedef spans, vector-typedef clones

Pair B implementer pass (refill after pass 130). Base `c9e2923c` (branch matrix-1.87). Ground: `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`, `src/UhdmExporter.cpp` (the patch touches no other source file; `src/TaskFuncEmit.cpp` and
`uhdm_main.cpp` needed nothing). Worktree `/tmp/wt_r11u134`, system-deps config, `-j 2`.

| binary | md5 | what |
|---|---|---|
| pristine | `61cfb59f3cfa1865bccb360c76bf09dd` | the base, byte-identical to the main tree's `build/slang-uhdm` |
| law | `c4df1a46b2c140c818bc72b933fff741` | this patch (all eleven laws) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the main tree's |
| `strictcmp_x` | — | MEASUREMENT ONLY: tools/probe/r11u132map/drivers/strictcmp_x.cpp built with its cc.sh (record dumps that carry the raw full name) |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u134_bin/`) before it measured anything; every sweep
exported `SLANG_UHDM` and `STRICT_CMP` to the frozen copy (cmds.txt audit: 3273 of 3323 corpus runs name the
frozen binary in each sweep, the other 50 never ran slang-uhdm). Sweeps: pristine `/tmp/r11u134_wdP`, law
`/tmp/r11u134_wdL` (same-length names for the byte verifier), downstream `/tmp/r11u134_dsL`. Law names are written
`§ <name>` in the source, here and in every case's first line.

## 1. Verdict per target

| target (map cluster) | before -> after | law |
|---|---|---|
| (1) FULLNAME-IN-TYPESPEC-SUBTREE, member refs whose typedef's parent is not ours: N0032 (golden `ABC.A`, ours `work@dut.ABC.A`), N0004's importer faces (`work@z_mod.p::t.x`), the elaborated-assignment faces | AssignRhsFlat, PartSelectNoParent (surelog), PartSelectInFor, IndexedPartSelectInFor, struct_pattern_named_default, latch_nested_ex_field, EnumInPackage, struct_access (u2r), StructAccess, StructTypedef, HierPathStruct, AssignmentPatternInAssignmentPattern (surelog) -> `equal`; jeras_union fullname(94) -> (54), rsp_gen_minimal (166) -> (3), rp32_r5p_* fullname(62..91) -> file(46) | § typedefParentLastWriter134, § contAssignLhsTsUnparented134 |
| (1) N0014 anonymous member struct/union refs (golden `BC1.B`, ours `B`) | PatternOrder (surelog), svtypes_struct_simple, union_simple (u2r) -> `equal` | § anonMemberRefChainName134 |
| (1) N0004 module-local typedef under an unpacked-array net (golden `work@top.tl_h2d_t.source`, ours `tl_h2d_t.source`) and the pass-130 residue R2 "struct spans taken at the use" | RangeSelect (surelog), indexed_partsel_array, IndexedPartSelectOfArrayElement, latch_fifo_dynfield, unpacked_struct_2d, unpacked_struct_dyn_read, unpacked_struct_mixed (u2r) -> `equal`; Scr1SvTests line(244) -> (228), Earlgrey_0_1 line(5100) -> (1038) | § defNetTypedefArrayShares134, § defNetTypedefEndWrite134 |
| (1) N0013 / N0020 ref_obj inside a package-held typespec (golden `pkg::AsyncOn::NAlerts`, ours `pkg::AsyncOn.NAlerts`) | EarlgreyPackParam, LogicArrayParam (surelog) -> `equal`; IntegerConcat fullname(3) -> line(1); ibex_alu / ibex_branch_predict / ibex_decoder ... fullname(13) -> (2) | § pkgTsRefObjChainName134 |
| (1) N0019 golden-empty path element in a typespec range | object counts drop on every carrier (cva6_struct_param_field 13 -> 9, iface_zero_width_field 12 -> 8, OutputSize... 11 -> 8, struct_member_cfg_width 55 -> 34); no row clears alone (the hier_path spans N0191 remain) | § tsHierPathElemNoName134 |
| (2) N0031 / N0042 range-bound constant without file or span in a PACKAGE vector-typedef clone | TypedefWithParameter, typedef_package (u2r) -> `equal` (with the class-B law below) | § pkgTdCloneBoundLoc134 |
| (3) N0045 member-default constant listed in the struct | DECODED, not landed (residue R3) | — |
| (4) the `--elabuhdm` clones | DECODED, not landed (residue R5) | — |
| (5) class B, typedef alias on the net typespec (N0085) | LogicTypedef, WireType (surelog), net_types (u2r) -> `equal` (elaborated net); TypedefWithParameter, typedef_package -> `equal` (definition net, package-scoped name) | § elabNetTdCloneNoAlias134, § defNetScopedPkgVecTdShares134 |
| (6) pass-130 residue c02: the nested anonymous union unlocated | grid an08, an10 -> `equal` | § memberAnonUnionAtKeyword134 |
| (6) pass-130 R1 (type-parameter override by a local enum) | the sister's (ParamEmit.cpp emitParameters, the type-parameter override branch after § typeParamChainBorrow45); pass 130's scratch-verified shape stands (README r11u130repro section 7) | — |

**CONVERSIONS (loud): 24 surelog row-modes, 34 uhdm2rtlil row-modes, 21 probe cases turn `STRICT_NOTEQUAL` ->
`CMP_EQUAL` / `EQUAL`. results/ untouched.** The fresh csv rows (law sweep, every one both modes unless noted):

    surelog     AssignmentPatternInAssignmentPattern,{default,testflags},CMP_EQUAL,,,equal   (was differ:fullname(20))
    surelog     AssignRhsFlat,{default,testflags},CMP_EQUAL,,,equal                          (was differ:fullname(23))
    surelog     EarlgreyPackParam,{default,testflags},CMP_EQUAL,,,equal                      (was differ:fullname(2))
    surelog     HierPathStruct,{default,testflags},CMP_EQUAL,,,equal                         (was differ:fullname(4) / (5))
    surelog     LogicArrayParam,{default,testflags},CMP_EQUAL,,,equal                        (was differ:fullname(3))
    surelog     LogicTypedef,{default,testflags},CMP_EQUAL,,,equal                           (was differ:type(1))
    surelog     PartSelectNoParent,{default,testflags},CMP_EQUAL,,,equal                     (was differ:fullname(6))
    surelog     PatternOrder,{default,testflags},CMP_EQUAL,,,equal                           (was differ:fullname(14))
    surelog     RangeSelect,{default,testflags},CMP_EQUAL,,,equal                            (was differ:endline(7))
    surelog     StructAccess,{default,testflags},CMP_EQUAL,,,equal                           (was differ:fullname(9) / (10))
    surelog     StructTypedef,{default,testflags},CMP_EQUAL,,,equal                          (was differ:fullname(12))
    surelog     WireType,{default,testflags},CMP_EQUAL,,,equal                               (was differ:type(1))
    uhdm2rtlil  EnumInPackage,{default,testflags},CMP_EQUAL,,,equal                          (was differ:fullname(11))
    uhdm2rtlil  indexed_partsel_array,{default,testflags},CMP_EQUAL,,,equal                  (was differ:fullname(1))
    uhdm2rtlil  IndexedPartSelectInFor,{default,testflags},CMP_EQUAL,,,equal                 (was differ:fullname(6))
    uhdm2rtlil  IndexedPartSelectOfArrayElement,{default,testflags},CMP_EQUAL,,,equal        (was differ:fullname(1))
    uhdm2rtlil  latch_fifo_dynfield,{default,testflags},CMP_EQUAL,,,equal                    (was differ:endline(20))
    uhdm2rtlil  latch_nested_ex_field,{default,testflags},CMP_EQUAL,,,equal                  (was differ:fullname(25))
    uhdm2rtlil  net_types,{default,testflags},CMP_EQUAL,,,equal                              (was differ:type(1))
    uhdm2rtlil  PartSelectInFor,{default,testflags},CMP_EQUAL,,,equal                        (was differ:fullname(6))
    uhdm2rtlil  struct_access,{default,testflags},CMP_EQUAL,,,equal                          (was differ:fullname(16))
    uhdm2rtlil  struct_pattern_named_default,{default,testflags},CMP_EQUAL,,,equal           (was differ:fullname(30))
    uhdm2rtlil  svtypes_struct_simple,{default,testflags},CMP_EQUAL,,,equal                  (was differ:fullname(4))
    uhdm2rtlil  typedef_package,{default,testflags},CMP_EQUAL,,,equal                        (was differ:endline(6))
    uhdm2rtlil  TypedefWithParameter,{default,testflags},CMP_EQUAL,,,equal                   (was differ:endline(2))
    uhdm2rtlil  union_simple,{default,testflags},CMP_EQUAL,,,equal                           (was differ:fullname(8))
    uhdm2rtlil  unpacked_struct_2d,{default,testflags},CMP_EQUAL,,,equal                     (was differ:endline(13))
    uhdm2rtlil  unpacked_struct_dyn_read,{default,testflags},CMP_EQUAL,,,equal               (was differ:endline(13))
    uhdm2rtlil  unpacked_struct_mixed,{default,testflags},CMP_EQUAL,,,equal                  (was differ:endline(13))

Probe cases turned `EQUAL` (was STRICT_NOTEQUAL): r10buvm8repro/v4order8, r10buvm8repro/vfwdts8,
r10earl100repro/a1_bare100, r10earl91repro/g1_head91, r10earl_repro/{pt23, qh21, tf, vb},
r10vearl100repro/v1_union100, r11u108repro/grid/pk/k08_var_vn, r11u109repro/grid/hp/h08_unpacked_base,
r11u5repro/g2, r11u88repro/grid/{vf_collide, y6_hoistconv}, r11u90repro/grid.verifier/vx14_strtypedef,
r11v17repro/grid/va20_structnet_unpacked_array_lhs, r11v77repro/grid/{va_netstructkinds, vd_structmem},
r11v88repro/grid/v13_ndatypedef, v11u112repro/grid/brk/v/b4g_struct_ctl, v11u93b107repro/brk/p10_union_of_struct.

## 2. The laws (each droppable alone; `R11U134_OFF=1` drops all eleven)

The switch table is in `src/UhdmExporter.cpp` (`r11u134Law`).

| law | switch | site (file + token) | rule |
|---|---|---|---|
| § typedefParentLastWriter134 | `R11U134_TDPARENT_OFF` | UhdmExporter.cpp typedefParentModel134 (called last in exportDesign) | UhdmWriter::writeDataTypes runs `tps->VpiParent(parent)` (setParent=true) for every datatype of every package (elaborated listing, then unelaborated), program, interface and module definition, in that order, and a module's map holds every typedef its `import p::*` / `import p::t` brought in (CompileHelper::importPackage, `scope->insertDataType`). The LAST container whose typespec list holds a struct/union typedef object is its parent, and every full name ComputeFullName synthesises below a member reads through it: two importers -> `work@z_mod.p::t.x` (ours parented the elaborated package listing at the FIRST importer's instance), a package importing a package -> `q::p::t::x`. Enums excluded (Kmac: a package enum's base-type ref keeps `sha3_pkg::sha3_pkg::keccak_strength_e` under an importer) |
| § contAssignLhsTsUnparented134 | `R11U134_CAUNPARENT_OFF` | UhdmExporter.cpp typedefParentModel134 (`noteCa`) | UhdmWriter::writeCont_assign ends every elaborated continuous assignment with `if (tps != nullptr) tps->VpiParent(nullptr)`, `tps` = the LHS expression's own ref_typespec actual, or for a plain identifier the typespec of what CompileHelper::bindVariable finds by NAME in the instance (a module_inst's Variables, then Nets; a generate scope climbs to the enclosing module and never sees its own declarations, grid ca20; the module's Variables list holds wildcard-imported package variables first, r11u82 w8_structown). A declaration with an initializer is a cont_assign whose LHS is the net. The named struct/union/enum typedef so assigned is unparented, and every listing cloned from it afterwards: `ABC.A` (AssignRhsFlat), `my_pkg::hw_key_req_t.key` (PartSelectNoParent), an unparented enum's base-type ref `e_t`. Keyed by kind/name/location; the unelaborated package listing (AllPackages without TopPackages) is never reached (r10earl99 g1_lit99, r10earl jj, v11u108 c01); a signal typed by a type parameter does not reach the override's typedef (gen_scope_typaram) |
| § anonMemberRefChainName134 | `R11U134_ANONMEMBER_OFF` | TypeEmit.cpp anonMemberRefPrefix134 (called from buildStructTs and buildUnionTs after the member ref) | compileTypespec's struct/union case parents a member's own typespec at the member (`member_ts->VpiParent(m)`, once per declarator), so an anonymous struct/union member type's refs are named through the containing member: `ABC.BC1.B` (PatternOrder), `b.x` (svtypes_struct_simple), `byte4.a` (union_simple); nested levels compose; a type shared by two declarators keeps the first declarator's names (golden names the object both ways) |
| § memberAnonUnionAtKeyword134 | `R11U134_MEMUNION_OFF` | TypeEmit.cpp makeTypespec (the anonymous union case) | a field's DeclaredType carries no type syntax (the member syntax is the override), so the nested anonymous union was never located; golden locates it at the bare `union` keyword (pass-130 residue c02) |
| § defNetTypedefEndWrite134 | `R11U134_TDNETEND_OFF` | ModuleEmit.cpp materializeDefNetTs (`tdNetEnd134`) | writeNets' end-only populate (§ defNetEndOnlyLoc130's mechanism) lands on the SHARED struct/union/enum typedef object for a bare name (TypeDef::getTypespec, no clone): its END and FILE move to the first unpacked dimension of each definition net (last writer wins), in every listing: RangeSelect `tl_h2d_t a[4]` -> 2:12-6:17. An initializer does not move it (grid td03, td07, td20); ports excluded |
| § defNetTypedefArrayShares134 | `R11U134_TDARRSHARE_OFF` | ModuleEmit.cpp materializeDefNetTs (the unpacked-array-of-module-struct case) | the definition net `tl_h2d_t a[4]` binds the shared typedef object (the raw walk, `--no-canon`, lists golden's typedef once under the module); ours bound a clone whose member refs read the bare `tl_h2d_t.source` |
| § elabNetTdCloneNoAlias134 | `R11U134_ELABNETALIAS_OFF` | ModuleEmit.cpp emitInstance (the module-local vector-typedef NET clone) + materializeDefNetTs (the single-view reuse case) | at the v1.87 pin the ELABORATED net typed by a module-local vector typedef reads the typedef's own form, no Typedef_alias (LogicTypedef `reg_two_bits regn`, WireType / net_types `wire typename w`); the definition net keeps its alias clone and no longer reuses the elaborated one |
| § defNetScopedPkgVecTdShares134 | `R11U134_SCOPEDPKGTD_OFF` | ModuleEmit.cpp materializeDefNetTs (head) | a definition net typed by a PACKAGE-SCOPED name of a vector typedef written over a built-in type (`p::t v;`) binds the package's own typedef object (compileTypespec's scoped case, no alias clone), and writeNets' end-only populate lands on it at the first unpacked dimension or the INITIALIZER (`my_pkg::word w = 8'h5C;` -> the package typedef ends at the literal, in every listing). A typedef over another typedef keeps its clone (r11v111 y31_two_pkgs_rows) |
| § pkgTdCloneBoundLoc134 | `R11U134_PKGCLONEBOUND_OFF` | ModuleEmit.cpp emitInstance (`bareCloneComputedBounds`) | the elaborated clone of a PACKAGE vector typedef keeps its computed bound located at the bound's left operand (`INT:7` at the `X` of `[X-1:0]`); the bare unparented fold stays the module-local clone's (grid bc01, bc05) |
| § pkgTsRefObjChainName134 | `R11U134_TSREFCHAIN_OFF` | UhdmExporter.cpp pkgTsRefObjChainName134 | a range-bound ref_obj whose chain climbs through a range into typespecs and reaches a package is named by ComputeFullName ("::" throughout, every named typespec on the way): `alert_handler_reg_pkg::AsyncOn::NAlerts`, `ibex_pkg::RndCnstLfsrSeedDefault::lfsr_seed_t::LfsrWidth`; applied when the old name starts with the same package and ends with the object's name |
| § tsHierPathElemNoName134 | `R11U134_TSHPNAME_OFF` | UhdmExporter.cpp tsHierPathElemNoName134 | a hier_path element in a typespec range has no full name in golden (the hier_path there has no parent, so ComputeFullName yields the bare name): the no-fullname idiom |

`R11U134_OFF=1` restores pristine bytes on all 92 grid cells (evidence/switches_grid.txt: `off=pristine` on every
case) and on 263 of the 266 corpus byte movers (the other 3 are the UVM order coin, section 6). Each single switch
moves back exactly the cells of its own law (the `laws:` column of evidence/switches_grid.txt).

## 3. Decode notes (Surelog v1.87 source, third_party/Surelog/src)

* **Full names are synthesised.** The generated `VpiFullName()` getter calls `BaseClass::ComputeFullName()` when
  nothing was stored (UHDM scripts/classes.py), and `vpi_get_str(vpiFullName)` returns null when that equals the
  name. Surelog stores no full name on a typespec member's ref_typespec, on a range bound's ref_obj or on a
  path element, so golden's names there are the parent chain, and the chain is decided by the typedef object's
  FINAL vpiParent, which two writer actions mutate after compilation: `UhdmWriter::writeDataTypes` (setParent)
  and `UhdmWriter::writeCont_assign` (`tps->VpiParent(nullptr)`). The comparator's copy rule (r11u129) excuses a
  name only where golden gives our object more than one name; a typedef's shared object names its members one
  way, so these are content.
* **writeNets' end-only populate on a shared typedef** (`UhdmWriter.cpp` writeNets, the
  `dest_net->Typespec() == nullptr` case, `populateCoreMembers(InvalidNodeId, dimensions, ts)`):
  `compileDatastructureTypespec` returns `TypeDef::getTypespec()` for a struct/union/enum typedef and a
  `clone_tree` with a Typedef_alias only for a SimpleType, so the end lands on the shared object.
  `CompileHelper` builds the Signal with `unpackedDimension = fC->Sibling(signal)`.
* **Anonymous member types** (`CompileType.cpp`, the paStruct_union case): `member_ts = compileTypespec(...)`
  inside the declarator loop, then `member_ts->VpiParent(m)`.
* **The scoped package name** (bc grid): golden's definition net `p::t v` lists the package typedef's own range
  where ours listed an alias ref; `p::t v = 8'h5C` moves the package typedef's end to the literal in every
  listing (pass-130 residue R5, TypedefWithParameter).

## 4. Grids (cases under grid/, every case names its law in its first line)

Scored per cell (drivers/case.sh: Surelog `-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, ours `dut.sv
--single-unit --nobuiltin`, uhdm-strictcmp; drivers/grid.sh gives the per-field counts pristine vs law). Full table
evidence/grid_scores.txt (92 cells).

| grid | law | cells | judge-equal | strict-equal pristine | strict-equal law |
|---|---|---|---|---|---|
| td td01-td20 (arrays of struct/union/enum typedefs, two writers, initializers, var, interface, sub-module, 2-D, two declarators, packed control, `wire`, unpacked struct) | § defNetTypedefEndWrite134, § defNetTypedefArrayShares134 | 20 | 15 | 4 | 14 (td12: interface nets, residue R7) |
| ca ca01-ca24 (assign / decl-init to struct, enum, union, package imported and scoped, member and element LHS controls, generate scopes with and without a shadowing local, procedural control, logic typedef control) | § contAssignLhsTsUnparented134 | 24 | 22 | 9 | 22 |
| an an01-an11 (nested anonymous struct/union members, shared by two declarators, three levels, unpacked, package, anonymous variable) | § anonMemberRefChainName134, § memberAnonUnionAtKeyword134 | 11 | 10 | 0 | 10 |
| pk pk01-pk14 (one/two importers, unused import, named import, scoped control, interface, package importing a package, enum, union, header import, `$unit` import, port type) | § typedefParentLastWriter134 | 14 | 14 | 10 | 14 |
| nb nb01-nb07 (wire/wand/reg vector typedef nets, var control, sub-module, interface control) | § elabNetTdCloneNoAlias134 | 6 | 6 | 1 | 6 |
| bc bc01-bc06 (module-local controls, scoped package vector typedef with/without initializer, procedural) | § defNetScopedPkgVecTdShares134, § pkgTdCloneBoundLoc134 | 6 | 5 | 2 | 5 |
| rp rp01-rp06 (package parameter ranges, typedef clone chain, module control) | § pkgTsRefObjChainName134 | 6 | 2 | 1 | 1 (rp02 fullname 3 -> 1; the package-parameter shapes are judge-NE single-file) |
| hp hp01-hp05 (member-select bounds of struct parameters) | § tsHierPathElemNoName134 | 5 | 3 | 0 | 0 (hp05 fullname 6 -> 2; the path spans remain) |

Every NOT_EQUAL cell keeps its uhdm-cmp head with both binaries; the line count is unchanged except hp04 (92 -> 90:
the printed ref_obj loses its two `vpiFullName` lines, the head is the same object).

## 5. Census: strict column, law sweep vs pristine sweep, row by row (evidence/cols_P_L.tsv, fieldcheck_P_L.txt)

| corpus | judge-equal row-modes | strict-equal pristine | strict-equal law |
|---|---|---|---|
| surelog | 954 (480 + 474) | 639 | 663 |
| uhdm2rtlil | 1606 (803 + 803) | 1270 | 1304 |
| probe cases | 4087 | 2081 | 2102 |

Row-modes changed: surelog 24 turned equal, 12 fewer objects on the same first field, 10 first field moved;
uhdm2rtlil 34 / 34 / 20; probe 21 / 51 / 11, and 1 more (below). No status change, no row leaves `equal`.
drivers/fieldcheck.py re-runs uhdm-strictcmp on every changed row with both databases and compares the per-field
tallies: **no field count grows on any of the 139 changed non-converting rows** except r10buvm8repro/v5b8
(positive control: the checker flags r10earl jj's fullname 8 -> 26 on an interim binary). v5b8 is an UNMASKING:
the pristine walk diverged at the package-scoped `kp5b::b_t bb` alias (now fixed by § defNetScopedPkgVecTdShares134)
before the last two of the ten `kp5b::e_t` enum listings; both databases hold the same ten listings at 6:3-6:43
where golden has 20:24-20:27 (the enum relocated to the last formal's type reference, residue R4): line(8) -> line(10),
type/fullname/file/size faces cleared.

Interim sweeps caught what the final laws exclude: the unelaborated package listing (r10earl99 g1_lit99 EQUAL ->
fullname(1), jj, c01), a generate-scope assignment binding (w8_structown), a package enum's base ref (Kmac +2), a
type-parameter-typed LHS (gen_scope_typaram +4), a typedef over a typedef (y31_two_pkgs_rows +3); each is back to its
pristine cell.

## 6. Gates

1. build: pristine `61cfb59f3cfa` (= main tree), law `c4df1a46b2c1`.
2. probe: `EQUAL=2102 STRICT_NOTEQUAL=1985 (of 4087)`, `regressions=0 conversions=21 changes=63`.
3. corpora: surelog `[default] CMP_EQUAL=343 ... STRICT_NOTEQUAL=137`, `[testflags] CMP_EQUAL=320 ...
   STRICT_NOTEQUAL=154`, uhdm2rtlil `CMP_EQUAL=652 CMP_NOTEQUAL=1 SLANG_REJECT=67 STRICT_NOTEQUAL=151` both modes;
   `regressions=0` in both (conversions 24 / 34). The judge-equal scoreboards stay 480/3 + 474/3 and 803/1/67. The
   sweep's rc=1 is `law index STALE` (tests/LAWS.md is regenerated with this README).
4. downstream (law): `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`; verdict
   AND `differs` identical to results/downstream_uhdm2rtlil.csv on all 871 rows; every converted uhdm2rtlil row
   IDENTICAL; the pass-120/125/130 rows unchanged (evidence/downstream_law.csv).
5. uhdm-cmp: every corpus row keeps its status; every probe case uhdm-cmp-equal (the gate's own check).
6. byteverify (`SELFCHECK=1`, same-length workdirs): PATH_SETS_IDENTICAL both corpora, SELFCHECK 959/960 and
   1607/1608; MOVERS 102/960 + 164/1608 = 266 (evidence/byteverify_*.txt, byte_movers.tsv; two of them are the two
   modes of one slang-fenced test, predicted and restored by `R11U134_OFF=1`, left out of the committed evidence
   files). PREDICTED from the pristine databases first (drivers/predict.py, evidence/predict_pristine.tsv: every
   strict-NE row whose golden-vs-pristine records carry a face a law writes): 187 movers in the predicted set; the
   other 79 are 61 strict-equal rows (byte-only reparenting of a typedef whose
   names already matched: § typedefParentLastWriter134 on 61 of them) and 18 walk-diverged rows (`depth(1)` /
   `name(2)` first faces, the signature cannot see past the divergence). Attribution (drivers/attrib.sh): the law
   binary with `R11U134_OFF=1` gives the pristine bytes back on 263 of 266; the other 3 are MiniAmiq/default,
   SimpleUVM/default, SeqDriver/testflags, the UVM order coin (pristine vs law and pristine vs OFF both differ by the
   same 4 order-blind dump lines). Every unpredicted mover is owned by one switch (evidence/attribution_laws.tsv:
   TDPARENT 61, CAUNPARENT 14, TSHPNAME 2, TDPARENT+CAUNPARENT 2).
7. canaries: `canaries.sh` law vs pristine: surelog ok=46 changed=6 (Scr1SvTests line(244) -> (228), Earlgrey_0_1
   line(5100) -> (1038), BuildUVMPkg fullname(315) -> line(284): strict improvements, fieldcheck ok), uhdm2rtlil
   ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` results/golden_surelog.csv PASS ok=58, `EXPECT_UNKNOWN=6`
   results/golden_uhdm2rtlil.csv PASS ok=2.

## 7. Residues, ranked

* **R1 N0004/N0028 inside parameter typespecs** (`work@top.p::cfg_t.HSK` under `parameter CFG_DEF`,
  `work@top.TargetCfg.pinmux_pkg::...` vs golden `work@top.pinmux_pkg::...`): the member names of a
  parameter's struct copy; ours names them through makeParamTs (ParamEmit.cpp, § tpAnonAggParamTsNoStamp47 /
  § paramCloneImportedCopy) — the sister's ground. GenForStructParamBound fullname(25) -> (13) with this patch.
* **R2 gen-scope typedef reparenting**: writeElabGenScope's `writeDataTypes(..., true)` reparents a generate
  scope's typedefs to the gen_scope; not modelled (no carrier converted by it in the grids).
* **R3 N0045 member default**: golden's typespec_member of `cfg_pkg::cfg_t` lists the constants a pattern
  assigned (`32'd64`, twice) as its default: a writer mutation during pattern flattening, not a share; ours lists
  none. Not landed.
* **R4 enum relocation to a formal's type reference** (probe v5b8: golden `kp5b::e_t` 20:24-20:27 in every
  listing, the last `e_t` io_decl type of the package): the name case's `populateCoreMembers(type, type, ...)` on the
  shared enum; decoded shape, not landed.
* **R5 elabuhdm clones** (N0124/N0280/N0282/N1849/N0652): the library clones our definition functions and copies the
  full names we STORE; Surelog stores none there, so golden's clones read the instance path
  (`work@top.u_lfsr.get_1s`). The fix is to leave those names unstored on the definition task_func subtree before
  `listenDesigns` in uhdm_main.cpp; it needs a per-kind map of what Surelog stores (nets do store theirs), not landed.
* **R6 hier_path spans in typespec ranges** (N0191): the N0019 carriers now differ only in path spans (ExprEmit/
  TypeEmit emitSyntaxExpr § hpSymbolicSelect span).
* **R7 interface definition nets** (grid td12): § defNetTypedefEndWrite134 does not reach interface nets (their
  typespecs are materialized by emitInterfaceDef).
* Pass-130 residues not taken: R3 (TypeParam def net), k07/c04, m01/m03, h09, i02/i05, port views.

## 8. Files

* `grid/{td,ca,an,pk,nb,bc,rp,hp}/` — the cases (every `dut.sv` names its law in its first line).
* `evidence/` — grid_scores.txt, switches_grid.txt, cols_P_L.tsv (strict column, row by row, all three stages),
  fieldcheck_P_L.txt, byteverify_*.txt, byte_movers.tsv, predict_pristine.tsv, attribution_off.tsv,
  attribution_laws.tsv, sweep_pristine.txt, sweep_law.txt, downstream_law.csv, downstream_summary.txt.
* `drivers/` — case.sh / grid.sh / pc.sh (one case, a grid, a probe case), rows.sh / rowrec.sh (corpus rows and
  their record dumps), sweep.sh, census.py (row-by-row strict census), fieldcheck.py (per-field tallies),
  predict.py (mover prediction from pristine databases), switches.sh / attrib.sh (per-law attribution).
