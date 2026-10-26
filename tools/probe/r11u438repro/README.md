# r11u438 — the whole-name and net-declaration unsized-constant clone legs (module/type ground)

The nineteenth pass of the sv-tests campaign on the module/type ground (pass
438), base 82e1e458. Production file: src/ModuleEmit.cpp only (TypeEmit,
UhdmExporter, TaskFuncEmit, uhdm_main.cpp and the sister's ExprEmit,
EmitHelpers.h, StmtEmit and ParamEmit unchanged).

## Result

| sv-tests row | before (results/golden_svtests.csv) | after (this pass's sweep) |
|---|---|---|
| generated/fx68k/fx68k.sv | STRICT_NOTEQUAL differ:fullname(4) | **EQUAL** (`generated/fx68k/fx68k.sv,EQUAL,,equal`; uhdm-strictcmp STRICT_EQUAL 82353 objects, uhdm-cmp 0 lines) |

sv-tests: EQUAL 1906 -> 1907, STRICT_NOTEQUAL 2 -> 1, every other count
unchanged (BOTH_REJECT 303, DIFFERENT 32, SLANG_ONLY 19, SURELOG_CRASH 8,
SURELOG_ONLY 75, TIMEOUT 1 of 2346); regressions 0, conversions 1, changes 0.
Goal 1: nothing on this ground; all 75 SURELOG_ONLY rows carry an upstream
slang front-end diagnostic (no detail names an exporter message).

## The decode

fx68k's last strict field (pass 433's report): fx68k.sv 1815/1816 `assign
isLineA = lineBmap['hA];` inside `uaddrDecode`, golden full names
`work@fx68k.uaddrDecode.lineBmap` / `.isLineA`, ours
`work@uaddrDecode.*` (the elaborated view shared the definition's cell).

Surelog's `UhdmWriter::writeCont_assign`
(third_party/Surelog/src/DesignCompile/UhdmWriter.cpp) clones an elaborated
cell in four legs: a named delay; a plain-name Lhs bound by `bindVariable`
with an OPERATION Rhs; a typespec'd Lhs whose Rhs flattens to an operation;
a Rhs `reduceExpr` turns into a constant. When none fired (`simplified ==
false && cloned == false`), `DetectUnsizedConstant` clones the whole cell
(`clone_tree(assign, ElaboratorContext(&s, false, true))`, parent the
instance) when an unsized constant sits anywhere in the Rhs. The leg does
not look at the Lhs. § caUnsizedRhsClonePerInst193 modelled it for a select
or concatenation Lhs only (`!plainLhs`); a whole-name Lhs whose Rhs is no
operation (a bit, part, indexed or element select) reaches the same leg. A
net-declaration assignment goes through the same writer: the clone copies
its Lhs net, so golden lists a fresh Lhs net with its own typespec copy
(the shape § ndaConstRhsFreshLhs271 builds for the constant leg).

Two exclusions, both from the reduce leg that runs before the fourth one:
a Rhs reading no net or variable folds to a constant (a different clone,
pu05, nd03, nd13 stay as on pristine), and a user function call is evaluated
by the reducer (v11u417's VH/vh12 `assign o = f('0, i);` folds to BIN:0000
in golden; the law4 draft cloned it and moved vh12 one dump line away, so
law5 abstains on any user call, § ifUnsizedUserCallAbstains305v's finding
for the interface twin).

## Laws (src/ModuleEmit.cpp, read through src/LawSwitch.h; R11U438_OFF drops all)

- § caPlainLhsUnsizedClone438 (R11U438_PLAINUNSIZED_OFF): in the elaborated
  module view a shared cell with a whole-name Lhs whose Rhs holds an unsized
  constant (rhsHasUnsized438: rhsHasUnsized193's shapes plus a var_select's
  indexes), reads a net or variable and holds no user call, is cloned per
  instance through § caUnsizedRhsClonePerInst193's drain. lawTrace
  `caPlainLhsUnsizedClone438` / `PLAINUNSIZED438_ABSTAIN`.
- § ndaUnsizedRhsFreshLhs438 (R11U438_NDAUNSIZED_OFF): the module
  net-declaration twin, a fresh Lhs net for such an initializer.
- § genNdaUnsizedFreshLhs438 (R11U438_GENNDAUNSIZED_OFF): the generate-scope
  twin, overriding the scope-net sharing of § genNdaSelRhsSharesNet303 and
  the scalar loop scope for such an initializer.
- § ifNdaUnsizedFreshLhs438 (R11U438_IFNDAUNSIZED_OFF): the interface twin.

No src/R*.h, no getenv, no reader function, no LawState.h section; no flag
written across files. The four laws share two helpers in ModuleEmit's
anonymous namespace (rhsHasUnsized438, rhsHasUserCall438).

## Grid (cases/PU 29 dirs, cases/ND 14 dirs; evidence/grid_law5.txt)

Each case's first line names its law; drivers/grid.sh runs pristine (the
main tree's build, md5 a1389d52cb05d259babaa70fa64f23a7) and law5, with
R11U438_OFF and the case's own switch.

- 22 STRICT_NOTEQUAL -> STRICT_EQUAL: PU pu01 to pu04, pu11, pu12, pu14 to
  pu16, pu19, pu20, pu24, pu25, pu27 (§ caPlainLhsUnsizedClone438, pu12
  § ndaUnsizedRhsFreshLhs438), ND nd01, nd04, nd06 (§ ndaUnsizedRhsFreshLhs438),
  nd08 to nd10 (§ genNdaUnsizedFreshLhs438), nd05, nd12
  (§ ifNdaUnsizedFreshLhs438).
- 1 STRICT_EQUAL on both with different bytes: pu13 (an uninstantiated top,
  instance and definition share the path, the clone is invisible to both
  judges).
- 20 controls byte-identical to pristine: pu05 (a parameter-only Rhs),
  pu06, pu21, pu22, pu29 and nd14 (user calls), pu07 (a generate-block
  cell, already equal), pu08 and nd07 (`$countones`), pu09 (interface,
  § ifCaUnsizedRhsClonePerInst305 already), pu10 (`'b1` sized), pu17 (a
  localparam index), pu18 (a named delay), pu23, pu26 (a concatenation),
  pu28 (a program), nd02 and nd11 (sized indexes), nd03 and nd13 (a
  parameter-only initializer).
- every exit code 0 on both binaries; R11U438_OFF gives pristine's bytes on
  43 of 43 and each case's own switch on 43 of 43; upstream slang accepts
  every case.
- downstream (drivers/dsgrid.sh, evidence/downstream_cases_law4.txt): the 41
  case dirs of the law4 grid IDENTICAL on both binaries.

## Gates

- The one full five-stage sweep, on law4 (md5 4d0773c37fd1e336e70f82eb6aeaae75)
  with the trace on (drivers/fullsweep.sh: the four corpus stages through the
  worktree's tests/sweep.sh, the sv-tests stage through the main tree's
  scripts/check_svtests.py since a worktree has no UVM tree;
  evidence/sweep_law4_corpus_summary.txt): probe EQUAL 4019 + STRICT_NOTEQUAL
  68 with 0/0/0; surelog default 480 + 0, testflags 474 + 0, 0/0/0;
  uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream IDENTICAL 803,
  SLANG_REJECT 66, EQUIVALENT 2, not identical and not excused 0; sv-tests
  0 / 1 / 0 (fx68k). Against the master's control /tmp/intr11u436: probe,
  uhdm2rtlil and downstream csvs identical, surelog differing only in the two
  LowMem log-path texts, svtests only in the fx68k row.
- The trace census (evidence/sweep_trace_law4.txt): the laws fire on one
  database of the whole sweep, fx68k, on its two cells 1815 and 1816;
  PREDICTED before the sweep by name: a traced law run over all 4087 probe
  cases (0 firings, a positive control on pu01 firing), a traced targeted
  verify_golden on the 54 surelog and 25 uhdm2rtlil tests whose sources hold
  a candidate statement (drivers/scan_candidates.py, fence-filtered; 0
  firings, every status equal to the baseline) and a traced runner call on
  the 31 sv-tests rows whose files hold one (fx68k only).
- byteverify law4 against the control (evidence/byteverify_law4_vs_control.txt):
  surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805, the
  self-checks flagging 961, 1607 and 804; the probe and kept sv-tests
  databases by path-normalized dump (drivers/dcmp.sh): 4087 probe and 53 of
  54 kept sv-tests databases identical (tnoc's dump not finished, stopped
  after the sister's verified sweep started; tnoc fires no law), a positive
  control (pu01 pristine against law) that moves.
- canaries ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil),
  both ctcan2 checks PASS; the binary audit fence-filtered: surelog 1523 of
  1573 command records naming law4 (the other 50 holding only a Surelog
  line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.
- The earlier-pass census (drivers/bytecensus.sh over 5118 fence-filtered
  case dirs of passes 401 to 436, evidence/earlier_pass_census_law*.txt):
  exit codes equal everywhere; law5 moves 5, all toward golden: r11u433
  HX/hx01 to hx04 STRICT_NOTEQUAL -> STRICT_EQUAL (pass 433's residue for
  this face, dump distance 26/26/26/17 -> 2, the path line), v11u425
  VQ/vq10 STRICT_EQUAL on both with dump distance 59 -> 0. law4 moved v11u417
  VH/vh12 too (NOT_EQUAL on both, 63 -> 64): the user-call break, fixed in
  law5 (byte-identical to pristine there).
- law5 (md5 a59709b933e2dbc6e3098e2fb6786d3b, the final binary) against law4:
  law5 only adds the user-call abstention; the sweep's trace shows the laws
  firing nowhere but fx68k's two select cells, so every sweep input gives
  law4's bytes; checked on fx68k (law4 and law5 byte-identical, STRICT_EQUAL
  82353 objects, uhdm-cmp 0 lines), a traced law5 run over the 4087 probe
  cases (0 firings) and over the 31 sv-tests candidate rows (verdicts
  identical to law4's, fx68k the only firing). Three concurrent fx68k
  draws on law5 read one hash.

## Measurement budget

No pristine build and no pristine sweep (the master's control /tmp/intr11u436
and the main tree's build frozen for case runs). One full sweep, on law4;
law5 narrows law4 after the earlier-pass census found the vh12 break, and
the trace argument above stands in for the second sweep (deviation recorded:
the sweep binary is law4, the final binary law5). Builds law1 to law5 used
on case runs and targeted calls only. No build, grid or runner call of this
pass overlapped a sister sweep: every batch waited on drivers/quiet.sh
(three quiet readings); a path-normalized dump comparison of this pass
(tnoc) was still running when the sister v11u435's verified sweep started
and was stopped by task id. The fence list was read into a file by a
program, never printed; every tree-wide list was filtered on it first.

## Residues (ranked; all wrong on pristine too)

1. The 16 uvm-examples rows (the largest open cluster on this ground; pass
   426's this_type vpiInstance face, then about 30 heads) — not reached.
2. The 3 uvm_scoreboard testbench rows (golden design null) and easyUVM.
3. The 8 basejump inv-placeholder rows (round_robin_fifo_to_fifo's head is
   still the typedef range `width_p*num_out_p-1` golden keeps unfolded where
   ours folds INT:7; control_slave and dff_en_segmented head at the design's
   module list); p737 and tnoc (await the user).
4. This face's own: user calls with an unsized argument (pu06, pu21, pu22,
   nd14: golden clones where the reducer does not fold, folds where it can;
   the abstention keeps pristine's bytes); the select-Lhs leg
   § caUnsizedRhsClonePerInst193 does not see an element select's indexes
   (rhsHasUnsized193 has no var_select case).
5. The carried lists of passes 436 and earlier, unchanged.

## Sister-ground faces (reported, not written)

None new; pass 436's apb_protocol_monitor left-side select span (ExprEmit
under StmtEmit's assignment) stands as the one STRICT_NOTEQUAL row.

## Files

cases/PU, cases/ND (43 case dirs); drivers/ (grid.sh, run1.sh, sc.sh,
dist.sh, ddiff.sh, cmp.sh, dsgrid.sh, bytecensus.sh, fullsweep.sh,
quiet.sh, bld.sh, gold.sh, scan_candidates.py, probe_trace.sh,
dcmp.sh, switches.txt); evidence/.
