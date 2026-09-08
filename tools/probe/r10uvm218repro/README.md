# r10uvm218 — § `uninstIfaceBodyBindsInMethodWindow218` — **THE BODY OF A SUBROUTINE IN AN INTERFACE THAT NO INSTANCE ELABORATES BINDS ITS REFERENCES IN EXACTLY THE IN-BODY CLASS METHOD'S WINDOW, AND NOWHERE ELSE** — the MiniAmiq ×2 head clears

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
**nothing was promoted** and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; they are named only inside `canaudit.sh`'s own `FENCED=`
list, and its `FENCE-BREACH=0` is the check that it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `5c4eb804` |
| pristine binary | md5 `9ba51a177d67154a84ed9a462f38448d`, built `-j 2` from this pass's OWN worktree at a clean `5c4eb804` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `5ec486e65d0ed6c8f7f6ed6a29b1b81c`, frozen `chmod 555`. **The deliverable patch applied to a FRESH `5c4eb804` worktree and built there comes out byte-identical to it** — every gate below was run on the binary the patch reproduces. |
| production surface | `include/UhdmExporter.h`, `src/ExprEmit.cpp`, `src/ModuleEmit.cpp`. **+185 / −3 lines, of which 150 are the decoded comment — 35 lines of code at FOUR sites. No new pass, no new phase, nothing minted, nothing removed, nothing reshaped: the patch only ever SETS an `Actual_group` the pristine emitter left null.** |
| probe surface | `tools/probe/r10uvm218repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head, re-measured on this pass's own pristine build FIRST | **MiniAmiq ×2, 29 cmp lines / ONE head each** — the r10uvm216 R0, reproduced exactly. Every other row at BASE: SeqDriver ×2 **1327330/1** (the SISTER PASS r10uvm217's head, untouched here), SimpleUVM ×2 **0**, Scoreboard/default **0**, BuildUVMPkg ×2 **0**, Earlgrey_0_1 ×2 **0**, Rggen/default **0**. |
| the head after | **THE OBJECT IS GONE.** MiniAmiq ×2 read **20 lines / 1 head**, a NEW object of a different family: golden's `unsupported_typespec (a_lof_sva)` @198:15 against our `class_typespec (svaunit_concurrent_assertion_info)` @196:45 — the `foreach` header's typespec for a formal declared `svaunit_concurrent_assertion_info a_lof_sva[]`. **R0.** |
| the law | **CONFIRMED and decoded to Surelog `file:line`.** `UhdmWriter::writeInterface` (UhdmWriter.cpp:1626-1794) — the ONLY writer for an interface DEFINITION — **contains no `lateBinding` call at all**, while `writeModule` (:1575, :1623), `writePackage` (:1304) and the elaborated-instance writer (:4785, gated `if (mod && netlist)`) all call it. So for an interface nothing instantiates, only Surelog's COMPILE-TIME eager `CompileHelper::bindVariable` (CompileStmt.cpp:3089, `if (scope == nullptr) return nullptr;`) survives — and that is the class-method window, carve-out for carve-out (§3). |
| the population (question 2) | Inside `work@svaunit_vpi_interface`: **322 golden references, 279 ours, 326 keys**, calibration null. Pristine `SAME 219 / MISSING-OURS 21 / EXTRA-OURS 16 / OTHER 70`; patched `SAME 239 / MISSING-OURS 1 / EXTRA-OURS 16 / OTHER 70`. **Both one-sided key sets are unchanged (ONLY-GOLDEN 47, ONLY-OURS 23) and the EXTRA-OURS and OTHER CELL LISTS are byte-identical between the two binaries.** By referent kind the 20 moved cells are 10 `io_decl` (a formal), 9 `bit_var` and 1 `enum_var` (a block local); by subroutine kind, 2 in a DPI-EXPORTED function and 18 in a plain one. |
| the golden grid (question 3) | **5 arms × 2 views = 10 arm-views, one REAL Surelog golden each, 0 NO-DATABASE, golden-vs-golden CALIBRATION null in all 10, on BOTH binaries.** `a2_window` closes to **MISSING-OURS 0** and `a4_dpi` (the corpus shape) to **0**. **`EXTRA-OURS` and `OTHER` never rise in ANY arm-view in EITHER view: AWAY-GOLDEN 0, MOVED-WRONG 0.** `a3_muststay` — package function, in-body and out-of-body class method, instantiated interface, uninstantiated MODULE WITH PORTS, uninstantiated PROGRAM, top module — is **byte-identical, cell for cell, in both views**. |
| the a-priori prediction (question 5) | Written from PRISTINE databases and PRISTINE sources alone, BEFORE any patched sweep ran: the FIRE SET is **6 of 1573** surelog row-modes and **0 of 1462** uhdm2rtlil ones, and of those only **MiniAmiq ×2** has a database at all (AmiqSimpleTestSuite ×2 and Monitor ×2 are `SLANG_REJECT` with no `slang.uhdm`). Predicted: **exactly two** surelog movers, **zero** uhdm2rtlil. |
| byte movers | **2 / 956** surelog and **0 / 1358** uhdm2rtlil — **exactly the two predicted, by name, and no others.** The move is **ADD-ONLY, proved at the byte level**: the whole-dump diff of the MiniAmiq database with ids normalised is **40 lines added, 0 removed** — twenty `\|vpiActual` markers and the twenty objects they name, each landing on golden's own value. |
| gates | goldens **23 PASS / 0 FAIL on BOTH binaries**, `/bin/false` control 23 FAIL; uhdm2rtlil **679/50/2 in BOTH modes on both binaries**, `ct8rows` PASS three ways, `byteverify` 0/1358; surelog 1588 rows, status histogram **475/6 default + 469/6 testflags UNCHANGED, cell for cell — NO ROW CONVERTED IN EITHER DIRECTION**; the SEVEN protected CMP_EQUAL row-modes all HELD at judge rc = 0 with both columns scored; wide boundary **LISTED = PROCESSED = 5501, MOVED_ARMS 12, RC_DIFFS 0**, all 12 re-scored against real goldens at **TO-GOLDEN 44 / AWAY-GOLDEN 0**. |

---

## 1. THE HEAD, AND THE PRISTINE BASELINE, MEASURED FIRST

This pass built its own pristine binary from a clean `5c4eb804` worktree; it came
out **byte-identical** to the main tree's binary at that commit
(`9ba51a17…`). `rowheads.sh` on its own sweep reproduced the brief's target
exactly: **MiniAmiq ×2, 29 cmp lines, ONE head, both modes, and the two logs are
byte-identical to each other.**

The head, read out of `head_pris_MiniAmiq.default.cmp` before a line was written:

```
LHS:
decompile:
io_decl: (a_sva_type), id:248683, line:255:103, endln:255:113
|vpiParent:
\_function: (work@svaunit_vpi_interface.pass_info_to_sv_dpi), line:72:4, endln:72:48
…
RHS: <null>
```

`BaseClass.h`'s **SINGULAR** `SafeCompare` is the only overload that prints this
shape (RESUME §9, the buvm13/15 framing), and the only field whose value can be
an `io_decl` is `ref_obj::Actual_group()`. The dumps name the reference on both
sides at `svaunit_vpi_interface.sv:258:10`, inside
`if(a_sva_type == "vpiCover") begin`:

```
        \_ref_obj: (work@…pass_info_to_sv_dpi.a_sva_type), line:258:10
          |vpiName:a_sva_type
          |vpiFullName:work@…pass_info_to_sv_dpi.a_sva_type
golden    |vpiActual:
golden    \_io_decl: (a_sva_type), line:255:103, endln:255:113
ours      (nothing)
```

Everything else about the reference — kind, name, fullname, span, parent
operation — is identical on both sides.

## 2. WHAT WAS THERE BEFORE, AND WHY IT WAS HALF RIGHT

`src/ModuleEmit.cpp`'s interface-definition emitter raised `suppressRefActual`
for the whole `emitTaskFuncs` call when `defAllInstCount[&def] == 0`, with the
comment

> An UNINSTANTIATED interface's function body keeps every ref bare — formals
> included.

The first half is right and the second half is too strong. In the corpus holder
golden binds **21** of its 240 body references and we bound **none**; the census
`BOUND-AGREE` between the two sides was literally **0**. So the question was
never "why is this one reference unbound" but "which 21, and by what rule".

## 3. QUESTION (4) — THE DECODE, AND THE GATED EXTENSION OF THE buvm WINDOW

Full transcript in `DECODE.r10uvm218.txt`, every `file:line` READ in
`~/git-repos/Surelog`. In one paragraph:

> Surelog has two roads to a `vpiActual`. **Road 1** is the compile-time eager
> `CompileHelper::bindVariable` (CompileStmt.cpp:3089), which runs exactly where
> `compileExpression` was handed a **non-null `pexpr`** — a user call's argument
> list and the condition columns — and returns immediately on a null scope, which
> is why a cast's operand (CompileExpression.cpp:2637-2645 passes `nullptr`
> literally) never binds. **Road 2** is `UhdmWriter::lateBinding`
> (UhdmWriter.cpp:3294), which resolves the whole late-binding list by walking
> `VpiParent`. Its call sites are the story: `writePackage` :1304,
> `writeModule` :1575 and :1623, `writeElabProgram` :2072, and the elaborated
> instance writer :4785 gated `if (mod && netlist)`. **`UhdmWriter::writeInterface`
> (1626-1794) — the only writer for an interface DEFINITION — contains no
> `lateBinding` call at all**, and an interface nothing instantiates has no
> netlist, so it never reaches :4785 either. Road 2 never runs for it and only
> Road 1's eager binds survive.

Road 1's set **is** the in-body class method's binding window, which is why this
is a **gated extension of the buvm window** and not a new rule. Arm
`grid218/a2_window` measures all thirty-one cells of it on ONE golden and every
carve-out the campaign already decoded holds verbatim:

| existing law | its cell in arm a2 | golden |
|---|---|---|
| § classArgBind12 | w17 50:17 `callee218(a_x);` | **BINDS** |
| § classInBodyBareCallArgStmtOnly53 | w27 61:22 `loc218 = fn218(a_x);` | bare |
| § classInBodyRecvCallArgNoBind52 | w26 59:17 `h218.take(a_x);` / w28 62:26 `loc218 = h218.give(a_x);` | **BINDS** / bare |
| § refVarLocalWindowBinds5 (the six condition sites) | w01 27:11 / w15 47:14 `while` / w16 48:33 `for` | **BINDS** / bare / bare |
| § controlBodyNoBind28 | 38:14, 39:20, 43:14 one control body deeper | bare |
| § blockLocalSameCtrlDepthArgBinds57 | w31 72:14 unnamed-block local, same depth | **BINDS** |
| § namedBlkLocalNoBind144v | w29 66:14 / w30 67:20 named-block local | bare |
| § castOperandNeverBindsInWindow161v | w08 34:16 / w25 58:22 | bare |
| § classArgBind12's concat carve-out | w23 56:18/23 | bare |

**AND ONE HALF THAT IS NOT THE CLASS WINDOW: THE SYMBOL.** The interface's OWN
member variable (w03 29:11), member net (w04 30:11) and localparam (w05 31:11)
are golden-**bare** inside a condition, and the same three as call-statement
arguments (w19/w20/w21) are golden-bare too, while a formal and a subroutine
local in those very positions bind. Road 1 explains it exactly — `bindVariable`
walks the enclosing `uhdmfunction`/`uhdmtask` scope's own `Variables()` and
`Io_decls()` and stops. **That is why the law is not simply
`classMethodNoBind = true`**, and why the predicate carries an explicit
declaring-scope test.

The decode also PREDICTS the other homes, and arm `a3_muststay` confirms every
one: a package function, an uninstantiated MODULE WITH PORTS (buvm13's
`m13_unused2` shape), a top module and an INSTANTIATED interface all bind
everywhere on both sides (their writers do late-bind), and an uninstantiated
PROGRAM is golden-**bare** exactly like the interface — `writeProgram` has no
`lateBinding` call either. That last one is **R2**: we over-bind there today,
pre-existing, unchanged by this pass, recorded and not taken.

## 4. THE LAW, AND WHY IT CANNOT MOVE ANYTHING AWAY

> **§ uninstIfaceBodyBindsInMethodWindow218** — the BODY of a subroutine declared
> in an interface DEFINITION that no instance elaborates binds a reference **only**
> when the reference stands in the in-body class method's BINDING WINDOW — a user
> call's argument list in STATEMENT position, or one of the six
> § refVarLocalWindowBinds5 CONDITION columns — **and** names a symbol that window
> admits: a FORMAL or a plain subroutine LOCAL read at `ctrlBodyDepth28 == 0`, or a
> variable declared in an UNNAMED statement block open at its own entry depth. Not
> under a cast operand, not inside a receiver-qualified expression-position call's
> argument list, never the function return name, and never the interface's own
> member or parameter.

### STATED GATE == CODE GATE

**STATED:** one new flag raised at ONE call site; one predicate; the window's
STATEMENT-position restriction extended to this body on the same term
§ classInBodyBareCallArgStmtOnly53 already uses.

**CODE:** `git diff` vs `5c4eb804` — **185 added / 3 removed, 150 of them
comment, 35 lines of code at FOUR sites**:

* `include/UhdmExporter.h` — `bool uninstIfaceSubBody218 = false;`, the
  predicate's declaration, and the decode.
* `src/ModuleEmit.cpp` — the flag is set and restored beside the existing
  `suppressRefActual` for `defAllInstCount[&def] == 0`. **`suppressRefActual`
  itself is left exactly as it was**: it also governs `TypeEmit`'s typespec
  actuals (three readers), which are not this law's business.
* `src/ExprEmit.cpp` — `uninstIfaceWindowBind218`, and ONE new arm at the top of
  the existing `else if (suppressRefActual)` branch that sets the actual from the
  same `netMap` the body was emitted with.
* `src/ExprEmit.cpp` — the two `ClassArgBindIf38 cab12(classArgBindDepth12,
  callStmtCtx0 || !(curSubClassScope9 && !curSubOob9))` sites gain
  `|| uninstIfaceSubBody218` inside the negation, so the argument window is
  STATEMENT-position only for this body as well (w27 is the cell). Inert
  everywhere else, because the flag is false everywhere else.

**ADD-ONLY IS THE SAFETY PROPERTY, AND IT IS MEASURED, NOT ASSERTED.** The patch
reaches exactly one branch that previously did nothing, and the only thing it can
do there is SET a null `Actual_group`. The whole-dump diffs prove it: the corpus
mover is **40 lines added / 0 removed**, and each of the six foreign boundary arms
is **2 lines added / 0 removed**. A reference golden leaves unbound therefore
**stays unbound by construction**, and every cell the predicate fires on is a cell
arm a2 measured golden binding.

### the gates that were REFUTED, each on a grid arm

| candidate gate | refuted by |
|---|---|
| "an uninstantiated interface's body binds NOTHING" (the pristine behaviour) | arm a1 u03-u14, a2 w01/w02/w17/w18/w26/w31, a4 d01-d09 — golden binds 13, 12 and 8 cells |
| "it binds EVERYTHING, like a module" | arm a2 w15/w16 (while/for conditions), 38:14/39:20/43:14 (one body deeper), 40:10 (an assignment) — golden bare |
| "set `classMethodNoBind = true` and be done" | arm a2 w03/w04/w05 and w19/w20/w21 — the interface's own member var, member net and localparam are golden-BARE in the very windows a formal binds in |
| "the DPI export is what is special" | arm a4: the DPI-exported function (d01/d02), the DPI-exported TASK (d05/d06) and a PLAIN function (d08/d09) in the same interface behave identically, and so does the ported interface `if418_p` (e01/e02) |
| "an interface is special; a program is not" | arm a3 60:21/62:7/62:16 — an uninstantiated PROGRAM is golden-bare too (**R2**), because `writeProgram` has no `lateBinding` call either |
| "an uninstantiated MODULE behaves the same" | arm a3 u01-u03, an uninstantiated module WITH PORTS — golden BINDS, `writeModule` late-binds; buvm13's `m13_unused2` said the same |
| "the law is view-independent in golden" | arm a1/a2/a4 elab — with `-elabuhdm` Surelog elaborates the definition and golden binds everywhere. The law's cells stay a strict SUBSET in that view, which is why the patch is written view-independent |

## 5. QUESTION (3) — THE GOLDEN GRID

`grid218.sh` + `grid218/`, five arms × two views, one REAL Surelog golden each
(`~/git-repos/Surelog/build/bin/surelog`, the one `scripts/verify_golden.py`
names — earl120's R4 trap), `-parse -d coveruhdm -nobuiltin -nocache` and again
with `-elabuhdm`. Surelog and our binary run in the SAME directory (buvm8's
`bndarms` trap). The per-arm `uhdm-cmp` verdict is RECORDED and is **not** the
scorer (r10uvm210's caution: `-nobuiltin` makes golden's `AllPackages` shorter
than ours, so every arm's head is that vector-size mismatch). The scorer is
`cen218.py`, the reference-actual census, **golden-vs-golden CALIBRATED FIRST in
every cell (null in all 10)**.

| arm | what it varies | MISSING-OURS pris→pat, parse | EXTRA / OTHER | verdict |
|---|---|---|---|---|
| **a1_iface** | THE LAW's three homes side by side — an UNINSTANTIATED interface, an INSTANTIATED one and a MODULE, each with the same twelve reference positions | **13 → 2** | 1 → 1 / 1 → 1 | closes; the 2 left are the instantiated interface's own member on an lvalue inside a control body, **R3**, unchanged |
| **a2_window** | THE WINDOW BOUNDARY — 31 cells: both window kinds, the depth half, while/for, concat, system call, cast, named block, unnamed block, receiver-qualified statement and expression position, and the interface's own member var / net / localparam as the OVER-FIRE control | **12 → 0** | 6 → 6 / 1 → 1 | **CLOSES COMPLETELY**; not one over-fire cell moves |
| **a3_muststay** | THE MUST-STAY CONTROL — package function, in-body class method, out-of-body class method, INSTANTIATED interface, uninstantiated MODULE WITH PORTS, uninstantiated PROGRAM, top module | **0 → 0** | 8 → 8 / 0 → 0 | **byte-identical cell lists in BOTH views** |
| **a4_dpi** | THE CORPUS SHAPE — a DPI-EXPORTED function and TASK in an uninstantiated interface whose export items sit far above their definitions, a plain function beside them, and a PORTED uninstantiated interface | **8 → 0** | 0 → 0 / 0 → 0 | **CLOSES COMPLETELY** |
| **a5_sibling** | R1 ISOLATED — a call statement whose sibling argument is a RECEIVER-QUALIFIED method call | **6 → 2** | 0 → 0 / 2 → 2 | closes 4 of 6; the 2 left are R1, characterised below |

The `elab` column varies the GOLDEN only (the arm's own database is the one our
binary writes without `--elabuhdm`, exactly as `grid216.sh` does it), and it
tells the same story: MISSING-OURS falls in every arm that has the law's shape,
**and `EXTRA-OURS` and `OTHER` never rise in any of the ten arm-views.**
**AWAY-GOLDEN 0, MOVED-WRONG 0.**

## 6. QUESTION (5) — THE PREDICTION, AND THE MOVERS

`PREDICT.r10uvm218.txt` was written and run from PRISTINE databases and PRISTINE
sources alone, before either corpus was swept with the patched binary.
`predict218.sh` reads each row-mode's own `cmds.txt` file set and asks whether it
declares an interface that nothing in the set instantiates; a database that never
compiled such a file cannot reach the law's one call site.

* FIRE SET: **6 of 1573** surelog row-modes, **0 of 1462** uhdm2rtlil.
* All six name the same interface, `svaunit_vpi_interface`, and four of them —
  `AmiqSimpleTestSuite` ×2 and `Monitor` ×2 — are `SLANG_REJECT` with **no
  `slang.uhdm` at all**. `MiniAmiq` ×2 is the only survivor.
* PREDICTION: **exactly two** surelog byte movers, `MiniAmiq` ×2, TO-GOLDEN,
  AWAY 0, MOVED-WRONG 0; **zero** uhdm2rtlil movers.

**MEASURED: 2 / 956 and 0 / 1358 — the two predicted, by name, and no others.**
Twenty cells moved in each mode (the two modes' databases carry the same md5),
every one of them onto golden's own value:

```
  123:25 a_test_name io_decl   309:37 enable_sva  bit_var   407:24 a_test_name io_decl
  149:11 a_reason    io_decl   333:24 a_test_name io_decl   407:37 enable_sva  bit_var
  206:16 crt_state   enum_var  333:37 disable_sva bit_var   433:24 a_test_name io_decl
  219:10 a_sva_type  io_decl   357:24 a_test_name io_decl   433:37 enable_sva  bit_var
  258:10 a_sva_type  io_decl   357:37 enable_sva  bit_var   467:50 enable_sva  bit_var
  309:24 a_test_name io_decl   382:24 a_test_name io_decl   482:50 disable_sva bit_var
                              382:37 enable_sva  bit_var   498:50 disable_sva bit_var
```

There is **no unpredicted mover to attribute** — no layout class, no allocation
churn — because the patch allocates nothing: it adds one `bool` member and a
predicate, and the `netMap` it reads was already built and already passed to this
call.

## 7. QUESTION (6) — THE GATES AND THE BOUNDARY

`GATES.r10uvm218.txt` carries every number. Headlines: goldens 23/0 on both
binaries with the `/bin/false` control at 23 FAIL; uhdm2rtlil 679/50/2 in both
modes on both binaries with `ct8rows` PASS three ways and `byteverify` 0/1358;
surelog **475/6 default + 469/6 testflags on BOTH binaries**, `ct8rows` PASS
against the committed baseline AND against this pass's own pristine — **0
differing rows over 1588, status column and dump column, NO ROW CONVERTED IN
EITHER DIRECTION**.

The seven protected CMP_EQUAL row-modes, both columns scored explicitly, judge
rc = 0 on both binaries: `BuildUVMPkg` ×2, `SimpleUVM` ×2, `Earlgrey_0_1` ×2,
`Scoreboard`/default — **all HELD**, and none is even in the fire set. Ten of the
twelve measured head-set cmp logs are byte-identical between the two binaries;
the two that differ are MiniAmiq's.

Canaries: `canaries.sh` ok=52 changed=0 (surelog) and ok=8 changed=0 (u2r);
`ctcan2.sh` PASS on both; `canaudit.sh` over this pass's drivers **audited=29
UNCOVERED=0 FENCE-BREACH=0**. Protected databases by name, both modes:
**`InterfaceModPort` — AN INTERFACE TEST, and therefore the pin that matters most
for an interface law — SAME**, `BlackParrotComplex` SAME, `YosysOldOr` SAME,
`SVSwitch` pinned at `4842211c4030`, `YosysVerx` pinned at `6ccda350c24a`.

Wide boundary over a COPY of the whole probe tree (subdirectories included, both
views, both binaries, children `</dev/null`, the file list on fd 3, scratch keyed
on the RELATIVE path): **LISTED = PROCESSED = 5501, MOVED_ARMS 12, RC_DIFFS 0**.
Six are this pass's own grid arms — the POSITIVE CONTROL that proves the gate can
see. All twelve were re-scored against REAL Surelog goldens by `armscore218.sh`
(calibration null in every arm-view): **TO-GOLDEN 44, AWAY-GOLDEN 0**. In each of
the six foreign arms the whole-dump diff is exactly **two added lines** — one
`|vpiActual:` and the object it names — on a formal or a local in a condition at
depth 0 inside an uninstantiated interface, i.e. exactly the cell this law names.

**No § 215 arm moved. No § 214 arm moved. No buvm13 or buvm15 arm moved. No
uvm82-91 arm moved. No sd8-12 arm moved.** The one § 216 arm that moved is
`g216_d_iface_top` — the portless-uninstantiated-interface topology — and on it
**§ 216's OWN scorer reads identical on both binaries and null against golden**
(`RIGHT-BOTH=12 ONLY-GOLDEN=0 ONLY-OURS=0` for calibration, pristine and
patched): only the reference-actual half moved, toward golden.

## 8. THE FILES

| file | what it is |
|---|---|
| `cen218.py` | THE SCORER — the reference-actual census, keyed (vpiName, line, col) as a MULTISET, classifying every key SAME / MISSING-OURS / EXTRA-OURS / OTHER. |
| `grid218.sh`, `grid218/`, `GRID.pristine.*`, `GRID.patched.*` | question (3): five arms × two views, both binaries, calibration first. |
| `predict218.sh`, `PREDICT.r10uvm218.txt`, `PREDICT.stage1.*` | question (5), written and run before any patched sweep. |
| `DECODE.r10uvm218.txt` | question (4): the two Surelog roads, read `file:line`. |
| `POPULATION.r10uvm218.txt` | question (2): the population by referent kind × subroutine kind × view, both one-sided sets, and R1 isolated on arm a5. |
| `CENSUS.pristine.MiniAmiq.*`, `CENSUS.patched.MiniAmiq.*`, `CENSUS.moved-cells.*`, `CENSUS.MiniAmiq.wholedump.diff.txt` | the corpus census on both binaries, the 20 moved cells with golden's value beside each, and the ADD-ONLY whole-dump proof. |
| `bound218.sh`, `BOUNDARY.r10uvm218.txt`, `armscore218.sh`, `ARMSCORE.r10uvm218.txt` | question (6): the 5501-arm wide boundary and the against-golden re-score of every mover. |
| `GATES.r10uvm218.txt` | every gate number, both binaries. |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the head on both binaries, both modes. |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, copied unchanged from their canonical homes. |

## 9. RESIDUES

* **R0 — THE NEW MiniAmiq HEAD IS A `foreach` HEADER'S ARRAY TYPESPEC.** 20 lines,
  one head, both row-modes, the two logs byte-identical. Golden's
  `unsupported_typespec (a_lof_sva)` @`svaunit_vpi_interface.sv:198:15` against our
  `class_typespec (svaunit_concurrent_assertion_info)` @196:45 — the formal is
  declared `svaunit_concurrent_assertion_info a_lof_sva[]`, an UNSIZED dynamic
  array of a class handle, and golden gives the `foreach` header's element
  typespec an `unsupported_typespec` carrying the FORMAL'S OWN NAME while we give
  it the class typespec. A different family (typespec linkage, not reference
  binding). `head_pat_MiniAmiq.default.cmp` carries it.
* **R1 — THE SIBLING OF A RECEIVER-QUALIFIED CALL ARGUMENT DOES NOT BIND.**
  `svaunit_vpi_interface.sv:383:56` `a_sim_time`, the one corpus cell of 21 the
  law does not take. Our emitter renders a call STATEMENT one of whose arguments
  is a receiver-qualified method call through the hier_path arm that raises
  § classInBodyRecvCallArgNoBind52's counter, and fence (5) of the predicate —
  correct for the class-method twin — then silences the SIBLING arguments too.
  Arm `grid218/a5_sibling` separates the features on one golden: the receiver call
  FIRST (s02) and SECOND (s04) both silence the sibling formal, while a BARE call
  as sibling (s03) and a receiver call in a CONDITION (s05) do not. A later pass
  can lift it by scoping fence (5) to the receiver call's OWN argument list. It is
  a MISSING residue in both views: **never AWAY**.
* **R2 — AN UNINSTANTIATED PROGRAM IS GOLDEN-BARE TOO, AND WE BIND IT.** Arm a3
  `pr318_un` 60:21, 62:7, 62:16: golden leaves the body's local and formal bare —
  `UhdmWriter::writeProgram` (1795-1900) has no `lateBinding` call, exactly like
  `writeInterface` — and our emitter binds them, on BOTH binaries. Pre-existing,
  the same law's PROGRAM twin, unchanged here because the flag is raised only at
  the interface call site. The decode says what the fix is; the measurement says
  it is a separate landing.
* **R3 — AN INSTANTIATED INTERFACE'S OWN MEMBER ON AN lvalue INSIDE A CONTROL
  BODY.** Arm a1 `gvar218i` 63:24 and 64:31: golden binds the interface's
  `bit_var`, we do not, while the identical assignment one line up at control
  depth 0 binds on both sides. Pre-existing, a different family (the elaborated
  interface's variable fixup), unchanged pristine to patched.
* **R4 — WE MINT ENUM-CONST ACTUALS THE UNINSTANTIATED INTERFACE'S GOLDEN DOES
  NOT HAVE.** Sixteen cells in the corpus holder, one in arm a1 (`E218_A` 33:28),
  six in arm a2. Golden leaves an enum-const reference bare in this body and we
  bind a minted `enum_const`; the arm shows it happens inside and outside the
  window alike, so it is NOT this law's window question. Pre-existing on both
  binaries, EXACTLY unchanged (the EXTRA-OURS cell lists are byte-identical), and
  deliberately left: removing it is a separate law with its own grid.
* **R5 — OUR FOR-LOOP ITERATORS BIND WHERE THE PARSE-VIEW GOLDEN LEAVES THEM
  BARE.** Arm a2 `i218` 42:26/42:36/44:20 and `j218` 48:26/48:38. The ELAB-view
  golden BINDS them, so this is a VIEW disagreement, not a simple over-fire, and
  it is why the law was written ADD-ONLY rather than by setting
  `classMethodNoBind`: a blanket silence would have moved these AWAY in the elab
  view. Unchanged on both binaries.
