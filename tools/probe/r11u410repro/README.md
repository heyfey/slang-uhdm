# r11u410 — module/type ground, sv-tests campaign pass 410

Base 2aa103d1 (pass 408). Ground: src/TypeEmit.cpp, src/ModuleEmit.cpp,
src/UhdmExporter.cpp, src/TaskFuncEmit.cpp (uhdm_main.cpp, include/ and the
sister's ExprEmit/StmtEmit/ParamEmit/EmitHelpers.h untouched). Every law
reads `lawOn(410, "R11U410_<LAW>_OFF")` from src/LawSwitch.h,
`R11U410_OFF` drops the whole pass, `R11U410_TRACE=<dir>` logs each firing
through `lawTrace(410, ...)`. No src/R*.h, no getenv, no reader function.

Binaries: pristine (worktree build at the base, frozen copy, used only for
the case grid) md5 18a8b0bb50273c372eb97da9b304aa0c = main tree's
build/slang-uhdm at the base; law binary md5 7bdbdc7f885c6bd11cc2f74c8c1deb53
(the final law binary, frozen as /tmp/r11u410_scratch/law27.bin). The pristine
sweep reading is the master's control at the base, /tmp/intr11u408.

## Laws

| law | switch | file | what |
|---|---|---|---|
| § classBoundedQueueMultiDim410 | R11U410_CLSQMULTI_OFF | UhdmExporter.cpp (+ TypeEmit.cpp buildUnpackedRanges skip branch) | GOAL 1: a class property mixing a bounded queue `[$:N]` with fixed dims, or a fixed/bounded dim under an unsized one (`int q[$:3][2]`, `int r[2][$:3]`, `int s[$][2]`, `int d[2][]`) exited 4. Golden: one array_var; vpiArrayType 1 when no dim is unsized, else the first unsized dim's kind (queue 4, dynamic 2); vpiSize the product of the FIXED dims' counts; when the first unsized dim is outermost, one range per remaining written dim (a bounded queue's range as § classBoundedQueueStatic408 writes it) and the innermost element under vpiReg; when it is inner (last, integer-atom element measured), no range, no element, and an array_typespec of that kind whose element array_typespec holds the earlier dims' ranges over a bare atom typespec. Abstains on associative dims, a second unsized dim after a leading one, typedef-contributed dims. |
| § clsQBoundUntypedParamTs410 | R11U410_QBOUNDUNTYPED_OFF | UhdmExporter.cpp | a class bounded-queue bound naming an UNTYPED parameter (`parameter P = 3; int q[$:P];`) carries a reference named by the property to an unsigned int_typespec spanning the parameter declaration (pass 408's residue v11u408 VQ/vq01); a signed or ranged untyped parameter abstains (QU/qu03). Applies to the single-dim law of pass 408 and to the multi-dim one above. |
| § unitBoundedQTd410 | R11U410_BOUNDEDQTD_OFF | TypeEmit.cpp, UhdmExporter.cpp | GOAL 1: a $unit or module-body typedef of a bounded queue with a literal bound (`typedef int q_t [$:4];`, `typedef p_t q_t [$:4];`, r11u406 AY/ay06) exited 4 (`typedef target: QueueType`). Listed as the unbounded queue typedef of § unitDynArrTd249 / § aliasElemDynTd406, the one range the written `[$:N]` (brackets; `$` constant at the `$`; UINT size-64 bound at its token). A parameter bound abstains (AQ/aq09, still exit 4). |
| § dynTdAliasClone410 | R11U410_DYNTDALIAS_OFF | UhdmExporter.cpp ($unit), TypeEmit.cpp (module) | GOAL 1: a typedef NAMING a listed dynamic/queue/associative typedef (`typedef b_t c_t;`, v11u402 VY/vy05) exited 4. Golden: a clone of the named typedef's array_typespec (its span, ranges, element; the associative marker reference named by the new typedef) named by the new typedef, vpiTypedefAlias onto the named listing (module) or onto an unparented copy of the named typedef that itself aliases the listing ($unit). |
| § modVirtIfaceTd410 | R11U410_MODVIFTD_OFF | TypeEmit.cpp, UhdmExporter.cpp | GOAL 1: the module-body twin of § virtIfaceTd402 (`typedef virtual I vi_t;` in a module, v11u402 VV/vv05) exited 4. Listed as the interface_typespec the $unit branch builds; each definition variable typed by it binds its own copy (named by the typedef, its span, Instanced at the module, aliasing the listing) — golden's weakly-referenced copies, one per variable (VF/vf02: three). |
| § genLpUntypedDefNoTs410 | R11U410_GENLPNOTS_OFF | ModuleEmit.cpp | in the DEFINITION view a generate-block parameter with a BARE implicit type (no packed range, no signing) carries no typespec at all (golden GP gp01–gp06: a literal, a module-parameter fold, in a loop, an if, an instantiated or uninstantiated module); only a genvar-reading initializer had dropped it. `localparam [31:0] X` and `localparam signed X` keep it (gp07, golden bsg_mul_pipelined). |
| § parenCastNameUnsupTs410 | R11U410_PARENCASTNAME_OFF | TypeEmit.cpp (emitSyntaxExpr CastExpression) | a PARENTHESIZED name as the cast size in a syntax view (`(w) ' (x)` in a generate block) is golden's unsupported_typespec named by the inner identifier at its own span, as the bare `w'(x)` is; ours wrote the size-cast integer_typespec over an expression (pass 405's sister report, r11u405 SC/sc23, sc24). |
| § modStructMemberBitsTypeFold410 | R11U410_STRUCTBITS_OFF | TypeEmit.cpp | inside a MODULE-body packed struct typedef's member dimensions `$bits(<typedef name>)` folds to the type's width (UINT, size 64, at the call), as in a package typedef (pass 405's sister report, the basejump macro-declared struct). A keyword type argument abstains (`$bits(logic [3:0])`, golden UINT:1 at the name, SB/sb05). |
| § macroIncludeCol410 | R11U410_MACROINCCOL_OFF | UhdmExporter.cpp | an `include whose file name comes out of a macro: the include_file_info columns are Surelog's expanded-text columns: the name starts one past the directive keyword and its blanks (column 10 for one blank); it ends after the WRITTEN macro call when the directive is written in the file, after the substituted name when the directive is a macro body. |
| § classPropBasedLitKept410 | R11U410_CLSBASEDLIT_OFF | UhdmExporter.cpp | a BASED literal initializer of a class property keeps its written form: source text as decompile, the digits as written under BIN 3 / OCT 4 / DEC 1 / HEX 5, sized by the LITERAL for binary or decimal and by the PROPERTY for octal or hex; a signed hex literal adds a reference named by the property to an unlocated signed int_typespec. Unsized binary/decimal, underscores, x/z and signed non-hex abstain. |
| § unitTdClassPropAliasName410 | R11U410_UNITCLSPROPALIAS_OFF | UhdmExporter.cpp | a CLASS PROPERTY's copy of a $unit typedef is parented at the property and its alias reference named `<property>::<typedef>`, the $unit twin of § clsPropLawSAliasName243. |
| § unitScalarTdAliasChain410 | R11U410_UNITALIASCHAIN_OFF | UhdmExporter.cpp | § unitPredefAliasOfAlias245's clone for a $unit typedef naming a SCALAR or plain VECTOR typedef: listing at the target's tokens with its ranges, aliasing a per-use copy (with the ranges) of the target; a target that is itself an alias, or a package listing (vpiInstance the package), is bound directly. |
| § oobUnitClsTdUnsupported410 | R11U410_OOBUNITCLSTD_OFF | TaskFuncEmit.cpp | the out-of-body FUNCTION of a `$unit` class (listed on the design by § unitOobFuncOnDesign402) compiles in `$unit`, where the class's own typedef is not in scope: a formal or body local typed by a class typedef of a scalar/vector/atom/string kind is an unsupported_typespec named as written; struct/enum typedefs resolve (OT ot05), package/module homes resolve (ot02, ot03). |
| § clsMethodDimRefColons410 | R11U410_CLSDIMREF_OFF | TaskFuncEmit.cpp | inside a class method (prototype, in-body, package class) a param-sized formal dim's reference is named `<formal>::N`, where a module subroutine's is `<formal>.N`. |

The buildUnpackedRanges change in TypeEmit.cpp (a hook answering no range
but naming the next level skips the dim) is reached only by the two hooks
of § classBoundedQueueMultiDim410; the ModuleEmit hook never answers that
way.

## Case grid (evidence/grid.txt, drivers/grid.sh)

75 case dirs in AQ, CB, CU, GP, MI, OT, PC, PD, QM, QU, SB, TA, VF, YA
(first line `// § <law>`; MI cases carry an `inc.svh`). Golden: the pinned
Surelog `-parse -nobuiltin -nocache -sv dut.sv` (drivers/run1.sh), ours
`dut.sv --single-unit --nobuiltin`.

- exit 4 -> 0: 31 cases (QM qm01–qm08, QU qu04, AQ aq01, aq02, aq04–aq08,
  aq10, aq11, VF vf01–vf04, YA ya01–ya05), 28 of them STRICT_EQUAL, aq05,
  aq11 and ya04 NOT_EQUAL on pre-existing faces of the unbounded twins (see
  residues).
- NOT_EQUAL / STRICT_NOTEQUAL -> STRICT_EQUAL: 34 more (CB 3, CU 3, GP 4,
  MI 5, OT ot01, PC pc23, pc24, PD 3, QU qu01, qu02, SB 4, TA 5).
- moved toward golden, still NOT_EQUAL: GP/gp06 (17 -> 30 lines, head
  moved later to the generate-block `parameter` vpiLocalParam placement),
  OT/ot04 (30 -> 29), OT/ot06 (same count, the prototype half not
  modelled), PC/pc25, pc26 (def view fixed, elaborated view the sister's).
- controls keeping pristine's bytes: AQ aq03, aq09 (abstains, exit 4 kept),
  GP gp04, MI mi05 (and GP/gp07: law moves only the bare `U`, the ranged/signed ones keep pristine's typespec whose span is a residue), OT ot02, ot03, ot05, PC pc27, pc28, pc29, QU qu03,
  SB sb05.
- R11U410_OFF gives pristine's bytes and exit code on 75 of 75; each
  group's own switch on 72 of 75, the other three (CB/cb01, QU/qu04,
  YA/ya05) restored by their two-switch sets (evidence/switchsets.txt).
- no exit code worsens; no case leaves STRICT_EQUAL.

## Measurements (one full sweep on the law binary)

Two binaries were swept, and why: the first full five-stage sweep ran on
law26 (md5 82c1db2c6e9febbe2257a5d48477a9ec). Its trace census showed
§ genLpUntypedDefNoTs410 firing on bsg_mul_pipelined (still DIFFERENT) and
dropping three typespecs golden keeps for `localparam [31:0] blocks_lp`.
That row did not move in status. The law was narrowed to a bare implicit
type (law27, the final binary). Narrowing a law can only remove firings, and
the law26 trace census read 0 firings of ANY pass-410 law in the probe,
surelog, uhdm2rtlil and downstream stages, so law27's bytes there equal
law26's by construction. Only the sv-tests stage was rerun on law27, as a
stage alone. Both binaries were frozen; every cmds.txt names the binary
under test: surelog 1523 of 1573 fence-filtered cmds.txt name law26, 0 name
another binary, and 50 hold no slang line; uhdm2rtlil 1740 of 1740;
sv-tests 2346 of 2346 name law27.

law26, tests/sweep.sh --jobs 3 --workdir /tmp/r11u410_wd --corpus "probe surelog uhdm2rtlil downstream"
(exit 0, law index current):
- probe: EQUAL 4018 + STRICT_NOTEQUAL 69 of 4087, regressions=0
  conversions=0 changes=0; probe.csv byte-identical to results/golden_probe.csv.
- surelog: default CMP_EQUAL 480, testflags 474 (Tnoc d/t CMP_NOTEQUAL
  standing), regressions=0 conversions=0 changes=0.
- uhdm2rtlil: regressions=0 conversions=0 changes=0 (stamped_gen_param d/t
  CMP_NOTEQUAL standing).
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of
  871; not identical and not excused 0.
- byteverify against the master's control /tmp/intr11u408 (SELFCHECK=1,
  path sets identical): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0
  of 805 movers (evidence/byteverify.txt). Predicted: the trace census
  (R11U410_TRACE over the whole sweep) recorded no pass-410 firing outside
  sv-tests.
- canaries: canaries.sh ok=52 changed=0 (surelog) and ok=16 changed=0
  (uhdm2rtlil). ctcan2 EXPECT_UNKNOWN=1 surelog PASS, EXPECT_UNKNOWN=6
  uhdm2rtlil PASS.

law27, sv-tests stage: the main tree's scripts/check_svtests.py, run
read-only because a worktree has no UVM tree, with `--baseline
<worktree>/results/golden_svtests.csv` (the base's golden; pass 407 landed in
the main tree meanwhile), --jobs 3, machine otherwise quiet:
**regressions=0 conversions=25 changes=0**; BOTH_REJECT 303, DIFFERENT
279 -> 256, EQUAL 1641 -> 1663, SLANG_ONLY 19, STRICT_NOTEQUAL 20 -> 21,
SURELOG_CRASH 8, SURELOG_ONLY 75, TIMEOUT 1 of 2346. The fresh csv differs
from the control's svtests.csv on exactly the 25 rows below. law26's
sv-tests reading was the same 25 rows.

| row | before -> after | law(s), by trace |
|---|---|---|
| chapter-22/22.4--include_via_define.sv | STRICT_NOTEQUAL col(2) -> EQUAL | macroIncludeCol410 |
| chapter-22/22.5.1--include-define-expansion.sv | STRICT_NOTEQUAL col(1) -> EQUAL | macroIncludeCol410 |
| generated/basejump/bsg_cache_BaseJumpSTL_bsg_cache_dma_to_wormhole.sv | DIFFERENT -> EQUAL | modStructMemberBitsTypeFold410 |
| generated/basejump/bsg_cache_BaseJumpSTL_bsg_wormhole_to_cache_dma_fanout.sv | DIFFERENT -> EQUAL | modStructMemberBitsTypeFold410 |
| generated/basejump/bsg_cache_BaseJumpSTL_bsg_wormhole_to_cache_dma_inorder.sv | DIFFERENT -> EQUAL | modStructMemberBitsTypeFold410 |
| generated/basejump/bsg_dataflow_BaseJumpSTL_bsg_parallel_in_serial_out.sv | DIFFERENT -> EQUAL | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_mem_BaseJumpSTL_bsg_cam_1r1w_replacement.sv | DIFFERENT -> EQUAL | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_encode_one_hot.sv | DIFFERENT -> EQUAL | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_hash_bank.sv | DIFFERENT -> EQUAL | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_hash_bank_reverse.sv | DIFFERENT -> EQUAL | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_dramsim3_unmap.sv | DIFFERENT -> EQUAL | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_mesh_router.sv | DIFFERENT -> STRICT_NOTEQUAL (col) | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router.sv | DIFFERENT -> STRICT_NOTEQUAL (fullname) | genLpUntypedDefNoTs410 |
| generated/basejump/bsg_dataflow_BaseJumpSTL_bsg_round_robin_n_to_1.sv | DIFFERENT -> EQUAL | parenCastNameUnsupTs410 |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_decode.sv | DIFFERENT -> EQUAL | parenCastNameUnsupTs410 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_mesh_router_decoder_dor.sv | DIFFERENT -> EQUAL | parenCastNameUnsupTs410 |
| generated/basejump/bsg_test_BaseJumpSTL_bsg_nonsynth_ramulator_hbm.sv | DIFFERENT -> EQUAL | parenCastNameUnsupTs410 |
| generated/basejump/bsg_link_BaseJumpSTL_bsg_link_ddr_upstream.sv | DIFFERENT -> STRICT_NOTEQUAL (col) | parenCastNameUnsupTs410 |
| generic/class/class_test_56.sv, _57, _58 | DIFFERENT -> EQUAL | classPropBasedLitKept410 + unitTdClassPropAliasName410 |
| generic/member/class_member_test_18.sv | DIFFERENT -> EQUAL | oobUnitClsTdUnsupported410 |
| generic/member/class_member_test_19.sv | DIFFERENT -> EQUAL | oobUnitClsTdUnsupported410 + clsMethodDimRefColons410 |
| generic/typedef/typedef_test_8.sv, typedef_test_14.sv | DIFFERENT -> EQUAL | unitScalarTdAliasChain410 |

Trace census over the sv-tests stage (evidence/trace_census_svtests.txt):
the 25 rows above, plus firings with no status change:
- bsg_noc_BaseJumpSTL_bsg_wormhole_router_decoder_dor (DIFFERENT), the
  genLp law: the dump distance to golden goes 7674 -> 7666 lines, toward
  golden.
- the six black-parrot rows (genLp, macroIncludeCol, modStructMemberBits)
  and rsd (genLp): SURELOG_CRASH rows with no golden, so the status can't
  move.
- bsg_mul_pipelined is byte-identical to the control on law27 (0 dump lines
  differ).
- Away census on the firing rows: 0 away.
The goal-1 laws (classBoundedQueueMultiDim, clsQBoundUntypedParamTs,
unitBoundedQTd, dynTdAliasClone, modVirtIfaceTd) fire on no sv-tests row.
No sv-tests row holds those shapes. Their reach is the case grid and pass
402/406/408's residue cases.

Goal-1 census of results/golden_svtests.csv at the base, the SURELOG_ONLY /
BOTH_REJECT / SLANG_CRASH rows with should_fail = 0: every detail is an
upstream slang diagnostic:
- the basejump clock rows and biquad_example: time scale.
- generated/fusesoc/ibex-sim: unknown macro.
- the utd-sv rows: unknown module.
- the hdlconvertor rows: duplicate definitions, unconnected ref ports, an
  unresolved hierarchical path, implicit named port type mismatch.
- chapter-22/22.5.1--define-expansion_26: undeclared identifier.
- the ariane and uvm-examples BOTH_REJECT rows: missing files or packages,
  and the UVM fork's errors.
No row is stuck at an exporter error, on this ground or the sister's.


## Residues (all wrong on pristine too)

Ranked by sv-tests reach:

1. The about 107 UVM rows and the 11 chapter-16 UVM interface rows. Their
   heads are unchanged from pass 408: the sister's ParamEmit copy of the
   $unit-imported typedef-typed parameter. Not touched.
2. Module-level `localparam X = $bits(<struct typedef>)` carries an
   int_typespec golden does not write, and its folded constant is size 32
   where golden has 64. Rows: bsg_ready_and_link_async_to_wormhole
   (wormhole_width_lp) and bsg_tag_trace_replay (bsg_tag_header_width_lp),
   both still DIFFERENT. The parameter is emitted by ParamEmit, a
   sister-ground face (see below).
3. The STRICT_NOTEQUAL rows this pass made:
   - bsg_mesh_router: col.
   - bsg_link_ddr_upstream: col.
   - bsg_wormhole_router: fullname.
   Not decoded.
4. The elaborated view of a parenthesized size cast: golden writes an
   integer_typespec with the value UINT:4 at the inner name; ours writes the
   parameter's int_typespec with an Expr reference. Cases PC/pc25, pc26.
   This is the ExprEmit elaborated cast, sister ground. A parenthesized
   cast at module-item level (pc29) is not reached either.
5. hdlconvertor p88 and p124: a variable typed by an overridden type
   parameter (`p2 j = 0;`) has its initializer constant sized by the
   parameter's DEFAULT type in golden (shortint 16) where ours sizes it by
   the override (32). Decoded, not written: the constant comes from
   ExprEmit.
6. Out-of-body $unit class functions:
   - In the body, references are named `cls::f.x` in golden and are
     unbound; ours are `cls::f::x` and bound (OT/ot04). This is
     § unitOobFuncOnDesign402's body, the ExprEmit/StmtEmit naming.
   - The extern prototype's formals typed by class typedefs take a copy at
     the use span in golden (OT/ot06, the prototype half).
7. Typedef shapes reached by the goal-1 laws but still NOT_EQUAL. All are
   pre-existing faces of the unbounded twins, the same on pristine with
   `[$]`:
   - A module-body dynamic/queue typedef used by a module variable lacks
     golden's per-use aliased copy (AQ/aq05).
   - A $unit queue typedef of a packed-struct typedef or a string element:
     the struct alias's parent, and a missing string element typespec
     (AQ/aq11, YA/ya04).
   - A parameter-bounded queue typedef abstains and stays exit 4 (AQ/aq09).
8. Implicit-typed generate parameters with a packed range or signing keep
   their typespec but at the declaration span; golden has the
   range/`signed` span (GP/gp07). Also a generate-block `parameter` (not
   localparam) has its vpiLocalParam placement differing (GP/gp06).
9. Not reached: the rest of the brief's backlog.
   - Pass 408: interface-class-typed objects, the default-less generic
     class gaps, class copies of unpacked-array/string/real typedefs, DPI
     $unit tasks, typedef_test_0.
   - Multi-dimension typedef uses: at18, va01–va22. These are rc 0 and
     NOT_EQUAL.
   - Union typedef args and arrays: vu09 (rc 0, NOT_EQUAL); vu10 is
     STRICT_NOTEQUAL line.
   - Dynamic and queue event-array class properties.
   - The seven basejump definitions § undefaultedDefInvalidInst404 skips.
   - Implicit-net and variable-initializer residues of pass 404.
   - Pass 402's net kinds.
   - Pass 406's sequence/realtime/time residues, 6.12--realtime.
   - The singletons of decode.csv: p148/p184 class property operation
     initializer, p753_2/p790 gate var_select constant, p761/p762
     interface_inst, the 15.4 mailbox and 6.19.2 enum_sequence pairs, the
     6.6.7 nettype pair, 8.8 typed_constructor.

## Sister-ground faces (reported, not written)

- ParamEmit (module parameter emission, makeParamTs): `localparam W =
  $bits(<struct typedef>)` in a module body. Golden writes no typespec on
  the parameter and folds the constant at size 64. Two basejump rows:
  bsg_ready_and_link_async_to_wormhole, bsg_tag_trace_replay.
- ExprEmit (elaborated CastExpression): `(W)'(x)` in an elaborated
  generate scope. Golden writes an integer_typespec UINT:<value> at the
  inner name. Cases PC/pc25, pc26.
- ExprEmit (variable initializer constant): a type-parameter-typed variable
  initializer is sized by the parameter's default type. Rows hdlconvertor
  std2012 p88, std2017 p124.
- ExprEmit/StmtEmit (§ unitOobFuncOnDesign402 body): reference naming and
  binding inside a $unit class's out-of-body function. Case OT/ot04.

## Process

- The one full sweep ran on the machine after the master's pass 407
  integration sweep had finished. pgrep -af for sweep, runner and harness
  processes read 0 before each launch.
- The sv-tests stage ran through the main tree's check_svtests.py
  read-only, against the base's golden.
- The binary under test was frozen in scratch.
- No pkill or pgrep -f was used on any other agent's process.
- The fence list was read into a scratch file without printing it, and
  every tree-wide path list was filtered on it before any file was opened.
- No fenced test was named, run or read.
- Nothing was written outside /tmp/wt_r11u410 and /tmp/r11u410_*.
- The single-row decode runs (scratch drivers sv/one.sh, sv/dd.sh) reran
  the control's own slang command on one row at a time with the
  intermediate binaries, and compared the result with the cached Surelog
  golden. These were light runs, made while no sweep of any agent was
  live.
- Over the budget by one stage: the sv-tests stage was rerun alone on the
  narrowed law27, for the reason given under Measurements.

