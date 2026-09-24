# r11u130 — the module/type ground on the strict axis: definition-net typespec slots, port views, wildcard spans, the preprocessor line model

Pair B implementer pass (refill after pass 125). Base `634b3a19` (branch matrix-1.87). Ground:
`src/ModuleEmit.cpp`, `src/TypeEmit.cpp`, `src/UhdmExporter.cpp` (the patch touches no other source
file; `src/TaskFuncEmit.cpp` and `uhdm_main.cpp` needed nothing). Worktree `/tmp/wt_r11u130`, built
with the system-deps config at `-j 2`.

| binary | md5 | what |
|---|---|---|
| pristine | `7c5a7e01c46167100bd7787ae1798f2c` | base, byte-identical to the main tree's `build/slang-uhdm` (the worktree's own pristine build has the same md5) |
| law | `6a3e91ed5fc42521d23d417bf12da912` | this patch (all ten laws) |
| `uhdm-strictcmp` | `70ddf0ad777735ff05ec8d89aee66627` | the main tree's |
| `-g1` build | — | MEASUREMENT ONLY: the base source with `-g1` line tables, used to pin minting sites under gdb (drivers/pinsite.sh, drivers/pinrow.sh) |
| decode build | — | MEASUREMENT ONLY: a scratch copy with the sister-ground ParamEmit edit of residue R1, never landed |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u130_bin/`) before it measured anything; every
sweep exported `SLANG_UHDM` (and `STRICT_CMP`) to the frozen copy, and the cmds.txt files name that path.
Sweeps: pristine `/tmp/r11u130_wdP`, law `/tmp/r11u130_wdL` (same-length names for the byte verifier),
downstream `/tmp/r11u130_dsL`.

## 1. Verdict per target

| target (map cluster) | before -> after | law |
|---|---|---|
| (1) K0028/K0058 anonymous enum typespec unlocated | `simple_enum` `differ:file(2)` -> `equal`, `AnonymousEnum` `differ:file(6)` -> `equal` (both modes) | § defNetEndOnlyLoc130 |
| (1) K0053 packed_array typespec without a file | `EnumArray`, `EnumArrayListedElements`, `packed_struct_array_net_elem` `differ:file(2)` -> `equal` (both modes); `dyn_field_select` file(4) -> fullname(2), `StructArrayNet` file(3) -> fullname(2), `PackedEnumPort` file(4) -> name(3), `InterfArrayBind` file(5) -> fullname(4) (the rest are fullname/name faces of the sister's ground) | § defNetEndOnlyLoc130 |
| (1) K0028 type-parameter override typed by a module-local enum (`TypeParameterAsPortTypeWithEnum*`) | DECODED, sister's ground (ParamEmit.cpp); residue R1 | — |
| (2) K0048 net-type keyword span (`wire signed`) | `SignedWire` (surelog) `differ:endcol(1)` -> `equal`, `static_cast_simple` `differ:endcol(6)` -> `equal` (both modes); YosysOldOpen endcol(6) -> depth(1) (the depth divergence pre-exists) | § netSigningTsSpan130 |
| (2) K0074 inline struct header span | `svtypes_struct_simple` `differ:endcol(1)` -> `equal` (both modes) | § suSigningNotInSpan130, § ifaceElabInlineSuKeyword130 |
| (2) K0070 / K0024 / K0052 / the rest of K0074 | measured per shape, not landed: use-site copies (residue R2) and the type-parameter def net (R3) | — |
| (3) K0034 implicit nets without a file | the ModuleEmit mint (class-specialization argument lookup miss) landed: `ClassTypeParam` endline(27) -> (26), file(40) -> (39); the Disable / foreach / hier-name mints are the sister's (R4) | § classSpecArgNetNoFile130 |
| (4) K0067 `.*` connection span | `WildConn` `differ:endcol(2)` -> `equal`, `sva_basic02` `differ:endcol(4)` -> `equal` (both modes); `gen_scope_numports` fullname(21) -> (17) | § wildcardConnRefSpan130 |
| (4) K0085 port-view parameter named by the definition | `InterfType` `differ:fullname(2)` -> `equal`, `iface_param_width_per_inst`, `iface_ff_genvar_partsel` `differ:fullname(2)` -> `equal` (both modes), `OneNetRange` default fullname(2) -> `equal`, testflags (4) -> (2); GenForIfaceLocalparamBound fullname(9) -> endcol(5), GenForIfaceLocalparamNestedGen file(8) -> (6) | § portViewParamDefName130 |
| (5) K0049/K0057 TypedefWithParameter fold | not landed: the fold is not the head (R5) | — |
| (6) R5 def-view gen_for int_typespec file | r11v125 gv v05, v06 -> strict-equal | § genvarIntTsRootFile130 |
| (6) R9 empty redefinition lowers the root file's lines | r11v125 rd z02, z03, z05, z10 -> strict-equal; grid g9 7/8 | § emptyRedefineObjLine130 |
| (6) R10 include that splices one line fewer | decoded as "an included file with no text splices nothing": rd z06, z08, z09, z12 -> strict-equal; grid g10 11/11 | § includeNoTextSplicesNothing130 |
| (6) R4 multi-line macro line model, R8 text before an include | not landed (R6) | — |

The fresh csv rows of every turned row-mode (law sweep, both corpora):

    InterfType,{default,testflags},CMP_EQUAL,,,equal              (was differ:fullname(2))
    OneNetRange,default,CMP_EQUAL,,,equal                         (was differ:fullname(2))
    SignedWire,{default,testflags},CMP_EQUAL,,,equal              (surelog; was differ:endcol(1))
    WildConn,{default,testflags},CMP_EQUAL,,,equal                (was differ:endcol(2))
    AnonymousEnum,{default,testflags},CMP_EQUAL,,,equal           (was differ:file(6))
    EnumArray,{default,testflags},CMP_EQUAL,,,equal               (was differ:file(2))
    EnumArrayListedElements,{default,testflags},CMP_EQUAL,,,equal (was differ:file(2))
    iface_ff_genvar_partsel,{default,testflags},CMP_EQUAL,,,equal (was differ:fullname(2))
    iface_param_width_per_inst,{default,testflags},CMP_EQUAL,,,equal (was differ:fullname(2))
    packed_struct_array_net_elem,{default,testflags},CMP_EQUAL,,,equal (was differ:file(2))
    simple_enum,{default,testflags},CMP_EQUAL,,,equal             (was differ:file(2))
    static_cast_simple,{default,testflags},CMP_EQUAL,,,equal      (was differ:endcol(6))
    sva_basic02,{default,testflags},CMP_EQUAL,,,equal             (was differ:endcol(4))
    svtypes_struct_simple,{default,testflags},CMP_EQUAL,,,equal   (was differ:endcol(1))

## 2. The laws (each droppable alone; `R11U130_OFF=1` drops all ten)

The switch table is in `src/UhdmExporter.cpp` (`r11u130Law`).

| law | switch | site (file + token) | rule |
|---|---|---|---|
| § defNetEndOnlyLoc130 | `R11U130_DEFNETLOC_OFF` | ModuleEmit.cpp materializeDefNetTs (the tail block, and the file half in the initializer stretch) | a definition net's fresh unnamed typespec that nothing located takes the END and the FILE of Surelog's packed-slot node: UhdmWriter writeNets runs `populateCoreMembers(InvalidNodeId, dimensions, ts)`, which writes end line/column and the end node's file only. The slot is the node after the type node: an inline enum with a base -> its first member, without a base -> its second member (one member: no slot); a named type with packed dimensions -> the first packed dimension. A package-SCOPED name locates nothing else (`dut.sv 0:0:7:22`); a BARE name was already located from the name by compileTypespec's name case (start = the name). The initializer case (EnumArray `0:0:8:46`) had the end and lacked the file |
| § netSigningTsSpan130 | `R11U130_NETSIGN_OFF` | ModuleEmit.cpp materializeDefNetTs | the same slot for a NET declaration with a signing keyword: compileNetDeclaration's packed slot is the node after `wire`, i.e. `signed`/`unsigned`, so the definition typespec ends at the keyword (`wire signed` 3:3-3:14 of `wire signed [7:0] s`); also `wire signed w;`, an initialized net (the net road has no initializer slot), `tri`, interfaces, parameterized widths. An unpacked dimension fills the slot first (unchanged) |
| § suSigningNotInSpan130 | `R11U130_SUSIGN_OFF` | TypeEmit.cpp makeTypespec (the anonymous packed struct case and the anonymous union case) | an inline packed struct/union's definition typespec ends at `packed`, never at the signing keyword (the slot after the struct keyword is `packed`): `struct packed signed` 11:2-11:15 |
| § ifaceElabInlineSuKeyword130 | `R11U130_IFSUKW_OFF` | ModuleEmit.cpp emitInterfaceInstance (the struct-signal case) | the ELABORATED interface's inline anonymous struct typespec spans the bare `struct` keyword, as a module instance's does |
| § wildcardConnRefSpan130 | `R11U130_WILDSPAN_OFF` | ModuleEmit.cpp emitInstance (before `p->High_conn(h)`) | a HighConn a `.*` implies is one column wide: NetlistElaboration's wildcard case writes line/column of the `.*` token and end = column + 1 |
| § classSpecArgNetNoFile130 | `R11U130_CLSARGNET_OFF` | ModuleEmit.cpp emitModuleDef (the class-specialization argument wire) | the wire minted for a bare-identifier class specialization argument is a lookup-miss mint: no file (§ implicitNetNoFile119's producer, UhdmWriter late binding) |
| § portViewParamDefName130 | `R11U130_PVPARAM_OFF` | ModuleEmit.cpp emitInterfaceInstance (after emitParameters) | a reference-style port view (the view an interface-typed port's LowConn reaches, and an interface's own interface-typed port) is Surelog's copy of the DEFINITION: a param_assign whose Rhs is a constant keeps the definition's parameter, full name `work@<def>.<param>` (and its ref_typespec). A modport-qualified port view (listed under the module with the override) and a param_assign whose Rhs stays an operation (a struct default) keep the path name |
| § emptyRedefineObjLine130 | `R11U130_REDEFLINE_OFF` | UhdmExporter.cpp fileLineCol (`UhdmExporter_redefLost130`) | an empty bare redefinition drops one output line, and an object's line is its output line mapped through the nearest earlier line record, so every later line of the SAME file reads one lower per drop until the next record: an `include directive or a multi-line macro invocation (a one-line macro pushes and pops on one output line and does not resync) |
| § includeNoTextSplicesNothing130 | `R11U130_INCNOTEXT_OFF` | UhdmExporter.cpp emitIncludeFileInfos | an included file whose text is nothing but `define/`undef/`ifdef-family directives and blank lines splices NO line (the include_file_info FLATTENED line of every later directive); a comment, code or a `timescale line is text (YosysOldI2c's timescale.v splices both its lines) |
| § genvarIntTsRootFile130 | `R11U130_GVTSFILE_OFF` | ModuleEmit.cpp emitDefGenStmts (the gen_for loop variable) | the loop variable's implicit int typespec is Surelog's `buildIntTypespec(fC->getFileId(), ...)`: the ROOT file (the preprocessed FileContent) with the node's own line |

`R11U130_OFF=1` restores pristine bytes on all 117 grid cells (evidence/switches_grid.txt: `off=pristine`
on every case) and on the corpus byte movers (section 6). Each single switch moves back exactly the cells
of its own law (the `laws:` column of evidence/switches_grid.txt; two cells need two laws: k07 SUSIGN+IFSUKW,
rd z06 REDEFLINE+INCNOTEXT).

## 3. Decode notes

* **The definition-net slot** (K0028 anonymous enums, K0053, K0048, K0074 signed headers): one
  mechanism, `UhdmWriter.cpp` writeNets, the `dest_net->Typespec() == nullptr` case:
  `m_helper.compileTypespec(...)` then `if (dimensions) fC->populateCoreMembers(InvalidNodeId,
  dimensions, ts)` with `dimensions = orig_net->getUnpackedDimension() ?: getPackedDimension()`.
  `FileContent::populateCoreMembers` with no start writes the end fields and the file of the end node.
  The Signal's packed slot is the sibling of the type node, which explains every measured face: `enum
  logic [1:0] {A, B} x` -> `A`; `enum {A, B, C} x` -> `B` (the first member IS the type node);
  `struct packed signed {..}` -> `packed`; `wire signed [7:0]` -> `signed`.
* **Port views** (K0085): the plain port's view is reached through the port's LowConn and lists the
  definition's param_assigns (Rhs = the DEFAULT, UINT:3 under a `#(.W(22))` override): its Lhs is the
  definition's parameter object. The rule was refined twice on grid g6: p05 (modport port) and p11
  (struct default kept as an operation) keep path names; p13 (struct type, constant default) is the
  definition's. GenIfIfaceParamStructField (a struct default, an operation) moved AWAY under the first
  cut (col(7) -> col(9)) and is back to its pristine cell with the constant-Rhs gate.
* **Wildcard connection** (K0067): NetlistElaboration.cpp, the `if (wildcard)` block of the
  port-connection loop: `ref->VpiEndColumnNo(wildcardColumnNumber + 1)`.
* **Implicit nets** (K0034): pinned (drivers/pinsite.sh, pinrow.sh on the `-g1` build): Disable's
  `loop` -> StmtEmit.cpp emitStmt (Disable case, the implicitNetMap mint); ForeachArray's `i` ->
  ExprEmit.cpp emitExpr; AssertDelayError's `tb_left_rotation` -> ExprEmit.cpp emitExpr;
  FuncIoTypespec's `len` -> ExprEmit.cpp fnLocalParamRangeActual; UnitElabBlock's `hold` -> ExprEmit.cpp
  emitExpr; ClassTypeParam's `uvm_object` -> ModuleEmit.cpp emitModuleDef (landed here).
* **Line model** (R9/R10 of r11v125): SV3_1aPpTreeShapeListener drops the line filler of an empty bare
  redefinition; objects map output lines through IncludeFileInfo records, which exist at include
  push/pop and macro push/pop. Grid g9 separates the resync points (r03 one-line macro: no resync; r05
  include, r07 multi-line macro: resync). Grid g10 shows the "last line is a define" face of r11v125 is
  really "the file has no text": q04 (blank then define) and q09 (`ifndef/`define/`endif) splice 0,
  q01 (comment then define) and q06 (code then define) splice everything, q11 (`timescale) splices
  everything.
* **Genvar typespec file** (R5): `CompileHelper::compileVariable`, the `implicitInt` case:
  `buildIntTypespec(compileDesign, fC->getFileId(), ...)`.

## 4. Grids (cases under grid/, every case names its law in its first line)

Scored per cell against golden's records (drivers/case.sh: Surelog `-parse -nobuiltin -nocache -sv
dut.sv -mt 0 -mp 0`, ours `dut.sv --single-unit --nobuiltin`, uhdm-strictcmp; drivers/gridscore.sh gives
the per-field counts pristine vs law). Full table evidence/grid_scores.txt (117 cells, the 19 r11v125 rd
and gv cells included).

| grid | law | cells | judge-equal | strict-equal pristine | strict-equal law |
|---|---|---|---|---|---|
| g1 e01-e20 (anonymous enums with/without base, one member, values, two declarators, initializer, multi-line, include, interface, sub-module; package struct/enum packed arrays 1 and 2 dims, unpacked, port, imported bare names, local typedefs) | § defNetEndOnlyLoc130 | 20 | 16 | 4 | 16 |
| g2 t01-t02 (the two corpus type-parameter enum rows) | residue R1 (§ typeParamChainBorrow45 is the nearest law at the site) | 2 | 2 | 0 | 0 |
| g3 w01-w08 (`.*` alone, bind, mixed with named, implicit `.a` control, generate, vector, two modules, nested) | § wildcardConnRefSpan130 | 8 | 8 | 1 | 8 |
| g4 d01-d06 (Disable, foreach: residue R4 under § implicitNetNoFile119; class specialization arguments) | § classSpecArgNetNoFile130 | 6 | 5 | 0 | 0 (the class rows lose exactly their net facet: 27->26, 14->13, 30->28 objects) |
| g5 s01-s15 (`wire signed` vector/scalar, `unsigned`, 2-dim, init, `tri`, sub-module, interface, parameter width; controls: `logic signed`, `reg signed`, ports, unpacked) | § netSigningTsSpan130 | 15 | 13 | 4 | 13 |
| g6 p01-p14 (override, nested interface port, default, localparam, modport control, generic, two levels, two params, child reads the parameter, typed, struct operation default control, struct constant default, vector) | § portViewParamDefName130 | 14 | 13 | 1 | 7 (p04 p14: the folded Rhs constant span, sister's; p06/p07: structural; p09: hier-name faces; p11: control) |
| g7 t01 (TypeParam) | residue R3 | 1 | 1 | 0 | 0 |
| g8 k01-k09 (signed/unsigned struct, union, sub-module, init, multi-line signing, interface) | § suSigningNotInSpan130, § ifaceElabInlineSuKeyword130 | 9 | 9 | 0 | 8 (k05: the initialized struct_net span, another road) |
| g9 r01-r08 (redefinition without include, two drops, one-line macro after, inside the module, include after, inside an include, multi-line macro after, two modules) | § emptyRedefineObjLine130 | 8 | 8 | 0 | 7 (r07: the multi-line invocation line itself, R6) |
| g10 q01-q11 (include contents) | § includeNoTextSplicesNothing130 | 11 | 11 | 4 | 11 |
| g11 n01-n04 (loop in an include, from a macro, plain, nested include) | § genvarIntTsRootFile130 | 4 | 4 | 2 | 4 |
| r11v125 rd z01-z12, gv v01-v08 (byte controls of pass 125, re-scored) | pass-125 laws + this pass | 19 | 19 | 9 | 19 |

No cell's per-field counts grow; every NOT_EQUAL cell keeps its uhdm-cmp line count (e04 36, e09 28, e12
58, e17 28, d06 94, s06 62, s09 62, p08 32: the same with both binaries).

## 5. Census: strict column, law sweep vs pristine sweep, row by row (evidence/cols_P_L.tsv)

| corpus | judge-equal row-modes | strict-equal pristine | strict-equal law |
|---|---|---|---|
| surelog | 954 (480 + 474) | 593 | 600 |
| uhdm2rtlil | 1606 (803 + 803) | 1222 | 1242 |
| probe cases | 4087 | 1890 | 1902 |

Row-modes changed: 46 = 27 `differ -> equal`, 8 fewer objects on the same first field, 11 first field
moved with fewer objects (YosysOldOpen/testflags endcol(6) -> depth(1): the depth divergence was already
there, the five endcol objects cleared); **0 worse, 0 more, 0 status changes**. Probe cases
(evidence/probe_P_L.tsv): 12 turned equal, 5 fewer, 8 moved with fewer, 0 worse.

Two interim sweeps caught the two defects this pass fixed before the final sweep: the first port-view
cut named GenIfIfaceParamStructField's operation-valued parameter by its definition (col(7) -> col(9)),
and the first include-splice rule counted `timescale.v` as empty (YosysOldI2c `equal` -> `line(3)`,
YosysOldOr line(78) -> line(140)). Both are back to their pristine cells.

## 6. Gates

1. build: pristine `7c5a7e01c461` (= main tree), law `6a3e91ed5fc4`.
2. probe: `EQUAL=4087 (of 4087)`; strict tally 1890 -> 1902.
3. corpora: surelog `[default] CMP_EQUAL=480 ... [testflags] CMP_EQUAL=474`, uhdm2rtlil 803/1/67 both
   modes; `regressions=0 conversions=0 changes=0` in both (the sweep's rc=1 is `law index STALE`,
   before tests/LAWS.md was regenerated with this README).
4. downstream (law): `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not
   excused=0`; verdict and `differs` identical to results/downstream_uhdm2rtlil.csv on every row
   (func_upto, matching_end_labels EQUIVALENT = baseline; the pass-120 rows and arb_idx_cast
   IDENTICAL; every turned uhdm2rtlil row IDENTICAL). evidence/downstream_law.csv.
5. uhdm-cmp: every corpus row keeps its status; every grid cell equal at base keeps 0 lines; the
   NOT_EQUAL cells keep their line counts.
6. byteverify (`SELFCHECK=1`, same-length workdirs): PATH_SETS_IDENTICAL both corpora, SELFCHECK
   959/960 and 1607/1608; MOVERS 33/960 (surelog) + 32/1608 (uhdm2rtlil) = 65 databases
   (evidence/byteverify_*.txt, byte_movers.txt). PREDICTED from the pristine databases first
   (drivers/predict.py, evidence/predict_pristine.tsv: every strict-NE row whose golden-vs-pristine
   records carry a field a law writes, toward the value it writes): 60 of the 65 are in the predicted
   set with the law's signature; the other 5 are MiniAmiq (both modes), SeqDriver (both modes),
   SimpleUVM/testflags (the known UVM order coin) and Kmac, VarPassedTo2Submodules (both modes, whose
   pristine walk diverges before the moved objects) — attributed below.
   Attribution (drivers/attrib.sh, evidence/attribution.txt): each switch alone on the law binary over
   every mover, both modes. Every mover is owned by at least one law and
   `R11U130_OFF=1` gives the pristine bytes back on 60 of the 65; the other 5 are the UVM coin
   (MiniAmiq both modes, SeqDriver both modes, SimpleUVM/testflags: every run of them, the switch runs
   included, differs from the pristine sweep by 4 dump lines, `UINT`/`vpiDecompile` of one order, order-blind
   sorted diff = those 4 lines). Per law: DEFNETLOC 20 databases (AnonymousEnum, dyn_field_select,
   Earlgrey_0_1, EnumArray, EnumArrayListedElements, InterfArrayBind, PackedEnumPort,
   packed_struct_array_net_elem, simple_enum, StructArrayNet, VarPassedTo2Submodules: its only moved
   field is the packed_array VpiFile, K0053's face, invisible to uhdm-dump; Earlgrey_0_1's flash_ctrl
   `flash_ctrl_reg2hw_mp_region_cfg_mreg_t [MpRegions:0] region_cfgs;` gains 310:3-310:55, which golden's
   uhdm-dump reads identically for every listing of that object); WILDSPAN 16 (WildConn,
   sva_basic02, gen_scope_numports, and the `.*` rows whose walk diverges earlier: ApbSlave, Kmac,
   Earlgrey_0_1, def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot — their moved objects are
   exactly the `.*` HighConn ref_objs going from 2 to 1 column, e.g. Kmac `strength_i` 13:20-13:22 ->
   13:20-13:21); PVPARAM 12; NETSIGN 6; CLSARGNET 2; SUSIGN 2; REDEFLINE, INCNOTEXT, GVTSFILE, IFSUKW 0
   (no corpus row carries their shapes; their grids are their controls). The prediction's signature
   named another law on ApbSlave, def_ctx_struct_param and the latch rows (their pristine walks diverge
   before the `.*` objects, so the signature saw only the later line faces); Kmac and
   VarPassedTo2Submodules were outside the signature set for the same reason (walk diverged, no
   signature before it) and are attributed by the switch runs.
7. canaries: `canaries.sh` law vs pristine: surelog ok=48 changed=4 (YosysOldOpen line(19) -> (14),
   endcol(6) -> depth(1); ClassTypeParam endline(27) -> (26), file(40) -> (39): strict improvements),
   uhdm2rtlil ok=16 changed=0. `EXPECT_UNKNOWN=1 ctcan2.sh` (committed surelog csv, LF-normalised: it
   checks out CRLF here) PASS ok=58 changed=0; `EXPECT_UNKNOWN=6` uhdm2rtlil PASS ok=2.

## 7. Residues, ranked

* **R1 type-parameter override by a module-local enum typedef** (K0028's other half:
  TypeParameterAsPortTypeWithEnum, ...OfParametrizedWidth; 4 row-modes; grid g2) — SISTER's ground.
  Site: ParamEmit.cpp emitParameters, the type-parameter override branch after § typeParamChainBorrow45:
  `its = buildEnumTs(ta9.getCanonicalType().as<EnumType>(), tgt9, std::string(ta9.name))`. Golden
  locates the object at the typedef declaration (12:3-14:13, `;` included) and names its base ref
  `<type_parameter full name>.<enum name>`. VERIFIED on a scratch build (never landed): passing
  `tp->VpiFullName() + "." + ta9.name` and `setLoc(its, <TypedefDeclaration>.sourceRange())` turns g2
  t01 strict-equal; t02 then keeps only the range `ref_obj StateWidth` full name inside the base
  typespec (`...test_parameter.state_e.StateWidth` vs ours `...test_parameter.StateWidth`).
* **R2 struct typespec spans taken at the use** (K0024, K0052, the rest of K0074): after this pass 34
  strict-NE row-modes still carry a struct/union span difference (evidence/residue_signatures_law.tsv:
  cva6_struct_param_field, gen_scope_typaram, IfGenTypeBinding, latch_fifo_dynfield,
  packed_array_struct(_port_sel), packed_struct_array_fifo, port_chained_type_param, RangeSelect,
  struct_member_cfg_width, struct_member_trailing_index, StructParamFieldRange, TaggedPattern,
  TypeParamElab, unpacked_struct_2d/_dyn_read/_mixed). The examples (RangeSelect ends at the `a[4]`
  declarator, gen_scope_typaram pair_t 17:13-60 at the declaration line's end, const_cast_signext at
  the reference) are the identity residue: one shared object where golden holds a copy per use.
* **R3 the type-parameter definition net** (K0070's corpus row TypeParam, structural class F): golden's
  `bottom` DATA1 binds TP1's default `logic_typespec`, ours an `int_typespec` 19:5 from
  materializeDefNetTs -> makeTypespec; the plain shapes (grid g7 probes, not kept) are already equal,
  only the chained `bottom #(.TP1(TP0))` under two instantiations differs. K0070's DATA2 face no longer
  heads the row at the base.
* **R4 late-bound implicit nets with a file** (K0034/K0027): the mints are the sister's — StmtEmit.cpp
  emitStmt Disable case (`loop`), ExprEmit.cpp emitExpr (foreach variables, hier names),
  ExprEmit.cpp fnLocalParamRangeActual; each should call `noteLateBindNet119` on the net it mints
  (grid g4 d01, d02). 36 strict-NE row-modes still carry a golden-empty logic_net file.
* **R5 TypedefWithParameter** (K0049/K0057): the head is not the fold. Golden's package typedef
  `my_pkg::word` spans 3:12-7:26 — writeNets' end-only populate lands on the SHARED typedef typespec of
  `my_pkg::word w = 8'h5C;` and moves its end to the initializer — and our net typespec carries a
  Typedef_alias clone golden lacks (class B), so the walk diverges before the range.
* **R6 macro/include line model**: a multi-line macro's first output line reads the `define line
  (grid g9 r07's invocation line, r11v125 mf w04); text before an `include on its line reads the
  included file (r11v125 ic x02, x08).
* **R7 folded parameter Rhs constant spans** (grid g6 p04/p14: golden `2 + 3` folded spans only `2`):
  ParamEmit.cpp, sister's.
* Port views not covered: modport views and two-level views keep structural differences (grid g6
  p06, p07); iface_param_port_width, interface_array(_fanout) keep parameter full-name faces after this
  pass (6 row-modes).

## 8. Files

* `grid/g1..g11/` — the cases (every `dut.sv` names its law in its first line).
* `evidence/` — grid_scores.txt, switches_grid.txt, cols_P_L.tsv (strict column, row by row),
  probe_P_L.tsv, byteverify_*.txt, byte_movers.txt, predict_pristine.tsv, attribution.txt,
  residue_signatures_law.tsv, downstream_law.csv (the four slang-fenced tests' rows are left out of the
  committed evidence files; the sweeps ran them as the standard harness does, none of them moved).
* `drivers/` — case.sh / casediff.sh / gridscore.sh (one case), rowcmp.sh (one sweep row), rows.sh
  (filtered corpus rows), pinsite.sh / pinrow.sh (gdb mint sites on the `-g1` build), linemap.py (line
  offsets per record), strictcols.py / probecols.py (row-by-row strict census), probe_strict.py,
  predict.py (mover prediction from pristine databases), switches.sh / attrib.sh (per-law attribution).
