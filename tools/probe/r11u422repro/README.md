# r11u422 — module/type ground, the sv-tests campaign's eleventh pass on this ground (pass 422)

Base 5b736803 (pass 420). Production files: src/ModuleEmit.cpp,
src/UhdmExporter.cpp. Every law reads its switch through src/LawSwitch.h
(`lawOn(422, "R11U422_<LAW>_OFF")`); `R11U422_OFF=1` drops all ten;
`R11U422_TRACE=<dir>` logs each firing through `lawTrace(422, ...)`.

## Laws

1. § arrayElemConcatConnWhole422 (ModuleEmit, emitInstance's high-conn chain;
   R11U422_ELEMCONCAT_OFF). A module-array element's named connection written
   as a concatenation or replication is the whole written expression, bound
   in the instantiating scope, its refs named through the element and the
   formal (work@top.c[0].a.en) and bound to the definition-view net twin
   where the expression writer bound them (left unbound where it did not, a
   generate scope). Was: exit 4 'element select base' (replication) or the
   slice's last operand. Cases IA/ia01 to ia12 (ia07 positional: not reached;
   ia10 a scalar-instance control).
2. § arrayBcastConcatBound422 (ModuleEmit, emitModuleArray;
   R11U422_BCASTBIND_OFF). The module_array's broadcast concatenation
   (§ arrayBcastConcatActual420) binds its refs to the instantiating scope's
   nets, its bit-select operands span their index, and a replication's count
   constant has no parent. Cases IA.
3. § arrayBcastConcatOneBit422 (ModuleEmit, emitModuleArray;
   R11U422_BCASTONEBIT_OFF). § arrayBcastConcatActual420 also holds when
   slang's slice of the representative element is a single written operand
   (a NamedValue). Cases IA/ia01, ia09, ia11.
4. § arrayElemReplCountFold422 (ModuleEmit, inside law 1;
   R11U422_REPLCOUNT_OFF). In the element copy a non-literal replication
   count ({N{en}}) is folded to an unparented constant at the count's span
   (UINT:4, size 32 for an untyped parameter); the broadcast keeps the ref.
   Case IA/ia05.
5. § unnamedUdpInstName422 (ModuleEmit, the primitive listing and
   buildGate; R11U422_UNNAMEDUDP_OFF). An unnamed udp instance is named after
   its definition: definition view full name work@dff.posdff_udp and NO
   terminals; elaborated view vpiName posdff_udp, full name
   work@dff.posdff_udp. Cases UU/uu01, uu03 to uu06 (uu02 a named control).
6. § specifyRefNoDefNet422 (ModuleEmit, collectDefBoundNames;
   R11U422_SPECIFYNET_OFF). A specify block binds nothing in the definition
   view: an implicit net named only there gets no definition-view net.
   Cases IN/in01, in09, in10 (in02 to in08 controls).
7. § strNetRefMintsNet422 (ModuleEmit, the module definition and elaborated
   net listings; R11U422_STRNETMINT_OFF). A strength-dropped net
   (§ caNetDeclStrengthDropped90) is minted back as an implicit wire: in the
   definition view at the first continuous-assignment, procedural or named
   port-connection reference, in the elaborated view at the first gate
   terminal or named port-connection reference, listed after the declared
   nets in the order of their minting references, binding the references.
   Any other reference abstains. Cases SD/sd01 to sd09 (sd10 a generate-block
   abstention control).
8. § derivedClassFullNameOrder422 (UhdmExporter, drainPendingExtends;
   R11U422_DERIVEDORDER_OFF). vpiDerivedClasses lists derived classes in the
   order of their FULL names (uvm_pkg::uvm_sequence_library before work@C).
   Cases DC/dc01, dc02, dc05, dc06 (dc03, dc04 controls).
9. § unitChandleTd422 (UhdmExporter, the $unit typedef listing;
   R11U422_UNITCHANDLETD_OFF). A $unit `typedef chandle ch_t;` is a
   chandle_typespec named like the typedef at the `chandle` keyword,
   parented and Instanced at the design (was exit 4 'typedef target:
   CHandleType', the v11u414 case VH/vh06). Cases CH/ch02, ch04.
10. § classChandleTdPropBareLogicVar422 (UhdmExporter, emitClassDefn's
    property loop; R11U422_CHANDLETDPROP_OFF). A class property typed by a
    chandle typedef is a bare logic_var with no typespec. Cases CH/ch01,
    ch03, ch05, ch06.

## sv-tests rows (base golden results/golden_svtests.csv at 5b736803)

| row | before | after | law(s) |
|---|---|---|---|
| generated/utd-sv/utd-sv_std-7.1.6-primitives.sv | DIFFERENT | EQUAL | § arrayElemConcatConnWhole422, § arrayBcastConcatBound422, § arrayBcastConcatOneBit422 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p884.sv | DIFFERENT | EQUAL | § unnamedUdpInstName422, § specifyRefNoDefNet422 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p827.sv | DIFFERENT | EQUAL | § strNetRefMintsNet422 |
| generated/uvm_classes_0/uvm_component_class_0.sv | DIFFERENT | EQUAL | § derivedClassFullNameOrder422 |
| generated/uvm_classes_2/uvm_component_class_2.sv | DIFFERENT | EQUAL | § derivedClassFullNameOrder422 |
| generated/uvm_classes_3/uvm_component_class_3.sv | DIFFERENT | EQUAL | § derivedClassFullNameOrder422 |
| testbenches/uvm_sequence.sv | DIFFERENT | EQUAL | § derivedClassFullNameOrder422 |
| generated/uvm_classes_1/uvm_component_class_1.sv | DIFFERENT | STRICT_NOTEQUAL differ:value(3) | § derivedClassFullNameOrder422 (the remaining face is ParamEmit's, the 7 sibling rows' one) |

The uvm rows' uhdm-cmp head at the base was uvm_sequence's (uvm_component's,
...) vpiDerivedClasses order: golden `[uvm_pkg::uvm_sequence_library,
work@C]`, ours `[work@C, uvm_pkg::uvm_sequence_library]` (Surelog's class map
is keyed by full name; ours sorted by bare name).

Goal 1: the detail column at the base holds no exporter error on any
SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH row (0 rows read 'unsupported'; all
75 SURELOG_ONLY rows carry an upstream slang front-end diagnostic), so no
sv-tests row moves on goal 1. The probe-only exit-4 shapes: IA/ia03 (pass
420's module-array replication, 'element select base') exits 0 STRICT_EQUAL;
the v11u414 case VH/vh06 ($unit `typedef chandle`, 'typedef target:
CHandleType'; its text is case CH/ch01) exits 0 STRICT_EQUAL; vh04 (chandle
array class property), vc13 (module typedef of a class used in an array:
golden's class_typespec c_t spans 5:11-6:13), vy02, vu02 and aq09 still exit
4 (not written).

## Measurements (final binary law19, md5 0542fc402d08d349f984ac9ea1af89b1)

Pristine = the worktree build at the base, md5 c9ef73f8cb6af6970663ee549c1b65aa
(= the main tree's); the pristine sweep reading is the master's control
/tmp/intr11u420. One full five-stage sweep on law19 (evidence/sweep_corpus.log,
evidence/sweep_svtests.log; the sv-tests stage through the main tree's
scripts/check_svtests.py read-only with `--baseline` the worktree's base
results/golden_svtests.csv, since the main tree had moved to pass 419):

- probe: EQUAL 4018, STRICT_NOTEQUAL 69, regressions=0 conversions=0
  changes=0; probe.csv byte-identical to the control's.
- surelog: default CMP_EQUAL 480, testflags 474; regressions=0
  conversions=0 changes=0; the csv differs from the control only in the two
  LowMem log-path texts.
- uhdm2rtlil: 803/1/67 both modes, 0/0/0; csv byte-identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  csv byte-identical to the control.
- sv-tests: EQUAL 1849, STRICT_NOTEQUAL 12, DIFFERENT 79, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0, conversions=8 (the table above), changes=0.
- byteverify (SELFCHECK=1) law sweep vs control: surelog 3 of 962
  (Scoreboard default, SimpleUVM default and testflags), uhdm2rtlil 0 of
  1608, downstream 0 of 805. The three movers are exactly the corpus rows on
  which the trace logs § derivedClassFullNameOrder422 (evidence/
  trace_census.tsv); their normalized dumps differ from the control only by
  the position of the user class's extends class_typespec in the
  weakly-referenced tail (later, where golden also has it near the end);
  status CMP_EQUAL and strict equal unchanged. They were not predicted by name
  before the sweep (the trace was the instrument); no other law fired on any
  corpus row or probe case.
- canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); ctcan2
  EXPECT_UNKNOWN=1 and =6 PASS.
- the five corpus UVM rows on law17 (the order law already in):
  BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM d/t and Scoreboard d CMP_EQUAL
  strict equal (evidence/corpus_uvm5_law17.csv).
- determinism: three concurrent draws of SimpleUVM default (one hash, equal
  to the sweep's) and of testbenches/uvm_sequence (one hash).
- trace census over the sweep: § arrayElemConcatConnWhole422,
  § arrayBcastConcatBound422 and § arrayBcastConcatOneBit422 on utd-sv only;
  § unnamedUdpInstName422 and § specifyRefNoDefNet422 on p884 only;
  § strNetRefMintsNet422 on p827 only; § derivedClassFullNameOrder422 on 153
  databases (3 corpus, 150 sv-tests: 111 EQUAL, 26 DIFFERENT, 9
  STRICT_NOTEQUAL, 4 SLANG_ONLY); § unitChandleTd422 and
  § classChandleTdPropBareLogicVar422 nowhere.
- away census on the 39 non-EQUAL sv-tests rows the order law fires on
  (evidence/away_census_derivedorder.txt, uhdm-cmp lines against the cached
  golden, law vs control): 30 unchanged count (tail-only moves, spot-checked
  on 18.14_1), 5 toward golden (uvm_component_class_1 663078 -> 0;
  testbenches uvm_agent_active, uvm_agent_passive, uvm_driver_sequencer_env,
  uvm_monitor_env 676352/690148 -> 17, their head now ParamEmit's class
  param_assign constant typespec), 4 SLANG_ONLY without golden; 0 away.

A first law binary (law18) swept the probe stage with one regression,
v11u93repro/grid/b09b_netdecl EQUAL -> NOT_EQUAL: § strNetRefMintsNet422
minted a definition-view net for a strength net read by an assign inside a
NESTED module definition, where golden mints none. The law now abstains in
nested definitions (case SD/sd11); that sweep was stopped during its surelog
stage and the whole five-stage sweep above reran on law19.

## Grid

51 case dirs in CH, DC, IA, IN, SD, UU (drivers/grid.sh; evidence/
grid_final.txt; each case's first line names its law):

- pristine -> law19: 34 NOT_EQUAL -> STRICT_EQUAL (8 of them from exit 4:
  IA ia03, ia05, ia08, ia09, ia11, ia12; CH ch01, ch04), 13 STRICT_EQUAL
  controls byte-identical to pristine, CH/ch02, ch05, ch06 NOT_EQUAL on
  both (ch02, ch06 exit 4 -> 0 with the head later: a module variable typed
  by the chandle typedef golden writes as a logic_var, the per-use alias clone
  of a function argument; ch05 a class-scope `typedef chandle` golden lists
  in the class's typedefs and ours does not, the head moved later from the
  property's kind to the class typedef listing, cmp 36 -> 55 printing the
  class), IA/ia07 (positional array connection, exit 4 on both, not reached).
- `R11U422_OFF` restores pristine's bytes and exit code on 51 of 51; each
  case's own switch on 40; the 11 others are restored by the co-firing
  set (measured): IA ia01-ia06, ia09, ia11, ia12 by R11U422_ELEMCONCAT_OFF +
  R11U422_BCASTBIND_OFF + R11U422_BCASTONEBIT_OFF, CH ch01 and ch06 by
  R11U422_CHANDLETDPROP_OFF + R11U422_UNITCHANDLETD_OFF.
- Downstream (drivers/downstream_cases.py, evidence/downstream_cases.txt,
  the class-free IA, IN, SD, UU cases on law18, whose bytes on these cases
  equal law19's): IA ia01, ia11 DIVERGENT -> IDENTICAL; IA ia02, ia03, ia05,
  ia06, ia08, ia09, ia12 and SD sd01, sd05-sd09 EQUIVALENT -> IDENTICAL;
  none worse.
- The pass 90 evidence case r11u90repro/grid.verifier/vx2_strreadsame (a
  strength net read by its own module's assign) NOT_EQUAL -> STRICT_EQUAL.

Not done within the budget: the earlier-pass case census (tools/probe
r11u401..r11u420 case dirs) — left to the verifier.

## Residues (ranked; all wrong on pristine too, none moved away)

1. 12 uvm-examples rows (uvm_ac_config_db, uvm_ef_vif_config_db,
   uvm_param_vif_config_db, uvm_vif_config_db, uvm_id_register,
   uvm_messaging_example, uvm_priority_arbitration, uvm_priority_grab_lock,
   uvm_use_models_* x4) and 4 more (uvm_generation_seq_* x3, uvm_test_init):
   uhdm-cmp head at a package object pair (golden uvm_pkg vs ours a user
   package, or test_lib_pkg/test_top_pkg pairs); the first value difference
   inside the user package is ParamEmit's `1<<16` parameter copies (golden
   UINT:65536 decompile 65536, ours INT:65536 decompile 1<<16): sister ground,
   possibly what pass 419's UINT law covers; evidence/uvm_heads_law15.txt.
2. testbenches uvm_agent_active, uvm_agent_passive, uvm_driver_sequencer_env,
   uvm_monitor_env: head now class_defn(work@packet_in|out) > param_assign >
   constant > ref_typespec: golden's class copy of the uvm_pkg parameter
   (UVM_COPY, `parameter uvm_field_flag_t ...`) carries a ref_typespec to
   uvm_field_flag_t where ours has none (ParamEmit's class import copies:
   sister ground).
3. easyUVM/top: head class_defn(work@sequencer) against <null> in a vector
   not identified (the derived lists and allClasses agree); the 3
   testbenches scoreboard rows: design-level size mismatch, not decoded.
4. 16.12 property-interface (-prec) and apb_protocol_monitor at
   interface_inst (ParamEmit's interface import copies, sister ground);
   16.17 expect at the expect statement (StmtEmit, sister ground).
5. p737 (an undefaulted type parameter top: ours writes no top, design
   unnamed), p489 (comma-continued ANSI ports `logic[7:0] in1, in2,
   in_array[20:0]`: golden in2 and in_array plain logic_net 36 without
   typespec in the elaborated view, ours a logic_var and an array_net), p334,
   p599, p130, p203, p193_2, p179, p719, default-value, typedef_test_9,
   class_test_49/51, fx68k, scr1, tnoc, the basejump rows: carried.
6. Probe-only goal-1 shapes vh04, vc13, vy02, vu02, aq09 (exit 4); CH/ch02,
   ch05, ch06; IA/ia07 (positional module-array concatenation: Surelog's
   UDP-form decision interacts).
7. Pass 420's residues not reached (vp01/vp08/vp09/vp16 direction-less ANSI
   port after a directed one, ...): carried.

## Sister-ground faces (reported, not written)

- ParamEmit: the class param_assign copy of an imported typed package
  parameter lacks the constant's ref_typespec (testbenches rows above); the
  package parameter copies `1<<16` folded to UINT with a decimal decompile in
  golden (uvm-examples rows).
- ParamEmit: interface import parameter copies (16.12 rows, apb monitor).
- StmtEmit: 16.17 expect action block.

## Process

The implementer measured within the budget: one full sweep on the final
binary (law19); intermediate binaries law1..law18 only on grids and runner
calls on the targeted rows (98 non-equal rows on pristine, the 42 UVM rows
on law15, three rows on law14). A first full sweep on law18 was stopped by
its own task id during its surelog stage after its probe stage read the
b09b regression; nothing of it is used. Slip: an unset $UHDM_DUMP in an early
shell made the shell run a golden .uhdm; it dropped two empty files in the
main tree root, deleted at once by time window (`find -newermt ... -empty
-delete`), main tree clean afterwards. The `--keep-golden` copy the runner
leaves for UVM rows is built with sv-tests' own uvm (not the cached golden
the comparison uses); every UVM head here is read against the cached
golden. A sister build (/tmp/wt_r11u421) ran during the law18 run's probe
stage; no sister sweep was live during the law19 sweep. The fence list was
read into a file by a program and never printed; every tree-wide reader
filtered on it first.
