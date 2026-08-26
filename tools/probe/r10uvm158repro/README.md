# r10uvm158 — § `badBlockKeepsItsScope158` — **A `begin` SLANG REJECTED STILL HAS ITS SCOPE: SLANG DROPS THE `blockSymbol` LINK ON A BAD BLOCK, SO THE BLOCK'S LOCALS, ITS LABEL AND ITS BLOCK-SCOPE PARAMETERS VANISHED** — the SimpleUVM ×2 + Scoreboard/default **163-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `1f9906a` |
| worktree | `/tmp/wt_r10uvm158` |
| pristine binary | md5 `100987bc8d76f2052aa842d7c65c5110`, built from a clean `1f9906a` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `5c39f2b244f69d171cfaa3353e8fdf63`, frozen `chmod 555` |
| production surface | `src/EmitHelpers.h` (the law + `recoverBadBlockScope158`), `src/StmtEmit.cpp` (`case StatementKind::Block` — every one of its 18 `bs.blockSymbol` reads routed through the recovered handle) |
| probe surface | `tools/probe/r10uvm158repro/` only |


## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **163** | **67** | 1 — a **NEW head**, the concat whose middle operand is a method call on the type-parameter local (§7) |
| **Scoreboard default** | **163** | **67** | 1 — the **SAME new object** |
| SeqDriver default / testflags | 22 | 22 | 1 unchanged, same object (one serializer id shifts in the log) |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged, head log BYTE-IDENTICAL |
| BuildUVMPkg default / testflags | 1371 | 1371 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 31 / 36 | 31 / 36 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; surelog `CMP_NOTEQUAL` stays **10 default + 9 testflags** and uhdm2rtlil stays `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2`, status histograms IDENTICAL | |
| byte movers | — | **9 / 956** surelog — **all nine PREDICTED BY NAME from the pristine databases before the patched sweep ran** — and **0 / 1358** uhdm2rtlil | |
| the corpus census (9 moved DBs, both row families) | — | **13 BLK + 15 DECL cells TOWARD; 0 WRONG, 0 AWAY, 0 RESHAPE, 0 ONLY-A** | |
| the grid (6 arms + the one moved earlier-pass arm, both views) | — | **93 TOWARD, 0 WRONG, 0 AWAY** | |
| the WIDE boundary (4419 arms, both views) | — | **8 moved arms, RC_DIFFS=0** — 6 are this pass's own grid (the positive control), the 7th is re-measured TOWARD golden and the 8th is a gate FLAKE, refuted by 92 byte-identical direct builds and a clean re-run (`BOUNDARY.r10uvm158.txt`) | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size (RESUME.md §7). `head_pris_SimpleUVM.default.cmp` (163 lines) is
the head the brief named; `head_pat_SimpleUVM.default.cmp` (67) is the new one.
`Scoreboard/testflags` is `SLANG_REJECT` and `Rggen/testflags` has no golden —
both print SKIP-NOFILE and are COUNTED, never read as perfection.


---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this worktree's own pristine sweep reproduced the brief
exactly — **SimpleUVM default/testflags and Scoreboard/default, 163 cmp lines,
1 head each** (`head_pris_*.cmp`):

```
LHS:
decompile:
begin: (uvm_pkg::uvm_reg_predictor::get_type_name), id:155842, line:118:26, endln:122:8
|vpiParent:
\_if_stmt: , id:155841, line:118:5, endln:122:8
|vpiFullName:uvm_pkg::uvm_reg_predictor::get_type_name
|vpiVariables:
\_ref_var: (uvm_pkg::uvm_reg_predictor::get_type_name::t), id:155843, line:119:15, endln:119:16
  ... |vpiActual: \_int_typespec: , id:155791, line:142:31, endln:142:38
|vpiStmt:  \_assignment: 120:7-120:41   (t = BUSTYPE::create)
|vpiStmt:  \_assignment: 121:7-121:71   (type_name = {...})
RHS: <null>
```

Source — `uvm-1.2/src/reg/uvm_reg_predictor.svh:54` and `:117-124`:

```systemverilog
class uvm_reg_predictor #(type BUSTYPE=int) extends uvm_component;   // :54
  ...
  virtual function string get_type_name();                            // :117
    if (type_name == "") begin                                        // :118  <- THE HEAD
      BUSTYPE t;                                                      // :119
      t = BUSTYPE::type_id::create("t");                              // :120
      type_name = {"uvm_reg_predictor #(", t.get_type_name(), ")"};   // :121
    end                                                               // :122
    return type_name;
  endfunction
```

### (1) WHICH `SafeCompare` PRINTED THE NULL — DECIDED BY MEASUREMENT, NOT BY SHAPE

`LHS: <object> / RHS: <null>` is printed by **two different arms** of
`BaseClass::SafeCompare` and they are not distinguishable from the cmp log
alone:

* the **SINGULAR** overload with `rhs == nullptr` sets `m_failedLhs` to the
  **VALUE** and leaves `m_failedRhs` unset — here that would be
  `if_stmt::Vpi_stmt` with OUR `begin` missing entirely;
* the **VECTOR** overload's `(lhs != nullptr) && !lhs->empty() && (rhs == nullptr)`
  arm sets `m_failedLhs` to the **OWNER** (`lhs_obj`) and also leaves
  `m_failedRhs` unset — here that is the `begin`'s own
  `scope::Variables` with our vector NULL.

`ct158cen` on BOTH pristine databases settles it — the block itself is
present on our side, with the same span and the same two statements, and only
its `vpiVariables` vector is missing:

```
G  BLK  uvm_pkg::uvm_reg_predictor::get_type_name  118:26-122:8  begin  -   1  2  -1  t:ref_var
O  BLK  uvm_pkg::uvm_reg_predictor::get_type_name  118:26-122:8  begin  -  -1  2  -1  -
                                                                          ^NVARS ^NSTMTS
                                              (-1 is the NULL vector, 0 would be an EMPTY one)
```

**THE FIELD IS `scope::Variables`, THE VECTOR OVERLOAD, RHS NULL, OWNER = THE
`begin`.** `begin::Compare` reads only `Stmts`; `Variables` is read by its base
`scope::Compare` (`~/git-repos/UHDM/build/generated/src/scope.cpp`), sixth in
that function's order and the first of its tests that can fail here — the
`begin`'s VpiName is empty on both sides and the five vectors before
`Variables` are null on both.

A 22-line arm (`/tmp/r10uvm158_scr/a0.sv`, reproduced as the grid's
`g158_a_shape.sv` `ifBad158` cell) reproduces the head at **163 cmp lines, 1
`^LHS:`** — the same count as the corpus rows, because a cmp line count is the
head object's decompile size and the arm's `begin` decompiles the same way.

---

## 2. THE LAW

> **§ `badBlockKeepsItsScope158`** — *a `begin` / `fork` that **slang rejected**
> (any one of its items bound bad) arrives at the emitter with a **NULL
> `blockSymbol`**, because `Statement::bindBlock` returns the `badStmt`
> wrapper **before** it links the block to its scope. Everything our block arm
> asks that symbol — the block's **local declarations**, its **label**, its
> **block-scope parameters** — was therefore silently dropped, and the block
> came out as an **unnamed `begin` with a NULL `vpiVariables` vector**.
> **Surelog performs no such check and lists all three.** Recover the scope
> from the block's own bound body: `bindScopeInitializers` has already pushed
> a `VariableDeclStatement` for **every** variable of the block's scope into
> that body, and each one's `symbol.getParentScope()` **IS** the
> `StatementBlockSymbol` the early return dropped.*

### THE SLANG MECHANISM, READ NOT GUESSED

`slang/source/ast/Statement.cpp` (`e4e8a2d`), `Statement::bindBlock` — the only
place a `BlockStatement` is ever linked to its scope:

```cpp
const Statement& Statement::bindBlock(const StatementBlockSymbol& block, ...)   // :296
    auto& bs = BlockStatement::fromSyntax(comp, bss, context, stmtCtx,
                                          /* addInitializers */ true);
    if (bs.bad())
        return bs;                       // :307  <-- EARLY RETURN
    result = &bs.as<BlockStatement>();
    result->syntax = &bss;               //        <-- also never reached
    ...
    result->blockSymbol = &block;        // :353  <-- NEVER REACHED
    if (anyBad)
        return badStmt(comp, result);    // :355  (the LATER bad path DOES link)
```

`BlockStatement::fromSyntax` (`:689-750`) returns `badStmt(comp, result)`
(`:746-747`) as soon as **any** item of the block binds bad, so ONE rejected
statement inside a `begin` costs the WHOLE block its `blockSymbol`.

The recovery handle is in the same file: `bindBlock` calls
`BlockStatement::fromSyntax` with `addInitializers = true`, and
`Statement::bindScopeInitializers` (`:379-402`) pushes a
`VariableDeclStatement` for **every non-compiler-generated variable of the
block's scope** into the block's body list before any item is bound:

```cpp
    auto& scope = *context.scope;                       // the StatementBlockSymbol
    for (auto& member : scope.members()) {
        if (member.kind != SymbolKind::Variable) continue;
        auto& var = member.as<VariableSymbol>();
        if (!var.flags.has(VariableFlags::CompilerGenerated))
            results.push_back(comp.emplace<VariableDeclStatement>(var, range));
    }
```

Those statements survive the `badStmt` wrapper untouched. So the scope is
recoverable **from the bad block itself**, with no new lookup and no scope
walk.

### WHAT SURELOG DOES (why golden has all three)

`compileStmt`'s `paSeq_block` / `paPar_block` arms
(`Surelog/src/DesignCompile/CompileStmt.cpp:380-508`) walk the block's children
and hand every `paBlock_item_declaration` to `compileDataDeclaration`
(`:1127-1281`) **whatever the sibling statements turn out to be** — there is no
"the block is bad" state in Surelog at all. The label is stamped by
`populateCoreMembers(labelId, labelId, scope)` in the same arm, and a
block-scope `localparam` becomes a leading `param_assign` statement. Golden
therefore lists the locals, the label and the parameters of a block we could
not bind.

### WHICH BLOCKS THIS ACTUALLY REACHES (the population, measured)

A statement slang rejects **with a reported diagnostic** makes the whole test
`SLANG_REJECT`, which is out of the campaign's scope by decision. The
population this law reaches is the statement slang binds **bad in silence**:
the body of a **GENERIC CLASS's DEFAULT specialization**, which nothing in the
source ever specializes and which slang therefore never diagnoses — our
emitter is what asks for it (`GenericClassDefSymbol::getDefaultSpecialization`,
`ClassSymbols.cpp:985`), after the diagnostics have been collected. That is
exactly `uvm_pkg::uvm_reg_predictor #(type BUSTYPE=int)`: `BUSTYPE::type_id`
and `t.get_type_name()` are both errors for `BUSTYPE = int`, both silent, and
between them they make the `begin` bad.

Every grid arm below is built that way, and the arms whose bad statement is
reported instead were REWRITTEN once the pristine binary answered `rc=3` on
them — an arm our own tool refuses is not an arm that measures anything.

### STATED GATE == CODE GATE

`recoverBadBlockScope158` fires **only** when `bs.blockSymbol == nullptr`
(otherwise it returns `bs.blockSymbol` verbatim, so every block slang linked is
byte-for-byte what it was), the body carries at least one
`VariableDeclStatement`, **every** `VariableDeclStatement` in the body agrees
on ONE parent scope, and that scope's symbol is a `StatementBlock`. Nothing
else — no syntax test, no view test, no home test. A block with no locals at
all has no handle and is left exactly as it was (§6, residue R2).

**WHY THE HANDLE CANNOT LIE.** `addInitializers` defaults to **false**
(`slang/ast/Statement.h:315`) and `Statement::bindBlock` is the **only** caller
that passes `true`. A `VariableDeclStatement` can therefore appear in a block's
body list **only on the path that also had a `StatementBlockSymbol` for it**. A
block slang built WITHOUT a scope — an unnamed `begin` with no declarations,
reached through `Statement::bind`'s no-symbol arm at `Statement.cpp:195-205`
— carries none, the scan finds nothing, and the block keeps exactly the shape
it had. The recovery cannot invent a scope for a block that never had one, and
it cannot attach a *different* block's scope, because the only scope it can
reach is the declaring scope of a variable the block itself listed.

---

## 3. THE CHANGE

**`src/EmitHelpers.h`** — the law, the slang citations and one predicate:

```cpp
inline const slang::ast::StatementBlockSymbol* recoverBadBlockScope158(
    const slang::ast::BlockStatement& bs);
```

**`src/StmtEmit.cpp`, `case StatementKind::Block`** — one line adds the handle
and **all 18** of the arm's `bs.blockSymbol` reads are routed through it:

```cpp
const StatementBlockSymbol* blkSym158 = recoverBadBlockScope158(bs);
```

The routing is deliberately ALL-OR-NOTHING. The arm asks the symbol five
different questions — the labelled-assertion shortcut, the `named_begin` /
`named_fork` name + end label + anchor, the `innerPrefix` every local's
`vpiFullName` is built from, the `BlkCtrl57` identity key, the variables
listing and the block-scope `param_assign` listing. Recovering the scope for
the LISTING but not for the NAME would list a named block's locals under the
UNLABELLED prefix — a MOVED-WRONG cell, not a fix. The grid's `namedBad158`
cells are what score that decision (§5).

**Nothing else changed.** A block slang linked normally reaches
`recoverBadBlockScope158`'s first line and comes back with `bs.blockSymbol`
itself, so every accepted block in both corpora is byte-for-byte what it was —
which is what the 0/1358 uhdm2rtlil byte gate and the 4418-arm boundary
measure.

**FENCES (all measured, all must-stay):**

* a **for-loop / foreach implicit wrapper** returns above the handle
  (`bs.syntax->kind == ForLoopStatement / ForeachLoopStatement`), untouched.
* **§ `parBlockJoinTailAfterFirstItem131`** reads `bss131`, which comes from
  `stmt.syntax` and NOT from the block symbol: a bad block has no syntax
  either, so `joinTailSeen131` stays `true` exactly as it did pristine — the
  empty-fork gate is unmoved (grid arm A `forkBad158` / `forkOk158`, arm E
  `nfBad158`).
* **§ `blockDeclAutomaticIsWrittenKw80`**, **§ `blockLocalTdDeclIsRefVarUnsupported155`**
  SITE 2, **§ `classScopedTdDeclTsUnsupported11`** SITE 2,
  **§ `builtinClassLocalUnsupportedBeforeClassPhase115`** SITE 2,
  **§ `typeParamRetIsRefVar58`**, **§ `declInitWrittenNewNoStmt66`** CALL SITE 1
  and **§ `thisSuperNewAssignNoStmt3`** CALL SITE 1 all live INSIDE the loop the
  handle now feeds; none of their predicates was touched, so a recovered block
  runs the identical factory the accepted twin runs. Arm C's `outOk158` /
  `outBody158` pair is the direct proof: the ACCEPTED out-of-body block and the
  RECOVERED one produce the SAME cell, `('ref_var','int_typespec','-','pc158')`
  (§6, residue R3).
* **`emitCtorBody27`** is reached from the LIST arm, not this one; a
  constructor holding a rejected inner block still goes through here for that
  inner block only (arm C `hostC158::new`).

---

## 4. THE PREDICTION, MADE FROM THE PRISTINE DATABASES BEFORE ANY PATCHED ONE EXISTED

`predsweep158.sh` censuses BOTH pristine sides of every row of a
`verify_golden` workdir and prints every statement block where **golden lists
variables and our pristine `vpiVariables` vector is NULL**. It also prints the
reverse bucket, which must stay empty.

```
uhdm2rtlil : -- rows=1358 SKIP-NOFILE=104 toward=0 away=0
surelog    : -- rows=956  SKIP-NOFILE=617 toward=13 away=0
```

**13 cells in 9 databases, NAMED, and nothing else:**

| row-mode | owner | span | golden lists |
|---|---|---|---|
| SeqDriver / SimpleUVM / Scoreboard / MiniAmiq (uvm-1.2) | `uvm_pkg::uvm_reg_predictor::get_type_name` | `118:26-122:8` | `t:ref_var` |
| BuildUVMPkg (1800.2 pp_output) | `uvm_pkg::uvm_reg_predictor::type_name` | `61835:28-61839:8` | `t:ref_var` |
| BuildUVMPkg | `uvm_pkg::uvm_registry_common::create` | `14059:30-14066:8` | `msg:string_var` |
| BuildUVMPkg | `uvm_pkg::uvm_registry_common::set_type_alias` | `14094:63-14100:9` | `factory:class_var, rgtry:ref_var` |

Predicted mover set, BY NAME: **SeqDriver ×2, SimpleUVM ×2, Scoreboard/default,
MiniAmiq ×2, BuildUVMPkg ×2 — 9 databases on surelog, 0 on uhdm2rtlil.**
(`Scoreboard/testflags` is `SLANG_REJECT` and has no `slang.uhdm`; it is one of
the 617 SKIP-NOFILE rows, counted, never read as agreement.)

`byteverify.sh --selfcheck` then measured **MOVERS 9 / 956** on surelog and
**0 / 1358** on uhdm2rtlil — the predicted set exactly, with no unpredicted
mover and no predicted non-mover.

---

## 5. THE GRID — 6 ARMS, BOTH VIEWS, THREE WAYS (golden vs pristine vs patched)

`grid158.sh` builds Surelog's golden, our pristine and our patched database for
each arm in BOTH the def and the elab view (12 commands per arm, each echoed
into the arm's own `cmds.txt` with its binary PATH and its own `rc=` line —
**all 72 arm commands returned rc=0**, so no cell in this table is a segfault
wearing a result). `score158.py` scores every cell three ways.

| arm | what it varies |
|---|---|
| `g158_a_shape.sv` | BLOCK SHAPES: an if-arm `begin` with one local + one statement (the corpus shape), a bare inner `begin`, a NAMED `begin`, a NESTED `begin`, a `for` body, a `fork` arm, a `while` body, a `case` item — each with an ACCEPTED twin |
| `g158_b_type.sv` | WHAT THE LOCAL IS: a type parameter defaulted to `int`, one defaulted to a CLASS, a typedef OF a type parameter, a parameter-typed unpacked array, plus plain `int`/`string`/class/enum/struct/vector locals — all in ONE rejected block, against the SAME declaration set in an accepted one; and the OVERRIDE pair (`ovB158`, whose default binding is rejected and whose `#(payl158)` specialization is accepted, in ONE database) |
| `g158_c_home.sv` | WHERE: in-body method, OUT-OF-BODY method, static method, task, constructor, a class that EXTENDS, one and two type parameters, `$unit` / package / module / interface / program homes, a NON-generic negative control, and the out-of-body ACCEPTED twin |
| `g158_d_count.sv` | LISTING COUNTS AND ORDER: 0/1/2/3 locals; a block-scope `localparam`; a NAMED rejected block with locals (label + end label + the `::lb158::` prefix); a NAMED rejected block with NO locals; two sibling rejected blocks |
| `g158_e_edge.sv` | EDGES: rejected inside rejected; an accepted block nested in a rejected one; the ELSE arm; array / queue / associative locals; a NAMED fork; bad-statement FIRST vs LAST; twin siblings; a `do..while` body |
| `g158_f_witness.sv` | THE REDUCED CORPUS WITNESS — `uvm_reg_predictor.svh:54,117-124` in 24 lines. Pristine **163 cmp lines / 1 head**, `LHS: begin / RHS: <null>`; patched **67 / 1** on the concat `operation` — the SAME two numbers and the SAME next head object as SimpleUVM ×2 and Scoreboard/default |

**GRID TOTALS (6 arms + the one moved earlier-pass boundary arm, both views,
both row families):**

```
RIGHT=181  TOWARD=93  WRONG=0  STILL=7  RESHAPE=8
ONLY-G=15  AWAY=0  ONLY-OURS=7  ONLY-A=2
```

* **`WRONG = 0`** — no cell that was right pristine is wrong patched.
* **`AWAY = 0`** — no cell exists in the patched database that exists in
  neither golden nor the pristine one. Nothing was invented.
* **`ONLY-A = 2`** are the two NAMED rejected blocks (`a_shape namedBad158`,
  `d_count namedBad158`): pristine emitted an UNNAMED `begin` at the whole
  `begin..end` span, patched emits golden's `named_begin` at golden's LABEL
  span. Each ONLY-A row pairs with a TOWARD row at golden's own key —
  e.g. `('named_begin','47:15-47:23')` `G=('lbBad158','1','2',…,'nb158:ref_var')`
  matched exactly. The block did not disappear; it moved onto golden's key.
* **`STILL = 7` and `RESHAPE = 8`** are named one by one in §6. Every one of
  them is a residue that the ACCEPTED twin in the same arm shows too — the
  recovered block runs the identical factory the accepted block runs, so it
  inherits the same open residues and adds none.

---

## 6. THE RESIDUES THIS PASS DOES NOT CLOSE (each MEASURED, none guessed)

**R1 — a rejected block loses its SPAN as well as its scope, and there is no
handle for it.** `bindBlock`'s early return also skips `result->syntax = &bss`
(Statement.cpp:308), and `createBlockStatement` gives a single-item block the
ITEM's source range — so a rejected block whose bound body collapses to one
statement comes out at `0:0-0:0`, and the enclosing body's wrapper `begin`
anchors on it (`case StatementKind::List`'s `sl.list[1]->sourceRange`). Cells:
`d_count zeroBad158`, `d_count twinBad158`'s wrapper, `e_edge twinBad158`'s
wrapper, `a_shape forkBad158`'s fork, `e_edge nfBad158`'s fork, and
`r10uvm59repro/a1_witness.sv`'s `arg_pos`. **The judge never reads a span**
(RESUME.md §9), so these are DUMP-ONLY; they are UNCHANGED pristine→patched
(they appear as the `ONLY-OURS`/`ONLY-G` pairs in the grid totals) and no
corpus row's head sits on one.

**R2 — a rejected block with NO locals of its own keeps neither its LABEL nor
its scope.** `bindScopeInitializers` pushes a statement per VARIABLE and
nothing else, so a block whose scope holds only a label (`d_count namedZero158`,
`e_edge nfBad158`'s `fork : nf158`, `a_shape forkBad158`) offers the recovery no
handle at all: golden's `named_begin`/`named_fork` stays our `begin`/`fork_stmt`.
`VpiName` IS read by `scope::Compare`, so this is a REAL residue, not a
dump-only one. It was **deliberately not closed**: the only other handle is a
CHILD block's scope's parent, and that is unsound — for
`begin <no locals> begin int x; end end` inside a NAMED block the child's parent
scope is the ENCLOSING label's `StatementBlockSymbol`, and the recovery would
stamp the wrong label on the inner block. No corpus row reaches this face (the
13 predicted cells are all locals-bearing).

**R3 — an out-of-body method's type-parameter local binds an
`int_typespec` where golden binds an `unsupported_typespec` named `T`.**
Arm C's pair is the decider: the ACCEPTED twin `hostC158::outOk158`'s `oo158`
and the RECOVERED `hostC158::outBody158`'s `ob158` produce the SAME cell,
`('ref_var','int_typespec','-','pc158')`, against golden's
`('ref_var','unsupported_typespec','T','pc158')`. It is a pre-existing gap in
§ `scopedTdUnsupTsHomePkgInstance83` / § `blockLocalTdDeclIsRefVarUnsupported155`'s
out-of-body face, inherited by the recovered block and introduced by nothing
here.

**R4 — a typedef OF a type parameter is an `int_var` for us and a `ref_var`
for golden**, and a type-parameter typespec carries golden's alias NAME where
ours carries none (`b_type allBad158` `al158`/`tp158`/`ar158`). The ACCEPTED
twin `allOk158` scores the identical residue (`STILL`), so again: inherited,
not introduced. This is § `typeParamRetIsRefVar58`'s alias face.

**R5 — a generic class declared inside a MODULE, an INTERFACE or a PROGRAM is
not emitted by us at all** (`c_home ifC158` / `prC158` / `modC158`: `ONLY-G` on
both binaries, 3 BLK + 6 DECL cells). Unrelated to this law and unchanged by
it; recorded because the arm measured it.

---

## 7. THE NEXT HEAD (R0)

SimpleUVM ×2 and Scoreboard/default move from 163 cmp lines to **67**, on a
**new object**, and the reduced witness `g158_f_witness.sv` reproduces the same
move (163 → 67) in 24 lines:

```
LHS:
operation: , id:155851, line:121:19, endln:121:67          <- {"uvm_reg_predictor #(", …, ")"}
|vpiParent: \_assignment: , line:121:7, endln:121:67
|vpiOpType:33
|vpiOperand: \_constant: "uvm_reg_predictor #(" 121:20-121:42
|vpiOperand: \_hier_path: (t.get_type_name), 121:44-121:61
              |vpiActual: \_ref_obj: (t)               121:44-121:45
              |vpiActual: \_method_func_call: (get_type_name) 121:46-121:59
|vpiOperand: \_constant: ")" 121:64-121:66
RHS: <null>
```

**R0 — SimpleUVM ×2 + Scoreboard/default, 67 lines, 1 head: the CONCATENATION
whose middle operand is a METHOD CALL ON A LOCAL WHOSE TYPE IS AN UNBOUND TYPE
PARAMETER.** `t.get_type_name()` is bad for `BUSTYPE = int`, so the whole
`assignment`'s Rhs expression is an `InvalidExpression` and we emit no
`vpiRhs` at all; golden emits the concat with a `hier_path`
`[ref_obj t, method_func_call get_type_name]`. This is
§ `droppedCall14`'s family one level up: `emitDroppedCall14` handles a bad
statement whose whole expression is a dotted call, not a bad OPERAND inside a
good operation. The same shape is what
`tools/probe/r10uvm158repro/g158_f_witness.sv` prints at 67 lines, so the next
pass has a 24-line repro before it starts.

---

## 8. THE CORPUS CENSUS — 9 MOVED DATABASES, THREE WAYS

`scoreall158.sh` censuses golden, our pristine and our patched database for
each moved row and scores every BLK and DECL cell (`CENSUS.r10uvm158.txt`):

| row-mode | BLK | DECL |
|---|---|---|
| SeqDriver def / tf | RIGHT 6059 **TOWARD 1** WRONG 0 AWAY 0 | RIGHT 11833 **TOWARD 1** WRONG 0 AWAY 0 |
| SimpleUVM def / tf | RIGHT 4002 **TOWARD 1** WRONG 0 AWAY 0 | RIGHT 9281 **TOWARD 1** WRONG 0 AWAY 0 |
| Scoreboard def | RIGHT 4025 **TOWARD 1** WRONG 0 AWAY 0 | RIGHT 9313 **TOWARD 1** WRONG 0 AWAY 0 |
| MiniAmiq def / tf | RIGHT 6609 **TOWARD 1** WRONG 0 AWAY 0 | RIGHT 12755 **TOWARD 1** WRONG 0 AWAY 0 |
| BuildUVMPkg def / tf | RIGHT 4397 **TOWARD 3** WRONG 0 AWAY 0 | RIGHT 9211 **TOWARD 4** WRONG 0 AWAY 0 |

**13 BLK cells and 15 DECL cells moved TOWARD golden; `WRONG = 0`,
`AWAY = 0`, `RESHAPE = 0`, `ONLY-A = 0` in every one of the 9 databases.** The
13 BLK cells are exactly the 13 the prediction named.

The whole-dump, path-normalised, **order-blind** diff (Scoreboard/default is a
~50/50 coin, so order-blind is the only sound attribution) closes the
attribution: **15 added lines on each uvm-1.2 row and 90 on BuildUVMPkg, ZERO
deleted lines**, every one of them inside a recovered block's `vpiVariables`
listing — the `ref_var` / `class_var` / `string_var`, its `ref_typespec`, its
`int_typespec` / `class_typespec` / `string_typespec`, the two `assignment`s
`set_type_alias` gains with them, and the `vpiClassDefn` back-reference of the
recovered `uvm_factory` handle. `DUMPDIFF.r10uvm158.txt` holds every line.

---

## 9. THE GATES

All green; the full battery with its numbers is `GATES.r10uvm158.txt`. In one
line: goldens **23/0** and `/bin/false` **0/23**; uhdm2rtlil **679/50/2** both
modes with **0 differing rows** and **0/1358 byte movers**; surelog status
histograms **identical to this pass's own pristine sweep** with **0 differing
rows over 1588** and **9/956 byte movers, all 9 predicted by name**; canaries
**52/8 ok, 0 changed**, `ctcan2` PASS both corpora, `canaudit` **audited=29
UNCOVERED=0 FENCE-BREACH=0**; the six protected databases byte-identical with
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on their pins; the wide
boundary **LISTED=4419 PROCESSED=4419 MOVED_ARMS=8 RC_DIFFS=0** with six of
the eight being this pass's own positive control, the seventh
(`r10uvm59repro/a1_witness.sv`) re-measured TOWARD golden, and the eighth
(`r10vrgg3repro/xi_iface_param_type/dut.sv`) refuted as a gate flake — an arm
with no procedural code at all, byte-identical over 92 direct builds and over
a clean 52-arm re-run of the same gate.

**NO CORPUS ROW CONVERTED.** `CMP_NOTEQUAL` stays 10 (default) + 9 (testflags)
on surelog; `results/*.csv` were read only.

---

## 10. FILE MAP

| file | what it is |
|---|---|
| `ct158cen.cpp` | the census — `ct155cen.cpp` verbatim plus the `BLK` row type (block kind, name, NVARS / NSTMTS / NPARAM with `-1` for a NULL vector and `0` for an empty one, and the ordered variable list) |
| `score158.py` | the three-way cell scorer (RIGHT / TOWARD / WRONG / STILL / RESHAPE / ONLY-G / AWAY / ONLY-OURS / ONLY-A), `--rows BLK\|DECL`, `--nospan` |
| `predjoin158.py`, `predsweep158.sh` | the a-priori prediction from the PRISTINE databases only |
| `scoreall158.sh` | the corpus census over the moved rows |
| `grid158.sh`, `g158_*.sv` | the six grid arms and their builder |
| `bound158.sh` | the wide boundary gate |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing instruments, copied unchanged |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the official `uhdm-cmp` head logs for all seven named rows, both modes, measured on THIS worktree's own pristine and patched sweeps |
| `GRID.r10uvm158.txt`, `CENSUS.r10uvm158.txt`, `DUMPDIFF.r10uvm158.txt`, `PREDICT.*.tsv`, `BOUNDARY.r10uvm158.txt`, `GATES.r10uvm158.txt` | the measurements |
