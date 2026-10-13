# v11u313 — adversarial verification of r11u313

Base 71ee56cf (pass 311). Verdict: **ACCEPT, no production change.** The four laws of r11u313 in src/ModuleEmit.cpp
(§ genIfaceConnGenScopeName313 `R11U313_GENIFCONN_OFF`, § genIfaceParentAtBirth313 `R11U313_GENIFBIRTH_OFF`,
§ ifaceHcSelNamedByInst313 `R11U313_HCSELINST_OFF`, § genIfaceHcInnerRefUnbound313 `R11U313_GENIFHCUNBIND_OFF`;
`R11U313_OFF` drops all four) are delivered as the implementer wrote them. No fresh case was found where pristine was
right and the law wrong, so this pass adds no switch and no source line. Its surface is this directory and the
regenerated tests/LAWS.md.

## Binaries (built in two fresh worktrees at 71ee56cf with -j 2, frozen with chmod 555 before any measurement)

| binary | md5 |
|---|---|
| pristine | 7350caade5ac8f411d370d9029b7d462 (equal to the main tree's build/slang-uhdm) |
| law (r11u313's patch applied) | a8ee6fc02b5b65fa90772107fa722afa (equal to the implementer's) |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 |
| strictcmp_x (r11u313repro/drivers/cc_x.sh) | 886f030233ecdbcce7d0e29ac0c4df2c |

Both slang-uhdm binaries report slang 12.0.0+545f88b2e. The case drivers are r11u313repro's (case.sh, grid.sh,
pgrid.sh, gridsum313.py, awaycv.sh, awaycorp.sh, controls.sh, ctlsum.py, dscases.py, det.sh, firescan.sh,
bvmirror.sh), run from this checkout with this pass's own binaries and scratch. drivers/pred313.cpp is this pass's own
mover predictor (below). Every helper reads $FENCED fail-closed, and every tree scan filters its path list before
opening a file.

## Reproduction of the implementer's numbers

- **Grid** (r11u313repro GP 49 dirs, GQ 19 dirs, both views; evidence/gridsum_impl_repro.txt): the 952 lines equal
  the implementer's grid.txt on 952 of 952 lines apart from the md5 field (which hashes a database holding its
  worktree path). All rc=0. 136 case-views, 118 moving, 68 entering STRICT_EQUAL, 0 leaving, `R11U313_OFF` equal to
  pristine on 136 of 136. Restored by one switch alone: GENIFCONN 22, HCSELINST 34, GENIFBIRTH 6; 56 need two or more.
- **Away census** on the 118 grid movers (evidence/away_impl_repro.txt): lost 0, chain away 0, flat away 0, 176
  records toward golden. The positive control (binaries swapped) on 12 entering movers reads chain away > 0 on 12 of 12
  (evidence/away_poscontrol.txt).
- **Firing scan** (firescan.sh with the law binary; evidence/firing_law.txt): 26992 fence-filtered tools/probe dirs
  (the implementer's 26942 plus this pass's first 50 dirs), 251 firing. The 144 earlier dirs are the implementer's
  firing_earlier.txt line for line. The rest are 59 r11u313repro dirs and 48 of this pass's. The one exit 139 is
  v11u112repro m07_hdr_enum_default, which also crashes on pristine. All 395 nonzero exits of the scan give the same
  exit code on pristine.
- **The 144 earlier firing dirs, both views** (evidence/controls_firing_sum.txt, away_controls.txt): 288 case-views,
  152 moving, 14 entering STRICT_EQUAL, 0 leaving, no exit-code or uhdm-cmp line-count change. Away census on the
  152: lost 0, chain away 0, flat away 0, 89 toward. The 14 entering: v11u311repro VG/vg01_ifc_with_port (the target,
  both views), r11u251repro BP/b09_bitsel, v11u254repro H/vh04_qual_iface, v11u283repro VI/vi07_gen_param and
  vi14_direct_gen_direct (both views each), v11u293repro VI/vi06_gen_parent (both views), vi21_gen_iface_modport and
  vi22_for_gen_two (elaborated view). The only other verdict change: v11u307repro VG/vg01_iface_pos_gen fullname ->
  line in both views (toward).
- **Standard byte controls** (r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131 and r11v131
  repro dirs; evidence/controls_std_sum.txt): 1440 case-views, 0 moving.

## Mover prediction (frozen before the law sweep; evidence/predict_v313.txt)

This pass did not reuse the implementer's trace census. drivers/pred313.cpp reads the PRISTINE databases and applies
the laws' structural trigger:
- GEN: an interface_inst whose parent is a gen_scope (GENIFCONN, GENIFBIRTH and GENIFHCUNBIND can only act there);
- SEL: an interface_inst port whose HighConn is a bit_select, indexed_part_select, operation, or a hier_path of two or
  more elements (HCSELINST).

The predictor ran over the pristine sweep's 7452 fence-filtered databases (8 fenced paths skipped before opening). The
positive control on fresh databases reads GEN and SEL where expected. It names 13 databases: surelog Rggen/default
(GEN=305) and 12 probe databases, every one GEN-only. This is exactly the implementer's trace-census set. No SEL
trigger exists in any gate database, so HCSELINST and GENIFHCUNBIND cannot move a gate row.

## Gates (evidence/gates.txt)

tests/sweep.sh --jobs 3 ran on pristine (from the pristine worktree) and on the law (from the law worktree), with
workdirs of equal length:

| stage | pristine | law |
|---|---|---|
| probe | 4017 + 70, 0/0/0 | 4017 + 70, 0/0/0 |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | 480 + 0 / 474 + 0, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | 803/1/67 both modes, 0/0/0 |
| downstream | 803/66/2/0 | 803/66/2/0 |

- Both sweeps exit 1 on the law-index check alone. At the base the index lacks the base commit's own hash; in the law
  worktree this pass's cases had not yet been indexed.
- The csv row diff law vs pristine is 0 lines in all four csvs, so every strict column is unchanged. Both downstream
  csvs are byte-identical to results/downstream_uhdm2rtlil.csv.
- **byteverify** (r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors):
  - corpus and downstream: 1 of 3365 databases move, surelog Rggen/default (predicted). SELFCHECK flags 3363 of
    3365; the pair not flagged is the 1DUnpackedArray twin.
  - probe: the pristine probe stage was rerun from the law worktree, because a probe database embeds its worktree
    path; the workdir string was normalised. 5 of 4087 databases move, all predicted and all EQUAL on both binaries:
    r10rgg16repro cells/g1, r10vrgg16repro cells/v8, r10vrgg3repro z1_single_genfor_named, r11u115repro
    grid/i/o05_nmp_samegen_ctl and v11u115repro grid/f2b/q01_genfor_same_iter.
- **Rggen/default direction.** The strict walk does not reach the moved objects (away census 0/0, column `equal` on
  both). An interface_inst census with r11u313repro's objinfo reads:
  - golden: 305 column-0 duplicates under a gen_scope and 455 under a module_inst;
  - pristine: 760 under a module_inst;
  - law: the same as golden.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, and ctcan2 PASS on both csvs of both sweeps.
- Binary audit: in each sweep, 3273 of 3323 cmds.txt name the sweep's own binary, and 0 name the other binary, the
  main tree's or the implementer's worktree.
- **Determinism** (det.sh, three concurrent draws with the law binary; evidence/det.txt): one hash per row-mode on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen (12 row-modes). Each equals the law
  sweep's database.

## The attack: 77 fresh case dirs in both views (cases/VM 37, cases/VG 40)

Each case is judged three ways: by uhdm-cmp and uhdm-strictcmp against Surelog v1.87, by the chain-keyed and
order-blind away census, and by the downstream verdict on both binaries (evidence/grid_fresh.txt, gridsum_fresh.txt,
away_fresh.txt, downstream_fresh.txt). All 1078 grid lines carry rc=, and every one is rc=0. Six first drafts left the
child module unused (slang rejects a top-level module with an unconnected interface port, exit 3 on both binaries).
They were corrected before measuring, and the final grid holds only the corrected cases.

**Totals:**
- 154 case-views, 144 moving, 69 entering STRICT_EQUAL, 0 leaving.
- `R11U313_OFF` equal to pristine on 154 of 154.
- Restored by one switch alone: HCSELINST 68, GENIFBIRTH 4, GENIFCONN 4. The other 68 need two or more (the
  generate-block cases fire GENIFCONN, GENIFBIRTH and GENIFHCUNBIND together).
- Away census on all 144 movers: lost 0, chain away 0, flat away 0, 208 records toward golden.
- Downstream on all 77 dirs: no verdict moves. 72 IDENTICAL, 3 EQUIVALENT (vg01, vm06, vg27), 1 DIVERGENT (vm10) and
  1 STATUS_DIFF (vg39), the same on both binaries.

**Shapes covered:**
- module level: nested parents, two parents, a parameter or package-parameter index, unary, ternary and nested
  operations, a reduction over a concatenation, function and system calls, casts, replication, two ports, positional
  connections with several ports, macros, CRLF, a bind, hierarchical actuals into a child instance, another interface
  and an interface port, packed-struct and unpacked-array selects, descending ranges, interface arrays, an interface
  inside an interface, and an interface passed to an interface port;
- generate blocks: if, else, case and two-level for generate, generate inside a generate-block child, genvar and
  parameter-override forms, modport-qualified connections, unconnected ports, gen-local operands, sibling-scope
  hierarchical reads of the interface, a bind into a module holding a generate-block interface, an interface body
  with part-select writes, and an interface in a generate block of an interface itself in a generate block.

| case | § law | default view | elaborated view | downstream (both binaries) |
|---|---|---|---|---|
| VG/vg01_funccall_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | EQUIVALENT |
| VG/vg02_syscall_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg03_hier_actual_gen | § genIfaceConnGenScopeName313 | fullname -> EQ 156 (pair) | fullname -> EQ 174 (pair) | IDENTICAL |
| VG/vg05_parent_twice | § genIfaceConnGenScopeName313 | fullname -> EQ 303 (pair) | EQ 340 -> EQ 340 (pair) | IDENTICAL |
| VG/vg06_gen_in_genchild | § genIfaceHcInnerRefUnbound313 | stage1 -> fullname (pair) | stage1 -> EQ 248 (pair) | IDENTICAL |
| VG/vg07_noport_dup | § genIfaceParentAtBirth313 | EQ 79 -> EQ 79 (GENIFBIRTH) | EQ 85 -> EQ 85 (GENIFBIRTH) | IDENTICAL |
| VG/vg08_forgen_genvar_op | § genIfaceHcInnerRefUnbound313 | fullname -> EQ 246 (pair) | EQ 284 -> EQ 284 (pair) | IDENTICAL |
| VG/vg09_cast_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> fullname (pair) | stage1 -> fullname (pair) | IDENTICAL |
| VG/vg10_replication_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> EQ 146 (pair) | stage1 -> EQ 165 (pair) | IDENTICAL |
| VG/vg11_param_ref_gen | § genIfaceConnGenScopeName313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg12_outer_hier_read | § genIfaceParentAtBirth313 | fullname -> EQ 167 (pair) | fullname -> EQ 221 (pair) | IDENTICAL |
| VG/vg13_casegen_varidx | § genIfaceHcInnerRefUnbound313 | stage1 -> EQ 165 (pair) | stage1 -> EQ 184 (pair) | IDENTICAL |
| VG/vg14_unpacked_varidx_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> EQ 165 (pair) | stage1 -> EQ 184 (pair) | IDENTICAL |
| VG/vg15_nested_bitsel_idx | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg16_iface_gen_in_iface | § genIfaceConnGenScopeName313 | stage1 -> fullname (pair) | fullname -> fullname (pair) | IDENTICAL |
| VG/vg17_after_gen_modchild | § genIfaceHcInnerRefUnbound313 | stage1 -> EQ 209 (pair) | stage1 -> EQ 226 (pair) | IDENTICAL |
| VG/vg18_modlevel_after_gen | § ifaceHcSelNamedByInst313 | fullname -> depth (HCSELINST) | fullname -> EQ 214 (HCSELINST) | IDENTICAL |
| VG/vg19_rooted_hier_gen | § genIfaceConnGenScopeName313 | fullname -> EQ 144 (pair) | fullname -> EQ 163 (pair) | IDENTICAL |
| VG/vg20_for_in_if | § genIfaceHcInnerRefUnbound313 | stage1 -> fullname (pair) | stage1 -> EQ 281 (pair) | IDENTICAL |
| VG/vg21_gen_local_op | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg22_array_varidx_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> EQ 248 (pair) | stage1 -> EQ 294 (pair) | IDENTICAL |
| VG/vg23_ternary_bitsel_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg24_gen_two_ifaces_one_dup | § genIfaceParentAtBirth313 | fullname -> EQ 247 (pair) | fullname -> EQ 285 (pair) | IDENTICAL |
| VG/vg25_genchild_iface_port_bare | § genIfaceParentAtBirth313 | fullname -> EQ 154 (pair) | EQ 195 -> EQ 195 (pair) | IDENTICAL |
| VG/vg26_hier_iface_port_gen | § genIfaceConnGenScopeName313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg27_genarr_whole_dup | § genIfaceParentAtBirth313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | EQUIVALENT |
| VG/vg32_genvar_actual | § genIfaceConnGenScopeName313 | EQ 122 (unmoved) | EQ 150 (unmoved) | IDENTICAL |
| VG/vg33_param_ovr_genvar | § genIfaceHcInnerRefUnbound313 | stage1 -> fullname (pair) | fullname -> fullname (pair) | IDENTICAL |
| VG/vg34_sibling_gen_hier | § genIfaceParentAtBirth313 | fullname -> EQ 181 (pair) | fullname -> EQ 236 (pair) | IDENTICAL |
| VG/vg36_modport_conn_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> EQ 156 (pair) | fullname -> EQ 196 (pair) | IDENTICAL |
| VG/vg37_unconnected_gen | § genIfaceConnGenScopeName313 | stage1 -> stage1 (GENIFBIRTH) | stage1 -> stage1 (GENIFBIRTH) | IDENTICAL |
| VG/vg38_crlf_macro_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg39_else_case_nested_sel | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | STATUS_DIFF |
| VG/vg40_gen_iface_and_modchild_same_net | § genIfaceHcInnerRefUnbound313 | stage1 -> EQ 226 (pair) | stage1 -> EQ 244 (pair) | IDENTICAL |
| VG/vg41_gen_two_level_for | § genIfaceHcInnerRefUnbound313 | stage1 -> fullname (pair) | stage1 -> fullname (pair) | IDENTICAL |
| VG/vg42_hier_in_op_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> fullname (pair) | stage1 -> fullname (pair) | IDENTICAL |
| VG/vg43_bitsel_hier_index_gen | § genIfaceHcInnerRefUnbound313 | stage1 -> stage1 (pair) | stage1 -> stage1 (pair) | IDENTICAL |
| VG/vg44_bind_into_gen_iface_mod | § genIfaceConnGenScopeName313 | fullname -> fullname (GENIFCONN) | fullname -> fullname (GENIFCONN) | IDENTICAL |
| VG/vg45_iface_body_partsel_gen | § genIfaceParentAtBirth313 | fullname -> EQ 151 (pair) | fullname -> EQ 185 (pair) | IDENTICAL |
| VG/vg46_nested_iface_in_gen_iface_in_gen | § genIfaceConnGenScopeName313 | fullname -> fullname (GENIFCONN) | fullname -> fullname (GENIFCONN) | IDENTICAL |
| VM/vm01_nested_parent | § ifaceHcSelNamedByInst313 | fullname -> EQ 199 (HCSELINST) | fullname -> EQ 195 (HCSELINST) | IDENTICAL |
| VM/vm02_param_op_idx | § ifaceHcSelNamedByInst313 | stage1 -> stage1 (HCSELINST) | fullname -> endcol (HCSELINST) | IDENTICAL |
| VM/vm03_unary | § ifaceHcSelNamedByInst313 | fullname -> depth (HCSELINST) | fullname -> EQ 144 (HCSELINST) | IDENTICAL |
| VM/vm04_ternary | § ifaceHcSelNamedByInst313 | fullname -> depth (HCSELINST) | fullname -> EQ 172 (HCSELINST) | IDENTICAL |
| VM/vm05_redconcat_bitsel | § ifaceHcSelNamedByInst313 | fullname -> depth (HCSELINST) | fullname -> fullname (HCSELINST) | IDENTICAL |
| VM/vm06_funccall | § ifaceHcSelNamedByInst313 | stage1 (unmoved) | stage1 (unmoved) | EQUIVALENT |
| VM/vm07_syscall | § ifaceHcSelNamedByInst313 | fullname (unmoved) | fullname (unmoved) | IDENTICAL |
| VM/vm08_two_ports | § ifaceHcSelNamedByInst313 | fullname -> EQ 154 (HCSELINST) | fullname -> EQ 153 (HCSELINST) | IDENTICAL |
| VM/vm09_positional_bitsel | § ifaceHcSelNamedByInst313 | fullname -> EQ 157 (HCSELINST) | fullname -> EQ 153 (HCSELINST) | IDENTICAL |
| VM/vm10_iface_in_iface | § ifaceHcSelNamedByInst313 | stage1 -> stage1 (HCSELINST) | stage1 -> stage1 (HCSELINST) | DIVERGENT |
| VM/vm11_hier_into_sub | § ifaceHcSelNamedByInst313 | fullname -> EQ 162 (HCSELINST) | fullname -> EQ 157 (HCSELINST) | IDENTICAL |
| VM/vm12_packed_struct_bit | § ifaceHcSelNamedByInst313 | fullname -> EQ 173 (HCSELINST) | fullname -> EQ 169 (HCSELINST) | IDENTICAL |
| VM/vm13_unpacked_varidx | § ifaceHcSelNamedByInst313 | fullname -> EQ 171 (HCSELINST) | fullname -> EQ 167 (HCSELINST) | IDENTICAL |
| VM/vm14_bitsel_operand | § ifaceHcSelNamedByInst313 | fullname -> fullname (HCSELINST) | fullname -> fullname (HCSELINST) | IDENTICAL |
| VM/vm16_macro_bitsel | § ifaceHcSelNamedByInst313 | fullname -> EQ 157 (HCSELINST) | fullname -> EQ 153 (HCSELINST) | IDENTICAL |
| VM/vm17_two_stmts | § ifaceHcSelNamedByInst313 | fullname -> EQ 256 (HCSELINST) | fullname -> EQ 248 (HCSELINST) | IDENTICAL |
| VM/vm18_pkg_param_idx | § ifaceHcSelNamedByInst313 | fullname -> EQ 173 (HCSELINST) | fullname -> EQ 169 (HCSELINST) | IDENTICAL |
| VM/vm21_param_override | § ifaceHcSelNamedByInst313 | fullname -> EQ 135 (HCSELINST) | fullname -> EQ 134 (HCSELINST) | IDENTICAL |
| VM/vm23_bind_varidx | § ifaceHcSelNamedByInst313 | stage1 -> stage1 (HCSELINST) | stage1 -> stage1 (HCSELINST) | IDENTICAL |
| VM/vm24_op_const | § ifaceHcSelNamedByInst313 | fullname -> EQ 150 (HCSELINST) | fullname -> EQ 146 (HCSELINST) | IDENTICAL |
| VM/vm25_nested_ops | § ifaceHcSelNamedByInst313 | fullname -> depth (HCSELINST) | fullname -> EQ 174 (HCSELINST) | IDENTICAL |
| VM/vm26_cast | § ifaceHcSelNamedByInst313 | fullname -> fullname (HCSELINST) | fullname -> fullname (HCSELINST) | IDENTICAL |
| VM/vm27_replication | § ifaceHcSelNamedByInst313 | fullname -> depth (HCSELINST) | fullname -> EQ 148 (HCSELINST) | IDENTICAL |
| VM/vm28_two_parents | § ifaceHcSelNamedByInst313 | fullname -> EQ 344 (HCSELINST) | fullname -> EQ 335 (HCSELINST) | IDENTICAL |
| VM/vm29_ipsel_opbase | § ifaceHcSelNamedByInst313 | fullname -> fullname (HCSELINST) | fullname -> fullname (HCSELINST) | IDENTICAL |
| VM/vm30_hier3 | § ifaceHcSelNamedByInst313 | fullname -> EQ 182 (HCSELINST) | fullname -> EQ 177 (HCSELINST) | IDENTICAL |
| VM/vm31_hier_other_iface | § ifaceHcSelNamedByInst313 | fullname -> EQ 171 (HCSELINST) | fullname -> EQ 167 (HCSELINST) | IDENTICAL |
| VM/vm32_hier_iface_port | § ifaceHcSelNamedByInst313 | stage1 -> stage1 (HCSELINST) | stage1 -> stage1 (HCSELINST) | IDENTICAL |
| VM/vm33_hier_bitsel_iface_port | § ifaceHcSelNamedByInst313 | stage1 (unmoved) | stage1 (unmoved) | IDENTICAL |
| VM/vm35_modlevel_in_genchild | § ifaceHcSelNamedByInst313 | fullname -> EQ 231 (HCSELINST) | fullname -> EQ 250 (HCSELINST) | IDENTICAL |
| VM/vm36_unary_partsel | § ifaceHcSelNamedByInst313 | EQ 161 (unmoved) | EQ 157 (unmoved) | IDENTICAL |
| VM/vm39_positional_multi | § ifaceHcSelNamedByInst313 | stage1 -> stage1 (HCSELINST) | stage1 -> stage1 (HCSELINST) | IDENTICAL |
| VM/vm40_crlf_op | § ifaceHcSelNamedByInst313 | fullname -> depth (HCSELINST) | fullname -> EQ 158 (HCSELINST) | IDENTICAL |
| VM/vm41_bitsel_desc_range | § ifaceHcSelNamedByInst313 | fullname -> EQ 178 (HCSELINST) | fullname -> EQ 174 (HCSELINST) | IDENTICAL |
| VM/vm42_bitsel_in_iface_port_view | § ifaceHcSelNamedByInst313 | fullname -> fullname (HCSELINST) | fullname -> fullname (HCSELINST) | IDENTICAL |
| VM/vm43_array_varidx_modlevel | § ifaceHcSelNamedByInst313 | stage1 -> stage1 (HCSELINST) | stage1 -> stage1 (HCSELINST) | IDENTICAL |
| VM/vm44_array_op_modlevel | § ifaceHcSelNamedByInst313 | stage1 -> stage1 (HCSELINST) | stage1 -> stage1 (HCSELINST) | IDENTICAL |

(verdicts: pristine -> law; `EQ n` = STRICT_EQUAL at n objects; the parenthesis names the switch that alone restores
pristine's bytes, `pair` = two or more.)

The stage-1 movers that read no record either way (vg01, vg02, vg11, vg37, vg39) were read by uhdm-dump:
- vg02: golden names `$signed(a)`'s argument `work@top.g.u.clk.a`. Pristine wrote `work@top.a` and the law writes
  `work@top.g.a`, both wrong.
- vg11: golden folds the parameter actual, so the reference has no counterpart.
- vg39: its uhdm-cmp line count drops 981 -> 977 at stage 1 on a design-level head that is the same on both binaries.

## Residues (all wrong on pristine too; none moved away)

1. **An operation operand that is a select is named through the instantiating scope.** golden names a bit_select
   operand of an operation actual `<inst>.<port>.<name>`:
   - vg44 `.clk(ck[0] ^ ck[1])` in a generate block: golden `work@top.t.g.u.clk.ck`, law `work@top.t.g.ck`, pristine
     `work@top.t.ck`;
   - vg46 (interface in a generate block of an interface) is the same face.

   The site is § ifaceHcSelNamedByInst313's `idx` walker in ModuleEmit, which renames only ref_obj operands. The same
   rule holds for a system-call argument (vg02) and probably a function-call argument (vg01, stage 1). Next law on
   this ground: extend the walker to bit_select, part_select and call-argument operands.
2. **The third logic_net object.** The `depth` head left after the law on module-level operation actuals in the
   default view (vm03, vm04, vm05, vm25, vm27, vm40, vg18) is the implementer's residue 1. golden's walk reaches an
   extra logic_net of the operand's name; the fullname records ahead of it are cleared.
3. **The struct-member, ternary and hierarchical shapes at stage 1** (vg23 a ternary of bit_selects, vg26 and vm32 a
   hierarchical actual through an interface port, vg42 and vg43 a hierarchical operand or index, vm43 and vm44
   module-level interface arrays where the definition-view module_array heads at stage 1). These match the
   implementer's residues 3 to 5. vm42 (an interface passed on to another interface's port) keeps a fullname head
   past the cleared record.
4. **vg33** (a genvar-dependent parameter override) and **vg41** (a two-level for generate): the law clears the
   stage-1 head, and a fullname head follows.

No sister-ground face was reached: every residue site above is in ModuleEmit.

## Process

- Nothing was written outside the two worktrees /tmp/wt_v11u313 and /tmp/wt_v11u313pris and this pass's
  /tmp/v11u313_* scratch.
- No process this pass did not start was touched, and no command line of another agent was listed.
- Every tool call went through variables checked with `[ -x ]`.
- The fence scan of the delivered patch is 0 for all four names.
