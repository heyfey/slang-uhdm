# r11u279 — module/type ground: the probe residue by writer (the `assign o = P` struct-parameter read, the package row-typedef element, class typedef member paths, scoped class spans, inline struct port spans)

Base b56f9a1c (pass 277; the Surelog corpus at zero open rows). Six laws in ModuleEmit, TypeEmit and UhdmExporter
behind `src/R279.h`: each law reads its own `R11U279_<LAW>_OFF` switch, `R11U279_OFF` drops all six and gives
pristine's bytes on 208 of 208 grid case-views, `R11U279_TRACE=<dir>` logs every firing (and the first law's
abstentions). No corpus row moves status; **FORTY-TWO PROBE CONVERSIONS** and four probe changes, every one toward
golden.

| target | before (base) | after (law) |
|---|---|---|
| probe `assign o = P` struct-parameter bucket (25 cases, `differ:name(2)`) | STRICT_NOTEQUAL | **25 EQUAL** (all of the bucket in tests/probe) |
| probe `q2::row_t` alias-chain bucket (`differ:name(8)`, 10 cases) | STRICT_NOTEQUAL | **7 EQUAL**, 2 changes toward golden (t12, b02), x36 unchanged (residue 2) |
| probe nested-class typedef member full names (`r10sd10repro`, 4 cases) | STRICT_NOTEQUAL | **4 EQUAL** |
| probe scoped class typedef / scoped extends spans (3 cases) | STRICT_NOTEQUAL | **3 EQUAL** |
| probe inline packed struct port / `var` spans (3 cases) | STRICT_NOTEQUAL | **3 EQUAL** |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged (row by row) |

## The laws

1. **§ structParamCaReadsPaValue279** (ModuleEmit, recorded where the elaborated view shares the definition's
   cont_assign and applied design-final by `structParamCaDrain279` from UhdmExporter's post-passes, after
   § castRhsClonePerInst176's drain; switch `R11U279_SPCAVAL_OFF`). An elaborated continuous assignment in a module
   instance's body that reads a WHOLE struct- or union-typed parameter whose effective value (the override actual,
   else the default) is written as the NAME of another parameter (`parameter p::s_t P = p::D;`, `.P(p::D2)`,
   `.P(Q)`, a chain `DC = D` followed through parameters) takes the instance's param_assign value constant itself:
   golden lists a fresh cont_assign (its Lhs a copy of the definition's, bound to the definition's net) whose Rhs is
   the param_assign's constant re-parented at the assignment (the last reader when several read it, A/a12), where
   ours shared the definition's cont_assign with its `ref_obj P`. A literal value (`= 16'hbeef`, `.P(16'h1234)`),
   an unbased fill (`'0`) or a name whose chain ends in an assignment pattern keeps the shared definition object in
   golden as in ours (A/a01, a03, a06's overridden instance, a38, a40); a cont_assign in a generate scope keeps the
   ref_obj in golden (A/a07). Decoded by pass 272 (its residue 1: the read reduces to the param_assign value only
   when the default is a parameter name with a constant value); Surelog keeps such a value as the instance's
   complex value and elaboration hands that object back for `P`. Values with unknown bits fold too (A/a34).
2. **§ topPkgMemberTdOfNamedElemShares279** (TypeEmit buildStructTs, the element site of the `vtaMem` road; switch
   `R11U279_TOPPKGTDELEM_OFF`). In the ELABORATED package listing (pkgTopEmit) a struct member written `T [d] m`,
   where T is a package typedef of a NAMED type (`typedef ut_e [0:2] row_t;`), keeps its member-span wrapper but
   points the wrapper's element at T's shared listing object `q2::row_t` (golden: member `U` -> logic_typespec at the
   member span -> elem `q2::row_t`, unlocated), where ours pointed it at a bare-named clone `row_t` located at the
   typedef with a Typedef_alias to the listing object, one level more than golden. The decision is
   § defPkgMemberTdOfNamedShares108's (typedef of a named type, four-state scalar leaf, package home, own package or
   a scoped name, the listing object named `pkg::T`), read in the top listing. Decode at pass 108 (compileDatastructure
   Typespec's TypeDef branch returns the package typedef's own typespec; the elaborated listing wraps it).
3. **§ clsTdMemberContainerPath279** (UhdmExporter buildClassTypedefTs, the struct, union and unpacked-array branches;
   switch `R11U279_CLSTDPATH_OFF`). The member path of a typedef declared in a NESTED class, or in a class a module
   or program declares, is named from the class's full container path: a package (`px::outer_c::inner_c::irec_t::a`),
   a module or program body (`work@top::outer_c::inner_c::...`, `work@top::outer_c::orec_t::a` for a class the
   module declares directly, `work@prg::...`), and $unit or an interface body as `work@<outermost class>`
   (`work@outer_c::inner_c::irec_t::a`). Ours named it from the innermost class alone (`inner_c::irec_t::a`,
   `outer_c::orec_t::a`). The nested and module twin of § classTdStructMemberPkgPath146 (a class a package holds
   directly, unchanged) and § clsTdArrElemPkgPath249 (the array element, which already names module classes).
4. **§ clsTdScopedTargetQualSpan279** (UhdmExporter buildClassTypedefTs, the class-specialization branch; switch
   `R11U279_CLSTDQUAL_OFF`). A class typedef whose target is SCOPED (`typedef rp::regb #(ub, "ub") tidb;` in a
   class) locates its class_typespec at the scope prefix `rp::`, the Class_scope node Surelog collects it from (the
   rule TypeEmit's scoped class reference already follows), where ours spanned the whole specialization.
5. **§ extendsScopedBaseNameSpan279** (UhdmExporter drainPendingExtends; switch `R11U279_EXTQUALSPAN_OFF`). A
   SCOPED base class (`class ub extends rp::baseb;`) keeps its written name `rp::baseb` but its extends and
   class_typespec span only the class name after the last `::` (the identifier when parameterized), as golden's do;
   ours spanned `rp::baseb`.
6. **§ inlineStructPortVarKwSpan279** (TypeEmit, the anonymous packed struct span; switch
   `R11U279_INLSTRUCTKW_OFF`). An inline packed struct typing a PORT (`input struct packed {..} i`, an ANSI or
   non-ANSI port header) or a declaration written with `var` (`var struct packed {..} x;`) is located at the
   `struct` keyword alone: compileTypespec's struct branch populates the typespec at the keyword, and only a plain net
   declaration's Signal re-stamps the end at the packed slot through writeNets' end-only populate
   (§ defNetEndOnlyLoc130, `struct packed`, unchanged: K/k09). Ours wrote `struct packed` for all three.

## Characterization (the base probe residue by first record)

`uhdm-strictcmp --max 1` on every one of the 338 STRICT_NOTEQUAL probe cases at the base (pristine sweep databases
against `scripts/check_probe.py`'s cached goldens; `evidence/base_heads.tsv`). The heads worked here:

- `#536 name  A: ref_obj o work@dut.o  B: ref_obj P work@dut.P` (r11u108repro/grid/pk/k10_member_v_pkgparam): golden's
  elaborated cont_assign lists Rhs `constant 8:21-8:22 16'hbeef` (the param_assign's own value object, vpiParent the
  cont_assign) and a fresh Lhs; ours re-listed the definition's cont_assign object. 25 probe cases: r11u108repro pk
  k10, k10b, k10c, k10d, k10e, k10f, k10g, k10j, k10k, k10l, k11; r11u111repro f2 b03, b04, b05, b06, b07, b08, b10,
  b11, b12, b13, b14, b17; v11u111repro f2 x22, x26.
- `#134 name  A: logic_typespec q2::row_t (unlocated)  B: logic_typespec row_t dut.sv 4:11-4:21`
  (r11u114repro/grid/f1/a02): the elaborated package listing's member `row_t [0:1] UnitTypes` wrapper element; the
  records below ours are golden's shifted by one level. 10 probe cases: r11u111repro f3 t12_pat_row_dims_member,
  r11u114repro f1 a02, r11u117repro g1 g18, t03, t12, v11u108repro f2 c01, c03, c16, v11u111repro f3 x36_iface_sig,
  v11u117repro b02.
- `#48 fullname` with raw `px::outer_c::inner_c::irec_t::a | inner_c::irec_t::a` (r10sd10repro g4_owner_reach,
  v9_nested_classes, v13_root_lookup, v14_early_nested_sib).
- `#6 endcol  class_typespec tidb 5:13-5:17 | 5:13-5:33` (r10sd1repro b18_qualified; r10v212repro
  gridv_v4_scopedname_base_design 12:11-12:15; r10v112repro g4_qualified 9:23-9:30), with b18 and v4 then reading
  `#7 col extends 4:24-4:29 | 4:20-4:29` (the scoped extends).
- `#6 endcol  struct_typespec 2:7-2:13 | 2:7-2:20` (r11u109repro f5 k07_var_nodim; r11u113repro e e12_port 1:16-1:22;
  r11u19repro q02_mod_packedstruct_defzero 1:41-1:47).

## Grid (tools/probe/r11u279repro/cases, 104 case dirs, both views)

Every case's first line names its law. Driver `drivers/grid.sh` runs each case in both views on pristine (P), law (L),
law + `R11U279_OFF` (OFF) and the law with each switch off; every line carries the exit code (`evidence/grid.txt`,
1872 lines; `drivers/gridsum279.py` -> `evidence/grid_summary.txt`):

**208 case-views: OFF == P on 208 of 208; 138 moving, 115 entering STRICT_EQUAL, 0 leaving, 0 uhdm-cmp line-count
changes, 0 exit-code changes; every mover returns to pristine's bytes under exactly one switch** (SPCAVAL 42,
TOPPKGTDELEM 16, CLSTDPATH 36, CLSTDQUAL 8, EXTQUALSPAN 10, INLSTRUCTKW 26). The away census (`drivers/away.py`
order-blind, `drivers/awaychain.py` chain-keyed) reads lost=0 and chain away=0 on all 138 movers
(`evidence/grid_away.txt`).

- **A — § structParamCaReadsPaValue279**: a01_literal_default (control, equal on both), a02_pkgname_default,
  a03_pkgpattern_default (control), a04_modlocal_name (stage 1 on both), a05_union, a06_literal_override (only the
  default instance folds), a07_genif (control: generate scope), a08_chain_name (moves; first record a package
  parameter's `HEX:BEEF` value on both, sister face), a09_localparam, a10_select_lhs, a11_interface (stage 1 on both),
  a12_two_reads, a13_logic_typed_ctl (stage 1 on both), a14_parent_name_override, a15_wildcard_import,
  a16_struct_lhs, a17_var_lhs, a18_concat_rhs_ctl (stage 1 on both), a19_expr_valued and a20_chain_to_pattern (stage
  1 on both: the param_assign value's decompile), a21_delay, a22_two_inst_default, a23_paren_default,
  a25_cast_default (control), a28_net_decl_assign (control), a29_program (control: a program keeps the ref; its
  first record a program parameter's missing value on both), a30_bind, a31_positional_override,
  a32_port_param_passdown, a33_alias_typed, a34_xvalue, a35_member_read_ctl (stage 1 on both), a36_macro_name,
  a37_pkg_two_files_hdr, a38_unbased_zero, a39_unbased_one (stage 1 on both), a40_unbased_override, a41_concat_default
  (stage 1 on both). 20 dirs enter STRICT_EQUAL in both views.
- **B — § topPkgMemberTdOfNamedElemShares279**: b01_pkgparam, b02_modvar, b03_port, b04_pkgfunc, b15_two_members,
  b16_macro_member enter STRICT_EQUAL in both views; b05_scoped_other_pkg moves (its first record the definition
  listing's member, residue 3), b11_td_chain moves at stage 1 (both); controls b06_imported_other_pkg, b07_multidim,
  b08_enum_elem_ctl, b09_bit_leaf_ctl, b10_union_member, b12_nodim_ctl, b14_plain_vec_td_ctl (stage 1 on both,
  unmoved), b13_module_struct_ctl (unmoved, residue 3).
- **C — § clsTdScopedTargetQualSpan279**: c01_cls_td_scoped_param, c02_cls_td_scoped_plain, c06_cls_td_scoped_macro,
  c07_module_cls_td_scoped enter STRICT_EQUAL; c03_pkg_td_scoped_param and c04_mod_td_scoped_param stage 1 on both
  (c04 exits 4 on both), c05_cls_td_unscoped_param_ctl equal on both.
  **§ extendsScopedBaseNameSpan279**: c11_extends_scoped, c14_extends_scoped_module_cls, c15_extends_scoped_macro
  enter STRICT_EQUAL; c12_extends_scoped_param and c16_extends_scoped_multiline move at stage 1 (both);
  c13_extends_unscoped_ctl equal on both.
- **K — § inlineStructPortVarKwSpan279**: k01_ansi_input, k02_ansi_output, k05_signed_port, k07_var_signed,
  k11_two_instances, k12_program_port, k13_var_two_decl, k14_macro_port enter STRICT_EQUAL; k15_var_init moves (the
  typespec now golden's; the struct_net span to the initializer's end left, residue 4); k03_nonansi, k04_output_var,
  k10_interface_port, k16_inout_port move at stage 1 (both); k06_union_port, k08_var_union stage 1 on both,
  unmoved; k09_plain_net_ctl equal on both, unmoved.
- **N — § clsTdMemberContainerPath279**: n01_struct, n02_packed_struct, n03_union, n05_three_levels,
  n06_unused_typedef, n07_module_class_ctl, n08_unit_class_ctl, n10_nested_member_used_by_inner, n11_macro_td,
  n12_param_outer, n13_module_class_direct_ctl, n14_module_three_levels, n15_interface_class, n17_program_nested,
  n18_module_direct_union, n20_program_direct enter STRICT_EQUAL in both views (n07, n08 and n13 were written as
  controls before the law was widened to module, $unit and interface containers; their names keep `_ctl`);
  n19_module_direct_two_inst enters in the default view, its elaborated view keeps the instance class_defn full name
  (residue 5); n04_unpacked_array moves at stage 1 (both); n09_outer_own_td_ctl, n16_interface_direct,
  n21_module_direct_array equal on both, unmoved.

Downstream on every case dir with both binaries (`drivers/dscases.py`, `evidence/downstream_cases_{P,L}.txt`): 88
IDENTICAL on both, 6 moving to IDENTICAL (b01, b03, b15, b16 EQUIVALENT -> IDENTICAL; b02, b04 DIVERGENT ->
IDENTICAL), 7 EQUIVALENT and 3 DIVERGENT (b13, k03, k04) the same on both, none leaving IDENTICAL.

## Byte controls (`drivers/controls.sh`, `evidence/controls.txt`, `evidence/controls_summary.txt`)

1104 earlier repro dirs, 2208 case-views (r11u108, v11u108, r11u110, v11u110, r11u111, v11u111, r11u109, r11u113,
r11u19, r11u272, v11u272, r11u273, v11u273, r11u277, v11u277, r11u118, r11u119, r11u120, r11u146, r11u130, r11u237,
r11u249; path lists fence-filtered before any file was opened): **100 moving, 18 entering STRICT_EQUAL, 0 leaving,
0 exit-code changes**; entering: r11u111repro/grid/f2 b01_q_q_w16, b02_imp_imp_w16, b09_imp_imp_w64, b19_k10k,
b20_k10l, b21_k10j, b23_k10e, r11u272repro/cases/L/l07_net_typed and v11u272repro/cases/VL/vl29_assign_whole, each
in both views (law 1). uhdm-cmp line counts change on 4: r11u108repro/grid/pk/k12_member_arr_dims and
r11u111repro/grid/f3/k12_member_arr_dims in both views, 96 -> 64 lines, stage 1 on both binaries, the first head
moving from the row typedef `logic_typespec (p::a_t)` (law 2 clears it) to the cont_assign's `'0` value constant (the
next face, `localparam p::sa_t P = '0` read by `assign o = P`, golden folding where ours keeps the ref; not this
pass's law). The away census reads lost=0 and chain away=0 on all 100 movers (`evidence/controls_away.txt`).

## Gates (worktree at b56f9a1c + this patch; pristine `/tmp/r11u279_bin/pristine` md5 d5fdc90a4faa563830c31a1dfd6127bd = the main tree's build, law md5 7fa8abf349b009efe99741e9ea6fe615; both link slang 12.0.0+545f88b2e)

Both sweeps `tests/sweep.sh --jobs 3` with `SLANG_UHDM` exported (workdirs of equal length); each exited 1 on the
law-index check alone (the committed index is stale at the base, INDEX QUIRK; this patch carries the regenerated
`tests/LAWS.md`).

- **probe**: pristine EQUAL 3749 + STRICT_NOTEQUAL 338, regressions=0; law **EQUAL 3791 + STRICT_NOTEQUAL 296,
  regressions=0 conversions=42 changes=4**:
  - conversions (law 1): r11u108repro/grid/pk k10_member_v_pkgparam, k10b_member_child_sel, k10c_member_widthparam,
    k10d_member_child_nosel, k10e_member_child_sel_q, k10f_member_bodyimport, k10g_member_bodyimport_child,
    k10j_wide, k10k_w32, k10l_w33, k11_member_v_qualified; r11u111repro/grid/f2 b03_q_imp_w16, b04_imp_q_w16,
    b05_q_q_w80, b06_imp_imp_w80, b07_q_imp_w80, b08_imp_q_w80, b10_q_q_w64, b11_localparam_q_w16, b12_sub_q_w16,
    b13_sub_imp_w80, b14_hdrimp_imp_w80, b17_q_q_w16_plainmember_ctl; v11u111repro/brk/f2 x22_explicit_imp_wide,
    x26_q_twoinst_override (all `differ:name(2) -> EQUAL`);
  - conversions (law 2): r11u111repro/grid/f3/t12_pat_row_dims_member, r11u114repro/grid/f1/a02,
    r11u117repro/grid/g1 g18 and t03, v11u108repro/brk/f2 c01_var_of_struct, c03_port_of_struct, c16_pkg_func (all
    `differ:name(8) -> EQUAL`);
  - conversions (law 3): r10sd10repro g4_owner_reach `fullname(2)`, v13_root_lookup `fullname(4)`,
    v14_early_nested_sib `fullname(4)`, v9_nested_classes `fullname(3)`;
  - conversions (law 4): r10v112repro/g4_qualified `endcol(4)`; (laws 4 + 5): r10sd1repro/b18_qualified
    `endcol(3)`, r10v212repro/gridv_v4_scopedname_base_design `endcol(7)`;
  - conversions (law 6): r11u109repro/grid/f5/k07_var_nodim, r11u113repro/grid/e/e12_port,
    r11u19repro/grid/q02_mod_packedstruct_defzero (`endcol(2)`);
  - changes, all toward golden: r11u117repro/grid/g1/t12 `name(8) -> fullname(4)` (old first record #134 the
    `q2::row_t` element, cleared; new first record #338 `hier_path` full name, golden empty, ours `work@top.f`, an
    expression-ground face behind it) and v11u117repro/grid/b02 `name(8) -> fullname(1)` (new #396 `ref_obj cfg`
    full name, golden `work@top.cfg`, ours empty) by law 2; r10vearl100repro/v6_more100 `fullname(23) -> (21)` by
    law 6; v11u110repro/brk/v6/s01_single_chain2_ctl `fullname(7) -> (6)` by law 2 (first records unchanged).
- **surelog**: default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2 on both binaries; regressions=0
  conversions=0 changes=0; the two csvs differ only in the LowMemLib / LowMemPkg detail text (the workdir path).
  Every UVM row, Earlgrey_0_1 d/t, Rggen d, BlackBePipeInt d/t stay CMP_EQUAL.
- **uhdm2rtlil**: 803 CMP_EQUAL / 1 CMP_NOTEQUAL / 67 SLANG_REJECT both modes on both binaries, regressions=0, the
  csvs byte-identical.
- **downstream**: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; the law csv byte-identical to the
  pristine csv and to `results/downstream_uhdm2rtlil.csv`.
- **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, on fence-filtered hard-link mirrors from
  `drivers/bvmirror.sh`, 8 fenced row-mode databases left out of each): surelog MOVERS 0 / 952 (SELFCHECK 951 / 952),
  uhdm2rtlil 2 / 1608 (stamped_gen_param d/t; SELFCHECK 1607 / 1608), downstream 1 / 805 (stamped_gen_param, the same
  bytes as its uhdm2rtlil testflags database; SELFCHECK 804 / 805), probe 46 / 4087 (SELFCHECK 4086 / 4087).
- **firing census** (`drivers/tracecensus.sh`, the law binary under `R11U279_TRACE` over the probe cases and both
  corpora with the fence filter, frozen as `evidence/predict.txt` BEFORE the law sweep): 48 lines, uhdm2rtlil
  stamped_gen_param d/t (TOPPKGTDELEM) and 46 probe databases; **the 46 probe movers match the prediction exactly**,
  the two uhdm2rtlil movers are the predicted ones, the downstream lane's stamped_gen_param database is that test's
  (the census does not run the downstream lane). stamped_gen_param is the known-failure row: CMP_NOTEQUAL on both
  binaries with uhdm-cmp at 64 lines on both, the chain-keyed away census 0 away (102 toward) and the order-blind
  census lost 0 in both modes, downstream IDENTICAL on both.
- **away census** on the 46 probe movers: lost=0 and chain away=0 on all 46 (`evidence/probe_movers_away.txt`).
- **canaries**: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `ctcan2.sh` EXPECT_UNKNOWN=1 (surelog) and
  EXPECT_UNKNOWN=6 (uhdm2rtlil) both PASS.
- **binary-path audit** (cmds.txt path list fence-filtered first): 3265 of 3315 name each sweep's own binary, the
  other 50 carry no slang line, none names another binary.
- **determinism** (`drivers/det.sh`): three concurrent draws of the law binary on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes: one hash per row-mode on all 12 row-modes with a
  database, each equal to the law sweep's and to the pristine sweep's (Scoreboard and Rggen testflags write none).

## Residues (ranked; all wrong on pristine too)

1. The probe residue after this pass is 296 cases. Largest faces read at the base, by writer:
   - **ParamEmit (sister)**: the type-parameter chain `type b_t = a_t` in the definition view (golden binds the
     terminal parameter's default object, ours a copy located at the reference; r11u45repro g9, g10, g13,
     r11v45repro v2, v6, v7; § typeParamChainBorrow45), the elaborated param_assign cast constant's typespec left
     unlocated where golden binds the parameter's own typespec (r10earl_repro ss, tl, ud, ue, r11u108repro f4
     c12_const_fold), the package struct typedef stretched to a later use (r10earl53repro v2_v53, r10uvm149repro
     g149/homes, r11u32repro k9b, r11u88repro i6_ifarray and y2_pkgvarkind, r11v77repro vh_arrelem), a package
     `localparam s_t DC = D;` writing `HEX:BEEF` where golden writes `HEX:beef` (grid A/a08), a program parameter
     listing no value (A/a29).
   - **This ground, not attempted**: class_typespec spans in other contexts (a parameterized class property or local
     `regb #(ub, "ub") lv1` and `static box_j #(8) s_j` spanning the name only in golden: r10sd1repro
     b27_inline_method_foreign, r10v119repro v119_j; a scoped function return `p3v::h3` spanning `p3v::` in golden:
     r10uvm56repro v3_hierpath, r10v150repro v150_f1; a dynamic array of a class spanning to the declarator in golden:
     r10uvm221repro a4_corpus, r10uvm225repro a6_headerforms); the definition-view type-parameter array shapes of
     pass 275 (r11u110repro e25, i09, i11; v11u110repro a11, d01, d02; v11u93b107repro r05).
2. The interface variable typed `q2::row_t` (v11u111repro/brk/f3/x36_iface_sig): golden binds the package listing,
   ours a located `row_t` alias copy (the law-2 face at the variable's typespec).
3. A struct member written with a scoped name of another package's row typedef (B/b05) and a module struct's member
   `q2::row_t [0:1] U` (B/b13, DIVERGENT downstream on both): golden binds the listing object directly in the
   definition listing (no wrapper); § defPkgMemberTdOfNamedShares108 does not fire there.
4. `var struct packed {..} x = 2'b10;` (K/k15): the struct_net span runs to the initializer's end in golden.
5. A class a module declares, in the elaborated instance (N/n19_el): golden names the class_defn `work@sub::outer_c`,
   ours `work@top::s1::outer_c`.
6. Stage 1 on both binaries (moved toward golden or not moved): A/a04, a11, a13, a18, a19, a20, a35, a39, a41;
   B/b06-b12, b14; C/c03, c04 (exit 4 on both), c12, c16; K/k03, k04, k06, k08, k10, k16; N/n04; the
   `localparam p::sa_t P = '0` read by `assign o = P` (r11u108repro and r11u111repro k12_member_arr_dims, golden
   folding to the value).
7. The brief's items (2) to (7) beyond the above, the expression-ground faces behind t12 and b02, and the 139 exit of
   r11v105repro/grid/v09_A_nested_program_in_sub: not attempted.

## Sister-ground faces (reported, not written)

- ParamEmit: § typeParamChainBorrow45's chain copy (6 probe cases), the elaborated cast constant's typespec (5), the
  package struct typedef stretch (6, the live sister's package-net listing item), the `HEX:BEEF` case of a package
  parameter initialised by another (grid A/a08), the program parameter value (A/a29).
- ExprEmit: the hier_path full name behind r11u117repro/grid/g1/t12 (`work@top.f` where golden stores none) and the
  `ref_obj cfg` full name behind v11u117repro/grid/b02.

## Process notes

- **FENCE SLIP**: the first cmds.txt binary audit ran `find <sweep workdir> -name cmds.txt | xargs grep` without
  filtering the path list by `$FENCED` first, so the grep read the command-line files of the 8 fenced row-modes too
  (command lines only; no fenced source or database was opened, nothing was printed from them). The audit was rerun
  with the path list fence-filtered before any read and those are the numbers reported above.
- Every other path list (byteverify mirrors, controls, probe classification, away census) was fence-filtered before
  any file was opened; every tool call through a variable was guarded with `[ -x ]`; no process was signalled; the
  first byteverify run over a single merged mirror of all three corpora read SELFCHECK 3363 / 3365 (two byte-identical
  databases besides the fixed one) and was rerun per corpus as earlier passes do.
- Binaries frozen under `/tmp/r11u279_bin` (`chmod 555`) before every measurement; the law binary was rebuilt after
  the last comment edit and frozen before the firing census.
- The drivers are copied from tools/probe/r11u277repro/drivers (`gridsum279.py` and the switch lists renamed).
