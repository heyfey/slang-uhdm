# v11u280 — adversarial verification of r11u280

Verifier of pass 280 (pair A, the expression/parameter ground), base c49f4f5c6. Implementer's patch: five laws in
`src/ExprEmit.cpp` and `src/ParamEmit.cpp` behind `src/R280.h` (§ hpMemVarSelRvalSpan280 `R11U280_VSRVSPAN_OFF`,
§ hpMemVarSelIdxNamesByChain280 `R11U280_VSIDXNAME_OFF`, § hpMemVarSelNamesFinal280 `R11U280_VSFINAL_OFF`,
§ pkgNetNamedTsDimEnd280 `R11U280_PKGNAMEDDIMEND_OFF`, § genLoopDirectBoundPaCopy280 `R11U280_LOOPBOUNDCOPY_OFF`;
`R11U280_OFF` drops all five), tools/probe/r11u280repro.

**Verdict: VERIFIED, no production fix.** Every headline number of the implementer reproduced bit for bit on binaries
I built myself; 84 fresh case dirs (168 case-views) found no case-view moving away from golden, no exit-code or
uhdm-cmp change and no downstream verdict change; the widened byte controls found no regression. The verified patch
is the implementer's patch plus this directory and the regenerated tests/LAWS.md; no source line is changed.

## Binaries (built in /tmp/wt_v11u280pris and /tmp/wt_v11u280, -j 2, frozen before any measurement)

- pristine `/tmp/v11u280_bin/pris.bin` md5 902d5954de344b684ebc9f7daf62e5dc (= the main tree's build/slang-uhdm and the
  implementer's pris.bin), slang 12.0.0+545f88b2e, UHDM 1.87.
- law `/tmp/v11u280_bin/law.bin` md5 479517a7c2af2dd64df98d1db915b89b (= the implementer's law.bin).
- The patch applies clean on a fresh c49f4f5c worktree; there `scripts/law_index.py --check` reads current.

## Reproduction of the implementer's numbers

| item | implementer | verifier |
|---|---|---|
| probe stage (law sweep) | 3825 EQUAL + 262, regressions 0, conversions 4, changes 5 | identical, the same 4 + 5 by name (evidence/sweep_law_summary.txt) |
| probe stage (pristine) | 3821 + 266 | identical (sweep_pristine_summary.txt) |
| surelog | 478 + 2 / 472 + 2, 0 / 0 / 0 | identical; law csv vs pristine csv: only the LowMemLib / LowMemPkg testflags detail text (the workdir path) |
| uhdm2rtlil | 803 / 1 / 67 both modes, 0 / 0 / 0 | identical; csv byte-identical to pristine's |
| downstream | 803 / 66 / 2 / 0 | identical; csv byte-identical to pristine's and to results/downstream_uhdm2rtlil.csv |
| firing census (before the law sweep) | 9 lines, all probe | my own run (drivers/tracecensus.sh): the same 9 lines, predict.txt md5 5f43eaa15a75a0b67e4842f9eff32521 equal to the implementer's |
| byteverify corpus | 0 / 2560, SELFCHECK 2559 / 2560 | identical (byteverify_corpus.txt, fence-filtered hard-link mirrors, 8 fenced paths skipped) |
| byteverify probe | 9 / 4087, the predicted 9 | identical (byteverify_probe.txt) |
| byteverify downstream | 0 / 805 | identical (byteverify_downstream.txt) |
| away census on the 9 probe movers | 0 | 0 on all 9, toward 6, 2, 6, 1, 8, 6, 12, 20, 24 (away_probe.txt) |
| canaries | ok=52 / ok=16, ctcan2 PASS | identical (canaries.txt) |
| binary audit | 3265 of 3315 per sweep | identical (binary_audit.txt) |
| determinism | one hash per row-mode | three concurrent draws: the same hashes as the implementer's, row-mode by row-mode (determinism.txt) |
| grid (65 dirs, 130 case-views, 1040 lines) | 94 moving, 69 entering, 0 leaving, R11U280_OFF 130 / 130 | identical in every rc, cmp and strict field of all 1040 lines (impl_grid_repro.txt, impl_grid_summary.txt); away 0 on all 94 (impl_grid_away.txt) |
| byte controls (22 dirs, 2656 case-views) | 16 moving, 0 entering, 0 leaving | the same 16 movers by name, 0 exit-code changes, away 0 on all 16 (controls_impl.txt, controls_movers.txt, away_controls.txt) |

SELFCHECK 2559 / 2560: byteverify's negative control compares every patched database with ONE fixed pristine file
(the first path); the patched copy of that same path is byte-identical to it when it is not a mover, so exactly one
path is not flagged. It is the self-check's construction, not a mover.

Probe byte comparison: the pristine sweep ran from the pristine worktree, whose probe databases embed its own source
paths, so a straight comparison flags all 4087; the pristine probe stage was rerun from the law worktree with the
pristine binary (csv byte-identical to the pristine sweep's, evidence/probe_pristine_rerun_from_law_worktree.txt) and
compared against the law sweep's databases.

Conversions (fresh law-sweep probe.csv rows; `results/` untouched):

    r10svs4repro/g1_thisidx,EQUAL,,equal         (base differ:col(2))
    r10uvm147repro/g147_a,EQUAL,,equal           (base differ:col(6))
    r10vearl105repro/v7_repl105,EQUAL,,equal     (base differ:fullname(8))
    r11u39repro/a1,EQUAL,,equal                  (base differ:col(6))

Changes: r10earl29repro/b1_sites col(10) -> fullname(4), r10uvm92repro/v92_b2_varsel col(2) -> fullname(1),
r11u88repro/grid/i6_ifarray endline(13) -> endcol(1), r11u88repro/grid/y2_pkgvarkind endline(21) -> endcol(1),
r11v77repro/grid/vh_arrelem endline(33) -> endline(9); every one toward golden with away 0.

## The attack (cases/, 84 case dirs, both views, drivers/grid.sh: pristine, law, law + R11U280_OFF, law + each switch)

**168 case-views, 1344 lines, every line with its exit code: 140 moving, 66 entering STRICT_EQUAL, 0 leaving, 0
exit-code changes, 0 uhdm-cmp line changes, R11U280_OFF equal to pristine on 168 / 168** (evidence/grid.txt,
grid_summary.txt). **Away census (chain-keyed, tools/probe/r11u272repro/drivers/awaychain.py over my own strictcmp_x
build, md5 equal to the implementer's): away 0 and flat away 0 on all 140 movers** (away_grid.txt); positive control
with the binaries swapped reads away 10, 7, 6 and 7 on VA/va02 d, VP/vp13 d, VL/vl05 d and VA/va14 e
(away_poscontrol.txt). Per family: VA 44 dirs, 88 case-views, 78 moving, 40 entering; VP 25 dirs, 50, 42, 20; VL 15
dirs, 30, 20, 6. Single switches: LOOPBOUNDCOPY returns 20 movers to pristine and PKGNAMEDDIMEND 42; the VA movers
need the three member-path switches together (VSRVSPAN alone 2, the literal-index case), as on the implementer's grid.
**Downstream** on all 84 dirs (drivers/dscases.py, both binaries): 76 IDENTICAL, 5 EQUIVALENT, 3 DIVERGENT on both,
the same verdict per case; the slang lane's 252 `.il`, `_nohier.il` and `_synth.v` files byte-identical between the
binaries (downstream_cases_*.txt).

Shapes (each case's first line names its law):
- VA (§ hpMemVarSelRvalSpan280, § hpMemVarSelIdxNamesByChain280, § hpMemVarSelNamesFinal280): genvar, enum constant,
  localparam, package-qualified, struct-parameter-member and function-call indices; unary, binary, ternary, part-select,
  unpacked element and cast indices; call and system-call arguments, ternary conditions, `$display`, queue method
  arguments, inside sets, casts, replications, assignment patterns; named begin blocks, for, foreach, fork, repeat,
  do-while, case selectors and items, immediate assertions, event controls and wait; always_ff left and right sides, a
  concatenation left side, a compound assignment, a genvar-indexed generate left side; tasks, static functions, a
  generate-local function, a program, a package function, class methods (static, extern below the class, a pure
  virtual prototype implemented in a derived class, nested package classes, a module-local class, `this.`); parameterized
  child instances twice, an instance array in a for-generate two levels down, port actuals in and out, an interface
  instance actual, an interface body; port, array-element, package-variable, `$unit`, hierarchical (u.z) and
  three-member roots; a last select that is a range; a macro index from an included header; a delayed continuous
  assignment and a net declaration assignment; an implicit net.
- VP (§ pkgNetNamedTsDimEnd280): a module variable, net, unpacked array and function formal using the stretched
  typedef; wildcard import; size-form and parameter dimensions; queue, associative and fixed arrays together; two
  packages with the same typedef name; an alias typedef; an initializer and a multi-line declarator; a parameter and a
  function of the typedef; the typedef in an included header and the array in an included header; a class member;
  wire, explicit var, static and const arrays, wire-then-implicit and implicit-then-var order; a union; an interface
  port; an unpacked-array typedef element; a wire array of an enum; a class-scoped typedef element; two typedefs
  interleaved; a macro-written typedef.
- VL (§ genLoopDirectBoundPaCopy280): a generate-local localparam shadowing the module's (the law is not reached), a
  generate-local replication localparam, an overridden child parameter, concatenation and hex values, if inside for
  and for inside if, comparison / reduction / negation operands, a child instantiated in a for-generate, header
  parameters with a genvar-scaled base, a case-generate select left side, an interface body, a module localparam
  shadowing an imported package parameter, an always_comb beside an assign, a class specialization's parameter as the
  width beside the bound, an implicit and a generate-local left side, and the constant slots (a replication count, a
  dimension bound, a localparam default and the select bound in one generate body).

Per case (pristine -> law; `(bytes =)`; EQ = STRICT_EQUAL; away / toward from the chain-keyed census):

| case | law(s) | result |
|---|---|---|
| VA/va01_genvar_idx | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(68) -> rc0 stage1(68), away=0 toward=8 ; e: rc0 stage1(68) -> rc0 stage1(68), away=0 toward=8 |
| VA/va02_enum_idx | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=10 ; e: rc0 col -> rc0 EQ, away=0 toward=10 |
| VA/va03_pkgqual_idx | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(128) -> rc0 stage1(128), away=0 toward=0 ; e: rc0 stage1(128) -> rc0 stage1(128), away=0 toward=0 |
| VA/va04_unary_idx | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(208) -> rc0 stage1(208), away=0 toward=4 ; e: rc0 stage1(208) -> rc0 stage1(208), away=0 toward=4 |
| VA/va05_func_arg | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=12 ; e: rc0 col -> rc0 EQ, away=0 toward=12 |
| VA/va06_named_block | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(156) -> rc0 stage1(156), away=0 toward=0 ; e: rc0 stage1(156) -> rc0 stage1(156), away=0 toward=0 |
| VA/va07_ff_lhs_rhs | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=12 ; e: rc0 col -> rc0 EQ, away=0 toward=12 |
| VA/va08_two_insts | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=6 ; e: rc0 col -> rc0 EQ, away=0 toward=9 |
| VA/va09_ternary_idx | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(264) -> rc0 stage1(264), away=0 toward=0 ; e: rc0 stage1(264) -> rc0 stage1(264), away=0 toward=0 |
| VA/va10_port_root | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=8 ; e: rc0 col -> rc0 EQ, away=0 toward=8 |
| VA/va11_arr_root | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=4 ; e: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=4 |
| VA/va12_ifgen_casegen | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(120) -> rc0 stage1(120), away=0 toward=2 ; e: rc0 stage1(120) -> rc0 stage1(120), away=0 toward=2 |
| VA/va13_task_static | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=8 ; e: rc0 col -> rc0 EQ, away=0 toward=8 |
| VA/va14_gen_inst_depth | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 fullname -> rc0 EQ, away=0 toward=7 ; e: rc0 fullname -> rc0 EQ, away=0 toward=7 |
| VA/va15_class_static | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=4 ; e: rc0 col -> rc0 EQ, away=0 toward=4 |
| VA/va16_assert | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=8 ; e: rc0 col -> rc0 EQ, away=0 toward=8 |
| VA/va17_include_macro | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=4 ; e: rc0 col -> rc0 EQ, away=0 toward=4 |
| VA/va18_program | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=6 ; e: rc0 col -> rc0 EQ, away=0 toward=6 |
| VA/va19_unpacked_member | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=8 ; e: rc0 col -> rc0 EQ, away=0 toward=8 |
| VA/va20_delay_ca | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=6 ; e: rc0 col -> rc0 EQ, away=0 toward=6 |
| VA/va21_foreach_fork | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(56) -> rc0 stage1(56), away=0 toward=8 ; e: rc0 stage1(56) -> rc0 stage1(56), away=0 toward=8 |
| VA/va22_event_ctrl | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=12 ; e: rc0 col -> rc0 EQ, away=0 toward=12 |
| VA/va23_method_arg | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=12 ; e: rc0 col -> rc0 EQ, away=0 toward=12 |
| VA/va24_cast_repl | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=12 ; e: rc0 col -> rc0 EQ, away=0 toward=12 |
| VA/va25_iface_inst_actual | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(17) -> rc0 stage1(17), away=0 toward=8 ; e: rc0 stage1(17) -> rc0 stage1(17), away=0 toward=8 |
| VA/va26_gen_lhs_ff | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(244) -> rc0 stage1(244), away=0 toward=0 ; e: rc0 stage1(224) -> rc0 stage1(224), away=0 toward=0 |
| VA/va27_class_handle_two | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=4 ; e: rc0 col -> rc0 EQ, away=0 toward=4 |
| VA/va28_repeat_while | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(138) -> rc0 stage1(138), away=0 toward=8 ; e: rc0 stage1(138) -> rc0 stage1(138), away=0 toward=8 |
| VA/va29_lhs_concat | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 fullname -> rc0 EQ, away=0 toward=8 ; e: rc0 fullname -> rc0 EQ, away=0 toward=8 |
| VA/va30_struct_param_idx | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(164) -> rc0 stage1(164), away=0 toward=0 ; e: rc0 stage1(164) -> rc0 stage1(164), away=0 toward=0 |
| VA/va31_range_last | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 EQ (bytes =) ; e: rc0 EQ (bytes =) |
| VA/va32_xmr_root | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(76) (bytes =) ; e: rc0 stage1(76) (bytes =) |
| VA/va33_pkg_root | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(94) -> rc0 stage1(94), away=0 toward=4 ; e: rc0 stage1(94) -> rc0 stage1(94), away=0 toward=4 |
| VA/va34_unit_root | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=4 ; e: rc0 col -> rc0 EQ, away=0 toward=4 |
| VA/va35_member_after_sel | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(38) (bytes =) ; e: rc0 stage1(38) (bytes =) |
| VA/va36_signed_cast_idx | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(152) -> rc0 stage1(152), away=0 toward=0 ; e: rc0 stage1(152) -> rc0 stage1(152), away=0 toward=0 |
| VA/va37_pure_virtual_named_call | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 EQ (bytes =) ; e: rc0 EQ (bytes =) |
| VA/va38_iface_body | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(36) -> rc0 stage1(36), away=0 toward=6 ; e: rc0 stage1(36) -> rc0 stage1(36), away=0 toward=6 |
| VA/va39_this_path | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 EQ (bytes =) ; e: rc0 EQ (bytes =) |
| VA/va40_out_port_actual | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(314) -> rc0 stage1(314), away=0 toward=2 ; e: rc0 stage1(314) -> rc0 stage1(314), away=0 toward=2 |
| VA/va41_genvar_lhs | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(64) -> rc0 stage1(64), away=0 toward=32 ; e: rc0 stage1(64) -> rc0 stage1(64), away=0 toward=32 |
| VA/va42_nested_hier_two | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(64) -> rc0 stage1(64), away=0 toward=6 ; e: rc0 stage1(64) -> rc0 stage1(64), away=0 toward=6 |
| VA/va43_module_class | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 col -> rc0 EQ, away=0 toward=2 ; e: rc0 col -> rc0 EQ, away=0 toward=2 |
| VA/va44_nested_pkg_class | § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280 | d: rc0 stage1(20) -> rc0 stage1(20), away=0 toward=2 ; e: rc0 stage1(20) -> rc0 stage1(20), away=0 toward=0 |
| VL/vl01_shadow_genlocal | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) (bytes =) |
| VL/vl02_override_repl | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) (bytes =) |
| VL/vl03_concat_val | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(64) (bytes =) ; e: rc0 stage1(64) (bytes =) |
| VL/vl04_if_in_for | § genLoopDirectBoundPaCopy280 | d: rc0 EQ (bytes =) ; e: rc0 EQ (bytes =) |
| VL/vl05_compare_reduce | § genLoopDirectBoundPaCopy280 | d: rc0 fullname -> rc0 EQ, away=0 toward=6 ; e: rc0 fullname -> rc0 EQ, away=0 toward=6 |
| VL/vl06_inst_in_gen | § genLoopDirectBoundPaCopy280 | d: rc0 fullname -> rc0 EQ, away=0 toward=4 ; e: rc0 fullname -> rc0 EQ, away=0 toward=4 |
| VL/vl07_param_port_repl | § genLoopDirectBoundPaCopy280 | d: rc0 fullname -> rc0 fullname, away=0 toward=4 ; e: rc0 fullname -> rc0 fullname, away=0 toward=4 |
| VL/vl08_casegen | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(69) (bytes =) ; e: rc0 stage1(69) (bytes =) |
| VL/vl09_iface_body | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(100) -> rc0 stage1(100), away=0 toward=2 ; e: rc0 stage1(100) -> rc0 stage1(100), away=0 toward=2 |
| VL/vl10_genlocal_only | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(64) -> rc0 stage1(64), away=0 toward=2 ; e: rc0 stage1(64) -> rc0 stage1(64), away=0 toward=2 |
| VL/vl11_pkg_shadow | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(50) -> rc0 stage1(50), away=0 toward=2 ; e: rc0 stage1(50) -> rc0 stage1(50), away=0 toward=2 |
| VL/vl12_always_in_gen | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=2 ; e: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=2 |
| VL/vl13_class_spec_bound | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(26) -> rc0 stage1(26), away=0 toward=4 ; e: rc0 stage1(26) -> rc0 stage1(26), away=0 toward=4 |
| VL/vl14_implicit_lhs | § genLoopDirectBoundPaCopy280 | d: rc0 fullname -> rc0 EQ, away=0 toward=2 ; e: rc0 fullname -> rc0 EQ, away=0 toward=2 |
| VL/vl15_const_slots | § genLoopDirectBoundPaCopy280 | d: rc0 stage1(36) -> rc0 stage1(36), away=0 toward=2 ; e: rc0 stage1(36) -> rc0 stage1(36), away=0 toward=2 |
| VP/vp01_module_var_use | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(58) (bytes =) ; e: rc0 stage1(17) (bytes =) |
| VP/vp02_import_wild | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=2 ; e: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=2 |
| VP/vp03_size_dim | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=8 ; e: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=8 |
| VP/vp04_assoc | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(211) -> rc0 stage1(211), away=0 toward=4 ; e: rc0 stage1(211) -> rc0 stage1(211), away=0 toward=4 |
| VP/vp05_two_pkgs_same_name | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=10 ; e: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=10 |
| VP/vp06_alias | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(78) -> rc0 stage1(78), away=0 toward=2 ; e: rc0 stage1(78) -> rc0 stage1(78), away=0 toward=2 |
| VP/vp07_init | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=4 ; e: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=4 |
| VP/vp08_param_and_net | § pkgNetNamedTsDimEnd280 | d: rc4 stage1(11) -> rc4 stage1(11), away=0 toward=9 ; e: rc4 stage1(11) -> rc4 stage1(11), away=0 toward=9 |
| VP/vp09_hdr_typedef | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=4 ; e: rc0 stage1(29) -> rc0 stage1(29), away=0 toward=4 |
| VP/vp10_class_use | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=6 ; e: rc0 endline -> rc0 EQ, away=0 toward=6 |
| VP/vp11_wire_net | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(255) -> rc0 stage1(255), away=0 toward=0 ; e: rc0 stage1(255) -> rc0 stage1(255), away=0 toward=0 |
| VP/vp12_iface_port | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(30) -> rc0 stage1(30), away=0 toward=2 ; e: rc0 stage1(30) -> rc0 stage1(30), away=0 toward=2 |
| VP/vp13_var_kw | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=7 ; e: rc0 endline -> rc0 EQ, away=0 toward=7 |
| VP/vp14_net_then_var_kw | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=9 ; e: rc0 endline -> rc0 EQ, away=0 toward=9 |
| VP/vp15_wire_then_var | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=9 ; e: rc0 endline -> rc0 EQ, away=0 toward=9 |
| VP/vp16_wire_only | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=7 ; e: rc0 endline -> rc0 EQ, away=0 toward=7 |
| VP/vp17_static_auto | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=9 ; e: rc0 endline -> rc0 EQ, away=0 toward=9 |
| VP/vp18_unpacked_td | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(22) (bytes =) ; e: rc0 stage1(22) (bytes =) |
| VP/vp19_wire_enum | § pkgNetNamedTsDimEnd280 | d: rc0 EQ (bytes =) ; e: rc0 EQ (bytes =) |
| VP/vp20_class_td | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(103) (bytes =) ; e: rc0 stage1(103) (bytes =) |
| VP/vp21_two_typedefs | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=18 ; e: rc0 endline -> rc0 EQ, away=0 toward=18 |
| VP/vp22_used_in_module_array | § pkgNetNamedTsDimEnd280 | d: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=2 ; e: rc0 stage1(58) -> rc0 stage1(58), away=0 toward=2 |
| VP/vp23_param_dim | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=7 ; e: rc0 endline -> rc0 EQ, away=0 toward=7 |
| VP/vp24_dim_in_header | § pkgNetNamedTsDimEnd280 | d: rc0 file -> rc0 EQ, away=0 toward=7 ; e: rc0 file -> rc0 EQ, away=0 toward=7 |
| VP/vp25_macro_typedef | § pkgNetNamedTsDimEnd280 | d: rc0 endline -> rc0 EQ, away=0 toward=7 ; e: rc0 endline -> rc0 EQ, away=0 toward=7 |

## Findings

1. **No break.** No case-view of the 168, of the implementer's 130, of the 5762 byte-control case-views or of the
   gate databases moves a record away from golden, changes an exit code or a uhdm-cmp line count, or changes a
   downstream verdict.
2. **Widened byte controls** (drivers/bytectl.sh, byte-only, both views, path list filtered by `$FENCED` first): 22
   repro dirs the implementer did not use (r11u264, v11u264, r11u275, v11u275, r11u270, v11u270, r11u272, v11u272,
   r11u281, v11u281, r11u279, v11u279, r11u254, v11u254, r11u244, v11u244, r11u258, v11u258, r11u252, v11u252,
   r11u105, r11u145; 1553 case dirs, 3106 case-views): 6 movers, 0 exit-code changes, away 0 on all 6
   (controls_wide.txt, controls_movers.txt, away_controls.txt): r11u264repro/cases/N/n15_gen_two_selects d / e
   fullname -> STRICT_EQUAL (toward 16; pass 264's residue `w.en[k][j]`, two element selects, now golden's through
   § hpMemVarSelIdxNamesByChain280 and § hpMemVarSelNamesFinal280), v11u279repro/cases/VB/vb10_member_read d / e col ->
   STRICT_EQUAL (toward 2; § hpMemVarSelRvalSpan280), v11u275repro/cases/VI/vi19_struct_unpacked d / e endline -> endcol
   (toward 8; § pkgNetNamedTsDimEnd280, the remainder the importer copy pass 275 left). 15 case-views read `nodb`
   (neither binary writes a database: exit 3, and exit 139 on pass 254's known --elabuhdm crashes f04_class, vf02 and
   vf04 on both binaries).
3. **Movers with away 0 and toward 0** (VA/va03, va06, va09, va26, va30, va36, VP/vp11, v11u278repro VS/vs08,
   VA/va44 e): drivers/recdiff.sh shows the law's records equal golden's field by field except where golden's own
   record differs for a reason outside this pass, so no chain key can match: golden's hier_path text is Surelog's
   decompile, which drops a select's base or a constant's name inside an index (`z.g[k[0]][1]` reads `z.g[0]` /
   `z.g[[0]]`, `pk::K` folds to `2`, `$unsigned(k)` disappears), and every record below it is keyed under that
   name. VA/va44 e moves bytes the strict walk never reaches (the records it walks are identical).
4. **VP/vp11_wire_net** (stage 1 on both binaries, package vpiVariables): `wire un_t wv [0:1]; var un_t vv [0:2];`
   — golden lists `vv` as an array_var (the variable road, no stretch) and stretches `un_t` to `wv`'s dimension
   (5:21); we list `vv` as a net, so the law's last-entry rule stretches to `vv` (6:20) where pristine kept 4:57; both
   wrong, away 0. A struct written `var st_t v [0:1]` is a logic_net in golden and stretches (VP/vp13, vp14 convert),
   so the rule turns on Surelog's listing, not on the keyword; the fix sits with the listing of a union variable, not
   with this law.

## Residues on this ground (ranked)

1. The implementer's residues stand as listed in tools/probe/r11u280repro/README.md (the generate-scope fold reference
   names, the variable road of the package stretch, the member-path leftovers, PS/p10 and p11).
2. A call inside the trailing select's index (VA/va36 `z.g[$unsigned(k)][1]`): golden names the reference under the
   sys_func_call through the chain (`work@top.z.g[1].g.k`, ComputeFullName skipping the call's own name);
   § hpMemVarSelIdxNamesByChain280 abstains on calls, so the subtree keeps pristine's name (stage 1 here on the
   decompiled hier_path name).
3. Golden's hier_path decompile inside an index (finding 3): stage 1 on both binaries wherever a select, a qualified
   constant or a call sits in the index; a Surelog text defect, not copied.
4. VP/vp11 (finding 4): the union `var` array listed as a net.

Sister-ground faces: none new beyond the implementer's list.

## Process

- Fence: every corpus path list was filtered by `$FENCED` (word boundary, read from
  tools/probe/r11u107repro/canaudit.sh's FENCED= line through the env file) before any file was opened: the census
  ran through the harness filter, bvmirror.sh skipped the 8 fenced paths, the probe and downstream database lists and
  the cmds.txt list were filtered before the cmp loop and the grep. No fenced source, database or cmds.txt was read
  or dispatched outside the gate sweeps; every helper here (case.sh, grid.sh, away.sh, bytectl.sh, recdiff.sh,
  dscases.py, tracecensus.sh, det.sh) refuses to run without `$FENCED`.
- No process was listed or signalled. The main tree was not written apart from git's worktree metadata (worktrees
  /tmp/wt_v11u280, /tmp/wt_v11u280pris and /tmp/wt_v11u280chk, the last for the fresh-apply check).
- Exploratory first runs of the fresh cases used the implementer's frozen pris.bin / law.bin read-only while my
  builds compiled (both md5-equal to mine); every number above is from my own binaries.
- SLIPS: my first byte-control pass labelled 17 case-views MOVED where neither binary wrote a database (cmp of two
  missing files); each was rerun three times (pristine twice, law once) and confirmed database-less, the driver now
  prints `nodb`, and the files under evidence/ carry the corrected label. One temporary sort file was written as
  /tmp/a1 (not pass-prefixed) and deleted in the same command.
- Words: the implementer's source comments in ExprEmit use the word integration rewrites to "branch" five times
  (around the lvalue branch, the package branches, the emission-time branches, the index-name branch and the copy
  branch), and two case comments (LB/b16_int_plain, VR/r22_lhs) once each; left for integration as before.

Files: drivers/case.sh, grid.sh, gridsum.py, tracecensus.sh, det.sh and dscases.py (from r11u280repro); away.sh,
bytectl.sh and recdiff.sh (new); the away census (awaychain.py with strictcmp_x built by cc_x.sh) and bvmirror.sh
are used in place from tools/probe/r11u272repro/drivers, byteverify.sh from tools/probe/r11v75repro.
