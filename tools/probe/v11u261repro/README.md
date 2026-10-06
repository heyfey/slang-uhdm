# v11u261: adversarial verification of r11u261 (pass 261, the module/type ground)

Base e3538174 (pass 259). Worktrees /tmp/wt_v11u261 (law + fix) and /tmp/wt_v11u261pris (pristine), scratch
/tmp/v11u261_*. Every binary was built by the verifier and frozen before any measurement:

| binary | md5 |
|---|---|
| pristine (e3538174) | 59fd71bb928e52946a4bf932aba35a98 (equal to the main tree's build) |
| law (/tmp/r11u261.patch, md5 62bcdb091642355b634ee04ffbb0c54c) | 3667c71c45081af8b7cf558a0a52d403 (equal to the implementer's) |
| fix (law + § qselPkgParamOnly261v) | 1e68cb111860d0083e3b95fcccaa540a |

All three link slang 12.0.0+545f88b2e. The patch applies clean on a fresh e3538174 (whitespace warnings from the CRLF
cases only). On the current HEAD 2178d427c (pass 256) the source files apply clean and only the generated
tests/LAWS.md conflicts.

## Verdict

**VERIFIED WITH ONE FIX.** Every headline number of r11u261 reproduces bit for bit. Fresh cases found one law moving
dump records away from golden on legal SV: § pkgQualSelChainOwnName261 fires on class-scoped, `$unit::`-scoped and
package-VARIABLE bases, where golden writes a ref_obj. The fix is § qselPkgParamOnly261v, behind its own switch
`R11V261_QSELPARAM_OFF`. It moves no gate database against the law: 0 of 2560 corpus, 0 of 4087 probe and 0 of 805
downstream, as predicted before its sweeps.

## Targeted rows (reproduced from the verifier's own sweeps)

| row-mode | pristine sweep | law sweep (= fix sweep) |
|---|---|---|
| Earlgrey_0_1 default | `STRICT_NOTEQUAL,differ:fullname(117)`, head #136315 | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(74),,differ:fullname(74)`, head #233633 |
| Earlgrey_0_1 testflags | `STRICT_NOTEQUAL,differ:fullname(24)`, head #137760 | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(4),,differ:fullname(4)`, head #216212 |

The old head (evidence/earlgrey_default_P.txt) is `#136315 fullname A: ref_typespec work@sha2 / B: ref_typespec
<none>`. The new heads (evidence/earlgrey_*_L.txt):
- default `#233633 A: ref_typespec work@rstmgr_ctrl / B: work@rstmgr_ctrl.rst_req_i`.
- testflags `#216212 A: ref_obj DataWidth prim_cipher_pkg::PRINCE_ROUND_CONST::...::DataWidth / B:
  work@prim_prince.p_pre_round_xor.prim_cipher_pkg::PRINCE_ROUND_CONST...DataWidth`.

Both new heads are on the expression ground. Every record the law sweep lists is also a pristine record, with the
same id and field (no new record in either mode).

## Gates (reproduced)

1. **Builds**: md5s as above. Binary-path audit over fence-filtered cmds.txt: each of the pristine, law and fix sweeps
   has 3265 of 3315 files naming its own frozen binary and 0 naming another. The other 50 carry no slang line.
2. **Probe**: pristine `EQUAL=3565 STRICT_NOTEQUAL=522` with regressions=0 conversions=0 changes=0. Law and fix both
   read `EQUAL=3566 STRICT_NOTEQUAL=521`, `regressions=0 conversions=1 changes=4`:
   - CONVERSION r10vrgg16repro/cells/v8 `fullname(4) -> EQUAL`.
   - v41v_comment `fullname(20) -> (18)`: first record #90 -> #91.
   - ue `fullname(5) -> file(3)`: #170 and #181 (ref_typespec, golden `work@ue`) are cleared. The new first record
     #341 file was pristine's third record and is unchanged.
   - m_gen108 `line(6) -> (3)` and v4_nestinst `line(4) -> (2)`: first records #931 and #255 unchanged.
3. **Corpora**: surelog `regressions=0 conversions=0 changes=2` (the Earlgrey rows). uhdm2rtlil 0/0/0 with 1606 + 0.
   The pristine sweep reproduces the baseline in all three stages. Row by row, the law csvs differ from pristine's
   only in the two Earlgrey rows and the five probe cases above; the LowMem SURELOG_FAIL detail text is a workdir
   path. The fix csvs equal the law csvs row for row.
4. **Downstream**: law and fix both read `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)`. The verdict diff is 0
   against the baseline and 0 fix vs law. The 805 slang-lane databases are byte-identical between fix and law. Each
   sweep exits 1 only on the law-index check, because this README's cases existed before the index was regenerated.
5. **uhdm-cmp**: 0 lines on both Earlgrey row-modes and on all five probe movers (judge status kept).
6. **byteverify** over fence-filtered hard-link mirrors (2560 databases, SELFCHECK 2559/2560, PATH_SETS_IDENTICAL):
   - Law vs pristine: MOVERS 14/2560. These are Earlgrey d/t, Rggen d, genscope_module_ctx_reset d/t, BuildUVMPkg
     d/t, Scoreboard d, SimpleUVM d/t, MiniAmiq d/t and SeqDriver d/t, exactly the implementer's 14.
   - Probe (both runs from one worktree): 72/4087 movers.
   - Every mover is named by the firing census. The verifier's own census (drivers/tracecensus.sh, law binary under
     R11U261_TRACE, fence filter) is identical line for line to r11u261's frozen evidence/predict_frozen.txt (545
     lines).
   - Fix vs law: 0/2560 corpus and 0/4087 probe.
7. **Away census**:
   - Chain-keyed (drivers/awaychain.py with strictcmp_x) on all 14 corpus movers: away=0 everywhere. Earlgrey d
     toward=70 and t toward=58; Rggen d toward=1; the order-only movers 0/0.
   - Flat: 1 lost on each Earlgrey mode, the all-zero empty ref_typespec the implementer explained.
8. **Canaries** (from the base's results/): surelog ok=50 changed=2 (Earlgrey d/t), uhdm2rtlil ok=16 changed=0. Both
   ctcan2 checks PASS, for the law and the fix.
9. **Determinism**:
   - Three concurrent harness draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and
     BuildUVMPkg give one hash each for both the law and the fix, equal to the law sweep's hashes. Scoreboard
     testflags has no database, as at the base.
   - Ten concurrent draws per view on the seven grp54 probe cases (a2_twomacros, g206_a_selftd, t47a, t47b,
     g97_a1_selftd, v97_c8_counts, vb32s1) give one hash each with the fix.

## The implementer's grid and the byte controls

- **Grid**: the implementer's 59 case and decode dirs and the verifier's 59 dirs, in both views on P / L / F / FOFF /
  FUOFF / F with `R11V261_QSELPARAM_OFF` (1416 lines, every rc=0; evidence/grid_fix.txt, gridsum_fix.txt).
  - Of 236 case-views, the law moves 138 (94 entering STRICT_EQUAL, none leaving) and the fix moves 134 against
    pristine (94 entering, none leaving).
  - R11U261_OFF on the fix gives pristine's bytes, and R11V261_OFF gives the law's bytes, on 236 of 236.
- **Byte controls**: the implementer's 26 repro dirs widened by 12 (r11u124, r11v124, r11u125, r11u130, r11u131,
  r11v131, r11v120, r11v125, r11v130, r11u160, r11u164, r11u168): 5532 case-views on P / L / F
  (evidence/controls_summary.txt).
  - The law moves 22 and 4 enter STRICT_EQUAL: r11u254 G/g01 and r11u255 decode/A/a03, both views. None leave.
  - The other movers: the implementer's 20, plus r11v120 T/t06_genif_named in both views (GENBIRTH, STRICT_EQUAL on
    both).
  - No exit code and no uhdm-cmp line count changes. Fix vs law: 0 movers.
  - The away census reads 0 lost on all 22 (evidence/away_controls.txt).

## Fresh cases (cases/, each first line names its law)

59 dirs, 118 case-views. Law grid with 18 configurations per case: evidence/grid_law.txt, gridsum_law.txt. Away
census: evidence/away_grid.txt. Downstream on P / L / F: evidence/downstream_cases.txt.

- **VA, § sysArgFoldTsUnitName261** (19 dirs):
  - Entering STRICT_EQUAL in both views: va02 body import, va03 explicit import, va04 localparam type, va05 `$bits`
    and `$clog2` of a byte parameter, va06 two instances, va07 two packages / two modules, va09 module typedef
    struct, va10 task argument and local, va11 interface port, va13 top-only, va14 CRLF two files, va15 parameter
    override, va17 child in a for-generate, and va18 a macro used twice.
  - va01 (a class in a module): enters in the default view. The elaborated view keeps an unrelated class_defn full
    name record (`work@sha2::c` vs ours `work@top::u::c`).
  - Stage 1 on both binaries, with no record lost:
    - va08 for-generate: uhdm-cmp 42 -> 44 lines; golden keeps the ref_obj, the same face as r11u261 A/a06.
    - va12 a local shadowing the package name.
    - va16 a nested module declaration: 42 -> 44 lines.
- **VC, § pkgQualSelChainOwnName261** (18 dirs):
  - Entering in both views: vc06 bit last, vc09 three part selects, vc10 in a child's generate, vc11 ternary, and
    vc14 as an index.
  - vc08 (if-generate condition) moves fullname -> endcol: the remaining record #102 endcol was pristine's too.
  - vc15 (two in a concatenation) keeps fullname: residue, golden's `cp::RC::cp::RC::k`.
  - Unmoved: vc02 always_comb, vc03 function and vc05 module assign (STRICT_EQUAL on both); vc01 indexed part
    select, vc04 port actual and vc07 parameter initializer (stage 1 on both).
  - The fix's cases:
    - **vc12 class-scoped `C::RC[k][W-1:0]`, vc13 `$unit::URC[k][..]` and vc17 a package VARIABLE `cp::VR[k][3:0]`**:
      the law LOSES one golden dump line in both views (`|vpiFullName:work@top.g.C::RC`; golden writes a ref_obj
      with the chain name, which our var_select's computed name matched).
    - vc18, a re-exported package parameter `cq::RC`: the law is right there and must keep firing.
- **VD, § genChildParentAtBirth261** (12 dirs):
  - Entering: vd02 unnamed generate and vd07 a bind into a generate child (default view; their elaborated views move
    and are equal on both).
  - Unmoved and equal on both: vd03, vd04 interface-port child, vd05 case-generate always_ff, vd06 hierarchical
    reference, vd08, vd10 two generate levels, vd11 program child and vd12 struct member.
  - Wrong on both binaries: vd01 an instance array in a generate (stage 1), and vd09 the genvar reference full name
    in a child's own for-generate (`work@leaf.inner.d.j` vs ours `work@leaf.inner.j`; residue).
- **VG, § pselConnArrPathName261** (11 dirs):
  - Entering in the default view: vg01 an instance-array parent (the `[` comes from the array, not a generate),
    vg02 two generate levels and vg04 mixed bounds; vg09 package-qualified bounds and vg10 a program child in both
    views.
  - vg05 (module-parameter bounds) is stage 1 on both; the law's dump moves 12 lines toward golden.
  - Unmoved: vg03 indexed part select (stage 1 on both), vg06 struct-member base (fullname on both, residue), vg07
    genvar bounds (stage 1), vg08 concatenation actual (fullname on both), and vg11 child in the core's own
    generate.

Totals for the law vs pristine: 118 case-views, 72 moving, 48 entering STRICT_EQUAL, none leaving. R11U261_OFF gives
pristine's bytes on 118 of 118, and each mover is moved only by its own law's switch. The away census reads 0 lost on
every mover except the three QSEL shapes above (1 dump line each, both views).

Downstream on the 59 dirs: the same verdict on all three binaries, 55 IDENTICAL, 3 EQUIVALENT (va12, vc13, vd01) and
1 DIVERGENT (vc07: a package-qualified select in a parameter initializer, DIVERGENT on pristine too). The driver
reads dut.sv only, so va14's second file is not in its downstream run.

## The fix: § qselPkgParamOnly261v (TypeEmit, at § pkgQualSelChainOwnName261; switch `R11V261_QSELPARAM_OFF`)

§ pkgQualSelChainOwnName261 stores the select's own name only when the qualified base is a PACKAGE PARAMETER.

- The qualifier and member are read from the syntax tokens, so a comment inside the name, as in v41v_comment, still
  resolves.
- The base is resolved with the package's `findForImport`, so a re-exported parameter (vc18) keeps the law.
- A class-scoped, `$unit::` or package-variable base abstains. Golden writes a ref_obj for these, whose chain name our
  var_select's computed name already matched.
- `R11V261_OFF` drops the fix and gives the law's bytes; `R11U261_OFF` still gives pristine's.
- On the fix's movers it moves 6 case-views against the law (vc12, vc13 and vc17 in both views). Each has lost=0
  against pristine, and the line the law lost is restored. vc18 is equal to the law.
- Firing prediction, frozen before the fix sweeps (evidence/fix_predict_frozen.txt, md5
  cb6fcadee04fb7d586a3a9bceeea77e6): QSELNAME fires on 3 gate databases (v41v_comment and Earlgrey d/t), all on
  package parameters, so 0 movers and 0 abstentions.
- Measured: 0 / 0 / 0 database movers, 0 QSELPARAM-ABSTAIN trace lines, and 8 QSELNAME firings in the fix sweep's
  trace.
- uhdm-cmp line counts on the stage-1 cases return to pristine's (vc13 106 -> 110, vc17 84 -> 88).

## Residues, ranked (all wrong on pristine too unless stated)

1. Earlgrey_0_1 default, 74 records, and testflags, 4 records. Both are headed by the sister (expression) ground:
   - #233633 / #233638 (testflags #235310 / #235315): ExprEmit § shadowedImportParamFold.
   - #216212: ExprEmit, the `::` form on a compound assignment.
   - #403326: ExprEmit's cast-target typespec in the elaborated view.

   Pass 256, landed at 2178d427c on top of this base, clears #464077..#482968 (§ genIpsBoundOwner256 /
   § elabBodyIpsBoundSelName256) and #439105 / #439106 (§ patLitFormFileAtRef256). The integration sweep must
   re-read the composite heads.
2. Qualified select chains: as an indexed part select (vc01, stage 1), as a port actual (vc04), in a parameter
   initializer (vc07, downstream DIVERGENT on every binary), inside a concatenation (vc15: golden's
   `cp::RC::cp::RC::k`), and as a whole generate right side (r11u261 C/c02, r11u254 Q/q05, q08).
3. The `$clog2` read in a generate block (va08, r11u261 A/a06: golden keeps the ref_obj) and in a nested module
   declaration (va16).
4. A part-select actual on a struct-member base (vg06) and in a concatenation (vg08); the genvar reference full name in
   a child's own for-generate (vd09).
5. The class-defined-in-module full name in the elaborated view (va01_el: `work@sha2::c` vs `work@top::u::c`).
6. § classImportsIdOrder261 keeps pointer order between two symbols of one class_defn. The loop body reads only the
   class's location and container, which specializations share, so no byte can move there; it is recorded, not
   changed.
7. Items (2) to (7) of the brief beyond the determinism work were not attempted by the implementer.

## Process

- The verifier signalled no process. Its fix binary was refrozen twice before any gate measurement:
  - The first draft resolved the base with crossPkgBoundParam9 on vpiName, which missed v41v_comment's commented
    spellings by prediction.
  - The second draft missed the re-exported vc18 (the grid caught it: 4 records lost against the law).
  - Only the final binary's grid, controls, sweeps and census are reported.
- Every corpus path list was filtered by `$FENCED` (word boundary) before any file was opened: the byteverify mirrors,
  the cmds.txt audit, the away census, the trace reads, and the one Earlgrey source line read to confirm
  PRINCE_ROUND_CONST is a parameter.
- Nothing fenced was dispatched, read or decoded outside the gate sweeps. The evidence holds no fenced name (checked).
- Every tool call went through a `[ -x ]` guard (drivers/env.sh, case.sh). No patch file is kept in the repo.

## Files

- `src/R261.h`: `r11v261On`. `src/TypeEmit.cpp`: § qselPkgParamOnly261v.
- `cases/VA` (§ sysArgFoldTsUnitName261), `VC` (§ pkgQualSelChainOwnName261; vc12, vc13, vc17 and vc18 name
  § qselPkgParamOnly261v), `VD` (§ genChildParentAtBirth261), `VG` (§ pselConnArrPathName261).
- `drivers/`: r11u261's case.sh, grid.sh, away tools, tracecensus.sh, det.sh, nondet.sh and dscases.py, plus
  gridF.sh and controlsF.sh (P / L / F).
- `evidence/`: grids, controls, away censuses, both predictions, byteverify, determinism, downstream on the cases,
  sweep summaries, Earlgrey records.
