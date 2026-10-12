# v11u300 — adversarial verification of r11u300 (pass 300, expression/parameter ground)

Base 142a850e. Verified patch surface: src/ExprEmit.cpp, src/StmtEmit.cpp, src/R300.h (the implementer's law
§ pkgRetCallFoldSharesCalleeRet300) plus the verifier's refinement § retShareActualFoldAbstain300v in
src/ExprEmit.cpp (inside the law's site) and src/R300.h, and this directory.

Binaries, all built here with the system-deps config at -j 1, frozen (chmod 555) under /tmp/v11u300_bin before any
measurement: pristine 44bee4bc45377433566d9695a8897241 (equal to the main tree's build/slang-uhdm), law
bfc751431b6887cd6400213d3a94a64c (equal to the implementer's), fix a9d5e63753b2720c752db3d5da60c73e (rebuilt from
the verified patch on a fresh 142a850e: same md5). Every binary reports slang 12.0.0+545f88b2e.

## Verdict

**The law is right on its five probe conversions and on the gate, but it BREAKS legal SystemVerilog where pristine
was right.** 10 fresh case-views leave pristine's golden-agreeing bytes: 8 leave STRICT_EQUAL in the elaborated
view, with chain away 1 each, uhdm-cmp going 0 -> 58 lines, and 3 downstream IDENTICAL -> DIVERGENT. The verifier's
refinement **§ retShareActualFoldAbstain300v** (R11V300_ACTFOLD_OFF) fixes every one of them. The fix binary keeps
every gate number of the law bit for bit:

- probe 3989 + 98 with regressions 0, conversions 5 and changes 0;
- surelog 480 + 0 / 474 + 0 and uhdm2rtlil 803/1/67 in both modes, regressions, conversions and changes 0;
- downstream 803/66/2/0, the csv byte-identical to results/downstream_uhdm2rtlil.csv;
- 0 of 2560 corpus, 0 of 805 downstream and 0 of 4087 probe databases moving fix vs law.

The five conversions (fresh rows, both law and fix sweeps):

| case | base | fresh row |
|---|---|---|
| r10buvm8repro/v9fold8 | differ:depth(1) | `r10buvm8repro/v9fold8,EQUAL,,equal` |
| r11v48repro/va8 | differ:depth(1) | `r11v48repro/va8,EQUAL,,equal` |
| r10uvm52repro/a1 | differ:depth(1) | `r10uvm52repro/a1,EQUAL,,equal` |
| r10buvm13repro/v3_clone13 | differ:depth(1) | `r10buvm13repro/v3_clone13,EQUAL,,equal` |
| r10buvm8repro/v3_argts8 | differ:type(1) | `r10buvm8repro/v3_argts8,EQUAL,,equal` |

## The break and the refinement

The law shares the callee's `a + 1` operation when "every written actual is a bare reference to a formal or local
of the caller". Surelog's EvalFunc (UHDM templates/ExprEval.cpp evalFunc) can instead VALUE the actual. reduceExpr's
vpiAddOp branch then folds the add to a fresh UINT constant at the call, which golden writes and pristine already
writes in the elaborated view. The law replaced that with the shared operation. There are two roads.

1. **A macro-born actual read as omitted.** The law decided `written` by source-range containment of the actual in
   the call. An actual from a macro argument lives in another buffer, so it read as an omitted default and skipped
   the bare-reference test. Witnesses (§ retShareActualFoldAbstain300v):
   - VA/va01 `` f(`ONE) ``;
   - VA/va02 `` f(`KK) `` with K a package parameter;
   - VA/va13 `` `CALLF(2) ``, the whole call in a macro;
   - VF/vf05, the same through parentheses;
   - VA/va16, a macro-born package parameter as the second actual.

   Golden folds each one (va01: `constant UINT:2` at 5:34-5:38 in uhdmtopPackages).
2. **A caller-package parameter of the same name.** evalFunc clones the param_assigns of the package being compiled
   (the CALLER's package) into its scope, and reduceExpr resolves a reference BY NAME there. A caller formal or local
   spelled like such a parameter therefore reads the parameter's value. Golden folds `f(x)` with `parameter int x = 3`
   to `UINT:4`. The same holds for a callee formal spelled like one: va22 golden `UINT:10` from `parameter b = 9`.
   Witnesses (§ retShareActualFoldAbstain300v):
   - VA/va04 (caller formal), VA/va14 (caller local), VA/va19 (localparam), VA/va17 (wildcard-imported parameter),
     VE/ve05 (a $unit parameter), VF/vf04 (parentheses);
   - VA/va05 and VA/va22 (callee formal; pristine wrong too);
   - VE/ve01 (an enum constant, golden `INT:1`; pristine wrong too).

   The boundary holds on its other side:
   - VA/va18: a name shared only with the CALLEE package's parameter still shares in golden.
   - VE/ve04: a parameter declared after the caller is not yet compiled and still shares.
   - VE/ve06: a kind-2 callee (`return $urandom();`) reads no actual and shares even with a macro constant.
   - VA/va21: a package variable of the same name still shares.

**§ retShareActualFoldAbstain300v** (v11u300; R11V300_ACTFOLD_OFF; R11V300_OFF drops it and gives the law's bytes on
206 of 206 fresh case-views, R11U300_OFF still gives pristine's). It applies to kind-1 shares (the add) only:

- A positional call writes the first N arguments of its syntax list. That list is read through slang's
  ParenthesizedExpression (`return (f(x));`, r11u300repro RS/s19, which a first draft broke) and off a shell via
  § shellCallKeepsItsSyntax167's callInvocation167.
- A named call writes every argument it names, and abstains when it omits any.
- Every written actual must be a bare reference to the caller's formal or non-const local.
- No checked actual and no callee formal may be spelled like a Parameter or EnumValue that `lookupName` finds from
  the caller's package at the caller (`LookupLocation::before(caller)`).

When it stands aside where the law would have shared, it traces `ACTFOLD300V <caller>-><callee> <why>` under
R11U300_TRACE. The census below shows it fires nowhere in the gate. The positive control on va01 traces
`ACTFOLD300V c->f arg-kind`.

## Measurements

1. **Reproduction of the implementer's grid** (evidence/impl_grid_rerun_pris_law.txt): 168 case-views, 76 moving,
   66 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes. R11U300_OFF and R11U300_RETSHARE_OFF equal pristine on
   168 of 168. The verdict equals the implementer's grid.txt on every one of the 504 pristine/law/OFF lines (md5s
   differ only by the worktree path the databases embed). The fix equals the law on 168 of 168
   (evidence/impl_grid_law_vs_fix.txt).
2. **Fresh attack grid**: 103 case dirs in VA (actuals), VB (callee shapes and types), VC (contexts), VD (scopes),
   VE and VF (refinement boundaries). That is 206 case-views, every line with its exit code (all rc=0).
   Every case file's first line names its law: `// § pkgRetCallFoldSharesCalleeRet300` for the law's shapes, and
   `// § retShareActualFoldAbstain300v` for the refinement's witnesses and boundaries
   (va01, va02, va04, va05, va13, va14, va16 to va23, VE, VF).
   - Law vs pristine (evidence/grid_law.txt, grid_law_summary.txt): 186 moving, 140 entering STRICT_EQUAL,
     **8 leaving STRICT_EQUAL** (va01, va02, va04, va13, va14, va19, vf04 and vf05, all in the e view), 0 exit-code
     changes. Chain-keyed away census (evidence/grid_away_law.txt): **away 1 on 10 movers** (those 8, va17 e and
     ve05 e), 384 records toward golden.
   - Fix vs pristine (evidence/grid_fix.txt, grid_fix_summary.txt): 158 moving, 140 entering STRICT_EQUAL,
     0 leaving, 0 exit-code changes. Chain away 0 on all 158 (evidence/grid_away_fix.txt), 374 records toward golden.
   - Fix vs law: 28 case-views differ (va01, va02, va04, va05, va13, va14, va16, va17, va19, va22, ve01, ve05, vf04
     and vf05, both views). Each one carries pristine's exact bytes, and R11V300_ACTFOLD_OFF and R11V300_OFF each
     restore the law's bytes on 206 of 206.
   - uhdm-cmp line count growing on the fix: only VC/vc08 `return $bits(f(x));` (56 -> 68 in both views). The first
     difference is the same on both binaries: golden folds `$bits(...)` to `constant UINT:0` at 5:34-5:45. The
     extra lines are the shared operation printed under the RHS sys_func_call. Chain away is 0.
3. **Downstream on the fresh cases** (drivers/dscases.py, evidence/downstream_cases.txt, downstream_transitions.txt),
   pristine -> law -> fix over 103 dirs:
   - 49 DIVERGENT -> IDENTICAL -> IDENTICAL;
   - 7 EQUIVALENT -> IDENTICAL -> IDENTICAL;
   - 26 IDENTICAL on all three;
   - 16 DIVERGENT on all three;
   - **3 IDENTICAL -> DIVERGENT -> IDENTICAL** (va01, va13 and vf05: the law's downstream breaks, fixed);
   - 2 DIVERGENT -> IDENTICAL -> DIVERGENT (va16 and ve01, where pristine and golden disagree in the strict walk on
     every binary). The refinement gives back pristine's bytes there, as golden folds and neither shares.
4. **Byte controls** (drivers/ctlsel.sh, evidence/control_dirs.txt, controls_summary.txt), pristine vs fix:
   - The set is 4231 case dirs (8462 case-views): every tools/probe dir whose dut.sv holds `package`, `function`
     and `return` (3455), plus the implementer's 958. The path list was filtered by $FENCED before any file was
     opened.
   - **0 moving.** 26 case-views write no database or have no golden on both binaries.
   - Positive control (evidence/controls_poscontrol.txt): the same driver flags VB/vb02 d/e and leaves va01 and ve08
     unmoved.
5. **Firing census on the frozen fix binary, before the fix sweep** (drivers/tracecensus.sh,
   evidence/predict_fix.txt): byte-identical to the implementer's predict.txt.
   - RETSHARE fires on exactly the five probe databases.
   - Everything else is RETSHARE_ABSTAIN, on 34 probe cases, 11 surelog row-modes and 2 uhdm2rtlil row-modes.
   - **ACTFOLD300V fires nowhere.** That predicts 0 gate databases moving fix vs law and the five probe movers
     fix vs pristine. Both were measured.
6. **Gate sweeps** (tests/sweep.sh --jobs 3, workdirs /tmp/v11u300_wd{P,L,F}; evidence/sweep_{P,L,F}.log):
   - pristine: 3984 + 103 / 480 + 0 / 474 + 0 / 803/1/67 both modes / 803/66/2/0, regressions 0 everywhere;
   - law and fix: 3989 + 98 with conversions 5 and changes 0, regressions 0 in all three stages; surelog and
     uhdm2rtlil conversions 0 and changes 0; downstream 803/66/2/0 with not identical and not excused 0;
   - row-by-row csv diff law vs pristine: only the five probe rows and the LowMem detail text (the workdir path);
     fix vs law: nothing;
   - every sweep exits 1 on the law-index check alone; the patch carries the regenerated tests/LAWS.md.
7. **Byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors
   (drivers/mirror.sh, mirrords.sh; 8 fenced corpus paths skipped by name)):
   - corpus 0 of 2560 for law vs pristine, fix vs law and fix vs pristine;
   - downstream 0 of 805 for the same three pairs;
   - probe: a direct cmp of the 4087 databases from sweeps run in the same worktree (pristine's probe stage rerun
     there as /tmp/v11u300_wdQ, evidence/sweep_Q_probe_pristine.log, 3984 + 103), exactly the five predicted law
     vs pristine and fix vs pristine, 0 fix vs law;
   - SELFCHECK reads 2559 of 2560 (804 of 805): the self-check compares every database against ONE fixed database
     of the other side, and that file's own twin is byte-identical when nothing moves, so it is the one path not
     flagged. This is the known artefact, not a mover.
8. **Canaries**: canaries.sh surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0, and ctcan2.sh PASS on both
   (EXPECT_UNKNOWN=1 and 6), for each of the three sweeps.
9. **Binary-path audit** (drivers/audit.sh): own=3265 other=0 noslang=50 fenced_skipped=8 on each of the three
   sweeps.
10. **Determinism** (drivers/det.sh, evidence/determinism_{law,fix}.txt): three concurrent draws per row-mode on
    Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. There is one hash per row-mode
    on both binaries, each equal to its sweep's database; Scoreboard and Rggen testflags write no database, as at
    the base.

## Residues (ranked; all wrong on pristine too)

1. **The implementer's residues 1 to 7 stand as listed in tools/probe/r11u300repro/README.md:**
   - a re-parented shared result holding references (binary or ternary parent);
   - multi-statement callees;
   - the `return 5`, bit-select, identity and nested-add callee shapes;
   - package-variable, bit-select and output actuals;
   - the INT:0 placeholder;
   - v3_clone13's elaborated default argument;
   - a package parameter in a top-listing return.
2. **Valued actuals: golden's fold to a fresh constant at the call.** This covers va01, va02, va04, va13, va14, va19,
   vf04 and vf05 in the d view, and va05, va16, va17, va22, ve01 and ve05. It is a constant fold (the
   § evalFuncOpReduceGate195 family), not a share, and the refinement keeps pristine there. Writing the d view's
   fold would convert the d views pristine still misses.
3. **The unary and system-call contexts the law shares through, where golden folds the whole expression.** One
   example is VC/vc08 `$bits(f(x))`, which golden writes as `UINT:0`, a Surelog quirk not to copy.
4. **Contexts the law abstains on** (pristine bytes, still stage 1 or wrong):
   - VC/vc18 `**` and VC/vc26 a cast;
   - VC/vc20 `inside` and VC/vc21 `==?` around a kind-2 callee;
   - VD/vd01 and VD/vd06, a three-package import or export chain;
   - VD/vd10, a two-level caller chain (d depth, e stage 1);
   - VD/vd11 and VD/vd12, class bodies in the package;
   - VD/vd03, the module import clone (d depth -> type, e stage 1);
   - VE/ve03, a type parameter of the formal's name (stage 1, 271 lines, on every binary).
5. **Cost of the refinement:** va16 and ve01 lose the law's coincidental downstream IDENTICAL (both strict-wrong on
   every binary, golden folding).

## Process

- **The verifier's slips, with no effect on any number:**
  - Three refinement drafts were built before the frozen fix:
    - The first looked up both packages and returned the callee-package case va18 to pristine.
    - The second missed imported, $unit and enum names, and abstained on kind 2 and on parameters declared after
      the caller.
    - The third abstained on `return (f(x));` (RS/s19 d/e leaving STRICT_EQUAL against the law), caught by the
      implementer's grid.
  - Each draft build was stopped by its own task id before an edit; no source was edited while its TU compiled.
  - Every number above comes from the frozen fix binary (a9d5e637).
  - The fresh case files' first lines were retagged after a first grid; the final grids, away census, downstream
    and controls ran on the files as committed.
- **The fence:** every driver reads $FENCED fail-closed. Every path list was filtered before any file was opened.
  No fenced name was spelled, no fenced source or database was read, no other agent's process was listed or
  signalled, and nothing outside /tmp/wt_v11u300*, /tmp/v11u300_* and the session scratchpad was written.
- **Process listing:** the only one was a cc1plus listing filtered to this pass's worktree path.
- **Golden caches:** the goldens for the cases live in /tmp/v11u300_gold, keyed by the case files' content.
