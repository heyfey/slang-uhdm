# r10ladder1 — CLUSTER REPORT

Instrument: `ctladder` (MEASUREMENT-ONLY; the official `uhdm-cmp` remains the sole acceptance judge).  Every rung below is a real `design::Compare` head under official semantics — the walk, the field order and the failure points are UHDM's own.

## Per-row ladder length (the first honest 'how far are we')

| row | rungs | stop | deepest walk (golden objs proven equal) | masks | secs |
|---|---:|---|---|---:|---:|
| default_BuildUVMPkg | 89 | FIXPOINT | 18936/183142 | 89 | 3.2 |
| default_Earlgrey_0_1 | 3215 | BUDGET | 471011/783183 | 3215 | 1500.4 |
| default_Rggen | 98 | FIXPOINT | 94688/252296 | 98 | 6.8 |
| default_Scoreboard | 76 | ROOT-BLOCKED | 22670/187081 | 75 | 3.3 |
| default_SeqDriver | 59 | FIXPOINT | 16090/317210 | 63 | 3.7 |
| default_SimpleUVM | 47 | ROOT-BLOCKED | 15402/188084 | 51 | 2.5 |
| default_YosysVerx | 1 | FIXPOINT | 24205/24205 | 1 | 0.2 |
| testflags_BuildUVMPkg | 89 | FIXPOINT | 18936/183142 | 89 | 3.3 |
| testflags_SeqDriver | 59 | FIXPOINT | 16102/317222 | 63 | 3.5 |
| testflags_SimpleUVM | 47 | ROOT-BLOCKED | 15414/188096 | 51 | 2.6 |
| testflags_YosysVerx | 1 | FIXPOINT | 24205/24205 | 1 | 0.2 |

Rows whose ladder is TRUNCATED (stop != FIXPOINT), so their length is a strict LOWER bound: **default_Earlgrey_0_1, default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM**

Every ladder length is a lower bound in a second way as well: masking an object skips its WHOLE SUBTREE, so any defect inside a masked subtree is invisible to later rungs (see `masked=` per rung).

## Per-row family profile (top 5 by entries)

| row | rungs | top families |
|---|---:|---|
| default_BuildUVMPkg | 89 | `function\|<rhs-null>\|MISSING-OURS` x25<br>`io_decl\|<rhs-null>\|MISSING-OURS` x9<br>`ref_typespec\|<rhs-null>\|MISSING-OURS` x4<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x4<br>`+string_var\|<lhs-null>\|EXTRA-OURS` x4 |
| default_Earlgrey_0_1 | 3215 | `ref_typespec\|<rhs-null>\|MISSING-OURS` x1441<br>`constant\|VpiType\|KIND:constant>ref_obj` x1263<br>`int_typespec\|VpiType\|KIND:int_typespec>integer_typespec` x236<br>`ref_obj\|VpiType\|KIND:ref_obj>constant` x68<br>`constant\|VpiDecompile\|O-EXTRA-PREFIX(')` x40 |
| default_Rggen | 98 | `constant\|VpiType\|KIND:constant>ref_obj` x26<br>`hier_path\|VpiName\|TEXT:register_if[#].value[#+:#]\|register_if[#+#*i+#].value[# + # * l+:#]` x24<br>`constant\|VpiDecompile\|TEXT:#\|#+#*i+#*j+k` x11<br>`constant\|VpiDecompile\|DIGITS-ONLY` x8<br>`constant\|VpiDecompile\|TEXT:#\|-#` x6 |
| default_Scoreboard | 76 | `parameter\|VpiType\|KIND:parameter>constant` x10<br>`+string_var\|<lhs-null>\|EXTRA-OURS` x8<br>`function\|<rhs-null>\|MISSING-OURS` x7<br>`constant\|VpiType\|KIND:constant>hier_path` x4<br>`ref_obj\|VpiType\|KIND:ref_obj>hier_path` x4 |
| default_SeqDriver | 59 | `function\|<rhs-null>\|MISSING-OURS` x6<br>`+class_var\|<lhs-null>\|EXTRA-OURS` x6<br>`+ref_typespec\|<lhs-null>\|EXTRA-OURS` x6<br>`+string_var\|<lhs-null>\|EXTRA-OURS` x4<br>`ref_obj\|VpiType\|KIND:ref_obj>hier_path` x4 |
| default_SimpleUVM | 47 | `+string_var\|<lhs-null>\|EXTRA-OURS` x7<br>`function\|<rhs-null>\|MISSING-OURS` x7<br>`+class_var\|<lhs-null>\|EXTRA-OURS` x3<br>`method_func_call\|VpiName\|TEXT:this\|sequences` x2<br>`constant\|VpiType\|KIND:constant>operation` x2 |
| default_YosysVerx | 1 | `+module_inst\|<lhs-null>\|EXTRA-OURS` x1 |
| testflags_BuildUVMPkg | 89 | `function\|<rhs-null>\|MISSING-OURS` x25<br>`io_decl\|<rhs-null>\|MISSING-OURS` x9<br>`ref_typespec\|<rhs-null>\|MISSING-OURS` x4<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x4<br>`+string_var\|<lhs-null>\|EXTRA-OURS` x4 |
| testflags_SeqDriver | 59 | `function\|<rhs-null>\|MISSING-OURS` x6<br>`+class_var\|<lhs-null>\|EXTRA-OURS` x6<br>`+ref_typespec\|<lhs-null>\|EXTRA-OURS` x6<br>`+string_var\|<lhs-null>\|EXTRA-OURS` x4<br>`ref_obj\|VpiType\|KIND:ref_obj>hier_path` x4 |
| testflags_SimpleUVM | 47 | `+string_var\|<lhs-null>\|EXTRA-OURS` x7<br>`function\|<rhs-null>\|MISSING-OURS` x7<br>`+class_var\|<lhs-null>\|EXTRA-OURS` x3<br>`method_func_call\|VpiName\|TEXT:this\|sequences` x2<br>`constant\|VpiType\|KIND:constant>operation` x2 |
| testflags_YosysVerx | 1 | `+module_inst\|<lhs-null>\|EXTRA-OURS` x1 |

## FAMILIES (kind | field | value shape)

| rank | rows | entries | family |
|---:|---:|---:|---|
| 1 | 9 | 27 | `constant\|VpiType\|KIND:constant>operation` |
| 2 | 8 | 1460 | `ref_typespec\|<rhs-null>\|MISSING-OURS` |
| 3 | 8 | 23 | `+ref_typespec\|<lhs-null>\|EXTRA-OURS` |
| 4 | 8 | 9 | `constant\|VpiConstType\|INT:G<O` |
| 5 | 7 | 83 | `function\|<rhs-null>\|MISSING-OURS` |
| 6 | 7 | 38 | `+string_var\|<lhs-null>\|EXTRA-OURS` |
| 7 | 7 | 26 | `io_decl\|<rhs-null>\|MISSING-OURS` |
| 8 | 7 | 25 | `+class_var\|<lhs-null>\|EXTRA-OURS` |
| 9 | 7 | 13 | `+enum_const\|<lhs-null>\|EXTRA-OURS` |
| 10 | 7 | 7 | `+io_decl\|<lhs-null>\|EXTRA-OURS` |
| 11 | 7 | 7 | `class_typespec\|VpiName\|TEXT:rsp_type\|uvm_sequence_item` |
| 12 | 7 | 7 | `hier_path\|VpiName\|TEXT:m_streams[].exists\|m_streams[ro.get_name()].exists` |
| 13 | 7 | 7 | `ref_var\|VpiType\|KIND:ref_var>logic_var` |
| 14 | 6 | 78 | `ref_obj\|VpiType\|KIND:ref_obj>constant` |
| 15 | 5 | 14 | `ref_obj\|VpiType\|KIND:ref_obj>hier_path` |
| 16 | 5 | 10 | `method_func_call\|VpiName\|TEXT:this\|sequences` |
| 17 | 5 | 9 | `function\|VpiName\|G-EXTRA-PREFIX(uvm_root::)` |
| 18 | 5 | 8 | `constant\|VpiType\|KIND:constant>hier_path` |
| 19 | 5 | 5 | `enum_typespec\|VpiName\|G-EXTRA-SUFFIX(_enum)` |
| 20 | 5 | 5 | `logic_var\|<rhs-null>\|MISSING-OURS` |
| 21 | 5 | 5 | `package\|<rhs-null>\|MISSING-OURS` |
| 22 | 5 | 5 | `parameter\|VpiImported\|O-EMPTY` |
| 23 | 5 | 5 | `ref_obj\|VpiName\|G-EXTRA-SUFFIX(_name)` |
| 24 | 5 | 5 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX(_name)` |
| 25 | 5 | 5 | `string_var\|<rhs-null>\|MISSING-OURS` |
| 26 | 3 | 14 | `parameter\|VpiType\|KIND:parameter>constant` |
| 27 | 3 | 6 | `operation\|VpiType\|KIND:operation>constant` |
| 28 | 3 | 6 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([original_type])` |
| 29 | 3 | 4 | `+int_var\|<lhs-null>\|EXTRA-OURS` |
| 30 | 3 | 4 | `module_inst\|Variables\|VEC:G>O` |
| 31 | 3 | 3 | `+package\|~Typespecs\|VEC:G>O` |
| 32 | 3 | 3 | `chandle_var\|<rhs-null>\|MISSING-OURS` |
| 33 | 3 | 3 | `constant\|<rhs-null>\|MISSING-OURS` |
| 34 | 3 | 3 | `design\|Typespecs\|VEC:G>O` |
| 35 | 3 | 3 | `package\|~Typespecs\|VEC:G>O` |
| 36 | 3 | 3 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([obj])` |
| 37 | 3 | 3 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([original_type_name])` |
| 38 | 3 | 3 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([rtype])` |
| 39 | 2 | 1289 | `constant\|VpiType\|KIND:constant>ref_obj` |
| 40 | 2 | 16 | `constant\|VpiDecompile\|DIGITS-ONLY` |
| 41 | 2 | 8 | `constant\|VpiSize\|INT:G>O` |
| 42 | 2 | 6 | `+package\|<lhs-null>\|EXTRA-OURS` |
| 43 | 2 | 6 | `method_func_call\|VpiType\|KIND:method_func_call>hier_path` |
| 44 | 2 | 4 | `+enum_var\|<lhs-null>\|EXTRA-OURS` |
| 45 | 2 | 4 | `begin\|<rhs-null>\|MISSING-OURS` |
| 46 | 2 | 4 | `hier_path\|Path_elems\|VEC:G>O` |
| 47 | 2 | 4 | `logic_typespec\|VpiName\|O-EXTRA-PREFIX(uvm_pkg::)` |
| 48 | 2 | 2 | `+interface_inst\|<lhs-null>\|EXTRA-OURS` |
| 49 | 2 | 2 | `+module_inst\|<lhs-null>\|EXTRA-OURS` |
| 50 | 2 | 2 | `+ref_var\|<lhs-null>\|EXTRA-OURS` |
| 51 | 2 | 2 | `array_var\|VpiType\|KIND:array_var>class_var` |
| 52 | 2 | 2 | `bit_typespec\|VpiType\|KIND:bit_typespec>int_typespec` |
| 53 | 2 | 2 | `bit_var\|<rhs-null>\|MISSING-OURS` |
| 54 | 2 | 2 | `class_typespec\|VpiName\|TEXT:uvm_component\|STRUCTURE` |
| 55 | 2 | 2 | `class_typespec\|VpiName\|TEXT:uvm_object\|T` |
| 56 | 2 | 2 | `enum_typespec\|VpiType\|KIND:enum_typespec>bit_typespec` |
| 57 | 2 | 2 | `enum_var\|VpiType\|KIND:enum_var>class_var` |
| 58 | 2 | 2 | `function\|VpiMethod\|INT:G>O` |
| 59 | 2 | 2 | `hier_path\|VpiType\|KIND:hier_path>bit_select` |
| 60 | 2 | 2 | `logic_net\|VpiType\|KIND:logic_net>int_var` |
| 61 | 2 | 2 | `module_inst\|~Typespecs\|VEC:G>O` |
| 62 | 2 | 2 | `package\|VpiName\|TEXT:uvm_pkg\|adpcm_pkg` |
| 63 | 1 | 236 | `int_typespec\|VpiType\|KIND:int_typespec>integer_typespec` |
| 64 | 1 | 40 | `constant\|VpiDecompile\|O-EXTRA-PREFIX(')` |
| 65 | 1 | 32 | `hier_path\|VpiName\|TEXT:reg#hw.ctrl_en_input_filter.q[#]\|reg#hw.ctrl_en_input_filter.q[i]` |
| 66 | 1 | 30 | `logic_net\|<rhs-null>\|MISSING-OURS` |
| 67 | 1 | 28 | `enum_const\|<rhs-null>\|MISSING-OURS` |
| 68 | 1 | 24 | `hier_path\|VpiName\|TEXT:register_if[#].value[#+:#]\|register_if[#+#*i+#].value[# + # * l+:#]` |
| 69 | 1 | 11 | `constant\|VpiDecompile\|TEXT:#\|#+#*i+#*j+k` |
| 70 | 1 | 7 | `logic_typespec\|VpiName\|O-EXTRA-PREFIX(hmac_pkg::)` |
| 71 | 1 | 6 | `constant\|VpiDecompile\|TEXT:#\|-#` |
| 72 | 1 | 4 | `+logic_var\|<lhs-null>\|EXTRA-OURS` |
| 73 | 1 | 3 | `+logic_net\|<lhs-null>\|EXTRA-OURS` |
| 74 | 1 | 3 | `constant\|VpiDecompile\|TEXT:#\|#'b#` |
| 75 | 1 | 3 | `constant\|VpiDecompile\|TEXT:#\|'#` |
| 76 | 1 | 3 | `constant\|VpiSize\|INT:G<O` |
| 77 | 1 | 3 | `hier_path\|VpiName\|TEXT:reg#hw.addr.q[#+:#]\|reg#hw.addr.q[DataBitWidth+:#]` |
| 78 | 1 | 3 | `int_typespec\|VpiSigned\|INT:G>O` |
| 79 | 1 | 3 | `param_assign\|VpiOverriden\|INT:G>O` |
| 80 | 1 | 2 | `constant\|VpiConstType\|INT:G>O` |
| 81 | 1 | 2 | `constant\|VpiDecompile\|G-EXTRA-PREFIX(#'b#)` |
| 82 | 1 | 2 | `constant\|VpiDecompile\|O-EXTRA-SUFFIX(+i)` |
| 83 | 1 | 2 | `constant\|VpiDecompile\|TEXT:#\|#+#*i+#` |
| 84 | 1 | 2 | `constant\|VpiDecompile\|TEXT:#\|#+i` |
| 85 | 1 | 2 | `constant\|VpiType\|KIND:constant>func_call` |
| 86 | 1 | 2 | `hier_path\|VpiSize\|INT:G<O` |
| 87 | 1 | 2 | `param_assign\|VpiOverriden\|INT:G<O` |
| 88 | 1 | 1 | `bit_select\|VpiType\|KIND:bit_select>bit_var` |
| 89 | 1 | 1 | `class_typespec\|<rhs-null>\|MISSING-OURS` |
| 90 | 1 | 1 | `constant\|VpiDecompile\|O-EXTRA-PREFIX(-)` |
| 91 | 1 | 1 | `constant\|VpiDecompile\|O-EXTRA-SUFFIX(+#*i+#*j+k)` |
| 92 | 1 | 1 | `constant\|VpiDecompile\|TEXT:#'hab\|#` |
| 93 | 1 | 1 | `constant\|VpiDecompile\|TEXT:-#\|#'b#` |
| 94 | 1 | 1 | `int_typespec\|VpiType\|KIND:int_typespec>logic_typespec` |
| 95 | 1 | 1 | `logic_typespec\|VpiType\|KIND:logic_typespec>bit_typespec` |
| 96 | 1 | 1 | `module_inst\|Variables\|VEC:G<O` |
| 97 | 1 | 1 | `operation\|Operands\|VEC:G>O` |
| 98 | 1 | 1 | `operation\|VpiOpType\|INT:G<O` |

### Example cells (up to 3 per family, in rank order)

**F1 `constant|VpiType|KIND:constant>operation`** — 27 entries in 9 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Rggen, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 77
    - L(golden) `constant@uvm_pkg.sv:32186:23-32186:24`
    - R(ours)   `operation@:32186:23-32186:25`
    - G= constant   O= operation
  - `default_Earlgrey_0_1` rung 26
    - L(golden) `constant@tlul_fifo_sync.sv:76:69-76:91`
    - R(ours)   `operation@:76:69-76:91`
    - G= constant   O= operation
  - `default_Rggen` rung 13
    - L(golden) `constant@:0:0-0:0`
    - R(ours)   `operation@:68:29-68:78`
    - G= constant   O= operation

**F2 `ref_typespec|<rhs-null>|MISSING-OURS`** — 1460 entries in 8 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 7
    - L(golden) `ref_typespec@:0:0-0:0`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 3
    - L(golden) `ref_typespec@:0:0-0:0`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Scoreboard` rung 29
    - L(golden) `ref_typespec@:0:0-0:0`
    - R(ours)   `<null>`
    - G= -   O= -

**F3 `+ref_typespec|<lhs-null>|EXTRA-OURS`** — 23 entries in 8 row(s): default_BuildUVMPkg, default_Rggen, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 89
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0`
    - G= -   O= -
  - `default_Rggen` rung 9
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0`
    - G= -   O= -
  - `default_Scoreboard` rung 70
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0`
    - G= -   O= -

**F4 `constant|VpiConstType|INT:G<O`** — 9 entries in 8 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 54
    - L(golden) `constant@uvm_pkg.sv:30186:82-30186:82`
    - R(ours)   `constant@:24157:58-24157:59`
    - G= 7   O= 9
  - `default_Earlgrey_0_1` rung 232
    - L(golden) `constant@prim_fifo_sync.sv:72:53-72:58`
    - R(ours)   `constant@:72:53-72:58`
    - G= 7   O= 9
  - `default_Scoreboard` rung 26
    - L(golden) `constant@uvm_report_server.svh:689:82-689:82`
    - R(ours)   `constant@:321:58-321:59`
    - G= 7   O= 9

**F5 `function|<rhs-null>|MISSING-OURS`** — 83 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 12
    - L(golden) `function(set_severity_count)@uvm_pkg.sv:29615:9-29615:21`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Scoreboard` rung 14
    - L(golden) `function(print_field)@uvm_printer.svh:102:3-102:9`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_SeqDriver` rung 24
    - L(golden) `function(set_severity_count)@uvm_report_server.svh:76:9-76:21`
    - R(ours)   `<null>`
    - G= -   O= -

**F6 `+string_var|<lhs-null>|EXTRA-OURS`** — 38 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 73
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_warning_id)@:45032:14-45032:60`
    - G= -   O= -
  - `default_Scoreboard` rung 7
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_warning_id)@:24:14-24:60`
    - G= -   O= -
  - `default_SeqDriver` rung 7
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_warning_id)@:24:14-24:60`
    - G= -   O= -

**F7 `io_decl|<rhs-null>|MISSING-OURS`** — 26 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 34
    - L(golden) `io_decl(severity)@uvm_pkg.sv:9560:40-9560:48`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Scoreboard` rung 12
    - L(golden) `io_decl(l_sequencer)@uvm_sequence_base.svh:940:71-940:82`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_SeqDriver` rung 31
    - L(golden) `io_decl(severity)@uvm_report_server.svh:458:50-458:58`
    - R(ours)   `<null>`
    - G= -   O= -

**F8 `+class_var|<lhs-null>|EXTRA-OURS`** — 25 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 75
    - L(golden) `<null>`
    - R(ours)   `class_var(uvm_cmdline_proc)@:43181:23-43181:39`
    - G= -   O= -
  - `default_Scoreboard` rung 8
    - L(golden) `<null>`
    - R(ours)   `class_var(build_ph)@:46:11-46:19`
    - G= -   O= -
  - `default_SeqDriver` rung 38
    - L(golden) `<null>`
    - R(ours)   `class_var(uvm_default_comparer)@:654:14-654:42`
    - G= -   O= -

**F9 `+enum_const|<lhs-null>|EXTRA-OURS`** — 13 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 57
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_ERROR)@:8053:3-8053:12`
    - G= -   O= -
  - `default_Scoreboard` rung 28
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_ERROR)@:246:3-246:12`
    - G= -   O= -
  - `default_SeqDriver` rung 36
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_ERROR)@:246:3-246:12`
    - G= -   O= -

**F10 `+io_decl|<lhs-null>|EXTRA-OURS`** — 7 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 56
    - L(golden) `<null>`
    - R(ours)   `io_decl(action)@:30797:51-30797:57`
    - G= -   O= -
  - `default_Scoreboard` rung 27
    - L(golden) `<null>`
    - R(ours)   `io_decl(action)@:347:51-347:57`
    - G= -   O= -
  - `default_SeqDriver` rung 35
    - L(golden) `<null>`
    - R(ours)   `io_decl(action)@:347:51-347:57`
    - G= -   O= -

**F11 `class_typespec|VpiName|TEXT:rsp_type|uvm_sequence_item`** — 7 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 71
    - L(golden) `class_typespec(rsp_type)@uvm_pkg.sv:53934:58-53934:61`
    - R(ours)   `class_typespec(uvm_sequence_item)@:0:0-0:0`
    - G= "rsp_type"   O= "uvm_sequence_item"
  - `default_Scoreboard` rung 6
    - L(golden) `class_typespec(rsp_type)@uvm_sequencer_param_base.svh:211:58-211:61`
    - R(ours)   `class_typespec(uvm_sequence_item)@:0:0-0:0`
    - G= "rsp_type"   O= "uvm_sequence_item"
  - `default_SeqDriver` rung 6
    - L(golden) `class_typespec(rsp_type)@uvm_sequencer_param_base.svh:211:58-211:61`
    - R(ours)   `class_typespec(uvm_sequence_item)@:0:0-0:0`
    - G= "rsp_type"   O= "uvm_sequence_item"

**F12 `hier_path|VpiName|TEXT:m_streams[].exists|m_streams[ro.get_name()].exists`** — 7 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 53
    - L(golden) `hier_path(m_streams[].exists)@uvm_pkg.sv:30163:48-30163:94`
    - R(ours)   `hier_path(m_streams[ro.get_name()].exists)@:30163:48-30163:94`
    - G= "m_streams[].exists"   O= "m_streams[ro.get_name()].exists"
  - `default_Scoreboard` rung 25
    - L(golden) `hier_path(m_streams[].exists)@uvm_report_server.svh:666:48-666:94`
    - R(ours)   `hier_path(m_streams[ro.get_name()].exists)@:666:48-666:94`
    - G= "m_streams[].exists"   O= "m_streams[ro.get_name()].exists"
  - `default_SeqDriver` rung 32
    - L(golden) `hier_path(m_streams[].exists)@uvm_report_server.svh:666:48-666:94`
    - R(ours)   `hier_path(m_streams[ro.get_name()].exists)@:666:48-666:94`
    - G= "m_streams[].exists"   O= "m_streams[ro.get_name()].exists"

**F13 `ref_var|VpiType|KIND:ref_var>logic_var`** — 7 entries in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 51
    - L(golden) `ref_var@uvm_pkg.sv:28181:20-28181:36`
    - R(ours)   `logic_var@:28181:20-28181:36`
    - G= ref_var   O= logic_var
  - `default_Scoreboard` rung 22
    - L(golden) `ref_var@uvm_report_message.svh:338:20-338:36`
    - R(ours)   `logic_var@:338:20-338:36`
    - G= ref_var   O= logic_var
  - `default_SeqDriver` rung 29
    - L(golden) `ref_var@uvm_report_message.svh:338:20-338:36`
    - R(ours)   `logic_var@:338:20-338:36`
    - G= ref_var   O= logic_var

**F14 `ref_obj|VpiType|KIND:ref_obj>constant`** — 78 entries in 6 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Scoreboard, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 1
    - L(golden) `ref_obj(original_type)@uvm_pkg.sv:12509:31-12509:44`
    - R(ours)   `constant@:12370:39-12370:41`
    - G= ref_obj   O= constant
  - `default_Earlgrey_0_1` rung 72
    - L(golden) `ref_obj(PTRV_W)@prim_fifo_sync.sv:70:38-70:44`
    - R(ours)   `constant@:70:38-70:44`
    - G= ref_obj   O= constant
  - `default_Scoreboard` rung 36
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:984:31-984:44`
    - R(ours)   `constant@:986:36-986:39`
    - G= ref_obj   O= constant

**F15 `ref_obj|VpiType|KIND:ref_obj>hier_path`** — 14 entries in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 3
    - L(golden) `ref_obj(original_type)@uvm_pkg.sv:12657:29-12657:42`
    - R(ours)   `hier_path(original_type.get_type_name)@:12658:34-12658:63`
    - G= ref_obj   O= hier_path
  - `default_Scoreboard` rung 38
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:1114:29-1114:42`
    - R(ours)   `hier_path(original_type.get_type_name)@:1115:34-1115:63`
    - G= ref_obj   O= hier_path
  - `default_SeqDriver` rung 13
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:1114:29-1114:42`
    - R(ours)   `hier_path(original_type.get_type_name)@:1115:34-1115:63`
    - G= ref_obj   O= hier_path

**F16 `method_func_call|VpiName|TEXT:this|sequences`** — 10 entries in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 3
    - L(golden) `method_func_call(this)@uvm_sequencer_base.svh:1578:12-1578:21`
    - R(ours)   `method_func_call(sequences)@:1578:12-1578:21`
    - G= "this"   O= "sequences"
  - `default_SeqDriver` rung 3
    - L(golden) `method_func_call(this)@uvm_sequencer_base.svh:1578:12-1578:21`
    - R(ours)   `method_func_call(sequences)@:1578:12-1578:21`
    - G= "this"   O= "sequences"
  - `default_SimpleUVM` rung 3
    - L(golden) `method_func_call(this)@uvm_sequencer_base.svh:1578:12-1578:21`
    - R(ours)   `method_func_call(sequences)@:1578:12-1578:21`
    - G= "this"   O= "sequences"

**F17 `function|VpiName|G-EXTRA-PREFIX(uvm_root::)`** — 9 entries in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 68
    - L(golden) `function(uvm_root::get)@uvm_root.svh:324:1-327:12`
    - R(ours)   `function(get)@:324:1-327:12`
    - G= "uvm_root::get"   O= "get"
  - `default_SeqDriver` rung 47
    - L(golden) `function(uvm_root::get)@uvm_root.svh:324:1-327:12`
    - R(ours)   `function(get)@:324:1-327:12`
    - G= "uvm_root::get"   O= "get"
  - `default_SimpleUVM` rung 41
    - L(golden) `function(uvm_root::get)@uvm_root.svh:324:1-327:12`
    - R(ours)   `function(get)@:324:1-327:12`
    - G= "uvm_root::get"   O= "get"

**F18 `constant|VpiType|KIND:constant>hier_path`** — 8 entries in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 2
    - L(golden) `constant@uvm_sequencer_base.svh:1576:23-1576:44`
    - R(ours)   `hier_path(this.sequences.size)@:1576:23-1576:44`
    - G= constant   O= hier_path
  - `default_SeqDriver` rung 2
    - L(golden) `constant@uvm_sequencer_base.svh:1576:23-1576:44`
    - R(ours)   `hier_path(this.sequences.size)@:1576:23-1576:44`
    - G= constant   O= hier_path
  - `default_SimpleUVM` rung 2
    - L(golden) `constant@uvm_sequencer_base.svh:1576:23-1576:44`
    - R(ours)   `hier_path(this.sequences.size)@:1576:23-1576:44`
    - G= constant   O= hier_path

**F19 `enum_typespec|VpiName|G-EXTRA-SUFFIX(_enum)`** — 5 entries in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 80
    - L(golden) `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_pkg.sv:8200:1-8211:22`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_sequence_state)@:8200:1-8211:22`
    - G= "uvm_pkg::uvm_sequence_state_enum"   O= "uvm_pkg::uvm_sequence_state"
  - `default_Scoreboard` rung 10
    - L(golden) `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_object_globals.svh:399:1-410:22`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_sequence_state)@:399:1-410:22`
    - G= "uvm_pkg::uvm_sequence_state_enum"   O= "uvm_pkg::uvm_sequence_state"
  - `default_SimpleUVM` rung 10
    - L(golden) `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_object_globals.svh:399:1-410:22`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_sequence_state)@:399:1-410:22`
    - G= "uvm_pkg::uvm_sequence_state_enum"   O= "uvm_pkg::uvm_sequence_state"

**F20 `logic_var|<rhs-null>|MISSING-OURS`** — 5 entries in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 82
    - L(golden) `logic_var(e)@uvm_pkg.sv:55336:11-55336:12`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Scoreboard` rung 11
    - L(golden) `logic_var(e)@uvm_sequence_base.svh:757:11-757:12`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_SimpleUVM` rung 11
    - L(golden) `logic_var(e)@uvm_sequence_base.svh:757:11-757:12`
    - R(ours)   `<null>`
    - G= -   O= -

**F21 `package|<rhs-null>|MISSING-OURS`** — 5 entries in 5 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 70
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 82
    - L(golden) `package(dm)@dm_pkg.sv:19:1-414:16`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_SeqDriver` rung 1
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - R(ours)   `<null>`
    - G= -   O= -

**F22 `parameter|VpiImported|O-EMPTY`** — 5 entries in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 72
    - L(golden) `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23`
    - R(ours)   `parameter(UVM_ABSTRACT)@:201:11-201:23`
    - G= "uvm_pkg"   O= 0
  - `default_SeqDriver` rung 49
    - L(golden) `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23`
    - R(ours)   `parameter(UVM_ABSTRACT)@:201:11-201:23`
    - G= "uvm_pkg"   O= 0
  - `default_SimpleUVM` rung 44
    - L(golden) `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23`
    - R(ours)   `parameter(UVM_ABSTRACT)@:201:11-201:23`
    - G= "uvm_pkg"   O= 0

**F23 `ref_obj|VpiName|G-EXTRA-SUFFIX(_name)`** — 5 entries in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 5
    - L(golden) `ref_obj(original_type_name)@uvm_pkg.sv:12701:34-12701:52`
    - R(ours)   `ref_obj(original_type)@:12700:29-12700:42`
    - G= "original_type_name"   O= "original_type"
  - `default_Scoreboard` rung 41
    - L(golden) `ref_obj(original_type_name)@uvm_factory.svh:1154:34-1154:52`
    - R(ours)   `ref_obj(original_type)@:1153:29-1153:42`
    - G= "original_type_name"   O= "original_type"
  - `default_SeqDriver` rung 16
    - L(golden) `ref_obj(original_type_name)@uvm_factory.svh:1154:34-1154:52`
    - R(ours)   `ref_obj(original_type)@:1153:29-1153:42`
    - G= "original_type_name"   O= "original_type"

**F24 `ref_obj|VpiName|O-EXTRA-SUFFIX(_name)`** — 5 entries in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 4
    - L(golden) `ref_obj(original_type)@uvm_pkg.sv:12700:29-12700:42`
    - R(ours)   `ref_obj(original_type_name)@:12701:34-12701:52`
    - G= "original_type"   O= "original_type_name"
  - `default_Scoreboard` rung 40
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:1153:29-1153:42`
    - R(ours)   `ref_obj(original_type_name)@:1154:34-1154:52`
    - G= "original_type"   O= "original_type_name"
  - `default_SeqDriver` rung 15
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:1153:29-1153:42`
    - R(ours)   `ref_obj(original_type_name)@:1154:34-1154:52`
    - G= "original_type"   O= "original_type_name"

**F25 `string_var|<rhs-null>|MISSING-OURS`** — 5 entries in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 44
    - L(golden) `string_var(i)@uvm_factory.svh:1183:15-1183:16`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_SeqDriver` rung 19
    - L(golden) `string_var(i)@uvm_factory.svh:1183:15-1183:16`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_SimpleUVM` rung 17
    - L(golden) `string_var(index)@uvm_packer.svh:797:18-797:23`
    - R(ours)   `<null>`
    - G= -   O= -

**F26 `parameter|VpiType|KIND:parameter>constant`** — 14 entries in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 52
    - L(golden) `parameter(UVM_STR_CRC_POLYNOMIAL)@uvm_misc.svh:368:11-368:33`
    - R(ours)   `constant@:368:36-368:48`
    - G= parameter   O= constant
  - `default_SimpleUVM` rung 16
    - L(golden) `parameter(UVM_PACK)@uvm_object_globals.svh:195:11-195:19`
    - R(ours)   `constant@:195:31-195:32`
    - G= parameter   O= constant
  - `testflags_SimpleUVM` rung 16
    - L(golden) `parameter(UVM_PACK)@uvm_object_globals.svh:195:11-195:19`
    - R(ours)   `constant@:195:31-195:32`
    - G= parameter   O= constant

**F27 `operation|VpiType|KIND:operation>constant`** — 6 entries in 3 row(s): default_BuildUVMPkg, default_Rggen, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 81
    - L(golden) `operation@uvm_pkg.sv:54965:56-54965:148`
    - R(ours)   `constant@:40511:56-40511:58`
    - G= operation   O= constant
  - `default_Rggen` rung 21
    - L(golden) `operation@rggen_or_reducer.sv:66:10-66:18`
    - R(ours)   `constant@:66:10-66:16`
    - G= operation   O= constant
  - `testflags_BuildUVMPkg` rung 81
    - L(golden) `operation@uvm_pkg.sv:54965:56-54965:148`
    - R(ours)   `constant@:40511:56-40511:58`
    - G= operation   O= constant

**F28 `ref_obj|VpiName|O-EXTRA-SUFFIX([original_type])`** — 6 entries in 3 row(s): default_Scoreboard, default_SeqDriver, testflags_SeqDriver

  - `default_Scoreboard` rung 39
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:1119:3-1119:25`
    - R(ours)   `ref_obj(m_inst_override_queues[original_type])@:1119:3-1119:40`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[original_type]"
  - `default_SeqDriver` rung 14
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:1119:3-1119:25`
    - R(ours)   `ref_obj(m_inst_override_queues[original_type])@:1119:3-1119:40`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[original_type]"
  - `testflags_SeqDriver` rung 14
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:1119:3-1119:25`
    - R(ours)   `ref_obj(m_inst_override_queues[original_type])@:1119:3-1119:40`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[original_type]"

**F29 `+int_var|<lhs-null>|EXTRA-OURS`** — 4 entries in 3 row(s): default_BuildUVMPkg, default_Scoreboard, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 18
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:22227:8-22227:10`
    - G= -   O= -
  - `default_Scoreboard` rung 15
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:485:7-485:9`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 18
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:22227:8-22227:10`
    - G= -   O= -

**F30 `module_inst|Variables|VEC:G>O`** — 4 entries in 3 row(s): default_Earlgrey_0_1, default_SeqDriver, testflags_SeqDriver

  - `default_Earlgrey_0_1` rung 513
    - L(golden) `module_inst(u_fwmode)@spi_device.sv:330:3-359:5`
    - R(ours)   `module_inst(u_fwmode)@spi_device.sv:330:3-359:5`
    - G= 11   O= 10
  - `default_SeqDriver` rung 59
    - L(golden) `module_inst(work@top_tb)@testbench.sv:210:1-236:18`
    - R(ours)   `module_inst(work@top_tb)@testbench.sv:210:1-236:18`
    - G= 66   O= 25
  - `testflags_SeqDriver` rung 59
    - L(golden) `module_inst(work@top_tb)@testbench.sv:210:1-236:18`
    - R(ours)   `module_inst(work@top_tb)@testbench.sv:210:1-236:18`
    - G= 66   O= 25

**F31 `+package|~Typespecs|VEC:G>O`** — 3 entries in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 51
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - G= 125   O= 91
  - `default_SimpleUVM` rung 39
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 39
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - G= 123   O= 89

**F32 `chandle_var|<rhs-null>|MISSING-OURS`** — 3 entries in 3 row(s): default_Scoreboard, default_SeqDriver, testflags_SeqDriver

  - `default_Scoreboard` rung 49
    - L(golden) `chandle_var(compiled_regex)@uvm_traversal.svh:257:18-257:32`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_SeqDriver` rung 34
    - L(golden) `chandle_var(compiled_regex)@uvm_traversal.svh:257:18-257:32`
    - R(ours)   `<null>`
    - G= -   O= -
  - `testflags_SeqDriver` rung 34
    - L(golden) `chandle_var(compiled_regex)@uvm_traversal.svh:257:18-257:32`
    - R(ours)   `<null>`
    - G= -   O= -

**F33 `constant|<rhs-null>|MISSING-OURS`** — 3 entries in 3 row(s): default_BuildUVMPkg, default_Scoreboard, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 60
    - L(golden) `constant@uvm_pkg.sv:20128:59-20128:60`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Scoreboard` rung 32
    - L(golden) `constant@uvm_misc.svh:284:79-284:80`
    - R(ours)   `<null>`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 60
    - L(golden) `constant@uvm_pkg.sv:20128:59-20128:60`
    - R(ours)   `<null>`
    - G= -   O= -

**F34 `design|Typespecs|VEC:G>O`** — 3 entries in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 76
    - L(golden) `design(work@my_scoreboard_unit_test)@:0:0-0:0`
    - R(ours)   `design(work@my_scoreboard_unit_test)@:0:0-0:0`
    - G= 125   O= 91
  - `default_SimpleUVM` rung 47
    - L(golden) `design(work@top)@:0:0-0:0`
    - R(ours)   `design(work@top)@:0:0-0:0`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 47
    - L(golden) `design(work@top)@:0:0-0:0`
    - R(ours)   `design(work@top)@:0:0-0:0`
    - G= 123   O= 89

**F35 `package|~Typespecs|VEC:G>O`** — 3 entries in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 1
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - R(ours)   `<null>`
    - G= 125   O= 91
  - `default_SimpleUVM` rung 1
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - R(ours)   `<null>`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 1
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - R(ours)   `<null>`
    - G= 123   O= 89

**F36 `ref_obj|VpiName|O-EXTRA-SUFFIX([obj])`** — 3 entries in 3 row(s): default_Scoreboard, default_SeqDriver, testflags_SeqDriver

  - `default_Scoreboard` rung 35
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:919:13-919:35`
    - R(ours)   `ref_obj(m_inst_override_queues[obj])@:919:13-919:40`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[obj]"
  - `default_SeqDriver` rung 10
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:919:13-919:35`
    - R(ours)   `ref_obj(m_inst_override_queues[obj])@:919:13-919:40`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[obj]"
  - `testflags_SeqDriver` rung 10
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:919:13-919:35`
    - R(ours)   `ref_obj(m_inst_override_queues[obj])@:919:13-919:40`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[obj]"

**F37 `ref_obj|VpiName|O-EXTRA-SUFFIX([original_type_name])`** — 3 entries in 3 row(s): default_Scoreboard, default_SeqDriver, testflags_SeqDriver

  - `default_Scoreboard` rung 43
    - L(golden) `ref_obj(m_inst_override_name_queues)@uvm_factory.svh:1176:7-1176:34`
    - R(ours)   `ref_obj(m_inst_override_name_queues[original_type_name])@:1176:7-1176:54`
    - G= "m_inst_override_name_queues"   O= "m_inst_override_name_queues[original_type_name]"
  - `default_SeqDriver` rung 18
    - L(golden) `ref_obj(m_inst_override_name_queues)@uvm_factory.svh:1176:7-1176:34`
    - R(ours)   `ref_obj(m_inst_override_name_queues[original_type_name])@:1176:7-1176:54`
    - G= "m_inst_override_name_queues"   O= "m_inst_override_name_queues[original_type_name]"
  - `testflags_SeqDriver` rung 18
    - L(golden) `ref_obj(m_inst_override_name_queues)@uvm_factory.svh:1176:7-1176:34`
    - R(ours)   `ref_obj(m_inst_override_name_queues[original_type_name])@:1176:7-1176:54`
    - G= "m_inst_override_name_queues"   O= "m_inst_override_name_queues[original_type_name]"

**F38 `ref_obj|VpiName|O-EXTRA-SUFFIX([rtype])`** — 3 entries in 3 row(s): default_Scoreboard, default_SeqDriver, testflags_SeqDriver

  - `default_Scoreboard` rung 45
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:1387:10-1387:32`
    - R(ours)   `ref_obj(m_inst_override_queues[rtype])@:1387:10-1387:39`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[rtype]"
  - `default_SeqDriver` rung 20
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:1387:10-1387:32`
    - R(ours)   `ref_obj(m_inst_override_queues[rtype])@:1387:10-1387:39`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[rtype]"
  - `testflags_SeqDriver` rung 20
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:1387:10-1387:32`
    - R(ours)   `ref_obj(m_inst_override_queues[rtype])@:1387:10-1387:39`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[rtype]"

**F39 `constant|VpiType|KIND:constant>ref_obj`** — 1289 entries in 2 row(s): default_Earlgrey_0_1, default_Rggen

  - `default_Earlgrey_0_1` rung 80
    - L(golden) `constant@prim_fifo_sync.sv:131:29-131:38`
    - R(ours)   `ref_obj(PTR_WIDTH)@:131:29-131:38`
    - G= constant   O= ref_obj
  - `default_Rggen` rung 11
    - L(golden) `constant@:0:0-0:0`
    - R(ours)   `ref_obj(RGGEN_OKAY)@:104:35-104:45`
    - G= constant   O= ref_obj
  - `default_Earlgrey_0_1` rung 128
    - L(golden) `constant@prim_fifo_sync.sv:131:29-131:38`
    - R(ours)   `ref_obj(PTR_WIDTH)@:131:29-131:38`
    - G= constant   O= ref_obj

**F40 `constant|VpiDecompile|DIGITS-ONLY`** — 16 entries in 2 row(s): default_Earlgrey_0_1, default_Rggen

  - `default_Earlgrey_0_1` rung 2
    - L(golden) `constant@rv_core_ibex.sv:68:30-68:52`
    - R(ours)   `constant@:68:30-68:52`
    - G= "32'h0"   O= "4'h0"
  - `default_Rggen` rung 1
    - L(golden) `constant@rggen_or_reducer.sv:30:22-30:23`
    - R(ours)   `constant@:30:22-30:23`
    - G= "0"   O= "1"
  - `default_Earlgrey_0_1` rung 605
    - L(golden) `constant@prim_fifo_sync.sv:12:40-12:41`
    - R(ours)   `constant@:12:40-12:41`
    - G= "4'h0"   O= "32'h0"

**F41 `constant|VpiSize|INT:G>O`** — 8 entries in 2 row(s): default_Earlgrey_0_1, default_Rggen

  - `default_Earlgrey_0_1` rung 603
    - L(golden) `constant@tlul_socket_1n.sv:126:32-126:33`
    - R(ours)   `constant@:126:32-126:35`
    - G= 64   O= 32
  - `default_Rggen` rung 5
    - L(golden) `constant@rggen_adapter_common.sv:18:39-18:48`
    - R(ours)   `constant@:18:39-18:48`
    - G= 64   O= 32
  - `default_Earlgrey_0_1` rung 604
    - L(golden) `constant@tlul_socket_1n.sv:127:32-127:33`
    - R(ours)   `constant@:127:32-127:35`
    - G= 64   O= 32

**F42 `+package|<lhs-null>|EXTRA-OURS`** — 6 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 9
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 9
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11`
    - G= -   O= -
  - `default_BuildUVMPkg` rung 17
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11`
    - G= -   O= -

**F43 `method_func_call|VpiType|KIND:method_func_call>hier_path`** — 6 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 63
    - L(golden) `method_func_call(set_type_override_by_type)@uvm_pkg.sv:14073:13-14073:38`
    - R(ours)   `hier_path(factory.set_type_override_by_type)@:14073:5-14073:38`
    - G= method_func_call   O= hier_path
  - `testflags_BuildUVMPkg` rung 63
    - L(golden) `method_func_call(set_type_override_by_type)@uvm_pkg.sv:14073:13-14073:38`
    - R(ours)   `hier_path(factory.set_type_override_by_type)@:14073:5-14073:38`
    - G= method_func_call   O= hier_path
  - `default_BuildUVMPkg` rung 64
    - L(golden) `method_func_call(set_inst_override_by_type)@uvm_pkg.sv:14088:13-14088:38`
    - R(ours)   `hier_path(factory.set_inst_override_by_type)@:14088:5-14088:38`
    - G= method_func_call   O= hier_path

**F44 `+enum_var|<lhs-null>|EXTRA-OURS`** — 4 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 69
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 69
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32`
    - G= -   O= -
  - `default_BuildUVMPkg` rung 87
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32`
    - G= -   O= -

**F45 `begin|<rhs-null>|MISSING-OURS`** — 4 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 58
    - L(golden) `begin@uvm_pkg.sv:14059:30-14066:8`
    - R(ours)   `<null>`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 58
    - L(golden) `begin@uvm_pkg.sv:14059:30-14066:8`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_BuildUVMPkg` rung 65
    - L(golden) `begin@uvm_pkg.sv:14094:63-14100:9`
    - R(ours)   `<null>`
    - G= -   O= -

**F46 `hier_path|Path_elems|VEC:G>O`** — 4 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 43
    - L(golden) `hier_path(m_recur_states[lhs][rhs].exists)@uvm_pkg.sv:21564:13-21564:55`
    - R(ours)   `hier_path(m_recur_states[lhs][rhs].exists)@:21564:13-21564:55`
    - G= 3   O= 2
  - `testflags_BuildUVMPkg` rung 43
    - L(golden) `hier_path(m_recur_states[lhs][rhs].exists)@uvm_pkg.sv:21564:13-21564:55`
    - R(ours)   `hier_path(m_recur_states[lhs][rhs].exists)@:21564:13-21564:55`
    - G= 3   O= 2
  - `default_BuildUVMPkg` rung 44
    - L(golden) `hier_path(m_recur_states[rhs][lhs].exists)@uvm_pkg.sv:18764:13-18764:55`
    - R(ours)   `hier_path(m_recur_states[rhs][lhs].exists)@:18764:13-18764:55`
    - G= 3   O= 2

**F47 `logic_typespec|VpiName|O-EXTRA-PREFIX(uvm_pkg::)`** — 4 entries in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 19
    - L(golden) `logic_typespec(uvm_bitstream_t)@uvm_object_globals.svh:49:9-49:42`
    - R(ours)   `logic_typespec(uvm_pkg::uvm_bitstream_t)@:49:9-49:42`
    - G= "uvm_bitstream_t"   O= "uvm_pkg::uvm_bitstream_t"
  - `testflags_SimpleUVM` rung 19
    - L(golden) `logic_typespec(uvm_bitstream_t)@uvm_object_globals.svh:49:9-49:42`
    - R(ours)   `logic_typespec(uvm_pkg::uvm_bitstream_t)@:49:9-49:42`
    - G= "uvm_bitstream_t"   O= "uvm_pkg::uvm_bitstream_t"
  - `default_SimpleUVM` rung 20
    - L(golden) `logic_typespec(uvm_integral_t)@uvm_object_globals.svh:59:9-59:28`
    - R(ours)   `logic_typespec(uvm_pkg::uvm_integral_t)@:59:9-59:28`
    - G= "uvm_integral_t"   O= "uvm_pkg::uvm_integral_t"

**F48 `+interface_inst|<lhs-null>|EXTRA-OURS`** — 2 entries in 2 row(s): default_SeqDriver, testflags_SeqDriver

  - `default_SeqDriver` rung 57
    - L(golden) `<null>`
    - R(ours)   `interface_inst@design.sv:1:1-16:23`
    - G= -   O= -
  - `testflags_SeqDriver` rung 57
    - L(golden) `<null>`
    - R(ours)   `interface_inst@design.sv:1:1-16:23`
    - G= -   O= -

**F49 `+module_inst|<lhs-null>|EXTRA-OURS`** — 2 entries in 2 row(s): default_YosysVerx, testflags_YosysVerx

  - `default_YosysVerx` rung 1
    - L(golden) `<null>`
    - R(ours)   `module_inst(work@vexriscv.demo.GenFull)@vexriscv.demo.GenFull.v:1059:1-7202:10`
    - G= -   O= -
  - `testflags_YosysVerx` rung 1
    - L(golden) `<null>`
    - R(ours)   `module_inst(work@vexriscv.demo.GenFull)@vexriscv.demo.GenFull.v:1059:1-7202:10`
    - G= -   O= -

**F50 `+ref_var|<lhs-null>|EXTRA-OURS`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 6
    - L(golden) `<null>`
    - R(ours)   `ref_var(orig_type_alias_per_inst)@:12754:30-12754:54`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 6
    - L(golden) `<null>`
    - R(ours)   `ref_var(orig_type_alias_per_inst)@:12754:30-12754:54`
    - G= -   O= -

**F51 `array_var|VpiType|KIND:array_var>class_var`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 55
    - L(golden) `array_var(idx)@uvm_pkg.sv:9847:29-9847:32`
    - R(ours)   `class_var(idx)@:9847:29-9847:32`
    - G= array_var   O= class_var
  - `testflags_BuildUVMPkg` rung 55
    - L(golden) `array_var(idx)@uvm_pkg.sv:9847:29-9847:32`
    - R(ours)   `class_var(idx)@:9847:29-9847:32`
    - G= array_var   O= class_var

**F52 `bit_typespec|VpiType|KIND:bit_typespec>int_typespec`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 61
    - L(golden) `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49`
    - R(ours)   `int_typespec@:7997:11-7997:27`
    - G= bit_typespec   O= int_typespec
  - `testflags_BuildUVMPkg` rung 61
    - L(golden) `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49`
    - R(ours)   `int_typespec@:7997:11-7997:27`
    - G= bit_typespec   O= int_typespec

**F53 `bit_var|<rhs-null>|MISSING-OURS`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 23
    - L(golden) `bit_var@uvm_pkg.sv:21545:7-21545:18`
    - R(ours)   `<null>`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 23
    - L(golden) `bit_var@uvm_pkg.sv:21545:7-21545:18`
    - R(ours)   `<null>`
    - G= -   O= -

**F54 `class_typespec|VpiName|TEXT:uvm_component|STRUCTURE`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 21
    - L(golden) `class_typespec(uvm_component)@uvm_pkg.sv:43513:70-43513:79`
    - R(ours)   `class_typespec(STRUCTURE)@:43560:76-43560:85`
    - G= "uvm_component"   O= "STRUCTURE"
  - `testflags_BuildUVMPkg` rung 21
    - L(golden) `class_typespec(uvm_component)@uvm_pkg.sv:43513:70-43513:79`
    - R(ours)   `class_typespec(STRUCTURE)@:43560:76-43560:85`
    - G= "uvm_component"   O= "STRUCTURE"

**F55 `class_typespec|VpiName|TEXT:uvm_object|T`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 78
    - L(golden) `class_typespec(uvm_object)@uvm_pkg.sv:25704:56-25704:57`
    - R(ours)   `class_typespec(T)@:25991:37-25991:38`
    - G= "uvm_object"   O= "T"
  - `testflags_BuildUVMPkg` rung 78
    - L(golden) `class_typespec(uvm_object)@uvm_pkg.sv:25704:56-25704:57`
    - R(ours)   `class_typespec(T)@:25991:37-25991:38`
    - G= "uvm_object"   O= "T"

**F56 `enum_typespec|VpiType|KIND:enum_typespec>bit_typespec`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 22
    - L(golden) `enum_typespec(recursion_state_e)@uvm_pkg.sv:18219:1-18223:21`
    - R(ours)   `bit_typespec@:21030:6-21030:23`
    - G= enum_typespec   O= bit_typespec
  - `testflags_BuildUVMPkg` rung 22
    - L(golden) `enum_typespec(recursion_state_e)@uvm_pkg.sv:18219:1-18223:21`
    - R(ours)   `bit_typespec@:21030:6-21030:23`
    - G= enum_typespec   O= bit_typespec

**F57 `enum_var|VpiType|KIND:enum_var>class_var`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 59
    - L(golden) `enum_var@uvm_pkg.sv:19055:27-19055:56`
    - R(ours)   `class_var@:20364:10-20364:39`
    - G= enum_var   O= class_var
  - `testflags_BuildUVMPkg` rung 59
    - L(golden) `enum_var@uvm_pkg.sv:19055:27-19055:56`
    - R(ours)   `class_var@:20364:10-20364:39`
    - G= enum_var   O= class_var

**F58 `function|VpiMethod|INT:G>O`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 68
    - L(golden) `function(get_default_max_ready_to_end_iterations)@uvm_pkg.sv:32619:3-32619:9`
    - R(ours)   `function(get_default_max_ready_to_end_iterations)@:33672:1-33674:12`
    - G= 1   O= 0
  - `testflags_BuildUVMPkg` rung 68
    - L(golden) `function(get_default_max_ready_to_end_iterations)@uvm_pkg.sv:32619:3-32619:9`
    - R(ours)   `function(get_default_max_ready_to_end_iterations)@:33672:1-33674:12`
    - G= 1   O= 0

**F59 `hier_path|VpiType|KIND:hier_path>bit_select`** — 2 entries in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 72
    - L(golden) `hier_path(list1[name].get_comp)@uvm_pkg.sv:45158:20-45158:42`
    - R(ours)   `bit_select(list1)@:45158:26-45158:30`
    - G= hier_path   O= bit_select
  - `testflags_BuildUVMPkg` rung 72
    - L(golden) `hier_path(list1[name].get_comp)@uvm_pkg.sv:45158:20-45158:42`
    - R(ours)   `bit_select(list1)@:45158:26-45158:30`
    - G= hier_path   O= bit_select

**F60 `logic_net|VpiType|KIND:logic_net>int_var`** — 2 entries in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 15
    - L(golden) `logic_net(sz)@:488:15-488:17`
    - R(ours)   `int_var(sz)@:485:7-485:9`
    - G= logic_net   O= int_var
  - `testflags_SimpleUVM` rung 15
    - L(golden) `logic_net(sz)@:488:15-488:17`
    - R(ours)   `int_var(sz)@:485:7-485:9`
    - G= logic_net   O= int_var

**F61 `module_inst|~Typespecs|VEC:G>O`** — 2 entries in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 46
    - L(golden) `module_inst@testbench.sv:44:1-71:10`
    - R(ours)   `<null>`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 46
    - L(golden) `module_inst@testbench.sv:44:1-71:10`
    - R(ours)   `<null>`
    - G= 123   O= 89

**F62 `package|VpiName|TEXT:uvm_pkg|adpcm_pkg`** — 2 entries in 2 row(s): default_SeqDriver, testflags_SeqDriver

  - `default_SeqDriver` rung 39
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - R(ours)   `package(adpcm_pkg)@testbench.sv:10:1-207:22`
    - G= "uvm_pkg"   O= "adpcm_pkg"
  - `testflags_SeqDriver` rung 39
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11`
    - R(ours)   `package(adpcm_pkg)@testbench.sv:10:1-207:22`
    - G= "uvm_pkg"   O= "adpcm_pkg"

**F63 `int_typespec|VpiType|KIND:int_typespec>integer_typespec`** — 236 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 74
    - L(golden) `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27`
    - R(ours)   `integer_typespec@:72:45-72:51`
    - G= int_typespec   O= integer_typespec
  - `default_Earlgrey_0_1` rung 75
    - L(golden) `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27`
    - R(ours)   `integer_typespec@:73:45-73:51`
    - G= int_typespec   O= integer_typespec
  - `default_Earlgrey_0_1` rung 76
    - L(golden) `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27`
    - R(ours)   `integer_typespec@:73:67-73:73`
    - G= int_typespec   O= integer_typespec

**F64 `constant|VpiDecompile|O-EXTRA-PREFIX(')`** — 40 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 118
    - L(golden) `constant@tlul_adapter_sram.sv:132:18-132:20`
    - R(ours)   `constant@:132:18-132:20`
    - G= "0"   O= "'0"
  - `default_Earlgrey_0_1` rung 119
    - L(golden) `constant@tlul_adapter_sram.sv:138:18-138:20`
    - R(ours)   `constant@:138:18-138:20`
    - G= "0"   O= "'0"
  - `default_Earlgrey_0_1` rung 151
    - L(golden) `constant@tlul_adapter_sram.sv:132:18-132:20`
    - R(ours)   `constant@:132:18-132:20`
    - G= "0"   O= "'0"

**F65 `hier_path|VpiName|TEXT:reg#hw.ctrl_en_input_filter.q[#]|reg#hw.ctrl_en_input_filter.q[i]`** — 32 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 480
    - L(golden) `hier_path(reg2hw.ctrl_en_input_filter.q[0])@gpio.sv:40:17-40:49`
    - R(ours)   `hier_path(reg2hw.ctrl_en_input_filter.q[i])@:40:17-40:49`
    - G= "reg2hw.ctrl_en_input_filter.q[0]"   O= "reg2hw.ctrl_en_input_filter.q[i]"
  - `default_Earlgrey_0_1` rung 481
    - L(golden) `hier_path(reg2hw.ctrl_en_input_filter.q[1])@gpio.sv:40:17-40:49`
    - R(ours)   `hier_path(reg2hw.ctrl_en_input_filter.q[i])@:40:17-40:49`
    - G= "reg2hw.ctrl_en_input_filter.q[1]"   O= "reg2hw.ctrl_en_input_filter.q[i]"
  - `default_Earlgrey_0_1` rung 482
    - L(golden) `hier_path(reg2hw.ctrl_en_input_filter.q[2])@gpio.sv:40:17-40:49`
    - R(ours)   `hier_path(reg2hw.ctrl_en_input_filter.q[i])@:40:17-40:49`
    - G= "reg2hw.ctrl_en_input_filter.q[2]"   O= "reg2hw.ctrl_en_input_filter.q[i]"

**F66 `logic_net|<rhs-null>|MISSING-OURS`** — 30 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 81
    - L(golden) `logic_net(rdata)@prim_fifo_sync.sv:29:27-29:32`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 99
    - L(golden) `logic_net(rdata)@prim_fifo_sync.sv:29:27-29:32`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 108
    - L(golden) `logic_net(rdata)@prim_fifo_sync.sv:29:27-29:32`
    - R(ours)   `<null>`
    - G= -   O= -

**F67 `enum_const|<rhs-null>|MISSING-OURS`** — 28 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 150
    - L(golden) `enum_const(OpRead)@tlul_adapter_sram.sv:49:5-49:11`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 152
    - L(golden) `enum_const(OpRead)@tlul_adapter_sram.sv:49:5-49:11`
    - R(ours)   `<null>`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 154
    - L(golden) `enum_const(OpWrite)@tlul_adapter_sram.sv:48:5-48:12`
    - R(ours)   `<null>`
    - G= -   O= -

**F68 `hier_path|VpiName|TEXT:register_if[#].value[#+:#]|register_if[#+#*i+#].value[# + # * l+:#]`** — 24 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 42
    - L(golden) `hier_path(register_if[12].value[0+:1])@block_1.sv:356:42-356:78`
    - R(ours)   `hier_path(register_if[6+7*i+6].value[0 + 1 * l+:1])@:356:42-356:78`
    - G= "register_if[12].value[0+:1]"   O= "register_if[6+7*i+6].value[0 + 1 * l+:1]"
  - `default_Rggen` rung 43
    - L(golden) `hier_path(register_if[12].value[1+:1])@block_1.sv:356:42-356:78`
    - R(ours)   `hier_path(register_if[6+7*i+6].value[0 + 1 * l+:1])@:356:42-356:78`
    - G= "register_if[12].value[1+:1]"   O= "register_if[6+7*i+6].value[0 + 1 * l+:1]"
  - `default_Rggen` rung 46
    - L(golden) `hier_path(register_if[12].value[0+:1])@block_1.sv:356:42-356:78`
    - R(ours)   `hier_path(register_if[6+7*i+6].value[0 + 1 * l+:1])@:356:42-356:78`
    - G= "register_if[12].value[0+:1]"   O= "register_if[6+7*i+6].value[0 + 1 * l+:1]"

**F69 `constant|VpiDecompile|TEXT:#|#+#*i+#*j+k`** — 11 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 44
    - L(golden) `constant@block_1.sv:280:44-280:53`
    - R(ours)   `constant@:280:44-280:55`
    - G= "7"   O= "6+7*i+3*j+k"
  - `default_Rggen` rung 48
    - L(golden) `constant@block_1.sv:280:44-280:53`
    - R(ours)   `constant@:280:44-280:55`
    - G= "8"   O= "6+7*i+3*j+k"
  - `default_Rggen` rung 52
    - L(golden) `constant@block_1.sv:280:44-280:53`
    - R(ours)   `constant@:280:44-280:55`
    - G= "9"   O= "6+7*i+3*j+k"

**F70 `logic_typespec|VpiName|O-EXTRA-PREFIX(hmac_pkg::)`** — 7 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1312
    - L(golden) `logic_typespec(sha_word_t)@hmac_pkg.sv:17:11-17:23`
    - R(ours)   `logic_typespec(hmac_pkg::sha_word_t)@:17:11-17:23`
    - G= "sha_word_t"   O= "hmac_pkg::sha_word_t"
  - `default_Earlgrey_0_1` rung 1313
    - L(golden) `logic_typespec(sha_word_t)@hmac_pkg.sv:17:11-17:23`
    - R(ours)   `logic_typespec(hmac_pkg::sha_word_t)@:17:11-17:23`
    - G= "sha_word_t"   O= "hmac_pkg::sha_word_t"
  - `default_Earlgrey_0_1` rung 1377
    - L(golden) `logic_typespec(sha_word_t)@hmac_pkg.sv:17:11-17:23`
    - R(ours)   `logic_typespec(hmac_pkg::sha_word_t)@:17:11-17:23`
    - G= "sha_word_t"   O= "hmac_pkg::sha_word_t"

**F71 `constant|VpiDecompile|TEXT:#|-#`** — 6 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 72
    - L(golden) `constant@rggen_register_common.sv:33:59-34:93`
    - R(ours)   `constant@:33:59-34:93`
    - G= "68"   O= "-60"
  - `default_Rggen` rung 77
    - L(golden) `constant@rggen_register_common.sv:33:59-34:93`
    - R(ours)   `constant@:33:59-34:93`
    - G= "72"   O= "-56"
  - `default_Rggen` rung 82
    - L(golden) `constant@rggen_register_common.sv:33:59-34:93`
    - R(ours)   `constant@:33:59-34:93`
    - G= "76"   O= "-52"

**F72 `+logic_var|<lhs-null>|EXTRA-OURS`** — 4 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1340
    - L(golden) `<null>`
    - R(ours)   `logic_var(fifo_wptr)@:58:27-58:36`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 1349
    - L(golden) `<null>`
    - R(ours)   `logic_var(fifo_wptr)@:58:27-58:36`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 1358
    - L(golden) `<null>`
    - R(ours)   `logic_var(fifo_wptr)@:58:27-58:36`
    - G= -   O= -

**F73 `+logic_net|<lhs-null>|EXTRA-OURS`** — 3 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 90
    - L(golden) `<null>`
    - R(ours)   `logic_net(clk_i)@:11:16-11:21`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 250
    - L(golden) `<null>`
    - R(ours)   `logic_net(host_req_i)@:16:9-16:19`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 512
    - L(golden) `<null>`
    - R(ours)   `logic_net(clk_i)@:11:16-11:21`
    - G= -   O= -

**F74 `constant|VpiDecompile|TEXT:#|#'b#`** — 3 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 192
    - L(golden) `constant@prim_ram_1p_adv.sv:32:41-32:53`
    - R(ours)   `constant@:32:41-32:53`
    - G= "14"   O= "32'b00000000000000000000000000001110"
  - `default_Earlgrey_0_1` rung 597
    - L(golden) `constant@prim_ram_2p_adv.sv:32:41-32:53`
    - R(ours)   `constant@:32:41-32:53`
    - G= "9"   O= "32'b00000000000000000000000000001001"
  - `default_Earlgrey_0_1` rung 598
    - L(golden) `constant@prim_ram_2p_async_adv.sv:32:41-32:53`
    - R(ours)   `constant@:32:41-32:53`
    - G= "9"   O= "32'b00000000000000000000000000001001"

**F75 `constant|VpiDecompile|TEXT:#|'#`** — 3 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1379
    - L(golden) `constant@hmac_core.sv:116:83-116:85`
    - R(ours)   `constant@:116:83-116:85`
    - G= "15"   O= "'1"
  - `default_Earlgrey_0_1` rung 1380
    - L(golden) `constant@hmac_core.sv:117:83-117:85`
    - R(ours)   `constant@:117:83-117:85`
    - G= "15"   O= "'1"
  - `default_Earlgrey_0_1` rung 1576
    - L(golden) `constant@hmac.sv:257:86-257:88`
    - R(ours)   `constant@:257:86-257:88`
    - G= "15"   O= "'1"

**F76 `constant|VpiSize|INT:G<O`** — 3 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 781
    - L(golden) `constant@flash_ctrl.sv:310:43-310:52`
    - R(ours)   `constant@:310:43-310:52`
    - G= 32   O= 64
  - `default_Earlgrey_0_1` rung 1086
    - L(golden) `constant@flash_prog_ctrl.sv:44:10-44:15`
    - R(ours)   `constant@:44:10-44:15`
    - G= 32   O= 64
  - `default_Earlgrey_0_1` rung 1133
    - L(golden) `constant@flash_rd_ctrl.sv:44:10-44:15`
    - R(ours)   `constant@:44:10-44:15`
    - G= 32   O= 64

**F77 `hier_path|VpiName|TEXT:reg#hw.addr.q[#+:#]|reg#hw.addr.q[DataBitWidth+:#]`** — 3 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1088
    - L(golden) `hier_path(reg2hw.addr.q[2+:17])@flash_ctrl.sv:171:22-171:58`
    - R(ours)   `hier_path(reg2hw.addr.q[DataBitWidth+:17])@:171:22-171:58`
    - G= "reg2hw.addr.q[2+:17]"   O= "reg2hw.addr.q[DataBitWidth+:17]"
  - `default_Earlgrey_0_1` rung 1136
    - L(golden) `hier_path(reg2hw.addr.q[2+:17])@flash_ctrl.sv:249:22-249:58`
    - R(ours)   `hier_path(reg2hw.addr.q[DataBitWidth+:17])@:249:22-249:58`
    - G= "reg2hw.addr.q[2+:17]"   O= "reg2hw.addr.q[DataBitWidth+:17]"
  - `default_Earlgrey_0_1` rung 1144
    - L(golden) `hier_path(reg2hw.addr.q[2+:17])@flash_ctrl.sv:277:22-277:58`
    - R(ours)   `hier_path(reg2hw.addr.q[DataBitWidth+:17])@:277:22-277:58`
    - G= "reg2hw.addr.q[2+:17]"   O= "reg2hw.addr.q[DataBitWidth+:17]"

**F78 `int_typespec|VpiSigned|INT:G>O`** — 3 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1374
    - L(golden) `int_typespec@prim_packer.sv:31:14-31:17`
    - R(ours)   `int_typespec@:31:14-31:17`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1375
    - L(golden) `int_typespec@prim_packer.sv:30:14-30:17`
    - R(ours)   `int_typespec@:30:14-30:17`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1376
    - L(golden) `int_typespec@prim_packer.sv:30:14-30:17`
    - R(ours)   `int_typespec@:30:14-30:17`
    - G= 1   O= 0

**F79 `param_assign|VpiOverriden|INT:G>O`** — 3 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1139
    - L(golden) `param_assign@flash_ctrl_pkg.sv:12:18-12:65`
    - R(ours)   `param_assign@:12:18-12:65`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1140
    - L(golden) `param_assign@flash_ctrl_pkg.sv:13:18-13:65`
    - R(ours)   `param_assign@:13:18-13:65`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1141
    - L(golden) `param_assign@flash_ctrl_pkg.sv:18:18-18:57`
    - R(ours)   `param_assign@:18:18-18:57`
    - G= 1   O= 0

**F80 `constant|VpiConstType|INT:G>O`** — 2 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 601
    - L(golden) `constant@prim_ram_2p_async_adv.sv:178:32-178:33`
    - R(ours)   `constant@:178:32-178:33`
    - G= 9   O= 7
  - `default_Earlgrey_0_1` rung 602
    - L(golden) `constant@prim_ram_2p_async_adv.sv:185:32-185:33`
    - R(ours)   `constant@:185:32-185:33`
    - G= 9   O= 7

**F81 `constant|VpiDecompile|G-EXTRA-PREFIX(#'b#)`** — 2 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 4
    - L(golden) `constant@rggen_adapter_common.sv:128:47-128:94`
    - R(ours)   `constant@:128:47-128:94`
    - G= "2'b00"   O= "0"
  - `default_Rggen` rung 25
    - L(golden) `constant@rggen_adapter_common.sv:128:47-128:94`
    - R(ours)   `constant@:128:47-128:94`
    - G= "2'b00"   O= "0"

**F82 `constant|VpiDecompile|O-EXTRA-SUFFIX(+i)`** — 2 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 32
    - L(golden) `constant@block_1.sv:173:42-173:43`
    - R(ours)   `constant@:173:42-173:45`
    - G= "2"   O= "2+i"
  - `default_Rggen` rung 36
    - L(golden) `constant@block_1.sv:225:42-225:43`
    - R(ours)   `constant@:225:42-225:45`
    - G= "4"   O= "4+i"

**F83 `constant|VpiDecompile|TEXT:#|#+#*i+#`** — 2 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 64
    - L(golden) `constant@block_1.sv:385:40-385:45`
    - R(ours)   `constant@:385:40-385:47`
    - G= "12"   O= "6+7*i+6"
  - `default_Rggen` rung 96
    - L(golden) `constant@block_1.sv:385:40-385:45`
    - R(ours)   `constant@:385:40-385:47`
    - G= "19"   O= "6+7*i+6"

**F84 `constant|VpiDecompile|TEXT:#|#+i`** — 2 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 34
    - L(golden) `constant@block_1.sv:173:42-173:43`
    - R(ours)   `constant@:173:42-173:45`
    - G= "3"   O= "2+i"
  - `default_Rggen` rung 38
    - L(golden) `constant@block_1.sv:225:42-225:43`
    - R(ours)   `constant@:225:42-225:45`
    - G= "5"   O= "4+i"

**F85 `constant|VpiType|KIND:constant>func_call`** — 2 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 10
    - L(golden) `constant@rggen_adapter_common.sv:55:14-55:16`
    - R(ours)   `func_call(pre_decode)@:40:27-40:53`
    - G= constant   O= func_call
  - `default_Rggen` rung 29
    - L(golden) `constant@rggen_adapter_common.sv:55:14-55:16`
    - R(ours)   `func_call(pre_decode)@:40:27-40:53`
    - G= constant   O= func_call

**F86 `hier_path|VpiSize|INT:G<O`** — 2 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1174
    - L(golden) `hier_path(reg2hw.cfg0.prescale.q)@rv_timer.sv:56:24-56:46`
    - R(ours)   `hier_path(reg2hw.cfg0.prescale.q)@:56:24-56:46`
    - G= 0   O= 12
  - `default_Earlgrey_0_1` rung 1175
    - L(golden) `hier_path(reg2hw.cfg0.step.q)@rv_timer.sv:57:24-57:42`
    - R(ours)   `hier_path(reg2hw.cfg0.step.q)@:57:24-57:42`
    - G= 0   O= 8

**F87 `param_assign|VpiOverriden|INT:G<O`** — 2 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1137
    - L(golden) `param_assign@flash_erase_ctrl.sv:41:31-41:78`
    - R(ours)   `param_assign@:41:31-41:78`
    - G= 0   O= 1
  - `default_Earlgrey_0_1` rung 1138
    - L(golden) `param_assign@flash_erase_ctrl.sv:42:31-42:96`
    - R(ours)   `param_assign@:42:31-42:96`
    - G= 0   O= 1

**F88 `bit_select|VpiType|KIND:bit_select>bit_var`** — 1 entries in 1 row(s): default_Scoreboard

  - `default_Scoreboard` rung 53
    - L(golden) `bit_select(crc1)@uvm_misc.svh:386:12-386:19`
    - R(ours)   `bit_var(crc1)@:372:16-372:20`
    - G= bit_select   O= bit_var

**F89 `class_typespec|<rhs-null>|MISSING-OURS`** — 1 entries in 1 row(s): default_Scoreboard

  - `default_Scoreboard` rung 71
    - L(golden) `class_typespec(uvm_analysis_imp)@design.sv:9:3-9:19`
    - R(ours)   `<null>`
    - G= -   O= -

**F90 `constant|VpiDecompile|O-EXTRA-PREFIX(-)`** — 1 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 67
    - L(golden) `constant@rggen_register_common.sv:33:59-34:93`
    - R(ours)   `constant@:33:59-34:93`
    - G= "64"   O= "-64"

**F91 `constant|VpiDecompile|O-EXTRA-SUFFIX(+#*i+#*j+k)`** — 1 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 40
    - L(golden) `constant@block_1.sv:280:44-280:53`
    - R(ours)   `constant@:280:44-280:55`
    - G= "6"   O= "6+7*i+3*j+k"

**F92 `constant|VpiDecompile|TEXT:#'hab|#`** — 1 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 16
    - L(golden) `constant@block_0.sv:468:30-468:43`
    - R(ours)   `constant@:468:30-468:43`
    - G= "8'hab"   O= "171"

**F93 `constant|VpiDecompile|TEXT:-#|#'b#`** — 1 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1
    - L(golden) `constant@rv_core_ibex.sv:67:29-67:51`
    - R(ours)   `constant@:67:29-67:51`
    - G= "-1"   O= "1'b1"

**F94 `int_typespec|VpiType|KIND:int_typespec>logic_typespec`** — 1 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 71
    - L(golden) `int_typespec@:0:0-0:0`
    - R(ours)   `logic_typespec@:0:0-0:0`
    - G= int_typespec   O= logic_typespec

**F95 `logic_typespec|VpiType|KIND:logic_typespec>bit_typespec`** — 1 entries in 1 row(s): default_Rggen

  - `default_Rggen` rung 15
    - L(golden) `logic_typespec@:0:0-0:0`
    - R(ours)   `bit_typespec@:450:18-450:27`
    - G= logic_typespec   O= bit_typespec

**F96 `module_inst|Variables|VEC:G<O`** — 1 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1385
    - L(golden) `module_inst(u_pad)@sha2.sv:290:3-312:5`
    - R(ours)   `module_inst(u_pad)@sha2.sv:290:3-312:5`
    - G= 8   O= 9

**F97 `operation|Operands|VEC:G>O`** — 1 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1381
    - L(golden) `operation@hmac_core.sv:119:5-119:19`
    - R(ours)   `operation@:119:5-119:19`
    - G= 2   O= 1

**F98 `operation|VpiOpType|INT:G<O`** — 1 entries in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1281
    - L(golden) `operation@aes_key_expand.sv:109:39-109:69`
    - R(ours)   `operation@:109:24-109:74`
    - G= 30   O= 32

## COARSE FAMILIES (kind | field)

| rank | rows | entries | family |
|---:|---:|---:|---|
| 1 | 9 | 1326 | `constant\|VpiType` |
| 2 | 9 | 66 | `hier_path\|VpiName` |
| 3 | 8 | 1460 | `ref_typespec\|<rhs-null>` |
| 4 | 8 | 23 | `+ref_typespec\|<lhs-null>` |
| 5 | 8 | 11 | `constant\|VpiConstType` |
| 6 | 7 | 83 | `function\|<rhs-null>` |
| 7 | 7 | 38 | `+string_var\|<lhs-null>` |
| 8 | 7 | 26 | `io_decl\|<rhs-null>` |
| 9 | 7 | 25 | `+class_var\|<lhs-null>` |
| 10 | 7 | 13 | `+enum_const\|<lhs-null>` |
| 11 | 7 | 11 | `class_typespec\|VpiName` |
| 12 | 7 | 7 | `+io_decl\|<lhs-null>` |
| 13 | 7 | 7 | `ref_var\|VpiType` |
| 14 | 6 | 92 | `ref_obj\|VpiType` |
| 15 | 5 | 25 | `ref_obj\|VpiName` |
| 16 | 5 | 10 | `method_func_call\|VpiName` |
| 17 | 5 | 9 | `function\|VpiName` |
| 18 | 5 | 5 | `enum_typespec\|VpiName` |
| 19 | 5 | 5 | `logic_var\|<rhs-null>` |
| 20 | 5 | 5 | `package\|<rhs-null>` |
| 21 | 5 | 5 | `parameter\|VpiImported` |
| 22 | 5 | 5 | `string_var\|<rhs-null>` |
| 23 | 3 | 14 | `parameter\|VpiType` |
| 24 | 3 | 11 | `logic_typespec\|VpiName` |
| 25 | 3 | 6 | `operation\|VpiType` |
| 26 | 3 | 5 | `module_inst\|Variables` |
| 27 | 3 | 4 | `+int_var\|<lhs-null>` |
| 28 | 3 | 3 | `+package\|~Typespecs` |
| 29 | 3 | 3 | `chandle_var\|<rhs-null>` |
| 30 | 3 | 3 | `constant\|<rhs-null>` |
| 31 | 3 | 3 | `design\|Typespecs` |
| 32 | 3 | 3 | `package\|~Typespecs` |
| 33 | 2 | 91 | `constant\|VpiDecompile` |
| 34 | 2 | 11 | `constant\|VpiSize` |
| 35 | 2 | 6 | `+package\|<lhs-null>` |
| 36 | 2 | 6 | `method_func_call\|VpiType` |
| 37 | 2 | 4 | `+enum_var\|<lhs-null>` |
| 38 | 2 | 4 | `begin\|<rhs-null>` |
| 39 | 2 | 4 | `hier_path\|Path_elems` |
| 40 | 2 | 2 | `+interface_inst\|<lhs-null>` |
| 41 | 2 | 2 | `+module_inst\|<lhs-null>` |
| 42 | 2 | 2 | `+ref_var\|<lhs-null>` |
| 43 | 2 | 2 | `array_var\|VpiType` |
| 44 | 2 | 2 | `bit_typespec\|VpiType` |
| 45 | 2 | 2 | `bit_var\|<rhs-null>` |
| 46 | 2 | 2 | `enum_typespec\|VpiType` |
| 47 | 2 | 2 | `enum_var\|VpiType` |
| 48 | 2 | 2 | `function\|VpiMethod` |
| 49 | 2 | 2 | `hier_path\|VpiType` |
| 50 | 2 | 2 | `logic_net\|VpiType` |
| 51 | 2 | 2 | `module_inst\|~Typespecs` |
| 52 | 2 | 2 | `package\|VpiName` |
| 53 | 1 | 237 | `int_typespec\|VpiType` |
| 54 | 1 | 30 | `logic_net\|<rhs-null>` |
| 55 | 1 | 28 | `enum_const\|<rhs-null>` |
| 56 | 1 | 5 | `param_assign\|VpiOverriden` |
| 57 | 1 | 4 | `+logic_var\|<lhs-null>` |
| 58 | 1 | 3 | `+logic_net\|<lhs-null>` |
| 59 | 1 | 3 | `int_typespec\|VpiSigned` |
| 60 | 1 | 2 | `hier_path\|VpiSize` |
| 61 | 1 | 1 | `bit_select\|VpiType` |
| 62 | 1 | 1 | `class_typespec\|<rhs-null>` |
| 63 | 1 | 1 | `logic_typespec\|VpiType` |
| 64 | 1 | 1 | `operation\|Operands` |
| 65 | 1 | 1 | `operation\|VpiOpType` |

