# r11u423 — expression/parameter ground, the twelfth sv-tests pass on this ground

Base 36240458 (pass 421). Ground: src/ExprEmit.cpp, src/EmitHelpers.h,
src/ParamEmit.cpp (StmtEmit.cpp unchanged). Pristine = the worktree build at
the base, md5 0620ec3fde41ca631002651bc458f79a (equal to the main tree's build
at the base); the pristine sweep reading is the master's control
/tmp/intr11u421. Final law binary: md5 fea31847620c7987ca44e928f34dbe9e.

## Result

| sv-tests row | before (base) | after | law |
|---|---|---|---|
| generated/scr1/scr1.sv | DIFFERENT | EQUAL | § decUnszElabRespellKeepsM1_423 |

Fresh csv row: `generated/scr1/scr1.sv,EQUAL,,equal` (control:
`generated/scr1/scr1.sv,DIFFERENT,decompile:,`). The scr1 head was
scr1_top_tb_axi.sv 21:59, `localparam TIMEOUT = 'd2000_000;`, whose
elaborated param_assign Rhs golden writes `INT:2000000` decompile `2000000`
size -1 and ours size 32 (pass 413's "unsized 'd localparam golden sizes at
-1, the distinguishing condition unknown"). The distinguisher, measured
(cases UD): the elaborated copy keeps -1 unless a continuous assignment reads
the parameter as its whole right-hand side, where Surelog shares that very
constant with the read and resizes it to the reader's width (golden parents it
at the cont_assign; ud02 / ud09, which ours already wrote).

The four testbenches rows the sister pass 422 reported for this ground
(uvm_agent_active, uvm_agent_passive, uvm_driver_sequencer_env,
uvm_monitor_env) stay DIFFERENT: on the base their head is pass 422's
derived-class order, and on base + pass 422 + this pass (binary c12,
evidence/runner_c12_on422.csv, evidence/testbenches_heads_on422.txt) the
ParamEmit/ExprEmit faces are gone and the head moves later in the walk to
TypeEmit's specialized class typespec (`uvm_resource#(TYPE)` at
uvm_resource_defines.svh 43:3 lacks golden's vpiParameter/vpiParamAssign;
sister ground, below). The faces this pass cleared on those rows, in walk order:
(1) the `uvm_field_*` macro's `case (local_op_type__) UVM_PRINT: ...` items in
a `$unit` class's `__m_uvm_execute_field_op`, folded constants with no
typespec where golden carries `ref_typespec (work@packet_in)` to
`uvm_field_flag_t`; (2) the same method's `(UVM_ALL_ON|UVM_HEX) & UVM_NOCOPY`
operands, golden `ref_typespec (work@packet_in::__m_uvm_execute_field_op)`;
(3) `UVM_RADIX` (`parameter UVM_RADIX = 'hf000000;`) read there, golden
size -1 and a ref_typespec with no actual, ours size 32 with the int_typespec.

The 16 uvm-examples rows pass 422 reported (`1<<16` copies): decoded, NOT
this ground. The `UINT:65536` / `1<<16` cells are the enum constants of the
re-listed `uvm_recursion_policy_enum` typedef (`UVM_DEEP = (1<<16)`) in the
importing user package's typedef listing, written by TypeEmit's enum_const
loop (evidence: messaging_pkg section, golden `UINT:65536` decompile `65536`,
ours `INT:65536` decompile `1<<16`); the rows' uhdm-cmp head itself prints
at the package pair (package listing). Sister ground, reported below.

Goal 1: no SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH row of
results/golden_svtests.csv carries an exporter message (0 rows read
`unsupported`); all 75 SURELOG_ONLY rows carry an upstream slang front-end
diagnostic, so no row moves on goal 1. The probe-only shapes
(evidence/residue_cases/g1a-g1c): `C::mk().arr[1]` exits 4 ('element select
base'), upstream slang 0, Surelog 3 (syntax error); `u.mk(x).a[2]` exits 4,
upstream slang 0, Surelog 3; `this.mk().inner.s` exits 0, upstream slang 0,
Surelog 3. Not forced (golden has no shape). Black-parrot: bp_unicore alone
with pass 403's guard on exits 3 in 19.7 s at 774 MB maxrss with the same
`basic_string::substr` error; no memory-bounded export found, guard standing.

## Laws (pass 423; switches through src/LawSwitch.h lawOn(423, ...), `R11U423_OFF` drops all; `R11U423_TRACE=<dir>` logs each firing)

1. § caseItemPkgFoldTsOps423 (EmitHelpers.h caseItemTsOps423, ExprEmit's
   pkg-param fold stamp; `R11U423_CIOPS_OFF`). § caseItemPkgFoldTs116's
   literal fence widened to an initializer built only of integer literals
   joined by unary and binary operators (`parameter f_t A = (1<<4)`): the case
   item is the getValue clone of the copy's Rhs and carries the declaration
   typespec as for a literal. A name, call, conditional, concat or select in
   the initializer stays fenced. Cases CI/ci18, ci21 (and with law 2 ci01,
   ci02, ci08). Note: its trace line is written when the fence admits the case
   item, before the unqualified / materialized-copy test; the four probe cases
   it logs (r11u114 f2/b12, v11u114 set1/q01, q04, q13, qualified `pk::P` or
   already stamped) are byte-identical to pristine.
2. § caseItemPkgFoldTsLate423 (EmitHelpers.h CiLateTs423, ExprEmit,
   ParamEmit drainShareDefParamTs; `R11U423_CILATE_OFF`). A parameter typed by
   a package VECTOR typedef defers its import copy's typespec past
   emitTypedefs (drainDefParamTs), so `importedParamDefTs` is empty for it
   while subroutine bodies compile and the case-item fold came out bare. The
   site records the constant, its compiling component and the reference name;
   the dead-last drain stamps a ref_typespec to the typespec of the first
   same-named imported param_assign copy walking up from that component (Rhs
   constant's typespec, else Lhs's); in a CLASS method the actual is golden's
   per-reference clone built by makeParamTs under the class name (named clone
   of the typedef whose alias reaches a bare clone instanced at the package,
   alias name joined with `::`). No copy found writes nothing. Cases CI/ci01,
   ci02, ci08, ci19.
3. § caseItemFoldClassOwner423 (ExprEmit, the § tfFoldCaseInsideBoundModule282
   site; `R11U423_CICLSOWN_OFF`). A class method's case item names the CLASS
   (`work@C`, `q::C`), not the subroutine: the clone hangs at the param_assign
   copy the class or its package lists. Case CI/ci21 (with law 1), ci01.
4. § clsTfOpFoldTsLate423 (ExprEmit, ParamEmit drain; `R11U423_CLSOPLATE_OFF`).
   The OPERAND half: a subroutine operand folded from a typed imported package
   parameter that § pkgImportTfOpFoldTs159 (class, package copies only) or
   § tfOpFold9 (module, `importedParamDefTs`) leave bare is recorded and
   stamped by the same drain, the reference named by the subroutine
   (`work@C::f`, `work@top.f`). Cases CO/co01-co04, co07; co05 moves toward
   golden behind an earlier head; co06 (a process) not reached.
5. § unszBasedPkgFoldUnsized423 (EmitHelpers.h unszBasedLit423, ExprEmit's
   pkg-param fold; `R11U423_UNSZFOLD_OFF`). A package parameter declared
   without a type, range or signing and initialized by an unsized based
   literal (`'hf000000`, `'d12`, `'b101`, not the `'b0`/`'b1` tokens) keeps
   size -1 on every fold read from an importing scope, and the fold's
   ref_typespec has no actual (the copy's Lhs carries none, § unsizedBasedParamRhsSize106).
   Cases US/us01-us03, us07; controls us04 (module parameter), us06 (sized,
   typed, ranged, `'b1`).
6. § decUnszElabRespellKeepsM1_423 (EmitHelpers.h decUnszElab423, ParamEmit's
   § unsizedBasedParamRhsSize106 drain; `R11U423_DECUNSZ_OFF`). The drain
   re-checked the written spelling and skipped the ELABORATED copy of an
   unsized DECIMAL default, which the instance respells `INT:<n>` decompile
   `<n>` (§ impCopyBasedDecKeep); golden keeps size -1 there unless the copy
   is the shared whole-RHS of a continuous assignment (parented at it). The
   law reaches only a respelled copy still parented at its param_assign.
   Cases UD/ud01, ud03, ud05, ud06, ud08, ud10; controls ud02, ud09.
7. § octUnszElabRespell423 (EmitHelpers.h octUnszElab423, ParamEmit drain;
   `R11U423_OCTUNSZ_OFF`). The octal twin: the elaborated copy of an unsized
   octal default is golden's decimal `UINT:<n>` decompile `<n>` at size -1
   (as § sizedOctElabRespell does for the sized spelling); ours kept `'o17`
   OCT. Signed spelling fenced. Cases UO/uo01-uo03 (uo02 with law 5);
   control uo04 (`'so17`).

No src/R*.h, no getenv, no reader definition; include/, TypeEmit, ModuleEmit,
UhdmExporter, TaskFuncEmit, StmtEmit and uhdm_main.cpp unchanged.

## Measurements (one full sweep on the final law binary, evidence/sweep_corpus.log, sweep_svtests.log)

Launched after three quiet readings; corpus stages through the worktree's
tests/sweep.sh, the sv-tests stage through the main tree's
scripts/check_svtests.py read-only with `--baseline` this worktree's base
results/golden_svtests.csv (a worktree has no UVM tree; the main tree's csv had
moved to pass 422's promotion).

- probe: EQUAL 4018, STRICT_NOTEQUAL 69, regressions=0 conversions=0
  changes=0; probe.csv byte-identical to the control's.
- surelog: default CMP_EQUAL 480, testflags 474, 0/0/0; the csv differs
  from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 both modes, 0/0/0; csv byte-identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  csv byte-identical to the control.
- sv-tests: EQUAL 1855, STRICT_NOTEQUAL 2, DIFFERENT 83, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0, conversions=1 (scr1), changes=0; the csv differs from the
  control's in that one row only (evidence/svtests_vs_control.txt).
- byteverify (SELFCHECK=1) law sweep against the control: 0 of 962, 0 of
  1608, 0 of 805 (evidence/byteverify.txt). PREDICTED BY NAME before the
  sweep: no corpus byte or exit-code mover — a fence-filtered source scan of
  both corpora found untyped unsized `'d`/`'o` parameters only in
  NyuziProcessor (SLANG_REJECT) and wav-lpddr (Lpddr, SURELOG_FAIL) and
  untyped unsized based package parameters only in NyuziProcessor and the
  1800.2-2017 UVM (`UVM_RADIX`, not in a corpus row's compiled source), and a
  traced run of the eleven key corpus rows (MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg, Earlgrey_0_1, Rggen, BlackBePipeInt, TypeParam,
  LogicTypespec, Scr1SvTests, both modes) logged no firing and read the
  baseline statuses.
- trace census (evidence/trace_census.tsv): no corpus row; four probe cases
  (law 1's fence line only, bytes identical, see law 1); nine sv-tests rows:
  scr1 (law 6), easyUVM/top and the seven testbenches rows uvm_agent_active,
  uvm_agent_passive, uvm_driver_sequencer_env, uvm_monitor_env,
  uvm_scoreboard_env, uvm_scoreboard_monitor_agent_env,
  uvm_scoreboard_monitor_env (laws 1, 2, 4, 5).
- away census on the eight firing rows still DIFFERENT
  (evidence/away_census.txt, path-normalized multiset distance golden vs
  control and golden vs law): all eight toward golden (easyUVM 502943 ->
  496684, uvm_agent_active 83860 -> 81599, the others -2261 each), 0 away;
  uhdm-cmp counts unchanged on easyUVM and the four agent/monitor rows (their
  head is pass 422's derived-class order on this base) and +452 on the three
  scoreboard rows, whose golden reads `LHS: <null>` at the design (uhdm-cmp
  prints our whole design, which now holds the stamped typespecs).
- canaries ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil);
  ctcan2 EXPECT_UNKNOWN=1 and =6 PASS.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the law
  binary (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740.

## Grid (drivers/grid.sh, evidence/grid_final.txt; 35 case dirs in CI, CO, UD, UO, US)

Every line carries the exit code (all 0). Pristine -> law: 24 NOT_EQUAL ->
STRICT_EQUAL (CI ci01, ci02, ci08, ci18, ci19, ci21; CO co01-co04, co07; UD
ud01, ud03, ud05, ud06, ud08, ud10; UO uo01-uo03; US us01-us03, us07), 7
STRICT_EQUAL controls byte-identical (ci11, ci12, ci13, ci20, ud02, ud09,
us04), 3 NOT_EQUAL controls byte-identical (co06, uo04, us06), co05 moved
toward golden behind an earlier head (cmp 76 -> 76, distance 474 -> 416).
`R11U423_OFF` restores pristine's bytes and exit code on 35 of 35; a single
switch restores pristine on every moved case except uo02 and us07, which need
`R11U423_UNSZFOLD_OFF` and `R11U423_OCTUNSZ_OFF` together (both laws fire);
ci01, ci02, ci08 are restored by either CIOPS or CILATE (the late record
needs the widened fence), ci21 by CIOPS (CICLSOWN alone renames a stamp
CIOPS still writes).

Downstream on the 29 class-free case dirs (drivers/ds.sh,
evidence/downstream_cases.txt): UO uo02 EQUIVALENT -> IDENTICAL, uo03
DIVERGENT -> IDENTICAL, US us02, us03, us07 EQUIVALENT -> IDENTICAL; none
worse.

Earlier-pass census (drivers/earlier.sh): of 3017 fence-filtered case dirs
under tools/probe/r11u4NN and v11u4NN (passes 401-422), 3016 unchanged (bytes
and exit code) and one moved: r11u413repro/evidence/residue_cases/UD/ud03
NOT_EQUAL -> STRICT_EQUAL (pass 413's scr1 TIMEOUT residue). The byte-control
grids r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124,
r11u125, r11u130, r11u131 and r11v131: 879 of 879 unchanged.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The 4 testbenches rows (above): next head TypeEmit's class_typespec
   parameters (sister). The 16 uvm-examples rows: TypeEmit enum consts
   (sister).
2. An untyped imported parameter (`parameter A = 16`, `= (1<<4)`) folded in a
   case item: golden stamps the declaration's int_typespec; § caseItemPkgFoldTs116
   requires a typed parameter (residue_cases ci04, ci15, ci16).
3. A class method assignment's right side reading a typedef-typed import
   (`x = A`, golden `ref_typespec (work@C)`; ci05) and a module process
   operand (co06; its head first at the port's imported typedef, ci09/ci17's
   `p::f_t` alias name, sister ground).
4. A class-method operand of an untyped `'d` package parameter: golden a
   ref_typespec with no actual, ours none (us05).
5. An enum-typed parameter as a class case item (ci07, golden INT:1 const 7
   with the enum typespec), a package class over a typedef-typed parameter
   (ci03, co05: head at the package's Rhs typespec), ci10 (a qualified case
   item's end line), ci14 (package copies of `~8'h0F`, `A + 1`).
6. An overridden unsized `'d` parameter (ud04) and a net-declaration
   initializer reading one (`wire [7:0] w = T`, golden 8, ours 32; ud07); the
   signed octal `'so17` (uo04).
7. The probe STRICT_NOTEQUAL rows r11u109repro f1 c04, c06, p06, p07: a
   64-bit size cast inside a struct parameter pattern member, golden `UINT:0`
   (the `1ULL << 64` mask of § srlgSizeCastUbShiftMask93), ours the operand;
   decoded, not written (the mask is applied only at the param_assign's
   top-level cast chain).
8. Carried: passes 421, 419, 417, 415, 413, 411, 409, 407, 405, 403, 401
   residues as listed in the brief (bitsKeep faces of v11u421 VB, hier-path
   `$clog2` names, labelled expect actions, uo18, vo08, vo02, vp05, the VA
   cases, vc02, ia17, tnoc 333:14, p733, fx68k, ...); none re-measured moved.

## Sister-ground faces (reported, not written)

- TypeEmit: a specialized parameterized class typespec (`uvm_resource#(TYPE)`
  in a `$unit` class method's block variable, uvm_resource_defines.svh 43:3)
  written without golden's vpiParameter type_parameter and vpiParamAssign —
  the 4 testbenches rows' next head on base + 422 + 423.
- TypeEmit, the enum_const loop of the enum typespec copy an importing package
  re-lists (`UVM_DEEP = (1<<16)`): golden `UINT:65536` decompile `65536`, ours
  `INT:65536` decompile `1<<16` — the 16 uvm-examples rows.
- TypeEmit emitSyntaxExpr, the TypeEmit half of § genBlockBitsKeepsSelect200:
  in a generate block's DEFINITION view `$bits(<signal declared outside the
  block>)` is golden's sys_func_call (`out_calib_code[($bits(out_calib_code)-1)
  -:(1+width_p)]`, bsg_source_sync_channel_control_master), ours folds it; the
  elaborated scope folds in golden at size 32 with no location (residue_cases
  gb01-gb03; gb04, gb06 other faces; gb05 control). An ExprEmit attempt
  reached only the elaborated view, the wrong one, and was withdrawn.
- ModuleEmit, the cont-assign system-call stamp (the `nm3` name list beside
  § genCaSysCallTsVarLhs22 and § ndaSysCallNetTs212): Surelog's
  UhdmWriter::writeCont_assign gives EVERY system function call that is the
  whole right side of an elaborated continuous assignment a ref_typespec to the
  left side's typespec (`$realtobits`, `$countones`, `$onehot`, `$rtoi`; p599;
  residue_cases nd01, nd03, nd04, nd06, nd07, nd08, nd10; nd02, nd09 controls;
  nd05 a variable initializer, another face).
- UhdmExporter / ModuleEmit: array-variable initializers `int tab1[5] = {...}`
  (18.14_1: class-property elements size 32 parented at the int_var; ai01; a
  module array variable's initializer missing, ai02); the design-level
  include_file_info list (six basejump rows); class_test_51's `$bits(int)` in a
  class parameter (emitClassParameters); typedef_test_9 and p600 typedef range
  bounds (TypeEmit); p179's `$unit` function class_var naming (TaskFuncEmit);
  the basejump definition-view generate statement faces (axi_mem's ternary
  operand, mem_1rw_sync_mask_write_byte_assoc's `(i` raw-text name,
  comm_link's `$clog2` in a typedef range).

## Process

Within the budget: no pristine sweep (the master's control); intermediate
binaries law1-law11 only on grids and runner calls on the targeted rows
(the 86 non-equal rows once on c7 = base + pass 422 + laws 1-5, the 13 rows
of evidence/runner_c12_on422.csv on c12 = base + pass 422 + the final
source); one full sweep on the final binary (law12). A combined worktree
(/tmp/wt_r11u423c, base + pass 422's verified src) was built only to read the
rows' heads above pass 422's ground; nothing of pass 422 is in this patch. The
fence list was read into a file by a program and never printed; every
tree-wide list was filtered on it before any file was opened. No other
agent's process touched. One law attempt (generate-block `$bits` of an outer
name, ExprEmit) was withdrawn before the sweep after its grid showed it hit the
elaborated view where golden folds.

## Files

cases/ (35 case dirs, each first line `// § <law>`), drivers/ (case.sh,
show.sh, grid.sh, ds.sh, earlier.sh, away.sh, gold.sh), evidence/ (sweep
logs, grid_final.txt, trace_census.tsv, away_census.txt, byteverify.txt,
downstream_cases.txt, earlier_cases_*.txt, svtests_vs_control.txt,
runner_c12_on422.csv, testbenches_heads_on422.txt,
heads_nonequal_on422_law7.txt, residue_cases/).
