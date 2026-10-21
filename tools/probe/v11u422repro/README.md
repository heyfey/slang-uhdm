# v11u422 — adversarial verification of r11u422 (module/type ground, pass 422)

Base 5b736803 (pass 420). Implementer's patch /tmp/r11u422.patch, applied clean.
Law binary rebuilt once in /tmp/wt_v11u422: md5 0542fc402d08d349f984ac9ea1af89b1,
equal to the implementer's law19 (frozen /tmp/v11u422_bin/law). Pristine: the
implementer's frozen base build, md5 c9ef73f8cb6af6970663ee549c1b65aa (copied to
/tmp/v11u422_bin/pristine; no pristine build, no pristine sweep: the pristine
reading is the master's control /tmp/intr11u420). Verified binary
/tmp/v11u422_bin/ver1, md5 481e5cde980877debfcb7b6f2b6ee9ea.

## Verdict

THE LAWS HOLD ON THEIR TARGETS. TWO BREAKS were found on legal SV that upstream
slang accepts, where pristine was right and the law wrong. Both are fixed behind
their own switches; the targeted sv-tests rows and every gate are unchanged.

1. § derivedClassFullNameOrder422 sorted vpiDerivedClasses by FULL name. But
   Surelog's design class map holds a class NESTED in a class under its BARE name:
   CompileDesign copies each class's own map, which ClassDefinition::insertClass
   keys by getName. The break: VD/vd06 (a module base with a nested derived class
   work@top::X::N) and VD/vd07 ($unit work@A::zed) went STRICT_EQUAL -> NOT_EQUAL
   at 106 and 70 uhdm-cmp lines. Fixed by § derivedNestedBareKey422v.
2. § strNetRefMintsNet422 counted every name equal to the strength net's name as
   a minting reference, and so minted at references that do not read the net:
   - a select c[0] or c[1:0]. Golden mints no net there, and mints at a later
     whole reference;
   - a member or hierarchical name s.c or top.c;
   - a name that a begin-end block or a for loop declares again.

   The break: VS/vs03 and vs11 went STRICT_EQUAL -> NOT_EQUAL (470 and 494 lines),
   and downstream IDENTICAL -> STATUS_DIFF and IDENTICAL -> DIVERGENT. In vs01,
   vs02 and vs06 a spurious definition-view net appeared where pristine wrote none.
   vs09, vs12 and vs13 minted at the wrong line (STRICT_NOTEQUAL line). Fixed by
   § strNetRefNotNetSkip422v.

## Refinements (src/LawSwitch.h fixOn(422, ...); R11V422_OFF drops both)

- § derivedNestedBareKey422v (UhdmExporter, drainPendingExtends;
  R11V422_NESTEDKEY_OFF): the derived-order key of a class whose parent is a
  class_defn is its bare name. Cases VD/vd06, vd07, vd08 (vd08: two nested N
  in two outer classes, NOT_EQUAL on pristine and law, STRICT_EQUAL on ver1).
- § strNetRefNotNetSkip422v (ModuleEmit, strNetRefs422;
  R11V422_STRREFSKIP_OFF): these references are skipped and the walk goes on:
  - a select of the name (IdentifierSelectName);
  - a name that is a member of a ScopedName;
  - a name that an enclosing begin-end block or for loop declares again.

  Cases VS/vs01, vs02, vs03, vs06, vs09, vs11, vs12, vs13.

No src/R*.h, no getenv; both switches go through fixOn. tests/LAWS.md was
regenerated and `--check` passes.

## Reproduction of the implementer's claims (law binary)

- Full five-stage sweep, workdir /tmp/v11u422_lw (evidence/sweep_corpus.log,
  evidence/sweep_svtests.log; the sv-tests stage ran through the main tree's
  scripts/check_svtests.py, byte-identical to the worktree's, with --baseline set
  to the worktree's base results/golden_svtests.csv):
  - probe: 4018 + 69, 0/0/0; the csv is byte-identical to the control.
  - surelog: 480 / 474, 0/0/0; the csv differs from the control only in the two
    LowMem log-path texts.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0; the csv is identical.
  - downstream: 803/66/2/0; the csv is identical.
  - sv-tests: EQUAL 1849, STRICT_NOTEQUAL 12, DIFFERENT 79, BOTH_REJECT 303,
    SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions=0,
    conversions=8, changes=0. The csv is byte-identical to the implementer's
    /tmp/r11u422_sw/svtests.csv on all 2346 rows.
- byteverify (SELFCHECK=1) against the control: surelog 3 of 962 (Scoreboard
  default, SimpleUVM default and testflags), uhdm2rtlil 0 of 1608, downstream
  0 of 805. These are exactly the three corpus databases on which the trace logs
  § derivedClassFullNameOrder422, and their statuses are unchanged.
- canaries: ok=52 and ok=16, changed=0; both ctcan2 checks PASS.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name the law binary
  and the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests
  2346 of 2346.
- trace census: in the corpus stages only § derivedClassFullNameOrder422 fires
  (3 corpus databases, none in probe or downstream). In sv-tests:
  - the array laws fire on utd-sv only;
  - § unnamedUdpInstName422 and § specifyRefNoDefNet422 fire on p884 only;
  - § strNetRefMintsNet422 fires on p827 only;
  - the order law fires on the UVM rows;
  - the chandle laws fire nowhere.
- the implementer's grid of 51 case dirs, reproduced line for line on exit code,
  uhdm-cmp count, strict verdict and the OFF and own-switch columns
  (evidence/grid_implementer_reproduced.txt; md5s differ only by the worktree path).

## Verified binary (ver1)

- Second full five-stage sweep, workdir /tmp/v11u422_vw (evidence/sweep2_*.log):
  - probe, surelog, uhdm2rtlil and downstream: the same as the law sweep. The
    corpus stage exited 1 only on the stale law index (the verifier's new cases),
    regenerated afterwards.
  - sv-tests: the csv is byte-identical to the law sweep's (0 / 8 / 0).
- byteverify ver1 against law: 0 of 962, 0 of 1608 and 0 of 805. Against the
  control: the same 3 / 0 / 0 as the law.
- The refinements fire on no corpus row, probe case or sv-tests row: no 422v line
  in the trace of the second sweep.
- The 112 kept sv-tests databases, law against ver1 by path-normalized dump:
  111 are identical. tnoc's dump hit its 900 s timeout; uhdm-cmp reads 0 lines
  and the sizes are equal (evidence/svtests_kept_dump_law_vs_ver1.txt).
- ver1 equals law on all 51 implementer case dirs. Switch checks
  (evidence/switches.txt):
  - R11V422_OFF on ver1 gives the law's bytes on 89 of 89 case dirs;
  - R11U422_OFF on ver1 gives pristine's bytes and exit code on 89 of 89;
  - each fix switch alone gives the law's bytes on its own cases (11 of 11).
- Determinism: three concurrent draws of VD/vd08 give one hash.

## Attack grid (38 fresh case dirs, every one accepted by upstream slang; evidence/attack_grid.txt)

pristine -> law -> ver1:
- VA (module-array concatenation and replication: a generate block, part-select
  and nested replication operands, a localparam-expression count, a concatenation
  as wide as one port, mixed operands, a parameterized child):
  - va01, va02, va04, va05 and va06 go to STRICT_EQUAL (va02 from exit 4);
  - va03 goes exit 4 -> 0, still NOT_EQUAL. Golden folds the count (W/2) as
    INT:4 at size 64, while § arrayElemReplCountFold422 writes UINT at size 32
    (residue).
- VC (chandle):
  - vc02 (package typedef) and vc03 (an unused $unit typedef, from exit 4) go to
    STRICT_EQUAL;
  - vc01 (an alias of a chandle typedef) and vc04 (local/protected properties and
    an array of the typedef) go exit 4 -> 0, still NOT_EQUAL (residue).
- VD (derived order):
  - vd01, vd03 and vd05 go NOT_EQUAL -> STRICT_EQUAL;
  - vd02 goes to STRICT_NOTEQUAL endcol, on a program class's extends
    class_typespec Q::B ending at 11:4 where golden reads 11:12 (a residue, not
    the order);
  - vd04 is a STRICT_EQUAL control;
  - vd06 and vd07 are THE BREAK: STRICT_EQUAL -> NOT_EQUAL -> STRICT_EQUAL;
  - vd08 goes NOT_EQUAL -> NOT_EQUAL -> STRICT_EQUAL.
- VP (specify):
  - vp02 (a conditional module path) goes 690 -> 0, STRICT_EQUAL;
  - vp03 is a STRICT_EQUAL control;
  - vp01 (an implicit net read in specify and later by an assign) is
    STRICT_NOTEQUAL line on all three binaries. Golden places the def net at the
    assign (9:14), ours at the specify reference (residue).
- VS (strength nets):
  - vs04, vs05, vs07, vs08 and vs10 go to STRICT_EQUAL;
  - vs03 and vs11 are THE BREAK: STRICT_EQUAL -> NOT_EQUAL -> STRICT_EQUAL;
  - vs01, vs02, vs06, vs09, vs12 and vs13 go -> NOT_EQUAL or STRICT_NOTEQUAL
    line -> STRICT_EQUAL.
- VU (unnamed UDP: two of one definition, with a delay, in a generate block and in
  a child, driving an undeclared net): vu01 to vu04 go NOT_EQUAL -> STRICT_EQUAL.
- No exit code gets worse; 9 cases go exit 4 -> 0.

Downstream on the class-free cases (VA, VP, VS, VU), pristine -> ver1
(evidence/downstream_attack_*.txt):
- 15 go to IDENTICAL: 12 from EQUIVALENT, VA/va06 from DIVERGENT, VA/va05 and
  VS/vs09 from STATUS_DIFF;
- the other 11 are IDENTICAL on both;
- none is worse.

On the law binary, VS/vs03 read STATUS_DIFF and VS/vs11 DIVERGENT, both IDENTICAL
on pristine: part of THE BREAK.

## Earlier-pass census (evidence/census_earlier_passes.txt)

2817 fence-filtered case dirs of passes 401 to 420 (r11u and v11u), pristine
against ver1:
- 2796 are byte-identical at the same exit code.
- 8 write no database at exit 3 on both binaries.
- 13 move, none away:
  - to STRICT_EQUAL: r11u404 IN/in09; r11u420 IA/ia01, ia02 and ia03 (exit 4 -> 0);
    v11u420 VA/va01, va02, va04, va05, va06 and va08; v11u414 VH/vh06 (exit 4 -> 0);
  - toward golden but still unequal: v11u420 VA/va07 (normalized dump distance
    34 -> 24) and r11u418 UG/ug08 (122 -> 36).

## Residues (ranked; all wrong on pristine too)

1. The sv-tests residues the implementer lists stand. The heads of the
   uvm-examples and testbenches rows are ParamEmit's (sister ground); easyUVM and
   the scoreboard testbench rows are not decoded.
2. A specify-referenced implicit net later bound by an assign: the definition
   view's net location (VP/vp01). § specifyRefNoDefNet422 could move it to the
   first binding reference.
3. The replication count folded from a non-parameter expression: golden INT
   size 64 (VA/va03).
4. A chandle typedef's alias and arrays of it as class properties (VC/vc01,
   vc04), and the implementer's CH/ch02, ch05, ch06.
5. A program class's extends class_typespec end column on a package-scoped base
   (VD/vd02).
6. The probe-only goal-1 shapes vh04, vc13, vy02, vu02 and aq09, and IA/ia07.

## Sister-ground faces

None new; the implementer's list stands (ParamEmit's class and interface import
parameter copies, StmtEmit's 16.17 expect).

## Process

- One law build (equal to the implementer's) and one verified build. Two full
  sweeps, one on the law binary and one on ver1, both launched on a quiet machine.
  No third build or sweep.
- Slips, none affecting a measurement:
  - The implementer-grid reproduction ran while the sister's r11u421 probe stage
    was live: the verifier's own quiet check had matched its own command line.
  - The ver1 build, the attack grids and the downstream case runs overlapped the
    sister verifier v11u421's sweep. All are single processes, and the grids
    judge bytes, not time.
- The fence list was read into a file by a program and never printed. Every
  tree-wide list was filtered on it first. No other agent's process was touched.
