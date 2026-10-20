# r11u421: expect action blocks, system-call operands of selects, untyped $bits parameters (pass 421, expression/parameter ground)

Base d0d46b5ca. Production surface: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`,
`src/StmtEmit.cpp`. No change to `EmitHelpers.h`, `include/`, `uhdm_main.cpp`
or any sister-ground file. Every law reads its switch through
`src/LawSwitch.h` (`lawOn(421, ...)`, `lawTrace(421, ...)`); there is no
`src/R*.h`, no `getenv` and no reader function. `R11U421_OFF=1` gives
pristine's bytes and exit code on 39 of 39 grid case dirs, and each group's
own switch does too (`evidence/grid.txt`).

Binaries: pristine = the main tree's `build/slang-uhdm` at the base (md5
2e1233784f8120b172b1a2bf12fded1f; the worktree's base build is
byte-identical); law = md5 22d95ce83451d22560ae8990578e4ff7 (frozen before
any measurement; every cmds.txt audited by path).

## Result

One full five-stage sweep on the law binary (`drivers/fullrun.sh`; the four
corpus stages through the worktree's `tests/sweep.sh --jobs 3`, the sv-tests
stage through the main tree's `scripts/check_svtests.py` read-only with
`--baseline` the worktree's `results/golden_svtests.csv`, since a worktree has
no UVM tree; launched after three quiet readings; evidence/sweep_corpus.log,
evidence/svtests_stage.log, evidence/svtests.csv):

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0
  conversions=0 changes=0; the csv byte-identical to the master's control.
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0
  conversions=0 changes=0 (Tnoc d/t CMP_NOTEQUAL standing); the csv differs
  from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, regressions=0 conversions=0
  changes=0; the csv byte-identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of
  871, not identical and not excused 0; the csv byte-identical to the control.
- sv-tests: regressions=0 conversions=3 changes=0. EQUAL 1851 -> 1854,
  STRICT_NOTEQUAL 3 -> 2, DIFFERENT 86 -> 84, BOTH_REJECT 303, SURELOG_ONLY
  75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; the csv differs from
  the control in exactly the three rows below.

| row | before -> after | law |
|---|---|---|
| chapter-16/16.17--expect-uvm.sv | DIFFERENT -> EQUAL | § expectActionBlockStmts421 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_concentrator_out.sv | STRICT_NOTEQUAL differ:fullname(1) -> EQUAL | § hpTrailIpsSysArgNames421 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_ready_and_link_async_to_wormhole.sv | DIFFERENT -> EQUAL | § bitsDefNoFoldNoTs421 |

Fresh csv rows (evidence/svtests.csv):

    chapter-16/16.17--expect-uvm.sv,EQUAL,,equal
    generated/basejump/bsg_noc_BaseJumpSTL_bsg_ready_and_link_async_to_wormhole.sv,EQUAL,,equal
    generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_concentrator_out.sv,EQUAL,,equal

Byte movers: byteverify of the law sweep against the master's control
(`/tmp/intr11u419`, same-length workdir names, SELFCHECK=1): MOVERS 0 of 962
(surelog), 0 of 1608 (uhdm2rtlil), 0 of 805 (downstream), the self-checks
flagging 961, 1607 and 804 (evidence/byteverify.txt). PREDICTED BY NAME
before the sweep (evidence/predict_trace.txt, predict_srcscan.txt): a
fence-filtered source scan for each law's shape (expect with an action
block, a system call in a dotted path's trailing indexed part select, a
system call over a select in a parameter initializer, `= $bits(` in a
parameter declaration; none in the bundled UVM library) named the candidate
Surelog rows, and a trace run of the law binary with `R11U421_TRACE` on those
rows (both modes), on every uhdm2rtlil row and on every probe case wrote no
trace line (positive control: cases/BF/bf02 run the same way writes two), so
the prediction was zero corpus movers in bytes and in exit codes; the sweep
read zero.

Trace census of the sweep (evidence/trace_census.txt): the laws fired on 10
rows, all sv-tests: the 3 conversions, bsg_tag_trace_replay (still
DIFFERENT, below) and the six black-parrot rows (SURELOG_CRASH on both
binaries; § hpTrailIpsSysArgNames421 fires 12 times in bp_cce_inst_decode,
bp_cce_src_sel and bp_cce_inst_stall before our exporter exits 3 under pass
403's size guard), and on no probe case or corpus row.

Away census (evidence/away_census.txt): bsg_tag_trace_replay uhdm-cmp 17 ->
50 with its head moved LATER in the walk (from the parameter's typespec to a
definition-view generate-block port connection written by the sister's
emitSyntaxExpr) and the multiset distance 43 -> 35, toward; nothing away.

Canaries: canaries.sh ok=52 changed=0 (surelog) and ok=16 changed=0
(uhdm2rtlil); ctcan2 EXPECT_UNKNOWN=1 ok=58 PASS and EXPECT_UNKNOWN=6 ok=2
PASS (evidence/canaries.txt). Binary audit (evidence/binary_audit.txt):
surelog 1523 of 1573 fence-filtered cmds.txt name the law binary (the other
50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of
2346.

Downstream on the grid (evidence/downstream.txt): all 39 case dirs keep their
verdict, 35 IDENTICAL and 4 EQUIVALENT (HS/hs01, hs02, hs03, hs05: the
elaborated port connection face below) on both binaries; none worse.

Earlier-pass census (drivers/earlier.sh, evidence/earlier_census.txt): all
2908 case dirs of tools/probe/r11u400repro to r11u420repro and their v11u
twins, the path list fence-filtered first: 2906 at pristine's exit code and
bytes, two movers, both toward golden: v11u420 VS/vs33 (an expect with an
else action) NOT_EQUAL -> STRICT_EQUAL, and r11u405 BU/bu04 (`$bits(n+1)`
over a default-less parameter) NOT_EQUAL with dump distance 42 -> 34, its
head moved later in the walk from the parameter's typespec (removed, as
golden) to the param_assign's `$bits` call, which golden parses as three
arguments. No exit code changes.

## Laws (find a site with `grep -n '§ <law>' src`)

### § expectActionBlockStmts421 (src/StmtEmit.cpp)

Switch: `R11U421_EXPECTACT_OFF`.

Surelog's `paExpect_property_statement` branch (CompileStmt.cpp) compiles an
expect's action block into two fields: the pass statement into `vpiStmt`, the
statement after `else` into `vpiElseStmt`. We wrote the `else` action as
`vpiStmt` and dropped a pass action. `expect (@(posedge clk) a ##1 b) else
$error("e");` now has no `vpiStmt` and its `$error` under `vpiElseStmt`.
This was the head of chapter-16/16.17--expect-uvm.sv (uhdm-cmp: `LHS: <null>
RHS: begin` under the expect, the `uvm_error` action block), the face pass 420
reported for this ground.

Grid cases/EX: ex01 (else only), ex02 (pass only), ex03 (both), ex04 (block
actions), ex06 (a task), ex07 (an else block) NOT_EQUAL -> STRICT_EQUAL; ex05
(no action) the control, pristine's bytes.

### § hpTrailIpsSysArgNames421 (src/ExprEmit.cpp, inside hpTrailIpsNames218)

Switch: `R11U421_HPIPSSYSARG_OFF`.

§ hpTrailIpsNamesByPath218 names a reference in the base or the width of a
dotted path's trailing indexed part select through the path (the writer's
ComputeFullName walks ref_obj -> operation -> indexed_part_select ->
hier_path). Its walk descended only through operations. A reference that is
an argument of a SYSTEM CALL there is named the same way in golden:
`work@m.d.i.h.cid[0+:num_in_p == 1 || num_in_p == 0 ? 1 :
$clog2(num_in_p)].cid.num_in_p` for the `$clog2` argument of the
`BSG_SAFE_CLOG2` width, where ours kept the scope's `work@m.d.i.num_in_p`.
That was the only strict field of
generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_concentrator_out.sv
(STRICT_NOTEQUAL differ:fullname(1); pass 418's sister report).

Grid cases/HS: hs06 (the same width in a continuous assignment)
STRICT_NOTEQUAL -> STRICT_EQUAL; hs01 to hs04 (port connections) closer
(dump distance 101 -> 97, 77 -> 73, 77 -> 73, 58 -> 54) at the next head,
the ELABORATED port connection, where golden folds the select's width to a
constant (`h.cid[0+:2]`, the constant spanning the taken ternary branch) and
we keep the expression (not decoded to its writer; listed under residues);
hs05 (`$bits(h.len)` in the width) and hs07 (no system call) unchanged; hs08
(the call in the BASE, `h.cid[$clog2(n)+:2]`) STRICT_EQUAL on both binaries
with moved bytes and an identical dump (the reference was already named
through the path on pristine; the law writes the same name earlier); hs09
(`$clog2(n)` as the whole width in a continuous assignment) NOT_EQUAL on both
at the hier_path NAME: golden renders a whole-width system call as nothing,
`h.cid[0+:]`, where ours keeps the raw text (§ hpIdxBaseHierPathEmpty94's
gate abstains on a constant base; residue).

### § paramInitSysArgBitSelAtIndex421 (src/ExprEmit.cpp, the ElementSelect branch)

Switch: `R11U421_PISYSBS_OFF`.

A parameter initializer's bit_select spans the whole select (func_upto's
`!(SWAPS[0])`). Golden anchors one that is itself an ARGUMENT of a system
call at its index, as every rvalue select: `localparam W = $bits(P[1]);`
golden 3:26-3:27, ours 3:24-3:28. This is the module-level half of
bsg_mesh_router's last strict field; the row's own site is a DEFINITION-VIEW
generate-block localparam, written by TypeEmit's emitSyntaxExpr (sister
ground, below), so the row stays STRICT_NOTEQUAL differ:col(1).

Grid cases/PB: pb03 and pb04 (module localparams over `$bits(P[1])`,
`$clog2(P[1])`) closer (dump distance 18 -> 14), their remaining head the
packed parameter's default constant typespec (golden a ref_typespec to a
logic_typespec where ours has none) and golden's own `$bits(P[1])` value 1;
pb01, pb02, pb06 (generate blocks: not reached, the sister's writer) and pb05
(an operation operand, the control) unchanged.

### § bitsDefNoFoldNoTs421 (src/ParamEmit.cpp, beside § bitsParamArgNoFold405)

Switch: `R11U421_BITSDEFNOFOLD_OFF`.

An UNTYPED parameter initialized by `$bits(...)` takes the declaration's
implicit int_typespec, and its elaborated value is typed by it (size 32,
a ref_typespec on the constant), because Surelog's definition compile folds
`$bits` there. When the definition compile CANNOT fold the call (the answer
of `srlgBitsFoldArg` in its definition view, the predicate the expression
emitter keeps the `sys_func_call` on), golden keeps the call in the
definition listing, the parameter carries no typespec in either view, and
the elaborated value is the computed fold: UINT, size 64, no typespec. The
shapes: a typedef or struct whose width reads a parameter (defaulted or
not), a signal of parameter width, a type parameter. § bitsParamArgNoFold405
was the same rule for a parameter-name argument; this law gives it the
general predicate. It was the head of
generated/basejump/bsg_noc_BaseJumpSTL_bsg_ready_and_link_async_to_wormhole.sv
(`wormhole_width_lp = $bits(wormhole_packet_s)`: uhdm-cmp `LHS: <null> RHS:
ref_typespec`) and of bsg_tag_BaseJumpSTL_bsg_tag_trace_replay.sv
(`bsg_tag_header_width_lp`), pass 405's residue 1 and the face pass 410
reported.

Grid cases/BF: bf01 (a "inv" default), bf02 (a defaulted parameter), bf03
(a type parameter), bf04 (a typedef of parameter width), bf13 (an
interface), bf14 (two instances, one overriding) NOT_EQUAL -> STRICT_EQUAL;
bf05 (`$bits(v)` of a signal of parameter width) closer (dump distance 31 ->
4), its next head the definition listing's `$bits` argument ref_obj with no
actual where golden binds it to the net (later in the walk; residue); bf16
(the parameter read by a continuous assignment) closer (39 -> 12), the
elaborated read still typed (residue); controls unchanged at pristine's
bytes: bf06 (a struct of constant width), bf07 (a typedef of constant
width), bf08 (`$bits(t) + 1`), bf09 (`$bits` of a constant-width signal),
bf10 (a package type), bf11 (an operation over a parameter-width struct),
bf12 (a typed parameter), bf15 (a package parameter), bf17 (a parameter-port
localparam, NOT_EQUAL on both at another head).

## Cases (every case's first line names its law)

| group | law | cases |
|---|---|---|
| EX | § expectActionBlockStmts421 | ex01-ex07 |
| HS | § hpTrailIpsSysArgNames421 | hs01-hs09 |
| PB | § paramInitSysArgBitSelAtIndex421 | pb01-pb06 |
| BF | § bitsDefNoFoldNoTs421 | bf01-bf17 |

Drivers: `drivers/case.sh <casedir> <binary> [ENV=V...]` (golden by md5 of
the case text, prints exit code, uhdm-cmp lines, dump distance, md5 and the
strict verdict), `drivers/grid.sh <pristine> <law> <out>` (pristine, law,
`R11U421_OFF`, the group's own switch), `drivers/runner.sh` (the sv-tests
runner on a paths file after three quiet readings), `drivers/heads.sh` (uhdm-cmp
heads of runner rows), `drivers/scan.py` (the fence-filtered source scan),
`drivers/predict.sh` (the prediction trace run), `drivers/show.sh`.

## Goal 1

- No sv-tests row is open on this ground. All 75 SURELOG_ONLY rows of
  results/golden_svtests.csv carry a slang front-end `error:` diagnostic (the
  detail column; none names an exporter shape), and no BOTH_REJECT or
  SLANG_CRASH row holds an exporter message (`grep -ci 'unsupported\|exporter'`
  reads 0 on both sets).
- The probe goal-1 shapes are unchanged and not forced: `C::mk().arr[1]` and
  `u.mk(x).a[2]` exit 4 in our exporter, 0 in upstream slang and 3 in Surelog
  (a syntax error), so golden has no shape to transcribe; `this.mk().inner.s`
  exits 0 since pass 415.
- No law of this pass changes an exit code: the four laws only re-place,
  rename or drop objects the pristine path already built; the prediction run
  over every probe case, every uhdm2rtlil row and the candidate Surelog rows
  traced no firing (evidence/predict_trace.txt) and the sweep's exit codes are
  in the stage csvs.
- Black-parrot: the six rows stay SURELOG_CRASH (Surelog dies first) and
  pass 403's size guard stays. Measured alone on a quiet machine with the
  law binary: bp_unicore exits 3 in 14.8 s at 814 MB peak resident memory
  with the same `basic_string::substr` error; no memory-bounded export was
  found, so the guard was not lifted.
- generated/rsd/rsd.sv is SURELOG_CRASH (Surelog dies first): not reachable.

## Heads at the base (evidence/svtests_heads_base.txt)

The runner was rerun with the pristine binary on all 89 open rows (86
DIFFERENT, 3 STRICT_NOTEQUAL) with `--keep-golden`; the uhdm-cmp head of each
is listed there. Decoded per row below; the faces on this ground were
written, the others are reported.

## Residues on this ground (ranked; all wrong on pristine too, none moved away)

Reduced residue cases (no law landed; first line `// residue`):
evidence/residue_cases ra01/ra02 (interface assertion and its module
control), rp01/rp02 (program binding and foreach), rd01 (decoder_dor's
naming), rf01 (parenthesized port-connection base), rf02 (elaborated port
connection folds), rt01 (type-parameter variable initializer size).

1. generated/basejump/bsg_tag_BaseJumpSTL_bsg_tag_trace_replay.sv: after
   § bitsDefNoFoldNoTs421 its head is the sister's parenthesized
   port-connection bound (below); still DIFFERENT, toward.
2. The elaborated port connection of a dotted path with an indexed part
   select (HS/hs01 to hs04, hs09): golden folds the base and the width to
   constants in the INSTANCE's high_conn (`h.cid[0+:2]`, a ternary width's
   constant spanning its taken branch, `di[(width_p-1)-:c]` base INT 7 at the
   `width_p` token and width UINT 2 size 32) and names the path with the
   folded text, where we keep the expressions; writer not decoded (the
   elaborated port connection is ModuleEmit's caller of emitExpr). And a
   whole-width system call renders EMPTY in the definition-view name
   (`h.cid[0+:]`), which § hpIdxBaseHierPathEmpty94's gate abstains on when
   the base is a constant (hs09).
3. A parameter left typespec-less by § bitsDefNoFoldNoTs421 read in an
   elaborated continuous assignment keeps a ref_typespec on the folded copy
   (BF/bf16, toward): the fold site was not found among the param-read fold
   branches of ExprEmit in this pass.
4. `$bits(v)` of a signal of parameter width (BF/bf05): the definition
   listing's argument ref_obj has no actual where golden binds it to the net.
5. A parameter-init `$bits(P[1])` (PB/pb03, pb04): golden's own value 1 and
   the packed parameter default constant's typespec; the law moves only the
   span.
6. Program scope (v11u417 VC/vc04, vc24, VT/vt19, and fresh probes): golden
   leaves EVERY reference in an uninstantiated top-level program's process
   unbound (`program top; int n; initial n = 1; endprogram`: golden's
   ref_obj n has no actual), its foreach array and loop variable ref_vars over
   unsupported_typespecs and mints no implicit net; the foreach typing is
   StmtEmit's, but no row moves while the binding face (ModuleEmit's
   program listing, `uninstProgDefs`) stands. An instantiated program's loop
   variable is an array_var in golden (not decoded).
7. `__LINE__` after a `` `line N `` directive (v11u416 VL/vl07): golden
   reads N+1 (Surelog counts the directive's own line) where slang's value is
   N; the value is a parameter's folded value and every fold of it downstream,
   so a transcription has to correct the value at its source (not written).
8. uo18 (a port-list localparam over an int-typed keyword-less parameter:
   golden size 32, ours the computed fold's 64), v11u419 VO/vo08, vo02, VP/vp05,
   VA/va01, va05, va08, va11, VC/vc02 and r11u419 IA/ia17: measured on the law
   binary, unchanged heads (pass 419's descriptions stand).
9. Carried backlog unchanged: passes 417, 415, 413, 411, 409, 407, 405, 403
   and 401 residues as their READMEs list them; scr1's unsized `'d` localparam
   at golden size -1 (condition still unknown), tnoc 333:14, p733 (defparam),
   fx68k's `CF` parameter listed under the design.

## Sister-ground faces (reported, not written)

- chapter-16/16.12--property-interface-uvm.sv and -prec-uvm.sv (the largest
  open UVM face, uhdm-cmp 659513 lines): the head is NOT a parameter copy. In
  the interface definition golden lists the interface's concurrent assertion
  (`assert property (@(posedge clk) ...) else `uvm_error(...)`) under
  vpiAssertion, an assert_stmt with full name `work@top.dif` parented at the
  elaborated instance; ours wraps it in an `always` under vpiProcess. Reduced
  without UVM (evidence/residue_cases/ra01, the module control ra02): `interface ifc(input bit clk, input read, write); assert
  property (@(posedge clk) !(read & write)) else $error("x"); endinterface`
  (NOT_EQUAL, 205 uhdm-cmp lines; the same assertion in a module is
  STRICT_EQUAL). Call site: ModuleEmit emitInterfaceInstance's process loop
  (`emitProcess(member.as<ProceduralBlockSymbol>(), procParent, procPrefix,
  netMap)` after § ifacePortViewNoProcs283), which takes every
  ProceduralBlock, where the module road (emitAssertion first, the
  ConcurrentAssertionMember fence) lists assertions.
- bsg_async_fifo, bsg_launch_sync_sync and bsg_tag_trace_replay: a
  PARENTHESIZED base of an indexed part select in a definition-view
  generate-block port connection (`.w_data_i(w_data_i[(width_p-1)-:c])`) is
  written as one raw-text ref_obj `(width_p-1)`; golden an operation spanning
  inside the parentheses with operands named through the select
  (`work@top.ctrl.u.d.di.width_p`). Writer: TypeEmit emitSyntaxExpr.
- bsg_sync_sync: a macro usage `` `bss_max_block `` written as a ref_obj by
  emitSyntaxExpr; golden the constant 8.
- bsg_wormhole_router_decoder_dor (STRICT_NOTEQUAL fullname(1)): in a
  definition-view gen_for localparam (ModuleEmit emitDefGenStmts' branch
  listing -> emitSyntaxExpr) a reference OPERAND of an operation in a
  bit-select index is named through the select, `rof.cord_markers_pos_p.i`
  (`P[i+1]`); a bare index stays `rof.i`. Reduced: evidence/residue_cases/rd01
  (`localparam A = P[i+1];` in a for-generate), golden `work@top.rof.P.i`.
- bsg_mesh_router (STRICT_NOTEQUAL col(1)): the same definition-view
  gen_for localparam listing spans a bit_select argument of `$bits` over the
  whole select where golden anchors it at its index (this pass wrote the
  module-level case, § paramInitSysArgBitSelAtIndex421; PB/pb01, pb02 and
  pb06 are the generate-block shape).
- chapter-7/structures/unpacked/default-value.sv: an unpacked struct member's
  default (`bit [3:0] lo = c;`) is a ref_obj `c` (unparented) on the
  typespec_member, whose span extends to the default's end; ours writes none
  (TypeEmit's struct member typespecs).
- hdlconvertor p88 and p124: the elaborated variable initializer of a
  variable typed by a type parameter is sized by the parameter's DEFAULT type
  (`p2 j = 0` with `p2 = shortint` overridden to int: golden size 16, ours
  32; byte -> 8, logic [3:0] -> 4): ModuleEmit's elaborated variable
  initializer chain.
- generic/class/class_test_51.sv: `$bits(int)` in a class parameter is
  emitted by UhdmExporter emitClassParameters through emitSyntaxExpr (a
  ref_obj `int`), golden the folded constant (pass 407's decode, BK cases).
- p600: a typedef range bound `1'b1` (TypeEmit makeBoundConst: golden BIN
  size 1 at the literal, ours UINT 1 size 64 at its first character).
- p193_2: a class method whose return type is a type parameter: golden a
  ref_var, ours a class_var (TaskFuncEmit).
- The UVM rows still DIFFERENT (uvm-examples, testbenches, uvm_classes_0/2/3,
  easyUVM): package and class listing heads, unchanged.

## Process

- Read RESUME.md sections 6 and 9, tests/README.md and tests/probe/README.md
  first. Worktree /tmp/wt_r11u421 at d0d46b5c; scratch /tmp/r11u421_*.
- No pristine sweep: the pristine reading is the master's control
  /tmp/intr11u419. The worktree's base build was made (needed to build the
  law) and is byte-identical to the main tree's binary.
- Targeted runner calls only on the rows worked (the 89 open rows once with
  the pristine binary to read their heads, then 1 to 3 rows per law with
  intermediate binaries), each after three quiet readings; one prediction
  trace run (drivers/predict.sh) and one full sweep, both on the final law
  binary, each launched after three quiet readings (the first prediction and
  the first sweep attempt found the sister's sweep live and waited; the first
  sweep attempt also tripped on its own script name matching the quiet check,
  launched nothing and was renamed).
- A note on the fence: one early `grep -rlE` for expect statements over
  tools/probe and tests/probe was restricted to files named dut.sv but was not
  filtered on the fence list first; afterwards the path lists of both trees
  were checked: 14 files whose path holds a fenced name exist there, none of
  them named dut.sv, so none was opened. Every later tree-wide reader
  (drivers/scan.py, drivers/earlier.sh, the binary audit) built its path list
  and filtered it on the fence list, read into /tmp/r11u421_fenced.txt by a
  program without printing it, before opening a file. No fenced test was
  named, opened or run; no other agent's process was touched.
