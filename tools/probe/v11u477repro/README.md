# v11u477: adversarial verification of r11u477

Base 61ba6caa. Implementer's patch /tmp/r11u477.patch (src diff in src/EmitHelpers.h,
src/ExprEmit.cpp and src/ParamEmit.cpp). VERDICT: CONFIRMED WITH ONE BREAK FIXED.
§ caAddLeafIntMint477 broke three fresh cases on legal SV where pristine was right
(VA/va33, va34, va37 STRICT_EQUAL on pristine, NOT_EQUAL on the law binary). The fix
is § paramEncNoAddLeaf477v (R11V477_PARAMENC_OFF), read through fixOn(477, ...). The
verified patch is /tmp/r11u477.verified.patch.

## Binaries (frozen under /tmp/v11u477_bin before any measurement)

| binary | md5 | how |
|---|---|---|
| pristine | cf8527bcef90bc4865274fbe62642707 | copy of the main tree's base build (no pristine build, per the budget) |
| law | ee75397171c2128097132ba3a6fd38b4 | rebuilt once from the patch on fresh 61ba6caa; equal to the implementer's law6 |
| verified | f430c65a529a2495885bc69cf3c6d5f1 | law + § paramEncNoAddLeaf477v (second and last build) |

All three link slang 12.0.0+545f88b2e.

## The break and its fix

§ caAddLeafIntMint477 changes UhdmExporter::isIntEncoded. That function is also what
ParamEmit's analyzeParamEnc asks when it sets the paramIntEnc marker of a parameter,
and a marked parameter reads INT under ANY operator of a later fold (isIntEncoded's
NamedValue branch), not only under `+`. So with `localparam logic [7:0] L = P + 8'd1;`
(P = 8'd33) the law marked L, and every fold reading L read INT:
- VA/va33 `localparam logic [7:0] M = L & 8'hff;`: golden UINT:34, pristine UINT:34
  (STRICT_EQUAL), law INT:34 (NOT_EQUAL, uhdm-cmp 64 lines).
- VA/va34 `assign z = L & 8'hff;`: pristine STRICT_EQUAL, law NOT_EQUAL (28 lines).
- VA/va37 `M = L | 8'h0; N = L + 8'h1; assign z = M ^ N;`: pristine STRICT_EQUAL,
  law NOT_EQUAL (64 lines).
- VA/va27 (untyped L and M): verdict NOT_EQUAL on both at an older size face, the
  law adding a second difference (dump distance 4 -> 8).

The law's own add-chain guard (addChain477) does not protect this path, since the
marker is consulted at the NamedValue leaf, below the non-add operator.

§ paramEncNoAddLeaf477v: analyzeParamEnc computes the marker with the leaf rule off
(a thread-local flag ParamEncNoLeaf477v in EmitHelpers.h, read in isIntEncoded).
A read of L inside an add chain still mints INT through red97OperandMintsInt97, which
follows L's initializer, so AD/ad01, the implementer's target, stays STRICT_EQUAL.
Cost: VA/va09 keeps the law's cont-assign fix (`L + 0`, UINT:34 -> INT:34) but loses the
range-bound `[L:0]` change (dump distance pristine 14, law 6, verified 10), and VA/va36
returns to pristine's bytes (the law had moved the bound's value toward golden but its
size away, 8 -> 64). lawTrace(477, "paramEncNoAddLeaf477v", <param>) logs each marker
the fix withholds.

## Reproduction of the implementer's numbers

- Patch applies cleanly on fresh 61ba6caa; the law build is byte-identical to law6.
- The implementer's grid, 43 case dirs in AD, CD, FN and RF, reproduced on both binaries
  on exit code, uhdm-cmp count, strict verdict and dump distance: 86 of 86 lines equal
  (evidence/grid.txt holds the law and verified columns too). On the verified binary
  all 43 dirs keep the law's bytes.
- One five-stage sweep on the law binary (workdir /tmp/v11u477_swlw, trace on; the
  sv-tests stage through the main tree's tests/sweep.sh, since the worktree's UVM
  folder is empty; the main tree's results/ and scripts/ are identical to the base's):
  - probe EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0. All 4087 databases are dump-identical
    to the master's control /tmp/intr11u475 after the repo path is normalized; the
    negative control reads DIFF (evidence/probe_dumpcensus_law.txt).
  - surelog default 480 + 0, testflags 474 + 0, 0/0/0.
  - uhdm2rtlil 803/1/67 in both modes, 0/0/0.
  - downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; verdict diff
    against the control 0.
  - sv-tests EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
    SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions 0, conversions 0, changes 0; the
    csv identical to results/golden_svtests.csv and to the control's. The command
    exited 1 only on the main tree's stale law index.
  - Every non-detail column of the probe, surelog and uhdm2rtlil csvs equals the
    control's.
- Byteverify (SELFCHECK on) law sweep against the control: surelog 6 of 962 movers,
  exactly the implementer's six (BlackBePipeInt, Earlgrey_0_1, YosysOldOpen, default and
  testflags); uhdm2rtlil 0 of 1608; downstream 0 of 805.
- sv-tests: of the 26 databases the stage keeps, 25 are STRICT_EQUAL to the control's
  under uhdm-strictcmp --no-canon; easyUVM is the mover (evidence/svtests_kept_law_vs_control.txt).
- easyUVM: uhdm-cmp against the cached golden reads 60 lines on the control's database
  (head comparator.sv 63:14, exp.compare(rec) with the defaulted argument) and 658119 on
  the law's, whose first record is the definition module work@top. The implementer's
  sister case evidence/sister/rm2port reproduces the reported head: golden 0 ref_module
  objects, ours 3; rm1port 2 and 2, STRICT_EQUAL.
- Canaries: ok=52 (surelog) and ok=16 (uhdm2rtlil); ctcan2 PASS on both (ok=58 with 1
  unknown pattern, ok=2 with 6).
- Binary audit, fence-filtered: surelog 1523 of 1573 records name the law binary, the
  other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.
- Goal 1: all 75 SURELOG_ONLY rows carry an upstream slang `error:` diagnostic; none
  carries the exporter's own message.

## The attack grid (82 fresh case dirs in VP, VR, VF and VA; evidence/grid.txt)

Every case is accepted by upstream slang (~/.local/bin/slang dut.sv --single-unit, real
exit code read; the negative control, a module assigning an undeclared name, reads rc 1).
Every exit code is 0 on all three binaries. Tally pristine -> verified:
STRICT_EQUAL 30 -> 54, STRICT_NOTEQUAL 1 -> 8, NOT_EQUAL 51 -> 20 (the law binary reads
STRICT_EQUAL 51, the three break cases NOT_EQUAL).

**VP, § parenCallWrittenArgs477 (26 dirs)**
- 15 go NOT_EQUAL -> STRICT_EQUAL: vp01 (named argument), vp02 (double parentheses),
  vp04 (empty slot), vp05 (continuous assignment), vp09 (two instances), vp11 (call as
  an argument), vp12, vp14 (interface), vp15 (generate loop), vp17 (DPI import), vp18,
  vp19 (dotted method chain o.h.m), vp20 (out-of-body method in a package), vp21 (named
  out of order), vp22 (interface instance call u.f).
- vp08 NOT_EQUAL -> STRICT_NOTEQUAL depth: the same verdict the unparenthesized form
  reads on both binaries (pass 457's return share not reached when the callee has a
  default argument).
- vp10, vp13, vp24, vp25, vp26 closer, still NOT_EQUAL. vp24 and vp25 now equal the
  unparenthesized form's reading (17 lines each); vp10 `(obj::sf(1))`, vp13
  `(super.m(a)) + (this.sf(a))` and vp26 `(super.m(a))` remain wrong where the
  unparenthesized forms read STRICT_EQUAL (residue 1).
- vp03, vp06, vp07, vp16 byte-identical controls; vp23 (randomize in parentheses)
  byte-identical and NOT_EQUAL on all binaries.

**VR, § unitImpRootFileDef477 (11 dirs)**
- 9 go NOT_EQUAL -> STRICT_EQUAL: vr01 (include before the import), vr02 (the import
  itself in an included file), vr03 (nested include with the import in the middle file),
  vr04 (interface), vr05 (explicit import), vr06 (the included file with its own import
  of a second package), vr07 (the import at the end of the file, after the include and
  the modules), vr08 (`include of a macro), vr09 (parameterized module, two instances).
- vr11 (a program in an included file) closer (dump distance 180 -> 60), uhdm-cmp 429
  on both: the program listing, the implementer's rf03 residue.
- vr10 (include inside a module body) byte-identical control.

**VF, § fileMacroPathNormal477 (8 dirs)**
- 6 go NOT_EQUAL -> STRICT_NOTEQUAL endcol (uhdm-cmp equal): vf02 `sub//inc.svh`, vf03
  `../vf03/sub/inc.svh`, vf04 a string parameter default, vf05 a concatenation,
  vf06 `__FILE__ inside another macro's body, vf07 two expansions on one line. The
  remaining columns are the sister's rest-of-line shift (two columns per expansion
  earlier on the line: vf07's second expansion sits four columns late).
- vf01 (top file) and vf08 (`include "sub/inc.svh"`, already normal) byte-identical.

**VA, § caAddLeafIntMint477 and § paramEncNoAddLeaf477v (37 dirs)**
- No verdict moves pristine -> verified. Byte movers with dumps identical to pristine
  (string table only): va10, va11, va15, va19, va21, va22, va25, va26, va35, and on the
  verified binary va27, va33, va34, va36, va37.
- va09 closer (dump distance 14 -> 10, the cont-assign `L + 0` now INT:34 as golden).
- va14 (`p::A + 4'd1`), va32: bytes move with identical dumps.
- Controls reading the same bytes on all binaries: sub, `*`, unary minus and `~` over the
  add, conditional, variable initializer, port actual, generate scope, range bound
  `[R + 4'd1 : 0]`, concatenation, cast, shift, index, function argument, genvar,
  comparison, a net operand, a package function return.

**Switches** (evidence/switch_checks.txt): on all 125 grid dirs (82 + the implementer's 43)
the verified binary with R11U477_OFF writes pristine's bytes, and with R11V477_OFF or
R11V477_PARAMENC_OFF writes the law's bytes, every exit code 0.

**Downstream** (evidence/downstream_cases.txt, 22 module-reading dirs, three binaries):
no case moves away from IDENTICAL. vp05, vr01, vr05, vr06, vr09, rf01, rf05 EQUIVALENT ->
IDENTICAL; vp09 STATUS_DIFF -> IDENTICAL; vp15 and vp25 DIVERGENT -> IDENTICAL; vp24
DIVERGENT on all three; the VA dirs and AD/ad01, ad08 IDENTICAL on all three.

## The verified sweep (one five-stage sweep on the verified binary, workdir /tmp/v11u477_swvf)

Prediction written before it ran: evidence/PREDICTION_verified.md (the verified binary run
traced beforehand on the three surelog mover rows: the fix fires 406 times there and every
database keeps the law's bytes).
- probe EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0; all 4087 databases byte-identical to the
  law sweep's (so dump-identical to the control's).
- surelog default 480 + 0, testflags 474 + 0, 0/0/0; byteverify against the law sweep
  0 of 962, against the control the same six movers (BlackBePipeInt, Earlgrey_0_1,
  YosysOldOpen, d/t), as predicted.
- uhdm2rtlil 803/1/67 in both modes, 0/0/0; byteverify 0 of 1608 against both.
- downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; byteverify 0 of 805
  against both; verdict diff 0.
- sv-tests EQUAL 1935, DIFFERENT 5, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1, regressions 0, conversions 0, changes 0; the csv identical
  to the law sweep's and to results/golden_svtests.csv. Kept databases against the law
  sweep's under uhdm-strictcmp --no-canon: 26 of 26 STRICT_EQUAL, easyUVM included
  (evidence/svtests_kept_verified_vs_law.txt).
- Every non-detail column of the probe, surelog, uhdm2rtlil and downstream csvs equals the
  law sweep's. Canaries ok=52 and ok=16, ctcan2 PASS on both. Binary audit: surelog 1523
  of 1573 records name the verified binary (the other 50 hold only a Surelog line),
  uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.
- The stage 1 to 4 command exited 1 on the law index alone (stale from this folder's new
  case files; tests/LAWS.md regenerated in the verified patch).

## Residues (all wrong on pristine too; none moved away on the verified binary)

1. A parenthesized call whose callee is class-scoped or a super or this method,
   `(obj::sf(1))`, `(super.m(a))`, `(this.sf(a))`: golden writes the same objects as
   for the unparenthesized call (func_call / method_func_call with the super prefix),
   ours a ref_obj `obj::sf` or a hier_path `super.m` (VP/vp10, vp13, vp26; the
   implementer's cd21). The callee-shape decoders read `expr.syntax` without the
   parentheses' unwrap the argument decoders now get.
2. Pass 457's return share not reached when the callee has a defaulted formal
   (VP/vp08 and its unparenthesized twin, STRICT_NOTEQUAL depth on every binary).
3. § caAddLeafIntMint477's reach on a parameter marker: with the fix, a whole read of
   `L` (L = P + 8'd1) in a range bound or a continuous assignment stays UINT where
   golden writes INT (VA/va09's `[L:0]`, va36); writing it needs a marker that only an
   add chain or a whole read consults, not the general paramIntEnc.
4. A program in an included file (VR/vr11, the implementer's rf03).
5. The implementer's ranked residues stand as reported: the ref_module listing of an
   interface instance with two or more ports (easyUVM's head), the `__FILE__
   rest-of-line shift, the qualified int-typed parameter read stamp, the add
   overflowing its width, rf07, and the carried lists.

## Sister-ground faces (reported, not written)

- ModuleEmit: no ref_module for an interface instance with two or more ports in golden
  (evidence/sister/rm2port of r11u477repro reproduced: golden 0, ours 3); easyUVM's head.
- UhdmExporter § ppMacroBodyLines160: the rest-of-line column shift after a `__FILE__
  expansion uses slang's path length (VF/vf02 to vf07).

## Process

- One law build and one verified build (the budget's allowance for a refinement); one
  five-stage sweep on each binary; no pristine build and no pristine sweep (the master's
  control /tmp/intr11u475 is the pristine reading).
- The fence list was read into a file by a program without printing it; every evidence
  file and the repro folder were scanned with it before delivery (no hit).
- Slips, none affecting a reported number: one ad hoc uhdm-cmp call ran with UHDM_CMP
  unset (the environment file not sourced), so the shell tried to execute a golden
  database; it wrote no file (checked) and every later call sourced the environment and
  guarded the variable with [ -x ]. My case runs, downstream case runs, dump and strict
  comparisons ran single-process while the sister verifier v11u472's sv-tests sweep was
  live; my two sweeps never overlapped another sweep (pgrep read 0 before each launch,
  the second launched only after v11u472's ended).
