# r11u426 — module/type ground, pass 426 (sv-tests campaign, thirteenth pass on this ground)

Base 8dc2a0acb.  Production files: src/TypeEmit.cpp, src/UhdmExporter.cpp,
src/TaskFuncEmit.cpp, src/ModuleEmit.cpp (a trace call only).  No ExprEmit,
StmtEmit, ParamEmit, EmitHelpers.h, include/ or uhdm_main.cpp change.  Every
law reads its switch through src/LawSwitch.h (`lawOn(426,
"R11U426_<LAW>_OFF")`); R11U426_OFF drops the whole pass; R11U426_TRACE=<dir>
logs each firing.  No src/R*.h, no getenv, no reader function.

## Result

Pristine = the main tree's build at the base (md5
c623a2128527ff4453411543a280fc43, rebuilt in the worktree byte-identical);
the pristine reading is the master's control sweep /tmp/intr11u424 (its csvs
equal the committed results/*.csv).  Final law binary law6, md5
afc4313dcda1982a869079fe4ae93484 (rebuilt after the last comment-only edit:
same md5), swept ONCE with all five stages (drivers/fullsweep.sh; the
sv-tests stage through the main tree's scripts/check_svtests.py read-only,
baseline the base's results/golden_svtests.csv; evidence/fullsweep_law6.log):

| stage | result |
|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69, regressions=0 conversions=0 changes=0; csv byte-identical to the control |
| surelog | default 480 / testflags 474 CMP_EQUAL, regressions=0 conversions=0 changes=0 |
| uhdm2rtlil | 803/1/67 both modes, regressions=0 conversions=0 changes=0 |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0; csv identical to the control |
| sv-tests | **regressions=0 conversions=2 changes=0**: EQUAL 1880 -> 1882, STRICT_NOTEQUAL 2, DIFFERENT 58 -> 56 (of 2346; BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1) |

The corpus stage's rc=1 is the stale law index alone (tests/LAWS.md
regenerated afterwards; `scripts/law_index.py --check` reads current).

sv-tests conversions (evidence/svtests_law6_vs_control.diff; the only two rows
whose csv line differs from the control):

- generic/typedef/typedef_test_9.sv: DIFFERENT -> EQUAL through
  § unitTdBoundUnitParamFold426 (`typedef data_t my_array_t [k:0][j:0];` over
  `$unit` parameters; pass 411's reported TypeEmit face "typedef range bounds
  reading $unit parameters").
- generated/hdlconv_std2017/hdlconvertor_std2017_p179.sv: DIFFERENT -> EQUAL
  through § namedTypeLocalTfItemOutsideClass426 (`xtndA xtnd1; baseA base2,
  base3;` in the paren-less `$unit` function `test`).

Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law workdir
against the master's control): surelog 0 of 962 (selfcheck 961/962),
uhdm2rtlil 0 of 1608 (1607/1608), downstream 0 of 805 (804/805): NO CORPUS
BYTE MOVER.  The trace census (evidence/trace_census.txt; R11U426_TRACE on for
the whole sweep): no corpus row and no probe case fires any law of this pass
(the positive control: 23 sv-tests rows do); the firing sv-tests rows are the
two conversions and the 20 uvm-examples rows of § enumLitArithImportCloneFolds426
(16 DIFFERENT, 4 SLANG_ONLY).  Canaries: canaries.sh ok=52 changed=0 (surelog)
and ok=16 changed=0 (uhdm2rtlil); ctcan2.sh PASS on both (EXPECT_UNKNOWN=1 /
6).  Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name law6 (the
other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of
2346; no other slang-uhdm binary named.

Away census (evidence/away_census_cmp_lines.txt, uhdm-cmp line counts against
the control's databases): the 20 uvm-examples rows read the same count
(their uhdm-cmp head is earlier in the walk, the instance face below); on
uvm_messaging_example the path-normalized dump distance to golden goes
379191 -> 378037 lines (toward golden: the re-listed enum constants now read
golden's `UINT:65536` / `65536` / 64).  Determinism: three concurrent draws of
uvm_messaging_example with law6 read one hash; the sweep's copy differs from
them only in the cwd-dependent builtin.sv path.

Goal 1: the 75 SURELOG_ONLY rows all carry an upstream slang `error:`
front-end diagnostic (0 rows with an exporter `unsupported` detail; BOTH_REJECT
and SLANG_CRASH none either), as passes 406-424 found: no sv-tests row on this
ground.  The probe-only exit-4 shape written by this pass:
`typedef ua_t ub_t;` over a fixed-size `$unit` array typedef
(§ unitFixedArrTdAliasClone426, cases UR/ur21, AC).

## Laws

All four read their switch through src/LawSwitch.h (`lawOn(426,
"R11U426_<LAW>_OFF")`); R11U426_OFF drops the pass (pristine bytes and exit
code on 54 of 54 grid case dirs); R11U426_TRACE=<dir> logs each firing
through `lawTrace(426, ...)`.  No src/R*.h, no getenv, no reader function, no
include/ change.

1. § unitTdBoundUnitParamFold426 (R11U426_UNITTDBOUND_OFF; TypeEmit
   buildUnpackedArrayTypedefTs, makeTypespec's packed `emitBound`, and the
   per-use copy in copyArrayTypedefTs) — a `$unit` typedef's dimension bound
   that reads a `$unit` PARAMETER is reduced by Surelog (the file-level
   typedef is compiled with the reducer on), where the class-typedef builder
   we share kept it symbolic (`ref_obj my_array_t::k`) and the packed path
   folded it to a bare UINT at 64.  Golden, measured on cases UR:
   * a bare name or a parenthesized one (`[k:0]`, `[(k):0]`, the size form
     `[k]`, packed `[k:0]`, `[(k):j]`): the parameter's own value object at
     the name (UINT:2 size 32 for an untyped `parameter k = 2`, DEC:200 size
     8 for `logic [7:0] k = 8'd200`, HEX:5 size -1 for `'h5`, UINT size 32 for
     `parameter int k`), with a ref_typespec named like the typedef whose
     actual is the parameter's own typespec (none when the parameter has
     none, ur12);
   * a binary `+ - *` over such names and unsized decimals (unpacked bounds):
     the folded constant at the LEFT OPERAND's span, no typespec, reduced as
     UHDM's ExprEval does (`+` UINT when no operand is signed, at the wider
     operand's size; `-` and `*` INT at 64): `[k-1:0]` INT:3 at `k`,
     `[k+j:0]` UINT:6 size 32, `[2*k:1]` INT:8 at `2`, `[k+1-j:0]` INT:3 at
     `k+1`;
   * the per-use copy of the listing that a variable binds (ur05) carries the
     same reference.
   A parameter declared in another command-line root file, any other operator
   or operand, a parenthesized expression and an import-twin clone keep the
   symbolic bound.  Mechanism: the value is cloned from the parameter's
   param_assign Rhs (cloneUnitParamRhs) and the reference is resolved in the
   `$unit` parameter typespec drain (pendingUnitSubstTs), as § unitRefSubst
   does for spliced values.
2. § unitFixedArrTdAliasClone426 (R11U426_UNITARRTDALIAS_OFF; UhdmExporter,
   the `$unit` typedef loop, extending § dynTdAliasClone410's branch) — GOAL 1:
   a `$unit` typedef naming a listed FIXED-SIZE unpacked array `$unit`
   typedef (`typedef ua_t ub_t;`) exited 4 (`typedef target:
   FixedSizeUnpackedArrayType`) where upstream slang accepts.  Golden lists
   the clone named ub_t at ua_t's span with ua_t's ranges and element (every
   reference named ub_t), its alias reaching ua_t's listing through an
   unparented copy named ua_t, exactly as § dynTdAliasClone410's dynamic
   kinds (cases UR/ur21, AC ac01-ac03, ac06).  Only a target listed by
   § unitArrTd245 (a `$unit` typedef of a fixed-size array whose element is
   not a typedef); an alias of an alias (ac04) and an element typedef (ac05)
   keep exit 4 (residues).
3. § namedTypeLocalTfItemOutsideClass426 (R11U426_NAMEDTFITEM_OFF;
   TaskFuncEmit emitTaskFuncs, the body-local loop) — the block-member model
   for a NAMED-type local (`box_t r;`, `A a1;`: name span, no vpiAutomatic,
   re-parented to the body block) holds in a CLASS method only (case CV/cv11).
   In the tf-item form (a function written without a port list, or a task
   whose body declares a port) of a `$unit`, module, interface, program or
   generate-scope subroutine Surelog compiles it through compileTfPortDecl's
   block-item branch (CompileStmt.cpp, `var->VpiAutomatic(!is_static)`):
   located at its DATA TYPE (`A` 6:3-6:4, `p::C` 8:3-8:7, `C #(4)` 6:3-6:9),
   vpiAutomatic set unless written `static`, and listed on the function
   (cases CV cv01-cv04, cv06-cv09, cv12-cv20, cv22: class, parameterized and
   package-scoped class, class typedef, struct, enum and vector typedefs).
   The typespec it binds is unchanged.
4. § enumLitArithImportCloneFolds426 (R11U426_ENUMCLONEFOLD_OFF; TypeEmit
   buildEnumTs, § enumConstLitArithRender188's gate) — the IMPORT-LISTING
   CLONE of a package enum (the object an importing package and the
   elaborated home package list) takes the elaborated listing's folded form
   of an arithmetic initializer over integer literals: golden `UINT:65536`
   decompile `65536` size 64 for `UVM_DEEP = (1<<16)`, where ours wrote the
   definition text at the base width (`INT:65536` / `1<<16` under UVM's
   bit-vector base, `BIN` at 32 under `int`).  Cases EC ec01-ec03 (shift,
   `+ - *` over decimals, sized and unsized based literals); a shift over an
   unsized based literal (UHDM's unfolded render) abstains.

Also (no byte change): § ifcProcCallArgNoTs424 now logs its firing
(`lawTrace(424, "ifcProcCallArgNoTs424", <instance>)`) as the brief asked; the
flag it writes is ExprEmit's definition-only flag `defOnlyDefEmit`
(include/UhdmExporter.h), so every reader of that flag inside the window
(the interface instance's process and assertion compile up to
`ifaceProcsDone283`) is gated by it, not only the call-argument stamp; today
the only reader is ExprEmit's formal-typespec stamp (one site).

## Grid (cases/, 54 case dirs; evidence/grid_law6.txt)

Line format: case | law | pristine reading | law reading | R11U426_OFF ==
pristine | the case's own switch == pristine (exit code, uhdm-cmp line
count, strict verdict, md5 on each side).

- UR (22, § unitTdBoundUnitParamFold426 except ur21): ur01-ur07, ur09-ur18,
  ur20 NOT_EQUAL -> STRICT_EQUAL (18); ur19 (`[k-1:0]` packed, already
  folded) a control kept byte-identical; ur22 NOT_EQUAL -> STRICT_NOTEQUAL
  type (the `wire pk_t w` net's typedef alias copy, a residue present on
  pristine too); ur08 (a MODULE typedef over a module parameter: golden keeps
  `ref_obj work@test.ua_t.k`, ours folds) unchanged bytes, a residue; ur21
  (§ unitFixedArrTdAliasClone426) exit 4 -> STRICT_EQUAL.
- AC (6, § unitFixedArrTdAliasClone426): ac01, ac02, ac06 exit 4 ->
  STRICT_EQUAL; ac03 exit 4 -> STRICT_NOTEQUAL type (a variable typed by the
  alias binds golden's alias clone where ours mints a fresh array_typespec);
  ac04 (alias of an alias) and ac05 (an element typedef) stay exit 4 (ac04's
  partial database moves because its middle link is now written; ac05
  byte-identical).
- CV (22, § namedTypeLocalTfItemOutsideClass426): cv01-cv04, cv06-cv09,
  cv12-cv17, cv20, cv22 NOT_EQUAL -> STRICT_EQUAL (16); cv19 (`static A a1;
  automatic A a2;`) STRICT_NOTEQUAL col -> STRICT_EQUAL; controls cv05 (a
  task), cv10 (a function with a port list), cv11 (a class method), cv21 (a
  package function) byte-identical; cv18 (a program function) NOT_EQUAL on
  both with the head moved later (golden lists a program-level logic_net
  work@prg.a1 for the function local; pristine's residue too).
- EC (4, § enumLitArithImportCloneFolds426): ec01-ec03 NOT_EQUAL ->
  STRICT_EQUAL (shift under `int`, `+ - *` over decimals and sized/unsized
  based literals, UVM's bit-vector-typedef base); ec04 (no importing package)
  a control kept.

Totals: 37 NOT_EQUAL -> STRICT_EQUAL, 1 STRICT_NOTEQUAL -> STRICT_EQUAL, 4
exit 4 -> STRICT_EQUAL, 1 exit 4 -> STRICT_NOTEQUAL, 1 NOT_EQUAL ->
STRICT_NOTEQUAL, 6 controls byte-identical, 4 unequal on both (2
byte-identical, cv18 head later, ac04 exit 4 on both).  R11U426_OFF gives
pristine's bytes and exit code on 54 of 54; each case's own switch on 52 (ac06
and ur21 need § unitTdBoundUnitParamFold426's switch too: their bounds read a
`$unit` parameter).  Downstream (evidence/downstream_cases_*.txt) on the 36
class-free cases: UR/ur05 EQUIVALENT -> IDENTICAL, AC/ac03 EQUIVALENT ->
IDENTICAL, the other 34 IDENTICAL on both; none worse.

## Residues and decoded faces (ranked)

1. THE 16 UVM-EXAMPLES ROWS (the 1<<16 cells, the sister's report for this
   ground): written by § enumLitArithImportCloneFolds426, but not the rows'
   first head.  Decoded with a Compare tracer (evidence/tools/cmptrace*.cpp:
   it reruns design::Compare seeding the CompareContext's visited set to
   bisect the failing pair; uhdm-cmp only prints the package pair) the first
   head of 12 rows (ac_config_db, ef_vif_config_db, id_register,
   messaging_example, param_vif_config_db, priority_arbitration,
   priority_grab_lock, use_models_bidir_get_put, bidir_item_done,
   pipelined_get_put, unidirectional, vif_config_db) is a vpiInstance:
   the class-local typedef object of a class SPECIALIZATION written at
   package level (`typedef uvm_pool#(string, uvm_action)
   uvm_id_actions_array;` makes uvm_pool's `this_type`, located at that
   typedef, uvm_report_handler.svh 34:9) is unlisted and carries golden's
   TOP (elaborated) view of the DECLARING package (CompileType's
   `result->Instance(component->getUhdmInstance())` in the elaborated
   compile), where ours carries the DEF view of the last importing package
   (§ classKeyTsScopeOwner35's stamp).  The rule, checked on the messaging
   golden (0 changes, evidence/uvm_messaging_faceA_rule_on_golden.txt) and
   on ours (9 objects, evidence/uvm_messaging_faceA_rule_on_ours.txt): an
   unlisted class_typespec parented by its class_defn whose Typedef_alias
   target is named `P::N`, listed by TOP P and NOT by DEF P, takes TOP P.
   Cases evidence/residue_cases/CT ct01-ct06 (ct03 control equal; ct02, a
   specialization typedef in the importer, a second face).  Not written: it
   converts no row alone.  The heads after it, in walk order
   (evidence/uvm_messaging_heads_after_faceA.txt): a package struct
   member's class_typespec (`uvm_object_wrapper m_type` of
   m_uvm_factory_type_pair_t, 14 copies) with golden vpiInstance TOP uvm_pkg
   and ours null (residue_cases/SM: golden gives the DEF home package when
   an importer package re-lists the struct, sm01, and TOP+DEF without one,
   sm02, which ours already matches); the enum constants (now written); the
   radix enum's base `uvm_field_flag_t` alias chain naming; and
   uvm_default_factory's `m_inst_typename_alias_t` locals written as a
   struct_typespec where golden has an unsupported_typespec with vpiInstance
   TOP uvm_pkg (about 20 foreach/local heads).  Five more rows
   (generation_seq_persistence, _poly, _randomization, many_to_one, test_init)
   head at the instance of the radix enum's copy in a module or class
   (golden the importing package), and apb_protocol_monitor at an
   interface_inst listing; § enumLitArithImportCloneFolds426 fires on 16 of
   these 18 DIFFERENT rows (and on 4 SLANG_ONLY ones) with each row's
   uhdm-cmp count unchanged.
2. THE 4 TESTBENCHES ROWS (uvm_agent_active, uvm_agent_passive,
   uvm_driver_sequencer_env, uvm_monitor_env): at this base their first head
   is still ParamEmit's class param_assign copy (`ref_typespec` under the
   constant at line 202, class packet_in/packet_out), the face pass 423 says it
   wrote; the TypeEmit uvm_resource face it reported is behind it on this base
   (pass 423 landed after this pass's base).  The three scoreboard rows fail
   first at the design level; the tracer's seeded walk names a class_typespec
   `this_type` of work@comparator (the instance family of item 1) and then the
   same ParamEmit face.
3. `$unit` typedef bound shapes not written: an alias of an alias (AC/ac04)
   and an array whose element is a typedef (ac05) stay exit 4; a variable
   typed by the alias clone (ac03, STRICT_NOTEQUAL type); a MODULE typedef's
   bound over a module parameter, where golden keeps the reference and ours
   folds (UR/ur08); the net typed by a `$unit` packed typedef (ur22, type).
4. Remaining heads decoded at the base (evidence/heads_multi_base_nonuvm.txt,
   the tracer's seeded walk): p334 (a default-less generic class: method
   return and argument `logic [N-1:0]` typespecs lose their range, golden
   keeps the unfolded `ENCODE_W-1` with an unbound ref_obj; 4 objects);
   bsg_mesh_stitch and round_robin_fifo_to_fifo, dpi_rom, comm_link (the
   default-less "inv" placeholder widths); channel_control_master (3
   `$bits(<signal>)` in a generate block's definition view golden keeps,
   ours folds); non_blocking_data_mem (2 hier_path names, `**` rendered `* *`
   by emitSyntaxExpr); p737 (a module with a default-less type parameter:
   golden names the design work@M, ours `unnamed`); p489 (a direction-less
   ANSI port after `logic[7:0] in1` written as a variable where golden has a
   net); p130 (a type-parameter override's int_typespec); p719, p765,
   imod_range, axi_mem, mul_pipelined (module listing heads); easyUVM
   (class_defn work@sequencer against null); class_test_49 (ExprEmit's
   select naming, sister); p599 (ModuleEmit's cont-assign system-call stamp).
5. The carried backlog of passes 402-424 (their READMEs) stands; none of
   their cases moved (the trace census: no law of this pass fires on a probe
   case).

## Sister-ground faces (reported, not written)

- ParamEmit: the class param_assign copy's constant at line 202 without its
  ref_typespec is still the first head of the 4 testbenches rows at this base
  (the face pass 423 reports written; re-measure after its landing).
- ExprEmit: class_test_49's `f(glb::arr[N])` select naming (unchanged).

## Process

One full sweep on the final binary (launched on a quiet machine after the
master's pass-423 integration sweep ended; the sister r11u425's base build ran
alongside, 16 cores); intermediate binaries law1-law5 on case runs and one
targeted runner call (p179, typedef_test_9) only.  The fence list was read
into a file by a program and never printed; every tree-wide list was filtered
on it.  One slip, no measurement affected: an early `grep -rl --include=*.cpp`
over tools/probe looking for a Compare tracer was not filtered on the fence
list first (C++ tool sources only; none matched a fenced name, checked
afterwards).  No other agent's process touched.

## Files

- cases/{UR,AC,CV,EC}/<case>/dut.sv — the grid, first line `// § <law>`.
- drivers/run1.sh, grid.sh, dd.sh (keyed on the path after tools/probe/, not
  after cases/), fullsweep.sh, switches.txt.
- evidence/: grid_law6.txt, fullsweep_law6.log, svtests_law6_vs_control.diff,
  trace_census.txt, away_census_cmp_lines.txt, downstream_cases_*.txt,
  heads_first_base.txt and heads_multi_base_nonuvm.txt (the tracer's heads on
  the 57 DIFFERENT/STRICT_NOTEQUAL rows at the base), runner_base_57rows.csv,
  runner_law4_p179_td9.csv, uvm_messaging_* (face 1), residue_cases/{CT,SM},
  tools/ (cmptrace.cpp, cmptrace2.cpp, listers2.cpp, fixer.cpp, insttd.cpp,
  shared.cpp; built against ~/.local's libuhdm.a).
