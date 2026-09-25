# v11u164: adversarial verification of r11u164 (the module/type ground, pair B)

Base `d48f8f8a` (branch matrix-1.87). Worktrees `/tmp/wt_v11u164` (the patch) and `/tmp/wt_v11u164pris` (pristine), both
built with system deps at `-j 2`. The implementer's patch `/tmp/r11u164.patch` applies clean on a fresh `d48f8f8a`. This
pass reproduces its numbers, attacks each law with fresh cases, and fixes the breaks it found. The deliverable is
`/tmp/r11u164.verified.patch`: the implementer's patch plus two refinement laws, the corrected law attribution of the
implementer's cases, this directory, and the regenerated `tests/LAWS.md`.

The slang-fenced tests are written `FENCED=` here and are never spelled. `drivers/env.sh` builds the list from RESUME.md
and refuses to go on without four names. The byte comparisons ran on hard-link mirrors (the implementer's
`r11u164repro/drivers/bvmirror.sh`) that leave out the 8 fenced row-mode databases. No fenced source or database was
run, read or decoded outside the gate sweeps, which dispatch every row themselves.

## 1. Verdict

**ACCEPT-WITH-FIX.** Every headline number of r11u164 reproduces bit for bit. The fresh cases found three defects:

1. **§ enumAliasClone161 folds a symbolic base.** A module alias of a module enum whose base range uses a module
   parameter (`typedef enum logic [W-1:0] ... e_t; typedef e_t f_t;`, case `EA/e06`) got a folded clone base (INT:2).
   Golden's clone keeps `W-1`, with the reference named `f_t.W`. The r11u161 rule "folded bounds" holds only for a
   package target (r11u161 `al/e17`). Fixed by § enumAliasBaseAsTarget164v.
2. **§ rangeQueryFoldUnconverted164 moves a value away from golden.** A range query of a variable or net onto a narrower
   declared net (`logic [20:0] a; wire [3:0] w; assign w = $high(a);`, cases `RQ/r03`, `r12`, `r14`, `r15`, `r16`) now
   reads the unconverted UINT:20. Golden and pristine both read UINT:4. The cases are stage 1 before and after on the
   located range-bound object (a pre-existing face), and downstream stays IDENTICAL. Still, it is the value field moving
   from right to wrong on legal SV. Fixed by § rangeQueryVarDeclMask164v.
3. **Law index attribution.** 12 of the implementer's 20 PV cases named laws that do not exist in the source
   (`ifacePortViewParamDef164`, `ifacePortViewParamShared164`). As a result, tests/LAWS.md listed no case for
   `portViewParamShared164`, and no case at all named `rangeQueryDeclNetSize164`. The first lines were corrected to
   `§ modportPortViewParamDef164` / `§ portViewParamShared164`, and q04 q05 q09 now also name `§ rangeQueryDeclNetSize164`.
   Comment text only: the cases' databases are unchanged.

The report calls the pass "ten laws"; the source holds nine r11u164 laws with nine switches (section 2).

## 2. Laws in the verified patch

The r11u161 laws are delivered unchanged by the implementer. Every `+` and `-` line of `tools/probe/r11u161gen/law.patch`
is present in the patch, which was checked by a sorted line comparison. The two extra `-` lines belong to r11u164's own
sites. `R11U164_OFF=1` drops every r11u164 law and both refinements below (they read `r11u164Law`). `R11U161_OFF=1` drops
the r11u161 laws.

| law | switch | site |
|---|---|---|
| § defGenPathSel161 | `R11U161_ROUTE_OFF` (+ `_SPAN_OFF`, `_NAME_OFF`) | TypeEmit.cpp `defGenRoute161`, ModuleEmit.cpp `emitDefGenStmts` |
| § firstOrderedPathSel161 | `R11U161_PORT_OFF` | ModuleEmit.cpp `emitInstance` (`firstOrderedConn161`) |
| § enumAliasClone161 | `R11U161_ALIAS_OFF` (+ `_FILE_OFF`) | TypeEmit.cpp `emitTypedefs`, UhdmExporter.cpp `exportDesign` |
| § rangeQueryFoldUnconverted164 | `R11U164_RANGEQ_OFF` | ModuleEmit.cpp `emitContAssigns` sysFold |
| § rangeQueryDeclNetSize164 | `R11U164_RANGEQSIZE_OFF` | same, UINT branch |
| § caDelayFirstOnly164 | `R11U164_CADELAY_OFF` | ModuleEmit.cpp `emitContAssigns` delay |
| § caDelayParamElabFresh164 | `R11U164_DLYPARAMELAB_OFF` | same, elab share decision |
| § modportPortViewParamDef164 | `R11U164_PVMPDEF_OFF` | ModuleEmit.cpp `emitInterfaceInstance` |
| § portViewParamShared164 | `R11U164_PVSHARE_OFF` | same |
| § defGenSelBaseLeafAtIndex164 | `R11U164_SELBASELEAF_OFF` | ModuleEmit.cpp `emitDefGenStmts` |
| § bindUnresolvedPathNoName164 | `R11U164_BINDPATHNAME_OFF` | ModuleEmit.cpp `emitInstance` bind literal path |
| § genNetDeclAssignLhsShared164 | `R11U164_GENNDAHP_OFF` | ModuleEmit.cpp `emitGenScopes` |
| **§ enumAliasBaseAsTarget164v** (this pass) | `R11V164_ALIASBASE_OFF` | TypeEmit.cpp `enumAliasTgtBaseFolded164v`, called at both § enumAliasClone161 fold sites (TypeEmit.cpp `emitTypedefs`, UhdmExporter.cpp `exportDesign`) |
| **§ rangeQueryVarDeclMask164v** (this pass) | `R11V164_RQMASK_OFF` | ModuleEmit.cpp `emitContAssigns`: the flag at the sysFold evaluation, the mask in § rangeQueryDeclNetSize164's branch |

**§ enumAliasBaseAsTarget164v.** The clone of a NON-package target copies the target's base as the target holds it. When
any bound of the target's base range is not a constant, the clone keeps the symbolic bound and is not folded. A package
target's clone still folds. The decode is golden's `EA/e06` (`\_operation` `W-1` with `\_ref_obj: (f_t.W)` under the
clone's `logic_typespec`) against r11u161's `al/e17` (package parameter bound folded in the clone). A first version
without the package branch broke `al/e17` (STRICT_EQUAL to stage 1); the package branch restores it.

**§ rangeQueryVarDeclMask164v.** This refines § rangeQueryDeclNetSize164. A `$high/$low/$left/$right` query of a
VARIABLE or NET whose queried bound is a plain integer literal of its first packed dimension is masked to the declared
target's width. The decode is Surelog's `CompileHelper::adjustSize`: its `vpiUIntConst` branch does
`uval & NumUtils::getMask(size)`. The object Surelog hands writeCont for such a query is the declared range-bound constant
itself, a UINT constant located at the bound token. The mask does not apply in three cases:

* a PARAMETER's query is a bare reduce result with no constant type (golden `q09` UINT:6 onto two bits, `r11` UINT:20
  onto four);
* an expression bound (`logic [N-1:0]`) is an INT constant (golden `r08` INT:3 / INT:7 onto one bit, `r18`);
* a sized-literal bound (`logic [5'd20:0]`) is a DEC constant that keeps its size 5 (golden `r17` DEC:20).

A first version keyed on "the argument is not a parameter" broke `r08` (its value went to 1). A second version missed
nets (`r16`), because a net's declared type syntax is `ImplicitType`.

## 3. Reproduction (implementer's patch as delivered, `law.bin`)

| binary | md5 |
|---|---|
| `/tmp/v11u164_bin/pris.bin` (worktree build of d48f8f8a) | `76f6b803e83ec4e631b29a1f4d18b1bd` (= the stated main-tree md5) |
| `/tmp/v11u164_bin/law.bin` (d48f8f8a + r11u164.patch) | `f43f2933b26d730acaabbf6083c43dee` (= the implementer's) |
| `/tmp/v11u164_bin/ver4.bin` (the verified patch) | `3a5945317e16cb1d05d9cb5654f66f1b` |
| `/tmp/v11u164_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` |

Sweeps are `tests/sweep.sh --jobs 3` (`drivers/sweep.sh`). The workdirs are `/tmp/v11u164_swP` (pristine),
`/tmp/v11u164_swL` (law) and `/tmp/v11u164_swV` (verified), all names of the same length. In the corpus `cmds.txt` files
there are 3273 `slang:` lines per sweep, and every one names its own binary. The downstream stage's `slang.uhdm` of each
moved row differs between the pristine and law sweeps (for example interface_array `89b9ac1b` against `4781d46c`), which
proves it ran the exported binary.

| gate | pristine | law (as delivered) |
|---|---|---|
| probe vs golden_probe.csv | EQUAL 2547 / STRICT_NOTEQUAL 1540; 0 / 0 / 0 | EQUAL 2597 / 1490; regressions 0, conversions 50, changes 73 (every CHANGE lowers its count; `r11v1repro/vA` goes depth(1) -> col(2), a later walk position) |
| surelog vs golden_surelog.csv | CMP_EQUAL 432 + 429, STRICT_NOTEQUAL 48 + 45; 0 / 0 / 0 | regressions 0, conversions 6 (ComplexHierPath, GenIfIfaceParamStructField, HighLow, both modes), changes 4 (Earlgrey_0_1 d/t line(1730) -> line(1686), GenForStructParamBound d/t fullname(7) -> fullname(3)) |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | CMP_EQUAL 766 + 766, STRICT_NOTEQUAL 37 + 37; 0 / 0 / 0 | regressions 0, conversions 8 (iface_param_port_width, interface_array, interface_array_fanout, mriscv_bind_sva, both modes), changes 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; downstream.csv byte-identical to the pristine sweep's |
| sweep rc | 1 (only `law index STALE`: the pristine worktree's LAWS.md predates later commits in the repo) | 0 |

Byte movers (SELFCHECK=1 on the fenced mirrors, path sets identical): surelog 19 / 952 and uhdm2rtlil 12 / 1608.

* The deterministic movers are ComplexHierPath, Earlgrey_0_1, GenForStructParamBound, GenIfIfaceParamStructField,
  HighLow and OneNetModPort (d/t), Rggen/default, and in uhdm2rtlil genvar_iface_struct, iface_array_modport_drive,
  iface_param_port_width, interface_array, interface_array_fanout and mriscv_bind_sva (d/t).
* Every one is on the implementer's pristine-database prediction list
  (`r11u164repro/evidence/prediction/predicted_candidates_from_pristine_final.tsv`).
* The rest are the UVM coin: MiniAmiq d/t, SeqDriver d/t, and SimpleUVM d/t this run (the implementer's run caught
  SimpleUVM t only). Each is exactly 4 order-blind lines (`UINT:0`/`UINT:1124`, `vpiDecompile:0`/`1124`).
* Probe: 125 databases move (dump-normalised for the worktree path, `drivers/probe_normdump.sh`). All 125 are on the
  prediction list.

Canaries against the committed baselines:

* surelog: ok=52 changed=0 (pristine) and ok=50 changed=2 (law: Earlgrey_0_1 d/t, the attributed CHANGE);
* uhdm2rtlil: ok=16 changed=0 on both;
* ctcan2: PASS on both corpora (EXPECT_UNKNOWN=1 / 6).

The fresh csv rows of the targeted row-modes (law sweep) are
`HighLow,default,CMP_EQUAL,,,equal`, `HighLow,testflags,CMP_EQUAL,,,equal`, and the same `CMP_EQUAL,,,equal` for
GenIfIfaceParamStructField, ComplexHierPath, iface_param_port_width, interface_array, interface_array_fanout and
mriscv_bind_sva in both modes. The downstream rows read `iface_param_port_width,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
`interface_array,IDENTICAL,OK,OK,8,8,,`, `interface_array_fanout,IDENTICAL,OK,OK,22,22,,` and
`mriscv_bind_sva,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.

## 4. Breaking the laws: 77 fresh cases (`cases/`, first line `// § <law>`)

Each case is judged by uhdm-cmp and uhdm-strictcmp against the pinned Surelog (`drivers/case.sh`: check_probe's
arguments) and by the downstream harness's `one()` (`drivers/dscase.py`). Pristine STRICT_EQUAL is 4 of 77; law and
verified are 35 of 77. No case pristine read STRICT_EQUAL reads otherwise.

Downstream over the 77 cases: pristine reads IDENTICAL 64, EQUIVALENT 6, DIVERGENT 5, STATUS_DIFF 1 and
SLANG_REJECT 1. Verified reads IDENTICAL 69, EQUIVALENT 5, DIVERGENT 1 (RQ r06, on both binaries), STATUS_DIFF 1 (PV
p12, on both) and SLANG_REJECT 1 (BU u05, on both). The five that improve are EA e01 e02 e04 e06
(DIVERGENT -> IDENTICAL) and e05 (EQUIVALENT -> IDENTICAL). No case leaves IDENTICAL.

Every stage-1 case that moved was checked by order-blind dump distance to golden (`drivers/obd.sh`). None is farther
from golden on the verified binary. On the delivered binary, r03, r12, r14, r15 and r16 were one line farther (defect 2),
and EA e06 kept a folded bound (defect 1).

| case | pristine | verified | law(s) |
|---|---|---|---|
| `BU/u02_unresolved_ordered` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § bindUnresolvedPathNoName164 |
| `BU/u03_resolved_only` | STRICT_EQUAL_136_objects | STRICT_EQUAL_136_objects| § bindUnresolvedPathNoName164 |
| `BU/u04_unresolved_deep` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_181_objects| § bindUnresolvedPathNoName164 |
| `BU/u05_unresolved_first_level` | SLANG_REJECT (rc 3) | SLANG_REJECT (rc 3) | § bindUnresolvedPathNoName164 |
| `DL/d01_real_list` | STRICT_NOTEQUAL_type | STRICT_EQUAL_58_objects| § caDelayFirstOnly164 |
| `DL/d02_list_genif` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § caDelayFirstOnly164 |
| `DL/d03_list_child_twice` | STRICT_NOTEQUAL_type | STRICT_EQUAL_160_objects| § caDelayFirstOnly164 |
| `DL/d04_list_iface` | STRICT_NOTEQUAL_type | STRICT_EQUAL_76_objects| § caDelayFirstOnly164 |
| `DL/d05_param_genif` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § caDelayParamElabFresh164 |
| `DL/d06_localparam_derived` | NOT_EQUAL_stage1 | STRICT_EQUAL_92_objects| § caDelayParamElabFresh164 |
| `DL/d07_pkg_param` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § caDelayParamElabFresh164 |
| `DL/d08_param_select_lhs` | NOT_EQUAL_stage1 | STRICT_EQUAL_69_objects| § caDelayParamElabFresh164 |
| `DL/d09_param_list_child` | NOT_EQUAL_stage1 | STRICT_EQUAL_178_objects| § caDelayFirstOnly164 § caDelayParamElabFresh164 |
| `DL/d10_param_rise_fall` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § caDelayParamElabFresh164 |
| `DL/d11_param_three_list` | NOT_EQUAL_stage1 | STRICT_EQUAL_111_objects| § caDelayFirstOnly164 |
| `EA/e01_unit_alias_used` | NOT_EQUAL_stage1 | STRICT_EQUAL_129_objects| § enumAliasClone161 |
| `EA/e02_alias_of_alias` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § enumAliasClone161 |
| `EA/e03_int_base` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § enumAliasClone161 |
| `EA/e04_signed_base` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § enumAliasClone161 |
| `EA/e05_iface_alias_port` | NOT_EQUAL_stage1 | STRICT_EQUAL_200_objects| § enumAliasClone161 |
| `EA/e06_param_range_base` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § enumAliasClone161 § enumAliasBaseAsTarget164v |
| `FO/f01_ordered_3lvl_first` | STRICT_NOTEQUAL_col | STRICT_EQUAL_99_objects| § firstOrderedPathSel161 |
| `FO/f02_ordered_bitsel_first` | STRICT_NOTEQUAL_col | STRICT_NOTEQUAL_col| § firstOrderedPathSel161 |
| `FO/f03_ordered_iface_member` | STRICT_NOTEQUAL_col | STRICT_EQUAL_94_objects| § firstOrderedPathSel161 |
| `FO/f04_ordered_two_insts` | STRICT_NOTEQUAL_col | STRICT_EQUAL_97_objects| § firstOrderedPathSel161 |
| `ND/n01_struct_member` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_70_objects| § genNetDeclAssignLhsShared164 |
| `ND/n02_path_bitsel` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_52_objects| § genNetDeclAssignLhsShared164 |
| `ND/n03_iface_signal` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_51_objects| § genNetDeclAssignLhsShared164 |
| `ND/n04_gencase` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_64_objects| § genNetDeclAssignLhsShared164 |
| `ND/n05_genfor_vec` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_90_objects| § genNetDeclAssignLhsShared164 |
| `ND/n06_delay_netdecl` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § genNetDeclAssignLhsShared164 |
| `ND/n07_abs_path` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_44_objects| § genNetDeclAssignLhsShared164 |
| `ND/n08_child_instance_path` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_71_objects| § genNetDeclAssignLhsShared164 |
| `ND/n09_typed_logic` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_48_objects| § genNetDeclAssignLhsShared164 |
| `PV/p01_ordered_two_overrides` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § modportPortViewParamDef164 § portViewParamShared164 |
| `PV/p02_ordered_two_params` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § modportPortViewParamDef164 |
| `PV/p03_typed_params` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_153_objects| § modportPortViewParamDef164 |
| `PV/p04_localparam` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_117_objects| § modportPortViewParamDef164 |
| `PV/p05_two_defs_same_param` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_189_objects| § portViewParamShared164 |
| `PV/p06_mixed_named_ordered` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_151_objects| § modportPortViewParamDef164 § portViewParamShared164 |
| `PV/p07_array_elems_named` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_134_objects| § modportPortViewParamDef164 § portViewParamShared164 |
| `PV/p08_string_param` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § modportPortViewParamDef164 |
| `PV/p09_child_param_and_iface` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_163_objects| § modportPortViewParamDef164 |
| `PV/p10_generic_two` | STRICT_EQUAL_125_objects | STRICT_EQUAL_125_objects| § modportPortViewParamDef164 § portViewParamShared164 |
| `PV/p11_ordered_same_value_default` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_148_objects| § portViewParamShared164 |
| `PV/p12_wildcard` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § modportPortViewParamDef164 |
| `PV/p13_shorthand` | STRICT_EQUAL_99_objects | STRICT_EQUAL_99_objects| § modportPortViewParamDef164 |
| `PV/p14_two_receivers` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_129_objects| § portViewParamShared164 |
| `PV/p15_genblk_inscope` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § modportPortViewParamDef164 |
| `PV/p16_named_twice_param_child` | STRICT_NOTEQUAL_type | STRICT_NOTEQUAL_type| § modportPortViewParamDef164 |
| `PV/p17_ref_style_ordered` | STRICT_NOTEQUAL_depth | STRICT_EQUAL_148_objects| § portViewParamShared164 |
| `PV/p18_mp_in_conn_ordered_ref` | STRICT_EQUAL_101_objects | STRICT_EQUAL_101_objects| § modportPortViewParamDef164 |
| `PV/p19_passthrough_mixed` | STRICT_NOTEQUAL_fullname | STRICT_EQUAL_179_objects| § modportPortViewParamDef164 § portViewParamShared164 |
| `RQ/r01_high_neg` | STRICT_NOTEQUAL_value | STRICT_NOTEQUAL_value| § rangeQueryFoldUnconverted164 |
| `RQ/r02_right_neg_asc` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryFoldUnconverted164 |
| `RQ/r03_high_wide_onto_narrow` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryDeclNetSize164 § rangeQueryVarDeclMask164v |
| `RQ/r04_high_dim2` | STRICT_NOTEQUAL_file | STRICT_NOTEQUAL_file| § rangeQueryFoldUnconverted164 |
| `RQ/r05_left_type` | STRICT_NOTEQUAL_file | STRICT_NOTEQUAL_file| § rangeQueryFoldUnconverted164 |
| `RQ/r06_high_unpacked` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryFoldUnconverted164 |
| `RQ/r07_low_signed_decl` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryDeclNetSize164 |
| `RQ/r08_param_child` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryFoldUnconverted164 § rangeQueryVarDeclMask164v |
| `RQ/r09_high_decl_var` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryDeclNetSize164 |
| `RQ/r10_high_selected_lhs` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryDeclNetSize164 |
| `RQ/r11_param_wide_onto_narrow` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryDeclNetSize164 |
| `RQ/r12_var_onto_2bit` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryDeclNetSize164 § rangeQueryVarDeclMask164v |
| `RQ/r13_var_implicit` | STRICT_NOTEQUAL_file | STRICT_NOTEQUAL_file| § rangeQueryFoldUnconverted164 |
| `RQ/r14_low_var_onto_1bit` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryVarDeclMask164v |
| `RQ/r15_right_asc_onto_2bit` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryVarDeclMask164v |
| `RQ/r16_net_onto_4bit` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryVarDeclMask164v |
| `RQ/r17_sized_bound` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryVarDeclMask164v |
| `RQ/r18_expr_bound_mod` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § rangeQueryVarDeclMask164v |
| `SB/s01_two_genvars` | STRICT_NOTEQUAL_fullname | STRICT_NOTEQUAL_fullname| § defGenSelBaseLeafAtIndex164 |
| `SB/s02_three_level` | STRICT_NOTEQUAL_col | STRICT_NOTEQUAL_fullname| § defGenSelBaseLeafAtIndex164 |
| `SB/s03_param_leaf` | NOT_EQUAL_stage1 | NOT_EQUAL_stage1| § defGenSelBaseLeafAtIndex164 |
| `SB/s04_op_base` | STRICT_NOTEQUAL_endcol | STRICT_NOTEQUAL_endcol| § defGenSelBaseLeafAtIndex164 |
| `SB/s05_unpacked` | STRICT_NOTEQUAL_endcol | STRICT_NOTEQUAL_fullname| § defGenSelBaseLeafAtIndex164 |
| `SB/s06_genif_inside_for` | STRICT_NOTEQUAL_endcol | STRICT_NOTEQUAL_fullname| § defGenSelBaseLeafAtIndex164 |

Notes by group:

* **PV:** 13 of 19 converted. The stage-1 cases p01 p02 p08 p12 p15 keep an identical cmp head and move toward golden
  order-blind (p02 50 -> 46, p08 40 -> 36, p12 58 -> 56, p15 29 -> 27). p12 (`.*`) and p13 (`.bus` shorthand) are the
  connection forms the implementer did not grid: p13 is STRICT_EQUAL on both binaries (the law keeps path names there,
  correctly), and p12 is stage 1 on a pre-existing face (ours mints a `hier_path (.*)` actual).
* **DL:** 7 converted. The residues are pre-existing, and the laws abstain on them:
  * d02 and d05: a delay inside a generate-scope assign (the delay is missing from ours);
  * d07: a package-parameter delay `#p::D` (golden ref_obj, ours constant);
  * d10: `#(R, F)` over parameters (golden operation with ref_obj R, ours constant `R`).
* **ND:** 8 of 9 converted: struct member, selected path, interface signal, gen-case, gen-for vector, absolute path,
  child instance, `wire logic`. n06 (`wire #1 z = A.x;`) is stage 1 on the missing net-declaration delay (pre-existing),
  order-blind 21 -> 6.
* **SB:** s02, s05 and s06 walk past the pristine head (#65 -> #131, #46 -> #103, #53 -> #116, objects 10/12/14 -> 8),
  and the remaining face is the elaborated refs `work@top.g[0].i` (ExprEmit, the sister's). s01 (two genvars) is
  unchanged, and s04 (operation base) is abstained, as designed.
* **EA:** e01 and e05 converted. e02, e03 and e04 are unmasked to the bare enum constant folded in golden's elaborated
  cont_assign (size 3 against 64, ExprEmit, r11u161 residue R6). e06 is at 2 order-blind lines after the fix (from 60
  pristine, 23 delivered).
* **FO:** 3 converted. f02 (a selected first actual) is abstained, as designed.
* **RQ:** these are value and shape faces of Surelog's range query, and none of them converts. After the fix no case is
  farther from golden than pristine except r17: the sized bound picks up the declared width 4, where golden keeps the
  literal's size 5. The field was already wrong on pristine (value UINT:4 against DEC:20), so this is not away from a
  matching field. The pre-existing faces:
  * r01: a negative bound prints `UINT:-1`, where golden has 65535;
  * r04: `$high(a, 2)`, where golden ignores the dimension argument (UINT:3);
  * r06: `$high` of an unpacked `[0:9]`, where golden reads UINT:10. This one is downstream DIVERGENT on both binaries
    (`connect \ccc 1'0` against `1'1`);
  * q07, r05, r13: golden hands back the located range-bound object.

**Every grid case gives pristine bytes with both landings off.** That covers these 77, the implementer's 63 and r11u161's
54, under `R11U164_OFF=1 R11U161_OFF=1` on the verified binary. **Each switch was dropped alone** over the same 194 cases:
all 17 switches run clean (rc 0; the only non-zero rc is DL/d06's Surelog abort), and each moves only its own law's
cases.

## 5. Gates on the verified patch (`ver4.bin`)

The sweep is `/tmp/v11u164_swV`, run from the worktree holding the verified patch. Its 3273 `slang:` lines all name
`ver4.bin`, and it exits 0 (`law index current`).

| gate | result |
|---|---|
| probe | EQUAL 2597 / STRICT_NOTEQUAL 1490; regressions 0, conversions 50, changes 73; `probe.csv` identical to the law sweep's |
| surelog | regressions 0, conversions 6, changes 4 (the same rows as the law sweep); `surelog.csv` differs from the law sweep only in LowMemLib/LowMemPkg testflags' detail text (the workdir path in the SURELOG_FAIL log line: environment) |
| uhdm2rtlil | regressions 0, conversions 8, changes 0; `uhdm2rtlil.csv` identical to the law sweep's |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0; `downstream.csv` byte-identical to the PRISTINE sweep's |
| uhdm-cmp on touched rows | every converted row is CMP_EQUAL, every changed row is judge-equal STRICT_NOTEQUAL, and the probe stage has no NOT_EQUAL case |
| canaries | surelog ok=50 changed=2 (Earlgrey_0_1 d/t, the attributed CHANGE); uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6) |

**Byte movers, verified against law.** The prediction was written after the verified sweep was launched and before any
of its results were read (`drivers/predict.py`, a source scan, fail-closed on `$FENCED`;
`evidence/prediction_ver4_vs_law.tsv`). Its positive control: the scan over this directory's cases finds all six
deterministic case movers (EA e06, RQ r03 r12 r14 r15 r16). It named 7 corpus candidates and no probe case:

* HighLow (`rqmask`: an implicit net, so no mask is expected);
* six `aliasbase` files whose aliases sit in packages or have literal bases (none expected).

It predicted 0 deterministic movers. Measured (SELFCHECK=1, path sets identical):

* surelog 7 / 952: MiniAmiq d/t, SeqDriver d/t and SimpleUVM d/t at exactly the 4-line UVM coin order-blind, and
  Scoreboard/default at 0 order-blind lines (the known svunit list-order coin);
* uhdm2rtlil 0 / 1608;
* probe 0 / 4087 (dump-normalised).

**Verified against pristine**: surelog 19 / 952 and uhdm2rtlil 12 / 1608, the same deterministic set as the law sweep
(section 3), plus the coins.

**Landings off.** `R11U164_OFF=1 R11U161_OFF=1` on `ver4.bin`, over the 13 moved tests in both modes (25 databases;
`verify_golden.py --filter`, the cmds.txt name `ver4.bin`), gives all 25 databases byte-identical to the pristine sweep's.

**Prior-pass control spot check.** The implementer's one strict-equal case that grows, r11u130 `g6/p07_two_level`
(STRICT_NOTEQUAL depth -> STRICT_EQUAL, order-blind 30 -> 32), was reproduced. The two extra lines are a column-0
`\_parameter: (work@my_iface.W)` and its `\_ref_typespec` under the dump's `\_weaklyReferenced:` section: the later
port view's own parameter object, orphaned by § portViewParamShared164. The judge and the plugin do not walk that
section.

## 6. Residues, ranked (this ground unless marked)

1. The residues the implementer lists, confirmed: OneNetModPort/OneNetModPortGeneric (program ports), GenerateUnnamed,
   GenForStructParamBound's interface range, the alias e15/e08/e13 faces, and Earlgrey_0_1's line face.
2. The range-query object face: for a variable, net or type argument, golden returns the located, decompiled declared
   bound (q07 r05 r13, and the stage-1 declared-net cases). A transcription of that object would convert these.
   Also r04 (the dimension argument ignored), r06 (an unpacked `$high` = 10, downstream-visible) and r01 (the negative
   value text).
3. The delay faces: a generate-scope assign's delay, a net declaration's delay, `#p::D`, and `#(R, F)` over parameters
   (DL d02 d05 d07 d10, ND n06).
4. `.*` wildcard connection of an interface port (PV p12, a garbage `hier_path (.*)`, downstream STATUS_DIFF on both
   binaries).
5. The sister ground (ExprEmit): the elaborated refs under a genvar-selected path (SB s01 s02 s05 s06), the bare enum
   constant's size in the elaborated cont_assign (EA e02 e03 e04 e06), and vA's column face.

## 7. Files

* `cases/<group>/<case>/dut.sv`: 77 cases, each with its law on its first line.
* `drivers/env.sh` (pinned tools, `$FENCED` from RESUME.md, fail-closed), `drivers/case.sh` (golden + ours + uhdm-cmp +
  uhdm-strictcmp), `drivers/obd.sh` (order-blind distance), `drivers/dscase.py` (downstream `one()`, fail-closed),
  `drivers/probe_normdump.sh` (path-normalised dump hash), `drivers/sweep.sh` (the gate sweep with the tools exported).
* `evidence/`: the case verdicts, downstream verdicts, compare outputs and byteverify outputs.
