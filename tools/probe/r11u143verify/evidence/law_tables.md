
#### unknownParamOperandFile133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_unkfile/uk01_mod | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: stage1 both, dump distance 8→8 | stage1 cmp=32 | stage1 both, dump distance 14→14 | stage1 both, dump distance 8→8 | IDENTICAL |
| p133_unkfile/uk02_and_z | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: stage1 both, dump distance 8→8 | stage1 cmp=32 | stage1 both, dump distance 14→14 | stage1 both, dump distance 8→8 | IDENTICAL |
| p133_unkfile/uk03_sub_override | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: untouched | stage1 cmp=32 | untouched | untouched | EQUIVALENT |
| p133_unkfile/uk04_shift | equal | ne:file(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk05_unary | equal | ne:file(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk06_typed_vec_xor | equal | ne:file(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk07_two_unknown_add | equal | ne:file(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_unkfile/uk08_macro_operand | stage1 cmp=32 | stage1 cmp=32 → stage1 cmp=32: stage1 both, dump distance 8→8 | stage1 cmp=32 | stage1 both, dump distance 14→14 | stage1 both, dump distance 8→8 | IDENTICAL |

#### aliasCloneTakesTargetFile137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_aliasfile/al01_enum_unpacked | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: untouched | stage1 cmp=56 | untouched | stage1 both, dump distance 84→81 | IDENTICAL |
| p137_aliasfile/al02_union_module | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | untouched | IDENTICAL |
| p137_aliasfile/al03_chain | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: stage1 both, dump distance 131→131 | stage1 cmp=56 | stage1 both, dump distance 131→131 | stage1 both, dump distance 131→131 | IDENTICAL |
| p137_aliasfile/al04_two_dims | stage1 cmp=162 | stage1 cmp=162 → stage1 cmp=162: untouched | stage1 cmp=162 | untouched | stage1 both, dump distance 87→89 | EQUIVALENT |
| p137_aliasfile/al05_two_modules | equal | ne:file(5) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_aliasfile/al06_union_pkg | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | stage1 both, dump distance 99→96 | IDENTICAL |
| p137_aliasfile/al07_alias_in_include | equal | ne:file(3) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### constCallNameSpan137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_callspan/cs01_unpacked_dim | stage1 cmp=36 | stage1 cmp=36 → stage1 cmp=36: untouched | stage1 cmp=36 | untouched | untouched | IDENTICAL |
| p137_callspan/cs02_param_port_range | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: stage1 both, dump distance 50→38 | stage1 cmp=17 | stage1 both, dump distance 44→32 | stage1 both, dump distance 50→38 | IDENTICAL |
| p137_callspan/cs03_genif_op_of_calls | stage1 cmp=99 | stage1 cmp=99 → stage1 cmp=99: stage1 both, dump distance 12→4 | stage1 cmp=99 | stage1 both, dump distance 12→4 | stage1 both, dump distance 12→4 | IDENTICAL |
| p137_callspan/cs04_genblock_lp_range | ne:endcol(1) | ne:endcol(1) → ne:endcol(1): untouched | ne:endcol(1) | untouched | untouched | IDENTICAL |
| p137_callspan/cs05_two_args | stage1 cmp=193 | stage1 cmp=193 → stage1 cmp=193: stage1 both, dump distance 8→2 | stage1 cmp=193 | stage1 both, dump distance 8→2 | stage1 both, dump distance 8→2 | IDENTICAL |
| p137_callspan/cs06_genif_in_gencase | ne:fullname(12) | ne:fullname(13) → ne:fullname(12): OK:better=1 | ne:fullname(12) | OK:better=1 | OK:better=1 | IDENTICAL |
| p137_callspan/cs07_sysfunc_arg | stage1 cmp=99 | stage1 cmp=99 → stage1 cmp=99: stage1 both, dump distance 6→2 | stage1 cmp=99 | stage1 both, dump distance 6→2 | stage1 both, dump distance 6→2 | IDENTICAL |
| p137_callspan/cs08_named_arg | stage1 cmp=45 | stage1 cmp=45 → stage1 cmp=45: stage1 both, dump distance 45→43 | stage1 cmp=45 | stage1 both, dump distance 71→69 | stage1 both, dump distance 45→43 | EQUIVALENT |

#### unsignedScalarVecTsAtKeyword137 / R11V137_DEFWIRE

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_defwire/dw01_tri_genblock | stage1 cmp=31 | stage1 cmp=31 → stage1 cmp=31: untouched | equal | untouched | stage1 both, dump distance 25→17 | IDENTICAL |
| p137_defwire/dw02_wor_uwire | stage1 cmp=60 | stage1 cmp=60 → stage1 cmp=60: stage1 both, dump distance 12→4 | stage1 cmp=60 | stage1 both, dump distance 12→4 | stage1 both, dump distance 12→4 | IDENTICAL |
| p137_defwire/dw03_wire_unpacked | equal | equal → equal: untouched | equal | untouched | **turned equal** | IDENTICAL |
| p137_defwire/dw04_param_sub | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_defwire/dw05_attr_wand | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### packedArrTdElemRefName137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_patd/pd01_union_elem | stage1 cmp=78 | stage1 cmp=78 → stage1 cmp=78: untouched | stage1 cmp=78 | untouched | untouched | DIVERGENT |
| p137_patd/pd02_port_type | stage1 cmp=194 | stage1 cmp=194 → stage1 cmp=194: untouched | stage1 cmp=194 | untouched | untouched | DIVERGENT |
| p137_patd/pd03_vec_elem | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | untouched | DIVERGENT |
| p137_patd/pd04_genblock_td | stage1 cmp=238 | stage1 cmp=238 → stage1 cmp=238: untouched | stage1 cmp=238 | untouched | untouched | DIVERGENT |
| p137_patd/pd05_struct_always | equal | ne:fullname(5) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_patd/pd06_pkg_enum_localparam | stage1 cmp=198 | stage1 cmp=198 → stage1 cmp=198: untouched | stage1 cmp=198 | untouched | untouched | IDENTICAL |
| p137_patd/pd07_import_struct | equal | ne:fullname(12) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_patd/pd08_func_return | stage1 cmp=116 | stage1 cmp=116 → stage1 cmp=116: stage1 both, dump distance 49→45 | stage1 cmp=116 | stage1 both, dump distance 57→53 | stage1 both, dump distance 49→45 | IDENTICAL |

#### pureVirtProtoSpan137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_purevirt/pv01_module_class_defaults | equal | ne:endline(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_purevirt/pv02_iface_class_task | stage1 cmp=103 | stage1 cmp=103 → stage1 cmp=103: stage1 both, dump distance 47→47 | stage1 cmp=103 | stage1 both, dump distance 47→47 | stage1 both, dump distance 47→47 | IDENTICAL |
| p137_purevirt/pv03_local_task | stage1 cmp=162 | stage1 cmp=162 → stage1 cmp=162: stage1 both, dump distance 47→43 | stage1 cmp=162 | stage1 both, dump distance 50→44 | stage1 both, dump distance 47→43 | IDENTICAL |
| p137_purevirt/pv04_extends_override | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_purevirt/pv05_module_protected_func | equal | ne:endcol(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_purevirt/pv06_param_class | stage1 cmp=18 | stage1 cmp=18 → stage1 cmp=18: stage1 both, dump distance 7→3 | stage1 cmp=18 | stage1 both, dump distance 9→3 | stage1 both, dump distance 7→3 | IDENTICAL |

#### defNetScopedPkgArrTdShares137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_scopedarrtd/sd01_enum_elem | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: stage1 both, dump distance 92→89 | stage1 cmp=56 | stage1 both, dump distance 93→90 | stage1 both, dump distance 92→89 | IDENTICAL |
| p137_scopedarrtd/sd02_port_type | stage1 cmp=105 | stage1 cmp=105 → stage1 cmp=105: stage1 both, dump distance 207→204 | stage1 cmp=105 | stage1 both, dump distance 209→206 | stage1 both, dump distance 207→204 | STATUS_DIFF |
| p137_scopedarrtd/sd03_ascending_init | stage1 cmp=11 | stage1 cmp=11 → stage1 cmp=11: stage1 both, dump distance 55→55 | stage1 cmp=11 | stage1 both, dump distance 57→57 | stage1 both, dump distance 55→55 | EQUIVALENT |
| p137_scopedarrtd/sd04_struct_two_lines | equal | ne:type(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_scopedarrtd/sd05_bit_elem | stage1 cmp=105 | stage1 cmp=105 → stage1 cmp=105: stage1 both, dump distance 160→157 | stage1 cmp=105 | stage1 both, dump distance 161→158 | stage1 both, dump distance 160→157 | EQUIVALENT |
| p137_scopedarrtd/sd06_odd_bounds | equal | ne:type(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### caLhsDefNetUnlessOpRhs139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_ca/ca01_nonansi_op | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca02_repl_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca03_delay_op | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca04_inst_array_child | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca05_partsel_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca06_member_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca07_ips_rhs_sub_two | equal | equal → equal: untouched | equal | untouched | **turned equal** | IDENTICAL |
| p139_ca/ca08_var_index_rhs | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca09_bits_sysfunc | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca10_pkg_param_partsel | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_ca/ca11_struct_param_member_override | stage1 cmp=84 | stage1 cmp=84 → stage1 cmp=84: stage1 both, dump distance 181→179 | stage1 cmp=84 | stage1 both, dump distance 181→179 | stage1 both, dump distance 181→179 | EQUIVALENT |
| p139_ca/ca12_param_bitsel_logic_lhs | stage1 cmp=48 | stage1 cmp=48 → stage1 cmp=48: untouched | stage1 cmp=52 | untouched | untouched | IDENTICAL |
| p139_ca/ca13_top_pkg_partsel | stage1 cmp=58 | stage1 cmp=58 → stage1 cmp=58: untouched | stage1 cmp=58 | untouched | untouched | IDENTICAL |
| p139_ca/ca14_nested_member_localparam | stage1 cmp=489 | stage1 cmp=489 → stage1 cmp=489: stage1 both, dump distance 207→207 | stage1 cmp=489 | stage1 both, dump distance 207→207 | stage1 both, dump distance 207→207 | IDENTICAL |
| p139_ca/ca15_countones_param | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: stage1 both, dump distance 32→32 | stage1 cmp=17 | stage1 both, dump distance 42→42 | stage1 both, dump distance 32→32 | DIVERGENT |
| p139_ca/ca16_clog2_sub_override | equal | ne:count(0) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_ca/ca17_imported_param_bitsel | equal | ne:count(0) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_ca/ca18_genblock_param_bitsel | stage1 cmp=40 | stage1 cmp=40 → stage1 cmp=40: untouched | stage1 cmp=40 | untouched | untouched | STATUS_DIFF |

#### clockingEventDefNet139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_clk/ck01_edge | stage1 cmp=29 | stage1 cmp=29 → stage1 cmp=29: untouched | stage1 cmp=29 | untouched | untouched | IDENTICAL |
| p139_clk/ck02_bitsel_clock | stage1 cmp=351 | stage1 cmp=351 → stage1 cmp=351: untouched | stage1 cmp=351 | untouched | untouched | IDENTICAL |
| p139_clk/ck03_genblock_sub | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_clk/ck04_skews | stage1 cmp=273 | stage1 cmp=273 → stage1 cmp=273: untouched | stage1 cmp=273 | untouched | untouched | IDENTICAL |
| p139_clk/ck05_two_blocks | stage1 cmp=429 | stage1 cmp=429 → stage1 cmp=429: stage1 both, dump distance 58→58 | stage1 cmp=429 | stage1 both, dump distance 60→60 | stage1 both, dump distance 58→58 | IDENTICAL |
| p139_clk/ck06_global_sub | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### ndaLeftmostLeafElab139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_nda/nd01_concat_leftmost | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd02_call_leftmost | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd03_cast_leftmost | ne:depth(1) | ne:depth(1) → ne:depth(1): untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd04_member_leftmost | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd05_compare | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_nda/nd06_nested_left_chain | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_nda/nd07_logical_unary_left | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p139_nda/nd08_sub_two_inst | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_nda/nd09_genblock | stage1 cmp=31 | stage1 cmp=31 → stage1 cmp=31: untouched | equal | untouched | untouched | IDENTICAL |

#### hpBaseSelMidMemberBare133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_hpmid/hm01_partsel_leaf | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p133_hpmid/hm02_2d_base | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_hpmid/hm03_ff_if_cond | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_hpmid/hm04_port_actual | ne:fullname(2) | ne:fullname(3) → ne:fullname(2): OK:better=1 | ne:fullname(1) | OK:better=2 | OK:better=1 | IDENTICAL |
| p133_hpmid/hm05_ips_leaf | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p133_hpmid/hm06_base_index_op | ne:fullname(2) | ne:fullname(4) → ne:fullname(2): OK:better=2 | ne:fullname(2) | OK:better=2 | OK:better=2 | IDENTICAL |
| p133_hpmid/hm07_nb_lvalue_member_idx | ne:fullname(2) | ne:fullname(4) → ne:fullname(2): OK:better=2 | ne:fullname(2) | OK:better=2 | OK:better=2 | IDENTICAL |

#### hpTrailSelIdxNamesByPath133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_trailidx/tx01_idx_ternary | equal | ne:fullname(6) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_trailidx/tx02_idx_funccall | ne:fullname(4) | ne:fullname(4) → ne:fullname(4): untouched | ne:fullname(4) | untouched | untouched | IDENTICAL |
| p133_trailidx/tx03_idx_int_var | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_trailidx/tx04_idx_sysfunc | ne:fullname(2) | ne:fullname(2) → ne:fullname(2): untouched | ne:fullname(2) | untouched | untouched | IDENTICAL |
| p133_trailidx/tx05_idx_sub_op | equal | ne:fullname(4) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_trailidx/tx06_trailing_ips_var | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### defNetTypeParamDefault137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_defnettp/tp01_pkg_typedef_default | equal | ne:type(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL; DIVERGENT; DIVERGENT |
| p137_defnettp/tp02_signed_vec_default | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p137_defnettp/tp03_unit_enum_default | ne:file(1) | ne:name(3) → ne:file(1): OK:better=7 | ne:file(1) | OK:better=7 | OK:better=7 | IDENTICAL; DIVERGENT; DIVERGENT |
| p137_defnettp/tp04_dependent_default | ne:fullname(5) | ne:fullname(3) → ne:fullname(5): GROW:fullname:1->5 | ne:fullname(4) | GROW:fullname:1->4 | GROW:fullname:1->5 | IDENTICAL; EQUIVALENT; EQUIVALENT |
| p137_defnettp/tp05_packed_dim_on_tp | stage1 cmp=36 | stage1 cmp=36 → stage1 cmp=36: untouched | stage1 cmp=36 | untouched | untouched | IDENTICAL |

#### emptyNamedConnLowConnAtDecl137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_emptyconn/en01_inout | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_emptyconn/en02_struct_port | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_emptyconn/en03_multiline_attr_decl | stage1 cmp=27 | stage1 cmp=27 → stage1 cmp=27: stage1 both, dump distance 11→9 | stage1 cmp=27 | stage1 both, dump distance 11→9 | stage1 both, dump distance 11→9 | IDENTICAL |
| p137_emptyconn/en04_with_wildcard | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_emptyconn/en05_unpacked_port | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### taggedUnionElabSpan137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_tagged/tu01_struct_member | equal | ne:endcol(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_tagged/tu02_genblock | stage1 cmp=174 | stage1 cmp=174 → stage1 cmp=174: untouched | stage1 cmp=174 | untouched | untouched | DIVERGENT |
| p137_tagged/tu03_signed | equal | ne:endcol(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_tagged/tu04_port_type | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### connLeftmostLeafElab139

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p139_port/pc01_inst_array_op | stage1 cmp=240 | stage1 cmp=240 → stage1 cmp=240: untouched | stage1 cmp=240 | untouched | untouched | EQUIVALENT |
| p139_port/pc02_paren_nested | equal | ne:fullname(3) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p139_port/pc03_param_sub_concat | equal | ne:depth(1) → equal: **turned equal** | equal | EQUAL-both(bytes moved) | **turned equal** | IDENTICAL |
| p139_port/pc04_bitsel_right | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p139_port/pc05_genblock_op | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### includeInactiveTabNotText141v

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p141_inctabact/it01_ifndef_defined | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it02_inner_skip_outer_tab_after | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p141_inctabact/it03_elsif_after_taken | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it04_skip_tab_undef_after | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it05_skipped_continuation | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p141_inctabact/it06_active_continuation | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |
| p141_inctabact/it07_skipped_inner_else | equal | ne:line(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_inctabact/it08_elsif_taken_tab | equal | equal → equal: untouched | equal | untouched | untouched | IDENTICAL |

#### ipsQualBaseRangeSpan141v

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p141_ipsqual/iq01_sub_two_inst | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_ipsqual/iq02_op_start | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_ipsqual/iq03_genblock_lp | stage1 cmp=56 | stage1 cmp=56 → stage1 cmp=56: untouched | stage1 cmp=56 | untouched | untouched | IDENTICAL |
| p141_ipsqual/iq04_contassign_ctl | stage1 cmp=62 | stage1 cmp=62 → stage1 cmp=62: untouched | stage1 cmp=62 | untouched | untouched | IDENTICAL |
| p141_ipsqual/iq05_in_concat | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p141_ipsqual/iq06_minus_localparam | stage1 cmp=64 | stage1 cmp=64 → stage1 cmp=64: stage1 both, dump distance 10→8 | stage1 cmp=64 | stage1 both, dump distance 10→8 | stage1 both, dump distance 10→8 | DIVERGENT |

#### impPaLhsDisjointClone133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_lhsclone/lc01_gen_for_inst | ne:line(4) | ne:depth(1) → ne:line(4): GROW:endline:0->4,col:1->4,line:0->4,endcol:1->4 | ne:line(4) | GROW:endline:0->4,col:1->4,line:0->4,endcol:1->4 | GROW:endline:0->4,col:1->4,line:0->4,endcol:1->4 | IDENTICAL |
| p133_lhsclone/lc02_pkg_explicit_pkg | stage1 cmp=50 | stage1 cmp=50 → stage1 cmp=50: stage1 both, dump distance 74→52 | stage1 cmp=50 | stage1 both, dump distance 74→52 | stage1 both, dump distance 74→52 | IDENTICAL |
| p133_lhsclone/lc03_two_pkgs_hdr | stage1 cmp=87 | stage1 cmp=87 → stage1 cmp=87: stage1 both, dump distance 42→21 | stage1 cmp=87 | stage1 both, dump distance 42→21 | stage1 both, dump distance 42→21 | IDENTICAL |
| p133_lhsclone/lc04_macro_pkg_param | ne:line(2) | ne:depth(1) → ne:line(2): GROW:col:1->2,endcol:1->2 | ne:line(2) | GROW:col:1->2,endcol:1->2 | GROW:col:1->2,endcol:1->2 | IDENTICAL |

#### elabPatQualRefQualSpan133

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p133_patqual/pq01_positional_pattern | stage1 cmp=52 | stage1 cmp=52 → stage1 cmp=52: stage1 both, dump distance 81→73 | stage1 cmp=60 | stage1 both, dump distance 84→76 | stage1 both, dump distance 81→73 | IDENTICAL |
| p133_patqual/pq02_nested_struct | stage1 cmp=112 | stage1 cmp=112 → stage1 cmp=112: stage1 both, dump distance 288→280 | stage1 cmp=112 | stage1 both, dump distance 288→280 | stage1 both, dump distance 290→280 | IDENTICAL |
| p133_patqual/pq03_two_params | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p133_patqual/pq04_genif_inst | ne:fullname(1) | ne:endcol(2) → ne:fullname(1): OK:better=1 | ne:fullname(1) | OK:better=1 | OK:better=1 | IDENTICAL |

#### elabCloneFullNameUnstored137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_elabclone/ee01_iface_process | stage1 cmp=17 | stage1 cmp=17 → stage1 cmp=17: untouched | stage1 cmp=17 | untouched | untouched | IDENTICAL |
| p137_elabclone/ee02_func_struct_local | equal | equal → equal: untouched | equal | **turned equal** | untouched | IDENTICAL |
| p137_elabclone/ee03_latch_case_block | equal | equal → equal: untouched | equal | **turned equal** | untouched | IDENTICAL |
| p137_elabclone/ee04_task_output_arg | equal | equal → equal: untouched | equal | **turned equal** | untouched | IDENTICAL |

#### structParamPathBaseAtMember137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_pathbase/sp01_unpacked_dim | stage1 cmp=50 | stage1 cmp=50 → stage1 cmp=50: untouched | stage1 cmp=50 | untouched | untouched | IDENTICAL |
| p137_pathbase/sp02_typedef_range | equal | ne:col(6) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_pathbase/sp03_genif_and | equal | ne:col(4) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_pathbase/sp04_genblock_net_range | equal | ne:col(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### connReplTsRefThroughPort137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_repl/rp01_net_operand_ctl | equal | equal → equal: untouched | equal | untouched | **turned equal** | IDENTICAL |
| p137_repl/rp02_struct_port | equal | ne:fullname(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_repl/rp03_genfor | equal | ne:fullname(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_repl/rp04_nonansi_child | equal | ne:fullname(1) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |

#### unsignedScalarVecTsAtKeyword137

| case | at base (default) | own switch off → on (default) | `--elabuhdm` at base | off → on (`--elabuhdm`) | three landings off → on (default) | downstream (on; own off; A3) |
|---|---|---|---|---|---|---|
| p137_unsigned/us01_unpacked_mem | equal | ne:endcol(2) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_unsigned/us02_typedef | equal | ne:endcol(12) → equal: **turned equal** | equal | **turned equal** | **turned equal** | IDENTICAL |
| p137_unsigned/us03_genblock_iface | ne:endcol(1) | ne:endcol(5) → ne:endcol(1): OK:better=4 | ne:endcol(1) | OK:better=4 | OK:better=4 | IDENTICAL |
