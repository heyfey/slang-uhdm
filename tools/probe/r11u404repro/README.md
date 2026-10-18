# r11u404 — pass 404, module/type ground, the sv-tests campaign's second pass on this ground: § undefaultedDefInvalidInst404 (basejump's default-less definitions listed), § invalidCaAssignChild404, § macroArgParamOrder404, § pkgStructMemberSysArgBind404, § unknownModEmptyNamedConnPort404, § unknownModBitSelConnScope404, § seqMatchItemsDropped404, § unitParamXzLiteral404, § assocIdxSpanAtTokens404, § varInitOpCastKept404, § implicitNetDefLastRef404, § subrBuiltinClassArrElemUnsup404, § unknownModWildcardConnPort404

Pair B, base c51d5b5f4 (passes 401 and 402 landed). Production surface: src/UhdmExporter.cpp, src/ModuleEmit.cpp
and src/TypeEmit.cpp (TaskFuncEmit.cpp and uhdm_main.cpp untouched; include/UhdmExporter.h unchanged). Thirteen laws,
each read through src/LawSwitch.h as `lawOn(404, "R11U404_<LAW>_OFF")`; `R11U404_OFF` drops all thirteen and gives
pristine's bytes and exit code on every grid case (evidence/grid404.txt, last column); `R11U404_TRACE=<dir>` logs
each firing through `lawTrace(404, ...)`. No src/R*.h, no LawState.h section, no getenv and no reader function in
the added lines. Cross-function state is local: a `static std::deque<HierarchyOverrideNode>` and one parsed
placeholder syntax tree inside addDefOnlyModule.

- Pristine build md5 d90254f4ad18ac702ba763d6a8f7854b, equal to the main tree's build/slang-uhdm at the base.
- Law build (law7, the delivered patch's source) md5 ac78571fe2f25d30ae6026852f1467ca.
- Both binaries were frozen as chmod 555 copies under /tmp/r11u404_bin before the counted sweeps; both report
  slang 12.0.0+545f88b2e; every cmds.txt with a slang line names its own binary (evidence/binary_audit.txt, fence-filtered list).

## Verdict

GATES (law7; evidence/gates_law7.txt, byteverify_law7.txt, canaries_law7.txt, svtests_law7_stage.txt):

- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions 0, conversions 0, changes 0; byteverify 0 of 4087.
- surelog: default 480 + 0, testflags 474 + 0 CMP_EQUAL (954 of 954), regressions 0, conversions 0, changes 0;
  byteverify 0 of 962 (one fenced row-pair included in the byte compare, as the gate dispatches it; its csv verdict
  unchanged).
- uhdm2rtlil: 803/1/67 in both modes, regressions 0, conversions 0, changes 0; byteverify 0 of 1608.
- downstream: IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, the verdict column identical to the
  pristine sweep on 871 of 871; byteverify 0 of 805.
- sv-tests: **regressions 0, conversions 302, changes 0** (check_svtests.py against results/golden_svtests.csv):
  EQUAL 1240 -> 1534, STRICT_NOTEQUAL 20 -> 8, DIFFERENT 668 -> 390, SURELOG_ONLY 87 -> 83, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8 and TIMEOUT 1 unchanged, of 2346. The pristine stage on the same machine reads the
  baseline exactly (0/0/0, evidence/svtests_pristine_stage.txt). Every one of the 302 movers is attributed to the
  laws its own trace fired (evidence/svtests_law7_attributed.txt, 0 movers without a firing).
- The laws fire on no corpus row except Gates d/t (§ implicitNetDefLastRef404, 6 firings each, bytes identical: the
  materializing reference it computes is where pristine already put those nets); two trace files belong to a
  fenced row-pair and are dropped unread by the census's fence filter (that pair's bytes are identical by
  byteverify and its csv verdict is unchanged); evidence/census_corpus_law7.txt, evidence/census_svtests_law7.txt.
- Canaries ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil); ctcan2 PASS on both csvs.
- Determinism: three concurrent draws of MiniAmiq default, SeqDriver testflags and Earlgrey_0_1 default with the
  law binary read one hash each, equal to the sweep's database (evidence/determinism_law7.txt).


## The laws

Every law's site is found by `grep -n '§ <name>' src`; the switch is the environment variable.

1. **§ undefaultedDefInvalidInst404** (R11U404_UNDEFPARAMDEF_OFF; UhdmExporter.cpp, addDefOnlyModule). A module
   definition with a value parameter that has NO default (basejump's `` `BSG_INV_PARAM(p) `` under Surelog's define
   set expands to a bare `p`) is still a parsed module for Surelog: golden lists its definition in uhdmallModules
   (the parameter with no value, its param_assign with no rhs; the writer already gives a default-less parameter that
   shape), whether it is unreferenced or reached only from the `if (0)` block of a `<name>__abstract` wrapper. Ours
   skipped every such definition (`allDefaulted` gate). The law builds the definition's instance through slang's
   hierarchy-override node with a placeholder initializer EXPRESSION (`8`, from a parsed one-line module) for each
   undefaulted value parameter; a pre-evaluated value would leave an implicitly typed parameter's type unresolved and
   every width it sets invalid (the first cut, a ConstantValue override, left `[w_p-1:0]` ports rangeless and the
   continuous assigns Invalid). It abstains on an undefaulted TYPE parameter (UD/ud02) and when the placeholder
   body holds an expression or statement slang could not bind at all (an undeclared name read in the
   uninstantiated body: UD/ud03, and on sv-tests generated/basejump bsg_scheduler_dataflow, bsg_dff_en_segmented,
   bsg_nonsynth_ascii_writer, bsg_nonsynth_mem_1rw_sync_assoc, bsg_source_sync_channel_control_slave and
   test_bsg_comm_link_checker, whose rows therefore stay where they were). Cases UD/ud01-ud04, MO/mo01.
2. **§ invalidCaAssignChild404** (R11U404_CAINVALID_OFF; ModuleEmit.cpp, emitContAssigns). slang wraps a
   continuous assignment it could not type in an uninstantiated body (`assign set = {els_p {w}} & a;` with a
   parameter it cannot know) in an Invalid expression around the Assignment it built; Surelog writes the cont_assign
   from the text. The law emits the wrapped Assignment (an Invalid with no Assignment child abstains). This is the
   `continuous assign form` rejection of generated/basejump/bsg_mem_BaseJumpSTL_bsg_mem_1r1w_sync_from_1rw_sync.sv
   and of the seven bsg_cache/bsg_async rows the first cut of law 1 had pushed to SURELOG_ONLY. Cases CA/ca01
   (moving), CA/ca02 (the defaulted control, unmoved).
3. **§ macroArgParamOrder404** (R11U404_MACROARGORDER_OFF; UhdmExporter.cpp, srcOrderLess). A declaration whose name
   token came in as a MACRO ARGUMENT (`` parameter `BSG_INV_PARAM(lg_size_p) ``) sits in the source where the argument
   was written; Surelog lists it there. srcOrderLess compared the expansion-buffer location, so such parameters were
   listed after every physical one (golden bsg_async_fifo `lg_size_p, width_p, control_width_p, ...`, ours the two
   last). A location that is a macro argument is now compared at its fully original location; an expansion-body
   token keeps its macro-buffer location; the trace fires only where the answer differs. Cases MO/mo01 (with law 1),
   MO/mo02 (an instantiated, defaulted module: pristine NOT_EQUAL, law STRICT_EQUAL).
4. **§ pkgStructMemberSysArgBind404** (R11U404_PKGMEMBERSYSARG_OFF; TypeEmit.cpp, the sys-call argument fallback of
   the syntax-expression emitter). A query-call argument naming a parameter of the SAME package, inside a
   packed-struct MEMBER range of that package's listing that keeps the call (`logic [$clog2(num_rows_p)-1:0] ro;` in
   bsg_dramsim3_pkg's dram_ch_addr_s, the copy built with the top-view flag set): golden binds the ref_obj to the
   parameter's Rhs constant (`vpiActual constant 23:28`), ours left it unbound. This was the FIRST uhdm-cmp head of
   every basejump row (`lhsPath: design(work@top) > package(bsg_dramsim3_hbm2_8gb_x128_pkg) > param_assign >
   constant`, results/svtests/decode.csv), since every basejump test compiles bsg_dramsim3_pkg.sv. Cases PS/ps01,
   ps02, ps03 (the whole dramsim3 package file, pristine NOT_EQUAL, law STRICT_EQUAL 2254 objects).
5. **§ unknownModEmptyNamedConnPort404** (R11U404_UNKEMPTYCONN_OFF; ModuleEmit.cpp, the UninstantiatedDef ref_module
   stub). An instance of a module with NO definition in the compile keeps an explicitly empty named connection
   `.O()` as a port with no name, spanning `.O()`, no High_conn (golden bsg_async_credit_counter's
   `.w_ptr_binary_r_o()` to the absent bsg_async_ptr_gray), and an IMPLICIT `.O` as a port NAMED O with no High_conn
   (golden bsg_1_to_n_tagged_fifo's `.clk_i`, `.reset_i`). Ours dropped both. Cases UE/ue01, ue04 (the defined-child
   control, unmoved), ue05.
6. **§ unknownModBitSelConnScope404** (R11U404_UNKBITSELSCOPE_OFF; same site). On such a stub a BIT-SELECT actual is
   scoped under the instance alone (`.d(q[1])` -> bit_select `work@child.s.q`), where a part select, a ref or an
   operation operand keeps the formal (`work@child.s.e.r`). Cases UE/ue02, ue03.
7. **§ seqMatchItemsDropped404** (R11U404_SEQMATCH_OFF; ModuleEmit.cpp, emitAssertionExpr). `(seq, x = e)`: Surelog
   keeps the sequence expression alone (golden 16.10's implication first operand is the ref_obj `valid`; the match
   item's assignment is built but listed nowhere). The law emits the inner sequence; a repetition on the
   parenthesized match abstains. It removes the `assertion expr kind: SequenceWithMatch` rejection (exit 4 -> 0).
   Cases SM/sm01, sm02 (still NOT_EQUAL: see the residues).
8. **§ unitParamXzLiteral404** (R11U404_UNITXZ_OFF; UhdmExporter.cpp, the $unit parameter encoder). A $unit
   parameter initialized by an unbased unsized literal keeps the fill bit uppercased as a BIN value (`'X`/BIN:X,
   `'0`/BIN:0, `'Z`/BIN:Z at the declared width; untyped: size -1 and no parameter typespec), except a TYPED `'1`,
   reduced to the all-ones UINT of the declared width (int 4294967295, logic [3:0] 15); a based literal with x/z
   digits gets a value at all (the branch required `!hasUnknown`), and a ONE-bit `x` digit is uppercased in value and
   decompile (`1'bX`; a one-bit z and multi-bit x/z keep the written case), as the module-scope branch already does.
   Golden generic/number/number_test_2, _10, _11. Cases UX/ux2, ux10, ux11, ux21 (moving to STRICT_EQUAL), ux20
   (moving; its remaining difference is the module-scope elaborated size of `parameter int ma = 1'bx`, sister ground).
9. **§ assocIdxSpanAtTokens404** (R11U404_ASSOCIDXSPAN_OFF; TypeEmit.cpp, the instance-level array_var associative
   index typespec). The index typespec spans the index's own tokens, not the bracket interior with its blanks
   (golden `int arr [ int ];` int_typespec 2:11-2:14, ours 2:10-2:15), as the subroutine-local site already reads the
   selector's range. The 14 chapter-7 associative STRICT_NOTEQUAL rows. Cases AI/ai01, ai02.
10. **§ varInitOpCastKept404** (R11U404_VARINITOP_OFF; ModuleEmit.cpp, the elaborated variable-initializer chain).
    A BINARY-operation or explicit-CAST variable initializer keeps its unfolded expression as the var's vpiExpr
    (the chain had no branch and wrote none), and adjustSize runs over the root operation's own constant operands
    against the variable's width with the split of § varInitConcatOperandAdjustSize (UINT masked, BIN truncated only
    when wider, DEC untouched, the rest re-sized: `byte f = 300 - 1` -> 44/8 and 1/8; `int c = 3 * 4 + 2` -> the 2 at
    32, the nested 3 and 4 at 64). Cases VI/vi01-vi03, vi06 (STRICT_EQUAL), vi04, vi05 (residues).
11. **§ implicitNetDefLastRef404** (R11U404_IMPNETLASTREF_OFF; UhdmExporter.cpp, a post-pass over defMap before
    § ifacePortViewAggregateFlattens). The DEFINITION-view net of an implicit net sits at the first reference that
    MATERIALIZES it in Surelog's definition compile: a named port connection, a terminal of a NAMED logic gate, an
    INPUT terminal of an unnamed logic gate, a continuous assignment or procedural code; an ordered port
    connection, an unnamed logic gate's OUTPUT terminal, a pullup/pulldown terminal and a net-declaration
    initializer only mention it. A UDP instance's terminals read like a gate's (named: materializes; unnamed: the
    output terminal does not; p835 `dff1 g1 (qi, clk, d);` keeps qi at g1, IN/in09, in10). The elaborated view keeps the first occurrence. The listing then orders the
    implicit nets by that location (only where one moved). The name records the first measured cells (p597, 6.10,
    p628, where the materializing reference is also the last); the Gates corpus row (`not (a_inv, A); and (y0, c0,
    a_inv, b_inv); and (y1, c1, a_inv, B);` -> golden 92:12, the FIRST `and`) and hier_undriven_port / ExplicitPorts
    (a named connection keeps its first) refuted the last-reference draft, see the process notes. Cases IN/in01-in08.
12. **§ subrBuiltinClassArrElemUnsup404** (R11U404_BUILTINCLASSELEM_OFF; TypeEmit.cpp, stmtScopeTdDegrades155 and
    makeStmtScopeTdUnsupTs155). The ELEMENT of a declarator array declared in a SUBROUTINE body whose element type is
    a built-in class (`process job[] = new [N];`, `mailbox m[$]`, `semaphore s[3]`): golden's element variable is a
    `ref_var` with an `unsupported_typespec (process)` at the type's tokens, the placeholder § blockLocalTdDeclIs-
    RefVarUnsupported155 builds for a statement-scope typedef; a user class or a scalar `process p;` resolves.
    Golden chapter-9/9.7--process_cls_*.sv (four rows). Cases BC/bc01 (STRICT_EQUAL), bc02, bc03 (residues).

13. **§ unknownModWildcardConnPort404** (R11U404_UNKWILDCONN_OFF; the ModuleEmit stub site of laws 5 and 6). A `.*`
    on an instance of a module with no definition is a port with no name spanning the `.*`, its High_conn a constant
    whose decompile and STRING value are the text `.*`, no size and no constant type (golden
    generated/basejump bsg_mem_1r1w, 2r1w, 3r1w: `bsg_mem_1r1w_synth ... synth (.*);`, the synth module absent from
    the compile). Case UE/ue06.

## The grid

45 case dirs in 12 groups under cases/ (AI, BC, CA, IN, MO, PS, SM, UD, UE, UX, VI), each `dut.sv` naming its law on
its first line; goldens from the pinned Surelog (`-parse -sverilog`, `--top-module top` when the case declares a
module `top`, the same top for slang-uhdm), drivers/grid404.sh, evidence/grid404.txt (law7):

- 38 cases move, 27 enter STRICT_EQUAL, none leaves (the three pristine-EQUAL controls CA/ca02, IN/in07, UE/ue04 stay
  STRICT_EQUAL and unmoved; UD/ud02, ud03 are the abstention controls, unmoved; IN/in10 and VI/vi05 unmoved
  controls).
- `R11U404_OFF` gives pristine's bytes and exit code on 45 of 45.
- Every moving case is restored to pristine's bytes by its own law's switch (evidence/switch404.txt) except six that
  need the set of laws they combine, each restored by that set (evidence/switch404_sets.txt): CA/ca01, MO/mo01 and
  UE/ue01 with R11U404_UNDEFPARAMDEF_OFF (their definition is listed only by law 1), UE/ue02 and ue06 with
  R11U404_UNKEMPTYCONN_OFF (they also hold an empty or implicit connection), UE/ue03 with both.
- Still not equal after the law (each named under the residues): AI/ai02 (`[ bit [7:0] ]` index), BC/bc02, bc03,
  IN/in04, in09, in10 (other faces, pristine too), PS/ps02 (endcol of a folded `$clog2(m)` bound), SM/sm01, sm02
  (the property-local variable, sister ground), UD/ud02-ud04, UX/ux20 (module-scope elaborated size, sister), VI/vi04,
  vi05.

| case | law | pristine | law7 |
|---|---|---|---|
| AI/ai01 | § assocIdxSpanAtTokens404 | rc=0 STRICT_NOTEQUAL col | rc=0 STRICT_EQUAL (172 objects) |
| AI/ai02 | § assocIdxSpanAtTokens404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| BC/bc01 | § subrBuiltinClassArrElemUnsup404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (197 objects) |
| BC/bc02 | § subrBuiltinClassArrElemUnsup404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| BC/bc03 | § subrBuiltinClassArrElemUnsup404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| CA/ca01 | § invalidCaAssignChild404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (129 objects) |
| CA/ca02 | § invalidCaAssignChild404 | rc=0 STRICT_EQUAL | rc=0 STRICT_EQUAL (134 objects) |
| IN/in01 | § implicitNetDefLastRef404 | rc=0 STRICT_NOTEQUAL line | rc=0 STRICT_EQUAL (255 objects) |
| IN/in02 | § implicitNetDefLastRef404 | rc=0 STRICT_NOTEQUAL line | rc=0 STRICT_EQUAL (186 objects) |
| IN/in03 | § implicitNetDefLastRef404 | rc=0 STRICT_NOTEQUAL line | rc=0 STRICT_EQUAL (171 objects) |
| IN/in04 | § implicitNetDefLastRef404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| IN/in05 | § implicitNetDefLastRef404 | rc=0 STRICT_NOTEQUAL line | rc=0 STRICT_EQUAL (223 objects) |
| IN/in06 | § implicitNetDefLastRef404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (231 objects) |
| IN/in07 | § implicitNetDefLastRef404 | rc=0 STRICT_EQUAL | rc=0 STRICT_EQUAL (258 objects) |
| IN/in08 | § implicitNetDefLastRef404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (214 objects) |
| IN/in09 | § implicitNetDefLastRef404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| IN/in10 | § implicitNetDefLastRef404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| MO/mo01 | § macroArgParamOrder404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (143 objects) |
| MO/mo02 | § macroArgParamOrder404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (170 objects) |
| PS/ps01 | § pkgStructMemberSysArgBind404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (154 objects) |
| PS/ps02 | § pkgStructMemberSysArgBind404 | rc=0 NOT_EQUAL | rc=0 STRICT_NOTEQUAL endcol |
| PS/ps03 | § pkgStructMemberSysArgBind404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (2254 objects) |
| SM/sm01 | § seqMatchItemsDropped404 | rc=4 NOT_EQUAL | rc=0 NOT_EQUAL |
| SM/sm02 | § seqMatchItemsDropped404 | rc=4 NOT_EQUAL | rc=0 NOT_EQUAL |
| UD/ud01 | § undefaultedDefInvalidInst404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (150 objects) |
| UD/ud02 | § undefaultedDefInvalidInst404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| UD/ud03 | § undefaultedDefInvalidInst404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| UD/ud04 | § undefaultedDefInvalidInst404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| UE/ue01 | § unknownModEmptyNamedConnPort404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (126 objects) |
| UE/ue02 | § unknownModBitSelConnScope404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (146 objects) |
| UE/ue03 | § unknownModBitSelConnScope404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (193 objects) |
| UE/ue04 | § unknownModEmptyNamedConnPort404 | rc=0 STRICT_EQUAL | rc=0 STRICT_EQUAL (169 objects) |
| UE/ue05 | § unknownModEmptyNamedConnPort404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (117 objects) |
| UE/ue06 | § unknownModWildcardConnPort404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (122 objects) |
| UX/ux10 | § unitParamXzLiteral404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (100 objects) |
| UX/ux11 | § unitParamXzLiteral404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (100 objects) |
| UX/ux2 | § unitParamXzLiteral404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (100 objects) |
| UX/ux20 | § unitParamXzLiteral404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| UX/ux21 | § unitParamXzLiteral404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (170 objects) |
| VI/vi01 | § varInitOpCastKept404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (105 objects) |
| VI/vi02 | § varInitOpCastKept404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (102 objects) |
| VI/vi03 | § varInitOpCastKept404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (145 objects) |
| VI/vi04 | § varInitOpCastKept404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| VI/vi05 | § varInitOpCastKept404 | rc=0 NOT_EQUAL | rc=0 NOT_EQUAL |
| VI/vi06 | § varInitOpCastKept404 | rc=0 NOT_EQUAL | rc=0 STRICT_EQUAL (161 objects) |


## sv-tests: the rows that move (results/golden_svtests.csv -> law7)

302 conversions, 0 regressions, 0 changes (evidence/svtests_law7_movers.txt; per-row laws in
evidence/svtests_law7_attributed.txt). The runner was check_svtests.py from the main tree, read-only (a worktree has
no UVM tree under third_party), with SLANG_UHDM and SVTESTS_ROOT exported, never while another sweep's sv-tests stage
ran.

GOAL 1 (exporter rejections of suite-legal tests upstream slang accepts):

| row | before -> after | laws |
|---|---|---|
| generated/basejump/bsg_mem_BaseJumpSTL_bsg_mem_1r1w_sync_from_1rw_sync.sv | SURELOG_ONLY (`continuous assign form`) -> EQUAL | invalidCaAssignChild404 + the basejump laws |
| chapter-16/16.10--property-local-var.sv | SURELOG_ONLY (`assertion expr kind: SequenceWithMatch`) -> DIFFERENT | seqMatchItemsDropped404 |
| chapter-16/16.10--property-local-var-uvm.sv | SURELOG_ONLY -> DIFFERENT | seqMatchItemsDropped404 |
| chapter-16/16.10--property-local-var-fail.sv (should_fail 1; Surelog accepts it) | SURELOG_ONLY -> DIFFERENT | seqMatchItemsDropped404 |

The three 16.10 rows now first differ on the property-local variable (sister face 3 below). Still rejected on this
ground: generic/typedef/typedef_test_13.sv (`typedef target: AssociativeArrayType`, residue 2). The rest of the
SURELOG_ONLY detail column, by message: `statement kind: PatternCase` (chapter-12/12.6.1 case, casex, casez),
`complex if condition` (12.6.2), `complex conditional` (12.6.3) and `user function call`
(generated/hdlconv_std2017/hdlconvertor_std2017_p728.sv) are the sister's (StmtEmit / ExprEmit);
generated/tnoc/tnoc.sv `expression kind: Invalid` is the sister's (sister face 1); every other SURELOG_ONLY or
BOTH_REJECT detail is an upstream slang diagnostic (`error: ...`, from the should_fail tests and from the five
basejump clock-generator rows' `design element does not have a time scale defined`), not the exporter's.

GOAL 2 (both accepted):

- BASEJUMP: 268 rows DIFFERENT -> EQUAL and 5 DIFFERENT -> STRICT_NOTEQUAL, plus the bsg_mem row above (274 of the 360
  basejump rows move; the tier now reads EQUAL 269, STRICT_NOTEQUAL 5, DIFFERENT 81, SURELOG_ONLY 5, where it read
  DIFFERENT 354 and SURELOG_ONLY 6). Laws, by
  the number of moving rows whose trace fired them: § pkgStructMemberSysArgBind404 (every basejump row: it was the
  first uhdm-cmp head of all 354), § undefaultedDefInvalidInst404 (the 313-row "definitions missing from allModules"
  cluster), § macroArgParamOrder404 (the default-less parameters' order), § unknownModEmptyNamedConnPort404 /
  § unknownModBitSelConnScope404 / § unknownModWildcardConnPort404 (definitions instantiating modules absent from
  the compile), § invalidCaAssignChild404. The 31-row "unreferenced typespec order" cluster was not a judged
  difference: the tail order of the weakly referenced package typespecs differs from golden in every basejump row
  that is now EQUAL (uhdm-cmp and the strict walk never read it); its rows moved with the package-member binding.
  The five new STRICT_NOTEQUAL rows: bsg_clk_gen bsg_dram_clk_gen (fullname, 138 objects), bsg_dmc_phy (col, 8),
  bsg_link_ddr_downstream (col, 2), bsg_crossbar_control_locking_o_by_i (col, 1), bsg_idiv_iterative (col, 8).
- The 14 chapter-7/arrays/associative rows (alloc, assignment, integral, nonexistent, string, methods/delete,
  exists, first, last, next, num, prev, size, traversal) STRICT_NOTEQUAL (col) -> EQUAL: § assocIdxSpanAtTokens404.
- generic/number/number_test_2.sv, _3, _10, _11 DIFFERENT -> EQUAL: § unitParamXzLiteral404.
- chapter-6/6.24.1--cast_op.sv, 6.24.3--bitstream_cast.sv, chapter-5/5.6.4--compiler-directives-preprocessor-macro_1.sv
  DIFFERENT -> EQUAL: § varInitOpCastKept404.
- chapter-6/6.10--implicit_port_connection.sv, generated/hdlconv_std2017/hdlconvertor_std2017_p597.sv, p628
  STRICT_NOTEQUAL (line) -> EQUAL: § implicitNetDefLastRef404.
- chapter-9/9.7--process_cls_self.sv DIFFERENT -> EQUAL: § subrBuiltinClassArrElemUnsup404 (the other three 9.7 rows
  move toward golden and next differ on the foreach loop variable, sister face 7).

Rows where a law fired and the status did not move (93: 87 DIFFERENT, 6 SURELOG_CRASH where only the slang side
ran): the away census over the 87 DIFFERENT ones, golden-vs-ours normalised dump diff lines on pristine against law7
(evidence/away_census_law7.txt), reads 84 toward golden (365538 lines less in all), 3 unchanged (p230, p737, p884:
the law fires and writes what pristine wrote) and 0 away. On the law6 binary the census read one away row,
generated/hdlconv_std2017/hdlconvertor_std2017_p835.sv (+8 lines): its implicit net `qi` of the named UDP instance
`dff1 g1 (qi, clk, d);` was moved by the gate-only draft of § implicitNetDefLastRef404, where golden keeps it at g1
(a UDP instance's terminals read like a gate's); law7 puts p835 back on pristine's bytes for that net (IN/in10).

## Residues on this ground, ranked by sv-tests rows

1. **The 81 basejump rows still DIFFERENT** (evidence/basejump_remaining_heads.txt, first changed dump line per row):
   6 first differ at the definition law 1 abstains on (below); 25 first differ at a default-less parameter's typespec and 5 at a cast typespec, both the size-cast face of
   sister face 4; 9 at a localparam's typespec in a default-less definition (bsg_permute_box `lg_items_lp`: ours
   writes an int_typespec, golden none; the placeholder value reaches ParamEmit's typed-local test); 8 at a constant
   (sister face 6); 3 at a struct member's ref_typespec vpiRefLineNo inside a macro-declared struct typedef
   (bsg_cache_non_blocking_data_mem: golden the member's line, ours the macro's use line; TypeEmit); the rest are
   singletons (a part select's full name, a gate's vpiNetType, an operand kind). Six definitions abstain from law 1 on
   an unbound statement (bsg_scheduler_dataflow, bsg_dff_en_segmented, bsg_nonsynth_ascii_writer,
   bsg_nonsynth_mem_1rw_sync_assoc, bsg_source_sync_channel_control_slave, test_bsg_comm_link_checker): Surelog lists
   them; listing them needs the writer to emit what slang refuses to bind (an undeclared name read in a `$display`),
   which is sister ground. The placeholder value can leak where the def view reads a width: UD/ud04 `assign cnt =
   '0;` sizes the `'0` at 9 bits (the placeholder 8 + 1) where golden writes -1.
2. **generic/typedef/typedef_test_13.sv** (exit 4, `typedef target: AssociativeArrayType`, TypeEmit): decoded, not
   landed. Golden lists one array_typespec spanning the typedef through its FIRST dimension with one range per
   dimension, each `0 : "associative"` whose marker carries a ref_typespec named after the typedef onto the index's
   bit_typespec; the index bounds that read `$unit` parameters fold to size-32 constants carrying an unnamed
   ref_typespec onto an int_typespec spanning the whole parameter statement (`parameter k = 6;`, 2:1-2:16) that the
   ref_typespec parents; the element is a ref onto the typedef'd `data_t`. Also pass 402's VY/vy05, vy08, vy10 and
   VV/vv05 (still exit 4) were not reached.
3. **Five new STRICT_NOTEQUAL basejump rows** (fullname 138 on bsg_dram_clk_gen, col on four): not decoded.
4. **chapter-5/5.6.4--compiler-directives-debug-line.sv** (STRICT_NOTEQUAL endline): golden's module end line is the
   physical line, ours the `` `line ``-mapped one (1 instead of 6); the two chapter-22/22.12 `` `line `` rows are
   EQUAL, so the rule needs a grid before it is written.
5. **9.7 rows and builtin-class arrays**: BC/bc02 (a module-scope `process ma[];` and `p1 = process::self()` binding to
   an implicit net, the latter statement ground), BC/bc03 (a function-local `process p6[];` listed by golden both as a
   ref_var and as an array_var among the function's variables).
6. **Variable initializers**: VI/vi04 (`int f = -b;` golden keeps the unary op with its operand bound to the net
   view of `b`), VI/vi05 (chapter-5/5.9: `byte b[3:0] = "hi2"` golden a byte_var element with the string constant);
   generated/hdlconv_std2012/hdlconvertor_std2012_p148.sv and 5.9 stay DIFFERENT.
7. **IN/in04, in09**: the def-view net listing's other faces (a cont_assign target's actual, an unnamed UDP's full
   name `work@top.work@inv1`), pristine too.
8. **AI/ai02**: an associative index written `[ bit [7:0] ]` (the index typespec's ranges), and **PS/ps02**: a folded
   `[$clog2(m):0]` bound's end column (golden the whole call).
9. Carried, not worked this pass: the 70 probe residues by writer, passes 319 and 402's residue lists (net kinds,
   AA/aa07, aa08, ae_enum, VV/vv01, VA/va04, VG/vg16, vg19, GP/gp11, the tagged union in a child module).

## Sister-ground faces (ExprEmit / EmitHelpers.h / StmtEmit / ParamEmit; reported, not written)

1. **generated/tnoc/tnoc.sv** (SURELOG_ONLY, `expression kind: Invalid`, raised in ExprEmit's Invalid branch next to
   § typeParamScopedCallRef59): casts through an interface-port typedef, `tnoc_common_header'(flit[...].data)` at
   tnoc_flit_if.sv:128 (3646 sites) and tnoc_packet_deserializer.sv:113 (18), and the type-parameter cast default
   `DATA_TYPE'(0)` at tbcm_demux.sv:6 and tbcm_selector.sv:6 (SLANG_UHDM_UNSUP_LOC=1 lists them).
2. **generated/hdlconv_std2017/hdlconvertor_std2017_p728.sv** (`user function call`, ExprEmit
   noteUnsupportedAt("user function call")): a $unit task calling a $unit function declared after it.
3. **chapter-16/16.10 property-local variable** (three rows, now DIFFERENT): golden resolves `x` in `(out == x + 4)` to
   an implicit logic_net work@top.x (vpiNetType 1) the module's definition lists (ExprEmit's implicitNetModule branch);
   golden also lists the property_decl's local `int_var (x)` parented by a weakly referenced assignment (ModuleEmit's
   def-view property_decl, this ground, not written while the row cannot reach EQUAL without the sister face).
4. **Size casts by a default-less parameter** (`wh_len_width_p'(1 + dma_burst_len_p)`, about 30 basejump rows): golden
   shares ONE int_typespec named after the parameter, located at the first cast's parameter token, carrying
   vpiExpr ref_obj `P.P` onto the parameter, as every such cast's typespec AND as the parameter's own typespec; ours
   writes an unnamed integer_typespec per cast (ExprEmit's cast branch) and no parameter typespec (ParamEmit's
   emitParameters).
5. **A module-scope typed parameter with a one-bit x literal** (UX/ux20 `parameter int ma = 1'bx`): the elaborated
   param_assign constant's size 32 where golden keeps 1 (ParamEmit; pass 401's known residue).
6. **Constants in default-less definitions** (8 basejump rows): a `'0` parameter default decompiled `'b0` (golden
   `'0`, bsg_cache_dma `amo_support_level_none_lp`), a macro-named bound `` `bss_max_block `` written as a ref_obj
   (golden the folded constant, bsg_sync_sync).
7. **The foreach loop variable** as an implicit net (9.7--process_cls_kill, _await, _suspend_resume; the same face as
   the UVM rows' uvm_init::idx, StmtEmit).

## Process

The draft laws that the gates refuted, in order:

1. **§ pkgViewsInterleaved404 (withdrawn).** The first reading of the basejump tail said Surelog builds a package's
   two views before the next package (the weakly referenced typespecs list p1, p1', p2, p2', ...), and the law emitted
   the def and top view package by package. Its law sweep read probe 15, surelog 8 and uhdm2rtlil 10 regressions
   (multi-package UVM and BlackParrot rows, ibex_tracer, rp32 rows), every one attributed by trace to that law alone,
   and dropping it left pk1 (now PS/ps03) STRICT_EQUAL: the tail order is not judged and the package-member binding
   (§ pkgStructMemberSysArgBind404) was the whole head. Removed from the patch.
2. **§ implicitNetDefLastRef404, the last-reference draft.** Read off p597, 6.10 and p628 (where the materializing
   reference is also the last); its law sweep read surelog 4 (ExplicitPorts d/t, Gates d/t) and uhdm2rtlil 4
   (hier_undriven_port d/t, mriscv_bind_sva d/t) regressions, all line fields of implicit nets. The rule was re-decoded
   on those rows and on IN/in04-in08 (named vs ordered connections, named vs unnamed gates, pull gates, net
   declaration initializers) into the materializing-reference rule; the refined law reads 0 in every stage and the
   four rows byte-identical to pristine. The sv-tests away census of the next binary found p835 (a UDP instance),
   which law7 fixes; that binary's sweep is the one this README reports.
3. **§ undefaultedDefInvalidInst404's first cuts**: createInvalid (every parameter null) and a pre-evaluated
   placeholder value left the widths unresolved and the continuous assigns Invalid, pushing seven DIFFERENT basejump
   rows to SURELOG_ONLY on a 41-row run (never on a gate sweep); the expression placeholder fixed them. A
   bsg_scheduler_dataflow regression (DIFFERENT -> SURELOG_ONLY, `expression kind: Invalid`, an undeclared name read
   in the listed definition) on the 423-row target run became the unbound-body abstention.

The binaries measured: pristine d90254f4ad18ac702ba763d6a8f7854b (equal to the main tree's build); law7
ac78571fe2f25d30ae6026852f1467ca. Workdirs /tmp/r11u404_wdP (pristine) and /tmp/r11u404_wdL (law7), same-length
names for byteverify. The drivers in drivers/ are the ones run: grid404.sh and switch404.sh (the grid), r11u404_run.sh
(the sv-tests runner on a list, with R11U404_TRACE), r11u404_pair.sh (strictcmp + normalised dump diff of a kept
pair), r11u404_tracemap.sh (the fence-filtered trace census), r11u404_sweep.sh (the five-stage sweep, its sv-tests
stage waiting until no other sweep runs), r11u404_case.sh (one case against its golden).

SLIPS, none affecting a measurement:

- Two `pkill -f` / `pgrep -f` patterns matched the shell running them (the shell was killed, nothing else); the
  stale sweeps were then stopped by PID with self-excluding patterns.
- The first trace census read the trace files with `grep -l` over the whole trace directory before the fence filter
  existed, so the one trace file written for a fenced row-pair (my own law's trace: an `OUT` line and the law name)
  was opened. No fenced source, database or log was opened; the sweep dispatched that row as the gate does. Every
  later census filters the file list on the FENCED= line first (drivers/r11u404_tracemap.sh), and this README names
  no fenced test.
- slang-uhdm was run three times with its working directory inside third_party (the mriscv_bind_sva re-check and the
  determinism draws, which must run in the row's source directory as verify_golden.py does); its output went to
  /tmp, and `git status` of both submodules read clean afterwards.
- The corpus stages of my sweeps ran while the sister pass's sweeps ran (jobs 3 each on 16 cores); every sv-tests
  stage of mine started only after no other sv-tests stage was running (the sweep driver waits on pgrep).
- Corpus test sources (Gates, ExplicitPorts, hier_undriven_port, p597, p628, p835) were copied into scratch to decode;
  the cases kept under cases/ are rewritten reductions (IN/in07 is Gates' mux module trimmed, in10 is p835).

