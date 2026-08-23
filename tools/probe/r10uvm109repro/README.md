# r10uvm109 — § `classPropNewLhsNoHoist109` — **THE `= new` LVALUE OF A CLASS PROPERTY NEVER ENTERS SURELOG'S LATE-BINDING POOL, SO GOLDEN MINTS NO WIRE FOR IT** — uvm107's R0, the SimpleUVM ×2 head, **CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `5011fd9` |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY — one new file-static predicate, one new conjunct at the § `classPropRefs` push site |
| probe surface | `tools/probe/r10uvm109repro/` only |

## READ THIS FIRST — the numbers

`rowheads.sh` on the pass's own pristine and patched sweeps, same instrument
both times:

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **17** | **42** | 1 — a **NEW** head, and it is uvm107's R-C (see §7 R0) |
| SeqDriver default / testflags | 29 | 29 | 1 unchanged, byte-identical head text (16 cells moved BELOW it) |
| Scoreboard default | 42 | 42 | 1 unchanged |
| MiniAmiq default / testflags | 348 | 348 | 1 unchanged |
| BuildUVMPkg default / testflags | 17 | 17 | 1 unchanged |
| Earlgrey_0_1 default / testflags | 36 | 36 | 1 unchanged |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes) | |
| byte movers | — | **5 / 956** surelog (4 predicted + the Scoreboard COIN), **0 / 1358** uhdm2rtlil | |
| the head's family, nine UVM databases | 0 of 64 cells agreed | **64 / 64 agree**, **0 AWAY**, 0 still-different, over 454,152 scored reference cells | |
| SimpleUVM `work@top` implicit-wire NAMES ours has and golden lacks | 11 | **2** | |
| SeqDriver `work@top_tb` ditto | 10 | **1** | |
| implicit-wire names GOLDEN has and ours lacks | 8 | **8 — the identical set** | |
| the golden grid (arms a1/a2/a3, per view) | 12 of 24 net cells agreed | **22 / 24**, **0 away** (the 2 left are uvm107's R-MULTI) | |

**AND THE HEAD IT LEFT BEHIND IS ALREADY ON THE BOARD.** SimpleUVM's new head is
**byte-identical (object ids aside) to Scoreboard/default's** — the unfolded
unary MINUS at `uvm_sequencer_base.svh:529:23` that uvm107 named R-C. ONE residue
now heads **THREE** rows (SimpleUVM ×2 + Scoreboard/default).

## 1. THE HEAD, CONFIRMED FROM `BaseClass.h` + THE GENERATED `Compare` FIRST

The 17-line head, verbatim from the pristine cmp log
(`head_pris_default_SimpleUVM.cmp`):

```
LHS: <null>
RHS:
decompile:
logic_net: (work@top.rsp_export), line:228:3, endln:228:13
|vpiParent:
\_module_inst: work@top (work@top), file:.../SimpleUVM/testbench.sv, line:44:1, endln:71:10
|vpiName:rsp_export
|vpiFullName:work@top.rsp_export
|vpiNetType:1
```

**THE FIELD IS `ref_obj::Actual_group`, NOT `module_inst::Nets`.** `LHS: <null>`
with a full RHS is the SINGULAR `SafeCompare` overload's mirror arm
(`~/.local/include/uhdm/BaseClass.h:187-193`, `lhs == nullptr && rhs != nullptr`);
the VECTOR overload (`:202-224`) names BOTH CONTAINERS on a size mismatch and
would have printed the net LIST, not one net. Read off both `uhdm-dump`s, the
carrier is golden's `ref_obj (rsp_export)` @228:3 in the **`uhdmtopPackages`**
copy of `uvm_pkg`, whose `vpiActual` is EMPTY and whose ours is the wire —
`design::Compare` (`~/git-repos/UHDM/build/generated/src/design.cpp:296-302`)
walks `AllPackages` → `TopPackages` → `AllModules`, so the reference is reached
long before any module's net list. Confirmed on the object itself: the ref's
`vpiParent` is a one-element `hier_path` whose own parent is the `assignment`
whose `Rhs` is a `method_func_call` named `new` — **identically on both sides**.

**THE BRIEF'S SOURCE GUESS WAS WRONG, AND SO WAS uvm107's.** The site is NOT
`uvm_sequencer.svh:228` and it is NOT `rsp_export.<member>`, nor is 228 the
property DECLARATION. It is `uvm-1.2 seq/uvm_sequencer_param_base.svh:228`,
inside the OUT-OF-BODY constructor `uvm_sequencer_param_base::new`:

```systemverilog
function uvm_sequencer_param_base::new (string name, uvm_component parent);
  super.new(name, parent);
  rsp_export              = new("rsp_export", this);   // :228  <- THE HEAD
  sqr_rsp_analysis_fifo   = new("sqr_rsp_analysis_fifo", this);
  sqr_rsp_analysis_fifo.print_enabled = 0;
  m_req_fifo              = new("req_fifo", this);     // :231
```

**ALL SIXTEEN CELLS ARE `<class property> = new(...)` LVALUES.** The span-free
reference join over SimpleUVM/default (`cells109.py`, keyed view+owner+name so a
macro-expanded span cannot split a cell) returns exactly 17 references where ours
binds a wire golden does not; sixteen carry `parent = hier_path` and every one of
them is an `= new` lvalue, resolved back to its source line:

| owner (out-of-body body) | line | written |
|---|---|---|
| `uvm_component::new` | uvm_component.svh:1800 | `event_pool = new("event_pool");` |
| `uvm_phase::new` | uvm_phase.svh:817 | `m_end_node = new({name,"_end"}, …);` |
| `uvm_sequencer::new` | uvm_sequencer.svh:152 | `seq_item_export = new (…);` |
| `uvm_sequencer_param_base::new` | …param_base.svh:228 / :229 / :231 | `rsp_export` / `sqr_rsp_analysis_fifo` / `m_req_fifo` `= new(…)` |
| `uvm_reg::new` / `::clear_hdl_path` | uvm_reg.svh:1178 / :1183 / :1355 | `m_atomic = new(1);` `m_hdl_paths_pool = new("hdl_paths");` |
| `uvm_reg_block::new` / `::clear_hdl_path` | uvm_reg_block.svh:956 / :1971 | `hdl_paths_pool = new("hdl_paths");` |
| `uvm_reg_file::new` / `::clear_hdl_path` | uvm_reg_file.svh:230 / :266 | `hdl_paths_pool = new("hdl_paths");` |
| `uvm_mem::new` / `::configure` / `::clear_hdl_path` | uvm_mem.svh:951 / :984 / :2150 | `m_hdl_paths_pool = new(…);` `mam = new(…);` |

The seventeenth is `uvm_root::new` `clp` @339:3 — `clp = uvm_cmdline_processor::get_inst();`,
an ORDINARY assignment lvalue where golden binds the `class_var` and we mint a
wire. A different mechanism, untouched here; residue R-CLP (§7).

## 2. THE LAW

> **§ `classPropNewLhsNoHoist109`** — *A class-property name written as the LEFT
> side of a `= new` CLASS construction never joins Surelog's late-binding pool.
> `CompileHelper::compileBlockingAssignment`'s own `= new …` arm hands
> `compileExpression` a `paHierarchical_identifier`, which lands in the hier_path
> builder; that builder mints the path's first element as a bare name-only
> `ref_obj` and NEVER calls `component->needLateBinding` on it, where every
> ordinary `ref_obj` road does. Out of the pool means out of
> `UhdmWriter::lateBinding`'s walk, so the implicit-wire mint can never fire:
> golden binds nothing and the hoisting module carries no wire of that name. The
> DYNAMIC-ARRAY form `= new[n]` is NOT in the family — it takes the ordinary
> lvalue road and golden DOES mint its wire.*

### DECODED FROM SURELOG, file and line

1. **The `= new` road.** `CompileHelper::compileBlockingAssignment`
   (`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:4531-4554`): when the
   node after the operator is a `paHierarchical_identifier` the arm reads
   `Hierarchical_identifier` / `Select` / `Class_new` and calls
   `compileExpression(component, fC, Hierarchical_identifier, …)`, then builds the
   RHS as a `method_func_call` named `"new"` by hand.
2. **Where the lvalue is built.** `compileExpression`'s
   `paHierarchical_identifier` arm (`CompileExpression.cpp:2696`) walks the
   node's SIBLINGS; the `paSelect` sibling the `= new` grammar puts there sends it
   into `compileSelectExpression` (`:2786-2793`), whose `slStringConst` /
   `paPs_or_hierarchical_identifier` arm (`:1372-1384`) makes a `hier_path`, mints
   the base element
   ```cpp
   ref_obj *r1 = s.MakeRef_obj();
   r1->VpiName(name);  r1->VpiFullName(name);
   path->Path_elems(elems);  elems->push_back(r1);  r1->VpiParent(path);
   ```
   and returns the path (`:1549`). **There is no `needLateBinding` call anywhere
   in that arm.**
3. **What the ordinary roads do instead.** Every other `ref_obj` construction
   pairs the mint with the pool: `CompileExpression.cpp:2984-3000` (the bare-name
   fall-through of the same arm), `:5768-5786`, `:5794-5809`, `:1830-1844`
   (port expressions), `CompileHelper.cpp:4277`, `CompileAssertion.cpp:95` — all
   `if (bindVariable(...)) ref->Actual_group(var); else component->needLateBinding(ref);`.
4. **The pool and the mint.** `DesignComponent::needLateBinding`
   (`include/Surelog/Design/DesignComponent.h:189-193`) is the only writer of
   `m_needLateBinding`; `UhdmWriter::lateBinding` (`UhdmWriter.cpp:3294-3296`)
   iterates `mod->getLateBinding()` and nothing else, and the implicit-wire mint
   (`UhdmWriter.cpp:3982-4004`) sits at the end of THAT walk. A reference that
   never entered the vector is never considered, so no wire is ever made for it.
5. **Which module would have hoisted it.** Unchanged from uvm107 § 2 point 3 —
   `CompileHelper::importPackage` copies a package's unbound-reference list into
   every importing scope (`CompileHelper.cpp:190-193`) and `CompileModule.cpp:571-581`
   feeds every FILE-SCOPE `import uvm_pkg::*;` to that call. That is why the
   surplus wires land in `work@top` (SimpleUVM) and `work@top_tb` (SeqDriver) and
   in no module of Scoreboard / MiniAmiq / BuildUVMPkg, which import nothing.

## 3. THE GRID — golden's answer for every syntactic position, both views

`grid109.sh <arm.sv> <bin A> <bin B> <workdir> <cen bin>` builds three databases
per view (`def` and `--elabuhdm` / `-elabuhdm`), echoes every command with its own
`rc` into `<workdir>/cmds.txt`, and censuses all six. `GRID.txt` has every cell
verbatim. `g109_a1.sv` gives each position its OWN property name (a grid that
calls everything `a_t`/`b_t`/`c_t` is self-confirming, RESUME §9), so the
"one implicit wire per NAME per module" rule cannot merge two answers.

**The decisive table — golden's implicit wires in `work@top109`, arm a1:**

| cell | written | golden mints? | ours, pristine | ours, patched |
|---|---|---|---|---|
| 01 `newLhsA = new();` | class-new lvalue | **NO** | wire | **NO** ✓ |
| 02 `newLhsArgB = new(7);` | class-new with args | **NO** | wire | **NO** ✓ |
| 03 `newArrC = new[3];` | **array-new** lvalue | **YES** | wire | wire ✓ |
| 04 `plainAsgD = null;` | plain handle lvalue | **YES** | wire | wire ✓ |
| 05 `dotLhsE.fld = 4;` | hier_path lvalue | NO | — | — ✓ |
| 06 `loc9 = bareReadF;` | bare read | **YES** | wire | wire ✓ |
| 07 `memReadG.fld` | `prop.member` read | NO | — | — ✓ |
| 08 `chainReadH.hh.fld` | `prop.member.member` | NO | — | — ✓ |
| 09 `stmtCallJ.take(2);` | receiver call, STATEMENT | NO | — | — ✓ |
| 10 `if (exprCallK.ask(1)==0)` | receiver call, EXPRESSION | NO | — | — ✓ |
| 11 `chainCallL.hh.take(3);` | CHAINED receiver call | NO | — | — ✓ |
| 12 `idxSelM[1]` | `prop[i]` select | NO | — | — ✓ |
| 13 `idxObjN[2].fld` | `prop[i].member` | NO | — | — ✓ |
| 14 `plain9(callArgP);` | user call argument | **YES** | wire | wire ✓ |
| 15 `plain9(callArgMemQ.fld);` | argument `prop.member` | NO | — | — ✓ |
| 16 `this.thisMemR` | `this.prop` | NO | — | — ✓ |
| 17 `lhsPlainS = 9;` | scalar plain lvalue | **YES** | wire | wire ✓ |
| 18 `rhsPlainT` | plain RHS read | **YES** | wire | wire ✓ |
| 19 `$display(…, sysArgU)` | system-call argument | **YES** | wire | wire ✓ |
| 20 `if (condV == 0)` | condition operand | **YES** | wire | wire ✓ |
| 21 `return retW;` | return operand | **YES** | wire | wire ✓ |
| ctl `ibOnlyZ` in an IN-BODY method | the control | NO | — | — ✓ |

**11 of 11 net cells agree with golden after the patch, 9 of 11 before; 0 away.
Both views give the same table.**

**THE REGISTRATION RULE, stated exactly.** An unbound name in an out-of-body
package-class body reaches Surelog's pool from every position that builds a
PLAIN `ref_obj` — a bare read, an operand, a condition, a user call argument, a
system-call argument, a return operand, an ordinary assignment lvalue (scalar or
handle) **and an `= new[n]` lvalue** — and from NO position that builds a
`hier_path` ELEMENT: the base of `prop.member`, of `prop.member.member`, of a
receiver call in statement OR expression position, of a chained receiver call, of
`prop[i]` / `prop[i].member`, of `this.prop`, of a `prop.member` argument, **and
the lvalue of `= new`**. The dividing line is the BUILDER, not the position.

**RECONCILING uvm107's R2.** uvm107's verifier read `if (h.s.ask(v) == 0)` as
"a CHAINED receiver DOES get golden's wire for the base". It does not: the wire
that arm measures (`work@topb5.v@54:17`) is for the ARGUMENT `v`, a plain
`ref_obj` operand, not for the base `h`. Arm a1 cell 11 reads the BASE of a
chained receiver call on one golden and golden mints nothing for it — the same
answer as cells 07-13. There is no conflict; the two facts are about two
different elements of one call.

`g109_a2.sv` is the CLASS-KIND and `= new`-CORNERS grid. Golden's answer is the
same for every kind and the fence covers every corner:

| a2 cell | golden | pristine | patched |
|---|---|---|---|
| `copyNewA = new seed;` COPY constructor | **NO wire** | wire | **NO** ✓ |
| `ctorArgB = new(9);` | **NO wire** | wire | **NO** ✓ |
| `baseNewX = new(1);` a BASE-class property, from both bodies | **NO wire** | wire | **NO** ✓ |
| `statNewF = new(4);` a STATIC property | **NO wire** | wire | **NO** ✓ |
| `paramNewG = new(2);` a PARAMETERISED class's property | **NO wire** | wire | **NO** ✓ |
| `basePlainY = 2;` / `paramPlainH = 5;` the controls | **wire** | wire | wire ✓ |
| `pathNewC.sub2 = new();` hier_path lvalue | NO | — | — ✓ |
| `idxNewD[1] = new();` indexed lvalue | NO | — | — ✓ |
| `locNewK = new(6);` a plain LOCAL (uvm107's own fence) | NO | — | — ✓ |
| `ibNewE = new(5);` the SAME shape IN BODY | NO | — | — ✓ |
| `uHome4 = 3;` a `$unit`-home class | NO | — | — ✓ |

`g109_a3.sv` is the OWNER grid — two tops, a child instance, an
import-but-never-call module and an import-nothing module. Golden mints
`plainSet2` in `work@kid3` ALONE and `slotNew1` nowhere; the patched binary mints
`slotNew1` nowhere (3 cells TO-GOLDEN) and still mints `plainSet2` in all three
importing modules. That multiplicity is uvm107's **R-MULTI**, PRE-EXISTING and
untouched — the pristine binary shows the identical `plainSet2` spread.

**GOLDEN-VS-GOLDEN CALIBRATION FIRST** (`goldcen109.sh`). Over the five UVM tests
that have both modes, `default` and `testflags` are two independent Surelog runs
of the same design: **5 pairs calibrated, 0 SKIP, 0 pairs differ, EXPM_N = 0.**
Every golden-vs-ours number here is read against zero expected mismatch.

## 4. THE FIX

`src/ExprEmit.cpp`, at the § `classPropRefs` push site (~12744) — the arm that
records an unresolved CLASS-PROPERTY name for the hoisted-net pool. One new
conjunct:

```cpp
if (csc9 && csc9->asSymbol().kind == SymbolKind::ClassType &&
    !classNewAsgLhs109(expr.syntax)) {
```

`classNewAsgLhs109` walks the syntax parents to the nearest
`AssignmentExpression` / `NonblockingAssignmentExpression`, returns FALSE if the
walk came up the RIGHT side (a constructor ARGUMENT is not an lvalue), and
otherwise returns TRUE iff the right side is a `NewClassExpression` **or** a
`CopyClassExpression`. It deliberately does **not** accept
`NewArrayExpression` — arm a1 cell 03 is the reason, and that one difference is
why this is a new predicate rather than a second reader of uvm107's
`lhsOfWrittenNewAsg107` (written for the `ref_var`-local family, where the array
form is unreachable and both were fenced together).

The other three families that share the pool are untouched by construction: a
`with`-iterator argument (§ `withIterRefBindsHoistNet75`), a class-scope enum
constant (§ `classEnumConstBindsHoistNet76`) and a `ref_var` local
(§ `oobRefVarLocalHoistNet107`) cannot be the lvalue of a class `new`.

**DIRECTION: it removes a BINDING and the wire that binding forced, and nothing
else.** The order-blind whole-dump attribution in §6 proves the only objects that
change in any of the four movers are nine `logic_net`s with their five children
each and sixteen `|vpiActual` lines.

## 5. THE FENCE AND THE PREDICTION — written from PRISTINE databases only

`fence109.sh <sweep workdir> <cen bin> <out.tsv>` censuses BOTH sides of every
test in a sweep workdir and reports every reference that, on OUR side, is bound
to an IMPLICIT MODULE WIRE (`logic_net`, `vpiNetType 1`, parented at a
`module_inst`) **and** carries the `p = new(...)` lvalue signature `NEWLHS` —
spelled identically in both databases, so the classification never depends on our
own shapes.

| corpus | measured | SKIP | **HIT** | **RISK** | databases that MUST move |
|---|---|---|---|---|---|
| surelog | 956 | 617 | **64** | **0** | **4** |
| uhdm2rtlil | 1358 | 104 | **0** | **0** | **0** — the predicted NONE |

`RISK` is the blocking column: a reference where golden ALSO binds an implicit
wire of that name in that body. **Zero, corpus-wide, on both corpora** — the law
never touches a wire golden has. The four databases, BY NAME:
`{default,testflags}/{SimpleUVM,SeqDriver}`, 16 sites each, the sixteen listed in
§1.

`pred109.sh` is the MOVER PREDICTOR and reads OUR SIDE ALONE — no golden. It
reports two bounds: `OUTER`, any implicit-wire-bound `hier_path` base at all, and
`MAY-MOVE`, that shape plus the exact `NEWLHS` signature. Surelog: **5 databases
carry the outer shape, 4 the exact one**; uhdm2rtlil: **0 and 0**. The fifth,
`testflags/SimplifyHierPath`, is a CMP_EQUAL row whose one outer cell is a
TOPMOD-level `hier_path` base bound to a DECLARED net (`work@module_scope_top.a`
→ `o1`) with no class body anywhere near it; the predicate cannot reach it
(`inClassBodyEmit` + a `ClassType` parent scope + the `= new` syntax) and it did
not move.

## 6. THE GATE BATTERY

See `GATES.txt` for the whole battery with its numbers, the `cmds.txt` binary
audit, the four boundary runs and the order-blind mover attribution.

## 7. RESIDUES, named for the queue

**R0 — THE NEW HEAD of SimpleUVM ×2 (42 lines), AND IT IS ALREADY ON THE BOARD.**
uvm107's R-C, verbatim from `head_pat_default_SimpleUVM.cmp`, and
**byte-identical (ids aside) to `head_pat_default_Scoreboard.cmp`**:

```
LHS  constant: @529:23-529:24  |vpiDecompile:-1 |vpiSize:64 |INT:-1 |vpiConstType:7
RHS  operation: @529:23-529:25 |vpiOpType:1 |vpiOperand: constant UINT:1 @529:24
```

`uvm-1.2 base/uvm_sequencer_base.svh:529` — golden FOLDS the written `-1` into
ONE signed INT constant where we keep a unary MINUS operation over an unsigned
`1`. **ONE law now heads THREE rows** (SimpleUVM/default, SimpleUVM/testflags,
Scoreboard/default), which is the highest-leverage residue this family has
produced: § unary-minus literal folding. The 42-vs-17 count is a MASK REMOVAL,
not a regression — the new head prints more lines, and §6's order-blind
attribution proves the only objects that changed are the nine wires and their
bindings.

**R-CLP — the seventeenth cell, an ordinary lvalue golden RESOLVES.**
`uvm_root::new` `clp = uvm_cmdline_processor::get_inst();` @339:3
(`uvm_root.svh`): golden binds the **`class_var` `clp`** — it resolves the class
property outright — while we mint a hoisted wire. It survives this pass unchanged
(the lvalue is not a `= new`), it is the last class-property surplus wire in
SimpleUVM together with `top`, and it is a BINDING law, not a pool law: golden's
module-level search answered where ours did not. 1 cell in SimpleUVM, 1 in
SeqDriver. **Rank it next in this family** — it is what remains of the 11-name
surplus after this pass takes 9.

**R-TOPNET — `work@top.top` @67:18.** The other surviving SimpleUVM surplus wire.
Its reference is a DEFMOD-level one with no task/func owner at all, so it is NOT
a class-property pool cell; a different family, unmeasured here.

**R-MULTI (uvm107's) — the wire is minted ONCE PER REFERENCE, in the FIRST module
that cannot bind it.** Re-measured on `g109_a3.sv`: golden mints `plainSet2` in
`work@kid3` alone, both binaries mint it in `kid3`, `topA3` and `topB3`.
PRE-EXISTING and identical in both binaries; zero corpus reach (SimpleUVM and
SeqDriver each have exactly one importing module).

**R-NEWLHSSHAPE — our `p = new src` lvalue is NOT a hier_path.** Arm a2's
`copyNewA` cell: golden's copy-constructor lvalue carries the same one-element
`hier_path` parent as every other `= new` lvalue; ours is a plain `ref_obj`. The
BINDING now matches golden on both sides of the patch (that cell is TO-GOLDEN);
only the parent shape differs, and no generated `Compare` reads `vpiParent`
(RESUME §9), so it is invisible to the judge today. Noted, not ranked.

**R-ELABMULT — the ELAB copy COUNT.** Arm a1's elab view holds 32 span-free REF
cells whose golden/ours MULTIPLICITY differs (golden 7 copies of a body where we
hold 3, etc.). Identical in BOTH binaries, uvm103/105/107's multiplicity family,
untouched here.

**R-DEFCOPY — the DEF listing's half.** In the `DEFPKG` listing
`inClassBodyEmit` is false by construction, so neither binary hoists there and
both read `NONE` where golden also reads `NONE`; the only DEFPKG residue left on
these cells is the `NEWLHS` shape of R-NEWLHSSHAPE. Not cmp-visible today.

**R-P / R-NONREFVAR (uvm107's) — still open, still ranked.** The 8 references
where GOLDEN mints an implicit wire and we do not, in SimpleUVM/default:
`process`-typed locals (`uvm_root::run_test` `phase_runner_proc` @502:5,
`uvm_reg::XatomicX` `m_reg_process` ×3), `uvm_process_report_message` `p`,
`uvm_sequence_library::body` `select_rand` / `select_randc`, and
`uvm_phase::get_predecessors_for_successors` `uvm_phase`. **Identical before and
after** — this pass's golden-only set is byte-equal to the pristine one.

## 8. FILES

```
README.md                       this file (the decoded law)
GATES.txt                       the whole gate battery with its numbers
GRID.txt                        the golden grid, both views, cell by cell
SCORE.uvm9.txt                  TO-GOLDEN/AWAY/STILL over the nine UVM databases
PREDICTION.txt                  the fence + the mover predictor, from PRISTINE only
PREDICTION.fence_pristine_*.tsv the fence rows
PREDICTION.pred_pristine_*.tsv  the mover predictor's candidate rows
BOUND.{file,dir}.{def,elab}.txt the four boundary runs
ATTRIB.file.txt                 every differing boundary arm, attributed against a fresh golden
ATTRIB.movers.txt               the order-blind attribution of the five byte movers
head_pris_default_SimpleUVM.cmp the whole 17-line head this pass CLEARED
head_pat_default_SimpleUVM.cmp  the whole NEW 42-line one                 (R0)
head_pat_default_Scoreboard.cmp Scoreboard/default's head - the SAME object (R0)
head_pat_default_SeqDriver.cmp  SeqDriver's head, byte-identical before and after
g109_a1.sv                      the REFERENCE-POSITION grid (21 positions + control)
g109_a2.sv                      the CLASS-KIND and `= new`-CORNERS grid
g109_a3.sv                      the OWNER grid (two tops, a child, import-only, import-nothing)
r10uvm109cen.cpp                the reference-actual + implicit-net census (ACTIMPL / NEWLHS)
cells109.py                     per-cell golden/pristine/patched verdict printer
score109.py                     TO-GOLDEN / AWAY / STILL scorer (span / nospan / nets keys)
build109.sh                     builds a probe from THIS directory
grid109.sh                      builds a grid arm's 3 databases in BOTH views
fence109.sh                     the fence over a sweep workdir
pred109.sh                      the mover predictor over a sweep workdir
bound109.sh                     the boundary gate
goldcen109.sh                   golden-vs-golden calibration
attrib109.sh byteverify.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh ct8rows.sh
                                the standing gate instruments, copied so this
                                directory can re-run its own battery
```
