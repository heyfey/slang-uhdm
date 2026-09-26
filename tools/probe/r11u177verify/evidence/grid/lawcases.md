#### § aggFoldReanchorFile177v: 10 cases, fired on 0

unfired (same bytes both modes): Z/z01_pkg_param_ref_default, Z/z02_pkg_struct_param_ref_default, Z/z03_module_localparam_ref, Z/z04_pkg_param_ref_instance_override, Z/z05_pkg_other_root_struct_ref_default, Z/z06_pkg_include_struct_ref_default, Z/z07_other_root_unqualified_import, Z/z08_other_root_instance_override, Z/z09_other_root_scalar_control, Z/z10_other_root_localparam_body

#### § gcaChainInsideSetKeepsInst169v: 10 cases, fired on 9

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| G/i01_range_ops | STAGE1-AWAY / STAGE1-SAME | S1 / S1 |
| G/i02_param_of_param | TOWARD / TOWARD | fullname / EQ |
| G/i03_range_two_params | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| G/i04_mixed_set_idx | TOWARD / TOWARD | fullname / fullname |
| G/i05_cond_member | MIXED / MIXED | fullname / fullname |
| G/i06_set_in_binary | TOWARD / TOWARD | EQ / EQ |
| G/i08_nested_inside_left | TOWARD / TOWARD | fullname / EQ |
| G/i09_bare_in_concat_range | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| G/n03_child_inside_override | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

unfired (same bytes both modes): G/i07_concat_member

#### § genCaFoldTsChainNamed169: 37 cases, fired on 22

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| G/g01_ashr | TOWARD / TOWARD | EQ / EQ |
| G/g02_ashl_left | TOWARD / TOWARD | EQ / EQ |
| G/g03_idx_of_idx | TOWARD / TOWARD | EQ / EQ |
| G/g04_idx_of_idx_op | TOWARD / BYTES-ONLY | EQ / EQ |
| G/g05_cond_binary_cond | TOWARD / BYTES-ONLY | EQ / EQ |
| G/g08_minus_chain | TOWARD / TOWARD | EQ / EQ |
| G/g11_bits_plus | STAGE1-CLOSER / STAGE1-SAME | S1 / S1 |
| G/g14_logic_and_chain | MIXED / MIXED | fullname / fullname |
| G/g15_cond_in_idx | TOWARD / TOWARD | EQ / EQ |
| G/g16_localparam_binary | TOWARD / TOWARD | EQ / EQ |
| G/g17_eqeq_wild_bare | TOWARD / TOWARD | EQ / EQ |
| G/g18_logic_or_bare | TOWARD / TOWARD | EQ / EQ |
| G/g19_neg_of_binary | TOWARD / TOWARD | EQ / EQ |
| G/g20_nested_cond | TOWARD / TOWARD | EQ / EQ |
| G/i04_mixed_set_idx | MIXED / MIXED | fullname / fullname |
| G/i06_set_in_binary | TOWARD / TOWARD | EQ / EQ |
| G/n03_child_inside_override | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x01_spaced_lit_param_in_loop | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x02_spaced_lit_macro_in_loop | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x03_hc_index_gen_param | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x04_hc_index_child_override | TOWARD / TOWARD | EQ / EQ |
| X/x12_chain_multiline_macro_operand | TOWARD / TOWARD | EQ / EQ |

unfired (same bytes both modes): G/g06_stream, G/g07_stream_slice, G/g09_partsel_op_bound, G/g10_idxpart_op_base, G/g12_cast_size, G/g13_repl_count_op, G/i01_range_ops, G/i02_param_of_param, G/i03_range_two_params, G/i05_cond_member, G/i07_concat_member, G/i08_nested_inside_left, G/i09_bare_in_concat_range, G/n01_three_level_loops, G/n02_child_override_nested

#### § hcSelIdxInstName168: 11 cases, fired on 6

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| H/h01_three_level_index | TOWARD / TOWARD | EQ / EQ |
| H/h04_gen_array_idx_of_idx | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| H/h05_three_deep_hier | TOWARD / TOWARD | EQ / EQ |
| X/x03_hc_index_gen_param | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x04_hc_index_child_override | TOWARD / TOWARD | EQ / EQ |
| X/x13_hc_idx_macro_conn_gen | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

unfired (same bytes both modes): H/h02_struct_member_of_elem, H/h03_two_dim_elem, H/h06_port_struct_member_partsel, H/h07_call_in_index, H/h08_packed2d_elem_bit

#### § macroConnInRange166: 3 cases, fired on 3

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| L/l07_macroconn_ranges | STAGE1-CLOSER / STAGE1-CLOSER | EQ / EQ |
| L/l09_macroconn_bitsel_multiline | STAGE1-CLOSER / STAGE1-CLOSER | EQ / EQ |
| X/x13_hc_idx_macro_conn_gen | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

#### § memLeftFormalArgLoc169: 25 cases, fired on 19

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| M/m01_call_actual | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m02_nested_call_body | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m03_binary_param_left | TOWARD / TOWARD | fullname / fullname |
| M/m04_unary_actual | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m07_override_param_actual | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m10_literal_underscore_based | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x06_partsel_bound_struct_member_func | TOWARD / TOWARD | fullname / fullname |
| X/x08_call_macro_from_include | TOWARD / TOWARD | col / col |
| X/x09_multiline_macro_actual_include | MIXED / MIXED | line / line |
| X/x10_spleaf_from_const_func | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| Y/y01_objml_incl_literal_nextline | MIXED / MIXED | line / line |
| Y/y02_funcml_incl_literal_nextline | MIXED / MIXED | line / line |
| Y/y03_objml_incl_literal_sameline | MIXED / MIXED | line / line |
| Y/y04_objml_incl_param_nextline | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| Y/y05_objml_incl_binary_nextline | MIXED / MIXED | line / line |
| Y/y06_objml_samefile_control | TOWARD / TOWARD | line / line |
| Y/y07_plain_multiline_call_control | TOWARD / TOWARD | fullname / fullname |
| Y/y08_module_header_default | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| Y/y09_objml_incl_both_literal_first | TOWARD / TOWARD | file / file |

unfired (same bytes both modes): M/m05_macro_expr_actual, M/m06_sign_cast_based, M/m08_pattern_literal_actual, M/m09_whole_member_through_pattern_param, X/x05_partsel_bound_from_const_func, X/x07_macro_actual_from_include

#### § memLeftSliceUnlocated169: 15 cases, fired on 14

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| M/m01_call_actual | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m02_nested_call_body | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m03_binary_param_left | TOWARD / TOWARD | fullname / fullname |
| M/m04_unary_actual | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m05_macro_expr_actual | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m06_sign_cast_based | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| M/m07_override_param_actual | STAGE1-SAME / STAGE1-SAME | S1 / S1 |
| M/m08_pattern_literal_actual | TOWARD / TOWARD | col / col |
| M/m10_literal_underscore_based | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x06_partsel_bound_struct_member_func | TOWARD / TOWARD | fullname / fullname |
| X/x07_macro_actual_from_include | TOWARD / TOWARD | col / col |
| X/x08_call_macro_from_include | TOWARD / TOWARD | col / col |
| X/x09_multiline_macro_actual_include | TOWARD / TOWARD | line / line |
| X/x10_spleaf_from_const_func | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

unfired (same bytes both modes): M/m09_whole_member_through_pattern_param

#### § mlArgLocFileAtActual177v: 9 cases, fired on 0

unfired (same bytes both modes): Y/y01_objml_incl_literal_nextline, Y/y02_funcml_incl_literal_nextline, Y/y03_objml_incl_literal_sameline, Y/y04_objml_incl_param_nextline, Y/y05_objml_incl_binary_nextline, Y/y06_objml_samefile_control, Y/y07_plain_multiline_call_control, Y/y08_module_header_default, Y/y09_objml_incl_both_literal_first

#### § paramBaseSelTsInstName168: 8 cases, fired on 1

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| P/p03_parent_param_passed | TOWARD / TOWARD | EQ / EQ |

unfired (same bytes both modes): P/p01_param_of_param, P/p02_param_of_param_override, P/p04_pkg_import_bound, P/p05_gen_if_bound, P/p06_localparam_of_localparam_param_base, X/x05_partsel_bound_from_const_func, X/x06_partsel_bound_struct_member_func

#### § patFlatMemberLeftSpan169: 7 cases, fired on 6

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| Q/q01_call_left_operand | TOWARD / TOWARD | endcol / endcol |
| Q/q03_unary_reduction_left | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| Q/q04_concat_repl_left | TOWARD / TOWARD | EQ / EQ |
| Q/q05_nested_three | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| Q/q06_override_shift | TOWARD / TOWARD | EQ / EQ |
| X/x11_patflat_multiline_macro | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

unfired (same bytes both modes): Q/q02_call_member

#### § ppBasedLitWsAfter166: 4 cases, fired on 4

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| L/l06_lit_spaces_after_paste | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| L/l10_lit_in_include_macro | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x01_spaced_lit_param_in_loop | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x02_spaced_lit_macro_in_loop | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

#### § ppFileCallArgBody168: 6 cases, fired on 3

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| F/f01_three_levels_two_files | MIXED / MIXED | line / line |
| F/f02_three_levels_three_files | MIXED / MIXED | line / line |
| F/f03_var_receiver_two_files | MIXED / MIXED | line / line |

unfired (same bytes both modes): X/x07_macro_actual_from_include, X/x08_call_macro_from_include, X/x09_multiline_macro_actual_include

#### § ppOutputCol166: 7 cases, fired on 7

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| L/l01_def_rootA_use_rootB | TOWARD / TOWARD | EQ / EQ |
| L/l03_paste_at_line_end | TOWARD / TOWARD | EQ / EQ |
| L/l04_stringify_escaped_quote | TOWARD / TOWARD | EQ / EQ |
| L/l12_stringify_multiline_actual | TOWARD / TOWARD | EQ / EQ |
| X/x02_spaced_lit_macro_in_loop | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x11_patflat_multiline_macro | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| X/x12_chain_multiline_macro_operand | TOWARD / TOWARD | EQ / EQ |

#### § ppOutputFile166: 38 cases, fired on 23

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| B/b01_objml_incl_then_nextline_actual | TOWARD / TOWARD | EQ / EQ |
| B/b02_objml_incl_oneline_then_next_stmt | TOWARD / TOWARD | EQ / EQ |
| B/b03_funcml_incl_then_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b05_objml_incl_oneline_call | TOWARD / TOWARD | EQ / EQ |
| B/b06_objml_incl_in_assign_multiline | TOWARD / TOWARD | EQ / EQ |
| B/b07_funcml_incl_multiline_actual | TOWARD / TOWARD | EQ / EQ |
| B/b08_objml_incl_then_same_line_tail | TOWARD / TOWARD | EQ / EQ |
| B/b09_objml_incl_call_var_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b10_objml_incl_pkg_call_nextline | STAGE1-SAME / STAGE1-SAME | S1 / S1 |
| B/b11_objml_incl_concat_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b12_objml_incl_sysfunc_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b13_objml_incl_task_call_nextline | TOWARD / TOWARD | EQ / EQ |
| X/x09_multiline_macro_actual_include | MIXED / MIXED | line / line |
| Y/y01_objml_incl_literal_nextline | MIXED / MIXED | line / line |
| Y/y02_funcml_incl_literal_nextline | MIXED / MIXED | line / line |
| Y/y03_objml_incl_literal_sameline | MIXED / MIXED | line / line |
| Y/y04_objml_incl_param_nextline | STAGE1-SAME / STAGE1-SAME | S1 / S1 |
| Y/y05_objml_incl_binary_nextline | MIXED / MIXED | line / line |
| Y/y08_module_header_default | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| Z/z01_pkg_param_ref_default | TOWARD / TOWARD | EQ / EQ |
| Z/z02_pkg_struct_param_ref_default | MIXED / MIXED | file / file |
| Z/z03_module_localparam_ref | STAGE1-SAME / STAGE1-SAME | S1 / S1 |
| Z/z04_pkg_param_ref_instance_override | TOWARD / TOWARD | EQ / EQ |

unfired (same bytes both modes): B/b04_objml_same_file_control, F/f01_three_levels_two_files, F/f02_three_levels_three_files, F/f03_var_receiver_two_files, X/x07_macro_actual_from_include, X/x08_call_macro_from_include, Y/y06_objml_samefile_control, Y/y07_plain_multiline_call_control, Y/y09_objml_incl_both_literal_first, Z/z05_pkg_other_root_struct_ref_default, Z/z06_pkg_include_struct_ref_default, Z/z07_other_root_unqualified_import, Z/z08_other_root_instance_override, Z/z09_other_root_scalar_control, Z/z10_other_root_localparam_body

#### § ppOutputInclLine166: 5 cases, fired on 1

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| L/l11_reinclude_multiline | TOWARD / TOWARD | EQ / EQ |

unfired (same bytes both modes): L/l02_nested_incl_multiline_body, L/l05_macro_in_arg_in_include, L/l08_def_rootA_use_rootB_include, L/l10_lit_in_include_macro

#### § ppOutputLine166: 23 cases, fired on 20

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| B/b01_objml_incl_then_nextline_actual | TOWARD / TOWARD | EQ / EQ |
| B/b02_objml_incl_oneline_then_next_stmt | TOWARD / TOWARD | EQ / EQ |
| B/b03_funcml_incl_then_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b05_objml_incl_oneline_call | TOWARD / TOWARD | EQ / EQ |
| B/b06_objml_incl_in_assign_multiline | TOWARD / TOWARD | EQ / EQ |
| B/b07_funcml_incl_multiline_actual | TOWARD / TOWARD | EQ / EQ |
| B/b08_objml_incl_then_same_line_tail | TOWARD / TOWARD | EQ / EQ |
| B/b09_objml_incl_call_var_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b10_objml_incl_pkg_call_nextline | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| B/b11_objml_incl_concat_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b12_objml_incl_sysfunc_nextline | TOWARD / TOWARD | EQ / EQ |
| B/b13_objml_incl_task_call_nextline | TOWARD / TOWARD | EQ / EQ |
| L/l01_def_rootA_use_rootB | TOWARD / TOWARD | EQ / EQ |
| L/l02_nested_incl_multiline_body | TOWARD / TOWARD | EQ / EQ |
| L/l04_stringify_escaped_quote | TOWARD / TOWARD | EQ / EQ |
| L/l05_macro_in_arg_in_include | TOWARD / TOWARD | EQ / EQ |
| L/l07_macroconn_ranges | TOWARD / TOWARD | EQ / EQ |
| L/l08_def_rootA_use_rootB_include | TOWARD / TOWARD | EQ / EQ |
| L/l12_stringify_multiline_actual | TOWARD / TOWARD | EQ / EQ |
| X/x11_patflat_multiline_macro | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

unfired (same bytes both modes): B/b04_objml_same_file_control, L/l03_paste_at_line_end, X/x12_chain_multiline_macro_operand

#### § ppReincludeSplice166: 1 cases, fired on 0

unfired (same bytes both modes): L/l11_reinclude_multiline

#### § rangeHierPathNoFullName168: 3 cases, fired on 2

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| R/r01_three_struct_levels | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| R/r03_iface_wire_two_levels_override | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

unfired (same bytes both modes): R/r02_module_wire_array

#### § structParamBoundAtPatternLeaf168: 10 cases, fired on 5

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| S/s02_outer_default | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| S/s03_two_level_override | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| S/s04_param_to_param_in_iface | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |
| S/s05_left_bound_positional_default | STAGE1-CLOSER / STAGE1-CLOSER | EQ / EQ |
| S/s06_pkg_param_nested_override | STAGE1-CLOSER / STAGE1-CLOSER | S1 / S1 |

unfired (same bytes both modes): R/r01_three_struct_levels, R/r02_module_wire_array, R/r03_iface_wire_two_levels_override, S/s01_nested_default, X/x10_spleaf_from_const_func

#### § undefKeepsOtherRootMacro168: 6 cases, fired on 4

| case | law off -> on (d / e) | ON verdict (d / e) |
|---|---|---|
| U/u01_undef_in_incl_of_root2 | TOWARD / TOWARD | EQ / EQ |
| U/u03_undef_never_defined | TOWARD / TOWARD | EQ / EQ |
| U/u04_undef_then_ifdef | TOWARD / TOWARD | EQ / EQ |
| U/u06_three_roots_redef_body_then_bare | TOWARD / TOWARD | EQ / EQ |

unfired (same bytes both modes): U/u02_redef_different_body, U/u05_undef_define_in_incl_root2

