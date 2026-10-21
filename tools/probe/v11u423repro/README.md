# v11u423 — adversarial verification of r11u423 (expression/parameter ground)

Base 36240458 (pass 421). Implementer's patch /tmp/r11u423.patch applies clean on a
fresh 36240458. Binaries, frozen read-only before any measurement:
pristine 0620ec3fde41ca631002651bc458f79a (the implementer's frozen base build,
equal to the main tree's build at the base; not rebuilt, per the budget), law
fea31847620c7987ca44e928f34dbe9e (rebuilt here, EQUAL to the implementer's
law12), verified fe23e89edab5e0c7920ed69b8b367cdc. Pristine sweep reading:
the master's control /tmp/intr11u421.

## Verdict

The law is CONFIRMED on its own claims (every headline number reproduced). It
has ONE BREAK, found by fresh cases on legal SV and fixed here behind its own
switch:

§ unszFoldWholeCaRhsKeepsSize423v (src/ExprEmit.cpp, inside
§ unszBasedPkgFoldUnsized423; switch R11V423_CAWHOLE_OFF, master R11V423_OFF).
THE BREAK: § unszBasedPkgFoldUnsized423 sets size -1 on EVERY fold read of an
untyped, unsized based package parameter. When the read is the WHOLE right side
of a continuous assignment, plain or net declaration, Surelog shares the
constant with that read and resizes it to the reader's width:
- `assign y = H` (int y) gives golden size 32.
- `assign z = H` (8-bit z) gives golden size 8.
- `wire [15:0] w = H` gives golden size 16.

Pristine wrote those sizes right and the law wrote -1. This is the same
distinguisher that § decUnszElabRespellKeepsM1_423 already abstains on for
module parameters. Measured on fresh cases (dump field by field, golden v1.87):
- VS/vs01: the law moved uhdm-cmp 11 -> 56 lines and dump distance 16 -> 66.
- VS/vs02 (a qualified `assign z = p::H`): distance 8 -> 34.
- VS/vs03 (net declaration): uhdm-cmp 17 -> 46.
- VS/vs16 (net declaration plus qualified read): distance 22 -> 50.
- VS/vs17 (an interface and a generate block): distance 36 -> 49.

Golden keeps -1 on every other read context measured (procedural whole-RHS
vs13, function return and argument vs14, port actual and concatenation operand
vs15, operand reads vs05, vs08, vs10, vs11, vs12), so the law is right there.
The refinement keeps the reader's size at a cont_assign parent and leaves the
law's actual-less ref_typespec half in place (golden has no actual there either).
With the refinement:
- vs01 and vs02 read STRICT_EQUAL (pristine NOT_EQUAL).
- vs03 is at 13 uhdm-cmp lines and distance 9 (pristine 17 / 14).
- vs16 is at distance 20 (pristine 22).
- vs17 is at distance 21 (pristine 36).

Every case is now at pristine's reading or closer.

## Reproduced headline numbers (law binary, one full five-stage sweep, evidence/sweep_law.log)

- probe EQUAL 4018 + STRICT_NOTEQUAL 69, 0/0/0; csv byte-identical to the
  control and to the implementer's.
- surelog 480 / 474 CMP_EQUAL, 0/0/0; the csv differs from the control only in
  the two LowMem log-path texts.
- uhdm2rtlil 803/1/67 both modes, 0/0/0; csv identical to the control and the
  implementer's.
- downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv
  identical to the control and the implementer's.
- sv-tests EQUAL 1855, STRICT_NOTEQUAL 2, DIFFERENT 83, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions=0 conversions=1 changes=0. The conversion is
  `generated/scr1/scr1.sv,EQUAL,,equal` (control `DIFFERENT,decompile:,`). The
  csv is byte-identical to the implementer's. This stage ran through the main
  tree's scripts/check_svtests.py (read-only, scripts unchanged since the base)
  with --baseline this worktree's results/golden_svtests.csv.
- byteverify (SELFCHECK=1) law vs control: 0 of 962, 0 of 1608, 0 of 805.
- canaries ok=52 and ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 and =6 PASS.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the law
  binary (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740,
  sv-tests 2346 of 2346; no other binary named.
- trace census: the same law firing counts in the law and verified sweeps
  (caseItemPkgFoldTsLate423 799 lines, clsTfOpFoldTsLate423 200,
  caseItemPkgFoldTsOps423 138, unszBasedPkgFoldUnsized423 60 (all
  UVM_RADIX), decUnszElabRespellKeepsM1_423 1 (scr1)). 13 traced processes: 4
  probe cases (law 1's fence line, bytes unchanged) and 9 sv-tests rows, as the
  implementer listed.
- grid: the implementer's 35 case dirs reproduced line for line (exit code,
  uhdm-cmp count, dump distance, strict verdict; evidence/grid3_implementer_cases.txt).
- goal 1: `C::mk().arr[1]` and `u.mk(x).a[2]` exit 4 with 'element select
  base' and upstream slang exits 0; `this.mk().inner.s` exits 0 (residue_cases
  g1a-g1c). bp_unicore alone with pass 403's guard: exit 3 in 14.6 s (runner
  wall 16.2 s), runner children maxrss 810 MB, the same `basic_string::substr`
  message. No memory-bounded export; the guard stands.

## Verified binary (one build, one full five-stage sweep, evidence/sweep_verified.log)

- Every stage reads regressions=0. The probe, uhdm2rtlil, downstream and
  sv-tests csvs are byte-identical to the law sweep's. The surelog csv differs
  from it only in the two LowMem log-path texts.
- byteverify verified vs control and verified vs law: 0 of 962, 0 of 1608,
  0 of 805.
- canaries ok=52 / ok=16; ctcan2 PASS.
- PREDICTED BY NAME before the sweep: the refinement fires only where
  § unszBasedPkgFoldUnsized423 fires at a cont_assign parent. That law fires
  only on UVM_RADIX, read inside class methods, so no corpus row, probe case
  or sv-tests row moves. Observed: the refinement's trace line appears in no
  sweep process. The positive control is VS/vs01, which logs two firings.
- 106 kept sv-tests databases, law vs verified, by path-normalized dump:
  105 identical. The 106th, tnoc, has its 900 s dump timeout cutting both
  dumps; uhdm-cmp reads 0 lines between the two databases, which have equal
  sizes.
- Earlier-pass census law vs verified: 3017 of 3017 fence-filtered case dirs
  of passes 401-422 unchanged (bytes and exit code; 8 write no database on
  both). The byte-control grids 118-131: 879 of 879 unchanged.
- The implementer's 35 case dirs: verified == law on 35 of 35. R11U423_OFF
  gives pristine's bytes and exit code on 35 of 35, and R11V423_OFF gives the
  law's on 35 of 35.

## Attack grid (drivers/grid3.sh, evidence/grid3_verifier_cases.txt; 41 fresh case dirs, all accepted by upstream slang, every exit code 0 on all three binaries)

Pristine -> verified:
- VC (11, case-item and operand laws):
  - vc05, vc06, vc07, vc08 and vc10 go NOT_EQUAL -> STRICT_EQUAL. These are a
    parameterized class, an interface function, an explicit `import p::A` in a
    class task, a module function in two instances, and an int-typedef import.
  - vc01, vc02, vc03, vc04, vc09 and vc11 stay NOT_EQUAL, toward golden by
    distance, with the heads elsewhere. vc02's three stamped case items match
    golden field by field.
  - vc11 (two packages each exporting an A, the class importing q::A) moves
    its uhdm-cmp head later in the walk, to a module `assign v = A` where
    Surelog binds the $unit import. That cell is the same on pristine.
- VD (8, § decUnszElabRespellKeepsM1_423):
  - vd01, vd03 and vd06 go to STRICT_EQUAL. These are a reader that is not the
    whole RHS, a child instance, and 'D, 'd0, 'd1 and 'd4294967295.
  - vd05 (two whole-RHS readers) is a STRICT_EQUAL control, byte-identical.
  - vd04 (interface, generate block) and vd07 (function localparam) move
    toward golden.
  - vd02 (overrides 5, 8'd5 and 'd7) and vd08 (defparam) are untouched.
- VO (4, § octUnszElabRespell423): all four move toward golden. 'o1x is
  skipped as the law says.
- VS (17, § unszBasedPkgFoldUnsized423):
  - The five cont-assign whole-RHS cases are fixed by the refinement (above).
  - vs04, vs11 and vs12 go to STRICT_EQUAL.
  - vs05, vs08, vs10, vs13, vs14 and vs15 move toward golden.
  - vs06 (a read inside the package itself), vs07 ('hx / 'bz) and vs09
    (generate bounds) are byte-identical to pristine.
- The switches: R11U423_OFF restores pristine on 41 of 41, and R11V423_OFF
  restores the law on 41 of 41.

Downstream (drivers/ds.sh) on the 34 class-free case dirs, pristine / law /
verified:
- 6 improve: vo01 DIVERGENT -> IDENTICAL; vo04, vs05, vs10 and vs12
  EQUIVALENT -> IDENTICAL; vs15 DIVERGENT -> EQUIVALENT.
- The rest keep their verdict (vd02, vd07, vo03, vs07 and vs08 EQUIVALENT,
  vd08 STATUS_DIFF on all three).
- None is worse, and the law and verified verdicts are equal on all 34.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The implementer's list stands: the 4 testbenches rows and 16 uvm-examples
   rows behind TypeEmit, untyped imported case items, a class assignment's
   right side, a module process operand, us05, ci07, ci03, ci10, ci14, the
   overridden 'd (ud04 and this pass's VD/vd02), the net-declaration
   initializer of a module 'd parameter (ud07), the signed octal uo04, and
   r11u109 f1.
2. NEW: a whole-RHS cont-assign read of a QUALIFIED package parameter, `assign
   y = p::H` with an 8-bit y. Golden writes size 8 and ours writes 32 (the
   reader resize reaches only the net-declaration road; VS/vs16).
3. NEW: a net-declaration read `wire [7:0] w = H` of an untyped unsized based
   package parameter. Golden carries no typespec there at all, and ours keeps
   the actual-less ref_typespec (VS/vs03).
4. NEW: a port actual `.i(H)`. Golden sizes the port's copy at -1 and ours at 32
   (VS/vs15). Also signed-base package parameters 'sh / 'sd (VS/vs08, reached
   by the law since unszBasedLit423 accepts the `'s` base; toward golden, the
   rest of the row's head unrelated).
5. Carried: passes 401-421 as listed in the brief.

## Sister-ground faces

The implementer's list is confirmed as written and not re-measured. Nothing
new was found on the module/type ground.

## Process

- A verifier slip, affecting no measurement. A first uhdm-cmp call on the vs01
  pair ran from a shell that had not sourced the environment, so an unset
  $UHDM_CMP made bash run a golden database as a script. It wrote nothing (the
  worktree and the main tree were checked clean). Every later call sources the
  environment and guards with `[ -x ]`.
- A verifier slip, affecting no measurement. The first launcher's quiet check
  ('swee[p].sh') matched its own name, v11u423_fullsweep.sh. It was stopped by
  its own PID before any stage started, renamed and relaunched. Both sweeps
  then waited out the pass-424 verifier's sweep and the master's pass-424
  integration sweep.
- The bp_unicore single-row runner call started when one sweep-pattern
  process was live (pgrep printed 1, gone a few seconds later). Its wall time
  may carry that load; the maxrss and exit code do not.
- The fence list was read into a file by a program and never printed. Every
  tree-wide list was filtered on it first. No other agent's process was
  touched.
- Budget: one law build (md5 equal to the implementer's), one verified build,
  one sweep each, no pristine build or sweep.
