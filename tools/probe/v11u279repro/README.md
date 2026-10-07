# v11u279 — adversarial verification of r11u279 (module/type ground: the `assign o = P` struct-parameter read, the package row-typedef element, nested and module class typedef member paths, scoped class spans, inline struct port and `var` spans)

**Verdict: ACCEPT, no production fix.** Every headline number of tools/probe/r11u279repro/README.md was reproduced
bit for bit on binaries built here, and the six laws survived 78 fresh case dirs (156 case-views) with no case leaving
STRICT_EQUAL, no record moved away from golden, no exit-code change and no downstream verdict leaving IDENTICAL.

## Binaries (built here, frozen before any measurement)

| binary | source | md5 |
|---|---|---|
| pristine | b56f9a1c, `cmake -DSLANG_UHDM_USE_SYSTEM_DEPS=ON`, `-j 2` | d5fdc90a4faa563830c31a1dfd6127bd (the base binary named in the brief; equal to the implementer's) |
| law | b56f9a1c + /tmp/r11u279.patch | 7fa8abf349b009efe99741e9ea6fe615 (equal to the implementer's) |

Both report slang 12.0.0+545f88b2e. strictcmp_x was rebuilt with tools/probe/r11u279repro/drivers/cc_x.sh (md5 equal
to the implementer's). The patch applies cleanly on a fresh b56f9a1c, and its source files also apply cleanly on the
main tree's new HEAD 7c896f02 (pass 274, which touched only ParamEmit; tests/LAWS.md is regenerated at integration).

## Gates reproduced (tests/sweep.sh --jobs 3, workdirs of equal length, SLANG_UHDM exported per binary)

- **probe**: pristine EQUAL 3749 + STRICT_NOTEQUAL 338, byte-identical to results/golden_probe.csv at b56f9a1c. Law
  **EQUAL 3791 + STRICT_NOTEQUAL 296, regressions=0 conversions=42 changes=4**. The same 42 conversions and 4 changes
  by name as the implementer reports (`evidence/sweep_L.log`):
  - law 1: 25 cases, `differ:name(2)`;
  - law 2: 7 cases, `differ:name(8)`;
  - law 3: 4 cases, r10sd10repro;
  - law 4: 1 case; laws 4 + 5: 2 cases;
  - law 6: 3 cases;
  - changes: r11u117repro/grid/g1/t12 `name(8) -> fullname(4)`, v11u117repro/grid/b02 `name(8) -> fullname(1)`,
    r10vearl100repro/v6_more100 `fullname(23) -> (21)` and v11u110repro/brk/v6/s01_single_chain2_ctl `fullname(7) -> (6)`.
- **surelog**: 478 + 2 / 472 + 2 on both binaries. regressions=0 conversions=0 changes=0. The status and strict
  columns are identical row by row to results/golden_surelog.csv at the base. The two csvs differ only in the LowMemLib
  and LowMemPkg detail text (the workdir path).
- **uhdm2rtlil**: 803/1/67 in both modes. The two csvs are byte-identical, and status and strict match the baseline.
- **downstream**: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT. The law csv is byte-identical to the
  pristine csv and to results/downstream_uhdm2rtlil.csv at the base.
- Both sweeps exited 1 on the law-index check alone (INDEX QUIRK).
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1). Fence-filtered hard-link mirrors were made with
  r11u279repro/drivers/bvmirror.sh: 3365 databases mirrored, 8 fenced row-mode databases skipped by path name.
  - surelog 0 / 952 (SELFCHECK 951 / 952);
  - uhdm2rtlil 2 / 1608: stamped_gen_param d/t, hashes 9d0e08db7645 / f4f51349831a against 2d482edcf55e /
    add12e922be3, the implementer's hashes;
  - downstream 1 / 805 (stamped_gen_param);
  - probe 46 / 4087 (SELFCHECK 4086 / 4087).
  - The pristine probe stage was rerun from the law worktree: probe databases embed the source path, and the two
    worktree paths differ in length. Its csv is byte-identical to the baseline.
  - The 46 probe movers are exactly the 46 probe lines of the implementer's predict.txt.
- **firing census**: drivers/tracecensus.sh with the law binary (fence filter built from $FENCED).
  `evidence/predict.txt` is identical line for line to the implementer's frozen 48-line census: 46 probe databases
  plus stamped_gen_param d/t (TOPPKGTDELEM).
- **away census**:
  - the 46 probe movers: lost=0 and chain away=0 on all 46 (`evidence/probe_movers_away.txt`);
  - stamped_gen_param d/t: lost=0, chain away=0, toward 102, uhdm-cmp 64 lines on both binaries, CMP_NOTEQUAL (the
    known failure) on both, downstream IDENTICAL.
- **canaries**: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog) and
  EXPECT_UNKNOWN=6 (uhdm2rtlil) both PASS.
- **binary-path audit**: the cmds.txt path list was fence-filtered before any file was read. In each sweep, 3265 of
  3315 cmds.txt name that sweep's own binary. The other 50 carry no slang line. The only other `slang-uhdm` strings are
  two Surelog lines naming the repository path.
- **determinism**: three concurrent draws of the law binary (drivers/det.sh) give one hash on each of the 12 row-modes
  with a database (Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg in both modes, Rggen
  default). Each hash equals both sweeps' hash and the implementer's hash (`evidence/determinism.txt`).
- **grid**: the implementer's 104 case dirs were rerun on these binaries (208 case-views, 1872 lines). Every cmp,
  cmplines, strict and rc field is identical to evidence/grid.txt. OFF == P on 208 of 208, 138 moving, 115 entering
  STRICT_EQUAL, 0 leaving, and the per-switch attribution is the same: SPCAVAL 42, TOPPKGTDELEM 16, CLSTDPATH 36,
  CLSTDQUAL 8, EXTQUALSPAN 10, INLSTRUCTKW 26.

## Attack: 78 fresh case dirs, both views (cases/VA, VB, VC, VK, VN; every case's first line names its law)

Each case runs on pristine, the law, the law + `R11U279_OFF` and the law with each switch off, and every line carries
its exit code (`evidence/grid.txt`, 1404 lines; `evidence/grid_summary.txt`).

**156 case-views: OFF == P on 156 of 156; 128 moving, 71 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.**
Every mover returns to pristine's bytes under exactly one switch: SPCAVAL 48, TOPPKGTDELEM 22, CLSTDPATH 18,
CLSTDQUAL 10, EXTQUALSPAN 12, INLSTRUCTKW 18. uhdm-cmp line counts change only on VB/vb06 in both views, from 96 to 0:
stage 1 becomes judge-equal. The away census (order-blind and chain-keyed) on all 57 movers that do not enter
STRICT_EQUAL reads lost=0 and chain away=0 (`evidence/grid_away.txt`).

Downstream on all 78 dirs with both binaries (`evidence/downstream_cases_{P,L}.txt`):
- 58 IDENTICAL on both;
- 6 move to IDENTICAL: vb01, vb03, vb06, vb11 and vb12 from EQUIVALENT, vb10 from DIVERGENT;
- 8 EQUIVALENT and 5 DIVERGENT the same on both (va03, vk01, vk02, vk09, vk10);
- 1 SURELOG_FAIL (vk12);
- none leaves IDENTICAL.

- **VA — § structParamCaReadsPaValue279** (33 dirs). These enter STRICT_EQUAL in both views:
  - va05_genfor_inst: instances in a for-generate;
  - va06_default_and_name_override: a default-name instance beside a `.P(p::D2)` instance;
  - va07_three_level: `.Q(p::D2)` passed through `.P(Q)`;
  - va10_two_assigns_one_stmt: `assign o = P, o2 = P;`;
  - va15_paren_read: `(P)`;
  - va16_signed_struct;
  - va17_also_always: an `always_comb` read beside the cont_assign;
  - va18_import_override_name: `.P(D2)` through `import p::*`;
  - va19_two_params_two_assigns;
  - va21_inst_in_genif: an instance in an if-generate;
  - va22_same_override_twice;
  - va24_parent_param_chain_literal: `.P(Q)` with Q a literal default;
  - va28_instance_array: `sub u[1:0]`;
  - va29_concat_lhs: `assign {o, o2} = P`;
  - va30_mixed_body_gen: a body read and a generate read of the same P;
  - va31_struct_typed_output: a struct-typed output, default and override instances;
  - va32_module_in_interface_ctx: the Lhs an interface port member `i.w`;
  - va33_override_from_import_in_pkg_scope: positional `#(p::D)` beside `#(16'h00ff)`.

  Unmoved and equal on both (the law abstains where golden keeps the read): va01_cast_chain (a chain ending in an
  explicit cast; the param_assign value is not a constant, `SPCAVAL_ABSTAIN noconst`) and va12_logic_typed_src (a
  logic-typed package parameter as the name).

  Stage 1 on both binaries, moved with 0 lost and 0 away or not moved:
  - va02_func_chain: the package parameter's func_call value;
  - va03_defparam: a defparam override; DIVERGENT downstream on both, a constant value mismatch;
  - va04_concat_chain;
  - va08_sibling_param: `P = Q`, a sibling port parameter;
  - va09_localparam_of_literal_param;
  - va11_arith_chain;
  - va13_narrow_lhs and va14_wide_lhs: a width-converted read, the cont_assign constant's size;
  - va20_struct_member_also;
  - va23_genblock_read_in_inst;
  - va25_untyped_param: `parameter P = p::D`, int_typespec in golden;
  - va26_type_param_typed: `parameter T P` with `type T = p::s_t`;
  - va27_cross_pkg_chain: STRICT_NOTEQUAL fullname on both; its head is a package `ref_obj p::D2` full name
    `p2::p::D2` in golden, ParamEmit's ground.
- **VB — § topPkgMemberTdOfNamedElemShares279** (12 dirs).
  - Entering STRICT_EQUAL in both views: vb01_nested_named (a typedef of a typedef vector), vb03_nested_struct (the
    member one struct down), vb11_scalar_leaf_named (`typedef logic ut_e`), vb12_two_modules (a port of another
    module).
  - vb06_two_pkgs_same_shape: two packages with the same row_t and impl_t. Pristine is uhdm-cmp stage 1 (96 lines).
    The law is judge-equal and reads `name`: golden's q4::impl_t member binds **q2::row_t** (Surelog resolves the
    same-named typedef to the first package), while ours binds q4::row_t. This is a Surelog-side defect, not a break.
    Downstream EQUIVALENT -> IDENTICAL.
  - Moving toward golden: vb07_imported_struct_in_module (its `file` head is the module's `row_t r` typespec),
    vb09_scoped_own_pkg (`q2::row_t [0:1] U` inside q2: golden binds the listing object directly with no wrapper, the
    implementer's residue 3), vb10_member_read (`name` -> `col`: the var_select column, ExprEmit, sister),
    vb04_retypedef_other_pkg and vb05_param_only (stage 1 on both).
  - Not moved: vb08_twostate_leaf (bit leaf, the law's four-state gate) and vb02_signed_leaf (moved, stage 1 on both).
- **VC — § clsTdScopedTargetQualSpan279 / § extendsScopedBaseNameSpan279** (11 dirs).
  - Entering STRICT_EQUAL: vc02_td_scoped_named_param (`#(.D(3), .W(5))`), vc03_td_scoped_unit_space (`rp :: regb`),
    vc04_td_scoped_in_module_class, vc05_td_scoped_two_files (an included header, two classes),
    vc13_extends_in_module, vc14_extends_crlf (CRLF, two classes).
  - Stage 1 on both, moved toward golden (chain toward 1-2) or not moved: vc01_td_nested_scope
    (`rp::outer_c::inner_c #(4)`), vc11_extends_nested_scope, vc12_extends_named_param, vc15_extends_spaces,
    vc16_extends_and_implements.
- **VK — § inlineStructPortVarKwSpan279** (12 dirs).
  - Entering STRICT_EQUAL: vk06_interface_var.
  - vk08_class_prop_var and vk11_var_in_genblock_el: `endcol -> fullname`, the endcol cleared (dist 1 -> 0, gained
    1); the next head is a member ref_typespec full name.
  - Stage 1 on both, moved with 0 away: vk01_input_var_port (`input var struct packed`), vk02_input_wire_port,
    vk04_func_local_var, vk05_pkg_var, vk09_always_block_var, vk10_nonansi_var_port.
  - Unmoved: vk03_port_packed_dim, vk07_unpacked_var. SURELOG_FAIL: vk12_static_var_task.
- **VN — § clsTdMemberContainerPath279** (10 dirs).
  - Entering STRICT_EQUAL: vn02_extended_nested (`inner_c::irec_t` through a derived class), vn03_param_outer_two_specs,
    vn06_unit_three_levels, vn07_packed_union_module, vn08_nested_member_struct_typed,
    vn10_module_direct_param_class, and vn04_module_inst_twice in the default view.
  - vn04_module_inst_twice_el keeps `fullname`: the class_defn `work@sub::outer_c` in golden against
    `work@top::s1::outer_c`, the implementer's residue 5. The law's member records are cleared (toward 11).
  - Stage 1 on both, moved toward golden: vn05_inner_td_of_outer_td, vn09_unpacked_array_nested.
  - Not moved: vn01_gen_block_class (a class in a generate block; the container walk returns no path, as designed).

## Widened byte controls (`evidence/controls.txt`, `evidence/controls_away.txt`)

The dirs: r11u114, r11u117, v11u117, r11u271, v11u271, r11u275, v11u275, r11u265, v11u265, r11u269, v11u269, r11u267,
v11u267, r11u241, r11u247, v11u247, r11u251, r11u105, r11v105, r11u112 and r11u116, none of them in the implementer's
control set. That is 2416 case-views on pristine and law, with path lists fence-filtered before any case was opened.
**124 moving, 2 entering STRICT_EQUAL (r11u117repro/grid/g2/r11u111_f3_t12_pat_row_dims_member in both views), 0
leaving, 0 uhdm-cmp line-count changes, 0 exit-code changes.** The law's rc histogram is 0: 2392, 4: 14, 3: 8, 139: 2
(the 139 pair is r11v105repro v09, which also exits 139 on pristine).

The 122 other movers are stage 1 on both binaries (r11u114 f1 a01 and a30; r11u117 g1; v11u117 b*). All 124 read
lost=0 and chain away=0. All 62 default-view movers return to pristine's bytes under R11U279_TOPPKGTDELEM_OFF alone.

## Findings (none a break; all wrong on pristine too or Surelog's own)

1. **Surelog binds a same-named typedef across packages to the first package** (VB/vb06). Golden's
   `q4::impl_t.U` element is `q2::row_t`. The law binds q4's own listing object, which is the correct one, and moves
   the case from uhdm-cmp stage 1 to judge-equal. Golden writes nothing we should copy here.
2. **A defparam override of a struct parameter** (VA/va03) is uhdm-cmp stage 1 and DIVERGENT downstream on both
   binaries: a constant value mismatch. The law does not fire on it. This is a residue for the module ground.
3. **The struct-parameter read where the default is not a plain name chain** stays stage 1 on both binaries:
   - a function-call value va02;
   - a concatenation va04;
   - an arithmetic value va11;
   - a sibling port parameter va08;
   - a localparam of a literal parameter va09;
   - a width-converting Lhs va13 / va14;
   - a member read beside it va20;
   - a generate-block read va23;
   - an untyped parameter va25;
   - a type-parameter-typed parameter va26.
4. **A scoped own-package row typedef in a struct member** (`q2::row_t [0:1] U` inside q2, VB/vb09) has golden
   binding the listing object directly with no wrapper. This is the implementer's residue 3, extended to the struct's
   own package.
5. **Nested scopes in a class typedef target and in an extends** (`rp::outer_c::inner_c`, VC/vc01 and vc11) are stage
   1 on both binaries. The law spans to the last separator; their spans are unverified behind stage 1.
6. A class property and a generate-block variable written `var struct packed` (VK/vk08, vk11_el) clear the span and
   then read a member ref_typespec full name, `<in>a` in both with a differing chain.

## Process

- Worktrees /tmp/wt_v11u279 (law) and /tmp/wt_v11u279pris (pristine) at b56f9a1c; scratch /tmp/v11u279_*. Both
  binaries were frozen (chmod 555) before any measurement.
- Every path list over a corpus or probe tree was fence-filtered by word boundary before any file was opened. The
  corpus census ran with the fence filter. No fenced source or database was opened, and every tool variable was
  guarded.
- No process was signalled. The main tree was not written. It moved during this pass (pass 274 integrated and
  committed at 7c896f02), so every baseline comparison here reads the base's results/ from the worktree.
- The first fresh VA batch shared one package carrying a function-call parameter (`DF = mk()`), which put every VA
  case in uhdm-cmp stage 1 on both binaries. The packages were trimmed to the parameters each case reads and the batch
  was rerun; only the rerun is reported.
- Drivers are the implementer's (tools/probe/r11u279repro/drivers). `drivers/run.sh` records the invocations.
