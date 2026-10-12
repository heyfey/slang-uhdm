# v11u301 — adversarial verification of r11u301

Base 5b58d3ee (pass 299). Verified the patch /tmp/r11u301.patch (twelve laws in ModuleEmit, UhdmExporter and
TaskFuncEmit behind `src/R301.h`). **Verdict: verified with three production refinements.** Fresh cases found four
breaks where pristine was right and the law was wrong on legal SystemVerilog: a chain-keyed record moved away from
golden, or a downstream row left IDENTICAL. Three refinements in ModuleEmit fix them, each behind its own
`R11V301_<X>_OFF` switch in `src/R301.h`. `R11V301_OFF` gives the law's bytes and `R11U301_OFF` still gives
pristine's bytes, on every case-view measured. No gate database moves between the law and the fix (0 of 3365 corpus
and downstream databases, 0 of 4087 probe), so the pass's twelve probe conversions stand unchanged.

## Reproduction (both binaries rebuilt from fresh worktrees at 5b58d3ee, -j 2)

- pristine md5 5c3e79f4 (equal to the main tree's build at the base), law e0fa57a0 (equal to the implementer's), fix
  a94a551d (law + the three refinements). All three were frozen read-only before any measurement. They link slang
  12.0.0+545f88b2e.
- Gate sweeps (`tests/sweep.sh --jobs 3`, all three run from the law worktree so the probe databases share one
  source path; evidence/sweep_{P,L,F}.txt):
  - Pristine: probe 3962 + 125; surelog 480 + 0 / 474 + 0; uhdm2rtlil 803/1/67 in both modes; downstream 803/66/2/0.
  - Law: probe EQUAL 3974 + STRICT_NOTEQUAL 113 with regressions 0, conversions 12 and changes 0. The twelve
    conversions are exactly the implementer's. Each fresh row reads `<case>,EQUAL,,equal`, e.g.
    `r10uvm99repro/g99_a2_proc,EQUAL,,equal` and `v11u112repro/grid/brk/k/b3a_multi_decl,EQUAL,,equal`.
    Surelog and uhdm2rtlil are unchanged with 0/0/0. Downstream is 803/66/2/0, byte-identical to
    results/downstream_uhdm2rtlil.csv.
  - Fix: the same numbers as the law, row for row.
  - Every sweep exited 1 on the law-index check alone (the index was regenerated last, `--check` now reads current).
- Row-by-row csv diff:
  - law vs pristine: surelog differs only in the LowMemLib / LowMemPkg testflags detail text, probe in the twelve
    conversions, uhdm2rtlil and downstream not at all;
  - fix vs law: the LowMem text only.
- Firing census (drivers/tracecensus.sh, filter built from `$FENCED`; evidence/predict_law.txt):
  - Law: 37 probe databases and 0 corpus row-modes, byte-identical to the implementer's predict.txt. The sweep moved
    exactly those 37 probe databases (evidence/probe_movers.txt).
  - Fix (frozen before its sweep; predict_fix.txt): the same 37 lines, and no refinement trace fired anywhere in the
    probe or the corpora. A positive control shows each refinement tracing on its witness
    (evidence/refinement_trace_poscontrol.txt).
- Byteverify (SELFCHECK=1 on fence-filtered hard-link mirrors, 8 fenced paths skipped by name;
  evidence/gates_misc.txt): 0 of 3365 movers for law vs pristine, fix vs law and fix vs pristine (SELFCHECK 3363 of
  3365, the known twin). Probe databases: pristine -> law 37, law -> fix 0. The corpus away census is therefore
  vacuous: no corpus record moves.
- Canaries on the law and fix csvs: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS on both
  (EXPECT_UNKNOWN=1 and 6).
- Binary audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary; the other 50 run no slang; none
  names a foreign binary.
- Determinism: three concurrent draws per row-mode (drivers/det.sh) on the law and fix binaries:
  - default: Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen;
  - testflags: Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM and BuildUVMPkg (the others write no database there).

  Every row-mode reads one hash, equal to the sweep's (evidence/determinism.txt).
- The implementer's grid, rerun (evidence/impl_grid_repro.txt): 185 dirs, 370 case-views. 246 move and 198 enter
  STRICT_EQUAL; R11U301_OFF equals pristine on 370 of 370. The strict verdict matches the implementer's grid.txt on
  740 of 740 P/L lines; md5 differs everywhere only because the databases carry the worktree path. Each mover is
  restored by exactly one law switch, with the implementer's counts (CAINSIDE 36, SELPARAMREUSE 30, PUREPROTO 30,
  CONSTVARINIT 28, PUREAGG 26, FILLAGGELAB 22, SETCASTW 16, TERNPARAMARM 16, DLYLITFRESH 12, TERNREAL 12,
  TERNTPQUERY 10, IFDLYCONST 8). The fix moves none of the 370 relative to the law.

## The breaks and the refinements (src/ModuleEmit.cpp, switches in src/R301.h)

**§ constVarNestedCallFolds301v** (`R11V301_CALLTOP_OFF`, inside § caConstVarFoldNeedsReducibleInit301).
- Decode: Surelog's `CompileHelper::getValue` reduces a variable's initializer only when the initializer is an
  operation, a hier_path, a bit select or a system call (its last branch). A user call that IS the whole initializer
  stays unreduced, so the law holds there. A module or package function nested inside an operation or a system call
  is evaluated by reduceExpr, and golden folds it. For example, `int w = $clog2(8) + mk();` gives golden `UINT:5`
  under the elaborated cell.
- The law suppressed the fold on any nested call. Seven cases read chain away 1 in the default view with pristine
  right: VV/vv01_sys_plus_user, vv05_tern_call, vv11_unary_fn (`-mk()`), vv12_pkgvar_nested_pkgfn,
  vv13_modvar_nested_qual_pkgfn, vv15_two_calls and vv17_sys_of_call (`$clog2(mk())`). Downstream, vv05 went
  EQUIVALENT -> DIVERGENT.
- The refinement keeps the law for a call at the top (through parentheses and implicit conversions: CV/c21, vv16
  `mk(mk(1))`) and for a nested CLASS static call, which golden does not evaluate (CV/c12, vv14).

**§ setCastWidthParenQualFolds301v** (`R11V301_CASTWQUAL_OFF`, inside § caStructSetterCastMemberWidthNoFold301).
- Surelog does reduce the setter cast in two cases: when the member width is written in parentheses
  (`(Cfg.XLEN)'(2)`) and when it is rooted at an explicit package qualifier (`cfg_pkg::DefaultCfg.XLEN'(2)`).
  Golden writes `UINT:2` for both. The law unwrapped the parentheses and claimed both shapes: VC/vc01_paren_width and
  vc03_pkg_param_width read chain away 1 in both views, with pristine right.
- The law keeps the bare member path: vc02 nested `Cfg.sub.W`, vc04 a local localparam, vc05 two instances and vc07
  an imported `DefaultCfg.XLEN` all move toward golden.

**§ ternParamArmLeadXzOnly301v** (`R11V301_XZLEAD_OFF`, inside § caTernParamArmReusesPaConst301).
- Decode: UHDM's `ExprEval::get_value` parses a BIN, HEX or OCT value with NumUtils' prefix parse (strToInt). The branch
  is unevaluable only when its FIRST digit is x, z or ?. For example, `4'b10xx` reads 2, and golden folds the cell to
  an unlocated `INT:2` of the target width (`6'o7x` gives `INT:7`).
- The law installed the parameter's object for any x/z value: VA/va06_internal_net, va08_oct, va09_lead0_bin
  (`4'b0x1x`) and va10_lead_hex_digit (`8'h3x`) went downstream IDENTICAL -> DIVERGENT with pristine IDENTICAL. All
  four are at uhdm-cmp stage 1 on both binaries; va06's elaborated uhdm-cmp line count grew 28 -> 46 under the law.
- The refinement abstains (pristine's bytes) unless the first digit is x/z/?. It keeps va01 to va05, va07, va11
  (`4'bz100`) and the implementer's TP cases. Transcribing golden's prefix fold (INT:<prefix value>) is a residue.

## Attack grid (cases/, 124 dirs, both views, 248 case-views, every line rc=0; evidence/grid.txt, grid_summary.txt)

Groups and the law each attacks (each case's first line names its law):

| group | law | group | law |
|---|---|---|---|
| VI | § caInsideRhsClonesCell301 | VA | § caTernParamArmReusesPaConst301 |
| VS | § caSelLhsParamReuseAnyEnc301 | VC | § caStructSetterCastMemberWidthNoFold301 |
| VV | § caConstVarFoldNeedsReducibleInit301 | VD | § caDlyParamLitRhsFresh301 |
| VR | § caTernRealArmKept301 | VE | § ifCaConstDelayPerCell301 |
| VQ | § caTernTypeParamQueryNoFold301 | VF | § caFillPackedAggElabSharesDef301 |
| VP | § unitTdPureProtoFormalWriter301 | VG | § pureProtoInlineAggSpans301 |

The refinement witnesses name their refinement:
- § constVarNestedCallFolds301v: vv01, vv05, vv11, vv12, vv13, vv15, vv17;
- § setCastWidthParenQualFolds301v: vc01, vc03;
- § ternParamArmLeadXzOnly301v: va06, va08, va09, va10.

VP/vp08 (a package class reading a `$unit` typedef) was dropped: slang exits 3 on both binaries.

The configurations were P, L, F (fix), FV (fix with R11V301_OFF), FU (fix with R11U301_OFF) and the fix with each
refinement switch off (drivers/fgrid.sh), plus the law with each of the twelve law switches (drivers/swgrid.sh).

- **Law vs pristine:** 194 case-views move, 129 enter STRICT_EQUAL and none leave; no exit code changes. Each mover is
  restored by exactly one law switch: CAINSIDE 28, CONSTVARINIT 26, TERNPARAMARM 20, SELPARAMREUSE 18, PUREAGG 16,
  DLYLITFRESH 14, SETCASTW 12, IFDLYCONST 12, FILLAGGELAB 12, PUREPROTO 12, TERNTPQUERY 12, TERNREAL 12.
  - Away census (drivers/awaycv.sh, chain-keyed): 182 movers read away 0. The other 12 read chain away 1: the
    nine witnesses above in the default view (vv01, vv05, vv11, vv12, vv13, vv15, vv17, vc01, vc03) and vc01_el,
    vc03_el in the elaborated view. That is 11; the twelfth is the vi12 note below.
  - vi12_signed_lhs: order-blind lost 1 with chain away 0 and toward 1, on a coincidental pairing. Strict moves from
    fullname with 2 objects to fullname with 1 object; the remaining record is the signed literal's ref_typespec
    named work@dut in the definition cell, on the sister's ground.
- **Fix vs law:** 26 case-views differ (the 13 witnesses in both views). Every one is back to pristine's bytes and is
  restored to the law's bytes by exactly one refinement switch. FV equals L and FU equals P on 248 of 248 and on the
  implementer's 370 of 370. No case-view leaves STRICT_EQUAL.
- **Fix vs pristine away census:** lost 0 and chain away 0 on every mover except vi12's coincidental order-blind
  pairing, with 498 records toward golden (evidence/grid_away_PF.txt).
- **Downstream** (drivers/dscases.py, all three binaries; evidence/downstream_cases.txt):
  - the law worsened five cases: va06, va08, va09 and va10 IDENTICAL -> DIVERGENT, and vv05
    EQUIVALENT -> DIVERGENT;
  - the fix worsens none;
  - seven cases go EQUIVALENT -> IDENTICAL: vq02, vq03, vq04, vq05, vq06, vq07 and vv10.
- **Shapes the laws met and got right**:
  - CAINSIDE: wildcard sets, signal ranges, instance arrays, `[3:$]`, an unpacked-array set, a function operand, a
    child in a generate block, a parameter delay over two instances, enum members, three cells in one module. A
    parameter-only `inside` is left alone and stays at stage 1 on both binaries.
  - SELPARAMREUSE: 2-D elements, an element part-select, `-:`, a struct part-select, a wire bit, unsized-decimal and
    unsized-based parameters, two instances with overrides.
  - DLYLITFRESH: three instances with one default, an unsized based literal, an x literal, a comma list, a narrow
    literal, a wire Lhs.
  - IFDLYCONST: three instances, an interface array, an interface in a generate block, modport ports, two
    statements with different delays.
  - FILLAGGELAB: parameter-sized dimensions with two instances, a child in a generate block, a delayed fill, a
    package enum element, two fills in one module.
  - PUREPROTO: a pure task, class-key order, a pure virtual extended by another pure virtual, a `ref` formal, two
    multi-line formals.
  - PUREAGG: an interface class with a direction, a task with a union and no direction, an unpacked dimension, a
    multi-line output, a package class return, a parameterized class, CRLF, a macro-built type.

## Byte controls (drivers/ctlpl.sh; evidence/controls*.txt)

4015 case dirs were selected from 359 earlier repro dirs under tools/probe by the laws' triggers (`inside {`,
`assign #`, `pure virtual`, `$bits(`, `= '1;`, a real branch, a cast `'(`, a bare call initializer). The path list was
built with find and filtered by `$FENCED` before any file was opened. That gives 8030 case-views; 38 views exit 3
(SLANG_FAIL) and 4 are SURELOG_FAIL, identically on both binaries.

- Law vs pristine: 44 move, 12 enter STRICT_EQUAL and 0 leave, with 0 exit-code changes.
- One uhdm-cmp line count changes, and toward golden: v11u144repro/brk/tq/x5_el goes 36 -> 0 and converts.
- The 12 entering are r11u85repro a6_commadrive, v11u144repro tq/x5 and v11u299repro VP/vp08, VR/vr08, VU/vu01 and
  vu14, each in both views.
- Away census on all 44: lost 0 and chain away 0, with 44 records toward golden.
- The fix equals the law on all 44.

## Residues (ranked; all wrong on pristine too)

1. The prefix fold of an x/z ternary branch with a valid leading digit (va06, va08, va09, va10). Golden writes an
   unlocated `INT:<prefix value>` at the target width; transcribing it would convert these four. ModuleEmit, the
   § elabCaTernaryArmInstall92 site.
2. The implementer's residues stand (re-measured):
   - interface-body cells: c_iface_body, SP s11, CI c10, CV c18, FP p26;
   - generate-scope cells: CI c11 and c25, FP p27;
   - a constant `inside` (CI c05, and vi04 here);
   - TP a06 and a10;
   - parenthesised or rise/fall delays (DL d06, i04, i09; VE/ve05 `#(6)` here at stage 1);
   - FP p13, p17, p18 and p24;
   - the pure virtual leftovers vu15, PV v13 and PA a14;
   - pass 299's list.
3. Shapes found here, at uhdm-cmp stage 1 on both binaries:
   - moved by the law toward golden with away 0: VR vr02 (real array target), VQ vq04 (struct type override),
     VD vd05 (a realtime parameter delay), VE ve01 to ve04 and ve06 in the default view (the interface cells' other
     stage-1 face), VP vp07 (a nested class), VG vg01 (an interface class with a direction), VV vv14, VC vc02 and
     vc07;
   - unmoved: VS vs02 (real parameter), vs06 (localparam of a parameter), vs10 and vs13; VQ vq01 (`$bits` of a
     T-typed signal); VD vd03 (`#pk::D`); VE ve05 (`#(6)`); VF vf08 (an unpacked array of structs); VP vp01 (a
     parameterized class, pass 299's vu06 face) and vp04 (an implementing class); VG vg04 (a return without
     dimensions); VV vv02 and vv08;
   - VI vi07 (a typedef'd Lhs) and vi12 stay STRICT_NOTEQUAL at depth and fullname, moved toward golden.
4. Sister-ground faces (reported, not written): the signed literal's ref_typespec full name in a definition cell
   (VI/vi12, ExprEmit); the implementer's list in r11u301repro/README.md stands.

## Process

- Every driver reads `$FENCED` fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh)
  and never spells it. Every path list was filtered before any file was opened.
- Only the verifier's own processes were waited on; no other agent's process was listed or signalled. Nothing was
  written outside /tmp/wt_v11u301, /tmp/wt_v11u301pris and /tmp/v11u301_*.
- The refinements were written after the pristine and law binaries were frozen. The fix binary was frozen before its
  census and its sweep. A first fix draft (7a8fcbf1) carried only the first two refinements and was measured only on
  the VV and VC grids.
- No slip.
