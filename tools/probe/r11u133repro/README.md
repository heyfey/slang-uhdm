# r11u133 — the expression/parameter ground of the strict axis, third refill (implementer)

Base `e562f4d4` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/StmtEmit.cpp`,
`src/EmitHelpers.h`. No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp` or any header under `include/`; a face whose fix sits there is decoded below and stops there.
Worktree `/tmp/wt_r11u133`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree rebuild of the base; byte-identical to the main tree's `build/slang-uhdm`) | `c7b333fcf978012efd649d7383f77730` |
| law (this patch) | `47c5a369425776b106f2773ad4e294a2` |
| `build/uhdm-strictcmp` (identical to the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |

Both were frozen (`chmod 555` copies) before they measured anything. Every `cmds.txt` of both corpus sweeps
names its frozen binary (pristine 3273 / 3273 slang lines, law 3273 / 3273); the downstream lane's database is
byte-identical to the law binary's own output (checked on `dyn_field_select`, a mover: `d5a71026865f` both,
pristine `b40bbe904bb4`). A `-g1` build of the same source (line tables only) was used with gdb to pin sites.

## Result

| axis | pristine | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 684 | **689** | +5 |
| uhdm2rtlil strict-equal (of 1606) | 1286 | **1300** | +14 |
| probe EQUAL (of 4087) | 2112 | **2193** | +81 |
| surelog / uhdm2rtlil judge-equal (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps judge-equality |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same | 0 of 871 rows changed (verdict and `differs`) |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them)**, fresh csv rows:

    surelog:     DecValue,default,CMP_EQUAL,,,equal
                 HierPathOverride,default,CMP_EQUAL,,,equal       HierPathOverride,testflags,CMP_EQUAL,,,equal
                 SelectHierPath,default,CMP_EQUAL,,,equal         SelectHierPath,testflags,CMP_EQUAL,,,equal
    uhdm2rtlil:  BitSelectOfParameterPassedToSubmodule,{default,testflags},CMP_EQUAL,,,equal
                 ParameterWithUnderscoreValueDividedPassedFromCommandLine,{default,testflags},CMP_EQUAL,,,equal
                 assert_wide_const_cond,{default,testflags},CMP_EQUAL,,,equal
                 dyn_field_select,{default,testflags},CMP_EQUAL,,,equal
                 ff_dead_both_branches,{default,testflags},CMP_EQUAL,,,equal
                 ff_dead_guarded_reset,{default,testflags},CMP_EQUAL,,,equal
                 struct_param_func_loop,{default,testflags},CMP_EQUAL,,,equal

19 row-modes in 10 tests; 81 probe cases (`evidence/probe_conversions_by_law.txt`). By the law whose trigger the
pristine database carries (`drivers/predict133.cpp`): LHSCLONE HierPathOverride x2 BitSelectOf... x2;
HPMID SelectHierPath x2; TRAILIDX dyn_field_select x2 struct_param_func_loop x2; PATQUAL assert_wide_const_cond x2;
LHSCLONE+PATQUAL ff_dead_both_branches x2 ff_dead_guarded_reset x2; UNKFILE DecValue/default
ParameterWithUnderscoreValueDividedPassedFromCommandLine x2. Probe: LHSCLONE 76, PATQUAL 3, TRAILIDX 2.

## Laws (all under `R11U133_OFF=1`, each droppable alone)

| law | switch | site (file + § token) | cluster(s) of the map |
|---|---|---|---|
| § impPaLhsDisjointClone133 | `R11U133_LHSCLONE_OFF` | ParamEmit.cpp, `impPaLhsDisjointClone133` (end of `drainShareDefParamTs`) + `lhsCloneNode133` | N0002 (class C, the definition-view/package half), pass-124 residue § impLhsCloneFlippedDefView124 |
| § hpBaseSelMidMemberBare133 | `R11U133_HPMID_OFF` | ExprEmit.cpp, `emitMixedHierPath` (the member ref_obj case, beside § vifClockingPathComponent5 SITE 2) | N0007 |
| § hpTrailSelIdxNamesByPath133 | `R11U133_TRAILIDX_OFF` | ExprEmit.cpp, `trailSelIdxNames133`, called after § hpNameBareIdxFold69 in `emitMixedHierPath` (SITE 1) and in the plain-base member-select builder (SITE 2, § hpTrailSelPkgFold42's site) | N0052 (`fullname|ref_obj|...|under:bit_select`), dyn_field_select's head |
| § elabPatQualRefQualSpan133 | `R11U133_PATQUAL_OFF` | ParamEmit.cpp, `pkgQualSpan133` lambda at the top of `emitParameters`; the BSOPPS default-reference block (`structOvLoc`) and the op75 site (import copy) | N0058 (`span|operation|endcol|under:param_assign`) |
| § unknownParamOperandFile133 | `R11U133_UNKFILE_OFF` | ParamEmit.cpp, the "Elab typed-param op init with UNKNOWN param-ref operands" block | `file|constant|ours-empty|under:operation` |

Switch helper: `r11u133On` in EmitHelpers.h. `R11U133_OFF=1` restores pristine bytes on all 50 case databases
of this directory (`evidence/master_switch.txt`: SAME 50 of 50; positive control: the law binary without the
switch differs from pristine on 40, `evidence/law_vs_pristine_bytes.txt`) and on ten
example rows (`evidence/master_switch_rows.txt`: SelectHierPath, HierPathOverride, DecValue, dyn_field_select,
assert_wide_const_cond, ff_dead_both_branches, struct_param_func_loop, BitSelectOfParameterPassedToSubmodule,
ParameterWithUnderscoreValueDividedPassedFromCommandLine, ibex_tracer: 10 of 10 SAME). Each single switch moves
only its own grid's cases (`evidence/single_switches.txt`): LHSCLONE lhs 10 + pqs 4 (the pqs cells carry a
header import), HPMID hpm 5 + tix/t05 (a middle member `f`), TRAILIDX tix 11, PATQUAL pqs 9, UNKFILE unk 4
(u04 u05, stage 1 on both binaries, move only the file of the folded operand).

### § impPaLhsDisjointClone133 (N0002's definition/package half; pass 124's § impLhsCloneFlippedDefView124)
DECODE (UhdmExporter.cpp's § unitImportHoistsPkgParams146 statement, re-read at the producer):
CompileHelper::importPackage (CompileHelper.cpp:199-277) materializes an import in two disjoint blocks — it
clones each package `parameter` onto the scope's Parameters() and, separately, clones each package
`param_assign` (its Lhs with it) onto the scope's Param_assigns(). So the Lhs is never the listed parameter:
golden ParamFromPackage prints `vpiLhs: parameter work@aes_cipher_core.X` in full under the definition's
param_assign (`vpiParent: param_assign`, `vpiImported: aes_pkg`), and HierPathOverride / BitSelectOf...
print pinmux_pkg's `NDioPads` Lhs in full in both package listings. Ours shares one object between the two
listings wherever § modDefImportShape flips the listing to the elaborated shape (a module WITH a parameter port
list, a package importing a package): the strict walk's `depth` head. Pass 124 measured the gap and reverted an
emission-time clone (the flipped view's deferred typespec chain stayed bound to the shared object and three
rows went CMP_NOTEQUAL). THE LAW runs after every deferred binding (end of drainShareDefParamTs): in every
DEFINITION module/interface listing and every package listing (both views), an imported parameter that is both
the scope's Parameters() entry (parent = the scope) and a param_assign Lhs gets a Lhs of its own — every field
copied, a fresh ref_typespec to the same typespec, an unpacked parameter's own ranges deep-copied (constants,
operations, refs), parented at the param_assign. ELABORATED module listings are left alone: golden shares there
(ParamFromPackage's instance prints its Lhs `X` bare). Grid `lhs/` (12 cells, law named in each first line):
depth cleared on every header-import / package-import cell (l01-l05 l09-l12; l03 l05 l12 → equal); body-import
and no-port-list controls l07 l08 untouched; pass 124's own c12 cells a01-a08 a12 a13 move the same way
(a02 a05 → equal). Corpus: HierPathOverride, BitSelectOfParameterPassedToSubmodule → equal (both modes).

### § hpBaseSelMidMemberBare133 (N0007)
MEASURED: in a base-select path (`pipeReg[1].brResult.nextAddr`), golden names the first select
(`pipeReg[1]`) and the leaf (`work@...nextAddr`) and leaves every MIDDLE member bare (no stored full name);
`emitMixedHierPath`'s base-select case stored the dotted prefix (`pipeReg[1].brResult`). The census of every
hier_path element over all 4087 probe cases and 2560 corpus row-modes (drivers/hpref.cpp + hpcensus.py):
a middle ref_obj after a bit_select is golden-bare in 1956 of 1986 cells (the 30 named ones ours already
matches); ours stored a name in 171 of the golden-bare cells, all of them the base-select case's. THE LAW leaves a middle member bare in that case (rvalue and lvalue alike: anon_struct_packed_dim
`q_n[i].pte.v`, BuildUVMPkg `overrides[index].ovrd.m_type`). Grid `hpm/` m01-m03 m05 m06 → equal (rvalue, process
rvalue, process lvalue, constant index, trailing vector member). Corpus: SelectHierPath → equal (both modes).

### § hpTrailSelIdxNamesByPath133
DECODE: UHDM ComputeFullName (BaseClass.cpp:100) skips a bit_select's name only above a ref_obj and keeps a
hier_path's name; Surelog stores no full name on a trailing select's index objects, so golden reads
`work@dut.tbl[row_i][col_i].sat[sel_i].sel_i` (dyn_field_select) and, for an operation index,
`work@dut.tbl[r].sat[i + 1].sat.i` (grid t07: the bit_select stays in the chain above an operation). Ours
stored the net's own `work@dut.sel_i`. THE LAW names every ref directly under the trailing bit_select, or under
unnamed operations below it, from the path's FINAL name (after § hpNameBareIdxFold69), in an rvalue only (the
process-lvalue case already scopes its index through `prefix + dotted`). Grid `tix/`: t01-t03 t05-t07 t09 t11
t13 t15 → equal (array base, plain struct base, process, depth-2 member, 2-D base, operation index,
sub-instance, function body, `always_comb` plain base); t04 (constant index) untouched; t08 (process lvalue) and
t14 (the BASE select's index inside an operand, residue R7) keep other faces. Corpus: dyn_field_select,
struct_param_func_loop → equal (both modes).

### § elabPatQualRefQualSpan133 (N0058)
DECODE: the qualified case of CompileHelper::getValue (CompileExpression.cpp:921-952) expands the package
pattern for a `pkg::NAME` read and the copy is located by the reference's paPackage_scope node — the
qualifier span `pkg::`, which our definition listing already carries. MEASURED: an ELABORATED module's pattern
parameter defaulted to `cfg_pkg::DefaultCfg` lists its flat op75 at 11:36-45 in golden (assert_wide_const_cond),
ours the whole reference 11:36-55; an unqualified default keeps the whole name (BSOPPS `DefaultTargetCfg`, the
existing block). And an elaborated IMPORT copy of the same package parameter under the SAME name
(ff_dead_both_branches `parameter cfg_t Cfg = cfg_pkg::Cfg` with `import cfg_pkg::*`), which Surelog updates by
name, carries the same span (golden 12:73-82; ours the package's own 9:26-48); a differently named reader
leaves the import copy at the package span (struct_param_repl_count `CVA6Cfg`, golden and ours agree). Grid
`pqs/`: q01-q05 q07 move to their next face (a trailing `logic_net` listed under the output's ref_obj: the
net-binding class, residue R10); q06 q10 (overridden / two instances) clear the endcol and land on the same
net-binding face; q08 (interface: the range's base-ref column, residue R3) and q09 (stage 1) untouched.
Corpus: assert_wide_const_cond → equal; ff_dead_both_branches, ff_dead_guarded_reset → equal with
§ impPaLhsDisjointClone133 (both modes); struct_param_repl_count moves to its N0001 face.

### § unknownParamOperandFile133
An elaborated typed parameter whose initializer reads an X/Z parameter (`localparam int C = A / B`, `A = 'x`)
keeps the operation and replaces each reference by its BIN:X constant at the reference span — ours with no
file, golden with the file every located object carries (§ vpiFileOnEveryLocated117; golden DecValue
`dut.sv 4:23-24`). Grid `unk/`: u01 u02 → equal; u03 (known value) untouched; u04 u05 stage 1 at the base.
Corpus: DecValue/default, ParameterWithUnderscoreValueDividedPassedFromCommandLine → equal.

## Census (the whole status column, law sweep vs pristine sweep, row by row)

Sweeps: `tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil"`, workdirs `/tmp/r11u133_wdP` (pristine)
and `/tmp/r11u133_wdC` (law), same length. The pristine sweep reads `regressions=0 conversions=0 changes=0` in
all three stages against the committed baselines. Law vs committed (evidence/sweep_gates.txt):

| | regressions | conversions | changes |
|---|---|---|---|
| probe | 0 | 81 | 112 |
| surelog | 0 | 5 | 22 |
| uhdm2rtlil | 0 | 14 | 18 |

Every change is attributed (drivers/predict133.cpp run on the PRISTINE database of the row): probe changes
LHSCLONE 61, PATQUAL 28 (+2 with HPMID), TRAILIDX 17 (+1 with HPMID), HPMID 3; corpus changes: the imported
Lhs clone (Kmac, ParamFromPackage, ParameterFromPkgOnParameterPortList, param_struct_field_bitsel,
param_unpacked_struct_array, StructArrayParameterInitializedByPatternPassedAsPort: `depth` → the next face;
Earlgrey_0_1 `line(5086)` → `line(5109)` and Rggen `file(7)` → `file(12)` and ibex_tracer `fullname(51)` →
`fullname(94)`: the walk now diverges LATER, 50756 → 51100, 439 → 469, 3727 → 4880, so more objects are
compared; StructUnsizedVal, struct_param_repl_count, struct_param_pattern_packing: field changes), the two
path laws (BuildUVMPkg -29, FuncStructVal -6, SVSwitch -1, anon_struct_packed_dim -6, struct_dynamic_range -4,
MiniAmiq/SeqDriver/SimpleUVM/Scoreboard -4..-8).

Record level (drivers/worse2.py, r11u131's rule: a record that matched golden under pristine and differs under
the law before either walk diverges, or an earlier divergence, is WORSE): every corpus byte mover 89 / 89 OK
(evidence/corpus_movers_record_check.txt), every probe byte mover 283 / 283 OK
(evidence/probe_movers_record_check.txt), every grid cell 41 OK + 4 stage-1 on both.

## Gates

1. Build: md5s above; the pristine rebuild is byte-identical to the main tree's `build/slang-uhdm`.
2. Probe: `regressions=0` vs `results/golden_probe.csv`; EQUAL 2112 → 2193, STRICT_NOTEQUAL 1975 → 1894; no
   case left judge-equality.
3. Corpora: `regressions=0` in both (surelog conversions 5 changes 22; uhdm2rtlil conversions 14 changes 18,
   every one listed above); scoreboards 480/3 + 474/3 and 803/1/67 both modes unchanged in judge-equality.
4. Downstream (`tests/sweep.sh --corpus downstream`, law binary): `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66
   (of 871); not identical and not excused=0`; joined to `results/downstream_uhdm2rtlil.csv` on every column: 0
   of 871 rows changed (evidence/downstream_summary.txt). Targeted rows:
   `assert_wide_const_cond,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `BitSelectOfParameterPassedToSubmodule,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `dyn_field_select,IDENTICAL,OK,OK,151,151,,`, `ff_dead_both_branches,IDENTICAL,OK,OK,8,8,,`,
   `ff_dead_guarded_reset,IDENTICAL,OK,OK,16,16,,`,
   `ParameterWithUnderscoreValueDividedPassedFromCommandLine,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `struct_param_func_loop,IDENTICAL,OK,OK,70,70,,`; pass 120's eight rows stay IDENTICAL.
   (The sweep exits 1 only on `law index STALE`, fixed by the regenerated tests/LAWS.md in this patch.)
5. uhdm-cmp: every touched row keeps judge-equality (the status join), every probe case judge-equal.
6. Byteverify (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law vs pristine workdir):
   surelog `PATH_SETS_IDENTICAL (960 paths)`, `MOVERS: 33 / 960`, selfcheck 959/960; uhdm2rtlil
   `PATH_SETS_IDENTICAL (1608 paths)`, `MOVERS: 56 / 1608`, selfcheck 1607/1608. PREDICTED BY NAME from the
   pristine databases (drivers/predict133.cpp, evidence/predictions_pristine.txt): 89 / 89 movers predicted, 0
   unpredicted; movers by trigger LHSCLONE 59, TRAILIDX 24, HPMID 17, PATQUAL 14, UNKFILE 3 (a database can
   carry several). The predicate is wider: 16 predicted databases did not move (TRAILIDX 8, HPMID 8:
   GenForIfaceLocalparamBound, GenForIfaceLocalparamNestedGen, Scr1SvTests, genvar_iface_struct,
   genvar_loop_decl_2, iface_array_struct(_field), struct_member_trailing_index — their paths are built by
   TypeEmit's emitSyntaxExpr twin, residue R3). The UVM family moves and is predicted (TRAILIDX/HPMID on
   MiniAmiq, SeqDriver, SimpleUVM, Scoreboard; record level OK).
7. Canaries: `canaries.sh` on the law csvs vs committed: surelog ok=39 changed=13 — the 13 are the strict
   cells of the movers above (FuncStructVal, Earlgrey_0_1, SVSwitch, SimpleUVM, SeqDriver, BuildUVMPkg,
   Scoreboard), every one record-level OK; the pristine csv reads ok=52 changed=0; uhdm2rtlil ok=16 changed=0.
   `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: PASS ok=58; `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil: PASS ok=2.
8. Earlier passes' cases as byte controls (pristine vs law, evidence/controls_earlier_passes.txt):
   r11u118repro 0/56, r11v11u118repro 0/56, r11u119repro 0/78, r11u120repro 0/44, r11v120repro 0/47,
   r11u121repro 0/83, v11u121repro 0/41, r11u125repro 0/61, r11v125repro 0/48, r11v130repro 0/115,
   r11u124repro 12/81, r11v124repro 9/109, r11u130repro 1/98, r11u131repro 9/121, r11v131repro 1/128. Every mover
   judged (evidence/controls_movers_verdicts.txt, controls_record_check.txt, controls_stage1_dumpdelta.txt): 24
   judge-equal movers record-level OK (c12 a02 a05, v24 f1 f2 f4 f6 q04 k10, pass-131 hpm m08 → equal; the rest
   move to their next face), 8 stage-1 on both with the same uhdm-cmp line count and a smaller order-blind dump
   distance to golden (P → L: 30→23, 93→85, 74→66, 227→219, 93→85, 27→23, 40→26, 45→37).

## Decoded, not landed (ranked residues)

R1 — N0008, the range-bound fold's typespec reference (ParameterInitializedByPartSelectOfParametersAssignedToVar
both modes as a single object; every ibex row's `PmpAddrRst`; Earlgrey): golden's ref_typespec under the folded
range constant (`logic [DepthW:0] max_value`) is parented at that constant, whose chain ends at an UNPARENTED
logic_typespec copy, so its full name computes empty; ours stores the owner name. Pinned with gdb on the `-g1`
build: TypeEmit.cpp makeTypespec's bound-fold lambda, beside § foldedBoundTsIsTheSignednessCapture48
(`rt0->VpiFullName(boundOwnerFullName)`) — the sister's ground; the law is "store no name there".

R2 — N0003's in-package read (decode grid `pkr/`, first lines name § pkgPatInPkgReadNoParent133r, not
landed): a package pattern parameter read UNQUALIFIED inside its own package (`logic [B.DAT-1:0]` in a package
typedef; iface_zero_width_field `B.CTL`) leaves the PACKAGE listing's pattern reference unparented in golden
(pkr p01 u01), which § pkgPatReadTsNoParent131's read set (scoped `pkg::NAME` reads only) does not model — and
for the PACKED case p01 golden's ELABORATED import copy KEEPS its parent where pass 131's elaborated-copy rule
unparents it (ours `NULL`, golden `work@top`): that rule is triggered by the qualified read, not by an import.
Site: ParamEmit.cpp drainShareDefParamTs, § pkgPatReadTsNoParent131. No corpus row clears on it alone
(iface_zero_width_field carries R3 too).

R3 — hier_path element spans and names built by TypeEmit's emitSyntaxExpr (sister): the base ref of a
struct-parameter member path in a range (iface_array_elem_cfg_param, iface_cfg_param_def_pass, iface_param_2level,
struct_member_cfg_width, struct_param_repl_count: golden at the MEMBER token, pass 131's R2), the definition-view
generate paths (iface_array_modport_drive, genvar_iface_struct: hier_path spans the base name, the leaf is named
`man[i].vld`), and the emitSyntaxExpr twins of § hpBaseSelMidMemberBare133 / § hpTrailSelIdxNamesByPath133 (the 16
predicted-not-moved databases above).

R4 — the port view's parameter fold spans the LEFT operand (`localparam int LP = AW + 1` in an interface port
view: golden 7:23-25, ours 7:23-29; 35 probe cases of portViewRangeRecvParams, N0005's largest share): the port
view's param_assigns are built in ModuleEmit.cpp emitInterfaceInstance (beside § portViewParamDefName130).

R5 — the elaborated `Q = X` over a wildcard-imported package parameter: golden's Rhs constant typespec is Q's
OWN (its declaration span, lhs l01 l07 l09 l11: `int_typespec 3:35-38`), ours X's package-located one: ParamEmit
emitParameters, the pkgRefSrc case (§ pkgScopedParamRhsTs60 / § pkgUntypedYNoStamp60). Pass 60 measured the
opposite for the ParameterFromPkg* case; this is the next face of the header-import cells, not landed.

R6 — the unpacked-array import clone's typespec (lhs l04, pass 124 c12 a13, Kmac, param_unpacked_struct_array,
param_struct_field_bitsel, StructArrayParameterInitializedByPatternPassedAsPort: `depth` → `type`): golden's
clone array_typespec lists its range before the element reference; decode pending (the copy's typespec is not
the listing's).

R7 — a BASE select's variable index inside an operation operand (tix t14 `tbl[r].sat[i] & ...`): golden
`work@dut.tbl[r].sat[i].r` (parented at the base bit_select), ours `work@dut.r`: emitMixedHierPath's base-select
`doParent` rule, not landed.

R8 — the process-lvalue trailing select (tix t08 `tbl[r].sat[i] = 1'b1` in `always_comb`): golden bit_select
`tbl[r].sat[i]` at the index span, ours the doubled lazily frozen name at the member+index span:
emitMixedHierPath's first single-select case.

R9 — constants a ModuleEmit fold writes (sister): PkgParamAsFunctionArg's elaborated function-call fold
(golden span 0:0-0:1, ours 0:0-0:0; emitContAssigns), IndexAssign's `assign sig[I-7] = 3` (golden keeps 64-bit
`3`, ours re-sized to the select).

R10 — NET BINDING (pass 131's R1): the pqs grid's trailing `logic_net` under the output ref_obj and every class-A
row; ModuleEmit.

R11 — StructUnsizedVal / LargeValue2Struct: the elaborated fold of a module parameter defaulted to an imported
struct parameter spans `<pkg>::`'s length from the reference (17:53-58 for `pkg`); not pinned (none of the
ParamEmit / ExprEmit qualifier-span sites fires on the unqualified text).

## Cases (first line of every case names its law)

| case | law (first line) | pristine | law binary |
|---|---|---|---|
| `hpm/m01` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 187 objects |
| `hpm/m02` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 189 objects |
| `hpm/m03` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 184 objects |
| `hpm/m05` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 186 objects |
| `hpm/m06` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 196 objects |
| `lhs/l01_hdr_int` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL line |
| `lhs/l02_hdr_vec2d` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL fullname |
| `lhs/l03_hdr_struct` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 289 objects |
| `lhs/l04_hdr_unpacked` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL type |
| `lhs/l05_pkgpkg_int` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_EQUAL 115 objects |
| `lhs/l06_pkgpkg_two` | § impPaLhsDisjointClone133 | cmp=50 NOT_EQUAL stage1 | cmp=50 NOT_EQUAL stage1 |
| `lhs/l07_body_ctl` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_NOTEQUAL line |
| `lhs/l08_hdr_noport_ctl` | § impPaLhsDisjointClone133 | cmp=0 STRICT_EQUAL 81 objects | cmp=0 STRICT_EQUAL 81 objects |
| `lhs/l09_iface_hdr` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL line |
| `lhs/l10_hdr_enum` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL fullname |
| `lhs/l11_hdr_two_inst` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL line |
| `lhs/l12_hdr_untyped` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_EQUAL 93 objects |
| `pkr/p01` | § pkgPatInPkgReadNoParent133r | see evidence/pkr_decode.txt | byte-identical to pristine |
| `pkr/p03` | § pkgPatInPkgReadNoParent133r | see evidence/pkr_decode.txt | byte-identical to pristine |
| `pkr/p04` | § pkgPatInPkgReadNoParent133r | see evidence/pkr_decode.txt | byte-identical to pristine |
| `pkr/u01` | § pkgPatInPkgReadNoParent133r | see evidence/pkr_decode.txt | byte-identical to pristine |
| `pkr/u04` | § pkgPatInPkgReadNoParent133r | see evidence/pkr_decode.txt | byte-identical to pristine |
| `pqs/q01_noimp` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL count |
| `pqs/q02_hdr_othername` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL count |
| `pqs/q03_hdr_samename` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL count |
| `pqs/q04_body_samename` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_NOTEQUAL count |
| `pqs/q05_unqual` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL count |
| `pqs/q06_override` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL depth |
| `pqs/q07_localparam` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL count |
| `pqs/q08_iface` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_NOTEQUAL col |
| `pqs/q09_hdr_samename_other` | § elabPatQualRefQualSpan133 | cmp=36 NOT_EQUAL stage1 | cmp=36 NOT_EQUAL stage1 |
| `pqs/q10_twoinst` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL depth |
| `tix/t01` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 200 objects |
| `tix/t02` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 162 objects |
| `tix/t03` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 202 objects |
| `tix/t04` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_EQUAL 178 objects | cmp=0 STRICT_EQUAL 178 objects |
| `tix/t05` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 211 objects |
| `tix/t06` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 217 objects |
| `tix/t07` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 204 objects |
| `tix/t08` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname |
| `tix/t09` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 290 objects |
| `tix/t11` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 164 objects |
| `tix/t13` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 260 objects |
| `tix/t14` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname |
| `tix/t15` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 173 objects |
| `unk/u01_div` | § unknownParamOperandFile133 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 57 objects |
| `unk/u02_z` | § unknownParamOperandFile133 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 50 objects |
| `unk/u03_known_ctl` | § unknownParamOperandFile133 | cmp=0 STRICT_EQUAL 52 objects | cmp=0 STRICT_EQUAL 52 objects |
| `unk/u04_sub` | § unknownParamOperandFile133 | cmp=52 NOT_EQUAL stage1 | cmp=52 NOT_EQUAL stage1 |
| `unk/u05_bin` | § unknownParamOperandFile133 | cmp=90 NOT_EQUAL stage1 | cmp=90 NOT_EQUAL stage1 |

## Files

* `lhs/ hpm/ tix/ pqs/ unk/` — the law grids; `pkr/` — the decode grid of residue R2 (its first lines name the
  residue, not landed).
* `drivers/`: `run_case.sh` (one case: golden with the probe flags, cached by content md5; ours; uhdm-cmp;
  strictcmp), `grid2.sh` (a grid on pristine and a law binary), `bytes.sh` (byte compare with an optional
  environment for the second run), `worse2.py` (record-level worsening check), `dumpdelta.py` (order-blind dump
  distance for stage-1 pairs), `predict133.cpp` (mover prediction from pristine databases), `tsref.cpp` +
  `tscensus.py` + `tsall.py` (every ref_typespec: parent, root of the parent chain, full name, walk context),
  `hpref.cpp` + `hpcensus.py` (every hier_path element: position, kind, full name, span), `jobs.py`
  (NE row-modes of a sweep with their goldens), `anc.py` / `ctx.sh` (a strict record with its ancestors).
  Build a C++ driver with `g++ -std=gnu++20 -include uhdm/config.h X.cpp -I ~/.local/include
  ~/.local/lib64/libuhdm.a ~/.local/lib64/libcapnp.a ~/.local/lib64/libkj.a -ldl -lpthread`.
* `evidence/`: sweep gates, byteverify, predictions, record checks, downstream summary, grids, switches,
  earlier-pass controls, the pkr decode.
