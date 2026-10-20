# r11u415 — expression/parameter ground, the eighth sv-tests pass on this ground

Base 4f83b198 (pass 413 on top of pass 416). Ground: src/ExprEmit.cpp,
src/StmtEmit.cpp (EmitHelpers.h and ParamEmit.cpp unchanged). Seven laws, each
read through src/LawSwitch.h as `lawOn(415, "R11U415_<LAW>_OFF")`;
`R11U415_OFF` drops all of them, `R11U415_TRACE=<dir>` logs each firing
through `lawTrace(415, ...)`. No src/R*.h, no LawState.h section, no getenv,
no reader function; include/, TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit
and uhdm_main.cpp unchanged.

Binaries: pristine = the main tree's build at the base (md5
72d4f6bae580986adaa074230873072e, rebuilt in the worktree to the same md5 and
frozen); final law binary `law7` md5 3bfb5860fd8461254d6babfe48feb443.
Intermediate binaries law1 to law6 ran only on the case grids and on the
targeted sv-tests rows.

## Verdict per targeted row

| row | before (base) | after (law7) | law |
|---|---|---|---|
| generated/hdlconv_std2017/hdlconvertor_std2017_p292.sv | DIFFERENT | EQUAL (IDENTICAL, strict equal) | § pkgLetCallFuncCall415 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p765.sv | DIFFERENT | DIFFERENT, three faces gone, head moved to the sister's task listing | § labeledCallStmtLabelDropped415, § disableHierNetFirstName415, § externTaskCallUnlinked415 |
| v11u413 VC/vc13 (`this.mk().s`, goal 1 probe face) | exit 4, NOT_EQUAL | exit 0, STRICT_EQUAL | § thisCallResultMemberDropped415 |
| r11u416 DC/dc13 (`W'(x[i])` in a generate-loop port connection, goal 1) | exit 4, STRICT_EQUAL partial db | exit 0, same bytes | § badCastSizeNoExpr415 |
| v11u405 VD/vd03 (`disable top.b1;`) | NOT_EQUAL | STRICT_EQUAL | § disableHierNetFirstName415 |

The sv-tests stage on law7 (evidence/svtests_law7_summary.txt): EQUAL 1808
-> 1809, DIFFERENT 126 -> 125, STRICT_NOTEQUAL 6, BOTH_REJECT 303,
SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
regressions 0, conversions 1 (generated/hdlconv_std2017/hdlconvertor_std2017_p292.sv
DIFFERENT -> EQUAL, § pkgLetCallFuncCall415), changes 0. The fresh row:
`generated/hdlconv_std2017/hdlconvertor_std2017_p292.sv,EQUAL,,equal`
(results/ untouched; the master promotes).

## Laws

1. § thisCallResultMemberDropped415 (ExprEmit, R11U415_THISCALLMEMBER_OFF).
   A member of a call made through `this` or `super` (`this.mk().s`,
   `super.mk().s`) is the call alone to Surelog: the method_func_call the
   call writes without the member (golden TC/tc01 method_func_call (mk)
   9:17-9:19 with the prefix constant `this` STRING size 4, tc04 `super`),
   the member dropped. The exporter rejected the base ('member access
   base') and exited 4 where upstream slang accepts. Site: the class-call
   branch of the member-access emitter, beside § classCallResultMemberRef413.
2. § badCastSizeNoExpr415 (ExprEmit, R11U415_BADCASTSIZE_OFF). A size cast
   whose written width name binds in no scope the exporter tries (`W'(x[i])`
   in a port connection of an instance in a generate loop, and at module
   scope: the instance content binds in the child's body) while slang
   resolved the conversion is Surelog's bare integer_typespec at the name
   with no vpiExpr (golden BC/bc01 7:15-7:16 under work@top.g[0].u). The
   object was already written that way (the partial database at exit 4 was
   STRICT_EQUAL); the emission of the unbound width only noted `expression
   kind: Invalid`. The law keeps the emission and withdraws the note it
   added (only when that emission added it, the width is a plain or scoped
   name, the size expression is Invalid and slang's conversion type is
   valid), so every byte stays and only the exit code moves.
3. § pkgLetCallFuncCall415 (ExprEmit, R11U415_PKGLET_OFF). A call to a `let`
   declared in a PACKAGE is not substituted by Surelog (its compileTfCall
   finds no let in the calling scope): an unqualified call reached through
   an import is an unresolved func_call named by the let, spanning the whole
   call, with the written arguments in written order bound at their
   call-site spans (golden p292 func_call (valid_arb) 14:5-14:58 with the
   three named arguments unwrapped; LT lt01, lt02, lt04, lt06, lt08), and a
   package-qualified call `pex::sum2(a, b)` is an unbound ref_obj named
   `pex::sum2` spanning the written scope through its last `::`, the
   arguments dropped (lt03). slang expands a let call in place (the
   expansion's syntax is the let's body; the call syntax is gone), so the
   law indexes, once per run and only when some package declares a let,
   the design's invocations of each package let's name, and finds the call
   site by its arguments: every written argument (ordered or named) a plain
   identifier naming the net or variable slang substituted for that formal,
   exactly one call site matching. Anything else abstains (lt07: an
   expression argument; lt09: two identical calls). Module-local lets keep
   emitLetInlined (lt05, byte-identical control).
4. § labeledCallStmtLabelDropped415 (StmtEmit, R11U415_LABELCALL_OFF). A
   LABELED call statement (`callr: b.Read(raddr);`, `cf: f(a);`,
   `callr: t(a);`, `sys: $display(...)`, `lc: h.run(3);`, `cv: void'(f(a));`)
   has no named_begin and no name in Surelog: the label is dropped and the
   call is written as the plain statement, its references scoped without
   the label (golden p765 method_func_call (Read) 61:9-61:13 with ref_obj
   work@cpuMod.raddr; LB lb01 to lb06). Site: the labeled-statement test of
   the Block case, before the labeled-assertion branch.
5. § disableHierNetFirstName415 (StmtEmit, R11U415_DISABLEHIER_OFF). A
   hierarchical disable target (`disable mem1.a.Read;`, `disable
   sb.Write;`, `disable top.b1;`) mints its implicit net named for the
   path's FIRST written identifier, one net per name however many disables
   go through it (golden p765 logic_net work@top.mem1 75:9-75:20; DN dn01,
   dn02 one net u1 for two disables, dn04, dn05). The span stays the whole
   path. Pristine named the net after the target symbol (Read, Write, b1).
6. § disableHierNoTaskExpr415 (StmtEmit, R11U415_DISABLEHIERTASK_OFF). A
   task named through a hierarchical path is not linked: golden's disable
   carries no vpiExpr there (DN dn01, dn02, dn05), where
   § disableTargetScopeChain405 had linked the task object.
7. § externTaskCallUnlinked415 (ExprEmit, R11U415_EXTERNCALL_OFF). A call to
   an interface's EXTERN subroutine prototype (`extern forkjoin task
   countSlaves();` called as `countSlaves;`, `extern task Write(...)` called
   as `Write(8'h5)`), whose body lives in an exporting module, is an
   unresolved func_call in Surelog: named by the prototype, spanning the
   call, with its written arguments and no vpiTask/vpiFunction link, even
   for a task (golden p765 func_call (countSlaves) 26:1-26:12; FJ fj01,
   fj02). Pristine wrote a task_call linked to a name-only task shell.

## Grid (evidence/grid_law7.txt, drivers/grid.sh)

36 case dirs in BC, DN, FJ, LB, LT and TC, every first line `// § <law>`.
Each line: pristine and law7 (exit code, uhdm-cmp line count, dump lines
away from golden, md5, strict verdict), R11U415_OFF -> pristine's bytes and
exit code, the group's own switch -> pristine's bytes and exit code.

| group | law | cases | pristine -> law7 |
|---|---|---|---|
| TC | § thisCallResultMemberDropped415 | tc01-tc05 (`this.mk().s` return, with an argument, as an operand in a task, `super.mk().s`, in an if condition), tc06 control `this.mk()` | 5 exit 4 NOT_EQUAL -> exit 0 STRICT_EQUAL; tc06 byte-identical |
| BC | § badCastSizeNoExpr415 | bc01 the dc13 shape, bc02 `W'(x[i+1])`, bc03 `(W)'(x[i])`, bc04 a localparam width, bc05 module scope, bc06 control `2'(x[i])` | 5 exit 4 -> exit 0, bytes identical (STRICT_EQUAL partial databases now complete runs); bc06 identical |
| LT | § pkgLetCallFuncCall415 | lt01 p292's shape, lt02 positional, lt03 `pex::sum2`, lt04 explicit import in always_comb, lt05 module-local control, lt06 conditional body, lt07 expression argument, lt08 two calls, lt09 two identical calls | lt01-lt04, lt06, lt08 NOT_EQUAL -> STRICT_EQUAL; lt05, lt07, lt09 byte-identical (abstain/control) |
| LB | § labeledCallStmtLabelDropped415 | lb01 task, lb02 void-cast function, lb03 system call, lb04 interface method call, lb05 class method call, lb06 function, lb07 labeled assignment, lb08 labeled if | lb01-lb03, lb05, lb06 NOT_EQUAL -> STRICT_EQUAL; lb04 toward golden (98 -> 62 dump lines, head now the modport port typespec, sister ground); lb07, lb08 byte-identical (not calls) |
| DN | § disableHierNetFirstName415, § disableHierNoTaskExpr415 | dn01 module-instance task, dn02 two tasks through one instance, dn03 local block control, dn04 `disable top.blk`, dn05 interface task | dn01, dn02, dn04, dn05 NOT_EQUAL -> STRICT_EQUAL; dn03 identical |
| FJ | § externTaskCallUnlinked415 | fj01 forkjoin task, fj02 extern task with an argument | both NOT_EQUAL toward golden (22 -> 16, 24 -> 18 dump lines); the head moved later to the sister's out-of-body interface task listing in the exporting module (uhdm-cmp 28 -> 85 and 60 -> 85 lines: a later head, nothing moved away) |

R11U415_OFF restores pristine's bytes and exit code on 36 of 36; each
group's own switch on 36 of 36.

Downstream (evidence/downstream_cases.txt, `downstream_uhdm2rtlil.one` on 19
class-free cases): LT lt02, lt03, lt04, lt06, lt08 STATUS_DIFF -> IDENTICAL,
FJ fj02 EQUIVALENT -> IDENTICAL, BC bc01-bc05 EQUIVALENT on both (same
bytes), bc06, LB lb01, lb03, lb06 and DN dn01, dn02, dn04, dn05 IDENTICAL on
both; none worse.

Earlier-pass case dirs (evidence/earlier_pass_cases_md5_pristine_vs_law7.txt):
2194 fence-filtered dut.sv dirs under tools/probe/r11u401repro to
v11u416repro, pristine vs law7 by exit code and md5: 3 move, all targeted:
r11u416 DC/dc13 (exit 4 -> 0, same bytes), v11u413 VC/vc13 (exit 4 -> 0,
STRICT_EQUAL) and v11u405 VD/vd03 (`disable top.b1`, NOT_EQUAL ->
STRICT_EQUAL, the trace naming disableHierNetFirstName415).

## Prediction before the sweep

Fence-filtered scan of 41853 source files (the Surelog tests and
third_party tests, Surelog's UVM, uhdm2rtlil tests, tests/probe, sv-tests
tests and third_party; evidence/prediction_scan_*.txt):

- `this.`/`super.` call with a member (THIS): 20 files, every hit a comment
  or a multi-line port list, no corpus shape: 0 movers.
- hierarchical `disable a.b` (DISABLEHIER): 10 files, the corpus hits are
  comments; p765 the only shape: 0 corpus movers, p765 in sv-tests.
- `let` (LET): no corpus file declares a package let; sv-tests p292 the
  only one: 0 corpus movers.
- an interface extern subroutine (EXTIF): Surelog Verilator
  t_interface_modport_export.v (the Verilator row is SLANG_REJECT in both
  modes) and p765: 0 corpus movers.
- the bad-cast-size note withdrawal moves no byte by construction.
- labeled call statements: the text scan is too noisy to name rows (case
  items); measured by the trace below.

Predicted: 0 byte movers in probe, surelog, uhdm2rtlil and downstream;
sv-tests movers p292 and p765.

## Gates (law7, one full sweep from the worktree, workdir /tmp/r11u415_sw)

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69, regressions 0, conversions 0,
  changes 0; probe.csv byte-identical to the control's.
- surelog: default CMP_EQUAL 480 + 0, testflags 474 + 0, regressions 0,
  conversions 0, changes 0; surelog.csv differs from the control only in the
  two LowMem log-path texts.
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0,
  not identical and not excused 0; csv identical to the control.
- byteverify (SELFCHECK=1) against the control dirs: surelog 0 of 962,
  uhdm2rtlil 0 of 1608, downstream 0 of 805 (selfcheck 961, 1607, 804
  flagged). The prediction (0) holds.
- canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil);
  ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
- binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 naming law7
  (2 naming slang-uhdm only in the UVM checkout path of a Surelog line, 48
  with no slang line), uhdm2rtlil 1740 of 1740.
- The sweep's svtests stage skipped (a worktree has no sv-tests sibling and
  no UVM tree); it ran alone through the main tree's
  scripts/check_svtests.py read-only (main tree at the base, its script and
  results/golden_svtests.csv identical to the worktree's), SLANG_UHDM=law7.

Trace census (R11U415_TRACE over all five stages, evidence/trace_law7.txt):
three runs fired a law. probe: tests/probe/r11u47repro/branches/g2
(§ badCastSizeNoExpr415 on `it_t'(8'd3)`, `it_t` a `localparam type`
union: exit 4 -> 0 with the database byte-identical, md5 44e2adeaa6a8 on
both, the case EQUAL on both; not named before the sweep: the prediction
named byte movers, and this one moves only the exit code). sv-tests: p292
(§ pkgLetCallFuncCall415, the conversion) and p765
(§ labeledCallStmtLabelDropped415 on callr and callw,
§ disableHierNoTaskExpr415 on Read and Write, § disableHierNetFirstName415
minting mem1 and sb_intf, § externTaskCallUnlinked415 on countSlaves). No
firing in surelog, uhdm2rtlil or downstream: the byteverify zero agrees.

Away census on the sv-tests databases the stage kept (152 rows, all
DIFFERENT or STRICT_NOTEQUAL; the databases embed the work directory, so
bytes differ on every row): the path- and id-normalized dump of law7 against
the control on the 74 non-UVM rows that dump quickly plus
chapter-16/16.2--assert-uvm: 74 identical, 1 different, p765 (the traced
row): 204 -> 110 dump lines from golden, its uhdm-cmp head moved later
(28 -> 285 lines, the first difference now the exporting module's task
listing). The UVM rows, tnoc, rsd, 8.24 and the chapter-18/20 rows were not
dumped; no law fired on them (trace).

## Goal 1 on this ground

- this.mk().s: written (§ thisCallResultMemberDropped415).
- `W'(x[i])` in a generate-loop port connection (r11u416 DC/dc13): written
  (§ badCastSizeNoExpr415); module scope (BC/bc05) exited 4 too.
- C::mk().arr[1] and u.mk(x).a[2] ('element select base'): Surelog rejects
  both, upstream slang accepts; not forced (no golden shape).
- A package cast outside a parameter declaration (evidence/residue_cases/PC
  pc01 a package function's `return e_t'(1)`, pc03 a package variable's
  initializer, pc05 a module continuous assign of an imported enum cast,
  plus pc02 a default argument and pc04 an alias cast in a function, both
  STRICT_EQUAL): every one exits 0 on pristine, so there is no goal-1 face
  there; pc01, pc03 and pc05 are NOT_EQUAL on the value golden folds
  (pass 407's partial return folds, pass 411's enum-cast value). The two
  package-cast laws were not widened.
- Black-parrot: bp_unicore alone on the law binary with the guard on exits
  3 in 16.1 s at 795 MB max RSS (`basic_string::substr: __pos (which is 18)
  > this->size() (which is 17)`), no memory-bounded export found; the guard
  stays (evidence/black_parrot_bp_unicore.txt). rsd: SURELOG_CRASH, not
  ours.
- Every SURELOG_ONLY row of results/golden_svtests.csv (75) carries an
  upstream slang front-end diagnostic (expected a declaration name, unknown
  module, undeclared identifier, redefinition, randc constraints, real
  indexing, ...); one names slang-uhdm only in the checkout path. None is an
  exporter error: nothing on this ground or the sister's.

## Residues (all wrong on pristine too; none moved away)

Ranked by sv-tests rows they hold:

1. The UVM rows (chapter-16 *-uvm, uvm-examples, uvm_classes, testbenches,
   easyUVM, 8.24): heads measured on 6 of them at law6, all on the
   module/type ground: interface port typespecs (16.2--assert-uvm
   logic_typespec 38:12), the package listing (uvm_vif_config_db), class
   listings (uvm_sequence_library, easyUVM sequencer, 8.24 test_cls),
   interface instances (uvm_agent_class_1). Sister ground.
2. The basejump rows still DIFFERENT, measured at the base
   (evidence/svtests_nonuvm_heads_pristine.txt): module typedef ranges with
   `$clog2`/`$bits` folded where golden keeps the calls (comm_link,
   control_master), emitSyntaxExpr's raw-text bounds in the macro rows
   (`(i`, `(width_p-1)` ref_objs: async_fifo, mask_write_var,
   mask_write_byte_assoc, launch_sync_sync), the gen-for increment written
   `i++` as an assignment in golden (pipeline_stall_collapse), the instance
   parameter order (mux_one_hot) and the computed localparam typespecs
   (ready_and_link_async_to_wormhole, tag_trace_replay): TypeEmit and
   ModuleEmit, sister ground.
3. decoder_dor's last strict field: decoded here
   (evidence/residue_cases/GL gl01, gl02, gl06 STRICT_NOTEQUAL fullname,
   gl03-gl05 equal controls): in a definition-view generate block, a
   localparam initializer that IS a select whose index is an OPERATION
   names the operation's ref_obj operands under the select
   (`work@top.g.P.i` for `P[i+1]`, `P[i-1]`, `P[2*i]`, `P[i+1]`); a bare
   index (`P[i]`), a select nested in an operation (`P[i+1] + 1`) and a
   module-scope localparam keep the scope prefix. The writer is TypeEmit's
   emitSyntaxExpr (called from ModuleEmit's gen-block localparam listing):
   sister ground. mesh_router's col(1) (a bit-select inside `$bits` in a
   generate localparam inside a macro) is the same writer.
4. p765 (DIFFERENT after this pass): the exporting module's out-of-body
   interface tasks (`task a.countSlaves()`) golden lists as an unnamed task
   work@memMod in the module's vpiTaskFunc (TaskFuncEmit / ModuleEmit,
   sister ground); FJ fj01, fj02 hold the same head.
5. Labeled non-call statements (LB lb07 `asg: o = a;`, lb08 `lif: if ...`;
   pass 403's VM/vm12): golden names the statement by the label, spans it
   from the label and scopes the body's references through the label but
   not an if condition's; decoded, not written.
6. A package let called twice with the same identifier arguments (LT lt09)
   or with an expression argument (lt07): the call site cannot be told
   apart from the expansion; abstains.
7. chapter-18 18.14--random-stability_1 now heads at a class property
   `int tab1[5] = {1, 2, 3, 4, 5}` (golden the concatenation at the element
   reg with constants of size 32; evidence/residue_cases/AI): the variable
   initializer placement is TypeEmit's (§ arrStringInitAtElem414's site),
   sister ground; 18.5.9 and 18.5.13 head at uvm_reg_block::find_blocks'
   foreach (pass 413's decoded FB face, StmtEmit; not written here).
8. class_test_49: a typed class parameter's typespec at its keyword
   (`parameter reg P = '1` logic_typespec 26:13-16; evidence/residue_cases/RG)
   and the class localparam `f(glb::arr[N]) + 1` call: both in UhdmExporter's
   emitClassParameters, sister ground.
9. p599: the `$realtobits` call in a net declaration assignment carries the
   net's typespec in golden, and the LHS net differs (ModuleEmit's
   net-declaration assignment); p600's package typedef range bound `1'b1`
   (TypeEmit); utd-sv primitives' instance-array connection `{bushigh,
   buslow}` (ModuleEmit); typedef_test_9 ($unit parameters in typedef range
   bounds, TypeEmit); class_test_51 and class_test_53 (UhdmExporter): sister
   ground.
10. Carried on this ground, unchanged: tnoc at tnoc_pkg.sv 333:14 (golden's
    evaluated 241), scr1's unsized 'd localparam size -1, p733 (defparam
    values), fx68k, p88/p124 (sister: type-parameter variable initializer),
    p179/p193_2/p203 (class variable spans and typespecs), 5.10
    replication sizes, default-value, and the backlog of passes 401 to 413
    listed in their READMEs.

## Sister-ground faces (reported, not written)

- TypeEmit `emitSyntaxExpr` (bit_select / indexed part-select branch, from
  ModuleEmit's gen-block localparam listing): the operand names of an
  operation index under the select (decoder_dor's last field; GL cases) and
  the indexed part-select's whole span `P[i*2+:2]` (gl06 5:23-5:32 where we
  write 5:25-5:31).
- TaskFuncEmit / ModuleEmit: the exporting module's out-of-body interface
  task listing (p765 memMod; FJ).
- ModuleEmit: interface modport port typespec (LB lb04), net-declaration
  assignment typespec (p599), instance-array connection concatenation
  (utd-sv primitives).
- TypeEmit: the unpacked int array concatenation initializer at the element
  reg (18.14--random-stability_1; AI cases).
- UhdmExporter `emitClassParameters`: typed class parameter typespecs and
  class localparam calls (class_test_49; RG cases).

## Process

Within the budget: one full five-stage sweep on the final law binary (the
svtests stage run alone right after, through the main tree's script, since
the worktree's sweep skips it), byteverify once against the master's control
/tmp/intr11u413, no pristine build beyond the md5 check of the worktree
build and no pristine sweep. Intermediate binaries ran only the case grids,
the 2194 earlier-pass case dirs and targeted runner calls (p292, p765, six
UVM rows for their heads). The fence list was read by a program into a file
and never printed; every tree-wide list was filtered on it before any file
was opened. No other agent's process was touched; the one process stopped
was this pass's own uhdm-dump of tnoc (a slow dump), by its PID.

Drivers: drivers/case.sh (golden cached per dut.sv + optional TOP file,
exit code, uhdm-cmp line count, dump lines away, md5, strict verdict),
drivers/grid.sh, drivers/show.sh, drivers/ddiff.sh, drivers/gold.sh.
