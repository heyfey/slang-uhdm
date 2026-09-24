# r11v140 — adversarial verification of r11u140 (expression/parameter ground, strict axis)

Base `d8473d78` (branch matrix-1.87). Implementer's patch `/tmp/r11u140.patch` (md5 `686edff46c42147962f56bf5dd704206`),
applied clean to a fresh worktree `/tmp/wt_v11u140`; pristine worktree `/tmp/wt_v11u140pris`. System-deps config,
`-j 2`. Every binary was frozen (`chmod 555` copies under `/tmp/v11u140_bin`) before it measured anything; every
`cmds.txt` of the pristine, law and verified sweeps names its frozen binary (3273 of 3273 slang lines each), and the
downstream sweep's database is byte-identical to the verified binary's own run (struct_member_trailing_index).

| binary | md5 |
|---|---|
| pristine (rebuild of the base, byte-identical to the main tree's `build/slang-uhdm` at `d8473d78`) | `5737c6b070f5aaa9ecd29a6b291c1402` |
| law (r11u140 as delivered; reproduces the implementer's md5) | `28d69b69ace5614d967ec44e61619c95` |
| verified (law + the two refinements below) | `7790191b5b19afe73ea3fe2a9ea117a5` |
| `build/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` |

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of the implementer reproduces bit for bit; two laws were broken
on legal SV (a pristine-right cell moved away from golden) and are refined here, each behind its own switch; the
refinements move no corpus row, no probe case and no downstream row (the corpus and probe csvs of the law and verified
sweeps are identical row for row).

## 1. Reproduction (law binary, committed baselines)

| stage | implementer | reproduced |
|---|---|---|
| probe | regressions=0 conversions=23 changes=46; EQUAL 2221 -> 2244 | same (evidence/sweep_law_vs_baselines.txt) |
| surelog | regressions=0 conversions=13 changes=20 | same |
| uhdm2rtlil | regressions=0 conversions=10 changes=32 | same |
| pristine sweep | regressions=0 conversions=0 changes=0 in all three | same (evidence/sweep_pris_vs_baselines.txt; rc 1 = law index stale at the base) |
| byte movers vs pristine | surelog 35/960, uhdm2rtlil 42/1608, probe 70/4087 | same counts AND the same names (byteverify path sets identical, selfcheck 959/960, 1607/1608; probe compared against a pristine run from the same checkout path, since a probe database embeds its case path) |
| strict-cell changes | 98 changes + 46 conversions; 24 grow, record check 24/24 OK | 144 changed pairs, `worse2.py` rule (no record newly differing before either walk diverges, no earlier divergence): **144 / 144 OK** (evidence/record_check_144.txt); ibex_alu pristine diverges at record 5640 (`range` vs `ref_typespec`), law has no divergence, first record #2449 unchanged |
| canaries | surelog ok=39 changed=13, u2r ok=16 changed=0, ctcan2 PASS both | same (the 13 = Earlgrey_0_1, SVSwitch, ApbSlave, SimpleUVM, SeqDriver, BuildUVMPkg, Scoreboard strict cells) |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, 0 of 871 rows changed | same, measured on the verified binary (whose database on the targeted rows is byte-identical to the law binary's); the five targeted rows read `func_local_compound_xor,IDENTICAL,OK,OK,65,65,,` `param_struct_field_bitsel,IDENTICAL,OK,OK,6,6,,` `param_unpacked_struct_array,IDENTICAL,OK,OK,20,20,,` `struct_dynamic_range,IDENTICAL,OK,OK,68,68,,` `struct_member_trailing_index,IDENTICAL,OK,OK,177,177,,` |
| grid (108 cases) | table in r11u140repro/README.md | all 108 pristine AND law verdicts reproduce exactly |
| switches | `R11U140_OFF` pristine bytes on 108/108 | pristine bytes on all 237 cases (108 + this directory's 129), verified binary |
| earlier-pass byte controls | 24 movers of 1280 | the same 24 (r11u124 c12 a01 a03 a04 a07 a08 a12 a13; r11u133 lhs l01 l02 l04 l07 l09 l11, tix t08; r11v133 lhs c01-c04 c06 c08 c09 c10 h05, tix f09); the verified binary moves none of the 1388 control databases against the law binary |

## 2. Breaks found and fixed

### B1 — § sysArgUnaryWholeSpan140 on the other constant selects -> § sysArgUnaryConstSelToken140v
The law keeps the operator-token span only under `inPsRangeBound || inParamInit`; `inPsRangeBound` is raised by the
whole-variable RANGED select alone. Golden keeps the token span in every `constant_range` bound and every indexed
select's WIDTH (`indexed_range: expression +: constant_expression`), whatever the select's base; the indexed BASE and a
bit-select index span the whole unary (as the law says). Pristine-right -> law-wrong, legal SV:

| case | pristine | law | golden record |
|---|---|---|---|
| `sca/a06_ips_width` `x[0 +: $bits(~a)]` | STRICT_EQUAL | STRICT_NOTEQUAL endcol | operation 3:27-28 (law 3:27-29) |
| `sca/a15_ips_down_width` `x[31 -: $bits(~a)]` | STRICT_EQUAL | endcol | token |
| `sca/a18_elem_ranged` `y[1][$bits(~a)-1:0]` | STRICT_EQUAL | endcol | token |
| `sca/a20_proc_ips_width` (always_comb) | STRICT_EQUAL | endcol | token |
| `sca/a21_lhs_ips_width` (process lvalue) | STRICT_EQUAL | endcol | token |
| `sca/a16_member_ranged` `s.f[$bits(~a)-1:0]`, `sca/a19_elem_ips_width` | fullname (first #52 / #36) | endcol: a NEW record #51 / #35 before pristine's first | token |
| `sca/a17_member_ips_width`, `a23_ips_width_signed`, `a28_hier_member_ips_width` (stage 1 both) | dump distance 18 / 8 / 18 | 22 / 12 / 22 | token |

THE REFINEMENT (ExprEmit.cpp, `sysArgUnaryConstSelToken140v`, called at the § sysArgUnaryWholeSpan140 site): the
nearest enclosing selector of the unary's syntax decides — a simple range -> token, an indexed range -> token only
under its width, a bit select -> whole. It only returns cells to the pristine span. Switch `R11V140_CONSTSEL_OFF`
(also off under `R11U140_OFF`). All ten cases return to pristine bytes (the five STRICT_EQUAL again); the law's own
grid (sca, 25 cases) and every other case keep the law's bytes; controls `a22_ips_base_ctl` and `a27_proc_ips_base`
(indexed base, whole span) convert under both binaries, `a24_proc_ranged` / `a26_range_in_bitsel` equal on all three;
`a25_nested_bitsel_in_range` (a bit select inside a range bound) is unchanged by all three binaries.

### B2 — § pkgRefFoldClonesMultiDimOnly140's definition-name rename -> § mdRenameNotUnderBareCa140v
The rename of the multi-dimension clone's reference to the DEFINITION's name (`work@cc`) is wrong when a continuous
assignment of the instance body reads the parameter BARE: golden keeps the instance's name there. Pairwise grid `pfx/`
(all header import, `logic [7:0][3:0] P = X`, top instance `u`):

| case | the only difference | golden clone reference | law |
|---|---|---|---|
| `x2_unused_nested`, `x3_port_unused`, `x4_used_localparam_ref`, `x7_always`, `x9_subparam`, `x11_assign_other` | P unused / read by a localparam, an always block, an override, or `assign o = Q` | `work@cc` | `work@cc` (STRICT_EQUAL, law right) |
| `x1_used_top`, `x5_used_decl`, `x6_nested_used`, and `pfp/b07_md_nested`, `b08_md_body_withports`, `b14_md_two_levels_ovr` | `assign o = P;` (header or body parameter, any depth, with or without override) | `work@top.u` / `work@top.m.u` | `work@cc` (dump distance +4 on every one; stage 1 on all binaries through the sister's cont_assign face) |
| `x12_assign_bitsel` `assign o = P[1]`, `x10_genif`, `x8_netdecl` | a select, a generate condition, a net declaration assignment | `work@cc` / neutral | law right or neutral |

THE FENCE (ParamEmit.cpp, beside the rename): no rename when a ContinuousAssign member of the instance body has, after
implicit conversions, the parameter symbol itself as its right-hand side. Switch `R11V140_MDRENAME_OFF`. The six cases
return to pristine bytes; the other pfx/pfp cases keep the law's bytes (ParamFromPackage, g01-g16 unchanged).

Both refinements together: `R11V140_CONSTSEL_OFF=1 R11V140_MDRENAME_OFF=1` gives the law binary's bytes on all 129
cases of this directory and all 108 of r11u140repro; each alone differs from the law exactly on its own cases (the
ten B1 cases / the six B2 cases).

## 3. Gates on the verified binary

1. Build: md5s above.
2. Probe (`tests/sweep.sh --corpus probe`): regressions=0 conversions=23 changes=46, EQUAL=2244 STRICT_NOTEQUAL=1843;
   csv identical to the law sweep's.
3. Corpora: surelog regressions=0 conversions=13 changes=20; uhdm2rtlil regressions=0 conversions=10 changes=32; both
   csvs identical to the law sweep's (only the LowMem detail text, which embeds the workdir). uhdm-cmp statuses of every
   row unchanged (480/3 + 474/3, 803/1/67).
4. Downstream (`tests/sweep.sh --corpus downstream`): `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not
   identical and not excused=0`, joined to results/downstream_uhdm2rtlil.csv on every column: 0 rows changed.
5. uhdm-cmp: every judge-equal row and probe case stays judge-equal (status join); every stage-1 grid case keeps its
   uhdm-cmp line count or lowers it.
6. Byteverify verified vs law: surelog 4/960 = MiniAmiq and SeqDriver, both modes, the UVM UINT/vpiDecompile order coin
   (order-blind sorted dumps differ only on `UINT:`/`vpiDecompile:` lines, 4 per database); uhdm2rtlil 0/1608; probe
   0/4087. Prediction by shape (made from the sources, not by a tool over the pristine databases): the two
   refinements trigger only on a unary under a system call inside an indexed width or a member/element range select,
   and on a multi-dimension unqualified package-parameter clone read by a bare continuous assignment, and only return
   such cells to the pristine bytes; expected 0 non-coin movers, measured 0.
7. Canaries (verified sweep): surelog ok=39 changed=13 (the law's thirteen), u2r ok=16 changed=0; `EXPECT_UNKNOWN=1
   ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6` uhdm2rtlil PASS.

## 4. The break grid (129 cases, first line names the law)

Tally: 51 cases move to STRICT_EQUAL under both the law and the verified binary, 11 are equal on all three, 62 are
not equal on all three (stage 1 or a later face), and 5 are pristine-equal cases the law broke (B1) and the verified
binary restores; no case leaves equality under the verified binary. Stage-1 dump distances
(evidence/grid_stage1_dumpdist.txt) grow under the verified binary only on `lat/k05_two_mods` (200 -> 222, a
line-alignment artefact: its order-blind distance falls 184 -> 104, the copies golden lists now listed) and
`pfp/b15_int_from_md` (which converts to STRICT_EQUAL). Downstream verdicts (`drivers/ds1.py`, 24 cases, pristine vs
verified): every case IDENTICAL on both except `sca/a04_case_expr`, `a08_nested_parens`, `a11_if_cond`: EQUIVALENT ->
IDENTICAL (§ sysArgUnaryWholeSpan140's spans reach the RTLIL src attributes).

| case | law (first line) | pristine | law binary (r11u140) | verified binary |
|---|---|---|---|---|
| `dfl/f01_pkg` | § defaultFillOneConstant140 | rc=0 cmp=36 NOT_EQUAL stage1 | rc=0 cmp=36 NOT_EQUAL stage1 | rc=0 cmp=36 NOT_EQUAL stage1 |
| `dfl/f02_2d` | § defaultFillOneConstant140 | rc=0 cmp=100 NOT_EQUAL stage1 | rc=0 cmp=100 NOT_EQUAL stage1 | rc=0 cmp=100 NOT_EQUAL stage1 |
| `dfl/f03_vec` | § defaultFillOneConstant140 | rc=0 cmp=136 NOT_EQUAL stage1 | rc=0 cmp=112 NOT_EQUAL stage1 | rc=0 cmp=112 NOT_EQUAL stage1 |
| `dfl/f04_override` | § defaultFillOneConstant140 | rc=0 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 |
| `dfl/f05_expr` | § defaultFillOneConstant140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_NOTEQUAL endcol |
| `dfl/f06_localparam` | § defaultFillOneConstant140 | rc=0 cmp=0 STRICT_NOTEQUAL depth | rc=0 cmp=0 STRICT_NOTEQUAL file | rc=0 cmp=0 STRICT_NOTEQUAL file |
| `fav/e01_include` | § foreachArrayPlaceholderFile140 | rc=0 cmp=0 STRICT_NOTEQUAL file | rc=0 cmp=0 STRICT_EQUAL 23 | rc=0 cmp=0 STRICT_EQUAL 23 |
| `fav/e02_nested_foreach` | § foreachArrayPlaceholderFile140 | rc=4 cmp=814 NOT_EQUAL stage1 | rc=4 cmp=814 NOT_EQUAL stage1 | rc=4 cmp=814 NOT_EQUAL stage1 |
| `lat/k01_vec_elem` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_EQUAL 197 | rc=0 cmp=0 STRICT_EQUAL 197 |
| `lat/k02_typedef_arr` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=60 NOT_EQUAL stage1 | rc=0 cmp=60 NOT_EQUAL stage1 | rc=0 cmp=60 NOT_EQUAL stage1 |
| `lat/k03_enum_elem` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=32 NOT_EQUAL stage1 | rc=0 cmp=32 NOT_EQUAL stage1 | rc=0 cmp=32 NOT_EQUAL stage1 |
| `lat/k04_iface` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_EQUAL 194 | rc=0 cmp=0 STRICT_EQUAL 194 |
| `lat/k05_two_mods` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=36 NOT_EQUAL stage1 | rc=0 cmp=36 NOT_EQUAL stage1 | rc=0 cmp=36 NOT_EQUAL stage1 |
| `lat/k06_other_pkg_elem` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_EQUAL 254 | rc=0 cmp=0 STRICT_EQUAL 254 |
| `lat/k07_body_import_vec` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_EQUAL 170 | rc=0 cmp=0 STRICT_EQUAL 170 |
| `lat/k08_range_param` | § impLhsCloneArrayTsOwnCopy140 | rc=0 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_EQUAL 186 | rc=0 cmp=0 STRICT_EQUAL 186 |
| `mdi/m01_two_then_one` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 97 | rc=0 cmp=0 STRICT_EQUAL 97 |
| `mdi/m02_one_then_two` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_EQUAL 97 | rc=0 cmp=0 STRICT_EQUAL 97 | rc=0 cmp=0 STRICT_EQUAL 97 |
| `mdi/m03_typedef_decl` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_NOTEQUAL name | rc=0 cmp=0 STRICT_NOTEQUAL name | rc=0 cmp=0 STRICT_NOTEQUAL name |
| `mdi/m04_unpacked_decls` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 109 | rc=0 cmp=0 STRICT_EQUAL 109 |
| `mdi/m05_only_decl_then_return` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 89 | rc=0 cmp=0 STRICT_EQUAL 89 |
| `mdi/m06_oldstyle_ports` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_EQUAL 109 | rc=0 cmp=0 STRICT_EQUAL 109 | rc=0 cmp=0 STRICT_EQUAL 109 |
| `mdi/m07_initial_block` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_EQUAL 31 | rc=0 cmp=0 STRICT_EQUAL 31 | rc=0 cmp=0 STRICT_EQUAL 31 |
| `mdi/m08_task_three` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 55 | rc=0 cmp=0 STRICT_EQUAL 55 |
| `mdi/m09_two_only_multi` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 73 | rc=0 cmp=0 STRICT_EQUAL 73 |
| `mdi/m10_class_two_decls` | § multiDeclOneItem140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 32 | rc=0 cmp=0 STRICT_EQUAL 32 |
| `pfp/b01_word_td` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=92 NOT_EQUAL stage1 | rc=0 cmp=0 STRICT_EQUAL 223 | rc=0 cmp=0 STRICT_EQUAL 223 |
| `pfp/b02_implicit` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_EQUAL 93 | rc=0 cmp=0 STRICT_EQUAL 93 | rc=0 cmp=0 STRICT_EQUAL 93 |
| `pfp/b03_implicit_range` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_EQUAL 147 | rc=0 cmp=0 STRICT_EQUAL 147 | rc=0 cmp=0 STRICT_EQUAL 147 |
| `pfp/b04_bit_scalar` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 90 | rc=0 cmp=0 STRICT_EQUAL 90 |
| `pfp/b05_integer` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 93 | rc=0 cmp=0 STRICT_EQUAL 93 |
| `pfp/b06_enum_ctl` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname |
| `pfp/b07_md_nested` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfp/b08_md_body_withports` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfp/b09_signed16` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 |
| `pfp/b10_real_ctl` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 |
| `pfp/b11_chain` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_NOTEQUAL endcol |
| `pfp/b12_iface` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 99 | rc=0 cmp=0 STRICT_EQUAL 99 |
| `pfp/b13_override` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 138 | rc=0 cmp=0 STRICT_EQUAL 138 |
| `pfp/b14_md_two_levels_ovr` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfp/b15_int_from_md` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=0 STRICT_EQUAL 150 | rc=0 cmp=0 STRICT_EQUAL 150 |
| `pfp/b16_logic_scalar` | § pkgRefFoldClonesMultiDimOnly140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 90 | rc=0 cmp=0 STRICT_EQUAL 90 |
| `pfx/x10_genif` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfx/x11_assign_other` | § mdRenameNotUnderBareCa140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 199 | rc=0 cmp=0 STRICT_EQUAL 199 |
| `pfx/x12_assign_bitsel` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfx/x1_used_top` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfx/x2_unused_nested` | § mdRenameNotUnderBareCa140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 130 | rc=0 cmp=0 STRICT_EQUAL 130 |
| `pfx/x3_port_unused` | § mdRenameNotUnderBareCa140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 179 | rc=0 cmp=0 STRICT_EQUAL 179 |
| `pfx/x4_used_localparam_ref` | § mdRenameNotUnderBareCa140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 148 | rc=0 cmp=0 STRICT_EQUAL 148 |
| `pfx/x5_used_decl` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfx/x6_nested_used` | § mdRenameNotUnderBareCa140v | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 | rc=0 cmp=87 NOT_EQUAL stage1 |
| `pfx/x7_always` | § mdRenameNotUnderBareCa140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 181 | rc=0 cmp=0 STRICT_EQUAL 181 |
| `pfx/x8_netdecl` | § mdRenameNotUnderBareCa140v | rc=0 cmp=89 NOT_EQUAL stage1 | rc=0 cmp=89 NOT_EQUAL stage1 | rc=0 cmp=89 NOT_EQUAL stage1 |
| `pfx/x9_subparam` | § mdRenameNotUnderBareCa140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 156 | rc=0 cmp=0 STRICT_EQUAL 156 |
| `plv/v01_ff_basesel` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 230 | rc=0 cmp=0 STRICT_EQUAL 230 |
| `plv/v02_basesel_mid` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 250 | rc=0 cmp=0 STRICT_EQUAL 250 |
| `plv/v03_basesel_ips` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=178 NOT_EQUAL stage1 | rc=0 cmp=178 NOT_EQUAL stage1 | rc=0 cmp=178 NOT_EQUAL stage1 |
| `plv/v04_basesel_const` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 217 | rc=0 cmp=0 STRICT_EQUAL 217 |
| `plv/v05_task` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname |
| `plv/v06_compound` | § procLvTrailIdxNamesByPath140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 201 | rc=0 cmp=0 STRICT_EQUAL 201 |
| `plv/v07_basesel_opidx` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname |
| `plv/v08_gen` | § procLvTrailIdxNamesByPath140 | rc=0 cmp=58 NOT_EQUAL stage1 | rc=0 cmp=58 NOT_EQUAL stage1 | rc=0 cmp=58 NOT_EQUAL stage1 |
| `plv/v09_2d_trail` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_EQUAL 256 | rc=0 cmp=0 STRICT_EQUAL 256 | rc=0 cmp=0 STRICT_EQUAL 256 |
| `plv/v10_rvalue_ctl` | § procLvTrailIdxNamesByPath140 | rc=0 cmp=0 STRICT_EQUAL 224 | rc=0 cmp=0 STRICT_EQUAL 224 | rc=0 cmp=0 STRICT_EQUAL 224 |
| `plv/v11_incdec` | § procLvTrailIdxNamesByPath140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col |
| `plv/v12_2d_mid_basesel` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 256 | rc=0 cmp=0 STRICT_EQUAL 256 |
| `plv/v13_iface_arr` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=42 NOT_EQUAL stage1 | rc=0 cmp=42 NOT_EQUAL stage1 | rc=0 cmp=42 NOT_EQUAL stage1 |
| `plv/v14_class` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 |
| `plv/v15_unpacked_base` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=58 NOT_EQUAL stage1 | rc=0 cmp=58 NOT_EQUAL stage1 | rc=0 cmp=58 NOT_EQUAL stage1 |
| `plv/v16_nb_basesel_opidx` | § procLvBaseSelTrailAtIdx140 | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_EQUAL 186 | rc=0 cmp=0 STRICT_EQUAL 186 |
| `pso/q01_multiline` | § elabPatOperandRefSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 70 | rc=0 cmp=0 STRICT_EQUAL 70 |
| `pso/q02_parens` | § elabPatOperandRefSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 70 | rc=0 cmp=0 STRICT_EQUAL 70 |
| `pso/q03_twice` | § elabPatOperandRefSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 76 | rc=0 cmp=0 STRICT_EQUAL 76 |
| `pso/q04_ternary` | § elabPatOperandRefSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 81 | rc=0 cmp=0 STRICT_EQUAL 81 |
| `pso/q05_iface` | § elabPatOperandRefSpan140 | rc=0 cmp=148 NOT_EQUAL stage1 | rc=0 cmp=148 NOT_EQUAL stage1 | rc=0 cmp=148 NOT_EQUAL stage1 |
| `pso/q06_genblk` | § elabPatOperandRefSpan140 | rc=0 cmp=122 NOT_EQUAL stage1 | rc=0 cmp=122 NOT_EQUAL stage1 | rc=0 cmp=122 NOT_EQUAL stage1 |
| `pso/q07_include` | § elabPatOperandRefSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL file | rc=0 cmp=0 STRICT_EQUAL 71 | rc=0 cmp=0 STRICT_EQUAL 71 |
| `pso/q08_two_inst` | § elabPatOperandRefSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL line | rc=0 cmp=0 STRICT_EQUAL 93 | rc=0 cmp=0 STRICT_EQUAL 93 |
| `pso/q09_sysfunc` | § elabPatOperandRefSpan140 | rc=0 cmp=108 NOT_EQUAL stage1 | rc=0 cmp=108 NOT_EQUAL stage1 | rc=0 cmp=108 NOT_EQUAL stage1 |
| `sca/a01_decl_range` | § sysArgUnaryWholeSpan140 | rc=0 cmp=36 NOT_EQUAL stage1 | rc=0 cmp=36 NOT_EQUAL stage1 | rc=0 cmp=36 NOT_EQUAL stage1 |
| `sca/a02_gen_localparam` | § sysArgUnaryWholeSpan140 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 |
| `sca/a03_param_override` | § sysArgUnaryWholeSpan140 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 |
| `sca/a04_case_expr` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 72 | rc=0 cmp=0 STRICT_EQUAL 72 |
| `sca/a05_func_return` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 99 | rc=0 cmp=0 STRICT_EQUAL 99 |
| `sca/a06_ips_width` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_EQUAL 82 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 82 |
| `sca/a07_genfor_bound` | § sysArgUnaryWholeSpan140 | rc=0 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 |
| `sca/a08_nested_parens` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 111 | rc=0 cmp=0 STRICT_EQUAL 111 |
| `sca/a09_port_conn` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname |
| `sca/a10_in_binop` | § sysArgUnaryWholeSpan140 | rc=0 cmp=78 NOT_EQUAL stage1 | rc=0 cmp=78 NOT_EQUAL stage1 | rc=0 cmp=78 NOT_EQUAL stage1 |
| `sca/a11_if_cond` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 66 | rc=0 cmp=0 STRICT_EQUAL 66 |
| `sca/a12_localparam_mod` | § sysArgUnaryWholeSpan140 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 |
| `sca/a13_ps_ranged_both` | § sysArgUnaryWholeSpan140 | rc=0 cmp=92 NOT_EQUAL stage1 | rc=0 cmp=92 NOT_EQUAL stage1 | rc=0 cmp=92 NOT_EQUAL stage1 |
| `sca/a14_func_localparam` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_NOTEQUAL type |
| `sca/a15_ips_down_width` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_EQUAL 82 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 82 |
| `sca/a16_member_ranged` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_NOTEQUAL fullname |
| `sca/a17_member_ips_width` | § sysArgUnaryConstSelToken140v | rc=0 cmp=172 NOT_EQUAL stage1 | rc=0 cmp=172 NOT_EQUAL stage1 | rc=0 cmp=172 NOT_EQUAL stage1 |
| `sca/a18_elem_ranged` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_EQUAL 99 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 99 |
| `sca/a19_elem_ips_width` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_NOTEQUAL fullname |
| `sca/a20_proc_ips_width` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_EQUAL 84 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 84 |
| `sca/a21_lhs_ips_width` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_EQUAL 70 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 70 |
| `sca/a22_ips_base_ctl` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 82 | rc=0 cmp=0 STRICT_EQUAL 82 |
| `sca/a23_ips_width_signed` | § sysArgUnaryConstSelToken140v | rc=0 cmp=92 NOT_EQUAL stage1 | rc=0 cmp=92 NOT_EQUAL stage1 | rc=0 cmp=92 NOT_EQUAL stage1 |
| `sca/a24_proc_ranged` | § sysArgUnaryWholeSpan140 | rc=0 cmp=0 STRICT_EQUAL 88 | rc=0 cmp=0 STRICT_EQUAL 88 | rc=0 cmp=0 STRICT_EQUAL 88 |
| `sca/a25_nested_bitsel_in_range` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col |
| `sca/a26_range_in_bitsel` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_EQUAL 66 | rc=0 cmp=0 STRICT_EQUAL 66 | rc=0 cmp=0 STRICT_EQUAL 66 |
| `sca/a27_proc_ips_base` | § sysArgUnaryConstSelToken140v | rc=0 cmp=0 STRICT_NOTEQUAL endcol | rc=0 cmp=0 STRICT_EQUAL 84 | rc=0 cmp=0 STRICT_EQUAL 84 |
| `sca/a28_hier_member_ips_width` | § sysArgUnaryConstSelToken140v | rc=0 cmp=172 NOT_EQUAL stage1 | rc=0 cmp=172 NOT_EQUAL stage1 | rc=0 cmp=172 NOT_EQUAL stage1 |
| `stm/b01_multi` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_EQUAL 82 | rc=0 cmp=0 STRICT_EQUAL 82 |
| `stm/b02_with` | § streamOperandBraceSpan140 | rc=0 cmp=52 NOT_EQUAL stage1 | rc=0 cmp=52 NOT_EQUAL stage1 | rc=0 cmp=52 NOT_EQUAL stage1 |
| `stm/b03_nested` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_EQUAL 60 | rc=0 cmp=0 STRICT_EQUAL 60 |
| `stm/b04_macro` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col |
| `stm/b05_comment` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL col |
| `stm/b06_select` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname |
| `stm/b07_funcarg` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_EQUAL 101 | rc=0 cmp=0 STRICT_EQUAL 101 |
| `stm/b08_type_slice` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_EQUAL 58 | rc=0 cmp=0 STRICT_EQUAL 58 |
| `stm/b09_include` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_EQUAL 57 | rc=0 cmp=0 STRICT_EQUAL 57 |
| `stm/b10_brace_expr_operand` | § streamOperandBraceSpan140 | rc=0 cmp=0 STRICT_NOTEQUAL col | rc=0 cmp=0 STRICT_EQUAL 82 | rc=0 cmp=0 STRICT_EQUAL 82 |
| `tdc/t01_union` | § pkgTypedefCastTargetTs140 | rc=4 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_NOTEQUAL file | rc=0 cmp=0 STRICT_NOTEQUAL file |
| `tdc/t02_td_of_td` | § pkgTypedefCastTargetTs140 | rc=4 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_EQUAL 211 | rc=0 cmp=0 STRICT_EQUAL 211 |
| `tdc/t03_in_op` | § pkgTypedefCastTargetTs140 | rc=4 cmp=124 NOT_EQUAL stage1 | rc=0 cmp=124 NOT_EQUAL stage1 | rc=0 cmp=124 NOT_EQUAL stage1 |
| `tdc/t04_int_bits` | § pkgTypedefCastTargetTs140 | rc=4 cmp=96 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 | rc=0 cmp=64 NOT_EQUAL stage1 |
| `tdc/t05_other_pkg` | § pkgTypedefCastTargetTs140 | rc=0 cmp=0 STRICT_EQUAL 126 | rc=0 cmp=0 STRICT_EQUAL 126 | rc=0 cmp=0 STRICT_EQUAL 126 |
| `tdc/t06_parameter_used_twice` | § pkgTypedefCastTargetTs140 | rc=4 cmp=60 NOT_EQUAL stage1 | rc=0 cmp=60 NOT_EQUAL stage1 | rc=0 cmp=60 NOT_EQUAL stage1 |
| `tdc/t07_pkg_func` | § pkgTypedefCastTargetTs140 | rc=0 cmp=70 NOT_EQUAL stage1 | rc=0 cmp=70 NOT_EQUAL stage1 | rc=0 cmp=70 NOT_EQUAL stage1 |
| `tdc/t08_decl_after` | § pkgTypedefCastTargetTs140 | rc=4 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 | rc=0 cmp=17 NOT_EQUAL stage1 |
| `tdc/t09_forward_td` | § pkgTypedefCastTargetTs140 | rc=4 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_EQUAL 124 | rc=0 cmp=0 STRICT_EQUAL 124 |
| `tdc/t10_two_pkgs` | § pkgTypedefCastTargetTs140 | rc=4 cmp=106 NOT_EQUAL stage1 | rc=0 cmp=106 NOT_EQUAL stage1 | rc=0 cmp=106 NOT_EQUAL stage1 |
| `tdc/t11_module_localparam_ctl` | § pkgTypedefCastTargetTs140 | rc=0 cmp=0 STRICT_EQUAL 124 | rc=0 cmp=0 STRICT_EQUAL 124 | rc=0 cmp=0 STRICT_EQUAL 124 |
| `tdc/t12_nested_struct` | § pkgTypedefCastTargetTs140 | rc=4 cmp=0 STRICT_NOTEQUAL type | rc=0 cmp=0 STRICT_NOTEQUAL fullname | rc=0 cmp=0 STRICT_NOTEQUAL fullname |

## 5. Residues, ranked (the implementer's list stands; added by this verification)

1. `plv/v05_task` — § procLvTrailIdxNamesByPath140 does not reach a FUNCTION body's lvalue (`tbl[rr].sat[ii] = 1'b1`
   inside a function: golden `work@dut.setb.tbl[rr].sat[ii].ii`, ours `work@dut.setb.ii`); ExprEmit `emitMixedHierPath`.
2. `plv/v07_basesel_opidx` — the base index of `tbl[r ^ 1].sat[i]` is named by the path in golden
   (`work@dut.tbl[r ^ 1].sat[i].r`, ours `work@dut.r`): pass 133's R7 in a process lvalue.
3. `stm/b05_comment` — a comment between a stream's brace and operand: the scan stops and keeps the old span (golden
   3:19-30); `stm/b04_macro` — a macro-born stream keeps the old span.
4. `plv/v11_incdec` — `s.sat[i]++`: the base ref spans `s` alone where golden spans `s.sat` (col 5-6 vs 7-10).
5. `sca/a25_nested_bitsel_in_range` — a bit_select inside a range bound spans its index only (golden 4:16-28, ours
   4:18-27), all binaries.
6. `pfx/x8_netdecl` (`wire [31:0] w = P`) — neutral under the rename; the net-declaration assignment is the sister's
   ground.
7. `tdc/t12_nested_struct` — after § pkgTypedefCastTargetTs140 the next face is a member path's full name.

## Files

* `sca/ stm/ plv/ fav/ pso/ mdi/ lat/ pfp/ pfx/ tdc/ dfl/` — the break grid (129 cases).
* `drivers/`: `rc.sh` (one case on the frozen binaries named in `BINS`: rc, uhdm-cmp lines, strict verdict),
  `fr.sh` (first differing strict records), `dd3.sh` (dump distance, pristine/law/verified), `sw.sh` (a switch
  environment against a reference database), `bytes1.sh` (earlier-pass byte controls), `ds1.py` (downstream verdict of
  a case), `pairs.py` + `worse2.py` (the implementer's record check, pointed at this pass's binaries).
* `evidence/`: sweep outputs (pristine, law, verified vs the committed baselines), byteverify (law vs pristine,
  verified vs law), the record check of all 144 changed pairs, the earlier-pass byte controls, the grid verdicts and
  stage-1 distances.
