# r11u173: second adversarial verification of passes 164 and 167 (verifier, measurement plus one refinement patch)

Base `edb34d8a` (branch matrix-1.87). Pass 164 (with the r11u161 decode and its verifier v11u164's two refinements)
landed at `35ed4056`, r11u170's three refinements at `2dcbc596`, pass 167 (with its verifier r11v167's refinement) at
`45b8e774`; the commit before pass 164 is `d8cfd83a`. Worktrees: `/tmp/wt_r11u173` (HEAD, the deliverable),
`/tmp/wt_r11u173pre` (`d8cfd83a`), `/tmp/wt_r11u173fix` (HEAD + [fix.patch](fix.patch)). System-deps configuration,
`-j 2`.

This directory is the whole deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is
edited. The refinement is [fix.patch](fix.patch), a `git diff edb34d8a -- src` (one file, `src/ModuleEmit.cpp`) that
applies clean on a fresh `edb34d8a` (`git apply --check`, measured). It is NOT applied here. No canonicalisation
patch for `tools/uhdm-strictcmp` was handed to this pass, and no comparator defect was found, so the comparator is not
edited.

The slang-fenced tests are named nowhere here. [drivers/env.sh](drivers/env.sh) builds `$FENCED` from RESUME.md
without spelling it. Every driver that reads corpus sources or databases refuses to run without it and skips those
names by word boundary (section 9).

## Verdict

**One break found, fixed behind its own switch in fix.patch (§ pvElabGenDefParamLhs173v, `R11V173_PVELABGEN_OFF`).**

| break | law | shape | axis |
|---|---|---|---|
| B1 | § modportPortViewParamDef164 | under `--elabuhdm` (testflags mode), a copy-style port view (ordered, selected, out of scope) of an instance that sits inside a generate scope, directly or through any instance above it | strict: the port view's parameter under the elaborated instance was `work@top.g.u.b.W` in golden and in pristine; the law makes it `work@my_if.W` (pv/p07 and p16: 4 and 2 records AWAY at aligned walk positions before the pristine divergence; p11 p13 p14 p15 stage 1, AWAY by dump distance) |

The law is right in default mode on the same cases (pv/p07 converts to STRICT_EQUAL, p11 p13-p16 move closer), and
right under `--elabuhdm` for instances outside generate scopes (pv/p12). The decode: Surelog hands the port view the
DEFINITION's parameter (`inst_assign->Lhs(mod_assign->Lhs())`, NetlistElaboration.cpp:450), whose full name is
unstored; UHDM's ElaboratorListener (run under `-elabuhdm` only) re-clones generate-scope instances and a DeepClone
recomputes an unstored name through the clone's parent chain (§ elabCloneFullNameUnstored137). The law STORES
`work@my_if.W` on a per-view copy, and the clone copies it verbatim. The refinement makes such a view's Lhs the
definition's own parameter under `--elabuhdm`. It moves 6 of the 125 fresh cases (2 to STRICT_EQUAL) and 23 earlier
passes' cases (8 to STRICT_EQUAL), all toward golden, and no corpus row, probe case or downstream row
(census before the sweep: 0 firings, positive control 2).

No other break was found: across 125 fresh cases x 2 modes (the laws' own switches, the landing switches, both
landings off, the pre-164 build), no field that matched golden moves away except B1; no case loses STRICT_EQUAL;
no case crashes where pristine writes a database; downstream, 16 cases improve to IDENTICAL and none leaves it.
Every order-blind AWAY reading was traced to its object and is either B1 or a dump artefact outside the judge's walk
(the `weaklyReferenced` tail, or a shared object's lines matching golden by coincidence; section 3.2).

**Composition: additive.**

- `R11U161_OFF R11U164_OFF R11U167_OFF R11V170_OFF` on HEAD gives the bytes of the `d8cfd83a` build everywhere:
  probe 0/4087 movers, corpora 6/2560 (the UVM coin, 4 order-blind lines each), csvs identical.
- Every conversion the landings claimed is owned by exactly one landing: probe 50 + 29, surelog 6 + 4, uhdm2rtlil
  8 + 4 (OWN164 + OWN167; no SHARED, no JOINT). No pair of laws cancels: 0 rows at the status level; at the byte
  level the only candidates are the four UVM coin databases.
- The two landings' byte movers are disjoint (probe 126 | 43, corpus 24 | 14) except Rggen/default, which both move
  record-neutrally, as both passes reported.

**Changes: all unmaskings or strict improvements.** Both landings off against HEAD, record by record: probe 86 CHANGE
lines = 77 SUBSET + 9 UNMASK (every new record past the pristine divergence), surelog 6 SUBSET, uhdm2rtlil 0.

**Downstream: the six converted uhdm2rtlil rows are byte-identical to golden's lane** (`.il`, `_nohier.il`,
`_synth.v`), and the downstream csv is byte-identical with both landings off (the landings are downstream-neutral on
the corpus).

**Fence: held.** No law, case or number rests on a fenced reading: the fenced rows' verdicts are identical with both
landings on and off; four laws nearest the fenced shapes were re-derived here from Surelog's source and fresh cases.
26 drivers of the four directories lack their own `$FENCED` refusal; all but one read only evidence cases,
probe cases or their own scratch, or are the gate sweep / a SLANG_UHDM stand-in dispatched under a fenced
`--filter`. The exception, r11v167repro/drivers/audit.sh, greps every corpus row's `cmds.txt`, the fenced rows'
included (a sweep artefact, not a source or database; section 9).

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u173_bin/law.bin` | `d64816326230eb41669e1062297ba547` | worktree build of edb34d8a = the main tree's `build/slang-uhdm` (the brief's `d64816326230`) |
| `/tmp/r11u173_bin/pre.bin` | `2a705713aa2d9ba859d3fd83eaa95ed7` | build of `d8cfd83a`, the commit before pass 164 (= r11u170's law.bin) |
| `/tmp/r11u173_bin/fix1.bin` | `13add26eb37c1ceb1bd1236ee9f78557` | edb34d8a + fix.patch |
| `/tmp/r11u173_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `alloff.sh`, `off164.sh`, `off167.sh`, `alloff170.sh` | wrappers ([drivers/mkstate.sh](drivers/mkstate.sh)) | law.bin under `R11U161_OFF R11U164_OFF R11U167_OFF`, `R11U161_OFF R11U164_OFF`, `R11U167_OFF`, and all three plus `R11V170_OFF` |

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/sweep.sh](drivers/sweep.sh); workdir names all the same length)

| sweep | binary | probe EQUAL / STRICT_NOTEQUAL | vs committed baselines (probe; surelog; uhdm2rtlil) | downstream |
|---|---|---|---|---|
| swH | law.bin (the gate) | 2676 / 1411 | 0/0/0; 0/0/0; 0/0/0 | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 |
| swA | alloff.sh | 2597 / 1490 | regressions 79, changes 86; 10, 6; 12, 0 | csv byte-identical to swH's |
| sw4 | off164.sh | 2626 / 1461 | 50, 73; 6, 4; 8, 0 | - |
| sw7 | off167.sh | 2647 / 1440 | 29, 13; 4, 2; 4, 0 | - |
| swZ | alloff170.sh | 2597 / 1490 | as swA; csvs identical to swP's | - |
| swP | pre.bin | 2597 / 1490 | as swA | - |
| swF | fix1.bin | 2676 / 1411 | 0/0/0; 0/0/0; 0/0/0 | 803 / 66 / 2 / 0, csv byte-identical to swH's |

Every sweep's `cmds.txt` names its own binary: 1531 surelog and 1742 uhdm2rtlil `slang:` lines each (the other 50
surelog `cmds.txt` hold no slang line, SURELOG_FAIL and the like). The downstream stage ran the exported binary too:
interface_array's downstream `slang.uhdm` reads `89b9ac1b` with both landings off and `4781d46c` at HEAD (the md5s
v11u164 quoted for its pristine and law binaries), with byte-identical netlists. Every sweep exits 1 for one reason,
`law index STALE`: a clean checkout of edb34d8a itself reads STALE (the r11u172 commit named four `§` laws in its
message without regenerating tests/LAWS.md: `boundLitWrittenDigits172`, `pkgFnCastTopListing172`,
`sysSignNameSpanSyntax172`, `tdMoveCarriesFile172`), and this directory's cases name laws, so the landing regenerates it.

Gate results at HEAD ([evidence/sweep_head.log](evidence/sweep_head.log)): `probe.csv` byte-identical to
results/golden_probe.csv and `downstream.csv` to results/downstream_uhdm2rtlil.csv; canaries.sh surelog ok=52
changed=0, uhdm2rtlil ok=16 changed=0; ctcan2.sh surelog ok=58 changed=0 PASS (EXPECT_UNKNOWN=1), uhdm2rtlil ok=2
changed=0 PASS (EXPECT_UNKNOWN=6) ([evidence/swH_canaries.txt](evidence/swH_canaries.txt)). uhdm-cmp reads 0 lines on
every row the two landings touched, both modes ([evidence/touched_rows_cmp.txt](evidence/touched_rows_cmp.txt)):

    surelog     HighLow, GenIfIfaceParamStructField, ComplexHierPath, StructParamFieldRange,
                StructParamFuncBodyFieldCompare                       d/t  CMP_EQUAL,,,equal
                Earlgrey_0_1 d/t differ:line(1686), GenForStructParamBound d/t differ:fullname(3),
                StructParamPatternInitCast d/t differ:fullname(3)     (STRICT_NOTEQUAL, judge-equal)
    uhdm2rtlil  iface_param_port_width, interface_array, interface_array_fanout, mriscv_bind_sva,
                cva6_struct_param_field, ibex_register_file_ff        d/t  CMP_EQUAL,,,equal

## 3. The fresh cases and the per-law scores

125 cases in [cases/](cases) (15 groups), none in any grid of r11u161gen, r11u164repro, v11u164repro, r11u167repro or
r11v167repro; the first line of each names its laws. [drivers/grid.py](drivers/grid.py) runs every case in both
modes (default = check_probe's arguments; `--elabuhdm` = Surelog `-elabuhdm`, ours `--elabuhdm`) under: ON, each
named law's own switch (a refinement also under its parent's), each landing off, both landings off, both off plus
`R11V170_OFF`, and pre.bin. It scores ON against each state from the strict records (uhdm-strictcmp `--max 100000`,
field by field): UNFIRED (same bytes), TOWARD (records only leave), AWAY / MIXED (a new record at an aligned walk
position: a break candidate), UNMASK (new records past the off state's divergence), BYTES-ONLY, and for stage-1
cases the order-blind dump distance to golden (STAGE1-CLOSER / SAME / AWAY). Downstream is the harness's own `one()`
([drivers/dscase.py](drivers/dscase.py)), both landings off against ON.

Totals (law x case cells): default mode TOWARD 38, STAGE1-CLOSER 67, STAGE1-SAME 4, BYTES-ONLY 2, UNFIRED 64,
STAGE1-AWAY 9; `--elabuhdm` TOWARD 35, STAGE1-CLOSER 54, UNMASK 2, STAGE1-SAME 4, BYTES-ONLY 10, UNFIRED 64,
STAGE1-AWAY 14, MIXED 1. STRICT_EQUAL cases: both landings off 8 -> ON 43 (default), 8 -> 41 (`--elabuhdm`); no case that is
STRICT_EQUAL with the landings off reads otherwise with them on. Both-off-plus-`R11V170_OFF` equals pre.bin's bytes
on 125/125 cases in both modes. Downstream: 16 cases go to IDENTICAL (EA e01 e02 e04 e05 e06 e09, x04, HW w01-w08
w11), none leaves IDENTICAL ([evidence/downstream_cases_ALLOFF.txt](evidence/downstream_cases_ALLOFF.txt) ->
[evidence/downstream_cases_ON.txt](evidence/downstream_cases_ON.txt)).

### 3.1 Per law (verdict abbreviations: EQ = STRICT_EQUAL, S1 = NOT_EQUAL stage 1, otherwise the first differing field)

Generated by [drivers/lawtables.py](drivers/lawtables.py) from [evidence/grid_default.txt](evidence/grid_default.txt),
[evidence/grid_elabuhdm.txt](evidence/grid_elabuhdm.txt) and the downstream files. The two pass-157/158 laws appear
only as the cross pairs' second law.

#### § arrQueryFoldAtBound158 (1 cases: STAGE1-CLOSER 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x06_range_query_param_fold | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |

#### § bindUnresolvedPathNoName164 (4 cases: TOWARD 2, UNFIRED 2)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| bu/u01_bind_type_two_instances | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| bu/u02_bind_unresolved_selected | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | EQUIVALENT -> EQUIVALENT |
| bu/u03_bind_instance_path_target | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| bu/u04_bind_genscope_path | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § caDelayFirstOnly164 (9 cases: STAGE1-AWAY 1, STAGE1-CLOSER 3, TOWARD 3, UNFIRED 2)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| dl/d01_localparam_expr_list | type | S1 | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| dl/d02_pkg_param_list | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| dl/d03_expr_list | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| dl/d04_genif_literal_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d05_mintypmax_list | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| dl/d06_param_iface_two_insts | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| dl/d08_three_list_param_child | type | S1 | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| dl/d09_imported_param | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| dl/d10_param_delay_genfor_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § caDelayParamElabFresh164 (7 cases: STAGE1-CLOSER 3, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| dl/d01_localparam_expr_list | S1 | S1 | EQ | STAGE1-CLOSER | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| dl/d02_pkg_param_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d06_param_iface_two_insts | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d07_real_param | S1 | S1 | EQ | STAGE1-CLOSER | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| dl/d08_three_list_param_child | S1 | S1 | EQ | STAGE1-CLOSER | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| dl/d09_imported_param | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| dl/d10_param_delay_genfor_list | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § defGenPathSel161 (9 cases: STAGE1-CLOSER 3, TOWARD 3, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x05_defgen_vs_elab_path_select | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gp/g01_nested_iface_lhs_genif | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| gp/g02_genif_cond_two_paths | EQ | depth | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gp/g03_concat_lhs_genif | col | col | col | UNFIRED | col | UNFIRED | IDENTICAL -> IDENTICAL |
| gp/g04_genfor_port_param_bound | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gp/g05_gencase_item_struct_param | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| gp/g06_genif_cond_call_arg | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| gp/g07_rhs_concat_paths | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| hw/w05_genblock_target_def_view | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |

#### § defGenSelBaseLeafAtIndex164 (4 cases: STAGE1-CLOSER 2, TOWARD 1, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| sb/s01_genvar_expr_base | endcol | endcol | endcol | UNFIRED | endcol | UNFIRED | IDENTICAL -> IDENTICAL |
| sb/s02_iface_array_leaf | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| sb/s03_union_leaf | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| sb/s04_gencase_inside_for | endcol | endcol | fullname | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § enumAliasBaseAsTarget164v (3 cases: STAGE1-CLOSER 2, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| ea/e01_pkg_param_base_module_enum | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e05_header_param_base_override | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e06_unit_alias_expr_base | EQ | S1 | EQ | UNFIRED | EQ | UNFIRED | DIVERGENT -> IDENTICAL |

#### § enumAliasClone161 (10 cases: STAGE1-CLOSER 9, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x04_alias_enum_in_func_body | S1 | S1 | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e01_pkg_param_base_module_enum | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e02_alias_chain_iface | S1 | S1 | name | STAGE1-CLOSER | name | STAGE1-CLOSER | EQUIVALENT -> IDENTICAL |
| ea/e03_alias_in_program | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| ea/e04_iface_alias_modport_var | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e05_header_param_base_override | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e06_unit_alias_expr_base | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| ea/e07_unpacked_dim_alias | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| ea/e08_param_valued_members | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| ea/e09_unit_import_alias | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |

#### § evalFuncBodyRhsStampClone167 (12 cases: STAGE1-CLOSER 2, TOWARD 5, UNFIRED 5)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x04_alias_enum_in_func_body | fullname | S1 | fullname | TOWARD | fullname | TOWARD | DIVERGENT -> IDENTICAL |
| fb/b01_part_select | EQ | EQ | EQ | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b02_indexed_part_select | EQ | EQ | EQ | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b03_concat | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| fb/b04_user_call | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b05_size_cast | fullname | fullname | fullname | TOWARD | fullname | UNMASK | IDENTICAL -> IDENTICAL |
| fb/b06_ternary | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| fb/b07_unary_reduction | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| fb/b08_sys_call | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b09_nested_member | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| fb/b10_row_select | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b11_instance_array | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § firstOrderedPathSel161 (6 cases: STAGE1-CLOSER 1, TOWARD 1, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| fo/f01_ordered_iface_struct_member | col | col | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| fo/f02_ordered_instance_array | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| fo/f03_ordered_concat_first | col | col | col | UNFIRED | col | UNFIRED | IDENTICAL -> IDENTICAL |
| fo/f04_ordered_param_and_ports_genblk | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fo/f05_empty_first_ordered | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| fo/f06_partsel_first | col | col | col | UNFIRED | col | UNFIRED | IDENTICAL -> IDENTICAL |

#### § genNetDeclAssignLhsShared164 (7 cases: STAGE1-CLOSER 5, TOWARD 2)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x03_gen_netdecl_and_proc_fold | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| cx/x08_one_genscope_netdecl_and_fold | depth | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| nd/n01_two_declarators | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| nd/n02_tri_nettype | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| nd/n03_in_interface_genblk | S1 | S1 | S1 | STAGE1-CLOSER | depth | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| nd/n04_signed_vec_genfor | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| nd/n05_iface_port_member | depth | depth | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § genProcFoldDeclTsScopeNamed167 (11 cases: STAGE1-CLOSER 1, TOWARD 4, UNFIRED 6)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x03_gen_netdecl_and_proc_fold | S1 | S1 | S1 | UNFIRED | depth | UNFIRED | IDENTICAL -> IDENTICAL |
| cx/x08_one_genscope_netdecl_and_fold | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gs/z01_struct_typed_param | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z02_signed_genfor | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| gs/z03_typedef_typed_param | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z04_int_typed_param | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z05_gencase_wide_range | fullname | fullname | EQ | TOWARD | EQ | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| gs/z06_ascending_range_bit | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| gs/z07_param_select_genfor | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z08_genscope_contassign_ctl | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| gs/z09_param_in_genproc_expr | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |

#### § hpDotWsTrimmed167 (13 cases: STAGE1-CLOSER 10, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| hw/w01_blank_after_dot_lhs | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w02_port_actual | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w03_if_condition | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w04_genblock_scope_path | S1 | S1 | S1 | STAGE1-CLOSER | depth | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w05_genblock_target_def_view | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w06_three_dots_mixed | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| hw/w07_root_path | S1 | S1 | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | DIVERGENT -> IDENTICAL |
| hw/w08_genarray_elem | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w09_root_path_noblank_ctl | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| hw/w10_genblock_scope_path_noblank_ctl | S1 | S1 | S1 | UNFIRED | depth | UNFIRED | IDENTICAL -> IDENTICAL |
| hw/w11_macro_path | S1 | S1 | EQ | STAGE1-CLOSER | EQ | STAGE1-CLOSER | STATUS_DIFF -> IDENTICAL |
| hw/w12_index_member_blanks | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| hw/w13_index_member_noblank_ctl | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |

#### § hpSelRoute157 (1 cases: UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x05_defgen_vs_elab_path_select | EQ | col | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |

#### § modportPortViewParamDef164 (20 cases: STAGE1-CLOSER 8, STAGE1-SAME 1, TOWARD 7, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x01_pview_struct_typed_iface_param | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| cx/x02_pview_header_type_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| cx/x07_pview_generic_struct_param_iface | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| cx/x09_pview_header_param_and_tp_struct | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| pv/p01_shorthand_two_params | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p02_wildcard_passthrough | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | STATUS_DIFF -> STATUS_DIFF |
| pv/p03_iface_array_port | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p04_generic_two_levels | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p05_ordered_three_levels | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p06_derived_localparam_ordered | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p07_array_elem_genfor_named | fullname | fullname | EQ | TOWARD | fullname | UNMASK | IDENTICAL -> IDENTICAL |
| pv/p08_generic_modport_ordered_two_ifs | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | STATUS_DIFF -> STATUS_DIFF |
| pv/p09_named_absolute_path_actual | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p10_two_parents_different_values | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| pv/p11_iface_in_genblock_ordered | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p12_top_ordered_ctl | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p13_genif_view_iface_outside | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p14_genfor_ordered_elem | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p15_view_below_genblock_module | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p16_genif_named_inscope_ctl | S1 | S1 | S1 | STAGE1-CLOSER | fullname | MIXED | IDENTICAL -> IDENTICAL |

#### § pkgPatCallArgReadNoParent167 (4 cases: STAGE1-AWAY 3, TOWARD 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| pc/c01_nested_call | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pc/c02_genif_localparam | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pc/c03_member_arg_user_fn | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| pc/c04_iface_header_default | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |

#### § portViewParamShared164 (12 cases: STAGE1-AWAY 4, TOWARD 4, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x02_pview_header_type_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p01_shorthand_two_params | EQ | EQ | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p02_wildcard_passthrough | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | STATUS_DIFF -> STATUS_DIFF |
| pv/p03_iface_array_port | depth | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p04_generic_two_levels | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p05_ordered_three_levels | depth | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p07_array_elem_genfor_named | depth | fullname | EQ | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| pv/p08_generic_modport_ordered_two_ifs | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | STATUS_DIFF -> STATUS_DIFF |
| pv/p09_named_absolute_path_actual | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p10_two_parents_different_values | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| pv/p11_iface_in_genblock_ordered | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| pv/p14_genfor_ordered_elem | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |

#### § rangeQueryDeclNetSize164 (6 cases: STAGE1-CLOSER 5, UNFIRED 1)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| rq/q01_left_param_onto_wider | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q03_high_var_genscope_decl | type | type | type | UNFIRED | line | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q05_low_net_masked | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q06_high_packed2d_onto_2bit | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q07_left_port_onto_decl | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q09_high_param_onto_var | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |

#### § rangeQueryFoldUnconverted164 (7 cases: STAGE1-SAME 2, TOWARD 1, UNFIRED 4)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x06_range_query_param_fold | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | IDENTICAL -> IDENTICAL |
| rq/q01_left_param_onto_wider | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q02_right_unpacked_var_implicit | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | DIVERGENT -> DIVERGENT |
| rq/q03_high_var_genscope_decl | type | type | type | UNFIRED | line | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q04_low_localparam_implicit | value | value | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| rq/q08_high_param_genfor | S1 | S1 | S1 | UNFIRED | line | UNFIRED | DIVERGENT -> DIVERGENT |
| rq/q09_high_param_onto_var | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § rangeQueryVarDeclMask164v (4 cases: STAGE1-CLOSER 1, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| rq/q03_high_var_genscope_decl | type | type | type | UNFIRED | line | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q05_low_net_masked | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| rq/q06_high_packed2d_onto_2bit | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| rq/q07_left_port_onto_decl | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |

#### § s2ClonePrecheck167v (11 cases: BYTES-ONLY 1, STAGE1-CLOSER 4, UNFIRED 6)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| fb/b01_part_select | SLANG_FAIL | EQ | EQ | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b02_indexed_part_select | SLANG_FAIL | EQ | EQ | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b03_concat | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b04_user_call | fullname | fullname | fullname | BYTES-ONLY | fullname | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| fb/b05_size_cast | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b06_ternary | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | EQUIVALENT -> EQUIVALENT |
| fb/b07_unary_reduction | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |
| fb/b08_sys_call | SLANG_FAIL | fullname | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b09_nested_member | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| fb/b10_row_select | SLANG_FAIL | fullname | fullname | STAGE1-CLOSER | fullname | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| fb/b11_instance_array | EQ | fullname | EQ | UNFIRED | EQ | UNFIRED | IDENTICAL -> IDENTICAL |

#### § tpAnonStructCopySpanAtKeyword167 (11 cases: BYTES-ONLY 1, STAGE1-CLOSER 6, TOWARD 1, UNFIRED 3)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x07_pview_generic_struct_param_iface | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| cx/x09_pview_header_param_and_tp_struct | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| tp/t01_three_value_params_forms | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |
| tp/t02_function_formal_user | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t03_unpacked_struct | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t04_nested_type_params | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| tp/t05_header_default_two_insts_one_override | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | EQUIVALENT -> EQUIVALENT |
| tp/t06_packed_union | endline | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| tp/t07_task_formal_and_ports | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t08_alias_of_type_param | fullname | fullname | fullname | BYTES-ONLY | fullname | BYTES-ONLY | IDENTICAL -> IDENTICAL |
| tp/t09_cast_in_body | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | IDENTICAL -> IDENTICAL |

#### § tpAnonStructLastParamUser167 (12 cases: STAGE1-AWAY 1, STAGE1-CLOSER 1, STAGE1-SAME 1, TOWARD 3, UNFIRED 6)

| case | law off | both landings off | on | on vs law off | --elabuhdm: on | --elabuhdm: on vs law off | downstream off -> on |
|---|---|---|---|---|---|---|---|
| cx/x01_pview_struct_typed_iface_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| cx/x02_pview_header_type_param | fullname | fullname | fullname | TOWARD | fullname | TOWARD | IDENTICAL -> IDENTICAL |
| cx/x09_pview_header_param_and_tp_struct | S1 | S1 | S1 | STAGE1-AWAY | S1 | STAGE1-AWAY | IDENTICAL -> IDENTICAL |
| tp/t01_three_value_params_forms | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t02_function_formal_user | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t03_unpacked_struct | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t04_nested_type_params | S1 | S1 | S1 | STAGE1-CLOSER | S1 | STAGE1-CLOSER | DIVERGENT -> DIVERGENT |
| tp/t05_header_default_two_insts_one_override | S1 | S1 | S1 | STAGE1-SAME | S1 | STAGE1-SAME | EQUIVALENT -> EQUIVALENT |
| tp/t06_packed_union | fullname | fullname | EQ | TOWARD | EQ | TOWARD | IDENTICAL -> IDENTICAL |
| tp/t07_task_formal_and_ports | line | line | line | UNFIRED | S1 | UNFIRED | DIVERGENT -> DIVERGENT |
| tp/t08_alias_of_type_param | fullname | fullname | fullname | UNFIRED | fullname | UNFIRED | IDENTICAL -> IDENTICAL |
| tp/t09_cast_in_body | S1 | S1 | S1 | UNFIRED | S1 | UNFIRED | IDENTICAL -> IDENTICAL |


### 3.2 Every AWAY-type reading, traced to its object

| reading | cases | what moved | verdict |
|---|---|---|---|
| § modportPortViewParamDef164 AWAY / MIXED under `--elabuhdm` | pv p11 p13 p14 p15 (STAGE1-AWAY), p16 (MIXED), p07 (UNMASK in grid.py's classification; the new records #121/#173 sit BEFORE the pristine divergence #190) | the parameter of the port view under the elaborated instance in a generate scope: golden and pristine `work@top.g.u.b.W`, law `work@my_if.W` | **BREAK B1** (section 4) |
| § portViewParamShared164 STAGE1-AWAY (+2 dump lines) | pv p02 p04 p10 p14 (both modes) | the later view's own parameter object, orphaned by the share, printed in the `\_weaklyReferenced:` tail (column 0, after the marker; r11u164's g6/p07_two_level precedent) | tail only: the judge's walk and the plugin never read it |
| § pkgPatCallArgReadNoParent167 STAGE1-AWAY (+3) | pc c01 (nested call), c02 (gen-if localparam), c04 (interface header default), both modes | the walked package param_assign's pattern reference: golden unnamed, law unnamed, pristine `(p)`; golden's named `(p)` copy is the ORIGINAL operation, orphaned in its weak tail by CompileHelper::getValue's write-back (`param->Rhs(rhs)`, CompileExpression.cpp:943) | toward golden at the walked object; the order-blind lines were pristine's walked copy matching golden's orphan |
| § caDelayFirstOnly164 STAGE1-AWAY | dl d06 (both modes), d03 (`--elabuhdm`) | the definition view's second cont_assign now shares the first one's delay object, exactly as golden prints it (no children); the lost "golden" lines were the duplicated wrong subtree's generic lines (`\|vpiParent:`, `\_cont_assign: , line:3:19`) coinciding with golden lines elsewhere. d06's stage 1 is the interface INSTANCE's missing elaborated delay (residue N3), d03's the `#(D + 1)` object (r11u164 d14's residue) | structurally equal to golden at the moved object |
| defGenPathSel161 (landing) MIXED | sb s01 (`s[i+1].f[0]`, an operation base where § defGenSelBaseLeafAtIndex164 abstains) | the leaf bit_select: golden `s[i + 1].f[0]` 6:21-6:22, pristine `s[i+1].f[0]` 6:19-6:20, law a selected-field full name 6:19-6:23 | wrong to wrong on every field (no field matched golden before); residue N6 |
| § tpAnonStructLastParamUser167 STAGE1-AWAY (+4) | cx x09 (an interface with a header parameter and a body type parameter's struct used by a value parameter, both modes) | the struct copy's parent and member-reference names (`work@my_if.I.x`): every changed line lies after the dump's `\_weaklyReferenced:` marker (aligned dump diff: first change at line 573, marker at 563) | tail only |
| STAGE1-SAME with new ours-only lines | rq q02 x06 (§ rangeQueryFoldUnconverted164), tp t05 (§ tpAnonStructLastParamUser167), pv p08 | q02: golden's `$right` of an unpacked variable is UINT:32 size 64 (Surelog), pristine UINT:1, law UINT:5 (wrong to wrong); x06: the implicit-net constant moves UINT:1 -> UINT:5 = golden; t05: the moved struct objects are all in the weak tail; p08: golden has no port view for an `interface.mp` generic port there (pre-existing stage 1) | none moves a matching field |

Field-level spot checks on stage-1 range-query cases, the elaborated right side at HEAD against golden: q05 (`$low`
of a net, bound 9, onto 3 bits) UINT:1 size 3 = golden; q06 UINT:3 size 2 = golden; q07 UINT:5 size 3 = golden; q01
UINT:9 size 16 = golden; q09 (a parameter onto a 3-bit VARIABLE) UINT:6 size 3 = golden (unmasked, the parameter
query). Their stage 1 is the located range-bound object (v11u164 residue 2).

### 3.3 Notes by law family

- **§ s2ClonePrecheck167v holds on every clone shape written.** With the pre-check switched off, fb b01 (part
  select), b02 (indexed part select), b08 (`$countones`) and b10 (row select of a 2-D member) crash (rc 139, no
  database) and b04 (user call) leaves orphan objects in the file; with it on, every one of the 11 fb shapes writes a
  database, and b03 (concatenation) b07 (unary reduction) b11 (instance array) convert to STRICT_EQUAL. The clone
  abstains (pristine bytes) on calls, system calls and selected path elements; b05 (size cast) b06 (ternary) b09
  (nested member) move toward golden.
- **§ hpDotWsTrimmed167:** blanks after a dot only (w01), in a port actual (w02), in a procedural condition (w03), at
  both dots of a three-component path (w06), a generate-array element (w08) and from a macro expansion (w11) all
  convert; `$root . top . s` (w07) and `g . x` (w04) reach exactly their no-blank controls (w09, w10). A blank-carrying
  path in a definition-view generate TARGET (w05) is routed by § defGenPathSel161 in TypeEmit, which does not trim
  (residue N4).
- **Range queries:** the laws do not reach generate scopes (q03 gen-if declared net, q08 gen-for implicit net: both
  UNFIRED); q08 is downstream DIVERGENT on both binaries (residue N1).
- **Delays:** localparam-derived (d01), min:typ:max (d05), a real parameter (d07) and a three-assignment child (d08) convert; an imported
  package parameter (d09) and a generate-for list (d10) are not reached (the elaborated delay is missing, as
  v11u164's d02/d05 residue).
- **Enum alias clone:** module-parameter and `$unit`-parameter bases, a three-level chain in an interface, a program,
  a modport variable, a `$unit` import alias: every one moves toward golden and 6 go downstream DIVERGENT/EQUIVALENT
  -> IDENTICAL; an unpacked-dimension alias (e07) is abstained, as it must be. e08 (enum members valued by a
  parameter expression) is DIVERGENT on both: golden leaves the members unreduced (`vpiDecompile:P`, INT:0).
- **Port views:** the `.bus` shorthand with two overrides (p01, EQ on both), `.*` through two levels (p02), an
  interface-array port (p03 -> EQ), a generic port through two levels (p04), three ordered levels (p05 -> EQ), a derived
  localparam (p06 -> EQ), array elements in a gen-for (p07 -> EQ in default mode), an absolute-path named actual
  (p09 -> EQ). Golden shares ONE parameter across views of the same definition even when their values differ (p10).
- **Cross-ground pairs** (cx, each also scored with both laws off together, grid.py's PAIR rows): x02 (a header
  type parameter's struct and a value parameter, two ordered port views) - the port-view laws and the struct law all
  fire and every pair reads TOWARD; x08 (one gen-if scope with an absolute-path net declaration and a folded parameter
  in a process) - each law removes its own record and the pair converts to STRICT_EQUAL in both modes (164 alone:
  depth divergence gone; 167 alone: the fullname record gone); x09 (a port view of an interface whose value parameter
  has a type parameter's struct) - the port-view law closer, the struct law's moves in the weak tail only; x01, x03
  and x07 exercise one law each (the port view of an interface without header parameters, nested gen blocks, a generic
  port: the other law abstains, as designed); x04
  (an aliased enum in a function body) converts downstream to IDENTICAL and leaves 2 records: the S2 clone keeps
  the stored name of an enum-constant reference inside the cloned tree (residue N5); x05 (§ defGenPathSel161 with
  § hpSelRoute157) converts to STRICT_EQUAL by the route law alone; x06 (§ rangeQueryFoldUnconverted164 with
  § arrQueryFoldAtBound158) moves the implicit net's value to golden, and the folded `w = h` constant keeps the
  call's span where golden locates it at the bound (residue N7).

## 4. The break and the refinement (fix.patch; `R11V173_OFF=1` drops it)

### B1: § modportPortViewParamDef164 under `--elabuhdm` in a generate scope (§ pvElabGenDefParamLhs173v, `R11V173_PVELABGEN_OFF`, ModuleEmit.cpp `emitInterfaceInstance`)

**Found:** pv/p07 (`sub u(.b(arr[i]))` inside a gen-for) reads STRICT_EQUAL with the law in default mode, but under
`--elabuhdm` the law adds records at walk #121/#173 that the law-off database matched, before the law-off walk's
divergence at #190 (`evidence/grid_elabuhdm.txt`):

    #121 fullname  A: 7 parameter W  work@top.g[0].u.b.W  dut.sv 2 29 2 30  UINT:2     (golden = law off)
                   B: 7 parameter W  work@my_if.W         dut.sv 2 29 2 30  UINT:2     (law on)

**Distinguisher (minimal pair, `--elabuhdm`):** pv/p12 (the ordered view at top level) converts to STRICT_EQUAL with
the law; the same view one level inside a gen-if (p13), in a gen-for (p14), one module below a gen-if (p15), and a
named connection inside a gen-if (p16, a copy by § namedModportOutOfScopeFresh115) all move AWAY. In default mode all
five move toward golden. Golden (p16, `--elabuhdm`) lists TWO objects for the view `work@top.g.u.b`: the one under
the elaborated `module_inst u` (`vpiInterface`) whose param_assign Lhs is a FRESH parameter `work@top.g.u.b.W`, and
the one the hier_path `b.data` reaches (printed in the weak tail) whose Lhs is the definition's parameter
`work@my_if.W` (printed without children: shared). Ours lists the same two objects, and the law stores
`work@my_if.W` on both.

**Decode (Surelog + UHDM source, no fenced reading):** NetlistElaboration.cpp:450 `inst_assign->Lhs(mod_assign->Lhs())`
hands the view the DEFINITION's parameter object, whose full name Surelog leaves unstored. Under `-elabuhdm` alone,
UHDM's ElaboratorListener (third_party/Surelog/third_party/UHDM/templates/ElaboratorListener.cpp, the gen_scope
collection before `elabModule_inst`) re-clones the instances of generate scopes; a generated DeepClone copies a
stored full name verbatim and recomputes an unstored one through the clone's own parent chain
(§ elabCloneFullNameUnstored137, uhdm_main.cpp), so the clone reads `work@top.g.u.b.W`. The law stores
`work@my_if.W` on a per-view copy, and our listener run copies it verbatim.

**Refinement:** under `--elabuhdm` (`elabUhdmView121`), when the receiving instance of a copy-style port view lies in
a generate scope (the parent scopes are walked up through instance bodies' `parentInstance`), the view's scalar
param_assign Lhs becomes the definition's own parameter (`ifaceDefMap[&def]`'s `Parameters()`, unstored by
§ elabCloneFullNameUnstored137) instead of a copy storing the definition name. That is Surelog's
`inst_assign->Lhs(mod_assign->Lhs())` literally; § portViewParamShared164's one-object-per-definition follows by
construction. Default mode and views outside generate scopes are untouched. `R11V173_TRACE=1` prints
`R11V173_TRACE PVELABGEN` per firing.

### Fix measurements

| set | result |
|---|---|
| own cases, default mode ([evidence/fix_grid_own_cases.txt](evidence/fix_grid_own_cases.txt)) | 125/125 UNFIRED; `R11V173_OFF=1` = HEAD bytes 125/125 |
| own cases, `--elabuhdm` | 6 move, all toward: p07 and p16 -> STRICT_EQUAL (4 and 2 records leave, none enter), p11 p13 p14 p15 stage 1 closer (dump distance back to the law-off value: 34 -> 26, 56 -> 48, 60 -> 42, 78 -> 60, and field level the view's definition parameter now matches golden's `work@my_if.W`); p12 (top level) UNFIRED; `R11V173_OFF=1` = HEAD bytes 125/125 |
| earlier passes' cases, both modes ([drivers/fixbytes.sh](drivers/fixbytes.sh): r11u161gen, r11u164repro, v11u164repro, r11u167repro, r11v167repro, r11u170verify, r11u162verify, r11u115repro, r10rgg3repro, r10vrgg3repro, r10rgg16repro, r10vrgg16repro, r11u130repro, r11v1repro; PROCESSED = LISTED = 854) | default mode 0 movers; `--elabuhdm` 23 movers, every one a generate-scope port view, every one toward golden against its own `-elabuhdm` golden ([evidence/fix_prior_movers_elabuhdm.txt](evidence/fix_prior_movers_elabuhdm.txt)): 8 -> STRICT_EQUAL (r10rgg16 g5, r10vrgg16 v6, r11u115 n05 o01 o06 o07, r11u164 PV a16 a20), 15 stage 1 closer |
| census BEFORE the sweep ([drivers/census.sh](drivers/census.sh), [evidence/census_fix_before_sweep.txt](evidence/census_fix_before_sweep.txt)) | the refinement fires only under `--elabuhdm`: surelog testflags (636 of 788 rows pass it) is the only reachable stage; 794 rows (the four fenced excluded by `--filter`, "fenced mentions: 0") fire 0 times; positive control pv/p07 fires 2; the census csv's 794 testflags rows equal swH's. Predicted movers: none |
| gate sweep swF ([evidence/sweep_fix.log](evidence/sweep_fix.log)) | probe, surelog, uhdm2rtlil: regressions 0, conversions 0, changes 0 against the committed baselines; probe.csv, uhdm2rtlil.csv and downstream.csv byte-identical to swH's, surelog.csv too but for the LowMemLib/LowMemPkg testflags detail text (the workdir path); downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0; canaries.sh ok=52 / ok=16 changed=0, ctcan2 PASS on both ([evidence/swF_canaries.txt](evidence/swF_canaries.txt)); cmds.txt: 1531 + 1742 `slang:` lines name fix1.bin |
| fix vs HEAD bytes (byteverify, SELFCHECK=1, fenced mirrors; [evidence/byteverify_fix_vs_head.txt](evidence/byteverify_fix_vs_head.txt)) | surelog 3/952 = MiniAmiq d/t and SeqDriver d, the UVM coin (4 order-blind lines each, `UINT`/`vpiDecompile`, [evidence/uvm_coin_fix_vs_head.txt](evidence/uvm_coin_fix_vs_head.txt)); uhdm2rtlil 0/1608; probe 0/4087; SELFCHECK 951/952 and 1607/1608. As predicted: no deterministic mover |

## 5. Composition ([drivers/compose.py](drivers/compose.py), [drivers/bytecancel.py](drivers/bytecancel.py), [evidence/composition.txt](evidence/composition.txt), [evidence/composition_bytes.txt](evidence/composition_bytes.txt))

Status level, HEAD (swH) against both landings off (swA), each conversion attributed by the single-landing-off
sweeps (sw4, sw7):

| stage | conversions | OWN164 | OWN167 | SHARED / JOINT | CHANGE lines | CANCEL |
|---|---|---|---|---|---|---|
| probe | 79 | 50 | 29 | 0 / 0 | 73 (164) + 13 (167) | 0 |
| surelog | 10 | 6 (ComplexHierPath, GenIfIfaceParamStructField, HighLow d/t) | 4 (StructParamFieldRange, StructParamFuncBodyFieldCompare d/t) | 0 / 0 | 4 (Earlgrey_0_1, GenForStructParamBound d/t) + 2 (StructParamPatternInitCast d/t) | 0 |
| uhdm2rtlil | 12 | 8 (iface_param_port_width, interface_array, interface_array_fanout, mriscv_bind_sva d/t) | 4 (cva6_struct_param_field, ibex_register_file_ff d/t) | 0 / 0 | 0 | 0 |

These are exactly the conversions and changes each pass claimed (pass 164: 50 + 6 + 8 and 73 + 4 + 0; pass 167: 29 + 4 + 4
and 13 + 2 + 0), and each single-landing-off sweep reads exactly its own landing's numbers as regressions/changes
against the baselines (sw4 50/73, 6/4, 8/0; sw7 29/13, 4/2, 4/0).

Byte level over 6647 databases (4087 probe + 2560 corpus, fenced skipped): 6432 same in all four sweeps; OWN164 150
(probe 126 + 24 corpus row-modes), OWN167 57 (probe 43 + 14); BOTH 4 = Rggen/default (both passes reported it as a
record-neutral mover of theirs) and the UVM coin MiniAmiq d/t, SeqDriver d; CANCEL candidates 4 = SeqDriver t,
SimpleUVM d/t, Scoreboard d, each the coin (4 or 0 order-blind lines against HEAD, [evidence/uvm_coin_cancel_candidates_sw4.txt](evidence/uvm_coin_cancel_candidates_sw4.txt),
[..._sw7.txt](evidence/uvm_coin_cancel_candidates_sw7.txt)). No pair of laws cancels.

**The pre-164 bytes.** `R11U161_OFF R11U164_OFF R11U167_OFF R11V170_OFF` on HEAD (swZ) against the d8cfd83a build
(swP): path sets identical (6647), movers 6 = MiniAmiq, SeqDriver, SimpleUVM d/t, the coin
([evidence/alloff170_vs_pre_bytes.txt](evidence/alloff170_vs_pre_bytes.txt), [evidence/uvm_coin_alloff170_vs_pre.txt](evidence/uvm_coin_alloff170_vs_pre.txt)); probe.csv
byte-identical, surelog and uhdm2rtlil csvs identical in status and strict. On the fresh cases the same state equals
pre.bin 125/125 in both modes. So the landings plus r11u170's refinements are exactly the switched code.

**Movers against the passes' own predictions.** The 169 probe byte movers (HEAD vs both off) are 126 of pass 164's
predicted 173 plus all 43 of pass 167's predicted 43; 0 unpredicted ([evidence/probe_movers_head_vs_alloff.txt](evidence/probe_movers_head_vs_alloff.txt)).
Corpus byte movers (byteverify HEAD vs both off, SELFCHECK 951/952 and 1607/1608, [evidence/byteverify_head_vs_alloff.txt](evidence/byteverify_head_vs_alloff.txt)):
surelog 26 = the passes' named movers + MiniAmiq d/t and SeqDriver d (coin, 4 order-blind lines, [evidence/uvm_coin_H_vs_A.txt](evidence/uvm_coin_H_vs_A.txt)),
uhdm2rtlil 16 = the passes' named movers.

## 6. The CHANGE lines re-derived ([drivers/unmask.py](drivers/unmask.py), [drivers/unmaskpos.py](drivers/unmaskpos.py), [evidence/changes_unmask_alloff_vs_head.txt](evidence/changes_unmask_alloff_vs_head.txt))

Every row whose strict verdict differs between both-landings-off and HEAD, re-read record by record
(uhdm-strictcmp `--max 100000`, a record = field + golden text + ours text):

| stage | rows | CONVERSION | SUBSET (records only leave) | UNMASK | NEW / WORSE |
|---|---|---|---|---|---|
| probe | 165 | 79 | 77 | 9 | 0 |
| surelog | 16 | 10 | 6 (Earlgrey_0_1 d/t 1730 -> 1686, GenForStructParamBound d/t 7 -> 3, StructParamPatternInitCast d/t 11 -> 3) | 0 | 0 |
| uhdm2rtlil | 12 | 12 | 0 | 0 | 0 |

The 9 UNMASK cases (r10rgg3 h1 n2 n5, r10vrgg16 v8, r10vrgg3 x7 x8 x9 xc, r11v1 vA) were checked by position
([evidence/unmask_positions.txt](evidence/unmask_positions.txt)): every record HEAD has that the landings-off
database had not sits at or after the landings-off walk's divergence (vA: #317/#318 past #292, the `u.mp` hier_path
column face pass 164 named). Pass 164's 73 + 4 and pass 167's 13 + 2 are all among them (section 5 attributes each).

## 7. Downstream

- The six uhdm2rtlil rows the landings converted read IDENTICAL at HEAD, and their three netlist files are
  byte-identical between the Surelog lane and ours (`cva6_struct_param_field,IDENTICAL,OK,OK,1,1,,`,
  `ibex_register_file_ff,IDENTICAL,OK,OK,3663,3663,,`, `iface_param_port_width,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
  `interface_array,IDENTICAL,OK,OK,8,8,,`, `interface_array_fanout,IDENTICAL,OK,OK,22,22,,`,
  `mriscv_bind_sva,IDENTICAL,NO_GATES,NO_GATES,0,0,,`; `.il`, `_nohier.il`, `_synth.v` = same, `cmp`).
- The whole downstream csv is byte-identical with both landings off: the landings convert no downstream row and move
  none away.
- Fresh cases through `one()`, both landings off -> on: IDENTICAL 90 -> 106 of 125. The 16 that improve are the alias
  clones (EA e01 e02 e04 e05 e06 e09, x04) and the dotted-path trims (HW w01-w08, w11). None leaves IDENTICAL. The 19 not
  IDENTICAL with the laws on read the same verdict with them off: EQUIVALENT bu/u02, fb/b06, gp/g01, gs/z02, tp/t05;
  STATUS_DIFF pv/p02 (the `.*` hier_path), pv/p08 (the `interface.mp` generic port); DIVERGENT fb/b09, fo/f02, rq/q02,
  rq/q08 (N1), sb/s03, tp/t02 t04 t07, ea/e08 and gp/g06 (N8), hw/w12 w13 (N2).

## 8. Residues

### Re-measured at HEAD: every top-three residue still stands ([evidence/residue_rows_at_head.txt](evidence/residue_rows_at_head.txt), [evidence/residues_cases_at_head.txt](evidence/residues_cases_at_head.txt))

**Pass 164:** 1. OneNetModPort d/t `file(3)`, OneNetModPortGeneric d/t `line(2)`; 2. GenerateUnnamed d/t
`fullname(9)`; 3. GenForStructParamBound d/t `fullname(3)`. Its sister faces: SB b01 `fullname` (8 objects), vA
`col(2)`. **Its verifier:** 1. the implementer's list (above); 2. the range-query object face: q07 r05 r13 r04 `file(1)`,
r01 `value(3)`, r06 q04 q05 q09 stage 1; 3. the delay faces d02 d05 d07 d10 and ND n06, stage 1.

**Pass 167:** 1. StructParamPatternInitCast d/t `fullname(3)` (rs/r11: 3 objects); 2. LocalScopeHierPath t
`fullname(1)` (default CMP_EQUAL); 3. InterfArrayBind d `fullname(3)` (testflags CMP_EQUAL). S1 ibex_multdiv_fast d/t
`endcol(26)`; S2 UnionCast d/t `value(26)`/`value(28)`; S3 HighLow is **gone**: CMP_EQUAL both modes, converted by
pass 164's § rangeQueryFoldUnconverted164. **Its verifier:** 1. hw h07 h10 h12 stage 1; 2. fb b01 and b04
`fullname` (4 objects each); 3. gf g06 `fullname(1)`.

### New, found here (none is a break; ranked by reach)

- **N1 (downstream-visible).** A range query onto an implicit net inside a generate scope (rq/q08, `assign ccc =
  $high(a)` in a gen-for): golden folds it at the bound (`UINT:4` at 3:14), ours keeps the `$high` sys_func_call in
  every view; downstream DIVERGENT on both binaries (golden's lane `connect \g[0].ccc 1'0`, ours `1'1`). The range-query laws do
  not reach generate-scope cont_assigns (q03 declared, q08 implicit: UNFIRED). Site: ModuleEmit's generate-scope
  cont_assign emission (emitGenScopes), which has no sysFold branch.
- **N2 (downstream-visible, not blank-related).** A hier path into a generate array indexed by a struct-parameter member,
  `g[S.a].x` (hw/w13, and w12 with blanks): stage 1 and DIVERGENT on both binaries (golden's lane `connect \y \g[1].x`,
  ours `1'x`).
- **N3.** A parameter delay inside an INTERFACE: the elaborated interface instances' cont_assigns lack their delay
  (dl/d06: golden `work@top.i0.D` bound to the instance parameter); pre-existing, stage 1. Also an imported package
  parameter delay (d09) and a generate-for list (d10) are not reached.
- **N4.** A blank-carrying dotted path in a definition-view generate TARGET (`assign A . x = 1'b1;`, hw/w05) keeps
  `A . x` and ` x` (§ defGenPathSel161's TypeEmit route does not trim; § hpDotWsTrimmed167 covers ExprEmit's
  HierarchicalValue branch only). The route law's anchor moves the element spans toward golden (endcol 19 = golden).
- **N5.** § evalFuncBodyRhsStampClone167's clone keeps the stored name of an enum-constant reference inside the cloned
  body (cx/x04 `c.Mode == M1`: golden `<in>cfg_pkg::cfg_t.Flag.M1` computed through the clone, ours
  `cfg_pkg::build_config::M1`).
- **N6.** A definition-view generate target with an operation base, `s[i+1].f[0]` (sb/s01): golden anchors the leaf
  at its index (6:21-6:22) and names it by Surelog's decompiled path `s[i + 1].f[0]`, the rule
  § defGenSelBaseLeafAtIndex164 applies to a plain base; the law abstains on an operation base (as v11u164's s04).
- **N7.** cx/x06: the folded `assign w = h` (h = `$high(a)`) constant keeps the call's span 4:17-4:25 where golden
  locates it at the bound 3:14-3:15 (§ arrQueryFoldAtBound158 covers the parameter, not its cont_assign read).
- **N8 (Surelog defects, not ours).** gp/g06: Surelog cannot evaluate `$clog2(b.K)` of an interface-port parameter in a
  gen-if condition and takes the else branch (downstream DIVERGENT, like stamped_gen_param); ea/e08: golden leaves
  enum members valued by a parameter expression unreduced (INT:0); rq/q02: golden's `$right` of an unpacked variable
  is UINT:32 size 64.

## 9. The fence and the process

**No law, case or number rests on a fenced reading.**

- The fenced rows' verdicts ([drivers/fencerows.py](drivers/fencerows.py), csv rows compared blind): 8 surelog
  row-modes, (status, strict) identical with both landings on and off; no fenced uhdm2rtlil row exists.
- Every byte comparison ran on hard-link mirrors without the 8 fenced databases ([drivers/bvmirror.sh](drivers/bvmirror.sh):
  "mirrored=2560 fenced_skipped=8"); the census and the predictor rerun skip them by name ("fenced mentions: 0",
  "fenced rows skipped unread 8").
- Re-derived here from Surelog's source and this directory's cases, for the two laws of each pass nearest the fenced
  shapes (parameter folds and hierarchical paths):
  - § rangeQueryFoldUnconverted164 + § rangeQueryDeclNetSize164: UhdmWriter.cpp writeCont (`adjustSize(tps, ...)` on
    a constant right side, :2156) and CompileHelper::adjustSize (CompileHelper.cpp:4065: `ts == nullptr` returns the
    constant unchanged, an implicit net; a UINT constant is masked to `Bits(ts)` and takes that size). Cases q04 (->
    EQ), x06, q01 q05 q06 q07 q09 (value and size fields = golden).
  - § defGenPathSel161: CompileExpression.cpp compileSelectExpression's hierarchical branch
    (`fC->populateCoreMembers(Bit_select, Bit_select, r1)`, :1385: the base located at the NEXT component's token,
    `r1->VpiFullName(name)`). Cases g04, x05, g07 (-> EQ), w05 (the anchor).
  - § hpDotWsTrimmed167: the same writers build the path from `fC->SymName(...)` token texts joined by "." and locate
    each element at its token (:1388-1400, the `$root` branch :5088-5140), so no blank can enter a name. Cases w01 w02
    w03 w06 w08 w11 (-> EQ), w04/w07 (= their no-blank controls w10/w09).
  - § pkgPatCallArgReadNoParent167: CompileHelper::getValue's package branch (CompileExpression.cpp:921-953)
    replaces the package param_assign's pattern by expandPatternAssignment's result (`param->Rhs(rhs)`), orphaning
    the named original. Cases c01 c02 c04 (the walked copy unnamed = golden, the named original in golden's tail).

**Drivers of the four directories against the fence rule** (refuse to run without `$FENCED`, skip the names on sources
and databases):

| directory | meets the rule | lacks its own `$FENCED` refusal |
|---|---|---|
| r11u164repro | env.sh, attrib.sh, bvmirror.sh, dscase.py, orderblind.sh, predict_all.py, row.sh | attrib_probe.sh (probe cases and databases only), bytes.sh, case.sh, casedist.sh, offcheck.sh (evidence cases only), cc.sh (a compiler call), predict164.cpp (run only through predict_all.py, which guards) |
| v11u164repro | env.sh, dscase.py, predict.py | case.sh, obd.sh (case scratch only), probe_normdump.sh (any database it is given; used on probe databases), sweep.sh (the gate sweep, which dispatches every row by design) |
| r11u167repro | allrec.sh, census.sh, moverdiff.sh, predict.py, rowrec.sh, srcgrep.sh | grid.sh, gridall.sh, lawbytes.sh, offbytes.sh, recdiff.sh, switches.sh, mkstrictraw.sh, pdiff.sh (cases / probe only), tracewrap.sh (a SLANG_UHDM stand-in: it runs on whatever the harness dispatches; census.sh's `--filter` keeps the fenced rows from it) |
| r11v167repro | bytes.sh, census.sh, dsgrid.py (substring match, stricter than word boundary), grid.sh, predict.py, rowcmp.sh | **audit.sh** (greps every corpus `cmds.txt` for the binary path, the fenced rows' included: a sweep artefact, not a source or database, but a fenced row's file read), gridall.sh / sweep.sh / switches.sh (refuse without `$ENVFILE`, which carries the list, but do not check it; cases, the gate sweep, cases), pdump.sh (probe databases only), tracewrap.sh (as r11u167's) |

No driver of the four reads a fenced source or database; audit.sh is the one that opens a fenced row's file.

A grep of this directory for the four names (word boundary, from `$FENCED`) reads 0 files; positive control: each
name is found twice in RESUME.md. The 125 cases duplicate no case of the earlier grids or of tests/probe (text
compared with comments dropped and blank runs collapsed: 0 of 125).

**Pass 164's census was written before its sweep:** the claim cannot be dated from the repository (the scratch is
pruned), but its content is a pure function of the pristine databases and it reproduces: the committed first file
(221 rows) is the final file (238 rows) minus exactly the rows and tags of the four laws added later (0
inconsistencies), and pass 164's predictor rebuilt here and rerun on this pass's both-landings-off databases writes
the committed final file row for row (238/238 identical), predicting all 24 corpus and 126 probe movers the landing
owns at HEAD ([evidence/prediction164_rerun_on_alloff.txt](evidence/prediction164_rerun_on_alloff.txt)).

**Pass 167's pre-check holds on every clone shape written here** (section 3.3): 11 function-body right sides, 4 of which
crash with the pre-check off and none with it on.

**This pass's own process:** the binaries were frozen before any measurement; every sweep's `cmds.txt` audited by
binary path; the refinement's census ran and was saved (`evidence/census_fix_before_sweep.txt`, 20:19) before its
gate sweep was launched (20:19:31) and before any of its results were read; every driver here that reads corpus
databases or csvs (bvmirror.sh, bytecancel.py, compose.py, fencerows.py, orderblind.sh, unmask.py, census.sh) fails
closed on `$FENCED`, and the case drivers refuse a fenced path. No process this pass did not start was touched.

## 10. Files

- [fix.patch](fix.patch): the refinement (`git diff edb34d8a -- src`, `src/ModuleEmit.cpp` only), not applied.
- `cases/<group>/<case>/dut.sv`: 125 cases, the first line names the laws (groups: gp fo ea for the r11u161 laws; rq dl
  pv sb bu nd for pass 164's; tp pc fb gs hw for pass 167's; cx for the cross-ground pairs).
- Drivers: [env.sh](drivers/env.sh) (pins, `$FENCED`), [laws.py](drivers/laws.py) (law -> switch map),
  [case.sh](drivers/case.sh), [grid.py](drivers/grid.py), [gridall.sh](drivers/gridall.sh),
  [summarize.py](drivers/summarize.py), [lawtables.py](drivers/lawtables.py), [obdiff.sh](drivers/obdiff.sh)
  (order-blind golden-line gains/losses between two states), [dscase.py](drivers/dscase.py), [dsall.sh](drivers/dsall.sh),
  [mkstate.sh](drivers/mkstate.sh), [sweep.sh](drivers/sweep.sh), [sweeps_compose.sh](drivers/sweeps_compose.sh),
  [compose.py](drivers/compose.py), [bytecancel.py](drivers/bytecancel.py), [unmask.py](drivers/unmask.py),
  [unmaskpos.py](drivers/unmaskpos.py), [rescase.sh](drivers/rescase.sh), [bvmirror.sh](drivers/bvmirror.sh),
  [orderblind.sh](drivers/orderblind.sh), [fencerows.py](drivers/fencerows.py), [fixgrid.py](drivers/fixgrid.py),
  [fixbytes.sh](drivers/fixbytes.sh), [fixprior.py](drivers/fixprior.py), [census.sh](drivers/census.sh),
  [tracewrap.sh](drivers/tracewrap.sh).
- `evidence/`: the files named above, plus [law_tables.md](evidence/law_tables.md) (section 3.1's source).
