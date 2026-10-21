# r11u424 — module/type ground, pass 424 (sv-tests campaign, twelfth pass on this ground)

Base 556047d2e.  Production files: src/ModuleEmit.cpp, src/TypeEmit.cpp,
src/UhdmExporter.cpp, src/TaskFuncEmit.cpp (no ExprEmit, StmtEmit, ParamEmit,
EmitHelpers.h, include/ or uhdm_main.cpp change).  Every law reads its switch
through src/LawSwitch.h (`lawOn(424, "R11U424_<LAW>_OFF")`); R11U424_OFF drops
the whole pass; R11U424_TRACE=<dir> logs each firing.  No src/R*.h, no getenv,
no reader function.

## Result

Final binary (law21, md5 c623a2128527ff4453411543a280fc43; pristine
3ee8999f424a2bdc9c6378d0ba960e77 = the main tree's build) swept ONCE with all
five stages (drivers/fullsweep.sh; the sv-tests stage through the main tree's
scripts/check_svtests.py, baseline the base's results/golden_svtests.csv):

| stage | result |
|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69, regressions=0 conversions=0 changes=0 |
| surelog | default 480 / testflags 474 CMP_EQUAL, regressions=0 conversions=0 changes=0 |
| uhdm2rtlil | 803/1/67 both modes, regressions=0 conversions=0 changes=0 |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2, verdicts identical to the control /tmp/intr11u422 |
| sv-tests | **regressions=0 conversions=20 changes=0**: EQUAL 1862 -> 1880, STRICT_NOTEQUAL 2 -> 2, DIFFERENT 76 -> 58 (of 2346; BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 unchanged) |

sv-tests conversions (evidence/svtests_conversions.txt), with the law(s) the
trace names (evidence/trace_svtests_rows.txt):

- chapter-16/16.12--property-interface-uvm.sv, -prec-uvm.sv: DIFFERENT -> EQUAL
  (§ ifcConcAssertListed424 + § ifcUnitVarRefMintsNet424; § ifcProcCallArgNoTs424
  on the uvm_report_enabled call in the assertion action, § coverClockedPropExprIsClock424
  not needed there)
- basejump bsg_async_fifo, bsg_launch_sync_sync, bsg_sync_sync, bsg_cache,
  bsg_tag_trace_replay, bsg_nonsynth_mem_1rw_sync_mask_write_byte_assoc:
  DIFFERENT -> EQUAL (§ defGenConnIpsExprBounds424)
- bsg_mem_1rw_sync_mask_write_var, bsg_mem_1r1w_sync_mask_write_var:
  DIFFERENT -> EQUAL (§ defGenConnPsExprBounds424)
- bsg_mul_array, bsg_nonsynth_dramsim3: DIFFERENT -> EQUAL (§ defGenConnVarSelRange424)
- bsg_pipeline_stall_collapse: DIFFERENT -> EQUAL (§ genForCompoundStep424)
- bsg_wormhole_router_decoder_dor: STRICT_NOTEQUAL fullname(1) -> EQUAL (§ defGenLpSelIdxThroughBase424)
- bsg_mesh_router: STRICT_NOTEQUAL col(1) -> EQUAL (§ defGenLpSysArgBitSelAtIndex424)
- hdlconvertor std2012 p88, std2017 p124: DIFFERENT -> EQUAL (§ tpVarInitSizedByDefault424)
- generic/class/class_test_51.sv: DIFFERENT -> EQUAL (§ classParamBitsKeywordFold424)
- hdlconvertor p193_2: DIFFERENT -> STRICT_NOTEQUAL differ:line(3) (§ tpRetOobRefVar424)
- hdlconvertor p600: DIFFERENT -> STRICT_NOTEQUAL differ:fullname(6) (§ boundSizedLitKept424)

Goal 1: nothing on this ground; the 75 SURELOG_ONLY rows are unchanged
(upstream slang front-end diagnostics, as passes 406-422 found).

## Laws

1. § ifcConcAssertListed424 (R11U424_IFCASSERT_OFF; ModuleEmit
   emitInterfaceInstance) — a concurrent assertion written as an interface
   item is listed under vpiAssertion (assert_stmt/assume/cover), not wrapped
   in an `always`.  Surelog compiles it once on the definition
   (CompileAssertion compileAssertionItem) and UhdmWriter lists that vector for
   the definition and every elaborated instance, re-parenting it at each, so
   the last instance names it while references stay bound to the FIRST
   instance (golden IA/ia06: ref work@top.d2.clk -> bit_var work@top.d1.clk);
   a port view lists none (ia09).  Compiled at the first instance, renamed at
   later ones with § propAssertLastInstPath188's renamer.  Cases IA ia01-ia10
   (ia01 = pass 421 residue ra01; ia02 = ra02 module control; ia03/ia05
   controls).
2. § ifcUnitVarRefMintsNet424 (R11U424_IFCUNITVAR_OFF) — § unitVarRefMintsNet418
   on an interface: a `$unit` variable read in an interface body mints a
   logic_net (vpiNetType 1, no file, at the first reference, last of the
   nets) on the FIRST elaborated instance only (ui02), the reference binding
   it; § unitVarNestedScopeAbstain418v's fences (generate, class, nested
   declarations: ui04 control); port views mint nothing (ui07).  Cases UI
   ui01-ui12 (ui01 = v11u418 VU/vu08; ui08, ui10, ui11 module controls).
3. § ifcProcCallArgNoTs424 (R11U424_IFCARGTS_OFF) — call actuals in an
   interface's process or concurrent-assertion action carry no formal
   typespec (golden UI/ui12, UC/uc01-uc03, uc05), as a module process's do;
   the instance sets ExprEmit's defOnlyDefEmit gate (whose only reader is that
   stamp) over its process/assertion compile.  uc04 (continuous assign and
   function body) is a control at pristine bytes.
4. § coverClockedPropExprIsClock424 (R11U424_COVERCLK_OFF; ModuleEmit
   emitAssertion) — compileConcurrentAssertion: cover and restrict carry no
   vpiStmt (no Action_block node), and assert/cover/restrict take the
   property_spec's FIRST child as vpiPropertyExpr (the clocking op when
   clocked); a cover sequence's property_spec spans the event expression.
   Cases CV cv01-cv06 (cv04, an unclocked cover sequence where golden keeps
   only the first operand, is a residue); IA/ia07.
5. § defGenLpSelIdxThroughBase424 (R11U424_GENLPSELIDX_OFF; TypeEmit bit_select
   branch, armed by ModuleEmit emitDefGenStmts) — in a definition-view generate
   localparam initializer, references in a non-bare select index are named
   through the select (`P[i+1]` -> work@top.rof.P.i; bare `P[i]` stays rof.i).
   Cases RD rd01-rd06 (all toward golden; their remaining heads are the
   unpacked parameter-array and packed-parameter faces of ParamEmit/ExprEmit).
6. § defGenLpSysArgBitSelAtIndex424 (R11U424_GENLPSYSBS_OFF) — the same
   initializer's bit_select argument of a system call is anchored at its index
   (§ paramInitSysArgBitSelAtIndex421's generate half).  Cases PB pb01, pb02,
   pb06 (r11u421 PB), pb07; toward golden, remaining heads the sister's.
7. § defGenConnIpsExprBounds424 (R11U424_GENIPSBOUND_OFF; ModuleEmit def-gen
   port connections) — an indexed part-select's base or width that is not a
   plain name, number or `a*b` (parenthesized, an operation, a ternary, a
   macro, a macro ARGUMENT substituted into the body) is built from the
   selector syntax: an operation inside the parentheses, references through
   the select, constant leaves unparented.  Cases RF rf01-rf07 (rf05 control
   byte-identical).
8. § defGenConnPsExprBounds424 (R11U424_GENPSBOUND_OFF) — the simple-range
   twin: a bound with parentheses, `$`, a macro, a conditional or more than
   one operator is built from syntax.  Cases PS ps01-ps03 (ps03 control at
   pristine bytes; all three keep the elaborated port-connection fold face,
   pass 421's residue 2).
9. § defGenConnVarSelRange424 (R11U424_GENVSRANGE_OFF) — a simple range as a
   later dimension of a multi-dimension connection select is a part_select
   index of the var_select (named after the base, through the select,
   spanning the range text).  Cases VR vr01, vr02.
10. § genForCompoundStep424 (R11U424_GENFORSTEP_OFF) — a generate-for step
   `i += 1` / `-=` / `*=` / `/=` is an assignment whose vpiOpType is the
   arithmetic operator.  Cases GS gs01, gs02.
11. § tpVarInitSizedByDefault424 (R11U424_TPVARINIT_OFF; ModuleEmit elaborated
   variable initializer) — a variable typed by an OVERRIDDEN type parameter
   sizes (and masks) its bare-decimal initializer at the parameter's DEFAULT
   type (`p2 j = 0`, default shortint overridden to int: size 16).  Cases TV
   tv01 (= pass 421 residue rt01) - tv04 (tv04 control).
12. § boundSizedLitKept424 (R11U424_BOUNDLIT_OFF; TypeEmit emitBound) — a packed
   range bound written as a sized/based literal is the literal (BIN/DEC/HEX,
   its size, its text, whole span), never the folded UINT.  Cases BV bv01-bv06
   (bv06, a struct member of a typedef'd packed array, is not reached by this
   builder: residue).
13. § tpRetOobRefVar424 (R11U424_TPRETOOB_OFF; TaskFuncEmit) — the class-body
   prototype listing of an `extern` method returning the class's type
   parameter is a ref_var (not § 185's class_var); the out-of-body definition
   `function C::T C::f()` keeps class_var but over an unsupported_typespec
   `C::T` spanning `C::`.  Cases TP tp01-tp03 (tp03 class-binding control).
14. § classParamBitsKeywordFold424 (R11U424_CLSBITSKW_OFF; TypeEmit, armed by
   UhdmExporter emitClassParameters) — `$bits(<keyword type>)` in a class
   parameter folds from the keyword alone (int 32, byte 8, logic 1 ...),
   UINT size 64 over the `$bits` token.  Cases CB cb01-cb03 (cb03 typedef
   control).
15. § classParamWrittenKwTs424 (R11U424_CLSPARAMKW_OFF; UhdmExporter
   emitClassParameters) — a class parameter written with a keyword type
   other than int/string gets that keyword's typespec over the type syntax
   (signed for byte/shortint/longint/integer, the parameter signed with a
   keyword); a written int/string/keyword parameter whose initializer does not
   fold still carries its typespec.  Cases CP cp01-cp05 (cp03, packed ranges,
   residue).

## Grid (evidence/grid_law21.txt; drivers/grid.sh law pristine)

87 case dirs.  R11U424_OFF gives pristine's bytes and exit code on 87 of 87;
each case's own switch gives pristine on 80, the other 7 (CB/cb02, CP/cp04,
PB/pb07, UC/uc05, UI/ui06, ui09, ui12) need a co-firing law's switch too.
Transitions pristine -> law: 47 NOT_EQUAL -> STRICT_EQUAL, 3 NOT_EQUAL ->
STRICT_NOTEQUAL (rf06 endcol, vr02 fullname, tp01 line), 9 STRICT_EQUAL
controls kept (7 byte-identical), 28 NOT_EQUAL on both (every one toward golden
by dump distance or a control at pristine bytes; no exit code changes, all 0).

## Corpus movers (byteverify, SELFCHECK, vs the master's control /tmp/intr11u422)

surelog 2 of 962: Tnoc default and testflags (CMP_NOTEQUAL standing; uhdm-cmp
28 -> 28 lines at the same head; the trace names § defGenConnPsExprBounds424,
11 firings each; Tnoc's dump distance not measured, the golden dump alone
being 392 MB and timing out).  uhdm2rtlil 0 of 1608, downstream 0 of 805.
Trace census over the corpora: FuncStructVal d/t (defGenConnPsExprBounds424,
bytes identical), probe r11u112 p06_seq_body and v11u113 r09_two_props
(coverClocked, EQUAL kept), probe r11u35 g3_shape35 (boundSizedLit, EQUAL
kept); nothing else fires.  Canaries ok=52 / ok=16, ctcan2 PASS on both.

sv-tests trace rows that did not convert: non_blocking_data_mem (uhdm-cmp
228 -> 228), round_robin_fifo_to_fifo (80 -> 80), class_test_49 (16 -> 36,
head moved later from 26:13 to the sister's `f(glb::arr[N])` at 27:29), tnoc
(DIFFERENT kept), rsd (SLANG_ONLY), six black-parrot rows (SURELOG_CRASH),
p612 (SURELOG_CRASH).  None away.

## Residues (ranked; all wrong on pristine too)

1. Default-less (`"inv"`) parameter placeholders in typedef / parameter ranges
   (comm_link, source_sync_channel_control_master, round_robin_fifo_to_fifo,
   dpi_rom, mesh_stitch): § undefaultedDefInvalidInst404's placeholder folds;
   cases TR tr03-tr05 ($clog2 in a module typedef range kept unfolded in golden).
2. The elaborated port connection's folds (PS, RF rf03/rf04/rf07; pass 421 rf02).
3. p599: a net-declaration assignment's system-call right side carries the
   net's typespec in golden (cases ND, not written).
4. default-value.sv (cases DV/dv01): golden's two struct_typespec objects.
5. p193_2 line(3): the prototype ref_var's typespec should be the type
   parameter's default typespec (and the oob body's `C::f.p` names).
6. p600 fullname(6); class_test_49 next head (sister); cv04 unclocked cover
   sequence; bv06/cp03 packed ranges; ui03/ui05 (a $unit variable read by an
   interface function or continuous assign is not bound); IA/ia03 (a positional interface
   connection: ours lists a ref_module in the top's definition, golden none).
7. Carried backlog: the UVM listing faces, easyUVM, tnoc, scr1, fx68k, p130,
   p179, p203, p334, p489, p719, p733, p737, p765, 18.14_1.

## Sister-ground faces (reported, not written)

- the 4 testbenches rows (ParamEmit class param_assign copy's ref_typespec)
  and the uvm-examples 1<<16 copies (pass 422's report, unchanged);
- class_test_49's `f(glb::arr[N])` package-array select naming (ExprEmit);
- PS/ps02's `$clog2(W)` argument named work@top.g.di.W where golden names it
  through the formal (TypeEmit emitSyntaxExpr's system-call argument prefix,
  mine, not written: residue).

## Process

Worktree /tmp/wt_r11u424, scratch /tmp/r11u424_*.  No pristine sweep (the
master's control /tmp/intr11u422 is the pristine reading); intermediate
binaries got only case runs and targeted runner calls on worked rows
(drivers/svrun.sh); one full sweep on the final binary, launched after three
quiet readings.  Slip: three background waiters of mine matched their own
command line and never ended (stopped by task id; no measurement affected),
and one law build overlapped my own runner call (frozen binary, no effect).
The fence list was read into a file by a program and never printed; every
tree-wide corpus scan was filtered on it first.
