# r10uvm108 — § `evCtrlOperandBinds108` — **the SeqDriver 29-line head cleared: an event control's expression is a binding window**

## Result

SeqDriver, **both modes, 29 → 46 cmp lines**: the head uvm106 named
(`@waiter.trigger;`, uvm-1.2 `src/base/uvm_config_db.svh:294`) is gone, and the
next one prints.  Across the nine UVM databases the pass moves **18 cells, every
one onto golden, 0 away**; the u2r corpus moves **0 of 1358** databases, exactly
as predicted; **no row converts** and `results/*.csv` is untouched.

## The head, confirmed from the pristine cmp log and the generated Compare

`uhdm-cmp` prints one head per run (`grep -c '^LHS:'` = 1) whose LHS is golden's

    class_var: (uvm_pkg::uvm_config_db::wait_modified::waiter), line:273:18

and whose RHS is `<null>`.  That shape can only come from the SINGULAR
`SafeCompare` overload (`~/.local/include/uhdm/BaseClass.h:190`, `lhs != nullptr
&& rhs == nullptr` sets `m_failedLhs` and leaves `m_failedRhs` unset), and the
only singular field on the path is `ref_obj::Actual_group`
(`ref_obj.cpp:150`), reached through `event_control::Compare`'s
`VpiCondition` (`event_control.cpp:86`).  So the head is a MISSING vpiActual on
the event control's condition, not a missing object and not a naming residue —
`head_before_SeqDriver_{default,testflags}.cmp` are the two logs.

Golden and we agree on everything else about that object.  Dumped in full at the
site, golden's

    event_control (294:5-294:20)
      vpiCondition -> ref_obj  name `waiter`, span 294:6-294:20
                        vpiActual -> class_var (…::wait_modified::waiter) @273:18

and ours is the same `ref_obj`, same name, same span, **minus the `vpiActual`
edge**.  Note the shape the brief asked about: golden does NOT build a
`hier_path` here.  The parens-less `@ <hierarchical_identifier>` production
gives ONE `ref_obj` named for the leading identifier and spanning the whole
dotted text — which is exactly the object § `parensLessEventPathBaseRef9`
(`src/StmtEmit.cpp`) already mints for us.  That object had simply never carried
an actual, in any scope.

## Surelog producer (read, not guessed)

`CompileHelper::compileEventControlStmt`, `src/DesignCompile/CompileStmt.cpp:1360`:

    UHDM::event_control* event = s.MakeEvent_control();
    fC->populateCoreMembers(Event_control, Event_control, event);
    event->VpiParent(pstmt);                                       // :1376
    if (Event_expression)
      if (UHDM::any* exp = compileExpression(component, fC, Event_expression,
                                             compileDesign, Reduce::No, event))
        event->VpiCondition(exp);                                  // :1379-1382

The `event_control` is **parented BEFORE its expression is compiled** and is
handed down as that expression's `pexpr`.  Every simple name in the expression
therefore reaches `CompileHelper::bindVariable` (`CompileStmt.cpp:3089`, called
from `CompileExpression.cpp:5775` / `:5799`), whose walk climbs the `VpiParent`
chain and inspects **exactly four scope kinds** — `uhdmfunction`, `uhdmtask`,
`uhdmbegin`, `uhdmmodule_inst` — reading `Variables()`, `Io_decls()` and (module
only) `Nets()`.

That single switch predicts every cell of the grid, in both directions:

* it FINDS a subroutine local, a formal, and an unnamed block's local, so those
  bind even inside an in-body class method where § `controlBodyNoBind28` and
  `classMethodNoBind` silence everything else;
* it has NO case for a class PROPERTY, a STATIC property, `uhdmnamed_begin`, a
  package or a class_defn, so `@propEvent`, `@statHandle.trigger`, a NAMED
  block's own local and `@pkg_ev108` read from an in-body method all stay bare —
  the eager bind fails, the ref goes on the late-binding list, and for an in-body
  class method that list is never processed (§ `pkgVarBindsOnlyThroughInstance88`);
* the walk only STARTS from a parented chain, so an `if`/`for`/`forever`/`case`
  arm's statement (not yet parented at that moment — § `controlBodyNoBind28`) and
  the two § `incDecOpaqueCarrier21` carriers (a `delay_control`, a `wait_stmt`,
  both compiled before they are parented) dead-end it.  An event control is the
  opposite: it is TRANSPARENT, which `UhdmExporter.h`'s `incDecOpaqueDepth21`
  comment already recorded from the other side and arm a2 d13 now shows from this
  one (`@pre13 @mm13.fired;` binds BOTH).

## Model

`include/UhdmExporter.h` (`evCtrlBindPos108`, the full decode) +
`src/StmtEmit.cpp` (`evCtrlBindSym108`, `evCtrlPathBaseSym108`,
`evCtrlBindEligible108`, the token raise, READER 1) + `src/ExprEmit.cpp`
(READER 2, the exception term).

**THE SOLE RAISE** is `StmtEmit.cpp`'s event-control statement arm, around the
event EXPRESSION only (the guarded statement is emitted outside it), and only at
`ctrlBodyDepth28 == 0 && incDecOpaqueDepth21 == 0`.

**READER 1** — § `parensLessEventPathBaseRef9`'s hand-built `ref_obj`.  It is
minted by the timing-control emitter rather than by the reference emitter, so it
had no actual in ANY scope: the corpus head, and every module / package /
out-of-body cell of arms a2-a4, were bare on our side and bound on golden's.
The base symbol comes from `evCtrlPathBaseSym108`, which walks the AST spine
(`MemberAccess` / `ElementSelect` / `RangeSelect`) exactly as clause 3 of
§ `parensLessEventPathBaseRef9` walks the syntax.  A HIERARCHICAL path is
DELIBERATELY refused: for `@top.e;` slang hands us one
`HierarchicalValueExpression` whose `symbol` is the LEAF (`e`) while the object
we mint is named for the BASE (`top`), so binding it would put the wrong actual
under the right name — and golden leaves those cells bare anyway, because a
module INSTANCE is in none of `bindVariable`'s listings (arm a5 g05/g06; the
corpus sites are Google chapter-15 `15.5.2--named-event-wait.sv:21` and Icarus
`ivltests/pr572.v:33`).

**READER 2** — the NamedValue reference gate, as an EXCEPTION term beside
§ `incDecStmtOperandBinds21`.  It lifts ONLY the two silences the walk actually
defeats, `classMethodNoBind` and § `controlBodyNoBind28`; `unitSubNoBind9`,
§ `classInBodyRecvCallArgNoBind52`, § `collArgNamedBlkLocalNoBind15` and
§ `newArrayArgNoBind16` are untouched, because an event control cannot sit inside
any of their windows.  Its corpus cell is uvm-1.2
`src/seq/uvm_sequence_base.svh:762`, `@e;` in `virtual task wait_for_relevant()`,
bound in golden to the task-local `logic_var e` declared at `:757`.

**The symbol gate**, `evCtrlBindSym108` (+ `evCtrlBindEligible108` for READER 1):
a Variable / FormalArgument / Iterator whose DECLARING scope is the subroutine
or an UNNAMED statement block; plus, for READER 1 only, a MODULE-scope net or
variable.  Interfaces and programs are fenced out on measured golden cells (a4
f11 `@progCell.fired;` in a program initial is golden-BARE; an interface binds
the ELABORATED instance's `class_var` through a late-binding route this one is
not, and a3 e20's bare `@ifEvent` in an interface task is golden-BARE, so the two
halves of an interface do not even agree with each other).

## The grid — every clause of the gate is a measured golden cell

Five arms, ten arm-views, ~120 golden cells; `a1_shapes.sv` (shapes),
`a2_ctx.sv` (positions and carriers), `a3_homes.sv` (symbol homes and reader
scopes), `a4_bound.sv` (container kinds), `a5_hier.sv` (hierarchical / scoped /
virtual-interface bases).  Golden, per cell:

    BINDS  a1 c01 `@kk01.trigger` parens-less dotted, task local     (the head's shape)
    BINDS  a1 c03 `@mm03.trigger.triggered` three deep
    BINDS  a1 c11 `@bag11.slots[0].trigger` index MID-path
    BINDS  a1 c05/c06 `@ev05` / `@(ev06)` a bare local event
    BINDS  a1 c07 `@(posedge sig07)`; c08 BOTH operands of `@(a or b)`
    BINDS  a1 c13 `@(ww13.trigger iff gate13)` — the iff condition, twice
    BINDS  a1 c14/c15 a plain non-event local; c19/c20 a FORMAL
    BINDS  a2 d02 unnamed begin, d03 a NAMED block reading the TASK's local,
           d05 an unnamed block's OWN local, d10 a fork arm, d13 BOTH of
           `@pre13 @mm13.fired`, d14 static task, d15 plain task,
           d16 out-of-body method and package free task, d17 after a blocking
           assignment, d18 both controls of one body
    BINDS  a3 e12..e18 module task / initial / always / child instance;
           a4 f01..f07, f10, f12; a5 g02 a virtual-interface FORMAL,
           g03 a virtual-interface task LOCAL
    bare   a1 c16/c17/c18, a3 e06/e07, a5 g01 — a CLASS or STATIC property
    bare   a1 c12, a3 e05 — a PACKAGE name read from an IN-BODY class method
    bare   a2 d04 — a NAMED block's OWN local
    bare   a2 d06/d07/d08/d09 — one `if`/`forever`/`for`/`case` body deeper
    bare   a2 d11 `#1 @kk11.fired;`, d12 `wait (guard) @ll12.fired;`
    bare   a1 c02/c04/c09, a3 e09 — the PARENTHESISED dotted form stays a
           `hier_path` with unbound elements ON BOTH SIDES
    bare   a4 f11 — a PROGRAM-scope name in a program body
    bare   a5 g04 `@hr108_pkg::scopedEvent` (a `::` separator, clause 3 declines)
    bare   a5 g05/g06 — a hierarchical path through an instance (golden binds an
           IMPLICIT net Surelog mints for the base name, which we do not have)

Scored three ways (golden / pristine / shipped, both views): **TO_GOLDEN 46,
AWAY 0**.  The residual LATERAL/STILL cells are instrument artefacts, named in
`GRID.txt`: in the elab views we emit one class copy more than golden (the
PRISTINE binary has the same extra copy), and a1 c13's iff condition object is
SHARED between the inner and the outer `vpiIffOp` on our side, where `uhdm-dump`
prints a revisited object with no fields — the raw dump shows the shared object
does carry the actual, and the official judge agrees (a1/def's head loses its
`vpiActual` gap and retains only the pre-existing `vpiAutomatic:1` one).

The strongest single statement about the patch: over all ten arm-views the
whole-dump diff pristine→shipped has **0 removed lines** and every added block is
`|vpiActual:` plus the object it names; every one of those objects is present in
golden's own dump, with one exception that is not a divergence (`f13_unitlocal`'s
local, inside a `$unit` free task golden does not emit at all).

## Cells and movers

Census (`cen108.py`, `PROJ=1`, the judge-visible projection — object KIND, the
LEAF of any name, and the presence/kind/leaf of a `vpiActual`; no span, no
synthesised `vpiFullName`) over EVERY `event_control` / `wait_stmt` /
`event_stmt` operand in the nine UVM databases, both modes:

* golden-vs-golden calibration (default vs testflags) **0 differing keys** on
  110 / 72 / 105 / 68 rows;
* golden-vs-ours **exactly 2 differing keys per database, 18 cells in all**, both
  of them event-control operands (`uvm_config_db.svh:294`,
  `uvm_sequence_base.svh:762`), and NOTHING else in the family;
* the carriers themselves agree row for row on both sides.

Movers, PREDICTED BY NAME from the pristine workdir before the shipped binary's
databases existed (`pred108.py`, `PREDICT.txt`) and then measured:

* uhdm2rtlil **0 / 1358** — predicted 0 (the corpus has no parens-less dotted
  event control at all, and its one class-plus-event file is a module-scope
  `always`);
* surelog **9 / 956** — the nine UVM databases and nothing else, every one inside
  the predicted candidate set.  Order-blind whole-dump attribution (`ATTRIB.txt`,
  sorted dumps, so Scoreboard/default's coin cannot confuse it): **each of the
  nine changed by exactly 4 lines, 2 `|vpiActual:` labels and the 2 objects they
  name, 0 removed** — `class_var …wait_modified::waiter` and `logic_var
  …wait_for_relevant::e`.

Wide boundary (`BOUNDARY.txt`), from a COPY of `tools/probe` with no path filter,
`.sv` AND `.v`, both views, rc per cell, `PROCESSED` asserted:

* per-file 3368 arms × 2 views: MOVED 13 = 9 of this pass's own arm-views + 4
  cells of `r10svs9repro/{a2_base,v4_more}.sv`, which were re-scored against
  golden and are **10 cells TO_GOLDEN, 0 AWAY**;
* per-directory 1487 directories × 2 views: MOVED 6 = 2 of this pass's own + 4
  cells of `r10uvm75repro` / `r10uvm76repro` whose **sorted diff is 0** (order
  only).  A positive control settles those: the PRISTINE binary run twice on the
  same directory produces a 10-line unsorted diff by itself — the documented
  macro-buffer `SourceLocation` nondeterminism, not this patch;
* `RC_DIFF 0`, `ASYM 0`, `PROCESSED-ASSERT-OK` in all five runs.

## Gates

All green, in `GATES.txt`: goldens 23/0 and `/bin/false` 0/23; u2r 679/50/2 both
modes with 0 differing rows against the committed baseline AND against the
pristine control, byteverify 0/1358; surelog 1588 rows, 0 differing rows
(status AND dump column) against both, byteverify 9/956 = the predicted set;
canaries 52 / 8 `ok`, `changed=0`, `ctcan2` PASS on both corpora, `canaudit`
PASS (`FENCE-BREACH=0`); `InterfaceModPort` / `BlackParrotComplex` /
`YosysOldOr` byte-identical, `SVSwitch` pin `4842211c4030` and `YosysVerx` pin
`6ccda350c24a` held.  **NO ROW CONVERTS** — SeqDriver was CMP_NOTEQUAL before
and is CMP_NOTEQUAL after, one head deeper — and `results/*.csv` is untouched.

## Residues

* **R0 (the new SeqDriver head, 46 cmp lines, both modes)** — uvm-1.2
  `src/reg/uvm_reg_adapter.svh:195`, `gp.m_byte_enable = new [nbytes];` inside
  `uvm_reg_tlm_adapter::reg2bus`.  Golden's assignment LHS is a plain `ref_obj`
  named `gp` spanning `195:6-195:22`; ours is a `hier_path (gp.m_byte_enable)`
  over the same span with two unbound elements.  A KIND divergence on the LHS of
  a dynamic-array `new[]` assignment through a class handle — the field is
  `assignment::Lhs`, and the object golden ships is the RECEIVER alone, the same
  collapse this pass's producer decode shows for the parens-less event path.
  `head_after_SeqDriver_{default,testflags}.cmp` are the logs.
* **R-idxbase108** — § `parensLessEventPathBaseRef9`'s clause 4 declines when the
  BASE ITSELF is indexed (`@modArr[1].fired;`, arm a4 f04): golden collapses to
  `ref_obj(modArr)` + actual, we keep a `hier_path`.  A KIND change with no
  corpus witness, deliberately not widened here.
* **R-this108** — `@this.propEvent;` (arm a1 c10): golden emits a `ref_obj` named
  `this` with NO actual, we emit `hier_path(this.propEvent)`.  Pre-existing, both
  binaries, unchanged by this pass.
* **R-span108** — `@mm03.trigger.triggered;` (a1 c03): golden's `ref_obj` spans
  the whole three-element text, ours stops after two.  Not judge-visible (no
  generated `Compare` reads `VpiFile`/line/col), recorded because the census
  shows it.
* **R-iface108 / R-prog108** — an interface's event control binds the ELABORATED
  instance's `class_var` in golden through a late-binding route (a4 f08/f09)
  while its bare-name twin is golden-BARE (a3 e20); a program initial reading a
  program-scope name is golden-BARE and we already over-bind it (a3 e21,
  PRE-EXISTING on both binaries).  Both fenced out of this law rather than
  approximated.
* **R-pkgevhoist108** — a PACKAGE free task reading a package `event` binds, in
  ONE of golden's two copies, a MODULE-level implicit net Surelog mints for the
  imported name (a3 e01).  A hoisted-net question, not a window question.
* uvm106's **R1-import / R-class106 / R-func106 / R-ovsize / R-signdec**,
  uvm104's **R-args / R-esc / R-assoc** and MiniAmiq's 348-line head are
  unchanged by this pass.

## Files

`run108.sh` (three-way arm runner, rc per cell, both views), `score108.sh`
(TO_GOLDEN / AWAY / LATERAL / STILL classifier), `cen108.py` (the event-control
operand census; `PROJ=1` projects onto the judge-visible axes), `join108.py`
(multiset join, LHS always golden), `pred108.py` (the a-priori mover predictor;
the four fenced tests are skipped by the md5 of their names, never spelled),
`bnd108.sh` / `bshard108.sh` (the wide boundary, per-file and per-directory),
`attr108.sh` (order-blind attribution of every moved database),
`a1_shapes.sv` … `a5_hier.sv` (the arms),
`head_{before,after}_SeqDriver_{default,testflags}.cmp`,
`GATES.txt`, `CENSUS.txt`, `GRID.txt`, `BOUNDARY.txt`, `ATTRIB.txt`,
`PREDICT.txt`.
