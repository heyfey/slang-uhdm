# v11u302 — adversarial verification of r11u302 (pass 302, expression/parameter ground)

Base 0c29ccd0 (pass 300). Worktrees /tmp/wt_v11u302 (law, then fix) and /tmp/wt_v11u302pris (pristine), scratch
/tmp/v11u302_*. Production surface of the verified patch: src/ParamEmit.cpp, src/ExprEmit.cpp and src/R302.h (the
implementer's three files; the two refinements are in ParamEmit and R302.h only), plus the regenerated tests/LAWS.md.

## Verdict

**The implementer's numbers reproduce bit for bit, and the patch has TWO BREAKS on legal SystemVerilog. Both are fixed
by two refinements in ParamEmit.cpp.**

1. Case-views where pristine was judge-equal and the law fails uhdm-cmp: VL/vl01, vl16 and vl17 in both views
   (uhdm-cmp 0 -> 28).
2. Strict records that the law moves away from golden: vl01, vl02, vl14, vl16, vl17, vl18 and vq07 (elaborated view,
   chain away 1 each), and vq03 d/e (chain away 26 and 27).

No gate row moves between the law and the fix. Neither refinement fires or abstains anywhere in the gate (census),
and 0 gate databases differ between the law and the fix.

- Builds (frozen, chmod 555, before any measurement):
  - pristine f050c791ecad49e641fde77e05aa7faa, equal to the main tree's build/slang-uhdm.
  - law 68d848f44dcb2c30d51741e98e5e1f61, equal to the implementer's.
  - fix 3f73fee7a6b2bbbdb1148db9f7766365, rebuilt from the final sources with the same md5.
  - The binaries report slang 12.0.0+545f88b2e and UHDM 1.87.
- The eight probe conversions and the one change, reproduced on the law and fix sweeps:
  - `r11u13repro/b3,EQUAL,,equal` (was `differ:line(29)`).
  - `r11u24repro/n11,EQUAL,,equal` (was `differ:fullname(7)`).
  - `r11u24repro/n4,EQUAL,,equal` (was `differ:line(17)`).
  - `r11u26repro/m4,EQUAL,,equal` (was `differ:fullname(39)`).
  - `r11u26repro/m7,EQUAL,,equal` (was `differ:fullname(38)`).
  - `r11u28repro/a2,EQUAL,,equal` (was `differ:fullname(39)`).
  - `r11u60repro/g7,EQUAL,,equal` (was `differ:fullname(1)`).
  - `r11v55repro/grid/vv1c_cast,EQUAL,,equal` (was `differ:file(8)`).
  - The change: `r11v21repro/v15,STRICT_NOTEQUAL,differ:depth(1),differ:depth(1)` (was `differ:fullname(7)`).
    - The first record moves from #6 (ref_typespec `<in>loc_t.aa`, raw `loc_t.aa` against ours
      `work@dut.LC.loc_t.aa`) to the walk's divergence at `typespec_member bb` (depth 6) against our leftover
      constant (depth 7).
    - The chain-keyed away census reads away 0 and toward 22 (evidence/v15_first_records.txt,
      evidence/probe_movers_away.txt).
  - The chain-keyed away census on all 9 probe movers, fix against pristine: away 0, toward 22 / 30 / 34 / 36 / 72 /
    38 / 72 / 1 / 8.

## The refinements (src/R302.h, ParamEmit stampEvalFuncLeftovers)

`R11V302_OFF` drops both refinements and gives the law's bytes on 108 of 108 fresh case-views and on 114 of 114 of
the implementer's grid. `R11U302_OFF` on the fix binary still gives pristine's bytes on 108 of 108 and on 114 of 114.
Both refinements log to `R11U302_TRACE` (tags `modFnLitLeftoverValueGate302v_ABSTAIN` and
`leftoverSlotSoleWriter302v_ABSTAIN`). evidence/refinement_trace_poscontrol.txt shows them firing on their witnesses.

### § modFnLitLeftoverValueGate302v — switch `R11V302_LITVAL_OFF`

- **The break:** § modFnLitLeftoverAtLiteral302 shares the body literal that the leftover collector recorded, which
  is the LAST assignment to the member in the body's text. Surelog's `setValueInInstance` stamps the literal of the
  assignment that the evaluation EXECUTED.
- **Witnesses:**
  - VL/vl01: `if (s) c.b = 64; else c.b = 99;` with `mk(1'b1)`. Golden's leftover is the `64` at 8:38. The law shared
    the `99` at 8:53. Pristine's minted UINT:64 at the call matched golden's value, so pristine was judge-equal and the
    law reads uhdm-cmp 0 -> 28 in both views.
  - VL/vl16: a case statement. VL/vl17: a named argument `mk(.s(1'b1))`. VL/vl18: an omitted default whose branch is
    the first one written (stage 1 on both binaries, chain away 1 in the elaborated view).
- **The refinement:**
  - The literal law fires only when the literal equals the folded bits that the minted constant was cut from. The
    literal is sized to the write target as the assignment converts it: truncated, or extended by its own sign.
  - The comparison is on bits only, so a signed literal's -56 and the folded 200 are the same 8 bits. A draft that
    compared values lost VL/vl15's sharing.
  - The record is `mintSlice302v`, written at makeMemLeftConst's only call site. Writing it moves no byte.
  - A truncated literal still fires: VL/vl03 `c.a = 300` into 8 bits, where golden keeps UINT:300 and the minted value
    is UINT:44. vl03 enters STRICT_EQUAL under both law and fix.

### § leftoverSlotSoleWriter302v — switch `R11V302_SOLEWRITER_OFF`

- **The break:** a typespec member's leftover is a SINGLE slot, and the last evaluation writes it.
  - Golden VQ/vq03: two module builders write pk::c_t's `u`, `mk` from `pk::UU` and then `mk2` from `UU` through
    `import pk::UU`. Golden keeps mk2's clone of the module's copy (`work@dut`).
  - Golden VQ/vq07 (the two localparams swapped) keeps mk's clone of the package listing (`pk`).
  - The stamp walk keeps the FIRST stamp's values on a shared typedef (the landed model). Pristine's module-copy clone
    therefore matched golden on vq03 by coincidence, and § pkgPatLeftoverSrcPkgListing302 turned it into the package
    listing's clone: chain away 26 and 27.
  - § modFnLitLeftoverAtLiteral302 likewise moved the first writer's literal:
    - vq07 `d` (`64` against `65`);
    - VL/vl02, two calls of one builder giving two values;
    - VL/vl14, two builders.
    Each is chain away 1 in the elaborated view.
- **The refinement:** the three drain laws stand aside on a member whose slot another stamp also writes. The slot is
  keyed by the owner parameter's canonical struct type, and what counts as a conflicting writer depends on the law:
  - **Literal law:** a different literal by source location (two instances of one module hold two AST copies of the
    same literal), a non-literal, or a different value.
  - **Package-listing law:** a different read site or a different parameter.
  - **Module-pattern law:** a writer that is not a module-held pattern-parameter read.
- **What still fires:** writers that agree keep the laws. Examples are one $unit builder called from two modules
  (VL/vl08) and one module builder in two instances (VL/vl06; the implementer's PM/p06, whose
  § modPatLeftoverCloneNoParent302 move toward golden is kept).
- **Gate effect:** the only implementer grid case it changes is RT/r08_two_mods (stage 1 on every binary, the literal
  law standing aside).

A third draft (the $root stamp walk taking the LAST matching stamp) was measured and dropped
before the fix was frozen: it worsened vr01, vr06 and r08 back to pristine's uhdm-cmp counts and vr03 from 28 to 36.
The fix binary is the rebuild without it, md5 equal to the draft before it.

## Grids (every line carries its exit code)

### Fresh attack cases

cases/: 54 dirs and 108 case-views. evidence/grid_fresh.txt and grid_fresh_summary.txt record pristine, law, fix, and
fix with each of R11U302_OFF, R11V302_OFF, R11V302_LITVAL_OFF and R11V302_SOLEWRITER_OFF.

**Law against pristine:**
- 90 moving, 12 entering STRICT_EQUAL, 0 leaving, no exit-code change.
- uhdm-cmp 0 -> 28 on vl01, vl16 and vl17 in both views: the breaks.
- uhdm-cmp 28 -> 0 on vl03.
- The other line-count changes are stage-1 heads moving on both binaries:
  - vl15 40 -> 64. The law shares the literal `4'sb1010` and the head moves to golden's assembled value, where Surelog
    zero-extends the signed literal (`19'b0000_1010...`) against slang's `1111_1010`. That is a Surelog extension
    defect, not to transcribe.
  - vr02 15 -> 36 and vr03 15 -> 28: pristine's missing $root stamp becomes a stamp from the wrong writer.
  - vr01 and vr06 32/62 -> 28/58.
- Chain away 60 on 9 case-views, all listed above. evidence/away_fresh_law.txt.

**Fix against pristine:**
- 82 moving, 12 entering, 0 leaving, no exit-code change.
- uhdm-cmp: vl03 28 -> 0 and the stage-1 counts above. The vl15 change is unchanged from the law and is chain away 0.
- Chain away 0 on all 82, with 2052 records toward golden. evidence/away_fresh_fix.txt.
- 22 case-views differ from the law. Each is restored to the law's bytes by exactly one switch: LITVAL 8 and SOLEWRITER
  14. Eight of the 22 carry pristine's exact bytes (vl14, vq03, vq07 and vq08).

**The cases:**

| group | law | cases |
|---|---|---|
| VL | § modFnLitLeftoverAtLiteral302 (vl03 to vl13), § modFnLitLeftoverValueGate302v (vl01, vl15 to vl18), § leftoverSlotSoleWriter302v (vl02, vl14) | vl01_branch_arg, vl02_two_args, vl03_trunc, vl04_class_static, vl05_genblk_fn, vl06_twoinst_ovr, vl07_xz, vl08_unit_twomods, vl09_loop_lit, vl10_program (interface, program, implicit net), vl11_sel_slot (part-select bounds, replication count, indexed width, dimension), vl12_two_literal_same, vl13_ifport_genfor, vl14_same_val_arms, vl15_signed_lit, vl16_case_arms, vl17_named_default, vl18_default_omitted |
| VP | § modPatLeftoverCloneNoParent302 | vp01_genlocal_uu, vp02_twoinst_param, vp03_modtd, vp04_unittd, vp05_nested_pat, vp06_shadow_pkg |
| VQ | § pkgPatLeftoverSrcPkgListing302 (vq01, vq02, vq04 to vq06), § leftoverSlotSoleWriter302v (vq03, vq07, vq08) | vq01_qual_genfn, vq02_chain_src, vq03_explicit_imp, vq04_iface_qual, vq05_twopkgs, vq06_explicit_single, vq07_two_builders_swapped, vq08_two_qual_builders |
| VR | § rootTdLeftoverStamp302 | vr01_two_lp, vr02_shadow_modtd, vr03_iface_root, vr04_nested_root, vr05_unpacked_var, vr06_two_inst_param |
| VG | § elabImpSelFlatKeepsParent302 | vg01_lp_sel, vg02_two_mods_explicit, vg03_nested_sel, vg04_iface_imp, vg05_export_chain, vg06_fn_sel |
| VC | § castPatTagKeyLocThroughParens302 | vc01_paren_nocast, vc02_default_key, vc03_array_keys (exit 4 on every binary), vc04_unpacked, vc05_typeparam (always_comb and port actual), vc06_forgen_case, vc07_class_prop, vc08_macro_key, vc09_slots_hdr (header default, override, constant slots), vc10_cls_bound (class specialization in a part-select bound) |

Entering STRICT_EQUAL under both law and fix:
- vl03, vl09 and vl12;
- vg02;
- vr04;
- vq06 (an explicit `import pk::UU` with a qualified read, the package-listing law correct when it is the slot's
  only writer).

**Downstream** (drivers/dscases.py, all 54 dirs on all three binaries; evidence/downstream_cases.txt): no verdict
change. Pristine, law and fix agree on all 54: 49 IDENTICAL, 3 DIVERGENT (vc02, vc03 and vg05, all stage 1 on
every binary) and 2 EQUIVALENT (vc09 and vp02).

**Positive control** (binaries swapped, every sixth fix mover): away on 13 of 13. evidence/away_poscontrol.txt.

### The implementer's grid

tools/probe/r11u302repro/cases: 57 dirs and 114 case-views, rerun with my goldens on all seven labels
(evidence/grid_implementer*.txt).
- The law reproduces the implementer's numbers bit for bit: 96 moving, 47 entering STRICT_EQUAL, 0 leaving, the same
  12 uhdm-cmp line changes, and R11U302_OFF equal to pristine on 114 of 114.
- The fix differs from the law on RT/r08_two_mods d/e only: SOLEWRITER, stage 1 on every binary, uhdm-cmp 28 on both.
- Chain away 0 on all 96 fix movers, with 2380 records toward golden, the implementer's count.

## Byte controls (evidence/control_dirs.txt, controls_summary.txt, controls_away.txt)

- **Path list:** 1808 case dirs and 3616 case-views on three binaries. It is the implementer's 1691 dirs plus 117 more
  selected by trigger: a cast-wrapped or parenthesized pattern, a member write from a literal beside a parameter
  initialized by a call, or a typedef sized by a parameter member select.
- **Fence:** the path list was built with find over tools/probe, filtered by $FENCED (word boundary) before any file
  was opened, and filtered again inside drivers/ctlv.sh. Surelog segfaults on 4 case-views, which have no golden.
- **Results:**
  - Law against pristine: 22 moving, 10 entering STRICT_EQUAL, 0 leaving, no exit-code or uhdm-cmp change.
  - The fix equals the law on every control case-view.
  - Chain away 0 on all 22, with 238 records toward golden.
- **The movers:**
  - The implementer's 18:
    - r11u260 E/e15_unpacked, v11u225 FO/h07 and r11v140 tdc/t08_decl_after (CASTPATKEY);
    - r11u272 L/l08_import and l15_import_noaa, and r11v178 pu/u07_packed_struct (IMPSELFLATPAR);
    - r11u28 a19 and a20 (LITLOC, with PATMODNOPAR on a19);
    - r11u26repro n11 (the twin of the converted gate case).
  - Two new ones: r11u195repro T/t10 d/e (entering STRICT_EQUAL) and v11u228repro FM/f13 d/e (stage 1), both
    CASTPATKEY by trace.

## Firing census (evidence/predict_law.txt, predict_fix.txt)

- **Law census:** drivers/tracecensus.sh on the law binary over the probe cases and both corpora in both modes, the
  filter built from $FENCED. The output is byte-identical to the implementer's predict.txt (39 lines).
  - Firings on the 9 probe databases.
  - elabImpSelFlatKeepsParent302 82 times on BlackBePipeInt d/t.
  - pkgPatLeftoverSrcPkgListing302_ABSTAIN on 26 probe cases and on portsel_struct_param d/t.
- **Fix census:** run and frozen before the fix sweep. It is byte-identical to the law census: no refinement tag
  anywhere in the gate.
- **Byte movers against the prediction:**
  - Probe: law against pristine moves exactly the 9 predicted databases. Fix against law: 0 of 4087.
  - The pristine probe databases were re-swept from the law worktree (sweep Q): a probe database embeds its source
    path, so a cross-worktree byte comparison flags all 4087.

## Gates (evidence/sweep_*.log, downstream_*.log, byteverify.txt)

| gate | pristine | law | fix |
|---|---|---|---|
| probe | 3997 + 90, 0/0/0 | 4005 + 82, regressions 0, conversions 8, changes 1 | identical to law (csv row diff 0) |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | same, 0/0/0 | same, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | same | same |
| downstream | 803/66/2/0, csv byte-identical to the committed one | same, byte-identical | same, byte-identical |

Further gate results:
- **csv row diff, law against pristine:** the 9 probe rows plus the LowMemLib / LowMemPkg testflags detail text (the
  workdir path). Fix against law shows only that detail text.
- **byteverify** (SELFCHECK=1, same-length workdirs, fence-filtered hard-link mirrors of 2560 databases with 8 fenced
  skipped):
  - MOVERS 0 / 2560 for law against pristine, fix against law and fix against pristine.
  - SELFCHECK reads 2559 / 2560 each time. It compares every file with one fixed file, and that file compared with
    itself is the one not flagged (pass 201's artefact), not a mover.
  - Downstream-lane slang.uhdm: 0 / 805 for all three pairs.
- **Canaries:** surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0 on all three sweeps. ctcan2 with
  EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 PASS on all three.
- **Binary-path audit** (drivers/audit.sh): own=3265, other=0, noslang=50, fenced_skipped=8 on each of the three
  sweeps.
- **Determinism** (drivers/det.sh, three concurrent draws on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
  BuildUVMPkg and Rggen): one hash per row-mode for law and for fix, each equal to its sweep's database. Scoreboard and
  Rggen testflags write no database. evidence/determinism_*.txt.
- **Law index:** every sweep exited 1 on the law-index check alone; tests/LAWS.md was stale at the base. The
  regenerated tests/LAWS.md is in the verified patch.

## Residues (ranked; all wrong on pristine too)

1. **The slot's last writer.** The stamp walk (ParamEmit stampEvalFuncLeftovers' TopPackages walk and
   § rootTdLeftoverStamp302) keeps the FIRST stamp where golden keeps the LAST evaluation. Witnesses on this ground:
   - vq07 (golden `pk`, ours `work@dut`);
   - vl02 (golden `64`, ours `99` at the call);
   - vr01, vr03, vr06 and r08 (a $root type with two writers).

   The laws stand aside there (fix == pristine or stage 1 on every binary). Simply taking the last stamp was measured
   and worsens vr01, vr03, vr06 and r08. The owner bindings and the per-member slots need a joint model.
2. **The literal of the executed branch when two branches agree in value** (vl14): stage 1 on every binary, the law
   standing aside.
3. **Surelog's zero extension of a signed sized literal** in its assembled struct value (vl15: `4'sb1010` into 8 bits
   reads 0x0A in golden). A Surelog defect, not transcribed.
4. **The implementer's residues** stand as listed in tools/probe/r11u302repro/README.md (v15's assembled
   param_assign reference, the stage-1 grid shapes, the naming leftovers, the r11u109 x64 value defect).
5. **Stage-1 shapes on every binary**, not decoded:
   - vc02 to vc09 (other faces of the same rows);
   - vg01, vg03 to vg06 (the package-select copies through a localparam, a nested select, an interface import and an
     export chain);
   - vp01 to vp06, vq01, vq02 and vq04;
   - vl04 to vl07, vl10, vl11 and vl13.

   All move toward golden or stay put with chain away 0.

Sister-ground faces: none new. The implementer's list stands.

## Process

- **No slip by the verifier.**
  - Pristine was built and frozen before the law sources were compiled. Every refinement draft was built only after
    its source edit was complete, and no source was edited while a compile ran.
  - Four drafts were frozen as fix_d1 to fix_d3 and a dropped fix_d4. The final fix is a rebuild with fix_d3's md5.
    Every number above comes from the frozen pristine, law and fix binaries.
- **The fence.**
  - Every driver read $FENCED fail-closed.
  - Every path list over tools/probe or a sweep workdir was filtered by $FENCED before any file was opened. No fenced
    name was spelled, and no fenced source or database was read.
  - The census ran with a --filter built from $FENCED.
  - The fence scan of this directory reads 0 hits.
- **Processes and writes.** No other agent's process was listed or signalled, and nothing was written outside the
  worktrees and /tmp/v11u302_* scratch.
- **Drivers.** Copied from tools/probe/r11u302repro/drivers (binaries /tmp/v11u302_bin, goldens /tmp/v11u302_gold),
  plus one.sh, gridv.sh, gridvsum.py, ctlv.sh, ctlvsum.py and bvlanes.sh (new). No patch file is kept in this
  directory.
