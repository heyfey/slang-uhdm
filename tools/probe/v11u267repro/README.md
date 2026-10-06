# v11u267: adversarial verification of r11u267

Base 7d6db9ca, implementer's patch /tmp/r11u267.patch (md5 b0d1531b). Verdict: **one break found and fixed**.
Law § caFoldParentUnboundLhs267 parented a folded right side that Surelog leaves unparented when the cont_assign's
delay is a parameter reference (`assign #D s.q = {W{1'b1}};`). That case is STRICT_EQUAL on pristine and
STRICT_NOTEQUAL fullname under the law, in both views (VA/va01).

The fix is § caFoldDelayRefKeepsUnparented267v, switch `R11V267_DLYREF_OFF`, in `src/ModuleEmit.cpp` and
`src/R267.h`. `R11V267_OFF` gives the law's bytes, and `R11U267_OFF` still gives pristine's. The fix moves 0
gate databases against the law. Every implementer number below was reproduced bit for bit.

| row-mode | base | law and fix sweep row |
|---|---|---|
| Earlgrey_0_1 default | `differ:file(19)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:file(210),,differ:file(210)` |
| Earlgrey_0_1 testflags | `differ:fullname(20)` | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(18),,differ:fullname(18)` |

The default count grows only because pristine's walk diverged. Its strict output reads `objects 2173209 vs 2173214
(walk diverged)`, with #816151 / #816152 last, the `sha_word_t [7:0] digest` net. The law's walk runs to the end of
the design. The first records are #395727, #464077 and then #726217 on both sides (evidence/earlgrey_default_*).

The away census on both Earlgrey row-modes reads 0 lost:
- record census: default dist 171 -> 154, testflags 586 -> 569;
- chain-keyed census: 0 away and 17 toward on each.

Probe conversions (STRICT_NOTEQUAL -> EQUAL, results/ untouched), the same four in the law sweep and the fix sweep:
`r10earl107repro/g1_home107`, `r10earl78repro/a3_wide78`, `r10v78repro/v6_ndecl78` and `r10v78repro/v7_pre78`.

## The verifier's refinement

**§ caFoldDelayRefKeepsUnparented267v** (`R11V267_DLYREF_OFF`; `R11V267_OFF` drops it). It sits inside
§ caFoldParentUnboundLhs267, in emitContAssigns.
- Surelog's `UhdmWriter::writeCont_assign` clones the assign first when `delay->UhdmType() == uhdmref_obj`, which
  sets `cloned = true`.
- Its `simplified == false` branch runs `res->VpiParent(assign)` only inside `if (cloned == false)`.
- So with a parameter-reference delay, golden's folded constant has no parent. The law now steps aside when our
  cont_assign's Delay is a `ref_obj`, mirroring Surelog's own test.
- A delay that folds to a constant keeps the law, because golden's delay is a constant there too (VA/va11, an
  imported package parameter `#Dly`). A constant `#1` or an operation `#(D+1)` delay also keeps it (VA/va10).
- The trace `caFoldDelayRefKeepsUnparented267v` fires on va01 (evidence/fix_positive_control_va01.txt).
- The firing census of the fix binary over probe and both corpora (fence-filtered; evidence/predict_fix_frozen.txt,
  frozen before the fix sweep) is identical line for line to the implementer's frozen prediction. The refinement
  fires on no gate database.

## Gates (all measured by the verifier on its own frozen binaries)

1. **Build.** Pristine `5a63fea69f27c2454a177981f83d37c9` (the main tree's). Law `028869c3ae32f7c2f9ca51fbfdf7f580`
   (the implementer's). Fix `90887493778b978e83ae9a828e266aab`. The uhdm-strictcmp md5 is fa6e4f42, the main
   tree's. The binary reports slang 12.0.0+545f88b2e.
2. **Probe.**
   - Pristine: 3566 / 521, 0 regressions.
   - Law and fix: 3570 EQUAL + 517 STRICT_NOTEQUAL, regressions=0, conversions=4, changes=0.
3. **Corpora.**
   - Pristine reads the baselines exactly.
   - Law and fix, surelog: regressions=0, conversions=0, changes=2 (the two Earlgrey rows above).
   - Law and fix, uhdm2rtlil: 803 / 1 / 67 in both modes, 0 changes.
4. **Downstream.** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on all three binaries. The csvs are
   identical once the workdir path is normalised.
5. **uhdm-cmp.** Every touched row-mode stays CMP-equal: the Earlgrey rows hold their judge-equal status, and every
   probe mover is EQUAL.
6. **byteverify** (fence-filtered hard-link mirrors, SELFCHECK 2559 / 2560):
   - law vs pristine: 2 of 2560 move, Earlgrey_0_1 d/t;
   - fix vs law: 0 of 2560 move;
   - fix vs pristine: the same 2.
   - Probe databases: 4 of 4087 move law vs pristine, the four conversions, and 0 fix vs law. Both probe sweeps ran
     from the same worktree, because a probe database records its source path.
   - The movers are exactly the six databases in the frozen firing census.
7. **Canaries** on the law csvs: surelog ok=50 changed=2 (the Earlgrey rows), uhdm2rtlil ok=16, and both ctcan2
   checks PASS. The fix csvs are identical to the law's.
8. **Binary-path audit.** On the pristine and the law sweep, 3265 of 3315 fence-filtered cmds.txt name that sweep's
   own binary and 0 name another binary. The other 50 run no slang: 48 carry no slang line at all, and the 2 SweRV
   lines match only the repository path.
9. **Determinism.** Three concurrent draws of the fix binary on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
   Scoreboard, BuildUVMPkg and Rggen give one hash per row-mode, equal to the fix sweep's (evidence/det_fix.txt).
10. **Law index.** At the base, `scripts/law_index.py --check` already reads STALE on the main tree and on a pristine
    worktree: pass 265's laws gain their own commit 7d6db9cad on regeneration. So every sweep, pristine included,
    exits 1 on that check alone. The index is regenerated in the delivered patch.

## The implementer's grid, reproduced (evidence/grid_impl.txt)

The grid covers 78 case dirs in both views, 156 case-views, on 10 configurations (P, L, F, F+R11V267_OFF,
F+R11U267_OFF, and F with each of the five switches off). Every line reads rc=0.
- 78 case-views move, 48 enter STRICT_EQUAL and none leave.
- R11U267_OFF gives pristine's bytes on 156 of 156, and R11V267_OFF gives the law's on 156 of 156.
- The fix gives the law's bytes on 156 of 156.
- Each mover is moved by exactly one switch: CAFOLDPARENT 16, GENREPLPARENT 12, TDDIMNET 38, QUALPATCONN 12.
- The uhdm-cmp line count changes only on C/c03 (32 -> 36 in both views), as the implementer reported.

## Byte controls

- The implementer's 19 repro dirs, pristine vs fix: 2606 case-views, 0 move (evidence/controls.txt). The 28 lines
  that are not rc=0 are rc 3 or rc 4 identically on both binaries.
- Widened by 7 dirs that hold delay, unsized/cast clone and port-actual fold legs (r11u164, r11u90, r11u193, r11u176,
  r11u152, r11u88, r11u16): 830 case-views, 0 move, every exit code the same on both binaries
  (evidence/controls_widened.txt).

## Attack: 47 fresh case dirs in both views (94 case-views; evidence/grid_fresh*.txt, away_fresh.txt, ds_fresh.txt)

Every line reads rc=0. R11U267_OFF gives pristine's bytes on 94 of 94, and R11V267_OFF gives the law's on 94 of 94.
- **Law vs pristine:** 56 move, 28 enter STRICT_EQUAL, and **2 leave: va01 in both views, the break.**
- **Fix vs pristine:** 54 move, 28 enter STRICT_EQUAL, none leave. Each mover is moved by exactly one switch.
- **Away census (fix vs pristine):** 0 lost wherever both sides pass stage 1. On the stage-1 movers (vb04, vc03,
  vc06, vc08) the dump-line census reads lost lines. Every one is a print-position artefact: an indentation-blind
  recount reads 0 lost on all of them.
- **Downstream (fix vs pristine):** VC/vc09 goes DIVERGENT -> IDENTICAL, an interface-body `wire b_t [1:0] w`.
  None leaves IDENTICAL.

| cases | law | shapes and result |
|---|---|---|
| VA/va01 | § caFoldDelayRefKeepsUnparented267v | `assign #D s.q = {W{1'b1}}`: STRICT_EQUAL on pristine, fullname under the law, STRICT_EQUAL again under the fix (both views) |
| VA/va09, va11 | § caFoldDelayRefKeepsUnparented267v | `#(D)` (unchanged; stage 1 on both), and `#Dly` / `#(fp::Dly)` from a package (golden's delay is a constant: the law keeps firing; stage 1 on both, toward golden) |
| VA/va02 to va08, va10 | § caFoldParentUnboundLhs267 | an arithmetic or ternary member fold, an interface body, a concat Lhs, a member part select, a hierarchical Lhs, a generate-for member path, a comma list, a constant or operation delay. va07 moves (its elaborated view enters STRICT_EQUAL); the rest are unchanged or stage 1 on both |
| VB/vb01 to vb10 | § genCaReplParentBoundLhs267 | a gen-local net shadowing the module port (vb01), a gen-local net whose name the parent instance also declares (vb02, vb09), an interface gen scope whose signal name the instantiating module also declares (vb03), a param delay (vb04), nested gen-for/gen-if with a gen-local count (vb05), a case-generate (vb06), a program (vb07, no fire), a gen net beside a replication operand (vb08), if/else and for-if (vb10). vb05_el, vb06, vb08 and vb10_el enter STRICT_EQUAL |
| VC/vc01 to vc16 | § typedefDimNetDropsDims267 | a 2-D typedef, a reg typedef, a module-local typedef, two ports in one declaration, an interface body wire, a child in a generate block, a non-ANSI port, an input port, two levels of children: all enter STRICT_EQUAL. inout (vc03), ascending dims (vc06) and wand/tri (vc08) are stage 1 on both and move toward golden. A type parameter (vc13) is STRICT_EQUAL and untouched |
| VD/vd01 to vd10 | § pkgQualPatConnSpan267 | spaces around `::`, a localparam with an import beside it, `'{default:}`, interface and program instances, a package in its own file (vd05), a pattern typed from a third package, a generate loop, a macro-written actual, CRLF, `$unit::` (no fire). vd02, vd06, vd08 and vd09 enter STRICT_EQUAL in the default view; the elaborated views clear the line record and stop at a pre-existing member-order record |

## Findings (none visible to any gate; ranked)

1. **The break and its fix** (above): VA/va01.
2. **The gen-scope twin of the delay rule.** § genCaReplParentBoundLhs267 ignores a parameter-reference delay
   (VB/vb04). Surelog's first branch needs `cloned == false` too, so golden keeps the replication operation unfolded,
   and ours folds it on pristine as well. That makes it stage 1 on both, with distance unchanged, and the law changes
   only the fold's parent. This is left as a residue, not refined: no strict or downstream reading moves.
3. **Surelog's `bindVariable` binds by name across scopes.** It walks the VpiParent chain and checks only function,
   task, begin and module_inst. A gen-local net (vb01), or a name that only the PARENT instance declares (vb02,
   vb09), therefore binds in golden. The same holds for an interface gen-scope signal whose name the instantiating
   module declares (vb03). In each case golden leaves the fold unparented, while `caLhsBindsByName267` reads the
   slang symbol and keeps the parent. This is wrong on pristine too; the next pass's shape for this law.
4. **§ typedefDimNetDropsDims267's homes not covered.** A typedef'd net inside a generate block (VC/vc11:
   STRICT_NOTEQUAL name and downstream DIVERGENT on both binaries). Unpacked dimensions (vc12, an array_net; stage 1
   and DIVERGENT on both). A parameter-dependent module-local typedef (vc14; stage 1 and DIVERGENT on both).
5. **§ pkgQualPatConnSpan267's positional span in a package from another file** (VD/vd05). The span is now golden's
   (7:10-7:14), but the file stays the package's (`pkg.sv`) where golden names the use site's `dut.sv`. Pristine had
   the same file.

## The implementer's residues and sister-ground decodes (not re-decoded here)

Not re-measured beyond the grid: #726217 / #727777 / #730573 (ParamEmit drainShareDefParamTs first-match, O/o01 to
o05), #395727, #464077 and the § genIpsBoundOwner256 family (ExprEmit), testflags #580520 to #594077 (not
reproduced), the select-Lhs fold (R/r11 to r14), and brief items (2) to (5).

## Process

- Every corpus reader read `$FENCED` fail-closed, from tools/probe/r11u107repro/canaudit.sh through drivers/env.sh:
  - the firing census ran through the harness with the fence filter;
  - byteverify ran on fence-filtered mirrors (8 fenced databases skipped unread);
  - the binary audit and the probe byte comparison ran on path lists filtered before opening any file;
  - the away census ran on Earlgrey only.
- No fenced name was spelled, and no process was signalled.
- **The verifier's slip.** The first launch of the implementer-case grid ran twice concurrently: a first invocation
  with a bad relative path started anyway, and its relaunch ran beside it. The two runs clobbered each other's
  case.sh outputs, which the duplicate-key check caught. All of that grid's non-golden outputs were deleted and the
  grid was rerun alone; the numbers above come from that rerun.
- The determinism draws, the fix sweep and the widened controls used the frozen binaries only.

## Files

- `cases/` holds 47 case dirs (VA 11, VB 10, VC 16, VD 10). The first line of each names its law.
- `drivers/`:
  - vgrid.sh, the 10-configuration grid;
  - vsum.py, its summary;
  - the remaining drivers copied from r11u267repro: env.sh, case.sh, grid.sh, controls.sh, tracecensus.sh,
    bvmirror.sh, det.sh, the away drivers, dscases.py, strictcmp_x.cpp and cc_x.sh.
- `evidence/` holds the measurements named above.
