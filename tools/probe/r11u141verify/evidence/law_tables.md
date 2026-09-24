
#### § defNetEndOnlyLoc130 (`R11U130_DEFNETLOC_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_defnetloc/a02_enum_macro | equal | ne:file(2) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_defnetloc/a03_enum_param_base | stage1 cmp=36 | stage1 cmp=36 → stage1 cmp=36: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p130_defnetloc/a04_pkg_packed_iface | stage1 cmp=53 | stage1 cmp=53 → stage1 cmp=53: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p130_defnetloc/a05_local_td_param_dim | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p130_defnetloc/a06_enum_pkg_param_base | stage1 cmp=60 | stage1 cmp=60 → stage1 cmp=60: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p130_defnetloc/a07_enum_int_unsigned | equal | ne:file(2) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |

#### § defNetVarNoSlot130v (`R11V130_DEFNETVAR_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_defnetvar/v01_var_enum_iface_base | stage1 cmp=41 | stage1 cmp=41 → stage1 cmp=41: untouched | untouched | untouched | DIVERGENT |
| p130_defnetvar/v02_var_scoped_2d | stage1 cmp=150 | stage1 cmp=150 → stage1 cmp=150: untouched | untouched | untouched | EQUIVALENT |
| p130_defnetvar/v03_var_enum_two_decl | equal | ne:file(4) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| p130_defnetvar/v04_var_enum_iface | equal | ne:file(2) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |

#### § netSigningTsSpan130 (`R11U130_NETSIGN_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_netsign/s01_supply_signed | stage1 cmp=58 | stage1 cmp=58 → stage1 cmp=58: stage1 both, bytes moved (dump lines: 9 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 9 fixed, 0 new) | IDENTICAL |
| p130_netsign/s02_wire_logic_signed | stage1 cmp=62 | stage1 cmp=62 → stage1 cmp=62: untouched | untouched | untouched | IDENTICAL |
| p130_netsign/s03_gen_block | stage1 cmp=62 | stage1 cmp=62 → stage1 cmp=62: untouched | untouched | untouched | IDENTICAL |
| p130_netsign/s04_macro_net | equal | ne:endcol(2) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_netsign/s05_two_decl_no_init | equal | ne:endcol(4) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |

#### § suSigningNotInSpan130 (`R11U130_SUSIGN_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_susign/k01_net_struct_signed | stage1 cmp=58 | stage1 cmp=58 → stage1 cmp=58: stage1 both, bytes moved (dump lines: 4 fixed, 4 new) | stage1 both | stage1 both, bytes moved (dump lines: 4 fixed, 4 new) | IDENTICAL |
| p130_susign/k02_struct_packed_dims | stage1 cmp=84 | stage1 cmp=84 → stage1 cmp=84: untouched | untouched | untouched | EQUIVALENT |
| p130_susign/k03_union_two_decl | ne:fullname(4) | ne:endcol(8) → ne:fullname(4): OK:better=4 | OK:better=2 | OK:better=4 | IDENTICAL |
| p130_susign/k04_program_struct | equal | ne:endcol(2) → equal: **turned equal** | OK:better=1 | **turned equal** | IDENTICAL |

#### § ifaceElabInlineSuKeyword130 (`R11U130_IFSUKW_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_ifsukw/i01_iface_array | equal | ne:endcol(2) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_ifsukw/i02_iface_in_gen | equal | ne:endcol(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_ifsukw/i03_iface_unpacked_struct | ne:endcol(2) | ne:endcol(2) → ne:endcol(2): untouched | untouched | untouched | IDENTICAL |

#### § wildcardConnRefSpan130 (`R11U130_WILDSPAN_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_wildspan/w01_macro_conn | stage1 cmp=19 | stage1 cmp=19 → stage1 cmp=19: untouched | untouched | untouched | STATUS_DIFF |
| p130_wildspan/w02_spaces_lines | equal | ne:endcol(2) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_wildspan/w03_port_default | stage1 cmp=1124 | stage1 cmp=1124 → stage1 cmp=1124: stage1 both, bytes moved (dump lines: 2 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 2 fixed, 0 new) | EQUIVALENT |
| p130_wildspan/w04_unpacked_ports | equal | ne:endcol(2) → equal: **turned equal** | OK:better=2 | **turned equal** | IDENTICAL |

#### § classSpecArgNetNoFile130 (`R11U130_CLSARGNET_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_clsargnet/c01_pkg_class_arg | stage1 cmp=102 | stage1 cmp=102 → stage1 cmp=102: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p130_clsargnet/c02_two_vars_same_arg | stage1 cmp=146 | stage1 cmp=146 → stage1 cmp=146: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p130_clsargnet/c03_program | stage1 cmp=94 | stage1 cmp=94 → stage1 cmp=94: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |

#### § portViewParamDefName130 (`R11U130_PVPARAM_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_pvparam/p01_string_param | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, bytes moved (dump lines: 12 fixed, 10 new) | stage1 both | stage1 both, bytes moved (dump lines: 12 fixed, 10 new) | EQUIVALENT |
| p130_pvparam/p02_array_elem_conn | equal | ne:fullname(2) → equal: **turned equal** | OK:better=2 | **turned equal** | IDENTICAL |
| p130_pvparam/p03_expr_override | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, bytes moved (dump lines: 12 fixed, 10 new) | stage1 both | stage1 both, bytes moved (dump lines: 12 fixed, 10 new) | IDENTICAL |

#### § emptyRedefineObjLine130 (`R11U130_REDEFLINE_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_redefline/r01_triple | equal | ne:line(29) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL (law off: EQUIVALENT, A3: EQUIVALENT) |
| p130_redefline/r02_args_then_bare | equal | ne:line(40) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL (law off: EQUIVALENT, A3: EQUIVALENT) |
| p130_redefline/r03_in_function | equal | ne:endline(20) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL (law off: EQUIVALENT, A3: EQUIVALENT) |
| p130_redefline/r04_celldefine | equal | ne:line(28) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL (law off: EQUIVALENT, A3: EQUIVALENT) |

#### § includeNoTextSplicesNothing130 (`R11U130_INCNOTEXT_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_incnotext/n01_undef_only | equal | ne:line(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_incnotext/n02_ifdef_else | equal | ne:line(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_incnotext/n03_define_trailing_comment | ne:line(1) | ne:line(1) → ne:line(1): untouched | untouched | untouched | IDENTICAL |
| p130_incnotext/n04_block_comment | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p130_incnotext/n05_default_nettype | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| res_inccomment/c01_define_block_comment | ne:line(1) | ne:line(1) → ne:line(1): untouched | untouched | untouched | IDENTICAL |
| res_inccomment/c02_undef_line_comment | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| res_inccomment/c03_ifdef_line_comment | ne:line(1) | ne:line(1) → ne:line(1): untouched | untouched | untouched | IDENTICAL |
| res_inccomment/c04_comment_own_line | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |

#### § includeLeadTabIsText130v (`R11V130_INCTAB_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| brk_inctab/b01_tab_else | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b02_tab_endif | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| brk_inctab/b03_tab_ifdef | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| brk_inctab/b04_tab_def_inactive | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b05_tab_def_active | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| brk_inctab/b06_tab_ifndef | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| brk_inctab/b07_tab_elsif | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b08_tab_else_active | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| brk_inctab/b09_tab_endif_only | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| brk_inctab/b10_tab_def_plain | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| brk_inctab/b11_tab_blank_inactive | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b12_nested_inactive | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b13_tab_endif_inactive | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b14_active_outer_inner_else | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b15_empty_inactive | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| brk_inctab/b16_empty_active | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| p130_inctab/t01_tab_undef | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| p130_inctab/t02_tab_else | ne:line(1) | equal → ne:line(1): BREAK:eq->ne | BREAK:eq->ne | untouched | IDENTICAL | fix: **turned equal**
| p130_inctab/t03_tab_then_space | equal | ne:line(1) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |

#### § genvarIntTsRootFile130 (`R11U130_GVTSFILE_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p130_gvtsfile/g01_inline_genvar_inc | equal | ne:file(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_gvtsfile/g02_sep_genvar_inc | equal | ne:file(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p130_gvtsfile/g03_two_loops_region | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |

#### § implicitNetMintNoFile131 (`R11U131_INETFILE_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_inetfile/f02_disable_named_fork | stage1 cmp=117 | stage1 cmp=117 → stage1 cmp=117: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p131_inetfile/f03_task_param | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p131_inetfile/f04_foreach_2d_func | equal | ne:file(4) → equal: **turned equal** | OK:better=2 | **turned equal** | IDENTICAL |
| p131_inetfile/f05_dumpvars_two_scopes | equal | ne:file(4) → equal: **turned equal** | OK:better=2 | **turned equal** | IDENTICAL |

#### § paramFoldParenSpan131 (`R11U131_PAREN_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_paren/q01_comment_in_paren | equal | ne:col(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p131_paren/q02_two_lines | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p131_paren/q03_paren_param_ref | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p131_paren/q04_program_param | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p131_paren/q05_paren_in_pkg_read | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p131_paren/q06_paren_ternary_default | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |

#### § pkgQualCallQualSpan131 (`R11U131_QCALL_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_qcall/c01_noarg | stage1 cmp=40 | stage1 cmp=40 → stage1 cmp=40: stage1 both, bytes moved (dump lines: 1 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 1 fixed, 0 new) | IDENTICAL |
| p131_qcall/c02_spaced_colons | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: untouched | untouched | untouched | IDENTICAL |
| p131_qcall/c03_iface_param | equal | ne:endcol(2) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |

#### § paramIdxPartSelWholeSpan131 (`R11U131_IPSSPAN_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| brk_ipsq/q01_qual_minus | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, bytes moved (dump lines: 2 fixed, 3 new) | stage1 both | stage1 both, bytes moved (dump lines: 2 fixed, 3 new) | EQUIVALENT | fix: stage1 both
| brk_ipsq/q02_import_bare | ne:depth(1) | ne:depth(1) → ne:depth(1): OK:better=0 | OK:better=0 | OK:better=0 | IDENTICAL |
| brk_ipsq/q03_qual_override | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| brk_ipsq/q04_qual_localparam | ne:col(1) | equal → ne:col(1): BREAK:eq->ne | BREAK:eq->ne | BREAK:eq->ne | IDENTICAL | fix: **turned equal**
| brk_ipsq/q05_qual_in_pkg | stage1 cmp=70 | stage1 cmp=70 → stage1 cmp=70: stage1 both, bytes moved (dump lines: 3 fixed, 3 new) | stage1 both | stage1 both, bytes moved (dump lines: 3 fixed, 3 new) | IDENTICAL | fix: stage1 both
| brk_ipsq/q06_qual_param_base | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: stage1 both, bytes moved (dump lines: 0 fixed, 2 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 2 new) | IDENTICAL | fix: stage1 both
| brk_ipsq/q07_qual_in_op | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, bytes moved (dump lines: 2 fixed, 3 new) | stage1 both | stage1 both, bytes moved (dump lines: 2 fixed, 3 new) | IDENTICAL | fix: stage1 both
| brk_ipsq/q08_local_ctl | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, bytes moved (dump lines: 3 fixed, 2 new) | stage1 both | stage1 both, bytes moved (dump lines: 3 fixed, 2 new) | EQUIVALENT |
| brk_ipsq/q09_qual_iface | stage1 cmp=31 | stage1 cmp=31 → stage1 cmp=31: stage1 both, bytes moved (dump lines: 2 fixed, 3 new) | stage1 both | stage1 both, bytes moved (dump lines: 2 fixed, 3 new) | IDENTICAL | fix: stage1 both
| p131_ipsspan/i01_pkg_param_sel | ne:col(1) | equal → ne:col(1): BREAK:eq->ne | BREAK:eq->ne | BREAK:eq->ne | IDENTICAL | fix: **turned equal**
| p131_ipsspan/i02_2d_elem_sel | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: untouched | untouched | untouched | EQUIVALENT |
| p131_ipsspan/i03_minus_expr_override | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: untouched | untouched | untouched | EQUIVALENT |

#### § sysCallKwTypeArgNameSpan131 (`R11U131_KWSYS_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_kwsys/s01_bits_time | stage1 cmp=54 | stage1 cmp=54 → stage1 cmp=54: stage1 both, bytes moved (dump lines: 4 fixed, 2 new) | stage1 both | stage1 both, bytes moved (dump lines: 4 fixed, 2 new) | EQUIVALENT |
| p131_kwsys/s02_bits_int_macro | equal | ne:endcol(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p131_kwsys/s03_bits_gen_localparam | ne:fullname(2) | ne:endcol(3) → ne:fullname(2): OK:better=1 | OK:better=1 | OK:better=1 | IDENTICAL |

#### § ovrMultiDimConstUnparented131 (`R11U131_OVRMD_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_ovrmd/o01_3d | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p131_ovrmd/o02_typedef_2d | stage1 cmp=122 | stage1 cmp=122 → stage1 cmp=122: untouched | untouched | untouched | IDENTICAL |
| p131_ovrmd/o03_iface_2d | stage1 cmp=31 | stage1 cmp=31 → stage1 cmp=31: stage1 both, bytes moved (dump lines: 1 fixed, 1 new) | stage1 both | stage1 both, bytes moved (dump lines: 1 fixed, 1 new) | IDENTICAL |
| p131_ovrmd/o04_signed_bit_2d | equal | ne:fullname(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p131_ovrmd/o05_pkg_typedef_2d | ne:name(2) | ne:name(2) → ne:name(2): untouched | untouched | untouched | IDENTICAL |

#### § pkgPatReadTsNoParent131 (`R11U131_PATTS_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_patts/t01_gen_for_bound | ne:endcol(3) | ne:fullname(4) → ne:endcol(3): OK:better=1 | OK:better=1 | OK:better=1 | IDENTICAL |
| p131_patts/t02_named_import_read | ne:fullname(3) | ne:fullname(4) → ne:fullname(3): OK:better=1 | OK:better=1 | OK:better=1 | IDENTICAL |
| p131_patts/t03_two_pkgs | equal | ne:fullname(2) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p131_patts/t04_nested_struct | stage1 cmp=88 | stage1 cmp=88 → stage1 cmp=88: untouched | untouched | untouched | IDENTICAL |

#### § pkgParamTsRefColons131 (`R11U131_PTSSEP_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_ptssep/g01_two_refs | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 4 fixed, 0 new) | IDENTICAL |
| p131_ptssep/g02_localparam_bit | stage1 cmp=50 | stage1 cmp=50 → stage1 cmp=50: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 2 fixed, 0 new) | IDENTICAL |
| p131_ptssep/g03_signed | stage1 cmp=68 | stage1 cmp=68 → stage1 cmp=68: stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 2 fixed, 0 new) | IDENTICAL |
| p131_ptssep/g04_unread | equal | equal → equal: EQUAL-both(bytes moved) | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p131_ptssep/g05_two_params_unread | ne:file(2) | ne:file(2) → ne:file(2): OK:better=0 | OK:better=0 | OK:better=6 | IDENTICAL |

#### § castTsPushLaidOut131 (`R11U131_CASTLOC_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_castloc/h01_nested_inc | equal | ne:col(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p131_castloc/h02_td_target | equal | ne:col(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p131_castloc/h03_signed_cast_inc | equal | ne:col(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p131_castloc/h04_tab_macro | equal | ne:col(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |

#### § constCtxCallArgInner131v (`R11V131_ARGCTX_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p131_ipsspan/i04_arg_nested_op | ne:file(4) | ne:col(5) → ne:file(4): OK:better=2 | OK:better=2 | untouched | IDENTICAL |
| p131_ipsspan/i05_nested_ternary | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, bytes moved (dump lines: 3 fixed, 2 new) | stage1 both | untouched | IDENTICAL |
| p131_qcall/c04_arg_in_op_of_call | stage1 cmp=60 | stage1 cmp=60 → stage1 cmp=60: stage1 both, bytes moved (dump lines: 2 fixed, 0 new) | stage1 both | untouched | EQUIVALENT |

#### § typedefParentLastWriter134 (`R11U134_TDPARENT_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_tdparent/a01_iface_and_module | equal | equal → equal: untouched | untouched | **turned equal** | IDENTICAL |
| p134_tdparent/a02_program_and_module | stage1 cmp=168 | stage1 cmp=168 → stage1 cmp=168: untouched | untouched | stage1 both, bytes moved (dump lines: 6 fixed, 0 new) | IDENTICAL |
| p134_tdparent/a03_struct_with_enum_member | equal | equal → equal: untouched | untouched | **turned equal** | IDENTICAL |
| p134_tdparent/a04_three_level_importers | equal | equal → equal: untouched | untouched | **turned equal** | IDENTICAL |
| p134_tdparent/a05_z_and_a_readers | equal | equal → equal: untouched | untouched | **turned equal** | IDENTICAL |

#### § contAssignLhsTsUnparented134 (`R11U134_CAUNPARENT_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_caunparent/u01_delay_assign | equal | ne:fullname(10) → equal: **turned equal** | **turned equal** | untouched | IDENTICAL |
| p134_caunparent/u02_gen_for_assign | equal | equal → equal: untouched | untouched | **turned equal** | IDENTICAL |
| p134_caunparent/u03_packed_array_td | ne:fullname(5) | ne:fullname(5) → ne:fullname(5): untouched | untouched | untouched | IDENTICAL |
| p134_caunparent/u04_iface_signal_lhs | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |

#### § anonMemberRefChainName134 (`R11U134_ANONMEMBER_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_anonmember/m01_union_in_pkg_imported | stage1 cmp=101 | stage1 cmp=101 → stage1 cmp=101: stage1 both, bytes moved (dump lines: 8 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 8 fixed, 0 new) | IDENTICAL |
| p134_anonmember/m02_member_packed_dims | ne:fullname(10) | ne:fullname(10) → ne:fullname(10): untouched | untouched | untouched | IDENTICAL |
| p134_anonmember/m03_iface_signal | stage1 cmp=137 | stage1 cmp=137 → stage1 cmp=137: stage1 both, bytes moved (dump lines: 4 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 8 fixed, 0 new) | IDENTICAL |
| p134_anonmember/m04_local_union | equal | ne:fullname(8) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p134_anonmember/m05_sub_twice | equal | ne:fullname(14) → equal: **turned equal** | OK:better=11 | **turned equal** | IDENTICAL |

#### § memberAnonUnionAtKeyword134 (`R11U134_MEMUNION_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_memunion/n01_union_in_union | equal | ne:file(4) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p134_memunion/n02_union_after_comment | ne:fullname(10) | ne:fullname(10) → ne:fullname(10): untouched | untouched | untouched | IDENTICAL |
| p134_memunion/n03_pkg_signed_union | stage1 cmp=101 | stage1 cmp=101 → stage1 cmp=101: stage1 both, bytes moved (dump lines: 8 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 21 fixed, 0 new) | IDENTICAL |

#### § defNetTypedefEndWrite134 (`R11U134_TDNETEND_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_tdnetend/e01_dyn_array | stage1 cmp=459 | stage1 cmp=459 → stage1 cmp=459: stage1 both, bytes moved (dump lines: 10 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 77 fixed, 0 new) | STATUS_DIFF |
| p134_tdnetend/e02_param_dim | equal | ne:endline(4) → equal: **turned equal** | OK:better=8 | **turned equal** | IDENTICAL |
| p134_tdnetend/e03_assoc_bare_import | stage1 cmp=52 | stage1 cmp=52 → stage1 cmp=52: stage1 both, bytes moved (dump lines: 7 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 7 fixed, 0 new) | IDENTICAL |

#### § defNetTypedefArrayShares134 (`R11U134_TDARRSHARE_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_tdarrshare/r01_enum_array | equal | equal → equal: untouched | untouched | **turned equal** | IDENTICAL |
| p134_tdarrshare/r02_nested_struct_array | ne:fullname(4) | ne:endline(10) → ne:fullname(4): OK:better=10 | OK:better=10 | OK:better=10 | IDENTICAL |
| p134_tdarrshare/r03_union_array | stage1 cmp=52 | stage1 cmp=52 → stage1 cmp=52: untouched | untouched | stage1 both, bytes moved (dump lines: 11 fixed, 0 new) | IDENTICAL |

#### § elabNetTdCloneNoAlias134 (`R11U134_ELABNETALIAS_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_elabnetalias/l01_tri1_wor | stage1 cmp=60 | stage1 cmp=60 → stage1 cmp=60: stage1 both, bytes moved (dump lines: 0 fixed, 45 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 45 new) | IDENTICAL |
| p134_elabnetalias/l02_gen_block_net | equal | equal → equal: untouched | untouched | untouched | IDENTICAL |
| p134_elabnetalias/l03_sub_twice | stage1 cmp=58 | stage1 cmp=58 → stage1 cmp=58: stage1 both, bytes moved (dump lines: 4 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 4 fixed, 0 new) | IDENTICAL |
| p134_elabnetalias/l04_sub_ports | equal | ne:type(1) → equal: **turned equal** | GROW:fullname:1->4 | **turned equal** | IDENTICAL |
| p134_elabnetalias/l05_tri_signed | stage1 cmp=62 | stage1 cmp=62 → stage1 cmp=62: stage1 both, bytes moved (dump lines: 0 fixed, 23 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 23 new) | IDENTICAL |
| p134_elabnetalias/l06_tri_unsigned | equal | ne:type(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p134_elabnetalias/l07_tri1_undriven | stage1 cmp=60 | stage1 cmp=60 → stage1 cmp=60: stage1 both, bytes moved (dump lines: 0 fixed, 22 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 22 new) | IDENTICAL |
| p134_elabnetalias/l08_wor_unsigned | equal | ne:type(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p134_elabnetalias/l09_wire_signed | stage1 cmp=62 | stage1 cmp=62 → stage1 cmp=62: stage1 both, bytes moved (dump lines: 0 fixed, 23 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 23 new) | IDENTICAL |
| p134_elabnetalias/l10_wand_unsigned | equal | ne:type(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p134_elabnetalias/l11_supply0 | stage1 cmp=60 | stage1 cmp=60 → stage1 cmp=60: stage1 both, bytes moved (dump lines: 0 fixed, 22 new) | stage1 both | stage1 both, bytes moved (dump lines: 0 fixed, 22 new) | IDENTICAL |

#### § defNetScopedPkgVecTdShares134 (`R11U134_SCOPEDPKGTD_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_scopedpkgtd/k01_unpacked_dim | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | untouched | untouched | IDENTICAL |
| p134_scopedpkgtd/k02_wire_scoped | stage1 cmp=58 | stage1 cmp=58 → stage1 cmp=58: stage1 both, bytes moved (dump lines: 47 fixed, 4 new) | stage1 both | stage1 both, bytes moved (dump lines: 4 fixed, 4 new) | EQUIVALENT |
| p134_scopedpkgtd/k03_iface_scoped | equal | ne:endline(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |

#### § pkgTdCloneBoundLoc134 (`R11U134_PKGCLONEBOUND_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_pkgclonebound/b01_mul_bound | equal | ne:file(1) → equal: **turned equal** | **turned equal** | **turned equal** | IDENTICAL |
| p134_pkgclonebound/b02_clog2_bound | stage1 cmp=86 | stage1 cmp=86 → stage1 cmp=86: untouched | untouched | untouched | IDENTICAL |
| p134_pkgclonebound/b03_two_param_bounds | stage1 cmp=36 | stage1 cmp=36 → stage1 cmp=36: stage1 both, bytes moved (dump lines: 2 fixed, 0 new) | stage1 both | stage1 both, bytes moved (dump lines: 64 fixed, 0 new) | EQUIVALENT |

#### § pkgTsRefObjChainName134 (`R11U134_TSREFCHAIN_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_tsrefchain/c01_member_range | equal | equal → equal: untouched | untouched | EQUAL-both(bytes moved) | IDENTICAL |
| p134_tsrefchain/c02_param_of_td | ne:decompile(2) | ne:fullname(4) → ne:decompile(2): OK:better=2 | OK:better=2 | OK:better=2 | IDENTICAL |
| p134_tsrefchain/c03_nested_td | stage1 cmp=100 | stage1 cmp=100 → stage1 cmp=100: untouched | untouched | untouched | IDENTICAL |
| p134_tsrefchain/c04_struct_member_param_range_import | equal | equal → equal: untouched | untouched | **turned equal** | IDENTICAL |

#### § tsHierPathElemNoName134 (`R11U134_TSHPNAME_OFF`)

| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |
|---|---|---|---|---|---|
| p134_tshpname/h01_member_bound | stage1 cmp=313 | stage1 cmp=313 → stage1 cmp=313: untouched | untouched | untouched | IDENTICAL |
| p134_tshpname/h02_nested_member_bound | stage1 cmp=11 | stage1 cmp=11 → stage1 cmp=11: untouched | untouched | stage1 both, bytes moved (dump lines: 0 fixed, 0 new) | IDENTICAL |
| p134_tshpname/h03_func_return | stage1 cmp=84 | stage1 cmp=84 → stage1 cmp=84: untouched | untouched | untouched | EQUIVALENT |
| p134_tshpname/h04_port_range | ne:col(3) | ne:col(3) → ne:col(3): untouched | untouched | untouched | IDENTICAL |
| p134_tshpname/h05_local_typedef | ne:col(7) | ne:col(7) → ne:col(7): untouched | untouched | untouched | IDENTICAL |
| p134_tshpname/h06_iface_signal | ne:col(3) | ne:col(3) → ne:col(3): untouched | untouched | untouched | IDENTICAL |
