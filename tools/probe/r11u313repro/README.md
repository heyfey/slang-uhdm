# r11u313 — interface port connections in generate blocks and select actuals of interface ports

Base 71ee56cf (pass 311). Ground: module/type (src/ModuleEmit.cpp only). Four laws, each behind its own switch read
through src/LawSwitch.h (`lawOn(313, ...)`); `R11U313_OFF` drops all four and gives pristine's bytes on 136 of 136 grid
case-views; `R11U313_TRACE=<dir>` logs every firing (`lawTrace(313, ...)`). No src/R*.h, no LawState.h section, no
getenv: the one piece of state, `genIfaceParent313`, is static in ModuleEmit.cpp next to `genChildParent261`.

**Target: the brief's first item.** v11u311repro VG/vg01_ifc_with_port read STRICT_NOTEQUAL fullname(2) in both views
(golden names the interface element's HighConn `work@top.g.clk`, ours `work@top.clk`). It enters STRICT_EQUAL in both
views: default 224 objects, elaborated 264 objects. Downstream it reads IDENTICAL on both binaries.

**Gate: no corpus row and no gated probe case changes status.**
- Probe: 4017 EQUAL + 70 STRICT_NOTEQUAL; regressions 0, conversions 0, changes 0.
- Surelog: 480 + 0 / 474 + 0. uhdm2rtlil: 803/1/67 in both modes. All 0/0/0.
- Downstream: 803/66/2/0, byte-identical to the committed csv.
- The csv row diff between the law and pristine sweeps is 0 lines in probe, surelog and uhdm2rtlil.

**Byte movers, all predicted by name.**
- The corpora: one database of 3365, surelog Rggen default. Its 305 column-0 interface duplicates in generate blocks
  are now parented at the gen_scope, as golden parents them (golden `interface_inst
  work@rggen.u_block_0.g_register_0.bit_field_if line:166:0` under `gen_scope work@rggen.u_block_0.g_register_0`).
  These objects sit in the weakly referenced tail, so the strict column stays `equal`.
- The probe: 5 databases of 4087. All five read EQUAL on both binaries.

## The decode

Surelog compiles an interface instance's port connection in two scopes.

**The reference is named through the instantiating scope.** For a whole-name actual, elab_interface's HighConn
ref_obj takes the enclosing scope's name, and inside a generate block that is the gen_scope:
- golden `.clk(clk)` in `g` gives `work@top.g.clk`;
- ours named every interface HighConn through the module (`parentPrefix` = the parent instance).

emitInstance already does this for a module child (`parentPrefix = genConnPrefix` under `genvarConnFold`).
emitInterfaceInstance did not.

**Everything else follows the interface instance itself.** The definition view's ref_module port lists the actual
under the instance path, and the elaborated port reads the same names:
- a bit_select `ck[1]` is `<inst>.ck`;
- a reference written directly as its index is `<inst>.s`, and one inside an index operation is `<inst>.ck.s`;
- an indexed part select is `<inst>.<port>.ck`, with a direct base reference `<inst>.<port>.s`;
- an operation's or concatenation's operand is `<inst>.<port>.a`;
- a hierarchical actual's last element is `<inst>.<port>.clk`.

The part_select and var_select actuals already got these names from the parent chain, because ExprEmit stores no
full name on them.

**In a generate block, every reference below the actual's top stays unbound.** golden `.clk(a & b)` lists
`ref_obj work@top.g.farr[0].clk.a` with no vpiActual. The module-level twins keep their bindings.

**A name left to the parent chain freezes while the instance is built.** The interface's parent was the module until
the generate loop re-parented it, so the frozen chain skipped the generate scope. Pass 261 fixed the same thing for
module children.

## Laws

| law | switch | site | statement |
|---|---|---|---|
| § genIfaceConnGenScopeName313 | R11U313_GENIFCONN_OFF | emitInterfaceInstance: the HighConn `emitExpr` and the nested interface-port HighConn `hc9` | an interface instantiated in a generate block (scalar or array; if, else, case and for generate; nested blocks; an interface's own generate block) names its HighConn through the generate scope (`genConnPrefix`), as emitInstance does; port views are untouched |
| § genIfaceParentAtBirth313 | R11U313_GENIFBIRTH_OFF | the two interface calls in emitGenScopes set `genIfaceParent313`; emitInterfaceInstance consumes it on entry | the interface instance, and its column-0 duplicate, are parented at the gen_scope from birth, the interface twin of § genChildParentAtBirth261 (GP/p24_partsel_scalar_ifgen: golden `work@top.g.u.clk.ck`, ours `work@top.u.clk.ck`) |
| § ifaceHcSelNamedByInst313 | R11U313_HCSELINST_OFF | emitInterfaceInstance port loop, after the HighConn `emitExpr` (helper `ifaceHcSelNamedByInst313`) | the actual is named through the interface instance (module level and generate blocks), as listed in the decode |
| § genIfaceHcInnerRefUnbound313 | R11U313_GENIFHCUNBIND_OFF | the same place (helper `genIfaceHcInnerRefUnbound313`) | in a generate block, every reference below the actual's top loses its binding: operation operands at any depth, a bit_select's index, an indexed part select's base. A whole-name actual keeps its net |

Every writing branch traces:
- GENIFCONN and GENIFBIRTH trace whenever they fire, so the census over-predicts. 12 probe databases were predicted
  and 5 moved.
- HCSELINST and GENIFHCUNBIND trace only when a name or a binding actually changes.

## Binaries

| binary | md5 |
|---|---|
| pristine (71ee56cf, -j 2) | 7350caade5ac8f411d370d9029b7d462 (equal to the main tree's build/slang-uhdm) |
| law (the delivered patch) | a8ee6fc02b5b65fa90772107fa722afa |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 |
| strictcmp_x (drivers/cc_x.sh) | 886f030233ecdbcce7d0e29ac0c4df2c |

Both slang-uhdm binaries link slang 12.0.0+545f88b2e. Both were frozen (chmod 555) before any measurement.

## Grid (cases/GP 49 dirs, cases/GQ 19 dirs; both views; evidence/grid.txt, gridsum.txt)

drivers/grid.sh runs each case-view on P, L, OFF (`R11U313_OFF`) and on L with each switch off. All 952 lines carry
`rc=`, and every line is rc=0.

**Overall:**
- 136 case-views, 118 moving, 68 entering STRICT_EQUAL, 0 leaving. No exit-code change.
- OFF equals pristine on 136 of 136.
- Restored by one switch alone: GENIFCONN 22, HCSELINST 34, GENIFBIRTH 6. The other 56 movers need two or more,
  because a generate-block select actual fires the naming laws together.
- Away census (drivers/awaycv.sh, order-blind and chain-keyed; evidence/away_grid.txt), all 118 movers: lost 0,
  chain away 0, flat away 0, with 176 records toward golden.
- The positive control, with the binaries swapped on 12 entering movers, reads chain away > 0 on 12 of 12
  (evidence/away_poscontrol.txt).

**Downstream on all 68 dirs** (drivers/dscases.py; evidence/downstream_cases_P.txt and _L.txt): no verdict moves on
either binary. 66 read IDENTICAL; p11_whole_array_child and p35_bitsel_two_insts read EQUIVALENT on both.

| group | cases (first line names the law) |
|---|---|
| GP, § genIfaceConnGenScopeName313 | p01_scalar_ifgen, p02_array_ifgen, p03_array_forgen, p04_scalar_forgen, p05_nested_gen, p06_gen_local_net, p09_positional, p11_whole_array_child, p12_else_branch, p13_case_gen, p14_two_ports, p18_ref_othername, p43_iface_in_genchild_body (control: a generate-block module child's own interface, unmoved) |
| GP, § ifaceHcSelNamedByInst313 | p10_bitsel_conn, p15_bitsel_modlevel_ctl, p16_bitsel_scalar_ifgen, p19_bitsel_othername_scalar, p20_bitsel_othername_array, p21_bitsel_scalar_modlevel_ctl, p25_bitsel_array_modlevel, p26_member_scalar_modlevel, p27_member_scalar_ifgen, p29_ipsel_scalar_modlevel, p30_ipsel_scalar_ifgen, p32_bitsel_varidx_modlevel, p33_bitsel_genvar_forgen, p34_bitsel_param_idx, p35_bitsel_two_insts, p37_ipsel_varbase_modlevel, p38_bitsel_opidx_modlevel, p40_bitsel_nestedop_modlevel, p44_bitsel_in_genchild_body, p45_ipsel_desc_modlevel, p46_op_conn_modlevel, p47_concat_modlevel; controls p08_modlevel_ctl, p17_scalar_modlevel_ctl, p22_bitsel_modchild_ctl (a module child), p23_partsel_scalar_modlevel, p31_bitsel_2d_modlevel (var_select), p36_param_idx_modchild_ctl, all unmoved |
| GP, § genIfaceHcInnerRefUnbound313 | p07_expr_conn, p28_concat_ifgen, p39_bitsel_array_ifgen_varidx, p41_bitsel_opidx_ifgen, p42_ipsel_varbase_ifgen, p48_unary_ifgen, p49_ternary_ifgen |
| GP, § genIfaceParentAtBirth313 | p24_partsel_scalar_ifgen |
| GQ, § genIfaceConnGenScopeName313 | q01_wildcard_conn, q02_shorthand_conn, q04_macro_conn, q06_escaped_inst, q07_iface_gen_in_iface, q08_bind_iface, q13_iface_port_iface_gen, q14_output_port_lvalue, q16_program_in_gen_ctl (a program, unmoved) |
| GQ, § ifaceHcSelNamedByInst313 | q05_hier_actual, q09_gen_bitsel_bind (a bind), q10_forgen_nested_if, q11_gen_two_scalar_one_stmt, q15_gen_local_bitsel, q17_crlf (a CRLF file), q18_hier_actual_modlevel, q19_struct_member_ifgen_ctl |
| GQ, § genIfaceParentAtBirth313 | q03_const_conn, q12_param_iface_gen |

Entering STRICT_EQUAL in both views:
- p01-p05, p09, p12-p14, p18 (the whole-name actuals in every generate form);
- p21, p29, p32, p38 and q18 (module level);
- p10, p16, p19, p20, p33, q10, q15 and q17 (generate-block selects; some only in the default view, because the
  elaborated view was already equal);
- p28, p39, p41, p42 and p48 (stage 1 -> STRICT_EQUAL by the unbinding);
- p24, q02, q04, q05, q07 and q12.

Elaborated view only: p37, p40, p45, p46 and p47.

## Controls

**Firing scan** (drivers/firescan.sh with the law binary; evidence/firing_law.txt):
- 26942 fence-filtered tools/probe dirs. 203 fire: 59 of this pass and 144 earlier dirs (evidence/firing_earlier.txt).
- One exit 139, v11u112repro/grid/brk2/k/m07_hdr_enum_default. It crashes on pristine too.

**The 144 earlier firing dirs in both views** (drivers/controls.sh; evidence/controls_firing.txt, controls_firing_sum.txt,
away_controls.txt):
- 288 case-views, 152 moving, 14 entering STRICT_EQUAL, 0 leaving. No exit-code change and no uhdm-cmp line-count
  change.
- Away census on all 152 movers: lost 0, chain away 0, flat away 0, with 89 records toward golden.
- Entering:
  - v11u311repro VG/vg01_ifc_with_port (both views);
  - r11u251repro BP/b09_bitsel (both views);
  - v11u254repro H/vh04_qual_iface (both views);
  - v11u283repro VI/vi07_gen_param and vi14_direct_gen_direct (both views);
  - v11u293repro VI/vi06_gen_parent (both views), vi21_gen_iface_modport (elaborated) and vi22_for_gen_two (elaborated).

**Standard byte controls** (passes 118, 119, 120, 124 and 131, nine repro dirs; evidence/controls_std_sum.txt):
1440 case-views, 0 moving.

## Firing census and gates (evidence/predict.txt, gates.txt, det.txt)

**Firing census** (drivers/tracecensus.sh, frozen before the law sweep; the law binary under R11U313_TRACE over the
probe and both corpora in both modes, filtered by $FENCED). It names:
- surelog Rggen/default: GENIFCONN 305 and GENIFBIRTH 305;
- 12 probe databases: GENIFCONN and GENIFBIRTH only. No HCSELINST or GENIFHCUNBIND line appears anywhere in the
  gate.

**Movers.** Rggen/default and 5 of the 12 probe databases move. Each mover was predicted:
- r10rgg16repro cells/g1;
- r10vrgg16repro cells/v8;
- r10vrgg3repro z1_single_genfor_named;
- r11u115repro grid/i/o05_nmp_samegen_ctl;
- v11u115repro grid/f2b/q01_genfor_same_iter.

The other 7 are the trace's over-prediction. The final parent is the same, and the prefix change reaches no stored
name.

**Sweeps.** tests/sweep.sh --jobs 3 ran on pristine and on the law, from this worktree, with workdirs of equal length.
Both exit 0 and read the gate numbers above.

**byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered mirrors with 8 fenced paths
skipped):
- The corpora: 1 of 3365 databases move (Rggen/default; chain away 0, toward 0 on its records).
- SELFCHECK flags 3363 of 3365; the unflagged pair is the known downstream/1DUnpackedArray twin.
- The probe: 5 of 4087 databases move.

**Canaries:** surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.

**Binary audit:** each sweep has 3323 cmds.txt. In each, 3273 name that sweep's own binary, 0 name the other binary or
the main tree's, and 50 run no slang.

**Determinism** (drivers/det.sh, three concurrent draws with the law binary): one hash per row-mode on Earlgrey_0_1,
MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Each hash equals the law sweep's.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **The last reference of an operation or part-select actual binds a third net object** (module level, the depth head
   left on GP/p37, p40, p45, p46 and p47 in the default view).
   - Golden's walk reaches a logic_net `work@top.b` that is listed nowhere else. It is the third object of that name,
     after the definition's and the elaborated top's.
   - Ours binds the listed net, and the dumps print the two identically.
   - The decision of which reference gets the extra object is not decoded: `a & b` gives b, `s + t - 1` gives t, and
     `ck[s+:1]` gives s.
2. **The definition-view generate net declaration** `wire lclk = clk;` (GP/p06): ours binds the initializer to
   `work@top.clk`, golden leaves it unbound. The elaborated HighConn should then bind `work@top.g.lclk`.
3. **A member actual `.clk(ck.a)`** (p26, p27, q19): golden gives the hier_path a ref_typespec and a vpiExpr struct_net
   (stage 1).
4. **A ternary actual** in a generate block (p49): the definition view writes a ref_obj named after the whole text
   (stage 1).
5. **The module-level interface array's definition-view module_array** (p15, p25; stage 1, the Surelog form with an
   operation range).
6. **A parameter index `ck[P]`** that golden folds to a constant (p34; the module-child twin p36 is the same).
7. **Two instances in one statement** (p35, q11): golden reuses the first instance's index constant, a Surelog defect.
8. **An interface output port connected to a select** (q14, stage 1), the escaped instance name (q06), the wildcard
   `.*` actual's end column (q01), and the nested interface-port view (q13: line and name of `work@top.g.h.i`).
9. **Generate-local nets** in the elaborated HighConn (p06), and an interface-array child fed a whole array in a
   generate block (p11, the vg08 / vg18 family).

The brief's other module/type residues stand as pass 311 left them. No sister-ground face was reached.

## Process

- **One slip, no effect.** One early decode shell ran `$UHDM_DUMP` before sourcing the environment. It executed one
  golden database of this pass's own scratch (r11u313_s/g/GP/p06_gen_local_net). No file was written; the directory
  was listed afterwards and nothing was added. Every later dump went through a guarded wrapper (`[ -x "$UHDM_DUMP" ]`).
- **One self-matching waiter, stopped.** One `until ... pgrep -f` waiter matched its own command line. It was stopped
  by its task id; nothing else was touched.
- **The fence.** Every helper read the fence fail-closed, and every tree scan built its path list and filtered it by
  $FENCED before opening a file.
- **Writes.** Nothing was written outside this worktree and the pass's /tmp scratch.
