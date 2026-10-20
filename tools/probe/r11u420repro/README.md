# r11u420 — the module/type ground, tenth pass of the sv-tests campaign

Implementer pass on base `ff652a334` (pass 418). Ground: `src/ModuleEmit.cpp`
and `src/UhdmExporter.cpp` (TypeEmit, TaskFuncEmit and uhdm_main.cpp
unchanged; the sister's ExprEmit, StmtEmit, ParamEmit and EmitHelpers.h
untouched). Thirteen laws, each read through `src/LawSwitch.h`
(`lawOn(420, "R11U420_<LAW>_OFF")`). `R11U420_OFF` drops them all, and
`R11U420_TRACE=<dir>` logs each firing through `lawTrace(420, ...)`. There is
no src/R*.h, no LawState.h section, no getenv and no reader function.

Binaries: pristine = the worktree's own base build, byte-identical to the
expected base binary (md5 a66aad5a9b59d95c047a890e200e636b); final law binary
md5 862f7c5f9460bda30054b8b0c71def1e (`/tmp/r11u420_bin/final`). The
intermediate binaries law1 to law20 ran only on the case grids and on
targeted runner calls over the rows worked (the chapter-16 rows, the 118
unequal rows, the 99 accepted UVM rows, the non-UVM unequal rows, and the
corpus rows SequenceInst, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
BuildUVMPkg, ApbSlave, Earlgrey_0_1 and the assertion rows). All five stages
of the one full sweep ran on the final binary.

## Result

sv-tests stage (the final binary, the main tree's `scripts/check_svtests.py`
read-only with `--baseline` the base golden `ff652a33:results/golden_svtests.csv`,
since a worktree has no UVM tree): **regressions=0, conversions=18,
changes=0** (evidence/svtests_stage_final.log).

| status | base | this pass |
|---|---|---|
| EQUAL | 1822 | 1840 |
| STRICT_NOTEQUAL | 11 | 11 |
| DIFFERENT | 107 | 89 |
| SURELOG_ONLY / BOTH_REJECT / SLANG_ONLY / SURELOG_CRASH / TIMEOUT | 75 / 303 / 19 / 8 / 1 | the same |

The fresh csv differs from the master's control (`/tmp/intr11u418/svtests.csv`)
in exactly the 18 converted rows (evidence/svtests_csv_vs_control.diff).
THE CONVERSIONS (fresh rows; results/ untouched, the master promotes), all
DIFFERENT -> EQUAL:

| row | law(s) |
|---|---|
| chapter-16/16.2--assert-final-uvm.sv, 16.2--assert0-uvm.sv, 16.12--property-uvm.sv, 16.12--property-prec-uvm.sv, 16.14--assume-property-uvm.sv, 16.7--sequence-uvm.sv | § pkgLateTsNetCapture420 |
| chapter-16/16.2--assert-uvm.sv, 16.2--assume-uvm.sv | § pkgLateTsNetCapture420, § pkgLateTsLoopVarCapture420 |
| chapter-16/16.10--property-local-var-uvm.sv, 16.10--sequence-local-var-uvm.sv, 16.11--sequence-subroutine-uvm.sv | § pkgLateTsNetCapture420, § unitVarNetSourceOrder420, § contAssignVarInitRhsShared420 |
| chapter-16/16.7--sequence-and-uvm.sv, 16.7--sequence-and-range-uvm.sv | § pkgLateTsNetCapture420, § seqAndOrLogOp420, § assertBinParenSpanInner420 |
| chapter-16/16.7--sequence-or-uvm.sv | § pkgLateTsNetCapture420, § seqAndOrLogOp420 |
| chapter-16/16.13--sequence-multiclock-uvm.sv | § pkgLateTsNetCapture420, § seqLeadDelayPairUnary420, § clockedSeqEventSpanBare420 |
| chapter-5/5.10-structure-replication.sv | § unpackedStructVarPosInit420 |
| chapter-8/8.24--out_of_block_methods.sv | § modOutOfBodyMethodIsModuleTf420 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p488.sv | § ansiNoDirNetPortUntyped420 |

    chapter-16/16.10--property-local-var-uvm.sv,EQUAL,,equal
    chapter-16/16.10--sequence-local-var-uvm.sv,EQUAL,,equal
    chapter-16/16.11--sequence-subroutine-uvm.sv,EQUAL,,equal
    chapter-16/16.12--property-prec-uvm.sv,EQUAL,,equal
    chapter-16/16.12--property-uvm.sv,EQUAL,,equal
    chapter-16/16.13--sequence-multiclock-uvm.sv,EQUAL,,equal
    chapter-16/16.14--assume-property-uvm.sv,EQUAL,,equal
    chapter-16/16.2--assert0-uvm.sv,EQUAL,,equal
    chapter-16/16.2--assert-final-uvm.sv,EQUAL,,equal
    chapter-16/16.2--assert-uvm.sv,EQUAL,,equal
    chapter-16/16.2--assume-uvm.sv,EQUAL,,equal
    chapter-16/16.7--sequence-and-range-uvm.sv,EQUAL,,equal
    chapter-16/16.7--sequence-and-uvm.sv,EQUAL,,equal
    chapter-16/16.7--sequence-or-uvm.sv,EQUAL,,equal
    chapter-16/16.7--sequence-uvm.sv,EQUAL,,equal
    chapter-5/5.10-structure-replication.sv,EQUAL,,equal
    chapter-8/8.24--out_of_block_methods.sv,EQUAL,,equal
    generated/hdlconv_std2017/hdlconvertor_std2017_p488.sv,EQUAL,,equal

The 11 chapter-16 rows headed at "an interface net's `reg [7:0]` typespec
against a class-queue array_typespec" (pass 418's first residue, not
decoded then) were all one face, decoded here (§ pkgLateTsNetCapture420):
Surelog's elaboration rebinds a uvm_pkg foreach's array (or loop variable)
typespec to the design net of the same name (`b`, `addr`, `c`).

Trace census on the sv-tests stage (evidence/law_firings.txt): the laws fire
on 151 rows.
- 18 are the conversions above.
- 84 stay EQUAL (the capture of `uvm_deferred_init` in `uvm_init`'s foreach
  by the hoisted design net of that name, which golden makes too; and
  hdlconvertor_std2017_p469's clocked sequence, `@clk`-form, bytes as
  before), 5 stay SLANG_ONLY (no status change, no golden comparison).
- 36 stay DIFFERENT and 8 stay STRICT_NOTEQUAL (the uvm_classes_1 rows and
  uvm_agent_env at differ:value(3), their strict column unchanged). Away
  census on those 44 plus the 5 SLANG_ONLY rows (drivers/away.sh,
  evidence/away_census.txt; golden against the master's control database and
  against this pass's): uhdm-cmp line counts unchanged on every row except
  utd-sv (62 -> 15) and three rows whose head moved later in the walk
  (corrected by the verifier v11u420: 16.12--property-interface-uvm and
  -prec-uvm 116 -> 659513, the head moving from the topPackages foreach
  typespec to the interface_inst's import parameter copies in
  allInterfaces, ParamEmit's face; 16.17--expect-uvm 116 -> 217, the head
  moving to the expect statement's action block in topModules, StmtEmit's
  face); the multiset distance of the normalized dump reads 47
  toward and 2 away, and on the UVM rows the move is exactly one line: an
  orphan array_typespec the captured foreach no longer references drops out
  of the weakly-referenced tail (outside the design walk, read by neither
  comparator). That tail line reads away on generated/easyUVM/top
  (502824 -> 502825) and generated/uvm-examples/uvm_many_to_one
  (802843 -> 802844): on both the control-vs-law dump diff is that single
  `\_array_typespec:` tail line and nothing else, uhdm-cmp 659635 and
  1407978 lines on both binaries. No design object moved away.

## Corpus gates

All on the final binary, one sweep (`tests/sweep.sh --jobs 3 --corpus
"probe surelog uhdm2rtlil downstream"` from the worktree, then the sv-tests
stage as above; evidence/corpus_stages_final.log):

- probe: EQUAL=4018 STRICT_NOTEQUAL=69 of 4087, regressions=0 conversions=0
  changes=0; the csv byte-identical to the control.
- surelog: default CMP_EQUAL 480 + 0, testflags 474 + 0, regressions=0
  conversions=0 changes=0; the csv identical to the control but the two
  LowMem log-path texts (environment).
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of
  871; csv identical to the control (verdict diff 0).
- byteverify against the master's control (`/tmp/intr11u418`, SELFCHECK=1):
  surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805
  (evidence/byteverify.txt).
- Predicted movers by name before the sweep: none in the corpora (source
  scans of the fence-filtered corpus trees: no direction-less net-typed ANSI
  port, the module-array concatenation connections only in rows that are
  SLANG_REJECT or SURELOG_FAIL (UtdSV, Verilator, Lpddr); SequenceInst's
  nested `@clkx` clocking traced in a targeted run with its databases
  byte-identical to pristine), none in the probe set (the two probe cases
  with a sequence `and`/`or`/`intersect` sit under `disable iff` or an
  inline assertion the laws do not reach). Trace census of the corpus
  stages: § clockedSeqEventSpanBare420 fires on SequenceInst d/t (bytes
  identical, as predicted); § pkgLateTsNetCapture420 fires on the probe case
  r10v148repro/v148_g_corpus (`names_v7` captured by the importing module's
  copy, same content), EQUAL on both; its dump differs from the control's
  only by one weakly-referenced orphan array_typespec. Nothing fires in
  uhdm2rtlil or downstream.
- The UVM corpus rows stay STRICT_EQUAL (MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard d, BuildUVMPkg, ApbSlave, Earlgrey_0_1 both modes; no law fires
  there).

## Laws

1. § pkgLateTsNetCapture420 (UhdmExporter, final287's design-final steps;
   R11U420_FOREACHNETCAP_OFF). Surelog compiles a foreach's array identifier
   with compileVariable (CompileStmt.cpp paFOREACH -> CompileType.cpp): a
   plain name that is no type is a ref_var over an unsupported_typespec of
   the name, registered with needLateTypedefBinding on the component being
   compiled, which for the topPackages copy of a package's own subroutines
   and its out-of-body class methods is the elaborated package.
   CompileHelper::importPackage copies the package's whole late-typedef list
   into every design component that imports it (a file-level import of the
   component's file, or a body import; explicit imports copy the whole list
   too), and ElaborationStep::bindTypedefsPostElab_ walks the instances
   breadth first from the tops, resolving each name against the instance's
   netlist nets, then its variables: the first instance holding the name wins
   (swap map emplace) and the reference takes THAT net's typespec. Cases
   FN/fn02 (the top's own net first), fn03 (a body import), fn05 (a module
   port), fn07 (a module instantiated before the interface wins), fn10 (a
   formal array), fn11, fn12 (an explicit import); controls fn01 (an in-body
   class method keeps its placeholder: the law skips a reference whose
   typespec is still the unsupported_typespec), fn04 (no import), fn08 (only
   a non-holding definition imports).
2. § pkgLateTsLoopVarCapture420 (UhdmExporter; R11U420_LOOPVARCAP_OFF). The
   loop variables are on the same list: a captured loop variable stays a
   ref_var over the net's typespec (UhdmWriter's lateTypedefBinding no longer
   sees an unsupported_typespec and never runs swapForSpecifiedVar), and the
   body's references to it, left to the late binder whose foreach branch skips a
   ref_var, bind to the first module definition (design module order) that
   imports the package: its net of that name, else a minted wire there at
   the first reference (no file). Cases FN/fn06 (minted in top), fn13 (bound
   to adder's c), fn14 (minted in adder); sv-tests 16.2 assert/assume
   (uvm_component's `foreach (m_children[c])` against adder_if's `c`).
3. § unitVarNetSourceOrder420 (ModuleEmit, the end of emitModuleDef;
   R11U420_UNITVARORDER_OFF). The `$unit` variable's wire of
   § unitVarRefMintsNet418 is UhdmWriter::lateBinding's, minted in the
   module's late-binding list order (compile order): a property or sequence
   local variable's wire written before the `$unit` variable's first
   reference is listed before it. The definition-view wire moves after the
   last later-minted wire of the module's file written before it. Cases UL
   ul01, ul03, ul05 (a sequence), ul06, ul07, ul08 (an always block);
   controls ul02, ul04.
4. § contAssignVarInitRhsShared420 (UhdmExporter; R11U420_CAVARINIT_OFF).
   UhdmWriter::writeCont_assign reduces the elaborated right side; its
   ref_obj branch reaches CompileHelper::getObject (CompileExpression.cpp),
   which answers an instance netlist variable of kind int, integer, real,
   shortint or longint with an initializer by the initializer expression
   ITSELF; with a hier_path left side (no typespec, adjustSize leaves it) the
   very constant is installed and re-parented at the cloned assignment. The
   law writes the elaborated clone (ours shared the definition's object) and
   installs the variable's own initializer constant. Cases CR cr01, cr05,
   cr10 (a module instance member), cr11 (two assignments: the last parents
   it); controls cr02 (a typed left side), cr03 (no initializer), cr04 (an
   expression), cr06 (logic), cr09 (a net).
5. § seqAndOrLogOp420 (ModuleEmit, emitAssertionExpr's binary branch;
   R11U420_SEQANDOR_OFF). Surelog maps paAND / paOR through
   UhdmWriter::getVpiOpType to vpiLogAndOp (26) / vpiLogOrOp (27) in every
   assertion context and never writes vpiCompAndOp / vpiCompOrOp; ours wrote
   79 / 80. Cases SA sa01-sa06, sa08, sa09, sa12.
6. § assertBinParenSpanInner420 (ModuleEmit; R11U420_ASSERTBINPAREN_OFF). A
   parenthesized binary sequence or property expression spans its inside
   (the parentheses belong to the enclosing node); a parenthesis carrying a
   match list or a repetition keeps its span. Cases SA sa07 (intersect),
   sa01, sa05, sa09 (double parentheses), sa12; sa18 control (inline).
7. § propAndOrUnparented420 (ModuleEmit; R11U420_PROPANDOR_OFF). An and/or
   with a property operand is CompileExpression's paProperty_expr branch: the
   operation has no vpiParent and every reference below it has no full name.
   Cases SA sa10, sa11, sa14 (a bit-select), sa15, sa16 (a sequence beside a
   property), sa17 (nested), sa20 (formals); sa19 control (inline).
8. § seqLeadDelayPairUnary420 (ModuleEmit, the SequenceConcat branch;
   R11U420_SEQLEADPAIR_OFF). A two-element concatenation with a leading delay
   is § seqNestLeadingDelay406v's unary cycle-delay operation (53) over the
   flat pair. Cases SQ sq01, sq02, sq03, sq05 (ranged); controls sq04, sq06.
9. § clockedSeqEventSpanBare420 (ModuleEmit, the Clocking branch;
   R11U420_CLOCKEDSEQ_OFF). A nested clocked sequence spans its whole written
   event `@(posedge x)`, and every reference under it (hier_path members,
   module signals, bit-selects) has no full name. Cases SQ sq03, sq07, sq08
   (`@clk2`), sq09.
10. § ansiNoDirNetPortUntyped420 (UhdmExporter; R11U420_ANSINODIR_OFF). A
    direction-less ANSI module port written with a net type (`wire [31:0]
    bus`) and the bare ports inheriting from it keep no type: no port
    typespec, no net typespec, no net type, both views. Cases AP ap01, ap02,
    ap05; controls ap03, ap04.
11. § unpackedStructVarPosInit420 (ModuleEmit, the elaborated signal loop;
    R11U420_USTRUCTPOSINIT_OFF). An unpacked struct variable demoted by its
    member scan keeps a positional or replicated pattern initializer as its
    vpiExpr (struct_var, not struct_net + cont_assign), unparented constants,
    no typespec on the pattern, an inline struct's typespec parented at the
    variable, the declarator span (inline) or name span (typedef), and a
    replication count sized at the struct's width. Cases ST st01, st04, st05,
    st06; st02 control; st03 (packed) and st07 (an all-logic unpacked struct)
    not reached.
12. § arrayBcastConcatActual420 (ModuleEmit, emitModuleArray;
    R11U420_ARRCONCAT_OFF). A module array's named broadcast connection
    written as a concatenation keeps it (compiled from syntax). Cases IA
    ia01-ia03, each closer (cmp 62/336/246 -> 15); the remaining face is in
    the elaborated element connections (an unbound actual), not reached.
13. § modOutOfBodyMethodIsModuleTf420 (UhdmExporter;
    R11U420_MODOOBMETHOD_OFF). An out-of-body method of a class declared in
    a module, defined in the module body, is the module's subroutine `C::m`
    (work@mod.C::m, both views, one object), the class keeps the prototype,
    and a class property the body reads binds the module's own signal of
    that name or a wire minted at the first reference. Abstains when the body
    references anything else. Cases OB ob01-ob04 (ob04: the module's own `a`).

## Grid

84 case dirs in AP, CR, FN, IA, OB, SA, SQ, ST and UL (drivers/grid.sh,
evidence/grid_final.txt; every case's first line names its law):

- pristine -> final: 55 move to STRICT_EQUAL (47 from NOT_EQUAL, 8 from
  STRICT_NOTEQUAL), 18 STRICT_EQUAL controls kept at their reading, 11
  unequal on both (CR/cr08 STRICT_NOTEQUAL fullname with its type face gone,
  toward; CR/cr07, FN/fn09, SA/sa21, ST/st03, st07, UL/ul09, ul10 NOT_EQUAL at
  pristine's bytes or the same cmp count; IA/ia01-ia03 NOT_EQUAL toward
  golden); no exit code changes (IA/ia03 exits 4 on both).
- `R11U420_OFF` restores pristine's bytes and exit code on 84 of 84; each
  case's own switch on 69 of 84; the 15 others need the co-firing law's
  switch too and are restored by the pair (listed at the end of
  evidence/grid_final.txt).
- Downstream (drivers/downstream_cases.py, evidence/downstream_cases.txt;
  class- and package-free cases): AP/ap01, ap02, ap05, CR/cr01, cr05, cr08,
  cr10, cr11, ST/st06 EQUIVALENT -> IDENTICAL; ST/st01, st04, st05
  DIVERGENT -> IDENTICAL; none worse.

## Goal 1

The detail column at the base: no SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH
row carries an exporter error; all 75 SURELOG_ONLY rows carry an upstream
slang front-end diagnostic (the should_fail rows and the time-scale rows).
The probe-only exit-4 shapes vh04, vh06, vc13, vy02, vu02 and aq09 are not
written. New: a module array whose named connection is a replication
(`child c[3:0] (.a({4{en}}))`, IA/ia03) exits 4 with "element select base"
where upstream slang accepts; decoded, not written.

## Residues (ranked; all wrong on pristine too, none moved away)

1. chapter-16/16.12--property-interface-uvm.sv and -prec-uvm.sv (2 rows):
   their head after § pkgLateTsNetCapture420 is the interface listing's
   import parameter copies (UVM_ALL_ON), ParamEmit's (sister ground).
2. chapter-16/16.17--expect-uvm.sv: golden's expect_stmt has no else
   statement (the `uvm_error` action block); StmtEmit's (sister ground).
3. The UVM uvm-examples, testbenches and uvm_classes_0/2/3 rows: package
   listing and class listing faces, carried.
4. The 8 uvm_classes_1 / uvm_agent_env STRICT_NOTEQUAL rows: ParamEmit's
   interface import copies (sister ground), unchanged.
5. FN/fn09: an out-of-body class method in a small package differs at the
   class's method listing (476 cmp lines on both), not decoded.
6. utd-sv primitives: after § arrayBcastConcatActual420 the elaborated
   element connections leave an actual unbound (IA/ia01).
7. UL/ul09 (a sequence local listed before a property local) and ul10 (an
   implicit continuous-assign net after the `$unit` wire): the late-bound
   wire order beyond the `$unit` wire.
8. CR/cr07 (`int cycle = 2 + 3`, golden folds to a fresh unlocated constant)
   and cr08 (a parameter-initialized variable's fullname).
9. ST/st03 (a packed struct pattern net's span and folded value) and st07
   (an all-logic unpacked struct with a positional initializer).
10. p130 (a type parameter's overridden typespec), p334, p489, p884, p737,
    p719, p599, p600, p733, p827, class_test_49 and 51, typedef_test_9,
    default-value, scr1, fx68k, tnoc, the basejump rows: carried.

## Sister-ground faces (reported, not written)

- ParamEmit: the interface listing's import copies of uvm_pkg parameters
  (the 16.12 property-interface rows and the 8 STRICT_NOTEQUAL rows).
- StmtEmit: an expect statement's `else` action block (16.17).

## Process

- One full sweep, all five stages on the final binary. The sv-tests stage
  ran through the main tree's scripts/check_svtests.py read-only with
  `--baseline` the base golden (a worktree has no UVM tree).
- Slips, none affecting a measurement: a targeted runner call over the 62
  non-UVM unequal rows (law18) ran during the sister pass 419's downstream
  stage (its pgrep showed the sweep; the slip was mine, noticed after the
  call); the law21 build and the four OB case runs overlapped the first
  minute of r11u419's sv-tests stage; the law19 grid's last minute
  overlapped the start of r11u419's second sweep. The final grid, the
  downstream case runs and the away census ran with no sweep live. My own full sweep ran on a
  quiet machine. No other agent's process touched, no fenced test named,
  opened or run; the fence list was read into a file by a program from
  canaudit.sh's FENCED= line without printing it, and every tree-wide list
  (probe cases, corpus sources) was filtered on it before opening a file.
- After the sweep the forbidden word in five added source comments and in
  the README was rewritten to 'branch' by the standing word rule; the
  rebuilt binary is byte-identical to the swept one (md5
  862f7c5f9460bda30054b8b0c71def1e).
- Drivers: drivers/run1.sh (one case: golden + ours + uhdm-cmp + strict),
  drivers/sdiff.sh, drivers/grid.sh, drivers/away.sh,
  drivers/downstream_cases.py.
