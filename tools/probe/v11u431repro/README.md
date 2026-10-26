# v11u431 — adversarial verification of r11u431

Base bc18c5011 (pass 429). Implementer's patch /tmp/r11u431.patch (six laws in
src/ExprEmit.cpp and src/ParamEmit.cpp). VERDICT: the implementer's numbers
reproduce bit for bit; the attack grid found FOUR breaks on legal SV where
pristine was right (or nearer golden) and the law moved away. All four are fixed
here behind their own switches (four refinements, all in src/ExprEmit.cpp,
read through src/LawSwitch.h `fixOn(431, ...)`; `R11V431_OFF` gives the law's
bytes on every case dir of both grids). The verified patch is
/tmp/r11u431.verified.patch.

## Binaries (frozen before any measurement)

- pristine: /tmp/v11u431_pris/slang-uhdm, md5 a68b561e10c30ef8b8f1e9ad8bc58506
  (a copy of the implementer's frozen pristine, equal to the main tree's build at
  the base; no pristine build of my own, as the budget says).
- law: /tmp/v11u431_law/slang-uhdm, md5 303e6d85e43c76afb6e6c3787f5259cb, rebuilt
  once from /tmp/r11u431.patch applied on a fresh bc18c501 worktree (-j 2):
  EQUAL to the implementer's law9. The patch applies cleanly and
  `scripts/law_index.py --check` reads current on the fresh base.
- verified: /tmp/v11u431_ver2/slang-uhdm, md5 f2e410ba01aeac5d13df666a0303f8cd.
  One intermediate verified build (/tmp/v11u431_ver1, md5 850c31b6..., the
  first two refinements only) was used on case runs only and never swept: it
  is one build over the budget's single verified build, recorded here. One
  compile of the final form failed (a `ParentRef` type error) and produced no
  binary.
- all three link slang 12.0.0+545f88b2e.

## Reproduction of the implementer's headline numbers

The law sweep (tests/sweep.sh --jobs 3, the four corpus stages from the
worktree, the sv-tests stage through the main tree's scripts/check_svtests.py
with --baseline the worktree's golden, as the implementer ran it; workdir
/tmp/v11u431sw1, same length as the control /tmp/intr11u429):

| stage | reading | reg / conv / changes | csv vs control |
|---|---|---|---|
| probe | 4018 EQUAL + 69 STRICT_NOTEQUAL | 0 / 0 / 0 | identical |
| surelog | default 480 + 4 CMP_NOTEQUAL, testflags 474 + 4 | 0 / 0 / 0 | only the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 both modes | 0 / 0 / 0 | identical |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | — | identical |
| sv-tests | EQUAL 1894, STRICT_NOTEQUAL 6, DIFFERENT 40, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 | 0 / 2 / 0 | only the two converted rows |

(The corpus stages exit 1 on the stale law index alone: this worktree held the
verifier's new cases by then. tests/LAWS.md is regenerated in the patch.)

Conversions (fresh rows of the law sweep, the verified sweep the same):
- generated/hdlconv_std2017/hdlconvertor_std2017_p130.sv DIFFERENT -> **EQUAL**:
  `generated/hdlconv_std2017/hdlconvertor_std2017_p130.sv,EQUAL,,equal`
  (§ bodyTypeParamDefKeepsDecl431).
- generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_dpi_rom.sv DIFFERENT -> **EQUAL**:
  `generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_dpi_rom.sv,EQUAL,,equal`
  (§ modParamArrElemDefRangeSym431).

- byteverify law against control: 0 / 962, 0 / 1608, 0 / 805, self-checks
  961 / 962, 1607 / 1608, 804 / 805 flagged; the 4087 probe databases identical
  by path-normalized dump (positive control: two different databases flagged).
- canaries ok=52 and ok=16; both ctcan2 checks PASS.
- binary audit, fence-filtered: 5659 command records, 5609 naming the law
  binary, the other 50 holding only a Surelog line (two of them name the
  slang-uhdm repo path in a UVM source, not a binary).
- trace census (R11U431_TRACE): exactly four databases, all sv-tests:
  fx68k (49 name bindings, 1 index fold, 1 concatenation typespec), rsd (40
  abstentions of § connOperandNonOvParamFold431, `abstain-const`; the
  implementer's "fires 40 times" are abstentions), p130 and dpi_rom; no
  corpus row, probe case or downstream row.
- the implementer's 95 grid lines reproduced exactly on exit code, uhdm-cmp
  count, strict verdict and both switch columns once the md5 column is
  stripped (ub24 and ub27 need two switches, as reported).

## The breaks (pristine right or nearer golden, law away) and the refinements

1. § caFnConcatWholeRhsOnly431v (`R11V431_CAWHOLERHS_OFF`). THE BREAK:
   § caFnArgConcatFormalTs431 stamped the formal's typespec on a concatenation
   argument of a call anywhere in a definition's continuous assignment, but
   golden stamps it only when the call is the WHOLE right side. Cases VF/vf03
   `assign y = f({a[2:0], a[5:3]}) + 4'd1;` and VF/vf16 (`~f({..})`,
   `f({..}) == 4'd3`): pristine STRICT_EQUAL, law NOT_EQUAL at 17 uhdm-cmp
   lines; the same on the pass 432 case r11u432repro FA/fa07. Fix: the law
   applies only when the call's parent is the cont_assign; vf03, vf16 and fa07
   back at pristine's bytes, every whole-right-side case (fa01, vf15, fx68k's
   uaddrDecode) keeps the law's bytes.
2. § unitNameBindNotInClass431v (`R11V431_UNITCLASS_OFF`). THE BREAK:
   § unitParamNameBindsDesign431 bound a module name inside a CLASS declared in
   the module to the `$unit` parameter, but Surelog runs no lateBinding over a
   class (UhdmWriter's class call is commented out), so the class keeps its
   compiled binding. VB/vb18 (`return CF;` in a module class, CF a module
   localparam shadowing the `$unit` CF): pristine STRICT_EQUAL, law NOT_EQUAL
   at 31 lines; VB/vb22 (a class property range `bit [W-1:0]`) moved away by
   dump distance 4 -> 6. Fix: abstain when the UHDM parent chain reaches a
   class_defn or the current subroutine sits in a class; vb18 and vb22 back at
   pristine's bytes, and VB/vb27 (a static method reading CF beside a module
   initial reading CF) goes NOT_EQUAL -> STRICT_EQUAL.
3. § connReplCountUnparented431v (`R11V431_REPLCOUNT_OFF`). THE BREAK:
   § connOperandNonOvParamFold431 parented its fold at the operation when the
   parameter is a replication count `{N{en}}`, where golden writes the count
   UNPARENTED. The earlier-pass census found it on the r11u422 case IA/ia05
   (`child c[N-1:0] (.a({N{en}}), ...)`): pristine's count unparented as golden,
   law parented, dump distance 3 -> 11 (strict verdict STRICT_EQUAL on both,
   the parent field is not a strict cell). Fix: the count fold is unparented;
   ia05 dump-identical to pristine, VC/vc03 dump distance 0, VC/vc28 closer.
4. § connOpGenvarAbstain431v (`R11V431_OPGENVAR_OFF`). THE BREAK:
   § connOperandNonOvParamFold431 judges an operation non-constant when it
   does not bind in the parameter's scope; an operation reading an enclosing
   generate loop's genvar fails to bind there and so read as non-constant,
   but in the elaborated scope it is constant and golden reduces it whole.
   The census found it on the r11u428 case HP/hp02
   (`p.sel[i+:`MAXV(W-i,1)]` in a generate loop: golden's width one constant
   INT:4, the law wrote UINT:4 for W inside `W - i`, pristine a reference;
   uhdm-cmp 324 -> 332, dump distance 180 -> 188); VC/vc25 and vc26 the same
   way (90 -> 94, 42 -> 46). Fix: when the bind fails and the operation names
   the genvar of an enclosing loop generate, abstain; hp02, vc25 and vc26 back
   at pristine's bytes, while an operation over a generate-block net (VC/vc27,
   dump distance 28 -> 12) keeps the law.

## Fresh attack grid (89 case dirs in VA, VB, VC, VF, VT)

Every case accepted by upstream slang (~/.local/bin/slang --single-unit, 0
errors); every exit code 0 on all three binaries. The pass 432 cases
r11u432repro FA and UP and v11u432repro VF and VU (61 dirs) were also run as
attacks on these laws (read from the main tree, not copied), and the
implementer's 95.

Pristine -> verified over the 89: 39 NOT_EQUAL -> STRICT_EQUAL, 2
STRICT_NOTEQUAL -> STRICT_EQUAL (VT/vt06 line, vt10 type), 2 NOT_EQUAL ->
STRICT_NOTEQUAL (VF/vf01 `f({P, Q})` and vf02 `f({P, 4'h2})`: type, the
elaborated call over parameters only, pass 432's residue), 18 NOT_EQUAL on
both and closer to golden by sorted dump distance, 28 byte-identical controls
and residues, NONE further. On the 245 case dirs: R11U431_OFF on the verified
binary gives pristine's bytes and exit code on 245 of 245, R11V431_OFF the
law's on 245 of 245, each case's own switch its baseline on 182 of 184 (ub24,
ub27 need both of their co-firing switches); verified equals law on every case
dir except the ten refinement cases (fa07, vb18, vb22, vb27, vc03, vc25, vc26,
vc28, vf03, vf16). Downstream on the 85 class-free cases: 9 EQUIVALENT ->
IDENTICAL (VC vc05, vc06, vc07, vc10, vc16, vc17, vc21, vc24, vc29), 72
IDENTICAL on both, VA/va09, VC/vc11 and vc15 EQUIVALENT on both, VB/vb12
DIVERGENT on both (a net with a `$unit` parameter's name read whole by an
elaborated continuous assignment, the implementer's residue 1); none worse.

Cases by law:
- § unitParamNameBindsDesign431: VB/vb01 (port, residue byte-identical), vb02
  (for-loop variable: the law does not reach a block-scoped name; byte-identical),
  vb03 (a localparam initializer, residue), vb04 (net declaration assignment),
  vb05 (case item and if condition, -> STRICT_EQUAL), vb06 (generate-if
  condition and loop bound: not reached, residue), vb07 (task), vb08 (an
  overridden parameter port), vb09 (function argument: unaffected), vb10 (a
  struct variable's member read), vb11 (array variable), vb12 (net on a
  continuous assignment's left side: closer, DIVERGENT downstream on both),
  vb13 (elaborated index of an overridden parameter, -> STRICT_EQUAL), vb14
  (`x[CF+1]` elaborated: closer, not equal), vb15 (control), vb16 (program:
  not reached, residue), vb17 (a packed range), vb19, vb20 (always_comb
  elaborated index), vb23 (module function reading a variable), vb24 (named
  begin), vb25 (generate-for body: control), vb26 (assertion and system call).
- § unitNameBindNotInClass431v: VB/vb18, vb21 (class property initializer:
  control), vb22, vb27.
- § connBitSelIdxNonOvParamFold431: VC/vc01 (logic signed [3:0]), vc02 (a
  default reading an overridden parameter, two instances), vc08 (enum-typed),
  vc09 (a localparam read from a `$unit` one: closer), vc11 (interface beside
  it: closer), vc12 (shortint and longint), vc13 (unpacked port), vc19
  (defparam: closer), vc22 (two-dimensional packed).
- § connOperandNonOvParamFold431: VC/vc04 (part-select base: not reached),
  vc05 (==), vc06 (<<), vc07 (P - x), vc10 (instance array), vc14
  (conditional: not reached), vc15 ($clog2 operand: not reached), vc16, vc17
  (an overridden positional parameter), vc18 (bit [3:0]), vc20 (a 64-bit
  value: residue), vc21 (an index operation x[y + P]), vc23 (generate loop
  over a port), vc24 (two parameters, each overridden in one instance), vc27
  (generate-block net), vc29 (indexed part-select base y + P).
- § connReplCountUnparented431v: VC/vc03, vc28.
- § connOpGenvarAbstain431v: VC/vc25, vc26.
- § caFnArgConcatFormalTs431: VF/vf01, vf02 (parameters in the concatenation),
  vf04 (nested), vf05 (net declaration assignment: unaffected), vf06 (package
  function with a typedef formal), vf07 (second argument), vf08 (call inside a
  call: unaffected), vf09 (conditional: unaffected), vf10 ($unit function),
  vf11 (elaborated child), vf12 (interface), vf15 (concatenated left side).
- § caFnConcatWholeRhsOnly431v: VF/vf03, vf16.
- § bodyTypeParamDefKeepsDecl431: VT/vt01 (a default naming another type
  parameter: closer), vt02, vt03 (positional override: closer), vt04, vt05
  (program: closer), vt06 (override equal to the default), vt07 (struct
  default: closer), vt08 (header list: control), vt09 (two overrides), vt10
  (package typedef default).
- § modParamArrElemDefRangeSym431: VA/va01 ([W:1]), va02, va04 (body
  localparam), va05, va06 (interface), va08 ([W*D-1:0]) all closer with the
  uhdm-cmp count larger only because the head moved later (the `'{default}`
  and literal-list defaults, the implementer's residue 4); va03 (`$unit`
  bound) and va07 (package bound) byte-identical, and va09 (two packed
  dimensions) byte-identical too.

## Verified sweep (the second and last sweep, on the verified binary)

Workdir /tmp/v11u431sw2. Predicted before the sweep: the refinements act only
inside the law branches, which fire on four sv-tests databases only; the
verified binary traced on those four (fx68k, rsd, p130, dpi_rom) writes the
law's bytes and no refinement fires, so the verified sweep was predicted equal
to the law sweep in every stage. Measured: all five csvs identical to the law
sweep's after the workdir name (probe 4018 + 69, surelog 480 / 474, uhdm2rtlil
803 / 1 / 67, downstream 803 / 66 / 2 / 0, sv-tests 0 / 2 / 0 with the same two
conversions); byteverify verified against law and verified against control 0 /
962, 0 / 1608, 0 / 805 with the self-checks passing; canaries ok=52 and ok=16,
both ctcan2 PASS; audit 5609 of 5659 records naming the verified binary, the
other 50 Surelog only; trace census the same four databases and the same
counts as the law sweep. The 67 kept sv-tests databases compared by
path-normalized dump between law and verified: 66 identical (uvm_test_init after
rerunning its cut dump at 1500 s), tnoc's dump cut by its timeout at the same
size on both with no firing logged (evidence/svtests_kept_dumps.txt).

## Earlier-pass census

4212 fence-filtered case dirs of passes 401 to 430 (r11u4xx and v11u4xx,
this pass's own excluded), each run with two binaries to the same output path:
- pristine -> law: 4209 byte-identical, exit codes equal on all 4212 (4184 rc 0,
  17 rc 4, 8 rc 3, 3 movers rc 0); movers IA/ia05 (away, break 3), HP/hp02
  (away, break 4) and the r11u424 residue case TR/tr04 (closer, 142 -> 109).
- law -> verified: 4210 byte-identical, the two movers ia05 (dump-identical to
  pristine) and hp02 (pristine's bytes); tr04 keeps the law.

## Goal 1

Nothing on this ground: no rejecting sv-tests row carries an exporter message
(the law and verified sweeps read the same 75 SURELOG_ONLY, 303 BOTH_REJECT and
0 SLANG_CRASH rows as the control). The black-parrot size guard was not
touched and not re-measured (the implementer's bp_unicore reading, exit 3 in
16.4 s at 782 MB, stands as its own).

## Residues (ranked; all wrong on pristine too, none moved away)

1. A module net or port with a `$unit` parameter's name read whole by an
   elaborated continuous assignment (VB/vb12, the implementer's ub18, ub22,
   ub23; DIVERGENT downstream on both binaries).
2. `$unit` name binding not reached: a module localparam initializer (VB/vb03),
   a generate-if condition and loop bound (vb06), `x[CF+1]` in an elaborated
   continuous assignment (vb14, closer), a program (vb16), a module class's own
   typespec range (vb22, golden different from both binaries), and Surelog's
   for-loop overwrite (lateBinding's for_stmt branch binds the loop variable
   and does not stop the walk, so the design's parameter overwrites it; vb02
   reads STRICT_EQUAL on both, so the shape is not reached by the corpus).
3. Elaborated connection shapes not written: a parameter defined by a `$unit`
   parameter (VC/vc09), a 64-bit value (vc20), a conditional branch (vc14), a
   `$clog2` operand (vc15), a part-select base P (vc04), operations over a
   genvar (vc25, vc26, now pristine's bytes), and the implementer's ec05, ec06,
   ec12, ec20, ec26, ub26.
4. The elaborated call over a concatenation of parameters only (VF/vf01,
   vf02: STRICT_NOTEQUAL type; pass 432's VF/vf03, vf14).
5. The unpacked-array parameter default's elaborated `'{default:0}` and
   literal-list forms (VA cases, the implementer's PA/pa01 to pa03), and a
   two-dimensional packed element (va09, byte-identical).
6. The implementer's residues 5 to 8 (tp13, ub15, fa16, p733, tnoc), unchanged.

## Integration note (pass 432 landed at 4f9e80238 above this base)

Pass 432 writes the SAME two fx68k faces on the sister's files:
§ unitParamShadowDefBind432 (UhdmExporter, a post-pass binding unbound
definition references to a module parameter named like a `$unit` one) and
§ caCallConcatArgFormalTs432 (UhdmExporter, a post-pass stamping a
whole-right-side call's concatenation argument). Both post-passes skip an
object that already carries an actual or a typespec, so with this pass's laws
firing first in the emitter they abstain; with § caFnConcatWholeRhsOnly431v the
two concatenation laws cover the same shapes (the pass 432 FA and VF grids read
the same verdicts on this binary as pass 432 reports for its own). Not
measured on the integration base (no third build): the master's integration
sweep is the measurement.

## Sister-ground faces (reported, not written)

The implementer's list stands (fx68k's TypeEmit size-form dimension, the six
basejump design-list rows in UhdmExporter, channel_control_master's TypeEmit
emitSyntaxExpr `$bits`, the `inv`-placeholder typedef ranges, the listing
heads of p203, p334, p719, p737, class_test_49, easyUVM and the 16
uvm-examples rows); nothing new found on the sister's ground.

## Process

Within the budget on sweeps (one law build, one full five-stage sweep on the
law binary, one on the final verified binary); one intermediate verified build
over the build budget (recorded above), used on case runs only. Slips, none
affecting a measurement: the first earlier-pass census ran with relative case
paths from the wrong directory and every run failed, so it was discarded and
rerun with absolute paths; the first downstream run on five cases used
relative paths after the driver changed directory and wrote nothing (the main
tree's git status read clean), rerun with absolute paths; the verified build
and one case batch ran beside my own law sweep's corpus stages (no sister
process was live then). Every grid, census and sweep launch waited for three
quiet readings with the pattern anchored on the interpreter (a sister's
waiting shell carrying the stage names in its command line is not matched).
The fence list was read into a file by a program without printing it, and
every tree-wide list (census, command-record audit, kept databases) was
filtered on it before any file was opened; no fenced test named, opened or
run; no other agent's process touched.

Drivers: drivers/run1.sh (one case, golden cached by content), grid.sh,
allgrid.sh, vgrid.sh, fgrid.sh (the final three-binary grid), census.sh,
dsgrid.sh, dist.sh, head.sh, quiet3.sh, fullsweep.sh; drivers/switches.txt.
Evidence: evidence/ (grids, censuses, downstream, sweep logs, trace censuses,
byteverify).
