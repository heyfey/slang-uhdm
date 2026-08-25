# r10uvm145 — § `tfItemLocalInitHoistsNoStatement145`

**MEASUREMENT-ONLY.**  Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here.  slang was NOT patched;
`results/*.csv` were READ ONLY; `GOLDEN_DEFER` stayed unset; the four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

---

## The head cleared

SeqDriver **and** MiniAmiq, both modes, **6254 / 6222 cmp lines and one
`^LHS:`** at base `2ce3785` — re-measured on THIS worktree's own pristine build
with `rowheads.sh` before a line of code was written (`head_pris_*.cmp`):

```systemverilog
function void uvm_component::m_set_cl_verb;                        // uvm_component.svh:3375
  static string values[$];                                         // :3380
  static bit    first = 1;                                         // :3381   <- SURPLUS
  string        args[$];                                           // :3382
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();   // :3383   <- SURPLUS
  uvm_root      top;                                               // :3384
  uvm_coreservice_t cs;                                            // :3385
  cs  = uvm_coreservice_t::get();                                  // :3386
  top = cs.get_root();                                             // :3387
```

The head object is the body `begin` at `3387:3`, and it is a `Stmts` **VECTOR
SIZE MISMATCH** — the vector `SafeCompare` overload sets BOTH containers, so
both sides print in full (RESUME.md §9).  Golden's `begin` holds **6**
top-level statements, ours held **8**: the two extra were the HOISTED
INITIALISERS of the TF-ITEM locals at `:3381` and `:3383`.

```
LHS (golden), 6 statements            RHS (ours), 8 statements
                                      assignment 3381:14-3381:23   <- surplus
                                      assignment 3383:25-3383:64   <- surplus
assignment  3386:3-3386:32            assignment 3386:3-3386:32
assignment  3387:3-3387:22            assignment 3387:3-3387:22
assignment  3456:3-3456:12            assignment 3456:3-3456:12
foreach_stmt 3392:3-3392:10           foreach_stmt 3392:3-3392:10
if_stmt     3389:3-3390:74            if_stmt    3389:3-3390:74
if_stmt     3432:3-3454:6             if_stmt    3432:3-3454:6
```

---

## 1. The decoded model (Surelog, read line by line)

The four questions the brief asked, answered from the source and then measured.

### (1) What each production does with a local's initialiser

| production | Surelog site | the initialiser |
|---|---|---|
| **TF-ITEM** | `CompileHelper::compileTfPortDecl`, the `paBlock_item_declaration` arm, `CompileStmt.cpp:1661-1712` | **never compiled at all** |
| **BLOCK-ITEM** | `CompileHelper::compileDataDeclaration`, `CompileStmt.cpp:1127-1281` | an `assignment` per declarator, kept as a body statement when it has an Rhs |

The TF-ITEM arm's whole declarator loop is:

```cpp
while (Variable_decl_assignment) {
  NodeId nameId = fC->Child(Variable_decl_assignment);        // the NAME
  const std::string_view name = fC->SymName(nameId);
  ...
  if (variables* var = (variables*)compileVariable(component, fC, Data_type, ...)) {
    var->VpiAutomatic(!is_static);
    var->VpiName(name);
    vars->push_back(var);
    ...                                                       // typespec only
  }
  Variable_decl_assignment = fC->Sibling(Variable_decl_assignment);
}
```

It never locates the `paExpression` sibling, never calls `compileExpression`,
and `compileTfPortDecl`'s return type is a `std::pair<VectorOfio_decl*,
VectorOfvariables*>` — **there is no statement list to put an assignment in**.
So under the TF-ITEM production the initialiser reaches the database NOWHERE:
no hoisted `assignment`, and no `vpiExpr` on the variable.  Both halves were
then measured, not assumed: the census column `LEXPR` scores
`RIGHT->RIGHT` on every cell of every arm — **neither producer ever puts
`vpiExpr` on a subroutine body local**, under either production, for any kind
or any initialiser shape.

The BLOCK-ITEM arm is where the hoist we emit comes from:

```cpp
assignment* assign_stmt = s.MakeAssignment();       // CompileStmt.cpp:1261
assign_stmt->VpiOpType(vpiAssignmentOp);
assign_stmt->VpiBlocking(true);
if (var) { var->VpiParent(assign_stmt); assign_stmt->Lhs(var); }
results->push_back(assign_stmt);
if (Expression) { ... assign_stmt->Rhs(rhs); }
```

— one per declarator, **with or without an initialiser** — and the body loop
that consumes it decides (`compileFunction`, `CompileStmt.cpp:2506-2520`; the
task twin is identical):

```cpp
} else if (stmt_type == uhdmassignment) {
  assignment* stmt = (assignment*)st;
  if (stmt->Rhs() == nullptr || any_cast<variables*>(stmt->Lhs())) {
    ...                                    // it is a DECLARATION: list the var
    if (stmt->Rhs() != nullptr) stmts->push_back(st);      // <- THE HOIST
    else                       var->VpiParent(begin);      // <- dropped
  } else stmts->push_back(st);
}
```

That is exactly the shape § `oobRefVarLocalHoistNet107`,
§ `classPropNewLhsNoHoist109` and uvm122's begin-block lvalue law all model,
and this pass leaves it alone.

### Which subroutine takes which production

* **FUNCTION** — `compileFunction` calls `compileTfPortDecl` for *any*
  `paTf_item_declaration` and then advances `Function_statement_or_null` past
  every one of them (`CompileStmt.cpp:2425-2470`).  A paren-less header is
  therefore ALWAYS TF-ITEM; a port-list paren makes the declarations block
  items.
* **TASK** — `compileTask` (`CompileStmt.cpp:2010-2027`) looks at
  `fC->Child(Tf_port_list)` first and calls `compileTfPortDecl` **only when it
  is not** a `paBlock_item_declaration`; so a task is TF-ITEM exactly when its
  body declares io.

That is precisely § `blockItems9`'s existing selector ("a FUNCTION takes the
block shape iff its header carries a port-list paren, a TASK unless its body
declares io"), which is why this law needs no new predicate.

### (the threshold) A TF-ITEM declaration is not a body item

`MoreFunction_statement_or_null = fC->Sibling(Function_statement_or_null)`
is evaluated AFTER that advance, so Surelog's "Page 983, 2017 Standard: More
than 1 Stmts" test counts only the SURVIVING statements.  Under the TF-ITEM
production a declaration contributes NOTHING to the wrapper `begin`.  Our
anchor loop already spelled that (`bodyTfItems9` skips every
`VariableDeclaration` when it builds `items9`); the THRESHOLD
(`eff9 = initCount + real.size()`) was the half that disagreed with it.

### The law

> **§ tfItemLocalInitHoistsNoStatement145.**  Under the **TF-ITEM** production
> a subroutine body local's initialiser produces **no statement and no
> `vpiExpr`** — Surelog never compiles the expression at all — and the
> declaration counts for **nothing** toward the body `begin`'s
> two-statement threshold.  The BLOCK-ITEM production is unchanged.
> A CLASS CONSTRUCTOR is never this production; neither is a
> qualifier+lifetime stub.

---

## 2. The production is directly visible in golden's database

`ct145cen` reads the production off either producer without knowing the source:
a TF-ITEM body lists its locals on the `task_func` and **not** on the body
`begin` (`NVARS>0`, `BVARS==-1`); a BLOCK-ITEM body dual-lists them
(`LOWN=both`).  Golden-vs-pristine calibration, arm A, both views:

```
pristine  LHOIST=1  LOWN=both  22      golden  LHOIST=1  LOWN=both  22
          LHOIST=1  LOWN=func  20              LHOIST=1  LOWN=func   0
```

Golden has **zero** hoists on the TF-ITEM face and exactly ours on the
BLOCK-ITEM face — the two productions, separated by the database alone.

---

## 3. The change

Two lines of gate in `src/StmtEmit.cpp`'s `StatementKind::List` arm, plus one
range guard; the law and its Surelog citations are in `include/UhdmExporter.h`
next to `tfBodyTfItems9`.

1. the threshold: `eff9 = (bodyTfItems9 ? 0 : initCount) + real.size();`
2. the statement: `if (bodyTfItems9) continue;` in the initialiser loop;
3. `items9[0]` is no longer read when `items9` is empty.

**FENCES (all measured, all must-stay):**

* a **CLASS CONSTRUCTOR** never reaches the gate — `emitCtorBody27` returns
  above it (§ `constructorBodyElementShift27`), which is what
  § `ctorBodyLocalsNotOnFunc71` and § `tfItemLocalClassTsNotAConstructor142v`
  require.  Arm C's `Holder145::new()` and the PAREN-LESS `Second145::new`
  are byte-identical pristine→patched and match golden on every column.
* the **§ `qualLifetimeStubListsNoBodyLocals141`** stub emits no body at all;
  arm C's `qualLife145` is unmoved.
* **`= new`** initialisers were already dropped under BOTH productions by
  § `declInitWrittenNewNoStmt66` and are not re-added (arm B `cNew`, `dArr`).
* an **inner `begin`**'s own locals are block items however the body was
  written — the gate is `tfBodyStmt9 == &stmt`, the BODY statement only
  (arm D `innerNoParen145`: the nested `nest145`'s `innerV` keeps its hoist on
  both sides).

---

## 4. The crash this also fixes

With every body item a declaration, the wrapper's anchor loop skipped them all
and `items9` came out EMPTY, while `eff9 = initCount + real.size()` had already
decided to build that wrapper — `items9[0]` then read off the end of the
vector.  The PRISTINE binary **SEGFAULTS (rc=139)** on

```systemverilog
function void f;  int k1 = 4;  int k2 = 5;  endfunction    // paren-less: TF-ITEM
```

in a package or a module, def view and elab view alike.  `verify_golden.py`
records rc=139 as `SLANG_REJECT` wearing the last stderr warning (RESUME.md
§9), so this crash was invisible as a crash.  Arm `g145_e_zero.sv` is the
quarantined cell — the pristine binary cannot produce a database for it at all
(`NO-pris rc_pris=139`), which is why it could not share an arm with scoreable
cells — and under the patch it compiles and scores **ONLY-GOLDEN=0 /
ONLY-OURS=0 on every row kind and every column, in both views**.  No corpus
row reaches it (see §6's status histograms: no `SLANG_REJECT` converted).

---

## 4b. The threshold half, confirmed against golden where the database could not say

The one shape the pristine database cannot decide is a TF-ITEM body whose only
initialiser was a written `= new`, already dropped by
§ `declInitWrittenNewNoStmt66`: it leaves neither a statement nor a `vpiExpr`,
so nothing in the database says the wrapper `begin` exists only because
`initCount` counted it.  The campaign already owns such a cell — pass 66's arm
`tools/probe/r10uvm66repro/a2_slots.sv`, cell `n24_tfitems` (`250:4`):

```systemverilog
task n24_tfitems;
   input int a;              // body io => TF-ITEM
   a2c ce = new();           // dropped by § declInitWrittenNewNoStmt66
   ce.set(a, 2);             // the ONE surviving statement
endtask : n24_tfitems
```

Run under Surelog and censused (`ct145cen`, def view):

```
golden    BKIND=method_func_call  BSPAN=253:10-253:13  NSTMTS=-1  NTOPS=1  NVARS=1
pristine  BKIND=begin             BSPAN=253:7-253:20   NSTMTS=1   NTOPS=1  NVARS=1
patched   BKIND=method_func_call  BSPAN=253:10-253:13  NSTMTS=-1  NTOPS=1  NVARS=1
```

The patched body row is byte-identical to golden's and the pristine one was
not.  The wide boundary gate found this cell on its own (it is where the gate's
"a moved database must have LOST a ROW=STMT" clause was too narrow — nothing is
lost here but the wrapper), and it is the only place in either corpus or any
arm tree where the § 66 interaction could hide.

## 5. The grids (`arms145.sh` + `ct145cen` + `score145.py` — `ARMS.txt`)

Five arms, each run under Surelog (golden), the pristine and the patched
binary, in the def and elab views — 5 arms x 2 views, `LISTED=5 PROCESSED=5
PROCESSED-ASSERT-OK`, every rc recorded.

| arm | grid |
|---|---|
| `g145_a_prod.sv` | **productions x lifetimes x declarators**: paren-less / paren function, task with / without body io, ANSI task; written `static` / `automatic` / neither; 1, 2 and 3 declarators per statement with the MIDDLE one uninitialised |
| `g145_b_kind.sv` | **kinds x initialiser shapes** under both productions: class handle, bit, int, string, enum, packed struct, real, queue, dynamic array, associative array, fixed array; literal / call / `new` / `null` / expression / another local |
| `g145_c_home.sv` | **homes**: package free function and task, in-body class method, OUT-OF-BODY class method and task, module function and task, program, interface, CLASS CONSTRUCTOR (paren and paren-less), qualifier+lifetime stub |
| `g145_d_thresh.sv` | **the threshold**: N inits x M real statements for N,M in 0..3 under both productions; an inner named `begin`; a body that IS one explicit `begin`; a `for`-loop variable |
| `g145_e_zero.sv` | **the zero-statement TF-ITEM bodies** — the pristine SEGFAULT, quarantined |

Cells are joined as MULTISETS on ID-FREE keys (`HSPAN` for a body,
`HSPAN+SSPAN` for a statement, `HSPAN+LNAME` for a local); the DEF/ELAB view
and the design listing are deliberately out of the key.  Spans appear ONLY in
keys, never as scored columns — `uhdm-cmp` reads no location at all, so a span
in the key can only SPLIT cells the judge pairs, and a split shows up as
ONLY-GOLDEN / ONLY-OURS rather than hiding.  Because this pass REMOVES
objects, ROW-SET one-sided counts are printed per row kind ahead of the column
verdicts (§ 109's lesson).

**RESULT — `RIGHT->WRONG` 0 and `AWAY` 0 in every arm, every view, every
column.**  The surplus statements go to zero:

| arm.view | ROW=STMT ONLY-OURS pristine -> patched | ROW=STMT ONLY-GOLDEN pristine -> patched |
|---|---|---|
| a.def / a.elab | 20 -> **0** / 30 -> **0** | 0 -> 0 / 0 -> 0 |
| b.def / b.elab | 30 -> **0** / 68 -> **0** | 0 -> 0 / 0 -> 0 |
| c.def / c.elab | 11 -> **0** / 21 -> **0** | 0 -> 0 / 0 -> 0 |
| d.def / d.elab | 26 -> **0** / 36 -> **0** | 6 -> **2** / 10 -> **2** |
| e.def / e.elab | (no pristine database) -> **0** | (no pristine database) -> **0** |

`SLHSVAR` — Surelog's own "this assignment is a declaration" test
(`any_cast<variables*>(stmt->Lhs())`) — goes to ONLY-OURS 0 with it.
`NSTMTS` / `NTOPS` / `BKIND` / `LHOIST` all score `WRONG->RIGHT` on the
TF-ITEM cells and `RIGHT->RIGHT` on every BLOCK-ITEM twin; `LKIND`, `LAUTO`,
`LEXPR`, `LOWN`, `NVARS`, `BVARS` are `RIGHT->RIGHT` throughout — the law moves
statements and nothing else about the locals.

Arm D's residual 2 ONLY-GOLDEN cells are R1 below (a BLOCK-ITEM body whose
whole `Stmt` IS the bare hoisted assignment) — a pre-existing residue in the
OTHER production, unmoved by this pass.

### A surplus DUPLICATE LISTING goes with the statement

Arm B's elab view carried FOUR listings of `kindsNoParen145` and
`kindsTaskIo145` where golden has TWO; under the patch it has golden's two
(`ROW=BODY` / `ROW=LOC` ROWSETS ONLY-OURS 4 / 28 -> **0**, ONLY-GOLDEN **0**
on both sides).  Both are the arm's only bodies whose removed statement
carried a call to a static class method.  Nothing golden asks for is lost —
every one-sided count moves toward golden and none away — and the wide
boundary gate therefore admits a DISAPPEARING `ROW=LOC` line while treating an
APPEARING one as a breach.

---

## 6. The a-priori prediction (`PREDICTION.txt`, `predsweep145.sh`, `pred145.py`)

`ct145cen` was run over **all 956 surelog databases and all 1358 uhdm2rtlil
databases of the PRISTINE sweep** (`LISTED=956 PROCESSED=956 NONZERO_RC=0`,
`LISTED=1358 PROCESSED=1358 NONZERO_RC=0`) and the mover set was named BEFORE
the patched binary existed:

```
surelog     9 databases, 86 hoist cells, 0 wrappers
            SeqDriver df+tf, MiniAmiq df+tf, BuildUVMPkg df+tf,
            SimpleUVM df+tf, Scoreboard df
            uvm_pkg::uvm_component::m_set_cl_verb   (uvm_component.svh:3375)
            uvm_pkg::uvm_component::m_set_cl_action (uvm_component.svh:3462)
            uvm_pkg::uvm_component::m_set_cl_sev    (uvm_pkg.sv:41346, BuildUVMPkg)
uhdm2rtlil  0 databases
```

`PREDICTED-WRAPPERS=0`: the threshold half has **zero corpus reach** and is
proved by the grid alone.

The predicate is `SLHSVAR=1` — a TF-ITEM body statement whose Lhs IS a
`variables` object, which is Surelog's OWN declaration test
(`any_cast<variables*>(stmt->Lhs())`, `CompileStmt.cpp:2508`).  A first cut
asked instead whether the Lhs object appears in the owner's `Variables` list,
and UNDER-COUNTED in the ELAB view, where a cloned listing's `Variables` vector
holds different objects than its body does; the WIDE BOUNDARY GATE caught that
on `r10uvm139repro/g139_b_kinds.sv elab` and the predicate was replaced.  Both
predicates name the SAME nine corpus databases and the same 86 cells.

A first cut of the predictor also dropped the `#hoists >= 1` conjunct and named ten
extra databases (PackFunc / EvalFunc / FuncIoTypespec / PreprocFunc /
BlockingAssignRewrite, both modes; subroutines `log2`, `fshl_s`, `foo_bar`).
All five sources were then read: **none of their body locals carries an
initialiser**, so `initCount` was 0 before the law and is 0 after, and the
`begin` those bodies dump is the SOURCE `begin`, not a wrapper.  They are printed in `PREDICTION.txt` as **CANDIDATES** (18 surelog +
4 uhdm2rtlil body-begins, adding `asym_ram_sdp_read_wider` /
`asym_ram_sdp_write_wider`), which is exactly the set where a
§ `declInitWrittenNewNoStmt66` `= new` drop could have hidden an initialiser the
database cannot show — closed empirically at zero by reading those sources, and
confirmed by measurement: **not one candidate moved** (`byteverify`
MOVERS 9/956 and 0/1358).

---

## 7. Gates (all green)

Both binaries were built in THIS worktree at base `2ce3785`, frozen `chmod 555`
at immutable paths before any sweep, and every `cmds.txt` was audited by binary
PATH (the single value found across all 2314 sweep directories was the frozen
patched binary — never the main-tree one, which `verify_golden.py` and
`check_goldens.sh` silently default to).

| gate | result |
|---|---|
| (1) build both, `-j 2` | pristine and patched both `Built target slang_uhdm`, 0 errors |
| (2) `tests/check_goldens.sh` (`SLANG_UHDM` exported per binary) | **PASS=23 FAIL=0**; negative control `SLANG_UHDM=/bin/false` **FAIL=23 PASS=0** |
| (3) uhdm2rtlil testflags | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2** (identical to pristine); `ct8rows` vs `results/gate_uhdm2rtlil.csv` **PASS**, vs this worktree's own pristine csv **PASS**, default mode **PASS** — 0 differing rows, status AND dump column |
| (4) surelog `--mode both` | histograms **byte-identical to pristine** in both modes (default 471/283/25/10/5; testflags 466/284/23/9/5/3/2/1/1); `ct8rows` vs `results/golden_surelog.csv` **PASS** and vs this worktree's own pristine csv **PASS** — **0 differing rows over 1588**, and **NO row was converted** (`results/*.csv` were never written) |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358** (SELFCHECK 1357/1358 flagged); surelog **MOVERS 9 / 956**, `PATH_SETS_IDENTICAL` on both (SELFCHECK 955/956 flagged) |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, u2r **ok=8 changed=0**; `ctcan2.sh` **PASS** on both; `canaudit.sh canaries.sh ctcan2.sh` **PASS, audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr **byte-identical**; SVSwitch **4842211c4030**; YosysVerx **6ccda350c24a** |

**THE NINE MOVERS ARE EXACTLY THE NINE PREDICTED, BY NAME** — SeqDriver,
MiniAmiq, BuildUVMPkg and SimpleUVM in both modes plus Scoreboard/default.
Scoreboard/default is the ~50/50 COIN (RESUME.md §9), so it is attributed
ORDER-BLIND: the path-normalised, id-normalised, SORTED dump diff.

Attribution of the movers (order-blind sorted dumps, `id:` normalised):

* every REMOVED line belongs to one of the three predicted assignments or its
  subtree — the `assignment` itself at `3381:14` / `3383:25` / `3467:14`
  (`41167` / `41254` / `41348` in BuildUVMPkg's `uvm_pkg.sv`), its
  `vpiOpType:82` / `vpiBlocking:1` / `vpiLhs` / `vpiRhs` / `vpiStmt` /
  `vpiParent` fields, the Rhs `constant` (`UINT:1`, `UINT:0`) or the
  `ref_obj (uvm_cmdline_processor::get_inst)`, and the `\_begin:` /
  `\_bit_var:` / `\_class_var:` PARENT-REFERENCE lines those objects printed;
* every ADDED line is a `\_function:` parent-reference line — the local's
  `vpiParent` is the FUNCTION again instead of the assignment that no longer
  exists.  **No generated `Compare` reads `VpiParent`** (RESUME.md §9), so the
  judge does not see it, and the row gates confirm it: 0 differing rows.

## 8. Heads before -> after

`rowheads.sh` on this worktree's own pristine and patched sweep workdirs;
counts are DEPTH, not distance.

| row | before | after |
|---|---|---|
| **SeqDriver default / testflags** | **6254 / 6254** | **62 / 62** |
| **MiniAmiq default / testflags** | **6222 / 6222** | **62 / 62** |
| SimpleUVM default / testflags | 62 / 62 | 62 / 62 (byte-identical head log) |
| Scoreboard default | 62 | 62 |
| BuildUVMPkg default / testflags | 55 / 55 | 55 / 55 (its head is reached earlier) |
| Earlgrey_0_1 default / testflags | 250 / 278 | 250 / 278 |
| Rggen default | 0 | 0 |

(`Scoreboard/testflags` is `SLANG_REJECT` and `Rggen/testflags` has no golden —
both print SKIP-NOFILE and are COUNTED, never read as perfection.)

SeqDriver and MiniAmiq have come DOWN onto SimpleUVM's and Scoreboard's head:
**four row-modes now share one 62-line head**, and SimpleUVM's head log is
byte-identical pristine->patched, which proves the four met at an object this
pass did not touch.

## 9. Residues and R0

* **R0 (the next head).**  SeqDriver, SimpleUVM, Scoreboard and MiniAmiq — six
  row-modes, **62 cmp lines, ONE `^LHS:`**, the SAME object on all four rows:
  a `class_var` named `cs`, reached as the `vpiActual` of the `cs` reference
  inside `uvm_component::m_set_cl_verb`.

  ```
  LHS (golden)                                  RHS (ours)
  class_var: (uvm_pkg::cs), 1731:21-1731:23     class_var: (…m_set_cl_verb::cs), 3385:3-3385:20
  |vpiParent: \_package: uvm_pkg                |vpiParent: \_function: …m_set_cl_verb
  |vpiName:cs                                   |vpiName:cs
  |vpiAutomatic:1                               |vpiAutomatic:1
  |vpiVisibility:1                              (absent)
  ```

  Golden's late binder resolves the FUNCTION-LOCAL `uvm_coreservice_t cs;`
  (`uvm_component.svh:3385`) to a PACKAGE-scope `class_var uvm_pkg::cs`
  declared at `uvm_pkg.sv:1731`, carrying `vpiVisibility:1`; we bind it to the
  local.  A § `oobRefVarLocalHoistNet107`-family late-binding question, and the
  `vpiVisibility` field is read by `variables::Compare`.  See
  `head_pat_default_SeqDriver.cmp` (and the identical-shaped
  `head_pat_default_SimpleUVM.cmp`, which is byte-identical to the PRISTINE
  one — this object was already SimpleUVM's head before the pass).
* **R1 — the BLOCK-ITEM body that is nothing but ONE initialised declaration.**
  `function void f(); int b1 = 1; endfunction`: golden's `Stmt` IS the bare
  hoisted `assignment` (`compileFunction`'s 0-or-1-statement branch,
  `CompileStmt.cpp:2534-2570`) and it lists TWO variables; we emit no `Stmt`
  at all and one variable.  A different site (slang hands that body as a bare
  `VariableDeclStatement`, not a `StatementList`, so StmtEmit's list arm is
  never entered) and the OTHER production — deliberately untouched.  Cells:
  arm D `p1m0_145` (`23:3-23:81`), both views, `WRONG->WRONG` on NVARS /
  BKIND / NTOPS and 2 ONLY-GOLDEN `ROW=STMT` rows.  Corpus incidence: zero
  (no predicted cell is one).
* **R2 — the surplus DUPLICATE LISTING.**  In the ELAB view we emit FOUR
  listings of a package free subroutine where golden emits TWO, whenever a body
  statement carries a call to a static class method (arm B
  `kindsNoParen145` / `kindsTaskIo145`; the arm's package-object count is
  142 pristine, 134 patched, 127 golden).  This pass takes 4 -> golden's 2 for
  the two bodies whose calling statement it REMOVED, which is a side effect of
  the removal and not a rule: the remaining surplus is a separate law about
  whatever mints the extra listing.  Nothing golden asks for is lost
  (ONLY-GOLDEN 0 on both sides, before and after).
* **R3 — the TF-ITEM local's SPAN.**  `compileTfPortDecl`'s block-item arm calls
  no `populateCoreMembers`, so golden's TF-ITEM local keeps `compileVariable`'s
  DECLARED-TYPE span; we give an INITIALISED one the NAME span (`hasInit` in
  TaskFuncEmit's `blockLocal || hasInit || blockItems9` test).  Dump-only —
  no generated `Compare` reads `VpiFile` / line / column (RESUME.md §9) — and
  therefore left alone; the census keeps spans in KEYS only and scored zero
  cells on it.
* **R4 — `= new` under the BLOCK-ITEM production.**  § `declInitWrittenNewNoStmt66`
  drops the hoist for a written `= new` on BOTH productions.  Under TF-ITEM
  that is now redundant (this law drops it anyway); under BLOCK-ITEM it is the
  only rule and is untouched.  Not merged: they are different Surelog sites and
  the merge would have to be re-measured.

---

## 10. The instruments

| file | what it is |
|---|---|
| `ct145cen.cpp` | the census: one `ROW=BODY` per `task_func`, one `ROW=STMT` per TOP-LEVEL body statement, one `ROW=LOC` per local, deduped by UhdmId.  `HID` (the owner's UhdmId) exists for INTRA-DATABASE joins only and is never a scored column |
| `score145.py` | the multiset cell scorer (ROW-SET one-sided counts first, then per-column verdicts; span in the key, never in a column) |
| `arms145.sh` | runs the five arms x golden/pristine/patched x def/elab, PROCESSED-asserted, every rc recorded |
| `pred145.py` / `predsweep145.sh` | the a-priori mover prediction from PRISTINE databases alone |
| `bound145.sh` | the wide boundary gate (see §11) |
| `g145_[abcde]_*.sv` | the arms |
| `head_pris_*.summary.txt` / `head_pat_*.cmp` | the before and after heads, measured on this worktree's own builds |
| `ARMS.txt` / `PREDICTION.txt` / `BOUNDARY.txt` / `GATES.txt` | the raw logs |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the campaign's standard instruments, copied verbatim so this directory reproduces on its own |

## 11. The wide boundary gate (`bound145.sh` — `BOUNDARY.txt`)

Every `.sv` / `.svh` under `tools/probe/` — **4086 files, both views, 8172
file-views** — compiled by the pristine and the patched binary TO THE SAME
OUTPUT PATH (a database embeds its `-o` path) and compared by md5 first.  A
file-view whose database MOVED must then pass four independent attributions:

1. its `ct145cen` census must have moved too (a database change with a frozen
   census is a change OUTSIDE the law's objects);
2. `pred145.py`, run on the PRISTINE census ALONE, must NAME a cell for it —
   a HOIST, a WRAPPER or a CANDIDATE;
3. no `ROW=BODY` and no `ROW=LOC` line may APPEAR once the columns this law
   owns are normalised away (`NSTMTS` / `NTOPS` / `BKIND` / `BSPAN` on a body,
   `LHOIST` / `LPAR` on a local, `HID` everywhere), and the census must have
   LOST either a `ROW=STMT` (a hoisted initialiser) or a `ROW=BODY`'s wrapper
   columns (a `begin` that lost its threshold).  `ROW=STMT` is deliberately
   excluded from the APPEARANCE test: when a wrapper `begin` is dropped, the
   SOURCE `begin` underneath becomes the body and ITS statements legitimately
   become top-level ones;
4. **nothing textually new** — with UhdmIds normalised and indentation
   stripped, every line the PATCHED dump gained must already occur SOMEWHERE in
   the PRISTINE dump.  A re-parent (`vpiParent` back to the function) or a
   promoted statement re-prints an identity that existed; a new object cannot.
   This is what makes (3)'s `ROW=STMT` exclusion safe.

A pris/pat rc MISMATCH is itself a breach, except the one direction this law is
expected to change — a pristine rc=139 SEGFAULT that the patch turns into a
clean run, reported as `FIXED-CRASH`.

**RESULT: `LISTED=4086 PROCESSED=4086` (2006 + 2080 over two halves),
`PROCESSED-ASSERT-OK`, `BREACH=0`, `RC-MISMATCH=0`, `BOUNDARY PASS` on both
halves.**  `MOVED=30` file-views plus `FIXED-CRASH=2`, `NORUN=306` (files both
binaries reject or crash on IDENTICALLY — an rc mismatch would have been a
breach).  Every one of the 32 lives in a TF-ITEM arm tree and every one carries
a predicted cell:

| arm tree | file-views moved | what they are |
|---|---|---|
| `r10uvm139repro` | 6 | § `tfItemLocalAutomaticIsNotWrittenStatic139`'s own TF-ITEM grids |
| `r10v139repro` | 12 | its verifier's grids |
| `r10uvm145repro` | 8 + 2 crash-fixed | this pass's arms A-D, and arm E |
| `r10uvm66repro` | 4 | § `declInitWrittenNewNoStmt66`'s `a2_slots` / `a3_count` — the CANDIDATE shape of §4b |

Nothing else in 4086 files moved: `r10uvm71repro` (§ `ctorBodyLocalsNotOnFunc71`),
`r10uvm141repro` (§ `qualLifetimeStubListsNoBodyLocals141`), `r10uvm107repro` /
`r10v107repro`, `r10uvm109repro` / `r10v109repro`, `r10uvm113repro`,
`r10uvm122repro`, `r10uvm142repro` / `r10v142repro`, `r10uvm143repro` /
`r10v143repro`, `r10uvm89repro`, `r10uvm77-79repro`, `r10buvm3-15repro`,
`r10uvm82-91repro`, `r10sd8-12repro` and `r10uvm33repro` (three files all named
`dut.sv`, kept apart by the RELATIVE-path scratch key) are all byte-identical.


The gate carries its own POSITIVE CONTROL: this pass's five arms live under
`tools/probe/r10uvm145repro/` and are in the swept set, so a gate that saw
nothing at all would be a gate that cannot see.  It also earned its keep twice
over — it is what caught the TWO INSTRUMENT BUGS this pass had:

* `pred145.py` originally asked "is the assignment's Lhs IN the owner's
  `Variables` list" and NAMED NOTHING for `r10uvm139repro/g139_b_kinds.sv`
  ELAB, whose database plainly moved.  The reason is that a cloned ELAB listing
  holds different variable objects in its `Variables` vector than in its body,
  so the question was the wrong one; the predicate is now `SLHSVAR` — Surelog's
  OWN declaration test, `any_cast<variables*>(stmt->Lhs())`.  Both predicates
  name the same nine corpus databases and the same 86 cells, so the corpus
  prediction in §6 is unaffected; the arms are where the difference shows.
* `bound145.sh`'s own `PREDICTED-WRAPPERS=` extractor was missing a trailing
  `.*`, so it captured the REST of the summary line and `$(( ))` died on a bare
  word under `set -u` — the gate ate its own run at file 2154 of 4086.  Both are
  fixed in the committed scripts, with the trap written down beside them.
* the gate's own clause "a moved database must have LOST a `ROW=STMT`" was too
  narrow: where § `declInitWrittenNewNoStmt66` had already dropped the
  initialiser, the only thing lost is the WRAPPER and no statement row changes
  at all.  That breach is what sent §4b to Surelog for `a2_slots`'s
  `n24_tfitems` — and golden turned out to agree with the patched output
  exactly.  A gate that had merely been loosened would have learned nothing;
  this one produced a measurement.
