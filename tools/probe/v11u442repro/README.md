# v11u442 — adversarial verification of r11u442 (module/type ground)

Verifier of pass 442 on base 4899f5c73 (src/TypeEmit.cpp, src/UhdmExporter.cpp).
Verdict: **the implementer's numbers reproduce exactly; two breaks found on legal
SV and fixed behind their own switches** (two refinements, § <name>442v through
`fixOn(442, "R11V442_<X>_OFF")` from src/LawSwitch.h; no src/R*.h, no getenv,
no reader function). Deliverable: /tmp/r11u442.verified.patch.

## Binaries (frozen under /tmp/v11u442_bin, read-only)

| binary | md5 | what |
|---|---|---|
| pristine | 9c2f5e28fcfc2802c710420b7d6ec655 | the implementer's frozen copy of the main tree's base build (the brief's pristine md5; no pristine build, no pristine sweep: the pristine reading is the master's control /tmp/intr11u440) |
| law | 4774f1a2b30c0a09c72529a446ae47ef | /tmp/r11u442.patch applied on a fresh 4899f5c73 and rebuilt once: equal to the implementer's law20 |
| ver5 (verified, final) | b0a6bb0a66fdc686e7275609ccb4e424 | law + the two refinements below |

All link slang 12.0.0+545f88b2e. ver1 to ver4 were intermediate verified builds
used on case runs only (never swept): ver1 and ver2 while fixing the CU-level
test of the first refinement, ver3 and ver4 while narrowing the second.

## The two breaks and their fixes

### 1. § unitAliasVarShadowAbstain442v (R11V442_ALIASVARSHADOW_OFF, UhdmExporter, inside § unitArrTdAliasVarBindsListing442)

THE BREAK: § unitArrTdAliasVarBindsListing442 rebinds an elaborated array_var's
bare unaliased copy to the $unit alias-clone listing by **name only**. A variable
typed by a SAME-NAMED typedef declared elsewhere was rebound to the $unit listing:

- VU/vu01 (`$unit: typedef int ua_t[2]; typedef ua_t ub_t;` and a module-body
  `typedef byte ub_t [3]; ub_t v;`): pristine **STRICT_EQUAL** 80 objects ->
  law NOT_EQUAL at 17 uhdm-cmp lines.
- VU/vu02 (a wildcard-imported package `p::ub_t` beside the $unit `ub_t`):
  pristine **STRICT_EQUAL** 123 objects -> law NOT_EQUAL 17.
- VU/vu09 (another module declares its own `ub_t`): pristine STRICT_NOTEQUAL
  type (judge-equal) -> law NOT_EQUAL 17.
- VU/vu07 (a class-scope `C::ub_t v`): bytes moved at the same uhdm-cmp count.

FIX: a name declared by any TypedefDeclaration that is not a direct member of a
CompilationUnit in any syntax tree (module, interface, program, package, class,
generate block, subroutine) is removed from the law's name map, so the law
abstains for that name (pristine's binding). Measured: vu01, vu02, vu07 and vu09
byte-identical to pristine again; vu03 (the law's own shape, two instances plus a
top variable) keeps the law (STRICT_NOTEQUAL type -> STRICT_EQUAL); the
implementer's AC and PA grids byte-identical to the law.

### 2. § clsTdFirstSameClass442v (R11V442_CLSTDSAMECLASS_OFF, TypeEmit, inside § modClassTdListing442's firstClassTdSpan442)

THE FACE: § modClassTdListing442 lends the location of the FIRST typedef of a
class (Surelog's compile order) to every module typedef of that class and aliases
it, matching the candidate typedef by the class name's **last identifier only**.
A typedef of a DIFFERENT class of the same name was taken:

- VM/vm01 (package p `typedef C pc_t;` of p::C, module `typedef q::C c_t;`):
  golden c_t at its own 14:11-14:14, Instanced at top, no alias; the law took
  6:11-6:12, aliased p::pc_t and Instanced at p: law NOT_EQUAL 17 -> verified
  **STRICT_EQUAL**.
- VM/vm15 (the same with q's own `typedef C qc_t;` present, which golden
  shares): law STRICT_NOTEQUAL line -> verified **STRICT_EQUAL**.
- VM/vm21 (module aa's unscoped `typedef C d_t;` of the $unit C, top's
  `typedef q::C c_t;`): law NOT_EQUAL 17 -> verified **STRICT_EQUAL**.
- VM/vm02 (module aa's `typedef C d_t;` where C is aa's own STRUCT typedef):
  the law gave top's class typedef aa's 7:11 location; verified writes golden's
  11:11 (still NOT_EQUAL 17 on aa's pre-existing struct-alias face, dump distance
  57 -> 42 law -> 34 verified).

Pristine exits 4 on all four (so not a pristine-right break), but the law wrote
wrong bytes on legal SV and the fix is local. Decoded on golden (VM/vm13, vm14,
vm16, vm22, vm23): Surelog compares the PACKAGE, not the class object: a $unit
class and a module-local class of one name share (vm14: top's typedef of the
$unit C takes aa's typedef of aa's local class C, STRICT_EQUAL on law and
verified; a first attempt comparing class identity broke vm14 and was dropped,
ver3), specializations of one generic class share (vm13). Rule: a package or
$unit candidate is resolved through its symbol and must name a class of the
target's package (none for a $unit or definition-local class); a candidate in a
module or interface definition goes by its written name: a scoped `p::C` names
package p, an unscoped C declared by a typedef in that definition is not a
class, any other unscoped C names the target's package only when the definition
imports it (`import q::*` or `import q::C`, header or body; vm23 STRICT_EQUAL on
both).

## Measurements

### Law sweep (law, trace on; /tmp/v11u442_LW, evidence/sweep_law.log, svtests_law.log)

Started after three quiet readings; the four corpus stages through the
worktree's tests/sweep.sh, the sv-tests stage through the main tree's
scripts/check_svtests.py with the worktree's baseline (the worktree's UVM
submodule is empty; scripts/, tests/sweep.sh and results/ equal between the base
and the main tree's HEAD):

- probe EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, 0/0/0; csv identical to the
  control; the 4087 databases STRICT_EQUAL to the control's by uhdm-strictcmp
  --no-canon (positive control: two different cases read NOT_EQUAL).
- surelog default CMP_EQUAL 480, testflags 474, 0/0/0; csv equal to the control
  but the two LowMem log-path texts.
- uhdm2rtlil 803/1/67 both modes, 0/0/0; csv identical to the control.
- downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv
  identical to the control.
- sv-tests EQUAL 1912, STRICT_NOTEQUAL 1, DIFFERENT 27, BOTH_REJECT 303,
  SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
  regressions 0, conversions 0, changes 0; csv identical to the control.
- the corpus stages' rc was 1 on the stale law index alone (cases I added after
  regenerating it); every stage read 0/0/0.
- byteverify against the control (SELFCHECK=1): surelog 0 of 962 (961 flagged),
  uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804). The 49 kept sv-tests
  databases differ in bytes from the control's only by the embedded workdir
  path: all 49 read STRICT_EQUAL against the control by uhdm-strictcmp --no-canon
  (evidence/svtests_kept_dbs_strict_law_vs_control.txt).
- canaries ok=52 and ok=16; both ctcan2 checks PASS.
- trace census: R11U442_TRACE set for all five stages, the directory EMPTY,
  reproducing the implementer's census (positive control: a traced law run of
  r11u442 MC/mc23 logs three modClassTdListing442 lines).
- binary audit, fence-filtered: surelog 1523 of 1573 records name the law
  binary (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740,
  sv-tests 2346 of 2346; no record names another slang-uhdm binary.

This is the first full five-stage reading of law20 (the implementer swept
law19 and reran only the probe stage on law20): it closes that gap.

### Verified sweep (ver5, trace on; /tmp/v11u442_VW, evidence/sweep_verified.log, svtests_verified.log)

Predicted before the sweep: identical to the law sweep, since both refinements
sit inside branches the law sweep's trace never reached. Read: every count and
every csv identical to the law sweep's (surelog but the two LowMem paths),
regressions 0 / conversions 0 / changes 0 in all five stages, rc 0; byteverify
verified against law 0 of 962, 0 of 1608 and 0 of 805, the 4087 probe databases
byte-identical to the law sweep's; canaries ok=52 and ok=16, both ctcan2 PASS;
the trace directory empty; binary audit 1523 of 1573, 1740 of 1740 and 2346 of
2346 records naming ver5, none another binary.

### Grid (cases/, 72 case dirs; evidence/grid3_ver5.txt, grid3_refcases.txt)

Every case accepted by upstream slang (~/.local/bin/slang dut.sv --single-unit,
rc 0); every case's first line names its law. R11U442_OFF on ver5 gives
pristine's bytes and exit code on 146 of 146 case dirs (my 72 and the
implementer's 74), R11V442_OFF on ver5 the law's on 146 of 146, each
refinement's own switch the law's bytes on its cases. pristine -> verified:

- exit 4 -> STRICT_EQUAL: VA/va01, va03, va04, va05, va07; VC/vc02, vc03;
  VE/ve01, ve03, ve04; VM/vm01, vm03, vm05, vm06, vm07, vm09, vm10, vm11, vm13,
  vm14, vm15, vm16, vm18, vm21, vm22, vm23; VQ/vq01, vq02; VR/vr01 to vr04 (32).
- NOT_EQUAL -> STRICT_EQUAL: VD/vd02, vd03, vd07, vd08 (4); STRICT_NOTEQUAL ->
  STRICT_EQUAL: VS/vs01 (endcol), VU/vu03 (type) (2).
- exit 4 -> exit 0 still unequal, every one closer by dump distance: VA/va02,
  VC/vc04, vc05, VE/ve05, VM/vm02, vm04, vm08, VQ/vq03 to vq06 (all NOT_EQUAL),
  VM/vm20 (STRICT_NOTEQUAL endline) (12).
- unequal on both, bytes moved, closer by dump distance: VC/vc01 (9 -> 7),
  VD/vd01 (121 -> 70), vd05 (125 -> 48), vd06 (192 -> 120), VM/vm12 (46 -> 30),
  VS/vs02 (31 -> 25), vs04 (43 -> 33), VU/vu05 (89 -> 70) (8; vc01's, vd05's,
  vd06's and vm12's uhdm-cmp counts grow because their first difference moved
  later in the walk).
- byte-identical to pristine: VA/va06 (exit 4, element typedef: the law
  abstains), VD/vd04 (STRICT_EQUAL control), VM/vm17, vm19 (subroutine-local and
  class-scope class-typedef arrays, the element law not reaching them), VR/vr05,
  VS/vs03, VU/vu04, vu06, vu08, and the four restored by the first refinement
  VU/vu01, vu02, vu07, vu09 (13).
- VE/ve02: no golden (Surelog reports a syntax error on `-> d[0]`), exit 4 ->
  0.

None further from golden on the verified binary. The implementer's 74 grid
lines reproduce exactly on exit code, uhdm-cmp count and strict verdict (the md5
column differs only by output path), and ver5 is byte-identical to law on all 74.

Downstream (evidence/downstream_grid.txt; the 36 class-free case dirs VA, VD,
VQ, VR, VU and VE/ve04): pristine -> verified 13 EQUIVALENT -> IDENTICAL
(va01, va02, va04, va05, va07, vq01, vq02, vq04, vq05, vq06, vr01, vr03, vr04)
plus VR/vr02 STATUS_DIFF -> IDENTICAL (3 of 3 reruns each), the rest IDENTICAL or
EQUIVALENT on both; none leaves IDENTICAL. VD/vd01 and vd07 flap between
STATUS_DIFF and IDENTICAL on BOTH binaries across reruns (evidence/
downstream_flake_reruns.txt: vd07 pristine STATUS_DIFF in 1 of 4 runs, vd01 ver5
STATUS_DIFF in 1 of 4 and pristine in 1 of 4): a harness-side flake on these
dynamic-array cases, not a law effect.

### Earlier-pass census (evidence/earlier_pass_census.txt, earlier_pass_movers_judged.txt)

6242 fence-filtered case dirs (tools/probe r11u4*/v11u4*, including the since
landed r11u439/v11u439 dirs present in the main tree, plus r11u249,
r11u245, v11u245, r11u202, r11u206, r11u293), pristine, law and ver5. Exit codes:
12 change, all 4 -> 0, the same on law and ver5. Movers pristine -> law: exactly
the implementer's 33; law -> ver5: 0 (ver5 byte-identical to law on all 6242).
Each mover judged against a fresh Surelog golden: 21 to STRICT_EQUAL, v11u406
VA/va12 to STRICT_NOTEQUAL fullname, v11u410 VU/vu02 and v11u436 VS/vs06 exit
4 -> 0 NOT_EQUAL closer, and r11u249 M/m05, v11u412 VW/vw03, v11u426 VA/va01,
va02, va04, va06, va07, va08, va10 closer by dump distance: none further.

Determinism: three concurrent ver5 runs each of VM/vm01, vm15, vm21, VU/vu03,
VA/va04, VQ/vq01 and r11u442 MC/mc23, PA/pa03, AC/ac05 read one hash each.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The implementer's residues stand as listed in tools/probe/r11u442repro/README.md
   (the 12-row uvm-examples family first).
2. § unitArrTdAliasVarBindsListing442 now abstains for a $unit alias name that
   any non-$unit typedef also declares (VU/vu09: the top variable's alias binding
   stays pristine's STRICT_NOTEQUAL type); a scope-aware lookup from the variable's
   own symbol would serve both.
3. § modClassTdListing442's end rule with a non-ANSI port typed by the typedef
   (VM/vm20): golden keeps the end at the class name, the law moves it to `k [3]`.
4. Class-typedef dynamic arrays as subroutine locals or class properties
   (VM/vm17, vm19) and in an interface with a $unit class typedef (vm12, closer).
5. The module dynamic-typedef copy in a task local (VD/vd01), a fixed dimension
   inside the dynamic one (vd05) and an array of a dynamic typedef (vd06): closer,
   not equal.
6. A parameter-bounded queue typedef with two instances (VQ/vq03), an imported
   package parameter bound (vq04), a subroutine local (vq05), a ranged parameter
   (vq06): closer, not equal.
7. $unit event typedef used by a class property (VE/ve05); chandle typedef in a
   package used by a class array (VC/vc05 closer), an event typedef fixed array
   in a class (vc04).
8. VM/vm02's struct alias face in module aa (the pre-existing typedef-of-struct
   alias naming).

## Sister-ground faces

None new.

## Process

Within the measurement budget on sweeps (one full five-stage sweep on the law
binary, one on the final verified binary since production code changed) and
over it on builds (one law build; five verified builds, ver1 to ver4 used on case
runs only, recorded above).

Slips, none affecting a measurement:
- my first quiet-waiter loop matched its own command line and was stopped by
  its task id before anything ran; my first law-sweep driver was named
  fullsweep.sh, which my own quiet pattern matched, so it waited on itself; stopped
  by its task id before any stage ran (the sister r11u441's waiter was waiting on
  it meanwhile) and relaunched as drivers/fivestage.sh.
- the earlier-pass census (22:07:46 to 22:14:35) overlapped the sister verifier
  v11u441's corpus stages (its sweep from 22:05:23) and my downstream grid's first
  run overlapped its sv-tests stage until I stopped it by task id at about 22:19;
  the census is a byte comparison with a 120 s cap per run and the grid was rerun
  in full on a quiet machine.
- my law sweep's corpus stages exited 1 on the stale law index (cases added after
  regenerating it), every stage reading 0/0/0; the index was regenerated before
  the verified sweep (rc 0).
- a path-normalized uhdm-dump comparison of the 49 kept sv-tests databases was too
  slow on the UVM rows and was stopped by task id (and its two tnoc uhdm-dump
  children by their PIDs); replaced by uhdm-strictcmp --no-canon on all 49.
- the fence list was read into a file by a program without printing it; every
  tree-wide list was filtered on it first; no fenced test named, dispatched,
  opened or run; no other agent's process touched.

Pass 439 and pass 441 (the sister ground, ExprEmit/StmtEmit/EmitHelpers/ParamEmit)
landed in the main tree during this verification; neither touches this pass's two
files.

## Files

- cases/<GROUP>/<case>/dut.sv: VA, VC, VD, VE, VM, VQ, VR, VS, VU (72 dirs); the
  first line names the law (`// § clsTdFirstSameClass442v` on VM/vm01, vm02,
  vm15, vm21; `// § unitAliasVarShadowAbstain442v` on VU/vu01, vu02, vu07, vu09).
- drivers/: run1.sh, grid.sh, grid3.sh, census3.sh, cmp.sh, ddiff.sh, dist.sh,
  dsgrid.sh, fivestage.sh, switches.txt (adapted from r11u442repro).
- evidence/: grid_law_first.txt, dist_pristine_law.txt, grid3_ver5.txt,
  grid3_refcases.txt, downstream_grid.txt, downstream_flake_reruns.txt,
  earlier_pass_census.txt, earlier_pass_movers_judged.txt,
  byteverify_law_whole_workdir.txt, svtests_kept_dbs_strict_law_vs_control.txt,
  sweep_law.log, svtests_law.log, sweep_verified.log, svtests_verified.log.
