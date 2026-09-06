# r10uvm172 — § `recvNamesSubroutineCollapsesStmtCall172` — **A STATEMENT CALL WHOSE CHAIN'S BASE IDENTIFIER IS ALSO A SUBROUTINE NAME COLLAPSES TO ONE BARE `func_call`/`task_call`** — the MiniAmiq ×2 40-line head CLEARED

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `d53fbaad` |
| pristine binary | md5 `fb82059559765e79eee43ee365aa4879`, built from this pass's OWN worktree at a clean `d53fbaad` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `01bb3fd9524dbf34f3dc255634a90b86`, frozen `chmod 555` |
| production surface | `src/StmtEmit.cpp` (the law, the name search, the emitter and the one call site in the `StatementKind::ExpressionStatement` arm), `src/UhdmExporter.cpp` (the design-final link drain), `include/UhdmExporter.h` (the two declarations, the deferred-link pool and the law's summary) |
| probe surface | `tools/probe/r10uvm172repro/` only |
| docs | `RESUME.md` §3b — the MiniAmiq row, refreshed with the head this landing produced (it rides with the code, per the standing direction) |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **MiniAmiq default and testflags, 40 cmp lines, ONE head each — CLEARED.**  The head OBJECT changed (`func_call (copy)` @155:10 → a `bit_select`/`ref_obj` disagreement @233:24, §10); the line count is unchanged by coincidence, a cmp line count being the HEAD OBJECT's decompile size (RESUME.md §7).  The two modes' logs stay byte-identical to each other. |
| corpus rows changed | **0** — both corpora, both modes.  `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **2 / 956** surelog — **both PREDICTED BY NAME before the patched sweep ran**, from the 956 PRISTINE databases and their goldens alone.  **0 / 1358** uhdm2rtlil. |
| the corpus population | FOUR cells per row-mode, all in MiniAmiq: `svaunit_immediate_assertion_details.svh:155,159,163` (`copy.<member>.push_back(...)`) and `svaunit_immediate_assertion_info.svh:230` (`get_checks.checks_details.delete()`). |
| the census (nine UVM DBs × both modes, 956 corpus rows scored) | statement-position calls: **TO-GOLDEN 4 per mode, AWAY 0, MOVED-WRONG 0**; MiniAmiq AGREE 5113 → 5117, COLLAPSE 11 → 7; every other row unchanged cell for cell. |
| the grids (6 arms, both views) | 439 golden cells over the two views.  Deduped diff-lines against golden: **b_name 10→0, c_home 6→0, d_scope 8→0, e_deep 20→0, a_shape 10→2, f_args 18/23→2** — the surviving 2+2 are the two DECLINED shapes and nothing else.  Four arms reach **CMP_EQUAL** under the official judge. |
| the FLOOR | r10uvm171, r10uvm169, r10uvm167, r10uvm89, r10uvm77-79, r10uvm82-91, r10buvm3-15, r10sd8-12: **not one of their arms moved**. |
| the WIDE boundary (4813 arms, both views) | `LISTED=4813 PROCESSED=4813 PRODUCED_DBS=4656 MOVED_ARMS=11 RC_DIFFS=0` — 6 are this pass's own arms, 2 are r10uvm154's address-derived residue, and 3 are earlier passes' arms for THIS law that all move **TOWARD** golden (one to CMP_EQUAL). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `d53fbaad` worktree; it
came out **byte-identical to the main tree's `build/slang-uhdm`**
(`fb820595…`), and its own 956-row surelog sweep reproduced the committed
baseline **row for row** (`ct8rows` PASS, 0 differing rows, status AND dump
column).  `rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
MiniAmiq       default         40      1
MiniAmiq       testflags       40      1     (the two cmp logs BYTE-IDENTICAL, md5 68d1ca6b…)
```

The head, `svaunit_immediate_assertion_details.svh:155`:

```
   function svaunit_immediate_assertion_details copy();          // 149
     copy = ...::type_id::create("copy_...");                    // 150
     copy.check_name = check_name;                               // 152
     foreach(tests_names[index]) begin                           // 154
       copy.tests_names.push_back(tests_names[index]);           // 155
     end
     ...
LHS  func_call:        (copy)         id:254781  line:155:10-155:56
     |vpiName:copy
     |vpiFunction: function (svaunit_pkg::svaunit_immediate_assertion_details::copy) 149:4-167:15
RHS  method_func_call: (tests_names)  id:186842  line:155:15-155:26
     |vpiName:tests_names
     |vpiPrefix: ref_obj (…::copy::copy) 155:10-155:14
```

**THE JUDGE, DECODED WITH THE OWNER-FINDER FIRST** (`ct172own.cpp`, output in
`OWNER.r10uvm172.txt`).  Both objects are PRESENT, so this is neither
`SafeCompare` null form:

```
HEAD KINDS: LHS=func_call RHS=method_func_call
            (DIFFERENT KIND -> BaseClass::Compare's VpiType line failed FIRST;
             no field beyond it was read)
OWNER PAIR  begin()@154:35-156:10  (the foreach body)
   begin::Stmts   LHS=1  RHS=1
       [0] LHS=func_call(copy)@155:10-155:56   RHS=method_func_call(tests_names)@155:15-155:26
REFERENCE SCAN  golden begin()@154:35-156:10  edge vpiType=104 (vector index 0)
                ours   begin()@154:35-156:10 -> vector present size 1, [0] = method_func_call(…)
```

The edge is the owner `begin`'s `vpiStmt` VECTOR (relation **104**), index 0,
**size 1 on both sides** — nothing is missing on either side, and the walk stops
on `BaseClass::Compare`'s `VpiType` line before any per-kind field is read.
(The parent-chain probe reports `class_defn` and `function` as `no-repro` and
their descendants as `REPRO`: the ordinary `m_visited` cascade — a fresh Compare
started at the class reaches an EARLIER difference that the whole-design walk had
already visited.)

---

## 2. THE DECODE — Surelog source, read, not inferred

`CompileStmt.cpp:250` sends every `paSubroutine_call_statement` to
`CompileHelper::compileTfCall` (`CompileHelper.cpp:4135`).  Its USER-CALL arm
(`:4216-4251`) reads the FIRST name node, builds the
`method_func_call{vpiPrefix}` we already reproduce — and then throws it away:

```cpp
    std::pair<task_func*, DesignComponent*> ret =
        getTaskFunc(name, component, compileDesign, nullptr, nullptr);
    task_func* tf = ret.first;
    if (tf) {
      if (tf->UhdmType() == uhdmfunction) {
        func_call* fcall = s.MakeFunc_call();
        fcall->Function(any_cast<function*>(tf));
        call = fcall;                                 // <- the method call is DROPPED
      } else {
        task_call* tcall = s.MakeTask_call();
        tcall->Task(any_cast<task*>(tf));
        call = tcall;
      }
      call->VpiParent(pexpr);
    }
    ...
    if (call->VpiName().empty()) call->VpiName(name);              // the BASE name
    if (call->VpiLineNo() == 0)
      fC->populateCoreMembers(Tf_call_stmt, Tf_call_stmt, call);   // the WHOLE statement
    NodeId argListNode = fC->Sibling(tfNameNode);                  // see §4
```

`name` is `fC->SymName(dollar_or_string)` — the chain's FIRST name node, the
subscript never read (the same fact § `selRecvStmtCallBareNames124` decodes out
of this very function).  Every further name, the method and its arguments are
DISCARDED.  Surelog `Purge()`s its serializer (`CompileDesign.cpp:89`), which is
why the abandoned `method_func_call` never reaches the golden database — and
**why this law is decided BEFORE anything is minted on our side: we never
purge, so an object minted and abandoned would be serialized.**


---

## 3. HOW FAR THE NAME SEARCH REACHES — measured on GOLDEN, cell by cell

`getTaskFunc` (`CompileExpression.cpp:349`) walks the component's own
`getTask_funcs()`, then `getParentScope()` upward, then the component's
`FileContent`s, then `getFuncFromPackage` (the ACCESS PACKAGES, transitively),
then the instance definitions, then every file's file-level task/funcs.  The
grid asks golden which of those actually reach, in both views:

| cell | written | golden |
|---|---|---|
| head, b06, C1, C4, C6, e06-e11 | the enclosing function's own RETURN NAME | **COLLAPSE** |
| b02 | another FUNCTION of the enclosing class | **COLLAPSE** (`func_call`) |
| b03 | a TASK of the enclosing class | **COLLAPSE** (`task_call`) |
| b04 / b05 | a wildcard-imported package FUNCTION / TASK | **COLLAPSE** |
| d02 | a `$unit`-scope free function | **COLLAPSE** |
| d03 | an imported package function | **COLLAPSE** |
| C6 / C7 / d09b | the enclosing MODULE's own function / task | **COLLAPSE** |
| C1 (4 copies) | a package free function, HOME **and** wildcard-import CLONE | **COLLAPSE in all four** |
| d01 | an INHERITED base-class method name | keeps `method_func_call` |
| b07 | a method of ANOTHER class | keeps `method_func_call` |
| d04 | a NOT-imported package function | keeps `method_func_call` |
| d05 | a MODULE function seen from a CLASS home | keeps `method_func_call` |
| **C3** | an **OUT-OF-BODY** class method's own return name | **keeps `method_func_call`** (4 copies) |
| e03 / e04 | `this.`-rooted / `super.`-rooted | keeps its own shape (a third Surelog road) |

Two of those negatives are load-bearing and both are confirmed ON THE CORPUS,
not only on the grid:

* **inheritance.**  `uvm_recorder.svh:1107` `record.close(end_time);` inside
  `uvm_text_recorder::end_tr` — `record` is `uvm_object::record`
  (`uvm_object.svh:394`), INHERITED by `uvm_text_recorder`.  Golden does not
  collapse it (`getTaskFunc` never follows a base class), and neither may we.
  The first cut of this law DID collapse the grid's d01 twin; arm D convicted it
  and the fix is the FOUND SYMBOL's own parent scope
  (`sym->getParentScope() != sc0` refuses it), because slang's
  `ClassType::find` DOES answer a base-class name.
* **out-of-body.**  `uvm_printer.svh:992` `index_string.itoa(index);` inside
  `function string uvm_printer::index_string(...)` — the receiver IS the
  enclosing function's return name, and golden STILL does not collapse it,
  because an out-of-body definition is compiled in the enclosing PACKAGE's
  scope where the class's methods are invisible.  That is the same
  `curSubOob9` split § `classArgBind12` and § `tfItemBodyLocal148` already
  read, and it is what keeps SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg
  — every one of which holds that cell — byte-identical under this law.

---

## 4. THE ARGUMENTS

`argListNode = fC->Sibling(tfNameNode)`, and `tfNameNode` is the chain's SECOND
name node:

* a **TWO-name** chain (`recv.m(a,b)`) — the sibling IS the written
  `paList_of_arguments`, so the WRITTEN actuals survive and bind exactly as an
  ordinary call's.  Golden, arm F: `ffn172.fadd172(floc172, fint172);` gives
  `func_call(ffn172)` with two `ref_obj` arguments carrying `vpiActual` to the
  body locals; the formal and class-property twins (f02, f03) do the same.
* a **THREE-OR-MORE-name** chain (`recv.mem.m(a)`) — the sibling is the empty
  select between the second and third names and NO argument is compiled.  The
  head itself, f04, f06, arm A c01-c05, arm E e05.


---

## 5. THE PRODUCTION SURFACE — one predicate, one emitter, one call site

| where | what |
|---|---|
| `src/StmtEmit.cpp`, `flattenCallee172` | flattens slang's LEFT-ASSOCIATIVE `ScopedName` tree into the WRITTEN name components.  Only the DOT separator: `::` is Surelog's `paClass_scope` road and `this`/`super` its `paImplicit_class_handle` road, both of which have different answers and both of which parse to syntax kinds this walk refuses outright. |
| `src/StmtEmit.cpp`, `UhdmExporter::stmtCallCollapseSub172` | the NAME SEARCH: the enclosing scope chain (DIRECT members only — a found symbol whose own `getParentScope()` is not that scope is refused, which is the inheritance fence), that chain's imported packages walked transitively, then the compilation units.  The start scope skips the CLASS when `curSubOob9` — Surelog's out-of-body component switch. |
| `src/StmtEmit.cpp`, `UhdmExporter::emitCollapsedStmtCall172` | mints the `func_call`/`task_call`, names it after the base identifier, spans it over `e.syntax->sourceRange()` (which for the `with` forms runs THROUGH the clause), takes the link from `subMap` when it is already there, and fills the argument vector by the §4 rule. |
| `src/StmtEmit.cpp`, `StatementKind::ExpressionStatement` | the ONE call site — `emitCollapsedStmtCall172` first, `emitExpr` only if it declines.  Nothing is minted and abandoned. |
| `src/UhdmExporter.cpp`, `drainCollapseLink172` | the design-final half of the link, next to `drainScopedCallBind26()`: a callee not yet emitted when the caller's body was walked (a module task or a `$unit` free function declared after the caller — arm D cells d02, d09b).  The link is taken IMMEDIATELY whenever `subMap` already holds the callee, so a package's DEF and ELABORATED views each link THEIR OWN copy; only the not-yet-emitted case defers, and those have exactly one copy. |

### The DECLINED shapes (each measured, each a README residue)

A fifth gate is not a decline but a HAND-OFF: § `retNameRecvCollapse69` already
owns the one-component return-name receiver and keeps it (§6).

* **a chain whose SECOND component carries a subscript** (`recv.arr[1].m(5)`) —
  golden's `argListNode` lands on that subscript and compiles its INDEX as the
  call's one argument (arm A c06: `func_call(cpy172) args=1`, the argument the
  constant `1`).  ZERO corpus cells.  The predicate declines and the cell is
  byte-identical to pristine.
* **a statement call with NO enclosing subroutine** — a module
  `initial`/`always` body (arm F f09).  `currentScope` is STALE throughout
  `emitInstance` (RESUME.md §9), so there is no sound scope handle to search
  from.  ZERO corpus cells.
* **a call slang REJECTED** (`StatementKind::Invalid` / § `droppedCall14`).
  Surelog never learns that slang refused the member, so it would collapse
  those too; this law fires only on `ExpressionKind::Call`.


---

## 6. WHAT THIS LAW ADDS TO § `retNameRecvCollapse69` — and what it must NOT touch

§ `retNameRecvCollapse69` (`src/ExprEmit.cpp:918`) is THIS law restricted to a
receiver of EXACTLY ONE component that is EXACTLY the enclosing function's own
return name, and it carries its own argument window
(§ `retNameRecvCollapseArgsBindLikeBody15`).  Its text ranks the rest as
residues in as many words:

> *NARROWNESS: the receiver must be EXACTLY the return name.  A CHAINED receiver
> whose FIRST segment is the return name (`n_chain.inner.touch(n);`, arm a3 cell
> N6) ALSO collapses in golden — but to an ARGUMENT-LESS func_call, a different
> object — and has ZERO corpus population, so it is left to § deepRecvCall11 and
> ranked as a residue.*

That residue is exactly the MiniAmiq head, and it is no longer population-free.
This law therefore **DECLINES whenever § 69 owns the cell**
(`comps.size() == 2 && tf172 == currentSubSym`), and adds only

1. a receiver of **TWO OR MORE** components whose FIRST segment collapses — the
   head, and arm A c01-c05, arm B b06, arm C C1/C4/C6, arm D d02/d03/d09b, arm E
   e05-e11, arm F f04/f06;
2. a base identifier naming a subroutine **OTHER THAN** the enclosing one — arm
   B b02-b05, arm D d02/d03, arm E e01/e02/e12, arm F f01-f03/f05/f07/f08.

**THE FIRST CUT DID NOT DECLINE, AND THE SWEEP CONVICTED IT.**
`uvm_misc.svh:437` `uvm_object_value_str.itoa(v.get_inst_id());` is § 69's cell,
AGREEING with golden in every pristine UVM row; re-emitting it here produced a
`func_call` whose ARGUMENT was rendered in STATEMENT shape
(`method_func_call(get_inst_id){vpiPrefix v}`) instead of golden's
expression-position `hier_path (v.get_inst_id)`, and that became the new head of
**SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg** (33→56, 17→29, 95→29,
52→56).  Two things were wrong and both are fixed: the § 69 decline above, and
`callStmtContext` — which `StatementKind::ExpressionStatement` raises before the
call and which the collapse must LOWER before emitting arguments, because
Surelog compiles them with the ordinary `compileTfCallArguments`.


---

## 7. THE GRIDS — six arms, Surelog golden + both binaries, BOTH views

`grid172.sh` builds one Surelog golden and both binaries' databases per arm in
each view and records EVERY rc; the DEF and ELAB listings are kept in separate
files and never merged (r10uvm166 §6 / r10v169's listcheck law).  Scored by
`gridscore172.py` as diff-lines against golden, both RAW (copy counts included)
and SET (deduped): the two producers legitimately emit different COPY COUNTS of
the same package body (r10uvm170 residue R6), identically under both binaries,
and a raw-only score drowns the cells this law owns.

| arm | view | cells | pristine raw | patched raw | pristine SET | patched SET |
|---|---|---|---|---|---|---|
| `g172_a_shape` | def  | 22 | 10 | 2 | 10 | **2** |
| `g172_a_shape` | elab | 44 | 20 | 4 | 10 | **2** |
| `g172_b_name`  | def  | 16 | 10 | 0 | 10 | **0** |
| `g172_b_name`  | elab | 20 | 24 | 12 | 10 | **0** |
| `g172_c_home`  | def  | 45 | 12 | 0 |  6 | **0** |
| `g172_c_home`  | elab | 90 | 33 | 7 |  6 | **0** |
| `g172_d_scope` | def  | 23 |  8 | 0 |  8 | **0** |
| `g172_d_scope` | elab | 50 | 29 | 11 |  8 | **0** |
| `g172_e_deep`  | def  | 22 | 20 | 0 | 20 | **0** |
| `g172_e_deep`  | elab | 54 | 59 | 5 | 20 | **0** |
| `g172_f_args`  | def  | 18 | 18 | 2 | 18 | **2** |
| `g172_f_args`  | elab | 35 | 37 | 5 | 23 | **2** |

The two arms that do not reach 0 hold EXACTLY the two declined shapes and
nothing else — arm A's `cpy172.iarr172[1].seti172(5)` @29 and arm F's
module-`initial` `fmodfn172.fq172.push_back("f09")` @62.  **No cell moved AWAY
from golden in any arm, in either view.**

**The official judge on the same arms** (uhdm-cmp, pristine → patched, cmp
lines / head count):

```
g172_a_shape   def   40/1 ->  72/1   head OBJECT changed -> the declined c06
g172_a_shape   elab  44/1 ->  72/1   ditto
g172_b_name    def   40/1 ->   0/0   CMP_EQUAL
g172_b_name    elab  44/1 ->   0/0   CMP_EQUAL
g172_c_home    def   40/1 ->  27/1   head OBJECT changed (class_var pe172::pkgcpy172 @12:12)
g172_c_home    elab  44/1 ->   0/0   CMP_EQUAL
g172_d_scope   def   40/1 ->   0/0   CMP_EQUAL
g172_d_scope   elab  44/1 ->   0/0   CMP_EQUAL
g172_e_deep    def   72/1 ->  16/1   head OBJECT changed (class_typespec @37:7)
g172_e_deep    elab  76/1 ->  16/1   ditto
g172_f_args    def  104/1 ->  29/1   head OBJECT changed (string_var floc172 @21:16)
g172_f_args    elab 112/1 ->  16/1   ditto
```

Four arms reach **CMP_EQUAL**; on the other two the head OBJECT changed to a
cell OUTSIDE this law's population (a package function's class-typed return
variable, an unpacked array of class handles, a body-local listing) — every
one of them present in the pristine database too and owned by another family.
A cmp line count going UP with a CHANGED head object is the new head's
decompile size (RESUME.md §7).

**RC census.**  Every command `rc=0` except Surelog's own runs of arms A and E,
which exit 4 on its own type checker while STILL WRITING THE DATABASE:

```
[ERR:CP0332] g172_a_shape.sv:29:7: Function "seti172" is not defined for variable "cpy172.iarr172" of type queue
[ERR:CP0332] g172_e_deep.sv:39:7:  Function "push_back" is not defined for variable "efn172.eq172" of type string
[ERR:CP0332] g172_e_deep.sv:67:7:  Function "%exobj" is not defined for variable "efn172" of type queue
```

Those three are the cells where Surelog has ALREADY collapsed the chain and then
type-checks the collapsed name — the diagnostic is itself evidence of the law.
Recorded, not hidden; the cells are in the database and are scored.


---

## 8. THE CORPUS CENSUS — nine UVM DBs × both modes, and both corpora

`ct172cen.cpp` lists ONE ROW per STATEMENT-POSITION call object, where
"statement position" is decided by the RELATION its owner holds it on (the
generated, kind-agnostic `GetByVpiType`; `vpiStmt` 104 or `vpiElseStmt` 73) —
the exact slot the head sits in.  The KEY is `(line, ordinal within the line of
THIS COPY of the body, enclosing subroutine NAME)`: the two producers give the
same statement DIFFERENT spans (that IS the defect), so a span key would join
nothing, and the ordinal is computed per enclosing subroutine OBJECT so the
several copies of a body show up as the key's multiplicity.  `score172.py`
compares the SHAPE SET at each key, never the multiplicity (r10uvm170 R6), and
the home chain is stripped: evidence, never a key (RESUME.md §9).

A last-writer `map<obj,int>` in the first cut of the relation pass silently
dropped ten of arm E's eighteen statement calls (a call is reachable on more
than one relation); the instrument records the SET of relations instead, and the
arm's count is asserted against the listing.

**Pristine, the nine UVM row-modes** (`CENSUS.r10uvm172.txt`):

```
BuildUVMPkg  default   TOTAL 5091  AGREE=5086  G-ONLY=1  LINKONLY=3  O-ONLY=1
MiniAmiq     default   TOTAL 5128  AGREE=5113  COLLAPSE=11  G-ONLY=3  LINKONLY=1
Scoreboard   default   TOTAL 4861  AGREE=4860  LINKONLY=1
SeqDriver    default   TOTAL 4840  AGREE=4839  LINKONLY=1
SimpleUVM    default   TOTAL 4834  AGREE=4833  LINKONLY=1
   … testflags identical row for row (Scoreboard/testflags has no golden: SKIP)
```

**Pristine, the WHOLE surelog corpus, both modes**: 956 rows scored (481 default
+ 475 testflags, the rest SKIP for want of a database), **`OTHER = 0`** — the
statement-call population agrees everywhere except MiniAmiq's 11 `COLLAPSE`
cells per mode.  Of those 11:

| cells | site | owner |
|---|---|---|
| 4 | `svaunit_immediate_assertion_details.svh:155,159,163` (`copy.<member>.push_back(...)`) and `:230` (`get_checks.checks_details.push_back(...)`) | **THIS LAW** |
| 7 | `svaunit_vpi_interface.sv:310,334,358,383,408,434` `control_assertion_dpi(a_sva.get_sva_path(), …)` and `:512` `get_cover_statistics_dpi(cover_info[index], …)` | r10buvm23's residue **R-P** — our receiver TEXT is split inside PARENTHESES, so the prefix reads `control_assertion_dpi(a_sva`.  A different defect; § `selRecvStmtCallBareNames124` already names this exact family and leaves it byte-identical, and so does this law (its base identifier comes off the SYNTAX name nodes and there is no receiver chain there at all). |

**THE A-PRIORI MOVER PREDICTION** (`predict172.sh`, made from the PRISTINE
databases and their goldens ALONE, before the patched sweep ran).
`ct172cen --pred` lists every statement-position `method_func_call`/
`method_task_call` whose vpiPrefix NAME is also the name of some function or
task IN THAT DATABASE — a deliberate SUPERSET (it ignores WHICH scope the
subroutine lives in, which only slang knows), so a row printing nothing here
CANNOT move:

```
surelog      scanned=956   SKIP=617  ROWS-WITH-CANDIDATES=9
             (SeqDriver x2, SimpleUVM x2, Scoreboard x1, MiniAmiq x2, BuildUVMPkg x2)
uhdm2rtlil   scanned=1358  SKIP=104  ROWS-WITH-CANDIDATES=0
```


---

## 9. THE PATCHED SWEEP — movers, census and heads

**Byte movers, surelog: `MOVERS 2 / 956`, SELFCHECK 955/956 — exactly the
predicted set.**

```
MOVER ./default/MiniAmiq-544c7f61/slang.uhdm
MOVER ./testflags/MiniAmiq-544c7f61/slang.uhdm
```

**Byte movers, uhdm2rtlil: `0 / 1358`**, SELFCHECK 1357/1358 — as the predictor
said (0 candidate rows).

**Attribution** (workdir-normalised, `id:`-stripped, ORDER-BLIND dump diff;
`attrib` in `GATES.r10uvm172.txt`).  48 lines, all four cells and nothing else:

```
+ func_call: (copy)        155:10-155:56 / 159:10-159:58 / 163:10-163:58   + vpiFunction -> function(copy)@149:4
+ func_call: (get_checks)  230:7-230:41                                    + vpiFunction -> function(get_checks)@222:4
- method_func_call: (tests_names) 155:15 / (attempt_time) 159:15 / (check_states) 163:15 / (checks_details) 230:18
- ref_obj: (…::copy::copy) x3 and (…::get_checks::get_checks), with their vpiFullName lines
```

**Census, the nine UVM row-modes, PATCHED** (`CENSUS.r10uvm172.txt`):

```
MiniAmiq   default/testflags  AGREE 5113 -> 5117   COLLAPSE 11 -> 7   G-ONLY 3   LINKONLY 1
BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM      UNCHANGED, cell for cell
```

**TO-GOLDEN 4 per mode (8 cells over the two row-modes) — AWAY 0, MOVED-WRONG
0.**  The 7 surviving `COLLAPSE` cells are r10buvm23's residue R-P and are
byte-identical.  The other 954 databases are byte-identical under the two
binaries, so no cell in them can have moved — byteverify is the stronger test
and it reports zero.

**Heads** (`rowheads.sh` on both sweeps; the cmp LOGS are md5-compared, not just
their line counts):

```
                   pristine      patched
SeqDriver    def     33 / 1  ->   33 / 1    log BYTE-IDENTICAL
SeqDriver    tf      33 / 1  ->   33 / 1    log BYTE-IDENTICAL
SimpleUVM  def/tf    17 / 1  ->   17 / 1    logs BYTE-IDENTICAL
Scoreboard   def     95 / 1  ->   95 / 1    log BYTE-IDENTICAL
MiniAmiq   def/tf    40 / 1  ->   40 / 1    HEAD OBJECT CHANGED (155:10 -> 233:24); the two modes' logs stay byte-identical to each other
BuildUVMPkg def/tf   52 / 1  ->   52 / 1    logs BYTE-IDENTICAL
Earlgrey_0_1 def     31 / 1  ->   31 / 1    log BYTE-IDENTICAL
Earlgrey_0_1 tf      32 / 1  ->   32 / 1    log BYTE-IDENTICAL
Rggen        def      0 / 0  ->    0 / 0
```

MiniAmiq's line count is unchanged BY COINCIDENCE — the head OBJECT changed and
the new one's decompile happens to be the same size (RESUME.md §7).  The old
head, `func_call (copy)` @155:10, is GONE from the cmp log.


---

## 10. R0 — THE NEXT HEAD ON THIS ROW

**MiniAmiq default and testflags, 40 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** (md5 `dcb32643befb…`):

```
svaunit_immediate_assertion_info.svh:233, inside
    virtual function svaunit_immediate_assertion_info get_checks(string a_test_name);
      foreach(checks_details[details_index]) begin
        check_index = checks_details[details_index].tests_names.find_index() with (item == a_test_name);

both sides hold hier_path (checks_details[details_index].tests_names) @233:24-233:105
LHS golden  bit_select (checks_details[details_index]) @233:24-233:38
              |vpiName:checks_details   |vpiFullName:checks_details[details_index]
              |vpiIndex -> ref_obj (…::get_checks::details_index) @233:39-233:52
RHS ours    ref_obj    (…::get_checks::checks_details[details_index]) @233:24-233:53
              |vpiName:checks_details[details_index]
```

The FIRST element of an EXPRESSION-position dotted path whose written component
carries a SUBSCRIPT: golden splits it into a `bit_select` NAMED for the base with
the index as `vpiIndex` and a span that stops at the `[`, while we emit ONE
`ref_obj` whose VpiName carries the subscript TEXT and whose span runs to the
`]`.  `ref_obj::Compare` reads `VpiName` (a TEXT law, RESUME.md §9) and the
kinds differ first.  This is the EXPRESSION-position twin of
§ `builtinRecvIndexedStepIsBitSelect74` (whose walk
`builtinRecvStepSelectors74` already confirms a text split component for
component and dimension for dimension against the bound receiver) and of
§ `selRecvStmtCallBareNames124`'s statement-position rename; neither reaches a
plain `hier_path` built outside the built-in-method arm.  Decode it with
`ct172own.cpp` (both objects are present and of DIFFERENT kind, the form this
tool was written for) and reuse `builtinRecvStepSelectors74` for the fence.

---

## 11. RESIDUES

* **R1 — the SECOND component's SUBSCRIPT.**  `recv.arr[1].m(5)`: golden's
  `argListNode = fC->Sibling(tfNameNode)` lands on that subscript and
  `compileTfCallArguments` compiles its INDEX as the collapsed call's ONE
  argument (arm A c06, golden `func_call (cpy172) args=1`, the argument the
  constant `1` at 29:22-29:23 — our pristine `method_func_call` carries the
  SAME constant, so only the wrapper differs).  Zero corpus cells in either
  corpus; the predicate declines and the cell is byte-identical to pristine.
  It is the remaining 2 SET diff-lines of arm A, in both views, and the arm's
  post-patch cmp head.
* **R2 — a statement call with NO enclosing subroutine.**  A module
  `initial`/`always` body (arm F f09, `fmodfn172.fq172.push_back("f09")`):
  golden collapses it against the module's own function, and
  `getTaskFunc`'s `component` there is the module.  Our only sound handle would
  be `currentScope`, which is STALE throughout `emitInstance` (RESUME.md §9),
  so the law declines.  Zero corpus cells.  It is the remaining 2 SET diff-lines
  of arm F.
* **R3 — a call slang REJECTED.**  Surelog never learns that slang refused the
  member, so it collapses a `§ droppedCall14` statement too; this law fires only
  on `ExpressionKind::Call`.  Not measured against a golden pair here, because
  the shape needs an unspecialized type parameter AND a collapsing base name at
  once; recorded, not guessed.
* **R4 — the seven MiniAmiq `COLLAPSE` cells this law leaves alone**
  (`svaunit_vpi_interface.sv:310,334,358,383,408,434,512`).  Golden holds the
  ordinary DPI `func_call` and we hold a `method_func_call` whose prefix reads
  `control_assertion_dpi(a_sva` — a RECEIVER TEXT split inside PARENTHESES,
  r10buvm23's residue R-P, which § `selRecvStmtCallBareNames124` already names
  and already leaves byte-identical.  A different defect with a different fix;
  this law's base identifier comes off the SYNTAX name nodes and there is no
  receiver chain there at all, so it cannot reach them.
* **R5 — the `LINKONLY` cells.**  One per UVM row (three on BuildUVMPkg):
  golden holds TWO spellings of the same link at one key
  (`task_call uvm_phase::m_run_phases` with `vpiTask` named both
  `m_run_phases` and `uvm_phase::m_run_phases`) where we hold one.  A naming
  family, present identically before and after, and outside this law.
* **R6 — the COPY COUNT.**  In the ELABORATED view we emit more copies of a
  package body than golden does (r10uvm170 R6).  Identical under both binaries;
  it is why the grid is scored deduped as well as raw, and it is 0 movers on the
  SET projection.


---

## 12. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct172own.cpp` | the OWNER-FINDER and judge decoder, in r10uvm171/161's form, extended for a BOTH-SIDES-PRESENT, DIFFERENT-KIND head: it prints the head's kinds and says outright that `BaseClass::Compare`'s `VpiType` line failed first, walks the parent chain asking each pair whether its own `Compare` reproduces the design head, descends by `VpiParent`, prints the owner pair's field vectors (the `tf_call` family's rows added here), and runs the kind-agnostic `GetByVpiType` reference scan that NAMES the edge. |
| `ct172cen.cpp` | the census reader.  `--rel` prints the relation histogram; the default mode lists one row per STATEMENT-POSITION call keyed on `(line, ordinal within the line of this COPY, enclosing subroutine)`; `--pred` is the A-PRIORI mover SUPERSET computable from ONE pristine database. |
| `ct172list.cpp` | the per-arm listing: every call object and every call-carrying `hier_path`, with the payload `Compare` reads (kind, name, link, prefix, argument count) and the home chain as EVIDENCE, never a key. |
| `grid172.sh` / `gridscore172.py` | one Surelog golden + both binaries × both views per arm, every rc recorded; scored RAW and DEDUPED, the two views never merged. |
| `cenrun172.sh` / `score172.py` | the corpus census over a sweep workdir pair, with the `COLLAPSE` / `LINKONLY` / `OTHER` classification. |
| `predict172.sh` | the a-priori mover prediction, from PRISTINE databases only; asserts a nonzero scanned-row count so a predictor that reached nothing cannot read as "no movers". |
| `bound172.sh` / `wide172.sh` | the wide boundary gate over a COPY of the probe tree. |
| `g172_a_shape.sv` … `g172_f_args.sv` | the six grid arms (§7). |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` / `byteverify.sh` / `ct8rows.sh` / `rowheads.sh` | the standing gates, copied verbatim so `canaudit.sh` can audit the drivers that actually RUN here. |


---

## 13. § `retNameRecvCollapse69`'s RESIDUE N6 IS CLOSED

The wide boundary flagged `tools/probe/r10uvm69repro/a3_recv.sv` as a mover, and
it is the arm § 69 wrote FOR the residue this law inherits — cell N6,
`n_chain.inner.touch(n);` at `a3_recv.sv:75`.  Re-measured against its own
Surelog golden with the official judge:

```
a3_recv.sv   def   pristine 40 lines / 1 head  ->  patched 0 / 0   CMP_EQUAL
a3_recv.sv   elab  pristine 44 lines / 1 head  ->  patched 0 / 0   CMP_EQUAL
```

An earlier pass's arm that moves must be re-measured against golden and must
move TOWARD it (RESUME.md §7).  This one goes all the way to EQUAL, in both
views.  § 69's other two arms (`a1_type.sv`, `a2_scope.sv`) do NOT move at all.


---

## 14. THE WIDE BOUNDARY — and the two OTHER earlier-pass arms it moved

`wide172.sh` copies the WHOLE committed probe tree and compiles every `.sv`/`.v`
in it — top level AND subdirectories — with both binaries in BOTH views, reading
the file list on fd 3 with every child `</dev/null`, keying scratch on the
RELATIVE path and asserting `PROCESSED == LISTED`.

Besides this pass's own six arms (the POSITIVE CONTROL — a gate that reports
zero movers over them cannot see) and r10uvm154's address-derived residue, the
gate moved **`r10v151repro/v151_6_shadow.sv`** and
**`r10v151repro/v151_8_tfname.sv`** — and those two arms were written by
r10uvm151's VERIFIER for EXACTLY this law, as known-wrong residues.  Arm 8's own
header says so:

> *r10v151 (VERIFIER) arm 8 — THE `getTaskFunc(name)` BRANCH.  Surelog's
> degenerate road looks the RECEIVER's name up as a subroutine
> (`CompileHelper.cpp:4239`) before falling out at `:4316`, so a receiver whose
> base name also names a FUNCTION gets `vpiFunction` resolved and one that names
> a TASK becomes a `task_call` outright.  **Both are pristine-WRONG and stay
> wrong**; this arm measures WHICH.*

Re-measured against their own Surelog goldens, cell for cell
(`ct172list`, DEF view):

```
v151_8_tfname  15:7  fname8.sort() with (item);  golden func_call(fname8) link=F:fname8
                     pristine func_call link=F:<null>   ->  patched  MATCHES GOLDEN
v151_8_tfname  16:7  tname8.sort() with (item);  golden task_call(tname8) link=T:tname8
                     pristine FUNC_call link=F:<null>   ->  patched  MATCHES GOLDEN
v151_6_shadow  23:7 / 31:7  golden func_call(zebra6) link=F:zebra6
                     pristine link=F:<null>             ->  patched  MATCHES GOLDEN
```

Both arms' cmp LOGS are id-stripped IDENTICAL before and after (the head of each
arm lies elsewhere), and every cell that moved moved TOWARD golden.  No cell in
either arm moved away.

**R7 — the KEYWORD array methods.**  The two arms' remaining wrong cells are
`fname8.unique(); tname8.unique();` (`v151_8_tfname.sv:18,19`) and
`zebra6.unique();` (`v151_6_shadow.sv:28`): the four keyword forms
(`unique`/`and`/`or`/`xor`) written with NO `with` clause keep
§ `stmtBuiltinBodyIsBareRecvCall151`'s link-less `func_call`, because this law's
flattener does not reach their callee syntax while it does reach the `with`
form's on the very next line.  The `with` twins of the SAME cells move; the
keyword twins do not.  **Zero corpus cells** — the whole-corpus census's
`LINKONLY` class, which is where such a cell would land, holds only
`pkg::fn`-spelling residues (`uvm_phase::m_run_phases` and two
`uvm_run_test_callback::` siblings on BuildUVMPkg).  Measured, named, left.


```
LISTED=4813  PROCESSED=4813  PRODUCED_DBS=4656  MOVED_ARMS=11  RC_DIFFS=0
```

| moved arm | attribution |
|---|---|
| `r10uvm172repro/g172_a_shape … g172_f_args` (6) | **this pass's own arms** — the positive control |
| `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` | r10uvm154's already-decoded **ADDRESS-DERIVED** residue: the only dump difference is `UINT:22580129 -> UINT:22584225` (and its `vpiDecompile` twin) |
| `r10uvm69repro/a3_recv.sv` | § 69's OWN residue cell N6 → **CMP_EQUAL**, both views (§13) |
| `r10v151repro/v151_6_shadow.sv`, `v151_8_tfname.sv` | uvm151's VERIFIER arms for THIS law, written as known-wrong residues → every moved cell now **MATCHES GOLDEN** (§14) |

**THE FLOOR HOLDS.**  Not one arm of r10uvm171, r10uvm169, r10uvm167, r10uvm89
(`hpTrailSelIdxDecompiled89`, `rendersAsItself89`, `selGroup89`, the
ElementSelect chain arm, the boundary mover `v81h_lvbase`), r10uvm77-79,
r10uvm82-91, r10buvm3-15 or r10sd8-12 is among the movers: they are
byte-identical under both binaries, in both views.

---

## 15. GATES — all green

Full transcript in `GATES.r10uvm172.txt`; the one-line form:

* goldens **23 PASS / 0 FAIL** under BOTH binaries, negative control
  `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**;
* uhdm2rtlil both modes: three `ct8rows` comparisons **PASS** (0 differing rows,
  status AND dump column), byteverify **0 movers / 1358**, SELFCHECK 1357/1358;
* surelog corpus both modes: `ct8rows` vs `results/golden_surelog.csv` and vs
  this pass's own `d53fbaad` pristine sweep both **PASS** — **0 differing rows
  over 1588**.  **NO ROW CONVERTED; `results/*.csv` NOT EDITED.**  The status
  histogram is identical to pristine's (937 CMP_EQUAL / 567 SLANG_REJECT / 48
  SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 2
  UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM — no rc=139 hiding as a SLANG_REJECT);
* surelog byteverify **2 movers / 956**, SELFCHECK 955/956 — **both PREDICTED BY
  NAME** (MiniAmiq ×2) and attributed line by line, order-blind: 48 lines, all
  four cells, nothing else.  No Scoreboard coin flip on this pair;
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r), both
  `ctcan2.sh` **PASS**, `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
  the four slang-fenced tests appear only as FENCED skips and are never
  dispatched;
* protected databases byte-identical (InterfaceModPort, BlackParrotComplex,
  YosysOldOr) and both brief pins held: SVSwitch `4842211c4030`, YosysVerx
  `6ccda350c24a`;
* wide boundary `LISTED=4813 PROCESSED=4813 PRODUCED_DBS=4656 MOVED_ARMS=11
  RC_DIFFS=0`, every mover attributed above.

**Every binary was frozen `chmod 555` before any sweep and every `cmds.txt` was
audited by BINARY PATH** (`/tmp/r10uvm172_bin/pristine`,
`/tmp/r10uvm172_bin/patched`); no sweep ran against the main-tree binary.

---

## 16. REPRODUCIBILITY

The patch is `git diff` against `d53fbaad` and applies clean to a FRESH
`d53fbaad` worktree (`git apply -3`, rc 0, no conflict markers).  Its surface is
`src/StmtEmit.cpp`, `src/UhdmExporter.cpp`, `include/UhdmExporter.h`,
`RESUME.md` §3b and `tools/probe/r10uvm172repro/` and nothing else; the four
slang-fenced names appear in it only inside `canaudit.sh`'s own fence list — 0
other hits, so the master's fence check reads 0/0/0/0.  (They are NOT spelled
here: r10v172's verification found this sentence naming all four, which made
that check read 1/1/1/1 against the README itself; `canaudit.sh` carries the
list and is the only place that may.)

Applied to that fresh worktree and BUILT INDEPENDENTLY, the binary comes out
**byte-identical to the gated one**: `01bb3fd9524dbf34f3dc255634a90b86`.  The
pristine binary built the same way from a clean `d53fbaad` worktree is
byte-identical to the main tree's own `build/slang-uhdm`
(`fb82059559765e79eee43ee365aa4879`), so both sides of every measurement above
are reproducible from the repository alone.
