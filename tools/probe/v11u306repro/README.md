# v11u306 — adversarial verification of r11u306 (pass 306, expression/parameter ground)

Verdict: **ACCEPT, no production fix.** Every headline number of r11u306 reproduces bit for bit, and 119 fresh
case dirs (238 case-views) found no case on legal SystemVerilog where pristine was right and the law wrong. The
verified patch is the implementer's production surface unchanged (src/ExprEmit.cpp, src/ParamEmit.cpp), plus
this directory and the regenerated tests/LAWS.md.

Base cee373de. Worktrees /tmp/wt_v11u306pris (pristine) and /tmp/wt_v11u306 (the r11u306 patch, applied cleanly
with `git apply`; the whitespace warnings come from tab-separated records in r11u306repro/evidence only). Both
were built with -j 2 and the system-deps config, and frozen with chmod 555 before any measurement:
pristine 2c0499bc5c68c49e3a4606a43bfefe37 (the md5 the brief names), law 0e7063a2ae2f7df48f364754d9b10c7a
(equal to the implementer's law build). Both report slang 12.0.0+545f88b2e.

## The laws under test (src/ExprEmit.cpp; switches read through src/LawSwitch.h)

- § nonTrailIdxPathNestShape306 (`R11U306_NESTSHAPE_OFF`): a member path in a non-trailing select's index takes
  Surelog's nested-path shape. The base ref sits on the first member's token, a leaf reference stores no full
  name, a leaf member select spans from its member name to its bracket and is named by its final chain, and a
  member part select carries its member name as its definition name.
- § nonTrailSelNestedSelWhole306 (`R11U306_BARESEL_OFF`): a select nested in a bare select that indexes a
  non-trailing select spans its whole select (pass 304's walker; `R11U304_NESTSEL_OFF` silences it too,
  confirmed on NB/nb01: law+R11U304_NESTSEL_OFF has pristine's bytes).
- § varSelIdxHpLeafByPath306 (`R11U306_VSHPLEAF_OFF`): a member path below a var_select in a trailing index names
  its leaf through the var_select's path-derived name.
- `R11U306_OFF` drops all three. No src/R*.h is added, no getenv or reader of its own, and the state is static in
  ExprEmit.cpp. Code read: the new `hier_path` case in trailIdxNestedNames187's walk returns in every branch, and
  before the patch the walk's `default:` also returned, so it is byte-neutral when it does not fire. Emission is
  single-threaded (no std::thread in src), so the static leaf vector is safe.

## Reproduction (bit for bit)

- **Implementer's grid** (drivers/gridall.sh with `CASEDIR=` on r11u306repro/cases; my binaries):
  - 936 of 936 lines match r11u306repro/evidence/grid.txt on case, view, label, exit code, uhdm-cmp count and
    strict verdict. Database md5s differ only because each database embeds its worktree path.
  - 156 case-views: 116 movers, 84 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.
  - 2 uhdm-cmp changes, both np42_extern.
  - `R11U306_OFF` equals pristine on 156 of 156.
  - Single-switch attribution: NESTSHAPE 68, VSHPLEAF 30, BARESEL 18.
  - Evidence: evidence/grid_r11u306_reproduced*.txt.
- **Gate sweeps** (`tests/sweep.sh --jobs 3`, one at a time; evidence/sweep_*_summary.txt, gates.txt):

  | stage | pristine sweep | law sweep |
  |---|---|---|
  | probe | 4015 + 72 | 4017 + 70: regressions 0, conversions 2, changes 0 |
  | surelog | 480 + 0 / 474 + 0, 0/0/0 | 480 + 0 / 474 + 0, 0/0/0 |
  | uhdm2rtlil | 803/1/67 both modes, 0/0/0 | 803/1/67 both modes, 0/0/0 |
  | downstream | 803/66/2/0 | 803/66/2/0 |

  - Both downstream csvs are byte-identical to results/downstream_uhdm2rtlil.csv.
  - The surelog csvs differ only in the LowMem detail text (the workdir path), so every corpus strict column is
    unchanged.
  - The law sweep exits 1 on the law-index check alone (this directory's cases were new until law_index.py ran).
  - Fresh rows:
    - `r10uvm79repro/c2_idxkind,EQUAL,,equal` (was `differ:col(3)`)
    - `r10uvm92repro/v92_b2_varsel,EQUAL,,equal` (was `differ:fullname(1)`)
- **Firing census** (drivers/tracecensus.sh on the law binary, run and frozen before the law sweep;
  evidence/predict.txt):
  - Exactly the two probe databases, with `c2_idxkind BARESEL:1 NESTSHAPE:1 NESTSHAPE_LEAFSEL:1` and
    `v92_b2_varsel VSHPLEAF:1`.
  - No line on any corpus row-mode (1588 surelog and 1742 uhdm2rtlil row-modes, fence-filtered).
  - Positive control: MiniAmiq default through the harness with R11U296_TRACE set writes 16 PKGFNCLONEIDX lines
    (evidence/census_poscontrol_trace.txt).
- **byteverify** on fence-filtered mirrors (7452 mirrored, 8 fenced skipped):
  - 0 of 3365 corpus and downstream databases move.
  - Probe databases: 2 of 4087 move, exactly the two predicted. The pristine probe stage was rerun from the law
    worktree, because a probe database embeds the case's absolute path. The cross-worktree compare, which flags
    hundreds of files, is the negative control.
  - SELFCHECK 3363 of 3365. The reference file (first sorted path, downstream/1DUnpackedArray/slang.uhdm) is
    byte-identical to uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm. Those two files are the unflagged
    pair, and every other file is flagged. The script prints SELFCHECK_FAILED only because its threshold of
    `na - 1` leaves no room for a twin of the reference. This is the same artifact passes 201 and 304 recorded.
- **Other gates:**
  - Canaries: surelog ok=52, uhdm2rtlil ok=16.
  - ctcan2 PASS on both csvs (EXPECT_UNKNOWN 1 and 6, with the r11u107repro and r10uvm67repro scripts).
  - Binary audit: own 3265, other 0, noslang 50 on each sweep.
- **Determinism** (three concurrent draws, evidence/determinism.txt): one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, each equal to the law sweep's database.
- **Firing scan** (drivers/firescan.sh over 30668 fence-filtered dut.sv dirs):
  - 180 dirs fire, of which 36 come from earlier passes. This is the same set as r11u306's control_trigger_dirs,
    compared path for path.
  - One crash: v11u112repro m07_hdr_enum_default, exit 139 on pristine too (measured).
- **Controls:**
  - Trigger controls: 72 case-views, 32 moving, 12 entering STRICT_EQUAL, 0 leaving, no exit-code or uhdm-cmp
    change.
  - Standard controls over r11u118, r11v11u118, r11u119, r11u120, r11u124, r11u131, r11u178, r11u184, r11u304,
    v11u304, r11u296 and v11u296: 1908 case-views, 4 moving (r11u178 m07_idx_kinds d/e entering STRICT_EQUAL,
    m11_first_kinds d/e at stage 1 on both), 0 leaving.
  - Chain-keyed away census on all 36 control movers: away 0, 116 records toward golden (evidence/controls_*).

## Attack (cases/, 119 dirs, 238 case-views; drivers/gridall.sh; evidence/grid_fresh*.txt)

Five labels per case-view: pristine, law, law+R11U306_OFF and law with each law switch off. Every line carries
its exit code. Each case's first line names its law.

- **Grid totals:**
  - 170 movers, 127 entering STRICT_EQUAL, **0 leaving**, 0 exit-code changes.
  - `R11U306_OFF` equals pristine on 238 of 238.
  - Every mover is restored to pristine's bytes by exactly one switch: NESTSHAPE 116, BARESEL 28, VSHPLEAF 26.
- **Away census** (drivers/awaygrid.sh, chain-keyed): chain away 0 and flat away 0 on all 170 movers, with 412
  records toward golden. Positive control with the binaries swapped: away on 12 of 12 sampled movers
  (evidence/away_poscontrol.txt).
- **uhdm-cmp line changes**, all at stage 1 on both binaries, with no golden counterpart for the moved objects:
  - vn40_extbelow 588 -> 586 and 608 -> 606.
  - VE ve03_super 110 -> 108 and 138 -> 136: golden erases the select of `super.iarr[h.k].f` entirely.
  - ve12_taskref 268 -> 266 and 308 -> 306.
- **Downstream** (drivers/dscases.py, both lanes): all 34 module-scope case dirs IDENTICAL on both binaries
  (evidence/downstream_cases.txt).
- **What the attack covers:**
  - Contexts: casts, inside, multiplication, fork, assertions, conditions, case, for, return, `+=`, `<=`, `++`.
  - Collections: assoc, queue and dynamic arrays.
  - Bases: static members, const properties, function and task-ref formals shadowing a property, virtual
    interfaces, derived classes, two non-trailing selects.
  - Module scope: package variables, struct localparams, packed unions, unpacked structs, port connections,
    always_ff, module functions, input struct ports, process lvalues, multi-dimensional bases, interface ports,
    interface bodies, implicit nets, depth-3 instances with two instances of the leaf, if-generate.
  - Macros: macro-born tokens from the same file and from an include.
  - Selects: indexed part-select leaves, escaped member names.
  - BARESEL: part, indexed and element selects, both conditional branches, call and system-call arguments,
    unary, concatenation, parentheses, packed bases, a middle member, ports, a struct-localparam index, macros.
  - VSHPLEAF: first dimension, deep paths, leaf selects, `this.`, operations, calls, three dimensions, int arrays,
    module processes and ports, two paths, conditions, a middle select, macros, ternaries, and the elaborated
    package class.

| case | law | default view (pristine -> law) | elaborated view (pristine -> law) |
|---|---|---|---|
| VB/vb01_partsel | § nonTrailSelNestedSelWhole306 | STRICT_EQUAL/145 -> STRICT_EQUAL/145 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb02_twoop | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb03_terntrue | § nonTrailSelNestedSelWhole306 | STRICT_EQUAL/147 -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb04_tern_false | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb05_callarg | § nonTrailSelNestedSelWhole306 | STRICT_EQUAL/145 -> STRICT_EQUAL/145 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb06_path | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/146 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb07_syscall | § nonTrailSelNestedSelWhole306 | STRICT_EQUAL/325 -> STRICT_EQUAL/325 | STRICT_EQUAL/329 -> STRICT_EQUAL/329 |
| VB/vb08_both | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb09_lvop | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/146 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb10_modcomb | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/329 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/336 |
| VB/vb11_unary | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/145 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb12_macro | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb13_ips | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb14_portconn | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/fullname | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/fullname |
| VB/vb15_elemsel | § nonTrailSelNestedSelWhole306 | STRICT_EQUAL/329 -> STRICT_EQUAL/329 | STRICT_EQUAL/333 -> STRICT_EQUAL/333 |
| VB/vb16_macroinner | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb17_ffnb | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/331 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/335 |
| VB/vb18_param | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/377 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/382 |
| VB/vb19_concat | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/145 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VB/vb20_ternouter | § nonTrailSelNestedSelWhole306 | STRICT_EQUAL/147 -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VD/vd01_depth3 | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/649 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/624 |
| VD/vd02_nestedpath | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col |
| VD/vd03_ipsleafmod | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/defname | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/defname |
| VD/vd04_ipsleafcls | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/defname | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/defname |
| VD/vd05_concatleaf | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/154 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/171 |
| VD/vd06_pluseq | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/150 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/167 |
| VD/vd07_foreach | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/152 -> STRICT_EQUAL/152 | STRICT_EQUAL/163 -> STRICT_EQUAL/163 |
| VD/vd08_randomize | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/144 -> STRICT_EQUAL/144 | STRICT_EQUAL/144 -> STRICT_EQUAL/144 |
| VD/vd09_constraint | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/26 -> STRICT_EQUAL/26 | STRICT_EQUAL/26 -> STRICT_EQUAL/26 |
| VD/vd10_cover | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/310 -> STRICT_EQUAL/310 | STRICT_EQUAL/310 -> STRICT_EQUAL/310 |
| VD/vd11_assertprop | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/314 -> STRICT_EQUAL/314 | STRICT_EQUAL/313 -> STRICT_EQUAL/313 |
| VD/vd12_static | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/150 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/167 |
| VD/vd13_twononTrail | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/165 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VD/vd14_twononTrailNS | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/165 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/190 |
| VD/vd15_pkgfn | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VD/vd16_shadowarg | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/157 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/171 |
| VD/vd17_escaped | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col |
| VD/vd18_twoinst_genif | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VD/vd19_nb_class | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/150 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/167 |
| VD/vd20_bitofleaf | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VD/vd21_nestvs | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/148 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/151 |
| VD/vd22_vsmodlv | § varSelIdxHpLeafByPath306 | STRICT_EQUAL/323 -> STRICT_EQUAL/323 | STRICT_EQUAL/329 -> STRICT_EQUAL/329 |
| VD/vd23_vselab | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/167 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/170 |
| VD/vd24_bsparenthesis | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/150 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VD/vd25_bsmidmember | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/151 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VE/ve01_pkgscoped | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve02_staticarr | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/157 -> STRICT_EQUAL/157 | STRICT_EQUAL/157 -> STRICT_EQUAL/157 |
| VE/ve03_super | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve04_ifcinst | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve05_upref | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve06_downref | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve07_nestedcondfalse | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/150 -> STRICT_EQUAL/150 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VE/ve08_inside | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/164 |
| VE/ve09_ifcarr_param | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve10_clslp | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve11_constprop | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/148 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/165 |
| VE/ve12_taskref | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve13_vsmidsel | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/160 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/163 |
| VE/ve14_bspacked | § nonTrailSelNestedSelWhole306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/153 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VE/ve15_widemod | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VE/ve17_fork | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/145 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/162 |
| VE/ve18_mult | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/149 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/169 |
| VN/vn01_cast | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VN/vn02_trailsel | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/145 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/167 |
| VN/vn03_twice | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/151 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/171 |
| VN/vn04_ifcond | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/148 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/165 |
| VN/vn05_paren | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/144 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/161 |
| VN/vn06_deep | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/146 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/163 |
| VN/vn07_postinc | § nonTrailIdxPathNestShape306 | STRICT_EQUAL/138 -> STRICT_EQUAL/138 | STRICT_EQUAL/138 -> STRICT_EQUAL/138 |
| VN/vn08_midsel | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col |
| VN/vn09_forcond | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/154 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/171 |
| VN/vn10_case | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/152 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/169 |
| VN/vn11_bothidx | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/169 |
| VN/vn12_assoc | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/144 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/161 |
| VN/vn13_queue | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/144 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/159 |
| VN/vn14_dyn | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/144 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/159 |
| VN/vn15_method | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col | STRICT_NOTEQUAL/col -> STRICT_NOTEQUAL/col |
| VN/vn16_assert | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/145 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/162 |
| VN/vn17_deepouter | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/156 |
| VN/vn18_selidxsel | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VN/vn19_condop | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/164 |
| VN/vn20_return | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/146 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/163 |
| VN/vn21_pkgvar | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VN/vn22_structparam | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/412 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/423 |
| VN/vn23_union | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/365 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/376 |
| VN/vn24_portconn | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/342 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/354 |
| VN/vn25_ffnb | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/335 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/345 |
| VN/vn26_modfn | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/460 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/453 |
| VN/vn27_partsel | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VN/vn28_unpackedst | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/347 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/358 |
| VN/vn29_macro | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/322 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/333 |
| VN/vn30_macropath | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/322 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/333 |
| VN/vn31_clsmacro | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/144 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/161 |
| VN/vn32_derived | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/152 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/161 |
| VN/vn33_inport | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/397 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/408 |
| VN/vn34_lvca | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/328 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/339 |
| VN/vn35_multidim | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/377 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/423 |
| VN/vn36_ifacepath | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VN/vn37_vif | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/152 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/164 |
| VN/vn38_alwaysif | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/348 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/365 |
| VN/vn39_includemacro | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/340 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/350 |
| VN/vn40_extbelow | § nonTrailIdxPathNestShape306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VN/vn41_ifacebody | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/endline -> STRICT_NOTEQUAL/endline | STRICT_NOTEQUAL/endline -> STRICT_NOTEQUAL/endline |
| VN/vn42_implicit | § nonTrailIdxPathNestShape306 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/355 | STRICT_NOTEQUAL/col -> STRICT_EQUAL/366 |
| VV/vv01_firstdim | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/150 |
| VV/vv02_deeppath | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/148 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/154 |
| VV/vv03_leafsel | § varSelIdxHpLeafByPath306 | STRICT_EQUAL/148 -> STRICT_EQUAL/148 | STRICT_EQUAL/151 -> STRICT_EQUAL/151 |
| VV/vv04_this | § varSelIdxHpLeafByPath306 | STRICT_EQUAL/145 -> STRICT_EQUAL/145 | STRICT_EQUAL/148 -> STRICT_EQUAL/148 |
| VV/vv05_op | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VV/vv06_call | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |
| VV/vv07_three | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/148 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/151 |
| VV/vv08_intarr | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/150 |
| VV/vv09_mod | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/328 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/342 |
| VV/vv10_modport | § varSelIdxHpLeafByPath306 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 | NOT_EQUAL/stage1 -> NOT_EQUAL/stage1 |
| VV/vv11_bothpaths | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/150 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/153 |
| VV/vv12_cond | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/151 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/154 |
| VV/vv13_deepouter | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/148 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/154 |
| VV/vv14_macro | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/147 | STRICT_NOTEQUAL/fullname -> STRICT_EQUAL/150 |
| VV/vv15_tern | § varSelIdxHpLeafByPath306 | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname | STRICT_NOTEQUAL/fullname -> STRICT_NOTEQUAL/fullname |

## Residues (ranked; all wrong on pristine too, none moved away)

1. **The elaborated view of a class method** names a non-trailing select's index objects through the outer
   bit_select (golden `...::f::iarr::midx::i`, ours `...::f::midx::i`). Cases: VB vb02, vb04, vb06, vb08, vb09,
   vb11, vb19 e, VD vd13, vd24, vd25 e, VE ve07, ve14 e. This confirms r11u306's residue 1 as the next law on this
   ground. The col faces are already fixed there, which is why those views move with neither toward nor away
   records.
2. **An indexed part-select leaf** (`sa[t.idx[i +: 1]].f`, `iarr[h.v[i +: 2]].f`; VD vd03, vd04): golden gives
   the indexed_part_select the member name as its definition name and names it by its chain
   (`work@top.sa[].f.t.idx[i+:1].idx`). The law moves the base (col -> defname, 1 or 2 records toward) but its
   `leafRange306` branch handles only `part_select`. Extending that branch and the drain to
   `indexed_part_select` is the transcription.
3. **A cast in a non-trailing index** (`iarr[int'(h.k)].f`, VN vn01): the nested shape is right inside the cast,
   which converts 2 records, but the cast's ref_typespec full name reads `work@grid::probe` where golden has
   `work@grid::probe::iarr[].f`. This is the non-trailing twin of § castTsInPathIdxByChain296.
4. **Port connection, bare select** (`.a(sa[m[m[i]]].f)`, VB vb14): the bare select's own name in the second
   listing reads `work@top.sa[].f.m` where golden has `work@top.u1.a.sa[].f.m`. This is the bare-select twin of
   § hcTrailIdxNamesByPortChain296. vb14 moved col -> fullname, toward only.
5. **An escaped member name** (`iarr[h.\kk ].f`, VD vd17): golden places both refs at 9:16-24. The law moves the
   base from one wrong span to another (toward 0, away 0, chain-key census) and clears the full name. This is the
   escaped-name family of § escBlockNameSpanTrailSpace286.
6. **Macro-born bare selects** (VB vb12, vb16): col on both binaries, because pass 304's walker abstains on macro
   spans.
7. **Stage 1 on both binaries:** VN vn18 (a member path in a leaf select's index), vn21 (a package-variable
   base), vn27, vn36 (an interface-port base), vn40 (an extern body below the caller); VV vv10; VD vd15 (a package
   function), vd18 (if-generate), vd20; VE ve01 (a package-scoped array), ve03 (super), ve04 (an interface
   instance's member array), ve05 and ve06 (upward and downward hierarchical references), ve09 (an interface
   array with a struct-parameter index), ve10 (a class struct localparam), ve12 (a task ref formal), ve15.
8. **Sister ground (reported, not written):** VN vn41 (an interface body) at endline on both binaries is the
   struct typespec end stretched to the use site (TypeEmit), as r11u306's np39 found.

Every residue of r11u306's README stands as measured there (the nested-select shapes, VH h11, h06, and the 70
probe residues and their sister-ground classification).

## Process

- Drivers were copied from r11u306repro/drivers, with scratch renamed to /tmp/v11u306_*. gridall.sh gains a
  `CASEDIR=` override so the same driver runs the implementer's cases. Every driver reads $FENCED fail-closed
  from tools/probe/r11u107repro/canaudit.sh (four names). Every corpus or probe path list is built and filtered
  before any file is opened, and byteverify ran on fence-filtered mirrors.
- SLIP, no effect: the comment line the copy prepended to strictcmp_x.cpp was a `#` line and broke its first
  compile. It was fixed to `//` and rebuilt before any use (r11u306 reported the same slip).
- Three first drafts of fresh cases were not legal SV (a package reading a $unit typedef, a continuous
  assignment with a variable index, an unconnected interface port on the top module), and one round-3 draft used
  a streaming concatenation as an index. All four were rewritten or dropped before any measurement counted.
- I touched no other agent's process or worktree, did not write the main tree, and listed no other pass's
  command lines. No patch file is kept in this directory.
