# v11u444 — adversarial verification of r11u444 (module/type ground)

Verifier of pass 444 on base d22bf8535. The implementer's patch
(/tmp/r11u444.patch: § defaultedStrPlaceholderRetry444 in UhdmExporter,
§ progLocalDeclNets444 in ModuleEmit) was reproduced bit for bit, then attacked
with 53 fresh case dirs (cases/VP, cases/VD) and a 1133-unit byte census.
VERDICT: the sv-tests conversion and every gate reproduce; the attack found
TWO shapes where the program law moved legal SV AWAY from golden (pristine
already unequal there, so not a pristine-right break, but strict cells further
by dump distance), each fixed by its own refinement in ModuleEmit, read through
src/LawSwitch.h (`fixOn(444, ...)`, `R11V444_OFF` drops both):

- **§ nestProgAbstain444v** (`R11V444_NESTPROG_OFF`): a program declared
  INSIDE a module is folded into the module by Surelog (golden has no
  `work@prg` object; the task locals appear only as the module's subroutine
  variables), so the nets § progLocalDeclNets444 adds land on an object golden
  does not have. Every face of the program law abstains on a program whose
  definition's parent scope is not the compilation unit. Cases VP/vp22,
  vp32, vp33 (dump distance pristine -> law -> verified: 159 -> 168 -> 159,
  250 -> 270 -> 250, 123 -> 153 -> 123; verified byte-identical to pristine).
  Trace `nestProgAbstain444v <program>`.
- **§ portNameLocalNoTs444v** (`R11V444_PORTLOCALTS_OFF`): inside face (d)
  (no dedupe), a local named like one of the program's PORTS is a second net
  of that name in golden but carries NO typespec (Surelog files the local's
  data declaration against the port's Signal). The law gave it the local's
  keyword typespec. Cases VP/vp34, vp38, vp39, vp40 (dump distance pristine ->
  law -> verified: 13 -> 16 -> 7, 17 -> 37 -> 9, 13 -> 16 -> 7, 28 -> 20 -> 11;
  the remaining lines are the port low_conn binding, which golden points at
  the local's net, pre-existing). Trace `portNameLocalNoTs444v <name>`.

The refinements fire on no corpus row, probe case, sv-tests row or earlier
case (census below). Binaries: pristine = the implementer's frozen base build
(/tmp/v11u444_bin/pristine, md5 6c3476f4f963ec67eaa8aa44be1d7e18, equal to
the main tree's base build), law rebuilt once in /tmp/wt_v11u444
(md5 479da4ca54c6f6af2788d04a7b9460ee, EQUAL to the implementer's law6,
linking slang 12.0.0+545f88b2e), verified ver3
(md5 9a21d746e552ff9693e5bc4e9427075c; ver1 and ver2 were intermediate builds
used on case runs only, ver1 carrying a nesting test that never matched a
program, nestDepth99 serving modules only).

## Targeted sv-tests row

`generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_slave.sv`:
DIFFERENT -> EQUAL, reproduced in the law sweep
(`generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_slave.sv,EQUAL,,equal`;
`CONVERSION ... DIFFERENT -> EQUAL`) and the verified sweep (below).

## Law sweep (law, tests/sweep.sh --jobs 3, four corpus stages + the sv-tests stage, trace on)

| stage | reading | vs baseline |
|---|---|---|
| probe | EQUAL 4023, STRICT_NOTEQUAL 64 of 4087 | 0 / 0 / 0 |
| surelog | default CMP_EQUAL 480, testflags 474 | 0 / 0 / 0 |
| uhdm2rtlil | 803 / 1 / 67 both modes | 0 / 0 / 0 |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2 | not excused 0 |
| sv-tests | EQUAL 1914, DIFFERENT 26, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | 0 / 1 / 0 |

The sv-tests stage ran through the main tree's scripts/check_svtests.py
(scripts/ identical to the worktree's) with `--baseline` the worktree's
results/golden_svtests.csv, since the worktree's UVM submodule is empty. The
corpus stage's exit code 1 is the stale law index alone (this repro dir's
cases were being added during the sweep); every compare reads 0/0/0.

- Against the master's control /tmp/intr11u442: probe, uhdm2rtlil and
  downstream csvs identical; surelog only the two LowMem log-path texts;
  svtests only the control_slave row.
- byteverify (SELFCHECK=1) against the control: surelog 0 / 962 (self-check
  961), uhdm2rtlil 0 / 1608 (1607), downstream 0 / 805 (804); the 4087 probe
  databases identical by path-normalized dump (positive control: a mismatched
  pair differs by 887 lines).
- Canaries: ok=52 changed=0 and ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 and
  EXPECT_UNKNOWN=6 PASS.
- Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt records name
  /tmp/v11u444_bin/law (the other 50 only a Surelog line), uhdm2rtlil 1740 of
  1740, sv-tests 2346 of 2346; no other binary named.
- Trace (evidence/law_sweep_trace.txt): one line in all five stages,
  `defaultedStrPlaceholderRetry444 bsg_source_sync_channel_control_slave default`.

## Verified sweep (ver3)

One full sweep on ver3 (all five stages, trace on, after the prediction in
evidence/versweep.prediction was written): probe 4023 + 64 with 0/0/0,
surelog 480 / 474 with 0/0/0, uhdm2rtlil 803/1/67 in both modes with 0/0/0,
downstream 803/66/2/0 with not-excused 0, sv-tests EQUAL 1914, DIFFERENT 26,
BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1
with regressions 0, conversions 1 (control_slave, fresh row
`generated/basejump/bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_slave.sv,EQUAL,,equal`),
changes 0; corpus stage exit 0. The prediction held: every csv equal to the
law sweep's (surelog apart from the two LowMem paths); byteverify ver3 against
law 0 / 962, 0 / 1608, 0 / 805 (self-checks 961, 1607, 804) and against the
control 0 movers in each; the 4087 probe databases dump-identical to the law
sweep's and the control's; canaries ok=52 and ok=16, both ctcan2 PASS; audit
surelog 1523 of 1573 records naming /tmp/v11u444_bin/ver3 (the other 50 only
a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346; trace the
same one line (no corpus source declares a program inside a module, so no
nestProgAbstain444v line). `R11V444_OFF` gives the law's bytes on 53 of 53
attack dirs, `R11V444_NESTPROG_OFF` on vp22, vp32, vp33 and
`R11V444_PORTLOCALTS_OFF` on vp34, vp38, vp39, vp40; ver3 is byte-identical
to the law on the implementer's 35 case dirs.

## Implementer's grid reproduced (evidence/grid_impl_reproduced.txt)

All 35 lines (CS 12, PN 23) reproduced exactly on exit code, uhdm-cmp count,
strict verdict, `R11U444_OFF` == pristine and own switches == pristine, and on
the dump distances it quotes (cs06 286 -> 230, pn05 38 -> 27, pn22 80 -> 57).

## Attack grid (evidence/grid_attack.txt; drivers/grid.sh, drivers/run1.sh)

53 fresh case dirs, every one accepted by upstream slang with the same top
(`Build succeeded: 0 errors`; VD/vd10 one warning), every exit code 0 on
pristine, law and verified; `R11U444_OFF` gives pristine's bytes on 53 of 53
and the law's own switches (all six program switches, or R11U444_DEFSTRPH_OFF)
too. Two shapes dropped before judging: VP/vp27 (non-ANSI program ports,
Surelog syntax error, no golden) and the first VD/vd03 (`parameter string`
used as a select bound, upstream slang rejects it).

§ progLocalDeclNets444 (VP, 43 dirs), pristine -> verified:

| group | cases |
|---|---|
| NOT_EQUAL -> STRICT_EQUAL (18) | vp01 two tasks with the same local name, vp03 class handle local with a class method local beside, vp04 initialized, unpacked-initialized and static function locals, vp06 ANSI ports, vp07 fork and named-block locals in a task with later program variables, vp10 string/event/chandle/real/time/shortint, vp11 int unsigned, bit, integer, logic signed, reg signed, vp12 2-D, queue, associative, dynamic, vp13 `program automatic`, vp14 continuous assign beside, vp16 explicit top the program, vp17 DPI import and two-declarator locals, vp18 a local shadowing at three levels, vp19 order with two later program variables, vp20 virtual interface local, vp25 clocking block, vp30 two programs, vp36 final and initial locals with a task and a function |
| NOT_EQUAL -> STRICT_NOTEQUAL (1) | vp35 endline: a struct-typedef local with an initializer, golden moves the typedef's own struct_typespec end to the initializer (6:24), the § initTsEndProgramLocal155 face for a typedef name |
| NOT_EQUAL both, closer (19) | vp02 typedef locals with unpacked dims (114 -> 91), vp08 two-declarator for and foreach (49 -> 36), vp09 inline enum and struct (127 -> 24), vp15 instantiated program (70 -> 48), vp21 include file between declarations (45 -> 34), vp23 implicit net from an assign (22 -> 11), vp24 typedef locals with initializer (74 -> 44), vp26 two instances (55 -> 44), vp28 package typedef locals (68 -> 42), vp29 parameter-sized locals (67 -> 63), vp31 instantiated program with port (61 -> 46), vp34, vp38, vp39, vp40 (the refinement, above), vp41 to vp44 queue, dynamic, fixed and associative typedef locals (103 -> 50, 149 -> 98, 364 -> 243, 135 -> 62) |
| byte-identical to pristine (5) | vp05 out-of-body class task at program scope (`task C::t(); int z;`, no law face reaches it), vp37 program beside an explicit module top, and the three nested programs vp22, vp32, vp33 on the verified binary (further on the law) |

§ defaultedStrPlaceholderRetry444 (VD, 10 dirs, UhdmExporter unchanged by the
refinements, verified == law): vd01 (a generate if on the string choosing
between two child modules), vd02 (the string passed to a child's width), vd03
(untyped string plus a `parameter string` used as a string), vd07 (a child in
a generate loop that a top also instantiates), vd08 (case on the string), vd09
(two such definitions) NOT_EQUAL -> STRICT_EQUAL; vd05 (a localparam copy of
the string as the bound, beside `'0` to an undefaulted width) NOT_EQUAL both,
331 -> 44 (the residue is pass 440's '0 sized -1 face); vd04 (a second string
default used as a file name: overriding it with 8 leaves `$fopen(8, "w")`
unbound) abstains, byte-identical; vd06 (an empty-string default as the left
bound: slang binds it, no retry) STRICT_EQUAL both; vd10 (no top: Surelog
elaborates the module as a top) bytes move with the dump identical and the
distance 180 on both.

Downstream (evidence/downstream_attack_*.txt; drivers/dsgrid.sh, the 51
class-free dirs): every verdict equal on pristine and verified (programs read
IDENTICAL with both lanes failing to read, vp22, vp32, vp33 EQUIVALENT on
both, the VD cases IDENTICAL, vd10's Surelog lane TIMEOUT on both).

## Earlier-case census (evidence/census_*.tsv, census_movers_judged.txt; drivers/census.sh, judge.sh)

Every fence-filtered .sv under tools/probe and tests/probe holding the word
`program` or a header parameter with a string default (1133 units; a case
dir's dut.sv with its TOP and FILES, a loose .sv alone), run on pristine, law
and ver2 then ver3: exit codes equal on all four binaries everywhere (12 units
exit nonzero on all with no database), 54 byte movers pristine -> law, none
under tests/probe, 0 movers law -> ver2 and 0 law -> ver3 (the refinements fire
on no earlier case; their positive controls are vp22 and vp34). Each mover
judged against a fresh Surelog golden: 25 to STRICT_EQUAL (the implementer's
22 plus r10uvm145 g145_c_home, r10v147 v147_h and r10v145 v145_b_homes), 28
NOT_EQUAL on both and closer by dump distance (the implementer's 5 among them) (two with uhdm-cmp counts growing, r10buvm17 a2_homes17 311 -> 3644
and r10v179 v179_c_home 534 -> 3230, because the first difference moved
earlier to a whole object uhdm-cmp prints, both closer), and 1 further:
r10vbuvm22repro/v3_kinds.sv 2243 -> 2254 with uhdm-cmp 30 on both. Its two
added nets (`work@pg3.r` twice, function locals typed by a queue typedef)
equal golden's records field by field; the 11 lines are the hoist's clone of
the queue typedef's array_typespec in the unreferenced typespec tail, where
golden binds the typedef's own object — the typespec-identity residue the
strict comparator canonicalizes, the same clone the pre-pass hoist writes for
a process-block local. Not fixed (binding the typedef's own object is a
general change to makeTypespec's clone policy, outside this pass).

## Residues (ranked; all wrong on pristine too, none moved away on ver3)

1. The uvm-examples family (17 rows), the 3 uvm_scoreboard rows and easyUVM
   (not reached by this pass).
2. bsg_nonsynth_mem_1rw_sync_assoc and bsg_scheduler_dataflow: unbound
   whatever the placeholder values (CS/cs09, VD/vd04 abstain the same way).
3. The elaborated instance of an instantiated program (vp15, vp26, vp31,
   pn05, pn18): golden lists the locals as the instance's variables.
4. The port low_conn of a program port whose name a local reuses binds the
   local's net in golden (vp34, vp38 to vp40; ModuleEmit's port emission).
5. A struct-typedef local with an initializer moving the typedef's own
   typespec end (vp35, § initTsEndProgramLocal155 limited to keyword types).
6. Typedef-typed locals with unpacked dims or a package typedef (vp02, vp24,
   vp28, vp41 to vp44): the hoist's per-net typedef clone (typespec identity
   and the clone's name/instance), v3_kinds the one census case where it costs
   distance.
7. A nested program (vp22, vp32, vp33): golden folds it into the module, ours
   keeps a program object (pre-existing, the refinement only stops this law).
8. The out-of-body class method body at program scope (vp05), the no-top
   placeholder definitions elaborated as tops by Surelog (CS/cs06, VD/vd10),
   '0 sized -1 under a placeholder width (VD/vd05).

## Sister-ground faces (reported, not written)

None new.

## Process

Within the budget on sweeps: one law build (md5 equal to the implementer's),
one sweep each on the law and the final verified binary, no pristine build or
sweep (the pristine reading the master's pass 442 control /tmp/intr11u442 and
the implementer's frozen base build for case runs); over it on builds: three
verified builds (ver1 and ver2 on case runs only, ver3 swept). Slips, none
affecting a measurement: the attack grids, the ver1 to ver3 builds (nice 10,
-j 2), the 1133-unit census (-P 2) and the mover judgements ran beside this
verifier's own law sweep's corpus stages, one process group at a time
(timing only; every reading is a byte, exit-code or verdict comparison); the
master's pass 443 integration sweep was waited out by three quiet readings
before the law build. The fence list was read into a file by a program without
printing it; every tree-wide list (tools/probe, tests/probe, the cmds.txt
records) was filtered on it before any file was opened; no fenced test named,
opened or run; no other agent's process touched.

## Files

- cases/VP (43 dirs; § progLocalDeclNets444, vp22/vp32/vp33
  § nestProgAbstain444v, vp34/vp38/vp39/vp40 § portNameLocalNoTs444v),
  cases/VD (10 dirs, § defaultedStrPlaceholderRetry444).
- drivers/: run1.sh, grid.sh, dist.sh, dd.sh, census.sh, judge.sh, dsgrid.sh,
  switches.txt.
- evidence/: as named above, plus law_sweep_probe.csv, law_sweep_svtests.csv,
  versweep.prediction.
