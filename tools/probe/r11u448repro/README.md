# r11u448 — the never-instantiated definition admission for undeclared reads (module/type ground)

Pass 448 is the twenty-fourth pass of the sv-tests campaign on the module/type ground. It changes
one production file, src/UhdmExporter.cpp; TypeEmit, ModuleEmit, TaskFuncEmit, uhdm_main.cpp and
the sister's four files (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) are unchanged. Base 84452b82f
(pass 446).

- **Pristine reading:** the master's control sweep at the base, /tmp/intr11u446 (its csvs equal the
  committed results/*.csv). No pristine build and no pristine sweep: the pristine for case runs is a
  frozen copy of the main tree's build/slang-uhdm, md5 0629d46c68933a364c6dcac8b2a3967b.
- **Final law binary:** law7, md5 997cfcce9c8595a4f6be1bedd419fbd7, linking slang 12.0.0+545f88b2e.
- **Intermediate binaries** (case runs and targeted runner calls only): law1 to law6.

## Result

| sv-tests row | base | law7 |
|---|---|---|
| generated/basejump/bsg_mem_BaseJumpSTL_bsg_nonsynth_mem_1rw_sync_assoc.sv | DIFFERENT | **EQUAL** (STRICT_EQUAL 5195 objects, uhdm-cmp 0 lines) |
| generated/basejump/bsg_misc_BaseJumpSTL_bsg_scheduler_dataflow.sv | DIFFERENT | **EQUAL** (STRICT_EQUAL 5589 objects, uhdm-cmp 0 lines) |

The fresh rows of the sweep's svtests.csv:

    generated/basejump/bsg_mem_BaseJumpSTL_bsg_nonsynth_mem_1rw_sync_assoc.sv,EQUAL,,equal
    generated/basejump/bsg_misc_BaseJumpSTL_bsg_scheduler_dataflow.sv,EQUAL,,equal

sv-tests after: EQUAL 1916, STRICT_NOTEQUAL 0, DIFFERENT 24, SURELOG_ONLY 75, BOTH_REJECT 303,
SLANG_ONLY 19, SLANG_CRASH 0, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, conversions 2,
changes 0 (evidence/r11u448_sweep.log). Both conversions were predicted by name before the sweep
(evidence/r11u448_prediction.txt).

## Heads at the base (question 1)

Both rows are brief item (2)(a). Golden lists each never-instantiated definition as a module_inst;
ours lists neither. UhdmExporter's admission (the Bad404 visitor after § undefaultedPlaceholderRetry440
and § defaultedStrPlaceholderRetry444) counted every InvalidStatement as unbound, so the definition
took the `abstain-unbound` return of § undefaultedDefInvalidInst404:
- bsg_scheduler_dataflow: 5 InvalidStatements `@(negedge clk_i) begin $display(..., bypass_lo); end`,
  each wrapping a TimedStatement; `bypass_lo` is declared nowhere (an InvalidExpression with no child
  and the bare IdentifierName syntax).
- bsg_nonsynth_mem_1rw_sync_assoc: 3 InvalidStatements `@(posedge clk_i) begin ... end`, each wrapping
  the nonblocking write to an associative element. StmtEmit's § invalidChild14 already writes it.

Pass 447's measurement-only hunk (r11u447repro/evidence/r11u447_xadmit_hunk.txt) skipped the return
for every unbound body. On its UN grid that blanket admission exits 4 on un07, un10, un13, un15,
un20 to un22 and un25 (pristine exit 0), because pass 447's writers do not write those shapes. So
the admission here is a predicate that admits only what the writers write.

## Decode (question 2)

Surelog lists every parsed module definition (`uhdmallModules`) and never evaluates the
placeholder body, so golden writes the definition whatever slang thinks of the body. Two parts
of the golden listing matter here:

1. A never-elaborated body's InvalidStatement is the statement slang built, marked invalid. StmtEmit
   re-emits its child (§ invalidChild14), and an undeclared simple-name read in it is written by
   pass 447 (§ undeclaredReadImplicitNet447, § undeclaredReadLaterDecl447): a ref_obj bound to an
   implicit logic_net, or to the later module-level declaration.
2. Surelog's lateBinding mints that implicit wire at the name's FIRST reference in source order
   among the module's processes and continuous assignments, not inside a subroutine body. The wire
   is listed among the implicit wires in that order. The OR grid shows this: or01 and v11u447 VP/vp09
   (process read at 3:28 before `assign w = u_x` at 4:14; golden `logic_net (work@m.u_x) 3:28`
   listed before `w`); or02 (the reverse order, golden at the continuous assignment); or03 (two names,
   golden u_y 3:40, u_x 4:26, w 5:10); or04 (a declared wire stays first); or05 (a port-connection
   implicit wire imp_a at 5:12 stays after u_x 4:26); or06 (a function body's read does not count,
   golden at the continuous assignment). ModuleEmit writes a never-elaborated definition's continuous
   assignments before its processes, so pass 447's law minted the wire at the continuous assignment.

## Laws (src/UhdmExporter.cpp, read through src/LawSwitch.h)

R11U448_OFF drops both laws. R11U448_TRACE=<dir> logs each firing and each abstention through
lawTrace(448, ...).

- **§ invalidReadDefAdmit448** (R11U448_INVREADADMIT_OFF; cases cases/AD; the two sv-tests rows).
  When every placeholder retry of passes 440 and 444 leaves the body unbound under the old strict
  judgement, the original placeholder build is judged once more by these rules:
  - An InvalidStatement that wraps a statement is judged by that statement. Inside it, an
    InvalidExpression with a child is judged by the child.
  - A child-less InvalidExpression is admitted only when all of the following hold:
    - Its syntax is a plain IdentifierName.
    - The definition is a module.
    - The name is declared nowhere in the body. A module-level variable or declared net is the one
      exception, since § undeclaredReadLaterDecl447 binds it.
    - No type, class, enum constant or other body member of that name exists in any nested scope
      (§ undeclaredReadImplicitNet447 abstains on those).
    - Its syntax ancestors, up to a procedural block, a continuous assignment or a module-level
      function or task, are only these:
      - parentheses, unary and binary operators (assignments included), conditional expressions
        and concatenations;
      - argument lists of a call, including the sequence and property wrappers of system-call
        arguments;
      - expression statements and sequential blocks;
      - the statement of a timing control;
      - if, case and case items, for, wait, return and immediate assert;
      - a bare generate region.
    - The next ancestor above that is the definition's own ModuleDeclaration.
  - Everything else stays unbound and the definition stays unlisted, as before: a generate block,
    a select, a member access, a call's callee, an event or delay control (InvalidTimingControl), an
    invalid assertion expression or constraint, a nested module, an interface or program definition.
  The relaxed judgement runs only after the retries, so a body that a retry binds keeps that retry's
  listing.
- **§ implicitNetFirstRefLoc448** (R11U448_FIRSTREFLOC_OFF; cases cases/OR; v11u447 VP/vp09). This
  runs in final287. For each definition the first law admitted, and each undeclared name it reads,
  the implicit logic_net takes the span of the earliest ref_obj bound to it among the module's
  processes and continuous assignments (a UhdmListener confined to each root, so subroutine bodies
  are not reached). The net then moves in front of the first implicit wire that starts after it.
  The implicit wires are slang's implicit nets of the body plus the admitted names.

No src/R*.h, no LawState.h section, no getenv, no reader function and no header change. The two
lawOn calls are the only switch reads in the added lines.

## Grid

The grid has 470 case dirs: this pass's AD (25) and OR (6), plus every case of r11u447 UN,
v11u447 VA/VI/VN/VP, r11u444 CS/PN, v11u444 VD/VP, r11u440 MS/NT/PH/TD/VI, v11u440 VA/VE/VN/VP/VX,
r11u404 and v11u404. They were run on five configurations: pristine, law7, law7 with R11U448_OFF,
law7 with R11U448_INVREADADMIT_OFF and law7 with R11U448_FIRSTREFLOC_OFF. The driver is
drivers/grid.sh, keyed on the full repro path. The data is in evidence/r11u448_grid.tsv and
evidence/r11u448_grid_summary.txt.
- **Movers:** 59 move bytes. Every exit code is the same on both binaries. 49 move NOT_EQUAL ->
  STRICT_EQUAL. 10 are closer by dump distance and none is further:
  - r11u444 CS/cs09 747 -> 379
  - v11u444 VD/vd04 620 -> 254
  - UN/un18 152 -> 18
  - un19 121 -> 11
  - un37 204 -> 5
  - v11u447 VP/vp01 103 -> 11
  - AD/ad08 95 -> 48
  - ad09 156 -> 77
  - ad18 106 -> 23
  - ad22 126 -> 21
- **The 49 to STRICT_EQUAL:**
  - r11u447 UN (17): un01 to un06, un08, un09, un11, un14, un16, un17, un23, un24, un27, un35, un36
  - v11u447 (9): VA/va18, va23; VP/vp03, vp04, vp05, vp06, vp08, vp09, vp12
  - earlier passes (3): r11u404 UD/ud03, r11u440 PH/ph04, v11u440 VP/vp05
  - AD (14): ad01 to ad04, ad10 to ad12, ad16, ad17, ad20, ad21, ad23 to ad25
  - OR (6): or01 to or06
- **Switches:**
  - R11U448_OFF gives pristine's bytes and exit code on 470 of 470.
  - R11U448_INVREADADMIT_OFF gives pristine's bytes on all 59 movers.
  - R11U448_FIRSTREFLOC_OFF moves exactly or01, or03, or04, or05 and vp09 back, to the bytes the
    first law alone writes.
- **Byte-identical controls (no rc change):**
  - ad05 and ad06: an @(undeclared) or #undeclared, an InvalidTimingControl.
  - ad07: a nested module, exit 4 on both binaries, see residues.
  - ad13 and ad15: a function name and an anonymous-enum constant read as values.
  - ad14: an interface; listed on pristine already.
  - ad19: undecl[0].
  - un07, un10, un13, un15, un20 to un22 and un25: the 9 shapes where pass 447's blanket admission
    exited 4. All stay exit 0 and unlisted.
- **Upstream slang** (~/.local/bin/slang --single-unit) accepts all 25 AD cases. Surelog accepts all of
  them except ad23 (`default_nettype none`: Surelog reports EL0535 and exits 4 with a database, against
  which law7 reads STRICT_EQUAL).
- **Downstream** (drivers/ds_cases.py, scripts/downstream_uhdm2rtlil.one per case): the 59 movers read
  57 IDENTICAL and 2 EQUIVALENT on both pristine and law7, with no verdict changing.

## Census before the sweep (by name)

drivers/census448.py ran law6 traced against the control (fence-filtered first; the fence list was
read into a file by a program and never printed). Data in evidence/r11u448_census_*.tsv and
evidence/r11u448_prediction.txt.
- **probe:** 4087 cases, 0 trace lines.
- **surelog:** 1523 control records, 0 trace lines, and the law output md5 equal to the control's on
  every record.
- **uhdm2rtlil:** 1740 records, 0 trace lines, every md5 equal.
- **sv-tests:** 2346 rows. law6 fired on 10. The positive controls are the AD and OR grid cases,
  which fire.

The firings on 4 basejump retry rows (control_slave, comm_link_checker, dff_en_segmented,
ascii_writer) led to law7's ordering (see Process). The runner on law7 reads all six basejump rows
EQUAL / equal, with the trace on the two target rows only (evidence/r11u448_svrows_law7.csv).

bp_multicore_1, _1_cce_ucode, _4 and _4_cce_ucode_cfg admit bp_uce. The run exits 3 on pass 403's
size guard on both binaries (bp_multicore_1 measured: 15 s and 14 s, the same
`basic_string::substr` message; evidence/r11u448_bp_multicore_1_tail_*.txt). The status
SURELOG_CRASH does not depend on it.

## Sweep (one full five-stage tests/sweep.sh --jobs 3 on law7)

Driver: drivers/fullsweep.sh. The four corpus stages ran from the worktree; the svtests stage ran
through the main tree's tests/sweep.sh, since the worktree's UVM submodule is empty. The machine was
quiet at launch: no sweep, runner or checker process.

| stage | result |
|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087; regressions 0, conversions 0, changes 0; csv identical to the control |
| surelog | default 480 + 0 and testflags 474 + 0 CMP_EQUAL; 0/0/0; csv equal to the control apart from the two LowMem log-path texts |
| uhdm2rtlil | 803 / 1 / 67 in both modes; 0/0/0; csv identical |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; csv identical |
| svtests | regressions 0, conversions 2 (the two rows above), changes 0; csv equal to the control except those two rows |

- **byteverify** against /tmp/intr11u446: surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805.
  The self-checks flag 961, 1607 and 804 (evidence/r11u448_byteverify.txt).
- **Canaries:** ok=52 and ok=16. ctcan2 PASS on both: ok=58 with unknown-patterns 1, and ok=2 with
  unknown-patterns 6 (evidence/r11u448_canaries.txt).
- **Binary audit** (fence-filtered):
  - surelog: 1523 of 1573 records name /tmp/r11u448_bin/law7; the other 50 hold no slang line.
  - uhdm2rtlil: 1740 of 1740.
  - svtests: 2346 of 2346.
- **Sweep trace:**
  - sv-tests: the two target rows and the four bp_multicore rows.
  - Every corpus stage: none (evidence/r11u448_sweep_trace.txt).
  - This is exactly the prediction.
- **Determinism:** three concurrent law7 runs of each converted row read one hash each
  (evidence/r11u448_determinism.txt). Strictcmp of those runs against the cached goldens reads
  STRICT_EQUAL 5589 and 5195 objects, with uhdm-cmp at 0 lines.
- **Law index:** the main tree's svtests stage exited 1 only on "law index STALE", as in passes 446
  and 447. The worktree's index is current, regenerated in the patch.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **AD/ad07, a goal-1 face.** A never-instantiated module holding a nested module definition whose
   body reads an undeclared name exits 4 on pristine and law7 alike; upstream slang and Surelog
   accept it. The Bad404 visitor does not descend into nested instances
   (`handle(const InstanceSymbol&) {}`), so pass 404 lists m and m::nest. § undeclaredReadImplicitNet447's
   scopeOk447 then abstains in the nested body, and the run exits on `expression kind: Invalid`.
   - Either the writer serves nested definitions (ExprEmit, the sister's), or the admission judges a
     nested definition's body (this ground).
   - The second fix would unlist definitions whose nested bodies hold written InvalidStatements, so it
     needs its own grid. Not written here.
2. **Shapes the admission does not reach**, all unlisted as on pristine:
   - an event or delay control over an undeclared name (ad05, ad06);
   - a bit-select, dotted name or call over one (un20 to un22, ad19);
   - a generate block (un10, un25);
   - a typedef, function or enum constant read as a value (un13, ad13, ad15);
   - a read before a later port-connection implicit wire (un15);
   - an index in a select (un07);
   - interface and program definitions (un31, un33);
   - a second definition in the same file that holds such a shape (ad09's n).
   Each needs the writer first (the sister's ExprEmit or StmtEmit), then an admission clause measured
   on the grid.
3. **Admitted but not equal:**
   - the bare generate region's gen_region that golden lists (ad08; ModuleEmit, pass 428's residue);
   - the concatenation shapes (un18, un34, ad18, ad22);
   - the named block re-emitted as an unnamed one (un19, VP/vp01);
   - the function-typedef cast (un37);
   - cs09 and vd04, now listed with their next face.
4. **bp_uce in black-parrot** is admitted, but the run exits on pass 403's size guard. Measure it
   once that guard is lifted.
5. **Carried:**
   - the 16 uvm-examples rows, the 3 scoreboard rows and easyUVM;
   - p733, p737 (the admission still abstains on the undefaulted type parameter) and tnoc, which
     await the user's decision;
   - the backlog lists of passes 446 and earlier.
   Pass 447's vp09 is closed here.

## Sister-ground faces (reported, not written)

- **ExprEmit § undeclaredReadImplicitNet447's scopeOk447** (the nested-module read of ad07): the
  goal-1 exit 4 above.
- **ExprEmit and StmtEmit:** the writers for the shapes in residue 2 (selects, calls, event controls
  over undeclared names). The admission clause follows each writer.

## Process

- **law1:** admitted any child-less IdentifierName inside an InvalidStatement but never descended
  into an InvalidExpression's child. On its UN grid 9 cases still exited 4 (un07, un10, un13, un15,
  un20 to un22, un25).
- **law2 and law3:** descend into children inside admitted statements (InvalidTimingControl,
  InvalidAssertionExpr and InvalidConstraint are unbound there) and accept the sequence wrappers of
  system-call arguments.
- **law4:** mirrors the writers' declaration rules (later module-level declarations bind; nested
  locals do not block) and accepts assignment left sides, return, and user-call arguments.
  Measured on the 439-case wide grid: 34 movers, all closer, none with an exit-code change.
- **law5:** adds § implicitNetFirstRefLoc448.
- **law6:** adds case, for, wait, immediate assert and the bare generate region (measured on
  ad03, ad04, ad08, ad16 and ad17 first).
- **law7:** runs the relaxed judgement only after the retries of passes 440 and 444. law6's census
  showed it judging the first placeholder build of control_slave, ascii_writer and
  dff_en_segmented ahead of the retries. Those 3 rows still read EQUAL on law6
  (evidence/r11u448_svrows3_law6.csv), but a retry-bound body must keep its retry's listing. The
  law7 grid summary equals law6's.
- **Measurement budget:** intermediate binaries got only case grids and targeted runner calls (the
  two rows on law4, three on law6, six on law7). There was one full sweep, on law7. No pristine
  build and no pristine sweep.
- **Overlap:** the sister r11u449 built in its own worktree while law1 was building, builds only.
  No sweep of either pass overlapped.
- **Fence:** never printed. Every tree-wide list was filtered on it before any file was opened.
- No other agent's process was touched.

## Files

- **cases/AD/ad01 to ad25** (§ invalidReadDefAdmit448) and **cases/OR/or01 to or06**
  (§ implicitNetFirstRefLoc448): each a dut.sv whose first line names its law.
- **drivers/:**
  - grid.sh: the grid, with the exit code per binary.
  - grid_summary.py: the movers and switch checks.
  - census448.py: the traced census.
  - ds_cases.py: downstream verdicts of case dirs.
  - fullsweep.sh: the sweep.
  - trace_one.sh: one case's 404/447/448 trace lines.
- **evidence/:** the grids, census, prediction, sweep log, byteverify, canaries, sweep trace,
  runner csvs, downstream case verdicts and determinism.
