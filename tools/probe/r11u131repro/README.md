# r11u131 — the expression/parameter ground of the strict axis, second refill (implementer)

Base `4e17c7ee` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`,
`src/StmtEmit.cpp`, `src/EmitHelpers.h`. No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`,
`UhdmExporter.cpp`, `TaskFuncEmit.cpp`, `uhdm_main.cpp` or any header under `include/` (a face whose fix
sits there is decoded below and stops there). Worktree `/tmp/wt_r11u131`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (byte-identical to the main tree's `build/slang-uhdm`, rebuilt from the base in the worktree) | `9767e18b4753a0562f90d27f919b01d8` |
| law (this patch) | `f70fbe2e2b3207848d8cbf5950aa3c45` |
| `build/uhdm-strictcmp` (identical to the main tree's) | `70ddf0ad777735ff05ec8d89aee66627` |

Every binary was frozen (`chmod 555` copy) before it measured anything; every `cmds.txt` of the law
sweep names the frozen law binary (3273 of 3273 slang lines; the pristine sweep's name the frozen
pristine binary, 3273 of 3273), and the downstream lane's databases are byte-identical to the law
binary's own output (checked on `Disable`, a mover).

## Result

| axis | pristine | law | delta |
|---|---|---|---|
| surelog strict-equal (of 954 judge-equal row-modes) | 640 | **685** | +45 |
| uhdm2rtlil strict-equal (of 1606) | 1264 | **1280** | +16 |
| probe strict-equal (of 4087) | 2068 | **2104** | +36 |
| surelog scoreboard | 480/3 + 474/3 | same | regressions=0 conversions=0 changes=0 |
| uhdm2rtlil scoreboard | 803/1/67 both modes | same | regressions=0 conversions=0 changes=0 |
| probe gate | EQUAL=4087 | EQUAL=4087 | |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same | 0 of 871 rows changed (verdict and `differs`) |

61 corpus row-modes turn strict-equal (evidence/to_equal_rows.txt, each with the laws its pristine
database triggers). No row-mode's strict column worsened, and no object that pristine matched differs
under the law binary, anywhere in the walk (method and numbers in "Census").

## Laws (all under `R11U131_OFF=1`, each droppable alone)

| law | switch | site (file + § token) | cluster(s) of the map |
|---|---|---|---|
| § implicitNetMintNoFile131 | `R11U131_INETFILE_OFF` | ExprEmit.cpp (emitPropFormalRef, the block-local / foreach / task-parameter mint, the scope-name-in-a-system-task mint), StmtEmit.cpp (the `disable` target), EmitHelpers.h (registry), ParamEmit.cpp (the clear, in drainShareDefParamTs) | K0027, K0034 (expression half) |
| § paramFoldParenSpan131 | `R11U131_PAREN_OFF` | ParamEmit.cpp (registration in the emitParameters loop, post-pass `paramFoldParenSpan131`) | K0025 |
| § pkgQualCallQualSpan131 | `R11U131_QCALL_OFF` | ExprEmit.cpp, the package-function call case (beside § defGenQualPkgCallBinds18) | K0060 |
| § paramIdxPartSelWholeSpan131 | `R11U131_IPSSPAN_OFF` | ExprEmit.cpp, the indexed part-select case | `span|indexed_part_select|…|under:param_assign` |
| § sysCallKwTypeArgNameSpan131 | `R11U131_KWSYS_OFF` | ExprEmit.cpp, the system-call case (the `$bits` folds and the sys_func_call) | `span|sys_func_call|endcol|under:param_assign` and the `$bits(int)` constants |
| § ovrMultiDimConstUnparented131 | `R11U131_OVRMD_OFF` | ParamEmit.cpp, post-pass `ovrMultiDimConstUnparented131` | `fullname|ref_typespec|golden-empty|under:constant` (param_assign part) |
| § pkgPatReadTsNoParent131 | `R11U131_PATTS_OFF` | ParamEmit.cpp, drainShareDefParamTs (registration in the emitParameters loop) | C0013 / `fullname|ref_typespec|golden-empty|under:operation` (pass-124 residue R2) |
| § pkgParamTsRefColons131 | `R11U131_PTSSEP_OFF` | ParamEmit.cpp, the makeParamTs call of emitParameters | `fullname|ref_obj|tok:::->.|under:operation` |
| § castTsPushLaidOut131 | `R11U131_CASTLOC_OFF` | ExprEmit.cpp, the three `pendingCastTs` pushes (§ castTsFile124 blocks) | pass-r11v125 residue R11 (ct t03) |

`R11U131_OFF=1` restores pristine bytes on all 121 cases of this directory (`drivers/bytes.sh`,
evidence/master_switch.txt: SAME 121 / DIFF 0; positive control: the law binary without the switch
differs from pristine on 63 of them) and on ten example rows (BlackParrotSkipParam, CheckerInst,
ElabCParam, EvalFunc, NonSynthError, LogicArrayParam, ParamOverload2, PackStructField,
IndexedSelectHex, Disable; evidence/master_switch_rows.txt). Each single switch restores pristine bytes
on a case where only its law fires (evidence/single_switches.txt, 10 of 10).

### § implicitNetMintNoFile131 (K0027, the expression half of K0034)
DECODE (the producer of § implicitNetNoFile119, not re-derived): a wire UhdmWriter's late binding mints
for a name nothing declares copies the reference's four span fields and no VpiFile
(UhdmWriter.cpp:3987-4005). Pass 119 cleared the definition-net loops' twins in ModuleEmit; the four
mint sites of the expression and statement emitters were its "NOT noted" roads: the property formal
(`emitPropFormalRef`), the block-scoped localparam / foreach loop variable / task-scope parameter mint,
the scope name handed to a system task (`$dumpvars(0, top)`) and the `disable` target. THE LAW: each
mint notes its net; the end-of-export pass in ParamEmit clears the file when the net's parent is a
DEFINITION (a module/interface/program with no name), as pass 119 does — an elaborated twin keeps its
file. The reuse branches (a net the module already lists, SimpleUVM's `top`) mint nothing and are
untouched. CheckerInst `req`: golden ` 6:22:6:25`, ours `dut.sv 6:22:6:25` → CheckerInst both modes
**equal**. Grid `inet/`: n01 n04 n05 n10 → equal; n06 loses its file facets (its first field is the
elaborated property's full name, not this law); n02 n03 n07 n08 n09 are NOT_EQUAL at the base.

### § paramFoldParenSpan131 (K0025)
DECODE. Surelog elaborates a parameter by reducing its declaration's Constant_param_expression node and
populating the reduced constant from that node; a written `($clog2(n+1))` is one node from `(` to `)`.
slang keeps the inner expression's sourceRange and parks the ParenthesizedExpression on `syntax` (the
rule § pkgQualPsParenSpan118v measured on a part-select bound). MEASURED (grid `par/`): the
elaborated constant spans the parentheses whatever the value (p02 the overridden `lg_p` 2:56-77, p06
`(8)` overridden by `(3+1)` 2:28-31, p11 `("ab")` 2:28-34); the definition listing's literal keeps its
own token (`(8)` def 2:29-30), and an Rhs that stays an operation keeps the inner span everywhere
(`(3+4)` def 2:29-32). THE LAW: emitParameters records every parenthesized declarator initializer
(inner span → outer span, keyed by file and parameter name); the post-pass widens every ELABORATED
param_assign constant found at the inner span, and in package listings and a definition's import
copies only a reduced (non-literal) initializer. A definition's own folded parameter is excluded: its
fold anchors elsewhere (Earlgrey dm_mem `(DmBaseAddress != 0)`, residue R8) — an earlier cut that
widened it moved one Earlgrey object from `endcol` to `col+endcol` and was fixed before the final sweep.
BlackParrotSkipParam `.lg_max_val_lp(10)` over the default `($clog2(max_val_p+1))`: golden 4:31-52,
ours 4:32-51 → both modes **equal**.

### § pkgQualCallQualSpan131 (K0060)
MEASURED (grid `qc/`): a package-qualified function call in a parameter initializer spans the
qualifier with its `::` (q01 `p::f(2)` 6:32-35), in the definition listing, the elaborated instance and
a body localparam (q01 q03 q04 → equal); the same call in a continuous assignment, a process and an
override actual already matched (q05 q06 q07 equal, untouched). The law
widens the package-token span by the written `::` in a parameter-init context (`inParamInit`) only.
struct_param_func_arg `p::build`: golden 16:39-42, ours 16:39-40 → both modes **equal**; EvalFunc
`prim_util_pkg::vbits` 67:25-40 → both modes **equal**.

### § paramIdxPartSelWholeSpan131
MEASURED (grid `ips/`): an indexed part-select in a parameter initializer or override spans the whole
select (`A[8*4+:4]` 4:16-25) where ours spanned the range (4:18-24); `+:` and `-:`, a literal and a
parameter base index, nested in an operation, a concatenation operand, a port-list default, an
override (i01 i02 i05 i06 i10 i11 i15 → equal or the next face). A procedural select keeps the range
span (i14 equal, untouched). Surelog compiles a parameter initializer through the Constant_primary
alternative (`ps_parameter_identifier constant_select`) and populates the select from that node. The
gen-if condition and the generate-scope localparam (i13 i16) are emitted by TypeEmit's emitSyntaxExpr
(residue R4). ElabCParam, LargeHex, PartSelect4 → both modes **equal**.

### § sysCallKwTypeArgNameSpan131
MEASURED (grid `sfc/`): a system call whose argument is a built-in keyword type spans its name token
(`$size(int)` 3:15-20), and a `$bits` of one folds to a constant at that span; `int`, `byte`,
`shortint`, `integer`, a scalar `logic`, in a parameter default, a localparam operand, a port-list
parameter and a continuous assignment (s01 s02 s05 s07 s09 s10 s11 s14 → equal, s13 → its next face);
a typedef name and a variable keep the whole call (s04 s08 equal, untouched). Surelog's call node is
the `System_task_names` name node (CompileExpression.cpp, paSystem_task_names). NonSynthError both
modes **equal**; the UVM rows' `$bits(int)` / `$bits(byte)` spans move (Scoreboard, SeqDriver,
SimpleUVM, MiniAmiq, BuildUVMPkg: evidence/scoreboard_default_orderblind.diff — every order-blind
line of Scoreboard/default is one of these spans).

### § ovrMultiDimConstUnparented131
DECODE. NetlistElaboration keeps a parameter whose type is multi-dimensional
(CompileHelper::isMultidimensional: a logic/bit/array typespec with more than one range, a packed
array of a struct or of more than one range) off the scalar road
(`(overriden == false) && (!isMultidimensional)`), the one road that parents the elaborated constant
(`c->VpiParent(inst_assign)`). MEASURED (grid `ovr/`): an overridden 2-D packed parameter's Rhs
constant has no parent in golden, so its ref_typespec (parented at the constant) computes an empty full
name (o07 o09 o11 → equal, o10 → its next face); a 1-D vector, a struct, an int and a non-overridden
2-D parameter keep it (o01 o02 o05 o06 o08 o12 o13 equal, untouched). A value the instance also READS
(`assign o = M;` shares the constant, as Surelog's substitution does) is reparented at that use in
golden and keeps the instance's name (probe r11u111repro a12_q_multidim, v11u111repro x04_twodim; grid
o14): excluded — the first cut missed it and moved those two probe cases, fixed before the final sweep.
ParamOverload2 `.RndCnstLfsrPerm(384'b1)`, 2DParameterOfInstance → both modes **equal**.

### § pkgPatReadTsNoParent131 (pass-124 residue R2, C0013)
DECODE (pass 124's, extended). The qualified case of CompileHelper::getValue
(CompileExpression.cpp:921-952), reached whenever an expression reading `pkg::NAME` is reduced, runs
expandPatternAssignment on the package param_assign's assignment-pattern Rhs and writes the result
back; the copy's ref_typespec is the one ExprEval::flattenPatternAssignments mints and never parents.
MEASURED (grid `pat/` + r11u124repro `c13/`): a package pattern parameter read qualified in a
continuous assignment, a member read, a localparam, a `default:` pattern, twice → the package listing's
reference is unnamed (t02 q02 q08 q09 → equal; t01 q03 q10 → their next face); a qualified parameter
DEFAULT is not such a read (t03 q04 untouched, the read set of § pkgNestedPatElabNoExpandSize34 excludes
parameter declarations). And every ELABORATED listing's copy of an imported packed pattern parameter is
the package's flattened complex value (body import, header import, interface body import, a submodule;
t04 t10 t14 t15 t16 t17 → equal, t11 → its next face); a module's own pattern parameter keeps its parent
(t12 t13 equal, untouched). THE LAW gives such an operation a FRESH unparented reference (the old one
stays with any other holder), and leaves alone: an operation that also stands in a module or interface
listing (our `pkg::P` substitution shares the package object where golden's use keeps the original:
ParamTypespec2's port connection, ParamNoImport's override), an UNPACKED struct (iface_zero_width_field
`B` keeps its parent), a name the definition declares itself (ff_dead_both_branches `Cfg`), and a
parameter whose initializer is not written as a pattern (BlackBePipeInt `bp_unicore_cfg_p =
bp_default_cfg_p`). Each exclusion is a cell the first cuts moved away from golden and the
final binary does not. IndexedSelectHex, GenScopeHierPath, ParamElabMulti, MultiConcatValueSize,
PAssignType, BitSelectOfParameterPassedToSubmoduleInGenFor(+OfSubmodule),
StructParameterInitializedWithPatternAndReferenced, PatternAssignmentOfStructParam → **equal**.

### § pkgParamTsRefColons131
UHDM's ComputeFullName switches every separator to `::` once a package is on the parent chain
(BaseClass.cpp `column = true`). A package parameter's typespec lives in the package, so the bound ref
of `parameter logic [NAlerts-1:0] AsyncOn` is `alert_handler_reg_pkg::AsyncOn::NAlerts` (golden
LogicArrayParam); ours joined `...::AsyncOn.NAlerts` (the ref is named by TypeEmit's emitSyntaxExpr with
the separator its caller sets; the packed-array-of-typedef branch of makeParamTs already set `::`).
THE LAW sets the separator at emitParameters' makeParamTs call in a package listing. Grid `pts/`: p06 →
equal, p03 p05 → their next face; p01 p02 p04 NOT_EQUAL at the base. LogicArrayParam, EarlgreyPackParam
→ both modes **equal**.

### § castTsPushLaidOut131 (pass-r11v125 residue R11)
The deferred cast-target typespec is written by ModuleEmit's drain verbatim from the `pendingCastTs`
record, whose columns ExprEmit took raw from the SourceManager (pass 124 laid out only a macro-expanded
one). THE LAW lays every push out with `locLineCol`, the arithmetic of every setLoc (the include
first-line shift § includeFirstLineColShift125, a same-line macro's shift). Grid `ctp/`: c01 (`include`
at column 3: golden `6'(a)` integer_typespec body.svh 1:14-15, ours 1:12-13), c03 (a macro before the
cast on the line), c05 (`include` at column 5) → equal; c02 c04 controls equal, untouched;
r11v125repro ct/t03 → equal.

## Grids (pristine → law, per cell; evidence/grids_pristine_vs_law.txt)

| grid | law | cells | → equal | next face | untouched equal | untouched NE | NOT_EQUAL at base |
|---|---|---|---|---|---|---|---|
| inet | § implicitNetMintNoFile131 | 10 | 4 | | | 1 (n06) | 5 |
| par | § paramFoldParenSpan131 | 12 | 3 | | 6 | | 3 |
| qc | § pkgQualCallQualSpan131 | 10 | 3 | | 3 | | 4 |
| ips | § paramIdxPartSelWholeSpan131 | 16 | 5 | 2 (i05 i15) | 3 | 2 (i13 i16, residue R4) | 4 |
| sfc | § sysCallKwTypeArgNameSpan131 | 14 | 8 | 1 (s13) | 3 | | 2 |
| ovr | § ovrMultiDimConstUnparented131 | 14 | 3 | 1 (o10) | 8 | 2 (o03 o04, other faces) | |
| pat | § pkgPatReadTsNoParent131 | 18 | 7 | 3 (t01 t07 t11) | 3 | 1 (t03) | 4 |
| pts | § pkgParamTsRefColons131 | 6 | 1 | 2 (p03 p05) | | | 3 |
| ctp | § castTsPushLaidOut131 | 5 | 3 | | 2 | | |
| hcc | residue R3 (decode only, law hiConnConstTsName131 not landed) | 8 | | | 2 | 4 | 2 |
| hpm | residue R2 (decode only, law cstParamMemberBaseSpan131 not landed) | 8 | | | | 4 | 4 |

drivers/worse.py over every grid cell (record by record against the same golden): 99 OK, 32 stage-1
(uhdm-cmp NOT_EQUAL on both binaries), 0 WORSE. Two stage-1 cells of `pat/` (t06 t09) print 11 instead
of 17 uhdm-cmp lines: the same `lhsPath`/`rhsPath` head, the printed decompile of the typespec
reference no longer carries its parent lines.

## Census (the whole strict column, law sweep vs pristine sweep, row by row)

Sweeps: `tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil"` with `SLANG_UHDM` exported,
workdirs `/tmp/r11u131_wdP` (pristine) and `/tmp/r11u131_wdJ` (law), same length. The pristine strict
column equals `results/golden_*.csv` column 6 on every row.

drivers/strictdiff.py (evidence/strictdiff_*.txt):

| | TO-EQUAL | BETTER (same field, fewer objects) | FIELD-CHANGE | WORSE | STATUS |
|---|---|---|---|---|---|
| surelog | 45 | 10 | 4 | 0 | 0 |
| uhdm2rtlil | 16 | 24 | 6 | 0 | 0 |
| probe | 36 | 20 | 16 | 0 | 0 |

Record level: drivers/worse.py re-walks every byte mover against its golden with both databases
(129 corpus row-modes: 133 checks, 133 OK; every changed probe case: 72 OK) — no object that pristine
matched differs under the law binary before the walk diverges, and no walk diverges earlier. Beyond the
divergence: drivers/analyze.py (r11u122's aligner) + drivers/facetdiff.py classify EVERY differing
object of all 656 strict-NE row-modes on both sweeps: 0 row-modes gain an object in any cluster, 127
lose objects (evidence/facetdiff.txt). This instrument is what found the six over-firing faces named
in the law sections, each fixed before this sweep.

Converted row-modes and the laws their pristine databases trigger (evidence/to_equal_rows.txt):
INETFILE 19, PATTS 14, IPSSPAN 6, PTSSEP 4, QCALL 4, OVRMD 4, PAREN 2, KWSYS 2, PAREN+PATTS 3,
INETFILE+PATTS 3 (61).

## Gates

1. Build: md5s above; the pristine rebuild is byte-identical to the main tree's `build/slang-uhdm`.
2. Probe: `EQUAL=4087 (of 4087)`; probe strict 2068 → 2104.
3. Corpora: `regressions=0 conversions=0 changes=0 only-fresh=0 only-committed=0` in both.
4. Downstream (`tests/sweep.sh --corpus downstream`, law binary): `EQUIVALENT=2 IDENTICAL=803
   SLANG_REJECT=66 (of 871); not identical and not excused=0`; row join against
   `results/downstream_uhdm2rtlil.csv` (drivers/dsdiff.py): 0 of 871 rows changed
   (evidence/downstream_summary.txt). The targeted u2r
   rows read IDENTICAL, e.g. `Disable,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `const_func_block_var,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `struct_param_func_arg,IDENTICAL,OK,OK,51,51,,`; pass 120's eight rows stay IDENTICAL.
5. uhdm-cmp: every row-mode keeps CMP_EQUAL (the scoreboard join), every probe case EQUAL.
6. Byteverify (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law vs pristine workdir):
   surelog `PATH_SETS_IDENTICAL (960 paths)`, `MOVERS: 81 / 960`, selfcheck 959/960; uhdm2rtlil
   `PATH_SETS_IDENTICAL (1608 paths)`, `MOVERS: 48 / 1608`, selfcheck 1607/1608. PREDICTED BY NAME:
   drivers/predict131.cpp reads each PRISTINE database and reports which law's trigger is present
   (evidence/predictions_pristine.txt): 129/129 movers predicted, 0 unpredicted; movers by law INETFILE 42,
   PATTS 53, PTSSEP 37, QCALL 18, KWSYS 11, PAREN 9, IPSSPAN 6, OVRMD 5 (a database can carry several).
   The predicates are wider than the laws (261 predicted databases did not move: INETFILE 229 — a
   definition wire with no typespec and a reference at its span is also a non-ANSI port or an
   undeclared-type net; PATTS 20, PAREN 8, PTSSEP 4, CASTLOC 2). The UVM family moves and is predicted
   (KWSYS and PTSSEP on all four, INETFILE too on SeqDriver and SimpleUVM): Scoreboard/default's order-blind dump diff is 128 lines, every one a `$bits(int)` /
   `$bits(byte)` span (evidence/scoreboard_default_orderblind.diff).
7. Canaries (the committed csvs are CRLF, so the scripts are read law output vs pristine output,
   evidence/canaries_law_vs_pristine.diff): every status identical; the strict cells that change move
   toward golden (Earlgrey_0_1 `line(1055)` → `line(1041)`, BuildUVMPkg `fullname(328)` → `(283)`,
   PartSelect4 / EvalFunc / BlackParrotSkipParam → `equal`).
8. Earlier passes' cases as byte/verdict controls (drivers/bytes.sh, pristine vs law,
   evidence/controls_earlier_passes.txt): r11u118repro 1/56 changed (p28_structmember, stage 1),
   r11v11u118repro 0/56, r11u119repro 0/78, r11u120repro 0/44, r11v120repro 0/47, r11u123canon 0/22,
   r11u125repro 0/61, r11u121repro 14/83, v11u121repro 12/41, r11u124repro 9/81, r11v124repro 2/109
   (pv/v14_string and qx/q08_string fail to export on BOTH binaries with `--nobuiltin`: no database, not
   a change), r11v125repro 1/48. Attribution (evidence/worse_controls.txt, controls_cmp_lines.txt,
   controls_ok_movers.txt): 11 record-level OK movers, all toward golden (c13 q02 q05 q08 q09 and
   r11v125 ct/t03 → equal; c13 q01 q03 q10, r11u121 s04 s08, c12 a05 → their next face); 26 stage-1
   cases keep the same uhdm-cmp head (`lhsPath`/`rhsPath`), 18 of them print 11 instead of 17 lines (the
   pattern reference's parent lines, § pkgPatReadTsNoParent131).

## Decoded, not landed (ranked residues)

R1 — NET-BINDING (K0017 K0080 K0044 K0045 + K0043's names; 32 structural row-modes at the map's base,
18 + 7 single-cluster rows here). The Actual choice is ModuleEmit's in every shape measured;
`drivers/refbind.cpp` lists, for every ref_obj of the elaborated tree, whether its Actual is a
definition-listing object (evidence/netbinding_refbind.txt):
* continuous-assignment LHS over a RHS Surelog REDUCES to a constant without an operation
  (ParameterColonReference `assign a = pkg::A[0]`, StructLocalParam, array_assign,
  Clog2OfSumWithParameterIn2InstancesOfSubmodule): UhdmWriter::writeCont_assign's `simplified == false`
  reduce (UhdmWriter.cpp:2245-2275) clones the assign with a context-free ElaboratorContext, whose
  elaborator has no instance on its stack: the generated `ref_obj::DeepCopy` copies the Actual and
  `bindAny` finds nothing, so the LHS keeps the DEFINITION net. Our rule ("A COMPUTED RHS that folds … a ref_obj Lhs bound to the DEF
  net", ModuleEmit.cpp emitContAssigns, beside § caStrengthAndDelayDeclined88) counts BinaryOp, UnaryOp,
  ConditionalOp and system calls only; an element select of a parameter is the missing kind (probe
  shape: `assign a = pkg::A[0]` DEF in golden, ELAB in ours; `assign a = 1'b1` DEF on both).
* the mirror, a continuous-assignment RHS operand (cdc_static_basic, partsel_simple, vector_index):
  golden ELAB, ours DEF — the same function.
* the default clocking block's event (sva_range, sva_throughout, sva_value_change_changed(_wide),
  sva_value_change_rose, sva_counter): golden binds the DEFINITION net; the elaborated listing calls
  `emitScopeClocking(body, mm9, prefix, topNets, false)` where the global clocking block passes the
  definition nets `it->second.nets` (ModuleEmit.cpp, beside § caProgramGenFlattensEveryKind95).
  StmtEmit's emitEventExpr (§ evCtrlOperandBinds108) only reads the map it is given.
* port connection operands (param_type_logic_width, wandwor, dff_different_styles): golden binds the
  DEFINITION net and names the ref through the port (`work@dffsr2.uut.preset.preset`: UHDM
  ComputeFullName over ref_obj → port → instance); emitInstance (ModuleEmit.cpp) chooses the map and the
  name.
All u2r rows of this class are downstream IDENTICAL.

R2 — the base ref of a struct-parameter member path in a constant context (`Cfg.XLEN` in a range, a
gen-if condition, a parameter initializer) is located at the MEMBER token in golden (82 row-modes carry
the cluster; iface_array_elem_cfg_param, iface_cfg_param_def_pass single-cluster). Pinned on grid `hpm`
m03 with a `-g1` build: TypeEmit.cpp emitSyntaxExpr (beside § hpSymbolicSelect), the sister's ground;
the parameter-initializer shapes of the grid are NOT_EQUAL at the base.

R3 — a port connection written as a replication folds to a constant whose ref_typespec golden names
through the parent chain `<instance>.<port>` (ParamMultiConcat, SignedBin, ReplicationPassedToInstance:
6 single-cluster rows; grid `hcc`): pinned to ModuleEmit.cpp emitInstance, the "ELAB conn REPLICATION
actual folds" block (beside § patFlatUnsizedMemberWidth61), which writes `hcPrefix + "." + port`.

R4 — an indexed part-select in a gen-if condition or a generate-scope localparam (ips i13 i16) is
emitted by TypeEmit.cpp emitSyntaxExpr (beside § selChainDecideBeforeMint41); the constant-expression
rule of § paramIdxPartSelWholeSpan131 applies there too.

R5 — the package listing of a pattern parameter whose operation our substitution SHARES with a module
use (ParamTypespec2, ParamNoImport, BlackBePipeInt): golden's use keeps the original and only the
package listing takes the flattened copy; landing it needs a separate object for the package listing
(a copy), so § pkgPatReadTsNoParent131 leaves these alone.

R6 — K0047/K0099 (the tagged-pattern key's cast typespec, cva6_struct_param_field `Cfg.XLEN'(1)`:
golden `struct cfg_pkg::cfg_t`, ours integer_typespec): not decoded; no row turns equal on it alone.

R7 — macro-argument spans (K0035 CovMacro's predefined `SV_COV_*` constants end at 0:0; K0050-K0055 the
ibex prim_assert `$error`/`$time` lines): locLineCol / fullFilePath in UhdmExporter.cpp (pass 125's R4,
the multi-line macro line model), the sister's ground.

R8 — a definition's own parenthesized parameter that folds anchors neither at the parentheses nor at
the inner expression (Earlgrey dm_mem `(DmBaseAddress != 0)`: golden 64:64-68, ours 64:64-76).

R9 — LargeValue2Struct: the elaborated fold of an unqualified imported struct parameter spans
`<package>::`'s length from the reference (8:19-25 for `pack`, 8:19-27 for `pkgxyz`) where golden spans
the name; not located on this ground (none of ExprEmit's / ParamEmit's qualifier-span sites fires on the
unqualified text; the next pass pins it with the `-g1` build).

R10 — EmptyAssign / InterfInst / ClogParam (testflags): the elaborated process / continuous
assignment named by the definition (`work@dut.b` for `work@top.dut.b`): shared def-view objects in
ModuleEmit's process and cont_assign emission.

R11 — the next faces this pass revealed: ips i05/i15 and ovr o10 (the parameter typespec's name
`pk::p_t`), pat t01/t07/t11, pts p03/p05, sfc s13 (`$size(int)` in a continuous assignment folds on
our side).

## Files

* `inet/ par/ qc/ ips/ sfc/ ovr/ pat/ pts/ ctp/` — the law grids (`dut.sv`, first line names the law);
  `hcc/ hpm/` — decode grids of residues R3 and R2 (their first lines name the residue, not landed).
* `drivers/run_case.sh` (one case: golden with the probe flags, cached by content md5, ours, uhdm-cmp,
  strictcmp), `grid.sh`, `cmpgrid.sh` (a grid on two binaries, joined), `show.sh`, `bytes.sh` (byte
  compare of every case between two binaries, optional environment for the second);
  `strictdiff.py` (strict-column row join), `worse.py` (record-level worsening check),
  `jobs.py` + `run1.sh` + `analyze.py` + `summ.py` (the r11u122 aligner re-pointed at this pass's
  dumps) + `facetdiff.py` (per-row cluster gains beyond the walk divergence), `rows.py`,
  `probe_strict.py`, `dsdiff.py`, `predict131.cpp` + `predjoin.py` (mover prediction),
  `refbind.cpp` (which object each elaborated ref_obj binds). Build a C++ driver with
  `g++ -O1 -std=c++17 X.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj`.
* `evidence/` — strict diffs, worse checks, facet diff, byteverify, predictions, downstream summary,
  grids, earlier-pass controls, canaries, switches, net-binding decode, the Scoreboard order-blind diff.
