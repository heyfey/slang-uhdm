# r11u428 — module/type ground, pass 428 (sv-tests campaign, fourteenth pass on this ground)

Base 04c3f6f4d.  Production files: src/TypeEmit.cpp, src/ModuleEmit.cpp,
src/UhdmExporter.cpp.  No ExprEmit, StmtEmit, ParamEmit, EmitHelpers.h,
TaskFuncEmit, include/ or uhdm_main.cpp change.  Every law reads its switch
through src/LawSwitch.h (`lawOn(428, "R11U428_<LAW>_OFF")`); R11U428_OFF drops
the whole pass; R11U428_TRACE=<dir> logs each firing through lawTrace.  No
src/R*.h, no getenv, no reader function.  Two file-scope flags carry a law
across files (named here as the brief asks for any flag written across
emitters): `g428NdaSysTs` (ModuleEmit writes, UhdmExporter's sys-call drain
reads: the stamps of § caAnySysCallLhsTs428's net-declaration half) and
`g428ClsLocalSpec` (TypeEmit sets it around its one call of
emitClassPropSpecParams163, UhdmExporter's builder reads it: the site of
§ clsMethodLocalForeignPkgSpec428).  Each is read nowhere else.


## Result

Pristine = the main tree's build at the base (md5
4cfe02b16eea0da34c20cac5afcbd2a7; the worktree's rebuild is byte-identical);
the pristine reading is the master's control sweep /tmp/intr11u426 (its csvs
equal the committed results/*.csv).  Final law binary law17, md5
51d6ad0ed34867e09399940fe7adf8ff, swept with all five stages
(drivers/fullsweep.sh, R11U428_TRACE on; the sv-tests stage through the main
tree's scripts/check_svtests.py read-only, baseline the base's
results/golden_svtests.csv; evidence/fullsweep_law17.log; workdir
/tmp/r11u428sw2, the control's name length for byteverify):

| stage | result |
|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69, regressions=0 conversions=0 changes=0; csv identical to the control |
| surelog | default 480 / testflags 474 CMP_EQUAL, regressions=0 conversions=0 changes=0; csv identical to the control but the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 both modes, regressions=0 conversions=0 changes=0; csv identical to the control |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, not excused 0; csv identical to the control |
| sv-tests | **regressions=0 conversions=10 changes=0**: EQUAL 1883 -> 1889, STRICT_NOTEQUAL 2 -> 6, DIFFERENT 55 -> 45 (of 2346; BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 unchanged) |

sv-tests conversions (evidence/svtests_law17_vs_control.diff: exactly these
ten rows differ from the control; fresh csv rows quoted):

- `generated/basejump/bsg_cache_BaseJumpSTL_bsg_cache_non_blocking_data_mem.sv,EQUAL,,equal`
  (DIFFERENT -> EQUAL) through § hpDispPowerOneToken428 (110:62) and
  § hpMacroSelDispExpanded428 (125:12).
- `generated/basejump/bsg_misc_BaseJumpSTL_bsg_imod_range.sv,EQUAL,,equal`
  (DIFFERENT -> EQUAL) through § uninstDefGenRegionCaUnlisted428 (`assign o
  = ...` at 56:11 inside the uninstantiated definition's generate region).
- `generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_axi_mem.sv,EQUAL,,equal`
  (DIFFERENT -> EQUAL) through § synCaseEqXnorOps428 and
  § synOneBitXUpper428 (`(ram[rd_ram_idx][i] === 1'bx)` at 201:29).
- `generated/hdlconv_std2017/hdlconvertor_std2017_p489.sv,EQUAL,,equal`
  (DIFFERENT -> EQUAL) through § ansiLogicLeaderFollowerNet428 (`in2`,
  `in_array [20:0]` after `logic[7:0] in1`).
- `generated/hdlconv_std2017/hdlconvertor_std2017_p599.sv,EQUAL,,equal`
  (DIFFERENT -> EQUAL) through § caAnySysCallLhsTs428 and
  § ndaWholeSysCallSharesLhs428 (`wire [64:1] net_r = $realtobits(r);`; the
  head pass 426 reported as ModuleEmit's short name list).
- `generated/hdlconv_std2017/hdlconvertor_std2017_p765.sv,EQUAL,,equal`
  (DIFFERENT -> EQUAL) through § modIfaceMethodImplLastNameless428.
- `testbenches/uvm_agent_active.sv,STRICT_NOTEQUAL,differ:type(1),differ:type(1)`,
  `testbenches/uvm_agent_passive.sv,...`, `testbenches/uvm_driver_sequencer_env.sv,...`,
  `testbenches/uvm_monitor_env.sv,STRICT_NOTEQUAL,differ:type(1),differ:type(1)`
  (DIFFERENT -> STRICT_NOTEQUAL) through § clsMethodLocalForeignPkgSpec428
  (the uhdm-cmp head at the base: `uvm_resource#(uvm_integral_t)
  __tmp_rsrc__` in work@packet_in::__m_uvm_execute_field_op without its
  specialization, `RHS: <null>`, the face pass 423 named as TypeEmit's
  uvm_resource#(TYPE) class typespec).  The strict head left (one object):
  a cast `uvm_radix_enum'(...)` in the same method whose enum typespec's base
  alias reaches the uvm_pkg DEFINITION listing of uvm_field_flag_t (range
  `UVM_FIELD_FLAG_RESERVED_BITS-1` unfolded) where golden reaches the
  elaborated one (`INT:27`) — the radix-enum face of the uvm-examples rows,
  below.

Goal 1: no rejecting row carries an exporter message (detail column re-read:
0 rows name a typedef target, class property, exporter or unsupported shape;
all 75 SURELOG_ONLY rows carry an upstream slang front-end diagnostic, e.g. 6
"design element does not have a time scale", 5 "expected a declaration
name").  No exit-4 shape of the backlog was written by this pass.

Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law workdir
against the master's control; evidence/byteverify_law17.txt): surelog 0 of
962 (selfcheck 961/962), uhdm2rtlil 0 of 1608 (1607/1608), downstream 0 of
805 (804/805): NO CORPUS BYTE MOVER, as predicted: the source scan before the
sweep (fence-filtered: whole-right-side system calls, `task a.X`, `**` in a
dotted select over the two corpora; P1 hits only in rejected or unrun rows,
the one P2 and P4 files outside every runnable row) and the five UVM corpus
rows run alone on law16 with the trace (CMP_EQUAL and strict-equal, no
firing).  The trace census of the whole sweep (evidence/trace_census.txt):
NO law of this pass fires on any probe case or corpus row (positive control:
a grid case logs its firings, and 17 sv-tests rows do): the ten conversions;
bsg_comm_link (§ synCaseEqXnorOps428, DIFFERENT on both, uhdm-cmp 42 -> 42
lines, sorted-dump distance 136 -> 78 toward golden); easyUVM/top and the
three scoreboard testbench rows (§ clsMethodLocalForeignPkgSpec428, DIFFERENT
on both, uhdm-cmp counts unchanged: 659635, 2200983, 2231211, 2216265, the
head earlier at the design level); generated/rsd/rsd (SURELOG_CRASH, no
golden; § ansiLogicLeaderFollowerNet428).  Away census: none away
(evidence/away_census_cmp_lines.txt).  Canaries: canaries.sh ok=52 changed=0
(surelog) and ok=16 changed=0 (uhdm2rtlil); ctcan2.sh PASS on both
(EXPECT_UNKNOWN=1 / 6).  Binary audit, fence-filtered: surelog 1523 of 1573
cmds.txt name law17 (the other 50 hold only a Surelog line), uhdm2rtlil 1740
of 1740; no other slang-uhdm binary named.

## Grid

59 case dirs in CE, CL, GR, HP, IM, PP and SC (evidence/grid_law17.txt;
drivers/grid.sh: exit code, uhdm-cmp line count, strict verdict, md5 per
binary): 34 NOT_EQUAL -> STRICT_EQUAL, 1 NOT_EQUAL -> STRICT_NOTEQUAL (SC/sc08,
type: golden keeps `$countones(4'b1011)` as a call in the elaborated view,
ours folds), 10 STRICT_EQUAL controls byte-identical, 1 STRICT_NOTEQUAL
control byte-identical (SC/sc16), 13 NOT_EQUAL on both binaries (10
byte-identical: the residues and controls GR/gr01, gr03, IM/im02, im05,
PP/pp03, pp04, pp05, SC/sc09, sc10, sc11; 3 moved: GR/gr11 618 -> 295 and
HP/hp02 340 -> 324 toward golden, SC/sc15 17 -> 46 with its uhdm-cmp head
moved later, from the definition's missing stamp to the elaborated
parameter substitution).  Every exit code 0.  R11U428_OFF gives pristine's
bytes on 59 of 59; each case's own switch on 51, the other 8 needing a
co-firing switch (CE/ce03 also SYNCASEEQ; SC/sc01, sc03, sc06, sc14 also
ANYSYSTS under NDASYSSHARE; sc07, sc12, sc15 also ANYSYSTS under CASYSSHARE;
evidence/grid_law17_cofiring.txt: all 8 restore pristine).  Downstream on
the 48 class-free case dirs (drivers/dsgrid.sh;
evidence/downstream_cases_law17.txt): PP/pp01 and pp10 EQUIVALENT ->
IDENTICAL, none worse (pp04, pp05 EQUIVALENT and sc08, sc15 DIVERGENT on both).

Decode cases (CL cl06-cl11, the package-order split): golden lists the
specialization when the method's class is at $unit or in a module, or in a
package whose NAME sorts after the generic's package (Surelog compiles
packages in name order; `q` after `p`, `zuse` after `agen`: listed; `pb`
before `rp`, `ause` before `zgen`: bare).  This decode came from the probe
case r10sd1repro/b27_inline_method_foreign, which the first law binary
(law16) broke in its corpus stages (EQUAL -> NOT_EQUAL; the only firing in
the probe stage); the law was narrowed and the full sweep rerun on law17.

## Laws

1. § uninstDefGenRegionCaUnlisted428 (ModuleEmit emitContAssigns;
   R11U428_UNINSTGRCA_OFF) — a continuous assignment written inside an
   explicit `generate ... endgenerate` region of a module nobody instantiates
   is not one of the definition's module-level cont_assigns.  CompileModule's
   definition walk stops at a Generate_region; only an instance's
   GENERATE_REGIONS collection descends it, so an uninstantiated definition
   lists no cont_assign for it (the region is compiled once by
   compileGenStmt, whose begin holds the region's FIRST item only).
   sv-tests generated/basejump/bsg_misc_BaseJumpSTL_bsg_imod_range.sv.
   Cases GR (gr02, gr08, gr10, gr11, gr12 law; gr01, gr03, gr05, gr06, gr09
   controls and residues).
2. § synCaseEqXnorOps428 (TypeEmit mapSyntaxBinOp; R11U428_SYNCASEEQ_OFF) —
   `===`, `!==` and `~^` in a syntax-built expression (a definition-view
   generate block's continuous assignment, a range bound) are vpiCaseEqOp,
   vpiCaseNeqOp and vpiBitXnorOp; without them the operand vanished.
   sv-tests generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_axi_mem.sv.
   Cases CE ce01, ce02, ce04.
3. § synOneBitXUpper428 (TypeEmit emitSyntaxExpr IntegerVectorExpression;
   R11U428_SYNONEBITX_OFF) — a 1-bit `1'bx` built from syntax reads `1'bX` /
   `BIN:X`, the expression emitter's quirk.  Same row (201:53).  Case CE ce03.
4. § hpDispPowerOneToken428 (TypeEmit emitSyntaxExpr dotted path;
   R11U428_HPPOW_OFF) — `**` is one operator in a hier_path's display
   spelling (`data_mem_pkt.data[0+:8 * 2 ** i]`, not `8 * 2 *  * i`).
   sv-tests generated/basejump/bsg_cache_BaseJumpSTL_bsg_cache_non_blocking_data_mem.sv.
   Cases HP hp01, hp03.
5. § hpMacroSelDispExpanded428 (TypeEmit emitSyntaxExpr dotted path;
   R11U428_HPMACROSEL_OFF) — a dotted path written outside a macro whose
   select holds a macro use is spelled from the expanded syntax: parentheses
   dropped, binary operators and the conditional's `?`/`:` spaced, the range
   `+:`/`-:`/`:` not (`data_mem_pkt.byte_sel[i+:byte_sel_width_lp - i > 1 ?
   byte_sel_width_lp - i : 1]`, not the source's `` `BSG_MAX(...) `` text); the
   last element's full name takes the same spelling.  Same row (125:12).
   Cases HP hp02, hp04.
6. § ansiLogicLeaderFollowerNet428 (UhdmExporter post-pass;
   R11U428_LOGICFOLLOWNET_OFF) — in an ANSI header where an earlier port has a
   direction, a direction-less `logic` port followed by bare ports
   (`input clk, logic [7:0] a, b, c [3:0]`): Surelog's no-direction branch builds
   the `logic` port's Signal with no typespec node and the bare followers
   reuse `last->getTypeSpecId()` (empty), so each follower is a logic_net with
   vpiNetType 36, no typespec and none of its own unpacked dimensions in every
   elaborated instance, its port's low connection bound to it, and no port of
   the chain carries a vpiTypedef.  The definition listing already matched.
   sv-tests generated/hdlconv_std2017/hdlconvertor_std2017_p489.sv.  Cases PP
   (pp01, pp02, pp06, pp07, pp08, pp10 law; pp03, pp04, pp05, pp09 controls).
7. § modIfaceMethodImplLastNameless428 (UhdmExporter post-pass;
   R11U428_IFCMETHODIMPL_OFF) — a module defining exported interface tasks
   (`task a.Write(...)`) lists ONE nameless task: the last such definition,
   full name the module's, vpiVisibility 1, the module as parent and
   instance, span `task` .. `endtask`, no ports and no body, in the definition
   listing and every elaborated instance.  A function as the last definition
   and a module listing subroutines of its own abstain.  sv-tests
   generated/hdlconv_std2017/hdlconvertor_std2017_p765.sv.  Cases IM (im01,
   im04 law; im02, im05 abstentions).
8. § caAnySysCallLhsTs428 (ModuleEmit emitContAssigns, both stamp sites; the
   drain in UhdmExporter; R11U428_ANYSYSTS_OFF) — writeCont_assign stamps
   EVERY system call that is the whole right side (its `simplified == false`
   branch is name-blind), written assignment and net-declaration assignment
   alike; a net-declaration stamp resolves to the declared net's typespec, not
   to a same-named non-ANSI port's.  sv-tests
   generated/hdlconv_std2017/hdlconvertor_std2017_p599.sv.  Cases SC (sc02,
   sc04, sc05, sc08, sc13 law; sc09, sc10, sc11 not reached).
9. § ndaWholeSysCallSharesLhs428 (ModuleEmit emitContAssigns;
   R11U428_NDASYSSHARE_OFF) — a net-declaration assignment whose whole
   initializer is a stamped system call of nets or variables (or of nothing)
   keeps the module's listed net as its left side (reduceExpr leaves the call,
   writeCont_assign does not clone).  p599.  Cases SC sc01, sc03, sc06, sc14.
10. § caWholeSysCallSharesDefCell428 (ModuleEmit emitContAssigns;
    R11U428_CASYSSHARE_OFF) — the written half: an elaborated instance lists
    the definition's cell for `assign y = $countones(x);`.  Cases SC sc07,
    sc12 law; sc15 (a parameter argument) and sc16 (`$bits`, `$clog2`)
    controls.
11. § clsMethodLocalForeignPkgSpec428 (TypeEmit makeTypespec class handles;
    the builder emitClassPropSpecParams163 in UhdmExporter;
    R11U428_CLSLOCALSPEC_OFF) — § 163's residue R2 measured: a class-method
    body local written as a specialization of a package generic keeps its
    vpiParameter / vpiParamAssign when the method's class is not homed in that
    package (compileTypespec's three probes miss), a package-typedef argument
    taking its per-use alias clone (`logic_typespec (uvm_integral_t)` with
    vpiTypedefAlias `uvm_resource.T.uvm_integral_t` -> the package listing).
    sv-tests testbenches/uvm_agent_active.sv, uvm_agent_passive.sv,
    uvm_driver_sequencer_env.sv, uvm_monitor_env.sv.  Cases CL (cl01, cl02,
    cl04, cl05 law; cl03 control).

## Residues (ranked; all wrong on pristine too, none moved away)

1. The radix-enum face (the 4 testbenches rows' next strict head and the 16
   uvm-examples rows' listing faces): a cast's or operation's
   `uvm_radix_enum` typespec reached from a $unit class method whose base
   alias reaches the definition listing of `uvm_pkg::uvm_field_flag_t`
   (`UVM_FIELD_FLAG_RESERVED_BITS-1` unfolded) where golden reaches a copy with
   the folded `INT:27`; golden's enum copy is located at an argument site
   (uvm_recorder.svh 976:32), ours at another (uvm_printer.svh 1076:47).  The
   cast typespec is chosen by ExprEmit (reported below); the listing copy it
   reaches is this ground's.
2. The generate-region listing (cases GR/gr01, gr03, gr11): Surelog's
   compileGenStmt compiles a generate region's FIRST item only into its
   gen_region > begin, so a region whose first item is a continuous
   assignment lists it there (with refs named through the module, no actual)
   in addition to the module-level cell of an instantiated module; ours writes
   no gen_region (gr01, gr11) or an empty begin (gr03).  Not written: it moves
   no sv-tests row.
3. § ansiLogicLeaderFollowerNet428 not reached: a `reg` leader (PP/pp03: golden
   both nets typeless, ours a typespec at the name), `bit`/`int` leaders
   (pp04, pp05: golden the followers' port vpiTypedef, ours none).
4. § modIfaceMethodImplLastNameless428 abstentions: a function as the last
   definition (IM/im02: golden a nameless function with its return variable
   `int_var (work@mm)`), a module with subroutines of its own (im05, order
   unmeasured).
5. § caAnySysCallLhsTs428 not reached: a select left side (SC/sc09), a
   generate-block assignment (sc10), an interface net declaration (sc11);
   the elaborated view of a call over a parameter (sc15: golden substitutes the
   parameter's value into the argument) or a literal (sc08: golden keeps the
   call, ours folds).
6. § hpMacroSelDispExpanded428 in an elaborated instance (HP/hp02: golden
   folds the expanded select to `p.sel[0+:4]`, ours keeps `W - i > 1 ? ...`).
7. Decoded heads not written: p737 (a module with a default-less TYPE
   parameter is a design top for Surelog, design `work@M`; slang refuses it as
   a top), p733 (defparams from a separate top `annotate` that Surelog does not
   apply; slang applies them), bsg_nonsynth_dpi_rom (the element range of
   `parameter bit [width_p-1:0] arr_p [els_p-1:0]`'s array_typespec: golden
   keeps `width_p-1`, ours folds), bsg_mesh_stitch, round_robin_fifo_to_fifo,
   comm_link (the default-less "inv" placeholder widths), default-value.sv,
   18.14--random-stability_1 (UVM listing noise), and the carried backlog of
   passes 402-426 (their READMEs).

## Sister-ground faces (reported, not written)

- ExprEmit (def-view and elaborated generate-block expressions,
  § genBlockBitsKeepsSelect200's site): `$bits(<signal declared at module
  level>)` inside a generate block stays a sys_func_call in golden in BOTH
  the definition listing and the elaborated gen_scope (`if`, `if/else`,
  `for`; its argument a ref_obj named through an enclosing select:
  `work@top.x.x`), while a signal the block itself declares folds; ours folds
  every fixed-width signal.  sv-tests
  bsg_comm_link_BaseJumpSTL_bsg_source_sync_channel_control_master.sv (143:53,
  148:41, 149:30).  Cases evidence/residue_cases/BB (bb02, bb03, bb04, bb06
  NOT_EQUAL at 42 lines; bb01 module level and bb05 block-local STRICT_EQUAL).
  A TypeEmit law was tried and withdrawn before the sweep: TypeEmit's
  emitSyntaxExpr does not build these expressions.
- ExprEmit spaceOps (the elaborated hier_path display, the copy beside
  TypeEmit's): the same `**` spacing as § hpDispPowerOneToken428; no row
  measured.
- ExprEmit cast typespec (residue 1): which enum copy a cast in a $unit class
  method references.
- ParamEmit (emitParameters' type_parameter, the definition listing):
  hdlconvertor_std2017_p130.sv — a type parameter declared in the module BODY
  (`parameter type t_3 = int;`) reads the representative instance's override
  in the definition listing (a `logic_typespec` at the override's text
  14:12-14:15) where golden keeps the declaration default `int_typespec`
  7:22-7:25; `defTypeSyn` is read from the header's parameter port list only.

## Process

The IMPLEMENTER: one five-stage sweep on the final binary law17
(evidence/fullsweep_law17.log).  An earlier run on law16 (its probe,
surelog, uhdm2rtlil and downstream stages complete,
evidence/fullsweep_law16_aborted.log) found the probe regression
r10sd1repro/b27_inline_method_foreign; its sv-tests stage was stopped by its
own PIDs after 2 minutes, the law narrowed (the package name order), and the
whole five-stage sweep rerun on law17: the corpus stages ran twice, the
sv-tests stage once complete.  Intermediate binaries law1-law16 got case runs
and targeted runner calls only (the 31 non-UVM DIFFERENT/STRICT_NOTEQUAL rows,
the 7 testbenches rows, the five UVM corpus rows through verify_golden.py
--filter).  Slips, none affecting a measurement: three batches overlapped the
sister v11u425's sweeps (a 308-case probe byte comparison during its sv-tests
stage, its pre-launch check printed the live processes and did not wait; the
law14 build with a 5-case grid during its surelog stage; a 40-second
31-row runner call at the start of its second sv-tests stage); every later
launch waited for a zero count.  The fence list was read into a file by a
program and never printed; every tree-wide list (the corpus and probe source
scans, the cmds.txt audit) was filtered on it before a file was opened.  No
other agent's process touched.

## Files

- cases/{CE,CL,GR,HP,IM,PP,SC}/<case>/dut.sv — the grid, first line `// § <law>`
  (a TOP file names the top for both tools).
- drivers/run1.sh, grid.sh (keyed on the path after tools/probe/), dsgrid.sh
  (downstream per case), fullsweep.sh, switches.txt, rowdiff.sh (a runner
  row's golden/ours dumps, uhdm-cmp and strict heads), cdiff.sh, pcmp.sh.
- evidence/: fullsweep_law17.log, fullsweep_law16_aborted.log,
  svtests_law17_vs_control.diff, byteverify_law17.txt, trace_census.txt,
  away_census_cmp_lines.txt, grid_law17.txt, grid_law17_cofiring.txt,
  downstream_cases_law17.txt, runner_base_31rows.csv (pristine),
  runner_law16_38rows.csv, uvm_corpus_rows_law16.csv, residue_cases/BB and
  residue_BB_law17.txt.
