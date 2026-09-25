
### § blockLhsVarSelBindsWholeRef151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `arr/a01_task_body` | EQ115 | SN:depth | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `arr/a02_initial` | EQ126 | SN:depth | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL | as on |
| `arr/a03_named_in_for` | EQ133 | SN:depth | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL | as on |

### § classSpecNestedAtName152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cn/n01_named_arg` | S1(77) | S1(77) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |
| `cn/n02_two_nested_args` | SN:line | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `cn/n03_extends_nested` | EQ22 | EQ22 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cn/n04_pkg_typedef` | S1(28) | S1(28) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |

### § classSpecPaNoFile152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cf/f01_named_partial` | S1(141) | S1(141) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |
| `cf/f02_type_param_default` | S1(26) | S1(26) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |
| `cf/f03_func_arg` | S1(77) | S1(77) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |

### § classVarInitNewDecl152v

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cv/v01_copy_new` | S1(29) | S1(29) | STAGE1-AWAY | STAGE1-AWAY | EQUIVALENT(nohier) / IDENTICAL | MOVED(= off_classVarInitNewDecl152v) |
| `cv/v02_method_call` | EQ48 | SN:endcol | TOWARD | TOWARD | IDENTICAL / EQUIVALENT(nohier) | as on |
| `cv/v03_new_then_noinit` | S1(17) | S1(17) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/v04_ternary_null` | S1(87) | S1(87) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / EQUIVALENT(nohier) | as on |
| `cv/v05_var_kw` | EQ39 | EQ39 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/v06_static_kw` | EQ39 | EQ39 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/v07_copy_new_same_decl` | S1(29) | S1(29) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/v08_three_decl_null_new_copy` | S1(19) | S1(19) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/v09_spec_copy_new_ctl` | S1(29) | S1(29) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/v10_copy_new_only` | S1(29) | S1(29) | STAGE1-AWAY | STAGE1-AWAY | EQUIVALENT(nohier) / IDENTICAL | MOVED(= off_classVarInitNewDecl152v) |
| `cv/v11_typed_ctor` | S1(94) | S1(94) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/v12_copy_new_paren` | SLANG_FAIL | SLANG_FAIL | NODB | NODB | SLANG_REJECT / SLANG_REJECT | - |

### § classVarInitSpan152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cv/s01_spec_static_call` | S1(77) | S1(77) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / EQUIVALENT(nohier) | as on |
| `cv/s02_spec_named_pa` | S1(18) | S1(18) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / EQUIVALENT(nohier) | as on |
| `cv/s03_typedef_spec_new` | S1(123) | S1(123) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / EQUIVALENT(nohier) | as on |
| `cv/s04_nested_class_scoped` | S1(20) | S1(20) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/s05_iface_scope` | EQ46 | EQ46 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cv/s06_spec_new_args` | S1(29) | S1(29) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / EQUIVALENT(nohier) | as on |

### § concatArrParamDefTs151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `g2/h01_gen_elem_read` | S1(32) | S1(32) | STAGE1-CLOSER | STAGE1-CLOSER | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | as on |
| `g2/h02_two_inst_override` | S1(338) | S1(338) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |

### § condTakenParamRhsShared151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `g/c01_three_level` | EQ235 | SN:depth | TOWARD | STAGE1-CLOSER | IDENTICAL / DIVERGENT(nohier il synth) | as on |
| `g/c02_repl_nested` | EQ181 | SN:depth | TOWARD | STAGE1-CLOSER | IDENTICAL / DIVERGENT(nohier il synth) | as on |
| `g/c03_child_cond_override` | EQ327 | SN:depth | TOWARD | STAGE1-CLOSER | IDENTICAL / EQUIVALENT(nohier il synth) | as on |

### § crossPkgFoldTsNameOnChain152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `pb/x01_width_from_pkg` | S1(46) | S1(46) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `pb/x02_module_default` | S1(64) | S1(64) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `pb/x03_localparam_pkg` | S1(36) | S1(36) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |

### § delayLiteralValueText152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `dv/d01_multi_assign` | SN:type | SN:value | MIXED | MIXED | IDENTICAL / IDENTICAL | as on |
| `dv/d02_many_digits` | EQ37 | SN:value | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `dv/d03_concat_lhs` | EQ63 | SN:value | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `dv/d04_multi_assign_int_ctl` | SN:type | SN:type | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |

### § enumQualDefaultDefSpan147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x08_tp_and_enum_default` | S1(88) | S1(88) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |
| `cx/x09_enum_default_typed_by_tp` | S1(17) | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `qen/q01_twice_inst` | EQ187 | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `qen/q02_type_param_mod` | S1(17) | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `qen/q03_import_and_qual` | S1(64) | S1(64) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |

### § firstOrderedConnBitSelWhole147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `pos/p01_param_idx` | S1(32) | S1(32) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `pos/p02_macro_sel` | S1(31) | S1(31) | UNFIRED | UNFIRED | EQUIVALENT(nohier il synth) / EQUIVALENT(nohier il synth) | as on |
| `pos/p03_escaped_first` | EQ122 | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `pos/p04_gen_genvar` | S1(27) | S1(27) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |

### § gcaBareBoundKeepsInst147v

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x07_bound_and_lp` | EQ316 | EQ316 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `mul/b01_two_bare` | EQ203 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `mul/b02_paren_bare` | SN:col | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |

### § gcaUseSiteParamConst147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x06_repl_and_lp` | EQ259 | EQ259 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `cx/x07_bound_and_lp` | EQ316 | EQ316 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `mul/g01_nested_loop` | EQ182 | EQ182 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `mul/g02_child_override` | S1(46) | S1(46) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `mul/g03_ips_bound` | SN:fullname | SN:fullname | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL | as on |
| `mul/g04_loop_in_if` | EQ151 | EQ151 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `mul/g05_repl_in_ternary` | EQ225 | SN:fullname | TOWARD | BYTES-ONLY | - / - | as on |
| `mul/g06_deep_op_count` | EQ254 | SN:fullname | TOWARD | TOWARD | - / - | as on |

### § genCaseItemUnnamed152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `gc/c01_multi_label_named_loop` | SN:line | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `gc/c02_in_interface` | EQ91 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `gc/c03_unnamed_wire` | EQ55 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |

### § genLpOperandTsNoParent152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x06_repl_and_lp` | EQ259 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `cx/x07_bound_and_lp` | EQ316 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `lp/l01_named_if_in_loop` | EQ107 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `lp/l02_outer_genvar_idx` | EQ133 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `lp/l03_case_in_loop` | EQ128 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `lp/l04_iface_nested` | S1(26) | S1(26) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |

### § hierSizeCastBaseStructTs151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `dd/x01_size_cast_ca` | S1(128) | S1(128) | STAGE1-CLOSER | STAGE1-CLOSER | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | as on |
| `dd/x02_size_cast_proc` | EQ137 | SN:type | TOWARD | TOWARD | IDENTICAL / EQUIVALENT(nohier il synth) | as on |

### § ifaceMemberTrailIdxNamesByPath147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x10_iface_tp_elem` | S1(60) | S1(60) | STAGE1-CLOSER | STAGE1-CLOSER | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | as on |
| `cx/x11_port_tp_elem_idx` | S1(124) | S1(124) | UNFIRED | UNFIRED | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | as on |
| `tsi/t01_idx_is_member` | S1(132) | S1(132) | UNFIRED | UNFIRED | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | as on |
| `tsi/t02_nested_iface` | S1(1428) | S1(1428) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |
| `tsi/t03_ternary_ff` | EQ243 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `tsi/t04_escaped_port` | S1(100) | S1(100) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |

### § lvIdxBitSelAtIndex147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `lvi/l01_case_ff` | EQ120 | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `lvi/l02_foreach` | EQ123 | EQ123 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `lvi/l03_latch` | EQ89 | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `lvi/l04_unpacked_idx` | EQ90 | EQ90 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `lvi/l05_function_body` | SN:type | SN:col | TOWARD | STAGE1-CLOSER | - / - | as on |

### § memberEnumCloneKeepsBase147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x04_clone_and_alias` | S1(32) | S1(17) | STAGE1-AWAY | STAGE1-AWAY | IDENTICAL / IDENTICAL | as on |
| `cx/x05_alias_member_clone` | S1(63) | S1(63) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `mec/m01_export` | EQ212 | S1(17) | STAGE1-AWAY | STAGE1-AWAY | IDENTICAL / IDENTICAL | as on |
| `mec/m02_port_type` | SN:fullname | S1(17) | STAGE1-AWAY | STAGE1-AWAY | IDENTICAL / IDENTICAL | as on |
| `mec/m03_nested_struct` | EQ280 | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |

### § nestedDefaultPatLoc147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `dfp/n01_gen_block_var` | EQ85 | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `dfp/n02_struct_arr` | S1(188) | S1(188) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT(nohier il synth) / EQUIVALENT(nohier il synth) | as on |
| `dfp/n03_ff_reset` | EQ127 | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `dfp/n04_typedef_elem` | S1(17) | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |

### § nestedPatOpTsNoParent151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `c3n/n01_three_level` | S1(272) | S1(272) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |
| `c3n/n02_module_local` | S1(58) | S1(58) | STAGE1-AWAY | STAGE1-AWAY | IDENTICAL / IDENTICAL | as on |
| `cx/x01_nested_port_two_inst` | S1(88) | S1(88) | STAGE1-AWAY | STAGE1-AWAY | IDENTICAL / IDENTICAL | as on |
| `cx/x02_nested_port_read_too` | EQ570 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `cx/x03_nested_port_hier` | EQ559 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |

### § nonblockingSelLhsBindsWholeRef151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `arr/b01_nb_reset_if` | EQ113 | SN:depth | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL | as on |
| `arr/b02_nb_partsel` | EQ98 | SN:depth | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL | as on |

### § packedElemAliasTypedef152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x04_clone_and_alias` | S1(32) | S1(32) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `cx/x05_alias_member_clone` | S1(63) | S1(63) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |
| `ea/e01_bare_import` | S1(36) | S1(36) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `ea/e02_module_alias` | S1(17) | S1(17) | STAGE1-AWAY | STAGE1-AWAY | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | MOVED(= off_packedElemAliasTypedef152) |
| `ea/e03_member` | SN:fullname | SN:fullname | MIXED | MIXED | IDENTICAL / IDENTICAL | as on |
| `ea/e04_local_alias_local_enum` | S1(17) | S1(17) | STAGE1-AWAY | STAGE1-AWAY | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | MOVED(= off_packedElemAliasTypedef152 alloff) |
| `ea/e05_local_alias_import` | S1(17) | S1(17) | STAGE1-AWAY | STAGE1-AWAY | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | MOVED(= off_packedElemAliasTypedef152) |
| `ea/e06_pkg_alias_other_pkg_bare` | EQ151 | SN:name | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `ea/e07_unit_alias` | S1(17) | S1(106) | STAGE1-AWAY | STAGE1-AWAY | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | MOVED(= off_packedElemAliasTypedef152) |
| `ea/e08_iface_alias` | S1(17) | S1(17) | STAGE1-AWAY | STAGE1-AWAY | EQUIVALENT(nohier il synth) / IDENTICAL | MOVED(= off_packedElemAliasTypedef152) |

### § patLeftoverOrphanCopy151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `dd/e01_two_members` | SN:fullname | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `dd/e02_child_holder` | SN:fullname | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |

### § pkgElemMemberPatNoLoc152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `uq/u01_module_union` | EQ171 | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `uq/u02_iface_typedef` | S1(137) | S1(137) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `uq/u03_three_dims_pkg` | EQ143 | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |

### § pkgLeafPatLocByWriting152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `pl/l01_module_typedef_import` | EQ155 | EQ155 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `pl/l02_iface_port_import` | S1(110) | S1(110) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `pl/l03_output_var_import` | EQ95 | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `pl/l04_member_bare_import` | EQ152 | EQ152 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |

### § pkgTdCastTargetOwnView151

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `d2/d01_enum_member` | S1(28) | S1(28) | STAGE1-SAME | STAGE1-SAME | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |
| `d2/d02_cast_concat` | S1(34) | S1(34) | STAGE1-SAME | STAGE1-SAME | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |
| `d2/d03_two_pkgs` | S1(34) | S1(34) | STAGE1-SAME | STAGE1-SAME | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |

### § portConnParamFoldAtActual152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x01_nested_port_two_inst` | S1(88) | S1(88) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `cx/x02_nested_port_read_too` | EQ570 | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `cx/x03_nested_port_hier` | EQ559 | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `pc/q01_two_ports_out_of_order` | EQ593 | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `pc/q02_escaped_inst` | SN:endcol | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `pc/q03_header_import` | EQ450 | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `pc/q04_param_child_deep` | EQ364 | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `pc/q05_pkg_qualified_ctl` | SN:col | SN:col | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `pc/q06_positional_ctl` | S1(60) | S1(60) | STAGE1-AWAY | STAGE1-SAME | IDENTICAL / IDENTICAL | as on |

### § tpElemPatAtUser152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x10_iface_tp_elem` | S1(60) | S1(60) | UNFIRED | UNFIRED | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | as on |
| `cx/x11_port_tp_elem_idx` | S1(124) | S1(124) | STAGE1-CLOSER | STAGE1-CLOSER | DIVERGENT(nohier il synth) / DIVERGENT(nohier il synth) | as on |
| `tp/t01_iface_port` | S1(60) | S1(60) | UNFIRED | UNFIRED | STATUS_DIFF / STATUS_DIFF | as on |
| `tp/t02_two_dims` | EQ94 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `tp/t03_parent_override` | EQ107 | EQ107 | BYTES-ONLY | BYTES-ONLY | IDENTICAL / IDENTICAL | as on |
| `tp/t04_pkg_elem` | S1(108) | S1(108) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |

### § tpOvrTypedefStructSpan152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cx/x08_tp_and_enum_default` | S1(88) | S1(88) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |
| `cx/x09_enum_default_typed_by_tp` | S1(17) | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL | as on |
| `ps/s01_union` | SN:endcol | SN:endcol | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `ps/s02_gen_scope_typedef` | SN:endcol | SN:endcol | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
| `ps/s03_nested_struct` | EQ155 | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `ps/s04_enum_member` | S1(68) | S1(68) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT(nohier il) / EQUIVALENT(nohier il) | as on |

### § unsupportedTsInitEnd152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `cg/u01_empty_parens` | EQ20 | SN:endcol | TOWARD | TOWARD | IDENTICAL / EQUIVALENT(nohier) | as on |
| `cg/u02_in_gen` | S1(53) | S1(53) | UNFIRED | UNFIRED | EQUIVALENT(nohier) / EQUIVALENT(nohier) | as on |
| `cg/u03_two_args_comment` | EQ22 | SN:endcol | TOWARD | TOWARD | IDENTICAL / EQUIVALENT(nohier) | as on |

### § vsIpsBaseNamesByIps147

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / off | fix binary |
|---|---|---|---|---|---|---|
| `ipb/v01_repl_base` | EQ102 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `ipb/v02_unary_base` | EQ98 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `ipb/v03_gen_loop_proc` | EQ142 | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL | as on |
| `ipb/v04_task_body` | EQ118 | EQ118 | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL | as on |
