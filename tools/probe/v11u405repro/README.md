# v11u405 — adversarial verification of r11u405

Verifier of pass 405 (the sv-tests campaign's third pass on the
expression/parameter ground: src/ExprEmit.cpp, src/EmitHelpers.h,
src/StmtEmit.cpp, src/ParamEmit.cpp), base 30acad58.  Implementer's patch
/tmp/r11u405.patch (md5 397cdc117ad00eeb1a05d708dabe4883) applies clean on a
fresh 30acad58; it carries ExprEmit, ParamEmit, StmtEmit, tests/LAWS.md and
tools/probe/r11u405repro only.  The no-header audit reads no src/R*.h, no
getenv and no reader definition in the added lines; the patch holds 18 laws
(the implementer's report says 17; its own table lists 18), every one through
lawOn(405, "R11U405_<LAW>_OFF").

VERDICT: the implementer's headline numbers reproduce bit for bit.  The
attack found ONE break on legal SV where pristine was right and the law wrong
(§ hierSelWidthLocalKeep405 in an elaborated port connection, VH/vh10
STRICT_EQUAL -> NOT_EQUAL), plus moves away from golden in the same law's
module-item variable declarations, and an elaborated size that § 
unboundedTypedParamTs405 writes as 32 for every type.  Both are fixed here by
two refinements read through fixOn(405, ...); the verified binary is swept on
all five stages with 0 regressions and the same 48 sv-tests conversions.
Deliverable: /tmp/r11u405.verified.patch.

## Binaries (built by the verifier, frozen before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine `/tmp/v11u405_bin/pristine.bin` | 10ec176d3fff159e0ac0aca38dbe6f32 | equal to the main tree's build at the base |
| law `/tmp/v11u405_bin/law.bin` | 4683ce55a2a022a55c36df946217f465 | equal to the implementer's law26.bin |
| verified `/tmp/v11u405_bin/verified1.bin` | f035bb9e489bb7b4c6436b996b9f1cff | law + the two refinements below |

All link slang 12.0.0+545f88b2e.  Binary audit: every corpus cmds.txt of the
law sweep names law.bin (surelog 1531 + uhdm2rtlil 1742 = 3273; the other 50
surelog cmds.txt hold no slang line) and none another binary; 2346 of 2346
sv-tests cmds.txt name law.bin.  The verified sweep the same with
verified1.bin.

## Reproduction of the implementer's numbers (law binary)

* probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions 0, conversions
  0, changes 0; probe.csv identical to the master's control /tmp/intr11u403.
* surelog: default CMP_EQUAL 480, testflags 474, Tnoc d/t CMP_NOTEQUAL as at
  the base; 0/0/0.  The only csv lines differing from the control are the
  LowMemLib / LowMemPkg detail text (the work dir path, environment).
* uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
* downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  csv identical to the control.
* canaries ok=52 and ok=16 (changed 0); ctcan2 PASS on both csvs
  (EXPECT_UNKNOWN=1 / 6).
* byteverify (SELFCHECK=1) law workdir /tmp/v11u405_lw against
  /tmp/intr11u403: surelog 4 of 962 (Earlgrey_0_1 d/t, Tnoc d/t), uhdm2rtlil
  0 of 1608, downstream 0 of 805: exactly the implementer's movers.  Trace
  census (R11U405_TRACE on the sweep): Earlgrey_0_1 d/t 58
  hierSelWidthLocalKeep405 each, Tnoc d/t 3664 ifacePortTdCastLogicTs405 + 2
  tpCastBeforeTpListed405 each, probe r10earl111repro/g6_view111 2
  hierSelWidthLocalKeep405 (csv row unchanged), const_func_block_var
  (uhdm2rtlil d/t, downstream) 1 blockParamWrittenRhs405 with identical bytes.
* sv-tests (evidence/svtests_law_vs_30acad58.txt): regressions 0,
  conversions 48, changes 0 against the 30acad58 golden; EQUAL 1548 -> 1591,
  STRICT_NOTEQUAL 9 -> 13, DIFFERENT 381 -> 335, SURELOG_ONLY 77 -> 76,
  BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; the 48
  paths are the implementer's list path for path, and the csv is identical on
  all 2346 rows to the implementer's /tmp/r11u405_wd/svtests.csv.  Against the
  master's control only those 48 rows differ in status.  The sv-tests trace
  census fires on 66 rows, the same 66 rows as the implementer's census.
  NOTE: the master landed pass 406 (e748204cb) while this stage ran, so the
  stage's own printout (evidence/svtests_law_vs_e748204cb_golden.log, run
  through the main tree's check_svtests.py) compared against pass 406's
  promoted golden and printed 21 "regressions" that are pass 406's own
  conversions, absent from a 30acad58 binary; the re-comparison against the
  30acad58 golden (drivers/svcmp.py, the same RANK/ACCEPTING rules imported
  from scripts/check_svtests.py) is the reading above, and the verified
  stage was run with --baseline at the 30acad58 golden.
* the implementer's grid (tools/probe/r11u405repro, 121 case dirs) rerun on
  this verifier's binaries reproduces evidence/grid_law.txt line for line,
  including the own-switch and R11U405_OFF lines (121 of 121).  The movers it
  counted away by uhdm-cmp lines are toward golden by dump distance (SC/sc28
  50 -> 18, sc29 44 -> 12, PZ/pz11 68 -> 36).
* away census on the 23 sv-tests rows a law fired on and that are not EQUAL
  under the law (evidence/svtests_away_census_law.txt, normalised dump
  distance to Surelog's cached golden): 16 toward, 1 the same
  (bsg_source_sync_channel_control_master), 0 away; the 6 black-parrot rows
  have no database (SURELOG_CRASH).
* black-parrot: bp_unicore alone, law binary with the 403 guard on: exit 3 in
  14.9 s, max RSS 820 MB (Python rusage), the pristine substr message.  The
  guard stays (no memory-bounded export found; pass 403 measured 10-11 GB
  without it).  This run overlapped another agent's sweep (r11u408), which
  only adds load.

## Attack: 105 fresh case dirs in 15 groups (cases/, drivers/grid.sh)

Golden by Surelog v1.87 `-parse -nobuiltin -nocache -sv dut.sv` (every case
accepted by Surelog and by upstream slang; VI/vi05's `$display` inside a class
was rewritten before counting because `-nobuiltin` Surelog rejects it), both
binaries `dut.sv --single-unit --nobuiltin`, uhdm-cmp lines, uhdm-strictcmp
verdict and the normalised dump distance to golden (`dist`), exit codes on
every line (evidence/grid_law.txt, evidence/grid_verified.txt).

| group | law(s) attacked | cases |
|---|---|---|
| VS | § undefParamCastSizeTs405, § castSizeGenFence405, § castSizeParenComputed405 | vs01-vs12 (procedural, function, declaration, port-actual, typed, paren, interface, gen + module casts, localparam init) |
| VZ | § impUnbasedLitKept405, § impUnbasedReadIsLit405 | vz01-vz07 (always_comb, `p::P`, 'z in a ternary, body import, function, gen block, always_ff) |
| VH | § hierSelWidthLocalKeep405 (+ § hierSelWidthCtxModItem405v) | vh01-vh15 (variable declaration, always, gen block, gen localparam, net + assign, named / ordered / gen port actuals, procedural and gen declarations, list declarators, child module, generate region) |
| VT | § typenameKwIsString405 | vt01-vt05 (int unsigned, logic signed, bit [7:0], localparam string, function, continuous assign) |
| VR | § nestedRepPatCount64_405 | vr01-vr05 |
| VD | § disableTargetScopeChain405 | vd01-vd08 (task from initial, enclosing block from fork, hierarchical, self-disable, sibling block, fork sibling, block of another initial, task from task) |
| VI | § implicitNetOnePerName405 | vi01-vi06 (two processes, interleaved iterators, two tasks, 2-D, class method, two modules) |
| VB | § blockParamWrittenRhs405 | vb01-vb08 (int, ranged logic, function block, signed, cast init, string, real, x/z literal chain) |
| VP | § implicitPortPaLastNoBody405 | vp01-vp05 |
| VU | § unboundedTypedParamTs405 (+ § unboundedElabSizeIsTypeWidth405v) | vu01-vu05 (overridden, localparam integer, longint, shortint + byte, logic [11:0]) |
| VC | § ifacePortTdCastLogicTs405 | vc01-vc11 (module port, interface port, struct alias, gen block, function, alias-of-alias, port-passed interface arrays, parameterized types interface) |
| VE | § tpCastBeforeTpListed405 | ve01-ve04 (overridden T, int, $bits default, struct T) |
| VM | § hierSelMacroBoundPretty405 | vm01-vm04 |
| VK | § bitsParamArgNoFold405 | vk01-vk04 |
| VA | § modUnpackedDimArithRef405 | va01-va06 |

### Law binary vs pristine (105 cases)

* 47 NOT_EQUAL -> STRICT_EQUAL, 1 NOT_EQUAL -> STRICT_NOTEQUAL (VA/va06, the
  `file` residue UA/ua06 shows on pristine), 1 STRICT_NOTEQUAL ->
  STRICT_EQUAL (VS/vs08), 8 STRICT_EQUAL and 3 STRICT_NOTEQUAL unchanged, 44
  NOT_EQUAL on both;
* ONE STRICT_EQUAL -> NOT_EQUAL: **VH/vh10** (pristine right, law wrong);
* four exit codes 4 -> 0: VC/vc09 (the § ifacePortTdCastLogicTs405 positive
  control: the implementer's TN cases never fire that law, it fires only in
  tnoc and the Tnoc corpus rows; vc09 reproduces golden's logic_typespec
  (hdr_t) at 7:11-16), VE/ve01, ve02, ve04;
* away by dump distance (8): VH/vh01 12 -> 32, vh06 22 -> 28, vh09 16 -> 34,
  vh10 0 -> 28, vh11 37 -> 97, vh13 12 -> 32, vh14 22 -> 28, VE/ve01 58 -> 78;
  69 toward, 1 the same;
* own switch(es) and R11U405_OFF give pristine's bytes and exit code on 105 of
  105.

### The break and its decode (§ hierSelWidthLocalKeep405)

The law keeps a module localparam width (`p.addr[0+:l]`, vpiWidthExpr ref_obj
`l`) everywhere except a NET declaration initializer.  Golden, measured:

| context | golden | law |
|---|---|---|
| module-item `wire w = p.addr[0+:l]` (BlackBePipeInt's witness) | `[0+:3]` | `[0+:3]` |
| module-item `logic w = p.addr[0+:l]`, `var logic`, list declarators (vh01, vh11, vh13) | `[0+:3]` | `[0+:l]` (away) |
| `generate ... endgenerate` region net declaration (vh15) | `[0+:3]` | `[0+:3]` |
| net declaration inside a generate BLOCK (vh12) | `[2+:l]` | `[2+:3]` (pristine's wrong form) |
| declaration in a procedural block or in a generate block (vh07, vh08) | `l` | `l` |
| definition view of a port actual (vh06, vh09, vh14) | `l` | `l` |
| ELABORATED port actual (vh06, vh09, vh10, vh14) | `[0+:3]` (constant) | `l` (away; vh10 STRICT_EQUAL on pristine) |

**§ hierSelWidthCtxModItem405v** (ExprEmit, inside the law's gate;
R11V405_HSWCTX_OFF): the substituting contexts are a module-ITEM declaration
initializer (net or variable, parent the module, interface or program, a
generate region transparent) and an elaborated child port actual
(elabConnEmit21, § elabConnSelFoldNoTs21's view); a net declaration inside a
generate block keeps the name.  Result: vh06, vh12, vh14 NOT_EQUAL ->
STRICT_EQUAL, vh10 back to STRICT_EQUAL (pristine's bytes), vh01, vh09, vh11,
vh13 back to pristine's bytes (their remaining head is the localparam
constant's missing param_assign parent and int typespec, wrong on pristine
too).  The implementer's 20 PH cases keep their law bytes (0 of 121 r11u405
grid databases move between law and verified).

### § unboundedElabSizeIsTypeWidth405v (ParamEmit; R11V405_UNBSIZE_OFF)

§ unboundedTypedParamTs405 re-encodes the elaborated `$` as a STRING constant
of size 32 for every type; golden sizes it by the parameter's type (longint
64, shortint 16, byte 8, logic [11:0] 12; int and integer 32).  The
refinement writes the type's bit width: VU/vu03, vu04, vu05 NOT_EQUAL ->
STRICT_EQUAL (downstream DIVERGENT -> IDENTICAL on all three); 20.6--isunbounded
(int) unchanged.

### Verified binary vs pristine (105 cases)

53 NOT_EQUAL -> STRICT_EQUAL, 1 NOT_EQUAL -> STRICT_NOTEQUAL, 1
STRICT_NOTEQUAL -> STRICT_EQUAL, 9 STRICT_EQUAL and 3 STRICT_NOTEQUAL
unchanged, 38 NOT_EQUAL on both; none leaving an equal status; 72 toward, 1
the same (VS/vs12), 1 away (VE/ve01, below).  Own switch(es) and R11U405_OFF
give pristine's bytes and exit code on 105 of 105; R11V405_OFF gives the law
binary's bytes and exit code on 226 of 226 (these 105 + the implementer's
121), each refinement's own switch on its group 20 of 20
(evidence/voff.txt).  Downstream (drivers/ds.sh, scripts/downstream_uhdm2rtlil
one()) on the 96 class-free cases, law vs pristine: 72 IDENTICAL kept, 12
improving (VE/ve04, VP/vp02, VS/vs09, VT/vt05, VZ/vz01, vz02, vz04
EQUIVALENT -> IDENTICAL, VZ/vz03 STATUS_DIFF -> IDENTICAL, VZ/vz07 DIVERGENT
-> IDENTICAL, VU/vu03-vu05 DIVERGENT -> EQUIVALENT), none worse; the verified
binary on VH, VU and VC: VU/vu03-vu05 DIVERGENT -> IDENTICAL, none worse.

## Verified sweep (all five stages, verified1.bin, once)

* probe 4018 + 69, 0/0/0, csv identical to the control and to the law sweep;
* surelog 480 + 0 / 474 + 0, Tnoc d/t CMP_NOTEQUAL, 0/0/0; uhdm2rtlil
  803/1/67 both modes, 0/0/0; downstream 803/66/2/0;
* sv-tests (against the 30acad58 golden): regressions 0, conversions 48,
  changes 0, the csv identical to the law sweep's on all 2346 rows;
* byteverify verified vs law: 0 of 962, 0 of 1608, 0 of 805 (predicted by
  name before the sweep: Earlgrey_0_1 default, probe g6_view111 and the two
  basejump rows where § hierSelWidthLocalKeep405 fires were rerun on the
  verified binary and matched the law's databases; the trace census of the
  sweep shows neither refinement firing on any corpus row, probe case or
  sv-tests row, the positive controls VH/vh06 elabconn, vh12 gennetdecl and
  VU/vu03 firing); verified vs control the same 4 of 962 movers as the law;
* canaries ok=52 / ok=16, ctcan2 PASS; binary audit as above;
* the sweep's exit code 1 is the law-index check alone (cases were added
  during the sweep; the index is regenerated in the patch).

## Residues (ranked; all wrong on pristine too unless said)

1. **VE/ve01** (§ tpCastBeforeTpListed405 when the instance OVERRIDES the
   type parameter): golden's cast typespec is the declaration DEFAULT
   (logic_typespec 2:31-42) even in the overriding body; the law builds
   makeTypespec on the overridden type (6:10-21).  Pristine exited 4 here, so
   this is a goal-1 gain with a wrong typespec, dump distance 58 -> 78
   (cmp lines 60 both).  Decoded fix (not landed, measurement budget: a
   third build and sweep): read the default from the header's
   TypeParameterDeclaration declarator and build it with
   makeTypeParamDefaultTs when tp294->isOverridden().
2. § hierSelWidthLocalKeep405's remaining head on vh01/vh09/vh11/vh13/vh05:
   the substituted localparam constant lacks golden's param_assign parent and
   int_typespec (wrong on pristine).
3. VS/vs07: a default-less parameter in an INTERFACE (the law is fenced to
   modules; golden mints the cast typespec there too; the interface listing
   itself is the sister's).
4. VC/vc07, vc08, vc10, vc11: casts through an interface-port typedef where
   pristine already writes a typespec but golden differs (the law does not
   fire); VR/vr01 (a localparam's nested replications, law silent); VD/vd02
   and vd03 (an enclosing block disabled from a fork, a hierarchical
   disable); VU/vu01 (an overridden `$` parameter: golden keeps the
   $isunbounded operation unfolded); VK/vk01-vk03 (the $bits(param)
   localparam moves toward but the elaborated value differs).
5. The implementer's residue list stands as written in
   tools/probe/r11u405repro/README.md (basejump computed localparams, the 6
   definitions § undefaultedDefInvalidInst404 abstains on, singletons, 16.10,
   tnoc's next head, pass 401's and 403's lists not reached).

## Sister-ground faces

None new beyond the implementer's list; VS/vs07's interface listing and the
property/sequence listings stay ModuleEmit's.

## Process

* Base moved during the pass: the master landed pass 406 (e748204cb) while
  the law sweep's sv-tests stage ran; all readings are against the 30acad58
  goldens (the worktree's results/ for the corpus stages, the 30acad58
  golden_svtests.csv for sv-tests).
* Slips: a first Monitor waiting on the master's sweep used pgrep -f with a
  pattern its own command line contained and would never have ended; it was
  stopped by its task id and replaced by a wait on the master sweep's PID; no
  process of another agent was signalled.  A first verified build failed to
  compile (SyntaxKind::SyntaxList does not exist in slang v12) and produced no
  binary; the copy it left at verified.bin was the law binary and was deleted
  unused.  A drafted third refinement (residue 1) was written and reverted
  before any build, by the measurement budget.  The bp_unicore measurement
  overlapped another agent's sweep.  The Earlgrey prediction run used the
  corpus test directory as its working directory, writing only to scratch
  (the submodule stays clean).  No fenced test was named, read or dispatched;
  nothing written outside /tmp/wt_v11u405, /tmp/wt_v11u405pris and
  /tmp/v11u405_*.

## Files

cases/<GROUP>/<case>/dut.sv (first line `// § <law>`), drivers/grid.sh (the
grid), drivers/voff.sh (R11V405_OFF and the refinement switches), drivers/ds.sh
(downstream verdicts), drivers/away.sh (sv-tests away census), drivers/svcmp.py
(sv-tests csv vs a chosen golden), evidence/ (grids, sweeps, census, downstream).
