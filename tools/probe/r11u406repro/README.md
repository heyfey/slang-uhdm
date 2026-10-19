# r11u406 — the module/type ground, third pass of the sv-tests campaign

Pass 406 (implementer), base 22bc000f7 (pass 404), the module/type ground (src/TypeEmit.cpp,
src/ModuleEmit.cpp, src/UhdmExporter.cpp; TaskFuncEmit.cpp and uhdm_main.cpp untouched).
Every law below reads its own switch through src/LawSwitch.h (`lawOn(406, "R11U406_<LAW>_OFF")`);
`R11U406_OFF=1` drops all of them; `R11U406_TRACE=<dir>` logs each firing (`lawTrace(406, ...)`).
No src/R*.h, no LawState.h section, no getenv, include/ unchanged.

## Result

sv-tests, against the base 22bc000f baseline (results/golden_svtests.csv of the base):
**regressions 0, conversions 21, changes 0** (EQUAL 1534 -> 1555, DIFFERENT 390 -> 370,
SURELOG_ONLY 83 -> 82; BOTH_REJECT 303, SLANG_ONLY 19, STRICT_NOTEQUAL 8, SURELOG_CRASH 8,
TIMEOUT 1 unchanged, of 2346). Every corpus gate unchanged: probe EQUAL 4018 + STRICT_NOTEQUAL 69
(0/0/0), surelog 480 + 0 / 474 + 0 (0/0/0), uhdm2rtlil 803/1/67 both modes (0/0/0), downstream
IDENTICAL 803 / EQUIVALENT 2 / SLANG_REJECT 66 (0 not excused).

| sv-tests row | before -> after | law |
|---|---|---|
| generic/typedef/typedef_test_13.sv | SURELOG_ONLY (`typedef target: AssociativeArrayType`, exit 4) -> EQUAL | § unitAssocTdMultiDim406 + § assocIdxParamBoundTs406 |
| chapter-16/16.2--assert-final.sv, assert0, assume-final, assume0, cover-final, cover0 | DIFFERENT -> EQUAL (6) | § deferredAssertItemDropped406 |
| chapter-16/16.7--sequence.sv | DIFFERENT -> EQUAL | § sequenceDeclListed406 |
| chapter-16/16.9--sequence-cons-repetition.sv, -goto-repetition, -noncons-repetition | DIFFERENT -> EQUAL (3) | § sequenceDeclListed406 + § seqConcatNestsRight406 |
| chapter-5/5.8-time-literals.sv, generated/integers/6.11--integer_time.sv | DIFFERENT -> EQUAL (2) | § timeModVarIsNet406 |
| generated/integers/6.11--integer_signed_time.sv, _unsigned_time | DIFFERENT -> EQUAL (2) | § timeModVarIsNet406 + § timeTsKeywordSpan406 |
| chapter-12/12.7.3--foreach.sv, 12.7.4--while.sv, 12.7.5--dowhile.sv | DIFFERENT -> EQUAL (3) | § arrElemVarKind406 |
| chapter-7/queues/bounded.sv, max-size.sv, slice.sv | DIFFERENT -> EQUAL (3) | § boundedQueueVarStatic406 |

The fresh rows (evidence/svtests_law.csv) read `<path>,EQUAL,,equal` for all 21.

Rows moved toward golden but still DIFFERENT (away census, below): chapter-16/16.10--sequence-local-var.sv
and -fail (90 -> 9 dump lines; head: the local variable `x` golden binds to an implicit net, sister
face 3), chapter-9/9.4.2.4--event_sequence.sv (77 -> 8; head: `@seq` event control, sister face 2),
chapter-5/5.9-string-word-assignment.sv (16 -> 10, byte_var element), generic/typedef/typedef_test_9.sv
(81 -> 40, the multi-dimension listing).

## Laws

1. **§ deferredAssertItemDropped406** (ModuleEmit, `R11U406_DEFERREDASSERT_OFF`; cases DA). A deferred
   immediate assertion written as a module, interface or generate item (`assert final (a);`,
   `l1: assume #0 (a);`, `cover final (b);`) is not in Surelog's database: CompileHelper::compileAssertionItem
   (third_party/Surelog/src/DesignCompile/CompileAssertion.cpp) compiles only paConcurrent_assertion_item and
   leaves the deferred branch a commented-out TODO. slang makes it a ProceduralBlockSymbol (syntax
   ImmediateAssertionMember) that every process listing wrote as `always` + `immediate_assert`. The check sits
   at every emitProcess caller of ModuleEmit (def view, generate region, elaborated instance, interface,
   generate scope, uninstantiated generate branch). Inside a procedural block the assertion is a statement
   and untouched (DA/da06).
2. **§ unitAssocTdMultiDim406** (TypeEmit buildUnpackedArrayTypedefTs + the $unit and module-body typedef
   branches in UhdmExporter / TypeEmit, `R11U406_TDMULTIDIM_OFF`; cases AT). A $unit or module-body typedef of an
   unpacked array with two or more written dimensions is ONE array_typespec spanning the element type through
   the FIRST dimension's `]`, one range per dimension in written order (each the one-dimension listing's range
   for its kind: size `[N]` -> `0 : N-1`, `[l:r]`, `[]`, `[$]`, `[*]`, `[<type>]` markers), the element reference
   onto the innermost element. The builder's fixed-size and kind-marker range code became two lambdas looped
   over the levels (single-dimension calls run the same code in the same order: byte movers 0 in every corpus).
   Also: an elaborated variable's copy folds every size-form range to an unlocated INT constant
   (`foldMultiDimCopy406`, AT/at09, at14, at16), the associative marker keeps its index reference in a range
   copy (copyRangeVec, AT/at15), and a multi-dimension listing whose innermost element is a typedef is bound
   by every use directly (AT/at06). Shape predicate `multiDimTdShape406` (every level fixed, dynamic,
   unbounded queue or associative with string / integer keyword / bit-logic-reg keyword / `[*]` index;
   innermost element not an unpacked array, integral when a typedef).
3. **§ assocIdxParamBoundTs406** (TypeEmit, the keyword-index bound maker of § assocTdIndexShapes402,
   `R11U406_ASSOCIDXPARAM_OFF`; cases AT/at02, at08, at20). A packed bound of an associative index keyword
   that names a value parameter: at $unit it folds at the parameter's width (32 for `parameter k = 6`, 4 for
   `parameter logic [3:0] w`) with an unnamed ref_typespec onto a fresh copy of the parameter's typespec
   (the written type at its tokens; an implicitly typed parameter an int_typespec spanning `parameter k = 6`);
   in a module body it stays a ref_obj (`work@top.a_t.k` in a multi-dimension listing, bare `k` in a
   one-dimension one, no actual).
4. **§ modAssocMarkerFullName406** (TypeEmit dyn-range builder, `R11U406_MODMARKERNAME_OFF`; AT/at19,
   at21). A module-body listing's associative marker names its index reference after the typedef's full path
   (`work@top.a_t`); pristine wrote the bare name (at21 `typedef int a_t [int];` was STRICT_NOTEQUAL
   fullname on pristine too).
5. **§ aliasElemDynTd406** (TypeEmit predicate `aliasElemDynTdShape406`, the $unit and module-body dynamic
   branches, the $unit use binder in UhdmExporter, `R11U406_ALIASELEMDYN_OFF`; cases AY; pass 402's VY/vy08,
   vy10). A typedef of a dynamic array or unbounded queue whose element is a typedef of an integral type
   (`typedef n_t q_t[$];`, `typedef myint_t d_t[];`) had no listing (exit 4); it is listed like the keyword
   shape, the element reference onto the element typedef's listing, and every $unit use binds the listing
   itself (no aliased definition copy, no bare elaborated copy).
6. **§ timeModVarIsNet406** (TypeEmit makeVar, `R11U406_TIMENET_OFF`; cases TM). A static `time` variable
   in a module body, declared without `var` and without an initializer, is a logic_net in the elaborated
   instance: NetlistElaboration::elabSignal (third_party/Surelog/src/DesignCompile/NetlistElaboration.cpp)
   starts every signal as a net and lists the integer atoms that make it a variable but not
   paIntegerAtomType_Time. Measured limits: `var time` stays a time_var (tm04), an interface or generate
   scope variable and an initialised one abstain (tm05, tm06, tm03: residues).
7. **§ timeTsKeywordSpan406** (UhdmExporter trimTypeSigning, `R11U406_TIMESPAN_OFF`; TM/tm02). A `time`
   typespec spans the keyword alone whatever signing follows (CompileType's paIntegerAtomType_Time branch:
   `populateCoreMembers(type, type, var)`).
8. **§ sequenceDeclListed406** (ModuleEmit def view + emitAssertionExpr, `R11U406_SEQDECL_OFF`; cases SQ).
   A module's named sequence declaration is a sequence_decl in the definition view (name span, full name
   `work@top.seq`), its body the vpiExpr (a clocked body a multiclock_sequence_expr at the body tokens
   holding one unlocated clocked_seq whose clocking event and sequence parent at the declaration), its
   formals seq_formal_decls (each spanning the whole formal list, a bare ref_typespec), body references scoped
   under the declaration and bound as a property body's (a formal mints its implicit net). A bare reference
   to it (`assert property (seq)`, `s3 |-> a`) is a ref_obj scoped under its context and bound to the
   declaration where we wrote a property_inst. A ranged delay `##[1:3]` inside a declaration body is a range
   operand at `1:3` (sq06).
9. **§ seqConcatNestsRight406** (ModuleEmit emitAssertionExpr SequenceConcat, `R11U406_SEQNEST_OFF`; SQ/sq03,
   sq10-sq12). In a sequence or property declaration body a concatenation of three or more elements is
   right-recursive: `[e0, ##d1, (e1 ##d2 ... en)]`, the tail one nested `##` operation spanning its elements
   (`b ##1 a[->2] ##1 b ##1 c[=1] ##1 d` -> `[b,1,[a',1,[b,1,[c',1,d]]]]`); two elements stay flat. Inline
   assertions are not reached by the gate (sq12 equal either way).
10. **§ arrElemVarKind406** (TypeEmit emitArrayVar, `R11U406_ARRELEMKIND_OFF`; cases SE). The element reg
    of a module-scope fixed-size unpacked array takes its own kind for string, real, shortreal, byte, shortint
    and longint elements (string_var, real_var, short_real_var, byte_var, short_int_var, long_int_var) where it
    fell to logic_var / int_var.
11. **§ boundedQueueVarStatic406** (TypeEmit emitDynArrayVar, `R11U406_BOUNDEDQ_OFF`; cases BQ). A
    module-scope bounded queue (`int q[$:2]`) is a vpiArrayType 1 array_var with the written range: at the
    brackets, left the `$` unbounded constant at the `$`, right the folded maximum at its tokens (size 64, the
    parameter's width when the bound names one, bq02).

## Grid (evidence/grid406.txt, drivers/grid406.sh)

63 case dirs in AT (21), AY (6), BQ (3), DA (8), SE (3), SQ (12), TM (10). Pristine (the base build,
md5 6ee88056d0a8447122ae3a598417db1f = the main tree's build/slang-uhdm) vs law
(md5 283350dabc3ac201906b83489f837973): 54 cases move in bytes, 51 enter STRICT_EQUAL (15 of them from
exit 4, at21 from STRICT_NOTEQUAL fullname), the 5 pristine-STRICT_EQUAL controls (at03, at11, at12, da06,
tm10) stay STRICT_EQUAL with pristine's bytes, none leaves. `R11U406_OFF=1` gives
pristine's bytes on 63 of 63; the switches of the laws each case's trace records, set together, give
pristine's bytes on 63 of 63; every case's own first-line law switch moves it (the controls and the
abstention residues inert). Still NOT_EQUAL under the law (residues, all NOT_EQUAL on pristine too):
AT/at18 (a module-body multi-dimension typedef USED by a variable: golden's definition net binds an aliased
copy), AY/ay06 (bounded queue typedef, still exit 4), DA/da07 (a generate region holding only a deferred
assertion: golden keeps an empty gen_region/begin), TM/tm03 (initialised `time t = 5`: golden a net with a
net-declaration cont_assign), tm05 (generate-scope `time`), tm06 (interface `time`), tm07 (`time a [2]`:
golden an array_net).

An intermediate build ran before the final one with identical output bytes on all 63 cases (the final
build only added trace lines and moved one trace label; the earlier law md5 b7fe41b0d65e7ba1d0a023cc1704b768
was never swept to completion: its sweep was stopped by its task id during the surelog stage and discarded).

## Gates (evidence/sweep_law_stages.txt, one five-stage sweep on the final law binary)

- probe: EQUAL 4018 STRICT_NOTEQUAL 69, regressions 0 conversions 0 changes 0.
- surelog: default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL standing), 0/0/0.
- uhdm2rtlil: 803/1/67 both modes, 0/0/0.
- downstream: IDENTICAL 803, EQUIVALENT 2, SLANG_REJECT 66, not excused 0.
- sv-tests: 0/21/0 against the base baseline (evidence/svtests_law_vs_base.txt, drivers/svcompare406.py,
  check_svtests.py's own rules). The stage ran the main tree's scripts/check_svtests.py read-only (a worktree
  has no UVM tree); pass 403 landed (30acad589) while it ran and moved that tree's baseline, so the stage
  printed 16 "regressions": exactly the 16 rows pass 403 promoted, none overlapping this pass's 21.
- byteverify (SELFCHECK=1) law vs the master's control /tmp/intr11u404: surelog 0 of 962, uhdm2rtlil 0 of
  1608, downstream 0 of 805 movers (each selfcheck flagging N-1 of N); probe: the raw files differ only
  because every probe database embeds its source path (worktree vs main tree), the normalised dump compare
  reads 4087 of 4087 identical with a positive control (evidence/byteverify_law.txt). Predicted movers: none
  (no corpus row or probe case holds a multi-dimension typedef, a deferred assertion item, a module
  sequence declaration, a module-scope plain `time` variable, a string/real/byte/shortint/longint array or
  a bounded queue in a judged position: each would have read NOT_EQUAL at the base); the corpus and probe
  bytes confirm it.
- canaries ok=52 / ok=16 changed 0, both ctcan2 checks PASS (evidence/canaries_law.txt).
- binary audit (fence-filtered path list): 5659 cmds.txt, 5609 name /tmp/r11u406_bin/law.bin, 0 another
  slang-uhdm binary, the rest Surelog-only rows (evidence/binary_audit.txt).
- away census, sv-tests (evidence/away_census_svtests.txt): the 247 non-UVM rows DIFFERENT or
  STRICT_NOTEQUAL at the base, pristine kept databases (targeted run) vs the law sweep's: 214 same distance,
  5 toward golden, 0 away, 28 not compared (20 converted rows whose database the runner deletes, and the 8
  STRICT_NOTEQUAL rows, strict verdicts unchanged). UVM rows: the law binary with R11U406_TRACE on
  uvm/uvm_files.sv (the 1800.2-2017 library) writes no trace (no law fires in the UVM package;
  evidence/uvm_trace.txt).
- determinism: no law reads an order or a container keyed on addresses; not separately drawn (the
  corpus bytes are identical to the control's).

## SURELOG_ONLY rows by message (goal 1)

Exporter messages: `typedef target: AssociativeArrayType` (typedef_test_13, converted here);
`statement kind: PatternCase` (12.6.1 case/casex/casez), `complex if condition` (12.6.2), `complex
conditional` (12.6.3) — the sister's StmtEmit/ExprEmit, converted by pass 403 meanwhile;
`expression kind: Invalid` (generated/tnoc/tnoc.sv) and `user function call`
(hdlconvertor_std2017_p728.sv) — the sister's. Every other SURELOG_ONLY detail is an upstream slang
diagnostic (`error: ...`): the should_fail tests and the five basejump clock rows (`design element does not
have a time scale defined but others in the design do`, reproduced with ~/.local/bin/slang on
bsg_clk_gen_osc with the same arguments).

## Residues (ranked by rows)

1. Class listings: 9 rows with an interface or parameterized class under the module (8.26.x), 8 in
   allClasses, 4 under the design, 3 design-level tasks/functions — not reached.
2. Basejump: about 37 rows first differ on a size cast by a default-less parameter (ref_typespec named after
   the parameter on the parameter: sister ground, ParamEmit), 7 rows on definitions § undefaultedDefInvalidInst404
   skips (decoded: bsg_dff_en_segmented's unpacked-array parameter `int widths_p[...]` makes the placeholder
   an invalid initializer; bsg_source_sync_channel_control_slave a reversed select from the placeholder width;
   test_bsg_comm_link_checker and bsg_scheduler_dataflow names slang cannot bind (`guts`, `bypass_lo`);
   bsg_nonsynth_mem_1rw_sync_assoc a nonblocking write to an associative element; bsg_nonsynth_ascii_writer
   a string conversion of the placeholder) — each a separate writer shape.
3. Time: realtime (chapter-6/6.12--realtime.sv: Surelog writes realtime as time_typespec / time_var,
   CompileType paNonIntType_RealTime; the real_typespec sites are spread over TypeEmit, UhdmExporter and
   ParamEmit, not written), initialised / interface / generate-scope / array `time` (TM/tm03, tm05-tm07).
4. Multi-dimension typedef uses in a module body (AT/at18), bounded queue typedefs (AY/ay06),
   p158's class-property bounded queue, a generate region left empty by a dropped deferred assertion (DA/da07).
5. Pass 402's VV/vv05 (module-body virtual-interface typedef, exit 4), VY/vy04, vy05, VU/vu09, vu10, VV/vv01
   not reached.
6. Carried: the named-event and associative-class implicit nets (15.5.1, 7/associative/class.sv, 8.8), the
   5.12 attributes, nettypes, interconnect, enum_sequence rows; passes 402/404 residue lists.

## Sister-ground faces (ExprEmit / EmitHelpers.h / StmtEmit / ParamEmit; reported, not written)

1. Size casts by a default-less parameter in basejump (ParamEmit: golden lists a ref_typespec named after the
   parameter on the parameter and an int_typespec named after it in the cast).
2. `@seq` event control naming a sequence (StmtEmit emitEventExpr: golden `event_control |vpiCondition
   ref_obj (work@seq_tb.seq)` bound to the sequence_decl; ours no condition) — 9.4.2.4 event_sequence.
3. A sequence's local variable (`int x;` in 16.10's sequence) golden binds to an implicit module net
   `work@top.x` (netType 1); ours leaves the reference unbound (the formal-reference binder in ExprEmit,
   emitPropFormalRef / propDeclScope lookup).
4. The class enum typespec / class_defn listings, the hierarchical reference `top.e` minting a net in an
   uninstantiated module (15.5.1) — the reference emitters.

## Process

- An intermediate law sweep was started, then stopped by its own task id after about ten minutes (only
  trace lines changed in the next build); its workdir was deleted and the full sweep rerun once on the final
  binary. No other process touched; pgrep checks before each launch read no live sweep.
- The SLIP: the first binary audit ran `grep` over the cmds.txt path list of the law sweep's corpus
  workdirs BEFORE filtering it on the fence line (10 of the 5669 paths name a fenced test; the files read
  were the harness's own command records, not test sources or databases); the audit was redone on the
  fence-filtered list and only that one is reported. No fenced test was dispatched, spelled in a case or
  read otherwise.
- The upstream-slang check of one basejump clock row ran ~/.local/bin/slang from scratch on sv-tests
  sources read-only. Nothing written outside /tmp/wt_r11u406 and /tmp/r11u406_*; third_party/, results/
  and the sv-tests checkout untouched.

## Drivers

drivers/grid406.sh (grid + switch audit), stat406.sh (one binary vs golden per case), r11u406_case.sh,
r11u406_pair.sh (kept sv-tests pair: strict head + dump diff), r11u406_run.sh (targeted runner rows),
r11u406_sweep.sh (the five stages), svcompare406.py (sv-tests rules vs a given baseline).
