# r11u416: module/type ground, sv-tests campaign pass 416 (implementer)

Base 2416fd57b (pass 414). Ground: src/TypeEmit.cpp, src/ModuleEmit.cpp and
src/UhdmExporter.cpp. TaskFuncEmit.cpp, uhdm_main.cpp, include/ and the
sister's four files are not touched.

- Pristine binary: the main tree's build at the base (md5
  66df7ded979fc01d27731b8d95a31e10). The worktree's first build at the base
  has the same md5. It is frozen at /tmp/r11u416_bin/pristine.
- Law binary: md5 18f76dd113d0725710277d4ac13ad9c5, frozen at
  /tmp/r11u416_bin/l7. A rebuild of the patch's sources gives the same md5.
- Pristine reading: the master's control sweep /tmp/intr11u414. Its csvs equal
  the committed results/*.csv.

Every law reads through src/LawSwitch.h with `lawOn(416, "R11U416_<LAW>_OFF")`.
`R11U416_OFF` drops the whole pass, and `R11U416_TRACE=<dir>` logs each firing
through `lawTrace(416, ...)`. The pass adds no src/R*.h, no LawState.h
section, no getenv and no reader function.

## Result

91 sv-tests rows convert from STRICT_NOTEQUAL to EQUAL, with 0 regressions
and 1 change. The four corpus gates are unchanged.

| sv-tests | EQUAL | STRICT_NOTEQUAL | DIFFERENT | SURELOG_ONLY | BOTH_REJECT | SLANG_ONLY | SURELOG_CRASH | TIMEOUT |
|---|---|---|---|---|---|---|---|---|
| base (results/golden_svtests.csv) | 1712 | 97 | 131 | 75 | 303 | 19 | 8 | 1 |
| law sweep | **1803** | **6** | 131 | 75 | 303 | 19 | 8 | 1 |

The stage printed `regressions=0 conversions=91 changes=1`
(evidence/sweep_svtests.txt). The fresh csv is evidence/svtests_law.csv.
Some converted rows, before and after:

    base: chapter-18/18.13.1--urandom_1.sv,STRICT_NOTEQUAL,differ:col(2),differ:col(2)
    law:  chapter-18/18.13.1--urandom_1.sv,EQUAL,,equal
    base: chapter-18/18.7.1--local-scope-resolution_1.sv,STRICT_NOTEQUAL,differ:col(9),differ:col(9)
    law:  chapter-18/18.7.1--local-scope-resolution_1.sv,EQUAL,,equal
    base: generated/basejump/bsg_dmc_BaseJumpSTL_bsg_dmc_phy.sv,STRICT_NOTEQUAL,differ:col(8),differ:col(8)
    law:  generated/basejump/bsg_dmc_BaseJumpSTL_bsg_dmc_phy.sv,EQUAL,,equal
    base: generated/basejump/bsg_misc_BaseJumpSTL_bsg_lfsr.sv,STRICT_NOTEQUAL,differ:fullname(1),differ:fullname(1)
    law:  generated/basejump/bsg_misc_BaseJumpSTL_bsg_lfsr.sv,EQUAL,,equal
    base: chapter-5/5.6.4--compiler-directives-debug-line.sv,STRICT_NOTEQUAL,differ:endline(2),differ:endline(2)
    law:  chapter-5/5.6.4--compiler-directives-debug-line.sv,EQUAL,,equal

The one CHANGE moves toward golden:
`generated/basejump/bsg_noc_BaseJumpSTL_bsg_mesh_router.sv` goes from
STRICT_NOTEQUAL `differ:col(2)` to `differ:col(1)`.
§ defGenConnSelAtIndex416 fixes the `.i(grants & {input_els_lp{ready_and_i[i]}})`
bit_select. The column that remains is the generate localparam's
`$bits(routing_matrix_p[i])` inside the `BSG_COUNTONES_SYNTH` macro (see
Residues).

### Conversions by law (91)

- **§ pasteBlankLedStartWritten416**: 80 UVM rows, the whole `differ:col(2)`
  UVM cluster.
  - 56 chapter-18 rows.
  - The 7 `generated/uvm_classes_0` rows, the 7 `uvm_classes_2` rows and the
    7 `uvm_classes_3` rows.
  - `testbenches/uvm_resource_db_read_by_name.sv`,
    `testbenches/uvm_test_run_test.sv` and `uvm/uvm_files.sv`.
  - The head on every one of them is pass 409's reported face: the `begin`
    of `m_uvm_field_op_begin` at `uvm_object_defines.svh:804`, instantiated
    by `uvm_reg_mem_hdl_paths_seq`'s `` `uvm_field_queue_string ``. Golden
    has 804:39 and 804:37 for OP = COMPARE and PRINT. Pristine had 804:36.
- **§ unitImportTfSourceOrder416 together with § pasteBlankLedStartWritten416**:
  3 rows (`chapter-18/18.7--in-line-constraints--randomize_4.sv`,
  `randomize_6.sv` and `18.7.1--local-scope-resolution_1.sv`). Pristine read
  col(9). With the paste law alone they read `differ:name(7)`: golden lists
  the `$unit` function F after uvm_pkg's 979 imported subroutines, and ours
  listed it first.
- **§ defGenConnSelAtIndex416**: 6 basejump rows
  (`bsg_channel_tunnel_out`, `bsg_dmc_phy`, `bsg_link_ddr_downstream`,
  `bsg_link_ddr_upstream`, `bsg_crossbar_control_locking_o_by_i` and
  `bsg_idiv_iterative`). These are the strict heads pass 411 decoded on this
  ground, the TypeEmit emitSyntaxExpr bit_select branch.
- **§ genCaseItemProcNoFull416**: `generated/basejump/bsg_misc_BaseJumpSTL_bsg_lfsr.sv`.
- **§ lineDirectiveIgnored416**: `chapter-5/5.6.4--compiler-directives-debug-line.sv`.

## Goal 1

Census of results/golden_svtests.csv at the base: 75 SURELOG_ONLY, 303
BOTH_REJECT and 0 SLANG_CRASH.

- Every SURELOG_ONLY detail is an upstream slang front-end diagnostic
  (`<file>:<line>:<col>: error: ...`).
- The detail column has 0 lines with `unsupported`, `shape` or `exit 4`.
- The one BOTH_REJECT detail without `: error:` is a missing input file
  (`uvm_alu_config_analysis/a`).

So no sv-tests row on either ground is stuck at an exporter error. This pass
did not reach the probe-only exit-4 shapes carried from passes 410 and 414
(VH/vh04, vh06, VC/vc13, VY/vy02, VU/vu02, AQ/aq09); they stay as residue.

New goal-1 face, on the sister's ground (reported, not written): a cast sized
by a parameter, `W'(x[i])`, in a port connection inside a generate loop exits
4 with `expression kind: Invalid` on every binary. Upstream slang accepts it
(`Build succeeded`). A literal size `2'(x[i])` and a module-scope connection
are fine.

- Case: DC/dc13_param_cast_exit4.
- Call chain: ModuleEmit `emitInstance` (the elaborated instance in the
  generate scope) -> ExprEmit `emitExpr` -> nested `emitExpr` on an
  `Invalid`. slang's own AST holds a plain `Conversion` there. The Invalid
  comes from the exporter's own re-bind of the cast's size expression in
  ExprEmit (the `Expression::bind(*cesyn.left, bctx...)` sites of the
  conversion emitter).

## Laws (5, every § name416, one switch each)

| law | file | switch | statement |
|---|---|---|---|
| § pasteBlankLedStartWritten416 | UhdmExporter (buildMacroExpansions, locLineCol, setLoc) | R11U416_PASTEBLANKSTART_OFF | See the note after this table. |
| § unitImportTfSourceOrder416 | UhdmExporter (the design's subroutine listing) | R11U416_UNITTFORDER_OFF | Surelog lists the design's subroutines in the order of the compilation unit's items. A `$unit` wildcard import's group sits where the import is written, so `import p::*; function F ...` lists p's subroutines before F. Ours appended every import group after the own `$unit` subroutines. The own entries keep their order and are matched by name to the units' subroutine items (an item the listing does not hold, a `$unit` task, is passed over). The law applies only when some group lands before an own entry, and abstains when not every own entry is matched. |
| § defGenConnSelAtIndex416 | TypeEmit (emitSyntaxExpr bit_select branch, flag `defGenConnSelAtIndex416()`) + ModuleEmit (sets it) | R11U416_DEFGENCONNSEL_OFF | A bit_select inside a definition-view generate block's port connection is anchored at its INDEX expression (parentheses kept, blanks dropped), as the operator branch's select leaf (mkOpSelLeaf9) already is. This covers connections written as a concatenation, a replication or a cast, and the operands the operator tree hands to the syntax emitter (a parenthesized reduction, a replication). Ours spanned the whole select. Golden examples: `bsg_channel_tunnel_out.sv` `.down_i(lg_remote_credits_lp ' (yumi_o [i]))` puts the bit_select at 89:56-89:57; `bsg_dmc_phy.sv` `{dfi_wrdata_array[dq_group_lp+i], ...}` puts it at 402:43-402:56. |
| § genCaseItemProcNoFull416 | ModuleEmit (emitBranch's process emission) | R11U416_GENCASEPROC_OFF | See the note after this table. |
| § lineDirectiveIgnored416 | UhdmExporter (fileLineCol) | R11U416_LINEDIRECTIVE_OFF | Surelog keeps the PHYSICAL line after a `` `line `` directive (5.6.4: golden's module end line is 18 where slang's directive-mapped line read 1). For a buffer whose text holds `` `line ``, the line is recounted from the buffer's newlines. Other buffers are not read. |

§ pasteBlankLedStartWritten416. slang lays out the blank-free run of tokens
right after a `` `` `` paste at the pasted text's running offset
(§ pasteChainRunning160v). With a positive shift (pasted length > written
span), that run reaches the written offsets of the tokens after the first
blank. The START of an object at such a token then collides with the
pasted-end key (`ppPasteEnd160`) or a run position, and pristine read the
run's column.

The `begin` of `if (!((FLAG)&UVM_NO``OP)) begin` is the example. With OP =
COMPARE (+3) or PRINT (+1) it read 804:36 where golden has 804:39 and 804:37.
UNPACK (+2), SET (-1) and COPY (0) were already right: an even positive shift
or a negative shift misses the collision.

The law's model: such a start reads the paste's column plus the written
distance plus the shift. It is limited to tokens on the paste's own definition
line whose buffer offset equals the written distance. setLoc marks the start
query, and END queries keep the run model.

§ genCaseItemProcNoFull416. A process in a case-generate item with no label
(`default: always @* begin : nb ... end`, or inside an unnamed begin) sits
under the unparented case_item (§ genCaseItemUnnamed152), so its statements
store no full name. Golden `bsg_lfsr.sv:34` has the `begin` of
`initial assert (...) else begin ... end` with an empty full name, where ours
wrote `work@bsg_lfsr`; a block local such as `int k` has an empty name too,
and its ref_typespec reads `k`.

The module prefix had stood in for the empty branch prefix. The law passes
the empty prefix to emitProcess. The names the statement emitter then builds
(`.nb`, `.k`) are cleared with the process unparented, so no getter computes
a module-chained name.

## Grid: tools/probe/r11u416repro/cases (37 case dirs, 5 groups)

Every case's first line names its law. Each case gets pristine, law,
`R11U416_OFF=1` and its own switch. Run it with
`drivers/grid.sh <law> <pristine>`; the output is evidence/grid.txt, and
every line carries the exit code.

| group | law | cases | pristine -> law |
|---|---|---|---|
| PB | § pasteBlankLedStartWritten416 | pb01_uvm_op_begin, pb02_paste_len_1_to_7, pb03_ctl_negative_shift, pb04_ctl_select_run_then_assign, pb05_long_paste_over_begin, pb06_multiline_case_label | See the PB note below. |
| UO | § unitImportTfSourceOrder416 | uo01_import_then_function, uo02_ctl_function_then_import, uo03_import_function_task, uo04_randomize_with, uo05_two_imports_between | uo01, uo03, uo04, uo05 STRICT_NOTEQUAL name -> STRICT_EQUAL; uo02 (function before the import) STRICT_EQUAL control, bytes unchanged |
| DC | § defGenConnSelAtIndex416 | dc01 to dc13 | See the DC note below. |
| LD | § lineDirectiveIgnored416 | ld01_same_file, ld02_other_file, ld03_before_module, ld04_ctl_line_named_macro, ld05_line_then_instance | ld01, ld02, ld03, ld05 STRICT_NOTEQUAL (line/endline) -> STRICT_EQUAL; ld04 (a `` `line_w `` macro name, recounted to the same lines) STRICT_EQUAL control, bytes unchanged |
| GC | § genCaseItemProcNoFull416 | gc01_initial_begin, gc02_always_named_begin, gc03_unnamed_block, gc04_block_local, gc05_ctl_genif, gc06_ctl_named_item, gc07_ctl_genif_noblock, gc08_assert_else_begin | See the GC note below. |

PB group:

- pb01, pb02 and pb06: STRICT_NOTEQUAL col -> STRICT_EQUAL.
- Controls pb03 (negative shift) and pb04 (pass 160's `arr_``n[1] =` run)
  have bytes unchanged. pb04 stays STRICT_NOTEQUAL endcol (pristine residue).
- pb05 (a paste longer than the run, the begin inside the pasted range) has
  bytes unchanged and stays STRICT_NOTEQUAL endcol: the operation's end
  column is a pristine residue.

DC group:

- dc01-dc08: STRICT_NOTEQUAL col -> STRICT_EQUAL. The shapes are a
  concatenation, a generate-if expression index, a replication, a nested
  concatenation, `[ i ]` and `[(i)]`, `$signed(x[i])` in a concatenation,
  `(&y) & (|x[i])` and `y & {4{x[i]}}`.
- Controls dc09-dc12 (a plain select, a binary operator, a module-scope
  concatenation and a unary operator) were already STRICT_EQUAL and their
  bytes are unchanged.
- dc13 (`W'(x[i])`) exits 4 on both binaries (the sister's goal-1 face
  above). Its partial database moves from STRICT_NOTEQUAL col to
  STRICT_EQUAL.

GC group:

- gc01-gc04: STRICT_NOTEQUAL fullname -> STRICT_EQUAL.
- Controls gc05-gc07 (generate-if, a labelled item, generate-if without a
  block) have bytes unchanged.
- gc08 (`initial assert ... else begin` in a case item) is NOT_EQUAL on both
  binaries at 46 uhdm-cmp lines: an assertion operand folds in the
  elaborated view, on the sister's ground. It moves toward golden on the
  begin full names (39 -> 34 dump lines from golden, `\_begin: (work@top)`
  -> `\_begin: ,`).

Totals: 24 cases go from STRICT_NOTEQUAL to STRICT_EQUAL (one of them dc13's
partial database at exit 4). 12 are byte-identical to pristine: 10 equal
controls, plus pb04 and pb05, which stay unequal. gc08 moves toward golden. No
cell moves away. `R11U416_OFF` restores pristine's bytes and exit code on 37
of 37 case dirs. Each group's own switch restores them on 37 of 37.

Downstream (uhdm2rtlil lanes, `ds.one` with the downstream flags) on the 35
class-free case dirs (evidence/downstream_cases.txt):

- ld01, ld02, ld03, ld05 and pb06 go from EQUIVALENT to IDENTICAL.
- dc13 and pb05 stay EQUIVALENT.
- The rest are IDENTICAL on both binaries.
- None is worse.

## Gates (one full five-stage sweep on the law binary)

The four corpus stages ran as `tests/sweep.sh --jobs 3 --workdir
/tmp/r11u416_sw --corpus "probe surelog uhdm2rtlil downstream"` from the
worktree with `SLANG_UHDM` set to the law binary. The sv-tests stage ran
through the main tree's scripts/check_svtests.py (read-only, at the base; a
worktree has no UVM tree), with the same binary and baseline
results/golden_svtests.csv at the base. `R11U416_TRACE` was set for both.
Logs are in evidence/sweep_corpora.txt and evidence/sweep_svtests.txt.

- **probe**: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, `regressions=0
  conversions=0 changes=0`. The csv is byte-identical to the control's.
  - 4087 of 4087 databases are STRICT_EQUAL control against law
    (evidence/probe_control_vs_law.txt).
  - A byte compare is not possible here: the worktree's case paths are
    absolute in VpiFile.
- **surelog**: default 480 + 0, testflags 474 + 0, `regressions=0
  conversions=0 changes=0`. The csv differs from the control only in the two
  LowMem log-path detail texts.
- **uhdm2rtlil**: 803 / 1 / 67 in both modes, 0 / 0 / 0. The csv is
  byte-identical to the control's.
- **downstream**: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0;
  not identical and not excused 0. The csv is byte-identical to the
  control's.
- **svtests**: as in Result above, `regressions=0 conversions=91 changes=1`.
- The sweep exited 1 only on the stale law index (printed before the probe
  stage; tests/LAWS.md is regenerated in this patch, and `law_index.py
  --check` reads current).
- **byteverify** against the master's control (`SELFCHECK=1`, same-length
  workdirs):
  - surelog: 0 of 962 movers (selfcheck 961 of 962 flagged).
  - uhdm2rtlil: 0 of 1608 movers (1607 of 1608 flagged).
  - downstream: 0 of 805 movers (804 of 805 flagged).
- **Canaries**: `ok=52 changed=0` (surelog) and `ok=16 changed=0`
  (uhdm2rtlil). ctcan2 PASS on both (EXPECT_UNKNOWN=1 and 6).
- **Binary audit**: the fence list was read into a file by a program, not
  printed, and every list was filtered on it first.
  - surelog: 1523 of 1573 fence-filtered cmds.txt name the law binary; 48
    hold no slang line, and 2 name slang only in the UVM checkout path of a
    Surelog line.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
- **UVM rows and determinism**: before the sweep, a traced run of the corpus
  UVM rows (BuildUVMPkg, SimpleUVM, MiniAmiq, SeqDriver, Scoreboard,
  Earlgrey_0_1, Rggen, BlackBePipeInt) on an earlier law binary read every
  row's status as the golden's, and every database byte-identical to the
  control. The full sweep's byteverify confirms this on the final binary.

### Trace census (evidence/trace_census.txt), predicted before the sweep

The prediction was a firing only where a paste, a case-generate process, a
`` `line ``, a `$unit` import before a `$unit` subroutine or a def-gen
connection select occurs.

| law | firings |
|---|---|
| § pasteBlankLedStartWritten416 | 63 (surelog) and 18 (uhdm2rtlil): every one `same`, 0 byte movers; in the UVM rows the shape is reached and golden's column already equals pristine's there. 332 `MOVED` (sv-tests): on 156 rows, all inside `m_uvm_field_op_begin` at 804 (see the note below). |
| § unitImportTfSourceOrder416 | the 3 converted chapter-18 rows, plus `generated/rsd/rsd` (SURELOG_CRASH: no golden, status unchanged; the control-vs-law strictcmp of its kept database reads NOT_EQUAL, the listing order). Nowhere in the corpora. |
| § defGenConnSelAtIndex416 | the 6 converted basejump rows, mesh_router (the CHANGE), `bsg_comm_link` (DIFFERENT, unchanged status, 192 -> 184 sorted dump lines from golden) and the six black-parrot rows (SURELOG_CRASH: no golden, status unchanged). Nowhere in the corpora. |
| § genCaseItemProcNoFull416 | bsg_lfsr (converted) and the uhdm2rtlil row `size_cast_param` (both modes and its downstream run). That row's two unnamed case items each hold one `always_ff` whose objects store no prefix-built full name, so its database stays byte-identical. |
| § lineDirectiveIgnored416 | 5.6.4 only (`1->18` twice). |

The positive control is the sv-tests stage. The probe stage logged no firing.

Paste-law MOVED rows:

- 83 rows are EQUAL.
- 68 are DIFFERENT, with the same two uvm_pkg moves as the EQUAL rows. On
  `testbenches/uvm_agent_active` the sorted `begin` @804 lines of the law's
  dump equal golden's line for line, and those of the control did not.
- 8 of the DIFFERENT rows also move `work@packet_in`'s own `uvm_field_*`
  begins 804:43 -> 804:44 and 804:46. These match golden on uvm_agent_active.
- 5 are SLANG_ONLY (no golden).

Away census on the kept sv-tests databases (158 rows the control and the law
both kept, strictcmp control against law;
evidence/svtests_kept_control_vs_law.txt):

- 81 are STRICT_EQUAL.
- 75 are STRICT_NOTEQUAL col: the 73 paste-law rows above plus
  `bsg_comm_link` and `mesh_router`, all toward golden.
- rsd: the order law with no golden.
- tnoc: a strictcmp canonicalisation overflow. uhdm-cmp control against law
  reads 0 lines and no law fires there.

On the three rows run again with the trace off (uvm_agent_active,
bsg_comm_link, mesh_router), the trace-off databases are STRICT_EQUAL to the
traced sweep's. sv-tests databases embed their work directory, so bytes
differ across workroots.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The 6 STRICT_NOTEQUAL rows left:
   - `bsg_cache_to_test_dram` fullname(2) and `bsg_wormhole_concentrator_out`
     fullname(1). A reference inside the bound of a part-select on a struct
     member select. Golden's full name reads through the select chain
     (`...dma_pkt_n.addr[...].addr.dram_byte_offset_width_lp`) where ours
     stores the scope name. Module-scope typedef grids of this shape are
     NOT_EQUAL elsewhere first (hp grid, not written).
   - `bsg_wormhole_router` fullname(1): pass 410's struct-typedef member
     select lacking the `work@` prefix.
   - `bsg_dram_clk_gen` fullname(138): a package struct member's
     ref_typespec, `bsg_tag_pkg::bsg_tag_s.clk` in golden against our
     `::clk`.
   - `bsg_wormhole_router_decoder_dor` fullname(1): pass 411's generate
     localparam select, the sister's report.
   - `bsg_mesh_router` col(1): a definition-view generate localparam
     `` `BSG_COUNTONES_SYNTH(routing_matrix_p[i]) `` whose `$bits` argument
     bit_select golden anchors at the index, inside a macro. Generate
     localparam grids `$bits(P[i])`, `P[i] + 1` and `$countones(P[i])` are
     NOT_EQUAL first on folding (ParamEmit), so this was not written.
2. The 131 DIFFERENT rows are unchanged in status: 66 non-UVM and 65 UVM.
   - On the UVM rows the paste law moves columns toward golden.
   - For the non-UVM heads (uhdm-cmp line counts in this pass's run): see
     passes 414, 412 and 410. p719 is a new decode: nested module
     definitions (`module ff1;` inside `dff_nested`) where golden mints the
     parent's nets `nq1` as implicit nets of the nested instance. p599: a
     `$realtobits` call's ref_typespec. class_test_53: a class type
     parameter's int_typespec clone.
3. Goal-1 probe shapes not reached: VH/vh04, vh06, VC/vc13, VY/vy02,
   VU/vu02, AQ/aq09.
4. Paste layout: pb04 (`arr_``n[1] =` with a longer actual, the run's end
   column) and pb05 (the operation end when the paste covers the
   blank-led token).
5. The carried backlog of passes 402 to 414 on this ground (listed in their
   READMEs), not reached.

## Sister-ground faces (reported, not written)

- ExprEmit, goal 1: `W'(x[i])` with W a parameter, in a generate-loop port
  connection, exits 4 with `expression kind: Invalid` (DC/dc13). The call
  chain is ModuleEmit emitInstance -> ExprEmit emitExpr; the Invalid
  expression comes from the exporter's re-bind of the cast size.
- ParamEmit, or the generate localparam emission: a definition-view generate
  localparam initializer's bit_select anchored at its index
  (bsg_mesh_router, inside `` `BSG_COUNTONES_SYNTH ``). The probe shapes are
  NOT_EQUAL first on folding.
- ExprEmit (the elaborated assertion operand in a case-generate item, gc08):
  `assert (W == 3)` where golden keeps a ref_obj W and we fold a constant.

## Process

- One law binary was swept once in full. Intermediate binaries got only
  targeted runner calls:
  - 1 row.
  - The 97 STRICT_NOTEQUAL rows twice.
  - The 66 non-UVM DIFFERENT rows once.
  - The 65 UVM DIFFERENT rows once.
  - The 3 trace-off rows.
  - One traced verify_golden run of 8 corpus rows.
- No pristine build beyond the md5 check of the worktree's first build, and
  no pristine sweep.
- `pgrep` read empty before every runner call and before the sweep.
- The fence list was read by a program into a file and never printed. No
  fenced test was named, opened or run.
- Only this pass's own processes were started or stopped.
- Case outputs and goldens live under /tmp/r11u416_scr. Drivers:
  `drivers/run1.sh` (golden cached per case text + ours + uhdm-cmp +
  uhdm-strictcmp), `drivers/sdiff.sh` and `drivers/grid.sh`.
- A slip with no effect on any measurement: a glob over one scratch
  directory once passed two non-directory paths to run1.sh. It ran Surelog on
  nothing in a scratch golden dir. Its strict-record dumps had been written
  into the scratch case dirs (not the repro dir) and were removed before the
  grid was built here.
