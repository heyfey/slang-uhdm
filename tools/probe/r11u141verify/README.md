# r11u141 — second adversarial verification of passes 130, 131 and 134

Verifier pass, base `e98516a3` (branch matrix-1.87). The laws under test landed at `f8ffb241` (pass 130 + its
verifier r11v130), `e49b93ea` (pass 131 + r11v131) and `8e8d2643` (pass 134, verified by v11u134 with no fix): 30
implementer laws and the three verifier refinements (§ defNetVarNoSlot130v, § includeLeadTabIsText130v,
§ constCtxCallArgInner131v). Every case here is new: no `.sv` file under tools/probe or tests/probe has the same text as any
of the 166 fresh `dut.sv` files.

**VERDICT: two BREAKS, both fixed in `fix.patch` (measured, gated). The composition is clean. The unmaskings and
the downstream claims hold. Every ranked residue still stands, except five rows of r11u130's R2, which pass 134
closed.**

| break | law (switch) | shape | pristine → law | fix (switch) |
|---|---|---|---|---|
| B1 | § includeLeadTabIsText130v (`R11V130_INCTAB_OFF`) | a TAB in a skipped conditional branch of a directive-only included file, or before the directive that ends a skipped branch | 9 cells strict-equal → `line(1)` | § includeInactiveTabNotText141v (`R11V141_INCTABACT_OFF`) |
| B2 | § paramIdxPartSelWholeSpan131 (`R11U131_IPSSPAN_OFF`) | a PACKAGE-QUALIFIED indexed part-select in a parameter default or a body localparam, e.g. `p::A[4 +: 4]` | 2 cells strict-equal → `col(1)`; 5 stage-1 cells lose 0-3 dump lines and gain 2-3 | § ipsQualBaseRangeSpan141v (`R11V141_IPSQUAL_OFF`) |

`R11V141_OFF=1` drops both refinements. Both breaks are strict-only: every cell reads the same downstream verdict
(IDENTICAL, or the EQUIVALENT that predates the passes) with and without the fix. Neither shape occurs in either
corpus or in `tests/probe`. The prediction by name was 0 real movers, and 0 were found.

| binary | md5 | what |
|---|---|---|
| pristine `/tmp/r11u141_bin/slang` | `eb9bed7afbf4f8c4f918e1de172fc4f8` | e98516a3; the worktree build `/tmp/wt_r11u141` (system-deps, `-j 2`) is byte-identical to the main tree's |
| fix `/tmp/r11u141_bin/fix` | `b860771b18356b2aa78290589b60188d` | e98516a3 + `fix.patch` (worktree `/tmp/wt_r11u141fix`) |
| nb `/tmp/r11u141_bin/nb` | `d865d96494d1beaeef5d4241658434d1` | MEASUREMENT ONLY: e98516a3 + `tools/probe/r11u139netbind/law.patch`, for the YosysOldOr unmasking |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the main tree's, identical to the worktree build |
| `strictx` | `34b24191e2b99f3177f5f33ec2d9e44c` | MEASUREMENT ONLY: `drivers/strictx.cpp` = uhdm-strictcmp plus `--diffs FILE` (every differing record/field pair under the comparator's own rule) and the raw full name in the `--dump` records |

All binaries were frozen (`chmod 555`) before they measured anything. Every sweep exported `SLANG_UHDM`. The
cmds.txt audit found 3273 of 3273 slang lines naming the intended frozen binary in all nine sweeps
(evidence/sweep_summaries.txt). A switch set in the environment reaches the binary: the eight configurations
give eight different strict tallies.

Two notes on the brief:

* `/tmp/strict_sweep` predates the strict flip: its AssignRhsFlat reads `differ:fullname(14)`, where HEAD and the
  committed baseline read `equal`. It was not used. Every measurement here comes from sweeps run for this pass.
* The brief's deliverable line names "the canonicalisation patch you were given" and `tools/probe/r11u141canon/`.
  No such patch was given, and the TARGET names `tools/probe/r11u141verify/`. The patch carries this directory only;
  the source fix is `fix.patch` inside it, not applied.

## 1. The breaks

### B1 — § includeLeadTabIsText130v counts a TAB the preprocessor never reads

§ includeNoTextSplicesNothing130 lets an included file made only of `define/`undef/`ifdef-family lines splice
no output line. r11v130 refined it: a TAB in a line's leading whitespace makes the file text, so golden splices
every line. Fresh grid `cases/brk_inctab` (16 cells) plus `cases/p130_inctab/t01-t03`. `defs.svh` is included
first and `body.svh` second; the head is `body.svh`'s include_file_info line.

| cell | TAB before | branch state | golden (flat line of 2nd include) | law | verdict |
|---|---|---|---|---|---|
| b10, t01, t03 | a plain `define / `undef / ` \t `define | active | text | text | right |
| b03, b06 | the opening `ifdef / `ifndef | active | text | text | right |
| b05 | a `define in the TAKEN branch | active | text | text | right |
| b08, b02, b09, b16 | `else / `endif after a TAKEN (or empty taken) branch | active | text | text | right |
| t02, b01 | `else after a FALSE `ifdef | skipped | nothing (4) | text (9) | **BREAK** |
| b04 | a `define inside the false branch | skipped | nothing | text | **BREAK** |
| b07 | `elsif after a false branch | skipped | nothing | text | **BREAK** |
| b11 | a TAB-only line inside the false branch | skipped | nothing | text | **BREAK** |
| b12 | TABs inside a nested block of a false branch | skipped | nothing | text | **BREAK** |
| b13 | `endif closing a false branch | skipped | nothing | text | **BREAK** |
| b14 | an inner `else after a false inner `ifdef, outer active | skipped | nothing | text | **BREAK** |
| b15 | `else after an EMPTY false branch | skipped | nothing | text | **BREAK** |

All 19 cells are judge-equal and downstream IDENTICAL under every binary. The 9 breaks read `equal` with
`R11V130_INCTAB_OFF` and `differ:line(1)` with the law on, in both modes. The record is `#2 include_file_info line
4 → 9`.

**Decode.** A TAB is text only where the preprocessor is ACTIVE. Surelog drops a skipped branch from the
preprocessed text, and the leading whitespace of the directive that ends it goes too. slang marks the same text:
`Preprocessor::parseBranchDirective` (third_party/slang/source/parsing/Preprocessor.cpp) puts a false branch's
tokens in `disabledTokens` and rewrites the leading trivia of the directive that ends it to `DisabledText`.

**§ includeInactiveTabNotText141v** (UhdmExporter.cpp, `emitIncludeFileInfos`; switch `R11V141_INCTABACT_OFF`).
One walk of the syntax trees records, per included buffer, the lines of a skipped branch. A skipped branch is
detected when the next directive's first token carries DisabledText trivia. The recorded lines run from the line
after the false branch's directive to that directive's own line. The TAB test of § includeLeadTabIsText130v skips
those lines. On the 9 breaks the fix gives exactly the `R11V130_INCTAB_OFF` bytes. On the 10 active-region cells
it gives the pristine bytes.

### B2 — § paramIdxPartSelWholeSpan131 widens a select whose base is package-qualified

`module sub #(parameter logic [3:0] P = p::A[4 +: 4])` (cases/p131_ipsspan/i01) gives golden
`indexed_part_select p::A dut.sv 6:45-6:51`, the range. The law gives `6:40-6:52`, the whole select. The same
holds for a body `localparam logic [3:0] L = p::A[4 +: 4]` (brk_ipsq/q04: `35-41` → `30-42`). Both cells are
judge-equal and strict-equal at pristine. Grid `cases/brk_ipsq`:

* The stage-1 shapes q01 (`-:`), q05 (another package's parameter), q06 (a qualified index), q07 (inside an
  operation) and q09 (an interface parameter) move 0-3 dump lines toward golden and 2-3 away, all at the select
  span.
* q02 (the name imported and written bare) is untouched by the fix.
* q03 (an override) is folded, so the law does not fire.
* q08 (a module-parameter base) is the law's own measured shape and is untouched by the fix.

**Decode.** Surelog's grammar is `constant_primary : (package_scope | class_scope)? identifier constant_select`.
Its `paPackage_scope` case (CompileExpression.cpp, the `childType == paPackage_scope` block) reduces the package
parameter, then compiles the select with `compileSelectExpression` on the `Constant_select` child. That case
populates the select from the select node, never from the whole primary. Only a bare base takes the whole-node
population that § paramIdxPartSelWholeSpan131 decoded.

**§ ipsQualBaseRangeSpan141v** (EmitHelpers.h `ipsQualBaseRangeSpan141On`, applied at the
§ paramIdxPartSelWholeSpan131 site in ExprEmit.cpp; switch `R11V141_IPSQUAL_OFF`). When the base is written
package-qualified (§ pkgWrittenQualSelBase41 non-empty), the select keeps its range span. On i01 and q04, and on
the five stage-1 cells, the fix gives exactly the `R11U131_IPSSPAN_OFF` bytes. Everywhere else it gives the
pristine bytes.

### The fix, measured (fix binary vs pristine; evidence/fix_on_cases.txt and the files below)

| check | result |
|---|---|
| 166 fresh cases, default and `--elabuhdm` | `R11V141_OFF=1` gives pristine bytes on 166/166 in both modes. The fix moves 16 cells per mode: the 11 breaks turn strict-equal, and 5 stage-1 cells return to the law-off bytes. Each single switch moves back only its own cells. |
| 1033 earlier-pass case dirs (the grids of r11u118, r11v11u118, r11u119, r11u125, r11v125, r11u130, r11v130, r11u131, r11v131, r11u134, v11u134, r11u139netbind) | **0 byte movers** (evidence/earlier_pass_cases_bytes_fix_vs_pristine.tsv). Predicted 0 by name: the two grep hits are r11v11u118 w07_ovr_idx, an override where the law does not fire, and r11v130 v19, a TAB in an active branch. |
| probe, 4087 cases | `EQUAL=2139 STRICT_NOTEQUAL=1948`, `regressions=0 conversions=0 changes=0`. The csv is identical to the pristine sweep's. Byte movers: **0/4087** (same worktree, same-length workdirs). The positive control, pristine vs three-passes-off, finds 287/4087 movers. |
| corpora | surelog `[default] CMP_EQUAL=364 STRICT_NOTEQUAL=116 CMP_NOTEQUAL=3`, `[testflags] 340 / 134 / 3`; uhdm2rtlil 660 / 143 / CMP_NOTEQUAL=1 / SLANG_REJECT=67 in both modes; `regressions=0 conversions=0 changes=0` in both corpora |
| byteverify (`SELFCHECK=1`, `/tmp/r11u141_wdFX` vs `/tmp/r11u141_wdON`) | PATH_SETS_IDENTICAL on both corpora, SELFCHECK 959/960 and 1607/1608. MOVERS: surelog **5/960**, all the UVM coin: MiniAmiq/default, SeqDriver both modes and SimpleUVM both modes, each exactly 4 order-blind dump lines `UINT`/`vpiDecompile`. uhdm2rtlil **0/1608**. Predicted 0 real movers: none of 18412 corpus files is a directive-only file with a TAB-led line, and the 10 qualified indexed part-selects in the corpora are procedural (`prim_cipher_pkg::PRESENT_SBOX4[data_state_sbox[k*4 +: 4]]`). |
| downstream | `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`. Verdict and `differs` are equal to the pristine sweep and to results/downstream_uhdm2rtlil.csv on all 871 rows. The 27 grid cells of the two breaks read the same verdict with both binaries. |
| uhdm-cmp | no corpus row changes status; every probe case is equal |
| canaries | `canaries.sh` vs committed: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; vs the pristine sweep: the same. `EXPECT_UNKNOWN=1 ctcan2.sh` and `EXPECT_UNKNOWN=6 ctcan2.sh` PASS. |

`tests/sweep.sh` exits 1 in every sweep here, the pristine one included, and only on `law index STALE`: this
directory, and fix.patch's two law names, are not yet in tests/LAWS.md. The landing regenerates it.

## 2. The laws, case by case (default mode, `--elabuhdm`, three passes off, downstream)

Every case is `cases/<group>/<case>/dut.sv`, and its first line names the law. Goldens come from the pinned
Surelog: `-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, plus `-elabuhdm` in the elab column. Ours come from
`dut.sv --single-unit --nobuiltin [--elabuhdm]`. How to read the columns:

* "at e98516a3" is the pristine verdict: `equal`, `ne:<first field>(<objects>)`, or `stage1 cmp=<uhdm-cmp
  lines>`.
* "law off → on" is judged record by record (drivers/judge.py):
  * `turned equal`
  * `OK:better=n`: fields that stop differing, none starting.
  * `untouched`: the same bytes.
  * `stage1 both, bytes moved`: the order-blind uhdm-dump delta (drivers/dd.py) is given in parentheses.
  * `BREAK`
* The three-passes-off column compares `R11U130_OFF R11U131_OFF R11U134_OFF` against law on.
* The downstream column is the harness's `one()` with law on. A cell whose verdict changes with the law off or the
  three off lists them.
* Every non-SAME pair was re-judged with a difflib alignment across the walk (drivers/judge2.py,
  evidence/alignment_worse_check.txt). It finds no field worsening except the 11 breaks.

Totals over the 166 cases, default mode:

* at e98516a3: 76 strict-equal, 31 strict-NE, 59 stage 1.
* law off → on: **52 turned equal**, 9 better, 53 untouched, 40 stage-1 byte moves, 1 strict-equal byte move,
  **11 BREAK**.
* `--elabuhdm`: 44 turned equal, 16 better, 53 untouched, 40 stage-1 byte moves, 1 strict-equal byte move, 11
  BREAK (the same cells), and 1 count growth, which is an unmasking (§4, l04).

The switch battery ran every one of the 33 single switches over every case (evidence/switch_battery_*.txt). It
found no break by any other law.

| pass | laws | fresh cases | laws the fresh cases fire |
|---|---|---|---|
| 130 (+v130) | 12 | 47 (+16 brk_inctab, 4 res_inccomment) | all 12 |
| 131 (+v131) | 10 | 40 (+9 brk_ipsq) | all 10 |
| 134 | 11 | 50 | 10: § tsHierPathElemNoName134 fires on none of its 6 cases (h01-h06: an instance array, a nested member, a function local, a port range, a local typedef, an interface signal; all of them are `col` residue R6 or stage 1) |

The per-law tables follow: one table per law, 166 rows (the same text is in `evidence/law_tables.md`). The
breaks are the `BREAK:eq->ne` rows under § includeLeadTabIsText130v and § paramIdxPartSelWholeSpan131. A cell
the fix moves carries `fix: <verdict>` after the last column.

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


Observations that are not breaks. Each one is below the judge, strict and downstream, or wrong on both binaries:

* **§ elabNetTdCloneNoAlias134, the weaklyReferenced tail.** On the strict-equal, downstream-IDENTICAL cells
  (l06 `tri`, l08 `wor`, l10 `wand` over an unsigned typedef), the law adds the module typedef to uhdm-dump's
  `\_weaklyReferenced` tail: 22 lines, where the pristine dump is order-blind identical to golden's. The judge,
  the strict walk and the plugin never read that tail. On the stage-1 shapes (l01 `tri1`/`wor` signed, l05 `tri`
  signed, l07 `tri1` undriven, l09 `wire` signed, l11 `supply0`) the head is the net's `vpiSigned`, the same with
  both binaries, and the same 22-24 lines appear.
* **§ suSigningNotInSpan130 on a NET**: `wire struct packed signed {...} w;` (k01, stage 1). Golden spans the
  whole struct, 4:8-4:62. Pristine ends at `signed` (4:28) and the law at `packed` (4:21), so the value moves from
  one wrong value to another (4 dump lines each way).
* **§ portViewParamDefName130** on the stage-1 shapes p01 (a string parameter) and p03 (an expression override):
  12 dump lines fixed, 10 new. The new lines are the definition-named parameter where golden's stage-1 walk lists
  the path name. The head is unchanged.

## 3. Composition: the three passes, switched off together and apart

**A 2^3 factorial over the whole gate.** Eight full sweeps (probe, surelog, uhdm2rtlil) with the frozen pristine
binary, one per subset of the passes switched on (evidence/composition_factorial.txt, sweep_summaries.txt).

| configuration (passes on) | surelog strict-equal (of 1596 row-modes; 954 judge-equal) | uhdm2rtlil (of 1742; 1606) | probe (of 4087) |
|---|---|---|---|
| ON: 130 131 134 | 704 | 1320 | 2139 |
| 131 134 (`R11U130_OFF`) | 697 | 1300 | 2127 |
| 130 134 (`R11U131_OFF`) | 663 | 1304 | 2102 |
| 130 131 (`R11U134_OFF`) | 684 | 1286 | 2112 |
| 134 only | 656 | 1284 | 2090 |
| 131 only | 677 | 1268 | 2100 |
| 130 only | 639 | 1270 | 2081 |
| none | 632 | 1252 | 2069 |

* **Judge-equal status never differs** across the 8 configurations, on any row or case.
* **NON-MONOTONE rows: 0** in all three sets. No row is equal in some configuration and unequal in one that
  switches strictly more passes on. So no pass cancels another pass's error, and no row is "equal only with both
  on and both off".
* The pass-dependent equal rows split by signature:
  * need 131 alone: 41 surelog, 16 uhdm2rtlil and 30 probe.
  * need 134 alone: 20, 32 and 20.
  * need 130 alone: 7, 18 and 12.
  * **need 131 AND 134**: 7 probe cases (v79v6_ca, the five m_*108 and r11v16repro/v2).
  * **need 130 AND 134**: `svtypes_struct_simple` in both modes.
  * **either 131 or 134 suffices**: EarlgreyPackParam and LogicArrayParam in both modes, and probe
    r10earl_repro/tf.

**Every claimed conversion was checked** (evidence/claimed_conversions.tsv, taken from the three passes' evidence
files; evidence/claimed_conversions_check.txt):

| pass | claimed (surelog + uhdm2rtlil + probe) | falls back with that pass off | shared |
|---|---|---|---|
| 130 | 7 + 20 + 12 | all 39 | — |
| 131 | 45 + 16 + 36 | 41 + 16 + 35 | EarlgreyPackParam and LogicArrayParam (both modes) and r10earl_repro/tf are converted by 134 too |
| 134 | 24 + 34 + 21 | 20 + 34 + 20 | the same five, claimed by both passes |

(The claims parser read `SignedWire` twice, because the name exists in both corpora. Its uhdm2rtlil row is equal
in every configuration and is not a claim.) At HEAD, every claimed conversion is equal. None needs a pass other
than its claimant, except for the joint rows below.

**Law level.** Each of the 33 switches was run alone over every pass-dependent row: 38 surelog tests and 34
uhdm2rtlil tests in both modes, and 70 probe cases (evidence/law_level_attribution.txt). Then every law pair
that a row needs together was switched off together (evidence/law_pairs_off.txt).

* 211 rows are equal at HEAD. 171 need exactly one law, 29 need two, and 1 needs three: probe v79v6_ca needs
  § implicitNetMintNoFile131 + § defNetTypedefArrayShares134 + § defNetTypedefEndWrite134.
* 9 are converted redundantly (either law suffices; each falls back only with its pair off):
  * EarlgreyPackParam, LogicArrayParam and r10earl_repro/tf: § pkgParamTsRefColons131 **or**
    § pkgTsRefObjChainName134. Both laws write the same `pkg::param::ref` name, one at makeParamTs and one in the
    post-pass.
  * indexed_partsel_array and IndexedPartSelectOfArrayElement: § defNetTypedefArrayShares134 **or**
    § contAssignLhsTsUnparented134, as v11u134 found.
* 1 is pass-independent (ParamNoSubst/testflags, listed by name).
* **Cancellation check: none.** For every row that needs two or three laws, the row is NOT equal with those laws
  switched off together. That covers TDARRSHARE+TDNETEND (14 row-modes), PATTS+TDPARENT (5), ANONMEMBER+CAUNPARENT
  (4), PKGCLONEBOUND+SCOPEDPKGTD (3), QCALL+SCOPEDPKGTD (1), SUSIGN+ANONMEMBER (2), and the triple.
* The joint rows, explained:
  * **r10vearl108repro m_arr108, m_ifs108, m_multi108, m_nest108, m_wide108.** Pass 131 claimed them on its base
    `4e17c7ee`, before the comparator commit `4f73d52f` counted a copy's full names. At HEAD, 131 alone leaves
    `fullname(8)` (none: 9). § typedefParentLastWriter134 clears that, and 134 alone leaves `fullname(1)`, the one
    § pkgPatReadTsNoParent131 clears.
  * **svtypes_struct_simple** needs § suSigningNotInSpan130 (the header span) and § anonMemberRefChainName134
    (the member names).
  * These are conjunctions, not cancellations: with both off each row is further from golden than with either
    one off.
* Laws needed by NO pass-dependent conversion (their value is outside the corpora and the probe set, in their
  grids): CLSARGNET, GVTSFILE, IFSUKW, INCNOTEXT, REDEFLINE, CASTLOC, MEMUNION, TSHPNAME, DEFNETVAR, INCTAB and
  ARGCTX. PTSSEP converts only redundantly.

**No row grows.** Between the three-off sweep and HEAD, 0 row-modes grow on the same first field, and 49
row-modes change their first field (evidence/first_field_changes_A3_to_ON.txt). Each of the 49 was re-walked
record by record: walk-aligned for the small rows, and difflib-aligned or with the divergence-offset unmasker
(drivers/unmask.py) for the large ones. **0 fields that golden matched with the passes off differ with them on**,
and no walk diverges earlier. Take PackStructField, simple_package, sva_counter and
NestedStructArrayParameterInitializedByPatternPassedAsPort, which now read `depth(1)`: their structural
divergence was already there, masked by an earlier differing field.

## 4. The unmaskings (record dumps; evidence/unmask_v5b8_b10.txt, unmask_YosysOldOr.txt)

* **tests/probe/r10buvm8repro/v5b8: `line(8)` → `line(10)` (pass 134).**
  * With the three passes off, the walk diverges at record #877 (the `kp5b::b_t` alias clone, 10 extra records).
    § defNetScopedPkgVecTdShares134 alone owns the change: with `R11U134_SCOPEDPKGTD_OFF` the row reads `line(8)`
    as with 134 off.
  * With the passes on, the walk aligns to the end. The ten `kp5b::e_t` enum_typespec listings all read
    `dut.sv 6:3-6:43` where golden has `20:24-20:27` (residue R4 of r11u134).
  * Seven of them (#6 … #716) were flagged with the passes off. The other three, ON #897, #977 and #1037, are
    the three-off walk's #902, #982 and #1042, past its divergence, with the same `6:3-6:43`.
  * The alignment check finds 0 fields worse. **Confirmed unmasking.**
* **YosysOldOr: `line(78)` → `line(604)` under the pending net-binding law (r11u139, both modes).**
  * Pristine walk: 243325 records, diverging at #88173. With law.patch: 243334 records, aligned with golden to
    the end.
  * Of the 1194 differing fields, 1050 were not reported before. Every one of the 1050 lies past #88173, and each
    is matched by the local key alignment to the same golden object in the pristine walk. There that object holds
    the SAME off-golden value (e.g. golden #88229 = pristine #88226, `endcol`).
  * 0 new differences before the divergence, and 0 where the pristine record matched golden. **Confirmed
    unmasking in both modes.** The row is otherwise untouched by passes 130/131/134: `line(78)` both on and off.
* **r11u119repro b10_scoped_alias_concat (`endline` → `depth`, the one v11u134 named):** difflib-aligned, 6 fields
  fixed and 0 worse. **Confirmed.**
* **Fresh cell l04 `--elabuhdm` (§ elabNetTdCloneNoAlias134).** Law off: the walk diverges at #108 (the alias
  clone, 5 extra records). Law on: it aligns and shows 4 `ref_obj` full names (`work@sub.i` for golden's
  `work@top.u.i`: r11u131's residue R10, the elaborated cont_assign named by the definition). The law-off walk
  holds the same 4 records at #133-#137 with the same values. **Unmasking.**

## 5. Downstream

* **Converted uhdm2rtlil rows.** All 36 uhdm2rtlil tests the three passes claimed converted read IDENTICAL in the
  HEAD sweep's downstream stage. All 108 of their `_nohier.il` / `.il` / `_synth.v` pairs are **byte-identical**
  between the Surelog and slang lanes (evidence/downstream_bytes_claimed_u2r.txt). The positive control
  func_upto, an EQUIVALENT row, differs. One per pass:

      130 simple_enum            nohier ec7f0282dde6 = ec7f0282dde6, il 80b8c2fb598d = 80b8c2fb598d, synth 5a6b32a7d0d8 = 5a6b32a7d0d8
      131 struct_param_func_arg  nohier c037935aac1a = c037935aac1a, il a4f09df4818a = a4f09df4818a, synth e13211fa59bd = e13211fa59bd
      134 union_simple           nohier 4a97e626c6a4 = 4a97e626c6a4, il 20b557ff48f2 = 20b557ff48f2, synth be32cceb867a = be32cceb867a

* **HEAD sweep downstream:** `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)`, verdict-identical to
  results/downstream_uhdm2rtlil.csv on every row.
* **Fresh cases** (evidence/downstream_cases.jsonl), 166 × {law on, own law off, three off}:
  * 138 IDENTICAL, 13 EQUIVALENT, 2 STATUS_DIFF and 1 DIVERGENT with the law on. Every non-IDENTICAL verdict is
    the same under all three configurations: pre-existing, stage-1 or residue shapes (v01 is DIVERGENT on every
    binary).
  * The only cells the laws move are **§ emptyRedefineObjLine130 r01-r04: EQUIVALENT → IDENTICAL** with the law
    on (the `src` attribute lines). That is toward golden.
  * **No law moves any cell away from IDENTICAL.**

## 6. The ranked residues, re-measured at e98516a3 (evidence/residue_cases_remeasured.txt, residue_rows_remeasured.csv)

| pair | residue | measured at e98516a3 | status |
|---|---|---|---|
| r11u130 R1 | type-parameter override by a module-local enum | TypeParameterAsPortTypeWithEnum `file(8)`, …OfParametrizedWidth `file(6)`; grid g2 t01 `file` (8 objects), t02 `file` (6) | stands |
| r11u130 R2 | struct spans taken at the use | 5 of its 17 named rows are now `equal`, closed by pass 134 (§ defNetTypedefEndWrite134 + § defNetTypedefArrayShares134): RangeSelect, latch_fifo_dynfield and unpacked_struct_2d/_dyn_read/_mixed. Still differing: cva6_struct_param_field `endcol(9)`, gen_scope_typaram `endcol(9)`, IfGenTypeBinding `endline(5)`, packed_array_struct `endline(2)`, …_port_sel `endcol(9)`, packed_struct_array_fifo `endline(2)`, port_chained_type_param `endcol(2)`, struct_member_cfg_width `col(33)`, struct_member_trailing_index `fullname(4)`, StructParamFieldRange `endcol(9)`, TaggedPattern `endcol(1)`, TypeParamElab `endline(15)` | stands (12 of 17) |
| r11u130 R3 | the type-parameter definition net | TypeParam `type(1)`; g7 t01 `type` | stands |
| r11v130 1 | `var` / port inline struct headers | grid/var k07 `endcol(2)`, grid/adv c04 `endcol(2)` | stands |
| r11v130 2 | indented empty redefinition | grid/adv m01, m03 `col(40)` | stands |
| r11v130 3 | multi-line macro invocation as a resync point | grid/adv h09 `endline(14)` (61 objects with the three passes off) | stands |
| r11u131 R1 | net binding | ParameterColonReference, StructLocalParam, cdc_static_basic `count(0)`; array_assign, Clog2OfSum…, partsel_simple, vector_index, sva_range, sva_throughout, sva_counter, param_type_logic_width, wandwor `depth(1)`; dff_different_styles `fullname(2)` | stands (r11u139's law pending) |
| r11u131 R2 | struct-parameter member path base ref | hpm m03 `col`, m04 `endcol`, m07 `col`, m08 `endcol` (m01, m02, m05, m06 stage 1); iface_array_elem_cfg_param `col(1)`, iface_cfg_param_def_pass `col(2)` | stands |
| r11u131 R3 | replication port connection | hcc h01, h05, h06 `fullname(1)`, h08 `fullname(2)`; ParamMultiConcat, SignedBin, ReplicationPassedToInstance `fullname(1)` | stands |
| r11v131 V2 | gen-scope parenthesized localparam | par/b24 `col(1)` | stands |
| r11v131 V3 | pattern parameter read procedurally | pat k06, k11, k12, k13, k16, k17: stage 1, 11 cmp lines each | stands |
| r11v131 V4 | indexed part-select in emitSyntaxExpr | ips i13 `col(1)`, i16 `col(2)` | stands |
| r11u134 R1 | member names in parameter typespecs | GenForStructParamBound `fullname(7)` | stands |
| r11u134 R2 | gen-scope typedef reparenting | no carrier (none in the pass's grids either) | unmeasurable, stands |
| r11u134 R3 | member default constant (N0045) | StructParamFuncBodyFieldCompare `depth(1)` | stands |
| v11u134 1 | package-scoped name of a typedef over a typedef | bc05 `fullname` (4 objects) | stands |
| v11u134 2 | included-file content carries `dut.sv` | td15 `file(6)`, td16 `file(26)` | stands |
| v11u134 3 | inline anonymous struct as a port type | an03 `endcol` (walk diverged) | stands |

### New residues, ranked (measured here, not landed)

1. **Code in a skipped branch of a directive-only include** (r11v130's residue 4, i05). The decode of B1 says the
   preprocessor drops a skipped branch, and golden's i05 (golden 4, ours 6 and 9) fits that. The same inactive-line
   map would let § includeNoTextSplicesNothing130 ignore code in a skipped branch. It is not in fix.patch, because
   only the TAB face was a proven break.
2. **Trailing comments on directive lines** (cases/res_inccomment, p130_incnotext/n03).
   § includeNoTextSplicesNothing130 treats a directive line that carries a comment as text. Golden splices NOTHING
   for `` `define W 4 // width `` (n03), `` `define W 4 /* w */ `` (c01) and `` `ifdef A // guard `` (c03). It
   splices everything for `` `undef W // gone `` (c02). The law abstains, and the cells read `line(1)` with and
   without it. The clause was never measured: r11v125 z10 and z11 carry their comments on lines of their own.
3. **A net's inline struct header** (`wire struct packed signed {...} w`, k01, stage 1): golden spans the whole
   data type, 4:8-4:62. That is a third slot beside § suSigningNotInSpan130 and § netSigningTsSpan130.
4. **§ tsHierPathElemNoName134 has no fresh firing shape.** It fires on 0 of the 6 fresh range/port/typedef/
   interface shapes and is needed by no pass-dependent conversion (§3). Its evidence is the pass's hp grid and the
   corpus movers alone.

## 7. Gates (for fix.patch, from /tmp/wt_r11u141fix with SLANG_UHDM exported to the frozen fix binary)

1. build: pristine `eb9bed7afbf4` (= main tree), fix `b860771b1835`. fix.patch applies clean on a fresh e98516a3
   worktree.
2. `tests/sweep.sh --corpus probe`: `EQUAL=2139 STRICT_NOTEQUAL=1948`, `regressions=0 conversions=0 changes=0`.
3. `--corpus "surelog uhdm2rtlil"`: `regressions=0 conversions=0 changes=0` in both corpora.
4. `--corpus downstream`: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, and no row moves from its baseline or
   pristine verdict.
5. uhdm-cmp: no status change anywhere, and every fresh cell keeps its uhdm-cmp line count under both binaries.
6. byteverify: 5 + 0 movers, all the UVM coin, with order-blind proof (evidence/probe_bytes_and_uvm_coin.txt,
   byteverify_*.txt). Predicted by name: 0 real movers. The canaries are green.

The pristine gate (HEAD, `/tmp/r11u141_wdON`) reproduces the committed baselines exactly:

* probe 2139 / 1948;
* surelog 704 CMP_EQUAL + 250 STRICT_NOTEQUAL of 954 judge-equal row-modes;
* uhdm2rtlil 1320 + 286 of 1606;
* downstream 803 / 66 / 2 / 0.

Every stage reads `regressions=0 conversions=0 changes=0`.

## 8. Files

* `cases/`, 166 fresh cases (every `dut.sv` names its law in its first line):
  * `p130_*` (47), `p131_*` (40) and `p134_*` (50), one directory per law;
  * `brk_inctab` (16) and `brk_ipsq` (9), the two break grids;
  * `res_inccomment` (4), the trailing-comment residue.
* `fix.patch` is the source fix: UhdmExporter.cpp, ExprEmit.cpp and EmitHelpers.h, 107 lines added and 3 changed. It is not
  applied by this directory's patch.
* `drivers/`:
  * `case.py`: one case, golden cached by content, any set of switch configurations, strict records and diff
    sets via `strictx`.
  * `runall.py` / `runfix.py`: batteries.
  * `judge.py` (walk-aligned) and `judge2.py` (difflib-aligned): field-level worsening.
  * `unmask.py`: divergence-offset unmasking proof for large rows.
  * `dd.py` / `ddshow.py`: order-blind dump deltas.
  * `table.py`, `allsw*.py`, `lawtable.py`, `fixtab.py`: reports.
  * `ds_case.py` / `ds_all.sh`: downstream verdicts.
  * `sweepchain.sh`, `chain2.sh` / `chain3.sh`, `lawsweeps.sh`: the factorial, law-level and pair sweeps.
  * `compose.py`, `claims.py`, `claimcheck.py`: the composition census.
  * `rowjudge.py`: one sweep row between two sweeps.
  * `bytes.py`: the earlier-pass byte controls.
  * `lawmap.py`: law ↔ switch.
  * `strictx.cpp`: the measurement comparator.
  * Build it with `g++ -O1 -std=c++17 strictx.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm
    -lcapnp -lkj`.
* `evidence/`: every table above in raw form. The files are:
  * law_tables.md
  * switch_battery_{default,elab,added_cases}.txt
  * alignment_worse_check.txt
  * dumpdelta_stage1_{default,elab}.txt
  * downstream_cases.jsonl and downstream_fix_movers.jsonl
  * fix_on_cases.txt
  * earlier_pass_cases_bytes_fix_vs_pristine.tsv
  * composition_factorial.txt
  * claimed_conversions{.tsv,_check.txt}
  * law_level_attribution.txt and law_pairs_off.txt
  * first_field_changes_A3_to_ON.txt
  * unmask_v5b8_b10.txt and unmask_YosysOldOr.txt
  * residue_{cases,rows}_remeasured
  * sweep_summaries.txt
  * downstream_bytes_claimed_u2r.txt
  * probe_bytes_and_uvm_coin.txt
  * bv_FX_ON_*.txt
