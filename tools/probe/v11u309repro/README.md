# v11u309 — adversarial verification of r11u309

Base cee373de. Verifier of pass 309's six ModuleEmit laws (§ ifaceTailDupArrayChild309 R11U309_TAILDUPARR_OFF,
§ ifaceTailDupGenChild309 R11U309_TAILDUPGEN_OFF, § ifaceConnNetArrayChild309 R11U309_CONNNETARR_OFF,
§ ifaceArrSliceElemName309 R11U309_ARRSLICE_OFF, § defGenModArraySizeRange309 R11U309_GENARRSIZE_OFF,
§ ifFillArmSharesDefOperand309 R11U309_IFFILLDEFOP_OFF; R11U309_OFF drops all six). **Verdict: VERIFIED, no
production fix.** No fresh case on legal SV found pristine right and the law wrong, so no R11V309 switch exists and
the verified patch carries the implementer's src/ModuleEmit.cpp unchanged.

## Binaries (built by the verifier, frozen before any measurement)

- pristine (fresh worktree at cee373de): md5 2c0499bc5c68c49e3a4606a43bfefe37, equal to the base binary the brief
  names and to the implementer's.
- law (fresh worktree at cee373de + /tmp/r11u309.patch, a clean apply): md5 c5379532851208184fa072ef72c65188, equal
  to the implementer's. Both report slang 12.0.0+545f88b2e and UHDM 1.87.

## Reproduction of the implementer's numbers (all bit for bit)

- Grid (tools/probe/r11u309repro/drivers/grid.sh on the 42 r11u309repro dirs): 756 lines equal to the implementer's
  grid.txt on every field except the md5 (the md5 covers vpiFile, which holds the worktree path). 84 case-views, 68
  moving, 43 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, R11U309_OFF equal to pristine on 84 of 84; single
  switch IFFILLDEFOP 14, TAILDUPARR 6, ARRSLICE 6, GENARRSIZE 6, TAILDUPGEN 4, CONNNETARR 2; 30 needing two or more.
- Firing scan (the implementer's firescan.sh, law binary, every dut.sv under tools/probe with the path list filtered
  by $FENCED first): 26522 dirs (26443 plus this pass's 79 new dut.sv dirs) and 177 firing; leaving out r11u309repro and
  v11u309repro, exactly the implementer's 67 earlier firing dirs. 395 nonzero exit codes, every one equal on pristine (the
  one 139, v11u112repro/grid/brk2/k/m07_hdr_enum_default, crashes on pristine too).
- The 67 earlier firing dirs in both views (evidence/controls_firing.txt): 134 case-views, 134 moving, 38 entering
  STRICT_EQUAL, 0 leaving, 0 exit-code changes; away census (evidence/away_controls.txt) lost 0 and chain away 0 on
  all 134 with 264 records toward golden.
- The targeted rows: r10vrgg16repro/cells/v12 stage 1 (1836 lines) -> STRICT_EQUAL 769 objects in the default view,
  stage 1 -> STRICT_NOTEQUAL depth in the elaborated view; v11u307repro VA/va08_iface_array_conn stage 1 (34) ->
  STRICT_EQUAL 169 / 189 objects; r11u305repro IU/u01_plain_fill_el, u03_plain_split_el and r11u303repro
  IF/i08_plainlhs_el stage 1 (28) -> STRICT_EQUAL 94 / 121 / 94 objects, their default views STRICT_EQUAL on both.
- Standard byte controls over r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11v120repro,
  r11u124repro, r11v124repro, r11u131repro and r11v131repro: 720 dirs, 1440 case-views, 0 moving and 0 exit-code
  changes (r11v124repro pv/v14_string and qx/q08_string exit 3 with no database on both binaries).
- Gate sweeps (tests/sweep.sh --jobs 3, run from the pristine worktree with SLANG_UHDM exported, workdirs
  /tmp/v11u309_sw_pri and /tmp/v11u309_sw_law; both exit 0): probe EQUAL 4015 + STRICT_NOTEQUAL 72, surelog 480 + 0
  / 474 + 0, uhdm2rtlil 803/1/67 in both modes, regressions 0, conversions 0, changes 0 in all three; downstream 803
  IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, both downstream csvs byte-identical to
  results/downstream_uhdm2rtlil.csv. The surelog, uhdm2rtlil, probe and downstream csvs of the two sweeps are
  identical once the workdir path is normalised, so no strict cell moves on any row-mode.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors built by
  r11u309repro/drivers/bvmirror.sh, 8 fenced paths skipped): MOVERS 0 of 3365. SELFCHECK reads 3363 of 3365 and
  prints SELFCHECK_FAILED; the two unflagged databases are the reference downstream/1DUnpackedArray/slang.uhdm and its
  byte twin uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm (the same test with the same arguments). This
  benign twin is what the implementer left unnamed. Probe databases: 1 of 4087 move, r10rgg9repro__cells__c_iface_body,
  exactly the implementer's frozen predict.txt (ifFillArmSharesDefOperand309), EQUAL on both binaries.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6).
- Binary audit: 3323 cmds.txt per sweep, 3273 naming the sweep's own binary, 0 naming the other.
- Determinism (r11u309repro/drivers/det.sh, three concurrent draws, evidence/det.txt): one hash per row-mode on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen (both modes where the row runs),
  each equal to the law sweep's database and to the implementer's det.txt.

## Attack (83 fresh dirs, 166 case-views; evidence/grid.txt with rc= on every line, evidence/gridsum.txt)

Every case's first line names the law it attacks. Every case-view runs on pristine, the law, R11U309_OFF and each
single switch, in both views; downstream verdicts on both binaries (evidence/downstream_{pri,law}.txt).

- **Totals: 158 moving, 78 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, R11U309_OFF equal to pristine on
  166 of 166.** Single-switch restore: IFFILLDEFOP 36, TAILDUPGEN 24, ARRSLICE 24, GENARRSIZE 20, TAILDUPARR 4; 50
  movers need two or more switches (array cases firing TAILDUPARR with CONNNETARR, generate-block arrays with
  GENARRSIZE). Away census (evidence/away_grid.txt, chain-keyed with the order-blind distance): lost 0 and chain away 0
  on all 158 movers, 556 records toward golden; the positive control (P and L swapped on 12 entering movers) reads
  chain away on 12 of 12.
- Downstream (83 dirs): 10 STATUS_DIFF -> IDENTICAL (vs02, vs03, vs04, vs05, vs07, vs08, vs10, vs11, vs13, vs14), 2
  EQUIVALENT -> IDENTICAL (va09, vs06), 68 IDENTICAL on both, vs01 and vz02 EQUIVALENT on both, va01 DIVERGENT on both;
  no verdict worse.

Cases by law (verdict pristine -> law; s1 = uhdm-cmp stage 1, SE = STRICT_EQUAL):

- VA, § ifaceTailDupArrayChild309: va03_plain_port, va06_two_ports_same_iface, va07_range_form ([1:0]),
  va08_param_ovr_arr, va09_mid_module_twice, va10_arr_and_modport_single, va11_arr_param_iface,
  va12_arr_iface_second, va13_gen_arr_outer_iface_modport_too, va14_macro_conn_tail: s1 -> SE in both views.
  va01_positional_arr (udp-shaped ordered list, exit 4 on both, 771 -> 43 lines), va02_generic_port (458 -> 212),
  va04_iface_array_child (an interface array with an interface port, 524 -> 524 lines), va05_program_arr (157 -> 387
  lines: the law matches golden except the definition-view program module_array, which pristine also writes and
  golden lacks; chain away 0, toward 5): stage 1 on both.
- VG, § ifaceTailDupGenChild309: vg01_case_gen, vg02_genif_else, vg04_positional_gen, vg06_gen_program,
  vg08_nested_gen_iface_in_gen, vg09_mixed_modport_bare, vg10_param_iface_gen, vg12_implicit_gen, vg13_gen_in_mid_twice:
  default view s1 -> SE (elaborated SE on both, bytes move). vg05_gen_iface_child s1 -> STRICT_NOTEQUAL line;
  vg03_named_nested (83 lines, both), vg07_gen_generic (521 -> 34; golden writes a generic port inside a generate block
  as a logic_net, the single-child control vg14_single_generic_ctl is SE on both): stage 1 on both. Controls unmoved:
  vg11_only_modport_gen_ctl, vg14_single_generic_ctl.
- VC, § ifaceConnNetArrayChild309: vc01_arr_then_gen_child, vc04_arr_param_iface_ovr, vc05_arr_multiline_conn,
  vc06_crlf (CRLF line ends), vc08_macro_conn: s1 -> SE. vc03_arr_two_ifaces_ports 552 -> 32 (golden lists the
  connection-site nets in connection order .q(ib), .p(ia), ours in port order; the single-child control
  vc07_single_reversed_ctl shows the same face on both binaries, 32 lines: a pre-existing order face of the
  connection-net loop, not this law's). vc02_gen_child_then_arr 17 lines on both (golden mints work@child.o in the
  child definition, the Surelog implicit-net defect of r11u309repro TA/a14).
- VS, § ifaceArrSliceElemName309: vs02_range_decl, vs03_reversed ([0:1] array into a [1:0] array),
  vs04_two_children_same_arr, vs06_gen_outer_arr, vs10_mid_twice, vs11_elem_and_whole, vs13_macro_slice,
  vs14_paren_slice: s1 -> SE. vs01_2d_slice 838 -> 2842 / 3314 lines (stage 1 on both; chain away 0, toward 1;
  two-dimensional slicing not reached), vs05_generic_slice 598 -> 34, vs07_with_arrport_child 94 -> 94,
  vs08_positional_slice 34 -> 24, vs09_program_slice 227 -> 463 (chain away 0, toward 24), vs12_iface_arr_child_slice
  664 -> 664: stage 1 on both.
- VZ, § defGenModArraySizeRange309: vz01_localparam_size, vz03_2d_size, vz04_case_gen_size, vz06_plain_mod_arr_gen,
  vz07_nested_gen_size, vz10_size_one, vz13_macro_size: s1 -> SE. vz02_genvar_size, vz09_size_paren and
  vz11_param_two_tops 366 lines on both (the head is the implicit net Surelog mints in the leaf definition for a
  parameter-sized generate array, r11u309repro TA/a14's defect), vz08_pkg_param_size 147 -> 48, vz12_program_arr_gen
  111 -> 287 / 345 and vz05_iface_arr_size_in_gen 89 -> 745 / 921 (the law also gives a generate-block INTERFACE array
  its range, clearing pristine's first head, the definition-view module_array range; the walk then reaches the
  elaborated gen_scope, residue 1's interface-array face; chain away 0, toward 5): stage 1 on both.
- VF, § ifFillArmSharesDefOperand309: vf03_fill_x, vf07_delay, vf08_nested_three, vf09_wide (70 bits),
  vf10_struct_lhs, vf11_port_view, vf13_signed_lhs, vf18_paren, vf20_ternary_param_cond: elaborated view s1 (28) -> SE,
  default view SE on both. vf01_diff_width / vf02_diff_width_rev (W=4 and W=8 sharing one definition operand),
  vf04_fill_z, vf05_iface_array, vf06_in_gen, vf12_true_branch_ovr, vf14_int_lhs, vf16_mod_twice, vf17_two_cells: SE on
  both views and both binaries, bytes moving, downstream IDENTICAL on both. vf15_nda (a net declaration assignment;
  the law does not reach it) unmoved at stage 1. vf19_gen_arr_two_mods moved by GENARRSIZE only (60 lines on both).

## Residues (ranked; all wrong on pristine too)

1. The interface-array path in a generate block (the implementer's residue 1): vz05 and vf19 now reach it, its first
   element's col-0 duplicate not minted (ModuleEmit emitGenScopes).
2. Two-dimensional whole-array slicing vs01 and the interface-array child vs12 (ARRSLICE handles one dimension of
   module children only).
3. The connection-site net order: golden follows the connection order, ours the port order (vc03 and the
   single-child control vc07; the connection-net loop in ModuleEmit emitModuleDef).
4. Generic interface ports: inside a generate block golden writes the port as a logic_net (vg07), and the array forms
   va02 and vs05 stay at stage 1.
5. Program arrays (va05, vs09, vz12): golden lists no definition-view module_array for a program array.
6. Surelog's implicit net in a child definition for parameter-sized generate arrays (vz02, vz09, vz11, vc02; the
   implementer's a14): a defect, not copied.
7. vf15: an interface net declaration assignment with a fill branch, outside the fill law.

No sister-ground face reached (no ExprEmit, ParamEmit, StmtEmit or EmitHelpers.h site read or written).

## Process

Two fresh worktrees at cee373de (/tmp/wt_v11u309pris, /tmp/wt_v11u309); pristine built and frozen before the patch
was built; both binaries frozen at read-only paths before any measurement. The implementer's drivers
(tools/probe/r11u309repro/drivers) were used as delivered, each reading $FENCED fail-closed; drivers/gridsum.py
reads only grid text. No database or source of a fenced test was opened; every corpus scan filtered its path list
first. No process of another agent was listed or touched; nothing was written outside the two worktrees and
/tmp/v11u309_*.
