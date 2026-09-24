# r11v133 — adversarial verification of r11u133 (the expression/parameter ground on the strict axis)

Verdict: **ACCEPT, no fix.** I rebuilt both binaries and every headline number of r11u133 reproduces bit for bit. None of 64 new cases, 16 earlier-pass control grids, 4087 probe cases, 2568 corpus row-modes or 871 downstream rows came out worse under the law. The production code is r11u133's as shipped. This directory adds only the verifier's cases and evidence.

Base `e562f4d4`. Worktrees `/tmp/wt_v11u133` (the patch) and `/tmp/wt_v11u133pris` (pristine). System-deps configuration, `-j 2`. The binaries were frozen with `chmod 555` before any measurement.

| binary | md5 |
|---|---|
| pristine | `c7b333fcf978012efd649d7383f77730` (the base's required md5) |
| law (r11u133.patch) | `47c5a369425776b106f2773ad4e294a2` (the same as the implementer's) |
| uhdm-strictcmp | `5d4617d0458f34aa79e0b91009d5d1fc` |

## Headline numbers reproduced

Sweeps: `tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil"` with the base's scripts and `SLANG_UHDM` and `STRICT_CMP` exported. Every `cmds.txt` slang line names the frozen binary (law 3273 of 3273, pristine 3273 of 3273). See `evidence/sweep_law.txt` and `evidence/sweep_pristine.txt`.

| stage | pristine vs committed | law vs committed |
|---|---|---|
| probe | regressions=0 conversions=0 changes=0 (EQUAL 2112) | regressions=0 **conversions=81** changes=112 (EQUAL 2193, STRICT_NOTEQUAL 1894) |
| surelog | 0 / 0 / 0 | regressions=0 **conversions=5** changes=22 |
| uhdm2rtlil | 0 / 0 / 0 | regressions=0 **conversions=14** changes=18 |
| downstream (law) | — | `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`; joined to `results/downstream_uhdm2rtlil.csv`, 0 of 871 rows changed on any column |

The 19 corpus conversions are exactly the implementer's list: DecValue/default, HierPathOverride x2, SelectHierPath x2, BitSelectOfParameterPassedToSubmodule x2, ParameterWithUnderscoreValueDividedPassedFromCommandLine x2, assert_wide_const_cond x2, dyn_field_select x2, ff_dead_both_branches x2, ff_dead_guarded_reset x2 and struct_param_func_loop x2. Each fresh row reads `<name>,<mode>,CMP_EQUAL,,,equal`.

The targeted rows' downstream verdicts stay IDENTICAL: `assert_wide_const_cond,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `dyn_field_select,IDENTICAL,OK,OK,151,151,,`, `ff_dead_both_branches,IDENTICAL,OK,OK,8,8,,`, `ff_dead_guarded_reset,IDENTICAL,OK,OK,16,16,,`, `struct_param_func_loop,IDENTICAL,OK,OK,70,70,,`, `BitSelectOfParameterPassedToSubmodule,IDENTICAL,NO_GATES,NO_GATES,0,0,,` and `ParameterWithUnderscoreValueDividedPassedFromCommandLine,IDENTICAL,NO_GATES,NO_GATES,0,0,,`. The downstream lane's database for dyn_field_select is the law binary's own output (`d5a71026865f`; pristine `b40bbe904bb4`).

**Byteverify** (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law workdir vs pristine workdir, same-length names):

| corpus | paths | movers | selfcheck |
|---|---|---|---|
| surelog | `PATH_SETS_IDENTICAL (960 paths)` | `MOVERS: 33 / 960` | 959/960 |
| uhdm2rtlil | `PATH_SETS_IDENTICAL (1608 paths)` | `MOVERS: 56 / 1608` | 1607/1608 |

**Prediction:** I ran the implementer's `predict133.cpp`, rebuilt, on MY pristine databases (`evidence/predictions_pristine.txt`). It flags 105 databases. All 89 movers are among them, so 0 movers are unpredicted. 16 flagged databases did not move, the same 16 the implementer lists (GenForIfaceLocalparamBound/NestedGen, Scr1SvTests, genvar_iface_struct, genvar_loop_decl_2, iface_array_struct(_field), struct_member_trailing_index; their paths come from TypeEmit's emitSyntaxExpr).

**Canaries:**
- `canaries.sh` surelog: law `ok=39 changed=13`. All 13 are strict cells of attributed movers (FuncStructVal, Earlgrey_0_1, SVSwitch, SimpleUVM, SeqDriver, BuildUVMPkg, Scoreboard). The pristine csv reads `ok=52 changed=0`.
- `canaries.sh` uhdm2rtlil: `ok=16 changed=0`.
- `ctcan2.sh`: PASS on both corpora, both binaries.

## Record level: no row or case got worse

I used r11u131's rule, `drivers/v11u133_worse.py`, which is the implementer's `worse2.py` pointed at this pass's comparator. A record is NEW when it matched golden under pristine and differs under the law, before either walk diverges. EARLIER means the law walk diverges first.

- **Corpus:** all 89 byte movers are OK (`evidence/corpus_movers_record_check.txt`).
  - Earlgrey_0_1 diverges later under the law: 50756 → 51100 in default, 52002 → 52346 in testflags. Rggen goes 439 → 469 and ibex_tracer 3727 → 4880. The larger `line`, `file` and `fullname` counts on those rows are objects the walk now reaches; none of them is new before the old divergence.
  - The UVM family (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard) each shows `gone=4 new=0`. These rows are real movers under the two hier_path laws, not the order coin.
- **Probe:** every one of the 4087 cases is OK at record level (`evidence/probe_record_check.txt`). Each database embeds its workdir path, so I checked every case rather than only the byte movers.
- **Earlier passes' grids** (byte movers, path-normalised; `evidence/controls_earlier_passes.txt`):
  - Movers: r11u133 40/50, r11u124 12/81, r11v124 9/107, r11u131 9/121, r11v131 1/128, r11u130 1/98.
  - Zero movers: r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u121, v11u121, r11u125, r11v125, r11v130.
  - 149 judge-equal movers are OK at record level.
  - 12 movers are stage 1 on both binaries. On 11 of them the uhdm-cmp text is identical. On r11u131 `hpm/m05_nested` it differs by one span, a pattern operation `3:39-43` → `3:39-42`; golden's dump prints `3:39-42`, so that one moves toward golden.

## Breaking the laws: 64 fresh cases (first line names the law)

**Grids:**
- `tix/` holds the trailing-index law in contexts the implementer did not grid: a named begin block, a generate for or if, a task, a function argument, a for-loop variable, two refs or nested operations or unary, concat or cast indices, a hier_path index, an interface, a ternary in `always_ff`, a port connection, `$display`, a case subject, a package function, a class method, a modport, a local automatic, and a nonblocking lvalue.
- `hpm/` holds the middle-member law: depth 3, a middle member with a select, a function body, generate, `assign` and `always_ff` lvalues, an unpacked base, two instances, an interface array, an operation, a package function, and a class method.
- `lhs/` holds the Lhs clone law: explicit import, a localparam package, real and string parameters, an unpacked parameter with expression bounds, a three-package chain, two instances with one overridden, typed vector parameters, an interface header, a `$unit` import, and an enum-typed package.
- `pqs/` holds the qualified-span law: `pkg :: NAME` with spaces, generate instances, an override, a body localparam, same-name unqualified, a macro-born reference, a same name from another package, and an interface.
- `unk/` holds the unknown-operand file law: a Z operand mixed with a known operand, and a parameter from an include file.
- The h* cases are downstream probes with gates and name collisions.

Each case was judged by uhdm-cmp and uhdm-strictcmp against the v1.87 golden, checked at record level, and run through the downstream harness (`ds.one`) on both binaries (`evidence/grid*`, `evidence/downstream_grid_*.txt`).

**Results:**
- 27 cases convert to STRICT_EQUAL. 2 are equal on both binaries.
- 22 stay STRICT_NOTEQUAL with nothing new at record level. They sit on faces the laws do not claim: the base-select index inside an operation (the implementer's residue R7), a hier_path index, a generate-scope trailing select, the definition listing's `pkg :: ` span, and the instance-override qualifier.
- 13 are stage 1 on both binaries with the same uhdm-cmp line count.
- **uhdm-cmp moved on no case.**
- **Downstream:** no verdict gets worse. One improves: `hpm/h01_collide_mid` goes from STATUS_DIFF (pristine: slang lane OK with 2 gates, Surelog lane NO_GATES) to **IDENTICAL**. The case is a depth-3 base-select path `tbl[r].g.f.valid` in a module that also declares a signal `f`. The plugin's hier_path fallback (expression.cpp, the "VpiFullName of the ref_obj itself" case) resolves a middle member by its full name. Golden's bare middle member computes `work@dut.f` and resolves to the local `f`. Pristine's stored `tbl[r].g.f` did not. So § hpBaseSelMidMemberBare133 makes the downstream consumer follow Surelog's database here too.

**Switches** (`evidence/single_switches.txt`):
- `R11U133_OFF=1` gives bytes identical to pristine on 58 of 58 cases (grids 1 and 2).
- Each `R11U133_<X>_OFF` returns its own law's cells to pristine bytes. Cells where two laws fire (`pqs/d07`, `pqs/d08`, `tix/f03`) revert only partially.

## Findings (none blocking)

- F1 (hygiene): the implementer's drivers default to `/tmp/r11u133_*` scratch (`run_case.sh` GCACHE, `worse2.py` SC). They are overridable or are the pass's own paths, and nothing touches shared state.
- F2 (residue, pre-existing): the definition listing of a spaced qualifier (`cfg_pkg :: DefaultCfg`) spans `11:34-43`, while golden spans `11:34-44` (qualifier plus spaces). The elaborated copy under § elabPatQualRefQualSpan133 matches golden at `34-44`. The definition-view site is not this pass's.
- F3 (residue): a macro-born `pkg::NAME` (`pqs/d06`) is excluded by the law. Golden spans the macro use by the qualifier's length (`12:34-43`); ours spans the whole expansion (`12:34-53`), as pristine did.
- F4 (residue): a trailing select inside a generate block (`tix/a02`, `tix/f06`) takes another case. Golden has bit_select `work@dut.gb.s.sat[i].sat` at the index span; ours has `s.sat[i]` at the member-plus-index span, and the index ref is still `work@dut.gb.i`. A hier_path index (`tix/a07`, golden `work@dut.s.f.sat.sat.k`) is not renamed.

## Cases

| case | law (first line) | pristine | law | record check | downstream pristine -> law |
|---|---|---|---|---|---|
| `hpm/b01_depth3` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 272 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/b02_mid_select` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_EQUAL 227 objects | cmp=0 STRICT_EQUAL 227 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/b03_func_body` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 297 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/b04_gen` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL endcol | OK | IDENTICAL -> IDENTICAL |
| `hpm/b05_lhs_assign` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 239 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/b06_ff_lhs` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 291 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/b07_unpacked` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 289 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/b08_sub_inst` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `hpm/b09_iface_array` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_EQUAL 258 objects | cmp=0 STRICT_EQUAL 258 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/b10_in_operation` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `hpm/g01_pkg_func_mid` | § hpBaseSelMidMemberBare133 | cmp=370 NOT_EQUAL stage1 | cmp=370 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `hpm/g02_class_mid` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 141 objects | OK | IDENTICAL -> IDENTICAL |
| `hpm/h01_collide_mid` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 413 objects | OK | STATUS_DIFF -> IDENTICAL |
| `hpm/h02_collide_mid_lhs` | § hpBaseSelMidMemberBare133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 396 objects | OK | IDENTICAL -> IDENTICAL |
| `lhs/c01_explicit_import` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL line | OK | IDENTICAL -> IDENTICAL |
| `lhs/c02_localparam_pkg` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `lhs/c03_real_string` | § impPaLhsDisjointClone133 | cmp=64 NOT_EQUAL stage1 | cmp=64 NOT_EQUAL stage1 | STAGE1 | EQUIVALENT -> EQUIVALENT |
| `lhs/c04_unpacked_expr_range` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL type | OK | IDENTICAL -> IDENTICAL |
| `lhs/c05_pkg_chain3` | § impPaLhsDisjointClone133 | cmp=50 NOT_EQUAL stage1 | cmp=50 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `lhs/c06_two_instances_overridden` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL line | OK | IDENTICAL -> IDENTICAL |
| `lhs/c07_typed_logic_vec` | § impPaLhsDisjointClone133 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `lhs/c08_program` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL line | OK | IDENTICAL -> IDENTICAL |
| `lhs/c09_unit_import` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `lhs/c10_enum_typed` | § impPaLhsDisjointClone133 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `lhs/h05_downstream_hdr` | § impPaLhsDisjointClone133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL line | OK | IDENTICAL -> IDENTICAL |
| `pqs/d01_space_qual` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL endcol | OK | IDENTICAL -> IDENTICAL |
| `pqs/d02_gen_inst` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `pqs/d03_ovr_qual` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_NOTEQUAL line | OK | IDENTICAL -> IDENTICAL |
| `pqs/d04_localparam_body` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 168 objects | OK | IDENTICAL -> IDENTICAL |
| `pqs/d05_samename_unqual_import` | § elabPatQualRefQualSpan133 | cmp=36 NOT_EQUAL stage1 | cmp=36 NOT_EQUAL stage1 | STAGE1 | EQUIVALENT -> EQUIVALENT |
| `pqs/d06_macro_qual` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL endcol | OK | IDENTICAL -> IDENTICAL |
| `pqs/d07_samename_two_pkgs` | § elabPatQualRefQualSpan133 | cmp=36 NOT_EQUAL stage1 | cmp=36 NOT_EQUAL stage1 | STAGE1 | EQUIVALENT -> EQUIVALENT |
| `pqs/d08_iface_body_samename` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL col | OK | IDENTICAL -> IDENTICAL |
| `pqs/h06_downstream_qual` | § elabPatQualRefQualSpan133 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_EQUAL 292 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a01_named_begin` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 178 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a02_gen_for` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `tix/a03_task` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 188 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a04_func_arg` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 196 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a05_for_loopvar` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 188 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a06_two_refs` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 200 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a07_hier_idx` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `tix/a08_interface` | § hpTrailSelIdxNamesByPath133 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `tix/a09_ternary_ff` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 242 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a10_port_conn` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `tix/a11_gen_scope_decl` | § hpTrailSelIdxNamesByPath133 | cmp=58 NOT_EQUAL stage1 | cmp=58 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `tix/a12_nested_op` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 204 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a13_display` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 163 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/a14_case` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 194 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/f01_pkg_func` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL line | OK | IDENTICAL -> IDENTICAL |
| `tix/f02_class_method` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 126 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/f03_pkg_func_arr` | § hpTrailSelIdxNamesByPath133 | cmp=370 NOT_EQUAL stage1 | cmp=370 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `tix/f04_modport_iface` | § hpTrailSelIdxNamesByPath133 | cmp=152 NOT_EQUAL stage1 | cmp=152 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `tix/f05_ref_localvar` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 173 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/f06_gen_if` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `tix/f07_nested_member_idx` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 178 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/f08_unpacked_member` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 195 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/f09_lhs_nonblocking_idx` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `tix/f10_idx_cast` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname | OK | IDENTICAL -> IDENTICAL |
| `tix/f11_unary_idx` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 151 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/f12_idx_concat` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 157 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/h03_collide_idx` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 313 objects | OK | IDENTICAL -> IDENTICAL |
| `tix/h04_idx_op_ff` | § hpTrailSelIdxNamesByPath133 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 329 objects | OK | IDENTICAL -> IDENTICAL |
| `unk/e01_mul_x_local` | § unknownParamOperandFile133 | cmp=32 NOT_EQUAL stage1 | cmp=32 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |
| `unk/e02_include` | § unknownParamOperandFile133 | cmp=48 NOT_EQUAL stage1 | cmp=48 NOT_EQUAL stage1 | STAGE1 | IDENTICAL -> IDENTICAL |

## Files

- `drivers/v11u133_grid.sh`: a grid on one binary. The golden is the pinned Surelog with the probe flags, cached by the md5 of the case's files.
- `drivers/v11u133_worse.py`: the record-level check.
- `drivers/v11u133_ds.py`: the downstream harness's `one()` over a grid.
- `drivers/v11u133_ctl.sh`: an earlier-pass control grid, byte-compared and record-checked.
- `drivers/v11u133_sw.sh`: the switch runs.
- `drivers/v11u133_sweep.sh`: the sweep wrapper.
- `evidence/`: as cited above.
