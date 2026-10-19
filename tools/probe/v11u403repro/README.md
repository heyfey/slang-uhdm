# v11u403 — adversarial verification of r11u403

Verifier of the implementer pass r11u403 (the sv-tests campaign's second pass
on the expression/parameter ground: src/ExprEmit.cpp, src/EmitHelpers.h,
src/StmtEmit.cpp, src/ParamEmit.cpp), base c51d5b5f.

VERDICT: ACCEPT, no refinement. Every headline number reproduces exactly, and
no fresh case breaks a law. In 67 fresh case dirs, no case that pristine got
right turned wrong. No production change is made here: there is no fixOn(403,
...) and no R11V403 switch. This directory adds the evidence and the cases.

## Binaries (built here, frozen before any measurement)

* pristine: fresh worktree at c51d5b5f, `cmake --build build -j 2`, md5
  d90254f4ad18ac702ba763d6a8f7854b (equal to the main tree's build/slang-uhdm),
  frozen at /tmp/v11u403_pristine.bin.
* law: a fresh c51d5b5f worktree plus /tmp/r11u403.patch, which applies clean,
  built the same way. md5 da9ae4cb9ce0fc8c71f8287efd301267, equal to the
  implementer's /tmp/r11u403_law10.bin. Frozen at /tmp/v11u403_law.bin.
  The binary reports slang 12.0.0+545f88b2e.
* Patch audit (the no-header rule): the added lines hold no src/R*.h, no
  getenv, no LawState section and no reader function. Every switch is read
  through lawOn(403, "R11U403_<X>_OFF") from src/LawSwitch.h. There are 16
  switches, MACROLITGUARD included.

## Gates reproduced (tests/sweep.sh --jobs 3, one sweep per binary, workdirs /tmp/v11u403_wdP and /tmp/v11u403_wdL)

| stage | pristine | law | verdict |
|---|---|---|---|
| probe | 4018 EQUAL + 69 STRICT_NOTEQUAL, 0/0/0 | the same, 0/0/0, csv identical row for row | 0 of 4087 databases moved (normalised dump, worktree prefix stripped; the raw bytes carry the worktree path) |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | the same, 0/0/0 | byteverify MOVERS 0 / 962, SELFCHECK 961 / 962 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | the same | byteverify 0 / 1608, SELFCHECK 1607 / 1608 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 | the same, csv identical | byteverify 0 / 805, SELFCHECK 804 / 805 |
| sv-tests | EQUAL 1240, STRICT_NOTEQUAL 20, DIFFERENT 668, BOTH_REJECT 303, SURELOG_ONLY 87, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; 0/0/0 (the baseline exactly) | EQUAL 1254, STRICT_NOTEQUAL 21, DIFFERENT 659, SURELOG_ONLY 81, the rest unchanged; regressions 0, conversions 16, changes 0 | the 16 rows below, the same as the implementer's |

* The surelog csvs differ only in the LowMemLib/LowMemPkg testflags detail
  text, which holds the workdir path (environment). The uhdm2rtlil and
  downstream csvs are identical.
* Canaries on the law csvs: canaries.sh ok=52 changed=0 (surelog) and
  ok=16 changed=0 (uhdm2rtlil). ctcan2 PASS on both: ok=58 with unknown 1, and
  ok=2 with unknown 6.
* Binary audit:
  * corpus stages: 3273 of the 3323 cmds.txt name the sweep's own binary and
    0 name the other binary. The remaining 50 have no slang line.
  * sv-tests stage: 2346 of 2346 slang lines name the sweep's own binary.
* Both sweeps exit rc=1 only because `law_index.py --check` reads
  tests/LAWS.md stale. It reads stale at the base too, in the main tree and in a
  pristine worktree. A committed LAWS.md cannot carry its own commit hash, so
  regenerating it on the base adds 'commits: c51d5b5f4' and corpus-test lines
  for the 401 laws. The index is regenerated last in the verified patch.
* The sv-tests stage was run through the main tree's
  scripts/check_svtests.py, read-only, for the same reason the implementer
  gave: a worktree has no UVM tree.
  * Neither stage overlapped another sv-tests runner. Before each launch the
    stage waited until no check_svtests or svtests_matrix process was live.
  * The sister verifier's away-census dumps (uhdm-dump only) were running
    during the pristine stage.

### sv-tests conversions (law stage, fresh rows, every one traced)

    chapter-12/12.4.2--unique0_if.sv                     DIFFERENT -> EQUAL        § unique0IfIsUnique403
    chapter-12/12.6.1--case_pattern.sv                   SURELOG_ONLY -> EQUAL     § patternCaseNoItems403
    chapter-12/12.6.1--casex_pattern.sv                  SURELOG_ONLY -> EQUAL     § patternCaseNoItems403
    chapter-12/12.6.1--casez_pattern.sv                  SURELOG_ONLY -> EQUAL     § patternCaseNoItems403
    chapter-12/12.6.2--if_pattern.sv                     SURELOG_ONLY -> EQUAL     § matchesOpPattern403, § patternVarImplicitNet403
    chapter-12/12.6.3--conditional_pattern.sv            SURELOG_ONLY -> EQUAL     § matchesOpPattern403
    chapter-15/15.5.1--named-event-trigger-blocking.sv   DIFFERENT -> EQUAL        § unboundEventImplicitNet403
    chapter-15/15.5.1--named-event-trigger-non-blocking.sv DIFFERENT -> EQUAL      § unboundEventImplicitNet403
    chapter-15/15.5.2--named-event-wait.sv               DIFFERENT -> EQUAL        § unboundEventImplicitNet403, § unboundEventWaitSpan403
    chapter-18/18.12--randomization-of-scope-variables_0.sv        DIFFERENT -> EQUAL § stdRandomizeIsScopeRef403
    chapter-18/18.12.1--adding-constraints-to-scope-variables_0.sv DIFFERENT -> EQUAL § stdRandomizeIsScopeRef403
    chapter-5/5.12-attributes-conditional.sv             DIFFERENT -> EQUAL        § operatorAttrsListed403
    chapter-5/5.12-attributes-operator.sv                DIFFERENT -> EQUAL        § operatorAttrsListed403
    chapter-5/5.7.1--integers-underscores.sv             DIFFERENT -> EQUAL        § sizeTickSpaceDropped403
    generated/hdlconv_std2017/hdlconvertor_std2017_p728.sv SURELOG_ONLY -> DIFFERENT § unitFwdCallNoLink403
    uvm/uvm_files.sv                                     DIFFERENT -> STRICT_NOTEQUAL § foreachUnitImportElemVar403, § oobCtorHoistSourceOrder403, § dottedPropRootUnitImport403
    fresh row: uvm/uvm_files.sv,STRICT_NOTEQUAL,differ:col(4),differ:col(4)

* The pristine and law sv-tests csvs differ on exactly these 16 rows. No
  other row's status, detail or strict column moved.
* Trace census, from R11U403_TRACE over the law stage (176 trace files):
  * oobCtorHoistSourceOrder403 on 156 rows, foreachUnitImportElemVar403 on
    135 and dottedPropRootUnitImport403 on 134.
  * macroVecLitTokenText403_GUARD on the six black-parrot rows (src 3.6 to
    3.8 MB). The law itself fires on no row.
  * The rest: stdRandomizeIsScopeRef403 4, patternCaseNoItems403 3,
    unboundEventImplicitNet403 3, operatorAttrsListed403 2,
    matchesOpPattern403 2, unitFwdCallNoLink403 1, unboundEventWaitSpan403 1,
    sizeTickSpaceDropped403 1, patternVarImplicitNet403 1.
  * This equals the implementer's census.
* Corpus stages: no R11U403 trace file at all.
  * Positive control for the harness path: the same verify_golden.py run on
    SimpleUVM with R11U401_TRACE and R11U403_TRACE set writes two
    bitsBlockLocalKeepsCall401 files (four firings) and no 403 file.
  * Positive control for the mechanism: PM/pm01 under R11U403_TRACE writes
    matchesOpPattern403 and patternVarImplicitNet403.
* Black-parrot: the six rows read SURELOG_CRASH on both binaries. The guard
  fires on each, so the law binary exports nothing for them, as pristine does.
  The size guard is what keeps the gate at 0 regressions. The memory bound
  (10 to 11 GB per row, and the two bp_multicore_4 rows killed even alone)
  was not re-measured here.
* Away census: evidence/away.txt, drivers/away.sh. It covers every sv-tests
  row where a law fired whose databases the runner kept, and compares the
  order-blind normalised dump diff against golden, pristine vs law.
  * Totals: 130 rows move toward golden (1364 lines), 21 are unchanged in
    count and 19 have no kept database (13 converted or pristine-rejected,
    plus the 6 black-parrot rows).
  * 6 grow, the same rows and deltas the implementer reported:
    * p728 42 -> 53: the $unit task that Surelog does not list.
    * The five UVM rows easyUVM/top +8, uvm_component_class_1 +24,
      uvm_many_to_one +6, uvm_use_models_pipelined_get_put +3 and
      testbenches/uvm_agent_active +4.
  * On uvm_component_class_1, a line-multiset check finds exactly 4 lines
    further from golden. They are one more uvm_object_wrapper class_typespec
    object and its class_defn reference. Each copy sits at depth 0 after
    `\_weaklyReferenced:` (line 1155091 of 1161356, after the tail starts
    at 1075549), and neither comparator reads that tail.

## Grid reproduced

The implementer's 49 case dirs, rerun with both frozen binaries
(evidence/grid_impl.txt), reproduce evidence/grid.txt of r11u403repro line
for line. The 31 NOT_EQUAL -> STRICT_EQUAL cases, ml01 NOT_EQUAL ->
STRICT_NOTEQUAL endcol, the 7 unchanged equal cases and the 10 NOT_EQUAL on
both all read as reported.

## Attack (cases/, 67 fresh case dirs in 14 groups; evidence/grid_v.txt)

Recipe: the probe recipe (Surelog -parse -nobuiltin -nocache -sv dut.sv
-mt 0 -mp 0 against slang-uhdm dut.sv --single-unit --nobuiltin), goldens built
per case by drivers/rc.sh. Every line carries rc. Totals, pristine -> law:

| pristine -> law | cases |
|---|---|
| NOT_EQUAL -> STRICT_EQUAL | 44 |
| NOT_EQUAL -> STRICT_NOTEQUAL | 1 |
| STRICT_EQUAL -> STRICT_EQUAL | 10, all byte-identical |
| NOT_EQUAL -> NOT_EQUAL | 12 |
| leaving an equal status | none |
| law bytes moved where pristine was right | none |

* Switches (drivers/sw.sh, the implementer's 49 cases plus these 67, 116 case
  dirs):
  * `R11U403_OFF=1` gives pristine's bytes and exit code on 116 of 116.
  * Each group's own switch(es) give pristine's bytes and exit code on 116 of
    116.
* Downstream (drivers/ds.py, ds.one with the downstream flags, the 50
  class-free fresh cases; evidence/ds_P.txt, ds_L.txt):
  * 21 EQUIVALENT -> IDENTICAL and 2 DIVERGENT -> IDENTICAL (vf02, vl03).
  * 25 IDENTICAL -> IDENTICAL and 2 EQUIVALENT -> EQUIVALENT (va04, vf05).
  * None worse.

Per group (law named by each case's first line):

* VA § operatorAttrsListed403:
  * va02 (two attributes, one bare, in a continuous assign), va03 (nested
    operators each with its own attribute) and va05 (bare attribute on a
    conditional in always_comb): NOT_EQUAL -> STRICT_EQUAL.
  * va01 (integer-valued attribute): the abstention, bytes identical.
  * va04 (attribute inside a folded parameter value): NOT_EQUAL on both; the
    law moves toward golden (dump diff 20 -> 13 lines). Golden hangs the
    attribute on the net that reads the parameter, a residue.
* VC, VP § patternCaseNoItems403: unique case-matches in a function, priority
  casez-matches in always_comb with a begin, case-matches in a class method,
  and unique casex-matches with a wildcard constant pattern. All rc 4
  NOT_EQUAL -> rc 0 STRICT_EQUAL.
* VM § matchesOpPattern403 / § patternVarImplicitNet403:
  * NOT_EQUAL -> STRICT_EQUAL on:
    * the body shapes: a begin body (vm01), an else-if chain with a void member
      (vm02) and a named begin with an else begin (vm11);
    * the binding shapes: a function in a module (vm03), a `&&&` guard reading
      the pattern variable (vm04) and the class method, where no implicit net
      is minted (vm09);
    * the shadowing shapes: a pattern variable shadowing a module `logic`
      variable (vm05) or a module wire (vm08) of the same name;
    * the remaining forms: a continuous-assign conditional (vm06) and a
      `.*` member (vm07).
  * vm10, a LABELED else branch (`else lbl: y = 3;`): rc 4 -> rc 0, NOT_EQUAL
    on both binaries. The law's unwrap drops the label, where golden names the
    assignment `lbl` and its ref `work@top.lbl.y`. The plain-if control vm12
    shows pristine already writes a named_begin there, so the labeled-statement
    face is a pre-existing residue and not this law's break (pristine rejected
    vm10).
* VE § unboundEventImplicitNet403 / § unboundEventWaitSpan403:
  * NOT_EQUAL -> STRICT_EQUAL on:
    * the trigger and wait forms: a downward trigger through an instance
      `-> u.e` (ve01), wait plus trigger on the same root (ve04, the minted
      net reused) and a nonblocking `->>` upward (ve05);
    * the procedural contexts: a trigger inside a task (ve07) and `always
      @top.e` (ve09).
  * Byte-identical: `@(u.e)` downward (ve02), a parenthesised upward wait
    (ve06) and a trigger in a class method, where no module is in scope (ve08).
  * ve03, a trigger into a generate block `-> g.e`: NOT_EQUAL on both. The law
    adds golden's implicit net `g` (cmp 123 -> 53). The rest is the gen-scope
    event listing (module ground), a residue.
* VF § unitFwdCallNoLink403:
  * vf02 (backward and forward $unit calls in one body): rc 4 -> rc 0
    STRICT_EQUAL.
  * Byte-identical: vf01 (a $unit class method calling a later $unit
    function), vf03 (a module calling a later $unit function) and vf04
    (recursion).
  * vf05 (a $unit task calling a later function) and vf06 (the forward call
    in a parameter default): rc 4 -> rc 0, NOT_EQUAL on both. vf05's next head
    is the $unit task, which Surelog does not list, and a module's call to it,
    which golden writes as a func_call. Both are TaskFuncEmit faces, as
    reported for p728. vf06's remaining head is the folded parameter constant
    INT where golden has UINT (parameter ground, pre-existing).
* VI § foreachUnitImportElemVar403:
  * NOT_EQUAL -> STRICT_EQUAL on a package function over a dynamic array
    (vi01), the $unit import written AFTER the module at the end of the file
    (vi03), and two packages of which only one is imported (vi04, the other
    keeps array_var).
  * Byte-identical: the int queue control (vi02), a class method in the
    package (vi05, already equal) and an associative array (vi06, NOT_EQUAL on
    both at a ref_typespec head, the loop variable equal).
* VD § dottedPropRootUnitImport403: an explicit `this.m.s[i]` root (vd01), an
  in-body method (vd02) and an element-select root `m[0].s[i]` (vd03).
  * All three are byte-identical across the two binaries.
  * The loop-variable census (drivers/lv.py of r11u403repro) reads 0
    differences on all three.
  * The vd01 and vd03 heads are elsewhere and pre-existing.
* VH § oobCtorHoistSourceOrder403:
  * vh01 (an included constructor body between two inline ones):
    NOT_EQUAL -> STRICT_EQUAL.
  * vh02 (nested includes): the package variable order becomes golden's
    (dd, bb, e, t). The dump diff against golden shrinks from 979 to 344
    lines, while uhdm-cmp's first-object print grows (66 -> 1296) because the
    first difference moved later. The new head is golden's class_defn
    listing, which copies the package-hoisted constructor locals into each
    class (p::A::dd, p::A::bb, ...); we list none on either binary. This is a
    residue at the class listing.
* VO § pkgTfMacroDefAtExpansion403:
  * vo02 (an out-of-body definition by macro, interleaved with plain ones) and
    vo03 (one macro writing two definitions): NOT_EQUAL -> STRICT_EQUAL.
  * vo01 (package functions, not out-of-body, written by a macro): already
    equal, byte-identical.
* VQ § unique0IfIsUnique403: an else-if chain (vq01), unique0 case beside a
  unique0 if (vq02, the case keeps no qualifier, as Surelog's compileCaseStmt
  maps paUNIQUE0 to vpiNoQualifier) and a function (vq03). All three
  NOT_EQUAL -> STRICT_EQUAL.
* VS § stdRandomizeIsScopeRef403:
  * `if (!std::randomize(a, b))` (vs01), a class with a with-block (vs02),
    no arguments (vs03, rc 4 -> 0), two with-blocks in one module (vs04, one
    net), a void cast (vs05), a package function (vs06) and a module task
    with a declared `wire std` (vs07).
  * All NOT_EQUAL -> STRICT_EQUAL.
* VZ § sizeTickSpaceDropped403: a signed literal and two blanks (vz01),
  parameters and a continuous assign (vz02), a case item (vz03), and 64-bit
  and unsized forms (vz04). All NOT_EQUAL -> STRICT_EQUAL. A TAB between the
  size and the tick is a Surelog syntax error (PA0207), so no case uses it.
* VL § macroVecLitTokenText403:
  * vl01 (a pasted macro argument in a casez item with a wildcard literal):
    NOT_EQUAL -> STRICT_EQUAL.
  * vl03 (a size pasted onto the tick, `` n``'d5 ``): NOT_EQUAL ->
    STRICT_NOTEQUAL endline, the macro-span model, as ml01.
  * vl02 (literals as plain macro arguments): byte-identical.

## Residues (ranked, all wrong on pristine too)

1. The UVM rows' next heads are on the module/type ground, as the
   implementer reports (UVM_ALL_ON copies and class listings).
2. The class_defn listing of package-hoisted constructor locals (vh02). Golden
   lists them under every class of the package, and we list none.
3. A labeled statement: golden names the statement itself. Pristine writes a
   named_begin (vm12), and inside a pattern-if else the law's unwrap drops the
   label (vm10).
4. An attribute on an operator inside a folded parameter value (va04).
5. A trigger into a generate block: the gen-scope event listing (ve03).
6. The implementer's own: pm08 named structure patterns, fe06 explicit $unit
   import, the ml01/vl03 macro spans, and the singletons it lists.

## Sister-ground faces (reported, not written)

* TaskFuncEmit: Surelog lists no $unit task, and writes a module's call to a
  $unit task as a func_call (vf05; p728).
* The class_defn variables listing of hoisted constructor locals (vh02).
* The gen-scope named event (ve03).

## Process

* Two waits written as `until [ -z "$(pgrep -f '...check_svtests...')" ]`
  matched their own shells' command lines, so they never ended. They were
  stopped by task id, a slip already recorded by pass 401. The sv-tests driver
  drivers/svt.sh ran its own check in a script whose command line holds none
  of the pattern words. No measurement was affected.
* Nothing was written outside /tmp/wt_v11u403, /tmp/wt_v11u403pris and
  /tmp/v11u403_*. No process of another agent was touched. No fenced name
  was dispatched: the sweeps use the harness's own filters.
