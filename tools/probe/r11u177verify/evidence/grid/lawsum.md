| § aggFoldReanchorFile177v | 10 | UNFIRED 20 | FSAME 16, SKIP 4 |
| § gcaChainInsideSetKeepsInst169v | 10 | MIXED 2, STAGE1-AWAY 1, STAGE1-CLOSER 6, STAGE1-SAME 1, TOWARD 8, UNFIRED 2 | FNEUTRAL 2, FSAME 2, FTOWARD 8, SKIP 8 |
| § genCaFoldTsChainNamed169 | 37 | BYTES-ONLY 2, MIXED 4, STAGE1-CLOSER 9, STAGE1-SAME 1, TOWARD 28, UNFIRED 30 | FNEUTRAL 4, FSAME 20, FTOWARD 28, SKIP 22 |
| § hcSelIdxInstName168 | 11 | STAGE1-CLOSER 6, TOWARD 6, UNFIRED 10 | FSAME 4, FTOWARD 6, SKIP 12 |
| § macroConnInRange166 | 3 | STAGE1-CLOSER 6 | SKIP 6 |
| § memLeftFormalArgLoc169 | 25 | MIXED 10, STAGE1-CLOSER 16, TOWARD 12, UNFIRED 12 | FSAME 7, FTOWARD 22, SKIP 21 |
| § memLeftSliceUnlocated169 | 15 | STAGE1-CLOSER 14, STAGE1-SAME 2, TOWARD 12, UNFIRED 2 | FSAME 1, FTOWARD 12, SKIP 17 |
| § mlArgLocFileAtActual177v | 9 | UNFIRED 18 | FSAME 14, SKIP 4 |
| § paramBaseSelTsInstName168 | 8 | TOWARD 2, UNFIRED 14 | FSAME 11, FTOWARD 2, SKIP 3 |
| § patFlatMemberLeftSpan169 | 7 | STAGE1-CLOSER 6, TOWARD 6, UNFIRED 2 | FSAME 2, FTOWARD 6, SKIP 6 |
| § ppBasedLitWsAfter166 | 4 | STAGE1-CLOSER 8 | SKIP 8 |
| § ppFileCallArgBody168 | 6 | MIXED 6, UNFIRED 6 | FSAME 6, FTOWARD 6 |
| § ppOutputCol166 | 7 | STAGE1-CLOSER 4, TOWARD 10 | FTOWARD 10, SKIP 4 |
| § ppOutputFile166 | 38 | MIXED 12, STAGE1-CLOSER 2, STAGE1-SAME 6, TOWARD 26, UNFIRED 30 | FAWAY 12, FSAME 28, FTOWARD 26, SKIP 10 |
| § ppOutputInclLine166 | 5 | TOWARD 2, UNFIRED 8 | FSAME 6, FTOWARD 2, SKIP 2 |
| § ppOutputLine166 | 23 | STAGE1-CLOSER 4, TOWARD 36, UNFIRED 6 | FSAME 6, FTOWARD 36, SKIP 4 |
| § ppReincludeSplice166 | 1 | UNFIRED 2 | FSAME 2 |
| § rangeHierPathNoFullName168 | 3 | STAGE1-CLOSER 4, UNFIRED 2 | SKIP 6 |
| § structParamBoundAtPatternLeaf168 | 10 | STAGE1-CLOSER 10, UNFIRED 10 | SKIP 20 |
| § undefKeepsOtherRootMacro168 | 6 | TOWARD 8, UNFIRED 4 | FSAME 4, FTOWARD 8 |

| case | ON d | ALLOFF d | ON el | ALLOFF el | rc (all states) |
|---|---|---|---|---|---|
| B/b01_objml_incl_then_nextline_actual | EQ | file | EQ | file | 0 |
| B/b02_objml_incl_oneline_then_next_stmt | EQ | file | EQ | file | 0 |
| B/b03_funcml_incl_then_nextline | EQ | file | EQ | file | 0 |
| B/b04_objml_same_file_control | EQ | EQ | EQ | EQ | 0 |
| B/b05_objml_incl_oneline_call | EQ | file | EQ | file | 0 |
| B/b06_objml_incl_in_assign_multiline | EQ | file | EQ | file | 0 |
| B/b07_funcml_incl_multiline_actual | EQ | file | EQ | file | 0 |
| B/b08_objml_incl_then_same_line_tail | EQ | file | EQ | file | 0 |
| B/b09_objml_incl_call_var_nextline | EQ | file | EQ | file | 0 |
| B/b10_objml_incl_pkg_call_nextline | S1(64) | S1(64) | S1(64) | S1(64) | 0 |
| B/b11_objml_incl_concat_nextline | EQ | file | EQ | file | 0 |
| B/b12_objml_incl_sysfunc_nextline | EQ | file | EQ | file | 0 |
| B/b13_objml_incl_task_call_nextline | EQ | file | EQ | file | 0 |
| F/f01_three_levels_two_files | line | endcol | line | endcol | 0 |
| F/f02_three_levels_three_files | line | endcol | line | endcol | 0 |
| F/f03_var_receiver_two_files | line | endcol | line | endcol | 0 |
| G/g01_ashr | EQ | fullname | EQ | fullname | 0 |
| G/g02_ashl_left | EQ | fullname | EQ | fullname | 0 |
| G/g03_idx_of_idx | EQ | fullname | EQ | fullname | 0 |
| G/g04_idx_of_idx_op | EQ | fullname | EQ | EQ | 0 |
| G/g05_cond_binary_cond | EQ | fullname | EQ | EQ | 0 |
| G/g06_stream | S1(46) | S1(46) | S1(50) | S1(50) | 0 |
| G/g07_stream_slice | S1(28) | S1(28) | S1(28) | S1(28) | 0 |
| G/g08_minus_chain | EQ | fullname | EQ | fullname | 0 |
| G/g09_partsel_op_bound | EQ | EQ | EQ | EQ | 0 |
| G/g10_idxpart_op_base | S1(144) | S1(144) | S1(144) | S1(144) | 0 |
| G/g11_bits_plus | S1(40) | S1(40) | S1(40) | S1(40) | 0 |
| G/g12_cast_size | fullname | fullname | EQ | EQ | 0 |
| G/g13_repl_count_op | EQ | EQ | EQ | EQ | 0 |
| G/g14_logic_and_chain | fullname | fullname | fullname | fullname | 0 |
| G/g15_cond_in_idx | EQ | fullname | EQ | fullname | 0 |
| G/g16_localparam_binary | EQ | fullname | EQ | fullname | 0 |
| G/g17_eqeq_wild_bare | EQ | fullname | EQ | fullname | 0 |
| G/g18_logic_or_bare | EQ | fullname | EQ | fullname | 0 |
| G/g19_neg_of_binary | EQ | fullname | EQ | fullname | 0 |
| G/g20_nested_cond | EQ | fullname | EQ | fullname | 0 |
| G/i01_range_ops | S1(158) | S1(158) | S1(158) | S1(158) | 0 |
| G/i02_param_of_param | fullname | fullname | EQ | EQ | 0 |
| G/i03_range_two_params | S1(106) | S1(106) | S1(106) | S1(106) | 0 |
| G/i04_mixed_set_idx | fullname | fullname | fullname | fullname | 0 |
| G/i05_cond_member | fullname | fullname | fullname | fullname | 0 |
| G/i06_set_in_binary | EQ | fullname | EQ | fullname | 0 |
| G/i07_concat_member | fullname | fullname | EQ | EQ | 0 |
| G/i08_nested_inside_left | fullname | fullname | EQ | EQ | 0 |
| G/i09_bare_in_concat_range | S1(106) | S1(106) | S1(106) | S1(106) | 0 |
| G/n01_three_level_loops | EQ | EQ | EQ | EQ | 0 |
| G/n02_child_override_nested | EQ | EQ | EQ | EQ | 0 |
| G/n03_child_inside_override | S1(192) | S1(192) | S1(192) | S1(192) | 0 |
| H/h01_three_level_index | EQ | fullname | EQ | fullname | 0 |
| H/h02_struct_member_of_elem | S1(103) | S1(103) | S1(103) | S1(103) | 0 |
| H/h03_two_dim_elem | fullname | fullname | fullname | fullname | 0 |
| H/h04_gen_array_idx_of_idx | S1(40) | S1(40) | S1(40) | S1(40) | 0 |
| H/h05_three_deep_hier | EQ | fullname | EQ | fullname | 0 |
| H/h06_port_struct_member_partsel | S1(17) | S1(17) | S1(17) | S1(17) | 0 |
| H/h07_call_in_index | S1(17) | S1(17) | S1(17) | S1(17) | 0 |
| H/h08_packed2d_elem_bit | fullname | fullname | fullname | fullname | 0 |
| L/l01_def_rootA_use_rootB | EQ | file | EQ | file | 0 |
| L/l02_nested_incl_multiline_body | EQ | file | EQ | file | 0 |
| L/l03_paste_at_line_end | EQ | col | EQ | col | 0 |
| L/l04_stringify_escaped_quote | EQ | line | EQ | line | 0 |
| L/l05_macro_in_arg_in_include | EQ | line | EQ | line | 0 |
| L/l06_lit_spaces_after_paste | S1(36) | S1(36) | S1(36) | S1(36) | 0 |
| L/l07_macroconn_ranges | EQ | S1(43) | EQ | S1(47) | 0 |
| L/l08_def_rootA_use_rootB_include | EQ | file | EQ | file | 0 |
| L/l09_macroconn_bitsel_multiline | EQ | S1(31) | EQ | S1(35) | 0 |
| L/l10_lit_in_include_macro | S1(36) | S1(36) | S1(36) | S1(36) | 0 |
| L/l11_reinclude_multiline | EQ | line | EQ | line | 0 |
| L/l12_stringify_multiline_actual | EQ | line | EQ | line | 0 |
| M/m01_call_actual | S1(60) | S1(60) | S1(60) | S1(60) | 0 |
| M/m02_nested_call_body | S1(28) | S1(28) | S1(28) | S1(28) | 0 |
| M/m03_binary_param_left | fullname | col | fullname | col | 0 |
| M/m04_unary_actual | S1(60) | S1(60) | S1(60) | S1(60) | 0 |
| M/m05_macro_expr_actual | S1(60) | S1(60) | S1(60) | S1(60) | 0 |
| M/m06_sign_cast_based | S1(32) | S1(32) | S1(32) | S1(32) | 0 |
| M/m07_override_param_actual | S1(58) | S1(62) | S1(58) | S1(62) | 0 |
| M/m08_pattern_literal_actual | col | col | col | col | 0 |
| M/m09_whole_member_through_pattern_param | S1(81) | S1(81) | file | file | 0 |
| M/m10_literal_underscore_based | S1(60) | S1(60) | S1(60) | S1(60) | 0 |
| P/p01_param_of_param | EQ | EQ | EQ | EQ | 0 |
| P/p02_param_of_param_override | EQ | EQ | EQ | EQ | 0 |
| P/p03_parent_param_passed | EQ | fullname | EQ | fullname | 0 |
| P/p04_pkg_import_bound | fullname | fullname | fullname | fullname | 0 |
| P/p05_gen_if_bound | depth | depth | EQ | EQ | 0 |
| P/p06_localparam_of_localparam_param_base | S1(36) | S1(36) | S1(36) | S1(36) | 0 |
| Q/q01_call_left_operand | endcol | endcol | endcol | endcol | 0 |
| Q/q02_call_member | endcol | endcol | endcol | endcol | 0 |
| Q/q03_unary_reduction_left | S1(36) | S1(36) | S1(36) | S1(36) | 0 |
| Q/q04_concat_repl_left | EQ | endcol | EQ | endcol | 0 |
| Q/q05_nested_three | S1(949) | S1(949) | S1(949) | S1(949) | 0 |
| Q/q06_override_shift | EQ | endcol | EQ | endcol | 0 |
| R/r01_three_struct_levels | S1(180) | S1(180) | S1(180) | S1(180) | 0 |
| R/r02_module_wire_array | S1(36) | S1(36) | S1(36) | S1(36) | 0 |
| R/r03_iface_wire_two_levels_override | S1(104) | S1(104) | S1(104) | S1(104) | 0 |
| S/s01_nested_default | S1(96) | S1(96) | S1(96) | S1(96) | 0 |
| S/s02_outer_default | S1(112) | S1(112) | S1(112) | S1(112) | 0 |
| S/s03_two_level_override | S1(84) | S1(84) | S1(84) | S1(84) | 0 |
| S/s04_param_to_param_in_iface | S1(72) | S1(36) | S1(76) | S1(36) | 0 |
| S/s05_left_bound_positional_default | EQ | S1(36) | EQ | S1(36) | 0 |
| S/s06_pkg_param_nested_override | S1(17) | S1(17) | S1(17) | S1(17) | 0 |
| U/u01_undef_in_incl_of_root2 | EQ | line | EQ | line | 0 |
| U/u02_redef_different_body | EQ | EQ | EQ | EQ | 0 |
| U/u03_undef_never_defined | EQ | line | EQ | line | 0 |
| U/u04_undef_then_ifdef | EQ | line | EQ | line | 0 |
| U/u05_undef_define_in_incl_root2 | EQ | EQ | EQ | EQ | 0 |
| U/u06_three_roots_redef_body_then_bare | EQ | line | EQ | line | 0 |
| X/x01_spaced_lit_param_in_loop | S1(64) | S1(64) | S1(64) | S1(64) | 0 |
| X/x02_spaced_lit_macro_in_loop | S1(36) | S1(36) | S1(36) | S1(36) | 0 |
| X/x03_hc_index_gen_param | S1(40) | S1(40) | S1(40) | S1(40) | 0 |
| X/x04_hc_index_child_override | EQ | fullname | EQ | fullname | 0 |
| X/x05_partsel_bound_from_const_func | EQ | EQ | EQ | EQ | 0 |
| X/x06_partsel_bound_struct_member_func | fullname | col | fullname | col | 0 |
| X/x07_macro_actual_from_include | col | col | col | col | 0 |
| X/x08_call_macro_from_include | col | col | col | col | 0 |
| X/x09_multiline_macro_actual_include | line | file | line | file | 0 |
| X/x10_spleaf_from_const_func | S1(50) | S1(50) | S1(50) | S1(50) | 0 |
| X/x11_patflat_multiline_macro | S1(132) | endcol | S1(132) | endcol | 0 |
| X/x12_chain_multiline_macro_operand | EQ | endcol | EQ | endcol | 0 |
| X/x13_hc_idx_macro_conn_gen | S1(17) | S1(17) | S1(17) | S1(17) | 0 |
| Y/y01_objml_incl_literal_nextline | line | file | line | file | 0 |
| Y/y02_funcml_incl_literal_nextline | line | file | line | file | 0 |
| Y/y03_objml_incl_literal_sameline | line | file | line | file | 0 |
| Y/y04_objml_incl_param_nextline | S1(60) | S1(60) | S1(60) | S1(60) | 0 |
| Y/y05_objml_incl_binary_nextline | line | file | line | file | 0 |
| Y/y06_objml_samefile_control | line | line | line | line | 0 |
| Y/y07_plain_multiline_call_control | fullname | col | fullname | col | 0 |
| Y/y08_module_header_default | S1(110) | S1(110) | S1(114) | S1(114) | 0 |
| Y/y09_objml_incl_both_literal_first | file | endcol | file | endcol | 0 |
| Z/z01_pkg_param_ref_default | EQ | file | EQ | file | 0 |
| Z/z02_pkg_struct_param_ref_default | file | S1(28) | file | S1(28) | 0 |
| Z/z03_module_localparam_ref | S1(60) | S1(60) | S1(64) | S1(64) | 0 |
| Z/z04_pkg_param_ref_instance_override | EQ | file | EQ | file | 0 |
| Z/z05_pkg_other_root_struct_ref_default | file | file | file | file | 0 |
| Z/z06_pkg_include_struct_ref_default | file | file | file | file | 0 |
| Z/z07_other_root_unqualified_import | EQ | EQ | EQ | EQ | 0 |
| Z/z08_other_root_instance_override | file | file | file | file | 0 |
| Z/z09_other_root_scalar_control | EQ | EQ | EQ | EQ | 0 |
| Z/z10_other_root_localparam_body | S1(78) | S1(78) | S1(86) | S1(86) | 0 |
