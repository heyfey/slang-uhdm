# r11u440 — the basejump placeholder definitions (module/type ground)

The twentieth pass of the sv-tests campaign on the module/type ground (pass
440), base e516a74d. Production files: src/TypeEmit.cpp, src/ModuleEmit.cpp
and src/UhdmExporter.cpp (TaskFuncEmit, uhdm_main.cpp, include/ and the
sister's ExprEmit, EmitHelpers.h, StmtEmit and ParamEmit unchanged).

## Result

| sv-tests row | before (results/golden_svtests.csv) | after (this pass's sweep, law6) |
|---|---|---|
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_mesh_stitch.sv | DIFFERENT | **EQUAL** (`...bsg_mesh_stitch.sv,EQUAL,,equal`; STRICT_EQUAL 5306 objects) |
| generated/basejump/bsg_dataflow_BaseJumpSTL_bsg_round_robin_fifo_to_fifo.sv | DIFFERENT | **EQUAL** (`...round_robin_fifo_to_fifo.sv,EQUAL,,equal`; STRICT_EQUAL 6358 objects) |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_dff_en_segmented.sv | DIFFERENT | **EQUAL** (`...bsg_dff_en_segmented.sv,EQUAL,,equal`; STRICT_EQUAL 5267 objects) |
| generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_ascii_writer.sv | DIFFERENT | **EQUAL** (`...bsg_nonsynth_ascii_writer.sv,EQUAL,,equal`; STRICT_EQUAL 5220 objects) |
| generated/basejump/bsg_comm_link_BaseJumpSTL_test_bsg_comm_link_checker.sv | DIFFERENT | **STRICT_NOTEQUAL** (`...test_bsg_comm_link_checker.sv,STRICT_NOTEQUAL,differ:endline(1),differ:endline(1)`; uhdm-cmp 0 lines) |

sv-tests: EQUAL 1907 -> 1911, STRICT_NOTEQUAL 1 -> 2, DIFFERENT 32 -> 27, every
other count unchanged (BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8,
SURELOG_ONLY 75, TIMEOUT 1 of 2346); regressions 0, conversions 5, changes 0
(measured against the base's golden, which holds pass 437's apb row at
STRICT_NOTEQUAL; the master's pass-437 landing moved that row to EQUAL in
between and touches none of these five). Goal 1: nothing on this ground; all
75 SURELOG_ONLY rows carry an upstream slang front-end diagnostic (`: error`
in every detail; no exporter message).

The checker's last strict field is the sister's: golden writes the EMPTY
argument of `$display(..., core_1_period_p, , " (Cycles Per Word) " ...)`
(test_bsg_comm_link_checker.sv 119/120) as INT:0 at 120:28 ending at
119:86, ours ends at 120:28 (ExprEmit's empty-argument constant; reported
below).

## The decode

The open basejump rows (results/golden_svtests.csv DIFFERENT at the base) are
the "inv placeholder" family: basejump's `` `BSG_INV_PARAM(p) `` expands to a
parameter with no default under the define set both tools get, and the
module is reached only from `` `BSG_ABSTRACT_MODULE ``'s `if (0)` block, so
it is a definition that is never elaborated (our `defOnlyDefs`; pass 404's
§ undefaultedDefInvalidInst404 builds it with a placeholder 8 for every
undefaulted value parameter). Surelog compiles such a definition without
evaluating anything. Measured at the base on the kept pairs
(evidence/heads_base.txt, the head tracer of tools/probe/r11u426repro
evidence/tools/cmptrace2.cpp, rebuilt here):

- bsg_mesh_stitch: six port typespecs. `x_max_p = "inv"` is a DEFAULT, a
  string read as a 24-bit width, so `[y_max_p-1:0][x_max_p-1:0]...`
  overflows and the port type is an error type in slang; ours wrote a bare
  logic_typespec at the port name, golden the written packed dimensions as
  ranges at the brackets (the typespec at the first dimension), references
  unbound, `[S:W]` bound to bsg_noc_pkg's enum constants.
- bsg_round_robin_fifo_to_fifo: three heads, (1) the definition net's own
  copy of the module typedef `bsg_round_robin_fifo_to_fifo_t` (the object
  with vpiTypedefAlias and vpiInstance the definition) folds its bound
  `width_p*num_out_p-1` to INT:7 at the left operand where golden keeps the
  operation with references named `bsg_round_robin_fifo_to_fifo_t.width_p`;
  measured on TD this is NOT a placeholder face: golden keeps the written
  bound on that copy in any module that is not the single-view top (TD/td02
  defaulted, td03/td13 instantiated, td14 overridden); (2) `zero_flat`, a
  variable typed by that typedef, prints vpiNetType 36 in ours and none in
  golden: in a definition that is never elaborated Surelog's
  writeNets reads getVpiNetType(netKeyword ?: sig->getType()) on an
  unresolved typedef name, so a variable prints no net type and a net its
  keyword's (NT/nt01, nt05, nt07; instantiated, nt02, both print 36);
  (3) the generate port connection `.i(data_head[in_top_channel_i][0+:W])`
  wrote its trailing `+:` select as one ref_obj named by its text, the
  indexed twin of pass 424's § defGenConnVarSelRange424.
- bsg_nonsynth_ascii_writer, bsg_dff_en_segmented, test_bsg_comm_link_checker,
  bsg_source_sync_channel_control_slave, bsg_nonsynth_mem_1rw_sync_assoc,
  bsg_scheduler_dataflow: the definition is missing from golden's module
  list in ours (uhdm-cmp's head is the design). Each is pass 404's
  `abstain-unbound`: the placeholder body holds an InvalidStatement. A
  diagnostic build (not kept; it printed each invalid statement's location)
  placed them: ascii_writer 24:11 `$fopen(filename_p, fopen_param_p)` (the
  placeholder 8 where a string is wanted), dff_en_segmented 58:10
  (`parameter int widths_p[els_p-1:0]` has no array initializer), the
  checker 155:16 (a generate loop bound by `num_channels_p`),
  control_slave 268:6 (`out_ctr_r[counter_min_bits_lp-1:lg_token_width_p]`
  reversed by the DEFAULT `lg_token_width_p = "inv"`), mem_1rw_sync_assoc
  41:13 (a nonblocking write to an associative element, which slang refuses
  whatever the values), scheduler_dataflow 187:12 (`bypass_lo`, a name the
  source never declares).

## Laws (read through src/LawSwitch.h; R11U440_OFF drops all)

- § errTypePortSyntaxRange440 (R11U440_ERRPORTRANGE_OFF, TypeEmit
  makeTypespec): in a definition that is never elaborated (defOnlyDefs), a
  module port, net or variable whose declared type is an error type in slang
  and whose type syntax is an implicit or keyword vector with range
  dimensions gets each written dimension as a range at its brackets with
  the bounds built by emitSyntaxExpr, the typespec at the first dimension
  (from the keyword for `bit`, MS/ms03). lawTrace `errTypePortSyntaxRange440
  <def> <name>`.
- § defOnlyAliasVarNoNetType440 (R11U440_DEFONLYNETTYPE_OFF, ModuleEmit
  emitModuleDef's net listing): in such a definition a non-port declaration
  written with a type name prints no vpiNetType when it is a variable or a
  net of a package-scoped type, and its keyword's VPI net type when it is a
  net of a bare type name (wire 1, wand 2, wor 3, tri 4, tri0 5, tri1 6,
  trireg 7, triand 8, trior 9, supply1 10, supply0 11, uwire 13, all
  measured in NT/nt07). lawTrace `defOnlyAliasVarNoNetType440 <net> <type>`.
- § defGenConnVarSelIdxPart440 (R11U440_GENVSIDXPART_OFF, ModuleEmit
  emitDefGenStmts): in such a definition, a `+:` / `-:` select as a later
  dimension of a multi-dimension generate port connection is an
  indexed_part_select of the var_select (named after the base, full name
  through the select, constant select, type 1 or 2, base and width the
  written expressions named through it, a bare constant unparented). Not in
  an elaborated definition: there golden folds the elaborated copy's base
  and width (VI/vi03, vi06), which this law does not model. lawTrace
  `defGenConnVarSelIdxPart440 <var_select> <text>`.
- § undefaultedPlaceholderRetry440 (R11U440_PHRETRY_OFF, UhdmExporter's
  addDefOnlyModule, inside pass 404's law): when the placeholder body is
  unbound, rebuild it with an unpacked parameter's placeholder
  `'{default: 8}` and then, one scalar parameter at a time, a string "inv",
  listing the first body slang binds completely; still unbound abstains as
  before. A definition the first build binds is untouched (pass 404's
  bytes). lawTrace `undefaultedPlaceholderRetry440 <def> <array|param>` or
  `... abstain <def>`.
- § defNetModTdCloneBoundSyntax440 (R11U440_DEFTDCLONEBOUND_OFF, ModuleEmit
  materializeDefNetTs): the definition net's own copy of a MODULE vector
  typedef (not the single-view top's shared clone) keeps each written bound
  that is neither a literal nor a bare name as the unreduced syntax, its
  references named through the typedef (`t.w`), where ours folded it. A bare
  name bound is golden's parameter value object (TD/td10) and is left as it
  was. lawTrace `defNetModTdCloneBoundSyntax440 <typedef> <net>`.

No src/R*.h, no getenv, no reader function, no LawState.h section, no flag
written across files (each law reads only `defOnlyDefs`, the existing member
UhdmExporter fills before emission).

## Grid (cases/MS 6, NT 7, PH 5, TD 23, VI 9 case dirs; evidence/grid_law6.txt)

Each case's first line names its law; drivers/grid.sh runs pristine (the main
tree's build at the base, md5 23f0fa7a9de9d5325d1ebc88ea697778, frozen at
/tmp/r11u440_bin/pristine) and law6 (md5 fe74127763ae0595f92c247852c07831)
with R11U440_OFF and the case's own switch; every case's TOP file is `top`
except TD/td12 (the module itself the top). Every exit code 0 on both
binaries; upstream slang accepts every case (each is plain SystemVerilog the
exporter already accepts).

- 28 NOT_EQUAL -> STRICT_EQUAL: MS/ms03, ms06 (§ errTypePortSyntaxRange440);
  NT/nt01, nt04 to nt07 (§ defOnlyAliasVarNoNetType440); PH/ph01, ph03
  (§ undefaultedPlaceholderRetry440); TD/td01 to td09, td13 to td16, td18,
  td21, td23 (§ defNetModTdCloneBoundSyntax440; td01 and td02 with
  § defOnlyAliasVarNoNetType440 too); VI/vi07 to vi09
  (§ defGenConnVarSelIdxPart440).
- 2 NOT_EQUAL -> STRICT_NOTEQUAL: NT/nt03 (endline: the package typedef
  `p::v_t`'s end moved by `wire p::v_t wv;` in golden, § wireScopedTdEndAtType305's
  definition-only twin, not written), TD/td22 (type: `wire t n;` in an
  instantiated module, an elaborated copy golden keeps unfolded).
- 4 NOT_EQUAL on both binaries and closer by dump distance
  (drivers/dist.sh, unsorted/sorted): MS/ms01 96/96 -> 2/2 (left: `'0` sized
  -1 in golden's definition of a never-elaborated module, ours the left
  side's width; seen on ms02 too), TD/td17 78/60 -> 57/41 (a `t q [2];`
  unpacked use moving the shared vector typedef's end in golden), td19 99/81
  -> 36/28 and td20 41/33 -> 20/20 (two instances: golden lists one
  elaborated copy of the typedef per instance, ours one fewer; the uhdm-cmp
  line count grows 58 -> 299 / 243 only because the definition copy's head
  is gone and the weak-object count is the next difference).
- 16 byte-identical to pristine: controls MS/ms04, ms05 (keyword port types
  slang sizes), NT/nt02 (instantiated), PH/ph02, ph05 (bound on the first
  build / instantiated), TD/td11, td12 (literal bound, single-view top),
  VI/vi04 (no generate loop, STRICT_NOTEQUAL fullname on both); residues MS/ms02, PH/ph04 (an undeclared name:
  still abstains), TD/td10 (a bare-name bound, golden's parameter value
  object), VI/vi01 to vi03, vi05, vi06 (elaborated definitions, the law
  abstains).
- R11U440_OFF gives pristine's bytes and exit code on 50 of 50; each case's
  own switch on 48 (TD/td01 and td02 also need
  R11U440_DEFONLYNETTYPE_OFF: both laws fire there).
- Downstream (drivers/dsgrid.sh, evidence/downstream_law6.txt), all 50 case
  dirs: TD/td14 EQUIVALENT -> IDENTICAL, the other 49 IDENTICAL on both; none
  leaves IDENTICAL.

## Gates (law6, the one full five-stage sweep; evidence/fullsweep_law6.log, svtests_stage_law6.log)

Launched by drivers/fullsweep.sh after three quiet readings at 14:11 with
R11U440_TRACE on, workdir /tmp/r11u440sw6 (the same length as the master's
control /tmp/intr11u438, which is this pass's pristine reading: no pristine
build of my own and no pristine sweep).

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, regressions 0, conversions
  0, changes 0; the csv identical to the control; the 4087 databases
  identical to the control's by path-normalized dump (a positive control,
  two different cases, flagged).
- surelog: default CMP_EQUAL 480, testflags 474, regressions 0, conversions
  0, changes 0 (Tnoc d/t CMP_NOTEQUAL standing); the csv differs from the
  control only in the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes, 0 / 0 / 0 (stamped_gen_param d/t
  CMP_NOTEQUAL standing); the csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; the
  csv identical to the control.
- sv-tests: above (0 regressions, the 5 conversions, 0 changes).
- byteverify against the control (SELFCHECK=1): surelog 0 of 962 (self-check
  961 flagged), uhdm2rtlil 0 of 1608 (1607), downstream 0 of 805 (804).
- canaries: ok=52 changed=0 (surelog), ok=16 changed=0 (uhdm2rtlil); ctcan2
  EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6 both PASS.
- no-header audit: no src/R*.h, no getenv, no #include and no reader added;
  the five switches through lawOn(440, ...).
- tests/LAWS.md regenerated (scripts/law_index.py; --check reads current).

## Census by name

- Predicted before the sweep: a traced law6 run over all 4087 probe cases
  (drivers/probe_trace.sh, check_probe.py's command) fired 0 times, with a
  positive control (PH/ph01 fires § undefaultedPlaceholderRetry440).
- The sweep trace (evidence/trace_census_sweep.txt): the laws fire on
  surelog Earlgrey_0_1 default and testflags (§ defOnlyAliasVarNoNetType440
  on three nets of the never-elaborated ibex_dummy_instr and
  ibex_multdiv_slow, writing no net type where pristine wrote none either:
  0 byte movers), on no probe case, no uhdm2rtlil or downstream row, and on
  50 sv-tests rows. Each of those 50 was rerun with pristine and law6 from
  its own command (evidence/svtests_firing_rows_pristine_vs_law6.txt):
  exactly 6 move, the five conversions and rsd (SURELOG_CRASH, unjudgeable;
  § defNetModTdCloneBoundSyntax440 and § defOnlyAliasVarNoNetType440), the
  other 44 (black-parrot's four bp_uce abstentions, 40 EQUAL basejump rows
  whose firings write what pristine wrote) byte-identical by dump; exit
  codes equal everywhere.
- Earlier-pass census (drivers/bytecensus.sh over the 5332 fence-filtered
  case dirs of tools/probe/r11u4*repro and v11u4*repro;
  evidence/earlier_pass_census_law6.txt): exit codes equal on all 5332, 7
  movers, all toward golden or judge-neutral: r11u405 PH/ph01 NOT_EQUAL ->
  STRICT_EQUAL (dump 27 -> 0), r11u434 TC/tc09 NOT_EQUAL -> STRICT_EQUAL
  (84/26 -> 72/0), v11u434 VT/vt17 NOT_EQUAL -> STRICT_EQUAL (32/26 -> 6/0),
  VT/vt20 NOT_EQUAL on both, closer (27 -> 1), VT/vt09 NOT_EQUAL on both
  (sorted 42 -> 20; unsorted 122 -> 142 from the weak-list alignment only,
  pristine-vs-law dumps differ in exactly the one rewritten bound; uhdm-cmp
  68 -> 493 for the two-instance face of TD/td19), r11u424 BV/bv02 and
  v11u424 VK/vk05 STRICT_EQUAL on both (bytes moved, dump identical).
- Determinism: three concurrent law6 draws of each converted row read one
  dump each.

## Residues (ranked; all wrong on pristine too, none moved away)

1. THE 16 UVM-EXAMPLES ROWS, re-measured at the base (evidence/runner_base_uvm.csv,
   uvm_heads_base_*.txt): two families. The 12-row messaging family heads
   at pass 426's class-local `this_type` vpiInstance face, then the struct
   member class_typespec instance, the radix enum alias chain, about 20
   `m_inst_typename_alias_t` and foreach `unsupported_typespec` instance
   heads. The 5-row family (generation_seq_persistence, _poly,
   _randomization, many_to_one, test_init) heads at the importing package:
   golden's test_top_pkg lists uvm_pkg's own package variables
   (`uvm_aa_string_key` at uvm_object_globals.svh 239, `m_uvm_core_state`)
   as its variables, the importer listing ours models with a different
   count per package; the head tracer then attributes about 25 typespec
   instance links to that package. Not written.
2. bsg_source_sync_channel_control_slave: the DEFAULT `lg_token_width_p =
   "inv"` reverses `out_ctr_r[counter_min_bits_lp-1:lg_token_width_p]`
   (268:6) and golden lists the parameter as STRING:inv with a
   string_typespec; the retry overrides only undefaulted parameters.
3. The placeholder bodies slang cannot bind whatever the values (sister
   ground, below): bsg_nonsynth_mem_1rw_sync_assoc, bsg_scheduler_dataflow.
4. Shapes the laws do not reach: the elaborated copies of the indexed select
   (VI/vi01 to vi03, vi05, vi06: golden folds base and width there); a
   bare-name typedef bound (TD/td10); the per-instance elaborated typedef
   copy count (td19, td20, vt09); the `wire t n;` elaborated copy (td22); a
   vector typedef's end moved by an unpacked use (td17) and the definition
   twin of § wireScopedTdEndAtType305 (NT/nt03); `'0` sized -1 in a
   never-elaborated definition (MS/ms01, ms02).
5. easyUVM, the 3 uvm_scoreboard rows, p733, p737, tnoc and the carried lists
   of passes 438 and earlier stand.

## Sister-ground faces (reported, not written)

- ExprEmit: the empty argument of a system call (`f(a, , b)`) is INT:0
  ending at the previous token's line end in golden
  (test_bsg_comm_link_checker 119/120, the row's last strict field).
- ExprEmit / StmtEmit: a placeholder body's statement slang leaves invalid
  (an undeclared name, `bypass_lo` in bsg_scheduler_dataflow 187:12; a
  nonblocking write to an associative element, bsg_nonsynth_mem_1rw_sync_assoc
  41:13) has no writer shape, so pass 404's admission still abstains there;
  listing those definitions needs that shape.
- The `'0` fill sized -1 in a never-elaborated definition (MS/ms01, ms02):
  the size is written by the unsized-literal path, not located further.

## Process

The implementer ran one full five-stage sweep, on the final binary law6.
Intermediate binaries law1 to law5 ran only case dirs and single-row reruns
from their runner commands. Budget deviations and slips, none affecting a
measurement:

- A pristine runner call on the 32 non-EQUAL rows (the base kept goldens)
  ran in two parts, the second from the main tree's checkout (its
  build/uhdm-strictcmp; the worktree had none yet), writing only to
  /tmp/r11u440_pw.
- One uhdm-dump call ran with UHDM_DUMP unset (env not sourced in that
  shell): bash tried to run a cached golden.uhdm as a script (a syntax error
  on line 1, nothing written); the main tree checked clean; later calls
  source the env file and guard each tool with [ -x ].
- A diagnostic -O0 build (used only to print the invalid placeholder
  statements, never published) was first built without NDEBUG and then
  under slang's debug define, so its slang layouts mismatched the installed
  library and it allocated about 14 GB per run: 11 of its own runs were
  OOM-killed (dmesg names only that binary), then it was rebuilt in the
  Release configuration at -O0.
- The master's pass-437 integration sweep (/tmp/intr11u437, started
  13:29:53) overlapped the tail of my law4 build, ten single-case grid runs
  and the law5 build (TypeEmit only, 13:33 to 13:35); every later build,
  grid batch, census and the sweep waited for drivers/quiet.sh.
- The fence list was read into a file by a program from
  tools/probe/r11u107repro/canaudit.sh without printing it; every tree-wide
  list (the earlier-pass census) was filtered on it first; no fenced test was
  named, opened or run. No other agent's process was touched.

## Files

- drivers/: run1.sh (one case: golden cached by case text, ours, uhdm-cmp
  lines, uhdm-strictcmp verdict), grid.sh, switches.txt, cmp.sh, ddiff.sh,
  dist.sh, dsgrid.sh, bytecensus.sh, probe_trace.sh, quiet.sh, fullsweep.sh
  (adapted from tools/probe/r11u438repro/drivers).
- evidence/: the grids (law5, law6), downstream grid, the sweep log and the
  five csv diffs against the control, the trace census, the sv-tests firing
  rows rerun, the earlier-pass census, the base head traces
  (heads_base.txt with the head tracer of
  tools/probe/r11u426repro/evidence/tools/cmptrace2.cpp, built here against
  ~/.local's UHDM; tools/cmphead.cpp prints the failing pair), the base
  runner csvs.

