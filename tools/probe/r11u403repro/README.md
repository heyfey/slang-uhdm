# r11u403 — the sv-tests campaign's second pass on the expression/parameter ground

Implementer pass on base c51d5b5f (passes 401 and 402 landed), ground
src/ExprEmit.cpp, src/EmitHelpers.h, src/StmtEmit.cpp, src/ParamEmit.cpp.
Every law is `§ <name>403` read through `lawOn(403, "R11U403_<LAW>_OFF")`
(src/LawSwitch.h); `R11U403_OFF` drops all of them; `R11U403_TRACE=<dir>`
logs each firing through `lawTrace(403, ...)`.  No src/R*.h, no getenv, no
reader function.

Binaries: pristine d90254f4ad18ac702ba763d6a8f7854b (equal to the main tree's
build at the base), final law binary da9ae4cb9ce0fc8c71f8287efd301267
(an intermediate law binary 9cf9a6c7177c613cb126cdb167968583 differs from it
only in the hierarchical-reference fence of § unboundEventImplicitNet403, see
"process"; every number below is the final binary's unless marked).  Every case line below carries the exit code.

## The laws

| law | switch | site | what golden writes |
|---|---|---|---|
| § patternCaseNoItems403 | R11U403_PATCASE_OFF | StmtEmit (case PatternCase) | `case (e) matches ...` is a case_stmt (case type, qualifier, condition parented at the enclosing scope) with an EMPTY item list: Surelog's compileCaseStmt builds items only for case_item / case_inside_item nodes |
| § matchesOpPattern403 | R11U403_MATCHOP_OFF | StmtEmit (if condition), ExprEmit (ConditionalOp), EmitHelpers.h matchPattern403 / patternShape403 / buildMatchOp403 | `e matches p` is a vpiMatchOp operation [e, pattern] from e through the pattern; `tagged m` is a tagged_pattern at the `tagged` keyword; `'{...}` holding `.v`/`.*` is a vpiListOp, all-constant `'{...}` a vpiAssignmentPatternOp; a list's first `.v` is an unsupported_expr over the dot (STRING: the source line), a later `.v` a ref_obj over the name with no stored full name, `.*` an unsupported_expr, constants unparented; a `&&& guard` is not written; in `e matches p ? a : b` the branches are dropped; the pattern-if's implicit block is unwrapped. Named structure members, nested lists, a bare constant/list pattern abstain (the rejection stays) |
| § patternVarImplicitNet403 | R11U403_PATVARNET_OFF | ExprEmit (NamedValue) | a read of a pattern variable binds the implicit module wire Surelog mints at the first reference (logic_net, vpiNetType 1, no file) |
| § unitFwdCallNoLink403 | R11U403_UNITFWDCALL_OFF | ExprEmit (call to a $unit subroutine not yet emitted) | a call to a $unit FUNCTION declared further down is a name-only func_call with its written arguments, no vpiFunction (Surelog is single-pass) |
| § unboundEventImplicitNet403 | R11U403_EVNET_OFF | StmtEmit (EventTrigger, Invalid trigger, event_control), EmitHelpers.h mintImplicitNet403 | a trigger or a bare `@a.b` wait through a HIERARCHICAL path leaks the implicit wire named by the first token over the whole written path; the wait's ref_obj binds it, the trigger does not. A path rooted at a declared handle (`h.e`, a member access) abstains (cases/EV ev04) |
| § unboundEventWaitSpan403 | R11U403_EVWAITSPAN_OFF | StmtEmit (event_control location) | the unbound `@a.b` event_control spans `@` through the end of the written path |
| § foreachUnitImportElemVar403 | R11U403_FEUNITIMP_OFF | StmtEmit (§ foreachPkgClassArrayVar25's gate) | in a package's elaborated listing a foreach over a package-level queue/dynamic/fixed array of class handles lists the ELEMENT class_var (bound to the element class_typespec) when the home package is wildcard-imported at $unit, directly or through a $unit-imported package's own wildcard import; the array_var answer is the no-import one |
| § dottedPropRootUnitImport403 | R11U403_DOTPROPROOT_OFF | StmtEmit (§ classPropUnitImport21's dotted exemption) | a dotted foreach path rooted at a CLASS PROPERTY read through the implicit `this` (`foreach (m_end_node.m_successors[succ])`) is NOT exempt from the $unit gate: under a $unit import of the home package golden writes the int_var fallback |
| § oobCtorHoistSourceOrder403 | R11U403_HOISTORDER_OFF | EmitHelpers.h sortOobCtorLocals403, used by ParamEmit (package listing, transitive clone) and EmitHelpers.h (module materialized copy) | the hoisted out-of-body constructor locals are in include-expanded source order among themselves: uvm_root::new's `rh` (uvm_root.svh:366, included at uvm_component.svh:1579) before uvm_component::new's error_str/top/cs/bld/common (:1596) |
| § pkgTfMacroDefAtExpansion403 | R11U403_PKGTFMACRO_OFF | ParamEmit pkgTfListingLess | the package Task_funcs listing orders a macro-born out-of-body definition (uvm_packer `M__UVM_GET_PACKED(byte)` ...) at the macro's expansion site (the package twin of § oobMacroDefAtExpansion402) |
| § macroVecLitTokenText403 | R11U403_MACROLITTOK_OFF; size guard R11U403_MACROLITGUARD_OFF | ExprEmit (IntegerLiteral) | pass 401's withdrawn black-parrot fix, landed behind a SIZE GUARD (see below) |
| § sizeTickSpaceDropped403 | R11U403_SIZETICKSP_OFF | ExprEmit (IntegerLiteral) | `32 'h 12ab_f001` decompiles `32'h12abf001` (blanks between size and tick dropped) |
| § unique0IfIsUnique403 | R11U403_UNIQUE0IF_OFF | StmtEmit (Conditional) | `unique0 if` carries vpiUniqueQualifier (Surelog compileConditionalStmt maps paUNIQUE0 to it; the case statement maps it to none) |
| § operatorAttrsListed403 | R11U403_OPATTR_OFF | ExprEmit (emitExpr prologue) | attributes on a binary or conditional operator are vpiAttribute objects on the operation, each spanning its attribute spec, a string value as STRING:; any other value form abstains |
| § stdRandomizeIsScopeRef403 | R11U403_STDRAND_OFF | ExprEmit (Call) | `std::randomize(...)` is one ref_obj: `std::randomize` spanning `std::` without a with block, `std` spanning through the constraint `}` with one, bound in a module to the implicit wire `std` (pass 116's residue R1) |

### The black-parrot size guard (§ macroVecLitTokenText403)

The law removes the exporter's `basic_string::substr` exception on all six
generated/black-parrot rows (the base-digit split of a macro literal whose
range reads back as `` ``funct12``,{5{1' ``; the literal takes its own tokens).
Pass 401 measured the consequence: run ALONE, bp_default, bp_multicore_1,
bp_multicore_1_cce_ucode and bp_unicore then export at 10 to 11 GB, and
bp_multicore_4 and bp_multicore_4_cce_ucode_cfg are killed for memory on the
15 GB machine even alone; under the gate's `--jobs 3` five rows died.
check_svtests ranks SLANG_CRASH (0) below SURELOG_CRASH (1), so a memory kill
is a REGRESSION, and bp_multicore_4 would be one on every run. The law is
therefore held off by a size guard: when the loaded source text
(SourceManager::getMemoryUsage) exceeds 1 MB the law abstains (traced as
`macroVecLitTokenText403_GUARD`) and the exporter rejects as pristine does.
Measured on bp_default with the law binary: the guard fires (src=3655593),
the run exits 3 in 18 s with pristine's message, so the row stays
SURELOG_CRASH exactly as at the base. `R11U403_MACROLITGUARD_OFF=1` lifts the
guard for a serialized or memory-bounded run. Below the guard the law fires on
case ML/ml01 (pristine rc 0 judge NOT_EQUAL -> uhdm-cmp 0, STRICT_NOTEQUAL
endcol: the macro-argument span model of a pasted literal, a residue) and on
no corpus row, probe case or sv-tests row (trace census below).

## Grid (cases/, 49 case dirs; evidence/grid.txt has every line)

Recipe of the probe harness (Surelog -parse -nobuiltin -nocache -sv dut.sv
-mt 0 -mp 0; slang-uhdm dut.sv --single-unit --nobuiltin), goldens built per
case (drivers/rc.sh).  Pristine -> law:

* PC (§ patternCaseNoItems403) pc01-pc04: rc 4 NOT_EQUAL -> rc 0 STRICT_EQUAL, 4 of 4.
* PM (§ matchesOpPattern403) pm01-pm06, pm09-pm12: rc 4 NOT_EQUAL -> rc 0 STRICT_EQUAL, 10 of 10; pm08 (named structure pattern) rc 4 both: the abstention.
* PV (§ patternVarImplicitNet403) pv01, pv02: rc 4 -> rc 0 STRICT_EQUAL.
* EV (§ unboundEventImplicitNet403, § unboundEventWaitSpan403) ev01-ev03: NOT_EQUAL -> STRICT_EQUAL; ev04 (handle member trigger and wait) STRICT_EQUAL on both: the fence.
* FE (§ foreachUnitImportElemVar403) fe01, fe02: NOT_EQUAL -> STRICT_EQUAL; fe03 (module-scope import), fe04 (import in another package) unchanged; fe05 (queue, dynamic, fixed) and fe07 (reached through a $unit-imported package): every loop variable now golden's, the head moves later in the walk to the module's materialized copy of the imported fixed array / package (sister ground, cmp 56 -> 1608 / 1644, the loop-variable census 0 differences); fe06 (EXPLICIT $unit import, golden int_var) unchanged: a residue.
* FD (§ dottedPropRootUnitImport403) fd01-fd05: the loop-variable census (drivers/lv.py) 1 difference each (golden int_var, ours class_var) -> 0; the uhdm-cmp head of these cases is the class's out-of-body method listing under a $unit import (sister ground) on both binaries; fd06, fd07 (no import) unchanged.
* HO (§ oobCtorHoistSourceOrder403) ho03 (the include shape of UVM): NOT_EQUAL -> STRICT_EQUAL; ho01, ho02 (no include) STRICT_EQUAL on both.
* OM (§ pkgTfMacroDefAtExpansion403) om01: NOT_EQUAL -> STRICT_EQUAL.
* UF (§ unitFwdCallNoLink403) uf05, uf06: rc 4 -> rc 0 STRICT_EQUAL; uf01 (the p728 shape): rc 4 -> rc 0, the head is the $unit TASK golden does not list (sister ground).
* SZ, UQ, AT, SR: sz01, uq01, at01, at02, sr01, sr02 NOT_EQUAL -> STRICT_EQUAL.
* ML (§ macroVecLitTokenText403) ml01: uhdm-cmp 28 -> 0, STRICT_NOTEQUAL endcol.

Totals (final binary, evidence/grid.txt): 49 case dirs; 31 NOT_EQUAL -> STRICT_EQUAL, 1 NOT_EQUAL ->
STRICT_NOTEQUAL (ml01), 5 STRICT_EQUAL and 2 STRICT_NOTEQUAL unchanged (the fences and
controls), 10 NOT_EQUAL on both (pm08, fe05, fe06, fe07, fd01-fd05, uf01: heads named above);
none leaving an equal status.  With the final binary `R11U403_OFF=1` gives pristine's bytes
and exit code on 49 of 49, and each group's own switch(es) give pristine's
bytes and exit code on its cases on 49 of 49 (drivers/sw.sh).

## sv-tests (scripts/check_svtests.py, --jobs 3)

Pristine at the base: EQUAL 1240, STRICT_NOTEQUAL 20, DIFFERENT 668,
BOTH_REJECT 303, SURELOG_ONLY 87, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1
(regressions 0, conversions 0, changes 0) — the baseline reproduced exactly.

Law sweep (final binary): regressions 0, conversions 16, changes 0;
EQUAL 1240 -> 1254, STRICT_NOTEQUAL 20 -> 21, DIFFERENT 668 -> 659,
SURELOG_ONLY 87 -> 81, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8,
TIMEOUT 1 (of 2346).  The sixteen, each attributed by its own trace:

    chapter-12/12.6.1--case_pattern.sv      SURELOG_ONLY -> EQUAL   § patternCaseNoItems403
    chapter-12/12.6.1--casex_pattern.sv     SURELOG_ONLY -> EQUAL   § patternCaseNoItems403
    chapter-12/12.6.1--casez_pattern.sv     SURELOG_ONLY -> EQUAL   § patternCaseNoItems403
    chapter-12/12.6.2--if_pattern.sv        SURELOG_ONLY -> EQUAL   § matchesOpPattern403, § patternVarImplicitNet403
    chapter-12/12.6.3--conditional_pattern.sv SURELOG_ONLY -> EQUAL § matchesOpPattern403
    generated/hdlconv_std2017/hdlconvertor_std2017_p728.sv SURELOG_ONLY -> DIFFERENT § unitFwdCallNoLink403
    chapter-15/15.5.1--named-event-trigger-blocking.sv     DIFFERENT -> EQUAL § unboundEventImplicitNet403
    chapter-15/15.5.1--named-event-trigger-non-blocking.sv DIFFERENT -> EQUAL § unboundEventImplicitNet403
    chapter-15/15.5.2--named-event-wait.sv                 DIFFERENT -> EQUAL § unboundEventImplicitNet403, § unboundEventWaitSpan403
    chapter-12/12.4.2--unique0_if.sv        DIFFERENT -> EQUAL      § unique0IfIsUnique403
    chapter-5/5.12-attributes-operator.sv   DIFFERENT -> EQUAL      § operatorAttrsListed403
    chapter-5/5.12-attributes-conditional.sv DIFFERENT -> EQUAL     § operatorAttrsListed403
    chapter-18/18.12--randomization-of-scope-variables_0.sv          DIFFERENT -> EQUAL § stdRandomizeIsScopeRef403
    chapter-18/18.12.1--adding-constraints-to-scope-variables_0.sv   DIFFERENT -> EQUAL § stdRandomizeIsScopeRef403
    chapter-5/5.7.1--integers-underscores.sv DIFFERENT -> EQUAL     § sizeTickSpaceDropped403
    uvm/uvm_files.sv                        DIFFERENT -> STRICT_NOTEQUAL (fresh row `uvm/uvm_files.sv,STRICT_NOTEQUAL,differ:col(4),differ:col(4)`) § foreachUnitImportElemVar403, § oobCtorHoistSourceOrder403, § dottedPropRootUnitImport403

(The intermediate binary 9cf9a6c7 read the same sixteen with 0 regressions
and 0 changes; it ran while the sister's runners were live.)

Goal 1 (SURELOG_ONLY rows whose detail is the exporter's own message):
* chapter-12/12.6.1--case_pattern.sv, casex, casez ('statement kind:
  PatternCase'): -> EQUAL [§ patternCaseNoItems403].
* chapter-12/12.6.2--if_pattern.sv ('complex if condition') and
  12.6.3--conditional_pattern.sv ('complex conditional'): -> EQUAL
  [§ matchesOpPattern403, § patternVarImplicitNet403].
* generated/hdlconv_std2017/hdlconvertor_std2017_p728.sv ('user function
  call'): -> DIFFERENT [§ unitFwdCallNoLink403]; next head: Surelog lists no
  $unit task (our design-level vpiTaskFunc has `task t`), sister ground.
* generated/black-parrot/*.sv (6): stay SURELOG_CRASH, the size guard above.
* generated/rsd/rsd.sv: 'member access base' was already cleared by pass 401
  (SURELOG_CRASH, slang side accepted); nothing to do.
* The other exporter messages in SURELOG_ONLY rows are not this ground:
  chapter-16/16.10--property-local-var.sv, -fail, -uvm ('assertion expr kind:
  SequenceWithMatch', ModuleEmit), generic/typedef/typedef_test_13.sv
  ('typedef target: AssociativeArrayType', TypeEmit),
  generated/basejump/bsg_mem_1r1w_sync_from_1rw_sync ('continuous assign
  form', ModuleEmit), generated/tnoc/tnoc.sv ('expression kind: Invalid', the
  tnoc exit 4 assigned to the sister).  Every other SURELOG_ONLY detail is an
  upstream slang diagnostic (`error:` lines: should_fail tests, keywords
  used as identifiers, missing modules, duplicate definitions, ...).

Goal 2:
* chapter-15/15.5.1--named-event-trigger-blocking.sv, -non-blocking and
  15.5.2--named-event-wait.sv: DIFFERENT -> EQUAL [§ unboundEventImplicitNet403,
  § unboundEventWaitSpan403].
* chapter-12/12.4.2--unique0_if.sv [§ unique0IfIsUnique403],
  chapter-5/5.12-attributes-operator.sv and -conditional.sv
  [§ operatorAttrsListed403], chapter-18/18.12--randomization-of-scope-variables_0.sv
  and 18.12.1--adding-constraints-to-scope-variables_0.sv
  [§ stdRandomizeIsScopeRef403], chapter-5/5.7.1--integers-underscores.sv
  [§ sizeTickSpaceDropped403]: see the sweep lines above.
* THE UVM ROWS (131 heads at uvm_init::idx at the base, evidence/
  svtests_heads_pristine.csv): § foreachUnitImportElemVar403 fixes the loop
  variable; the next heads were walked on a reduced pair (uvm_pkg.sv + a
  two-line test, drivers/ux.sh, the sv-tests recipe): uvm_phase::add's
  `foreach (m_end_node.m_successors[succ])` [§ dottedPropRootUnitImport403],
  then the package variable list (rh before error_str)
  [§ oobCtorHoistSourceOrder403], then the package Task_funcs listing
  (uvm_packer::get_packed_bytes/ints/longints at the macro expansion)
  [§ pkgTfMacroDefAtExpansion403]; after these uvm_pkg itself is equal and the
  first difference is in the MODULE's materialized copy of the imported
  package (sister ground, below).  uvm/uvm_files.sv converts to
  STRICT_NOTEQUAL.  The remaining UVM heads after this pass: the 131 rows whose head was uvm_init::idx at the base all stay
DIFFERENT with the first difference moved off this ground (uvm/uvm_files.sv,
whose head was the package variable order error_str/rh, converts to
STRICT_NOTEQUAL): 106 at a $unit class's (or the module's) materialized
copy of the imported uvm_pkg parameters (`class_defn(work@env) >
parameter(UVM_ALL_ON) > ref_typespec > bit_typespec(uvm_field_flag_t)` in
golden, the same parameter under the module in ours), 11 at a logic_typespec
of the same materialization, 8 at class listings (class_defn order: uvm_agent vs
work@C, packet_out, sequencer, uvm_sequence_library), 3 at the design's top-level listing, 2 at
uvm_reg_block::find_blocks' formal (ref_var vs class_var), 1 constant
(evidence/svtests_heads_law.csv).

## Corpus gates (law sweep tests/sweep.sh --jobs 3, final binary)

tests/sweep.sh --jobs 3 (probe, surelog, uhdm2rtlil, downstream) from the
worktree with the final binary, sv-tests stage as above:

* probe: regressions 0, conversions 0, changes 0 (4018 EQUAL + 69
  STRICT_NOTEQUAL, the csv identical to the pristine sweep's row for row);
  byte compare 0 of 4087 databases moved.
* surelog: regressions 0, conversions 0, changes 0 (default 480 + 0,
  testflags 474 + 0, Tnoc d/t CMP_NOTEQUAL as at the base); the csv equal to
  the pristine sweep's except the LowMemLib/LowMemPkg testflags detail text
  (the workdir path, environment); byteverify MOVERS 0 / 962, SELFCHECK
  961 / 962 flagged.
* uhdm2rtlil: regressions 0, conversions 0, changes 0 (803/1/67 both
  modes), the csv identical; byteverify MOVERS 0 / 1608 (SELFCHECK 1607).
* downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0
  DIVERGENT of 871, not identical and not excused 0; byteverify MOVERS
  0 / 805 (SELFCHECK 804).
* canaries: canaries.sh ok=52 changed=0 (surelog) and ok=16 changed=0
  (uhdm2rtlil); ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6).
* binary audit: every `slang` line of every cmds.txt of the law sweep names
  the final law binary (5619 of 5619), the pristine sweep the pristine
  binary (5619 of 5619).
* No corpus row, probe case or downstream row moves a byte, so there is no
  mover to attribute; the prediction from the trace census below (no law
  fires outside sv-tests) is the reason.

## Trace census (R11U403_TRACE over the whole law sweep)

Over every process of the final law sweep (176 trace files, all from the
sv-tests stage; NONE from the probe, surelog, uhdm2rtlil or downstream
stages): oobCtorHoistSourceOrder403 on 156 rows (the UVM rows' uvm_pkg and
their importer packages), foreachUnitImportElemVar403 on 135 rows,
dottedPropRootUnitImport403 on 134, macroVecLitTokenText403_GUARD on the six
black-parrot rows only (the law itself fires on no row), stdRandomizeIsScopeRef403
4 firings / 2 rows, patternCaseNoItems403 3 rows, unboundEventImplicitNet403
3 rows, matchesOpPattern403 2, operatorAttrsListed403 2,
patternVarImplicitNet403 1, unboundEventWaitSpan403 1, sizeTickSpaceDropped403 1,
unitFwdCallNoLink403 1; pkgTfMacroDefAtExpansion403 carries no trace (a
comparator).  The intermediate binary's sweep showed unboundEventImplicitNet403
firing 3 times on probe case r10uvm101repro/g101_a3_tokens (`-> h.own`) with no
byte change; the final binary's fence removes those firings.

AWAY CENSUS (drivers/away.sh, evidence/away_census.txt): on the 170 non-black-parrot
sv-tests rows where a law fired, the order-blind normalised dump diff against
golden, pristine vs law: 130 rows move toward golden (1364 lines), 21 are
unchanged in count (the order laws reorder without changing the multiset),
13 have no kept database (converted to EQUAL, or rejected on the pristine
side), and 6 grow: hdlconvertor_std2017_p728 (42 -> 53: pristine rejected
the call and wrote nothing, the law writes the func_call inside the $unit
task golden does not list at all, sister ground), and five UVM rows
(easyUVM/top +8, uvm_component_class_1 +24, uvm_many_to_one +6,
uvm_use_models_pipelined_get_put +3, testbenches/uvm_agent_active +4) where
every WALKED line moved to golden's shape (class_var uvm_init::idx bound to
class_typespec uvm_object_wrapper, int_var uvm_phase::add::succ, golden
holding exactly two of each) and the growth is entirely in the
weaklyReferenced tail (the element class_typespec and two int_typespec
objects listed at depth 0), which neither uhdm-cmp nor the strict walk reads.

## Residues on this ground, ranked

1. The UVM rows' remaining heads after this pass are on the module/type
   ground (below); on this ground the pass-401 residues stand: the lone
   declaration body (§ loneVarDeclStmtDropped401 too broad: the assignment
   half is ours, the function Variables listing is TaskFuncEmit's).
2. § matchesOpPattern403 abstains on named structure patterns (golden: a
   ref_obj `val1.val2` over the whole pattern bound to a minted implicit
   net `val1.val2`; cases/PM pm08), nested lists, bare constant patterns.
3. FE fe06: an EXPLICIT $unit import of a package item makes every other
   package-array loop variable the int_var fallback in golden (and the
   imported one array_var).
4. ML ml01 endcol: the macro-argument span of a pasted literal.
5. Singletons decoded and left: chapter-20/20.6--typename_type.sv
   ($typename(logic) folds to the STRING constant `logic`),
   generic/class/class_test_51.sv ($bits(int) folds to 32 spanning `$bits`
   in a class localparam replication, and the replication's concat constant
   unparented), chapter-6/6.19--enum_xx.sv, chapter-5/5.10 and 5.11
   replication sizes, hdlconvertor_std2017_p600 (a `1'b1` range bound),
   generated/scr1 and fx68k hier_path heads (large, many faces).

## Sister-ground faces (reported, not written)

* UhdmExporter.cpp / ModuleEmit.cpp (the materialized imported parameters,
  ModuleEmit `cp->VpiImported(pkgName)` and UhdmExporter's two
  `cp->VpiImported(pkgName)` sites): a module's copy of uvm_pkg's
  `parameter uvm_field_flag_t UVM_ALL_ON` binds golden's bit_typespec
  uvm_field_flag_t where ours binds an int_typespec over the written type
  name — the next head of the simple UVM rows (drivers/ux.sh case a).
* The $unit class with UVM macros lists the $unit-imported package variables
  as its own vpiVariables (work@my_c::uvm_aa_string_key ...) — the next head
  of the UVM rows that declare $unit classes (case b), class emission.
* TaskFuncEmit (the design-level Task_funcs): Surelog lists no $unit TASK
  (cases/UF uf01, hdlconvertor_std2017_p728.sv).
* TaskFuncEmit: a class's out-of-body method listing under a $unit import
  (cases/FD heads), and the lone-declaration body's local missing from the
  function's Variables (v11u401repro VD/vs01-vs03, class_member_test_27).
* The module's materialized copy of an imported fixed array of class handles
  (cases/FE fe05).
* Class property initializers with a based literal (`int a = 1'b1;` golden
  keeps the literal 1'b1, ours the converted 1/32/UINT; class_test_56..58).
* hdlconvertor_std2017_p733: a defparam in a separate top module is ignored
  by Surelog; p489: port nets.

## Process

* The implementer's slips: (1) source edits landed while a build compiled the
  same translation units (StmtEmit, EmitHelpers.h); every binary used for a
  measurement was rebuilt from a touched tree afterwards, and the final binary
  was reproduced by a full rebuild of all four files (equal md5). (2) A
  `pkill -f 'cmake --build build -j 2'` meant for my own build matched the
  sister pass's wrapper shell running the same command line in
  /tmp/wt_r11u404 at about 13:11; its make kept running and it relaunched a
  build at 13:11:49; no other process of the sister's was touched, and my own
  build was then left to finish rather than killed. (3) The intermediate law
  sweep (binary 4, before the last laws) and the law-9 sweep ran their
  sv-tests stage while the sister's svtests_matrix runners were live (load
  only; no TIMEOUT change was printed). (4) The pristine sweep's corpus
  stages read the law index stale (rc 1) because sources were edited during
  it; numbers unaffected.
* The sv-tests stage runs through the main tree's scripts/check_svtests.py
  read-only (a worktree has no UVM tree under third_party), with the
  worktree's results/golden_svtests.csv as baseline.
* § unboundEventImplicitNet403 first fired on any dotted trigger path; the
  law-9 sweep's trace showed it firing on probe case
  r10uvm101repro/g101_a3_tokens (`-> h.own`, h a class handle) with no byte
  change; the law was fenced to slang HierarchicalValue targets and the final
  sweep rerun with that binary.
