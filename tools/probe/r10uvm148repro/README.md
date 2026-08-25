# r10uvm148 — § `tfItemLocalLosesToPkgVar148` — **A PACKAGE VARIABLE DISPLACES A TF-ITEM BODY LOCAL, AND A BLOCK-ITEM ONE KEEPS ITS BINDING** — uvm145's R0, the SeqDriver ×2 / MiniAmiq ×2 head, **CLEARED**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; `GOLDEN_DEFER` stayed unset; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**; the four slang-fenced tests were
never dispatched and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `ac10a363` (= UVM pass 146) |
| pristine binary | built from a clean worktree at `ac10a363`, frozen `chmod 555` before any sweep; its head log reproduces the brief's head object BYTE FOR BYTE (`head_pris_default_SeqDriver.cmp` is identical to the committed `r10uvm145repro/head_pat_default_SeqDriver.cmp`) |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY — one new predicate, one new parameter on § 81's existing helper, one removed `case` label |
| probe surface | `tools/probe/r10uvm148repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SeqDriver default / testflags** | **62** cmp lines, 1 head | **36**, 1 head — a **NEW** object (§ 8, R0) |
| **MiniAmiq default / testflags** | **62**, 1 head | **36**, 1 head — the same new object |
| SimpleUVM default / testflags | 60, 1 head | 60 — head log **BYTE-IDENTICAL** |
| Scoreboard default | 60, 1 head | 60 — head log **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 174, 1 head | 174 — head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 29 / 50, 1 head | 29 / 50 — head logs **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this worktree's own pristine sweeps (1588 surelog row-modes + 1358 u2r) |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — **exactly the nine PREDICTED BY NAME** from the pristine databases before the patched binary produced anything |
| the law's corpus population | 54 wrong cells in 9 databases | **0** — `WRONG->RIGHT 54`, `RIGHT->WRONG 0`, `AWAY 0`, and every one-sided row-set count UNCHANGED |
| the grid, five arms × two views | 180 wrong binding cells | **0** — `RIGHT->WRONG 0`, `AWAY 0`, `ONLY-GOLDEN 0`, `ONLY-OURS 0` in every arm, every view, every column |
| wide boundary | — | 4181 files × 2 views: **MOVED 5** (this pass's own arms, def view), **BREACH 0**, RC-MISMATCH 0 |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`uvm-1.2 base/uvm_component.svh:3375` — a **PAREN-LESS** out-of-body method, so
the **TF-ITEM** production (§ `blockItems9`):

```systemverilog
function void uvm_component::m_set_cl_verb;      // 3375
  ...
  uvm_root      top;                             // 3384
  uvm_coreservice_t cs;                          // 3385
  cs  = uvm_coreservice_t::get();                // 3386
  top = cs.get_root();                           // 3387
```

62 cmp lines, ONE `^LHS:` (`head_pris_default_SeqDriver.cmp`):

```
LHS (golden)                                  RHS (ours)
class_var: (uvm_pkg::cs), 1731:21-1731:23     class_var: (…m_set_cl_verb::cs), 3385:3-3385:20
|vpiParent: \_package: uvm_pkg                |vpiParent: \_function: …m_set_cl_verb
|vpiName:cs                                   |vpiName:cs
|vpiAutomatic:1                               |vpiAutomatic:1
|vpiVisibility:1                              (absent)
```

The carrier is the `ref_obj (cs)` at **3386:3**, the assignment's `Lhs`, and the
field is its `Actual_group`; both sides are non-null, so this is neither the
vector overload nor a `<null>` singular arm — `variables::Compare` runs and
fails on **`vpiVisibility`** (a field it DOES read; `VpiFullName` it does not —
RESUME.md §9). Read off both `uhdm-dump`s, not assumed.

### Where golden's `uvm_pkg::cs` comes from — and we already emit it

`CompilePackage::collectObjects_` (`src/DesignCompile/CompilePackage.cpp:125`)
walks the package's whole FileContent with FOUR stop points —
`paClass_declaration`, `paFunction_body_declaration`, `paTask_body_declaration`,
`paInterface_class_declaration` — and **`paClass_constructor_declaration` is not
one of them**. So the walk descends into an OUT-OF-BODY constructor and collects
its `paData_declaration` block items as **PACKAGE** data declarations
(`:261`, `compileDataDeclaration(m_package, …)`), which
`ElaborationStep::makeVar_` then makes with
`obj->VpiVisibility(vpiPublicVis)` (`ElaborationStep.cpp:2356-2361`) — the only
writer of that field on a variable, and the reason the package copy carries
`vpiVisibility:1` while a `compileVariable`-made subroutine local carries none.
`function uvm_component::new (string name, uvm_component parent);` @1728
declares `uvm_coreservice_t cs;` @1731, and that is golden's `uvm_pkg::cs`.

**We already emit that package variable, span for span** (`class_var
(uvm_pkg::cs), line:1731:21, endln:1731:23`, `vpiVisibility:1`, parent
`package uvm_pkg` — byte-identical to golden's in both dumps). Only the
BINDING was wrong. This pass adds no object.

---

## 2. THE DECODED LAW

`UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3294`) walks the
reference's `VpiParent` chain OUTWARD and treats two of the scopes it meets in
**opposite** ways:

| scope arm | what it searches | what it does when it binds |
|---|---|---|
| `uhdmbegin` (`:3550-3562`) | the `begin`'s own `Variables()` | **`if (ref->Actual_group()) break;` — the walk STOPS** |
| `uhdmfunction` (`:3369-3428`) / `uhdmtask` (`:3434-3470`) | `Io_decls()` → `Variables()` → `Parameters()` → **`Instance()`'s `Variables()`, guarded by `inst->UhdmType() == uhdmpackage`** | nothing between the blocks — every one is a plain `ref->Actual_group(…)`, so the **LAST WRITER WINS** and the package beats the subroutine's own listings |

That last-writer walk is § `pkgSubRefBindsPkgVarOverFormal81`, which modelled
the **FORMAL** half of it (`Io_decls()`). This pass is the **LOCAL** half of the
same overwrite, and which listing a body local lands on **is the production**
(§ `blockItems9`, § `tfItemLocalInitHoistsNoStatement145`):

* **TF-ITEM** — `compileTfPortDecl` hands its variables straight to
  `func->Variables(results.second)` (`CompileStmt.cpp:2429`) and never to the
  body `begin`. The walk falls THROUGH the `begin` arm, reaches the function,
  binds the local — and the package block overwrites it.
* **BLOCK-ITEM** — the declaration stays a body statement, so the local is
  listed on the body `begin` as well as on the task_func (uvm145's `LOWN=both`
  signature) and the `begin` arm's `break` fires first.

> **§ tfItemLocalLosesToPkgVar148.**  In a subroutine whose `vpiInstance` is a
> PACKAGE, a reference that reached late binding and whose name is listed by
> that package binds the **PACKAGE variable** even when the subroutine has a
> body local of the same name — provided that local is a **TF-ITEM** local
> (listed on the task_func alone).  A **BLOCK-ITEM** body local, and a nested
> `begin`'s own local, keep their binding.

### GOLDEN SAYS IT IN ONE FILE, TWICE, ON ONE NAME

Both cells are in `uvm_component.svh`, both are `cs = uvm_coreservice_t::get();`,
both have `uvm_pkg::cs` in scope:

| body | production | `cs` @lhs binds |
|---|---|---|
| `uvm_component::new` @1728 (PORT-LIST PAREN) | BLOCK-ITEM — `begin` @1728 dual-lists `cs` | **`uvm_pkg::uvm_component::new::cs`** @1731:21 — THE LOCAL |
| `uvm_component::m_set_cl_verb` @3375 (PAREN-LESS) | TF-ITEM — `cs` on the FUNCTION only | **`uvm_pkg::cs`** @1731:21, `vpiVisibility:1` — THE PACKAGE |

### The gates, all § 81's, reused verbatim

* **`subHomeIsPkg81`** — the subroutine must be the package's OWN. SeqDriver
  carries `adpcm_pkg`'s wildcard-import COPY of `m_set_cl_verb`, and in the COPY
  every local survives, in golden and under this law alike.
* **`condPredEarlyBound81`** — a reference compiled with the ENCLOSING
  STATEMENT as `pexpr` binds EARLY through `CompileHelper::bindVariable`
  (`CompileStmt.cpp:3089`) and never enters the pool. **The corpus proves the
  split on ONE name in ONE body**: `top` @3432:14 is an `if` predicate at BODY
  TOP LEVEL and KEEPS THE LOCAL, while `top` @3410:48 is an `if` predicate
  nested inside a `foreach` body and TAKES THE PACKAGE.
* **a BOUND reference only** — the law replaces a binding and never mints one,
  so the deliberately BARE positions are outside it by construction: the
  `hier_path` element `cs` @3387:9 (in `cs.get_root`) and the call receivers
  `clp` @3406:13 and `top` @3439:9 are unbound in golden and stay unbound.

---

## 3. A CORRECTION INSIDE THE SHARED GATE: **`fork` IS NOT A BREAKER**

`condPredEarlyBound81` listed `SyntaxKind::ParallelBlockStatement` among the
statements that break the early bind. **Golden says otherwise, in BOTH halves**,
and arm E measures it:

```
task tf_fork148;  input int seed;  int dogleg; int splay;      // TF-ITEM local
  if (dogleg == 7) splay = 9;          // depth 0        golden -> LOCAL
  fork begin
    if (dogleg == 8) splay = 10;       // under a fork   golden -> LOCAL
  end join
task formal_e148(input int gimbal);    // § 81's own FORMAL population
  if (gimbal == 1) keel = 2;           // depth 0        golden -> FORMAL
  for (…) begin if (gimbal == 3) … end // under a loop   golden -> PACKAGE
  fork begin
    if (gimbal == 4) keel = 5;         // under a fork   golden -> FORMAL
  end join
```

The **pristine** binary already got the FORMAL fork cell wrong (`package` where
golden has `task`) — a pre-existing § 81 residue this pass takes
`WRONG->RIGHT`. The decode came after the measurement:
`CompileStmt.cpp`'s `paSeq_block` (`:335`) and `paPar_block` (`:430`) arms BOTH
run `scope->VpiParent(pstmt);` **before** the loop that compiles their children,
so the parent chain is live and `bindVariable`'s walk reaches the subroutine. A
CONDITIONAL is the opposite: `compileConditionalStmt` (`:1326-1350`) builds the
`if_stmt` / `if_else` and compiles its branches with that object as `pstmt`
while its OWN `VpiParent` is still null, so the walk dies there. That is why one
conditional or loop in the chain breaks the early bind and any number of
`begin`s or `fork`s does not.

**Corpus reach: ZERO.** Every `FORK=1` cell in the shadowed population of all
956 surelog databases is an ARG, a HPATH element or a RECV — never a predicate —
so removing the label cannot move a corpus byte, and the 9 movers' order-blind
dump diffs (§ 6) contain not one line from it.

---

## 4. THE CHANGE

Three edits, `src/ExprEmit.cpp` + `include/UhdmExporter.h`:

1. `UhdmExporter::tfItemBodyLocal148` — the new predicate: `tfBodyTfItems9`
   (§ `blockItems9`'s production selector for the body being emitted) **and**
   the symbol is a `SymbolKind::Variable` whose parent scope IS the current
   `SubroutineSymbol` (slang puts a subroutine's top-level body declarations in
   the subroutine's own scope — which is why `TaskFuncEmit` collects them with
   `sub.members()` — while a nested `begin`'s locals live in a
   `StatementBlockSymbol`) **and** it is not the return-value variable
   (lateBinding's `uhdmfunction` arm tests `parent->VpiName() == name` FIRST and
   `break`s, so a read of the function's own name never reaches the package
   block).
2. `pkgVarOverFormal81` takes that flag and widens its accepted displaced
   binding from `uhdmio_decl` alone to "`io_decl` **or** a TF-ITEM body local".
   The `!bound` guard is untouched, which is what keeps every unbound reference
   out of the law.
3. `SyntaxKind::ParallelBlockStatement` leaves `condPredEarlyBound81`'s breaker
   list (§ 3).

**THE ELABORATED VIEW IS OUTSIDE THE LAW, AND THAT IS MEASURED, NOT ASSUMED.**
Under `-elabuhdm` golden binds the LOCAL on every one of these cells — the
elaborator resolves the reference before `lateBinding` runs, and its first line
is `if (ref->Actual_group()) continue;`. Both our binaries already agree there
(§ 81's formal half does not fire in the elab view either — landed behaviour
this law inherits), so **all five arms' ELAB views are byte-identical
pristine→patched** and score `RIGHT->RIGHT` on every column. The corpus
population is entirely DEF-view: SeqDriver's own `cmds.txt` carries no
`--elabuhdm` in either mode.

---

## 5. THE GRIDS (`arms148.sh` + `ct148cen` + `score148.py` — `ARMS.txt`)

Five arms, each run under Surelog (golden), the pristine and the patched binary,
in the def and elab views — `LISTED=5 PROCESSED=5 PROCESSED-ASSERT-OK`, every rc
recorded.

| arm | grid |
|---|---|
| `g148_a_prod.sv` | **productions × reference roles**: paren-less function / paren function / task with body io / ANSI task, each reading the same shadowed names as lvalue, rhs read, user-call argument, system-call argument, top-level predicate, loop-nested predicate, method receiver and select index; plus a local with NO package twin |
| `g148_b_scope.sv` | **shadowing scopes**: package variable / class property / `$unit` variable / module variable / none, against an in-body method, an out-of-body method, a package free function and a module function and task |
| `g148_c_home.sv` | **homes**: package free function and task, in-body class method, out-of-body class method AND task, class constructor, module function and task, program, interface — plus a SECOND package that WILDCARD-IMPORTS the first (the copy vs the original) and two instances of the same module |
| `g148_d_kind.sv` | **kinds × lifetimes**: class handle, int, string, packed bit, real, enum, logic vector; written `static` / `automatic` / neither; both productions; and a function whose own NAME is a package variable name |
| `g148_e_early.sv` | **the early-bound ladder**: predicate at depth 0, under one `begin`, under two, under `for`, under `while`, under an `else`, under a `fork`; a `case` condition; a `while` condition; a nested named `begin`'s own local; the FORMAL twin of the whole ladder |

Cells are joined as MULTISETS on the ID-FREE key `HSPAN+RSPAN+RNAME`; the
DEF/ELAB view and the design listing are deliberately out of the key. Spans
appear ONLY in keys, never as scored columns. `BOWN` and `BSPAN` are diagnostic
only — the DEF and ELAB listings of one package subroutine spell the owner's
NAME differently, so only the scope KIND (`BSK`) is scored.

**RESULT — `RIGHT->WRONG` 0, `AWAY` 0, `ONLY-GOLDEN` 0, `ONLY-OURS` 0 and
ROWSETS 0/0 in every arm, every view, every column.**

| arm | def `BSK`/`BVIS` | elab |
|---|---|---|
| a | RIGHT->RIGHT 60, **WRONG->RIGHT 44** | 260 RIGHT->RIGHT (byte-identical database) |
| b | RIGHT->RIGHT 8, **WRONG->RIGHT 16** | 60 RIGHT->RIGHT |
| c | RIGHT->RIGHT 34, **WRONG->RIGHT 28**, WRONG->WRONG 2 (R2) | 142 RIGHT->RIGHT |
| d | RIGHT->RIGHT 50, **WRONG->RIGHT 46** | 240 RIGHT->RIGHT |
| e | RIGHT->RIGHT 42, **WRONG->RIGHT 46** | 220 RIGHT->RIGHT |

The fences that must NOT move, and did not:

* a **CLASS PROPERTY** shadow (`clsside148` read from an out-of-body method)
  keeps the LOCAL in golden and in both our binaries;
* an **IN-BODY class method** binds NOTHING at all on either side
  (§ `pkgVarBindsOnlyThroughInstance88`);
* a **MODULE** variable never displaces anything — `modfn_c148` / `modtk_c148`
  keep their locals in golden and in both binaries, in the DEF view, scored
  through the census's `APKGV` column (the def-view `module_inst` carries no
  `Variables` vector at all, so `MODV` alone could not have seen them);
* the **WILDCARD-IMPORT COPY**: for `freefn_c148` golden holds FOUR listings
  under one key — 2 `package` (the owner's) and 2 `function` (the importer's
  copy) — and the patched database holds exactly that, `2 + 2`;
* a **BLOCK-ITEM** body local and a **nested `begin`**'s local never move.

---

## 6. THE A-PRIORI PREDICTION (`PREDICTION.txt`, `predsweep148.sh`, `pred148.py`)

`ct148cen` was run over **all 956 surelog databases and all 1358 uhdm2rtlil
databases of the PRISTINE sweep** (`LISTED=956 PROCESSED=956 NONZERO_RC=0`;
`LISTED=1358 PROCESSED=1358 NONZERO_RC=0`) and the mover set was named BEFORE
the patched binary existed:

```
surelog     9 databases, 136 TF-ITEM candidate cells (+144 fork candidates)
            SeqDriver df+tf, MiniAmiq df+tf, SimpleUVM df+tf,
            BuildUVMPkg df+tf, Scoreboard df
uhdm2rtlil  0 databases, 0 cells
```

The predicate is read off the PRISTINE database alone: `PROD=TFITEM` and
`LOC=FUNC` (a body local listed on the task_func and NOT on the body `begin` —
uvm145's `LOWN` signature, which separates the two Surelog productions without
looking at the source) and `PKGV=1` (the home package lists the same name) and
the reference is BOUND to that local. It is an UPPER BOUND, because
`condPredEarlyBound81` is a SYNTAX test no database can answer.

**MEASURED: MOVERS 9 / 956 and 0 / 1358 — exactly the nine, by name.**

Attribution, order-blind (path-normalised, `id:` normalised, SORTED dumps —
`MOVERS.txt`): **every one of the nine moved by exactly 12 lines**, six `<` and
six `>`, and every line is a `vpiActual` of a `cs` or `top` reference inside
`uvm_component::m_set_cl_verb`:

```
4 <  \_class_var: (uvm_pkg::uvm_component::m_set_cl_verb::top), 3384:3-3384:11
4 >  \_class_var: (uvm_pkg::top),                               1730:12-1730:15
2 <  \_class_var: (uvm_pkg::uvm_component::m_set_cl_verb::cs),  3385:3-3385:20
2 >  \_class_var: (uvm_pkg::cs),                                1731:21-1731:23
```

(BuildUVMPkg is the 1800.2 `pp_output` and names the same objects at
`39600`/`39601` and `41173`/`41174`.) Nothing else moved in any of the nine.
**Scoreboard/default is the ~50/50 COIN** (RESUME.md §9) and is attributed this
way and no other; its 12 lines are the law's 12 lines.

### The corpus census, golden vs pristine vs patched (`CENSUS.txt`)

Per database, over 845–1196 scored reference cells:

```
BSK   WRONG->RIGHT 6   RIGHT->WRONG 0   AWAY 0     (× 9 databases = 54 cells)
BVIS  WRONG->RIGHT 6   RIGHT->WRONG 0   AWAY 0
ROLE / PROD / LOC / BKIND   RIGHT->RIGHT, unchanged
ROWSETS  ONLY-GOLDEN and ONLY-OURS IDENTICAL pristine -> patched
```

and the whole TF-ITEM face of SeqDriver/default now reads:

```
golden    18 function/vis0    6 package/vis1    8 unbound
pristine  24 function/vis0    0                 8 unbound
patched   18 function/vis0    6 package/vis1    8 unbound   <- golden, exactly
```

---

## 7. GATES (all green — `GATES.txt`)

Both binaries were built in THIS worktree at base `ac10a363`, frozen
`chmod 555` at immutable paths before any sweep, and every `cmds.txt` was
audited by binary PATH (the single value found across all sweep directories was
the intended frozen binary — never the main-tree one, which
`verify_golden.py` and `check_goldens.sh` silently default to).

| gate | result |
|---|---|
| (1) build both, `-j 2` | pristine and patched both `Built target slang_uhdm`, 0 errors |
| (2) `tests/check_goldens.sh` (`SLANG_UHDM` exported per binary) | **PASS=23 FAIL=0** for each; negative control `SLANG_UHDM=/bin/false` **FAIL=23 PASS=0** |
| (3) uhdm2rtlil both modes | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2**, identical to pristine in both modes; `ct8rows` vs `results/gate_uhdm2rtlil.csv` **PASS**, vs this worktree's own pristine testflags AND default csv **PASS** — 0 differing rows, status AND dump column |
| (4) surelog `--mode both` | histograms **byte-identical to pristine** (default 471/283/25/10/5; testflags 466/284/23/9/5/3/2/1/1); `ct8rows` vs `results/golden_surelog.csv` **PASS** and vs this worktree's own pristine csv **PASS** — **0 differing rows over 1588**, and **NO row was converted** (`results/*.csv` were never written) |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358**; surelog **MOVERS 9 / 956**; `PATH_SETS_IDENTICAL` on both (SELFCHECK 1357/1358 and 955/956 flagged) |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, u2r **ok=8 changed=0**; `ctcan2.sh` **PASS** on both; `canaudit.sh canaries.sh ctcan2.sh` **PASS, audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr **byte-identical**; SVSwitch **4842211c4030**; YosysVerx **6ccda350c24a** |
| wide boundary (`BOUNDARY.txt`) | 4181 files × 2 views, two halves: `MOVED=5 BREACH=0 RC-MISMATCH=0` — the five are this pass's OWN arms in the DEF view; **not one arm of any earlier pass moved a byte**. `CTRL=1` positive control on those arms: **POSITIVE-CONTROL-OK** |

The boundary gate convicts on four independent counts: the census must move
with the database; `pred148.py` must NAME a cell for that file and view from the
PRISTINE census alone; the census ROW SET and every non-binding column
(`ROLE`/`PROD`/`LOC`/`PKGV`/`CLSV`/`MODV`/`APKGV`/`FORK`) must be frozen; and
every moved binding must move between a subroutine listing and a PACKAGE
listing — `function|task -> package` always, `package -> function|task` only on
a `FORK=1` row (`bindmoves148.py`).

---

## 8. HEADS BEFORE → AFTER, AND R0

`rowheads.sh` on this worktree's own pristine and patched sweep workdirs, same
instrument both times; counts are DEPTH, not distance.

| row | before | after |
|---|---|---|
| **SeqDriver default / testflags** | **62 / 62** | **36 / 36** |
| **MiniAmiq default / testflags** | **62 / 62** | **36 / 36** |
| SimpleUVM default / testflags | 60 / 60 | 60 / 60 (byte-identical head log) |
| Scoreboard default | 60 | 60 (byte-identical) |
| BuildUVMPkg default / testflags | 174 / 174 | 174 / 174 (byte-identical) |
| Earlgrey_0_1 default / testflags | 29 / 50 | 29 / 50 (byte-identical) |
| Rggen default | 0 | 0 |

(`Scoreboard/testflags` is `SLANG_REJECT` and `Rggen/testflags` has no golden —
both print SKIP-NOFILE and are COUNTED, never read as perfection.)

**R0 — THE NEXT HEAD.** SeqDriver ×2 and MiniAmiq ×2, **36 cmp lines, ONE
`^LHS:`**, the same object on all four rows — the `with`-clause array method at
`uvm_component.svh:3436`:

```systemverilog
m_time_settings.sort() with ( item.offset );          // 3436, inside a fork begin
```

```
LHS (golden)                                  RHS (ours)
func_call: (m_time_settings) @3436:9-3436:52  method_func_call: (sort) @3436:25-3436:29
|vpiParent: \_if_stmt @3435:7-3436:53         |vpiParent: \_if_stmt @3435:7-3436:53
|vpiName:m_time_settings                      |vpiName:sort
                                              |vpiPrefix: \_ref_obj (…::m_time_settings)
```

Golden models the whole `<queue>.sort() with (…)` as a **`func_call` named after
the QUEUE**, spanning the entire call INCLUDING the `with` clause, and carries
no prefix and no arguments at all; we model it as a `method_func_call` named
`sort` with the queue as `vpiPrefix`. `if_stmt::Compare` reaches it through
`VpiStmt`, and `BaseClass::Compare`'s type test fails first (different
`UhdmType`), which is why both sides print in full. See
`head_pat_default_SeqDriver.cmp`.

---

## 9. RESIDUES

* **R1 — the fork-nested predicate is now right, the rest of the ladder was
  already right.** No residue; recorded because § 81's arms did not cover it.
* **R2 — a PROGRAM's subroutine binds nothing in golden.** Arm C
  `homeprog148::progfn_c148` @96:5 and @97:21: golden leaves the reference BARE,
  we bind the program-function's own local. `WRONG->WRONG` on `BKIND`/`BSK`,
  unmoved by this pass (2 cells, def view only). A different law — the program
  scope's late-binding pool — and corpus incidence is zero within this
  population.
* **R3 — `$unit` shadowing was measured and is empty.** Arm B declares
  `int dunnage148;` at `$unit` scope and a package function local of the same
  name; Surelog's database carries no `$unit` variable for the walk to find, so
  the local wins on both sides and no cell exists to score. Recorded so the
  brief's fifth scope is not left unmeasured.
* **R4 — the ELAB view is a different regime.** Golden's elaborator binds these
  references before `lateBinding` runs, so the package never displaces anything
  there. Both halves of § 81/§ 148 are DEF-view laws. If a corpus row ever
  arrives with `-elabuhdm` AND this shape, it is already correct and must stay
  so — the arms' elab views are the regression test.
* **R5 — no helper extraction.** `pkgVarOverFormal81` now carries two callers'
  worth of meaning in one flag; per the campaign's no-premature-extraction rule
  it stays as it is until 0 DIFF / 0 CMP_ONLY.
