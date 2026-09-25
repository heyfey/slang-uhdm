
### § NOGOLD

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `psc/p06_escaped_inst` | Surelog writes no database (SURELOG_FAIL) | | | | SURELOG_FAIL | |
| `tds/t01_program_nonansi` | Surelog writes no database (SURELOG_FAIL) | | | | SURELOG_FAIL | |
| `tds/t07_program_nonansi_plain` | Surelog writes no database (SURELOG_FAIL) | | | | SURELOG_FAIL | |

### § builtinMethodArgNamedByPath154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `mar/m01_task_body` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mar/m02_named_block_substr` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mar/m03_pkg_func` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mar/m04_queue_method` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mar/m05_struct_member_arg` | SN:fullname | SN:fullname | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mar/m06_nested_method_arg` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § defPkgStructParamMemberNames154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x09_pkg_struct_param_and_tp_ovr` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x10_pkg_struct_iface_and_tp_ovr` | S1(157) | S1(157) | UNFIRED | UNFIRED | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `cx/x14_unpacked_pkg_param_and_tp_ovr` | S1(36) | S1(36) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dps/d01_module_override` | S1(84) | S1(84) | UNFIRED | UNFIRED | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `dps/d02_cross_pkg_typedef` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dps/d03_union_param` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dps/d04_imported_type` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dps/d05_module_unpacked_pkgdef` | S1(36) | S1(36) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dps/d06_iface_two_params` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dps/d07_imported_unpacked` | S1(17) | S1(17) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dps/d08_three_level` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § dirlessFormalTypeAtName155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `dfn/d01_follower_after_input` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dfn/d02_ref_formal` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dfn/d03_unit_typedef` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dfn/d04_pkg_qualified_task` | EQ | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dfn/d05_interface_func` | SN:fullname | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `dfn/d06_spaced_scope` | EQ | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § elabCastSharesDeclRef154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cst/c01_gen_block_cast` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cst/c02_proc_cast` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cst/c03_param_width_only` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cst/c04_cast_in_concat` | EQ | SN:depth | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cst/c05_net_decl_assign` | S1(19) | S1(19) | UNFIRED | UNFIRED | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `cst/c06_port_actual` | EQ | SN:depth | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cst/c07_interface` | S1(33) | S1(33) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cst/c08_cast_of_expr` | EQ | SN:depth | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § genLpOperandTsNoParent152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x07_gen_proc_and_lp_operand` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x08_gen_proc_ps_lp_if` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § genProcFoldTsKeepsScope154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x07_gen_proc_and_lp_operand` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x08_gen_proc_ps_lp_if` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gft/f01_if_cond_idx` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gft/f02_local_param_in_block` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gft/f03_case_stmt` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gft/f04_nested_named` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gft/f05_initial_in_gen` | S1(46) | S1(46) | STAGE1-SAME | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § genScopeProcPsNamedByScope154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x07_gen_proc_and_lp_operand` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x08_gen_proc_ps_lp_if` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gsp/g01_loop_comb` | SN:col | SN:col | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gsp/g02_case_gen` | EQ | SN:fullname | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gsp/g03_iface_gen` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gsp/g04_loop_in_if` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `gsp/g05_latch_named_gen` | EQ | SN:fullname | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § hpElemSelNameIsPathSoFar154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x05_elem_path_and_child_port` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x06_elem_read_and_child_port` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x12_elem_ps_and_child_port` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `hpe/e01_two_dims` | S1(81) | S1(81) | UNFIRED | UNFIRED | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `hpe/e02_nested_iface_elem` | S1(1552) | S1(1552) | UNFIRED | UNFIRED | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `hpe/e03_proc_read` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `hpe/e04_var_idx_trailing_ps` | S1(42) | S1(42) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `hpe/e05_modport_proc_ps` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `hpe/e06_ips_trailing` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `hpe/e07_gen_loop_elem` | S1(38) | S1(38) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § hpPartSelBoundNamesBySelect154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `hpb/b01_iface_arr_elem` | S1(94) | S1(94) | STAGE1-CLOSER | STAGE1-CLOSER | STATUS_DIFF / STATUS_DIFF / STATUS_DIFF | SAME-AS-ON |
| `hpb/b02_nested_iface` | S1(1156) | S1(1156) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `hpb/b03_gen_loop_bound` | S1(200) | S1(200) | STAGE1-SAME | STAGE1-SAME | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `hpb/b04_modport_comb` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `hpb/b05_spaced_paren_bound` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § ifacePortViewFoldAtLeftOperand155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x01_pv_fold_and_nested_pat` | SN:col | SN:col | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x02_pv_fold_and_nested_pat_plain` | SN:col | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x13_pv_fold_nested_pat_typed_port` | SN:col | SN:col | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvl/v01_modulo` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvl/v02_param_pair` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvl/v03_modport_conn` | SN:col | SN:col | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvl/v04_logical_not` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvl/v05_left_is_op` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvl/v06_two_children` | SN:col | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvl/v07_nested_child` | SN:col | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § ifaceSigConnNamedByChildPort155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x05_elem_path_and_child_port` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x06_elem_read_and_child_port` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x12_elem_ps_and_child_port` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `isc/c01_sliced_member` | SN:fullname | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | STRICT_EQUAL_274_objects |
| `isc/c02_width_conv` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `isc/c03_escaped_port` | S1(64) | S1(64) | STAGE1-CLOSER | STAGE1-CLOSER | STATUS_DIFF / STATUS_DIFF / STATUS_DIFF | SAME-AS-ON |
| `isc/c04_iface_array_elem` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `isc/c05_macro_conn` | S1(31) | S1(31) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `isc/c06_inst_modport_conn` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `isc/c07_concat_member` | SN:depth | SN:fullname | TOWARD | TOWARD | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `isc/c08_macro_first_then_plain` | S1(31) | S1(31) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT / EQUIVALENT / EQUIVALENT | NOT_EQUAL_stage1 |
| `isc/c09_two_views_two_modports` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `isc/c10_bitsel_member` | SN:fullname | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | STRICT_EQUAL_262_objects |
| `isc/c11_bare_then_sliced` | SN:fullname | SN:fullname | MIXED | MIXED | IDENTICAL / IDENTICAL / IDENTICAL | STRICT_EQUAL_306_objects |
| `isc/c12_sliced_then_bare` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `isc/c13_ips_member` | SN:fullname | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | STRICT_EQUAL_301_objects |

### § implicitArgDimsInner155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `iad/i01_ref_follower` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `iad/i02_three_formals` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `iad/i03_desc_range` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `iad/i04_task_in_program` | S1(29) | S1(29) | STAGE1-CLOSER | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § initTsEndProgramLocal155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `itp/t01_fork_local` | S1(31) | S1(31) | STAGE1-CLOSER | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `itp/t02_bit_vector` | S1(29) | S1(29) | STAGE1-CLOSER | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `itp/t03_int_unsigned_expr` | S1(29) | S1(29) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `itp/t04_class_new_args` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `itp/t05_final_block` | S1(31) | S1(31) | STAGE1-CLOSER | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `itp/t06_multiline_init` | S1(31) | S1(31) | STAGE1-CLOSER | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § lvIdxPathIsRead154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `lxr/x01_struct_path_idx` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lxr/x02_blocking_comb_iface` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lxr/x03_ips_idx` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lxr/x04_concat_lhs` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lxr/x05_macro_index` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § lvIfacePathBitSelWhole154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `lbs/w01_var_index` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbs/w02_unpacked_member` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbs/w03_modport_blocking` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbs/w04_spaced_bitsel` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § lvPathBaseAtFirstMember154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x03_psel_conn_and_lv_chain` | S1(673) | S1(673) | STAGE1-CLOSER | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x04_psel_conn_struct_write` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x11_psel_conn_iface_in_gen` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbm/l01_macro_path` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbm/l02_nested_struct` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbm/l03_cont_assign` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbm/l04_escaped_base` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbm/l05_function_body` | S1(33) | S1(33) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lbm/l06_iface_spaced_path` | S1(124) | S1(124) | STAGE1-SAME | STAGE1-SAME | STATUS_DIFF / STATUS_DIFF / STATUS_DIFF | SAME-AS-ON |
| `lbm/l07_struct_spaced_comment` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § lvPathSelNamedByChain154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x03_psel_conn_and_lv_chain` | S1(673) | S1(671) | STAGE1-CLOSER | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x11_psel_conn_iface_in_gen` | EQ | SN:defname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lsn/s01_iface_ips_comb` | EQ | SN:defname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lsn/s02_modport_ps` | EQ | SN:defname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lsn/s03_gen_block_ps` | EQ | SN:defname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lsn/s04_ips_minus` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `lsn/s05_spaced_ps` | EQ | SN:defname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § modAggTfArgLastWriter155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `mag/m01_union_two_tasks` | EQ | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mag/m02_interface_func` | SN:fullname | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mag/m03_output_formal` | EQ | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mag/m04_child_module_two` | S1(17) | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `mag/m05_class_method_in_module` | S1(17) | S1(17) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § naArrNetOwnPortDecl155v

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `naa/a03_separate_reg` | SN:line | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `naa/a06_sep_wire_input_child` | S1(92) | S1(92) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `naa/a08_sep_logic_output` | S1(92) | S1(92) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § nonAnsiArrayNetAtHeader155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `naa/a01_two_decls_one_port_decl` | S1(30) | S1(30) | STAGE1-CLOSER | STAGE1-CLOSER | STATUS_DIFF / STATUS_DIFF / STATUS_DIFF | SAME-AS-ON |
| `naa/a02_reg_output` | EQ | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `naa/a03_separate_reg` | SN:line | SN:line | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `naa/a04_explicit_port` | S1(30) | S1(30) | UNFIRED | UNFIRED | DIVERGENT / DIVERGENT / DIVERGENT | SAME-AS-ON |
| `naa/a05_child_generated` | S1(27) | S1(27) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `naa/a06_sep_wire_input_child` | S1(92) | S1(92) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `naa/a07_escaped_name` | EQ | SN:line | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `naa/a08_sep_logic_output` | S1(92) | S1(92) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § packedStructNdaFoldConstLoc155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `nda/n01_pkg_typedef` | S1(207) | S1(207) | UNFIRED | UNFIRED | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `nda/n02_gen_scope` | S1(250) | S1(250) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `nda/n03_child_instance` | EQ | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `nda/n04_hex_literal` | S1(36) | S1(36) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `nda/n05_unit_typedef` | EQ | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `nda/n06_two_declarators` | EQ | SN:file | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `nda/n07_macro_value` | S1(36) | S1(36) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § paramInitUnpackedMemberPath154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `piu/u01_module_localparam` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `piu/u02_iface_param_chain` | S1(50) | S1(50) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `piu/u03_param_default_expr` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `piu/u04_spaced_member` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § pkgTdStretchNonAnsiHeaderSkips155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `tds/t02_iface_nonansi` | EQ | SN:endline | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `tds/t03_program_header_import` | S1(278) | S1(278) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `tds/t04_module_empty_hdr_enum` | EQ | SN:endline | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `tds/t05_child_nonansi` | EQ | SN:endline | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `tds/t06_program_automatic_empty` | S1(244) | S1(244) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § portViewNestedPatTsNamed154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x01_pv_fold_and_nested_pat` | SN:col | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x02_pv_fold_and_nested_pat_plain` | SN:col | SN:col | BYTES-ONLY | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x13_pv_fold_nested_pat_typed_port` | SN:col | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvn/n01_positional_modport` | SN:col | SN:col | BYTES-ONLY | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvn/n02_port_modport_typed` | EQ | SN:fullname | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pvn/n03_override_inst` | S1(78) | S1(78) | UNFIRED | UNFIRED | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `pvn/n04_generic_port` | SN:line | SN:line | BYTES-ONLY | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § psBoundPathFirstMember154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `pbp/p01_both_bounds` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pbp/p02_lvalue_bound` | EQ | SN:col | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pbp/p03_struct_param_path` | SN:col | SN:col | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `pbp/p04_spaced_path_bound` | S1(64) | S1(66) | STAGE1-CLOSER | STAGE1-CLOSER | STATUS_DIFF / STATUS_DIFF / STATUS_DIFF | SAME-AS-ON |

### § pselConnNameNotFrozen155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x03_psel_conn_and_lv_chain` | S1(673) | S1(673) | STAGE1-CLOSER | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x04_psel_conn_struct_write` | EQ | SN:fullname | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x11_psel_conn_iface_in_gen` | EQ | SN:fullname | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `psc/p01_ips_gen_loop` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `psc/p02_positional_gen_if` | S1(27) | S1(27) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `psc/p03_struct_member_ps` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `psc/p04_output_ps` | EQ | SN:fullname | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `psc/p05_nested_loops` | EQ | SN:fullname | TOWARD | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § tdStretchProgramKeeps155v

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `tds/t03_program_header_import` | S1(278) | S1(278) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `tds/t06_program_automatic_empty` | S1(244) | S1(244) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § tpOvrTypedefStructSpan152

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `cx/x09_pkg_struct_param_and_tp_ovr` | EQ | SN:endcol | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `cx/x10_pkg_struct_iface_and_tp_ovr` | S1(157) | S1(157) | STAGE1-CLOSER | STAGE1-CLOSER | EQUIVALENT / EQUIVALENT / EQUIVALENT | SAME-AS-ON |
| `cx/x14_unpacked_pkg_param_and_tp_ovr` | S1(36) | S1(36) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § unitAggTfArgLastWriter155

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `uag/u01_task_then_func` | S1(17) | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `uag/u02_union_default_arg` | SN:type | SN:line | TOWARD | STAGE1-CLOSER | DIVERGENT / DIVERGENT / DIVERGENT | SAME-AS-ON |
| `uag/u03_dpi_and_func` | SN:line | SN:line | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `uag/u04_class_method_and_func` | SN:line | SN:line | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `uag/u05_macro_function` | S1(17) | S1(17) | STAGE1-CLOSER | STAGE1-CLOSER | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § varInitDefNetModuleOnly154v

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `vid/v02_iface_substr` | EQ | SN:depth | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v03_program_compare` | EQ | SN:count | BYTES-ONLY | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v06_iface_in_module_port` | EQ | SN:depth | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### § varInitStrMethodArgDefNet154

| case | on | own switch off | score (default) | score (--elabuhdm) | downstream on / own off / all off | fix |
|---|---|---|---|---|---|---|
| `vid/v01_child_module` | EQ | SN:depth | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v02_iface_substr` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v03_program_compare` | EQ | EQ | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v04_module_task_static` | S1(162) | S1(162) | UNFIRED | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v05_module_getc` | EQ | SN:count | BYTES-ONLY | BYTES-ONLY | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v06_iface_in_module_port` | EQ | SN:depth | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v07_string_input_port` | EQ | SN:depth | TOWARD | TOWARD | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |
| `vid/v08_param_computed_arg` | EQ | SN:depth | TOWARD | UNFIRED | IDENTICAL / IDENTICAL / IDENTICAL | SAME-AS-ON |

### Tally per law (default mode)

| law | cases | TOWARD | STAGE1-CLOSER | STAGE1-SAME | BYTES-ONLY | UNFIRED | AWAY/MIXED/STAGE1-AWAY |
|---|---|---|---|---|---|---|---|
| § builtinMethodArgNamedByPath154 | 6 | 3 | 0 | 0 | 0 | 3 | 0 |
| § defPkgStructParamMemberNames154 | 11 | 2 | 0 | 3 | 0 | 6 | 0 |
| § dirlessFormalTypeAtName155 | 6 | 5 | 0 | 0 | 0 | 1 | 0 |
| § elabCastSharesDeclRef154 | 8 | 3 | 0 | 0 | 0 | 5 | 0 |
| § genLpOperandTsNoParent152 | 2 | 2 | 0 | 0 | 0 | 0 | 0 |
| § genProcFoldTsKeepsScope154 | 7 | 2 | 0 | 1 | 0 | 4 | 0 |
| § genScopeProcPsNamedByScope154 | 7 | 3 | 0 | 0 | 0 | 4 | 0 |
| § hpElemSelNameIsPathSoFar154 | 10 | 3 | 0 | 0 | 0 | 7 | 0 |
| § hpPartSelBoundNamesBySelect154 | 5 | 2 | 2 | 1 | 0 | 0 | 0 |
| § ifacePortViewFoldAtLeftOperand155 | 10 | 7 | 0 | 0 | 0 | 3 | 0 |
| § ifaceSigConnNamedByChildPort155 | 16 | 12 | 3 | 0 | 0 | 0 | 1 |
| § implicitArgDimsInner155 | 4 | 3 | 1 | 0 | 0 | 0 | 0 |
| § initTsEndProgramLocal155 | 6 | 1 | 5 | 0 | 0 | 0 | 0 |
| § lvIdxPathIsRead154 | 5 | 5 | 0 | 0 | 0 | 0 | 0 |
| § lvIfacePathBitSelWhole154 | 4 | 4 | 0 | 0 | 0 | 0 | 0 |
| § lvPathBaseAtFirstMember154 | 10 | 7 | 2 | 1 | 0 | 0 | 0 |
| § lvPathSelNamedByChain154 | 7 | 5 | 1 | 0 | 0 | 1 | 0 |
| § modAggTfArgLastWriter155 | 5 | 3 | 1 | 0 | 0 | 1 | 0 |
| § naArrNetOwnPortDecl155v | 3 | 1 | 1 | 0 | 0 | 1 | 0 |
| § nonAnsiArrayNetAtHeader155 | 8 | 2 | 2 | 0 | 0 | 4 | 0 |
| § packedStructNdaFoldConstLoc155 | 7 | 3 | 2 | 0 | 0 | 2 | 0 |
| § paramInitUnpackedMemberPath154 | 4 | 3 | 1 | 0 | 0 | 0 | 0 |
| § pkgTdStretchNonAnsiHeaderSkips155 | 5 | 3 | 0 | 0 | 0 | 2 | 0 |
| § portViewNestedPatTsNamed154 | 7 | 3 | 0 | 0 | 3 | 1 | 0 |
| § psBoundPathFirstMember154 | 4 | 2 | 1 | 0 | 0 | 1 | 0 |
| § pselConnNameNotFrozen155 | 8 | 4 | 2 | 0 | 0 | 2 | 0 |
| § tdStretchProgramKeeps155v | 2 | 0 | 2 | 0 | 0 | 0 | 0 |
| § tpOvrTypedefStructSpan152 | 3 | 1 | 2 | 0 | 0 | 0 | 0 |
| § unitAggTfArgLastWriter155 | 5 | 1 | 2 | 0 | 0 | 2 | 0 |
| § varInitDefNetModuleOnly154v | 3 | 2 | 0 | 0 | 1 | 0 | 0 |
| § varInitStrMethodArgDefNet154 | 8 | 4 | 0 | 0 | 1 | 3 | 0 |
