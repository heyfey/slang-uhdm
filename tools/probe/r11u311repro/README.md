# r11u311 — generate-block interface arrays, ordered interface-element actuals, port-path index bindings (module/type ground)

Base 605ba13f. Five laws in src/ModuleEmit.cpp, each behind its own switch read through src/LawSwitch.h
(`lawOn(311, ...)`), `R11U311_OFF` dropping all five, `R11U311_TRACE=<dir>` logging every firing (and, with an
`_ABSTAIN` tag, every stand-aside). No src/R*.h, no LawState.h section (no state is kept between emitter calls; the two
helpers are static in ModuleEmit.cpp).

Pristine binary md5 f3ed5499d637cc1564fcfaaab8de7e3c (equal to the main tree's build at the base); law binary
76bb9abd618269c50d487cc6049b0cbe; both link slang 12.0.0+545f88b2e.

## The decode

1. **Interface arrays in a generate block.** The module-level member loop of ModuleEmit emitInstance lists each element of
   an interface array under the instance's vpiInterface; emitGenScopes skipped interface arrays outright (`if (!l307 ||
   useInterfacePath(*l307)) continue;`), so a gen_scope never listed `farr[0]`, `farr[1]`. Golden lists them under the
   gen_scope exactly as a single gen-scope interface (gen_scope parent only, no vpiInstance), at the array statement's
   span. The col-0 duplicate Surelog writes for the first element when a sibling takes the whole array by its bare name
   (§ ifaceArrSliceElemName309 at module scope) is needed there too.
2. **Ordered interface-element actuals.** `child c0 (farr[0], o[0]);` is a udp_instantiation to Surelog's parser
   (§ udpFormNetLvalueFirst176): its FIRST terminal is a Net_lvalue compiled by compileSelectExpression, so the
   elaborated HighConn bit_select spans the whole `farr[0]` (12:15-12:22) while its index constant keeps the index
   token; a named connection, a later terminal, a single-terminal list (a module_instantiation) and a bind directive's
   instantiation keep the index-only span (the shape § udpPosModportPathAtSel305 reads, with the same bind stand-aside).
3. **Index blanks.** The index of an interface-element connection (and of a select actual in a definition-view generate
   statement) is Surelog's compiled index token: `farr[ 0 ]` gives decompile/value `0`/`UINT:0` at the token; ours kept
   the raw text ` 0 ` (a constant with blanks in both views; a ref_obj named ` 0 ` in the definition-view generate
   statement).
4. **Port-path index bindings.** A reference in a select index of a member PATH connected to a child port
   (`sub u (.a(q.f[i]))`) binds the DEFINITION's object of that name (golden: `logic_net work@dut.i` listed under the
   definition module) in the default view, while a plain select `.a(v[i])` binds the elaborated variable: Surelog keeps
   the binding the definition-time compile gave the hier_path's selects. UHDM's elaborator re-binds it in the
   -elabuhdm view. A cast operand keeps the elaborated binding (v11u296repro VH/vh18, VT/vt17).

## Laws

| law | switch | site | statement |
|---|---|---|---|
| § genScopeIfaceArrayElems311 | R11U311_GENIFARR_OFF | ModuleEmit emitGenScopes, the InstanceArray branch | an interface array in a generate block: each element emitted through emitInterfaceInstance, named `arr[i]`, listed under the gen_scope's vpiInterface, parent the gen_scope, no vpiInstance, registered in ifaceInstMap (one dimension, as the module-level path) |
| § genScopeIfaceArrTailDup311 | R11U311_GENIFARRDUP_OFF | same branch | a sibling in the same generate block or in an instantiated generate block nested in it that takes the WHOLE array by its bare name (a single child's interface port, or an instance array's elements slice by slice) makes the first element carry the col-0 duplicate (forceTailDup), named by the element |
| § ifaceElemPosSelWholeSpan311 | R11U311_POSELEMSPAN_OFF | ModuleEmit emitInstance, the interface-array element HighConn (bit_select) | the FIRST terminal of a udp-shaped ordered list (udpShapedInstantiation) spans the whole connection expression; a bind directive's instantiation stands aside (`POSELEMSPAN_BIND_ABSTAIN`) |
| § ifaceElemIdxTextTrim311 | R11U311_IFIDXTRIM_OFF | ModuleEmit: the definition-view interface-element bit_select (ref_module port), the elaborated one (emitInstance) and the definition-view generate statement's select actual | blanks around the index text are dropped from the decompile and value and the select and index sit at the token |
| § hcPathIdxBindsDefNet311 | R11U311_HCIDXDEF_OFF | ModuleEmit emitInstance's module-scope child loop (helper hcPathIdxBindsDefNet311) | every ref_obj inside a select index (bit_select, part_select bounds, indexed_part_select base/width, var_select indices; through operations, nested bit_select indices and system-call arguments, not through a cast) of a hier_path HighConn of a module or program child, bound to an object of the elaborated parent, is re-bound to the parent definition's net (then variable) of that name; a bound child stands aside (`HCIDXDEF_BIND_ABSTAIN`, logged for every bound child), a cast operand too (`HCIDXDEF_CAST_ABSTAIN`) |

## Cases (every first line names its law)

- GI (39 dirs): g01_if_two_singles, g03_range_desc, g04_range_asc, g05_unused, g06_two_dim, g07_used_outside,
  g08_case_gen, g09_nested_gen, g10_uninst_if0, g11_two_arrays, g12_in_submodule_twice, g13_hier_assign,
  g14_param_iface, g18_generic_port, g19_modport_conn, g20_modlevel_ctl, g21_single_in_gen_ctl, g23_genfor_index,
  g24_param_size, g25_program_user (§ genScopeIfaceArrayElems311); g02_for_arr_slice, g15_whole_to_arrport,
  g16_slice_nested_sibling, g17_slice_second_array (§ genScopeIfaceArrTailDup311); g22_positional (§
  genScopeIfaceArrayElems311), g26_pos_genfor_idx, g27_pos_modlevel, g28_pos_spaces, g30_pos_param_idx,
  g31_pos_genfor_expr, g32_pos_second_port, g33_pos_single_terminal_ctl, g34_pos_bind_ctl, g35_pos_three_terminals
  (§ ifaceElemPosSelWholeSpan311); g29_named_spaces, g36_named_tab, g37_gen_named_spaces, g38_genfor_spaces,
  g39_gen_vec_port_spaces (§ ifaceElemIdxTextTrim311).
- HB (24 dirs, § hcPathIdxBindsDefNet311): b01_int_idx, b02_logic_idx, b03_nested_parent_twice, b04_param_idx_ctl,
  b05_two_refs_op, b06_reg_idx, b07_iface_path, b08_plain_sel_ctl, b09_nested_struct_two_idx, b10_genvar_child_ctl,
  b11_partsel_bounds, b12_program_child, b13_gen_parent, b15_localvar_shadow_name, b16_bind_path, b17_const_idx_ctl,
  b18_cast_idx_ctl, b19_concat_ref, b20_cast_plus_ref, b21_sys_call_idx, b22_member_idx_ctl, b23_enum_idx_ctl,
  b24_nested_sel_idx, b25_ternary_two_refs.

## Grid (drivers/grid.sh via drivers/pgrid.sh, evidence/grid.txt, evidence/gridsum.txt; every line carries rc=)

- 63 dirs, 126 case-views (both views) on pristine, law, `R11U311_OFF` and the law with each switch off.
  **94 moving, 70 entering STRICT_EQUAL, 0 leaving**, 0 exit-code changes; `R11U311_OFF` gives pristine's bytes on
  126 of 126.
- GI: 78 case-views, 64 moving, 54 entering. HB: 48 case-views, 30 moving, 16 entering (the 14 other HB movers are the
  -elabuhdm views, STRICT_EQUAL on both binaries).
- Restored by exactly one switch: GENIFARR 40, HCIDXDEF 30, POSELEMSPAN 10, IFIDXTRIM 8. Six case-views need a pair
  (g22_positional both views GENIFARR + POSELEMSPAN, g28_pos_spaces POSELEMSPAN + IFIDXTRIM, g37_gen_named_spaces
  GENIFARR + IFIDXTRIM). GENIFARRDUP sits inside GENIFARR (GENIFARR_OFF restores pristine alone); dropping
  GENIFARRDUP alone moves the bytes of 8 case-views (g02, g15, g16, g17 both views).
- Movers staying at uhdm-cmp stage 1 (wrong on pristine too, chain away 0): g07_used_outside (the elaborated view
  157 -> 44 lines; head now a hier_path actual `g.farr[0]`, residue 2), g15_whole_to_arrport (the definition view of
  `recv`'s `p[0].sig[0]`, unrelated), g18_generic_port (generic interface port, residue), g19_modport_conn (`farr[0].mp`,
  el 42 -> 46 lines, 18 records toward golden), g30_pos_param_idx (`farr[P-1]`: golden folds the index to INT 0, the
  fold of § genvarIdxFoldRerender14 is gated on a genvar read; residue 3).
- Unmoved: the controls (g20, g21, g32, g33, b08, b10, b13, b17, b18 STRICT_EQUAL on both; g34 a bind at line, b23 an
  enum constant at fullname, both other faces) and the stage-1 shapes g06 (a two-dimensional interface array: the
  module-level twin is stage 1 on pristine too), g10, b04, b16 (golden lists no bound child), b22.
- Away-moved census (drivers/awaycv.sh, chain-keyed and order-blind, evidence/away_grid.txt): lost 0, chain away 0,
  flat away 0 on all 94 movers, 1290 records toward golden; the positive control (binaries swapped, 12 entering movers,
  evidence/away_poscontrol.txt) reads away on 12 of 12.

## The targeted residues

- r11u309repro/cases/TS/s05_gen_inner_slice: stage 1 (75 lines) -> **STRICT_EQUAL** in both views.
- r10vrgg3repro/x5_iface_in_generate: stage 1 (467 lines) -> **STRICT_EQUAL** in both views (488 and 945 objects).
- v11u309repro VZ/vz05_iface_arr_size_in_gen (745 / 921 lines) and VF/vf19_gen_arr_two_mods (60 lines): stage 1 ->
  **STRICT_EQUAL** in both views.
- r11u296repro HC (pass 296's residue 1, the default-view index binding): hc01, hc02, hc07, hc12, hc13, hc17, hc18,
  hc19 and hc20 depth -> **STRICT_EQUAL** in the default view (the elaborated views were already STRICT_EQUAL); with
  v11u296repro VH vh04, vh05, vh06, vh07, vh08, vh09, vh12, vh13, vh22, vh25 (both views), vh26 and r11u280repro
  VR/r27_portactual, r11v133repro tix/a10_port_conn, r11v178repro hx/x20_sub_inst_port.

## Firing scan and byte controls

- Firing scan (drivers/firescan.sh, law binary, default view, evidence/firing_law.txt): 26589 fence-filtered
  tools/probe dirs, 84 firing, 37 of them earlier dirs; the one exit 139 is
  v11u112repro/grid/brk2/k/m07_hdr_enum_default, crashing on pristine too.
- The 37 earlier firing dirs in both views (drivers/controls.sh, evidence/controls_firing.txt and
  controls_firing_sum.txt): 74 case-views, all moving in bytes, **34 entering STRICT_EQUAL, 0 leaving**, 0 exit-code
  changes; away census lost 0, chain away 0, flat away 0 on all 74 with 944 records toward golden
  (evidence/away_controls.txt). Entering: r10vrgg14repro/cells/v10 (both views), r10vrgg3repro/x5_iface_in_generate
  (both), r11u280repro VR/r27_portactual, r11u296repro HC hc01, hc02, hc07, hc12, hc13, hc17, hc18, hc19, hc20,
  r11u309repro TS/s05_gen_inner_slice (both), r11v133repro tix/a10_port_conn, r11v178repro hx/x20_sub_inst_port,
  v11u296repro VH vh04, vh05, vh06, vh07, vh08, vh09, vh12, vh13, vh22, vh25 (both), vh26, v11u309repro VF/vf19 (both)
  and VZ/vz05 (both).
- Control movers not entering (all wrong on pristine too, chain away 0): r11u143verify p133_hpmid/hm04_port_actual,
  r11u168repro H/h06, r11u296repro HC/hc06 and v11u296repro VH/vh20 (fullname on both: the bare reference indexing the
  path's FIRST select, pass 296's residue 2), hc05 (positional), r11u39repro/a2, v11u280repro VA/va25, vh15 and vh16
  (stage 1, same line count).
- A draft without the cast abstention moved v11u296repro VH/vh18_cast_in_port_idx and VT/vt17_rhs_and_port out of
  STRICT_EQUAL (golden keeps a cast operand bound to the elaborated net); the law stands aside under a cast and both
  are byte-identical to pristine with the final binary (they no longer fire).
- Standard byte controls over passes 118, 119, 120, 124 and 131 (r11u118repro r11v11u118repro r11u119repro
  r11u120repro r11v120repro r11u124repro r11v124repro r11u131repro r11v131repro; evidence/controls_earlier.txt and
  controls_earlier_sum.txt): 720 dirs, 1440 case-views, **0 moving**, 0 exit-code changes.

## Gates (tests/sweep.sh --jobs 3; both sweeps exit 1 on the law-index check alone, the index regenerated at the end)

| sweep | probe | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|
| pristine / law | EQUAL 4015 + STRICT_NOTEQUAL 72; regressions 0, conversions 0, changes 0 | 480 + 0 / 474 + 0; 0/0/0 | 803/1/67 both modes; 0/0/0 | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; both csvs byte-identical to the committed one |

- Row diff law vs pristine (workdir path normalised): 0 lines in probe.csv, surelog.csv, uhdm2rtlil.csv and
  downstream.csv; no strict column moves.
- Firing census frozen before the law sweep (drivers/tracecensus.sh, evidence/predict.txt): **no corpus row-mode and no
  probe database fires** a writing tag (the only tags are HCIDXDEF_BIND_ABSTAIN on 21 bound children: probe
  r10earl54repro/v13_v54, r10v92repro/v5_home, r10vearl95repro/v95f_bind, r10vearl98repro/v4b_bind98,
  r10vrgg16repro/cells/v14 and the surelog rows AssertDelayError and AssertTempError in both modes). Positive control:
  the same harness run with R11U309_TRACE on tests/probe r10rgg9repro/cells/c_iface_body writes pass 309's
  ifFillArmSharesDefOperand309 line, so the trace variable reaches the binary through check_probe.py.
- byteverify on fence-filtered mirrors (drivers/bvmirror.sh, tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1):
  **0 of 3365** corpus and downstream databases move (SELFCHECK 3363 of 3365, the known twin
  downstream/1DUnpackedArray = uhdm2rtlil testflags 1DUnpackedArray); probe **0 of 4087** databases move, as predicted.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both.
- Binary audit: 3323 cmds.txt per sweep, 3273 naming the sweep's own binary, 0 the other, 0 the main tree's, 50 running
  no slang.
- Determinism (drivers/det.sh, evidence/det.txt): three concurrent draws, one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, each equal to the law sweep's.
- uhdm-cmp stays at 0 lines on every corpus row and probe case (no database moves).


## Residues (ranked; all wrong on pristine too)

1. pass 296's residue 2 on the same ground: a bare reference indexing the path's FIRST select under a port
   (`.a(qa[i].f[0])`, HC/hc06, VH/vh20, hm04, h06; fullname, golden `work@dut.u.a.qa[i].f[0].i`), and the positional,
   call and class-specialization index shapes at stage 1 (hc05, hc14, hc22, hc23, vh15, vh16).
2. A hier_path actual naming an element of a generate-block interface array from outside the block
   (`child c0 (.p(g.farr[0]))`, GI/g07_used_outside): golden's definition view writes bit_select `farr` at the index
   token with full name `work@top.c0.p.g.farr[0].farr`, the elaborated view the same bit_select where ours writes a
   ref_obj `farr[0]`; ModuleEmit, the hier_path HighConn of an interface port.
3. A parameter-only operation index of an interface element (`farr[P-1]`, g30): golden folds the index constant to the
   reduced value (INT 0, size 64) where § genvarIdxFoldRerender14 folds only genvar reads; ModuleEmit emitInstance.
4. Two-dimensional interface arrays (g06 in a generate block and its module-level twin): stage 1 on both binaries
   (Surelog writes an implicit `farr` logic_net in the gen_scope); a modport-qualified element actual `farr[0].mp`
   (g19) and a generic interface port (g18) at stage 1; a bound instance's path index (b16: golden lists no bound
   child, nothing measures it).
5. The rest of the brief's module/type residue list stands as passes 305 to 309 left it (v12's elaborated view, the
   whole-array slices, the connection-net order, the program arrays, the nested definition listings, the udp
   terminals of § nestedPosInstUdp307 and the others named there).

Sister-ground faces: none written. The 72 gated STRICT_NOTEQUAL probe cases were re-read on pristine
(evidence/sne72_pristine.txt, first record per case): none is reached by these laws (the firing census names no probe
case); r10uvm79repro/c2_idxkind (a class-function hier_path select spanning its whole select in golden, ExprEmit) is the
sister's.

## Process

Pristine frozen before any edit; drafts d1 to d12 frozen as they were built; the law binary (d12) frozen before the
firing scan, the predictor, the grid, the controls and the law sweep; the predictor written after the last law. Every
driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh and filters path lists before opening a file;
every tool call went through a guarded environment script.

One slip, no fenced read, nothing written: my first case loop passed absolute paths to a `$T/$c` join, so case.sh got a
non-existent path, `realpath` returned nothing and its hash step ran `find . | sort | xargs md5sum` from $HOME. I killed
my own processes within two minutes; the sorted md5sum had reached only ~/.cache (every error line names
./.cache/google-chrome or ./.cache/bazel, none names git-repos or a fenced test), so no corpus source or database was
read; the find listed path names only. case.sh now refuses anything but a case dir (`case.sh: not a case dir`). No
other agent's process was touched and nothing was written outside the worktree, /tmp/r11u311_* and my scratchpad.

A draft without the cast abstention moved v11u296repro VH/vh18_cast_in_port_idx and VT/vt17_rhs_and_port out of
STRICT_EQUAL in the default view; a draft without the bind abstention re-bound HB/b16_bind_path where golden lists no
bound child; both fixed before the law was frozen.

