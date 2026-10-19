# r11u407 — the sv-tests campaign's fourth pass on the expression/parameter ground

Implementer pass on base 83aee5dc (passes 401, 402, 404, 403, 406 and 405
landed), ground src/ExprEmit.cpp, src/EmitHelpers.h, src/StmtEmit.cpp,
src/ParamEmit.cpp.  Every law is `§ <name>407` read through
`lawOn(407, "R11U407_<LAW>_OFF")` (src/LawSwitch.h); `R11U407_OFF` drops all
of them; `R11U407_TRACE=<dir>` logs each firing through `lawTrace(407, ...)`.
No src/R*.h, no getenv, no reader function, include/ and EmitHelpers.h
unchanged.

Binaries: pristine 8d0c5ea76c7f7aa73467f92a108b3527 (equal to the main
tree's build/slang-uhdm at the base), final law binary
df7fcedb34229ff10ae18b610a33a2c3 (frozen before the sweep).  The pristine
reading is the master's control sweep at the base (/tmp/intr11u405, whose
csvs equal the committed results/*.csv); no pristine sweep was run.  Every
case line below carries the exit code.

## Verdict per targeted row (sv-tests, results/golden_svtests.csv -> the law sweep)

| row | before | after | law |
|---|---|---|---|
| chapter-9/9.4.2.4--event_sequence.sv | DIFFERENT | **EQUAL** | § seqEventCtrlRefDecl407 |
| chapter-16/16.10--sequence-local-var.sv | DIFFERENT | **EQUAL** | § assertLocalVarImplicitNet407 |
| chapter-16/16.10--sequence-local-var-fail.sv | DIFFERENT | **EQUAL** | § assertLocalVarImplicitNet407 |
| chapter-16/16.10--property-local-var.sv | DIFFERENT | DIFFERENT, dump distance 29 -> 20 lines; the rest is the property_decl's vpiVariables listing (sister) | § assertLocalVarImplicitNet407 |
| chapter-16/16.10--property-local-var-fail.sv | DIFFERENT | DIFFERENT, 29 -> 20 (same face) | § assertLocalVarImplicitNet407 |
| generated/tnoc/tnoc.sv | DIFFERENT | DIFFERENT; uhdm-cmp head moved from tnoc_pkg.sv 200:28 (is_valid_packet_type's enum reference) past 204:64 (is_request_packet_type's bit-select index) to 333:14 | § pkgRetEnumOperandFold407, § pkgRetBitSelParamFold407 |
| 16.10--property-local-var-uvm, 16.10--sequence-local-var-uvm, 16.11--sequence-subroutine-uvm | DIFFERENT | DIFFERENT (toward: 84916 -> 84913, 84896 -> 84893, 84896 -> 84893 dump lines; their head is the sister's UVM_ALL_ON copy) | § assertLocalVarImplicitNet407 |

The three conversions, quoted from the law sweep's csv (/tmp/r11u407_wd/svtests.csv):
`CONVERSION chapter-16/16.10--sequence-local-var-fail.sv: DIFFERENT -> EQUAL`,
`CONVERSION chapter-16/16.10--sequence-local-var.sv: DIFFERENT -> EQUAL`,
`CONVERSION chapter-9/9.4.2.4--event_sequence.sv: DIFFERENT -> EQUAL`.

## Gates (one five-stage sweep on the final law binary, workdir /tmp/r11u407_wd)

* probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0 conversions=0 changes=0.
* surelog: default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing),
  regressions=0 conversions=0 changes=0.
* uhdm2rtlil: 803 CMP_EQUAL + 1 CMP_NOTEQUAL (stamped_gen_param) + 67 SLANG_REJECT
  in both modes, regressions=0 conversions=0 changes=0.
* downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0 of 871,
  not identical and not excused 0.
* sv-tests (the worktree has no sv-tests sibling or UVM tree, so the stage ran
  through the main tree's scripts/check_svtests.py read-only, with the main
  tree still at the base 83aee5dc): EQUAL 1612 -> 1615, DIFFERENT 315 -> 312,
  STRICT_NOTEQUAL 13, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=3 changes=0.
* sweep exit code 0 (the law index current).
* canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); ctcan2
  PASS on both csvs (EXPECT_UNKNOWN=1 / 6).
* binary audit: 3313 fence-filtered corpus cmds.txt, 3263 name
  /tmp/r11u407_bin/law.bin, 0 another binary, 50 hold no slang line.
* byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law workdir vs
  the master's control /tmp/intr11u405, same-length names): surelog 2 of 962
  (Tnoc default and testflags), uhdm2rtlil 0 of 1608, downstream 0 of 805;
  the self-checks flag 961/962, 1607/1608, 804/805.
* PREDICTED BY NAME before the sweep: evidence/prediction_census.py scanned the
  6647 fence-filtered pristine databases of the control sweep (probe, surelog,
  uhdm2rtlil) for the two return-window shapes in uhdmtopPackages and found
  them in Tnoc default and testflags only (3 enum operands, 6 bit-select
  indexes each; evidence/prediction_census.tsv, positive control on cases
  EF/ef01, BS/bs01, BS/bs03); a fence-filtered source census for the x/z
  parameter law found only shapes whose literal width already equals the type
  width (param_x_default, scr1_ahb.svh, number_test_71) or a $unit parameter
  (number_test_10, its sv-tests row run alone: unchanged).  The sweep's trace
  (R11U407_TRACE) agrees: in the four corpus stages the laws fire on Tnoc
  default and testflags alone (pkgRetEnumOperandFold407 x3,
  pkgRetBitSelParamFold407 x6 each; evidence/trace_corpus.tsv), and these are
  the only byte movers; both rows stay CMP_NOTEQUAL with the same detail.
* sv-tests trace census (evidence/trace_svtests.tsv): the laws fire on 10 rows:
  the 3 conversions, the 2 property rows and the 3 UVM rows above (all toward
  golden, evidence/away.py), and tnoc (head moved later).  Away census 0.
* black-parrot (goal 1 (a)): bp_unicore alone with the law binary and pass
  403's guard on: exit 3 in 17.4 s, max RSS 822 MB (Python rusage); no
  memory-bounded export found, R11U403_MACROLITGUARD_OFF not lifted, the six
  rows stay SURELOG_CRASH.  generated/rsd/rsd.sv is SURELOG_CRASH: not this
  ground.
* goal 1 (c): every SURELOG_ONLY row of results/golden_svtests.csv (75) carries an
  upstream slang front-end diagnostic (`<file>:<line>:<col>: error: ...`:
  should-fail tests, 'design element does not have a time scale defined' on
  5 basejump rows and biquad_example, unknown modules in utd-sv, duplicate
  definitions, ibex-sim's unknown macro, the 5.6.2 keyword rows' 'expected a
  declaration name'); none names an exporter shape, so none is this ground's.

## The laws

| law | switch | site | what golden writes |
|---|---|---|---|
| § seqEventCtrlRefDecl407 | R11U407_SEQEVREF_OFF | StmtEmit emitEventExpr, EdgeKind::None branch | `@seq` / `@(seq)` naming a sequence declared in the enclosing scope, no argument list, is the event_control's condition: a ref_obj named after the sequence at its name, scoped under the reference's context, bound (vpiActual) to the listed sequence_decl (§ sequenceDeclListed406).  We wrote no condition.  Fires only when the declaration is already listed on an enclosing scope (a parent-chain walk) |
| § assertLocalVarImplicitNet407 | R11U407_ASSERTLOCALNET_OFF | ExprEmit emitExpr NamedValue | a read of a sequence/property declaration's LOCAL variable (`int x;` in the declaration) is a name Surelog's netlist elaboration cannot resolve: it mints the implicit module wire at the first reference (vpiNetType 1, no file) and binds the scoped ref_obj (`work@top.seq.x`) to it by name, like a property formal (emitPropFormalRef).  We wrote the ref_obj unbound and no net |
| § tpCastOverrideKeepsDefault407 | R11U407_TPCASTDEFAULT_OFF | ExprEmit, the cast-typespec branch of § tpCastBeforeTpListed405 | when the instance OVERRIDES the type parameter, golden's typespec of `T'(x)` in a value parameter's initializer is still the header DEFAULT (Surelog compiles the initializer in compileParameterDeclaration before the override binds): built from the header declarator with makeTypeParamDefaultTs (v11u405repro VE/ve01, decoded there and not landed) |
| § pkgRetEnumOperandFold407 | R11U407_RETENUMFOLD_OFF | StmtEmit Return | in a package's ELABORATED listing (uhdmtopPackages) a package subroutine's DIRECT `return` (the body's own statement or a member of its statement list) whose expression is an OPERATION is compiled under Reduce::Yes: every enum-constant reference among its operands, through nested operations, is the constant getValue builds from the enum value: the enum_const's value, size and decompile (an INT/UINT one its digits), at the reference, no typespec.  A bare `return A;`, a return inside an if/case, the definition listing, class methods and module functions keep the ref_obj |
| § pkgRetBitSelParamFold407 | R11U407_RETBSPARAM_OFF | StmtEmit Return | the same window reduces a bit_select's INDEX that names a parameter of the subroutine's own package (the bit_select the returned expression itself or an operand of its operations): a constant at the reference with the parameter's written literal (base, decompile) at the parameter type's width, a ref_typespec named after the bit_select onto a copy of the parameter's typespec (vpiInstance the package when typed) |
| § typedParamXzLitSize407 | R11U407_XZLITSIZE_OFF | ParamEmit, the elaborated Rhs constant | in a MODULE's ELABORATED listing a TYPED parameter whose default is a SIZED based literal with x/z digits keeps the literal's own width on its Rhs constant (`parameter int ma = 1'bx` vpiSize 1, `4'bz` 4, `logic [7:0] mc = 1'bx` 1) where we wrote the type's width; a known literal and an unbased-unsized one are resized as before |

## Grid (tools/probe/r11u407repro/cases, drivers/grid.sh; evidence/grid.txt)

36 case dirs in BS, EF, LV, SE, TD and XZ; goldens from the pinned Surelog
(`-parse -nobuiltin -nocache -sv dut.sv`), ours `dut.sv --single-unit
--nobuiltin`; every case exits 0 on both binaries.  20 NOT_EQUAL -> STRICT_EQUAL,
6 STRICT_EQUAL controls unchanged (BS/bs05, bs06, EF/ef04, ef06, ef07, ef08),
10 NOT_EQUAL on both: 6 moved toward golden by dump lines (BS/bs04 88 -> 77,
XZ/xz02 36 -> 32, XZ/xz04 8 -> 6, TD/td01 78 -> 76, TD/td03 81 -> 60, LV/lv05
29 -> 20) and 4 unchanged in bytes (TD/td02, SE/se04, SE/se06, EF/ef11); none
moved away, none left an equal status.  Each group's own switch restores
pristine's bytes and exit code on 36 of 36, and R11U407_OFF on 36 of 36.

| group | law | cases |
|---|---|---|
| SE | § seqEventCtrlRefDecl407 | se01 `@seq` in initial, se02 `@(seq)` in a named block, se03 `always @s1`, se05 in fork/begin: NOT_EQUAL -> STRICT_EQUAL; se04 (in a task: the task body is emitted before the sister's sequence listing, the law abstains), se06 (`@(seq(a))` with arguments: golden a func_call) residues |
| LV | § assertLocalVarImplicitNet407 | lv01, lv02 (two reads, one net), lv03 (two sequences, one name, one net), lv04 (a module variable of the same name) -> STRICT_EQUAL; lv05 (a property's local variable) toward, the rest the property's vpiVariables listing |
| TD | § tpCastOverrideKeepsDefault407 | td01 (v11u405 VE/ve01) and td03 toward; td02 (no override) control unchanged; next head: the parameter D's own typespec in the overriding instance (golden the default type again, ours an int_typespec at the `T` token) |
| EF | § pkgRetEnumOperandFold407 | ef01 (unsized based values, tnoc's shape), ef02 (sized), ef03 (auto-numbered: INT), ef05 ('h and 'd), ef09 (function never called), ef10 (task + ternary: only the return's operands fold), ef12 (an importing package's function) -> STRICT_EQUAL; controls ef04 (module function), ef06 (module reads), ef07 (bare `return A;` and a return inside if), ef08 (if/case conditions) unchanged; ef11 residue (a `p::A` qualified read: golden 8'h00 HEX in both listings, ours the existing UINT 0/64; a localparam of enum type in the operation: golden folds it with a typespec copied from the other operand's) |
| BS | § pkgRetBitSelParamFold407 | bs01 (tnoc's `!x[RB]` under &&), bs02 (untyped parameter: no vpiInstance), bs03 (bare `return x[RB]`) -> STRICT_EQUAL; controls bs05 (an assignment's rhs), bs06 (a part-select range) unchanged; bs04 toward: `x[RB-1]` golden folds the index expression to INT 6/64 spanning `RB` alone (not written) |
| XZ | § typedParamXzLitSize407 | xz01 (`parameter int ma = 1'bx`), xz03 (an instantiated child's default, an overriding sibling untouched) -> STRICT_EQUAL; xz02 toward (next head: the elaborated continuous assignment `ma + mb + mc` over x/z parameters, golden keeps the operation, we fold to UINT 0/32), xz04 toward (next head: `parameter int ma = 1'b1` golden INT:-1 (Surelog sign-extends the 1-bit literal), ours UINT:1) |

evidence/residue_cases/BK (no law landed, decoded only): `$bits` of a type in
a CLASS parameter (sv-tests generic/class/class_test_51.sv): golden folds to a
constant UINT, size 64 spanning `$bits` alone for a keyword argument
(`$bits(int)` 3:25-3:30) and the whole call for a typedef (`$bits(t_t)`), and
when the call is the whole initializer the parameter carries the value and an
int_typespec over the whole declaration plus a ref_typespec on the constant;
class_test_51 also needs the replication's `1'b1` written with no vpiParent.
A module localparam (bk03) is already STRICT_EQUAL.

## Residues (ranked; all wrong on pristine too)

1. tnoc's next head: tnoc_pkg.sv 333:14 `width += 1;` in get_flit_width, golden
   an unparented constant 241 (a Surelog function-evaluation artefact) where we
   write 1.
2. The two 16.10 property-local-var rows: the property_decl's vpiVariables
   listing (an int_var parented at an unlisted assignment) — ModuleEmit,
   sister's ground (below).
3. SE/se04, se06 (a sequence event in a task; with arguments), EF/ef11, BS/bs04,
   XZ/xz02, xz04, TD/td01-td03 as in the grid table.
4. class_test_51 ($bits in a class parameter, evidence/residue_cases/BK).
5. Not reached: passes 405's, 403's and 401's residue lists (VH/vh01..vh13,
   VS/vs07, SC/sc10-sc12, UB/ub02-ub03, VC/vc07..vc11, VR/vr01, VD/vd02-vd03,
   VU/vu01, VK/vk01-vk03, VH/vh02, VM/vm10, vm12, VA/va04, VE/ve03, PM/pm08,
   FE/fe06, ML/ml01, VL/vl03, the § loneVarDeclStmtDropped401 breadth, RS,
   PE, PU, AP/vs02, BT/vs06, CS/vs02, SM/vs02), p292 (a let call), p770,
   fx68k, scr1, the basejump computed-localparam rows and the 70 probe residues.

## Sister-ground faces (reported, not written)

Measured on the 177 non-UVM DIFFERENT / STRICT_NOTEQUAL rows rerun at the base
with the pristine binary (evidence/firstdiff_base_nonuvm.csv, drivers/fd3.py):

* ModuleEmit, the property declaration listing: the property_decl's
  vpiVariables (`int_var x` parented at an assignment) — chapter-16/16.10
  property-local-var and -fail, the last face after § assertLocalVarImplicitNet407.
* ModuleEmit, the order of emission: a task/function body is emitted before
  § sequenceDeclListed406 lists the sequences, so `@seq` inside a task cannot
  bind (SE/se04).
* ModuleEmit, the elaborated variable-initializer chain: a constant
  initializer is not truncated to a 1-bit target (chapter-10/10.4.1
  blocking-assignment: `logic a = 3` golden 1/size 1, ours 3), a string
  literal into an unpacked byte array lists no vpiExpr (chapter-5/5.9
  string-word-assignment), a type-parameter variable's initializer sized by the
  DEFAULT type (hdlconvertor_std2012_p88, std2017_p124: golden 16 for an
  overriding `int`).
* TypeEmit/ModuleEmit, the variable listing: `bit signed v` missing vpiSigned on
  the bit_var (generated/integers/6.11--integer_signed_bit).
* TypeEmit, macro-declared structs: `$bits(<enum>)` inside a struct declared
  through a macro is folded by golden (basejump bsg_cache_dma_to_wormhole,
  bsg_wormhole_to_cache_dma_fanout, bsg_wormhole_to_cache_dma_inorder, 69:50).
* TypeEmit, parenthesized cast names in generate blocks (basejump bsg_decode,
  bsg_round_robin_n_to_1, bsg_link_ddr_upstream, bsg_mesh_router_decoder_dor,
  bsg_nonsynth_ramulator_hbm: golden an unsupported_typespec named after the
  parameter), as pass 405 reported.
* TypeEmit, the class listings (the 14 generic/class and 8.26 rows), the
  $unit parameters (UhdmExporter: number_test_7, number_test_15), the 6.19
  enum_xx constant, p600's range bound and the UVM rows' UVM_ALL_ON copies,
  unchanged from pass 405's report.
