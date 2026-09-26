#### § arrQueryFoldAtBound158 (1 cases: STAGE1-CLOSER 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x06_range_query_param_fold | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |

#### § bindUnresolvedPathNoName164 (4 cases: TOWARD 2, UNFIRED 2)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| bu/u01_bind_type_two_instances | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| bu/u02_bind_unresolved_selected | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | EQUIVALENT -> EQUIVALENT |
| bu/u03_bind_instance_path_target | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| bu/u04_bind_genscope_path | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § caDelayFirstOnly164 (9 cases: STAGE1-AWAY 1, STAGE1-CLOSER 3, TOWARD 3, UNFIRED 2)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| dl/d01_localparam_expr_list | type | S1 | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| dl/d02_pkg_param_list | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| dl/d03_expr_list | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| dl/d04_genif_literal_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d05_mintypmax_list | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| dl/d06_param_iface_two_insts | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| dl/d08_three_list_param_child | type | S1 | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| dl/d09_imported_param | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| dl/d10_param_delay_genfor_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § caDelayParamElabFresh164 (7 cases: STAGE1-CLOSER 3, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| dl/d01_localparam_expr_list | S1 | S1 | EQ | STAGE1-CLOSER | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| dl/d02_pkg_param_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d06_param_iface_two_insts | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d07_real_param | S1 | S1 | EQ | STAGE1-CLOSER | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| dl/d08_three_list_param_child | S1 | S1 | EQ | STAGE1-CLOSER | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| dl/d09_imported_param | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d10_param_delay_genfor_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § defGenPathSel161 (9 cases: STAGE1-CLOSER 3, TOWARD 3, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x05_defgen_vs_elab_path_select | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gp/g01_nested_iface_lhs_genif | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| gp/g02_genif_cond_two_paths | EQ | depth | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gp/g03_concat_lhs_genif | col | col | col | UNFIRED | col | UNFIRED | IDENTICAL -> IDENTICAL |
| gp/g04_genfor_port_param_bound | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gp/g05_gencase_item_struct_param | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| gp/g06_genif_cond_call_arg | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| gp/g07_rhs_concat_paths | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| hw/w05_genblock_target_def_view | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |

#### § defGenSelBaseLeafAtIndex164 (4 cases: STAGE1-CLOSER 2, TOWARD 1, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| sb/s01_genvar_expr_base | endcol | endcol | endcol | UNFIRED | endcol | UNFIRED | IDENTICAL -> IDENTICAL |
| sb/s02_iface_array_leaf | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| sb/s03_union_leaf | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| sb/s04_gencase_inside_for | endcol | endcol | fullname | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § enumAliasBaseAsTarget164v (3 cases: STAGE1-CLOSER 2, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| ea/e01_pkg_param_base_module_enum | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e05_header_param_base_override | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e06_unit_alias_expr_base | EQ | S1 | EQ | UNFIRED | EQ | UNFIRED | DIVERGENT -> IDENTICAL |

#### § enumAliasClone161 (10 cases: STAGE1-CLOSER 9, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x04_alias_enum_in_func_body | S1 | S1 | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e01_pkg_param_base_module_enum | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e02_alias_chain_iface | S1 | S1 | name | STAGE1-CLOSER | name | STAGE1-CLOSER | EQUIVALENT -> IDENTICAL |
| ea/e03_alias_in_program | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| ea/e04_iface_alias_modport_var | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e05_header_param_base_override | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e06_unit_alias_expr_base | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e07_unpacked_dim_alias | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| ea/e08_param_valued_members | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| ea/e09_unit_import_alias | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |

#### § evalFuncBodyRhsStampClone167 (12 cases: STAGE1-CLOSER 2, TOWARD 5, UNFIRED 5)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x04_alias_enum_in_func_body | fullname | S1 | fullname | TOWARD | fullname | TOWARD | DIVERGENT -> IDENTICAL |
| fb/b01_part_select | EQ | EQ | EQ | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b02_indexed_part_select | EQ | EQ | EQ | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b03_concat | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| fb/b04_user_call | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b05_size_cast | fullname | fullname | fullname | TOWARD | fullname | UNMASK | IDENTICAL -> IDENTICAL |
| fb/b06_ternary | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| fb/b07_unary_reduction | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| fb/b08_sys_call | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b09_nested_member | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| fb/b10_row_select | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b11_instance_array | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § firstOrderedPathSel161 (6 cases: STAGE1-CLOSER 1, TOWARD 1, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| fo/f01_ordered_iface_struct_member | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| fo/f02_ordered_instance_array | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| fo/f03_ordered_concat_first | col | col | col | UNFIRED | col | UNFIRED | IDENTICAL -> IDENTICAL |
| fo/f04_ordered_param_and_ports_genblk | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fo/f05_empty_first_ordered | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| fo/f06_partsel_first | col | col | col | UNFIRED | col | UNFIRED | IDENTICAL -> IDENTICAL |

#### § genNetDeclAssignLhsShared164 (7 cases: STAGE1-CLOSER 5, TOWARD 2)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x03_gen_netdecl_and_proc_fold | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| cx/x08_one_genscope_netdecl_and_fold | depth | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| nd/n01_two_declarators | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| nd/n02_tri_nettype | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| nd/n03_in_interface_genblk | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| nd/n04_signed_vec_genfor | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| nd/n05_iface_port_member | depth | depth | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § genProcFoldDeclTsScopeNamed167 (11 cases: STAGE1-CLOSER 1, TOWARD 4, UNFIRED 6)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x03_gen_netdecl_and_proc_fold | S1 | S1 | S1 | UNFIRED | depth | UNFIRED | IDENTICAL -> IDENTICAL |
| cx/x08_one_genscope_netdecl_and_fold | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gs/z01_struct_typed_param | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z02_signed_genfor | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| gs/z03_typedef_typed_param | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z04_int_typed_param | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z05_gencase_wide_range | fullname | fullname | EQ | TOWARD | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| gs/z06_ascending_range_bit | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gs/z07_param_select_genfor | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z08_genscope_contassign_ctl | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z09_param_in_genproc_expr | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § hpDotWsTrimmed167 (13 cases: STAGE1-CLOSER 10, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| hw/w01_blank_after_dot_lhs | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w02_port_actual | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w03_if_condition | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w04_genblock_scope_path | S1 | S1 | S1 | STAGE1-CLOSER | depth | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w05_genblock_target_def_view | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w06_three_dots_mixed | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| hw/w07_root_path | S1 | S1 | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| hw/w08_genarray_elem | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w09_root_path_noblank_ctl | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| hw/w10_genblock_scope_path_noblank_ctl | S1 | S1 | S1 | UNFIRED | depth | UNFIRED | IDENTICAL -> IDENTICAL |
| hw/w11_macro_path | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w12_index_member_blanks | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| hw/w13_index_member_noblank_ctl | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |

#### § hpSelRoute157 (1 cases: UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x05_defgen_vs_elab_path_select | EQ | col | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |

#### § modportPortViewParamDef164 (20 cases: STAGE1-CLOSER 8, STAGE1-SAME 1, TOWARD 7, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x01_pview_struct_typed_iface_param | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| cx/x02_pview_header_type_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| cx/x07_pview_generic_struct_param_iface | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| cx/x09_pview_header_param_and_tp_struct | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| pv/p01_shorthand_two_params | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p02_wildcard_passthrough | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | STATUS_DIFF -> STATUS_DIFF |
| pv/p03_iface_array_port | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p04_generic_two_levels | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p05_ordered_three_levels | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p06_derived_localparam_ordered | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p07_array_elem_genfor_named | fullname | fullname | EQ | TOWARD | fullname | UNMASK | IDENTICAL -> IDENTICAL |
| pv/p08_generic_modport_ordered_two_ifs | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | STATUS_DIFF -> STATUS_DIFF |
| pv/p09_named_absolute_path_actual | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p10_two_parents_different_values | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| pv/p11_iface_in_genblock_ordered | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p12_top_ordered_ctl | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p13_genif_view_iface_outside | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p14_genfor_ordered_elem | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p15_view_below_genblock_module | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p16_genif_named_inscope_ctl | S1 | S1 | S1 | STAGE1-CLOSER | fullname | MIXED | IDENTICAL -> IDENTICAL |

#### § pkgPatCallArgReadNoParent167 (4 cases: STAGE1-AWAY 3, TOWARD 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| pc/c01_nested_call | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pc/c02_genif_localparam | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pc/c03_member_arg_user_fn | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| pc/c04_iface_header_default | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |

#### § portViewParamShared164 (12 cases: STAGE1-AWAY 4, TOWARD 4, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x02_pview_header_type_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p01_shorthand_two_params | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p02_wildcard_passthrough | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | STATUS_DIFF -> STATUS_DIFF |
| pv/p03_iface_array_port | depth | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p04_generic_two_levels | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p05_ordered_three_levels | depth | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p07_array_elem_genfor_named | depth | fullname | EQ | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p08_generic_modport_ordered_two_ifs | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | STATUS_DIFF -> STATUS_DIFF |
| pv/p09_named_absolute_path_actual | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p10_two_parents_different_values | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p11_iface_in_genblock_ordered | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p14_genfor_ordered_elem | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |

#### § rangeQueryDeclNetSize164 (6 cases: STAGE1-CLOSER 5, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| rq/q01_left_param_onto_wider | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q03_high_var_genscope_decl | type | type | type | UNFIRED | line | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q05_low_net_masked | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q06_high_packed2d_onto_2bit | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q07_left_port_onto_decl | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q09_high_param_onto_var | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |

#### § rangeQueryFoldUnconverted164 (7 cases: STAGE1-SAME 2, TOWARD 1, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x06_range_query_param_fold | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | IDENTICAL -> IDENTICAL |
| rq/q01_left_param_onto_wider | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q02_right_unpacked_var_implicit | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | DIVERGENT -> DIVERGENT |
| rq/q03_high_var_genscope_decl | type | type | type | UNFIRED | line | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q04_low_localparam_implicit | value | value | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| rq/q08_high_param_genfor | S1 | S1 | S1 | UNFIRED | line | UNFIRED | DIVERGENT -> DIVERGENT |
| rq/q09_high_param_onto_var | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § rangeQueryVarDeclMask164v (4 cases: STAGE1-CLOSER 1, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| rq/q03_high_var_genscope_decl | type | type | type | UNFIRED | line | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q05_low_net_masked | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q06_high_packed2d_onto_2bit | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q07_left_port_onto_decl | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § s2ClonePrecheck167v (11 cases: BYTES-ONLY 1, STAGE1-CLOSER 4, UNFIRED 6)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| fb/b01_part_select | SLANG_FAIL | EQ | EQ | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b02_indexed_part_select | SLANG_FAIL | EQ | EQ | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b03_concat | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b04_user_call | fullname | fullname | fullname | BYTES-ONLY | fullname | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| fb/b05_size_cast | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b06_ternary | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | EQUIVALENT -> EQUIVALENT |
| fb/b07_unary_reduction | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b08_sys_call | SLANG_FAIL | fullname | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b09_nested_member | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| fb/b10_row_select | SLANG_FAIL | fullname | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b11_instance_array | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |

#### § tpAnonStructCopySpanAtKeyword167 (11 cases: BYTES-ONLY 1, STAGE1-CLOSER 6, TOWARD 1, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x07_pview_generic_struct_param_iface | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| cx/x09_pview_header_param_and_tp_struct | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| tp/t01_three_value_params_forms | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| tp/t02_function_formal_user | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t03_unpacked_struct | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t04_nested_type_params | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| tp/t05_header_default_two_insts_one_override | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| tp/t06_packed_union | endline | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| tp/t07_task_formal_and_ports | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t08_alias_of_type_param | fullname | fullname | fullname | BYTES-ONLY | fullname | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| tp/t09_cast_in_body | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |

#### § tpAnonStructLastParamUser167 (12 cases: STAGE1-AWAY 1, STAGE1-CLOSER 1, STAGE1-SAME 1, TOWARD 3, UNFIRED 6)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x01_pview_struct_typed_iface_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| cx/x02_pview_header_type_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| cx/x09_pview_header_param_and_tp_struct | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| tp/t01_three_value_params_forms | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t02_function_formal_user | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t03_unpacked_struct | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t04_nested_type_params | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| tp/t05_header_default_two_insts_one_override | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | EQUIVALENT -> EQUIVALENT |
| tp/t06_packed_union | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| tp/t07_task_formal_and_ports | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t08_alias_of_type_param | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t09_cast_in_body | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

totals: {'BYTES-ONLY': 2, 'STAGE1-AWAY': 9, 'STAGE1-CLOSER': 67, 'STAGE1-SAME': 4, 'TOWARD': 38, 'UNFIRED': 64, 'el:BYTES-ONLY': 10, 'el:MIXED': 1, 'el:STAGE1-AWAY': 14, 'el:STAGE1-CLOSER': 54, 'el:STAGE1-SAME': 4, 'el:TOWARD': 35, 'el:UNFIRED': 64, 'el:UNMASK': 2}
