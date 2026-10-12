# r11u298 — pass 298, expression/parameter ground: four cast and bound-span laws

Base 458cb4cb (pass 296). Production surface: src/ExprEmit.cpp and the new src/R298.h only.
Pristine build md5 f084a2ac85ffae8db05ce180440a60ed (equal to the main tree's build at the base);
law build md5 40dd231d0aaafb50a19ac7e91165026a. Both binaries were frozen before any measurement.

## Verdict

- **One probe conversion:** r10earl31repro/v4_ops `differ:endcol(4)` -> EQUAL
  (fresh csv row `r10earl31repro/v4_ops,EQUAL,,equal`).
  This is § pkgQualBoundSpanTernary298, predicted by name in the firing census.
- **No corpus row moves:**
  - surelog: default 480 + 0, testflags 474 + 0.
  - uhdm2rtlil: 803/1/67 in both modes.
  - 0 of 2560 corpus databases and 0 of 805 downstream databases move in bytes.
- **Downstream:** 803/66/2/0, and the csv is byte-identical to results/downstream_uhdm2rtlil.csv.
- **Gate:** probe 3972 EQUAL + 115 STRICT_NOTEQUAL, with regressions 0, conversions 1 and changes 0.
- **Earlier-pass residues converted** (control case-views; no tests/probe case among them):
  - v11u294repro/cases/VM/vm13_nested d/e: stage 1 cmp62 -> STRICT_EQUAL. This is pass 294's ranked residue 1.
  - v11u292repro/cases/VC/vc06_tp_nested_cls d/e: line -> STRICT_EQUAL.

## Laws (all in src/ExprEmit.cpp, switches in src/R298.h)

`R11U298_OFF` drops every law and gives pristine's bytes on 136 of 136 grid case-views.
`R11U298_TRACE=<dir>` logs every firing, switch-off and abstention.

1. **§ nestedCastOuterTpPlaceholder298** — switch `R11U298_NESTCASTTP_OFF`.
   - **The shape:** a cast in a module NESTED inside another module, to the OUTER module's type parameter:
     `module top #(type T=logic [2:0]); module inner; assign z = T'(b); endmodule ... endmodule`.
   - **What golden writes:** in the elaborated instance, Surelog's unresolved placeholder: an unsupported_typespec named T at the cast token.
     The definition listing (work@top::inner) keeps the outer default logic_typespec that § castModTypeParamDefaultTs294 binds.
   - **Distinguisher:** syntactic. The cast's nearest module, interface or program declaration is not the declaration of the type parameter's definition. The law fires only in emitInstance's content (castSiteScope57 set).
   - **Only the first elaborated emission of the cast takes the placeholder.** A second instance of the nested module (NC/nc03 u2, nc15 u2/u3, nc16 u[1]) or of its outer (nc08 o2) binds the default again, as golden does.
   - **It abstains in a parameter initializer.** Golden NC/nc19 `localparam logic [2:0] K = T'(5)` keeps K's own declaration typespec. A draft without this abstention moved nc19 from line to type; it was fixed before the law binary was frozen.
2. **§ pkgQualBoundSpanTernary298** — switch `R11U298_QBTERN_OFF`.
   - **The rule it extends:** § pkgQualBoundSpanQualifier192's walk from a folded `pkg::P` up to a part_select now crosses a conditional operator, unless the fold sits in the conditional's TRUE branch.
   - **What golden writes:** r10earl31repro/v4_ops `d[(pk::DC ? pk::DC : pk::DC)-1:0]` spans the condition's and the false branch's fold `pk::` alone (24:17-21, 24:35-39), and the true branch's the whole name (24:26-32).
     This is the same split § psBoundPkgParamTs31 reads for the typespec stamp (ternTrueArmOps31).
   - **Where it stays away:** a bit-select index, an indexed part-select base or width, a declaration dimension and a replication count (QT/qt11, qt18, qt19: unmoved).
3. **§ castClsTpOwnDefaultObj298** — switch `R11U298_CLSTPOBJ_OFF`.
   - **The shape:** a cast to a CLASS's type parameter whose default is not a predefined integer keyword: a logic or bit vector, a scalar, a signed or two-dimensional packed type, real, shortreal, string, or a class.
   - **What golden writes:** the binding of the type parameter's OWN typespec object, the one under the class_defn listing's type_parameter.
     Golden r11u292repro CT/ct05 U'(3) -> logic_typespec 4:39-50 with its range; CP/cp09 real_typespec at the default; CP/cp10 class_typespec base at the default.
     Ours minted a bare logic_typespec at the written name.
   - **How it binds:** the object is read from § typeParamUseSharesOwnTs183's registry (g_typeParamOwnTs183, UhdmExporter.cpp; read only). It is not re-parented and not instance-stamped (tpShared121).
   - **Integer keywords** keep § castTypeParamDefaultLoc292's located copy.
4. **§ castClsTpOutOfBodyPlaceholder298** — switch `R11U298_CLSTPOOB_OFF`. `R11U298_CLSTPOBJ_OFF` also drops it.
   - **The shape:** the same cast written in an OUT-OF-BODY method definition (`function void gen::f(); y = U'(3); endfunction`; its syntax has no ClassDeclaration ancestor).
   - **What golden writes:** the unresolved placeholder, an unsupported_typespec named after the written name at the cast token, with the package instance stamp. Golden CP/cp20, cp24, cp25.
   - **What it overrides:** for an integer-keyword default it overrides pass 292's located copy (cp24 `T'(3)` with `type T = int`).
   - **Why it exists:** without it, law 3 moved cp20 from 22 to 62 uhdm-cmp lines (pristine minted logic at the token). Found by the fresh attack cases and fixed before the final freeze.

## Grid (cases/NC, QT, CP: 68 case dirs, 136 case-views, every line with its exit code)

drivers/gridall.sh pristine/law/law+R11U298_OFF/law+each switch -> evidence/grid.txt. drivers/gridsum.py -> evidence/grid_summary.txt:

- **Movers:** 110 case-views move.
  - 87 enter STRICT_EQUAL and 0 leave it.
  - 0 exit codes change.
  - 30 uhdm-cmp line counts change, every one downward: 62/24/22 -> 0, and nc08 d 62 -> 17. No count grows.
  - R11U298_OFF equals pristine on 136 of 136.
- **Attribution** (drivers/attrib.py -> evidence/grid_attrib.txt): every mover is restored by a single switch.
  - CLSTPOBJ 42, NESTCASTTP 28, QBTERN 34.
  - CLSTPOBJ+CLSTPOOB 6: cp20, cp24 and cp25 are restored by CLSTPOOB alone or by CLSTPOBJ.
- **Away census** (drivers/awaygrid.sh with strictcmp_x and awaychain.py; evidence/grid_away.txt):
  - Chain away 0 on all 110 movers, with 316 records toward golden.
  - **Positive control** (binaries swapped, 12 sampled movers; evidence/away_poscontrol.txt): away 1 to 7 on 12 of 12.
- **Stage-1 movers** (both binaries stage 1, moved toward golden, away 0):
  - cp04, cp07, cp16, cp18, cp23.
  - nc08 d, nc13, nc18.
  - qt10, qt20.
  - nc11 goes stage 1 -> type and passes uhdm-cmp.
- **Downstream** (drivers/dscases.py, evidence/downstream_cases.txt): no verdict change on any of the 68 case dirs on either binary.
  - 66 IDENTICAL.
  - CP/cp23 DIVERGENT on both binaries.
  - QT/qt22 SLANG_REJECT on both binaries: an implicit net named by a port connection; slang rejects it.

| case | law | shape | default view pristine -> law | elaborated view pristine -> law |
|---|---|---|---|---|
| NC/nc01_nested | § nestedCastOuterTpPlaceholder298 | a cast in a nested module to the outer module type parameter | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc02_override | § nestedCastOuterTpPlaceholder298 | the outer module overridden from a parent | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc03_twice | § nestedCastOuterTpPlaceholder298 | the nested module instantiated twice | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc04_own_tp | § nestedCastOuterTpPlaceholder298 | control: the nested module's own type parameter (the law must not fire) | rc0 fullname cmp0 -> rc0 fullname cmp0 | rc0 fullname cmp0 -> rc0 fullname cmp0 |
| NC/nc05_outer_ctl | § nestedCastOuterTpPlaceholder298 | control: a cast in the outer module itself | rc0 EQ cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| NC/nc06_process | § nestedCastOuterTpPlaceholder298 | the cast in an always_comb of the nested module | rc0 EQ cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| NC/nc07_genif | § nestedCastOuterTpPlaceholder298 | the cast in an if-generate of the nested module | rc0 EQ cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| NC/nc08_two_outers | § nestedCastOuterTpPlaceholder298 | the outer instantiated twice with different overrides | rc0 stage1 cmp62 -> rc0 stage1 cmp17 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc09_int_default | § nestedCastOuterTpPlaceholder298 | an int default on the outer type parameter | rc0 stage1 cmp24 -> rc0 EQ cmp0 | rc0 stage1 cmp24 -> rc0 EQ cmp0 |
| NC/nc10_port_use | § nestedCastOuterTpPlaceholder298 | the outer type parameter also typing the outer port | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc11_iface_outer | § nestedCastOuterTpPlaceholder298 | a cast in a module nested in a module, the outer's localparam type | rc4 stage1 cmp22 -> rc4 type cmp0 | rc4 stage1 cmp22 -> rc4 type cmp0 |
| NC/nc12_func | § nestedCastOuterTpPlaceholder298 | the cast in a function of the nested module | rc0 EQ cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| NC/nc13_depth2 | § nestedCastOuterTpPlaceholder298 | the nested module instantiated below another instance | rc0 stage1 cmp58 -> rc0 stage1 cmp58 | rc0 stage1 cmp58 -> rc0 stage1 cmp58 |
| NC/nc14_macro | § nestedCastOuterTpPlaceholder298 | the cast written through a macro | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc15_thrice | § nestedCastOuterTpPlaceholder298 | the nested module instantiated three times | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc16_array | § nestedCastOuterTpPlaceholder298 | an instance array of the nested module | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc17_two_casts | § nestedCastOuterTpPlaceholder298 | two casts in one nested module, one instance | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| NC/nc18_genfor | § nestedCastOuterTpPlaceholder298 | the nested module instantiated in a for-generate | rc0 stage1 cmp58 -> rc0 stage1 cmp58 | rc0 stage1 cmp58 -> rc0 stage1 cmp58 |
| NC/nc19_localparam | § nestedCastOuterTpPlaceholder298 | constant slot: the cast in a nested module's localparam initializer | rc0 line cmp0 -> rc0 line cmp0 | rc0 line cmp0 -> rc0 line cmp0 |
| NC/nc20_bound | § nestedCastOuterTpPlaceholder298 | constant slot: the cast in a part-select bound and a replication count | rc0 stage1 cmp62 -> rc0 EQ cmp0 | rc0 stage1 cmp62 -> rc0 EQ cmp0 |
| QT/qt01_proc | § pkgQualBoundSpanTernary298 | a ternary in a part-select bound in a process | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt02_contassign | § pkgQualBoundSpanTernary298 | a ternary in a part-select bound in a continuous assignment | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt03_right_bound | § pkgQualBoundSpanTernary298 | the ternary on the right bound | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt04_nested_tern | § pkgQualBoundSpanTernary298 | a ternary nested in the false branch and in the true branch | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt05_bare_tern | § pkgQualBoundSpanTernary298 | the ternary as the whole bound | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt06_func | § pkgQualBoundSpanTernary298 | a ternary bound in a function body | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt07_genfor | § pkgQualBoundSpanTernary298 | a ternary bound in a for-generate process | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt08_port_conn | § pkgQualBoundSpanTernary298 | a ternary bound in a port connection | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt09_nda | § pkgQualBoundSpanTernary298 | a ternary bound in a net declaration assignment | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| QT/qt10_hier | § pkgQualBoundSpanTernary298 | a ternary bound on a struct member select | rc0 stage1 cmp316 -> rc0 stage1 cmp316 | rc0 stage1 cmp316 -> rc0 stage1 cmp316 |
| QT/qt11_bitsel_ctl | § pkgQualBoundSpanTernary298 | control: a ternary in a bit-select index and an indexed part-select base | rc0 EQ cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| QT/qt12_param_init | § pkgQualBoundSpanTernary298 | control: a ternary bound in a parameter initializer | rc0 stage1 cmp17 -> rc0 stage1 cmp17 | rc0 stage1 cmp17 -> rc0 stage1 cmp17 |
| QT/qt13_import | § pkgQualBoundSpanTernary298 | a wildcard import beside the qualified reads, and an unqualified read | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt14_macro | § pkgQualBoundSpanTernary298 | the ternary written through a macro | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt15_local_cond | § pkgQualBoundSpanTernary298 | a local parameter as the condition, qualified branches | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt16_class | § pkgQualBoundSpanTernary298 | a ternary bound in a class method | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| QT/qt17_lhs | § pkgQualBoundSpanTernary298 | a ternary bound on an assignment target | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| QT/qt18_dim_ctl | § pkgQualBoundSpanTernary298 | control: a ternary in a declaration dimension and a replication count | rc0 stage1 cmp34 -> rc0 stage1 cmp34 | rc0 stage1 cmp34 -> rc0 stage1 cmp34 |
| QT/qt19_ips_ctl | § pkgQualBoundSpanTernary298 | control: a ternary as an indexed part-select width | rc0 stage1 cmp17 -> rc0 stage1 cmp17 | rc0 stage1 cmp17 -> rc0 stage1 cmp17 |
| QT/qt20_interface | § pkgQualBoundSpanTernary298 | a ternary bound in an interface body and through an interface port | rc0 stage1 cmp320 -> rc0 stage1 cmp320 | rc0 stage1 cmp320 -> rc0 stage1 cmp320 |
| QT/qt21_this_path | § pkgQualBoundSpanTernary298 | a ternary bound on a this. path in a class method | rc0 EQ cmp0 -> rc0 EQ cmp0 | rc0 EQ cmp0 -> rc0 EQ cmp0 |
| QT/qt22_implicit | § pkgQualBoundSpanTernary298 | a ternary bound on an implicit net in a port connection and a named call argument | rc3 NODB cmp- -> rc3 NODB cmp- | rc3 NODB cmp- -> rc3 NODB cmp- |
| QT/qt23_nested_select | § pkgQualBoundSpanTernary298 | a ternary bound inside another select's index and inside a cast in a concatenation | rc0 endcol cmp0 -> rc0 EQ cmp0 | rc0 endcol cmp0 -> rc0 EQ cmp0 |
| CP/cp01_logic_vec | § castClsTpOwnDefaultObj298 | a cast to a class type parameter defaulting to a logic vector | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp02_bit_vec | § castClsTpOwnDefaultObj298 | a cast to a class type parameter defaulting to a bit vector | rc0 type cmp0 -> rc0 EQ cmp0 | rc0 type cmp0 -> rc0 EQ cmp0 |
| CP/cp03_mixed_int | § castClsTpOwnDefaultObj298 | an int default beside a vector default (the integer keyword keeps pass 292's copy) | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp04_typedef | § castClsTpOwnDefaultObj298 | a typedef default (the class listing's own object is the sister's ground) | rc0 stage1 cmp126 -> rc0 stage1 cmp126 | rc0 stage1 cmp126 -> rc0 stage1 cmp126 |
| CP/cp05_spec_override | § castClsTpOwnDefaultObj298 | a specialization overriding the vector default, used from a module | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp06_module_class | § castClsTpOwnDefaultObj298 | a class declared in a module with a vector type parameter default | rc4 type cmp0 -> rc4 type cmp0 | rc4 type cmp0 -> rc4 type cmp0 |
| CP/cp07_two_casts | § castClsTpOwnDefaultObj298 | two casts to the same vector type parameter and a variable of that type | rc0 stage1 cmp51 -> rc0 stage1 cmp51 | rc0 stage1 cmp51 -> rc0 stage1 cmp51 |
| CP/cp08_signed_vec | § castClsTpOwnDefaultObj298 | a signed logic vector default | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp09_real_default | § castClsTpOwnDefaultObj298 | a real default (the law abstains) | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp10_nodefault_cls | § castClsTpOwnDefaultObj298 | a class default (the law abstains) | rc0 type cmp0 -> rc0 EQ cmp0 | rc0 type cmp0 -> rc0 EQ cmp0 |
| CP/cp11_derived | § castClsTpOwnDefaultObj298 | a derived class passing its vector type parameter to the base | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp12_static_fn | § castClsTpOwnDefaultObj298 | a cast in a static function and in a constructor | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp13_logic_scalar | § castClsTpOwnDefaultObj298 | a scalar logic default and a parameter-sized vector default | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp14_multi_dim | § castClsTpOwnDefaultObj298 | a two-dimensional packed default | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp15_string | § castClsTpOwnDefaultObj298 | a string default | rc0 type cmp0 -> rc0 EQ cmp0 | rc0 type cmp0 -> rc0 EQ cmp0 |
| CP/cp16_shortreal | § castClsTpOwnDefaultObj298 | a shortreal default and a realtime default | rc0 stage1 cmp20 -> rc0 stage1 cmp20 | rc0 stage1 cmp20 -> rc0 stage1 cmp20 |
| CP/cp17_cls_param_default | § castClsTpOwnDefaultObj298 | a parameterized class default | rc0 type cmp0 -> rc0 EQ cmp0 | rc0 type cmp0 -> rc0 EQ cmp0 |
| CP/cp18_localparam | § castClsTpOwnDefaultObj298 | constant slot: a cast in a class localparam initializer and a replication count | rc0 stage1 cmp17 -> rc0 stage1 cmp17 | rc0 stage1 cmp17 -> rc0 stage1 cmp17 |
| CP/cp19_partsel | § castClsTpOwnDefaultObj298 | constant slot: a cast in a part-select bound inside a class method | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp20_extern | § castClsTpOutOfBodyPlaceholder298 | an extern method body (out of the class) casting to the vector type parameter | rc0 stage1 cmp22 -> rc0 EQ cmp0 | rc0 stage1 cmp22 -> rc0 EQ cmp0 |
| CP/cp21_pure_virtual | § castClsTpOwnDefaultObj298 | a pure virtual prototype above an implementation casting to the type parameter | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp22_this_path | § castClsTpOwnDefaultObj298 | a cast of a this. path and a cast in a select bound of a this. path | rc0 line cmp0 -> rc0 EQ cmp0 | rc0 line cmp0 -> rc0 EQ cmp0 |
| CP/cp23_spec_in_bound | § castClsTpOwnDefaultObj298 | a class specialization's static method called in a module part-select bound | rc0 stage1 cmp26 -> rc0 stage1 cmp26 | rc0 stage1 cmp26 -> rc0 stage1 cmp26 |
| CP/cp24_extern_int | § castClsTpOutOfBodyPlaceholder298 | an extern method body casting to an int and a real type parameter | rc0 stage1 cmp24 -> rc0 EQ cmp0 | rc0 stage1 cmp24 -> rc0 EQ cmp0 |
| CP/cp25_extern_module_cls | § castClsTpOutOfBodyPlaceholder298 | an extern task body in a class of a package, a typedef default and a vector default | rc0 stage1 cmp22 -> rc0 EQ cmp0 | rc0 stage1 cmp22 -> rc0 EQ cmp0 |

## Byte controls (drivers/controls.sh, evidence/controls.txt, controls_summary.txt, controls_away.txt)

**Scope:** 19 earlier repro dirs in both views, 2564 case-views:
r11u294, v11u294, r11u292, v11u292, r11u192, r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u131, r11v131, r11u124, r11v124, r11u113, r11u296, v11u296, r11u288 and v11u288.
This covers pass 118's, 119's, 120's, 124's and 131's grids, as the brief requires.

**Result:** 8 case-views move. 4 enter STRICT_EQUAL, 0 leave it, 0 exit codes change, and every mover reads away 0.

- v11u294repro VM/vm13_nested d/e: stage1 cmp62 -> STRICT_EQUAL (NESTCASTTP); toward 1.
- v11u292repro VC/vc06_tp_nested_cls d/e: line -> STRICT_EQUAL (CLSTPOBJ); toward 9.
- r11u292repro CT/ct05_tp_kinds d/e: stage 1 on both; toward 4.
  The U'(3) cast now binds the default object.
  The remaining head is the class listing's own object for `type V = n_t` (golden: a typedef clone `n_t` with a typedef alias; ours: the package listing object p::n_t). That listing is UhdmExporter emitClassParameters, the sister's ground.
- v11u292repro VC/vc03_tp_more d/e: stage 1 on both; toward 1.

## Firing census (evidence/predict.txt, frozen before the law sweep)

drivers/tracecensus.sh ran the frozen law binary under R11U298_TRACE over the 4087 probe cases and both corpora in both modes. The filter was built from $FENCED.

- **Probe:** exactly one database fires a law: r10earl31repro/v4_ops (pkgQualBoundSpanTernary298 x2).
- **Abstentions only (move nothing):** r10earl31repro/v3_tern, plus BlackBePipeInt and Earlgrey_0_1 in both modes. These are folds in a conditional's TRUE branch inside a bound.
- **Never fires on any corpus row or probe case:** the cast laws (1, 3, 4). No corpus or probe source casts to a nested outer's or a class's type parameter in those shapes.
- **Prediction met:** byteverify confirms the single predicted probe mover and 0 corpus movers.

## Gates (evidence/gates.txt, sweep_P.log, sweep_L.log)

1. **Builds:** pristine f084a2ac (equal to the main tree's build/slang-uhdm), law 40dd231d. Both are frozen under /tmp/r11u298_bin.
2. **Probe:** pristine 3971 + 116 with regressions 0. Law 3972 + 115: regressions 0, conversions 1 (v4_ops), changes 0.
3. **Corpora:**
   - surelog 480 + 0 / 474 + 0: regressions 0, conversions 0, changes 0.
   - uhdm2rtlil 803/1/67 in both modes: regressions 0, conversions 0, changes 0. stamped_gen_param d/t stays CMP_NOTEQUAL.
4. **Downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, and the csv is byte-identical to the committed one.
5. **uhdm-cmp:** 0 lines on v4_ops in both views. No corpus row moves.
6. **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered mirrors /tmp/r11u298_mrL vs /tmp/r11u298_mrP, drivers/mirror.sh, 8 fenced paths skipped by name in each):
   - PATH_SETS_IDENTICAL with 2560 paths, MOVERS 0 / 2560.
   - SELFCHECK reads 2559 / 2560. This is the self-check's own artefact: it compares every file against one fixed file, and that fixed file is never flagged against itself. It is not a mover.
   - Probe databases: 1 of 4087 moves (v4_ops, predicted).
   - Downstream slang-lane databases: 0 of 805 move.
7. **Canaries:**
   - surelog: ok=52, changed=0.
   - uhdm2rtlil: ok=16, changed=0.
   - ctcan2 surelog: PASS (EXPECT_UNKNOWN=1).
   - ctcan2 uhdm2rtlil: PASS (EXPECT_UNKNOWN=6).
8. **Binary-path audit** (drivers/audit.sh): every cmds.txt names its own sweep's binary. surelog own=1523 other=0 noslang=50; uhdm2rtlil own=1742 other=0 (both sweeps).
9. **Determinism** (drivers/det.sh, evidence/determinism.txt): three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen.
   - One hash per row-mode, each equal to the law sweep's database.
   - Scoreboard/testflags and Rggen/testflags write no database, as in the base.
10. **Law index:** both sweeps exit 1 on the law-index check alone (stale tests/LAWS.md for the new case files). The patch carries the regenerated tests/LAWS.md.

## Residues, ranked (all wrong on pristine too)

1. **The return fold of a package function in the elaborated package listing** — the probe bucket v9fold8, v3_argts8, v3_clone13, a1 and va8 (5 cases). DECODED, NOT WRITTEN.
   - **Where it shows:** uhdmtopPackages.
   - **What Surelog does:** it compiles a top-level `return` with Reduce::Yes (StmtEmit § pkgRetTopCallArgFormalTs8's window). CompileExpression's user-call branch calls EvalFunc (UHDM ExprEval::evalFunc). When that returns a non-null, non-invalid result, the func_call is replaced by it.
   - **The result:** for `return foldable(a)` with `foldable` = `return a + 1;` it is the CALLEE's own return-expression object (shared: uhdm-dump prints only its header, and the strict walk skips it). The same holds for `nofold_sys(s) == 0`, whose operand becomes the callee's `$urandom()` sys_func_call (v3_argts8 c2).
   - **What stays a func_call:** a callee whose return is a DPI call (c1) and a callee with a multi-statement body (c3, the foreach).
   - **What a law needs:** a model of evalFunc's invalid/valid split, plus a registry of each package function's elaborated-listing return expression (written in StmtEmit, consumed in ExprEmit's user-call branch under pkgRetTopExpr8 / pkgRetFoldExpr30).
2. **Law 1's unreached nested shapes** (stage 1 on both binaries):
   - A nested module instantiated below another nested module or in a for-generate (NC/nc13, nc18). Golden has no elaborated nested instance there and writes the placeholder in the DEFINITION listing.
   - nc08 d, whose remaining head is a missing logic_net in the nested definition listing work@outer::inner (ModuleEmit, the sister's nested-module ground).
   - nc11, a cast to an outer `localparam type T` (exit 4 on both binaries, the § castModTypeParamDefaultTs294 mt09 abstention with no default entry). The elaborated part converts; the definition listing reads integer_typespec where golden has the default.
3. **Law 3's unreached shapes:**
   - A typedef default (`type V = n_t`, CP/cp04, CT/ct05 V): the listing's own object, the sister's (above).
   - Two casts beside a variable of the type (cp07: golden gives the logic_var its own copy).
   - shortreal/realtime defaults (cp16).
   - A class localparam initializer and replication count (cp18).
   - A specialization's static method in a module bound (cp23).
   - A class in a module (cp06, exit 4 on both binaries, unmoved).
4. **Law 2's unreached shapes:**
   - A struct-member select through a module-local struct variable (QT/qt10).
   - An interface body and a path through an interface instance (qt20).
   - A parameter initializer (qt12; the 192 gate excludes inParamInit).
   - All stage 1 on both binaries.
5. **The brief's items not attempted:**
   - r11u117repro/grid/g1/t12. The rebinding of the path base after unparenting is not found.
   - The rest of items (2) to (7).

## Sister-ground faces (reported, not written)

- **r10vrgg17repro/v8 fullname(4).**
  - Ours: the def-view port-connection path `arr[6+7*i].value[0+:4]` parents the index operation at the bit_select, so the reader's ComputeFullName adds `.arr`.
  - Golden: parents it at the hier_path.
  - Ours also names the indexed_part_select with the raw text `arr[6+7*i]...` where golden writes the decompiled `arr[6 + 7 * i]...`.
  - Writer: TypeEmit emitSyntaxExpr called from ModuleEmit emitDefGenStmts (gdb backtrace on the release binary: no ref_obj::VpiFullName set reaches `...arr.i`, so the name is the reader's from the parent chain).
- **r10earl54repro/v13_v54 fullname(2).** A bind's port actual `sel` binds `work@v13_v54.sel` in golden. This is the bound-instance binding in ModuleEmit.
- **CT/ct05 and CP/cp04.** The class listing's own typespec object for a typedef default (UhdmExporter emitClassParameters).
- **The nested-module definition listing nets of NC/nc08 d** (ModuleEmit).

## Process

- **Fence:** every driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh (drivers/env.sh). Every corpus path list was filtered by $FENCED before any file was opened (mirror.sh, audit.sh, the probe and downstream cmp loops). No fenced name is spelled anywhere here.
- **gdb:** ran only on a probe case (r10vrgg17repro/v8).
- **The IMPLEMENTER'S SLIPS (no effect on any number):**
  - Three refinements went in after a first frozen law binary and its census and grid. These were the parameter-initializer abstention of law 1, then law 4 and its integer-default extension.
  - In each case the census, grid, controls and law sweep were rerun in full on the final frozen binary (40dd231d). Each census run was stopped by its task id.
  - The first law sweep had been chained after the pristine sweep in one background shell. Only that chain's two shell processes (this pass's own, checked by command line) were killed; the pristine sweep ran to completion alone.
- **Other agents:** no other agent's process was touched, and nothing was written to the main tree.

## Files

- drivers/: env.sh, case.sh, views.sh, gridall.sh, gridsum.py, attrib.py, controls.sh, ctlsum.py, tracecensus.sh, away.py, awaychain.py, awayrows.py, awaygrid.sh, awaycorp.sh, strictcmp_x.cpp, cc_x.sh, dscases.py, det.sh, audit.sh, mirror.sh, residue.py, dump.sh, classify.py, chains.py. All are copied from r11u294repro/v11u294repro with this pass's names.
- evidence/: grid*.txt, controls*.txt, away_poscontrol.txt, predict.txt, gates.txt, determinism.txt, downstream_cases.txt, residue_first_records_base.txt (the 116 residues' first strict records at the base) and sweep_P.log / sweep_L.log.
