# r11u444 — module/type ground: the defaulted string placeholder and the program's local nets

The twenty-second pass of the sv-tests campaign on the module/type ground
(src/UhdmExporter.cpp, src/ModuleEmit.cpp), implementer phase, on base
d22bf8535. Two laws, each behind its own switches, all read through
src/LawSwitch.h (`lawOn(444, "R11U444_<LAW>_OFF")`, `R11U444_OFF` drops the
whole pass, `R11U444_TRACE=<dir>` logs every firing and abstention through
`lawTrace(444, ...)`). No src/R*.h, no getenv, no reader function, no
LawState.h section, no flag written in one emitter and read in another;
TypeEmit, TaskFuncEmit, uhdm_main.cpp, include/ and the sister's files
(ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) unchanged.

## Verdict

- sv-tests: **1 row converts, DIFFERENT -> EQUAL**:
  `generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_slave.sv`
  through § defaultedStrPlaceholderRetry444 (the runner on the law binary:
  `bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_slave,OK,OK,EQUAL,equal,IDENTICAL`,
  evidence/runner_basejump_law1.csv). The sweep's sv-tests stage reads it as the one conversion
  (`CONVERSION ...control_slave.sv: DIFFERENT -> EQUAL`; fresh row
  `generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_slave.sv,EQUAL,,equal`):
  EQUAL 1913 -> 1914, DIFFERENT 27 -> 26 of 2346, regressions 0, changes 0.
- Goal 1: nothing on this ground (census below).
- Goal 2 on the probe backlog: the sister passes 439's and 441's reported
  program-net face (the program road, ModuleEmit) is written by
  § progLocalDeclNets444: r11u439 UP/up12, up15, v11u439 VP/vp01, vp06, vp07,
  vp20, VI/vi05, vi11, vi13, v11u441 VJ/vj17 and v11u417 VC/vc24 NOT_EQUAL ->
  STRICT_EQUAL, with eleven older program cases to STRICT_EQUAL (census below).
- Every corpus gate unchanged (sweep below): probe 4023 + 64 with 0/0/0,
  surelog 480 + 0 / 474 + 0 with 0/0/0, uhdm2rtlil 803/1/67 in both modes
  with 0/0/0, downstream 803/66/2/0; byteverify 0 of 962, 0 of 1608 and 0 of
  805 against the master's control; the sweep's trace holds exactly one
  firing, the control_slave row, as predicted.

## Goal-1 census (results/golden_svtests.csv at the base)

EQUAL 1913, BOTH_REJECT 303, SURELOG_ONLY 75, DIFFERENT 27, SLANG_ONLY 19,
SURELOG_CRASH 8, TIMEOUT 1 of 2346. Every one of the 378 SURELOG_ONLY,
BOTH_REJECT and SLANG_CRASH rows (no SLANG_CRASH row) carries an upstream
slang front-end diagnostic (`error:`) in its detail and none an exporter
`unsupported` message: nothing on this ground is stuck at an exporter error,
as passes 406 to 442 found.

## The open both-accepted rows at the base (27 DIFFERENT, 0 STRICT_NOTEQUAL)

Re-measured on the master's control /tmp/intr11u442 (its kept slang.uhdm
against the cached golden): control_slave, bsg_nonsynth_mem_1rw_sync_assoc
and bsg_scheduler_dataflow differ first at the design's module list, the
definition missing in ours (pass 404's `abstain-unbound`); easyUVM, p733, p737,
tnoc, the 17 uvm-examples rows and the 3 uvm_scoreboard rows as passes 440 and
442 read them. uvm_test_init's normalized dump diff (golden 8.59 M lines, ours
7.50 M) opens with vpiParent links of package string variables and io_decls,
the package of a typespec instance (uvm_pkg against test_top_pkg) and
`m_type_names[key].get_type_name` written as a hier_path in golden where ours
writes a bit_select: the family needs many laws, none taken here.

## Laws

### § defaultedStrPlaceholderRetry444 (R11U444_DEFSTRPH_OFF; UhdmExporter, inside pass 404's placeholder admission after § undefaultedPlaceholderRetry440)

Decoded on the control_slave row: golden lists the never-instantiated
`bsg_source_sync_channel_control_slave` in uhdmallModules (3281 dump lines,
`width_p` with no value, `lg_token_width_p` STRING:inv with a string_typespec,
`counter_min_bits_lp` UINT:24, the always_comb body with
`out_ctr_r[counter_min_bits_lp-1:lg_token_width_p]` as an unbound
part_select), since Surelog never evaluates the body; ours left it out because
pass 404's placeholder body still held an InvalidStatement after every retry
of § undefaultedPlaceholderRetry440: the DEFAULTED header parameter
`lg_token_width_p = "inv"` (basejump's placeholder written by hand) is the
select bound, a string reversing the select (pass 440's README located it at
268:6). The law: when every retry leaves the body unbound and the definition
has a defaulted non-local value parameter whose default is a string literal,
the retries run once more (first with no string placeholder, then one
undefaulted scalar parameter at a time as "inv", as pass 440 orders them)
with each such parameter overridden by the placeholder 8; the first body slang
binds completely is listed. The parameter's listing is unchanged (ParamEmit's
writer rebinds an overridden parameter's declaration default, so golden's
STRING:inv is written). A body still unbound abstains as before
(`lawTrace(444, "defaultedStrPlaceholderRetry444", "abstain <def>")`); a firing
logs `<def> default` or `<def> <param>`.

### § progLocalDeclNets444 (ModuleEmit emitModuleDef, the program's process-local hoist)

Decoded from Surelog's CompileProgram::collectObjects_: its DEFINITION walk
descends the whole program syntax tree (its one stop point is
paClass_declaration) and hands every paData_declaration it meets to
compileDataDeclaration(m_program, ...), so every data declaration of the
program, wherever it is written, is a program net. Our hoist (the
`A PROGRAM also lists every variable declared INSIDE its processes` block)
covered process blocks only. Six faces, each droppable alone:

- (a) R11U444_PRGSUBLOCAL_OFF: the locals of the program's tasks and
  functions, in their bodies and in every named or unnamed block under them,
  static ones too, are program nets (a function's return variable, flagged
  compiler-generated, and the formals are not; a class's method locals stay
  out). Trace `sub <subroutine> <name>`.
- (b) R11U444_PRGFORVAR_OFF: a `for (int k = ...)` control variable is a
  paFor_variable_declaration and never reaches that call: not listed (ours
  listed it from the process block, VP/vp01, PN pn06, pn19). Trace `forvar`.
- (c) R11U444_PRGLOCALORDER_OFF: the nets are filed in the walk's (source)
  order among the program's own declarations, not appended (PN pn15, pn16).
  Trace `order`.
- (d) R11U444_PRGLOCALDUP_OFF: nothing dedupes by name; a local re-declaring
  a program variable's name is a second net of that name (PN pn10, pn17).
  Trace `dup`.
- (e) R11U444_PRGLOCALNT_OFF: the hoisted net of a keyword-typed local takes
  the program net's own net type, `logic` 36 and `reg` 48 (`var logic`, int,
  bit, integer none; a typedef name none, r11u155 IT/s11). Trace `nettype`.
- (f) R11U444_PRGLOCALDIMEND_OFF: a keyword-typed local declared with unpacked
  dimensions reads a typespec ending at its FIRST unpacked dimension
  (`int b[3]` 5:3-5:11, `int c[2][3]` ends after `[2]`, `logic [3:0] d [4]`,
  `int e[]`), winning over § initTsEndProgramLocal155's initializer end
  (r11u155 IT/s16 `logic [3:0] j [2] = '{0, 1};` ends at `[2]` in golden,
  v11u155 IT/k05). Trace `dimend`.

## Grid (evidence/grid_law6.txt; drivers/grid.sh law6 pristine <case dirs>)

Each line: pristine and law reading (exit code, uhdm-cmp line count, strict
verdict), `R11U444_OFF` equal to pristine, the case's own switches equal to
pristine. 35 case dirs, every exit code 0 on both binaries, every case
accepted by upstream slang (`Build succeeded: 0 errors`; CS/cs06 one warning),
`R11U444_OFF` and the case's own switches giving pristine's bytes and exit
code on 35 of 35.

CS (§ defaultedStrPlaceholderRetry444; cs01 to cs05 and cs07 to cs12 with a
TOP file `top`, as the sv-tests runner gives `--top-module top`):

| case | shape | pristine -> law |
|---|---|---|
| cs01 | control_slave's shape: undefaulted `w`, `lg = "inv"`, `c[mn-1:lg]` in an always_comb if | NOT_EQUAL 708 -> STRICT_EQUAL |
| cs02 | only `lg = "inv"`, every parameter defaulted (no placeholder, admitted as before) | STRICT_EQUAL, byte-identical |
| cs03 | the select in a continuous assignment (§ invalidCaAssignChild404 already binds) | STRICT_EQUAL, byte-identical |
| cs04 | the string used as a string (`$display`): the body binds, no retry | STRICT_EQUAL, byte-identical |
| cs05 | an integer default `lg = 4` (control) | STRICT_EQUAL, byte-identical |
| cs06 | cs01 with no top and no wrapper (Surelog elaborates `m` as a top) | NOT_EQUAL both, dump distance 286 -> 230 |
| cs07 | two string defaults `c[hi:lg]` | STRICT_EQUAL, byte-identical (slang binds `c[hi:lg]` with both strings) |
| cs08 | with an undefaulted file-name parameter too (pass 440's string try plus this law) | NOT_EQUAL 760 -> STRICT_EQUAL |
| cs09 | with a nonblocking associative write too (unbound whatever the values) | NOT_EQUAL 666, byte-identical (abstains) |
| cs10 | `parameter string lg = "inv"` used as a string, `c[23:w]` the bad select | STRICT_EQUAL, byte-identical |
| cs11 | the select inside a function | NOT_EQUAL 626 -> STRICT_EQUAL |
| cs12 | the select inside a generate loop `c[23:lg+i]` | NOT_EQUAL 594 -> STRICT_EQUAL |

PN (§ progLocalDeclNets444; no top):

| case | shape | pristine -> law |
|---|---|---|
| pn01 | task local | NOT_EQUAL 666 -> STRICT_EQUAL |
| pn02 | function local with initializer, foreach | NOT_EQUAL 654 -> STRICT_EQUAL |
| pn03 | initial-block local (the old hoist) | STRICT_EQUAL, byte-identical |
| pn04 | named and unnamed block locals in a task | NOT_EQUAL 528 -> STRICT_EQUAL |
| pn05 | an instantiated program with a task local | NOT_EQUAL 60 both, distance 38 -> 27 (residue: the elaborated instance's variables) |
| pn06 | `for (int k ...)` in an initial (b) | NOT_EQUAL 482 -> STRICT_EQUAL |
| pn07 | a class method local (not listed) beside a task local | NOT_EQUAL 642 -> STRICT_EQUAL |
| pn08 | automatic and static function locals | NOT_EQUAL 752 -> STRICT_EQUAL |
| pn09 | two declarators | NOT_EQUAL 500 -> STRICT_EQUAL |
| pn10 | a task local named like a program variable (d) | NOT_EQUAL 338 -> STRICT_EQUAL |
| pn11 | `logic [3:0]` and `bit` task locals (e) | NOT_EQUAL 586 -> STRICT_EQUAL |
| pn12 | fork-block and final-block locals (the old hoist) | STRICT_EQUAL, byte-identical |
| pn13 | the same task in a module (control) | STRICT_EQUAL, byte-identical |
| pn14 | the same task in an interface (control) | STRICT_EQUAL, byte-identical |
| pn15 | an initial-block local before a later program variable (c) | NOT_EQUAL 56 -> STRICT_EQUAL |
| pn16 | a task local before a later program variable (c) | NOT_EQUAL 390 -> STRICT_EQUAL |
| pn17 | an initial-block local named like a program variable (d) | NOT_EQUAL 270 -> STRICT_EQUAL |
| pn18 | an instantiated program with an initial-block local | NOT_EQUAL 490, byte-identical (residue: the elaborated instance's variables) |
| pn19 | for-loop variables in a task and an initial (b) | NOT_EQUAL 806 -> STRICT_EQUAL |
| pn20 | a function's return variable and formals (not listed) | STRICT_EQUAL, byte-identical |
| pn21 | `logic`, `reg`, `logic signed`, `integer` initial-block locals (e) | NOT_EQUAL 58 -> STRICT_EQUAL |
| pn22 | `reg [1:0]`, `var logic`, `logic` task locals | NOT_EQUAL 510 both, distance 80 -> 57 (the net listing now equal; residue: the task's variable parent) |
| pn23 | unpacked-dimension locals (f) | NOT_EQUAL 1172 -> STRICT_EQUAL |

## Earlier-case census (evidence/census_law6.tsv, drivers/bytecensus.sh)

Every fence-filtered case dir under tools/probe and tests/probe whose dut.sv
holds the word `program` (607) or a string default beside a default-less
parameter (25), 632 dirs, run on pristine and law6: exit codes equal
everywhere, 3 dirs exiting nonzero on both with no database, 27 byte movers,
none under tests/probe, each judged against a fresh golden
(evidence/movers_law6.txt): 22 NOT_EQUAL or STRICT_NOTEQUAL -> STRICT_EQUAL
(r11u155 IT/s04, s07, s16, r11u291 CS/c25_prog_task_local, r11u314
NB/nb10_program, r11u426 CV/cv18, r11u439 UP/up12, up15, v11u155 IT/k01, k05,
k06, v11u209 LV/v20, v11u283 VP/vp08_for_loop_var, v11u417 VC/vc24, v11u439
VI/vi05, vi11, vi13, VP/vp01, vp06, vp07, vp20, v11u441 VJ/vj17; k05 was
STRICT_NOTEQUAL on endcol), 5 NOT_EQUAL on both and closer by dump distance
(r10uvm218 a3_muststay 41 -> 28, r10uvm220 a4_prog 103 -> 81, r10uvm221
a3_muststay 281 -> 257, v11u137 l13_program 20 -> 19 with its uhdm-cmp count
58 -> 229 only because the first difference moved to the elaborated
instance's variables, v11u302 VL/vl10_program 81 -> 68), none further. An
intermediate binary (law5) moved r11u155 IT/s11 one line further (a
typedef-named local given net type 36) and left IT/s16 STRICT_NOTEQUAL (the
initializer end winning over the dimension); law6 restricts face (e) to
keyword types and orders face (f) after § initTsEndProgramLocal155, s11
byte-identical to pristine again and s16 STRICT_EQUAL.

## Trace census before the sweep

- probe: a traced law6 run over all 4087 tests/probe cases
  (drivers/probe_trace.sh): 0 firings; positive control PN/pn01 firing
  `progLocalDeclNets444 sub t loc`.
- surelog corpus: the twelve fence-filtered tests holding a program (Google,
  Verilator, SVSwitch, OneNetRange, ClassCons, SimpleClass, InterfaceModPort,
  ClockingSntx, OneNetInterf, OneNetModPort, SimpleConstraint,
  OneNetModPortGeneric) run traced on law6 in both modes: 0 firings, every
  status as the baseline (7 + 7 CMP_EQUAL rows, the rest SLANG_REJECT or the
  standing Google testflags TIMEOUT).
- sv-tests: the rows holding a program in their sources (chapter-24
  24.3--program.sv and hdlconvertor p745 EQUAL, p371 and p454 SURELOG_ONLY,
  p759 and keyword_endprogram BOTH_REJECT) hold no subroutine or block local:
  predicted 0 movers from § progLocalDeclNets444; § defaultedStrPlaceholderRetry444
  predicted to fire on control_slave only (its runner reading above; the other
  two placeholder rows bsg_nonsynth_mem_1rw_sync_assoc and
  bsg_scheduler_dataflow byte-identical to the control by path-normalized
  dump on law1).

## Sweep (law6, tests/sweep.sh --jobs 3, all five stages, trace on)

One sweep on the final binary law6 (md5 479da4ca54c6f6af2788d04a7b9460ee,
linking slang 12.0.0+545f88b2e) with R11U444_TRACE on, after three quiet
readings; the four corpus stages through the worktree's tests/sweep.sh, the
sv-tests stage through the main tree's scripts/check_svtests.py (the main tree
clean at d22bf8535, scripts/ identical to the worktree's) with the baseline set
to the worktree's results/golden_svtests.csv, since the worktree's UVM
submodule is empty (tests/sweep.sh skipped the stage for want of
SVTESTS_ROOT; the stage was then run alone on the same binary into the same
workdir). evidence/sweep_law6_probe.csv and sweep_law6_svtests.csv (the corpus csvs stay out of the patch: their row lists name the fenced tests), sweep_law6_summary.txt,
sweep_law6_trace.txt.

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4023, STRICT_NOTEQUAL 64 of 4087 | regressions 0, conversions 0, changes 0 |
| surelog | default CMP_EQUAL 480, testflags 474 (CMP_NOTEQUAL 4 + 4, Tnoc standing) | 0 / 0 / 0 |
| uhdm2rtlil | 803 / 1 / 67 in both modes (stamped_gen_param CMP_NOTEQUAL) | 0 / 0 / 0 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | not identical and not excused 0 |
| sv-tests | EQUAL 1914, DIFFERENT 26, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | regressions 0, conversions 1 (control_slave), changes 0 |

- Against the master's control /tmp/intr11u442 (the pristine reading): the
  probe, uhdm2rtlil and downstream csvs identical; surelog differing only in
  the two LowMem log-path texts; svtests only in the control_slave row.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1): surelog
  MOVERS 0 / 962 (self-check 961 flagged), uhdm2rtlil 0 / 1608 (1607),
  downstream 0 / 805 (804); the 4087 probe databases identical to the
  control's by path-normalized dump (a mismatched pair as the positive
  control reads DIFF).
- Canaries: canaries.sh ok=52 changed=0 (surelog) and ok=16 changed=0
  (uhdm2rtlil); ctcan2 EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 PASS.
- Binary audit, fence-filtered path lists first: surelog 1523 of 1573
  cmds.txt records name /tmp/r11u444_bin/law6 (the other 50 hold only a
  Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346; no record
  names another binary.
- Trace: one line in all five stages,
  `defaultedStrPlaceholderRetry444 bsg_source_sync_channel_control_slave default`,
  on the control_slave database, as predicted.
- Downstream on the 35 grid case dirs (evidence/downstream_grid.txt, ds.one
  with the downstream flags): 24 IDENTICAL, 9 EQUIVALENT and 1 SLANG_REJECT
  on both binaries, CS/cs06 STATUS_DIFF -> IDENTICAL; none leaves IDENTICAL.

## Residues (ranked; all wrong on pristine too, none moved away)

1. THE UVM-EXAMPLES FAMILY (17 rows) and the 3 uvm_scoreboard rows, easyUVM:
   not reached (pass 442's 36 heads stand).
2. bsg_nonsynth_mem_1rw_sync_assoc and bsg_scheduler_dataflow: the definition
   admission is this ground's, but the placeholder body stays unbound whatever
   the values (a nonblocking write to an associative element at 41:13, the
   undeclared `bypass_lo` at 187:12), so admitting them needs the sister's
   writers for those statements first (CS/cs09 is the abstaining control).
3. The elaborated instance of an instantiated program lists every process,
   task and function local as a variable (golden `int_var work@top.p.loc` and
   `work@top.p.q` under vpiVariables, PN pn05, pn18, v11u137 l13_program):
   ModuleEmit's elaborated net listing (collectNetOrder93's elaborated caller),
   not written; and in pn05 a task-body reference binds `int_var work@top.p.x`
   in golden where ours binds the definition's `logic_net work@prg.x`.
4. A task's `reg [1:0]` local's variable parent (PN pn22, the task's begin in
   golden): TaskFuncEmit.
5. p733, p737 and tnoc (await the user's decision) and the carried lists of
   passes 442 and earlier.

## Sister-ground faces (reported, not written)

None new.

## Process

Within the budget: no pristine build of my own beyond the worktree's base
build (md5 6c3476f4f963ec67eaa8aa44be1d7e18, equal to the main tree's, frozen
as /tmp/r11u444_bin/pristine for case runs; the pristine reading is the
master's control), law1 to law6 on case runs and targeted runner calls only
(law1 on the three placeholder rows, law6 traced on the twelve corpus program
rows), one full five-stage sweep on the final law6, started after three quiet
readings and overlapping nothing. Slips, none affecting a measurement: the
sister verifier v11u443's second sweep started at 02:39:46, 50 s after my
quiet reading of 02:38:57, and ran until 03:03:43; my law5 build tail, the
law5 and law6 byte censuses, the law6 build, the grid, the traced probe run,
the traced corpus run of the twelve program rows (launched although my quiet
check read 4 live processes) and the mover judgements all ran beside it, one
process group at a time at -P 3 (timing only: every reading is a byte or
verdict comparison, the corpus statuses equal the baseline, and the final
sweep reproduces every one of them). An earlier runner call failed before
running anything for want of the SURELOG variable (no file written outside my
scratch). The fence list was
read into a file by a program without printing it, and every tree-wide list
(tools/probe, tests/probe, the Surelog corpus .sl files, sv-tests) was
filtered on it before any file was opened; no fenced test named, opened or
run. No other agent's process touched.

## Files

- cases/CS (12 case dirs, § defaultedStrPlaceholderRetry444), cases/PN (23
  case dirs, § progLocalDeclNets444); every dut.sv's first line names its law.
- drivers/run1.sh (golden per case text + ours + uhdm-cmp + uhdm-strictcmp),
  grid.sh, dist.sh, cmp.sh, gold.sh, quiet.sh, bytecensus.sh,
  probe_trace.sh, switches.txt.
- evidence/: grid_law6.txt, census_law6.tsv, movers_law6.txt,
  runner_basejump_law1.csv, corpus_program_rows_traced_law6.csv,
  sweep_law6_probe.csv, sweep_law6_svtests.csv, sweep_law6_summary.txt,
  sweep_law6_trace.txt, downstream_grid.txt.
