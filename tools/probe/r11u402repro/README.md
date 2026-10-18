# r11u402 — pass 402, module/type ground, the sv-tests campaign's first pass: unpacked and tagged union typedefs, associative-array typedef shapes and typedef'd array elements, virtual-interface typedefs, the gate primitives the exporter rejected, class event arrays and covergroup properties, the tnoc crash, the UVM out-of-body macro order and imported typedef'd parameters, net kinds, module clocking blocks, $unit out-of-body methods, and four span faces

Pair B, the sv-tests campaign's first pass on the module/type ground. Base eee9c5fd4. Production surface:
src/TypeEmit.cpp, src/ModuleEmit.cpp, src/UhdmExporter.cpp and src/TaskFuncEmit.cpp (uhdm_main.cpp untouched).
It holds 21 laws. There is no src/R*.h, nothing in src/LawState.h and no getenv; every switch is read through
src/LawSwitch.h (`lawOn(402, "R11U402_<LAW>_OFF")`, `lawTrace(402, ...)`). `R11U402_OFF` drops every law and gives
pristine's bytes and exit code on every grid case (evidence/grid402.txt, last column). `R11U402_TRACE=<dir>` logs every
firing into `<dir>/<pid>.402`, its first line `OUT <-o path>`. Cross-file state lives in plain globals of the file
that owns it (`g_unitOobFns402` and `g_unitOobEmit402` in TaskFuncEmit.cpp, two free functions `unitDynTdShape402`
in TypeEmit.cpp and `ifaceTdThroughPort402` / `netKindExtra402` in ModuleEmit.cpp), declared `extern` where read;
include/UhdmExporter.h is unchanged.

- Pristine build md5 2982d1ee861fb421aceffc8c0cc4e18f, equal to the main tree's build/slang-uhdm at the base.
- Law build (lawC, the delivered patch) md5 f06cef348eb2fb71d6fa5b3124dbcced.
- Both binaries were frozen (chmod 555 copies under /tmp/r11u402_bin) before any counted measurement, and both
  report slang 12.0.0+545f88b2e. Every cmds.txt of every sweep names its own binary (evidence/gates.txt).

## Verdict

GATES (lawC; numbers in evidence/gates.txt and evidence/svtests_law_stage.txt):

- probe: 4018 EQUAL + 69 STRICT_NOTEQUAL; regressions 0, conversions 1, changes 0. The conversion is
  r10uvm149repro/g149/homes (STRICT_NOTEQUAL differ:endline(1) -> EQUAL), attributed by trace to
  § anonUnpackedStructSlotEnd402 (`anonVar`, the module-scope anonymous unpacked struct variable). It is the one probe
  database moving in bytes (byteverify 1 of 4087).
- surelog: default 480 + 0 and testflags 474 + 0 CMP_EQUAL, unchanged; regressions 0, conversions 0, changes 2:
  **Tnoc default and testflags SLANG_REJECT (rc=-11, the crash) -> CMP_NOTEQUAL** (a database now; fresh rows
  `Tnoc,default,CMP_NOTEQUAL,decompile:,,` and `Tnoc,testflags,CMP_NOTEQUAL,decompile:,,`), § uninstIfaceTdThroughPortSkip402.
  Every other surelog database is byte-identical (byteverify 0 of 960 once the two new Tnoc databases are set aside).
- uhdm2rtlil: 803/1/67 in both modes; regressions 0, conversions 0, changes 0; byteverify 0 of 1608.
- downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, the verdict column identical to
  results/downstream_uhdm2rtlil.csv and to the pristine sweep (871 of 871).
- sv-tests: regressions 0, see the next section.
- Exit-code-only movers on the corpus (bytes identical, status CMP_EQUAL before and after; the firing census predicted
  them): CarryTrans d/t (pristine exit 4 `gate primitive: tranif0/tranif1`) and Gates d/t (exit 4 `bufif0/bufif1/notif1`)
  exit 0 under § elabMosPullPrims402's definition-view skip; SVSwitch d/t (exit 4 `class property type:
  CovergroupType`) exits 0 under § classCovergroupPropSilent402.

## sv-tests: the rows that move (base results/golden_svtests.csv -> lawC)

Totals (check_svtests.py, lawC): EQUAL 1153 -> 1187, STRICT_NOTEQUAL 23 -> 22, DIFFERENT 705 -> 687, SURELOG_ONLY
133 -> 119, SLANG_ONLY 13 -> 14, SLANG_CRASH 1 -> 0, BOTH_REJECT 309 -> 308, SURELOG_CRASH 8 and TIMEOUT 1 unchanged;
**regressions 0, conversions 40, changes 1** (tnoc SLANG_CRASH -> SURELOG_ONLY). evidence/svtests_law_stage.txt lists
them; evidence/svtests_conversions_attributed.txt names the laws each moved row's trace fires (every one of the 41 is
attributed).

GOAL 1 (exporter rejections and the crash, upstream slang accepts):

| row | before -> after | laws |
|---|---|---|
| chapter-11/11.9--tagged_union.sv | SURELOG_ONLY -> EQUAL | modUnpackedUnionTd402, unpackedUnionTdVar402, taggedVoidMemberTs402 |
| chapter-11/11.9--tagged_union_member_access.sv | SURELOG_ONLY -> EQUAL | same three |
| chapter-11/11.9--tagged_union_member_access-sim.sv | SURELOG_ONLY -> EQUAL | same three |
| chapter-11/11.9--tagged_union_member_access_inv.sv | SURELOG_ONLY -> EQUAL | same three |
| generic/typedef/typedef_test_10.sv, _11, _12 | SURELOG_ONLY -> EQUAL | assocTdIndexShapes402, arrTdAliasElemClone402 |
| generated/easyUVM/top.sv | SURELOG_ONLY -> DIFFERENT | virtIfaceTd402 (+ the UVM laws); next face below |
| generated/hdlconv_std2017/hdlconvertor_std2017_p771.sv | BOTH_REJECT -> SLANG_ONLY (Surelog rejects it) | virtIfaceTd402, vifVarNotElaborated402 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p556.sv | SURELOG_ONLY -> EQUAL | classCovergroupPropSilent402 |
| generated/uvm-examples/uvm_id_register.sv | SURELOG_ONLY -> DIFFERENT | classCovergroupPropSilent402 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p801.sv | SURELOG_ONLY -> EQUAL | elabMosPullPrims402, gateInBitSelIndexSpan402 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p628.sv | SURELOG_ONLY -> STRICT_NOTEQUAL (line, the implicit net `pd`) | elabMosPullPrims402 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p827.sv | SURELOG_ONLY -> DIFFERENT | elabMosPullPrims402 |
| generated/utd-sv/utd-sv_std-7.1.6-primitives.sv | SURELOG_ONLY -> DIFFERENT | elabMosPullPrims402 |
| generic/class/class_test_54.sv | SURELOG_ONLY -> EQUAL | classEventArrElem402 |
| generated/tnoc/tnoc.sv | SLANG_CRASH -> SURELOG_ONLY (exit 4, no crash) | uninstIfaceTdThroughPortSkip402 |

Still rejected on this ground: generic/typedef/typedef_test_13.sv (a two-dimension associative typedef whose index
bounds are parameter folds, residue 3), generated/basejump/bsg_mem_BaseJumpSTL_bsg_mem_1r1w_sync_from_1rw_sync.sv
(`continuous assign form`, residue 8). On the sister's ground (reported, not written): the five pattern rows
chapter-12/12.6.1--case_pattern.sv, casex, casez (`statement kind: PatternCase`), 12.6.2--if_pattern.sv (`complex
if condition`), 12.6.3--conditional_pattern.sv (`complex conditional`) — the union typedef they first stopped on is
now accepted; generated/hdlconv_std2017/hdlconvertor_std2017_p728.sv (`user function call`, ExprEmit); and tnoc
(`expression kind: Invalid`, ExprEmit, see the sister faces).

GOAL 2 (both accepted, the first difference on this ground):

| row | before -> after | laws |
|---|---|---|
| generated/nets/6.6.2--net_uwire.sv, 6.6.3 triand/trior, 6.6.4 trireg, 6.6.5 tri0/tri1, 6.6.6 supply0/supply1 (8) | DIFFERENT -> EQUAL | netKindTypeAll402 |
| chapter-6/6.9.2--vector_scalared.sv, 6.9.2--vector_vectored.sv | DIFFERENT -> EQUAL | netKindTypeAll402 |
| chapter-14/14.3--clocking-block.sv, 14.3--clocking-block-signals.sv | DIFFERENT -> EQUAL | moduleNamedClocking402 |
| chapter-5/5.12-attributes-module.sv | STRICT_NOTEQUAL line(3) -> EQUAL | topModSpanSkipsAttrs402 |
| chapter-7/structures/unpacked/basic.sv | STRICT_NOTEQUAL endline(1) -> EQUAL | anonUnpackedStructSlotEnd402 |
| chapter-7/unions/tagged/basic.sv | DIFFERENT -> EQUAL | taggedVoidMemberTs402, unpackedTaggedElabSpan402 |
| generic/member/class_member_test_2, _3, _4, _6, _7, _8 | DIFFERENT -> EQUAL | unitOobDefsNotInClass402 |
| generic/member/class_member_test_15.sv, _25.sv, generated/hdlconv_std2017/hdlconvertor_std2017_p189.sv | DIFFERENT -> EQUAL | unitOobDefsNotInClass402, unitOobFuncOnDesign402 |
| the 146 UVM rows (bundled 1800.2-2017) | DIFFERENT -> DIFFERENT, head moved | oobMacroDefAtExpansion402, unitImpTdParamTsClone402 |

The UVM cluster. At the base 130 rows first differed at uvm_pkg::uvm_packer's method list (ours set_packed_bits where
Surelog has get_packed_bytes at uvm_packer.svh:551). Decoded: the `M__UVM_GET_PACKED(T)` / `M__UVM_SET_PACKED(T)`
out-of-body definitions are macro-born, and Surelog lists them where the macro is EXPANDED (it compiles the
preprocessed text), while our sort compared raw SourceLocations, which put every macro buffer after the file's text.
The corpus UVM rows never reached this: MiniAmiq, SeqDriver, SimpleUVM and Scoreboard use uvm-1.2 and BuildUVMPkg the
preprocessed pp_output/uvm_pkg.sv, so no macro-born out-of-body method exists there. After § oobMacroDefAtExpansion402
the 129 rows reached a design-level parameter chain (`UVM_PACK`, a `uvm_field_flag_t`-typed parameter of the
`$unit`-imported uvm_pkg: golden deep-clones the alias chain, ours shared the package's), closed by
§ unitImpTdParamTsClone402. The UVM heads under the law binary (evidence/uvm_heads_law.txt, 148 rows with easyUVM and
uvm_id_register): 129 at `uvm_pkg::uvm_init::idx` (StmtEmit's foreach loop variable), 12 at uvm_pkg's own variable
list and 5 at a test package's (the hoisted out-of-body constructor locals, ParamEmit), 2 at `uvm_pkg::error_str`
(the same listing): every UVM head is now on the sister's ground (below).

## The laws

### § modUnpackedUnionTd402 — `R11U402_UUNIONTD_OFF` (TypeEmit, the module-body typedef branch)
A module-body typedef of an UNPACKED (or tagged) union is listed as the unpacked-struct branch lists: one union_typespec
with module-scoped member refs, module parent, spanning the type syntax. Before: `typedef target: UnpackedUnionType`,
exit 4. Cases: cases/UU (uu01-uu03).

### § unpackedUnionTdVar402 — `R11U402_UUNIONVAR_OFF` (TypeEmit `makeVar`)
A variable of a typedef'd unpacked union is a union_var (visibility 1), whatever its members; ours fell through to a
logic_net. Cases: UU/uu02, uu03.

### § taggedVoidMemberTs402 — `R11U402_VOIDMEM_OFF` (TypeEmit `buildUnionTs`)
A tagged union's `void` member is a void_typespec spanning the type keyword through the member name; its
typespec_member keeps the reference file and no reference span. Case: UU/uu01, US/us06.

### § unpackedTaggedElabSpan402 — `R11U402_UTAGGEDSPAN_OFF` (TypeEmit, the anonymous union branch)
§ taggedUnionElabSpan137 for an UNPACKED tagged union: the elaborated clone spans `union tagged` (golden
chapter-7/unions/tagged/basic.sv 18:1-18:13; ours the `union` keyword). Cases: US/us06, us08.

### § assocTdIndexShapes402 — `R11U402_ASSOCTD_OFF` (TypeEmit `unitDynTdShape402` and the marker range; UhdmExporter's $unit branch, TypeEmit's module branch)
The $unit and module-body typedef branches of pass 249 also list a one-dimension associative array whose element is a
typedef, whose index is the wildcard `[*]` (the associative marker with no index typespec), or whose index is a
`bit`/`logic`/`reg` keyword with or without packed dimensions (the keyword's own typespec at the index tokens, one
range per packed dimension with its bounds at their tokens, UNPARENTED as § assocIndexTsSigned63 measured for the
index position). Cases: cases/AA aa01-aa08.

### § arrTdAliasElemClone402 — `R11U402_ALIASELEM_OFF` (TypeEmit `buildUnpackedArrayTypedefTs`)
The struct-element rule of that builder holds for every typedef'd element: an array typedef over a typedef'd vector,
atom or enum points its element at a fresh NAMED clone of that typedef (its span, no parent) whose Typedef_alias
reference (named like the typedef) reaches the shared object; a $unit array typedef stacks TWO such clones (the
first one's alias reaches the second, the second's the listing). Fixed-size arrays included: AA/ae_fixed,
ae_fixed_mod, ae_int and ae_vec were wrong on pristine too and are EQUAL now; AA/ae_enum moves but stays NOT_EQUAL
(the enum clone's own constants, residue 4).

### § virtIfaceTd402 — `R11U402_VIFTD_OFF` (UhdmExporter's $unit typedef branch, and the LAW-S copy kinds of § unitTdLawS245)
A $unit typedef of a virtual interface lists one interface_typespec named like the typedef, spanning the interface
name (through the modport), parented and Instanced at the design; the definition-view net binds the § unitTdLawS245
aliased copy, which now takes the interface_typespec kind. Case: VI/vi01.

### § vifVarNotElaborated402 — `R11U402_VIFELAB_OFF` (ModuleEmit `emitInstance`, the signal loop)
A module-body VARIABLE of a virtual-interface type (written `virtual I v;` or through a typedef) has no elaborated
object: Surelog's elaboration keeps only the definition view's logic_net. Cases: VI/vi01, vi02.

### § elabMosPullPrims402 — `R11U402_GATEPRIM_OFF` (ModuleEmit `emitGates`)
nmos/pmos/cmos and their resistive forms reach the ELAB view as switch_tran objects with the gate terminal rule (term 0
the output, the rest inputs); pullup/pulldown as gates with their one output terminal; a bidirectional switch
(tran/rtran/tranif) marks every terminal but the LAST inout (`tran t(a, b)`: golden a inout, b input, where ours had
both inout); the definition view writes none of the elab-only primitives and reports nothing (bufif0 and tranif1 were
already strict-equal there but exited 4); an ARRAY of enable or pull gates takes the gate_array the n-input gates
take. Cases: cases/GP gp01-gp10. Residue: switch arrays (GP/gp11, golden `switch_array (work@top)`).

### § gateInBitSelIndexSpan402 — `R11U402_GATEBITSEL_OFF` (ModuleEmit `emitGates` buildGate)
An INPUT terminal written as a bit select (`in[3]`) spans its INDEX expression alone in both views; an output terminal
and a part select keep the whole terminal. Cases: GP/gt04, gp12, gt01 (control), gt02 and gt03 (the field moves later:
gt02's concat terminal ref actual and gt03's elaborated index fold, both on the sister's ground).

### § classEventArrElem402 — `R11U402_CLSEVENTARR_OFF` (UhdmExporter `emitClassDefn`)
A fixed-size array of events as a class property (`event revolution[4:0];`) is listed exactly as a scalar event
property: one named_event at the name. Before: `class array property element`, exit 4. Cases: CE/ce01, ce02.

### § classCovergroupPropSilent402 — `R11U402_CLSCGPROP_OFF` (UhdmExporter, the class property fallback)
The implicit property slang declares for an EMBEDDED covergroup has no variable in golden; the listing already agreed
and only the exit code was wrong (exit 4 -> 0). Cases: CG/cg01-cg03 (rc-only).

### § uninstIfaceTdThroughPortSkip402 — `R11U402_UNINSTIFTD_OFF` (UhdmExporter's uninstantiated-interface default instances; ModuleEmit's port-view default fold; predicate `ifaceTdThroughPort402`)
An interface whose body declares a typedef THROUGH one of its interface ports (`interface a_if(types_if types);
typedef types.T T;`) cannot be built unconnected: slang resolves the type through the unconnected port and
dereferences a null connection (InstanceSymbol::resolvePortConnections, exit 139 on tnoc's
tnoc_address_decoder_if; the gdb stacks went through the def-collection walk of exportDesign and then
`ifacePortViewFoldScope`). Such an uninstantiated interface is left out of the listing (golden lists it: residue 6)
and its port view folds at the connected instance. The predicate reads the syntax only (asking the body for its port
list elaborates it and crashes the same way). Case: TN/tn01 (pristine exit 139, law exit 0).

### § oobMacroDefAtExpansion402 — `R11U402_OOBMACRO_OFF` (TaskFuncEmit `emitTaskFuncs`, the out-of-body sort)
An out-of-body definition written by a macro is ordered at the macro's expansion site (getFullyExpandedLoc). Cases:
OM/om01-om03 (the class listing order is golden's; the package-level clone listing and the module listing are other
faces, see the sister faces); the 130 UVM rows.

### § unitImpTdParamTsClone402 — `R11U402_IMPTSCLONE_OFF` (UhdmExporter, § unitImportCopyOwnTsRef214's design-final pass and § unitImpPaRhsActualFinal243v's)
The design copy of a `$unit`-imported package parameter whose typespec is a typedef'd one (it carries a Typedef_alias)
holds its own copied alias chain: a fresh typespec of the same kind named bare, parented at the copy's reference,
Instanced as the source, whose alias reference is named `<parameter>.<alias target's bare name>` (the bare name alone
under the Rhs constant's empty-named reference) and reaches a bare-named copy of the alias target. Golden (uchain,
evidence and drivers/uchain.cpp): `UVM_PACK -> bit_typespec uvm_field_flag_t -> UVM_PACK.uvm_field_flag_t ->
bit_typespec uvm_field_flag_t`. Cases: IT/it01, it02 (heads move later; module-import faces remain, residue 10).

### § netKindTypeAll402 — `R11U402_NETKIND_OFF` (ModuleEmit `netKindExtra402`, both views and TypeEmit's array nets)
An explicitly declared net of tri0, tri1, trireg, triand, trior, supply0, supply1 or uwire carries its net kind
(vpiTri0 5 ... vpiUwire 13), read only where the shared map (EmitHelpers' netTypeFor) answers nothing, with its
explicit-declaration gate. Cases: cases/NT nt01-nt11.

### § moduleNamedClocking402 — `R11U402_MODCLOCKING_OFF` (ModuleEmit: emitModuleDef and emitInstance call the interface writer emitNamedClockingBlocks for modules)
A NAMED (neither default nor global) clocking block in a module is listed under vpiClockingBlock in both views; the
elaborated block's event refs bind the DEFINITION's nets (§ clockingEventDefNet139's rule for the default block).
Cases: cases/CK ck01-ck04.

### § topModSpanSkipsAttrs402 — `R11U402_TOPATTRSPAN_OFF` (ModuleEmit `emitInstance`, isTop)
The top view of a module starts at the `module` keyword, as the definition view already did; a leading attribute
instance is not in the span. Cases: TA/ta01, ta02, ta03 (a child, control).

### § anonUnpackedStructSlotEnd402 — `R11U402_ANONSTRUCTEND_OFF` (ModuleEmit `materializeDefNetTs`)
§ defNetEndOnlyLoc130's packed slot for an anonymous unpacked struct written in the declaration: the slot after the
`struct` header is the FIRST member, so the definition typespec ends at that member's end (golden 3:1-4:15); an
initializer or unpacked dimension and ports keep their roads. Cases: US/us01-us03, us04 and us05 (controls).

### § unitOobDefsNotInClass402 — `R11U402_UNITOOB_OFF` (TaskFuncEmit `emitTaskFuncs`, class scope)
A class declared in $unit lists NONE of its out-of-body definitions: a task or a constructor is listed nowhere, a
function on the design (next law). Cases: UO/uo02, uo03 (and with the next law uo01, uo04, uo06).

### § unitOobFuncOnDesign402 — `R11U402_UNITOOBFN_OFF` (UhdmExporter after the $unit classes; TaskFuncEmit's cursor)
Such an out-of-body FUNCTION is listed on the design's vpiTaskFunc as `cls::f`, vpiMethod 1, with its body, in source
order among the unit's own subroutines. Cases: UO/uo01, uo04, uo06; uo05 and uo07 move but keep the body-naming face
(residue 1, sister).

## Grid

evidence/grid402.txt: 78 case dirs, one line each (case | pristine exit + verdict | law exit + verdict | moved or not |
the switch whose single-off restores pristine's bytes and exit code, or the set needed together | R11U402_OFF equal
to pristine). 71 move (5 of them by exit code only: CG/cg01-cg03, GP/gp01, gp05), 52 enter EQUAL, none leaves EQUAL, every mover restored by one
switch or by its listed set, R11U402_OFF = pristine on 78 of 78. GP/gt02 moves from STRICT_NOTEQUAL col to depth
(its col face fixed, the concat terminal's reference actual left, a sister face). Every case's first line names its law.

## Controls and census

- Firing census (evidence/census_uhdm2rtlil.txt omits two uhdm2rtlil rows, d and t of one test whose name holds a fenced
  name as a substring, both reading `-`, so the patch spells no fenced name; drivers/census402.sh: every slang command line of the pristine surelog and uhdm2rtlil sweeps, the
  list fence-filtered before any file is opened, rerun with the law binary and R11U402_TRACE in the test's own
  directory): evidence/census_*.txt. Fires on CarryTrans d/t and Gates d/t (elabMosPullPrims402, the definition-view
  skip), SVSwitch d/t (classCovergroupPropSilent402) and Tnoc d/t (uninstIfaceTdThroughPortSkip402), nothing else; the
  byteverify movers (0 corpus, 2 new Tnoc databases) and the exit-code movers are exactly that set. The census was run
  after the first law sweep, so it is a check, not a prediction made before it (see the process notes).
- byteverify, canaries (surelog ok=52, uhdm2rtlil ok=16), ctcan2 (PASS, PASS), the binary-path audit and the
  determinism draws: evidence/gates.txt.

## Residues on this ground, ranked by rows

1. **$unit out-of-body function bodies** naming class members and formals: golden names them `c::get.x` (a dot) and
   leaves the formal's reference unbound; ours `c::get::x`, bound (UO/uo05, uo07). The separator and binding are
   decided in the statement/expression emitters (sister).
2. **Implicit net locations** (p628's `pd`, chapter-6/6.10--implicit_port_connection.sv's `c`, p597's `o1`/`o2`: three
   STRICT_NOTEQUAL line rows): decoded on a grid kept out of the patch (no law): a net born at a port connection or a
   gate terminal is located at its LAST reference in the module (golden 6.10 22:13, the `assign d = c`), one born as a
   continuous-assignment target keeps its first.
3. generic/typedef/typedef_test_13.sv: a two-dimension associative typedef (`[bit[31:0][k:0]][bit[j:0][l:0]]`):
   golden spans the array_typespec through the FIRST dimension and folds `k`, `j`, `l` to size-32 constants with a
   reference to the parameter's int_typespec.
4. AA/aa08 (a module variable of a module-scope associative typedef: golden binds a clone with a Typedef_alias),
   AA/aa07 (fullname), AA/ae_enum (the enum clone's constants).
5. GP/gp11 switch arrays (`switch_array (work@top)` in golden).
6. tnoc: the uninstantiated interface left out of uhdmallInterfaces.
7. chapter-5/5.6.4--compiler-directives-debug-line.sv: Surelog ignores `line for the module's end line.
8. generated/basejump/bsg_mem_BaseJumpSTL_bsg_mem_1r1w_sync_from_1rw_sync.sv: the definition view of an uninstantiated
   module whose default parameter (-1) makes a replication invalid; slang binds an Invalid assignment, golden writes
   the unbound syntax (`continuous assign form`).
9. US/us08: the definition-view object of a tagged union in a CHILD module ends at its first member in golden.
10. IT/it01: the module's own imported-parameter copy (module_inst > parameter(A) > bit_typespec(f_t) in golden, ours
    an int_typespec).

## Sister-ground faces (reported, not written)

- **StmtEmit, the foreach loop variable** (`VpiLoopVars` builder, StmtEmit.cpp, § foreachScopedArrayLoopVarIntFallback34
  neighbourhood): `foreach(uvm_deferred_init[idx])` over `uvm_object_wrapper uvm_deferred_init[$]` (base/uvm_globals.svh:373)
  — golden `class_var idx` typed `class_typespec uvm_object_wrapper`, ours `array_var` typed by the array. Blocks 129
  UVM rows.
- **ParamEmit, the package variable listing** (`collectOobCtorLocalsIn` / `flushHoist9`): the hoisted out-of-body
  constructor local `uvm_pkg::rh` (uvm_root::new, base/uvm_root.svh:366, included at uvm_component.svh:1579) precedes
  uvm_component::new's locals (`error_str` ...); ours lists it after `common`. 12 + 5 + 2 UVM rows (uvm_pkg and the
  test packages' wildcard-import clones).
- **ParamEmit, the package Task_funcs clone listing** (`pkgTfListingLess`): macro-born out-of-body definitions at the
  expansion site (OM/om01, om02).
- **StmtEmit**: `statement kind: PatternCase`, `complex if condition`, `complex conditional` (chapter-12/12.6.1-12.6.3).
- **ExprEmit**: `expression kind: Invalid` for casts to types reached through an interface port in an interface's
  definition view (tnoc_flit_if.sv:128 3646 times, tnoc_packet_deserializer.sv:113, tbcm_demux.sv:6 and
  tbcm_selector.sv:6 `DATA_TYPE'(0)`), keeping tnoc at exit 4; `user function call` (p728); the gate concat terminal's
  reference actual (GP/gt02); the $unit out-of-body function body naming (UO/uo05, uo07).

## Process notes (no effect on any measurement)

- The first svtests stage was run from the worktree, whose check_svtests.py resolves the UVM tree under its own empty
  submodule: every UVM row read BOTH_REJECT (149 "regressions"). Discarded; the stage was rerun with the main tree's
  check_svtests.py (byte-identical to the base's) as the sister pass does.
- One pristine sweep was launched while the sister's sv-tests stage ran; stopped through its own process group and
  relaunched without the sv-tests stage. A later `pkill -f` matched its own shell (exit 144, nothing else touched).
  One queued waiter's pgrep matched its own command line (it contained `check_svtests.py`) and never woke; stopped
  through its own process group. The law sv-tests stage may have overlapped with the sister's corpus sweep (load only).
- The first firing-census draft ran the commands in the workdir instead of the test directory (every line `-`); it was
  stopped and rewritten before any reading was used; the census list is fence-filtered before any file is opened.
- One `ls | grep -E` on the pristine workdir listing spelled the four fenced names to check whether the harness had run
  them; no file of theirs was opened, nothing was run on them.
- The firing census was first run after lawB's sweep and rerun on lawC: it is a check of the byteverify and exit-code
  movers, not a prediction frozen before the law sweep. lawB (md5 c292cd6490934a50efb37bf481fac695) ran the first full
  gate set; § unpackedTaggedElabSpan402 and § unitOobFuncOnDesign402 were added after it, and lawC reran every gate.
- No pristine sv-tests stage was run to completion: it waited for a free machine behind the other passes' sweeps and
  was withdrawn. The baseline results/golden_svtests.csv is the pristine reference the gate compares against, and every
  one of the 41 moved rows is attributed by its own trace (evidence/svtests_conversions_attributed.txt).
- Nothing written to the main tree; results/, tests/ (but tests/LAWS.md) and third_party/ untouched.
