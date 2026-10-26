# v11u434: adversarial verification of r11u434 (the module/type ground, pair B)

Base `4f9e8023` (branch matrix-1.87). The implementer's patch `/tmp/r11u434.patch` applied clean on a
fresh worktree `/tmp/wt_v11u434`. VERDICT: **CONFIRMED, no production refinement.** No fresh case on
legal SV where pristine was right and the law is wrong; the verified patch carries the implementer's
`src/TypeEmit.cpp` and `src/UhdmExporter.cpp` hunks byte-identical, plus this directory and the
regenerated `tests/LAWS.md`.

## Binaries

- pristine: the main tree's `build/slang-uhdm`, frozen as `/tmp/v11u434_bin/pristine`
  (md5 `54aa91a5ebd542f26280e15ffe67ab9d`); no pristine build, no pristine sweep (the pristine
  reading is the master's control sweep `/tmp/intr11u432`).
- law: rebuilt once in `/tmp/wt_v11u434` (`-j 2`), frozen as `/tmp/v11u434_bin/law`,
  md5 `e4102a40642390dc7eebaf6bf8c3d240`, equal to the implementer's law4.
- No verified build (no refinement).

## No-header audit

The source diff has no `src/R*.h`, no `getenv`, no `#include`, no reader function; the five laws read
through `lawOn(434, "R11U434_<LAW>_OFF")` and log through `lawTrace(434, ...)`. Two flags written
across emitters, both named by the implementer: `g434SpecAliasListing` (defined in TypeEmit, written
only by UhdmExporter emitClassPropSpecParams163, read only by TypeEmit bareScalarTdCopyOfFresh16; a
pointer set read only by `count`, never iterated, so no order effect) and `g434ModVecTd` (TypeEmit
only).

## The one five-stage sweep on the law binary (`/tmp/v11u434sw1`, trace on)

Launched by `drivers/fullsweep.sh` after three quiet readings (evidence/sweep_law_summary.txt):

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4019, STRICT_NOTEQUAL 68 of 4087 | regressions 0, conversions 0, changes 0 |
| surelog | default CMP_EQUAL 480 + 0, testflags 474 + 0 | 0 / 0 / 0 |
| uhdm2rtlil | 803 / 1 / 67 in both modes | 0 / 0 / 0 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 | not identical and not excused 0 |
| sv-tests | EQUAL 1901, DIFFERENT 39, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | regressions 0, conversions 6, changes 0 |

The corpus stages exited 1 only on the stale law index (this directory's later cases); regenerated
afterwards, `--check` current. Against the master's control: probe, uhdm2rtlil and downstream csvs
identical, surelog only the two LowMem log-path texts, sv-tests exactly the six conversion rows
(evidence/svtests_vs_control.diff), and the sv-tests csv identical to the implementer's
`/tmp/r11u434sw4/svtests.csv` on all 2346 rows. The six conversions, reproduced:

    generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_comm_link.sv,EQUAL,,equal                         (DIFFERENT at the base)
    generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_master.sv,EQUAL,,equal (DIFFERENT)
    testbenches/uvm_agent_active.sv,EQUAL,,equal                                                         (STRICT_NOTEQUAL differ:file(2))
    testbenches/uvm_agent_passive.sv,EQUAL,,equal                                                        (STRICT_NOTEQUAL differ:file(2))
    testbenches/uvm_driver_sequencer_env.sv,EQUAL,,equal                                                 (STRICT_NOTEQUAL differ:file(2))
    testbenches/uvm_monitor_env.sv,EQUAL,,equal                                                          (STRICT_NOTEQUAL differ:file(2))

A targeted runner call on these six plus the four firing non-converting rows, on both binaries,
read the same verdicts (pristine DIFFERENT / JUDGE_EQUAL differ:file(2), law EQUAL).

- byteverify (SELFCHECK=1, law workdir against `/tmp/intr11u432`, names of equal length): surelog
  0 of 962 (selfcheck 961), uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804)
  (evidence/byteverify.txt). Predicted from the trace: the only corpus firing is
  § clsSpecArgTsFileAtArg434's same-file branch on Scoreboard default.
- Probe: 4087 of 4087 databases identical to the control by path-normalized uhdm-dump, with two
  positive controls differing (a pristine/law pair and a cross pair).
- Canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); EXPECT_UNKNOWN=1 and
  EXPECT_UNKNOWN=6 ctcan2 both PASS.
- Binary audit (cmds.txt path list filtered on the fence list first): surelog 1523 of 1573 records
  name `/tmp/v11u434_bin/law`, the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740.
- Trace census (evidence/trace_census_sweep.txt): exactly the implementer's 13 databases. Probe
  r10uvm23repro/t34g_t and corpus Scoreboard default (clsSpecArgTsFileAtArg434 x1 each, same-file
  branch, bytes unchanged); sv-tests: bsg_comm_link (modTdRangeClogKeeps434 x4),
  channel_control_master (genBodyDefBitsKeepsCall434 x3), the 4 converting testbenches rows and the
  3 uvm_scoreboard rows (bareTdCopyOwnRangeAfterSpec434 x3, clsSpecArgTsFileAtArg434 x4 each),
  easyUVM (x3, x12), rsd (modTdRangeClogKeeps434 x3, SURELOG_CRASH).
- Away census on the firing rows that did not convert (against the cached golden): uhdm-cmp line
  counts unchanged on both binaries, easyUVM 659635, uvm_scoreboard_env 2200983,
  uvm_scoreboard_monitor_agent_env 2231211, uvm_scoreboard_monitor_env 2216265; sorted dump distance
  of the three scoreboard rows down by 54 each (63046 -> 62992, 75468 -> 75412, 69244 -> 69190);
  easyUVM's sorted distance reads 2389787 -> 2389829, a design that differs wholesale, so counted by
  object instead: `range 49:22-49:42` golden 105 / pristine 92 / law 96, `range 59:22-59:28`
  78 / 75 / 77, `logic_typespec (uvm_bitstream_t) 49:9-49:42` 56 / 49 / 51, all toward golden.

## The implementer's grid reproduced

The 54 case dirs of tools/probe/r11u434repro rerun with this directory's driver: every line equal
on exit code, uhdm-cmp count, strict verdict and both switch columns once the md5 and object-count
columns are stripped (the databases embed their output path) (evidence/grid_implementer_reproduced.txt).

## Earlier-pass census

4529 fence-filtered case dirs of passes 401 to 432 (the same count as the implementer's), pristine
and law by exit code and bytes (evidence/earlier_pass_census.txt): every exit code equal, 8 write no
database on either binary, 19 movers, exactly the implementer's list, all judged against golden
toward it (evidence/earlier_pass_movers_judged.txt): pass 424's TR/tr03 and tr05 NOT_EQUAL ->
STRICT_EQUAL (dump distance 13 -> 0, 26 -> 0), the other 17 (r11u405 PH/ph01, r11u423 residue gb01
to gb03, r11u428 residue BB bb02 to bb04 and bb06, r11u429 GB gb01, gb02, gb05, gb07, gb08, gb12 to
gb14, v11u429 VB/vb21) NOT_EQUAL on both with the dump distance down 13 to 39 lines each.

## The attack grid (71 fresh case dirs in VB, VR, VS, VT; evidence/grid_attack.txt)

Every case is accepted by upstream slang (two drafts that slang's front end rejects were removed:
a struct type written as a specialization argument, a name used before its declaration); every exit
code 0 on both binaries; `R11U434_OFF` gives pristine's bytes and exit code on 71 of 71 and each
case's own switch on 71 of 71. Pristine -> law:

- 12 NOT_EQUAL -> STRICT_EQUAL, 6 STRICT_NOTEQUAL depth -> STRICT_EQUAL, 8 STRICT_NOTEQUAL file ->
  STRICT_EQUAL, 3 NOT_EQUAL -> STRICT_NOTEQUAL file, 6 STRICT_EQUAL controls kept, 2
  STRICT_NOTEQUAL kept (VB/vb18 file, VR/vr09 fullname, byte-identical);
- 34 NOT_EQUAL on both: 32 closer to golden by dump distance, 2 byte-identical (VT/vt06, VB/vb23),
  none further (evidence/grid_attack_distance.txt; VB/vb14 and vb21 read further by the SORTED
  distance only, their unsorted distance 40 -> 27 and 42 -> 21: the law writes golden's
  definition-view call and the remaining difference is the elaborated view's fold, the sister's).
- Downstream on the 46 VB and VT cases (evidence/downstream_attack.txt): no verdict
  change and none worse; VT/vt09 EQUIVALENT on both with the differing stages nohier/il/synth ->
  nohier only; VB/vb05, vb13 and VT/vt15 DIVERGENT on both.

Per law (case: pristine -> law):

- § clsSpecArgTsFileAtArg434 (VS, 15): the same specialization spelled `reg [3:0]` against a first
  spelling `logic [3:0]` (vs01), `bit [4-1:0]` against `bit [3:0]` (vs02, NOT_EQUAL -> STRICT_EQUAL:
  the argument's own range is golden's), `bit [W-1:0]` in a parameterized class (vs03, NOT_EQUAL ->
  STRICT_EQUAL), `int unsigned` (vs04), two arguments (vs05), a macro argument (vs06), packed
  multi-dimension spelled with a space (vs07), real and string (vs08), a class inside a module
  (vs10), shortint and integer beside int (vs12): STRICT_EQUAL; `byte unsigned` against a first
  spelling `bit [7:0]` (vs09, a different specialization) a control; the $unit `N` bound (vs11) and
  package parameter bounds (vs13, vs15, vs16) NOT_EQUAL on both and closer, their head a Surelog
  artefact unrelated to the law (golden lists the package parameter `N` twice in the derived class).
- § bareTdCopyOwnRangeAfterSpec434 (VR, 10): bit and packed multi-dimension typedefs, two copies,
  two classes, method locals and arguments, a second alias clone, rand (vr01, vr02, vr05, vr07,
  vr08, vr10: STRICT_NOTEQUAL depth -> STRICT_EQUAL); unpacked and queue copies (vr04) and a module
  net (vr06) controls kept; a parameter bound (vr03) closer; an alias of an alias (vr09) unchanged.
- § genBodyDefBitsKeepsCall434 (VB, 23): a struct variable, a port, a module array instance, a
  replication count, a function argument, two instances, a shadowing block local, int and byte
  variables, a non-ANSI reg, an uninstantiated module with and without an explicit top, a
  zero-iteration loop (vb03, vb06, vb07, vb09, vb10, vb12, vb16, vb24, vb25, vb27: to STRICT_EQUAL
  or closer); an interface (vb08) to STRICT_NOTEQUAL file on the elaborated constant's location;
  a net-declaration assignment (vb18) and an always_comb (vb20) not reached and byte-identical;
  $bits in a select, in a ternary condition, a left-side range and $size(x, 2) closer with the
  elaborated head left; a gen-for nested in a gen-if (vb23) byte-identical (not reached).
- § genBodyDefSysArgCallTree434 (VB vb13 to vb15): `$clog2($size(x))`, `$signed($bits(x))`,
  `$clog2($clog2(256))` and `$unsigned($signed(a))`: the definition view becomes golden's on all four
  (vb15 STRICT_EQUAL), the rest left on the elaborated view.
- § modTdRangeClogKeeps434 (VT, 20): a typedef read by nets and assignments, an array of it, a
  function return and argument, a package parameter argument, signed, `$bits(t)` of it (vt01,
  vt07, vt10, vt12, vt13, vt16: to STRICT_EQUAL or closer); `[$clog2(W):0][1:0]` and
  `[W-1:$clog2(W)]` (vt03, vt11) to STRICT_NOTEQUAL file, golden's elaborated bound constant
  carrying no location (the implementer's TC/tc08 face); an unpacked-dimension typedef (vt02) and an
  enum base (vt08) controls kept; the rest closer (below).

## Residues standing (all wrong on pristine too, none moved away)

1. The elaborated view of a generate body's continuous assignment (ExprEmit, the sister's): golden
   folds a constant right side to one unlocated constant at the left side's size where ours keeps
   the call or a located 64-bit constant (VB vb01, vb02, vb04, vb05, vb11, vb13, vb14, vb17, vb19,
   vb21, vb26; the interface case vb08's constant location).
2. Elaborated bound constants of a module typedef range carrying a location golden does not write
   (VT/vt03, vt11; r11u434 TC/tc08) and the elaborated copy under an override (VT/vt09, r11u434
   TC/tc09).
3. § modTdRangeClogKeeps434 not reached: a typedef of the typedef (vt04, golden keeps
   `$clog2(W)-1` as an operation in the alias), a generate-block typedef (vt06), an interface's
   instance-level typedef listing (vt05), a nested module (vt17, an extra int_typespec), a program
   (vt20, also vpiNetType 36 on the variable), a class typedef inside a module (vt19), a struct
   member typed by the typedef (vt14); and inside the kept call, an argument that is itself a query
   call is a raw-text ref_obj where golden writes `$bits(t)` as a sys_func_call (vt18) or folds
   `$bits(a)` to 8 (vt15).
4. § genBodyDefBitsKeepsCall434 not reached: a gen-for nested in a gen-if (vb23), a
   net-declaration assignment (vb18, STRICT_NOTEQUAL file on both).
5. The alias of an alias as a specialization argument (VR/vr09, fullname) and a package parameter
   bound in the typedef (vr03); a package parameter listed twice in a derived class (VS vs11, vs13,
   vs15, vs16; a Surelog artefact).
6. The implementer's ranked list stands: the 16 uvm-examples rows (pass 426's this_type face and
   about 30 further heads), the 3 uvm_scoreboard rows and easyUVM, TC/tc05, BD/bd07, the basejump
   placeholder rows, and the carried lists of passes 432 and earlier.

## Sister-ground faces (reported, not written)

- ExprEmit's bound emitter: residue 1 above, the generate-body continuous assignment's elaborated
  fold (pass 431's target).

## Process

- The sister v11u431's verified sweep (`/tmp/v11u431sw2`) started at about 22:08 after its own quiet
  check read no sweep process, while this pass's law build (22:06 to 22:11), the first attack grid
  (22:11 to 22:13) and the downstream attack grid (22:13 to 22:14) were running: case runs and a
  build beside the sister's probe and surelog stages, no sweep of this pass overlapping another
  (this pass's sweep driver waited until three quiet readings at 22:38). Every later step ran on a
  quiet machine or beside this pass's own sweep only.
- The fence list was read from tools/probe/r11u107repro/canaudit.sh's FENCED= line into a file by a
  program without printing it; every tree-wide path list (the earlier-pass census, the binary
  audit, the probe dump comparison) was filtered on it before any file was opened; no fenced test
  was named, opened or run.
- Within the budget: one law build, no verified build, one full five-stage sweep, one targeted
  runner call per binary on the ten firing rows.

## Files

- cases/VB (26), VR (10), VS (15, each with its spec.svh), VT (20); every dut.sv's first line names
  its law.
- drivers/: run1.sh, grid.sh, dist.sh (sorted and unsorted dump distance), dsgrid.sh, census1.sh,
  pdump.sh, fullsweep.sh, quiet.sh, quiet3.sh, switches.txt.
- evidence/: the files named above.
