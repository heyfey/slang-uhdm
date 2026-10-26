# r11u434: the module/type ground, pair B (the sv-tests campaign's seventeenth pass on this ground)

Base `4f9e8023` (branch matrix-1.87). Files of the ground touched: `src/TypeEmit.cpp` and
`src/UhdmExporter.cpp` only (ModuleEmit, TaskFuncEmit, uhdm_main.cpp, EmitHelpers.h, ExprEmit,
StmtEmit, ParamEmit and include/ unchanged). Five laws, each read through `src/LawSwitch.h`
(`lawOn(434, "R11U434_<LAW>_OFF")`), `R11U434_OFF` drops all of them, `R11U434_TRACE=<dir>` logs
each firing through `lawTrace(434, ...)`. No `src/R*.h`, no LawState.h section, no getenv, no
reader function.

Pristine = the master's control sweep at the base, `/tmp/intr11u432` (its five csvs equal the
committed results/*.csv); for case runs the main tree's `build/slang-uhdm`, frozen as
`/tmp/r11u434_bin/pristine` (md5 `54aa91a5ebd542f26280e15ffe67ab9d`; the worktree's own first
build of the base gave the same md5). The final law binary `/tmp/r11u434_bin/law4`
(md5 `e4102a40642390dc7eebaf6bf8c3d240`).

## Verdict per targeted row (fresh rows of the law sweep's `svtests.csv`; results/ untouched)

Six sv-tests CONVERSIONS, 0 regressions, 0 changes:

| row | base | law |
|---|---|---|
| `testbenches/uvm_agent_active.sv` | STRICT_NOTEQUAL differ:file(2) | `testbenches/uvm_agent_active.sv,EQUAL,,equal` |
| `testbenches/uvm_agent_passive.sv` | STRICT_NOTEQUAL differ:file(2) | `testbenches/uvm_agent_passive.sv,EQUAL,,equal` |
| `testbenches/uvm_driver_sequencer_env.sv` | STRICT_NOTEQUAL differ:file(2) | `testbenches/uvm_driver_sequencer_env.sv,EQUAL,,equal` |
| `testbenches/uvm_monitor_env.sv` | STRICT_NOTEQUAL differ:file(2) | `testbenches/uvm_monitor_env.sv,EQUAL,,equal` |
| `generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_master.sv` | DIFFERENT | `...,EQUAL,,equal` |
| `generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_comm_link.sv` | DIFFERENT | `...,EQUAL,,equal` |

sv-tests at the law: EQUAL 1895 -> 1901, STRICT_NOTEQUAL 4 -> 0, DIFFERENT 41 -> 39, BOTH_REJECT
303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; the csv differs from the
control in exactly these six rows (evidence/svtests_vs_control.diff).

Attribution: the 4 testbenches rows need § clsSpecArgTsFileAtArg434 (their head #206401, the
`uvm_resource#(int)` int_typespec file) and § bareTdCopyOwnRangeAfterSpec434 (their next head
#219489, `uvm_report_message_int_element::_val`'s range); channel_control_master needs
§ genBodyDefBitsKeepsCall434 (143:53 `$bits(out_calib_code)`); bsg_comm_link needs
§ modTdRangeClogKeeps434 (794:22 `$clog2(core_channels_p)` in a module typedef range, the only law
firing on that row). Heads at the base, evidence/uvm_agent_active_heads_pristine.txt:

    #206401 file   A: int_typespec uvm_resource_defines.svh 43:17-43:20
                   B: int_typespec uvm_resource_specializations.svh 43:17-43:20
    #219489 depth  A: 7 range uvm_object_globals.svh 49:22-49:42
                   B: 4 int_var _size ...

## The laws

- **§ clsSpecArgTsFileAtArg434** (UhdmExporter emitClassPropSpecParams163, switch
  `R11U434_SPECARGFILE_OFF`). In a class specialization's listing (a class property or a
  class-method local `C #(...)`), a DATA-TYPE argument's typespec is compiled from the argument as
  written, as Surelog compiles the written `paData_type` node: its file and its packed range come
  from the argument, not from the specialization's FIRST spelling that slang keeps as the type
  parameter's syntax. Before, makeTypespec stamped the first spelling's file (UVM's
  uvm_resource_specializations.svh) and setLoc kept that file while it rewrote the line and
  columns, so the object read one file with another file's position. Cases SF (sf01 to sf07:
  through one macro, a nested macro call, no macro, a property, a `bit [3:0]` argument, two
  arguments; sf05 the control whose argument is in the first spelling's file).
- **§ bareTdCopyOwnRangeAfterSpec434** (TypeEmit bareScalarTdCopyOfFresh16, the flag
  `g434SpecAliasListing` written across files: defined in TypeEmit, written only by
  UhdmExporter emitClassPropSpecParams163 where § clsMethodLocalForeignPkgSpec428 mints its alias
  clone, read only by bareScalarTdCopyOfFresh16; switch `R11U434_BARERANGE_OFF`). Surelog compiles
  a variable's typedef'd type afresh at every declaration, so the bare LAW-S copy of a package
  vector typedef owns its packed range. Ours shared the listing object's range vector; the strict
  walk lists a class specialization's subtree once, so when § clsMethodLocalForeignPkgSpec428's
  alias clone (`uvm_resource#(uvm_bitstream_t) __tmp_rsrc__`) reached the listing first the shared
  range was already walked and `_val`'s copy read range-less. Only a copy of a listing object such
  an alias clone reached takes its own range vector (copyRangeVec); every other copy keeps the
  shared vector and its bytes. Cases RG (rg21 the converting shape: the class with the local
  before the class with the property; rg01 to rg22 controls with literal and macro bounds and the
  other orders).
- **§ genBodyDefBitsKeepsCall434** (TypeEmit emitSyntaxExpr, the query-call fold; switch
  `R11U434_GENDEFBITS_OFF`). In the DEFINITION listing of a continuous assignment written inside a
  generate body (gen-if, else branch, gen-for, gen-case, nested blocks, an interface's generate
  block, a child definition), `$bits(x)` and `$size(x)` of a module-level fixed-width net or
  variable keep their sys_func_call over a ref_obj, as golden writes them (and as ours already
  wrote them for a block-local name and a select, § genBlockBitsKeepsSelect200); the same call
  outside any generate construct folds (bd12). Cases BD bd01 to bd27.
- **§ genBodyDefSysArgCallTree434** (TypeEmit emitSyntaxExpr, the system-call argument emitter;
  switch `R11U434_GENDEFSYSARG_OFF`). In the same definition listing, a system-call argument that
  is itself a system call (`$clog2($bits(x))`) is compiled as an expression: golden writes the
  inner sys_func_call over its own ref_obj where the raw-text fallback named a ref_obj
  `$bits(x)`. Range and typedef bounds keep the raw-text ref_obj (the measured matrix at the
  site). Cases BD bd15, bd17, bd18. Fires on no sv-tests row, corpus row or probe case.
- **§ modTdRangeClogKeeps434** (TypeEmit emitSyntaxExpr's query-call fold, the flag
  `g434ModVecTd` set by TypeEmit emitTypedefs around a module-body vector typedef's makeTypespec
  and read only by that fold, both in TypeEmit; switch `R11U434_MODTDCLOG_OFF`). In a MODULE-body
  vector typedef's packed range Surelog keeps `$clog2(...)` unreduced, over a parameter, a
  localparam, a literal or an expression (golden `sys_func_call $clog2` over `ref_obj W`,
  `constant 8`, `operation W*2`), where the typedef context folded it. Cases TC tc01 to tc12
  (pass 424's TR tr03 and tr05 convert too); a package typedef (tc03), a struct member (tc07) and
  a variable's own range (tc11) are controls the law does not reach.

## Measurements

### The one full five-stage sweep on the final binary (law4, trace on)

`drivers/fullsweep.sh /tmp/r11u434_bin/law4 /tmp/r11u434sw4 /tmp/r11u434_trsw`, launched after
three quiet readings (evidence/fullsweep_law4.log):

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4019, STRICT_NOTEQUAL 68 of 4087 | regressions 0, conversions 0, changes 0 |
| surelog | default CMP_EQUAL 480 + 0, testflags 474 + 0 | regressions 0, conversions 0, changes 0 |
| uhdm2rtlil | 803 / 1 / 67 in both modes | regressions 0, conversions 0, changes 0 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | not identical and not excused 0 |
| sv-tests | EQUAL 1901, DIFFERENT 39, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | regressions 0, conversions 6, changes 0 |

The corpus stages exited 1 only on the stale law index (this repro dir was added before the
sweep; `scripts/law_index.py` regenerated afterwards, `--check` current). Against the master's
control: probe, uhdm2rtlil and downstream csvs identical; surelog differs only in the two LowMem
log-path texts; sv-tests in the six conversion rows.

- byteverify (SELFCHECK=1, law workdir against `/tmp/intr11u432`, names of equal length):
  surelog 0 of 962 (selfcheck 961), uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804)
  (evidence/byteverify.txt). Predicted: the only corpus firing is § clsSpecArgTsFileAtArg434's
  same-file branch on Scoreboard default (the argument is the first spelling), no byte moves.
- Probe: 4087 of 4087 databases identical to the control by path-normalized uhdm-dump; positive
  control SF/sf01 pristine against law differs (evidence/probe_dump_compare.txt).
- Canaries: ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil); EXPECT_UNKNOWN=1 and
  EXPECT_UNKNOWN=6 ctcan2 both PASS.
- Binary audit (fence-filtered path lists, records under a fenced path skipped before opening):
  surelog 1523 of 1573 records name `/tmp/r11u434_bin/law4`, the other 50 hold only a Surelog
  line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.
- Trace census (evidence/trace_census_sweep.txt): 13 databases fire. sv-tests: the six
  conversions (testbenches x4: § bareTdCopyOwnRangeAfterSpec434 x3 and
  § clsSpecArgTsFileAtArg434 x4 each; channel_control_master: § genBodyDefBitsKeepsCall434 x3;
  bsg_comm_link: § modTdRangeClogKeeps434 x4), easyUVM and the 3 uvm_scoreboard rows (both
  spec laws; uhdm-cmp line counts unchanged, 659635, 2200983, 2231211, 2216265, from targeted
  runner calls on both binaries), rsd (§ modTdRangeClogKeeps434 x3; SURELOG_CRASH, unjudgeable).
  Corpus: Scoreboard default, § clsSpecArgTsFileAtArg434's same-file branch only. Probe: the case
  r10uvm23repro/t34g_t, the same branch only (EQUAL, bytes unchanged). No other firing.

### The grid (54 case dirs in BD, RG, SF, TC; evidence/grid_law4.txt)

Every exit code 0 on both binaries; `R11U434_OFF` gives pristine's bytes and exit code on 54 of
54; each case's own switch restores pristine's bytes on 53 of 54, the other, BD/bd15
(`$clog2($bits(x))`), needing the co-firing `R11U434_GENDEFSYSARG_OFF` as well.

- 7 NOT_EQUAL -> STRICT_EQUAL: TC tc01, tc02, tc04, tc06, tc10, tc12, BD bd24.
- 7 STRICT_NOTEQUAL -> STRICT_EQUAL: SF sf01, sf02, sf03, sf04, sf06, sf07, RG rg21.
- 2 NOT_EQUAL -> STRICT_NOTEQUAL file: BD bd23 (an interface, the elaborated net-declaration
  file), TC tc08 (`[$clog2(W):0]`: golden's elaborated bound constant carries no location).
- 22 NOT_EQUAL on both: the definition view now golden's and the head on the elaborated view,
  which is ExprEmit's (the sister's; see below), every one closer to golden by dump distance
  (evidence/grid_dump_distance.txt; bd11, bd17 and bd25 read further by the SORTED distance only
  because pristine's folded definition cell paired with its own wrong elaborated cell, the
  unsorted diff reads 26 -> 13, 36 -> 25, 26 -> 13, evidence/grid_unsorted_diff_bd11_bd17_bd25.txt);
  bd07 (a bare `generate` region), bd21 (a parameter-width signal) and tc05 (`$bits` in a module
  typedef) are byte-identical residues.
- 16 controls STRICT_EQUAL on both (bd06, bd10, bd12, bd16, tc03, tc07, tc11, sf05, RG rg01 to
  rg22 except rg21) and bd19 STRICT_NOTEQUAL file on both (a net-declaration assignment, not
  reached).
- Downstream on the 39 class-free cases (BD, TC; evidence/downstream_cases_law4.txt): 37
  IDENTICAL on both, BD/bd25 DIVERGENT on both, TC/tc09 EQUIVALENT on both; none worse.

### Earlier-pass census

4529 fence-filtered case dirs of passes 401 to 432 (tools/probe/r11u4NNrepro and v11u4NNrepro),
pristine against law4 by bytes and exit code: 4510 identical (8 of them writing no database on
either binary), 19 movers, every exit code equal (evidence/earlier_pass_census_movers.txt), all
toward golden (evidence/earlier_pass_movers_judged.txt, _dist.txt): pass 424's TR/tr03 and tr05
NOT_EQUAL -> STRICT_EQUAL; pass 428's BB bb02, bb03, bb04, bb06, pass 429's GB gb01, gb02, gb05,
gb07, gb08, gb12, gb13, gb14, pass 423's residue gb01 to gb03, pass 429's verifier case VB/vb21
and pass 405's PH/ph01 stay NOT_EQUAL with the definition-view head cleared (dump distance down by
13 to 39 lines each).

## Goal 1

Nothing on this ground: no rejecting row of results/golden_svtests.csv carries an exporter
message; all 75 SURELOG_ONLY rows carry an upstream slang front-end `error:` diagnostic
(undeclared identifiers, unknown modules, redefinitions, local or protected member access, the
basejump time-scale error, ...). The exit-4 probe shapes of the brief's (1a) to (1c) were not
written by this pass.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The 16 uvm-examples rows: their first head on 12 rows is still pass 426's face A (a class-local
   `this_type` of a package-level specialization typedef, golden vpiInstance the declaring
   package's TOP view), then the struct-member class_typespec instance, the radix enum's base
   alias naming, about 20 `m_inst_typename_alias_t` struct against unsupported heads and the
   `m_override_info` foreach ref_var unsupported_typespec instances: pass 426's cmptrace2 rerun on
   uvm_ac_config_db at law2 lists 30 seeded heads (not written; a multi-face family).
2. The 3 uvm_scoreboard testbench rows (golden design empty) and easyUVM (class sequencer
   listing): firing both spec laws with uhdm-cmp counts unchanged.
3. The elaborated module-typedef copy under an override: TC/tc09, `child #(.W(16))` with
   `typedef logic [$clog2(W)-1:0] t; t x;`, golden keeps `$clog2(W)-1` in the child's elaborated
   variable typespec where ours folds the bound to INT:3 (the § modTdRangeClogKeeps434 face one
   view later; the elaborated typespec copy path).
4. TC/tc08: `[$clog2(W):0]`'s elaborated bound constant UINT:2 carries no location in golden,
   ours 3:18-3:24.
5. BD/bd07: a bare `generate ... endgenerate` region holding a continuous assignment, golden lists
   a gen_region in the definition (pass 407's and 428's gen_region face).
6. TC/tc05: `$bits(y)` in a module typedef range, golden folds the whole bound.
7. The remaining basejump rows (control_slave, comm_link_checker, round_robin_fifo_to_fifo,
   nonsynth_mem_1rw_sync_assoc, dff_en_segmented, scheduler_dataflow, nonsynth_ascii_writer,
   nonsynth_dpi_rom, mesh_stitch): the decoded default-less placeholder shapes of passes 404 to
   428 (round_robin 339:19 `[width_p*num_out_p-1:0]` folded to INT:7 in a placeholder instance,
   dpi_rom 31:22 and mesh_stitch 18:14 the same family), not written.
8. The carried lists of passes 432 and earlier (fx68k's elaborated port-connection fold, p130,
   p203, p334, p719, p733, p737, tnoc, the exit-4 probe shapes).

## Sister-ground faces (reported, not written)

- The elaborated view of a generate body's continuous assignment, ExprEmit's bound emitter: the
  head of 22 BD cases and of the 19 earlier-pass movers after § genBodyDefBitsKeepsCall434.
  Golden folds the whole right side to one unlocated constant sized to the left side when it is
  constant (bd02 `assign y = $bits(x)` golden `constant UINT:5 size 32` with no location, ours
  `constant UINT:5 size 64` at 5:16-5:24; bd11's `$size(x)` ours keeps a sys_func_call), and keeps
  `$bits(x)` inside a select whose base is not constant (bd01 `x[($bits(x)-1)-:(W)]`, golden
  `sys_func_call $bits` in work@top.genblk1, ours a constant). Pass 431's brief carries this face.

## Process

- Builds: the worktree's base build (md5 equal to the main tree's), two instrumented builds
  (dbg1, dbg2: a temporary stderr print in fullFilePath, removed before law1, never swept),
  law1, law2, law3, law4 (the final). Intermediate binaries got case runs and targeted runner
  calls on the rows worked (the 45 DIFFERENT / STRICT_NOTEQUAL rows on pristine and law2, the
  testbench and channel_control_master rows on law2, the 11 basejump rows on law3). One full
  five-stage sweep, on law4.
- Slips, none affecting a measurement: the sister r11u431's full sweep started at 20:16 while
  this pass's law1 and law2 builds, one instrumented UVM run and the SF/RG case runs were in
  flight (until 20:20; the check before those builds was made at 19:58 and not repeated); every
  later build, case batch, runner call and the sweep waited for a quiet process list. The first
  pristine runner call on the UVM rows passed the UVM directory relative to the worktree, whose
  submodules are empty, so those rows failed on both tools; rerun with the absolute path into a
  fresh csv.
- The fence list was read from tools/probe/r11u107repro/canaudit.sh's FENCED= line into a file by
  a program without printing it, and every tree-wide path list (the source scans, the
  earlier-pass census, the binary audit) was filtered on it before any file was opened; no fenced
  test was named, opened or run.

## Files

- cases/BD (27), RG (8), SF (7, with their include files), TC (12); every dut.sv's first line names
  its law.
- drivers/: run1.sh (golden + one binary + uhdm-cmp + strictcmp), grid.sh, switches.txt, dsgrid.sh
  (downstream), fullsweep.sh, quiet.sh, bytecensus.sh, cmp.sh, sc.sh, dist.sh, pdump.sh.
- evidence/: the files named above, the runner csvs (pristine and law2 on the 45 rows, law3 on the
  11 basejump rows).
