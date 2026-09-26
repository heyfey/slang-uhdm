# v11u176: adversarial verification of r11u176 (the module/type ground, pair B): ACCEPT-WITH-FIX, one break of § tdMoveKeyResolved176 refined by § tdKeyKeepsUnresolved176v

Base `72fd3061` (branch matrix-1.87). Verified: the implementer's patch (r11u176: r11u175's
§ externProtoFormalsFromPrototype175 plus fourteen laws of its own in `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`). The verified patch adds one refinement in `src/TypeEmit.cpp`
(the implementer's own ground) and this directory; nothing under `results/`, `tests/probe/`, `third_party/` or the
sister's files (`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`) is edited, and
`tests/LAWS.md` is regenerated.

The slang-fenced tests are written `FENCED=` here and never spelled. `drivers/env.sh` reads `$FENCED` from
RESUME.md and fails closed; every driver that reads corpus sources or databases refuses a fenced path by word
boundary (`drivers/mirror.sh` hard-links the corpus databases into fence-clean mirrors, 8 fenced row-mode
databases left out; `drivers/boundary.sh` drops fenced paths; `drivers/row.sh` refuses a fenced row). No fenced
test was run, read or decoded outside the gate sweeps, which dispatch every row themselves. gdb was not used.

## 1. Binaries (built in fresh worktrees at `72fd3061`, `-j 2`, system deps; frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `fdef3ad724d1655e4f9aa3b8a169655d` | pristine worktree build = the main tree's `build/slang-uhdm` |
| `law.bin` | `24e6c4dc65d673d6d6d98ed966ef1e80` | the implementer's patch as delivered (= its `final4.bin`) |
| `ver2.bin` | `98e591bd3ca38e6c42e7a851497197e5` | + § tdKeyKeepsUnresolved176v (the verified patch) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

(`ver1.bin`, the first build of the refinement, segfaulted on `cases/TT/t3` and `t4`: the filtered site was a
block-scoped object that `pick` still pointed into; it was never swept and `ver2.bin` holds it at loop scope.)
Every sweep's corpus `cmds.txt` names its own binary on all 3273 `slang:` lines (`swP` pris.bin, `swL` law.bin,
`swV` ver2.bin).

## 2. The implementer's headline numbers, reproduced bit for bit

Sweeps `tests/sweep.sh --jobs 3`, all four stages: `/tmp/v11u176_swP` (pris.bin), `/tmp/v11u176_swL` (law.bin),
`/tmp/v11u176_swV` (ver2.bin). Summaries: `evidence/sweep_sw{P,L,V}_summary.txt`. Every sweep exits 1 only for
`law index STALE` (the base reads it too; the patch carries the regenerated `tests/LAWS.md`).

| gate | pristine `swP` | law `swL` (implementer's `swI`) | verified `swV` |
|---|---|---|---|
| probe vs golden_probe.csv | 0/0/0, EQUAL 2768, STRICT_NOTEQUAL 1319 | regressions 0, conversions 61, changes 30 (EQUAL 2829) | identical to `swL` |
| surelog vs golden_surelog.csv | 0/0/0 | regressions 0, conversions 5, changes 16 | identical to `swL` |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0/0/0 | regressions 0, conversions 0, changes 2 (ibex_pmp d/t) | identical to `swL` |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; `downstream.csv` byte-identical to `swP` | byte-identical to `swP` |

The csvs of `swP` and `swL` equal the implementer's `swP` and `swI` line for line (only the LowMem detail text,
which carries the workdir path, differs); `swV`'s four csvs equal `swL`'s. The five conversions, quoted from `swV`:

    OneNetModPort,default,CMP_EQUAL,,,equal          (was differ:file(3))
    OneNetModPort,testflags,CMP_EQUAL,,,equal        (was differ:file(3))
    OneNetModPortGeneric,default,CMP_EQUAL,,,equal   (was differ:line(2))
    OneNetModPortGeneric,testflags,CMP_EQUAL,,,equal (was differ:line(2))
    UnsizedParam,default,CMP_EQUAL,,,equal           (was differ:fullname(2))

Every CHANGE row moves toward golden (`evidence/rows_orderblind_P_L.txt`, `drivers/row.sh`: first record, object
counts, and the order-blind record distance = strict records as multisets, depth dropped): BuildUVMPkg d/t first
record #873 -> #1135, 14,833 -> 5,431; MiniAmiq d/t #573 -> #770, 53,273 -> 44,429; SeqDriver d #556 -> #753,
42,605 -> 33,161; SimpleUVM d #458 (same record) 20,344 -> 10,594; Scoreboard d #466 (same) 18,002 -> 8,638;
FuncStructVal d/t 1,372 -> 1,360 / 2,209 -> 2,031; FuncStructValSimple d/t 94 -> 82 / 138 -> 122; InterfaceModPort
d/t 47 -> 24; ibex_pmp d/t 152 -> 24; ApbSlave d/t 88 -> 12; Rggen d 17,674 -> 17,193 (objects 311,774 -> 312,249 of
golden's 314,498); Scr1SvTests d/t 263 -> 261. **SVSwitch d/t fullname(11) -> fullname(18) grows because the walk
diverges later** (`evidence/svswitch_records_P_L.txt`, the full differing-record lists): pristine differs at #101,
#184, #264, #651, #756, #980, the program-port file faces #1397/#1399/#1401, #1951 and diverges at #3314 (depth);
the law keeps every record before #3314 except the three file faces, and the walk now runs to #3398, exposing
nine pre-existing reference full names and one column at #3375-#3394; order-blind 127 -> 112.

The six probe CHANGE rows whose first field changed also move toward golden (first record later, fewer records):
r10buvm15repro/a1_collargs15 #243 -> #414 (ob 14 -> 2), r10buvm21repro/g21b #7 -> #40 (92 -> 52), g21c #6 -> #92
(70 -> 24), r10uvm114repro/g114_f_twopkg #118 -> #264 (31 -> 7; the walk diverged on both), r10v150repro/v150_f1
#15 -> #54 (8 -> 4), v150_g #42 -> #106 (6 -> 2). The other 24 changes print a count decrease.

Canaries (`tools/probe/r11u107repro/canaries.sh` against the committed baselines): surelog `swP` ok=52 changed=0,
`swL` ok=40 changed=12 (exactly the CHANGE rows above: InterfaceModPort d/t, FuncStructVal t, SVSwitch d/t,
SimpleUVM d/t, SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d); uhdm2rtlil ok=16 changed=0 on both;
`EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.

Byte movers (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-clean mirrors of 2560 databases each,
PATH_SETS_IDENTICAL, SELFCHECK 2559/2560): `swL` vs `swP` **30 movers**, the implementer's 30 by name
(`evidence/byteverify_L_vs_P.txt`), all inside its 44-name prediction; probe **116 movers** of 4087, the implementer's
116. The implementer's grid (`tools/probe/r11u176repro/cases`, 105 cases, `drivers/case.sh` with goldens from the
pinned Surelog): strict-equal **28 -> 80**, reproduced; the only stage-1 count that moves is PG/g18 (432 -> strict-equal).

Boundary (`drivers/boundary.sh`: every `tools/probe/**/dut.sv` of the base tree, fenced paths refused, the three
binaries, children on `</dev/null`): **listed 9078, processed 9078: 8905 SAME, 68 MOVER, 105 NODB** (the same 3
segfaults on all three binaries: r10v226repro b13_modportproc, r11v105repro v09_A_nested_program_in_sub,
v11u112repro brk2/k/m07_hdr_enum_default). The 68 movers judged against golden (`evidence/boundary_movers_judged.txt`,
`boundary_movers_orderblind.txt`): 21 STRICT_NOTEQUAL -> STRICT_EQUAL, 2 NOT_EQUAL -> STRICT_EQUAL, 1 NOT_EQUAL ->
STRICT_NOTEQUAL, 3 STRICT_EQUAL on both, 9 STRICT_NOTEQUAL on both and 32 NOT_EQUAL on both, every one toward golden or
identity-only; v11u171 Q/c07 and c12 read farther by a sorted-dump count (56 -> 63, 67 -> 78) but the in-order dump
diff shrinks (c07 102 -> 63 lines): the swallowed concatenation is gone and the elaborated HighConns now read golden's,
the remaining lines being the definition view's missing ref_module (sister, residue below) listed once more.

## 3. The break: § tdMoveKeyResolved176 dropped a module writer at the shared position

§ tdMoveKeyResolved176 keys a relocated typedef's formal site on the typedef a PACKAGE formal's bare name resolves
to, so the law's site holds package formals only. A module (or interface) subroutine formal written with the same
bare name at the same line and column in another file is not in that site, although it is a writer of the same
object and Surelog compiles it after the package: golden files the object at the module's file, as pristine did.

| case (`cases/TT`) | shape | pristine | r11u176 | verified |
|---|---|---|---|---|
| t3_modfunc_vs_pkgfunc | `pb::f(s_t v)` in b_pkg.sv and module `dut`'s `g(s_t v)` (import pa::*) at 4:30 | STRICT_EQUAL (dut.sv) | **STRICT_NOTEQUAL file(10)**: b_pkg.sv | STRICT_EQUAL, pristine bytes |
| t8_ifacefunc_vs_pkgfunc | the same with an interface function | SN fullname, first #167 (an unrelated reference full name) | **first record #13 file** (b_pkg.sv, golden ifc.sv) | pristine bytes |
| t4_explicit_import_key | `import pa::s_t;` / `import pz::s_t;` package formals at one position | SN file | STRICT_EQUAL | STRICT_EQUAL (the law's gain kept) |
| t9_order_reversed | t3 with dut.sv before b_pkg.sv in the file list | SN file (b_pkg.sv, golden dut.sv) | the same | the same (residue 2) |

**§ tdKeyKeepsUnresolved176v** (`src/TypeEmit.cpp`, § tdMoveCarriesFile172's block; switch
`R11V176_TDKEYUNRES_OFF`, also dropped by `R11U176_OFF`): the resolved key drops only the writers KNOWN to resolve to
another typedef. Every formal at the name-keyed position records the typedef its bare name resolves to in its
package (none for a module / interface / program subroutine or a qualified name); when the resolved site exists, the
site read is the name-keyed site filtered to the writers resolving to this typedef or not resolved, in syntax order.
Where every writer is a package formal it equals the law's site (td02, v11u171 F/h10, t4 keep their conversions).
`R11U176_TRACE=1` prints `R11U176 TDKEYUNRES <type> <file>` when the filter changes the pick.

Prediction before the verified sweep (`drivers/pred176v.cpp`, over every PRISTINE database of `swP`, fenced paths
excluded by word boundary; positive controls t3 and t4 fire, a single-file case does not;
`evidence/pred176v_before_swV.txt`, written 02:39, the `swV` sweep started 02:41): the trigger (an enum / struct /
union base name typing io_decls in two files, one of them a package subroutine's outside a class) names MiniAmiq d/t,
Scoreboard d, SeqDriver d/t, SimpleUVM d/t and no probe case. Byte movers `swV` vs `swL`
(`evidence/byteverify_V_vs_L.txt`): **4 / 2560**, MiniAmiq d/t and SeqDriver d/t, each order-blind 4 lines
(`|UINT:` / `|vpiDecompile:` pairs: the known UVM order coin); a trace run of `ver2.bin` over the five UVM rows in both
modes prints no TDKEY / TDKEYUNRES / TDTIE line (`evidence/uvm_trace_tdkey.txt`, positive control t3: two lines).
Probe `swV` vs `swL` (both exported from the pristine worktree's `tests/probe`): **0 / 4087** byte movers. `swV`'s mover set against
`swP` is `swL`'s 30.

## 4. Breaking the laws: fresh cases (`cases/`, 115, first line `// § <law>`)

Each case judged by uhdm-cmp and uhdm-strictcmp against the pinned Surelog (`drivers/case.sh`, goldens cached by the
content of every file of the case), and by the downstream harness's own `one()` (`drivers/ds.py`, fresh golden
cache, single-file cases). Verdicts pristine / r11u176 / verified (`evidence/grid_final_P_L_V.txt`, raw lines
`grid_raw_*.txt`): strict-equal **11 -> 83 -> 84 of 115**; 71 STRICT_NOTEQUAL and 2 stage-1 cases convert; 17 stage-1
cases stay stage 1 with the same uhdm-cmp head (5 with pristine bytes; the 12 movers all toward golden: CC/a05
golden-not-ours 78 -> 1 dump lines with the head object unchanged, its +4 cmp lines being the parent print of that
head, which is now golden's per-instance ref_typespec; a12 92 -> 4, CM/c07 27 -> 13, c09 45 -> 31, GV/v08 22 -> 18,
PG/p02 52 -> 39, SP/s05 57 -> 27, XP/x01 38 -> 14, x03 80 -> 24, x07 86 -> 50 order-blind dump lines; TT/t7 the
typedef's file now golden's ma.sv, read with the stage-1 bypass `drivers/strictx.patch`; UL/l05 the elaborated
HighConns now golden's, the sorted count 56 -> 63 being the missing definition-view ref_module); 14 STRICT_NOTEQUAL
cases stay so: 8 with a later first record and fewer records (c18, v03, p04, q02, q10, q19, s02, x09) and 6 with the
pristine bytes on the verified binary (c20, q06, t2, t8, t9, l06). The one law-made regression is t3 (STRICT_EQUAL ->
file) with t8 (first record #167 -> #13 file), fixed by § tdKeyKeepsUnresolved176v. `R11U176_OFF=1 R11U175_OFF=1` gives the
pristine bytes on all 220 cases (these 115 and the implementer's 105).

| case | law | pristine | r11u176 | verified |
|---|---|---|---|---|
| CC/a01_genloop_inst | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a02_inst_array | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a03_partsel_rtl | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a04_op_operand | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a05_pkg_type_cast | § castRhsClonePerInst176 | stage1:122 | stage1:126 | stage1:126 |
| CC/a06_two_parents | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a07_rtl_implicit | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a08_bitsel_rtl | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a09_signed_cast_sel | § castRhsClonePerInst176 | stage1:13 | stage1:13 | stage1:13 |
| CC/a10_struct_member_lhs | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a11_concat_lhs_rtl | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CC/a12_gen_if_inst | § castRhsClonePerInst176 | stage1:17 | stage1:17 | stage1:17 |
| CC/a13_cast_in_iface_inst_twice | § castRhsClonePerInst176 | SN:fullname | EQ | EQ |
| CM/c01_cls_other_pkg_enum | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c02_cls_scoped_typedef | § tfArgClassMethodOrder176 | stage1:115 | stage1:115 | stage1:115 |
| CM/c04_pure_virtual | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c05_rev_name_order | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c06_default_arg | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c07_param_class | § tfArgClassMethodOrder176 | stage1:18 | stage1:18 | stage1:18 |
| CM/c08_struct_inbody | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c09_interface_class | § tfArgClassMethodOrder176 | stage1:330 | stage1:330 | stage1:330 |
| CM/c10_cls_pkgfunc_after | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c11_pkgfunc_before_cls | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c12_extern_task | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c13_unused_pkg_no_import | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c14_case_names | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c15_include_cls | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c16_extern_order_two | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c17_nested_class | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c18_unpacked_struct_inbody | § tfArgClassMethodOrder176 | SN:line | SN:fullname | SN:fullname |
| CM/c19_static_and_task | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c20_derived_two_pkgs | § tfArgClassMethodOrder176 | SN:line | SN:line | SN:line |
| CM/c21_cls_macro_method | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| CM/c22_cls_stringified | § tfArgClassMethodOrder176 | SN:line | EQ | EQ |
| GA/g01_else_begin_if_and | § genElseBeginIfDepth176 | SN:fullname | EQ | EQ |
| GA/g02_else_if_gate_array | § genElseIfGateArrayPath176 | SN:fullname | EQ | EQ |
| GA/g03_else_begin_if_nobegin | § genElseBeginIfDepth176 | SN:fullname | EQ | EQ |
| GA/g04_else_begin_inner_else | § genElseBeginIfDepth176 | SN:fullname | EQ | EQ |
| GA/g05_named_else_body | § genElseBeginIfDepth176 | EQ | EQ | EQ |
| GA/g06_two_levels | § genElseBeginIfDepth176 | SN:fullname | EQ | EQ |
| GA/g07_array_in_else_begin_if | § genElseIfGateArrayPath176 | SN:fullname | EQ | EQ |
| GA/g08_array_case_in_elseif | § genElseIfGateArrayPath176 | SN:fullname | EQ | EQ |
| GA/g09_array_first_branch | § genElseIfGateArrayPath176 | EQ | EQ | EQ |
| GA/g10_else_begin_if_in_inst | § genElseBeginIfDepth176 | SN:fullname | EQ | EQ |
| GV/v01_generic_named_plain | § genericPlainNamedView176 | SN:depth | EQ | EQ |
| GV/v02_generic_named_modport | § genericMpConnLowConnAtDecl176 | SN:line | EQ | EQ |
| GV/v03_generic_param_iface | § genericPlainNamedView176 | SN:type | SN:depth | SN:depth |
| GV/v04_two_views_one_inst | § genericPlainNamedView176 | stage1:280 | EQ | EQ |
| GV/v05_nets_and_vars | § genericPlainNamedView176 | stage1:220 | EQ | EQ |
| GV/v06_generic_plain_positional | § genericPlainNamedView176 | stage1:108 | stage1:108 | stage1:108 |
| GV/v07_generic_plain_procedural | § genericPlainNamedView176 | SN:depth | EQ | EQ |
| GV/v08_generic_mp_twoport | § genericMpConnLowConnAtDecl176 | stage1:16 | stage1:16 | stage1:16 |
| GV/v09_generic_plain_gen_inside | § genericPlainNamedView176 | SN:depth | EQ | EQ |
| GV/v10_typed_plain_named | § genericPlainNamedView176 | EQ | EQ | EQ |
| GV/v11_generic_shorthand | § genericPlainNamedView176 | SN:depth | EQ | EQ |
| GV/v12_generic_mp_shorthand_prog | § genericMpConnLowConnAtDecl176 | SN:type | EQ | EQ |
| PG/p01_mp_import_func | § progLowConnDefModport176 | SN:file | EQ | EQ |
| PG/p02_wildcard_conn | § progTypedPortLowConnUnlocated176 | stage1:52 | stage1:52 | stage1:52 |
| PG/p03_iface_array_elem | § progLowConnDefModport176 | SN:file | EQ | EQ |
| PG/p04_nested_twice | § progLowConnDefModport176 | SN:fullname | SN:fullname | SN:fullname |
| PG/p05_mp_conn_on_typed_plain | § progLowConnDefModport176 | SN:file | EQ | EQ |
| PG/p06_prog_param_iface | § progTypedPortLowConnUnlocated176 | SN:file | EQ | EQ |
| PG/p07_prog_and_mod_same_iface | § progLowConnDefModport176 | SN:file | EQ | EQ |
| PQ/q01_cls_other_pkg_qual | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q02_iface_func_qual_struct | § tfArgQualOutsideWriter176 | SN:line | SN:fullname | SN:fullname |
| PQ/q03_rtl_qual_struct | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q04_rtl_qual_enum_case | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q05_two_pkgs_same_name | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q06_qual_and_import_other_mod | § tfArgQualOutsideWriter176 | SN:line | SN:line | SN:line |
| PQ/q07_qual_unpacked_struct | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q08_qual_task_output | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q09_qual_prog | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q10_qual_typedef_in_module_pkgtype | § tfArgQualOutsideWriter176 | SN:line | SN:name | SN:name |
| PQ/q11_ref_dir | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q12_const_ref_dir | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q13_input_two_declarators | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q14_inout_task | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q15_qual_packed_dim | § tfArgQualOutsideWriter176 | EQ | EQ | EQ |
| PQ/q16_qual_macro | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q17_qual_multiline | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q18_qual_unused_func_twice | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q19_qual_pasted | § tfArgQualOutsideWriter176 | SN:line | SN:col | SN:col |
| PQ/q20_qual_macro_arg_func | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| PQ/q21_qual_inactive_branch | § tfArgQualOutsideWriter176 | SN:line | EQ | EQ |
| SP/s01_split_bare_import | § tfArgDefTopSplit176 | SN:line | EQ | EQ |
| SP/s02_split_outside_class | § tfArgDefTopSplit176 | SN:line | SN:line | SN:line |
| SP/s03_split_two_inside | § tfArgDefTopSplit176 | SN:line | EQ | EQ |
| SP/s04_split_struct | § tfArgDefTopSplit176 | SN:line | EQ | EQ |
| SP/s05_split_iface_outside | § tfArgDefTopSplit176 | stage1:17 | stage1:17 | stage1:17 |
| TT/t1_iface_vs_module | § tdEndMoveModuleOrder176 | stage1:60 | stage1:60 | stage1:60 |
| TT/t2_pkgvar_vs_module | § tdEndMoveModuleOrder176 | SN:file | SN:file | SN:file |
| TT/t3_modfunc_vs_pkgfunc | § tdKeyKeepsUnresolved176v | EQ | SN:file | EQ |
| TT/t4_explicit_import_key | § tdMoveKeyResolved176 | SN:file | EQ | EQ |
| TT/t5_iface_after | § tdEndMoveModuleOrder176 | SN:file | EQ | EQ |
| TT/t6_iface_before | § tdEndMoveModuleOrder176 | EQ | EQ | EQ |
| TT/t7_prog_after | § tdEndMoveModuleOrder176 | stage1:278 | stage1:278 | stage1:278 |
| TT/t8_ifacefunc_vs_pkgfunc | § tdKeyKeepsUnresolved176v | SN:fullname | SN:file | SN:fullname |
| TT/t9_order_reversed | § tdKeyKeepsUnresolved176v | SN:file | SN:file | SN:file |
| UL/l01_sel_in_first_concat | § udpFormNetLvalueFirst176 | EQ | EQ | EQ |
| UL/l02_member_first | § udpFormNetLvalueFirst176 | stage1:17 | stage1:17 | stage1:17 |
| UL/l03_repl_first | § udpFormNetLvalueFirst176 | EQ | EQ | EQ |
| UL/l04_name_first_concat_later | § udpFormNetLvalueFirst176 | EQ | EQ | EQ |
| UL/l05_lit_last_in_first | § udpFormNetLvalueFirst176 | stage1:287 | stage1:287 | stage1:287 |
| UL/l06_nested_concat_first | § udpFormNetLvalueFirst176 | SN:col | SN:col | SN:col |
| UL/l07_two_insts_first_ok_second_lit | § udpFormNetLvalueFirst176 | EQ | EQ | EQ |
| UL/l08_first_lit_second_concat | § udpFormNetLvalueFirst176 | EQ | EQ | EQ |
| XP/x01_default_proto_only | § externProtoFormalsFromPrototype175 | stage1:15 | stage1:15 | stage1:15 |
| XP/x02_extern_task_ranges | § externProtoFormalsFromPrototype175 | SN:line | EQ | EQ |
| XP/x03_param_class_extern | § externProtoFormalsFromPrototype175 | stage1:18 | stage1:18 | stage1:18 |
| XP/x04_extern_ctor_default | § externProtoFormalsFromPrototype175 | SN:file | EQ | EQ |
| XP/x05_extern_virtual_derived | § externProtoFormalsFromPrototype175 | SN:line | EQ | EQ |
| XP/x06_extern_static | § externProtoFormalsFromPrototype175 | SN:line | EQ | EQ |
| XP/x07_extern_in_module | § externProtoFormalsFromPrototype175 | stage1:362 | stage1:362 | stage1:362 |
| XP/x08_extern_macro_proto | § externProtoFormalsFromPrototype175 | SN:line | EQ | EQ |
| XP/x09_extern_enum_ret | § externProtoFormalsFromPrototype175 | SN:line | SN:fullname | SN:fullname |

What the fresh cases establish, law by law (every law of the patch, every face with at least three fresh instances):

| law | fresh instances | finding |
|---|---|---|
| § externProtoFormalsFromPrototype175 (`R11U175_FSPAN_OFF`) | XP x01-x09, CM c12, c16 | a default in the prototype only, ranges across lines, a parameterized class, an extern constructor with defaults, `extern virtual` in a derived class, `extern static`, a class inside a module, a macro-born prototype, an enum return: 5 convert (x02, x04, x05, x06, x08; CM c12, c16 too), 3 stay stage 1 toward golden (x01, x03, x07), x09 moves its first record #2 -> #83 |
| § castRhsClonePerInst176 (`R11U176_CASTCLONE_OFF`) | CC a01-a13 | generate-loop instances, an instance array, part-select, bit-select, struct-member and concatenation Lhs in synthesizable RTL, an operation operand, two parents, two levels: 10 convert; a05 (package typedef cast) and a12 (instance in a generate if) stay stage 1 toward golden; a09 (`signed'`) unchanged. Downstream IDENTICAL on all 13 (Yosys OK with gates on a03, a07, a11; the rest NO_GATES, compared as text) |
| § progTypedPortLowConnUnlocated176, § progLowConnDefModport176, § progPlainPortViewUnparented176 | PG p01-p07, GV v12 | a modport with an imported function, `.*`, an interface-array element, a program in a module instantiated twice, a modport connection on a plain typed port, a parameterized interface, a program and a module on one instance: 5 convert, p02 stage 1 toward, p04 toward (the shared-process residue) |
| § genericMpConnLowConnAtDecl176, § genericPlainNamedView176 | GV v01-v12 | named plain and named modport connections of module generic ports, a parameterized interface, two views on one instance, nets beside variables, a procedural write, a generate-block connection, `.bus` shorthand, a program generic port: 8 convert (v04, v05 from stage 1), v03 and v08 (stage 1) toward, v06 (positional, stage 1) and v10 (typed port, equal) unchanged. Downstream: both lanes READ_FAIL on the generic-port designs (the plugin), IDENTICAL on the rest |
| § tfArgQualOutsideWriter176 | PQ q01-q21 | a qualified formal in a class of another package, an interface function, synthesizable RTL (struct, enum case), two packages with one type name, a qualified and a bare writer in two modules, unpacked struct, task output / `ref` / `const ref` / `inout`, a program, a nested typedef, two declarators, packed dimensions, a macro type, a pasted token, a macro-argument function, a multi-line qualifier, an inactive `ifdef` branch: 16 convert, q02, q10, q19 toward, q06 (two containers) and q15 unchanged. Downstream IDENTICAL on all but q19 (EQUIVALENT on both binaries with the byte-identical nohier diff: the pasted token's io_decl column, pre-existing) |
| § tfArgClassMethodOrder176 | CM c01-c22 | another package's enum, a class-scoped typedef, pure virtual, reversed and case-differing class names (ASCII order: `Zed` before `abc`), defaults, a parameterized class, an in-body struct, an interface class, package functions before and after the class, extern tasks, an uncalled class, a class in an included file, two extern classes defined in reverse order, a nested class, an unpacked struct, static and virtual methods, a macro method, a stringified name: 16 convert, c07, c09 stage 1 toward, c18 toward, c02 unchanged (stage 1), c20 (a derived class in another package: class writers in two packages) unchanged |
| § tfArgDefTopSplit176 | SP s01-s05 | a bare imported outside writer, an outside class, two inside writers, a struct, an interface function: 3 convert, s02 and s05 toward |
| § tdEndMoveModuleOrder176 | TT t1, t2, t5, t6, t7 | an interface against a module at one position (golden takes the module in both file orders: t5 converts, t6 equal on both; t1, the same with ports, stage 1 with pristine bytes), a package variable against a module (t2, not reached: pristine bytes), a program against a module (t7: golden ma.sv, the law's pick) |
| § tdMoveKeyResolved176 / § tdKeyKeepsUnresolved176v | TT t3, t4, t8, t9 | section 3 |
| § udpFormNetLvalueFirst176 | UL l01-l08 | a select, a member access, a replication, a literal last, a nested concatenation first; two instances; a literal first with a later concatenation: l05 moves to golden's HighConns (downstream EQUIVALENT -> IDENTICAL), the rest keep their bytes (l01, l03, l04, l07, l08 strict-equal on both, l02 stage 1, l06 SN col) |
| § genElseBeginIfDepth176, § genElseIfGateArrayPath176 | GA g01-g10 | begin-less inner if, inner else, named else body, two levels, an array in an else-begin-if, an array in a case inside an else-if, an array in a first branch, two instances with different parameters: 8 convert, g05 and g09 equal on both. Downstream IDENTICAL on all 10 |

Downstream (`evidence/downstream_cases_{P,LV}.txt`): of the 106 single-file cases, pristine -> verified 104 IDENTICAL
-> IDENTICAL, **UL/l05 EQUIVALENT -> IDENTICAL**, PQ/q19 EQUIVALENT on both (the same nohier diff, byte for byte).
Two more cases read SLANG_REJECT on both binaries and were dropped from `cases/` (slang rejects a `$unit` typedef
read from a package class, and `.*` onto a generic interface port). No case leaves IDENTICAL.

The multi-file relocation grids (`evidence/multifile_{P,L,V}.txt`: r11u172rp F/f01-f12, v11u171 F/h01-h10,
r11u176repro TD/td01-td03): the law's conversions (td01, td02, h01, h02, h03, h05, h07, h10) hold on the verified binary,
byte-identical to r11u176; no case moves away.

## 5. Switches (`evidence/switch_drops.txt`)

Every law drops alone on the verified binary (each switch run over the 220 cases: no crash, NODB 2 as with every
binary, and the movers are that law's own cases). One coupling the implementer's README does not state:
**`R11U176_QUALFORMAL_OFF` also drops the aggregate face of § tfArgClassMethodOrder176** (CM/c08, c18: the struct
typedef enters the § 146 candidate map only through § tfArgQualOutsideWriter176's aggregate admission, `aggTd176`).
`R11U176_OFF=1 R11U175_OFF=1` restores the pristine bytes on all 220 cases; `R11V176_TDKEYUNRES_OFF` moves t3 and t8
alone.

## 6. Residues, ranked (verifier's findings; the implementer's list stands)

1. **The implementer's predictor trigger for § tdMoveKeyResolved176 was narrower than the law** (two same-named
   typedefs in two packages): the law also fires with ONE typedef whose package formal shares a position with a
   module / interface formal in another file, which is how t3 / t8 went unseen. No corpus row reaches it (no TDKEY
   firing in the UVM rows; 0 probe movers).
2. **§ tdMoveCarriesFile172's writer order across unit kinds** (t9, pristine-wrong too): at a position shared by a
   package formal and a module formal, golden takes the module's file even when the package file is later in the
   file list (packages compile before modules); ours takes the last in syntax order. TypeEmit, the same block.
3. Class writers in two packages (CM/c20: a derived class in another package re-declaring the method): golden takes
   the derived class's formal (12:29); § tfArgClassMethodOrder176 and § tfArgDefTopSplit176 decline. UhdmExporter § 146.
4. A package-level variable declarator at the position of a module declarator (TT/t2): golden moves the end to the
   module's declarator in ma.sv, ours keeps the typedef's span (not modelled; pristine bytes).
5. The implementer's own residues 1-8 (the UVM relocations beside class writers, import-parameter copies, typespec
   identity full names, type-parameter last writers, program processes shared by instances (PG/p04 here), the sister
   faces, the report-only rows, the not-attempted list) are confirmed where the fresh cases reach them: PQ/q02, CM/c18
   and XP/x09 stop at call-argument reference full names (`work@top.i.get.si`: sister, F5), PQ/q10 at a qualified
   typespec name inside a struct member (`q::n_t`), SP/s02 at an importing package's clone of a package function
   (`r::f`), PQ/q19 at a pasted-token io_decl column (7:37 vs 7:41), UL/l05 and v11u171 Q/c07, c12 at the definition
   view's missing ref_module (EmitHelpers.h `isNetLvalueSyntax`, sister).
6. Cosmetic (not changed): § genElseBeginIfDepth176 carries two dead statements (`for (auto& sg : segs171) (void)sg;`
   and the unused `outer`).

## 7. Files

* `cases/{CC,CM,GA,GV,PG,PQ,SP,TT,UL,XP}/`: 115 cases (first line `// § <law>`; `TT/*` carry a `files` list).
* `drivers/`: `env.sh` (pins, `$FENCED` from RESUME.md, fail closed), `build.sh`, `case.sh` / `rungrid.sh` / `runlist.sh`
  (a case against the pinned Surelog), `cmp2.sh` / `ob2.sh` / `obdump.sh` (first record, order-blind distances),
  `ds.py` (the downstream harness's `one()` on a case list), `boundary.sh` (three binaries over `tools/probe`),
  `mirror.sh` (fence-clean database mirrors for byteverify), `row.sh` (a corpus row's strict records, fence refused),
  `bytes.sh` (the switch and all-off byte runs), `pred176v.cpp` (the refinement's predictor over pristine databases),
  `strictx.patch` (a measurement-only uhdm-strictcmp variant, `SKIP_STAGE1=1` lists the records of a stage-1 pair).
* `evidence/`: sweep summaries, byte verification, the grid tables, downstream per case, boundary, switch drops, the
  predictor output, the UVM trace, the SVSwitch record lists, the corpus rows' order-blind distances.
