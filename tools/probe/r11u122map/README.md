# r11u122map — the strict ground map (measurement only)

Base `fc313b50` (branch matrix-1.87). No source edits. Worktree `/tmp/wt_r11u122`, built with
the system-deps config at `-j 2`: `build/slang-uhdm` md5 `3e6d2800759fb6ea476700223ab73bb0`
(byte-identical to the main tree's), `build/uhdm-strictcmp` md5 `6396c5583bc627b6ae61979a3d8d94f4`
(identical to the main tree's). Both were frozen (`chmod 555`) before any measurement.
Inputs (read-only): the fc313b50 strict sweeps `/tmp/strict_sweep/{surelog,uhdm2rtlil}.csv` and
their per-row `slang.uhdm` + `cmds.txt` (every cmds.txt audited: binary path =
`/home/heyfey/git-repos/slang-uhdm/build/slang-uhdm`, golden = the cached `golden.uhdm` it names).

## 0. Where we stand (fc313b50)

| corpus | judge-equal row-modes | strict-equal | strict NOT equal | tests judge-equal | tests strict-equal in every judged mode |
|---|---|---|---|---|---|
| surelog | 954 | 471 | 483 (256 tests) | 480 | 224 |
| uhdm2rtlil | 1606 | 1026 | 580 (290 tests) | 803 | 513 |

Downstream (the consumer): 794 IDENTICAL / 66 SLANG_REJECT / 7 EQUIVALENT / 4 DIVERGENT of 871.
The strict column is far stronger than the downstream need (290 u2r tests strict-NE, only 11 downstream
non-IDENTICAL). §5 maps the 11 downstream rows onto the clusters.

## 1. Method

1. `drivers/run1.sh`: `uhdm-strictcmp --max 50 --dump-a <golden records> --dump-b <our records> golden.uhdm slang.uhdm`
   on all **1063** strict-NE row-modes (483 surelog + 580 u2r; both modes, since 31 surelog tests differ
   by mode — e.g. AllPackageSignal/ArrayExprFuncArg are equal in default, NE in testflags). 1063/1063 rc=2;
   the tool's first field and `objects_differing` reproduce the csv `strict` cell on **1063/1063** rows.
2. `drivers/analyze.py` records EVERY differing object, not just the first (the tool stops at the first
   structural break). Alignment: GNU `diff` over the key (depth,type,name,defname); change hunks are
   sub-aligned by type (difflib). Paired objects are split into FACETS: `name`, `fullname`, `file`, `span`
   (line/col/endline/endcol), `value` (decompile/size/value/consttype); an unpaired object is a `struct`
   facet counted once at its subtree root (with its subtree size) and classified by the other side's
   multiset of (type,name,span) signatures: `fewer-copies` (the other side has fewer objects with that
   signature = object IDENTITY is shared there), `elsewhere` (the other side has it, first reached at a
   different walk point), `absent` (no same-signature object — often a span variant). Same-type pairs at a
   different depth are `depth`; a subtree equal to a sibling of its partner is `order`. A `file` facet whose
   file is a DIFFERENT buffer absorbs its span diff (`other-file+span`).
   Cross-check: on the 404 rows whose walk never diverged, the analyzer's differing-object set equals the
   tool's `objects_differing` on **404/404**.
3. Cluster = `facet|object type|shape|under:<walk parent type>` (1987 clusters); family = a brief-sized
   union (257 families; `drivers/final.py:family()`). Ranked by row-modes covered.
4. Yield: a row-mode becomes strict-equal only when EVERY facet of it falls in fixed clusters
   (computed from the per-object facets, `drivers/final.py:yld`); `tests` = every NE mode of the test clears.

### What the fields mean (decoded before clustering)

* `fullname` is `vpi_get_str(vpiFullName)`: the stored VpiFullName, else `BaseClass::ComputeFullName()`
  over the **vpiParent** chain ([BaseClass.cpp:100](../../../third_party/Surelog/third_party/UHDM/templates/BaseClass.cpp#L100)),
  and it prints EMPTY when fullname == VpiName ([classes.py:440](../../../third_party/Surelog/third_party/UHDM/scripts/classes.py#L440)).
  So a fullname diff on an unnamed object (ref_typespec, constant, operation) is a **parenting** diff, and
  `golden-empty` on a named object means golden's fullname is the bare name.
* The record walk is `VpiListener`: an object already visited in the current collection epoch is not
  re-entered ([VpiListener.cpp:43](../../../third_party/Surelog/third_party/UHDM/templates/VpiListener.cpp#L43)).
  So a `struct` facet is an **object-identity** difference (Surelog holds a private copy where we point at
  an already-walked shared object, or the reverse), not missing content. Proof on the examples: the
  path-normalised `uhdm-dump` of golden vs ours is **0 lines** different on SizeOfUnsignedParameter,
  ImportedParameter, ConstPort, ParameterColonReference (evidence/uhdmdump/) — the dumper cannot see it;
  the plugin's pointer-keyed maps can.
* WHY Surelog copies typespecs: every `clone_tree` during compile/elaboration runs with
  `uniquifyTypespec_ = true` ([ElaboratorListener.h:165](../../../third_party/Surelog/third_party/UHDM/templates/ElaboratorListener.h#L165)),
  and the generated `ref_typespec::DeepCopy` then DEEP-CLONES the actual typespec
  ([classes.py:186](../../../third_party/Surelog/third_party/UHDM/scripts/classes.py#L186)); only the final
  `-elabuhdm` pass turns it off ([UhdmWriter.cpp:5245](../../../third_party/Surelog/src/DesignCompile/UhdmWriter.cpp#L5245)).
  Every object Surelog produces by `clone_tree` — imported package params ([CompileHelper.cpp:265](../../../third_party/Surelog/src/DesignCompile/CompileHelper.cpp#L265)),
  elaborated param_assign/constant copies, typedef clones ([ElaborationStep.cpp:203](../../../third_party/Surelog/src/DesignCompile/ElaborationStep.cpp#L203)) —
  therefore carries a private typespec whose vpiParent is the clone's ref_typespec. That one mechanism
  explains F01 (golden copies), the parent-chain fullnames of F02, and most walk-order echoes (F08,
  `elsewhere` rows).

## 2. Positive controls

| control | result |
|---|---|
| surelog/default/1364_2005 (strict equal) | `STRICT_EQUAL 146 objects`, record dumps byte-identical, analyzer 0 facets |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 220 objects`, dumps identical, analyzer 0 facets |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 182 objects`, dumps identical, analyzer 0 facets |
| uhdm2rtlil/default/stamped_gen_param (CMP_NOTEQUAL) | rc=1 `NOT_EQUAL stage1`, `lhsPath: design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant` (golden `1'b0` size 1 vs ours `6'b010101` size 6); no record dumps written |
| tool vs sweep | first field + count reproduce the csv strict cell on 1063/1063 |
| analyzer vs tool | 404/404 non-diverged rows agree on the differing-object count |

Outputs in evidence/controls/.

## 3. Ranked families (brief-sized units; 257 families, top 30)

`alone-yield` = row-modes that become strict-equal if ONLY this family were fixed.
Full list: family_index.csv.

| rank | family | rows (sl/u2r) | tests | objects | alone-yield | what it is / owner |
|---|---|---|---|---|---|---|
| 1 | F01 `STRUCT-TSCOPY\|golden` | 459 (199/260) | 233 | 402945 | 30 | golden holds a private typespec copy (clone_tree uniquify) where ours points at the shared declaration typespec |
| 2 | F02 `FULLNAME-IN-TYPESPEC-SUBTREE` | 390 (164/226) | 206 | 53020 | 45 | fullname of an object inside a typespec subtree = ComputeFullName over the copy's vpiParent chain; moves with F01/F04 |
| 3 | F03 `FILE-EMPTY\|parameter` | 320 (140/180) | 163 | 25938 | 89 | VpiFile missing on located parameters: C0001 genvar localparam (ModuleEmit.cpp:22851) + C0003 import Lhs clone (ParamEmit.cpp:7983) |
| 4 | F04 `STRUCT-TSCOPY\|ours` | 294 (118/176) | 149 | 55232 | 29 | ours mints a private typespec where golden shares (elab ports ModuleEmit.cpp:17153, nets) |
| 5 | F05 `FULLNAME\|ref_obj\|tok` | 137 (91/46) | 86 | 94543 | 11 | scoped fullname forms on ref_obj (package column `::` vs `.`, typedef-name insertion, instance prefix) |
| 6 | F06 `SPAN\|ref_obj` | 137 (73/64) | 71 | 23491 | 2 | ref_obj spans: hier_path base/leaf (C0007), port high-conn endcol, macro-arg shifts |
| 7 | F07 `SPAN\|constant` | 109 (61/48) | 56 | 114658 | 4 | constant spans: pkg-qualified folds (C0014), paren spans (C0039), sys_func_call args, zero spans |
| 8 | F08 `STRUCT-SHARE\|ours\|enum_const` | 88 (40/48) | 45 | 4274 | 6 | enum_const identity echo (golden reaches it inside its enum typespec copy) |
| 9 | F09 `FILE-EMPTY\|constant` | 67 (43/24) | 36 | 2105 | 1 | constants with no VpiFile: typedef range bounds (ParamEmit.cpp:28807), folded operands |
| 10 | F10 `FILE-OTHER-BUFFER` | 61 (29/32) | 32 | 174357 | 0 | macro/include buffer attribution: golden names the expansion-site file in some shapes (YosysOldSpi spi_clgen.v vs our spi_defines.v) and the macro-definition file in others (ibex prim_assert_standard_macros.svh vs our prim_assert.sv) |
| 11 | F11 `STRUCT-IMPPARAM-CLONE\|golden` | 59 (19/40) | 30 | 97894 | 0 | golden's imported param_assign Lhs is a module-scoped clone; gate ParamEmit.cpp:7957 |
| 12 | F12 `SPAN\|struct_typespec` | 59 (27/32) | 30 | 173 | 2 | struct typespec span (end at `}` vs name; RangeSelect 2:12-6:17 vs 2:12-4:5) |
| 13 | F13 `STRUCT-SHARE\|golden\|logic_net` | 53 (19/34) | 29 | 604 | 13 | golden holds a second logic_net reached via ref_obj.Actual |
| 14 | F14 `SPAN\|operation` | 50 (34/16) | 26 | 2021 | 0 | operation spans (paren inclusion, macro args) |
| 15 | F15 `SPAN\|logic_typespec` | 50 (32/18) | 26 | 907 | 2 | logic typespec endcol (SignedWire: 2:1-12 vs ours 2:1-19, signing keyword) |
| 16 | F16 `FULLNAME\|ref_obj\|golden-empty` | 46 (32/14) | 24 | 6218 | 2 | golden ref_obj fullname == bare name (hier_path leaves, C0009) |
| 17 | F17 `FILE-EMPTY\|int_typespec` | 45 (9/36) | 23 | 47 | 14 | elab cast int typespec copy without VpiFile (C0015) |
| 18 | F18 `VALUE\|parameter\|value:UINT->empty` | 43 (27/16) | 22 | 1131 | 10 | parameter VpiValue not stamped for $bits/type-derived folds (C0020) |
| 19 | F19 `FILE-EXTRA\|logic_net` | 42 (32/10) | 21 | 168 | 20 | we stamp VpiFile where golden has none (implicit/property nets) |
| 20 | F20 `SPAN\|type_parameter` | 42 (12/30) | 21 | 70 | 0 | elab type_parameter unlocated (C0022/C0023) |
| 21 | F21 `STRUCT-SHARE\|ours\|logic_net` | 40 (20/20) | 22 | 764 | 7 | ours holds a second logic_net golden shares |
| 22 | F22 `FILE-EMPTY\|type_parameter` | 40 (10/30) | 20 | 60 | 0 | elab type_parameter unlocated (C0022) |
| 23 | F23 `SPAN\|sys_func_call` | 39 (17/22) | 20 | 771 | 2 | sys_func_call spans (macro-expanded $error in asserts, CovMacro) |
| 24 | F24 `FILE-EMPTY\|integer_typespec` | 38 (10/28) | 19 | 94 | 12 | elab cast integer typespec copy without VpiFile (C0028) |
| 25 | F25 `SPAN\|assignment` | 35 (31/4) | 19 | 945 | 0 | assignment endcol (macro expansion, CovMacro) |
| 26 | F26 `VALUE\|parameter\|value:INT->UINT` | 35 (15/20) | 18 | 792 | 0 | `parameter int` folds: golden INT, ours UINT (C0034/C0044) |
| 27 | F27 `SPAN\|func_call` | 33 (21/12) | 17 | 15433 | 2 | func_call endcol (name vs call; struct_param_func_arg 16:39-42 vs 16:39-40) |
| 28 | F28 `SPAN\|begin` | 33 (19/14) | 17 | 9884 | 2 | begin block spans |
| 29 | F29 `FULLNAME\|bit_select\|tok` | 33 (25/8) | 22 | 8973 | 0 | bit_select fullname forms |
| 30 | F30 `WALK-DEPTH-ORDER` | 32 (14/18) | 16 | 26907 | 0 | same object at a different depth (reparented) or reordered siblings |

## 4. Ranked clusters with emitter sites (1987 clusters, top 45)

VERIFIED = the minting line read and the example record matched; DECODED = the Surelog mechanism read
from source; OWNER (candidate) = owning function named, exact line not pinned. Full list with every
cluster's example: cluster_index.csv; per-row membership: clusters.csv
(`test,mode,corpus,first_field,cluster_id,objects`, 10425 rows); one evidence file per cluster
(`evidence/<cluster>_<corpus>_<mode>_<test>.txt`: the object's golden and our records with a +-12 record
window, the holder on the other side, and every facet of that row).

| # | cluster | rows (sl/u2r) | tests | objects | alone-yield | key | smallest example (row #golden/#ours) | emitter site / decode |
|---|---|---|---|---|---|---|---|---|
| 1 | C0001 | 206 (78/128) | 106 | 22420 | 89 | `file\|parameter\|ours-empty\|under:gen_scope` | surelog/testflags/BlackBox #23/23 parameter core_idx | VERIFIED [ModuleEmit.cpp:22851](../../../src/ModuleEmit.cpp#L22851): the GENVAR gen-scope localparam gets VpiLineNo(loop line)/VpiColumnNo(0) directly, never through setLoc, so no VpiFile (golden dut.sv) |
| 2 | C0002 | 198 (94/104) | 101 | 15162 | 13 | `struct\|golden-only:fewer-copies\|int_typespec\|under:ref_typespec` | uhdm2rtlil/testflags/SizeOfUnsignedParameter #16/-1 int_typespec  | DECODED: Surelog clone_tree uniquify (section 1). Ours binds the declaration's typespec (param_assign Rhs constant, $bits call typespec); owner: constant-typespec binding in ParamEmit + sharedTypespec [UhdmExporter.h:2743](../../../include/UhdmExporter.h#L2743) |
| 3 | C0003 | 135 (79/56) | 68 | 3518 | 0 | `file\|parameter\|ours-empty\|under:param_assign` | uhdm2rtlil/testflags/ImportedParameter #23/23 parameter TxWidth | VERIFIED [ParamEmit.cpp:7983](../../../src/ParamEmit.cpp#L7983): the def-view imported-param Lhs clone upLhs9 copies line/col/endline/endcol (7986-7989) but not VpiFile |
| 4 | C0004 | 102 (42/60) | 52 | 135230 | 5 | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec` | uhdm2rtlil/testflags/PatternStruct #52/-1 struct_typespec my_struct | DECODED: same uniquify copy, struct typespec of casts/patterns (holder rows, any how: operation 48, constant 48, typespec_member 32) |
| 5 | C0005 | 94 (40/54) | 49 | 17651 | 5 | `struct\|golden-only:fewer-copies\|logic_typespec\|under:ref_typespec` | surelog/testflags/ComplexExprSize #13/-1 logic_typespec  | DECODED: same uniquify copy, logic typespec (holders: constant 46, operation 24, sys_func_call) |
| 6 | C0006 | 83 (41/42) | 43 | 23786 | 15 | `struct\|ours-only:fewer-copies\|logic_typespec\|under:ref_typespec` | surelog/testflags/ExplicitPort #-1/22 logic_typespec  | VERIFIED for the port subset (45 of 83 rows) [ModuleEmit.cpp:17153](../../../src/ModuleEmit.cpp#L17153): the ELAB port mints its own makeTypespec where golden shares the net's (ExplicitPort, ImplicitPorts2, PortExpr); the rest are net holders |
| 7 | C0007 | 81 (37/44) | 42 | 6918 | 0 | `span\|ref_obj\|col+endcol\|under:hier_path` | surelog/testflags/IOClassStruct #16/16 ref_obj access_record | OWNER (candidate) [ExprEmit.cpp:8314](../../../src/ExprEmit.cpp#L8314) buildDottedHierPath (+18 MakeHier_path sites in ExprEmit): golden gives the BASE member the LEAF member's span (IOClassStruct access_record.read_count++: base 18:20-30 = the leaf's span; ours 18:6-19) |
| 8 | C0008 | 66 (26/40) | 35 | 3267 | 6 | `struct\|ours-only:fewer-copies\|enum_const\|under:ref_obj` | surelog/testflags/ConstPort #-1/33 enum_const CIPH_INV | walk echo of the typespec-identity family: golden reaches the enum_const first inside its private enum_typespec copy, ours first through ref_obj.Actual |
| 9 | C0009 | 62 (36/26) | 32 | 6216 | 2 | `fullname\|ref_obj\|golden-empty\|under:hier_path` | surelog/testflags/IOClassStruct #19/19 ref_obj read_count | OWNER (candidate) the same hier_path builders: golden's leaf member ref_obj fullname == its bare name (prints empty); ours scoped |
| 10 | C0010 | 61 (21/40) | 31 | 1671 | 0 | `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | surelog/testflags/PatternOrder #12/12 ref_typespec  | parent chain of the typespec copy (F02): golden BC1.B (member ref under a struct copy parented at typespec_member BC1), ours B |
| 11 | C0011 | 60 (32/28) | 31 | 1644 | 0 | `struct\|golden-only:elsewhere\|logic_typespec\|under:ref_typespec` | uhdm2rtlil/testflags/OneSysFunc #15/-1 logic_typespec  | DECODED: uniquify copy first reached elsewhere (walk order), logic typespec |
| 12 | C0012 | 58 (18/40) | 29 | 97822 | 0 | `struct\|golden-only:fewer-copies\|parameter\|under:param_assign` | surelog/testflags/ParamFromPackage #59/-1 parameter X | VERIFIED gate [ParamEmit.cpp:7957](../../../src/ParamEmit.cpp#L7957) wantLhsClone9: Surelog clones EVERY imported param_assign ([CompileHelper.cpp:265](../../../third_party/Surelog/src/DesignCompile/CompileHelper.cpp#L265)) so its Lhs is a module-scoped copy (work@aes_cipher_core.X); ours clones only the gated shapes (ParamFromPackage: a packed-array-typed import stays shared) |
| 13 | C0013 | 57 (23/34) | 29 | 543 | 0 | `fullname\|ref_typespec\|golden-empty\|under:operation` | surelog/testflags/ParamNoImport #29/29 ref_typespec  | golden's ref_typespec of a cast operation has no named vpiParent chain (prints empty); ours is parented into the package/module. Owner: the cast arm of emitExpr (ExprEmit) |
| 14 | C0014 | 50 (24/26) | 25 | 1204 | 0 | `span\|constant\|endcol\|under:param_assign` | surelog/testflags/ParamConstPush #73/73 constant  | package-qualified RHS constant (base_pkg::USAGE): def view golden endcol 48 / ours 53, elab view the reverse (ParamConstPush). Owner: ParamEmit param_assign RHS fold |
| 15 | C0015 | 45 (9/36) | 23 | 47 | 14 | `file\|int_typespec\|ours-empty\|under:ref_typespec` | uhdm2rtlil/testflags/Shortreal #31/31 int_typespec  | the ELAB copy of a cast-target int typespec has a span but no VpiFile (Shortreal: the def copy has dut.sv, the elab copy none); owner (candidate) the emitExpr cast arm; census of span-copy sites without VpiFile in section 6 |
| 16 | C0016 | 43 (21/22) | 23 | 1580 | 0 | `struct\|ours-only:elsewhere\|logic_typespec\|under:ref_typespec` | uhdm2rtlil/testflags/OneSysFunc #-1/35 logic_typespec  | walk echo (our logic_typespec reached first elsewhere) |
| 17 | C0017 | 42 (18/24) | 21 | 276 | 4 | `fullname\|ref_typespec\|tok:id@id.id.id::id.->id::id::id::\|under:typespec_member` | surelog/testflags/ParamNoImport #46/46 ref_typespec  | parent chain of the typespec copy: golden work@dut.t.pkg::pwr_ast_rsp_t.slow_clk_val vs ours (package-column form) pkg::pkg::pwr_ast_rsp_t::slow_clk_val |
| 18 | C0018 | 42 (14/28) | 21 | 242 | 0 | `fullname\|ref_typespec\|tok:->id.\|under:typespec_member` | surelog/testflags/HierPathEval #70/72 ref_typespec  | parent chain of the typespec copy (ours inserts the parameter name) |
| 19 | C0019 | 41 (21/20) | 21 | 1438 | 0 | `file\|constant\|ours-empty\|under:range` | surelog/testflags/TypedefRange #19/23 constant  | VERIFIED (gdb: both ranges minted in emitPackage) [ParamEmit.cpp:28807](../../../src/ParamEmit.cpp#L28807): the packed-array-over-typedef range bounds mkB2 (28809) get no location at all (golden dut.sv 5:14-15, ours 0:0:0:0) |
| 20 | C0020 | 41 (25/16) | 21 | 669 | 10 | `value\|parameter\|value:UINT->empty\|under:module_inst` | surelog/testflags/BitsLogic #12/12 parameter p | parameter folded from $bits(type) (BitsLogic parameter p = $bits(ReplayQueueEntry)): golden VpiValue UINT:12, ours none. Owner: ParamEmit parameter value stamping |
| 21 | C0021 | 40 (14/26) | 20 | 356 | 0 | `struct\|ours-only:elsewhere\|enum_typespec\|under:package` | surelog/testflags/HierPathOverride #-1/45 enum_typespec prim_pad_wrapper_pkg::pad_type_e | walk echo: our package lists the enum_typespec that golden first reaches through a copy |
| 22 | C0022 | 40 (10/30) | 20 | 60 | 0 | `file\|type_parameter\|ours-empty\|under:module_inst` | uhdm2rtlil/testflags/top_module_type_param #28/28 type_parameter data_t | elab type_parameter with no location at all (top_module_type_param: golden dut.sv 7:20-26, ours 0 and no file). Owner: elab type_parameter emission |
| 23 | C0023 | 40 (10/30) | 20 | 60 | 0 | `span\|type_parameter\|ours-zero\|under:module_inst` | uhdm2rtlil/testflags/top_module_type_param #28/28 type_parameter data_t | the same objects as C0022 (span facet) |
| 24 | C0024 | 39 (15/24) | 22 | 219 | 13 | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` | uhdm2rtlil/testflags/ParameterColonReference #42/-1 logic_net a | golden holds a second logic_net copy reached via ref_obj.Actual (ParameterColonReference) |
| 25 | C0025 | 38 (20/18) | 19 | 4852 | 6 | `fullname\|ref_typespec\|tok:id@id.->\|under:typespec_member` | surelog/testflags/HierPathStruct #18/18 ref_typespec  | parent chain of the typespec copy (golden work@dut. prefix) |
| 26 | C0026 | 38 (22/16) | 20 | 968 | 0 | `struct\|ours-only:elsewhere\|enum_const\|under:ref_obj` | surelog/default/InterfArrayBind #-1/121 enum_const IO_ONES | walk echo of enum_const identity |
| 27 | C0027 | 38 (12/26) | 19 | 552 | 0 | `struct\|golden-only:fewer-copies\|enum_typespec\|under:module_inst` | surelog/testflags/HierPathOverride #300/-1 enum_typespec prim_pad_wrapper_pkg::pad_type_e | golden module_inst lists a private enum_typespec copy (HierPathOverride) |
| 28 | C0028 | 38 (10/28) | 19 | 94 | 12 | `file\|integer_typespec\|ours-empty\|under:ref_typespec` | uhdm2rtlil/testflags/CastSize #46/46 integer_typespec  | elab cast integer typespec with span but no VpiFile (CastSize): the C0015 mechanism |
| 29 | C0029 | 37 (9/28) | 19 | 5173 | 0 | `struct\|ours-only:elsewhere\|struct_typespec\|under:ref_typespec` | surelog/testflags/TypedefRange #-1/18 struct_typespec pkg::a | walk echo (struct typespec reached first elsewhere in ours) |
| 30 | C0030 | 37 (7/30) | 19 | 1322 | 0 | `struct\|golden-only:fewer-copies\|array_typespec\|under:ref_typespec` | surelog/testflags/HierPathVarArray #25/-1 array_typespec pkg::b | uniquify copy, array_typespec |
| 31 | C0031 | 36 (10/26) | 18 | 238 | 0 | `struct\|golden-only:elsewhere\|struct_typespec\|under:ref_typespec` | surelog/testflags/TypedefRange #22/-1 struct_typespec pkg::a | walk echo, struct typespec |
| 32 | C0032 | 35 (23/12) | 18 | 2530 | 2 | `struct\|golden-only:fewer-copies\|enum_typespec\|under:ref_typespec` | uhdm2rtlil/testflags/PackageCast #99/-1 enum_typespec pkg::enum_t | uniquify copy, enum_typespec (PackageCast) |
| 33 | C0033 | 35 (7/28) | 18 | 1050 | 0 | `struct\|golden-only:fewer-copies\|range\|under:parameter` | surelog/testflags/DefaultPatternInt #64/-1 range  | golden parameter carries a private range copy |
| 34 | C0034 | 35 (15/20) | 18 | 224 | 0 | `value\|parameter\|value:INT->UINT\|under:package` | surelog/testflags/HierPathStructTypespec #116/116 parameter BufferCycles | parameter int X = <expr> folded value: golden INT:15, ours UINT:15 (package view, HierPathStructTypespec) |
| 35 | C0035 | 34 (4/30) | 17 | 1530 | 0 | `struct\|golden-only:fewer-copies\|struct_typespec\|under:module_inst` | uhdm2rtlil/testflags/StructArrayParameterInitializedByPatternPassedAsPort #87/-1 struct_typespec flash_ctrl_pkg::data_region_attr_t | golden module_inst lists a private struct_typespec copy |
| 36 | C0036 | 34 (14/20) | 17 | 822 | 0 | `struct\|ours-only:fewer-copies\|struct_typespec\|under:module_inst` | surelog/testflags/HierPathEval #-1/83 struct_typespec pinmux_pkg::target_cfg_t | ours module_inst lists a struct_typespec golden reaches elsewhere |
| 37 | C0037 | 34 (8/26) | 18 | 167 | 2 | `fullname\|ref_typespec\|golden-empty\|under:constant` | uhdm2rtlil/testflags/LocalParamInNestedForLoops #65/65 ref_typespec  | as C0013 on a constant holder |
| 38 | C0038 | 32 (4/28) | 16 | 270 | 2 | `fullname\|ref_typespec\|tok:id@id.id::id.->id::id::id::\|under:typespec_member` | surelog/testflags/MultiPort #15/15 ref_typespec  | parent chain of the typespec copy (package-column form in ours) |
| 39 | C0039 | 32 (12/20) | 16 | 172 | 2 | `span\|constant\|col+endcol\|under:param_assign` | surelog/default/BlackParrotSkipParam #120/120 constant  | param_assign RHS constant span: golden 4:31-52, ours 4:32-51 (BlackParrotSkipParam) |
| 40 | C0040 | 30 (20/10) | 16 | 1783 | 0 | `struct\|ours-only:elsewhere\|int_typespec\|under:ref_typespec` | surelog/testflags/InterfType #-1/42 int_typespec  | walk echo, int_typespec |
| 41 | C0041 | 30 (6/24) | 15 | 48 | 0 | `fullname\|ref_typespec\|tok:id.id::id.id.->\|under:enum_typespec` | surelog/testflags/HierPathOverride #241/227 ref_typespec  | parent chain of the typespec copy (enum member ref) |
| 42 | C0042 | 29 (21/8) | 18 | 134 | 8 | `file\|logic_net\|golden-empty\|under:ref_obj` | surelog/testflags/CheckerInst #11/11 logic_net req | we stamp VpiFile on a logic_net golden leaves fileless (reached through a property ref_obj; CheckerInst) |
| 43 | C0043 | 28 (8/20) | 15 | 1957 | 0 | `file\|ref_obj\|other-file\|under:operation` | uhdm2rtlil/testflags/ibex_csr #53/53 ref_obj clk_i | macro-expansion buffer attribution: golden prim_assert_standard_macros.svh, ours prim_assert.sv (ibex asserts) |
| 44 | C0044 | 28 (8/20) | 14 | 396 | 0 | `value\|parameter\|value:INT->UINT\|under:module_inst` | surelog/testflags/HierPathStructTypespec #296/295 parameter BufferCycles | as C0034, elab view |
| 45 | C0045 | 28 (8/20) | 14 | 56 | 0 | `fullname\|ref_obj\|tok:::->.\|under:operation` | surelog/testflags/EarlgreyPackParam #10/10 ref_obj NAlerts | fullname column form pkg::A::N (golden) vs pkg::A.N (ours) on a ref_obj in a typespec range |

## 5. Predicted yield

Rows = the 1063 strict-NE row-modes; tests = 546 (256 surelog + 290 u2r), a test counts when every NE mode clears.

**Top 15 clusters** (alone = only that cluster fixed; cum = clusters 1..k fixed together, in rank order):

| cluster | rows covered | objects | alone | cum rows | cum tests |
|---|---|---|---|---|---|
| C0001 `file\|parameter\|ours-empty\|under:gen_scope` | 206 | 22420 | 89 | 89 | 46 |
| C0002 `struct\|golden-only:fewer-copies\|int_typespec\|under:ref_typespec` | 198 | 15162 | 13 | 116 | 58 |
| C0003 `file\|parameter\|ours-empty\|under:param_assign` | 135 | 3518 | 0 | 139 | 69 |
| C0004 `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec` | 102 | 135230 | 5 | 144 | 72 |
| C0005 `struct\|golden-only:fewer-copies\|logic_typespec\|under:ref_typespec` | 94 | 17651 | 5 | 161 | 80 |
| C0006 `struct\|ours-only:fewer-copies\|logic_typespec\|under:ref_typespec` | 83 | 23786 | 15 | 183 | 90 |
| C0007 `span\|ref_obj\|col+endcol\|under:hier_path` | 81 | 6918 | 0 | 183 | 90 |
| C0008 `struct\|ours-only:fewer-copies\|enum_const\|under:ref_obj` | 66 | 3267 | 6 | 193 | 95 |
| C0009 `fullname\|ref_obj\|golden-empty\|under:hier_path` | 62 | 6216 | 2 | 195 | 96 |
| C0010 `fullname\|ref_typespec\|tok:id.->\|under:typespec_member` | 61 | 1671 | 0 | 195 | 96 |
| C0011 `struct\|golden-only:elsewhere\|logic_typespec\|under:ref_typespec` | 60 | 1644 | 0 | 199 | 98 |
| C0012 `struct\|golden-only:fewer-copies\|parameter\|under:param_assign` | 58 | 97822 | 0 | 199 | 98 |
| C0013 `fullname\|ref_typespec\|golden-empty\|under:operation` | 57 | 543 | 0 | 202 | 100 |
| C0014 `span\|constant\|endcol\|under:param_assign` | 50 | 1204 | 0 | 204 | 101 |
| C0015 `file\|int_typespec\|ours-empty\|under:ref_typespec` | 45 | 47 | 14 | 224 | 111 |

**Top 15 families** (rank order):

| family | rows covered | objects | alone | cum rows | cum tests |
|---|---|---|---|---|---|
| F01 `STRUCT-TSCOPY\|golden` | 459 | 402945 | 30 | 30 | 14 |
| F02 `FULLNAME-IN-TYPESPEC-SUBTREE` | 390 | 53020 | 45 | 90 | 45 |
| F03 `FILE-EMPTY\|parameter` | 320 | 25938 | 89 | 244 | 123 |
| F04 `STRUCT-TSCOPY\|ours` | 294 | 55232 | 29 | 319 | 159 |
| F05 `FULLNAME\|ref_obj\|tok` | 137 | 94543 | 11 | 339 | 175 |
| F06 `SPAN\|ref_obj` | 137 | 23491 | 2 | 361 | 186 |
| F07 `SPAN\|constant` | 109 | 114658 | 4 | 371 | 191 |
| F08 `STRUCT-SHARE\|ours\|enum_const` | 88 | 4274 | 6 | 395 | 203 |
| F09 `FILE-EMPTY\|constant` | 67 | 2105 | 1 | 398 | 205 |
| F10 `FILE-OTHER-BUFFER` | 61 | 174357 | 0 | 402 | 207 |
| F11 `STRUCT-IMPPARAM-CLONE\|golden` | 59 | 97894 | 0 | 412 | 212 |
| F12 `SPAN\|struct_typespec` | 59 | 173 | 2 | 422 | 217 |
| F13 `STRUCT-SHARE\|golden\|logic_net` | 53 | 604 | 13 | 442 | 228 |
| F14 `SPAN\|operation` | 50 | 2021 | 0 | 460 | 237 |
| F15 `SPAN\|logic_typespec` | 50 | 907 | 2 | 462 | 238 |

**Greedy by marginal yield** (families; the best order to land them):

| step | family | cum rows | cum tests |
|---|---|---|---|
| 1 | F03 `FILE-EMPTY\|parameter` | 89 | 46 |
| 2 | F01 `STRUCT-TSCOPY\|golden` | 169 | 84 |
| 3 | F02 `FULLNAME-IN-TYPESPEC-SUBTREE` | 244 | 123 |
| 4 | F04 `STRUCT-TSCOPY\|ours` | 319 | 159 |
| 5 | F08 `STRUCT-SHARE\|ours\|enum_const` | 343 | 171 |
| 6 | F17 `FILE-EMPTY\|int_typespec` | 367 | 183 |
| 7 | F06 `SPAN\|ref_obj` | 389 | 194 |
| 8 | F24 `FILE-EMPTY\|integer_typespec` | 413 | 206 |
| 9 | F19 `FILE-EXTRA\|logic_net` | 435 | 216 |
| 10 | F05 `FULLNAME\|ref_obj\|tok` | 456 | 233 |
| 11 | F13 `STRUCT-SHARE\|golden\|logic_net` | 478 | 245 |
| 12 | F21 `STRUCT-SHARE\|ours\|logic_net` | 501 | 257 |
| 13 | F16 `FULLNAME\|ref_obj\|golden-empty` | 515 | 264 |
| 14 | F27 `SPAN\|func_call` | 526 | 269 |
| 15 | F12 `SPAN\|struct_typespec` | 538 | 275 |

**Strategic unions** (which axis unlocks rows):

    TYPESPEC-IDENTITY (tscopy both sides + fullname-in-ts-subtree + absent *_typespec + walk): families=21 rows_touched=681 yield_rows=167 yield_tests=82
    ALL STRUCT + WALK + FULLNAME-IN-TS: families=87 rows_touched=755 yield_rows=221 yield_tests=110
    FILE-EMPTY (all kinds): families=23 rows_touched=522 yield_rows=138 yield_tests=71
    ALL FILE (empty+extra+other-buffer): families=33 rows_touched=592 yield_rows=158 yield_tests=80
    ALL SPAN: families=69 rows_touched=394 yield_rows=44 yield_tests=22
    ALL FULLNAME: families=38 rows_touched=484 yield_rows=74 yield_tests=45
    ALL VALUE+NAME: families=31 rows_touched=123 yield_rows=25 yield_tests=12
    FILE+STRUCT: yield_rows=522 yield_tests=260
    FILE+STRUCT+FULLNAME: yield_rows=611 yield_tests=318
    FILE+STRUCT+FULLNAME+SPAN: yield_rows=940 yield_tests=483
    everything: yield_rows=1063 yield_tests=546
    surelog rows 483 FILE-EMPTY yield 44 ALL FILE 60 STRUCT 99
    uhdm2rtlil rows 580 FILE-EMPTY yield 94 ALL FILE 98 STRUCT 122

Reading: file + structure/identity together clear 522 of 1063 row-modes (260 of 546 tests); adding
fullname gives 611, adding spans 940. Spans alone clear only 44 — they almost never occur alone. The
single best first landing is FILE-EMPTY|parameter (C0001 + C0003): 89 row-modes / 46 tests by itself,
and C0001 is also the whole strict delta of the downstream EQUIVALENT row func_upto (section 7).

## 6. Structure the judge never walks (depth/count facets)

All `struct` facets are identity differences unless `absent` (see section 1). Kinds per container
(walk holder < its parent), top 40; `how` as in section 1:

| side | how | kind | walk container (holder < its parent) | rows | objects | example |
|---|---|---|---|---|---|---|
| golden | fewer-copies | int_typespec | ref_typespec < constant | 186 | 13727 | uhdm2rtlil/testflags/ImportedParameter #48 |
| golden | fewer-copies | parameter | param_assign < module_inst | 50 | 41496 | surelog/testflags/ParamFromPackage #59 |
| golden | fewer-copies | struct_typespec | ref_typespec < operation | 48 | 117071 | uhdm2rtlil/testflags/CastStruct #59 |
| golden | elsewhere | logic_typespec | ref_typespec < port | 47 | 1567 | surelog/default/WildConn #95 |
| golden | fewer-copies | logic_typespec | ref_typespec < constant | 46 | 12666 | surelog/testflags/ParamConstPush #97 |
| ours | fewer-copies | logic_typespec | ref_typespec < port | 45 | 17002 | surelog/testflags/ExplicitPort #32 |
| ours | elsewhere | enum_typespec | package < design | 40 | 356 | surelog/testflags/HierPathOverride #45 |
| ours | fewer-copies | enum_const | ref_obj < operation | 38 | 529 | surelog/testflags/PackImport #53 |
| golden | fewer-copies | range | parameter < module_inst | 34 | 914 | surelog/testflags/DefaultPatternInt #64 |
| golden | fewer-copies | struct_typespec | module_inst < design | 34 | 1530 | uhdm2rtlil/testflags/StructArrayParameterInitializedByPatternPassedAsPort #87 |
| ours | fewer-copies | enum_const | ref_obj < case_item | 33 | 1520 | surelog/testflags/FuncCase #60 |
| golden | fewer-copies | struct_typespec | ref_typespec < typespec_member | 32 | 1094 | uhdm2rtlil/testflags/iface_nested_param_field #290 |
| ours | fewer-copies | struct_typespec | module_inst < design | 32 | 192 | surelog/testflags/HierPathEval #83 |
| ours | fewer-copies | enum_const | ref_obj < assignment | 31 | 1031 | uhdm2rtlil/testflags/simple_enum #46 |
| ours | elsewhere | logic_typespec | ref_typespec < port | 31 | 1279 | uhdm2rtlil/testflags/type_param_packed_dim #84 |
| golden | fewer-copies | enum_typespec | module_inst < design | 30 | 460 | surelog/testflags/HierPathOverride #300 |
| golden | fewer-copies | int_typespec | ref_typespec < parameter | 29 | 949 | uhdm2rtlil/testflags/LocalParamInNestedForLoops #80 |
| golden | fewer-copies | struct_typespec | ref_typespec < constant | 28 | 998 | uhdm2rtlil/testflags/struct_param_func_arg #182 |
| golden | fewer-copies | array_typespec | ref_typespec < operation | 27 | 994 | uhdm2rtlil/testflags/StructArrayParameterInitializedByPatternPassedAsPort #193 |
| ours | elsewhere | struct_typespec | package < design | 26 | 356 | uhdm2rtlil/testflags/StructArrayParameterInitializedByPatternPassedAsPort #43 |
| golden | fewer-copies | range | logic_typespec < ref_typespec | 25 | 894 | surelog/testflags/LogicTypespec #15 |
| ours | elsewhere | enum_const | ref_obj < operation | 25 | 232 | surelog/testflags/HierPathOverride #127 |
| golden | fewer-copies | logic_typespec | ref_typespec < operation | 24 | 1782 | surelog/testflags/IntegerConcat #253 |
| golden | elsewhere | int_typespec | ref_typespec < constant | 22 | 24 | surelog/testflags/InterfType #37 |
| ours | fewer-copies | logic_typespec | ref_typespec < logic_net | 21 | 219 | surelog/testflags/ExplicitPort #22 |
| golden | fewer-copies | logic_net | ref_obj < operation | 21 | 143 | uhdm2rtlil/testflags/sva_range #104 |
| golden | elsewhere | struct_typespec | ref_typespec < constant | 20 | 108 | uhdm2rtlil/testflags/ParameterPassedToSubmoduleOfSubmodule #95 |
| golden | elsewhere | logic_net | ref_obj < operation | 19 | 232 | uhdm2rtlil/testflags/sva_value_change_changed #106 |
| ours | elsewhere | struct_typespec | module_inst < design | 19 | 659 | surelog/testflags/StructUnsizedVal #92 |
| ours | elsewhere | logic_net | ref_obj < operation | 18 | 45 | uhdm2rtlil/testflags/sva_value_change_changed #129 |
| golden | fewer-copies | enum_typespec | ref_typespec < operation | 17 | 1332 | uhdm2rtlil/testflags/PackageCast #99 |
| golden | fewer-copies | struct_typespec | ref_typespec < parameter | 16 | 9374 | surelog/testflags/NoReducTypespec #111 |
| golden | fewer-copies | enum_typespec | ref_typespec < packed_array_typespec | 16 | 832 | surelog/testflags/HierPathOverride #34 |
| ours | elsewhere | enum_const | ref_obj < param_assign | 16 | 16 | surelog/testflags/HierPathOverride #120 |
| golden | fewer-copies | logic_net | ref_obj < cont_assign | 16 | 67 | uhdm2rtlil/testflags/ParameterColonReference #42 |
| ours | absent | integer_typespec | ref_typespec < operation | 16 | 106 | uhdm2rtlil/testflags/cva6_struct_param_field #112 |
| ours | elsewhere | struct_typespec | ref_typespec < operation | 16 | 5042 | uhdm2rtlil/testflags/def_ctx_struct_param #73 |
| ours | elsewhere | int_typespec | ref_typespec < constant | 15 | 774 | surelog/testflags/InterfType #42 |
| ours | elsewhere | enum_const | ref_obj < case_item | 15 | 522 | surelog/testflags/Kmac #191 |
| golden | fewer-copies | bit_typespec | ref_typespec < constant | 15 | 1652 | surelog/testflags/ValueSize #26 |

Golden's extra objects in uhdm-dump form: the dumper prints the same text for a shared and a copied
typespec, so the extras are visible only in the weakly-referenced tail (evidence/uhdmdump/*.diff:
PatternStruct's private `struct_typespec (my_struct)` with `vpiInstance work@top`; ExplicitPort's two
extra `logic_typespec` 5:10 in OURS; ComplexExprSize cont_assign order in the tail).
SizeOfUnsignedParameter, ImportedParameter, ConstPort, ParameterColonReference: 0 dump lines differ.

Surelog relationships that write them:
* ref_typespec.Actual_typespec deep clone: `ref_typespec::DeepCopy` under uniquifyTypespec (default true)
  — every clone_tree before the final elab pass. Holders: constant (param_assign Rhs, 186 rows for
  int_typespec alone), operation (casts/patterns), parameter, typespec_member, port, sys_func_call.
* param_assign.Lhs: `CompileHelper::importPackage` clones the package's param_assign (CompileHelper.cpp:265),
  so the Lhs parameter is a module-scoped object (fullname `work@<module>.<name>`), 50 rows.
* module_inst lists private enum/struct typespec copies (typedef import into the instance,
  UhdmWriter.cpp:1377/1391 `clone_tree(tps)` into `typespecs`), 30-34 rows.
* The reverse direction (ours copies, golden shares): elab port typespec (ModuleEmit.cpp:17153),
  module_inst struct typespec lists, enum_const reached via ref_obj.

`absent` rows (no same-signature object on the other side; mostly span variants of the same typespec):
24 rows ours-only struct_typespec (RangeSelect tl_h2d_t: our span 2:12-4:5, golden 2:12-6:17), 17 ours-only
logic_typespec, 16 integer_typespec, 11 class_typespec/int_typespec/enum_typespec; golden-only
absent is confined to the UVM rows (BuildUVMPkg, MiniAmiq, Scoreboard) and UnitElabBlock, Rggen
(`interface_inst register_15_bus_if` under a port ref_obj, 29 objects).

## 7. The downstream rows on this map (uhdm2rtlil default mode)

| downstream verdict | test | strict | clusters |
|---|---|---|---|
| DIVERGENT | PartSelectOfMember | decompile(3) | **C0375 only**: `value\|constant\|UINT->empty+decompile+size+consttype 9->0\|under:cont_assign` |
| DIVERGENT | IndexedPartSelectOfMember | decompile(3) | **C0375 only** |
| DIVERGENT | SelectOnMemberSelectedFrom2DArray | decompile(1) | **C0375 only** |
| EQUIVALENT | func_upto | file(2477) | C0001 (2477 genvar parameters without VpiFile) + C0582 `span\|parameter\|line\|under:gen_scope` (333: golden line 63 vs ours 64) |
| EQUIVALENT | arb_idx_cast | endline(3) | 10 clusters (C0002, C0581, C0089, C0001, ...) |
| EQUIVALENT | gen_scope_numports | depth(1) | 15 clusters (C0089, C0006, C0761 type_parameter, C0079, ...) |
| EQUIVALENT | param_name_collision_typeparam | fullname(2) | 8 clusters (C0006, C0089, C0022 type_parameter file, ...) |
| EQUIVALENT | type_param_override_elem_sel | depth(1) | 11 clusters (typespec identity: C0005, C1015, C0742, C0006, C1154, C0802) |
| DIVERGENT | iface_array_elem_cfg_param | depth(1) | 5 clusters (C0047 struct typespec copy, C0007, C0017, C0099, C0028) |
| EQUIVALENT | matching_end_labels | equal | none (strict-equal; downstream difference is outside the exported fields) |
| EQUIVALENT | ibex_controller | SLANG_REJECT in the corpus sweep | n/a |

**C0375 is the whole strict delta of three of the four DIVERGENT rows** (plus surelog MultiPartSelect): in the ELABORATED view
`assign a.b[0] = 1;` (LHS a bit-select of a packed-struct member) our cont_assign Rhs is an EMPTY
constant (no value, no decompile, size 0, const type 0) while the def view's is `UINT:1`; golden has
`UINT:1` in both. uhdm-cmp passes the row (CMP_EQUAL) — why the judge does not reach it is for the brief
to decode — and the plugin reads the constant by value. Evidence: evidence/C0375_*.txt.

## 8. Census: span writes that do not stamp VpiFile (FILE-EMPTY candidates)

setLoc ([UhdmExporter.cpp:760](../../../src/UhdmExporter.cpp#L760)) stamps VpiFile; these writes set
VpiLineNo with no VpiFile/setLoc/copyLoc within 8-10 lines (driver: drivers/census_vpifile.sh):
ExprEmit.cpp:22372, 27553; ModuleEmit.cpp:5979, 6289, 7383, 7393, 7411, 7463, 14390, 17217, 17228,
22851 (C0001), 28762, 29612, 29621, 29655, 30143, 31486, 43633, 43803, 43820; ParamEmit.cpp:7986 (C0003),
19117, 19244, 28972, 29070, 29419; StmtEmit.cpp:3681, 3716; TaskFuncEmit.cpp:5637; TypeEmit.cpp:13756,
14548, 14946. Objects that never get a location at all (C0019 range bounds, C0022 elab type_parameter)
are a separate shape: file AND span are both missing.

## 9. Residues, ranked (what the next briefs should target)

1. **C0375 (3 of the 4 DIVERGENT rows)** — elab cont_assign Rhs constant emitted empty for member-select LHS. Downstream-fatal, judge-blind. Smallest possible brief (4 tests, 1 cluster each).
2. **FILE-EMPTY|parameter (C0001 + C0003)** — 320 row-modes, alone 89 / 46 tests; C0001 is the downstream func_upto delta. Two verified lines.
3. **Typespec identity (F01 + F02 + F04 + walk echoes)** — 681 row-modes touched, 167 cleared as a union; one Surelog mechanism (clone_tree uniquify). Largest structural lever; needs a law about WHICH holders get a private copy (constant/operation/parameter/typespec_member golden-side; elab port/net ours-side).
4. **Imported param Lhs clone (C0012)** — 58 row-modes, gate at ParamEmit.cpp:7957.
5. **hier_path member span/fullname (C0007 + C0009)** — 81 + 62 row-modes; Surelog gives the base the leaf's span and the leaf a bare fullname.
6. **Parameter VpiValue (C0020, C0034, C0044, C0080, C0083, C0094)** — $bits/type folds unstamped, `parameter int` INT vs UINT.
7. **Unlocated objects (C0019 range bounds, C0022/C0023 elab type_parameter)**.
8. **FILE-OTHER-BUFFER** — macro/include attribution, 61 row-modes but 174k objects (YosysOldSpi, ibex, PreprocFunc).
9. Everything else: spans by kind (69 families, 394 row-modes, alone-yield 44).

## 10. Files

* `README.md` — this map. `clusters.csv` — every (row-mode, cluster) with object count.
* `cluster_index.csv` / `family_index.csv` — ranked, with rows per corpus, objects, alone-yield, smallest example.
* `evidence/C*.txt` — one example per cluster (top 60 + C0047, C0089, C0375, C0582, C0761).
* `evidence/uhdmdump/` — path-normalised uhdm-dump diffs golden vs ours for 8 structure examples.
* `evidence/controls/` — strictcmp outputs of the positive controls.
* `drivers/run1.sh` (strictcmp per row), `drivers/analyze.py` (alignment + facets), `drivers/final.py`
  (clusters, families, yields, csvs), `drivers/evid.py` (evidence files). Re-run:
  build the job list from the sweep csv (`corpus mode test golden ours strict`, tab-separated), then
  `xargs -n5 -P3 run1.sh`, `python3 analyze.py jobs.tsv all4.jsonl`, `python3 final.py`.
