# r11u432 — module/type ground, sv-tests campaign (pass 432)

Base eb8c9b78d. Pristine reading: the master's control sweep `/tmp/intr11u430`
(its csvs equal the committed `results/*.csv`); no pristine build of its own
and no pristine sweep (measurement budget, user 2026-10-18). Pristine binary
for case runs: the main tree's `build/slang-uhdm` at the base frozen at
`/tmp/r11u432_bin/pristine` (md5 60d3ffba6f056d6d32b8c5230a29b9c9; the
worktree's first build at the base reads the same md5). Final law binary
frozen at `/tmp/r11u432_bin/law19` (md5 6cdd7bbb6c34e655d223e9be62e95646,
the worktree build after the last source edit); the five-stage sweep ran on
`/tmp/r11u432_bin/law18` (md5 287b9a720f9d0fbdc6d8a130f7e37286), which
differs from law19 only in § caCallConcatArgFormalTs432's constant-only
abstention (see the sweep section). Both link slang 12.0.0+545f88b2e.
After the sweep two comment lines and a local flag's name in
src/TypeEmit.cpp were reworded by the standing word rule; the rebuild
`/tmp/r11u432_bin/law20` (md5 71ad50bd424b739ea3ce17f1f565bf40, 5 bytes from
law19 by `cmp -l`) writes law19's bytes on all 91 case dirs.

## sv-tests rows (before -> after, by path)

| row | before | after | laws |
|---|---|---|---|
| generated/hdlconv_std2017/hdlconvertor_std2017_p193_2.sv | STRICT_NOTEQUAL differ:line(3) | **EQUAL** | § tpProtoRetDefaultTs432, § unitOobBodyRefChainName432 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p600.sv | STRICT_NOTEQUAL differ:fullname(6) | **EQUAL** | § pkgVarEnumBaseRefName432, § impNetEnumSlotEnd432 |
| generic/class/class_test_49.sv | DIFFERENT | **EQUAL** | § clsParamCallArgPkgSel432 |
| generated/fx68k/fx68k.sv | DIFFERENT (head: fx68kAlu's `ccrCore[ CF]` reference unbound where golden binds the `$unit` CF) | DIFFERENT (three heads cleared; next head the elaborated port connection `.bAdd( (oper != OP_SBCD) )`, golden folds the parameter, see residues) | § unitParamShadowDefBind432, § caCallConcatArgFormalTs432, § unitParamSizeDimWide432 |

## The sweep (drivers/fullsweep.sh, workdir /tmp/r11u432sw1, trace on)

One five-stage sweep on law18, then the two stages the narrowed law fired in
rerun alone on law19 (`tests/sweep.sh --corpus "uhdm2rtlil downstream"`,
workdir /tmp/r11u432sw2), as the trace census allows: on law18
§ caCallConcatArgFormalTs432 fired in the corpora only on
TypedefedRangedFunctionArgument (uhdm2rtlil d/t and its downstream row) and
on sv-tests only on fx68k; no law of the pass fired on any surelog-corpus row.

- probe (law18): EQUAL 4019 + STRICT_NOTEQUAL 68 of 4087, regressions=0
  **conversions=1** changes=0: `CONVERSION r10uvm26repro/t36c
  STRICT_NOTEQUAL differ:fullname(6) -> EQUAL` (fresh row
  `r10uvm26repro/t36c,EQUAL,,equal`; the trace: § impNetEnumSlotEnd432 on
  `e_inline` and § pkgVarEnumBaseRefName432 on pk1::e_inline, pk2::e_inline,
  work@top.e_inline, p600's shapes). The csv differs from the control in that
  row alone.
- surelog (law18): default CMP_EQUAL 480, testflags 474, STRICT_NOTEQUAL 0
  (Tnoc d/t CMP_NOTEQUAL standing), regressions=0 conversions=0 changes=0;
  the csv differs from the control only in the two LowMem log-path texts.
- uhdm2rtlil: law18 read **regressions=2**, `TypedefedRangedFunctionArgument
  default/testflags CMP_EQUAL -> CMP_NOTEQUAL` (§ caCallConcatArgFormalTs432
  stamped `element_sum({32'h1234, 32'h5678})`'s concatenation of constants,
  where golden writes no typespec: the break, decoded on FA/fa14, fa20 and
  narrowed to concatenations with a non-constant operand, fa19 and fa21
  pinning the boundary). Rerun alone on law19: 803/1/67 in both modes,
  regressions=0 conversions=0 changes=0, csv identical to the control.
- downstream (law19 rerun): IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2,
  DIVERGENT 0 of 871, csv identical to the control (law18 read the same).
- sv-tests (law18; the main tree's scripts/check_svtests.py, read-only, the
  base's golden as baseline): EQUAL 1894, STRICT_NOTEQUAL 4, DIFFERENT 42,
  SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of
  2346; **regressions=0 conversions=3 changes=0**:
  - `CONVERSION generated/hdlconv_std2017/hdlconvertor_std2017_p193_2.sv: STRICT_NOTEQUAL -> EQUAL` (fresh row `generated/hdlconv_std2017/hdlconvertor_std2017_p193_2.sv,EQUAL,,equal`)
  - `CONVERSION generated/hdlconv_std2017/hdlconvertor_std2017_p600.sv: STRICT_NOTEQUAL -> EQUAL` (fresh row `generated/hdlconv_std2017/hdlconvertor_std2017_p600.sv,EQUAL,,equal`)
  - `CONVERSION generic/class/class_test_49.sv: DIFFERENT -> EQUAL` (fresh row `generic/class/class_test_49.sv,EQUAL,,equal`)
  law19 on the targeted rows (fx68k, class_test_49, p193_2, p600): the same
  verdicts, fx68k's path-normalized dump identical to law18's.
- The trace census (evidence/trace_census.txt): the laws fire on t36c, the
  uhdm2rtlil row above (law19: an abstention line only), and on sv-tests on
  p193_2, p600, class_test_49, fx68k, rsd (SURELOG_CRASH, unchanged) and
  hdlconvertor_std2012_p154_1 / hdlconvertor_std2017_p190 (EQUAL on both: the
  `$unit` body laws visit two bodies and change 0 objects).
- byteverify (SELFCHECK=1, against the master's control /tmp/intr11u430):
  surelog (law18) 0 of 962, uhdm2rtlil (law19) 0 of 1608, downstream (law19)
  0 of 805, every self-check flagging n-1 of n.
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil), changed 0; ctcan2 PASS with
  EXPECT_UNKNOWN=1 and 6.
- binary audit: surelog 1531 of 1581 cmds.txt name law18 (the other 50 hold
  only a Surelog line), uhdm2rtlil 1742 of 1742 name law19, sv-tests 2346 of
  2346 name law18.
- The corpus stages' exit 1 on the stale law index alone; tests/LAWS.md
  regenerated after the README, `--check` current.

## Goal 1

`results/golden_svtests.csv` at the base: 75 SURELOG_ONLY + 303 BOTH_REJECT,
no SLANG_CRASH; the detail column carries no exporter message (nothing names
"unsupported"); every SURELOG_ONLY detail is an upstream slang front-end
`error:` diagnostic, as passes 406 to 430 measured. Nothing on this ground;
the exit-4 backlog shapes of the brief (chandle arrays and aliases, vc13,
vy02, vu02, aq09, va09, ac04/ac05, the multi-dimension typedef uses, the
event arrays, the union shapes) were not written by this pass.

## Laws (each behind its own switch read through src/LawSwitch.h; `R11U432_OFF` drops all; `R11U432_TRACE=<dir>` logs every firing)

1. **§ tpProtoRetDefaultTs432** (`R11U432_TPRETTS_OFF`; src/TaskFuncEmit.cpp,
   at the return variable's typespec). The class-body PROTOTYPE of an `extern`
   method returning the class's TYPE PARAMETER (§ tpRetOobRefVar424's ref_var)
   references the type parameter's DEFAULT typespec, the object the class's
   type_parameter references: `class C #(type T = int); extern static function
   T f();` golden int_typespec 1:31-1:34 at `int`, ours a fresh one at the `T`
   token (p193_2's line(3)); a typedef default keeps its alias (TP/tp06), a
   `logic [3:0]` default its range. Cases TP/tp01, tp04, tp06, tp07, tp08 (to
   STRICT_EQUAL, tp04 to its next face); tp05 (an in-class method) control;
   tp03 (`return '0` sized to T where golden keeps '0 unsized) residue.
2. **§ unitOobBodyRefChainName432** (`R11U432_UNITOOBREF_OFF`;
   src/TaskFuncEmit.cpp, after the body of a `$unit` class's out-of-body
   function listed on the design, § unitOobFuncOnDesign402). Golden stores no
   full name on the body's references: the reader synthesises `C::f.q` from
   the parent chain, joined by `.` since no package or class lies on it, where
   ours stored `C::f::q` (joinRef's scoped-root rule). The references (and the
   selects, bit_select being a ref_obj) under `C::f::` keep no full name; the
   declared objects (a named block, its variable, their typespec references)
   read the chain spelled out, `C::f.blk.y`. Cases TN/tn01, tn03, tn04, tn05,
   tn06, tn09, tn10, tn12 to STRICT_EQUAL; tn07 (a package-homed definition,
   `pk::C::f::q` in golden) and tn08, tn11 (tasks, unlisted) controls; tn13
   residue (see below).
3. **§ unitOobBodyArgRefUnbound432** (`R11U432_UNITOOBARG_OFF`; the same
   site). In that body a reference to one of the function's own arguments or
   locals carries no actual in golden (TP/tp02 `return a;`, TN/tn02 a local
   `int x`), and a call of another design-listed `$unit` out-of-body function
   keeps no vpiFunction (TN/tn10 `g()`). Cases TP/tp02, TN/tn02 (and the
   co-firing tn03, tn09, tn10, tn12).
4. **§ pkgVarEnumBaseRefName432** (`R11U432_ENUMBASENAME_OFF`;
   src/UhdmExporter.cpp, design-final in `final287`). A PACKAGE variable
   declared with an inline anonymous enum (`enum {A, B, C = 99} X;`) carries
   its enum's base ref_typespec named after the variable (golden `A::X`), as a
   module's own variable already does, and so does the elaborated copy an
   importing instance lists; several declarators of one declaration
   (`enum {A, B} X, Y;`, keyed by the first enum constant's location) all read
   the LAST declarator's name (golden `A::Y`). p600's fullname(4). Cases
   EB/eb02 to STRICT_EQUAL (and the co-firing import cases); eb05 (a module
   variable) and eb06 (a typedef) controls.
5. **§ impNetEnumSlotEnd432** (`R11U432_IMPENUMSLOT_OFF`; src/ModuleEmit.cpp
   emitImportedPkgVarNets). The module's re-created typespec of an imported
   package variable declared with an inline anonymous enum takes writeNets'
   end-only populate as a module's own definition net does
   (§ defNetEndOnlyLoc130): `<file> 0:0` to the end of the packed slot, the
   SECOND member with no base type, the FIRST with one (golden EB/eb01
   `dut.sv 0:0-3:10`, eb03 3:13). p600's file(2)/endline(2)/endcol(2). A
   declarator with an initializer or an unpacked dimension, a `var`
   declaration and a one-member enum abstain. Cases EB/eb01, eb03, eb07,
   eb08, eb09, eb10 to STRICT_EQUAL; eb04 (an explicit base, other faces)
   closer.
6. **§ clsParamCallArgPkgSel432** (`R11U432_CLSCALLARG_OFF`;
   src/TypeEmit.cpp emitSyntaxExpr, set by src/UhdmExporter.cpp
   emitClassParameters around a class parameter's initializer: THE FLAG
   WRITTEN ACROSS FILES, `classParamRhs432()`, defined in TypeEmit and read
   only by emitSyntaxExpr's call, package-select and bit-select branches). In a
   CLASS parameter's initializer: a call is located at its callee node (the
   name; `pkg::` for a qualified call) and bound to the subroutine it names
   (golden CP/cp02 `func_call f` 7:18-7:19 with vpiFunction the `$unit` f), a
   call written as another call's argument keeps its whole span (cp12); a
   package parameter read with ONE bit select (`glb::arr[N]`) is a bit_select
   named by the qualified base, storing it as its own full name, located at
   the index expression (pass 40's residue R2), its index reference storing
   no full name; as a call argument the bit_select is parented at the package
   parameter, so the index reads `glb::arr::N` (cp01, cp06 to cp08), under an
   operation `work@C::N` (cp04); an unqualified bit select written as a call
   argument is located at its index too (cp13, cp18). Cases CP/cp01 to cp08,
   cp11 to cp16 to STRICT_EQUAL; cp09, cp10 controls; cp17, cp18, cp19 (class
   localparams typed by an unpacked array or a vector: the class parameter's
   own typespec, other faces) unequal on both, cp18 closer.
7. **§ unitParamShadowDefBind432** (`R11U432_UNITSHADOW_OFF`;
   src/UhdmExporter.cpp, `final287`). In a module's DEFINITION view a
   reference to the module's own parameter whose name a `$unit` parameter also
   carries binds to the `$unit` parameter (golden UP/up03 `localparam CF = 0;
   module m; localparam CF = 1; assign o = a[CF];` ref_obj CF -> the design's
   CF; fx68kAlu's `ccrCore[ CF]` against fx68k.sv's `localparam CF = 0`),
   where ours left it unbound as for an unshadowed module parameter (up04,
   golden unbound too). Only an unbound reference named like both a
   parameter of the module and a design-level parameter. Cases UP/up03, up05,
   up07 to up11 to STRICT_EQUAL (a continuous assignment, an always_comb, a
   localparam initializer, a case statement, a function body, a parameter
   port, an instantiated module); up01, up02, up04, up06 controls; up12 (a
   NET of that name, golden binds it too and folds the elaborated read)
   residue.
8. **§ caCallConcatArgFormalTs432** (`R11U432_CACONCATARG_OFF`;
   src/UhdmExporter.cpp, `final287`). In a module's DEFINITION view a
   concatenation written as an argument of a function call that is a
   continuous assignment's WHOLE right side carries the FORMAL's typespec
   (golden FA/fa01 `assign y = f({op[8:6], op[11:9]});` the operation's
   ref_typespec `work@m` -> the logic_typespec of `input [5:0] b`, non-ANSI and
   ANSI formals alike). A call under an operation (fa07: an intermediate
   draft walked into operations and moved fa07 away, narrowed before any
   sweep), a procedural call (fa04), another operation kind (fa03 `+`, fa06
   `~`), a replication (fa10) and the elaborated view carry none in golden
   either, and neither does a concatenation of constants only (fa14, the
   uhdm2rtlil corpus test TypedefedRangedFunctionArgument, and fa20: the
   first sweep's two regressions, narrowed before the stage reruns; fa21 with
   one constant operand stamps). Every formal type measured stamps: a
   typedef (fa13), a typedef packed array (fa19), bit, int, a two-dimension
   logic and reg (fa15 to fa18). Cases FA/fa01, fa02, fa05, fa08, fa12, fa13,
   fa15 to fa19, fa21 to STRICT_EQUAL; fa03, fa04, fa06, fa07, fa09 (a
   generate block), fa10, fa11 (a net declaration assignment), fa14 controls;
   fa20 (its elaborated fold BIN:1010 against our UINT:10) residue.
9. **§ unitParamSizeDimWide432** (`R11U432_UNITDIMWIDE_OFF`; src/TypeEmit.cpp,
   the size-form unpacked dimension builder). A `$unit` parameter initialized
   by a plain decimal literal folds into a size-form dimension as a PACKAGE
   parameter does (§ dimFoldTsQualifiedOrSignedModPar26's package row):
   untyped at sixty-four (golden UD/ud01 `reg [7:0] nRam[NANO_DEPTH]` the
   right bound's operand UINT:336 at size 64, ours 32) and never stamped with a
   typespec unqualified (ud05 `localparam int D`). A sized initializer
   (`4'd9`, ud07: golden INT:9 at size 4) abstains. Cases UD/ud01, ud03 to
   ud06, ud08 to STRICT_EQUAL; ud02 (a module parameter) control; ud07
   residue.

No src/R*.h, no LawState.h section, no getenv, no reader definition; every
law has its lawTrace call; ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit,
include/ and uhdm_main.cpp unchanged.

## The grid (82 case dirs in CP, EB, FA, TN, TP, UD, UP; drivers/grid.sh, evidence/grid.txt)

Every case accepted by upstream slang (`~/.local/bin/slang dut.sv
--single-unit`), every exit code 0 on both binaries. Pristine -> law:
45 NOT_EQUAL -> STRICT_EQUAL, 15 STRICT_NOTEQUAL -> STRICT_EQUAL, 2
STRICT_NOTEQUAL on both (TP/tp04 line -> fullname, objects 4 -> 3; TN/tn13
fullname 4 -> 4), 8 NOT_EQUAL on both (TP/tp03, CP/cp18 and EB/eb04 closer by
dump distance 13 -> 10, 69 -> 59, 63 -> 61; CP/cp17, cp19, UD/ud07, UP/up12
and FA/fa20 byte-identical to pristine), 21 STRICT_EQUAL controls
byte-identical; 91 case dirs in all. `R11U432_OFF` gives pristine's bytes and exit code on 91 of 91;
each case's own switch alone restores pristine on 77, the other 14 needing a
co-firing switch (the seven EB import cases with § pkgVarEnumBaseRefName432,
TN/tn02, tn03, tn09, tn10, tn12 and TP/tp01, tp02 with the other `$unit` body
law or § unitOobBodyRefChainName432). Downstream (drivers/dsgrid.sh,
evidence/dsgrid.txt) on the 51 class-free cases (EB, FA, UD, UP): 50
IDENTICAL on both binaries, UP/up12 DIVERGENT on both (its residue), none
worse.

## Process

- The implementer: intermediate binaries law1 to law17 on case runs and
  targeted runner calls only (the p193_2/p600 rows, class_test_49, fx68k,
  easyUVM and uvm_scoreboard_env), one full five-stage sweep on law18 with the
  trace on; its uhdm2rtlil stage read two regressions, the law was narrowed
  (law19) and the two stages the trace shows it fired in were rerun alone,
  with fx68k (the one sv-tests row it fired on) rerun by a targeted runner
  call: no second full sweep.
- Slip, affecting no measurement: one targeted runner call (two small rows,
  p193_2 and p600 on law6) ran while the master's pass 427 integration sweep
  (`/tmp/intr11u427`) was live, since its launch did not check the process
  list first; every later build, grid batch and runner call waited for a zero
  process count (drivers/quiet.sh) except one: the law19 uhdm2rtlil +
  downstream stage rerun started while the sister r11u429's targeted
  svtests_matrix call was live (the check printed it and did not wait); both
  stages read their baselines exactly, neither has a time-sensitive row.
- The fence list was never read: no tree-wide reader ran in this pass (the
  only corpus reads are the harness stages).
- The PF residue cases (the elaborated port-connection fold) are kept as text
  under evidence/residue_cases, not as case dirs, since no law of this pass
  claims them.

## Residues (all wrong on pristine too, none moved away)

Ranked by the rows they hold.

1. **fx68k's next head (this ground's carried residue, pass 421's and 424's
   "elaborated port-connection folds")**: the elaborated child port's
   high_conn `.bAdd( (oper != OP_SBCD) )` keeps a ref_obj where golden folds
   the parameter to a constant (UINT:6 at 64 for a `$unit` parameter, at 32
   for a module localparam); measured on five shapes kept as text under
   evidence/residue_cases (PF_pf01 to pf05: parenthesized or not, `!=` and
   `+`, `$unit` and module parameters). Every pf case is NOT_EQUAL on
   pristine too. Site: ModuleEmit's elaborated port connection (emitInstance's
   high_conn), the operands built by ExprEmit's bound-expression emitter.
2. **The `$unit` out-of-body function called statically from a module**
   (TP/tp04, TN/tn13): golden names the design-listed function
   `work@top.C::f` (its return variable and typespec reference too) and its
   body references `work@top.C::f.q`, ours `C::f` and `C::f.q` (§ unitOobFuncOnDesign402's
   naming; a method call `c.f(1)`, tn12, keeps `C::f` in golden).
3. **The 3 scoreboard testbench rows** (uvm_scoreboard_env,
   uvm_scoreboard_monitor_agent_env, uvm_scoreboard_monitor_env): golden's
   design is EMPTY (uhdm-cmp `LHS: <null>` at the design itself); nothing an
   exporter can follow. **easyUVM**: golden's class_defn work@sequencer lists
   UVM's `$unit`-level variables (`uvm_aa_string_key` uvm_pkg.sv-included
   :239, `m_uvm_core_state` :713) as the class's own variables; not decoded
   further.
4. **p719** (nested module definitions, 498 normalized dump lines): golden
   names a nested instance's gates `work@dff_nested.work@dff_nested::ff1.g1b`
   and binds their terminals to nets minted in the nested instance
   (`work@dff_nested.i1.nq1`); not written.
5. **Class parameters typed by an unpacked array or a vector** (CP/cp17,
   cp18, cp19: `localparam int a[3] = '{1,2,3}`, `localparam logic [7:0] v`):
   the class parameter's own typespec, value and range (golden an
   array_typespec with a `[0:2]`-style range and a logic_typespec 3:14-3:25,
   ours an int_typespec over the whole declaration); UhdmExporter
   emitClassParameters, not written.
6. **A `$unit` parameter shadowed by a module NET** (UP/up12): golden binds
   the net's references to the `$unit` parameter and folds the elaborated
   read `assign o = CF;` to the parameter's value; downstream DIVERGENT on
   both binaries. Not written (a net shadow is a Surelog misbinding the
   corpus never shows).
7. **A sized `$unit` initializer in a size-form dimension** (UD/ud07,
   `parameter D = 4'd9`): golden INT:9 at size 4, ours UINT:9 at 32 on both.
8. **tp03**: `return '0;` in the out-of-body body of a method returning a
   `logic [3:0]` type parameter: ours sizes the literal to 4 (`0000`), golden
   keeps `'0` at size -1 (sister's StmtEmit/ExprEmit, below).
9. **fa20**: the elaborated fold of `f({3'd1, 3'd2})` reads BIN:1010 in
   golden, UINT:10 in ours (the sister's ExprEmit constant fold).
10. **p203, p334, p130, p733, p737, tnoc, the 16 uvm-examples rows, the 4
   testbenches rows at type(1), the basejump placeholder rows and the
   carried lists of passes 430 and earlier** stand as their READMEs decode
   them (the exit-4 shapes, p719, the UVM listing faces, dpi_rom, the
   inv-placeholder rows).

## Sister-ground faces (reported, not written)

- tp03's `return '0;` sized to the type parameter's default width
  (`'0` -> `0000`, size 4) in a class method's out-of-body body, where golden
  keeps the unsized `'0` (size -1): the return statement's expression
  (StmtEmit's return_stmt / ExprEmit's conversion of an unbased unsized
  literal).
- fa20's elaborated fold of a constant concatenation argument
  (`f({3'd1, 3'd2})` -> golden BIN:1010 size 4, ours UINT:10): ExprEmit's
  constant fold of the call.
- fx68k's elaborated port-connection fold (residue 1): the operand
  expressions come from ExprEmit's bound emitter, the high_conn placement from
  ModuleEmit; the fold decision is not written on either side yet.
- The carried faces of pass 430 (ParamEmit makeParamTs and bsg_mul_pipelined,
  ExprEmit's `-a` UINT fold, the radix-enum cast behind the 4 testbenches
  rows and the 16 uvm-examples rows) are unchanged.
