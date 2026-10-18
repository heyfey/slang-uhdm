# r11u401 — the expression/parameter ground on sv-tests (pair A, implementer)

Base `eee9c5fd4` (matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/EmitHelpers.h`,
`src/StmtEmit.cpp`, `src/ParamEmit.cpp`. Every law reads its switch through
`lawOn(401, "R11U401_<LAW>_OFF")` from `src/LawSwitch.h`; `R11U401_OFF` drops
every law of the pass; `R11U401_TRACE=<dir>` logs each firing through
`lawTrace(401, ...)`. No `src/R*.h`, no `getenv`, no reader function.

Binaries (frozen before any measurement): pristine `2982d1ee861fb421aceffc8c0cc4e18f`
(byte-identical to the main tree's `build/slang-uhdm` at the base), law
`674e9baeed2ead711fa9f7a7c4a2cd4a`. slang 12.0.0+545f88b2e.

## Verdict

* sv-tests stage (`scripts/check_svtests.py`, all 2346 rows, `--jobs 3`):
  **regressions=0, conversions=65, changes=0** (rows listed below).
* probe 4017 EQUAL + 70 STRICT_NOTEQUAL, regressions/conversions/changes 0/0/0;
  surelog 480 + 0 / 474 + 0 (954 of 954 CMP_EQUAL), 0/0/0; uhdm2rtlil 803/1/67 in
  both modes, 0/0/0; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT /
  0 DIVERGENT, not identical and not excused 0. Every stage of the pristine
  control sweep reads the same.
* byte movers (byteverify, SELFCHECK on, same-length workdirs): surelog
  **0 / 960** (selfcheck 959 / 960), uhdm2rtlil **0 / 1608** (selfcheck
  1607 / 1608); probe: the 15 probe cases where a law fires (trace census
  below) rebuilt with both binaries, **0 of 15** move.

## Laws

| law | switch | file | what |
|---|---|---|---|
| § pkgEnumParamFold401 | R11U401_PKGENUMFOLD_OFF | ParamEmit | § r10fsv3 S4b (an elaborated package parameter whose default is ANOTHER package's enum member written `pkg::NAME` keeps the unfolded ref_obj) holds only for a FORWARD reference (FuncStructVal: cva6_config_pkg reads config_pkg declared below it). When the enum's package is compiled EARLIER (include-expanded source order), Surelog's elaborated listing folds it like any other enum default: constant with the member's own encoding, the parameter's value, ts ref named by the package. |
| § pkgEnumParamFoldQualSpan401 | R11U401_PKGENUMQSPAN_OFF | ParamEmit | that fold (and the package's own `p2::C`) is located at the qualifier `pkg::`, colons included (the span § pkgQualFoldSpanByView124 gives a qualified parameter ref). |
| § pkgEnumUntypedParamFold401 | R11U401_PKGENUMUNTYPED_OFF | ParamEmit | an UNTYPED package parameter defaulting to an enum member is the member's enum_const value: implicit / based-decimal member INT:<v> size 32, unsized decimal UINT:<v> size 32, binary/hex/octal the written literal at its width; the parameter carries the value; a fresh int_typespec at the whole declaration (ranged [w-1:0] for a based literal, bounds unparented) shared by both ts refs. |
| § unbasedUntypedElabKeepsLiteral401 | R11U401_UNBASEDUNTYPED_OFF | ParamEmit | an untyped parameter defaulting to '0 '1 'x 'z keeps the literal in the elaborated listing: BIN:<bit>, size -1, vpiBinaryConst; module instance decompile `'b0`, package `'0` / `'X` with a ts ref named by the package and no actual, the parameter value BIN:<bit> (basejump bsg_cache_pkg::amo_support_level_none_lp). The module 'x/'z rewrite to `'bX` no longer runs for a package. |
| § pkgOwnEnumQualRefKeepsName401 | R11U401_OWNENUMQUAL_OFF | ExprEmit | the definition listing's `p2::C` inside p2 is the same unbound `p2::C` ref_obj (full name `p2::p2::C`) S4 writes for another package. |
| § logEquivIsEqOp401 | R11U401_LOGEQUIV_OFF | EmitHelpers | `a <-> b` is vpiEqOp (Surelog UhdmWriter maps paBinOp_Equivalence to vpiEqOp); was rejected. |
| § forceIsForceObj401 | R11U401_FORCE_OFF | StmtEmit | a procedural `force` is UHDM `force` (Rhs, Lhs), spanning keyword..written rhs end (`)` of a parenthesized rhs included); was an assign_stmt. |
| § deassignReleaseObj401 | R11U401_DEASSIGN_OFF | StmtEmit | `deassign x;` / `release x;` are `deassign` / `release` with the target as Lhs, keyword..target; were rejected. |
| § bothEdgeIsAnyEdgeOp401 | R11U401_ANYEDGE_OFF | StmtEmit | `@(edge clk)` is an operation vpiAnyEdge (63) (CompileExpression paEdge_Edge); was rejected. |
| § unboundEventTriggerByToken401 | R11U401_EVTRIGINV_OFF | StmtEmit | an event trigger whose hierarchical target does not bind (a module never instantiated: `-> top.e;`) is the event_stmt named by the path's first token, vpiBlocking, spanning the statement. |
| § unboundEventWaitByToken401 | R11U401_EVWAITINV_OFF | StmtEmit | `@top.e;` unbound: event_control over a ref_obj named by the first token spanning the path. |
| § randCaseIsRandCaseStmt401 | R11U401_RANDCASE_OFF | StmtEmit | `randcase` is a case_stmt vpiRandType vpiRand, location-less case_items holding the weight (parented at the item) and the statement (CompileStmt compileRandcaseStmt). |
| § randSequenceDropped401 | R11U401_RANDSEQ_OFF | StmtEmit | Surelog writes no object for `randsequence`, and its statement list ENDS there: the statements after it and the block's hoisted declaration-initializer assignments are not listed (the assignment is still minted, parented at the block, unlisted). slang's scope block around it goes with it. |
| § loneVarDeclStmtDropped401 | R11U401_VARDECLSTMT_OFF | StmtEmit | a variable declaration reaching the statement emitter as a statement (a subroutine body that is only `T v = new;`) writes no statement. |
| § procCheckerIsCheckerInst401 | R11U401_PROCCHECKER_OFF | StmtEmit | a checker instantiated in a procedure is the checker_inst emitCheckerInst writes, parented at the enclosing statement. |
| § concatRangeSelIsConcat401 | R11U401_CATRANGESEL_OFF | ExprEmit | `{b, c}[9:6]` is the concat operation alone spanning the whole select, bounds dropped. |
| § typeRefExprIsTextRef401 | R11U401_TYPEREFEXPR_OFF | ExprEmit | `type(T)` as an operand is an unbound ref_obj named by its text (Surelog rejects the construct: no golden; keeps the database accepted). |
| § castSizeSubrLocalBind401 | R11U401_CASTSUBRBIND_OFF | ExprEmit | a size cast whose width names a subroutine-local localparam binds in the subroutine being emitted (rggen `UP_VALUE_WIDTH'(0)`); the module-scope bind failed and the Invalid width was rejected. |
| § ifacePortArrMemberChainPath401 | R11U401_IFMEMBERCHAIN_OFF | ExprEmit | a member access chain through any depth of member/element selects rooted at an interface-port member is the dotted hier_path (rsd `w.writeSrcTag[i].regTag[0].valid`); was rejected. |
| § sysCallEmptyArgIsIntZero401 | R11U401_EMPTYARG_OFF | ExprEmit | an empty system-call argument after the first is INT:0 / "0" / size 64 / vpiIntConst, unparented, zero-width at the token after the empty slot (CompileHelper compileTfCallArguments); a leading one keeps nothing. |
| § intraAsgEventCtrlEmptyDelay401 | R11U401_ASGEVENT_OFF | ExprEmit | `a = @(posedge clk) b;`, `a <= repeat(n) @(...) b;`: an EMPTY delay_control on the assignment at the event expression inside the parens, or at the repeat count's first token. |
| § bitsBlockLocalKeepsCall401 | R11U401_BITSBLOCKLOCAL_OFF | ExprEmit | `$bits` of a variable declared in a procedural block is not one of the component's signals for `getTypespec`: the call survives (20.6--bits.sv). |
| § kwArrayMethodIsCallElem401 | R11U401_KWMETHOD_OFF | ExprEmit | the keyword-spelled array methods `and` `or` `xor` `unique`: path named by the receiver alone, method_func_call element with or without parens, last receiver element scoped (the with-clause form's three effects). |
| § classEnumViaHandleIsPath401 | R11U401_CLSENUMPATH_OFF | ExprEmit | a class's enum member read through a handle (`test_obj.C`) is the dotted unbound hier_path. |
| § asgOpInnermostParenSpan401 | R11U401_ASGPAREN_OFF | ExprEmit | an assignment operator inside doubled parentheses spans the innermost pair. |
| § strLitMacroRefSubst401 | R11U401_STRMACRO_OFF | ExprEmit | `NAME of an object-like macro written inside a string literal is expanded (Surelog's preprocessor); value/decompile/size follow; the literal's end and the rest of its line move by the length difference through the § strLitPpEscIdShift224 line map (negative shifts allowed). |

## Grid (cases/, both views, `drivers/gridall.sh` with every switch)

`evidence/grid.txt`, summary `evidence/gridsum.txt` (`drivers/gridsum401.py`):
80 cases in 19 groups, 160 case-views (views d and e), every line with its exit code: 140 moving, 122 entering STRICT_EQUAL, 0 leaving, R11U401_OFF equal to pristine on 160 of 160; every mover restored by exactly the switch of its group's law (pkgEnum untyped movers by R11U401_PKGENUMFOLD_OFF too, the untyped fold needing the backward fold first). Movers that do not reach STRICT_EQUAL are residue 8 (pe11, pe17, pu04, ce01-02, sc01-02, ma01, ia04 STRICT_NOTEQUAL col).

Cases by law (first line of each dut.sv names it): PE (pe01-pe04, pe07-pe13
§ pkgEnumParamFold401 + § pkgEnumParamFoldQualSpan401, pe05 and pe14-pe21
§ pkgEnumUntypedParamFold401, pe06 pe19 pe22 § pkgOwnEnumQualRefKeepsName401;
pe04, pe12, pe13 are controls pristine already matched: module param and
forward references), PU § unbasedUntypedElabKeepsLiteral401, EA
§ sysCallEmptyArgIsIntZero401, IA § intraAsgEventCtrlEmptyDelay401, BT
§ bitsBlockLocalKeepsCall401 (bt02 module-level var a control), AM
§ kwArrayMethodIsCallElem401 (am04 `sum` control), CE
§ classEnumViaHandleIsPath401 (ce03 `cls::B` control), SM
§ strLitMacroRefSubst401 (sm03 undefined macro control), AP
§ asgOpInnermostParenSpan401 (ap02 single paren control), PD
§ forceIsForceObj401 / § deassignReleaseObj401, EV § bothEdgeIsAnyEdgeOp401,
RC § randCaseIsRandCaseStmt401, RS § randSequenceDropped401, PC
§ procCheckerIsCheckerInst401, LE § logEquivIsEqOp401, CS
§ concatRangeSelIsConcat401, SC § castSizeSubrLocalBind401, MA
§ ifacePortArrMemberChainPath401. § unboundEventTriggerByToken401,
§ unboundEventWaitByToken401, § typeRefExprIsTextRef401 and
§ loneVarDeclStmtDropped401 have no single-file case (the first two need the
`--top` the case harness does not pass; the third has no Surelog golden; the
fourth changes the exit code only): their evidence is the sv-tests rows below.

## sv-tests (goal 1 and goal 2) — base -> law, by path

Stage at the base: EQUAL 1153, STRICT_NOTEQUAL 23, DIFFERENT 705, BOTH_REJECT 309, SURELOG_ONLY 133, SLANG_ONLY 13, SLANG_CRASH 1, SURELOG_CRASH 8, TIMEOUT 1. With the law binary: EQUAL 1206, STRICT_NOTEQUAL 21, DIFFERENT 686, BOTH_REJECT 304, SURELOG_ONLY 101, SLANG_ONLY 18, SLANG_CRASH 1, SURELOG_CRASH 8, TIMEOUT 1; regressions=0 conversions=65 changes=0 (`evidence/svtests_stage_law.log`). The 65 conversions (attribution: the law named in brackets):

* chapter-10/10.6.1--assign-deassign.sv: SURELOG_ONLY -> EQUAL [§ deassignReleaseObj401]
* chapter-10/10.6.2--force-release.sv: SURELOG_ONLY -> EQUAL [§ forceIsForceObj401 + deassignReleaseObj401]
* chapter-11/11.3.6--two_assign_in_expr-sim.sv: STRICT_NOTEQUAL -> EQUAL [§ asgOpInnermostParenSpan401]
* chapter-11/11.3.6--two_assign_in_expr.sv: STRICT_NOTEQUAL -> EQUAL [§ asgOpInnermostParenSpan401]
* chapter-11/11.4.12--concat_op-bit_select.sv: SURELOG_ONLY -> EQUAL [§ concatRangeSelIsConcat401]
* chapter-15/15.5.1--named-event-trigger-blocking.sv: SURELOG_ONLY -> DIFFERENT [§ unboundEventTriggerByToken401]
* chapter-15/15.5.1--named-event-trigger-non-blocking.sv: SURELOG_ONLY -> DIFFERENT [§ unboundEventTriggerByToken401]
* chapter-15/15.5.2--named-event-wait.sv: SURELOG_ONLY -> DIFFERENT [§ unboundEventWaitByToken401]
* chapter-18/18.14--random-stability_2.sv: SURELOG_ONLY -> DIFFERENT [§ randCaseIsRandCaseStmt401]
* chapter-18/18.14--random-stability_3.sv: SURELOG_ONLY -> DIFFERENT [§ randCaseIsRandCaseStmt401]
* chapter-18/18.16--random-weighted-case-randcase_0.sv: SURELOG_ONLY -> EQUAL [§ randCaseIsRandCaseStmt401]
* chapter-18/18.16--random-weighted-case-randcase_2.sv: SURELOG_ONLY -> EQUAL [§ randCaseIsRandCaseStmt401]
* chapter-18/18.17--random-sequence-generation-randsequence_0.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17--random-sequence-generation-randsequence_2.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.1--random-production-weights_0.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.2--if-else-production-statements_0.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.2--if-else-production-statements_2.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.3--case-production-statements_0.sv: BOTH_REJECT -> SLANG_ONLY [§ randSequenceDropped401]
* chapter-18/18.17.4--repeat-production-statements_0.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.5--interleaving-productions-rand-join_0.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.5--interleaving-productions-rand-join_2.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.6--aborting-productions-break-and-return_0.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.6--aborting-productions-break-and-return_2.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-18/18.17.7--value-passing-between-productions_0.sv: SURELOG_ONLY -> EQUAL [§ randSequenceDropped401]
* chapter-20/20.6--bits.sv: DIFFERENT -> EQUAL [§ bitsBlockLocalKeepsCall401]
* chapter-22/22.4--check_included_definitions.sv: DIFFERENT -> EQUAL [§ strLitMacroRefSubst401]
* chapter-22/22.5.1--define-expansion_10.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_11.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_13.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_14.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_15.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_16.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_17.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_2.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_24.sv: DIFFERENT -> EQUAL [§ strLitMacroRefSubst401]
* chapter-22/22.5.1--define-expansion_3.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_4.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_5.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-22/22.5.1--define-expansion_9.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401]
* chapter-6/6.23--type_op_compare.sv: BOTH_REJECT -> SLANG_ONLY [§ typeRefExprIsTextRef401]
* chapter-7/arrays/associative/locator-methods/unique.sv: DIFFERENT -> EQUAL [§ kwArrayMethodIsCallElem401]
* chapter-7/arrays/unpacked/reduction-methods/and.sv: DIFFERENT -> EQUAL [§ kwArrayMethodIsCallElem401]
* chapter-7/arrays/unpacked/reduction-methods/or.sv: DIFFERENT -> EQUAL [§ kwArrayMethodIsCallElem401]
* chapter-7/arrays/unpacked/reduction-methods/xor.sv: DIFFERENT -> EQUAL [§ kwArrayMethodIsCallElem401]
* chapter-8/8.5--properties_enum.sv: DIFFERENT -> EQUAL [§ classEnumViaHandleIsPath401]
* chapter-9/9.4.2--event_control_edge.sv: SURELOG_ONLY -> EQUAL [§ bothEdgeIsAnyEdgeOp401]
* chapter-9/9.4.5--event_nonblocking_assignment_event.sv: DIFFERENT -> EQUAL [§ intraAsgEventCtrlEmptyDelay401]
* chapter-9/9.4.5--event_nonblocking_assignment_repeat.sv: DIFFERENT -> EQUAL [§ intraAsgEventCtrlEmptyDelay401]
* chapter-9/9.4.5--event_nonblocking_assignment_repeat_int.sv: DIFFERENT -> EQUAL [§ intraAsgEventCtrlEmptyDelay401]
* chapter-9/9.4.5--event_nonblocking_assignment_repeat_int_neg.sv: DIFFERENT -> EQUAL [§ intraAsgEventCtrlEmptyDelay401]
* chapter-9/9.4.5--event_nonblocking_assignment_repeat_neg.sv: DIFFERENT -> EQUAL [§ intraAsgEventCtrlEmptyDelay401]
* generated/binary_op/11.4.7--binary_op_log_equiv.sv: SURELOG_ONLY -> EQUAL [§ logEquivIsEqOp401]
* generated/hdlconv_std2017/hdlconvertor_std2017_p239.sv: DIFFERENT -> EQUAL [§ sysCallEmptyArgIsIntZero401 ($monitor, traced)]
* generated/hdlconv_std2017/hdlconvertor_std2017_p242.sv: SURELOG_ONLY -> EQUAL [§ deassignReleaseObj401]
* generated/hdlconv_std2017/hdlconvertor_std2017_p243.sv: SURELOG_ONLY -> EQUAL [§ forceIsForceObj401 + deassignReleaseObj401]
* generated/hdlconv_std2017/hdlconvertor_std2017_p489.sv: SURELOG_ONLY -> DIFFERENT [§ procCheckerIsCheckerInst401]
* generated/logical_equivalence_operator_sim/11.4.7--logical_equiv_operator_0.sv: SURELOG_ONLY -> EQUAL [§ logEquivIsEqOp401]
* generated/logical_equivalence_operator_sim/11.4.7--logical_equiv_operator_1.sv: SURELOG_ONLY -> EQUAL [§ logEquivIsEqOp401]
* generated/logical_equivalence_operator_sim/11.4.7--logical_equiv_operator_2.sv: SURELOG_ONLY -> EQUAL [§ logEquivIsEqOp401]
* generated/logical_equivalence_operator_sim/11.4.7--logical_equiv_operator_3.sv: SURELOG_ONLY -> EQUAL [§ logEquivIsEqOp401]
* generated/rggen/rggen.sv: BOTH_REJECT -> SLANG_ONLY [§ castSizeSubrLocalBind401]
* generated/simple_logical_operators_sim/11.4.7--simple_equiv_logical_operator.sv: SURELOG_ONLY -> EQUAL [§ logEquivIsEqOp401]
* generated/uvm-examples/uvm_slave_agent.sv: BOTH_REJECT -> SLANG_ONLY [§ randCaseIsRandCaseStmt401]
* generated/uvm-examples/uvm_slave_agent_multi_seq_item.sv: BOTH_REJECT -> SLANG_ONLY [§ randCaseIsRandCaseStmt401]
* generic/member/class_member_test_27.sv: SURELOG_ONLY -> DIFFERENT [§ loneVarDeclStmtDropped401]


Goal-1 rows still rejected and why:
* `generated/black-parrot/*.sv` (6, Surelog crashes on all): the exporter's
  `basic_string::substr` exception is ExprEmit's IntegerLiteral base split on a
  macro literal whose range text reads back as `` ``funct12``,{5{1' `` (the
  `rv64_fi_type` macro of bp_common_rv64_instr_defines.svh). A token-text fix
  (`evidence/withdrawn/macroVecLitTokenText401.cpp.txt`, case
  `evidence/withdrawn/ML`) removes the exception: run ALONE bp_default,
  bp_multicore_1, bp_multicore_1_cce_ucode and bp_unicore then export (rc 0,
  ~10-11 GB RSS, the bp_default database 950 MB), but bp_multicore_4 and
  bp_multicore_4_cce_ucode_cfg are OOM-killed (rc -9) on this 15 GB machine
  even alone, and under the stage's `--jobs 3` five rows were OOM-killed:
  SURELOG_CRASH -> SLANG_CRASH, which check_svtests counts as regressions.
  The law is therefore WITHDRAWN from this patch (the stage's status for
  these rows is SURELOG_CRASH either way); the master decides whether to land
  it with a serialized black-parrot run or a memory fix.
* `chapter-16/16.10--property-local-var(-uvm).sv`: 'assertion expr kind:
  SequenceWithMatch' is raised in ModuleEmit.cpp (sister ground).
* rsd (`member access base`) and rggen (`expression kind: Invalid`) are now
  accepted by this pass's laws (rsd stays SURELOG_CRASH, rggen BOTH_REJECT ->
  SLANG_ONLY).

## Census (predicted by trace before attribution)

`R11U401_TRACE` over the law sweep (all four stages): firings only of
§ bitsBlockLocalKeepsCall401 (111), § kwArrayMethodIsCallElem401 (5),
§ loneVarDeclStmtDropped401 (8), § unbasedUntypedElabKeepsLiteral401 (8), in
surelog ArrayMethodIterator, BuildUVMPkg, DecValue, MiniAmiq, Scoreboard,
Scr1SvTests, SeqDriver, SimpleUVM; uhdm2rtlil ibex_tracer,
ParameterWithUnderscoreValueDividedPassedFromCommandLine, struct_access; 15
probe cases (`evidence/firings.txt`). Every one is a non-moving firing: the
byte census reads 0 movers in all three corpora, so no corpus row and no probe
case can change; the positive control is the grid, where the same binary
moves 140 of 170 case-views.

Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2
(EXPECT_UNKNOWN=1 / 6) PASS on both csvs. Binary audit: the law sweep's
cmds.txt name the law binary 3273 times and pristine 0; the pristine sweep the
reverse (50 Surelog-only rows run no slang-uhdm).

## Residues (ranked by sv-tests rows)

1. basejump, 354 rows: the enum/unbased faces are cleared; the next head on
   313 rows is a module DEFINITION Surelog lists in allModules and we do not
   (modules whose parameters have no default, `BSG_INV_PARAM`, instantiated
   only under `if (0)` in `bsg_*__abstract`): UhdmExporter's uninstantiated-
   definition collection (sister ground, `addDefOnlyModule` /
   `uninstGenDefNames` in UhdmExporter.cpp). 31 more rows head at the
   weakly-referenced typespec tail order (uhdm-cmp names
   bsg_dramsim3_hbm2_8gb_x128_pkg's `num_rows_p` constant with RHS null).
2. module/class VARIABLE initializers dropped (5.6.4 macro_1, 6.24.1 cast_op,
   6.24.3 bitstream_cast, hdlconvertor_std2012_p148 class property, 5.9
   byte-array string): ModuleEmit's elaborated variable-initializer chain
   keeps only literal / call / pattern kinds (sister ground; repro
   `evidence/sister_faces/VI_module_var_init`).
3. associative-array index typespec span (14 STRICT_NOTEQUAL col(1) rows:
   `int arr [ int ];` golden 18:11-14, ours 18:10-15): TypeEmit (sister).
4. `$unit` parameters (number_test_2, _10, _11): X/Z case, '0 encoding,
   untyped sized literal — UhdmExporter's $unit parameter emission (sister;
   repro `evidence/sister_faces/NX_unit_param_xz`). The module-scope twin
   (`parameter int foo = 1'bx` elab constant size: golden 1 / 4, ours 32) is
   on this ground and open.
5. Surelog evaluates an untyped `'1` parameter as 1 in a later fold (PU/pu04
   `b = a & 3` golden UINT:1, ours 3).
6. include_file_info columns (22.4--include_via_define, 22.5.1--include-
   define-expansion): UhdmExporter (sister).
7. goal-1 rows now DIFFERENT, next faces: 15.5.x the implicit net `top`
   Surelog mints in the uninstantiated module (sister), p489 port net/var
   kinds (sister), class_member_test_27 the class_var listed twice
   (TaskFuncEmit, sister), 18.14 random-stability UVM order (sister).
8. PE/pe11 (a package localparam derived from a folded enum keeps INT where we
   write UINT), PE/pe17 (module import copy of the untyped enum parameter),
   CE/ce01-02 (class typedef listing, sister), SC (function-local parameter
   listing, TaskFuncEmit), MA (path element names).

## Sister-ground faces (reported, not written)

* UhdmExporter.cpp uninstantiated definition collection (`addDefOnlyModule`,
  `uninstGenDefNames`): modules without parameter defaults reached only from
  `if (0)` blocks are not listed (313 basejump rows).
* ModuleEmit.cpp elaborated variable initializer chain (`v->Expr(...)` branches
  near the struct-pattern var init): BinaryOp / Conversion initializers
  dropped.
* ModuleEmit.cpp `assertion expr kind` (SequenceWithMatch) rejection.
* TypeEmit.cpp associative index typespec span; UhdmExporter.cpp `$unit`
  parameters; UhdmExporter.cpp include_file_info columns; the column model
  `pp166` in UhdmExporter.cpp (this pass shifts string-macro lines through
  ExprEmit's own § strLitPpEscIdShift224 map instead).

## Process

* Builds `-j 2`; the pristine build equals the main tree's binary.
* sv-tests stages ran through the MAIN tree's `scripts/check_svtests.py`
  (read-only use; it resolves the UVM tree under the repo's third_party, empty
  in a worktree) with `SLANG_UHDM` set to the frozen binary; the four corpus
  stages through the worktree's `tests/sweep.sh`.
* SLIPS, no effect on any measurement: (1) a first pristine sv-tests stage was
  launched while the sister pass's svtests runner was live; it was stopped
  within a minute by PID after reading each command line (a `pkill -f` whose
  pattern matched only my own shell ended that shell; nothing of the
  sister's was touched); (2) an until-loop waiting on `pgrep -f` matched its
  own command line and was stopped by its task id; (3) early goal-1 runs used
  a worktree-relative UVM path (empty), so their uvm rows read BOTH_REJECT on
  both binaries; rerun with the absolute path; (4) the black-parrot single-job
  check overlapped the sister's sv-tests stage (memory only).
* Nothing written outside the worktree and /tmp/r11u401_*; no fenced test
  dispatched (sv-tests holds none; case.sh fails closed on $FENCED).
