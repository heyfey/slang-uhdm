# r11u306 — pass 306, expression/parameter ground: the member path in a non-trailing select's index, the select nested in a bare select index, the member path below a var_select index

Pair A, refill after pass 304. Base cee373de (the shared-header cleanup on top of pass 307). Production
surface: src/ExprEmit.cpp (the three laws, their state static in the file) and src/ParamEmit.cpp (one
declaration and one call in the drain list); no src/R*.h, nothing in src/LawState.h (the state is static
in ExprEmit.cpp), every switch read through src/LawSwitch.h (`lawOn(306, ...)`, `lawTrace(306, ...)`).
Pristine build md5 2c0499bc5c68c49e3a4606a43bfefe37 (equal to the main tree's build/slang-uhdm at the base);
law build md5 0e7063a2ae2f7df48f364754d9b10c7a. Both binaries were frozen (chmod 555) before any
measurement; every cmds.txt of both sweeps names its own binary (evidence/gates.txt). Both report slang
12.0.0+545f88b2e.

## Verdict

- **TWO PROBE CONVERSIONS**, each predicted by name in the firing census frozen before the law sweep
  (evidence/predict.txt), uhdm-cmp 0 lines before and after; the fresh law-sweep rows:
  - `r10uvm79repro/c2_idxkind,EQUAL,,equal` (was `differ:col(3)`) — § nonTrailSelNestedSelWhole306 (its d2
    face `iarr[midx[midx[i]]].f`) with § nonTrailIdxPathNestShape306 (its d6 face `iarr[h.idx[i]].f`)
  - `r10uvm92repro/v92_b2_varsel,EQUAL,,equal` (was `differ:fullname(1)`) — § varSelIdxHpLeafByPath306 (its
    p16 face `bb.bin[n + two_d[1][bb.q]]`)
- **No probe change otherwise, no regression:** probe 4017 EQUAL + 70 STRICT_NOTEQUAL against the base's
  4015 + 72, regressions 0, conversions 2, changes 0.
- **No corpus row moves:** surelog default 480 + 0 and testflags 474 + 0, uhdm2rtlil 803/1/67 in both modes,
  regressions 0 / conversions 0 / changes 0 in both corpora; byteverify reads 0 of 3365 corpus and
  downstream-lane databases moving, and exactly the 2 predicted of 4087 probe databases. Every Surelog row-mode
  stays CMP_EQUAL (954 of 954); stamped_gen_param d/t stays CMP_NOTEQUAL as at the base. The firing census
  found no firing and no abstention on any corpus row-mode.
- **Downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, the law csv byte-identical to
  results/downstream_uhdm2rtlil.csv and to the pristine sweep's.
- **Outside the gate:** 84 of this pass's 156 grid case-views and 12 earlier tools/probe case-views (trigger
  controls) enter STRICT_EQUAL, none leaves, chain away 0 on every mover.

## The laws (src/ExprEmit.cpp)

`R11U306_OFF` drops all three and gives pristine's bytes and exit code on 156 of 156 grid case-views.
`R11U306_TRACE=<dir>` logs every firing (`<TAG> <detail>`) and abstention (`<TAG>_ABSTAIN <reason>`, `<TAG>_OFF`)
into `<dir>/<pid>.306`, its first line `OUT <-o path>`.

### § nonTrailIdxPathNestShape306 — `R11U306_NESTSHAPE_OFF` (a wrapper at emitExpr's entry; the leaf names in `nestShapeDrain306`, called at the end of ParamEmit's drain list after `castTsInPathIdxDrain296`)

A member path written in the index of a NON-TRAILING select of a path (`r = iarr[h.k].f`, `r = iarr[h.idx[i]].f`,
`r = h.arr[hd.k].f`, `iarr[h.k].f = 3`, `assign r = sa[t.k].f`, `always_comb r = sa[t.k].g[t.j]`, a task, an
instance's body, an interface body, a streaming lvalue, a class in a package, a virtual method) takes the
NESTED-PATH SHAPE in golden. Surelog compiles the select of a path element that further members follow through
`CompileHelper::compileSelectExpression` (third_party/Surelog/src/DesignCompile/CompileExpression.cpp), whose
index reaches the Select-grammar branch (the `slStringConst` / `paPs_or_hierarchical_identifier` branch): the base
`ref_obj` is populated from the FIRST MEMBER's node (`fC->populateCoreMembers(Bit_select, Bit_select, r1)`), a
member reference gets a name only, and a member select is built from its member name to its closing bracket.
Golden (grid NP np02) `h` 7:16-17 on the token `k` (ours 7:14-15 on `h`), `k` with no full name (ours
`work@grid::probe::iarr[].f::k`, the name § hpSelIdxPathTrailByChain244 derives for a TRAILING select's index);
np12 `t.idx[1]`: `t` 6:19-22 on `idx`, the bit_select `idx` 6:19-25 named through its final chain
`work@top.sa[].f.t.idx[1].idx` (ours 6:23-24, `work@top.sa[].f.sa.t.idx[1].idx`); np27 `t.k[1:0]`: the
part_select `k` carries `k` as its definition name too. This is the shape pass 181's verifier called the
nested-path shape (§ lvIdxReadNestedKeepsLvalue181v), which our builders gave only to paths under an lvalue.

The wrapper fires when emitMixedHierPath raised its new non-trailing flag (beside § hpIdxCallNameSpan184's, for
lvalues too) and the parent climbs through operations and nested selects to the path's own bit_select; the path
is built as before (flag lowered) and then reshaped: the base on the first member's token, a leaf reference's full
name reset to its bare name design-final, a leaf member select spanned from its member name to the select's end
and named by its final parent chain design-final (UHDM ComputeFullName's walk, `chainFullName175`). It stands
aside (traced) in a conditional's TRUE branch (`iarr[i ? h.k : j].f` keeps the read shape in golden, np19, np23,
np24; the condition np21 and the false branch np22 take the nested shape: the § hpOpIdxTernTrueKeepsIdxLoc304v
twin, read from the stack the conditional branch of emitExpr raises around its true operand), in a call argument (np09, np33, np44: the climb stops at
the call), on a `this.` / `super.` base (np30), and where the built path's element count does not match the
written members. In the ELABORATED view a class method is the elaborator's clone, and golden names a leaf member
select there through the outer bit_select (np01 e `...::f::iarr::h.idx[i]::idx`): the drain keeps ours there
(trace `NESTSHAPE_LEAFSEL_ABSTAIN elab class`). Trace `NESTSHAPE <path>`, `NESTSHAPE_LEAF <name>`,
`NESTSHAPE_LEAFSEL <name>`, `NESTSHAPE_ABSTAIN ternary true branch|elems`, `NESTSHAPE_OFF switch`.

### § nonTrailSelNestedSelWhole306 — `R11U306_BARESEL_OFF` (emitMixedHierPath, the § hpOpIdxNestedSelByPath304 loop)

A select nested in a BARE select that indexes one of the path's non-trailing selects spans its whole select, at
every depth: `r = iarr[midx[midx[i]]].f` golden inner `midx` 7:19-26 named `...::f::midx::midx` (ours 7:24-25,
the index; grid NB nb01), three levels `iarr[midx[midx[midx[i]]]].f` each whole (nb02), through an operation
`iarr[midx[midx[i] + 1]].f` (nb05), a middle member's select (nb04), an lvalue (nb06), a member select after
(nb07), a module's `sa[m[m[i]]].f` in a continuous assignment and a process (nb09, nb10); the bare select itself
is already whole and a trailing select's index (`got = h.arr[midx[midx[i]]]`, nb03) is untouched. It is the same
compile as pass 304's (the path's element list), so the law reuses that law's walker with the bare select's name
as the outer name (a call argument keeping its index span, a conditional's true branch too). It fires only where
the walker can reach a select (through operations and call arguments). The walker is pass 304's: with
`R11U304_NESTSEL_OFF` this law writes nothing either. Trace `BARESEL <outer name>`, `BARESEL_OFF`.

### § varSelIdxHpLeafByPath306 — `R11U306_VSHPLEAF_OFF` (trailIdxNestedNames187's walk, a new `hier_path` case)

A member path inside a multi-level select's index below a path's trailing select (`got = bb.bin[n +
two_d[1][bb.q]]`, a class method) names its last reference through the var_select: Surelog stores no full name on
it, and ComputeFullName skips the hier_path above a ref_obj and keeps the var_select's own path-derived name, golden
`vsp::probe::probes::bb.bin[n + two_d[1][]]::bin::two_d::q`; ours kept the name the leaf got when the inner path
was built, before § trailIdxVarSelNamesByPath278 renamed the var_select (`vsp::probe::probes::two_d::q`). The
walk enters the inner path only below a var_select it entered; a path directly under the trailing select's
operations is named at its own site (unchanged). Grid VH: a whole index, the first dimension, three elements, a
call index, a nested var_select, two paths, module processes, continuous assignments, if-generate, a module
function, a package function, an lvalue in a module process and two instances, both views. Trace `VSHPLEAF
<name>`, `VSHPLEAF-OFF <name>`.

## Grid (tools/probe/r11u306repro/cases; drivers/gridall.sh; evidence/grid.txt, grid_summary.txt)

78 case dirs in both views (156 case-views), every line with its exit code, each case's first line naming its
law: VH h01-h20 § varSelIdxHpLeafByPath306, NB nb01-nb11 § nonTrailSelNestedSelWhole306 (nb03 the trailing-select
control), NP np01-np47 § nonTrailIdxPathNestShape306 (np07 the trailing-select control). Five labels per case-view: pristine, law, law+R11U306_OFF and law+each switch.

- 116 movers, 84 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 2 uhdm-cmp line changes (NP np42_extern
  d/e 528 -> 526 and 548 -> 546, stage 1 on both binaries: an out-of-block method body, golden's first difference
  elsewhere), `R11U306_OFF` equal to pristine on 156 of 156.
- Every mover restored to pristine's bytes by exactly one switch (evidence/grid_attrib.txt): NESTSHAPE 68,
  VSHPLEAF 30, BARESEL 18.
- The chain-keyed away census (drivers/awaygrid.sh, the record comparator strictcmp_x built by drivers/cc_x.sh):
  chain away 0 and flat away 0 on all 116 movers, 249 records toward golden (evidence/grid_away.txt); the positive
  control with the binaries swapped reads away on 12 of 12 sampled movers (evidence/away_poscontrol.txt).
- Downstream (drivers/dscases.py, both lanes): the 27 module-scope case dirs IDENTICAL on both binaries
  (evidence/downstream_cases_*.txt).
- The slots: part-select bound (np25), indexed part-select width (np26), replication (np27), a parameter
  initializer (np36), if-generate one and two levels (np37, np31), for-generate (np14, nb11, h15: stage 1 on
  both binaries), an implicit net (np38), an interface body (np39), a task (np40), a streaming lvalue (np32),
  inc/dec (np28), `this.` outer and inner (np29, np30), calls as indices with positional and named arguments
  (np09, np33, np44), extern and pure virtual (np42, np46), a class specialization (np43), a class in a package
  (np45), an lvalue in a module process (np47), unary and two-operand indices (np34, np35).

## Controls

- Firing scan (drivers/firescan.sh, the law binary under `R11U306_TRACE` over 30560 fence-filtered dut.sv dirs
  under tools/probe and tests/probe): 92 dirs write a trace line, 56 of them this pass's cases; one run crashed
  (v11u112repro m07_hdr_enum_default, exit 139 on pristine too). evidence/firescan.txt.
- Trigger controls: the other 36 dirs in both views (72 case-views, drivers/controls_list.sh): 32 moving, 12
  entering STRICT_EQUAL (c2_idxkind d, v92_b2_varsel d/e, r11u178 m07_idx_kinds d/e, r11v145 x16_member_in_op
  d/e, v11u244 a01_firstsel d/e and a13_cls_firstsel d/e, r11u252 x04_two_levels e), 0 leaving, no exit-code or
  uhdm-cmp change; chain away 0 on all 32 with 100 records toward golden (evidence/controls_*).
- Standard controls (drivers/controls.sh) over every dut.sv dir of r11u118, r11v11u118, r11u119, r11u120,
  r11u124, r11u131, r11u178, r11u184, r11u304 and v11u304 (1590 case-views): 4 moving (r11u178 m07_idx_kinds d/e
  entering STRICT_EQUAL, m11_first_kinds d/e at stage 1 on both), 0 leaving (evidence/controls_std_summary.txt).
- The firing census (drivers/tracecensus.sh), frozen before the law sweep: exactly the two probe databases
  (`c2_idxkind BARESEL:1 NESTSHAPE:1 NESTSHAPE_LEAFSEL:1`, `v92_b2_varsel VSHPLEAF:1`), no line on any corpus
  row-mode; the positive control (evidence/census_poscontrol.txt) runs MiniAmiq default through the harness with
  pass 296's trace switch beside this one: 16 PKGFNCLONEIDX lines, none of this pass's.

## Gates (evidence/gates.txt, sweep_P.log, sweep_L.log)

Both sweeps `tests/sweep.sh --jobs 3` from the worktree with SLANG_UHDM exported (each exits 1 on the law-index
check alone: this pass's cases are new until scripts/law_index.py runs).

- probe: pristine 4015 + 72 with regressions 0; law 4017 + 70, regressions 0, conversions 2, changes 0.
- surelog: 480 + 0 / 474 + 0 on both, regressions 0, conversions 0, changes 0.
- uhdm2rtlil: 803/1/67 in both modes on both, regressions 0, conversions 0, changes 0.
- downstream: 803/66/2/0 on both, the csvs byte-identical to the committed one.
- byteverify on fence-filtered mirrors (drivers/mirror.sh; the four fenced tests' databases never linked):
  0 of 3365 corpus and downstream-lane databases moving; SELFCHECK 3363 of 3365 flagged — the reference is the
  first sorted path, downstream/1DUnpackedArray/slang.uhdm, which is byte-identical to its twin
  uhdm2rtlil/testflags/1DUnpackedArray-*/slang.uhdm, so the reference and the twin are the two unflagged
  files (the comparator works: every other file is flagged). Probe databases: 2 of 4087 moving, the 2 predicted.
- canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both.
- binary-path audit: pristine sweep own 3265 other 0 (50 cmds.txt run no slang), law sweep own 3265 other 0.
- determinism (drivers/det.sh): three concurrent draws per row-mode of Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes read one hash each, equal to the law sweep's
  (evidence/determinism.txt; Scoreboard and Rggen testflags write no database, as at the base).

## Residues (ranked; all wrong on pristine too)

1. The elaborated view of a CLASS METHOD names the index objects of a non-trailing select through the base
   bit_select (golden `...::f::iarr::midx::i`, `...::iarr::h.idx[i]::i`, ours without `iarr`): NB nb01, nb02,
   nb04 to nb07 e, NP np01, np16, np18, np21, np22, np41 e, np19, np23, np24 e, np09, np33, np44 e. The UHDM
   elaborator's clone parents the index at the bit_select; the probe gate is the default view only. The next law
   on this ground: in the elaborated class-method clone, name the index objects of a non-trailing select through
   the bit_select (the drain's abstention is its first half).
2. A member path inside a var_select index of a non-trailing select (VH h11 `bb.bin[n + two_d[1][bb.q]].fv`):
   golden takes the nested shape there too (`bb` on `q`, `q` unnamed) and the var_select is named by the path;
   the wrapper's climb stops at the var_select.
3. The lvalue twin of § varSelIdxHpLeafByPath306 (VH h06 `bb.bin[n + two_d[1][bb.q]] = got`): the lvalue's
   trailing index is not path-named at all (`n`, the var_select and the leaf keep the scope's names), § lvSelIdxChainName181's ground.
4. Stage 1 on both binaries: a var_select index of a non-trailing select (NB nb08, NP np17), a path nested in a
   nested path's trailing index (np10), for-generate continuous assignments (np14, nb11, h15), np25/np26 (a
   member part select after the non-trailing select), np30 (`this.` inner path), np31/np37 (if-generate),
   np36 (parameter initializer), np42 (out-of-block method), np43 (class specialization).
5. NP np39: the interface body's struct typespec end stretched to the use site in golden (TypeEmit, the sister's).
6. The 70 probe residues at the base, classified by their first record's object chain
   (evidence/residue72_first_records_base.txt, tools/probe/r11u294repro/evidence/residue_writers_base.txt):
   on this ground t12 (the parameter path's parent, pass 292's withdrawn draft), r11v21repro/v15
   (§ elabParamLeftoverRefUnnamed174 in the drain), vh_arrelem (a separate typedef object per package listing),
   r11v4repro/v6, l_concat (a binding: the elaborated cont_assign's `a1` bound to the definition net), the four
   r11u109 64-bit value cases (a Surelog defect); the rest are the sister's (below).

## Sister-ground faces (reported, not written)

- TypeEmit emitSyntaxExpr from ModuleEmit emitDefGenStmts: r10earl41repro/v41v_comment (`q41::A::q41::A::g`),
  r10earl115repro/p1_pos115, r11u117repro g13, r10vrgg17repro/v8.
- ModuleEmit: r11v66repro/a3_inst66 (§ caStructParamModSharesPaOperand289's setLocCompact: golden's folded
  operand constant at `P`), r10rgg4repro/c9_litarith_noovr (fillSizeDimRange), r10earl54repro/v13_v54 (the bound
  port's binding), r10earl98repro/g3_rhs98 (the `$signed` typespec through the shadowed generate-local left side),
  r10v92repro/v5_home (bind), r10rgg3repro/f1_noovr_arr_recvp (pvFold115's int_typespec).
- TypeEmit / UhdmExporter typespec copies and their ref_typespec names: r10sd5repro/v6_no_import_control,
  r10uvm26repro/t36c, r10uvm207repro/g207_h_foreign, r10uvm226repro a12_pkgimport, r10uvm97repro
  g97_a5_samename, r10v136repro/v136_d_homes, r10v149repro/arms/paramtype, r11u47repro g2/g10/g12, r11v47repro
  v12/v28, r11u107repro t13, r11u110repro e18/i16, r11u112repro k14, r11v74repro v2_kindns, v11u108repro
  b07/b18/b21, v11u110repro k11 (makeTypespec, the `$bits(q)` fold span) and k13, v11u111repro x36/x40/y31/y62/
  y64/y65, v11u93b107repro r05, r10vearl100repro v6_more100, r10v200repro v200_5_modmat, r10buvm8repro/vxpkg8,
  r10uvm32repro/t42a, r10uvm36repro/t48a, r10v208repro/v208_f_io, r10uvm149repro homes, r10uvm129repro
  g129_d_bases, r10v206repro x206, r10v181repro v181_h_nofe.
- TaskFuncEmit / UhdmExporter import clones: r10uvm122repro g122_f_clone, r10v122repro q6clone,
  r10uvm227repro a9_class_holder, r10v194repro v194_a_explicit, r10v97repro v97_c3_twotd and v97_c9_pkganchor,
  r10v112repro g19_builtin; the macro column r11v11u8repro/v9 (UhdmExporter); ParamEmit / ModuleEmit
  r10earl59repro v59v2_earl59, v11u112repro g1k_hop_userfn, r11u23repro e05_untaken_bare_partsel,
  v11u111repro x64_two_dims_positional.

## Process

- Worktree /tmp/wt_r11u306 at cee373de, scratch /tmp/r11u306_*; built with -j 2; the pristine frozen before
  any edit, md5 equal to the main tree's. Drivers copied from tools/probe/r11u304repro/drivers (renamed); this
  pass's mirror.sh also mirrors the downstream lane's and the probe's databases.
- THE FENCE: every driver reads $FENCED fail-closed (four names) from tools/probe/r11u107repro/canaudit.sh;
  every corpus path list is filtered before any file is opened; byteverify ran on fence-filtered mirrors; the
  fence scan of this repro dir reads 0 for all four names.
- SLIPS, no effect: (1) two scratch helpers that print the 72 residue cases' first records parsed $FENCED with
  the wrong separator (fail-open); they were only ever given the 72 probe case names from
  results/golden_probe.csv, never a corpus path, and were fixed (whitespace split, four names asserted) before
  any other use. (2) Two of my own wait loops matched their own command line (a `ps | grep` pattern that the
  loop's text contained) and never ended; they were found by their /proc command lines, which name this pass,
  and stopped; no other process was touched. (3) The first firing scan was stopped (its own process group)
  after the traces were narrowed to log only real changes, its scratch removed, and rerun in full on the final
  law binary. (4) The copied drivers had lost their execute bits and the first away run failed; rerun.
  (5) The first header comment of the copied strictcmp_x.cpp broke its compile; fixed to a C++ comment.
- No patch file in this dir; the delivery /tmp/r11u306.patch is transport only.
