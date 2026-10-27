# r11u441 — expression/parameter ground, sv-tests campaign pass 441 (implementer)

Base d1d6686a (pass 439). Production file: src/ExprEmit.cpp only (EmitHelpers.h,
StmtEmit.cpp and ParamEmit.cpp unchanged; nothing in include/). Three laws, each
read through src/LawSwitch.h (`lawOn(441, "R11U441_<LAW>_OFF")`, `R11U441_OFF`
drops the pass, `R11U441_TRACE=<dir>` logs each firing through
`lawTrace(441, ...)`); no src/R*.h, no LawState.h section, no getenv, no reader
function.

## Verdict per targeted row

- generated/basejump/bsg_comm_link_BaseJumpSTL_test_bsg_comm_link_checker.sv:
  STRICT_NOTEQUAL differ:endline(1) -> **EQUAL** (CONVERSION), through
  § sysCallEmptyArgEndPrevTok441. Fresh row of the law sweep:
  `generated/basejump/bsg_comm_link_BaseJumpSTL_test_bsg_comm_link_checker.sv,EQUAL,,equal`
  (the runner reads uhdm-cmp EQUAL, strict equal, agreement IDENTICAL).
  NO STRICT_NOTEQUAL sv-tests ROW IS LEFT (EQUAL 1912 -> 1913, STRICT_NOTEQUAL 1 -> 0).

The head at the base (build/uhdm-strictcmp on the kept pair, pristine binary):

    #5386 endline
      A: 10 constant  test_bsg_comm_link_checker.sv 120 28 119 86 0 64 INT:0 7
      B: 10 constant  test_bsg_comm_link_checker.sv 120 28 120 28 0 64 INT:0 7

the empty argument of `$display(..., core_1_period_p,` (line 119, ending at
column 57) `\n                           ," (Cycles Per Word) " ...` (line 120).

## Heads at the base

The 27 DIFFERENT rows at the base were re-read (the master's control
r11u439 sweep and a runner call on the two basejump rows with --keep-golden).
None first differs on this ground:
- bsg_scheduler_dataflow and bsg_nonsynth_mem_1rw_sync_assoc: golden lists the
  never-instantiated definition (work@bsg_scheduler_dataflow, 1034 dump lines;
  work@bsg_nonsynth_mem_1rw_sync_assoc, 457 lines) as a module_inst in
  uhdmallModules and ours lists nothing: the admission gate in UhdmExporter.cpp
  (§ undefaultedDefInvalidInst404 / § undefaultedPlaceholderRetry440,
  `abstain-unbound`) is the sister's ground; once it admits the body the
  writer shapes for the unbound name `bypass_lo` (an InvalidExpression with no
  child) and the nonblocking write to an associative element (an
  InvalidStatement) are this ground's, decoded only as far as this.
- the 16 uvm-examples rows, control_slave, the 3 uvm_scoreboard rows, easyUVM,
  tnoc, p733 and p737: pass 440's and pass 439's readings stand (sister ground or
  Surelog artefacts; not re-decoded).

## Laws

### § sysCallEmptyArgEndPrevTok441 (R11U441_EMPTYARGEND_OFF) and § emptySlotArgEndPrevTok441 (R11U441_EMPTYSLOTEND_OFF)

Decoded from Surelog: CompileHelper::compileTfCallArguments mints the INT:0
placeholder of an empty positional argument and calls
`populateCoreMembers(argumentNode, argumentNode, c)` on the empty Argument node.
That node's ANTLR source interval is [a, a-1]: SV3_1aTreeShapeHelper::getFileLine
takes the start from token a (the next comma or the closing parenthesis) and the
end from `ParseUtils::getEndLineColumn(stream->get(a-1))`, token a-1 of the FULL
token stream, hidden channels included: that token's start line and its start
column plus its length plus one, so a token that spans a newline ends past its
own line's end. The lexer (grammar/SV3_1aLexer.g4) keeps one `White_space`
token per run of `[ \t\n\r]`, a `Block_comment` as one token and a
`One_line_comment` together with its newline as one token. So:
- `f(a,,b)` and `f(a, , b)`: the end is the start (zero width; pass 401's and
  pass 24's spans were right);
- `f(a,\n   , b)`: the end is on the earlier line, at the whitespace run's start
  column plus its length (checker: run of 28 characters at 119:58 -> 119:86);
- `f(a, // c\n   , b)`: the comment token owns the newline, so the run is the
  indentation only and the span is zero-width again (EA/ea06, pristine right);
- `f(a, /* c */\n   , b)`: the run after the comment (EA/ea07);
- a carriage return is not counted (Surelog's preprocessor output carries none;
  EA/ea14 CRLF golden 5:35 where LF counting gives 5:36).

The model reads the next token's leading trivia (slang splits whitespace and
newlines and keeps a line comment apart from its newline) and abstains when the
slot or its token comes from a macro, on any trivia kind other than whitespace,
newlines and comments (a directive, disabled text), and when the trivia text is
not the buffer's text right before the token. The system-call half sits at
§ sysCallEmptyArgIsIntZero401's site in ExprEmit; the user-call half (functions,
tasks, class methods, package functions) at § emptyArgSlotIntZero24's
emptySlotArg24, through the slot's parent ArgumentList.

### § uninstIfaceIncDecBinds441 (R11U441_IFACEINCDEC_OFF)

Pass 439's residue (v11u439 VI/vi07, vi08): the interface twin of
§ uninstProgIncDecBinds439v. In an interface no module instantiates (the bodies
ModuleEmit emits under `uninstIfaceSubBody218`), the operand of a
statement-position ++ or -- binds a formal of the interface's own task or
function, a local of that subroutine, or a local of an unnamed block in a
process or subroutine body, Surelog's paInc_or_dec_expression leg passing the
enclosing scope as pexpr exactly as in a program. An interface member, a
named-block local, an expression-position ++ (`x = garr[s]++`), an if, repeat,
while or do body and a for step stay bare (golden on II/ii03, ii04, ii07, ii08,
ii10). Golden bound on whole names, indexes, compound indexes `garr[s+1]--`,
call arguments `garr[g(s)]++`, a fork, a ref formal and an initial or always
block's unnamed-block local.

## Grid (cases/, 40 case dirs plus v11u439 VI/vi07 and vi08; evidence/grid_final.tsv)

Every case's first line names its law. Upstream slang accepts every case
(the first EA drafts used `%d` formats, which slang rejects; rewritten).

| group | law | cases | pristine -> law3 |
|---|---|---|---|
| EA | § sysCallEmptyArgEndPrevTok441 | ea01 ea03 ea04 ea05 ea07 ea09 ea10 ea11 ea12 ea13 ea14 ea16 ea18 ea19 ea20 | STRICT_NOTEQUAL endline -> STRICT_EQUAL |
| EA | § sysCallEmptyArgEndPrevTok441 | ea02 ea06 ea08 | controls, STRICT_EQUAL on both, byte-identical |
| EA | § sysCallEmptyArgEndPrevTok441 | ea15 (a slot inside a multi-line macro body), ea21 (an inactive `ifdef between the slots) | STRICT_NOTEQUAL endline on both, byte-identical (abstains) |
| EA | § sysCallEmptyArgEndPrevTok441 | ea17 (an uninstantiated interface task) | NOT_EQUAL on both (31 uhdm-cmp lines, another face), dump distance 6 -> 4 |
| EU | § emptySlotArgEndPrevTok441 | eu01 eu02 eu04 eu05 eu06 eu07 | STRICT_NOTEQUAL endline -> STRICT_EQUAL |
| EU | § emptySlotArgEndPrevTok441 | eu03 | control, byte-identical |
| EU | § emptySlotArgEndPrevTok441 | eu08 (a continuous assignment's call) | NOT_EQUAL on both (15 lines, another face), distance 26 -> 24 |
| EU | § emptySlotArgEndPrevTok441 | eu09 (a sequence instance's empty argument) | NOT_EQUAL on both, byte-identical (not reached) |
| II | § uninstIfaceIncDecBinds441 | ii01 ii02 ii03 ii04 ii05 ii07 ii08, v11u439 VI/vi07 vi08 | NOT_EQUAL (29 or 31 uhdm-cmp lines) -> STRICT_EQUAL |
| II | § uninstIfaceIncDecBinds441 | ii06 (an instantiated interface), ii09 (a module), ii10 (loop steps and loop bodies) | controls, byte-identical |

Totals: 30 to STRICT_EQUAL (21 from STRICT_NOTEQUAL, 9 from NOT_EQUAL), 2 NOT_EQUAL
on both and closer, 3 residues byte-identical, 7 controls byte-identical, none
further; every exit code 0 on both binaries. R11U441_OFF gives pristine's bytes
and exit code on 40 of 40 case dirs, and each case's own switch does too
(evidence/grid_switches.tsv). Downstream (drivers/dsgrid.py) on the 27 class-,
interface- and program-free EA and EU cases: IDENTICAL on both binaries
(evidence/grid_downstream.tsv).

## Prediction and census

Written before the sweep (evidence/prediction.txt): the empty-argument laws fire
on the checker row alone among compared rows; the interface law on nothing in the
gates (the 23 tests/probe sources holding `interface` and ++/-- ran
byte-identical on pristine and law3 with 0 trace lines; a traced runner call on
the 22 candidate sv-tests rows, evidence/runner_candidates.csv, fired once, on
the checker). The sweep's trace: exactly one firing,
`sysCallEmptyArgEndPrevTok441 $display 120:28 -> 119:86` on the checker row
(evidence/sweep_trace.txt). Earlier-case census (drivers/census.sh,
evidence/earlier_case_census.tsv): the 380 fence-filtered tools/probe case dirs
whose sources hold a cross-line empty argument or an interface with ++/--, run
on pristine and law3: exit codes equal on all 380, 2 movers (v11u439 VI/vi07 and
vi08, both to STRICT_EQUAL, in the grid).

## Gates (one full five-stage sweep on law3, md5 caf5b613ae9f5162678f8e3e81fe14aa)

evidence/sweep_summary.txt:
- probe EQUAL 4023 + STRICT_NOTEQUAL 64, regressions 0, conversions 0, changes 0,
  the csv identical to the control and the 4087 databases identical to the
  control by path-normalized dump (drivers/probedump.sh; positive control 3180 lines);
- surelog 480 + 0 / 474 + 0 with 0/0/0, the csv differing from the control only in
  the two LowMem log-path texts;
- uhdm2rtlil 803/1/67 in both modes with 0/0/0, the csv identical to the control;
- downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv
  identical to the control;
- sv-tests EQUAL 1913, STRICT_NOTEQUAL 0, DIFFERENT 27, SURELOG_ONLY 75,
  BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 with
  regressions 0, conversions 1 (the checker), changes 0;
- byteverify (SELFCHECK=1) against the control: 0 of 962, 0 of 1608, 0 of 805
  (self-checks 961, 1607, 804); canaries ok=52 and ok=16, both ctcan2 PASS;
- binary audit: surelog 1523 of 1573 records name law3 (the other 50 hold only a
  Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.

The sv-tests stage ran through the main tree's scripts/check_svtests.py with the
baseline set to the worktree's results/golden_svtests.csv (the worktree's UVM
submodule is empty; scripts/ unchanged between the base and the main tree).

## Goal 1

Nothing on this ground. All 75 SURELOG_ONLY rows carry an upstream slang
front-end `error:` diagnostic, none an exporter message. The probe shapes read
upstream slang 0 and Surelog 3, so golden has nothing to copy: v11u415 VT/vt03
(`this.mk().inner.s`) ours 0, v11u413 VC/vc04 (`C::mk().arr[1]`) ours 4, v11u413
VI/vi06 (`u.mk(x).a[2]`) ours 4. bp_unicore measured alone on law3: rc 3 in
16.0 s at 829 MB; pass 403's size guard stands. rsd stays SURELOG_CRASH.

## Residues (all wrong on pristine too, none moved away)

1. The empty-argument end where the law abstains: a slot inside a multi-line
   macro body (EA/ea15, golden 3:6 ending 2:28 on the macro's definition
   lines) and a run holding an inactive conditional (EA/ea21, golden counts the
   directive and inactive lines as empty lines, 5:38).
2. The sequence instance's empty argument (EU/eu09; Surelog's paSequence_arg leg
   in CompileExpression.cpp mints the same placeholder; ours differs earlier).
3. The two basejump definitions above (sister's admission gate first).
4. The carried lists of passes 439 and earlier (pass 439's foreach and
   program residues other than VI/vi07 and vi08; passes 437, 435, 433, 431, 429,
   427, 425, 423, 421, 419, 417, 415, 413, 411, 409, 407, 405, 403 and 401).

## Sister-ground faces (reported, not written)

- UhdmExporter.cpp's never-instantiated definition admission
  (§ undefaultedDefInvalidInst404's `abstain-unbound` after
  § undefaultedPlaceholderRetry440): bsg_scheduler_dataflow (`bypass_lo` never
  declared, bsg_scheduler_dataflow.sv 187:12) and
  bsg_nonsynth_mem_1rw_sync_assoc (a nonblocking write to an associative
  element, bsg_nonsynth_mem_1rw_sync_assoc.sv 41:13): golden lists both
  definitions as module_inst objects in uhdmallModules.

## Process

Within the budget: no pristine build (the base build in the worktree, md5
695581e8..., equal to the main tree's, was used as the frozen pristine copy for
case runs), law1 (unused but for the first grid), law2 and law3 on case runs and
targeted runner calls, one full five-stage sweep on the final law3. Slips, none
affecting a measurement: waiters launched as background shells whose own command
lines held the sweep pattern kept the quiet check from reading quiet; they were
stopped by their recorded PIDs and the sweep waited for three quiet readings
(started 21:18:50, after the sister v11u442's sweep ended 20:57). The fence list
was read into a file by a program without printing it and every tree-wide list
was filtered on it before any file was opened; no other agent's process was
touched; no fenced test was named, opened or run.

## Files

cases/EA, EU, II (40 dut.sv), drivers/ (grid.sh, switches.sh, census.sh,
dsgrid.py, probedump.sh, memrun.py, quiet.sh, scan.py, fullsweep.sh), evidence/.
