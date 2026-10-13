# v11u311 — adversarial verification of r11u311

Base 605ba13f (pass 309). Implementer patch: five laws in src/ModuleEmit.cpp read through src/LawSwitch.h
(§ genScopeIfaceArrayElems311 R11U311_GENIFARR_OFF, § genScopeIfaceArrTailDup311 R11U311_GENIFARRDUP_OFF,
§ ifaceElemPosSelWholeSpan311 R11U311_POSELEMSPAN_OFF, § ifaceElemIdxTextTrim311 R11U311_IFIDXTRIM_OFF,
§ hcPathIdxBindsDefNet311 R11U311_HCIDXDEF_OFF; R11U311_OFF drops all five; R11U311_TRACE=<dir> logs the firings).
The law statements, the decode and the implementer's grid are in tools/probe/r11u311repro/README.md.

**Verdict: the laws stand.** No fresh case where pristine was right and the law wrong was found: 88 fresh case dirs,
176 case-views, 154 moving, 86 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, chain-keyed and flat away 0 on all
154 movers, no downstream verdict worse. So there is no production refinement and no fixOn switch.

There is one correction, to tracing only. The definition-view generate branch of § ifaceElemIdxTextTrim311 moved the
select's location with no trace line when the index had leading blanks only (`farr[ 1]`). The fix sends the whole text to
trimIdx311, so the trace fires whenever the text changes; the resulting index and location are unchanged. Evidence:
VT/vt12_uninst_branch_lead_blank, an `if (0)` branch where only the definition view writes the select, wrote different
bytes from pristine with an empty trace dir under the implementer's binary; under the corrected binary it logs two
`defgen` lines with the same bytes.

Byte identity of the correction:
- On the cases: the corrected binary equals the law binary on 302 of 302 grid case-views (both grids, both views;
  evidence/fix_vs_law.txt).
- On the corpora: a full four-stage sweep with the corrected binary reads byteverify 0 of 3365 corpus and downstream
  databases moving against the law sweep, and 0 of 4087 probe databases.

## Binaries (built here with -j 2, frozen before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine (605ba13f) | f3ed5499d637cc1564fcfaaab8de7e3c | equal to the brief's main-tree build at the base |
| law (/tmp/r11u311.patch) | 76bb9abd618269c50d487cc6049b0cbe | equal to the implementer's |
| fix (law + the trace correction) | 98fe398addf57207314fc94a69741890 | byte-identical outputs to law |

All three link slang 12.0.0+545f88b2e. The uhdm-strictcmp build is fa6e4f42f252ae0ab69d9845003e71c5 and strictcmp_x
(drivers/cc_x.sh) is 886f030233ecdbcce7d0e29ac0c4df2c.

## Reproduction of the implementer's numbers

- **Grid** (drivers/pgrid.sh over r11u311repro/cases, evidence/impl_grid_repro.txt):
  - 1008 of 1008 lines match the implementer's grid.txt on every field but md5 (case, view, configuration, cmp,
    cmplines, strict, rc).
  - 126 case-views, 94 moving, 70 entering, 0 leaving; R11U311_OFF equals pristine on 126 of 126.
  - Single-switch attribution: GENIFARR 40, HCIDXDEF 30, POSELEMSPAN 10, IFIDXTRIM 8. Pairs on g22, g28 and g37.
- **Gate sweeps** (tests/sweep.sh --jobs 3, pristine P, law L, fix F, one worktree; evidence/gates.txt):

  | stage | result (P, L and F alike) |
  |---|---|
  | probe | EQUAL 4015 + STRICT_NOTEQUAL 72; regressions 0, conversions 0, changes 0 |
  | surelog | 480 + 0 / 474 + 0; 0/0/0 |
  | uhdm2rtlil | 803/1/67 in both modes; 0/0/0 |
  | downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; all three downstream.csv files byte-identical to results/downstream_uhdm2rtlil.csv |

  - The probe, surelog and uhdm2rtlil csvs differ by 0 lines from P, for both L and F (workdir normalised), so no
    strict column moves.
  - The L and F sweeps exit 1 on the law-index check alone, because the case set grew under them. The index was
    regenerated last.
- **byteverify** (drivers/bvmirror.sh fence-filtered mirrors, SELFCHECK=1):
  - L vs P: 0 of 3365 corpus and downstream databases move.
  - SELFCHECK flags 3363 of 3365. The one twin is downstream/1DUnpackedArray = uhdm2rtlil/testflags/1DUnpackedArray,
    the known pair.
  - Probe databases (the same worktree path in both sweeps): 0 of 4087 move. All of this is as predicted.
- **Firing census** (drivers/tracecensus.sh with the fix binary, so every writing branch traces):
  - predict.txt is empty: no corpus row-mode and no probe database fires a writing tag.
  - The trace dir holds exactly the implementer's 21 HCIDXDEF_BIND_ABSTAIN lines:
    - 7 probe lines (v13_v54 twice, v5_home, v95f_bind, v4b_bind98, cells/v14 twice).
    - The surelog rows AssertDelayError and AssertTempError, both modes.
    - The uhdm2rtlil rows BindModule, BindModuleWithInputPorts, BindModuleWithOutputPorts, mriscv_bind_sva and
      sva_basic02, both modes.
  - Because the trace reaches the binary through both harnesses, these lines are the census's own positive control.
- **Canaries:** surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both.
- **Binary audit:** each sweep has 3323 cmds.txt. In each, 3273 name that sweep's own binary, 0 name another binary
  (pristine, law, fix or the main tree's), and 50 run no slang.
- **Determinism** (drivers/det.sh, three concurrent draws per row-mode; evidence/det.txt): one hash per row-mode on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Each hash equals the law sweep's
  and the implementer's det.txt. The fix binary gives the same hashes (evidence/det_fix.txt).
- **Firing scan** (drivers/firescan.sh, law binary; evidence/firing_law.txt):
  - 26667 fence-filtered tools/probe dirs: the implementer's 26589 plus 78 of this dir at that time.
  - 152 fire: 47 in r11u311repro, 68 in v11u311repro, and 37 earlier dirs identical to the implementer's 37
    (evidence/firing_earlier37.txt).
  - One exit 139, v11u112repro/grid/brk2/k/m07_hdr_enum_default, which exits 139 on pristine too.
- **The 37 earlier firing dirs in both views** (evidence/controls_firing*.txt, away_controls.txt):
  - 74 case-views, 74 moving, 34 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 8 uhdm-cmp line-count changes.
  - The mover and entering set is the implementer's.
  - Away census: lost 0, chain away 0, flat away 0 on all 74, with 944 records toward golden.
- **Standard byte controls** (passes 118, 119, 120, 124 and 131, nine repro dirs; evidence/controls_earlier_sum.txt):
  1440 case-views, 0 moving.

## The attack (88 fresh dirs, 176 case-views; evidence/grid.txt, gridsum.txt, away_grid.txt)

Every case is judged by uhdm-cmp against the v1.87 pin, by uhdm-strictcmp field by field (drivers/case.sh, both views,
on the configurations P, L, OFF and each switch off; every line carries rc=), by the away census (drivers/awaycv.sh,
order-blind and chain-keyed), and by the downstream verdict on both binaries (drivers/dscases.py through
scripts/downstream_uhdm2rtlil.py one(); evidence/downstream_cases.txt, which covers the implementer's 63 dirs too).

| group | law | case-views | moving | entering STRICT_EQUAL |
|---|---|---|---|---|
| VG | § genScopeIfaceArrayElems311, § genScopeIfaceArrTailDup311 | 52 | 52 | 30 |
| VP | § ifaceElemPosSelWholeSpan311 | 36 | 28 | 20 |
| VT | § ifaceElemIdxTextTrim311 | 24 | 24 | 14 |
| VH | § hcPathIdxBindsDefNet311 | 64 | 50 | 22 |
| total | | 176 | 154 | 86 |

**Overall:**
- 0 leaving STRICT_EQUAL, 0 exit-code changes (all 1408 lines rc=0), and R11U311_OFF equals pristine on 176 of 176.
- Each mover is restored by exactly one switch (GENIFARR 52, HCIDXDEF 50, POSELEMSPAN 26, IFIDXTRIM 22), except four
  case-views needing a pair: vp07_multiline (POSELEMSPAN + IFIDXTRIM) and vt10_gen_nested_spaces
  (GENIFARR + IFIDXTRIM), both views.
- 22 movers are STRICT_EQUAL on both binaries: the VH elaborated views, where UHDM's elaborator re-binds.
- Away census on all 154 movers: lost 0, chain away 0, flat away 0, with 1648 records toward golden.
- The positive control, with the binaries swapped on 12 entering movers, reads chain away > 0 on 12 of 12
  (evidence/away_poscontrol.txt).

**Downstream on all 151 case dirs:**
- No verdict worse.
- Five go STATUS_DIFF -> IDENTICAL: GI/g02, g16, g17, VG/vg07 and vg14. The slang lane goes READ_FAIL -> NO_GATES, as
  the Surelog lane reads.
- In two, the slang lane goes READ_FAIL -> OK but the verdict stays STATUS_DIFF against the Surelog lane's NO_GATES:
  g15 and vg08.
- The rest are unchanged.

### Cases (each first line names its law)

- **VG** (§ genScopeIfaceArrayElems311):
  - vg01_ifc_with_port, vg02_iface_in_iface_gen, vg03_genfor_nested_idx, vg04_param_size_twice, vg05_single_elem
  - vg06_param_iface_ovr, vg09_case_gen_two_arrays, vg10_gen_in_deep_child, vg11_else_branch, vg12_virtual_ref
  - vg13_unused_with_sibling_net, vg15_modlevel_plus_gen, vg16_bound_target_gen, vg17_genvar_sized
  - vg20_iface_with_gen_inside, vg24_in_iface_array_elem_hier, vg25_nested_module_gen_arr,
    vg26_gen_arr_in_bind_target_scope
- **VG** (§ genScopeIfaceArrTailDup311):
  - vg07_whole_modport_slice, vg08_whole_arrport_single, vg14_slice_two_instance_arrays, vg18_arrport_modport_whole
  - vg19_same_name_outer_array, vg21_slice_part, vg22_genfor_nested_slice, vg23_desc_range_slice
- **VP** (§ ifaceElemPosSelWholeSpan311):
  - vp01_two_in_one_stmt, vp02_param_delay_hash, vp03_named_param, vp04_space_before_bracket, vp05_expr_second
  - vp06_macro_terminal, vp07_multiline, vp08_param_idx, vp09_gen_if_pos, vp10_child_in_submodule, vp11_asc_range
  - vp12_bind_not_first, vp13_iface_second_terminal, vp14_two_iface_terminals, vp15_scalar_iface_first_ctl
  - vp16_genfor_expr_idx, vp17_two_value_delay_form, vp18_arrport_elem_positional
- **VT** (§ ifaceElemIdxTextTrim311):
  - vt01_pos_spaces_modlevel, vt02_tab_and_newline, vt03_comment_idx, vt04_genfor_expr_spaces, vt05_gen_if_spaces_two
  - vt06_crlf, vt07_param_idx_spaces, vt08_arrinst_slice_spaces, vt09_escaped_name_spaces, vt10_gen_nested_spaces
  - vt11_gen_lead_blank_only, vt12_uninst_branch_lead_blank
- **VH** (§ hcPathIdxBindsDefNet311):
  - vh01_port_idx, vh02_output_lvalue_path, vh03_two_children_one_stmt, vh04_inst_array_child, vh05_wire_idx
  - vh06_pkg_var_idx, vh07_iface_inst_path, vh08_array_struct_path, vh09_parent_var_named_like_port
  - vh10_parent_in_gen_twice, vh11_enum_var_idx, vh12_unary_and_bin, vh13_ternary_idx, vh14_union_path
  - vh15_two_level_struct, vh16_signed_cast_func, vh17_genvar_parent_body_var, vh18_var_and_net_same_name_ctx
  - vh19_iface_port_path, vh20_mixed_idx_struct_root, vh21_func_call_idx, vh22_iface_child_with_port
  - vh23_child_bound_and_plain, vh24_param_parent_two_widths, vh25_idx_in_partsel_and_member
  - vh26_struct_array_var_idx_root, vh27_top_level_parent, vh28_genblock_var_same_name, vh29_nested_module_parent
  - vh30_two_paths_two_ports, vh31_struct_port_root, vh32_const_var_idx

Draft fixes before any measurement counted:
- Three drafts were not legal SV and were rewritten. The first was an output and inout path with a variable index
  (slang: not a constant expression); it became vh02 with a localparam index and vh09 with a parent variable named
  like the child's port.
- vg13 had an uninstantiated child left as a top with an unconnected interface port.
- vt08 had a slice in the wrong order; it became `farr[ 0 : 1 ]`.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **The interface's port connection under § genScopeIfaceArrayElems311** (vg01_ifc_with_port, fullname(2) in both
   views): for `ifc farr [2] (.clk(clk))` in a generate block, golden names the HighConn ref_obj `work@top.g.clk`, ours
   `work@top.clk`. The site is ModuleEmit emitInterfaceInstance's port-connection naming under genConnPrefix.
2. **Bind naming** (vg16_bound_target_gen, fullname(8)): golden names the bound module's generate-array elements
   `work@top.mb.g.farr[1]`, ours `work@top.t.mb...`. This is the bind display-path face, not this law.
3. **The interface element read from outside its generate block** (GI/g07, vg24, vg12 at fullname: the
   `v = g.farr[1]` virtual-interface assignment, whose naming is on the sister ground in StmtEmit/ExprEmit), plus
   vg02 (an interface array inside an interface's generate block, stage 1).
4. **Interface-array slices and array ports:**
   - vg21: a part slice `farr[0:1]` passed to an instance array, stage 1.
   - vt08: the same slice with blanks. Golden writes a part_select and ours a bit_select on both binaries.
     § ifaceElemIdxTextTrim311 also trims that range text, so bytes move with 0 records toward or away.
   - vg08 and vg18: a whole array into an `ifc p [2]` port, stage 1 at the port's array_typespec.
   - vg17: a genvar-sized array `farr[i+1]`, stage 1.
5. **Positional shapes the span law does not reach:**
   - vp01: two instances in one udp-shaped statement. Golden's second instance reuses the first terminal's index
     constant, a Surelog defect. Stage 1 on both, EQUIVALENT downstream on both.
   - Stage 1 on both, EQUIVALENT downstream: vp06 (a macro terminal), vp08 (a localparam index), vt03 (a comment in the
     index; golden drops it), vt07 (a localparam index with blanks).
   - vp03: `#(.W(1))`, not udp-shaped, stage 1 unchanged.
   - vp18: a positional element of an interface-array port, where the law does not fire. Stage 1, EQUIVALENT.
   - vp12: inside a bound module's body. The law fires, because the bind stand-aside reads only the bound
     instantiation itself. It moved 2 records toward golden and stays at fullname for the bind naming face.
6. **Escaped array names** (vt09, stage 1 -> name(4)): `\farr$x [ 0 ]` keeps the backslash in the bit_select's name,
   where golden writes `farr$x`. The site is ModuleEmit selBase303, the twin of v11u303repro VT/vt07 to vt09.
7. **Index-binding shapes § hcPathIdxBindsDefNet311 does not reach:**
   - Stage 1, unchanged:
     - vh04: an instance-array child.
     - vh17: a for-generate child.
     - vh19: an interface-port path, EQUIVALENT downstream on both.
     - vh21: a user-function index, where golden lists the function formal as a module net.
     - vh22: an interface instance with a port.
   - At fullname:
     - vh25: an operation HighConn, not a hier_path.
     - vh26: the index of the path's first select, pass 296's residue 2.
   - vh32: `int i = 3;` as the index, where golden folds the path to `q.f[3]`; Surelog reads the variable's initializer.
     Stage 1, EQUIVALENT downstream on both. The law rebinding i moves no record either way.
8. **Unrelated stage-1 heads:**
   - vg13: a gen-scope array read by an assign, with the same head on both binaries and the elaborated view's uhdm-cmp
     count 42 -> 46 lines, chain away 0, 27 records toward golden.
   - vg26: the child definition's net type.
   - vt12: the uninstantiated branch; uhdm-cmp grows 2026 -> 2034 lines, the first 30 lines unchanged, 4 records toward
     golden.

Sister ground: vg12's virtual-interface assignment naming (StmtEmit/ExprEmit) is the only face reached on it; it was
reported and not written.

## Process

- Pristine was built and frozen before the law build. Every driver reads $FENCED fail-closed from
  tools/probe/r11u107repro/canaudit.sh and filters path lists before opening a file. dscases.py is new here and is
  fence-checked; the other drivers are copied from r11u311repro, with case.sh's relative-name map extended to this dir.
- The firing census and the corpus runs went through the harnesses with --filter built from $FENCED.
- Nothing was written outside the two worktrees /tmp/wt_v11u311 and /tmp/wt_v11u311pris, /tmp/v11u311_* and the
  session scratchpad. No other agent's process was touched.
- **Slip, no effect:** one wait check ran `pgrep -f dscases.py`, which matched its own shell's command line, so it read
  "running" once after the run had ended. Nothing was killed, and the run's output was re-read by line count.
