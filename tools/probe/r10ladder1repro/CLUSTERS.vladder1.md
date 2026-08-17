# r10ladder1 — CLUSTER REPORT

Instrument: `ctladder` (MEASUREMENT-ONLY; the official `uhdm-cmp` remains the sole acceptance judge).  Every rung below is a real `design::Compare` head under official semantics — the walk, the field order and the failure points are UHDM's own.

## Per-row ladder length (the first honest 'how far are we')

| row | rungs | distinct pairs | stop | deepest walk | cascade masks | SUPPRESSED | secs |
|---|---:|---:|---|---|---:|---|---:|
| default_BuildUVMPkg | 273 | 238 | FIXPOINT | 42931/183142 | 139 | 182799/183142 | 208.8 |
| default_Earlgrey_0_1 | 3256 | 3230 | BUDGET | 471303/783183 | 17 | 638600/783183 | 1500.2 |
| default_Rggen | 98 | 98 | FIXPOINT | 94688/252296 | 3 | 241318/252296 | 9.6 |
| default_Scoreboard | 403 | 368 | ROOT-BLOCKED | 43381/187081 | 113 | 186794/187081 | 244.2 |
| default_SeqDriver | 396 | 357 | FIXPOINT | 15879/317210 | 95 | 316770/317210 | 138.2 |
| default_SimpleUVM | 398 | 364 | ROOT-BLOCKED | 40555/188084 | 110 | 187799/188084 | 187.5 |
| default_YosysVerx | 1 | 1 | FIXPOINT | 24205/24205 | 0 | 1/24205 | 0.2 |
| testflags_BuildUVMPkg | 273 | 238 | FIXPOINT | 42931/183142 | 139 | 182799/183142 | 202.4 |
| testflags_SeqDriver | 525 | 468 | FIXPOINT | 26295/317222 | 129 | 316770/317222 | 281.0 |
| testflags_SimpleUVM | 398 | 364 | ROOT-BLOCKED | 40567/188096 | 110 | 187811/188096 | 186.2 |
| testflags_YosysVerx | 1 | 1 | FIXPOINT | 24205/24205 | 0 | 1/24205 | 0.2 |

`SUPPRESSED` is the union of the sets REACHABLE from every masked object, over the golden database.  Read it as an UPPER bound on what the masks hid: an object reachable from a mask may still be compared through another edge (that is why rungs continue after a whole package is masked).  `maxvis` is the matching LOWER bound on what was proven equal.  Together they say the ladder is a SAMPLE OF THE HEAD PATH, not a defect census — on the UVM rows SUPPRESSED approaches 100%.  `cascade masks` counts rungs whose single mask reached >=1% of golden.

Rows whose ladder is TRUNCATED (stop != FIXPOINT), so their length is a strict LOWER bound: **default_Earlgrey_0_1, default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM**

Every ladder length is a lower bound in a second way as well.  Seeding `m_visited` with a golden object M makes every later `SafeCompare(M, x)` return 0 without descending, so every disagreement whose failing `SafeCompare` is only REACHED THROUGH M on the walk becomes invisible.  That is not the same as M's `vpiParent` subtree, which is what `PL` and `KINDP` print: an object reachable by an edge outside M is still compared. Per-rung `masked=` is the size of the set reachable from that rung's mask.

## Per-row family profile (top 5 by entries)

| row | rungs | top families |
|---|---:|---|
| default_BuildUVMPkg | 273 | `sys_func_call\|VpiType\|KIND:sys_func_call>constant` x45<br>`function\|<rhs-null>\|MISSING-OURS` x28<br>`bit_typespec\|VpiType\|KIND:bit_typespec>int_typespec` x27<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x16<br>`+class_var\|<lhs-null>\|EXTRA-OURS` x12 |
| default_Earlgrey_0_1 | 3256 | `ref_typespec\|<rhs-null>\|MISSING-OURS` x1441<br>`constant\|VpiType\|KIND:constant>ref_obj` x1304<br>`int_typespec\|VpiType\|KIND:int_typespec>integer_typespec` x236<br>`ref_obj\|VpiType\|KIND:ref_obj>constant` x68<br>`constant\|VpiDecompile\|O-EXTRA-PREFIX(')` x40 |
| default_Rggen | 98 | `constant\|VpiType\|KIND:constant>ref_obj` x26<br>`hier_path\|VpiName\|TEXT:register_if[#].value[#+:#]\|register_if[#+#*i+#].value[# + # * l+:#]` x24<br>`constant\|VpiDecompile\|TEXT:#\|#+#*i+#*j+k` x11<br>`constant\|VpiDecompile\|DIGITS-ONLY` x8<br>`constant\|VpiDecompile\|TEXT:#\|-#` x6 |
| default_Scoreboard | 403 | `parameter\|VpiImported\|O-EMPTY` x164<br>`parameter\|VpiType\|KIND:parameter>constant` x22<br>`+ref_typespec\|<lhs-null>\|EXTRA-OURS` x21<br>`sys_func_call\|VpiType\|KIND:sys_func_call>constant` x16<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x13 |
| default_SeqDriver | 396 | `parameter\|VpiImported\|O-EMPTY` x164<br>`+ref_typespec\|<lhs-null>\|EXTRA-OURS` x37<br>`constant\|VpiSize\|INT:G<O` x16<br>`sys_func_call\|VpiType\|KIND:sys_func_call>constant` x16<br>`constant\|VpiDecompile\|TEXT:#\|int` x14 |
| default_SimpleUVM | 398 | `parameter\|VpiImported\|O-EMPTY` x164<br>`+ref_typespec\|<lhs-null>\|EXTRA-OURS` x22<br>`parameter\|VpiType\|KIND:parameter>constant` x21<br>`sys_func_call\|VpiType\|KIND:sys_func_call>constant` x16<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x13 |
| default_YosysVerx | 1 | `+module_inst\|<lhs-null>\|EXTRA-OURS` x1 |
| testflags_BuildUVMPkg | 273 | `sys_func_call\|VpiType\|KIND:sys_func_call>constant` x45<br>`function\|<rhs-null>\|MISSING-OURS` x28<br>`bit_typespec\|VpiType\|KIND:bit_typespec>int_typespec` x27<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x16<br>`+class_var\|<lhs-null>\|EXTRA-OURS` x12 |
| testflags_SeqDriver | 525 | `parameter\|VpiImported\|O-EMPTY` x246<br>`+ref_typespec\|<lhs-null>\|EXTRA-OURS` x46<br>`constant\|VpiSize\|INT:G<O` x20<br>`sys_func_call\|VpiType\|KIND:sys_func_call>constant` x16<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x15 |
| testflags_SimpleUVM | 398 | `parameter\|VpiImported\|O-EMPTY` x164<br>`+ref_typespec\|<lhs-null>\|EXTRA-OURS` x22<br>`parameter\|VpiType\|KIND:parameter>constant` x21<br>`sys_func_call\|VpiType\|KIND:sys_func_call>constant` x16<br>`+enum_const\|<lhs-null>\|EXTRA-OURS` x13 |
| testflags_YosysVerx | 1 | `+module_inst\|<lhs-null>\|EXTRA-OURS` x1 |

## NORMALISED FAMILIES — THE QUEUE (referrer -> kind | shape, literals stripped)

| rank | rows | distinct objects | rungs | family |
|---:|---:|---:|---:|---|
| 1 | 9 | 98 | 98 | `hier_path\|VpiName\|TEXT-DIFF` |
| 2 | 9 | 83 | 83 | `constant\|VpiDecompile\|TEXT-DIFF` |
| 3 | 9 | 29 | 29 | `constant\|VpiType\|KIND:constant>operation` |
| 4 | 8 | 94 | 94 | `ref_obj\|VpiType\|KIND:ref_obj>constant` |
| 5 | 8 | 9 | 9 | `constant\|VpiConstType\|INT:G<O` |
| 6 | 7 | 170 | 170 | `sys_func_call\|VpiType\|KIND:sys_func_call>constant` |
| 7 | 7 | 69 | 94 | `func_call -> function\|MISSING-OURS` |
| 8 | 7 | 66 | 66 | `assignment -> +class_var\|EXTRA-OURS` |
| 9 | 7 | 58 | 82 | `parameter -> +ref_typespec\|EXTRA-OURS` |
| 10 | 7 | 54 | 54 | `ref_obj\|VpiType\|KIND:ref_obj>hier_path` |
| 11 | 7 | 52 | 52 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX` |
| 12 | 7 | 35 | 65 | `ref_obj -> +enum_const\|EXTRA-OURS` |
| 13 | 7 | 30 | 30 | `method_func_call -> method_func_call\|MISSING-OURS` |
| 14 | 7 | 29 | 29 | `class_typespec\|VpiName\|O-EMPTY` |
| 15 | 7 | 26 | 26 | `ref_obj -> io_decl\|MISSING-OURS` |
| 16 | 7 | 25 | 25 | `class_typespec\|VpiName\|TEXT-DIFF` |
| 17 | 7 | 22 | 22 | `param_assign -> +int_typespec\|EXTRA-OURS` |
| 18 | 7 | 19 | 19 | `bit_typespec -> ref_typespec\|MISSING-OURS` |
| 19 | 7 | 17 | 17 | `ref_obj -> ref_typespec\|MISSING-OURS` |
| 20 | 7 | 16 | 16 | `method_func_call -> +int_var\|EXTRA-OURS` |
| 21 | 7 | 16 | 16 | `method_func_call\|VpiName\|TEXT-DIFF` |
| 22 | 7 | 15 | 15 | `ref_obj -> class_var\|MISSING-OURS` |
| 23 | 7 | 13 | 13 | `function\|VpiName\|G-EXTRA-PREFIX` |
| 24 | 7 | 12 | 12 | `ref_obj\|VpiName\|G-EXTRA-SUFFIX` |
| 25 | 7 | 11 | 11 | `class_defn -> +io_decl\|EXTRA-OURS` |
| 26 | 7 | 10 | 19 | `class_defn -> +int_var\|EXTRA-OURS` |
| 27 | 7 | 10 | 10 | `delay_control -> ref_obj\|MISSING-OURS` |
| 28 | 7 | 10 | 10 | `named_fork\|VpiJoinType\|INT:G>O` |
| 29 | 7 | 8 | 8 | `bit_select\|VpiType\|KIND:bit_select>bit_var` |
| 30 | 7 | 7 | 60 | `class_defn -> +string_var\|EXTRA-OURS` |
| 31 | 7 | 7 | 28 | `class_defn -> +enum_const\|EXTRA-OURS` |
| 32 | 7 | 7 | 7 | `enum_typespec\|VpiName\|G-EXTRA-SUFFIX` |
| 33 | 7 | 7 | 7 | `function -> +int_var\|EXTRA-OURS` |
| 34 | 7 | 7 | 7 | `if_stmt -> +string_var\|EXTRA-OURS` |
| 35 | 7 | 7 | 7 | `ref_obj -> logic_var\|MISSING-OURS` |
| 36 | 7 | 7 | 7 | `ref_obj\|VpiType\|KIND:ref_obj>operation` |
| 37 | 7 | 7 | 7 | `ref_var\|VpiType\|KIND:ref_var>logic_var` |
| 38 | 7 | 7 | 7 | `string_var\|VpiType\|KIND:string_var>io_decl` |
| 39 | 6 | 63 | 63 | `constant\|VpiSize\|INT:G<O` |
| 40 | 6 | 16 | 16 | `ref_var\|VpiType\|KIND:ref_var>class_var` |
| 41 | 6 | 14 | 14 | `begin\|Stmts\|VEC:G<O` |
| 42 | 6 | 10 | 10 | `class_var\|VpiAutomatic\|INT:G>O` |
| 43 | 6 | 6 | 6 | `bit_var\|VpiAutomatic\|INT:G<O` |
| 44 | 6 | 6 | 6 | `operation -> +ref_typespec\|EXTRA-OURS` |
| 45 | 6 | 6 | 6 | `ref_var\|VpiType\|KIND:ref_var>hier_path` |
| 46 | 6 | 6 | 6 | `string_var\|VpiAutomatic\|INT:G<O` |
| 47 | 5 | 902 | 902 | `parameter\|VpiImported\|O-EMPTY` |
| 48 | 5 | 36 | 60 | `param_assign -> +ref_typespec\|EXTRA-OURS` |
| 49 | 5 | 23 | 23 | `constant\|VpiType\|KIND:constant>hier_path` |
| 50 | 5 | 21 | 21 | `event_stmt\|VpiName\|O-EMPTY` |
| 51 | 5 | 18 | 18 | `unsupported_typespec\|VpiType\|KIND:unsupported_typespec>class_typespec` |
| 52 | 5 | 15 | 15 | `method_func_call\|VpiType\|KIND:method_func_call>hier_path` |
| 53 | 5 | 10 | 10 | `func_call\|VpiType\|KIND:func_call>hier_path` |
| 54 | 5 | 5 | 5 | `begin -> +class_var\|EXTRA-OURS` |
| 55 | 5 | 5 | 5 | `class_defn\|VpiName\|TEXT-DIFF` |
| 56 | 5 | 5 | 5 | `class_var\|VpiType\|KIND:class_var>ref_var` |
| 57 | 5 | 5 | 5 | `foreach_stmt -> string_var\|MISSING-OURS` |
| 58 | 5 | 5 | 5 | `int_var -> operation\|MISSING-OURS` |
| 59 | 5 | 5 | 5 | `ref_obj\|VpiType\|KIND:ref_obj>func_call` |
| 60 | 4 | 8 | 8 | `enum_const\|VpiDecompile\|TEXT-DIFF` |
| 61 | 4 | 4 | 6 | `class_defn -> +package\|EXTRA-OURS` |
| 62 | 4 | 4 | 4 | `unsupported_typespec -> package\|MISSING-OURS` |
| 63 | 3 | 64 | 64 | `parameter\|VpiType\|KIND:parameter>constant` |
| 64 | 3 | 14 | 14 | `parameter\|VpiType\|KIND:parameter>operation` |
| 65 | 3 | 11 | 11 | `logic_typespec\|VpiName\|O-EXTRA-PREFIX` |
| 66 | 3 | 9 | 9 | `bit_select -> constant\|MISSING-OURS` |
| 67 | 3 | 8 | 8 | `class_defn -> +ref_var\|EXTRA-OURS` |
| 68 | 3 | 6 | 9 | `function\|Typespecs\|VEC:G>O` |
| 69 | 3 | 6 | 6 | `operation\|VpiType\|KIND:operation>constant` |
| 70 | 3 | 5 | 5 | `module_inst -> +ref_typespec\|EXTRA-OURS` |
| 71 | 3 | 4 | 4 | `module_inst\|Variables\|VEC:G>O` |
| 72 | 3 | 3 | 7 | `+package\|Typespecs\|VEC:G>O` |
| 73 | 3 | 3 | 3 | `design\|Typespecs\|VEC:G>O` |
| 74 | 3 | 3 | 3 | `hier_path\|VpiName\|O-EXTRA-SUFFIX` |
| 75 | 3 | 3 | 3 | `package -> +package\|EXTRA-OURS` |
| 76 | 3 | 3 | 3 | `package -> +string_var\|EXTRA-OURS` |
| 77 | 3 | 3 | 3 | `package\|Typespecs\|VEC:G>O` |
| 78 | 3 | 3 | 3 | `ref_obj -> +class_var\|EXTRA-OURS` |
| 79 | 3 | 3 | 3 | `ref_obj -> chandle_var\|MISSING-OURS` |
| 80 | 2 | 1330 | 1330 | `constant\|VpiType\|KIND:constant>ref_obj` |
| 81 | 2 | 54 | 54 | `bit_typespec\|VpiType\|KIND:bit_typespec>int_typespec` |
| 82 | 2 | 41 | 41 | `constant\|VpiDecompile\|O-EXTRA-PREFIX` |
| 83 | 2 | 16 | 16 | `constant\|VpiDecompile\|DIGITS-ONLY` |
| 84 | 2 | 12 | 12 | `constant\|VpiType\|KIND:constant>sys_func_call` |
| 85 | 2 | 8 | 8 | `constant\|VpiSize\|INT:G>O` |
| 86 | 2 | 6 | 6 | `hier_path\|Path_elems\|VEC:G>O` |
| 87 | 2 | 6 | 6 | `int_typespec\|VpiName\|O-EMPTY` |
| 88 | 2 | 4 | 4 | `function -> io_decl\|MISSING-OURS` |
| 89 | 2 | 4 | 4 | `if_stmt -> begin\|MISSING-OURS` |
| 90 | 2 | 4 | 4 | `logic_net\|VpiType\|KIND:logic_net>ref_var` |
| 91 | 2 | 2 | 5 | `package -> +int_var\|EXTRA-OURS` |
| 92 | 2 | 2 | 4 | `class_defn -> +enum_var\|EXTRA-OURS` |
| 93 | 2 | 2 | 2 | `array_var -> bit_var\|MISSING-OURS` |
| 94 | 2 | 2 | 2 | `array_var\|VpiType\|KIND:array_var>class_var` |
| 95 | 2 | 2 | 2 | `assignment -> +logic_net\|EXTRA-OURS` |
| 96 | 2 | 2 | 2 | `assignment -> bit_select\|MISSING-OURS` |
| 97 | 2 | 2 | 2 | `class_defn -> +logic_net\|EXTRA-OURS` |
| 98 | 2 | 2 | 2 | `class_defn -> +ref_typespec\|EXTRA-OURS` |
| 99 | 2 | 2 | 2 | `class_var\|VpiType\|KIND:class_var>io_decl` |
| 100 | 2 | 2 | 2 | `enum_typespec -> +package\|EXTRA-OURS` |
| 101 | 2 | 2 | 2 | `enum_var\|VpiType\|KIND:enum_var>class_var` |
| 102 | 2 | 2 | 2 | `function\|VpiMethod\|INT:G>O` |
| 103 | 2 | 2 | 2 | `hier_path\|VpiType\|KIND:hier_path>bit_select` |
| 104 | 2 | 2 | 2 | `int_var\|VpiType\|KIND:int_var>array_var` |
| 105 | 2 | 2 | 2 | `interface_inst -> +interface_inst\|EXTRA-OURS` |
| 106 | 2 | 2 | 2 | `logic_net\|VpiType\|KIND:logic_net>int_var` |
| 107 | 2 | 2 | 2 | `method_func_call -> +ref_var\|EXTRA-OURS` |
| 108 | 2 | 2 | 2 | `module_inst -> +module_inst\|EXTRA-OURS` |
| 109 | 2 | 2 | 2 | `module_inst\|Typespecs\|VEC:G>O` |
| 110 | 2 | 2 | 2 | `operation -> function\|MISSING-OURS` |
| 111 | 2 | 2 | 2 | `package -> +enum_var\|EXTRA-OURS` |
| 112 | 2 | 2 | 2 | `package\|VpiName\|TEXT-DIFF` |
| 113 | 2 | 2 | 2 | `struct_typespec\|VpiType\|KIND:struct_typespec>logic_typespec` |
| 114 | 2 | 2 | 2 | `unsupported_typespec\|VpiType\|KIND:unsupported_typespec>enum_typespec` |
| 115 | 1 | 1435 | 1435 | `hier_path -> ref_typespec\|MISSING-OURS` |
| 116 | 1 | 236 | 236 | `int_typespec\|VpiType\|KIND:int_typespec>integer_typespec` |
| 117 | 1 | 30 | 30 | `ref_obj -> logic_net\|MISSING-OURS` |
| 118 | 1 | 6 | 6 | `constant -> ref_typespec\|MISSING-OURS` |
| 119 | 1 | 4 | 4 | `module_inst -> +logic_var\|EXTRA-OURS` |
| 120 | 1 | 3 | 3 | `constant\|VpiDecompile\|O-EXTRA-SUFFIX` |
| 121 | 1 | 3 | 3 | `int_typespec\|VpiSigned\|INT:G>O` |
| 122 | 1 | 3 | 3 | `module_inst -> +logic_net\|EXTRA-OURS` |
| 123 | 1 | 3 | 3 | `param_assign\|VpiOverriden\|INT:G>O` |
| 124 | 1 | 2 | 21 | `ref_obj -> enum_const\|MISSING-OURS` |
| 125 | 1 | 2 | 2 | `constant\|VpiConstType\|INT:G>O` |
| 126 | 1 | 2 | 2 | `constant\|VpiDecompile\|G-EXTRA-PREFIX` |
| 127 | 1 | 2 | 2 | `constant\|VpiType\|KIND:constant>func_call` |
| 128 | 1 | 2 | 2 | `hier_path\|VpiSize\|INT:G<O` |
| 129 | 1 | 2 | 2 | `param_assign\|VpiOverriden\|INT:G<O` |
| 130 | 1 | 1 | 7 | `module_inst -> enum_const\|MISSING-OURS` |
| 131 | 1 | 1 | 1 | `class_defn -> +class_typespec\|EXTRA-OURS` |
| 132 | 1 | 1 | 1 | `int_typespec\|VpiType\|KIND:int_typespec>logic_typespec` |
| 133 | 1 | 1 | 1 | `logic_typespec -> package\|MISSING-OURS` |
| 134 | 1 | 1 | 1 | `logic_typespec\|VpiType\|KIND:logic_typespec>bit_typespec` |
| 135 | 1 | 1 | 1 | `module_inst\|Variables\|VEC:G<O` |
| 136 | 1 | 1 | 1 | `operation\|Operands\|VEC:G>O` |
| 137 | 1 | 1 | 1 | `operation\|VpiOpType\|INT:G<O` |
| 138 | 1 | 1 | 1 | `ref_obj -> +int_var\|EXTRA-OURS` |
| 139 | 1 | 1 | 1 | `ref_typespec -> class_typespec\|MISSING-OURS` |
| 140 | 1 | 1 | 1 | `ref_var -> +package\|EXTRA-OURS` |

### Example cells (up to 3 per family, in rank order)

**F1 `hier_path|VpiName|TEXT-DIFF`** — 98 distinct objects / 98 rungs in 9 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Rggen, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 46  (raw family `hier_path|VpiName|TEXT:m_streams[].exists|m_streams[ro.get_name()].exists`)
    - L(golden) `hier_path(m_streams[].exists)@uvm_pkg.sv:30163:48-30163:94#130233`
    - R(ours)   `hier_path(m_streams[ro.get_name()].exists)@:30163:48-30163:94#22414`
    - masked    `hier_path(m_streams[].exists)@uvm_pkg.sv:30163:48-30163:94#130233`
    - G= "m_streams[].exists"   O= "m_streams[ro.get_name()].exists"
  - `default_Earlgrey_0_1` rung 480  (raw family `hier_path|VpiName|TEXT:reg#hw.ctrl_en_input_filter.q[#]|reg#hw.ctrl_en_input_filter.q[i]`)
    - L(golden) `hier_path(reg2hw.ctrl_en_input_filter.q[0])@gpio.sv:40:17-40:49#338131`
    - R(ours)   `hier_path(reg2hw.ctrl_en_input_filter.q[i])@:40:17-40:49#280126`
    - masked    `hier_path(reg2hw.ctrl_en_input_filter.q[0])@gpio.sv:40:17-40:49#338131`
    - G= "reg2hw.ctrl_en_input_filter.q[0]"   O= "reg2hw.ctrl_en_input_filter.q[i]"
  - `default_Rggen` rung 42  (raw family `hier_path|VpiName|TEXT:register_if[#].value[#+:#]|register_if[#+#*i+#].value[# + # * l+:#]`)
    - L(golden) `hier_path(register_if[12].value[0+:1])@block_1.sv:356:42-356:78#259425`
    - R(ours)   `hier_path(register_if[6+7*i+6].value[0 + 1 * l+:1])@:356:42-356:78#172775`
    - masked    `hier_path(register_if[12].value[0+:1])@block_1.sv:356:42-356:78#259425`
    - G= "register_if[12].value[0+:1]"   O= "register_if[6+7*i+6].value[0 + 1 * l+:1]"

**F2 `constant|VpiDecompile|TEXT-DIFF`** — 83 distinct objects / 83 rungs in 9 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Rggen, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 256  (raw family `constant|VpiDecompile|TEXT:#|"."`)
    - L(golden) `constant@uvm_pkg.sv:41024:43-41024:43#82426`
    - R(ours)   `constant@:19941:74-19941:77#139880`
    - masked    `constant@uvm_pkg.sv:41024:43-41024:43#82426`
    - G= "0"   O= "".""
  - `default_Earlgrey_0_1` rung 1  (raw family `constant|VpiDecompile|TEXT:-#|#'b#`)
    - L(golden) `constant@rv_core_ibex.sv:67:29-67:51#242693`
    - R(ours)   `constant@:67:29-67:51#190781`
    - masked    `constant@rv_core_ibex.sv:67:29-67:51#242693`
    - G= "-1"   O= "1'b1"
  - `default_Rggen` rung 16  (raw family `constant|VpiDecompile|TEXT:#'hab|#`)
    - L(golden) `constant@block_0.sv:468:30-468:43#36546`
    - R(ours)   `constant@:468:30-468:43#28596`
    - masked    `constant@block_0.sv:468:30-468:43#36546`
    - G= "8'hab"   O= "171"

**F3 `constant|VpiType|KIND:constant>operation`** — 29 distinct objects / 29 rungs in 9 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Rggen, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 96  (raw family `constant|VpiType|KIND:constant>operation`)
    - L(golden) `constant@uvm_pkg.sv:32186:23-32186:24#12770`
    - R(ours)   `operation@:32186:23-32186:25#116289`
    - masked    `constant@uvm_pkg.sv:32186:23-32186:24#12770`
    - G= constant   O= operation
  - `default_Earlgrey_0_1` rung 26  (raw family `constant|VpiType|KIND:constant>operation`)
    - L(golden) `constant@tlul_fifo_sync.sv:76:69-76:91#287749`
    - R(ours)   `operation@:76:69-76:91#233079`
    - masked    `constant@tlul_fifo_sync.sv:76:69-76:91#287749`
    - G= constant   O= operation
  - `default_Rggen` rung 13  (raw family `constant|VpiType|KIND:constant>operation`)
    - L(golden) `constant@:0:0-0:0#353520`
    - R(ours)   `operation@:68:29-68:78#10621`
    - masked    `constant@:0:0-0:0#353520`
    - G= constant   O= operation

**F4 `ref_obj|VpiType|KIND:ref_obj>constant`** — 94 distinct objects / 94 rungs in 8 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 2  (raw family `ref_obj|VpiType|KIND:ref_obj>constant`)
    - L(golden) `ref_obj(original_type)@uvm_pkg.sv:12509:31-12509:44#5905`
    - R(ours)   `constant@:12370:39-12370:41#19245`
    - masked    `method_func_call(new)@:0:0-0:0#5904  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_obj   O= constant
  - `default_Earlgrey_0_1` rung 72  (raw family `ref_obj|VpiType|KIND:ref_obj>constant`)
    - L(golden) `ref_obj(PTRV_W)@prim_fifo_sync.sv:70:38-70:44#291403`
    - R(ours)   `constant@:70:38-70:44#235716`
    - masked    `indexed_part_select(fifo_wptr)@prim_fifo_sync.sv:70:35-70:44#291401`
    - G= ref_obj   O= constant
  - `default_Scoreboard` rung 55  (raw family `ref_obj|VpiType|KIND:ref_obj>constant`)
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:984:31-984:44#4791`
    - R(ours)   `constant@:986:36-986:39#19163`
    - masked    `method_func_call(new)@:0:0-0:0#4790  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_obj   O= constant

**F5 `constant|VpiConstType|INT:G<O`** — 9 distinct objects / 9 rungs in 8 row(s): default_BuildUVMPkg, default_Earlgrey_0_1, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 47  (raw family `constant|VpiConstType|INT:G<O`)
    - L(golden) `constant@uvm_pkg.sv:30186:82-30186:82#130323`
    - R(ours)   `constant@:24157:58-24157:59#22497`
    - masked    `constant@uvm_pkg.sv:30186:82-30186:82#130323`
    - G= 7   O= 9
  - `default_Earlgrey_0_1` rung 232  (raw family `constant|VpiConstType|INT:G<O`)
    - L(golden) `constant@prim_fifo_sync.sv:72:53-72:58#989528`
    - R(ours)   `constant@:72:53-72:58#250235`
    - masked    `constant@prim_fifo_sync.sv:72:53-72:58#989528`
    - G= 7   O= 9
  - `default_Scoreboard` rung 37  (raw family `constant|VpiConstType|INT:G<O`)
    - L(golden) `constant@uvm_report_server.svh:689:82-689:82#129983`
    - R(ours)   `constant@:321:58-321:59#22252`
    - masked    `constant@uvm_report_server.svh:689:82-689:82#129983`
    - G= 7   O= 9

**F6 `sys_func_call|VpiType|KIND:sys_func_call>constant`** — 170 distinct objects / 170 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 163  (raw family `sys_func_call|VpiType|KIND:sys_func_call>constant`)
    - L(golden) `sys_func_call($bits)@uvm_pkg.sv:22229:36-22229:41#70900`
    - R(ours)   `constant@:22229:36-22229:47#130630`
    - masked    `sys_func_call($bits)@uvm_pkg.sv:22229:36-22229:41#70900`
    - G= sys_func_call   O= constant
  - `default_Scoreboard` rung 128  (raw family `sys_func_call|VpiType|KIND:sys_func_call>constant`)
    - L(golden) `sys_func_call($bits)@uvm_packer.svh:731:34-731:39#69195`
    - R(ours)   `constant@:731:34-731:45#132130`
    - masked    `sys_func_call($bits)@uvm_packer.svh:731:34-731:39#69195`
    - G= sys_func_call   O= constant
  - `default_SeqDriver` rung 361  (raw family `sys_func_call|VpiType|KIND:sys_func_call>constant`)
    - L(golden) `sys_func_call($bits)@uvm_packer.svh:731:34-731:39#69195`
    - R(ours)   `constant@:731:34-731:45#134744`
    - masked    `sys_func_call($bits)@uvm_packer.svh:731:34-731:39#69195`
    - G= sys_func_call   O= constant

**F7 `func_call -> function|MISSING-OURS`** — 69 distinct objects / 94 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 13  (raw family `function|<rhs-null>|MISSING-OURS`)
    - L(golden) `function(get_recursion_policy)@uvm_pkg.sv:21000:3-21000:9#125962`
    - R(ours)   `<null>`
    - masked    `func_call(get_recursion_policy)@uvm_pkg.sv:21396:49-21396:71#126572  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 25  (raw family `function|<rhs-null>|MISSING-OURS`)
    - L(golden) `function(print_field)@uvm_printer.svh:102:3-102:9#145835`
    - R(ours)   `<null>`
    - masked    `func_call(print_field)@uvm_printer.svh:116:5-116:71#145883  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 27  (raw family `function|<rhs-null>|MISSING-OURS`)
    - L(golden) `function(set_severity_count)@uvm_report_server.svh:76:9-76:21#296189`
    - R(ours)   `<null>`
    - masked    `func_call(set_severity_count)@uvm_report_server.svh:120:33-120:87#296290  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F8 `assignment -> +class_var|EXTRA-OURS`** — 66 distinct objects / 66 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 87  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(build_ph)@:35319:11-35319:19#3356`
    - masked    `assignment@uvm_pkg.sv:35394:5-35394:65#130979  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 11  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(build_ph)@:46:11-46:19#3766`
    - masked    `assignment@uvm_domain.svh:122:5-122:65#130760  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 49  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(build_ph)@:46:11-46:19#6380`
    - masked    `assignment@uvm_domain.svh:122:5-122:65#261204  [bisected]`
    - G= -   O= -

**F9 `parameter -> +ref_typespec|EXTRA-OURS`** — 58 distinct objects / 82 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 108  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#28`
    - masked    `parameter(UVM_RADIX)@uvm_pkg.sv:7897:11-7897:20#61436  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 89  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#204`
    - masked    `parameter(UVM_RADIX)@uvm_object_globals.svh:99:11-99:20#60967  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 67  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#6114`
    - masked    `parameter(UVM_ALL_ON)@uvm_object_globals.svh:181:11-181:21#248577  [bisected]`
    - G= -   O= -

**F10 `ref_obj|VpiType|KIND:ref_obj>hier_path`** — 54 distinct objects / 54 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 4  (raw family `ref_obj|VpiType|KIND:ref_obj>hier_path`)
    - L(golden) `ref_obj(original_type)@uvm_pkg.sv:12657:29-12657:42#6234`
    - R(ours)   `hier_path(original_type.get_type_name)@:12658:34-12658:63#19566`
    - masked    `method_func_call(new)@:0:0-0:0#6232  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_obj   O= hier_path
  - `default_Scoreboard` rung 57  (raw family `ref_obj|VpiType|KIND:ref_obj>hier_path`)
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:1114:29-1114:42#5115`
    - R(ours)   `hier_path(original_type.get_type_name)@:1115:34-1115:63#19477`
    - masked    `method_func_call(new)@:0:0-0:0#5113  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_obj   O= hier_path
  - `default_SeqDriver` rung 16  (raw family `ref_obj|VpiType|KIND:ref_obj>hier_path`)
    - L(golden) `ref_obj(original_type)@uvm_factory.svh:1114:29-1114:42#5115`
    - R(ours)   `hier_path(original_type.get_type_name)@:1115:34-1115:63#22091`
    - masked    `method_func_call(new)@:0:0-0:0#5113  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_obj   O= hier_path

**F11 `ref_obj|VpiName|O-EXTRA-SUFFIX`** — 52 distinct objects / 52 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 5  (raw family `ref_obj|VpiName|O-EXTRA-SUFFIX(_name)`)
    - L(golden) `ref_obj(original_type)@uvm_pkg.sv:12700:29-12700:42#6301`
    - R(ours)   `ref_obj(original_type_name)@:12701:34-12701:52#19628`
    - masked    `ref_obj(original_type)@uvm_pkg.sv:12700:29-12700:42#6301  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "original_type"   O= "original_type_name"
  - `default_Scoreboard` rung 54  (raw family `ref_obj|VpiName|O-EXTRA-SUFFIX([obj])`)
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:919:13-919:35#4600`
    - R(ours)   `ref_obj(m_inst_override_queues[obj])@:919:13-919:40#18975`
    - masked    `ref_obj(m_inst_override_queues)@uvm_factory.svh:919:13-919:35#4600`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[obj]"
  - `default_SeqDriver` rung 13  (raw family `ref_obj|VpiName|O-EXTRA-SUFFIX([obj])`)
    - L(golden) `ref_obj(m_inst_override_queues)@uvm_factory.svh:919:13-919:35#4600`
    - R(ours)   `ref_obj(m_inst_override_queues[obj])@:919:13-919:40#21589`
    - masked    `ref_obj(m_inst_override_queues)@uvm_factory.svh:919:13-919:35#4600`
    - G= "m_inst_override_queues"   O= "m_inst_override_queues[obj]"

**F12 `ref_obj -> +enum_const|EXTRA-OURS`** — 35 distinct objects / 65 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 58  (raw family `+enum_const|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_ERROR)@:8053:3-8053:12#310`
    - masked    `ref_obj(UVM_ERROR)@uvm_pkg.sv:31245:80-31245:89#165281  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 39  (raw family `+enum_const|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_ERROR)@:246:3-246:12#464`
    - masked    `ref_obj(UVM_ERROR)@uvm_report_object.svh:132:80-132:89#165039  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 39  (raw family `+enum_const|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_ERROR)@:246:3-246:12#456`
    - masked    `ref_obj(UVM_ERROR)@uvm_report_object.svh:132:80-132:89#295483  [bisected]`
    - G= -   O= -

**F13 `method_func_call -> method_func_call|MISSING-OURS`** — 30 distinct objects / 30 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 234  (raw family `method_func_call|<rhs-null>|MISSING-OURS`)
    - L(golden) `method_func_call(super.new)@:0:0-0:0#121216`
    - R(ours)   `<null>`
    - masked    `method_func_call(super.new)@:0:0-0:0#121216`
    - G= -   O= -
  - `default_Scoreboard` rung 170  (raw family `method_func_call|<rhs-null>|MISSING-OURS`)
    - L(golden) `method_func_call(super.new)@:0:0-0:0#121504`
    - R(ours)   `<null>`
    - masked    `method_func_call(super.new)@:0:0-0:0#121504`
    - G= -   O= -
  - `default_SeqDriver` rung 281  (raw family `method_func_call|<rhs-null>|MISSING-OURS`)
    - L(golden) `method_func_call(super.new)@:0:0-0:0#276769`
    - R(ours)   `<null>`
    - masked    `method_func_call(super.new)@:0:0-0:0#276769`
    - G= -   O= -

**F14 `class_typespec|VpiName|O-EMPTY`** — 29 distinct objects / 29 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 212  (raw family `class_typespec|VpiName|O-EMPTY`)
    - L(golden) `class_typespec(uvm_pkg::uvm_event_pool)@uvm_pkg.sv:14624:9-14624:31#186097`
    - R(ours)   `class_typespec@:32177:10-32177:24#132142`
    - masked    `class_typespec(uvm_pkg::uvm_event_pool)@uvm_pkg.sv:14624:9-14624:31#186097  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg::uvm_event_pool"   O= 0
  - `default_Scoreboard` rung 144  (raw family `class_typespec|VpiName|O-EMPTY`)
    - L(golden) `class_typespec(uvm_pkg::uvm_event_pool)@uvm_pool.svh:344:9-344:31#188221`
    - R(ours)   `class_typespec@:520:10-520:24#133056`
    - masked    `class_typespec(uvm_pkg::uvm_event_pool)@uvm_pool.svh:344:9-344:31#188221  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg::uvm_event_pool"   O= 0
  - `default_SeqDriver` rung 377  (raw family `class_typespec|VpiName|O-EMPTY`)
    - L(golden) `class_typespec(uvm_pkg::uvm_event_pool)@uvm_pool.svh:344:9-344:31#317725`
    - R(ours)   `class_typespec@:520:10-520:24#135670`
    - masked    `class_typespec(uvm_pkg::uvm_event_pool)@uvm_pool.svh:344:9-344:31#317725  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg::uvm_event_pool"   O= 0

**F15 `ref_obj -> io_decl|MISSING-OURS`** — 26 distinct objects / 26 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 37  (raw family `io_decl|<rhs-null>|MISSING-OURS`)
    - L(golden) `io_decl(lhs)@uvm_pkg.sv:23219:62-23219:65#125009`
    - R(ours)   `<null>`
    - masked    `ref_obj(lhs)@uvm_pkg.sv:23233:20-23233:23#125056  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 23  (raw family `io_decl|<rhs-null>|MISSING-OURS`)
    - L(golden) `io_decl(l_sequencer)@uvm_sequence_base.svh:940:71-940:82#170732`
    - R(ours)   `<null>`
    - masked    `ref_obj(l_sequencer)@uvm_sequence_base.svh:946:40-946:51#170766  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 34  (raw family `io_decl|<rhs-null>|MISSING-OURS`)
    - L(golden) `io_decl(severity)@uvm_report_server.svh:458:50-458:58#260008`
    - R(ours)   `<null>`
    - masked    `ref_obj(severity)@uvm_report_server.svh:459:22-459:30#260010  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F16 `class_typespec|VpiName|TEXT-DIFF`** — 25 distinct objects / 25 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 36  (raw family `class_typespec|VpiName|TEXT:uvm_component|STRUCTURE`)
    - L(golden) `class_typespec(uvm_component)@uvm_pkg.sv:43513:70-43513:79#174452`
    - R(ours)   `class_typespec(STRUCTURE)@:43560:76-43560:85#106446`
    - masked    `class_typespec(uvm_component)@uvm_pkg.sv:43513:70-43513:79#174452  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_component"   O= "STRUCTURE"
  - `default_Scoreboard` rung 7  (raw family `class_typespec|VpiName|TEXT:rsp_type|uvm_sequence_item`)
    - L(golden) `class_typespec(rsp_type)@uvm_sequencer_param_base.svh:211:58-211:61#173009`
    - R(ours)   `class_typespec(uvm_sequence_item)@:0:0-0:0#104711`
    - masked    `class_typespec(rsp_type)@uvm_sequencer_param_base.svh:211:58-211:61#173009  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "rsp_type"   O= "uvm_sequence_item"
  - `default_SeqDriver` rung 7  (raw family `class_typespec|VpiName|TEXT:rsp_type|uvm_sequence_item`)
    - L(golden) `class_typespec(rsp_type)@uvm_sequencer_param_base.svh:211:58-211:61#303453`
    - R(ours)   `class_typespec(uvm_sequence_item)@:0:0-0:0#107325`
    - masked    `class_typespec(rsp_type)@uvm_sequencer_param_base.svh:211:58-211:61#303453  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "rsp_type"   O= "uvm_sequence_item"

**F17 `param_assign -> +int_typespec|EXTRA-OURS`** — 22 distinct objects / 22 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 138  (raw family `+int_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_typespec@:7897:1-7897:32#32`
    - masked    `param_assign@uvm_pkg.sv:7897:11-7897:32#61439  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 94  (raw family `+int_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_typespec@:99:1-99:32#208`
    - masked    `param_assign@uvm_object_globals.svh:99:11-99:32#60970  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 289  (raw family `+int_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_typespec@:99:1-99:32#200`
    - masked    `param_assign@uvm_object_globals.svh:99:11-99:32#60970  [bisected]`
    - G= -   O= -

**F18 `bit_typespec -> ref_typespec|MISSING-OURS`** — 19 distinct objects / 19 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 11  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#1710`
    - R(ours)   `<null>`
    - masked    `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49#1706  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 106  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#87273`
    - R(ours)   `<null>`
    - masked    `bit_typespec(uvm_reg_cvr_t)@uvm_reg_model.svh:105:10-105:22#87267  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 293  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#87273`
    - R(ours)   `<null>`
    - masked    `bit_typespec(uvm_reg_cvr_t)@uvm_reg_model.svh:105:10-105:22#87267  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F19 `ref_obj -> ref_typespec|MISSING-OURS`** — 17 distinct objects / 17 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 8  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#4528`
    - R(ours)   `<null>`
    - masked    `ref_obj(s)@uvm_pkg.sv:9737:24-9737:25#4525  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 46  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#1403`
    - R(ours)   `<null>`
    - masked    `ref_obj(init)@uvm_svcmd_dpi.svh:32:33-32:37#1401  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 11  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#22985`
    - R(ours)   `<null>`
    - masked    `ref_obj(s)@uvm_globals.svh:403:24-403:25#22982  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F20 `method_func_call -> +int_var|EXTRA-OURS`** — 16 distinct objects / 16 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 164  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:22227:8-22227:10#130617`
    - masked    `method_func_call(new)@uvm_pkg.sv:22232:13-22232:20#70914  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 126  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:485:7-485:9#131337`
    - masked    `method_func_call(new)@uvm_packer.svh:488:11-488:18#68417  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 359  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:485:7-485:9#133951`
    - masked    `method_func_call(new)@uvm_packer.svh:488:11-488:18#68417  [bisected]`
    - G= -   O= -

**F21 `method_func_call|VpiName|TEXT-DIFF`** — 16 distinct objects / 16 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 231  (raw family `method_func_call|VpiName|TEXT:delete|get_name()]`)
    - L(golden) `method_func_call(delete)@uvm_pkg.sv:40593:33-40593:39#81524`
    - R(ours)   `method_func_call(get_name()])@:40593:21-40593:32#139013`
    - masked    `method_func_call(delete)@uvm_pkg.sv:40593:33-40593:39#81524`
    - G= "delete"   O= "get_name()]"
  - `default_Scoreboard` rung 4  (raw family `method_func_call|VpiName|TEXT:this|sequences`)
    - L(golden) `method_func_call(this)@uvm_sequencer_base.svh:1578:12-1578:21#25797`
    - R(ours)   `method_func_call(sequences)@:1578:12-1578:21#104260`
    - masked    `method_func_call(this)@uvm_sequencer_base.svh:1578:12-1578:21#25797  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "this"   O= "sequences"
  - `default_SeqDriver` rung 4  (raw family `method_func_call|VpiName|TEXT:this|sequences`)
    - L(golden) `method_func_call(this)@uvm_sequencer_base.svh:1578:12-1578:21#25797`
    - R(ours)   `method_func_call(sequences)@:1578:12-1578:21#106874`
    - masked    `method_func_call(this)@uvm_sequencer_base.svh:1578:12-1578:21#25797  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "this"   O= "sequences"

**F22 `ref_obj -> class_var|MISSING-OURS`** — 15 distinct objects / 15 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 241  (raw family `class_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `class_var(i)@uvm_pkg.sv:56509:22-56509:23#192239`
    - R(ours)   `<null>`
    - masked    `ref_obj(i)@uvm_pkg.sv:56510:37-56510:38#26825  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 180  (raw family `class_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `class_var(i)@uvm_sequence_library.svh:431:22-431:23#195138`
    - R(ours)   `<null>`
    - masked    `ref_obj(i)@uvm_sequence_library.svh:432:37-432:38#26898  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 163  (raw family `class_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `class_var(waiter)@uvm_config_db.svh:273:18-273:24#259078`
    - R(ours)   `<null>`
    - masked    `ref_obj(waiter)@uvm_config_db.svh:294:6-294:20#259144`
    - G= -   O= -

**F23 `function|VpiName|G-EXTRA-PREFIX`** — 13 distinct objects / 13 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 150  (raw family `function|VpiName|G-EXTRA-PREFIX(uvm_root::)`)
    - L(golden) `function(uvm_root::get)@uvm_pkg.sv:38754:1-38757:12#60621`
    - R(ours)   `function(get)@:38754:1-38757:12#94875`
    - masked    `function(uvm_root::get)@uvm_pkg.sv:38754:1-38757:12#60621  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_root::get"   O= "get"
  - `default_Scoreboard` rung 87  (raw family `function|VpiName|G-EXTRA-PREFIX(uvm_root::)`)
    - L(golden) `function(uvm_root::get)@uvm_root.svh:324:1-327:12#60048`
    - R(ours)   `function(get)@:324:1-327:12#93985`
    - masked    `function(uvm_root::get)@uvm_root.svh:324:1-327:12#60048  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_root::get"   O= "get"
  - `default_SeqDriver` rung 167  (raw family `function|VpiName|G-EXTRA-PREFIX(uvm_root::)`)
    - L(golden) `function(uvm_root::get)@uvm_root.svh:324:1-327:12#198544`
    - R(ours)   `function(get)@:324:1-327:12#96599`
    - masked    `function(uvm_root::get)@uvm_root.svh:324:1-327:12#198544  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_root::get"   O= "get"

**F24 `ref_obj|VpiName|G-EXTRA-SUFFIX`** — 12 distinct objects / 12 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 6  (raw family `ref_obj|VpiName|G-EXTRA-SUFFIX(_name)`)
    - L(golden) `ref_obj(original_type_name)@uvm_pkg.sv:12701:34-12701:52#6302`
    - R(ours)   `ref_obj(original_type)@:12700:29-12700:42#19629`
    - masked    `ref_obj(original_type_name)@uvm_pkg.sv:12701:34-12701:52#6302  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "original_type_name"   O= "original_type"
  - `default_Scoreboard` rung 60  (raw family `ref_obj|VpiName|G-EXTRA-SUFFIX(_name)`)
    - L(golden) `ref_obj(original_type_name)@uvm_factory.svh:1154:34-1154:52#5197`
    - R(ours)   `ref_obj(original_type)@:1153:29-1153:42#19554`
    - masked    `ref_obj(original_type_name)@uvm_factory.svh:1154:34-1154:52#5197  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "original_type_name"   O= "original_type"
  - `default_SeqDriver` rung 19  (raw family `ref_obj|VpiName|G-EXTRA-SUFFIX(_name)`)
    - L(golden) `ref_obj(original_type_name)@uvm_factory.svh:1154:34-1154:52#5197`
    - R(ours)   `ref_obj(original_type)@:1153:29-1153:42#22168`
    - masked    `ref_obj(original_type_name)@uvm_factory.svh:1154:34-1154:52#5197  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "original_type_name"   O= "original_type"

**F25 `class_defn -> +io_decl|EXTRA-OURS`** — 11 distinct objects / 11 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 57  (raw family `+io_decl|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `io_decl(action)@:30797:51-30797:57#88678`
    - masked    `class_defn(uvm_report_handler)@uvm_pkg.sv:30476:1-31097:30#85  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 38  (raw family `+io_decl|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `io_decl(action)@:347:51-347:57#87541`
    - masked    `class_defn(uvm_report_handler)@uvm_report_handler.svh:55:1-797:30#77  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 38  (raw family `+io_decl|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `io_decl(action)@:347:51-347:57#90155`
    - masked    `class_defn(uvm_report_handler)@uvm_report_handler.svh:55:1-797:30#77  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F26 `class_defn -> +int_var|EXTRA-OURS`** — 10 distinct objects / 19 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 43  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:22227:8-22227:10#42203`
    - masked    `class_defn(uvm_packer)@uvm_pkg.sv:21680:1-22099:9#51  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 26  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(sz)@:485:7-485:9#42298`
    - masked    `class_defn(uvm_packer)@uvm_packer.svh:39:1-400:9#43  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 283  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:22:11-22:41#6431`
    - masked    `class_defn(uvm_domain)@uvm_domain.svh:65:1-218:9#83  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F27 `delay_control -> ref_obj|MISSING-OURS`** — 10 distinct objects / 10 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 225  (raw family `ref_obj|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_obj@uvm_pkg.sv:34198:21-34198:38#75498`
    - R(ours)   `<null>`
    - masked    `delay_control@uvm_pkg.sv:34198:19-34198:39#75497`
    - G= -   O= -
  - `default_Scoreboard` rung 156  (raw family `ref_obj|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_obj@uvm_phase.svh:1475:21-1475:38#72776`
    - R(ours)   `<null>`
    - masked    `delay_control@uvm_phase.svh:1475:19-1475:39#72775`
    - G= -   O= -
  - `default_SeqDriver` rung 298  (raw family `ref_obj|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_obj@uvm_objection.svh:751:11-751:28#272151`
    - R(ours)   `<null>`
    - masked    `delay_control@uvm_objection.svh:751:9-751:29#272150`
    - G= -   O= -

**F28 `named_fork|VpiJoinType|INT:G>O`** — 10 distinct objects / 10 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 223  (raw family `named_fork|VpiJoinType|INT:G>O`)
    - L(golden) `named_fork(master_phase_process)@uvm_pkg.sv:34061:9-34074:18#75220`
    - R(ours)   `named_fork(master_phase_process)@:34061:16-34061:36#134813`
    - masked    `named_fork(master_phase_process)@uvm_pkg.sv:34061:9-34074:18#75220  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 1   O= 0
  - `default_Scoreboard` rung 155  (raw family `named_fork|VpiJoinType|INT:G>O`)
    - L(golden) `named_fork(master_phase_process)@uvm_phase.svh:1400:9-1413:18#72506`
    - R(ours)   `named_fork(master_phase_process)@:1400:16-1400:36#135362`
    - masked    `named_fork(master_phase_process)@uvm_phase.svh:1400:9-1413:18#72506  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 1   O= 0
  - `default_SeqDriver` rung 297  (raw family `named_fork|VpiJoinType|INT:G>O`)
    - L(golden) `named_fork(guard)@uvm_objection.svh:702:11-733:28#272050`
    - R(ours)   `named_fork(guard)@:702:18-702:23#43457`
    - masked    `named_fork(guard)@uvm_objection.svh:702:11-733:28#272050  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 1   O= 0

**F29 `bit_select|VpiType|KIND:bit_select>bit_var`** — 8 distinct objects / 8 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 145  (raw family `bit_select|VpiType|KIND:bit_select>bit_var`)
    - L(golden) `bit_select(crc1)@uvm_pkg.sv:8655:12-8655:19#62924`
    - R(ours)   `bit_var(crc1)@:8641:16-8641:20#1003`
    - masked    `bit_select(crc1)@uvm_pkg.sv:8655:12-8655:19#62924`
    - G= bit_select   O= bit_var
  - `default_Scoreboard` rung 72  (raw family `bit_select|VpiType|KIND:bit_select>bit_var`)
    - L(golden) `bit_select(crc1)@uvm_misc.svh:386:12-386:19#2601`
    - R(ours)   `bit_var(crc1)@:372:16-372:20#4152`
    - masked    `bit_select(crc1)@uvm_misc.svh:386:12-386:19#2601`
    - G= bit_select   O= bit_var
  - `default_SeqDriver` rung 336  (raw family `bit_select|VpiType|KIND:bit_select>bit_var`)
    - L(golden) `bit_select(crc1)@uvm_misc.svh:386:12-386:19#61787`
    - R(ours)   `bit_var(crc1)@:372:16-372:20#1188`
    - masked    `bit_select(crc1)@uvm_misc.svh:386:12-386:19#61787`
    - G= bit_select   O= bit_var

**F30 `class_defn -> +string_var|EXTRA-OURS`** — 7 distinct objects / 60 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 83  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_error_id)@:45031:14-45031:56#3406`
    - masked    `class_defn(uvm_report_message)@uvm_pkg.sv:28318:1-28838:9#80  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 10  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_error_id)@:23:14-23:56#3822`
    - masked    `class_defn(uvm_phase)@uvm_phase.svh:134:1-660:9#80  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 10  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_error_id)@:23:14-23:56#6436`
    - masked    `class_defn(uvm_status_container)@uvm_misc.svh:206:1-305:9#6  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F31 `class_defn -> +enum_const|EXTRA-OURS`** — 7 distinct objects / 28 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 64  (raw family `+enum_const|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_MEDIUM)@:8109:3-8109:19#325`
    - masked    `class_defn(uvm_object)@uvm_pkg.sv:10037:9-10830:9#7  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 45  (raw family `+enum_const|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_MEDIUM)@:306:3-306:19#490`
    - masked    `class_defn(uvm_report_object)@uvm_report_object.svh:81:1-656:9#78  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 45  (raw family `+enum_const|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_const(UVM_MEDIUM)@:306:3-306:19#482`
    - masked    `class_defn(uvm_object)@uvm_object.svh:46:9-788:9#9  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F32 `enum_typespec|VpiName|G-EXTRA-SUFFIX`** — 7 distinct objects / 7 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 99  (raw family `enum_typespec|VpiName|G-EXTRA-SUFFIX(_enum)`)
    - L(golden) `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_pkg.sv:8200:1-8211:22#2835`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_sequence_state)@:8200:1-8211:22#3052`
    - masked    `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_pkg.sv:8200:1-8211:22#2835  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg::uvm_sequence_state_enum"   O= "uvm_pkg::uvm_sequence_state"
  - `default_Scoreboard` rung 21  (raw family `enum_typespec|VpiName|G-EXTRA-SUFFIX(_enum)`)
    - L(golden) `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_object_globals.svh:399:1-410:22#2346`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_sequence_state)@:399:1-410:22#3440`
    - masked    `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_object_globals.svh:399:1-410:22#2346  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg::uvm_sequence_state_enum"   O= "uvm_pkg::uvm_sequence_state"
  - `default_SeqDriver` rung 59  (raw family `enum_typespec|VpiName|G-EXTRA-SUFFIX(_enum)`)
    - L(golden) `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_object_globals.svh:399:1-410:22#2346`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_sequence_state)@:399:1-410:22#3423`
    - masked    `enum_typespec(uvm_pkg::uvm_sequence_state_enum)@uvm_object_globals.svh:399:1-410:22#2346  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg::uvm_sequence_state_enum"   O= "uvm_pkg::uvm_sequence_state"

**F33 `function -> +int_var|EXTRA-OURS`** — 7 distinct objects / 7 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 82  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:45030:11-45030:41#3401`
    - masked    `function(is_unbounded)@uvm_pkg.sv:45365:3-45367:14#144793  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 9  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:22:11-22:41#3817`
    - masked    `function(is_unbounded)@uvm_port_base.svh:331:3-333:14#144343  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 9  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:22:11-22:41#6431`
    - masked    `function(is_unbounded)@uvm_port_base.svh:331:3-333:14#274787  [bisected]`
    - G= -   O= -

**F34 `if_stmt -> +string_var|EXTRA-OURS`** — 7 distinct objects / 7 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 81  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_warning_id)@:45032:14-45032:60#3410`
    - masked    `if_stmt@uvm_pkg.sv:45269:5-45270:75#144726  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 8  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_warning_id)@:24:14-24:60#3826`
    - masked    `if_stmt@uvm_port_base.svh:244:5-245:75#144276  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 8  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_warning_id)@:24:14-24:60#6440`
    - masked    `if_stmt@uvm_port_base.svh:244:5-245:75#274720  [bisected]`
    - G= -   O= -

**F35 `ref_obj -> logic_var|MISSING-OURS`** — 7 distinct objects / 7 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 101  (raw family `logic_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `logic_var(e)@uvm_pkg.sv:55336:11-55336:12#170811`
    - R(ours)   `<null>`
    - masked    `ref_obj(e)@uvm_pkg.sv:55341:6-55341:7#170826`
    - G= -   O= -
  - `default_Scoreboard` rung 22  (raw family `logic_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `logic_var(e)@uvm_sequence_base.svh:757:11-757:12#170544`
    - R(ours)   `<null>`
    - masked    `ref_obj(e)@uvm_sequence_base.svh:762:6-762:7#170559`
    - G= -   O= -
  - `default_SeqDriver` rung 60  (raw family `logic_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `logic_var(e)@uvm_sequence_base.svh:757:11-757:12#300988`
    - R(ours)   `<null>`
    - masked    `ref_obj(e)@uvm_sequence_base.svh:762:6-762:7#301003`
    - G= -   O= -

**F36 `ref_obj|VpiType|KIND:ref_obj>operation`** — 7 distinct objects / 7 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 95  (raw family `ref_obj|VpiType|KIND:ref_obj>operation`)
    - L(golden) `ref_obj(UVM_PHASE_STARTED)@uvm_pkg.sv:35470:64-35470:81#131176`
    - R(ours)   `operation@:35470:63-35470:100#23337`
    - masked    `operation@uvm_pkg.sv:35470:38-35470:101#131175`
    - G= ref_obj   O= operation
  - `default_Scoreboard` rung 19  (raw family `ref_obj|VpiType|KIND:ref_obj>operation`)
    - L(golden) `ref_obj(UVM_PHASE_STARTED)@uvm_domain.svh:199:64-199:81#130958`
    - R(ours)   `operation@:199:63-199:100#23206`
    - masked    `operation@uvm_domain.svh:199:38-199:101#130957`
    - G= ref_obj   O= operation
  - `default_SeqDriver` rung 57  (raw family `ref_obj|VpiType|KIND:ref_obj>operation`)
    - L(golden) `ref_obj(UVM_PHASE_STARTED)@uvm_domain.svh:199:64-199:81#261402`
    - R(ours)   `operation@:199:63-199:100#25820`
    - masked    `operation@uvm_domain.svh:199:38-199:101#261401`
    - G= ref_obj   O= operation

**F37 `ref_var|VpiType|KIND:ref_var>logic_var`** — 7 distinct objects / 7 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 45  (raw family `ref_var|VpiType|KIND:ref_var>logic_var`)
    - L(golden) `ref_var@uvm_pkg.sv:28181:20-28181:36#164670`
    - R(ours)   `logic_var@:28181:20-28181:36#90098`
    - masked    `ref_var@uvm_pkg.sv:28181:20-28181:36#164670`
    - G= ref_var   O= logic_var
  - `default_Scoreboard` rung 33  (raw family `ref_var|VpiType|KIND:ref_var>logic_var`)
    - L(golden) `ref_var@uvm_report_message.svh:338:20-338:36#164430`
    - R(ours)   `logic_var@:338:20-338:36#89520`
    - masked    `ref_var@uvm_report_message.svh:338:20-338:36#164430`
    - G= ref_var   O= logic_var
  - `default_SeqDriver` rung 32  (raw family `ref_var|VpiType|KIND:ref_var>logic_var`)
    - L(golden) `ref_var@uvm_report_message.svh:338:20-338:36#294874`
    - R(ours)   `logic_var@:338:20-338:36#92134`
    - masked    `ref_var@uvm_report_message.svh:338:20-338:36#294874`
    - G= ref_var   O= logic_var

**F38 `string_var|VpiType|KIND:string_var>io_decl`** — 7 distinct objects / 7 rungs in 7 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 77  (raw family `string_var|VpiType|KIND:string_var>io_decl`)
    - L(golden) `string_var(val)@uvm_pkg.sv:33189:12-33189:15#186633`
    - R(ours)   `io_decl(val)@:53459:68-53459:71#103823`
    - masked    `string_var(val)@uvm_pkg.sv:33189:12-33189:15#186633  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= string_var   O= io_decl
  - `default_Scoreboard` rung 1  (raw family `string_var|VpiType|KIND:string_var>io_decl`)
    - L(golden) `string_var(val)@uvm_phase.svh:802:12-802:15#188738`
    - R(ours)   `io_decl(val)@:1381:68-1381:71#103779`
    - masked    `string_var(val)@uvm_phase.svh:802:12-802:15#188738  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= string_var   O= io_decl
  - `default_SeqDriver` rung 1  (raw family `string_var|VpiType|KIND:string_var>io_decl`)
    - L(golden) `string_var(val)@uvm_phase.svh:802:12-802:15#319101`
    - R(ours)   `io_decl(val)@:1381:68-1381:71#106393`
    - masked    `string_var(val)@uvm_phase.svh:802:12-802:15#319101  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= string_var   O= io_decl

**F39 `constant|VpiSize|INT:G<O`** — 63 distinct objects / 63 rungs in 6 row(s): default_Earlgrey_0_1, default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Earlgrey_0_1` rung 781  (raw family `constant|VpiSize|INT:G<O`)
    - L(golden) `constant@flash_ctrl.sv:310:43-310:52#370945`
    - R(ours)   `constant@:310:43-310:52#304544`
    - masked    `constant@flash_ctrl.sv:310:43-310:52#370945`
    - G= 32   O= 64
  - `default_Scoreboard` rung 307  (raw family `constant|VpiSize|INT:G<O`)
    - L(golden) `constant@uvm_object_globals.svh:99:23-99:32#187423`
    - R(ours)   `constant@:99:23-99:32#3130`
    - masked    `constant@uvm_object_globals.svh:99:23-99:32#187423`
    - G= -1   O= 32
  - `default_SeqDriver` rung 120  (raw family `constant|VpiSize|INT:G<O`)
    - L(golden) `constant@uvm_object_globals.svh:99:23-99:32#248761`
    - R(ours)   `constant@:99:23-99:32#6092`
    - masked    `constant@uvm_object_globals.svh:99:23-99:32#248761`
    - G= -1   O= 32

**F40 `ref_var|VpiType|KIND:ref_var>class_var`** — 16 distinct objects / 16 rungs in 6 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 148  (raw family `ref_var|VpiType|KIND:ref_var>class_var`)
    - L(golden) `ref_var(p)@uvm_pkg.sv:9683:11-9683:12#64119`
    - R(ours)   `class_var(p)@:9683:11-9683:12#2251`
    - masked    `ref_var(p)@uvm_pkg.sv:9683:11-9683:12#64119  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_var   O= class_var
  - `default_Scoreboard` rung 163  (raw family `ref_var|VpiType|KIND:ref_var>class_var`)
    - L(golden) `ref_var(phase_runner_proc)@uvm_root.svh:411:11-411:28#75327`
    - R(ours)   `class_var(phase_runner_proc)@:411:11-411:28#142194`
    - masked    `ref_var(phase_runner_proc)@uvm_root.svh:411:11-411:28#75327  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_var   O= class_var
  - `default_SimpleUVM` rung 142  (raw family `ref_var|VpiType|KIND:ref_var>class_var`)
    - L(golden) `ref_var(phase_runner_proc)@uvm_root.svh:411:11-411:28#75322`
    - R(ours)   `class_var(phase_runner_proc)@:411:11-411:28#142172`
    - masked    `ref_var(phase_runner_proc)@uvm_root.svh:411:11-411:28#75322  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_var   O= class_var

**F41 `begin|Stmts|VEC:G<O`** — 14 distinct objects / 14 rungs in 6 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 264  (raw family `begin|Stmts|VEC:G<O`)
    - L(golden) `begin@uvm_pkg.sv:41177:3-41177:23#82621`
    - R(ours)   `begin@:41177:3-41177:23#140059`
    - masked    `begin@uvm_pkg.sv:41177:3-41177:23#82621  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 5   O= 7
  - `default_Scoreboard` rung 200  (raw family `begin|Stmts|VEC:G<O`)
    - L(golden) `begin@uvm_component.svh:3387:3-3387:23#80429`
    - R(ours)   `begin@:3387:3-3387:23#141108`
    - masked    `begin@uvm_component.svh:3387:3-3387:23#80429  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 6   O= 8
  - `default_SimpleUVM` rung 183  (raw family `begin|Stmts|VEC:G<O`)
    - L(golden) `begin@uvm_component.svh:3387:3-3387:23#80424`
    - R(ours)   `begin@:3387:3-3387:23#141086`
    - masked    `begin@uvm_component.svh:3387:3-3387:23#80424  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 6   O= 8

**F42 `class_var|VpiAutomatic|INT:G>O`** — 10 distinct objects / 10 rungs in 6 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 261  (raw family `class_var|VpiAutomatic|INT:G>O`)
    - L(golden) `class_var(clp)@uvm_pkg.sv:41172:3-41172:24#82608`
    - R(ours)   `class_var(clp)@:41172:25-41172:28#140051`
    - masked    `class_var(clp)@uvm_pkg.sv:41172:3-41172:24#82608  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 1   O= 0
  - `default_Scoreboard` rung 197  (raw family `class_var|VpiAutomatic|INT:G>O`)
    - L(golden) `class_var(clp)@uvm_component.svh:3383:3-3383:24#80416`
    - R(ours)   `class_var(clp)@:3383:25-3383:28#141100`
    - masked    `class_var(clp)@uvm_component.svh:3383:3-3383:24#80416  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 1   O= 0
  - `default_SimpleUVM` rung 180  (raw family `class_var|VpiAutomatic|INT:G>O`)
    - L(golden) `class_var(clp)@uvm_component.svh:3383:3-3383:24#80411`
    - R(ours)   `class_var(clp)@:3383:25-3383:28#141078`
    - masked    `class_var(clp)@uvm_component.svh:3383:3-3383:24#80411  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 1   O= 0

**F43 `bit_var|VpiAutomatic|INT:G<O`** — 6 distinct objects / 6 rungs in 6 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 268  (raw family `bit_var|VpiAutomatic|INT:G<O`)
    - L(golden) `bit_var(initialized)@uvm_pkg.sv:41351:10-41351:13#83195`
    - R(ours)   `bit_var(initialized)@:41351:10-41351:13#140627`
    - masked    `bit_var(initialized)@uvm_pkg.sv:41351:10-41351:13#83195  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 0   O= 1
  - `default_Scoreboard` rung 202  (raw family `bit_var|VpiAutomatic|INT:G<O`)
    - L(golden) `bit_var(initialized)@uvm_component.svh:3539:10-3539:13#80963`
    - R(ours)   `bit_var(initialized)@:3539:10-3539:13#141639`
    - masked    `bit_var(initialized)@uvm_component.svh:3539:10-3539:13#80963  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 0   O= 1
  - `default_SimpleUVM` rung 185  (raw family `bit_var|VpiAutomatic|INT:G<O`)
    - L(golden) `bit_var(initialized)@uvm_component.svh:3539:10-3539:13#80958`
    - R(ours)   `bit_var(initialized)@:3539:10-3539:13#141617`
    - masked    `bit_var(initialized)@uvm_component.svh:3539:10-3539:13#80958  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 0   O= 1

**F44 `operation -> +ref_typespec|EXTRA-OURS`** — 6 distinct objects / 6 rungs in 6 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 222  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#133856`
    - masked    `operation@uvm_pkg.sv:33619:28-33619:44#74235  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 154  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#134431`
    - masked    `operation@uvm_phase.svh:1071:28-1071:44#71543  [bisected]`
    - G= -   O= -
  - `default_SimpleUVM` rung 133  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#134409`
    - masked    `operation@uvm_phase.svh:1071:28-1071:44#71538  [bisected]`
    - G= -   O= -

**F45 `ref_var|VpiType|KIND:ref_var>hier_path`** — 6 distinct objects / 6 rungs in 6 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 226  (raw family `ref_var|VpiType|KIND:ref_var>hier_path`)
    - L(golden) `ref_var(successors)@uvm_pkg.sv:34610:16-34610:26#76402`
    - R(ours)   `hier_path@:34610:16-34610:44#135962`
    - masked    `ref_var(successors)@uvm_pkg.sv:34610:16-34610:26#76402  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_var   O= hier_path
  - `default_Scoreboard` rung 157  (raw family `ref_var|VpiType|KIND:ref_var>hier_path`)
    - L(golden) `ref_var(successors)@uvm_phase.svh:1730:16-1730:26#73652`
    - R(ours)   `hier_path@:1730:16-1730:44#136484`
    - masked    `ref_var(successors)@uvm_phase.svh:1730:16-1730:26#73652  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_var   O= hier_path
  - `default_SimpleUVM` rung 136  (raw family `ref_var|VpiType|KIND:ref_var>hier_path`)
    - L(golden) `ref_var(successors)@uvm_phase.svh:1730:16-1730:26#73647`
    - R(ours)   `hier_path@:1730:16-1730:44#136462`
    - masked    `ref_var(successors)@uvm_phase.svh:1730:16-1730:26#73647  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= ref_var   O= hier_path

**F46 `string_var|VpiAutomatic|INT:G<O`** — 6 distinct objects / 6 rungs in 6 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SeqDriver, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 259  (raw family `string_var|VpiAutomatic|INT:G<O`)
    - L(golden) `string_var(values)@uvm_pkg.sv:41169:10-41169:16#82596`
    - R(ours)   `string_var(values)@:41169:10-41169:16#140042`
    - masked    `string_var(values)@uvm_pkg.sv:41169:10-41169:16#82596  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 0   O= 1
  - `default_Scoreboard` rung 195  (raw family `string_var|VpiAutomatic|INT:G<O`)
    - L(golden) `string_var(values)@uvm_component.svh:3380:10-3380:16#80404`
    - R(ours)   `string_var(values)@:3380:10-3380:16#141091`
    - masked    `string_var(values)@uvm_component.svh:3380:10-3380:16#80404  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 0   O= 1
  - `default_SimpleUVM` rung 178  (raw family `string_var|VpiAutomatic|INT:G<O`)
    - L(golden) `string_var(values)@uvm_component.svh:3380:10-3380:16#80399`
    - R(ours)   `string_var(values)@:3380:10-3380:16#141069`
    - masked    `string_var(values)@uvm_component.svh:3380:10-3380:16#80399  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 0   O= 1

**F47 `parameter|VpiImported|O-EMPTY`** — 902 distinct objects / 902 rungs in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 208  (raw family `parameter|VpiImported|O-EMPTY`)
    - L(golden) `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23#187236`
    - R(ours)   `parameter(UVM_ABSTRACT)@:201:11-201:23#3241`
    - masked    `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23#187236`
    - G= "uvm_pkg"   O= 0
  - `default_SeqDriver` rung 66  (raw family `parameter|VpiImported|O-EMPTY`)
    - L(golden) `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23#248574`
    - R(ours)   `parameter(UVM_ABSTRACT)@:201:11-201:23#6203`
    - masked    `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23#248574`
    - G= "uvm_pkg"   O= 0
  - `default_SimpleUVM` rung 190  (raw family `parameter|VpiImported|O-EMPTY`)
    - L(golden) `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23#186966`
    - R(ours)   `parameter(UVM_ABSTRACT)@:201:11-201:23#3219`
    - masked    `parameter(UVM_ABSTRACT)@uvm_object_globals.svh:201:11-201:23#186966`
    - G= "uvm_pkg"   O= 0

**F48 `param_assign -> +ref_typespec|EXTRA-OURS`** — 36 distinct objects / 60 rungs in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 308  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#3128`
    - masked    `param_assign@uvm_object_globals.svh:99:11-99:32#187422  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 121  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#6090`
    - masked    `param_assign@uvm_object_globals.svh:99:11-99:32#248760  [bisected]`
    - G= -   O= -
  - `default_SimpleUVM` rung 290  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#3106`
    - masked    `param_assign@uvm_object_globals.svh:99:11-99:32#187152  [bisected]`
    - G= -   O= -

**F49 `constant|VpiType|KIND:constant>hier_path`** — 23 distinct objects / 23 rungs in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 3  (raw family `constant|VpiType|KIND:constant>hier_path`)
    - L(golden) `constant@uvm_sequencer_base.svh:1576:23-1576:44#25787`
    - R(ours)   `hier_path(this.sequences.size)@:1576:23-1576:44#104247`
    - masked    `constant@uvm_sequencer_base.svh:1576:23-1576:44#25787`
    - G= constant   O= hier_path
  - `default_SeqDriver` rung 3  (raw family `constant|VpiType|KIND:constant>hier_path`)
    - L(golden) `constant@uvm_sequencer_base.svh:1576:23-1576:44#25787`
    - R(ours)   `hier_path(this.sequences.size)@:1576:23-1576:44#106861`
    - masked    `constant@uvm_sequencer_base.svh:1576:23-1576:44#25787`
    - G= constant   O= hier_path
  - `default_SimpleUVM` rung 3  (raw family `constant|VpiType|KIND:constant>hier_path`)
    - L(golden) `constant@uvm_sequencer_base.svh:1576:23-1576:44#25782`
    - R(ours)   `hier_path(this.sequences.size)@:1576:23-1576:44#104225`
    - masked    `constant@uvm_sequencer_base.svh:1576:23-1576:44#25782`
    - G= constant   O= hier_path

**F50 `event_stmt|VpiName|O-EMPTY`** — 21 distinct objects / 21 rungs in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 399  (raw family `event_stmt|VpiName|O-EMPTY`)
    - L(golden) `event_stmt(w)@uvm_config_db.svh:224:12-224:24#128530`
    - R(ours)   `event_stmt@:224:12-224:24#18005`
    - masked    `event_stmt(w)@uvm_config_db.svh:224:12-224:24#128530`
    - G= "w"   O= 0
  - `default_SeqDriver` rung 162  (raw family `event_stmt|VpiName|O-EMPTY`)
    - L(golden) `event_stmt(w)@uvm_config_db.svh:224:12-224:24#258974`
    - R(ours)   `event_stmt@:224:12-224:24#20619`
    - masked    `event_stmt(w)@uvm_config_db.svh:224:12-224:24#258974`
    - G= "w"   O= 0
  - `default_SimpleUVM` rung 381  (raw family `event_stmt|VpiName|O-EMPTY`)
    - L(golden) `event_stmt(w)@uvm_config_db.svh:224:12-224:24#128260`
    - R(ours)   `event_stmt@:224:12-224:24#17983`
    - masked    `event_stmt(w)@uvm_config_db.svh:224:12-224:24#128260`
    - G= "w"   O= 0

**F51 `unsupported_typespec|VpiType|KIND:unsupported_typespec>class_typespec`** — 18 distinct objects / 18 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 247  (raw family `unsupported_typespec|VpiType|KIND:unsupported_typespec>class_typespec`)
    - L(golden) `unsupported_typespec(REQ)@uvm_pkg.sv:54356:3-54356:6#26540`
    - R(ours)   `class_typespec@:54356:3-54356:6#101339`
    - masked    `unsupported_typespec(REQ)@uvm_pkg.sv:54356:3-54356:6#26540  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= unsupported_typespec   O= class_typespec
  - `default_Scoreboard` rung 185  (raw family `unsupported_typespec|VpiType|KIND:unsupported_typespec>class_typespec`)
    - L(golden) `unsupported_typespec(REQ)@uvm_sequencer.svh:164:3-164:6#26595`
    - R(ours)   `class_typespec@:164:3-164:6#101008`
    - masked    `unsupported_typespec(REQ)@uvm_sequencer.svh:164:3-164:6#26595  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= unsupported_typespec   O= class_typespec
  - `default_SimpleUVM` rung 164  (raw family `unsupported_typespec|VpiType|KIND:unsupported_typespec>class_typespec`)
    - L(golden) `unsupported_typespec(REQ)@uvm_sequencer.svh:164:3-164:6#26590`
    - R(ours)   `class_typespec@:164:3-164:6#100986`
    - masked    `unsupported_typespec(REQ)@uvm_sequencer.svh:164:3-164:6#26590  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= unsupported_typespec   O= class_typespec

**F52 `method_func_call|VpiType|KIND:method_func_call>hier_path`** — 15 distinct objects / 15 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 70  (raw family `method_func_call|VpiType|KIND:method_func_call>hier_path`)
    - L(golden) `method_func_call(set_type_override_by_type)@uvm_pkg.sv:14073:13-14073:38#161096`
    - R(ours)   `hier_path(factory.set_type_override_by_type)@:14073:5-14073:38#86540`
    - masked    `method_func_call(set_type_override_by_type)@uvm_pkg.sv:14073:13-14073:38#161096  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= method_func_call   O= hier_path
  - `default_Scoreboard` rung 175  (raw family `method_func_call|VpiType|KIND:method_func_call>hier_path`)
    - L(golden) `method_func_call(randomize)@uvm_sequence_builtin.svh:196:10-197:27#131764`
    - R(ours)   `hier_path(l_kind.randomize)@:196:10-196:27#24071`
    - masked    `method_func_call(randomize)@uvm_sequence_builtin.svh:196:10-197:27#131764`
    - G= method_func_call   O= hier_path
  - `default_SimpleUVM` rung 154  (raw family `method_func_call|VpiType|KIND:method_func_call>hier_path`)
    - L(golden) `method_func_call(randomize)@uvm_sequence_builtin.svh:196:10-197:27#131494`
    - R(ours)   `hier_path(l_kind.randomize)@:196:10-196:27#24049`
    - masked    `method_func_call(randomize)@uvm_sequence_builtin.svh:196:10-197:27#131494`
    - G= method_func_call   O= hier_path

**F53 `func_call|VpiType|KIND:func_call>hier_path`** — 10 distinct objects / 10 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 251  (raw family `func_call|VpiType|KIND:func_call>hier_path`)
    - L(golden) `func_call(randomize)@uvm_pkg.sv:56818:16-56818:38#27438`
    - R(ours)   `hier_path(select_rand.randomize)@:56818:16-56818:38#100528`
    - masked    `func_call(randomize)@uvm_pkg.sv:56818:16-56818:38#27438`
    - G= func_call   O= hier_path
  - `default_Scoreboard` rung 187  (raw family `func_call|VpiType|KIND:func_call>hier_path`)
    - L(golden) `func_call(randomize)@uvm_sequence_library.svh:673:16-673:38#27475`
    - R(ours)   `hier_path(select_rand.randomize)@:673:16-673:38#100170`
    - masked    `func_call(randomize)@uvm_sequence_library.svh:673:16-673:38#27475`
    - G= func_call   O= hier_path
  - `default_SimpleUVM` rung 169  (raw family `func_call|VpiType|KIND:func_call>hier_path`)
    - L(golden) `func_call(randomize)@uvm_sequence_library.svh:673:16-673:38#27470`
    - R(ours)   `hier_path(select_rand.randomize)@:673:16-673:38#100148`
    - masked    `func_call(randomize)@uvm_sequence_library.svh:673:16-673:38#27470`
    - G= func_call   O= hier_path

**F54 `begin -> +class_var|EXTRA-OURS`** — 5 distinct objects / 5 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 85  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(uvm_cmdline_proc)@:43181:23-43181:39#3398`
    - masked    `begin@uvm_pkg.sv:43215:7-43215:33#125390  [bisected]`
    - G= -   O= -
  - `default_Scoreboard` rung 86  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(uvm_default_comparer)@:654:14-654:42#3739`
    - masked    `begin@uvm_comparer.svh:413:5-413:33#126965  [bisected]`
    - G= -   O= -
  - `default_SeqDriver` rung 47  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(uvm_default_comparer)@:654:14-654:42#6353`
    - masked    `begin@uvm_comparer.svh:413:5-413:33#257409  [bisected]`
    - G= -   O= -

**F55 `class_defn|VpiName|TEXT-DIFF`** — 5 distinct objects / 5 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 245  (raw family `class_defn|VpiName|TEXT:uvm_abstract_component_registry|uvm_sequence_library`)
    - L(golden) `class_defn(uvm_abstract_component_registry)@uvm_pkg.sv:13774:1-13893:9#15`
    - R(ours)   `class_defn(uvm_sequence_library)@uvm_pkg.sv:56122:1-56407:9#99694`
    - masked    `class_defn(uvm_abstract_component_registry)@uvm_pkg.sv:13774:1-13893:9#15  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_abstract_component_registry"   O= "uvm_sequence_library"
  - `default_Scoreboard` rung 183  (raw family `class_defn|VpiName|TEXT:uvm_algorithmic_comparator|uvm_sequence_library`)
    - L(golden) `class_defn(uvm_algorithmic_comparator)@uvm_algorithmic_comparator.svh:68:1-134:9#224`
    - R(ours)   `class_defn(uvm_sequence_library)@uvm_sequence_library.svh:64:1-347:9#99317`
    - masked    `class_defn(uvm_algorithmic_comparator)@uvm_algorithmic_comparator.svh:68:1-134:9#224  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_algorithmic_comparator"   O= "uvm_sequence_library"
  - `default_SimpleUVM` rung 162  (raw family `class_defn|VpiName|TEXT:uvm_algorithmic_comparator|uvm_sequence_library`)
    - L(golden) `class_defn(uvm_algorithmic_comparator)@uvm_algorithmic_comparator.svh:68:1-134:9#224`
    - R(ours)   `class_defn(uvm_sequence_library)@uvm_sequence_library.svh:64:1-347:9#99295`
    - masked    `class_defn(uvm_algorithmic_comparator)@uvm_algorithmic_comparator.svh:68:1-134:9#224  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_algorithmic_comparator"   O= "uvm_sequence_library"

**F56 `class_var|VpiType|KIND:class_var>ref_var`** — 5 distinct objects / 5 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 243  (raw family `class_var|VpiType|KIND:class_var>ref_var`)
    - L(golden) `class_var(this_type::m_typewide_sequences)@uvm_pkg.sv:56591:12-56591:23#26949`
    - R(ours)   `ref_var(m_typewide_sequences)@:56591:12-56591:32#100053`
    - masked    `class_var(this_type::m_typewide_sequences)@uvm_pkg.sv:56591:12-56591:23#26949  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= class_var   O= ref_var
  - `default_Scoreboard` rung 182  (raw family `class_var|VpiType|KIND:class_var>ref_var`)
    - L(golden) `class_var(this_type::m_typewide_sequences)@uvm_sequence_library.svh:496:12-496:23#26987`
    - R(ours)   `ref_var(m_typewide_sequences)@:496:12-496:32#99696`
    - masked    `class_var(this_type::m_typewide_sequences)@uvm_sequence_library.svh:496:12-496:23#26987  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= class_var   O= ref_var
  - `default_SimpleUVM` rung 161  (raw family `class_var|VpiType|KIND:class_var>ref_var`)
    - L(golden) `class_var(this_type::m_typewide_sequences)@uvm_sequence_library.svh:496:12-496:23#26982`
    - R(ours)   `ref_var(m_typewide_sequences)@:496:12-496:32#99674`
    - masked    `class_var(this_type::m_typewide_sequences)@uvm_sequence_library.svh:496:12-496:23#26982  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= class_var   O= ref_var

**F57 `foreach_stmt -> string_var|MISSING-OURS`** — 5 distinct objects / 5 rungs in 5 row(s): default_Scoreboard, default_SeqDriver, default_SimpleUVM, testflags_SeqDriver, testflags_SimpleUVM

  - `default_Scoreboard` rung 63  (raw family `string_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `string_var(i)@uvm_factory.svh:1183:15-1183:16#194677`
    - R(ours)   `<null>`
    - masked    `foreach_stmt@uvm_factory.svh:1183:3-1183:10#5268  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 22  (raw family `string_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `string_var(i)@uvm_factory.svh:1183:15-1183:16#325890`
    - R(ours)   `<null>`
    - masked    `foreach_stmt@uvm_factory.svh:1183:3-1183:10#5268  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SimpleUVM` rung 28  (raw family `string_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `string_var(index)@uvm_packer.svh:797:18-797:23#195088`
    - R(ours)   `<null>`
    - masked    `foreach_stmt@uvm_packer.svh:797:3-797:10#10235  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F58 `int_var -> operation|MISSING-OURS`** — 5 distinct objects / 5 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 239  (raw family `operation|<rhs-null>|MISSING-OURS`)
    - L(golden) `operation@uvm_pkg.sv:56269:42-56269:54#190890`
    - R(ours)   `<null>`
    - masked    `int_var@uvm_pkg.sv:56269:18-56269:30#190895`
    - G= -   O= -
  - `default_Scoreboard` rung 178  (raw family `operation|<rhs-null>|MISSING-OURS`)
    - L(golden) `operation@uvm_sequence_library.svh:192:42-192:54#193334`
    - R(ours)   `<null>`
    - masked    `int_var@uvm_sequence_library.svh:192:18-192:30#193339`
    - G= -   O= -
  - `default_SimpleUVM` rung 157  (raw family `operation|<rhs-null>|MISSING-OURS`)
    - L(golden) `operation@uvm_sequence_library.svh:192:42-192:54#193680`
    - R(ours)   `<null>`
    - masked    `int_var@uvm_sequence_library.svh:192:18-192:30#193685`
    - G= -   O= -

**F59 `ref_obj|VpiType|KIND:ref_obj>func_call`** — 5 distinct objects / 5 rungs in 5 row(s): default_BuildUVMPkg, default_Scoreboard, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 240  (raw family `ref_obj|VpiType|KIND:ref_obj>func_call`)
    - L(golden) `ref_obj(this_type::add_typewide_sequence)@uvm_pkg.sv:56491:3-56491:14#26799`
    - R(ours)   `func_call(this_type::add_typewide_sequence)@:56491:3-56491:12#99898`
    - masked    `begin@uvm_pkg.sv:56492:3-56492:12#26798`
    - G= ref_obj   O= func_call
  - `default_Scoreboard` rung 179  (raw family `ref_obj|VpiType|KIND:ref_obj>func_call`)
    - L(golden) `ref_obj(this_type::add_typewide_sequence)@uvm_sequence_library.svh:413:3-413:14#26872`
    - R(ours)   `func_call(this_type::add_typewide_sequence)@:413:3-413:12#99576`
    - masked    `begin@uvm_sequence_library.svh:414:3-414:12#26871`
    - G= ref_obj   O= func_call
  - `default_SimpleUVM` rung 158  (raw family `ref_obj|VpiType|KIND:ref_obj>func_call`)
    - L(golden) `ref_obj(this_type::add_typewide_sequence)@uvm_sequence_library.svh:413:3-413:14#26867`
    - R(ours)   `func_call(this_type::add_typewide_sequence)@:413:3-413:12#99554`
    - masked    `begin@uvm_sequence_library.svh:414:3-414:12#26866`
    - G= ref_obj   O= func_call

**F60 `enum_const|VpiDecompile|TEXT-DIFF`** — 8 distinct objects / 8 rungs in 4 row(s): default_BuildUVMPkg, default_SimpleUVM, testflags_BuildUVMPkg, testflags_SimpleUVM

  - `default_BuildUVMPkg` rung 139  (raw family `enum_const|VpiDecompile|TEXT:# << #|#<<#`)
    - L(golden) `enum_const(UVM_DEEP)@uvm_pkg.sv:7932:3-7932:31#61526`
    - R(ours)   `enum_const(UVM_DEEP)@:7932:3-7932:31#294`
    - masked    `enum_const(UVM_DEEP)@uvm_pkg.sv:7932:3-7932:31#61526`
    - G= "1 << 16"   O= "1<<16"
  - `default_SimpleUVM` rung 395  (raw family `enum_const|VpiDecompile|TEXT:-#|#`)
    - L(golden) `enum_const(UVM_CVR_ALL)@uvm_reg_model.svh:279:7-279:32#28233`
    - R(ours)   `enum_const(UVM_CVR_ALL)@:279:7-279:32#3616`
    - masked    `enum_const(UVM_CVR_ALL)@uvm_reg_model.svh:279:7-279:32#28233`
    - G= "-1"   O= "4294967295"
  - `testflags_BuildUVMPkg` rung 139  (raw family `enum_const|VpiDecompile|TEXT:# << #|#<<#`)
    - L(golden) `enum_const(UVM_DEEP)@uvm_pkg.sv:7932:3-7932:31#61526`
    - R(ours)   `enum_const(UVM_DEEP)@:7932:3-7932:31#294`
    - masked    `enum_const(UVM_DEEP)@uvm_pkg.sv:7932:3-7932:31#61526`
    - G= "1 << 16"   O= "1<<16"

**F61 `class_defn -> +package|EXTRA-OURS`** — 4 distinct objects / 6 rungs in 4 row(s): default_BuildUVMPkg, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 105  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#2`
    - masked    `class_defn(uvm_component)@uvm_pkg.sv:36887:9-38397:25#117  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 340  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(adpcm_pkg)@testbench.sv:10:1-207:22#181555`
    - masked    `class_defn(uvm_component)@uvm_component.svh:60:9-1710:25#108  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 105  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#2`
    - masked    `class_defn(uvm_component)@uvm_pkg.sv:36887:9-38397:25#117  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F62 `unsupported_typespec -> package|MISSING-OURS`** — 4 distinct objects / 4 rungs in 4 row(s): default_BuildUVMPkg, default_SeqDriver, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 78  (raw family `package|<rhs-null>|MISSING-OURS`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#1`
    - R(ours)   `<null>`
    - masked    `unsupported_typespec(uvm_resource_types::rsrc_q_t)@uvm_pkg.sv:53518:3-53518:23#25794  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 2  (raw family `package|<rhs-null>|MISSING-OURS`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1`
    - R(ours)   `<null>`
    - masked    `unsupported_typespec(uvm_resource_types::rsrc_q_t)@uvm_sequencer_base.svh:1434:3-1434:23#25354  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 78  (raw family `package|<rhs-null>|MISSING-OURS`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#1`
    - R(ours)   `<null>`
    - masked    `unsupported_typespec(uvm_resource_types::rsrc_q_t)@uvm_pkg.sv:53518:3-53518:23#25794  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F63 `parameter|VpiType|KIND:parameter>constant`** — 64 distinct objects / 64 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 71  (raw family `parameter|VpiType|KIND:parameter>constant`)
    - L(golden) `parameter(UVM_STR_CRC_POLYNOMIAL)@uvm_misc.svh:368:11-368:33#120157`
    - R(ours)   `constant@:368:36-368:48#3328`
    - masked    `parameter(UVM_STR_CRC_POLYNOMIAL)@uvm_misc.svh:368:11-368:33#120157`
    - G= parameter   O= constant
  - `default_SimpleUVM` rung 27  (raw family `parameter|VpiType|KIND:parameter>constant`)
    - L(golden) `parameter(UVM_PACK)@uvm_object_globals.svh:195:11-195:19#119316`
    - R(ours)   `constant@:195:31-195:32#3204`
    - masked    `parameter(UVM_PACK)@uvm_object_globals.svh:195:11-195:19#119316`
    - G= parameter   O= constant
  - `testflags_SimpleUVM` rung 27  (raw family `parameter|VpiType|KIND:parameter>constant`)
    - L(golden) `parameter(UVM_PACK)@uvm_object_globals.svh:195:11-195:19#119316`
    - R(ours)   `constant@:195:31-195:32#3216`
    - masked    `parameter(UVM_PACK)@uvm_object_globals.svh:195:11-195:19#119316`
    - G= parameter   O= constant

**F64 `parameter|VpiType|KIND:parameter>operation`** — 14 distinct objects / 14 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 99  (raw family `parameter|VpiType|KIND:parameter>operation`)
    - L(golden) `parameter(UVM_MACRO_EXTRAS)@uvm_object_globals.svh:206:11-206:27#120090`
    - R(ours)   `operation@:206:32-206:53#323`
    - masked    `parameter(UVM_MACRO_EXTRAS)@uvm_object_globals.svh:206:11-206:27#120090`
    - G= parameter   O= operation
  - `default_SimpleUVM` rung 69  (raw family `parameter|VpiType|KIND:parameter>operation`)
    - L(golden) `parameter(UVM_MACRO_EXTRAS)@uvm_object_globals.svh:206:11-206:27#119289`
    - R(ours)   `operation@:206:32-206:53#315`
    - masked    `parameter(UVM_MACRO_EXTRAS)@uvm_object_globals.svh:206:11-206:27#119289`
    - G= parameter   O= operation
  - `testflags_SimpleUVM` rung 69  (raw family `parameter|VpiType|KIND:parameter>operation`)
    - L(golden) `parameter(UVM_MACRO_EXTRAS)@uvm_object_globals.svh:206:11-206:27#119289`
    - R(ours)   `operation@:206:32-206:53#327`
    - masked    `parameter(UVM_MACRO_EXTRAS)@uvm_object_globals.svh:206:11-206:27#119289`
    - G= parameter   O= operation

**F65 `logic_typespec|VpiName|O-EXTRA-PREFIX`** — 11 distinct objects / 11 rungs in 3 row(s): default_Earlgrey_0_1, default_SimpleUVM, testflags_SimpleUVM

  - `default_Earlgrey_0_1` rung 1312  (raw family `logic_typespec|VpiName|O-EXTRA-PREFIX(hmac_pkg::)`)
    - L(golden) `logic_typespec(sha_word_t)@hmac_pkg.sv:17:11-17:23#456400`
    - R(ours)   `logic_typespec(hmac_pkg::sha_word_t)@:17:11-17:23#27866`
    - masked    `logic_typespec(sha_word_t)@hmac_pkg.sv:17:11-17:23#456400`
    - G= "sha_word_t"   O= "hmac_pkg::sha_word_t"
  - `default_SimpleUVM` rung 30  (raw family `logic_typespec|VpiName|O-EXTRA-PREFIX(uvm_pkg::)`)
    - L(golden) `logic_typespec(uvm_bitstream_t)@uvm_object_globals.svh:49:9-49:42#196471`
    - R(ours)   `logic_typespec(uvm_pkg::uvm_bitstream_t)@:49:9-49:42#181029`
    - masked    `logic_typespec(uvm_bitstream_t)@uvm_object_globals.svh:49:9-49:42#196471  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_bitstream_t"   O= "uvm_pkg::uvm_bitstream_t"
  - `testflags_SimpleUVM` rung 30  (raw family `logic_typespec|VpiName|O-EXTRA-PREFIX(uvm_pkg::)`)
    - L(golden) `logic_typespec(uvm_bitstream_t)@uvm_object_globals.svh:49:9-49:42#196483`
    - R(ours)   `logic_typespec(uvm_pkg::uvm_bitstream_t)@:49:9-49:42#181041`
    - masked    `logic_typespec(uvm_bitstream_t)@uvm_object_globals.svh:49:9-49:42#196483  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_bitstream_t"   O= "uvm_pkg::uvm_bitstream_t"

**F66 `bit_select -> constant|MISSING-OURS`** — 9 distinct objects / 9 rungs in 3 row(s): default_BuildUVMPkg, default_Scoreboard, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 67  (raw family `constant|<rhs-null>|MISSING-OURS`)
    - L(golden) `constant@uvm_pkg.sv:20128:59-20128:60#9160`
    - R(ours)   `<null>`
    - masked    `bit_select(m_element_stack)@uvm_pkg.sv:20128:59-20128:60#9161`
    - G= -   O= -
  - `default_Scoreboard` rung 50  (raw family `constant|<rhs-null>|MISSING-OURS`)
    - L(golden) `constant@uvm_misc.svh:284:79-284:80#174999`
    - R(ours)   `<null>`
    - masked    `bit_select(m_uvm_cycle_scopes)@uvm_misc.svh:284:79-284:80#175000`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 67  (raw family `constant|<rhs-null>|MISSING-OURS`)
    - L(golden) `constant@uvm_pkg.sv:20128:59-20128:60#9160`
    - R(ours)   `<null>`
    - masked    `bit_select(m_element_stack)@uvm_pkg.sv:20128:59-20128:60#9161`
    - G= -   O= -

**F67 `class_defn -> +ref_var|EXTRA-OURS`** — 8 distinct objects / 8 rungs in 3 row(s): default_BuildUVMPkg, default_Scoreboard, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 7  (raw family `+ref_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_var(orig_type_alias_per_inst)@:12754:30-12754:54#19741`
    - masked    `class_defn(uvm_default_factory)@uvm_pkg.sv:11744:1-11990:9#10  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Scoreboard` rung 186  (raw family `+ref_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_var(t)@:164:7-164:8#101009`
    - masked    `class_defn(uvm_sequencer)@uvm_sequencer.svh:30:1-139:9#240  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 7  (raw family `+ref_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_var(orig_type_alias_per_inst)@:12754:30-12754:54#19741`
    - masked    `class_defn(uvm_default_factory)@uvm_pkg.sv:11744:1-11990:9#10  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F68 `function|Typespecs|VEC:G>O`** — 6 distinct objects / 9 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 44  (raw family `function|~Typespecs|VEC:G>O`)
    - L(golden) `function(uvm_process_report_message)@uvm_globals.svh:259:1-267:12#811`
    - R(ours)   `<null>`
    - masked    `func_call(uvm_process_report_message)@uvm_report_object.svh:146:5-146:49#165098  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 125   O= 91
  - `default_SimpleUVM` rung 50  (raw family `function|~Typespecs|VEC:G>O`)
    - L(golden) `function(uvm_process_report_message)@uvm_globals.svh:259:1-267:12#806`
    - R(ours)   `<null>`
    - masked    `func_call(uvm_process_report_message)@uvm_report_object.svh:146:5-146:49#164828  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 50  (raw family `function|~Typespecs|VEC:G>O`)
    - L(golden) `function(uvm_process_report_message)@uvm_globals.svh:259:1-267:12#806`
    - R(ours)   `<null>`
    - masked    `func_call(uvm_process_report_message)@uvm_report_object.svh:146:5-146:49#164840  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 123   O= 89

**F69 `operation|VpiType|KIND:operation>constant`** — 6 distinct objects / 6 rungs in 3 row(s): default_BuildUVMPkg, default_Rggen, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 100  (raw family `operation|VpiType|KIND:operation>constant`)
    - L(golden) `operation@uvm_pkg.sv:54965:56-54965:148#170480`
    - R(ours)   `constant@:40511:56-40511:58#98003`
    - masked    `operation@uvm_pkg.sv:54965:56-54965:148#170480`
    - G= operation   O= constant
  - `default_Rggen` rung 21  (raw family `operation|VpiType|KIND:operation>constant`)
    - L(golden) `operation@rggen_or_reducer.sv:66:10-66:18#60675`
    - R(ours)   `constant@:66:10-66:16#43324`
    - masked    `operation@rggen_or_reducer.sv:66:10-66:18#60675`
    - G= operation   O= constant
  - `testflags_BuildUVMPkg` rung 100  (raw family `operation|VpiType|KIND:operation>constant`)
    - L(golden) `operation@uvm_pkg.sv:54965:56-54965:148#170480`
    - R(ours)   `constant@:40511:56-40511:58#98003`
    - masked    `operation@uvm_pkg.sv:54965:56-54965:148#170480`
    - G= operation   O= constant

**F70 `module_inst -> +ref_typespec|EXTRA-OURS`** — 5 distinct objects / 5 rungs in 3 row(s): default_Rggen, default_SeqDriver, testflags_SeqDriver

  - `default_Rggen` rung 9  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#17064`
    - masked    `module_inst(u_mux)@rggen_adapter_common.sv:148:3-155:5#349499  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 395  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#292248`
    - masked    `module_inst@testbench.sv:210:1-236:18#328232  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_SeqDriver` rung 524  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#292260`
    - masked    `module_inst@testbench.sv:210:1-236:18#328244  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F71 `module_inst|Variables|VEC:G>O`** — 4 distinct objects / 4 rungs in 3 row(s): default_Earlgrey_0_1, default_SeqDriver, testflags_SeqDriver

  - `default_Earlgrey_0_1` rung 513  (raw family `module_inst|Variables|VEC:G>O`)
    - L(golden) `module_inst(u_fwmode)@spi_device.sv:330:3-359:5#997978`
    - R(ours)   `module_inst(u_fwmode)@spi_device.sv:330:3-359:5#285182`
    - masked    `module_inst(u_fwmode)@spi_device.sv:330:3-359:5#997978  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 11   O= 10
  - `default_SeqDriver` rung 396  (raw family `module_inst|Variables|VEC:G>O`)
    - L(golden) `module_inst(work@top_tb)@testbench.sv:210:1-236:18#328589`
    - R(ours)   `module_inst(work@top_tb)@testbench.sv:210:1-236:18#293455`
    - masked    `module_inst(work@top_tb)@testbench.sv:210:1-236:18#328589  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 66   O= 25
  - `testflags_SeqDriver` rung 525  (raw family `module_inst|Variables|VEC:G>O`)
    - L(golden) `module_inst(work@top_tb)@testbench.sv:210:1-236:18#328601`
    - R(ours)   `module_inst(work@top_tb)@testbench.sv:210:1-236:18#293467`
    - masked    `module_inst(work@top_tb)@testbench.sv:210:1-236:18#328601  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 66   O= 25

**F72 `+package|Typespecs|VEC:G>O`** — 3 distinct objects / 7 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 70  (raw family `+package|~Typespecs|VEC:G>O`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#154`
    - masked    `class_defn(uvm_component)@uvm_component.svh:60:9-1710:25#108  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 125   O= 91
  - `default_SimpleUVM` rung 186  (raw family `+package|~Typespecs|VEC:G>O`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#146`
    - masked    `ref_var(t)@uvm_component.svh:3546:28-3546:29#80993  [bisected]`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 186  (raw family `+package|~Typespecs|VEC:G>O`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#158`
    - masked    `ref_var(t)@uvm_component.svh:3546:28-3546:29#80993  [bisected]`
    - G= 123   O= 89

**F73 `design|Typespecs|VEC:G>O`** — 3 distinct objects / 3 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 403  (raw family `design|Typespecs|VEC:G>O`)
    - L(golden) `design(work@my_scoreboard_unit_test)@:0:0-0:0#194649`
    - R(ours)   `design(work@my_scoreboard_unit_test)@:0:0-0:0#1`
    - masked    `-`
    - G= 125   O= 91
  - `default_SimpleUVM` rung 398  (raw family `design|Typespecs|VEC:G>O`)
    - L(golden) `design(work@top)@:0:0-0:0#194978`
    - R(ours)   `design(work@top)@:0:0-0:0#1`
    - masked    `-`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 398  (raw family `design|Typespecs|VEC:G>O`)
    - L(golden) `design(work@top)@:0:0-0:0#194990`
    - R(ours)   `design(work@top)@:0:0-0:0#1`
    - masked    `-`
    - G= 123   O= 89

**F74 `hier_path|VpiName|O-EXTRA-SUFFIX`** — 3 distinct objects / 3 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 191  (raw family `hier_path|VpiName|O-EXTRA-SUFFIX(.randomize)`)
    - L(golden) `hier_path(item)@uvm_sequence_defines.svh:204:54-204:78#173878`
    - R(ours)   `hier_path(item.randomize)@:204:54-204:68#106042`
    - masked    `hier_path(item)@uvm_sequence_defines.svh:204:54-204:78#173878`
    - G= "item"   O= "item.randomize"
  - `default_SimpleUVM` rung 174  (raw family `hier_path|VpiName|O-EXTRA-SUFFIX(.randomize)`)
    - L(golden) `hier_path(item)@uvm_sequence_defines.svh:204:54-204:78#173608`
    - R(ours)   `hier_path(item.randomize)@:204:54-204:68#106020`
    - masked    `hier_path(item)@uvm_sequence_defines.svh:204:54-204:78#173608`
    - G= "item"   O= "item.randomize"
  - `testflags_SimpleUVM` rung 174  (raw family `hier_path|VpiName|O-EXTRA-SUFFIX(.randomize)`)
    - L(golden) `hier_path(item)@uvm_sequence_defines.svh:204:54-204:78#173620`
    - R(ours)   `hier_path(item.randomize)@:204:54-204:68#106032`
    - masked    `hier_path(item)@uvm_sequence_defines.svh:204:54-204:78#173620`
    - G= "item"   O= "item.randomize"

**F75 `package -> +package|EXTRA-OURS`** — 3 distinct objects / 3 rungs in 3 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg, testflags_SeqDriver

  - `default_BuildUVMPkg` rung 273  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#2`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#60163  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 273  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#2`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#60163  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_SeqDriver` rung 507  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(adpcm_pkg)@testbench.sv:10:1-207:22#181567`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#59742  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F76 `package -> +string_var|EXTRA-OURS`** — 3 distinct objects / 3 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 24  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_error_id)@:23:14-23:56#3822`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SimpleUVM` rung 24  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_error_id)@:23:14-23:56#3800`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_SimpleUVM` rung 24  (raw family `+string_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `string_var(s_connection_error_id)@:23:14-23:56#3812`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F77 `package|Typespecs|VEC:G>O`** — 3 distinct objects / 3 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 2  (raw family `package|~Typespecs|VEC:G>O`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1`
    - R(ours)   `<null>`
    - masked    `unsupported_typespec(uvm_resource_types::rsrc_q_t)@uvm_sequencer_base.svh:1434:3-1434:23#25354  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 125   O= 91
  - `default_SimpleUVM` rung 2  (raw family `package|~Typespecs|VEC:G>O`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1`
    - R(ours)   `<null>`
    - masked    `unsupported_typespec(uvm_resource_types::rsrc_q_t)@uvm_sequencer_base.svh:1434:3-1434:23#25349  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 2  (raw family `package|~Typespecs|VEC:G>O`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1`
    - R(ours)   `<null>`
    - masked    `unsupported_typespec(uvm_resource_types::rsrc_q_t)@uvm_sequencer_base.svh:1434:3-1434:23#25349  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 123   O= 89

**F78 `ref_obj -> +class_var|EXTRA-OURS`** — 3 distinct objects / 3 rungs in 3 row(s): default_Scoreboard, default_SimpleUVM, testflags_SimpleUVM

  - `default_Scoreboard` rung 47  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(end_of_elaboration_ph)@:48:11-48:32#3772`
    - masked    `ref_obj(end_of_elaboration_ph)@uvm_root.svh:252:18-252:39#168951  [bisected]`
    - G= -   O= -
  - `default_SimpleUVM` rung 54  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(end_of_elaboration_ph)@:48:11-48:32#3750`
    - masked    `ref_obj(end_of_elaboration_ph)@uvm_root.svh:252:18-252:39#168681  [bisected]`
    - G= -   O= -
  - `testflags_SimpleUVM` rung 54  (raw family `+class_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_var(end_of_elaboration_ph)@:48:11-48:32#3762`
    - masked    `ref_obj(end_of_elaboration_ph)@uvm_root.svh:252:18-252:39#168693  [bisected]`
    - G= -   O= -

**F79 `ref_obj -> chandle_var|MISSING-OURS`** — 3 distinct objects / 3 rungs in 3 row(s): default_Scoreboard, default_SeqDriver, testflags_SeqDriver

  - `default_Scoreboard` rung 68  (raw family `chandle_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `chandle_var(compiled_regex)@uvm_traversal.svh:257:18-257:32#127817`
    - R(ours)   `<null>`
    - masked    `ref_obj(compiled_regex)@uvm_traversal.svh:262:10-262:24#127828`
    - G= -   O= -
  - `default_SeqDriver` rung 37  (raw family `chandle_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `chandle_var(compiled_regex)@uvm_traversal.svh:257:18-257:32#258261`
    - R(ours)   `<null>`
    - masked    `ref_obj(compiled_regex)@uvm_traversal.svh:262:10-262:24#258272`
    - G= -   O= -
  - `testflags_SeqDriver` rung 37  (raw family `chandle_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `chandle_var(compiled_regex)@uvm_traversal.svh:257:18-257:32#258273`
    - R(ours)   `<null>`
    - masked    `ref_obj(compiled_regex)@uvm_traversal.svh:262:10-262:24#258284`
    - G= -   O= -

**F80 `constant|VpiType|KIND:constant>ref_obj`** — 1330 distinct objects / 1330 rungs in 2 row(s): default_Earlgrey_0_1, default_Rggen

  - `default_Earlgrey_0_1` rung 80  (raw family `constant|VpiType|KIND:constant>ref_obj`)
    - L(golden) `constant@prim_fifo_sync.sv:131:29-131:38#291799`
    - R(ours)   `ref_obj(PTR_WIDTH)@:131:29-131:38#235972`
    - masked    `constant@prim_fifo_sync.sv:131:29-131:38#291799`
    - G= constant   O= ref_obj
  - `default_Rggen` rung 11  (raw family `constant|VpiType|KIND:constant>ref_obj`)
    - L(golden) `constant@:0:0-0:0#350095`
    - R(ours)   `ref_obj(RGGEN_OKAY)@:104:35-104:45#10646`
    - masked    `constant@:0:0-0:0#350095`
    - G= constant   O= ref_obj
  - `default_Earlgrey_0_1` rung 128  (raw family `constant|VpiType|KIND:constant>ref_obj`)
    - L(golden) `constant@prim_fifo_sync.sv:131:29-131:38#299158`
    - R(ours)   `ref_obj(PTR_WIDTH)@:131:29-131:38#242950`
    - masked    `constant@prim_fifo_sync.sv:131:29-131:38#299158`
    - G= constant   O= ref_obj

**F81 `bit_typespec|VpiType|KIND:bit_typespec>int_typespec`** — 54 distinct objects / 54 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 68  (raw family `bit_typespec|VpiType|KIND:bit_typespec>int_typespec`)
    - L(golden) `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49#2042`
    - R(ours)   `int_typespec@:7997:11-7997:27#177668`
    - masked    `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49#2042  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= bit_typespec   O= int_typespec
  - `testflags_BuildUVMPkg` rung 68  (raw family `bit_typespec|VpiType|KIND:bit_typespec>int_typespec`)
    - L(golden) `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49#2042`
    - R(ours)   `int_typespec@:7997:11-7997:27#177668`
    - masked    `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49#2042  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= bit_typespec   O= int_typespec
  - `default_BuildUVMPkg` rung 109  (raw family `bit_typespec|VpiType|KIND:bit_typespec>int_typespec`)
    - L(golden) `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49#61573`
    - R(ours)   `int_typespec@:7981:11-7981:27#177633`
    - masked    `bit_typespec(uvm_field_flag_t)@uvm_pkg.sv:7859:9-7859:49#61573  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= bit_typespec   O= int_typespec

**F82 `constant|VpiDecompile|O-EXTRA-PREFIX`** — 41 distinct objects / 41 rungs in 2 row(s): default_Earlgrey_0_1, default_Rggen

  - `default_Earlgrey_0_1` rung 118  (raw family `constant|VpiDecompile|O-EXTRA-PREFIX(')`)
    - L(golden) `constant@tlul_adapter_sram.sv:132:18-132:20#986031`
    - R(ours)   `constant@:132:18-132:20#241820`
    - masked    `constant@tlul_adapter_sram.sv:132:18-132:20#986031`
    - G= "0"   O= "'0"
  - `default_Rggen` rung 67  (raw family `constant|VpiDecompile|O-EXTRA-PREFIX(-)`)
    - L(golden) `constant@rggen_register_common.sv:33:59-34:93#300581`
    - R(ours)   `constant@:33:59-34:93#199789`
    - masked    `constant@rggen_register_common.sv:33:59-34:93#300581`
    - G= "64"   O= "-64"
  - `default_Earlgrey_0_1` rung 119  (raw family `constant|VpiDecompile|O-EXTRA-PREFIX(')`)
    - L(golden) `constant@tlul_adapter_sram.sv:138:18-138:20#986074`
    - R(ours)   `constant@:138:18-138:20#241848`
    - masked    `constant@tlul_adapter_sram.sv:138:18-138:20#986074`
    - G= "0"   O= "'0"

**F83 `constant|VpiDecompile|DIGITS-ONLY`** — 16 distinct objects / 16 rungs in 2 row(s): default_Earlgrey_0_1, default_Rggen

  - `default_Earlgrey_0_1` rung 2  (raw family `constant|VpiDecompile|DIGITS-ONLY`)
    - L(golden) `constant@rv_core_ibex.sv:68:30-68:52#242696`
    - R(ours)   `constant@:68:30-68:52#190787`
    - masked    `constant@rv_core_ibex.sv:68:30-68:52#242696`
    - G= "32'h0"   O= "4'h0"
  - `default_Rggen` rung 1  (raw family `constant|VpiDecompile|DIGITS-ONLY`)
    - L(golden) `constant@rggen_or_reducer.sv:30:22-30:23#10103`
    - R(ours)   `constant@:30:22-30:23#10179`
    - masked    `constant@rggen_or_reducer.sv:30:22-30:23#10103`
    - G= "0"   O= "1"
  - `default_Earlgrey_0_1` rung 605  (raw family `constant|VpiDecompile|DIGITS-ONLY`)
    - L(golden) `constant@prim_fifo_sync.sv:12:40-12:41#358604`
    - R(ours)   `constant@:12:40-12:41#294501`
    - masked    `constant@prim_fifo_sync.sv:12:40-12:41#358604`
    - G= "4'h0"   O= "32'h0"

**F84 `constant|VpiType|KIND:constant>sys_func_call`** — 12 distinct objects / 12 rungs in 2 row(s): default_SeqDriver, testflags_SeqDriver

  - `default_SeqDriver` rung 324  (raw family `constant|VpiType|KIND:constant>sys_func_call`)
    - L(golden) `constant@uvm_object_defines.svh:3364:13-3364:29#311019`
    - R(ours)   `sys_func_call($bits)@:3364:13-3364:29#115790`
    - masked    `constant@uvm_object_defines.svh:3364:13-3364:29#311019`
    - G= constant   O= sys_func_call
  - `testflags_SeqDriver` rung 215  (raw family `constant|VpiType|KIND:constant>sys_func_call`)
    - L(golden) `constant@uvm_object_defines.svh:3364:13-3364:29#311031`
    - R(ours)   `sys_func_call($bits)@:3364:13-3364:29#115802`
    - masked    `constant@uvm_object_defines.svh:3364:13-3364:29#311031`
    - G= constant   O= sys_func_call
  - `default_SeqDriver` rung 325  (raw family `constant|VpiType|KIND:constant>sys_func_call`)
    - L(golden) `constant@uvm_object_defines.svh:3365:74-3365:90#311038`
    - R(ours)   `sys_func_call($bits)@:3365:74-3365:90#115801`
    - masked    `constant@uvm_object_defines.svh:3365:74-3365:90#311038`
    - G= constant   O= sys_func_call

**F85 `constant|VpiSize|INT:G>O`** — 8 distinct objects / 8 rungs in 2 row(s): default_Earlgrey_0_1, default_Rggen

  - `default_Earlgrey_0_1` rung 603  (raw family `constant|VpiSize|INT:G>O`)
    - L(golden) `constant@tlul_socket_1n.sv:126:32-126:33#358345`
    - R(ours)   `constant@:126:32-126:35#294387`
    - masked    `constant@tlul_socket_1n.sv:126:32-126:33#358345`
    - G= 64   O= 32
  - `default_Rggen` rung 5  (raw family `constant|VpiSize|INT:G>O`)
    - L(golden) `constant@rggen_adapter_common.sv:18:39-18:48#18673`
    - R(ours)   `constant@:18:39-18:48#16950`
    - masked    `constant@rggen_adapter_common.sv:18:39-18:48#18673`
    - G= 64   O= 32
  - `default_Earlgrey_0_1` rung 604  (raw family `constant|VpiSize|INT:G>O`)
    - L(golden) `constant@tlul_socket_1n.sv:127:32-127:33#358358`
    - R(ours)   `constant@:127:32-127:35#294397`
    - masked    `constant@tlul_socket_1n.sv:127:32-127:33#358358`
    - G= 64   O= 32

**F86 `hier_path|Path_elems|VEC:G>O`** — 6 distinct objects / 6 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 32  (raw family `hier_path|Path_elems|VEC:G>O`)
    - L(golden) `hier_path(m_recur_states[lhs][rhs].exists)@uvm_pkg.sv:21564:13-21564:55#10922`
    - R(ours)   `hier_path(m_recur_states[lhs][rhs].exists)@:21564:13-21564:55#12244`
    - masked    `hier_path(m_recur_states[lhs][rhs].exists)@uvm_pkg.sv:21564:13-21564:55#10922  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 3   O= 2
  - `testflags_BuildUVMPkg` rung 32  (raw family `hier_path|Path_elems|VEC:G>O`)
    - L(golden) `hier_path(m_recur_states[lhs][rhs].exists)@uvm_pkg.sv:21564:13-21564:55#10922`
    - R(ours)   `hier_path(m_recur_states[lhs][rhs].exists)@:21564:13-21564:55#12244`
    - masked    `hier_path(m_recur_states[lhs][rhs].exists)@uvm_pkg.sv:21564:13-21564:55#10922  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 3   O= 2
  - `default_BuildUVMPkg` rung 33  (raw family `hier_path|Path_elems|VEC:G>O`)
    - L(golden) `hier_path(m_recur_states[rhs][lhs].exists)@uvm_pkg.sv:18764:13-18764:55#128699`
    - R(ours)   `hier_path(m_recur_states[rhs][lhs].exists)@:18764:13-18764:55#17917`
    - masked    `hier_path(m_recur_states[rhs][lhs].exists)@uvm_pkg.sv:18764:13-18764:55#128699`
    - G= 3   O= 2

**F87 `int_typespec|VpiName|O-EMPTY`** — 6 distinct objects / 6 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 135  (raw family `int_typespec|VpiName|O-EMPTY`)
    - L(golden) `int_typespec(UVM_FILE)@uvm_pkg.sv:8459:9-8459:12#62665`
    - R(ours)   `int_typespec@:8461:11-8461:19#197`
    - masked    `int_typespec(UVM_FILE)@uvm_pkg.sv:8459:9-8459:12#62665  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "UVM_FILE"   O= 0
  - `testflags_BuildUVMPkg` rung 135  (raw family `int_typespec|VpiName|O-EMPTY`)
    - L(golden) `int_typespec(UVM_FILE)@uvm_pkg.sv:8459:9-8459:12#62665`
    - R(ours)   `int_typespec@:8461:11-8461:19#197`
    - masked    `int_typespec(UVM_FILE)@uvm_pkg.sv:8459:9-8459:12#62665  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "UVM_FILE"   O= 0
  - `default_BuildUVMPkg` rung 136  (raw family `int_typespec|VpiName|O-EMPTY`)
    - L(golden) `int_typespec(UVM_FILE)@uvm_pkg.sv:8459:9-8459:12#62681`
    - R(ours)   `int_typespec@:8462:11-8462:19#203`
    - masked    `int_typespec(UVM_FILE)@uvm_pkg.sv:8459:9-8459:12#62681  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "UVM_FILE"   O= 0

**F88 `function -> io_decl|MISSING-OURS`** — 4 distinct objects / 4 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 23  (raw family `io_decl|<rhs-null>|MISSING-OURS`)
    - L(golden) `io_decl(severity)@uvm_pkg.sv:9560:40-9560:48#4063`
    - R(ours)   `<null>`
    - masked    `function(uvm_report)@uvm_pkg.sv:9560:1-9574:12#457  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 23  (raw family `io_decl|<rhs-null>|MISSING-OURS`)
    - L(golden) `io_decl(severity)@uvm_pkg.sv:9560:40-9560:48#4063`
    - R(ours)   `<null>`
    - masked    `function(uvm_report)@uvm_pkg.sv:9560:1-9574:12#457  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_BuildUVMPkg` rung 146  (raw family `io_decl|<rhs-null>|MISSING-OURS`)
    - L(golden) `io_decl(severity)@uvm_pkg.sv:9560:40-9560:48#63817`
    - R(ours)   `<null>`
    - masked    `function(uvm_report)@uvm_pkg.sv:9560:1-9574:12#60292  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F89 `if_stmt -> begin|MISSING-OURS`** — 4 distinct objects / 4 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 65  (raw family `begin|<rhs-null>|MISSING-OURS`)
    - L(golden) `begin@uvm_pkg.sv:14059:30-14066:8#161044`
    - R(ours)   `<null>`
    - masked    `if_stmt@uvm_pkg.sv:14059:5-14066:8#161043  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 65  (raw family `begin|<rhs-null>|MISSING-OURS`)
    - L(golden) `begin@uvm_pkg.sv:14059:30-14066:8#161044`
    - R(ours)   `<null>`
    - masked    `if_stmt@uvm_pkg.sv:14059:5-14066:8#161043  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_BuildUVMPkg` rung 72  (raw family `begin|<rhs-null>|MISSING-OURS`)
    - L(golden) `begin@uvm_pkg.sv:14094:63-14100:9#161163`
    - R(ours)   `<null>`
    - masked    `if_stmt@uvm_pkg.sv:14094:6-14100:9#161162  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F90 `logic_net|VpiType|KIND:logic_net>ref_var`** — 4 distinct objects / 4 rungs in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 165  (raw family `logic_net|VpiType|KIND:logic_net>ref_var`)
    - L(golden) `logic_net(t)@:171:31-171:32#197788`
    - R(ours)   `ref_var(t)@:164:7-164:8#100987`
    - masked    `logic_net(t)@:171:31-171:32#197788`
    - G= logic_net   O= ref_var
  - `testflags_SimpleUVM` rung 165  (raw family `logic_net|VpiType|KIND:logic_net>ref_var`)
    - L(golden) `logic_net(t)@:171:31-171:32#197800`
    - R(ours)   `ref_var(t)@:164:7-164:8#100999`
    - masked    `logic_net(t)@:171:31-171:32#197800`
    - G= logic_net   O= ref_var
  - `default_SimpleUVM` rung 172  (raw family `logic_net|VpiType|KIND:logic_net>ref_var`)
    - L(golden) `logic_net(req_item)@:764:17-764:25#197800`
    - R(ours)   `ref_var(req_item)@:754:7-754:15#100415`
    - masked    `logic_net(req_item)@:764:17-764:25#197800`
    - G= logic_net   O= ref_var

**F91 `package -> +int_var|EXTRA-OURS`** — 2 distinct objects / 5 rungs in 2 row(s): default_SeqDriver, testflags_SeqDriver

  - `default_SeqDriver` rung 335  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:22:11-22:41#6431`
    - masked    `package(adpcm_pkg)@testbench.sv:10:1-207:22#183384  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_SeqDriver` rung 338  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:22:11-22:41#6443`
    - masked    `package(adpcm_pkg)@testbench.sv:10:1-207:22#183384  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_SeqDriver` rung 378  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:22:11-22:41#6431`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#59742  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F92 `class_defn -> +enum_var|EXTRA-OURS`** — 2 distinct objects / 4 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 76  (raw family `+enum_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32#3328`
    - masked    `class_defn(uvm_object_registry)@uvm_pkg.sv:13652:1-13767:9#14  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 76  (raw family `+enum_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32#3328`
    - masked    `class_defn(uvm_object_registry)@uvm_pkg.sv:13652:1-13767:9#14  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_BuildUVMPkg` rung 106  (raw family `+enum_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32#3328`
    - masked    `class_defn(uvm_root)@uvm_pkg.sv:38485:1-38740:9#118  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F93 `array_var -> bit_var|MISSING-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 12  (raw family `bit_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `bit_var@uvm_pkg.sv:21545:7-21545:18#187915`
    - R(ours)   `<null>`
    - masked    `array_var(compare_map)@uvm_pkg.sv:21545:7-21545:18#187917  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 12  (raw family `bit_var|<rhs-null>|MISSING-OURS`)
    - L(golden) `bit_var@uvm_pkg.sv:21545:7-21545:18#187915`
    - R(ours)   `<null>`
    - masked    `array_var(compare_map)@uvm_pkg.sv:21545:7-21545:18#187917  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F94 `array_var|VpiType|KIND:array_var>class_var`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 49  (raw family `array_var|VpiType|KIND:array_var>class_var`)
    - L(golden) `array_var(idx)@uvm_pkg.sv:9847:29-9847:32#191754`
    - R(ours)   `class_var(idx)@:9847:29-9847:32#5251`
    - masked    `array_var(idx)@uvm_pkg.sv:9847:29-9847:32#191754`
    - G= array_var   O= class_var
  - `testflags_BuildUVMPkg` rung 49  (raw family `array_var|VpiType|KIND:array_var>class_var`)
    - L(golden) `array_var(idx)@uvm_pkg.sv:9847:29-9847:32#191754`
    - R(ours)   `class_var(idx)@:9847:29-9847:32#5251`
    - masked    `array_var(idx)@uvm_pkg.sv:9847:29-9847:32#191754`
    - G= array_var   O= class_var

**F95 `assignment -> +logic_net|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 168  (raw family `+logic_net|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_net(seq_item_export)@:152:3-152:18#179234`
    - masked    `assignment@uvm_sequencer.svh:152:3-152:50#59302  [bisected]`
    - G= -   O= -
  - `testflags_SimpleUVM` rung 168  (raw family `+logic_net|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_net(seq_item_export)@:152:3-152:18#179246`
    - masked    `assignment@uvm_sequencer.svh:152:3-152:50#59302  [bisected]`
    - G= -   O= -

**F96 `assignment -> bit_select|MISSING-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 211  (raw family `bit_select|<rhs-null>|MISSING-OURS`)
    - L(golden) `bit_select(unpack_string)@uvm_pkg.sv:22952:7-22952:23#72450`
    - R(ours)   `<null>`
    - masked    `assignment@uvm_pkg.sv:22943:5-22943:40#72443  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 211  (raw family `bit_select|<rhs-null>|MISSING-OURS`)
    - L(golden) `bit_select(unpack_string)@uvm_pkg.sv:22952:7-22952:23#72450`
    - R(ours)   `<null>`
    - masked    `assignment@uvm_pkg.sv:22943:5-22943:40#72443  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F97 `class_defn -> +logic_net|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_SeqDriver, testflags_SeqDriver

  - `default_SeqDriver` rung 332  (raw family `+logic_net|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_net(hdl_paths_pool)@:1971:5-1971:19#293260`
    - masked    `class_defn(uvm_callback)@uvm_callback.svh:1140:1-1193:9#66  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_SeqDriver` rung 223  (raw family `+logic_net|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_net(hdl_paths_pool)@:1971:5-1971:19#293272`
    - masked    `class_defn(uvm_callback)@uvm_callback.svh:1140:1-1193:9#66  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F98 `class_defn -> +ref_typespec|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 173  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#100490`
    - masked    `class_defn(uvm_sequence_library)@uvm_sequence_library.svh:64:1-347:9#244  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_SimpleUVM` rung 173  (raw family `+ref_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_typespec@:0:0-0:0#100502`
    - masked    `class_defn(uvm_sequence_library)@uvm_sequence_library.svh:64:1-347:9#244  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F99 `class_var|VpiType|KIND:class_var>io_decl`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 48  (raw family `class_var|VpiType|KIND:class_var>io_decl`)
    - L(golden) `class_var(cs)@uvm_pkg.sv:39601:21-39601:23#186669`
    - R(ours)   `io_decl(cs)@:9785:42-9785:44#5162`
    - masked    `class_var(cs)@uvm_pkg.sv:39601:21-39601:23#186669  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= class_var   O= io_decl
  - `testflags_BuildUVMPkg` rung 48  (raw family `class_var|VpiType|KIND:class_var>io_decl`)
    - L(golden) `class_var(cs)@uvm_pkg.sv:39601:21-39601:23#186669`
    - R(ours)   `io_decl(cs)@:9785:42-9785:44#5162`
    - masked    `class_var(cs)@uvm_pkg.sv:39601:21-39601:23#186669  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= class_var   O= io_decl

**F100 `enum_typespec -> +package|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 10  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#2`
    - masked    `enum_typespec(recursion_state_e)@uvm_pkg.sv:18219:1-18223:21#144162  [bisected]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 10  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#2`
    - masked    `enum_typespec(recursion_state_e)@uvm_pkg.sv:18219:1-18223:21#144162  [bisected]`
    - G= -   O= -

**F101 `enum_var|VpiType|KIND:enum_var>class_var`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 66  (raw family `enum_var|VpiType|KIND:enum_var>class_var`)
    - L(golden) `enum_var@uvm_pkg.sv:19055:27-19055:56#146491`
    - R(ours)   `class_var@:20364:10-20364:39#52099`
    - masked    `enum_var@uvm_pkg.sv:19055:27-19055:56#146491`
    - G= enum_var   O= class_var
  - `testflags_BuildUVMPkg` rung 66  (raw family `enum_var|VpiType|KIND:enum_var>class_var`)
    - L(golden) `enum_var@uvm_pkg.sv:19055:27-19055:56#146491`
    - R(ours)   `class_var@:20364:10-20364:39#52099`
    - masked    `enum_var@uvm_pkg.sv:19055:27-19055:56#146491`
    - G= enum_var   O= class_var

**F102 `function|VpiMethod|INT:G>O`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 75  (raw family `function|VpiMethod|INT:G>O`)
    - L(golden) `function(get_default_max_ready_to_end_iterations)@uvm_pkg.sv:32619:3-32619:9#143529`
    - R(ours)   `function(get_default_max_ready_to_end_iterations)@:33672:1-33674:12#45954`
    - masked    `function(get_default_max_ready_to_end_iterations)@uvm_pkg.sv:32619:3-32619:9#143529`
    - G= 1   O= 0
  - `testflags_BuildUVMPkg` rung 75  (raw family `function|VpiMethod|INT:G>O`)
    - L(golden) `function(get_default_max_ready_to_end_iterations)@uvm_pkg.sv:32619:3-32619:9#143529`
    - R(ours)   `function(get_default_max_ready_to_end_iterations)@:33672:1-33674:12#45954`
    - masked    `function(get_default_max_ready_to_end_iterations)@uvm_pkg.sv:32619:3-32619:9#143529`
    - G= 1   O= 0

**F103 `hier_path|VpiType|KIND:hier_path>bit_select`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 80  (raw family `hier_path|VpiType|KIND:hier_path>bit_select`)
    - L(golden) `hier_path(list1[name].get_comp)@uvm_pkg.sv:45158:20-45158:42#145946`
    - R(ours)   `bit_select(list1)@:45158:26-45158:30#51478`
    - masked    `hier_path(list1[name].get_comp)@uvm_pkg.sv:45158:20-45158:42#145946`
    - G= hier_path   O= bit_select
  - `testflags_BuildUVMPkg` rung 80  (raw family `hier_path|VpiType|KIND:hier_path>bit_select`)
    - L(golden) `hier_path(list1[name].get_comp)@uvm_pkg.sv:45158:20-45158:42#145946`
    - R(ours)   `bit_select(list1)@:45158:26-45158:30#51478`
    - masked    `hier_path(list1[name].get_comp)@uvm_pkg.sv:45158:20-45158:42#145946`
    - G= hier_path   O= bit_select

**F104 `int_var|VpiType|KIND:int_var>array_var`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 244  (raw family `int_var|VpiType|KIND:int_var>array_var`)
    - L(golden) `int_var(i)@uvm_pkg.sv:56591:44-56591:45#192255`
    - R(ours)   `array_var(i)@:56591:44-56591:45#100057`
    - masked    `int_var(i)@uvm_pkg.sv:56591:44-56591:45#192255`
    - G= int_var   O= array_var
  - `testflags_BuildUVMPkg` rung 244  (raw family `int_var|VpiType|KIND:int_var>array_var`)
    - L(golden) `int_var(i)@uvm_pkg.sv:56591:44-56591:45#192255`
    - R(ours)   `array_var(i)@:56591:44-56591:45#100057`
    - masked    `int_var(i)@uvm_pkg.sv:56591:44-56591:45#192255`
    - G= int_var   O= array_var

**F105 `interface_inst -> +interface_inst|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_SeqDriver, testflags_SeqDriver

  - `default_SeqDriver` rung 394  (raw family `+interface_inst|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `interface_inst@design.sv:1:1-16:23#292117`
    - masked    `interface_inst@design.sv:1:1-16:23#328216`
    - G= -   O= -
  - `testflags_SeqDriver` rung 523  (raw family `+interface_inst|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `interface_inst@design.sv:1:1-16:23#292129`
    - masked    `interface_inst@design.sv:1:1-16:23#328228`
    - G= -   O= -

**F106 `logic_net|VpiType|KIND:logic_net>int_var`** — 2 distinct objects / 2 rungs in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 26  (raw family `logic_net|VpiType|KIND:logic_net>int_var`)
    - L(golden) `logic_net(sz)@:488:15-488:17#197713`
    - R(ours)   `int_var(sz)@:485:7-485:9#42276`
    - masked    `logic_net(sz)@:488:15-488:17#197713`
    - G= logic_net   O= int_var
  - `testflags_SimpleUVM` rung 26  (raw family `logic_net|VpiType|KIND:logic_net>int_var`)
    - L(golden) `logic_net(sz)@:488:15-488:17#197725`
    - R(ours)   `int_var(sz)@:485:7-485:9#42288`
    - masked    `logic_net(sz)@:488:15-488:17#197725`
    - G= logic_net   O= int_var

**F107 `method_func_call -> +ref_var|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 157  (raw family `+ref_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_var(orig_type_alias_per_inst)@:12754:30-12754:54#125880`
    - masked    `method_func_call(push_back)@uvm_pkg.sv:12766:24-12766:33#66159  [bisected]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 157  (raw family `+ref_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `ref_var(orig_type_alias_per_inst)@:12754:30-12754:54#125880`
    - masked    `method_func_call(push_back)@uvm_pkg.sv:12766:24-12766:33#66159  [bisected]`
    - G= -   O= -

**F108 `module_inst -> +module_inst|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_YosysVerx, testflags_YosysVerx

  - `default_YosysVerx` rung 1  (raw family `+module_inst|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `module_inst(work@vexriscv.demo.GenFull)@vexriscv.demo.GenFull.v:1059:1-7202:10#19575`
    - masked    `module_inst(work@vexriscv.demo.GenFull)@vexriscv.demo.GenFull.v:1059:1-7202:10#24206`
    - G= -   O= -
  - `testflags_YosysVerx` rung 1  (raw family `+module_inst|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `module_inst(work@vexriscv.demo.GenFull)@vexriscv.demo.GenFull.v:1059:1-7202:10#19575`
    - masked    `module_inst(work@vexriscv.demo.GenFull)@vexriscv.demo.GenFull.v:1059:1-7202:10#24206`
    - G= -   O= -

**F109 `module_inst|Typespecs|VEC:G>O`** — 2 distinct objects / 2 rungs in 2 row(s): default_SimpleUVM, testflags_SimpleUVM

  - `default_SimpleUVM` rung 397  (raw family `module_inst|~Typespecs|VEC:G>O`)
    - L(golden) `module_inst@testbench.sv:44:1-71:10#197492`
    - R(ours)   `<null>`
    - masked    `module_inst@testbench.sv:44:1-71:10#197492  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 123   O= 89
  - `testflags_SimpleUVM` rung 397  (raw family `module_inst|~Typespecs|VEC:G>O`)
    - L(golden) `module_inst@testbench.sv:44:1-71:10#197504`
    - R(ours)   `<null>`
    - masked    `module_inst@testbench.sv:44:1-71:10#197504  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 123   O= 89

**F110 `operation -> function|MISSING-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 21  (raw family `function|<rhs-null>|MISSING-OURS`)
    - L(golden) `function(get_show_max)@uvm_pkg.sv:21011:3-21011:9#125977`
    - R(ours)   `<null>`
    - masked    `operation@uvm_pkg.sv:21451:13-21451:62#126717`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 21  (raw family `function|<rhs-null>|MISSING-OURS`)
    - L(golden) `function(get_show_max)@uvm_pkg.sv:21011:3-21011:9#125977`
    - R(ours)   `<null>`
    - masked    `operation@uvm_pkg.sv:21451:13-21451:62#126717`
    - G= -   O= -

**F111 `package -> +enum_var|EXTRA-OURS`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 55  (raw family `+enum_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32#3328`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#1  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `testflags_BuildUVMPkg` rung 55  (raw family `+enum_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `enum_var(m_uvm_core_state)@:8503:16-8503:32#3328`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:7351:1-83263:11#1  [bisected]  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F112 `package|VpiName|TEXT-DIFF`** — 2 distinct objects / 2 rungs in 2 row(s): default_SeqDriver, testflags_SeqDriver

  - `default_SeqDriver` rung 165  (raw family `package|VpiName|TEXT:uvm_pkg|adpcm_pkg`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1`
    - R(ours)   `package(adpcm_pkg)@testbench.sv:10:1-207:22#3056`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg"   O= "adpcm_pkg"
  - `testflags_SeqDriver` rung 64  (raw family `package|VpiName|TEXT:uvm_pkg|adpcm_pkg`)
    - L(golden) `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1`
    - R(ours)   `package(adpcm_pkg)@testbench.sv:10:1-207:22#3068`
    - masked    `package(uvm_pkg)@uvm_pkg.sv:28:1-39:11#1  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= "uvm_pkg"   O= "adpcm_pkg"

**F113 `struct_typespec|VpiType|KIND:struct_typespec>logic_typespec`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 1  (raw family `struct_typespec|VpiType|KIND:struct_typespec>logic_typespec`)
    - L(golden) `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@uvm_pkg.sv:11947:40-11947:65#5567`
    - R(ours)   `logic_typespec@:11965:5-11965:30#18577`
    - masked    `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@uvm_pkg.sv:11947:40-11947:65#5567  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= struct_typespec   O= logic_typespec
  - `testflags_BuildUVMPkg` rung 1  (raw family `struct_typespec|VpiType|KIND:struct_typespec>logic_typespec`)
    - L(golden) `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@uvm_pkg.sv:11947:40-11947:65#5567`
    - R(ours)   `logic_typespec@:11965:5-11965:30#18577`
    - masked    `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@uvm_pkg.sv:11947:40-11947:65#5567  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= struct_typespec   O= logic_typespec

**F114 `unsupported_typespec|VpiType|KIND:unsupported_typespec>enum_typespec`** — 2 distinct objects / 2 rungs in 2 row(s): default_BuildUVMPkg, testflags_BuildUVMPkg

  - `default_BuildUVMPkg` rung 147  (raw family `unsupported_typespec|VpiType|KIND:unsupported_typespec>enum_typespec`)
    - L(golden) `unsupported_typespec(uvm_severity)@uvm_pkg.sv:9584:15-9584:27#60315`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_severity)@:8049:1-8055:16#302`
    - masked    `unsupported_typespec(uvm_severity)@uvm_pkg.sv:9584:15-9584:27#60315  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= unsupported_typespec   O= enum_typespec
  - `testflags_BuildUVMPkg` rung 147  (raw family `unsupported_typespec|VpiType|KIND:unsupported_typespec>enum_typespec`)
    - L(golden) `unsupported_typespec(uvm_severity)@uvm_pkg.sv:9584:15-9584:27#60315`
    - R(ours)   `enum_typespec(uvm_pkg::uvm_severity)@:8049:1-8055:16#302`
    - masked    `unsupported_typespec(uvm_severity)@uvm_pkg.sv:9584:15-9584:27#60315  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= unsupported_typespec   O= enum_typespec

**F115 `hier_path -> ref_typespec|MISSING-OURS`** — 1435 distinct objects / 1435 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 3  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#287442`
    - R(ours)   `<null>`
    - masked    `hier_path(tl_h_i.a_opcode)@tlul_fifo_sync.sv:38:22-38:37#287441`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 4  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#287446`
    - R(ours)   `<null>`
    - masked    `hier_path(tl_h_i.a_param)@tlul_fifo_sync.sv:39:22-39:36#287445`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 5  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#287450`
    - R(ours)   `<null>`
    - masked    `hier_path(tl_h_i.a_size)@tlul_fifo_sync.sv:40:22-40:35#287449`
    - G= -   O= -

**F116 `int_typespec|VpiType|KIND:int_typespec>integer_typespec`** — 236 distinct objects / 236 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 74  (raw family `int_typespec|VpiType|KIND:int_typespec>integer_typespec`)
    - L(golden) `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27#985050`
    - R(ours)   `integer_typespec@:72:45-72:51#235732`
    - masked    `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27#985050`
    - G= int_typespec   O= integer_typespec
  - `default_Earlgrey_0_1` rung 75  (raw family `int_typespec|VpiType|KIND:int_typespec>integer_typespec`)
    - L(golden) `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27#985061`
    - R(ours)   `integer_typespec@:73:45-73:51#235744`
    - masked    `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27#985061`
    - G= int_typespec   O= integer_typespec
  - `default_Earlgrey_0_1` rung 76  (raw family `int_typespec|VpiType|KIND:int_typespec>integer_typespec`)
    - L(golden) `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27#985065`
    - R(ours)   `integer_typespec@:73:67-73:73#235748`
    - masked    `int_typespec(DepthW)@prim_fifo_sync.sv:16:27-16:27#985065`
    - G= int_typespec   O= integer_typespec

**F117 `ref_obj -> logic_net|MISSING-OURS`** — 30 distinct objects / 30 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 81  (raw family `logic_net|<rhs-null>|MISSING-OURS`)
    - L(golden) `logic_net(rdata)@prim_fifo_sync.sv:29:27-29:32#291318`
    - R(ours)   `<null>`
    - masked    `ref_obj(rdata)@prim_fifo_sync.sv:145:14-145:19#985104`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 99  (raw family `logic_net|<rhs-null>|MISSING-OURS`)
    - L(golden) `logic_net(rdata)@prim_fifo_sync.sv:29:27-29:32#296267`
    - R(ours)   `<null>`
    - masked    `ref_obj(rdata)@prim_fifo_sync.sv:145:14-145:19#986584`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 108  (raw family `logic_net|<rhs-null>|MISSING-OURS`)
    - L(golden) `logic_net(rdata)@prim_fifo_sync.sv:29:27-29:32#296904`
    - R(ours)   `<null>`
    - masked    `ref_obj(rdata)@prim_fifo_sync.sv:145:14-145:19#986672`
    - G= -   O= -

**F118 `constant -> ref_typespec|MISSING-OURS`** — 6 distinct objects / 6 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1168  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#404128`
    - R(ours)   `<null>`
    - masked    `constant@rv_timer.sv:82:58-82:66#404126`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 1169  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#404138`
    - R(ours)   `<null>`
    - masked    `constant@rv_timer.sv:83:62-83:70#404136`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 1170  (raw family `ref_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `ref_typespec@:0:0-0:0#404150`
    - R(ours)   `<null>`
    - masked    `constant@rv_timer.sv:85:63-85:71#404148`
    - G= -   O= -

**F119 `module_inst -> +logic_var|EXTRA-OURS`** — 4 distinct objects / 4 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1340  (raw family `+logic_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_var(fifo_wptr)@:58:27-58:36#363310`
    - masked    `module_inst(u_msg_fifo)@hmac.sv:260:3-278:5#1018075  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 1349  (raw family `+logic_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_var(fifo_wptr)@:58:27-58:36#364161`
    - masked    `module_inst(u_reqfifo)@tlul_adapter_sram.sv:239:3-254:5#1018725  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 1358  (raw family `+logic_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_var(fifo_wptr)@:58:27-58:36#364656`
    - masked    `module_inst(u_maskfifo)@tlul_adapter_sram.sv:260:3-275:5#1018818  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F120 `constant|VpiDecompile|O-EXTRA-SUFFIX`** — 3 distinct objects / 3 rungs in 1 row(s): default_Rggen

  - `default_Rggen` rung 32  (raw family `constant|VpiDecompile|O-EXTRA-SUFFIX(+i)`)
    - L(golden) `constant@block_1.sv:173:42-173:43#242979`
    - R(ours)   `constant@:173:42-173:45#161588`
    - masked    `constant@block_1.sv:173:42-173:43#242979`
    - G= "2"   O= "2+i"
  - `default_Rggen` rung 36  (raw family `constant|VpiDecompile|O-EXTRA-SUFFIX(+i)`)
    - L(golden) `constant@block_1.sv:225:42-225:43#248879`
    - R(ours)   `constant@:225:42-225:45#165378`
    - masked    `constant@block_1.sv:225:42-225:43#248879`
    - G= "4"   O= "4+i"
  - `default_Rggen` rung 40  (raw family `constant|VpiDecompile|O-EXTRA-SUFFIX(+#*i+#*j+k)`)
    - L(golden) `constant@block_1.sv:280:44-280:53#254549`
    - R(ours)   `constant@:280:44-280:55#169154`
    - masked    `constant@block_1.sv:280:44-280:53#254549`
    - G= "6"   O= "6+7*i+3*j+k"

**F121 `int_typespec|VpiSigned|INT:G>O`** — 3 distinct objects / 3 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1374  (raw family `int_typespec|VpiSigned|INT:G>O`)
    - L(golden) `int_typespec@prim_packer.sv:31:14-31:17#1019031`
    - R(ours)   `int_typespec@:31:14-31:17#366092`
    - masked    `int_typespec@prim_packer.sv:31:14-31:17#1019031`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1375  (raw family `int_typespec|VpiSigned|INT:G>O`)
    - L(golden) `int_typespec@prim_packer.sv:30:14-30:17#1019051`
    - R(ours)   `int_typespec@:30:14-30:17#366113`
    - masked    `int_typespec@prim_packer.sv:30:14-30:17#1019051`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1376  (raw family `int_typespec|VpiSigned|INT:G>O`)
    - L(golden) `int_typespec@prim_packer.sv:30:14-30:17#1019064`
    - R(ours)   `int_typespec@:30:14-30:17#366127`
    - masked    `int_typespec@prim_packer.sv:30:14-30:17#1019064`
    - G= 1   O= 0

**F122 `module_inst -> +logic_net|EXTRA-OURS`** — 3 distinct objects / 3 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 90  (raw family `+logic_net|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_net(clk_i)@:11:16-11:21#238185`
    - masked    `module_inst(i_tck_inv)@dmi_jtag_tap.sv:221:3-227:5#985586  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 250  (raw family `+logic_net|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_net(host_req_i)@:16:9-16:19#249855`
    - masked    `module_inst(u_flash_eflash)@top_earlgrey.sv:471:3-481:5#989365  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 512  (raw family `+logic_net|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `logic_net(clk_i)@:11:16-11:21#285009`
    - masked    `module_inst(u_clk_spi)@spi_device.sv:317:3-317:82#997955  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F123 `param_assign|VpiOverriden|INT:G>O`** — 3 distinct objects / 3 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1139  (raw family `param_assign|VpiOverriden|INT:G>O`)
    - L(golden) `param_assign@flash_ctrl_pkg.sv:12:18-12:65#402045`
    - R(ours)   `param_assign@:12:18-12:65#330784`
    - masked    `param_assign@flash_ctrl_pkg.sv:12:18-12:65#402045`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1140  (raw family `param_assign|VpiOverriden|INT:G>O`)
    - L(golden) `param_assign@flash_ctrl_pkg.sv:13:18-13:65#402048`
    - R(ours)   `param_assign@:13:18-13:65#330790`
    - masked    `param_assign@flash_ctrl_pkg.sv:13:18-13:65#402048`
    - G= 1   O= 0
  - `default_Earlgrey_0_1` rung 1141  (raw family `param_assign|VpiOverriden|INT:G>O`)
    - L(golden) `param_assign@flash_ctrl_pkg.sv:18:18-18:57#402063`
    - R(ours)   `param_assign@:18:18-18:57#330817`
    - masked    `param_assign@flash_ctrl_pkg.sv:18:18-18:57#402063`
    - G= 1   O= 0

**F124 `ref_obj -> enum_const|MISSING-OURS`** — 2 distinct objects / 21 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 150  (raw family `enum_const|<rhs-null>|MISSING-OURS`)
    - L(golden) `enum_const(OpRead)@tlul_adapter_sram.sv:49:5-49:11#191246`
    - R(ours)   `<null>`
    - masked    `ref_obj(OpRead)@tlul_adapter_sram.sv:131:50-131:56#986839`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 152  (raw family `enum_const|<rhs-null>|MISSING-OURS`)
    - L(golden) `enum_const(OpRead)@tlul_adapter_sram.sv:49:5-49:11#191246`
    - R(ours)   `<null>`
    - masked    `ref_obj(OpRead)@tlul_adapter_sram.sv:136:68-136:74#986880`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 154  (raw family `enum_const|<rhs-null>|MISSING-OURS`)
    - L(golden) `enum_const(OpWrite)@tlul_adapter_sram.sv:48:5-48:12#191245`
    - R(ours)   `<null>`
    - masked    `ref_obj(OpWrite)@tlul_adapter_sram.sv:202:38-202:45#987090`
    - G= -   O= -

**F125 `constant|VpiConstType|INT:G>O`** — 2 distinct objects / 2 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 601  (raw family `constant|VpiConstType|INT:G>O`)
    - L(golden) `constant@prim_ram_2p_async_adv.sv:178:32-178:33#357079`
    - R(ours)   `constant@:178:32-178:33#292165`
    - masked    `constant@prim_ram_2p_async_adv.sv:178:32-178:33#357079`
    - G= 9   O= 7
  - `default_Earlgrey_0_1` rung 602  (raw family `constant|VpiConstType|INT:G>O`)
    - L(golden) `constant@prim_ram_2p_async_adv.sv:185:32-185:33#357188`
    - R(ours)   `constant@:185:32-185:33#292248`
    - masked    `constant@prim_ram_2p_async_adv.sv:185:32-185:33#357188`
    - G= 9   O= 7

**F126 `constant|VpiDecompile|G-EXTRA-PREFIX`** — 2 distinct objects / 2 rungs in 1 row(s): default_Rggen

  - `default_Rggen` rung 4  (raw family `constant|VpiDecompile|G-EXTRA-PREFIX(#'b#)`)
    - L(golden) `constant@rggen_adapter_common.sv:128:47-128:94#18537`
    - R(ours)   `constant@:128:47-128:94#16707`
    - masked    `constant@rggen_adapter_common.sv:128:47-128:94#18537`
    - G= "2'b00"   O= "0"
  - `default_Rggen` rung 25  (raw family `constant|VpiDecompile|G-EXTRA-PREFIX(#'b#)`)
    - L(golden) `constant@rggen_adapter_common.sv:128:47-128:94#233246`
    - R(ours)   `constant@:128:47-128:94#155787`
    - masked    `constant@rggen_adapter_common.sv:128:47-128:94#233246`
    - G= "2'b00"   O= "0"

**F127 `constant|VpiType|KIND:constant>func_call`** — 2 distinct objects / 2 rungs in 1 row(s): default_Rggen

  - `default_Rggen` rung 10  (raw family `constant|VpiType|KIND:constant>func_call`)
    - L(golden) `constant@rggen_adapter_common.sv:55:14-55:16#349089`
    - R(ours)   `func_call(pre_decode)@:40:27-40:53#8066`
    - masked    `constant@rggen_adapter_common.sv:55:14-55:16#349089`
    - G= constant   O= func_call
  - `default_Rggen` rung 29  (raw family `constant|VpiType|KIND:constant>func_call`)
    - L(golden) `constant@rggen_adapter_common.sv:55:14-55:16#411727`
    - R(ours)   `func_call(pre_decode)@:40:27-40:53#8066`
    - masked    `constant@rggen_adapter_common.sv:55:14-55:16#411727`
    - G= constant   O= func_call

**F128 `hier_path|VpiSize|INT:G<O`** — 2 distinct objects / 2 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1174  (raw family `hier_path|VpiSize|INT:G<O`)
    - L(golden) `hier_path(reg2hw.cfg0.prescale.q)@rv_timer.sv:56:24-56:46#1008881`
    - R(ours)   `hier_path(reg2hw.cfg0.prescale.q)@:56:24-56:46#335192`
    - masked    `hier_path(reg2hw.cfg0.prescale.q)@rv_timer.sv:56:24-56:46#1008881`
    - G= 0   O= 12
  - `default_Earlgrey_0_1` rung 1175  (raw family `hier_path|VpiSize|INT:G<O`)
    - L(golden) `hier_path(reg2hw.cfg0.step.q)@rv_timer.sv:57:24-57:42#1008889`
    - R(ours)   `hier_path(reg2hw.cfg0.step.q)@:57:24-57:42#335200`
    - masked    `hier_path(reg2hw.cfg0.step.q)@rv_timer.sv:57:24-57:42#1008889`
    - G= 0   O= 8

**F129 `param_assign|VpiOverriden|INT:G<O`** — 2 distinct objects / 2 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1137  (raw family `param_assign|VpiOverriden|INT:G<O`)
    - L(golden) `param_assign@flash_erase_ctrl.sv:41:31-41:78#401986`
    - R(ours)   `param_assign@:41:31-41:78#330915`
    - masked    `param_assign@flash_erase_ctrl.sv:41:31-41:78#401986`
    - G= 0   O= 1
  - `default_Earlgrey_0_1` rung 1138  (raw family `param_assign|VpiOverriden|INT:G<O`)
    - L(golden) `param_assign@flash_erase_ctrl.sv:42:31-42:96#401987`
    - R(ours)   `param_assign@:42:31-42:96#330920`
    - masked    `param_assign@flash_erase_ctrl.sv:42:31-42:96#401987`
    - G= 0   O= 1

**F130 `module_inst -> enum_const|MISSING-OURS`** — 1 distinct objects / 7 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 155  (raw family `enum_const|<rhs-null>|MISSING-OURS`)
    - L(golden) `enum_const(OpRead)@tlul_adapter_sram.sv:49:5-49:11#191246`
    - R(ours)   `<null>`
    - masked    `module_inst(u_tl_adapter_rom)@top_earlgrey.sv:350:3-371:5#986765  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 191  (raw family `enum_const|<rhs-null>|MISSING-OURS`)
    - L(golden) `enum_const(OpRead)@tlul_adapter_sram.sv:49:5-49:11#191246`
    - R(ours)   `<null>`
    - masked    `module_inst(u_tl_adapter_ram_main)@top_earlgrey.sv:397:3-416:5#987637  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -
  - `default_Earlgrey_0_1` rung 228  (raw family `enum_const|<rhs-null>|MISSING-OURS`)
    - L(golden) `enum_const(OpRead)@tlul_adapter_sram.sv:49:5-49:11#191246`
    - R(ours)   `<null>`
    - masked    `module_inst(u_tl_adapter_eflash)@top_earlgrey.sv:447:3-469:5#988544  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F131 `class_defn -> +class_typespec|EXTRA-OURS`** — 1 distinct objects / 1 rungs in 1 row(s): default_Scoreboard

  - `default_Scoreboard` rung 401  (raw family `+class_typespec|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `class_typespec(type_id)@:483:12-483:34#180233`
    - masked    `class_defn(work@my_scoreboard)@design.sv:7:1-24:9#330  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F132 `int_typespec|VpiType|KIND:int_typespec>logic_typespec`** — 1 distinct objects / 1 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 71  (raw family `int_typespec|VpiType|KIND:int_typespec>logic_typespec`)
    - L(golden) `int_typespec@:0:0-0:0#288957`
    - R(ours)   `logic_typespec@:0:0-0:0#765149`
    - masked    `int_typespec@:0:0-0:0#288957`
    - G= int_typespec   O= logic_typespec

**F133 `logic_typespec -> package|MISSING-OURS`** — 1 distinct objects / 1 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 82  (raw family `package|<rhs-null>|MISSING-OURS`)
    - L(golden) `package(dm)@dm_pkg.sv:19:1-414:16#16`
    - R(ours)   `<null>`
    - masked    `logic_typespec@dm_pkg.sv:34:14-34:26#292571`
    - G= -   O= -

**F134 `logic_typespec|VpiType|KIND:logic_typespec>bit_typespec`** — 1 distinct objects / 1 rungs in 1 row(s): default_Rggen

  - `default_Rggen` rung 15  (raw family `logic_typespec|VpiType|KIND:logic_typespec>bit_typespec`)
    - L(golden) `logic_typespec@:0:0-0:0#36547`
    - R(ours)   `bit_typespec@:450:18-450:27#253985`
    - masked    `logic_typespec@:0:0-0:0#36547`
    - G= logic_typespec   O= bit_typespec

**F135 `module_inst|Variables|VEC:G<O`** — 1 distinct objects / 1 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1385  (raw family `module_inst|Variables|VEC:G<O`)
    - L(golden) `module_inst(u_pad)@sha2.sv:290:3-312:5#1019494`
    - R(ours)   `module_inst(u_pad)@sha2.sv:290:3-312:5#367308`
    - masked    `module_inst(u_pad)@sha2.sv:290:3-312:5#1019494  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= 8   O= 9

**F136 `operation|Operands|VEC:G>O`** — 1 distinct objects / 1 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1381  (raw family `operation|Operands|VEC:G>O`)
    - L(golden) `operation@hmac_core.sv:119:5-119:19#1019373`
    - R(ours)   `operation@:119:5-119:19#366826`
    - masked    `operation@hmac_core.sv:119:5-119:19#1019373`
    - G= 2   O= 1

**F137 `operation|VpiOpType|INT:G<O`** — 1 distinct objects / 1 rungs in 1 row(s): default_Earlgrey_0_1

  - `default_Earlgrey_0_1` rung 1281  (raw family `operation|VpiOpType|INT:G<O`)
    - L(golden) `operation@aes_key_expand.sv:109:39-109:69#1014805`
    - R(ours)   `operation@:109:24-109:74#355790`
    - masked    `operation@aes_key_expand.sv:109:39-109:69#1014805`
    - G= 30   O= 32

**F138 `ref_obj -> +int_var|EXTRA-OURS`** — 1 distinct objects / 1 rungs in 1 row(s): default_Scoreboard

  - `default_Scoreboard` rung 402  (raw family `+int_var|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `int_var(UVM_UNBOUNDED_CONNECTIONS)@:22:11-22:41#3817`
    - masked    `ref_obj(UVM_UNBOUNDED_CONNECTIONS)@uvm_analysis_port.svh:60:43-60:68#121550  [bisected]`
    - G= -   O= -

**F139 `ref_typespec -> class_typespec|MISSING-OURS`** — 1 distinct objects / 1 rungs in 1 row(s): default_Scoreboard

  - `default_Scoreboard` rung 207  (raw family `class_typespec|<rhs-null>|MISSING-OURS`)
    - L(golden) `class_typespec(uvm_analysis_imp)@design.sv:9:3-9:19#194630`
    - R(ours)   `<null>`
    - masked    `ref_typespec@:0:0-0:0#194641  [CASCADE: this mask hides >=1% of the golden database for every later rung]`
    - G= -   O= -

**F140 `ref_var -> +package|EXTRA-OURS`** — 1 distinct objects / 1 rungs in 1 row(s): testflags_SeqDriver

  - `testflags_SeqDriver` rung 504  (raw family `+package|<lhs-null>|EXTRA-OURS`)
    - L(golden) `<null>`
    - R(ours)   `package(adpcm_pkg)@testbench.sv:10:1-207:22#181567`
    - masked    `ref_var(t)@uvm_component.svh:3546:28-3546:29#80998  [bisected]`
    - G= -   O= -

## RAW FAMILIES (kind | field | value shape)

| rank | rows | distinct objects | rungs | family |
|---:|---:|---:|---:|---|
| 1 | 9 | 29 | 29 | `constant\|VpiType\|KIND:constant>operation` |
| 2 | 8 | 1477 | 1477 | `ref_typespec\|<rhs-null>\|MISSING-OURS` |
| 3 | 8 | 94 | 94 | `ref_obj\|VpiType\|KIND:ref_obj>constant` |
| 4 | 8 | 71 | 155 | `+ref_typespec\|<lhs-null>\|EXTRA-OURS` |
| 5 | 8 | 9 | 9 | `constant\|VpiConstType\|INT:G<O` |
| 6 | 7 | 170 | 170 | `sys_func_call\|VpiType\|KIND:sys_func_call>constant` |
| 7 | 7 | 71 | 74 | `+class_var\|<lhs-null>\|EXTRA-OURS` |
| 8 | 7 | 69 | 96 | `function\|<rhs-null>\|MISSING-OURS` |
| 9 | 7 | 54 | 54 | `ref_obj\|VpiType\|KIND:ref_obj>hier_path` |
| 10 | 7 | 35 | 93 | `+enum_const\|<lhs-null>\|EXTRA-OURS` |
| 11 | 7 | 30 | 30 | `io_decl\|<rhs-null>\|MISSING-OURS` |
| 12 | 7 | 30 | 30 | `method_func_call\|<rhs-null>\|MISSING-OURS` |
| 13 | 7 | 29 | 29 | `class_typespec\|VpiName\|O-EMPTY` |
| 14 | 7 | 26 | 48 | `+int_var\|<lhs-null>\|EXTRA-OURS` |
| 15 | 7 | 22 | 22 | `+int_typespec\|<lhs-null>\|EXTRA-OURS` |
| 16 | 7 | 15 | 15 | `class_var\|<rhs-null>\|MISSING-OURS` |
| 17 | 7 | 14 | 70 | `+string_var\|<lhs-null>\|EXTRA-OURS` |
| 18 | 7 | 12 | 12 | `ref_obj\|VpiName\|G-EXTRA-SUFFIX(_name)` |
| 19 | 7 | 12 | 12 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX(_name)` |
| 20 | 7 | 11 | 11 | `+io_decl\|<lhs-null>\|EXTRA-OURS` |
| 21 | 7 | 11 | 11 | `function\|VpiName\|G-EXTRA-PREFIX(uvm_root::)` |
| 22 | 7 | 10 | 10 | `named_fork\|VpiJoinType\|INT:G>O` |
| 23 | 7 | 10 | 10 | `ref_obj\|<rhs-null>\|MISSING-OURS` |
| 24 | 7 | 8 | 8 | `bit_select\|VpiType\|KIND:bit_select>bit_var` |
| 25 | 7 | 7 | 7 | `class_typespec\|VpiName\|TEXT:rsp_type\|uvm_sequence_item` |
| 26 | 7 | 7 | 7 | `class_typespec\|VpiName\|TEXT:uvm_object\|T` |
| 27 | 7 | 7 | 7 | `class_typespec\|VpiName\|TEXT:uvm_sequence_item\|RSP` |
| 28 | 7 | 7 | 7 | `enum_typespec\|VpiName\|G-EXTRA-SUFFIX(_enum)` |
| 29 | 7 | 7 | 7 | `hier_path\|VpiName\|TEXT:m_streams[].exists\|m_streams[ro.get_name()].exists` |
| 30 | 7 | 7 | 7 | `logic_var\|<rhs-null>\|MISSING-OURS` |
| 31 | 7 | 7 | 7 | `ref_obj\|VpiType\|KIND:ref_obj>operation` |
| 32 | 7 | 7 | 7 | `ref_var\|VpiType\|KIND:ref_var>logic_var` |
| 33 | 7 | 7 | 7 | `string_var\|VpiType\|KIND:string_var>io_decl` |
| 34 | 6 | 63 | 63 | `constant\|VpiSize\|INT:G<O` |
| 35 | 6 | 16 | 16 | `ref_var\|VpiType\|KIND:ref_var>class_var` |
| 36 | 6 | 14 | 14 | `begin\|Stmts\|VEC:G<O` |
| 37 | 6 | 10 | 10 | `class_var\|VpiAutomatic\|INT:G>O` |
| 38 | 6 | 6 | 6 | `bit_var\|VpiAutomatic\|INT:G<O` |
| 39 | 6 | 6 | 6 | `constant\|VpiDecompile\|TEXT:#\|"."` |
| 40 | 6 | 6 | 6 | `hier_path\|VpiName\|TEXT:m_children[].get_type_name\|m_children[child.get_name()].get_type_name` |
| 41 | 6 | 6 | 6 | `hier_path\|VpiName\|TEXT:m_streams[].exists\|m_streams[stream.get_name()].exists` |
| 42 | 6 | 6 | 6 | `hier_path\|VpiName\|TEXT:m_streams[].size\|m_streams[stream.get_name()].size` |
| 43 | 6 | 6 | 6 | `method_func_call\|VpiName\|TEXT:delete\|get_name()]` |
| 44 | 6 | 6 | 6 | `ref_var\|VpiType\|KIND:ref_var>hier_path` |
| 45 | 6 | 6 | 6 | `string_var\|VpiAutomatic\|INT:G<O` |
| 46 | 5 | 902 | 902 | `parameter\|VpiImported\|O-EMPTY` |
| 47 | 5 | 23 | 23 | `constant\|VpiType\|KIND:constant>hier_path` |
| 48 | 5 | 21 | 21 | `event_stmt\|VpiName\|O-EMPTY` |
| 49 | 5 | 20 | 20 | `constant\|VpiDecompile\|TEXT:"UVM.#.#"\|"UVM-#.#"` |
| 50 | 5 | 18 | 18 | `unsupported_typespec\|VpiType\|KIND:unsupported_typespec>class_typespec` |
| 51 | 5 | 16 | 16 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([original_type])` |
| 52 | 5 | 15 | 15 | `method_func_call\|VpiType\|KIND:method_func_call>hier_path` |
| 53 | 5 | 10 | 10 | `func_call\|VpiType\|KIND:func_call>hier_path` |
| 54 | 5 | 10 | 10 | `method_func_call\|VpiName\|TEXT:this\|sequences` |
| 55 | 5 | 8 | 8 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([obj])` |
| 56 | 5 | 8 | 8 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([original_type_name])` |
| 57 | 5 | 8 | 8 | `ref_obj\|VpiName\|O-EXTRA-SUFFIX([rtype])` |
| 58 | 5 | 7 | 7 | `+logic_net\|<lhs-null>\|EXTRA-OURS` |
| 59 | 5 | 5 | 5 | `class_var\|VpiType\|KIND:class_var>ref_var` |
| 60 | 5 | 5 | 5 | `operation\|<rhs-null>\|MISSING-OURS` |
| 61 | 5 | 5 | 5 | `package\|<rhs-null>\|MISSING-OURS` |
| 62 | 5 | 5 | 5 | `ref_obj\|VpiType\|KIND:ref_obj>func_call` |
| 63 | 5 | 5 | 5 | `string_var\|<rhs-null>\|MISSING-OURS` |
| 64 | 4 | 4 | 12 | `+package\|<lhs-null>\|EXTRA-OURS` |
| 65 | 4 | 4 | 4 | `hier_path\|VpiName\|TEXT:c.objection.m_scheduled_contexts[]\|c.objection.m_scheduled_contexts[c.obj]` |
| 66 | 3 | 64 | 64 | `parameter\|VpiType\|KIND:parameter>constant` |
| 67 | 3 | 14 | 14 | `parameter\|VpiType\|KIND:parameter>operation` |
| 68 | 3 | 10 | 10 | `+ref_var\|<lhs-null>\|EXTRA-OURS` |
| 69 | 3 | 9 | 9 | `constant\|<rhs-null>\|MISSING-OURS` |
| 70 | 3 | 6 | 9 | `function\|~Typespecs\|VEC:G>O` |
| 71 | 3 | 6 | 6 | `operation\|VpiType\|KIND:operation>constant` |
| 72 | 3 | 4 | 4 | `module_inst\|Variables\|VEC:G>O` |
| 73 | 3 | 3 | 7 | `+package\|~Typespecs\|VEC:G>O` |
| 74 | 3 | 3 | 3 | `chandle_var\|<rhs-null>\|MISSING-OURS` |
| 75 | 3 | 3 | 3 | `class_defn\|VpiName\|TEXT:uvm_algorithmic_comparator\|uvm_sequence_library` |
| 76 | 3 | 3 | 3 | `design\|Typespecs\|VEC:G>O` |
| 77 | 3 | 3 | 3 | `hier_path\|VpiName\|O-EXTRA-SUFFIX(.randomize)` |
| 78 | 3 | 3 | 3 | `package\|~Typespecs\|VEC:G>O` |
| 79 | 2 | 1330 | 1330 | `constant\|VpiType\|KIND:constant>ref_obj` |
| 80 | 2 | 54 | 54 | `bit_typespec\|VpiType\|KIND:bit_typespec>int_typespec` |
| 81 | 2 | 28 | 28 | `constant\|VpiDecompile\|TEXT:#\|int` |
| 82 | 2 | 16 | 16 | `constant\|VpiDecompile\|DIGITS-ONLY` |
| 83 | 2 | 12 | 12 | `constant\|VpiType\|KIND:constant>sys_func_call` |
| 84 | 2 | 8 | 8 | `constant\|VpiSize\|INT:G>O` |
| 85 | 2 | 8 | 8 | `hier_path\|VpiName\|TEXT:packer.m_bits[+:#]\|packer.m_bits[]` |
| 86 | 2 | 6 | 6 | `enum_const\|VpiDecompile\|TEXT:# << #\|#<<#` |
| 87 | 2 | 6 | 6 | `hier_path\|Path_elems\|VEC:G>O` |
| 88 | 2 | 6 | 6 | `int_typespec\|VpiName\|O-EMPTY` |
| 89 | 2 | 4 | 4 | `begin\|<rhs-null>\|MISSING-OURS` |
| 90 | 2 | 4 | 4 | `logic_net\|VpiType\|KIND:logic_net>ref_var` |
| 91 | 2 | 4 | 4 | `logic_typespec\|VpiName\|O-EXTRA-PREFIX(uvm_pkg::)` |
| 92 | 2 | 2 | 6 | `+enum_var\|<lhs-null>\|EXTRA-OURS` |
| 93 | 2 | 2 | 2 | `+interface_inst\|<lhs-null>\|EXTRA-OURS` |
| 94 | 2 | 2 | 2 | `+module_inst\|<lhs-null>\|EXTRA-OURS` |
| 95 | 2 | 2 | 2 | `array_var\|VpiType\|KIND:array_var>class_var` |
| 96 | 2 | 2 | 2 | `bit_select\|<rhs-null>\|MISSING-OURS` |
| 97 | 2 | 2 | 2 | `bit_var\|<rhs-null>\|MISSING-OURS` |
| 98 | 2 | 2 | 2 | `class_defn\|VpiName\|TEXT:uvm_abstract_component_registry\|uvm_sequence_library` |
| 99 | 2 | 2 | 2 | `class_typespec\|VpiName\|TEXT:uvm_component\|STRUCTURE` |
| 100 | 2 | 2 | 2 | `class_var\|VpiType\|KIND:class_var>io_decl` |
| 101 | 2 | 2 | 2 | `enum_const\|VpiDecompile\|TEXT:-#\|#` |
| 102 | 2 | 2 | 2 | `enum_var\|VpiType\|KIND:enum_var>class_var` |
| 103 | 2 | 2 | 2 | `function\|VpiMethod\|INT:G>O` |
| 104 | 2 | 2 | 2 | `function\|VpiName\|G-EXTRA-PREFIX(uvm_printer::)` |
| 105 | 2 | 2 | 2 | `hier_path\|VpiName\|TEXT:gp.m_byte_enable[i % ]\|gp.m_byte_enable[i % gp.m_byte_enable_length…` |
| 106 | 2 | 2 | 2 | `hier_path\|VpiType\|KIND:hier_path>bit_select` |
| 107 | 2 | 2 | 2 | `int_var\|VpiType\|KIND:int_var>array_var` |
| 108 | 2 | 2 | 2 | `logic_net\|VpiType\|KIND:logic_net>int_var` |
| 109 | 2 | 2 | 2 | `module_inst\|~Typespecs\|VEC:G>O` |
| 110 | 2 | 2 | 2 | `package\|VpiName\|TEXT:uvm_pkg\|adpcm_pkg` |
| 111 | 2 | 2 | 2 | `struct_typespec\|VpiType\|KIND:struct_typespec>logic_typespec` |
| 112 | 2 | 2 | 2 | `unsupported_typespec\|VpiType\|KIND:unsupported_typespec>enum_typespec` |
| 113 | 1 | 236 | 236 | `int_typespec\|VpiType\|KIND:int_typespec>integer_typespec` |
| 114 | 1 | 40 | 40 | `constant\|VpiDecompile\|O-EXTRA-PREFIX(')` |
| 115 | 1 | 32 | 32 | `hier_path\|VpiName\|TEXT:reg#hw.ctrl_en_input_filter.q[#]\|reg#hw.ctrl_en_input_filter.q[i]` |
| 116 | 1 | 30 | 30 | `logic_net\|<rhs-null>\|MISSING-OURS` |
| 117 | 1 | 24 | 24 | `hier_path\|VpiName\|TEXT:register_if[#].value[#+:#]\|register_if[#+#*i+#].value[# + # * l+:#]` |
| 118 | 1 | 11 | 11 | `constant\|VpiDecompile\|TEXT:#\|#+#*i+#*j+k` |
| 119 | 1 | 7 | 7 | `logic_typespec\|VpiName\|O-EXTRA-PREFIX(hmac_pkg::)` |
| 120 | 1 | 6 | 6 | `constant\|VpiDecompile\|TEXT:#\|-#` |
| 121 | 1 | 4 | 4 | `+logic_var\|<lhs-null>\|EXTRA-OURS` |
| 122 | 1 | 3 | 3 | `constant\|VpiDecompile\|TEXT:#\|#'b#` |
| 123 | 1 | 3 | 3 | `constant\|VpiDecompile\|TEXT:#\|'#` |
| 124 | 1 | 3 | 3 | `hier_path\|VpiName\|TEXT:reg#hw.addr.q[#+:#]\|reg#hw.addr.q[DataBitWidth+:#]` |
| 125 | 1 | 3 | 3 | `int_typespec\|VpiSigned\|INT:G>O` |
| 126 | 1 | 3 | 3 | `param_assign\|VpiOverriden\|INT:G>O` |
| 127 | 1 | 2 | 28 | `enum_const\|<rhs-null>\|MISSING-OURS` |
| 128 | 1 | 2 | 2 | `class_typespec\|VpiName\|TEXT:adpcm_seq_item\|adpcm_tx_seq` |
| 129 | 1 | 2 | 2 | `constant\|VpiConstType\|INT:G>O` |
| 130 | 1 | 2 | 2 | `constant\|VpiDecompile\|G-EXTRA-PREFIX(#'b#)` |
| 131 | 1 | 2 | 2 | `constant\|VpiDecompile\|O-EXTRA-SUFFIX(+i)` |
| 132 | 1 | 2 | 2 | `constant\|VpiDecompile\|TEXT:#\|#+#*i+#` |
| 133 | 1 | 2 | 2 | `constant\|VpiDecompile\|TEXT:#\|#+i` |
| 134 | 1 | 2 | 2 | `constant\|VpiType\|KIND:constant>func_call` |
| 135 | 1 | 2 | 2 | `hier_path\|VpiSize\|INT:G<O` |
| 136 | 1 | 2 | 2 | `param_assign\|VpiOverriden\|INT:G<O` |
| 137 | 1 | 1 | 1 | `+class_typespec\|<lhs-null>\|EXTRA-OURS` |
| 138 | 1 | 1 | 1 | `class_typespec\|<rhs-null>\|MISSING-OURS` |
| 139 | 1 | 1 | 1 | `constant\|VpiDecompile\|O-EXTRA-PREFIX(-)` |
| 140 | 1 | 1 | 1 | `constant\|VpiDecompile\|O-EXTRA-SUFFIX(+#*i+#*j+k)` |
| 141 | 1 | 1 | 1 | `constant\|VpiDecompile\|TEXT:#'hab\|#` |
| 142 | 1 | 1 | 1 | `constant\|VpiDecompile\|TEXT:-#\|#'b#` |
| 143 | 1 | 1 | 1 | `int_typespec\|VpiType\|KIND:int_typespec>logic_typespec` |
| 144 | 1 | 1 | 1 | `logic_typespec\|VpiType\|KIND:logic_typespec>bit_typespec` |
| 145 | 1 | 1 | 1 | `module_inst\|Variables\|VEC:G<O` |
| 146 | 1 | 1 | 1 | `operation\|Operands\|VEC:G>O` |
| 147 | 1 | 1 | 1 | `operation\|VpiOpType\|INT:G<O` |

## COARSE FAMILIES (kind | field)

| rank | rows | distinct objects | rungs | family |
|---:|---:|---:|---:|---|
| 1 | 9 | 1396 | 1396 | `constant\|VpiType` |
| 2 | 9 | 145 | 145 | `constant\|VpiDecompile` |
| 3 | 9 | 101 | 101 | `hier_path\|VpiName` |
| 4 | 8 | 1477 | 1477 | `ref_typespec\|<rhs-null>` |
| 5 | 8 | 160 | 160 | `ref_obj\|VpiType` |
| 6 | 8 | 71 | 155 | `+ref_typespec\|<lhs-null>` |
| 7 | 8 | 11 | 11 | `constant\|VpiConstType` |
| 8 | 7 | 170 | 170 | `sys_func_call\|VpiType` |
| 9 | 7 | 71 | 74 | `+class_var\|<lhs-null>` |
| 10 | 7 | 71 | 71 | `constant\|VpiSize` |
| 11 | 7 | 69 | 96 | `function\|<rhs-null>` |
| 12 | 7 | 64 | 64 | `ref_obj\|VpiName` |
| 13 | 7 | 54 | 54 | `class_typespec\|VpiName` |
| 14 | 7 | 35 | 93 | `+enum_const\|<lhs-null>` |
| 15 | 7 | 30 | 30 | `io_decl\|<rhs-null>` |
| 16 | 7 | 30 | 30 | `method_func_call\|<rhs-null>` |
| 17 | 7 | 29 | 29 | `ref_var\|VpiType` |
| 18 | 7 | 26 | 48 | `+int_var\|<lhs-null>` |
| 19 | 7 | 22 | 22 | `+int_typespec\|<lhs-null>` |
| 20 | 7 | 16 | 16 | `method_func_call\|VpiName` |
| 21 | 7 | 15 | 15 | `class_var\|<rhs-null>` |
| 22 | 7 | 14 | 70 | `+string_var\|<lhs-null>` |
| 23 | 7 | 13 | 13 | `function\|VpiName` |
| 24 | 7 | 11 | 11 | `+io_decl\|<lhs-null>` |
| 25 | 7 | 10 | 10 | `named_fork\|VpiJoinType` |
| 26 | 7 | 10 | 10 | `ref_obj\|<rhs-null>` |
| 27 | 7 | 8 | 8 | `bit_select\|VpiType` |
| 28 | 7 | 7 | 7 | `enum_typespec\|VpiName` |
| 29 | 7 | 7 | 7 | `logic_var\|<rhs-null>` |
| 30 | 7 | 7 | 7 | `string_var\|VpiType` |
| 31 | 6 | 14 | 14 | `begin\|Stmts` |
| 32 | 6 | 10 | 10 | `class_var\|VpiAutomatic` |
| 33 | 6 | 6 | 6 | `bit_var\|VpiAutomatic` |
| 34 | 6 | 6 | 6 | `string_var\|VpiAutomatic` |
| 35 | 5 | 902 | 902 | `parameter\|VpiImported` |
| 36 | 5 | 21 | 21 | `event_stmt\|VpiName` |
| 37 | 5 | 20 | 20 | `unsupported_typespec\|VpiType` |
| 38 | 5 | 15 | 15 | `method_func_call\|VpiType` |
| 39 | 5 | 10 | 10 | `func_call\|VpiType` |
| 40 | 5 | 7 | 7 | `+logic_net\|<lhs-null>` |
| 41 | 5 | 7 | 7 | `class_var\|VpiType` |
| 42 | 5 | 5 | 5 | `class_defn\|VpiName` |
| 43 | 5 | 5 | 5 | `operation\|<rhs-null>` |
| 44 | 5 | 5 | 5 | `package\|<rhs-null>` |
| 45 | 5 | 5 | 5 | `string_var\|<rhs-null>` |
| 46 | 4 | 8 | 8 | `enum_const\|VpiDecompile` |
| 47 | 4 | 4 | 12 | `+package\|<lhs-null>` |
| 48 | 3 | 78 | 78 | `parameter\|VpiType` |
| 49 | 3 | 11 | 11 | `logic_typespec\|VpiName` |
| 50 | 3 | 10 | 10 | `+ref_var\|<lhs-null>` |
| 51 | 3 | 9 | 9 | `constant\|<rhs-null>` |
| 52 | 3 | 6 | 9 | `function\|~Typespecs` |
| 53 | 3 | 6 | 6 | `operation\|VpiType` |
| 54 | 3 | 5 | 5 | `module_inst\|Variables` |
| 55 | 3 | 3 | 7 | `+package\|~Typespecs` |
| 56 | 3 | 3 | 3 | `chandle_var\|<rhs-null>` |
| 57 | 3 | 3 | 3 | `design\|Typespecs` |
| 58 | 3 | 3 | 3 | `package\|~Typespecs` |
| 59 | 2 | 54 | 54 | `bit_typespec\|VpiType` |
| 60 | 2 | 6 | 6 | `hier_path\|Path_elems` |
| 61 | 2 | 6 | 6 | `int_typespec\|VpiName` |
| 62 | 2 | 6 | 6 | `logic_net\|VpiType` |
| 63 | 2 | 4 | 4 | `begin\|<rhs-null>` |
| 64 | 2 | 2 | 6 | `+enum_var\|<lhs-null>` |
| 65 | 2 | 2 | 2 | `+interface_inst\|<lhs-null>` |
| 66 | 2 | 2 | 2 | `+module_inst\|<lhs-null>` |
| 67 | 2 | 2 | 2 | `array_var\|VpiType` |
| 68 | 2 | 2 | 2 | `bit_select\|<rhs-null>` |
| 69 | 2 | 2 | 2 | `bit_var\|<rhs-null>` |
| 70 | 2 | 2 | 2 | `enum_var\|VpiType` |
| 71 | 2 | 2 | 2 | `function\|VpiMethod` |
| 72 | 2 | 2 | 2 | `hier_path\|VpiType` |
| 73 | 2 | 2 | 2 | `int_var\|VpiType` |
| 74 | 2 | 2 | 2 | `module_inst\|~Typespecs` |
| 75 | 2 | 2 | 2 | `package\|VpiName` |
| 76 | 2 | 2 | 2 | `struct_typespec\|VpiType` |
| 77 | 1 | 237 | 237 | `int_typespec\|VpiType` |
| 78 | 1 | 30 | 30 | `logic_net\|<rhs-null>` |
| 79 | 1 | 5 | 5 | `param_assign\|VpiOverriden` |
| 80 | 1 | 4 | 4 | `+logic_var\|<lhs-null>` |
| 81 | 1 | 3 | 3 | `int_typespec\|VpiSigned` |
| 82 | 1 | 2 | 28 | `enum_const\|<rhs-null>` |
| 83 | 1 | 2 | 2 | `hier_path\|VpiSize` |
| 84 | 1 | 1 | 1 | `+class_typespec\|<lhs-null>` |
| 85 | 1 | 1 | 1 | `class_typespec\|<rhs-null>` |
| 86 | 1 | 1 | 1 | `logic_typespec\|VpiType` |
| 87 | 1 | 1 | 1 | `operation\|Operands` |
| 88 | 1 | 1 | 1 | `operation\|VpiOpType` |

