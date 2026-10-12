# v11u293 — adversarial verification of r11u293

Base 28a27398 (pass 291). Implementer's patch: six laws in `src/ModuleEmit.cpp` behind `src/R293.h`
(tools/probe/r11u293repro). **VERDICT: verified with one production fix.** Every headline number of the implementer
reproduces bit for bit; one law, § portViewNdaNetCellParent293, moves elaborated-view records AWAY from golden where
the module that receives the modport sits in a generate block. The refinement § pvNdaTsNameUnstored293v fixes that
behind its own switch. The fix changes no gate database.

## Binaries (built here, frozen read-only before any measurement)

| tag | md5 | note |
|---|---|---|
| pristine | 961af689 | equal to the main tree's build/slang-uhdm at the base |
| law | 390358c0 | equal to the implementer's /tmp/r11u293_bin/law |
| fix | 082e003f | law + § pvNdaTsNameUnstored293v |

## The refinement — § pvNdaTsNameUnstored293v (switch `R11V293_PVTSUNSTORED_OFF`, ModuleEmit, inside § portViewNdaNetCellParent293)

**The break.** Law 6 gives the port-view net of a net declaration assignment an unlisted cont_assign parent and
clears the net's stored full name, but it STORES `w` as the ref_typespec's full name. With `-elabuhdm`, UHDM's
elaborator deep-clones a generate scope (`gen_scope_array::DeepClone` -> `module_inst::DeepCopy` ->
`interface_inst::DeepCopy` -> `modport::DeepCopy`, found with gdb on fresh case VP/vp04). When the scope holds the
module that receives the modport, the clone of the view copies the stored `w`. In golden the clone's ref_typespec
reads `work@top.g.u_s.p.mp.w.w`. Measured (pristine was already wrong here, at its first record):

| case-view | pristine | law | chain-keyed away (pristine -> law) |
|---|---|---|---|
| VP/vp04_gen_child_el | fullname(2) | fullname(1) | 1 |
| VP/vp15_both_in_gen_el | fullname | fullname | 1 |
| VP/vp16_for_gen_el | fullname | fullname | 4 |
| VP/vp18_case_gen_param_el | fullname | fullname | 1 |

The first record under the law, VP/vp04_gen_child_el #121: golden `ref_typespec work@top.g.u_s.p.mp.w.w`, ours `w`.

**The decode.** Surelog stores no full name on a ref_typespec. UHDM's `VpiFullName()` getter computes
`ComputeFullName()` over the parent chain when nothing is stored, and caches the result. Uncloned, the chain gives
`w` (net `w` under an unparented, unnamed cont_assign). In a clone, the chain gives the clone's path. The net
already behaves this way under the law, because the law stores an empty name on it.

**The refinement.** The law leaves the ref_typespec's full name unstored (`VpiFullName("")`, which UHDM's symbol
factory maps to the unset id) instead of storing `w`. Results:
- All four case-views reach STRICT_EQUAL (132, 119, 321 and 191 objects).
- `R11V293_PVTSUNSTORED_OFF` alone restores the law's bytes on each of them.
- Without a clone the bytes are the law's, because the getter computes and caches `w` before the save. On 278 of
  the 282 grid case-views (fresh and implementer's), fix == law.
- `R11V293_OFF` gives the law's bytes and `R11U293_OFF` gives pristine's on 282 of 282 case-views.

## Reproduction of the implementer's numbers (all bit for bit)

- **Probe** (law sweep, tests/sweep.sh --jobs 3): EQUAL 3941 + STRICT_NOTEQUAL 146, regressions 0, conversions 12,
  changes 1 (vh_arrelem endline(9) -> endline(6)), the twelve conversions by name:
  - g171_a_pos, g171_b_homes, g171_c_shapes and g194_c_clone, from depth(1).
  - a4_corpus and a6_headerforms, from endcol(2) and endcol(4).
  - i6_ifarray and y2_pkgvarkind, from endcol(1).
  - vx8_strifport and v14_ndamodport, from fullname(2).
  - pb10_ifnetuse, from line(20).
  - v15_ifdeclafterbody, from line(4).

  All twelve read STRICT_EQUAL with 0 uhdm-cmp lines in BOTH views (evidence/probe_movers_both_views.txt).
  Probe byte movers pristine -> law: 15 of 4087, exactly the implementer's list (the 12, vh_arrelem, g134_e_mult and
  v194_a_explicit). Away census on all 15 in both views: lost 0, chain away 0.
- **Corpora:**
  - surelog: default 478 + 2, testflags 472 + 2.
  - uhdm2rtlil: 803/1/67 in both modes.
  - 0 regressions, conversions and changes on each, against the committed baselines and against my own pristine
    sweep.
- **Downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, 0 not excused, on pristine, law
  and fix. The law and fix csvs are byte-identical.
- **byteverify** (surelog + uhdm2rtlil + downstream, fence-filtered mirrors of 3365 databases, 8 fenced left out):
  - pristine -> law: 0 movers.
  - law -> fix: 0 movers.
  - pristine -> fix: 0 movers.
  - SELFCHECK reads 3363 / 3365 (the known twin).

  The implementer's 2560 counted no downstream databases.
- **Implementer's grid** (58 dirs, 116 case-views; evidence/grid_implementer_cases.txt):
  - 79 moving, 51 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.
  - Single-switch attribution: CLSARRDIMEND 24, HOISTELEMSPAN 20, PVNDAPARENT 16, IFFIRSTREF 12, IFLOWFIRST 3 and
    CLONERETSEL 3, plus IF/if11 default, which needs both IF switches.
  - The fix's bytes equal the law's on all 116.
- **Firing census** of the fix binary, frozen before the fix sweep (evidence/predict_fix.txt, 335 lines): identical to
  the implementer's predict.txt line for line apart from the new tag. `pvNdaTsNameUnstored293v` fires on exactly
  vx8_strifport and v14_ndamodport, both default-view probe databases with no clone. That predicts 0 law -> fix
  movers, and 0 moved.
- **Canaries** (fix sweep): surelog ok=52, uhdm2rtlil ok=16, ctcan2 PASS on both.
- **Binary audit:** 3265 of 3315 cmds.txt name the sweep's own frozen binary on each of the three sweeps; the other
  50 carry no slang line.
- **Determinism** (drivers/det.sh, three concurrent draws, fix binary): one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Each hash equals the pristine, law and fix
  sweeps' database.

## Attack: 83 fresh case dirs (166 case-views, every line with rc=; evidence/grid_fresh.txt)

Families VA (CLSARRDIMEND, 15), VC (CLONERETSEL, 10), VH (HOISTELEMSPAN, 12), VI (IFFIRSTREF / IFLOWFIRST, 28) and
VP (PVNDAPARENT, 18).

The shapes cover:
- Class arrays: two declarators, dyn2, assoc, a package specialization, interface, program, generate, interface
  class, multiline, mixed dims, CRLF, two instances, and a virtual-interface control.
- Clone return names: ipsel, an import chain, loop, a module-import control, case, export, two functions, a class in
  the importer, two selects, and a return statement.
- Hoisted package arrays: a size parameter, a foreign struct, a two-hop typedef, an enum, two modules, multiline,
  macro, CRLF, a named size, an interface generate, an unpacked struct, and an included header.
- Interface first signal: a parent hierarchical read, scalar always, same line, function, inout, generate parent,
  multi-declarator in both orders, modport view, macro port declaration, parameters with two instances, tri, nested
  interface, delay, always_ff, body-first generate/process, signed, unconnected, positional, mixed, generate
  interface with modport, for-generate, clocking, modport import, body-first hierarchical, select left sides,
  initial/final, and an unpacked port.
- Port views: scalar, multi-declarator, wand, generate child, pass-down, parameter width, struct net, a var control,
  modport expression, interface array, explicit modport connection, body reads, program, output direction, both in
  generate, for-generate, generate interface by hierarchical name, and case-generate.

**pristine -> fix:**
- 129 case-views move and 58 enter STRICT_EQUAL.
- 0 leave STRICT_EQUAL and no exit code changes.
- Each mover is restored to pristine by exactly one switch, except VI/vi20 default, which needs both IF switches.
- Away census (order-blind and chain-keyed, evidence/grid_fix_away.txt, together with the implementer's 79 movers):
  208 movers, lost 0, chain away 0, 955 records toward golden.
- Positive control (binaries swapped): away 1 to 20 on 8 of 8.

**pristine -> law:** the four VP generate-scope views above read chain away 1 to 4 (evidence/grid_law_away.txt).
Every other mover reads away 0.

**Downstream** (drivers/dscases.py, 83 dirs): no verdict changes on pristine -> law -> fix (73 IDENTICAL,
3 EQUIVALENT, 5 DIVERGENT, 2 STATUS_DIFF on every binary). The DIVERGENT dirs are VC/vc01, vc02, vc03, vc06 and
vc07, whose stage-1 head is the package function call fold. The STATUS_DIFF dirs are VA/va03 and va09, where
Surelog crashes.

**Byte controls** (drivers/controls.sh, fence-filtered path list): 19 repro dirs not in the implementer's set,
listed below, 1566 case dirs and 3132 case-views. 0 move, 0 exit-code changes.
- The dirs: v11u283, v11u289, v11u291, r11u281, v11u281, r11u287, v11u287, r11u285, v11u285, r11u120, r11v120,
  r11u118, r11v11u118, r11u119, r11u131, r11v131, r11u124, r11v124 and v11u93.
- Positive control for the driver: r11u80, r11u85 and r10uvm225 read 18 movers, the implementer's movers in those
  dirs by name (evidence/controls_poscontrol.txt).

## Cases (first line names the law; P -> L -> F, `(=)` = pristine's bytes)

| case | law (first line) | default P -> L -> F | elaborated P -> L -> F |
|---|---|---|---|
| VA/va01_mod_fixed | § defNetClassArrTsDimEnd293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VA/va02_two_decl | § defNetClassArrTsDimEnd293 | EQ 67 -> EQ 67 -> EQ 67 | EQ 61 -> EQ 61 -> EQ 61 |
| VA/va03_dyn2 | § defNetClassArrTsDimEnd293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VA/va04_assoc_str | § defNetClassArrTsDimEnd293 | EQ 49 -> EQ 49 -> EQ 49 | EQ 46 -> EQ 46 -> EQ 46 |
| VA/va05_param_spec_pkg | § defNetClassArrTsDimEnd293 | EQ 49 -> EQ 49 -> EQ 49 | EQ 46 -> EQ 46 -> EQ 46 |
| VA/va06_iface_dyn | § defNetClassArrTsDimEnd293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VA/va07_program_queue | § defNetClassArrTsDimEnd293 | EQ 35 -> EQ 35 -> EQ 35 | EQ 35 -> EQ 35 -> EQ 35 |
| VA/va08_gen_block | § defNetClassArrTsDimEnd293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VA/va09_interface_class | § defNetClassArrTsDimEnd293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VA/va10_multiline | § defNetClassArrTsDimEnd293 | EQ 37 -> EQ 37 -> EQ 37 | EQ 34 -> EQ 34 -> EQ 34 |
| VA/va11_mixed_dims | § defNetClassArrTsDimEnd293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VA/va12_virtual_iface_ctl | § defNetClassArrTsDimEnd293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VA/va13_crlf | § defNetClassArrTsDimEnd293 | EQ 37 -> EQ 37 -> EQ 37 | EQ 34 -> EQ 34 -> EQ 34 |
| VA/va14_elab_two_inst | § defNetClassArrTsDimEnd293 | EQ 51 -> EQ 51 -> EQ 51 | EQ 54 -> EQ 54 -> EQ 54 |
| VA/va15_param_class_default | § defNetClassArrTsDimEnd293 | EQ 47 -> EQ 47 -> EQ 47 | EQ 44 -> EQ 44 -> EQ 44 |
| VC/vc01_ipsel | § cloneRetNameSelRefBindsHomeReturn293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VC/vc02_chain_import | § cloneRetNameSelRefBindsHomeReturn293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 (=) -> stage1 (=) |
| VC/vc03_loop_select | § cloneRetNameSelRefBindsHomeReturn293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VC/vc04_module_wildcard_ctl | § cloneRetNameSelRefBindsHomeReturn293 | EQ 112 -> EQ 112 (=) -> EQ 112 (=) | EQ 109 -> EQ 109 (=) -> EQ 109 (=) |
| VC/vc05_case_select | § cloneRetNameSelRefBindsHomeReturn293 | stage1 -> stage1 (=) -> stage1 (=) | type -> type (=) -> type (=) |
| VC/vc06_export | § cloneRetNameSelRefBindsHomeReturn293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 (=) -> stage1 (=) |
| VC/vc07_two_funcs | § cloneRetNameSelRefBindsHomeReturn293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 (=) -> stage1 (=) |
| VC/vc08_class_in_importer | § cloneRetNameSelRefBindsHomeReturn293 | depth -> EQ 174 -> EQ 174 | EQ 184 -> EQ 184 (=) -> EQ 184 (=) |
| VC/vc09_string_two_sel | § cloneRetNameSelRefBindsHomeReturn293 | depth -> EQ 253 -> EQ 253 | EQ 277 -> EQ 277 (=) -> EQ 277 (=) |
| VC/vc10_return_stmt | § cloneRetNameSelRefBindsHomeReturn293 | stage1 -> stage1 -> stage1 | type -> type (=) -> type (=) |
| VH/vh01_size_param | § pkgHoistArrNetElemDimSpan293 | endcol -> EQ 159 -> EQ 159 | endcol -> EQ 161 -> EQ 161 |
| VH/vh02_foreign_struct | § pkgHoistArrNetElemDimSpan293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VH/vh03_two_hop_named | § pkgHoistArrNetElemDimSpan293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VH/vh04_enum_elem | § pkgHoistArrNetElemDimSpan293 | endline -> endline (=) -> endline (=) | endline -> endline (=) -> endline (=) |
| VH/vh05_two_modules | § pkgHoistArrNetElemDimSpan293 | endcol -> EQ 221 -> EQ 221 | endcol -> EQ 222 -> EQ 222 |
| VH/vh06_multiline | § pkgHoistArrNetElemDimSpan293 | endline -> EQ 126 -> EQ 126 | endline -> EQ 128 -> EQ 128 |
| VH/vh07_macro_decl | § pkgHoistArrNetElemDimSpan293 | endline -> endline -> endline | endline -> endline -> endline |
| VH/vh08_crlf | § pkgHoistArrNetElemDimSpan293 | endcol -> EQ 126 -> EQ 126 | endcol -> EQ 128 -> EQ 128 |
| VH/vh09_wire_named_size | § pkgHoistArrNetElemDimSpan293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VH/vh10_iface_gen | § pkgHoistArrNetElemDimSpan293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VH/vh11_unpacked_struct | § pkgHoistArrNetElemDimSpan293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VH/vh12_header_include | § pkgHoistArrNetElemDimSpan293 | endcol -> EQ 127 -> EQ 127 | endcol -> EQ 129 -> EQ 129 |
| VI/vi01_hier_parent | § ifaceFirstSignalBindsRefs293 | line -> EQ 181 -> EQ 181 | line -> EQ 181 -> EQ 181 |
| VI/vi02_scalar_always | § ifaceFirstSignalBindsRefs293 | line -> EQ 130 -> EQ 130 | line -> EQ 130 -> EQ 130 |
| VI/vi03_same_line | § ifaceFirstSignalBindsRefs293 | col -> EQ 142 -> EQ 142 | col -> EQ 142 -> EQ 142 |
| VI/vi04_function_read | § ifaceFirstSignalBindsRefs293 | line -> line -> line | depth -> EQ 178 -> EQ 178 |
| VI/vi05_inout | § ifaceFirstSignalBindsRefs293 | line -> EQ 142 -> EQ 142 | EQ 142 -> EQ 142 (=) -> EQ 142 (=) |
| VI/vi06_gen_parent | § ifaceFirstSignalBindsRefs293 | line -> fullname -> fullname | line -> fullname -> fullname |
| VI/vi07_multi_decl | § ifaceFirstSignalBindsRefs293 | line -> EQ 142 -> EQ 142 | line -> EQ 142 -> EQ 142 |
| VI/vi08_body_multi_decl | § ifaceLowConnFirstSignal293 | line -> EQ 142 -> EQ 142 | line -> EQ 142 -> EQ 142 |
| VI/vi09_modport_view | § ifaceFirstSignalBindsRefs293 | line -> line -> line | line -> line -> line |
| VI/vi10_macro_portdecl | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VI/vi11_param_two_inst | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VI/vi12_tri | § ifaceFirstSignalBindsRefs293 | line -> EQ 142 -> EQ 142 | line -> EQ 142 -> EQ 142 |
| VI/vi13_nested_iface | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VI/vi14_delay_assign | § ifaceFirstSignalBindsRefs293 | line -> EQ 148 -> EQ 148 | line -> EQ 148 -> EQ 148 |
| VI/vi15_input_ff | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | fullname -> fullname (=) -> fullname (=) |
| VI/vi16_bodyfirst_gen_proc | § ifaceLowConnFirstSignal293 | stage1 -> stage1 -> stage1 | line -> EQ 180 -> EQ 180 |
| VI/vi17_implicit_port_decl_type | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 (=) -> stage1 (=) |
| VI/vi18_unconnected_port | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VI/vi19_positional | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VI/vi20_mixed_dirs_body_read | § ifaceLowConnFirstSignal293 | stage1 -> stage1 -> stage1 | line -> fullname -> fullname |
| VI/vi21_gen_iface_modport | § ifaceFirstSignalBindsRefs293 | line -> line -> line | line -> fullname -> fullname |
| VI/vi22_for_gen_two | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | line -> fullname -> fullname |
| VI/vi23_clocking | § ifaceFirstSignalBindsRefs293 | line -> line -> line | line -> line -> line |
| VI/vi24_modport_import_func | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 -> stage1 |
| VI/vi25_body_first_hier | § ifaceLowConnFirstSignal293 | line -> EQ 181 -> EQ 181 | line -> EQ 181 -> EQ 181 |
| VI/vi26_select_lhs | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 (=) -> stage1 (=) |
| VI/vi27_initial_final | § ifaceFirstSignalBindsRefs293 | line -> EQ 118 -> EQ 118 | line -> EQ 118 -> EQ 118 |
| VI/vi28_unpacked_port | § ifaceFirstSignalBindsRefs293 | stage1 -> stage1 -> stage1 | stage1 -> stage1 (=) -> stage1 (=) |
| VP/vp01_scalar | § portViewNdaNetCellParent293 | fullname -> EQ 90 -> EQ 90 | fullname -> EQ 86 -> EQ 86 |
| VP/vp02_multi_decl | § portViewNdaNetCellParent293 | fullname -> EQ 167 -> EQ 167 | fullname -> EQ 163 -> EQ 163 |
| VP/vp03_wand | § portViewNdaNetCellParent293 | fullname -> EQ 123 -> EQ 123 | fullname -> EQ 119 -> EQ 119 |
| VP/vp04_gen_child | § portViewNdaNetCellParent293 | stage1 -> stage1 -> stage1 | fullname -> fullname -> EQ 132 |
| VP/vp05_pass_down | § portViewNdaNetCellParent293 | fullname -> EQ 171 -> EQ 171 | fullname -> EQ 167 -> EQ 167 |
| VP/vp06_param_width | § portViewNdaNetCellParent293 | fullname -> EQ 155 -> EQ 155 | fullname -> EQ 151 -> EQ 151 |
| VP/vp07_struct_net | § portViewNdaNetCellParent293 | stage1 -> stage1 (=) -> stage1 (=) | stage1 -> stage1 (=) -> stage1 (=) |
| VP/vp08_var_init_ctl | § portViewNdaNetCellParent293 | EQ 117 -> EQ 117 (=) -> EQ 117 (=) | EQ 113 -> EQ 113 (=) -> EQ 113 (=) |
| VP/vp09_modport_expr | § portViewNdaNetCellParent293 | EQ 132 -> EQ 132 (=) -> EQ 132 (=) | EQ 128 -> EQ 128 (=) -> EQ 128 (=) |
| VP/vp10_iface_array | § portViewNdaNetCellParent293 | fullname -> EQ 195 -> EQ 195 | fullname -> EQ 199 -> EQ 199 |
| VP/vp11_explicit_modport_conn | § portViewNdaNetCellParent293 | fullname -> EQ 123 -> EQ 123 | fullname -> EQ 122 -> EQ 122 |
| VP/vp12_body_assign_reads | § portViewNdaNetCellParent293 | fullname -> EQ 198 -> EQ 198 | fullname -> EQ 194 -> EQ 194 |
| VP/vp13_program_port | § portViewNdaNetCellParent293 | EQ 93 -> EQ 93 -> EQ 93 | EQ 93 -> EQ 93 -> EQ 93 |
| VP/vp14_output_dir | § portViewNdaNetCellParent293 | fullname -> EQ 67 -> EQ 67 | fullname -> EQ 64 -> EQ 64 |
| VP/vp15_both_in_gen | § portViewNdaNetCellParent293 | fullname -> EQ 120 -> EQ 120 | fullname -> fullname -> EQ 119 |
| VP/vp16_for_gen | § portViewNdaNetCellParent293 | stage1 -> stage1 -> stage1 | fullname -> fullname -> EQ 321 |
| VP/vp17_gen_iface_hier_conn | § portViewNdaNetCellParent293 | fullname -> EQ 121 -> EQ 121 | fullname -> EQ 125 -> EQ 125 |
| VP/vp18_case_gen_param | § portViewNdaNetCellParent293 | stage1 -> stage1 -> stage1 | fullname -> fullname -> EQ 191 |

## Residues (ranked; all wrong on pristine too, none moved away by the fix)

1. **Generate-scope views of the elaborated port-view family:** VP/vp04 default (stage 1, 133 lines).
2. **Interface first-signal neighbours:**
   - VI/vi06 and vi21: the high-conn ref_obj full names in a generate block, `work@top.o` where golden has
     `work@top.g.o`.
   - VI/vi20 elaborated: the definition cont_assign refs keep `work@ifc.i` where golden has `work@top.u_if.i`.
   - VI/vi09 and vi21: a modport port view of a port-first net, pb19's face. The port view mints no
     port-declaration net.
   - vi04 default: a function body's reference, at line.
   - vi23: a clocking block's item.
   - Stage 1 on every binary: vi10 (port declaration in a macro), vi11 (parameters), vi13 (nested interface), vi15,
     vi16, vi17, vi18, vi19, vi22, vi24, vi26 and vi28.
3. **Clone return name:**
   - VC/vc01, vc02, vc03, vc05, vc06, vc07 and vc10 stay at stage 1 on the package function call fold (the sister
     ground).
   - vc05 and vc10 elaborated read type.
4. **Class arrays:** stage 1 for fixed and mixed-dimension arrays (va01, va11), dyn2 (va03), interface (va06),
   generate (va08) and interface class (va09). Surelog crashes downstream on va03 and va09.
5. **Hoisted arrays:**
   - vh04: the enum element keeps endline.
   - vh07: the macro declaration moves toward golden but stays at endline.
   - Stage 1: vh02, vh03, vh09, vh10 and vh11.
6. **Port views:** vp07 (a struct net, stage 1).
7. The implementer's ranked residues stand as written (pb19_modportview first).

## Process

- **Fence:**
  - Read fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line through drivers/env.sh, and never
    spelled.
  - The census ran through the harness filter.
  - Every control path list and both byteverify mirrors were filtered by word boundary before any file was opened.
  - gdb ran only on the fresh case VP/vp04.
  - Evidence files and cases were checked to hold no fenced name.
- **Processes and main tree:** no other agent's process was listed or signalled, no pgrep was used, and the main
  tree was not written.
- **Law index:** all three sweeps exited 1 on the law-index check alone. The base's own index reads stale once
  committed, because pass 291's laws gain a commit line. tests/LAWS.md was regenerated last.
- **Slip, no effect:** the first away-census run failed before reading anything, because drivers/awayrows.py had not
  been copied. It was rerun after copying.
