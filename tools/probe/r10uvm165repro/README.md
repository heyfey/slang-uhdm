# r10uvm165 — § `droppedCallArgTakesTheOrdinaryWindow165` — **A DROPPED CALL'S ARGUMENTS BIND EXACTLY WHERE A VALID CALL'S ARGUMENTS BIND** — the BuildUVMPkg ×2 29-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b9d5c606` |
| pristine binary | md5 `ac0350d07c685ac10b106abce26ec554`, built from this pass's own worktree at a clean `b9d5c606` and frozen `chmod 555` before any sweep |
| patched binary | md5 `8bac95ba55a581dfcc3c903251686479`, frozen `chmod 555`. The patch applied to a **FRESH `b9d5c606` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on |
| production surface | `src/StmtEmit.cpp` (two gates, 24 inserted lines / 2 changed), `include/UhdmExporter.h` (the law, 72 lines of comment, no code) |
| probe surface | `tools/probe/r10uvm165repro/` only |

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **BuildUVMPkg default and testflags, 29 cmp lines, ONE head each, the two logs BYTE-IDENTICAL** → **60 cmp lines, ONE head, a DIFFERENT OBJECT** (§9). A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7). |
| corpus rows changed | **0** — both corpora, both modes. Status histograms IDENTICAL to this pass's own pristine sweep, cell for cell. |
| byte movers | **3 / 956** surelog — **two PREDICTED BY NAME from the pristine databases before the patched sweep ran**, the third the known Scoreboard/default COIN (its order-blind sorted-dump diff is **0 lines**) — and **0 / 1358** uhdm2rtlil, also predicted. |
| the corpus cell | ONE. Each moved database's order-blind, indent-blind dump diff is **exactly two lines**, both REMOVED: `\_io_decl: (alias_name), line:14091:46` and its `\|vpiActual:`. |
| the corpus census | REF distance to golden **2532 → 2530** on both BuildUVMPkg rows; **TYP / VAR / CNT / OBJ move 0 lines** — nothing created, destroyed, re-typed or re-listed. |
| the ARG census, nine UVM DBs × both modes | golden-vs-ours disagreeing call-argument cells **320 → 318**; the two that go are the head, once per mode; **0 introduced**. |
| the grid (4 arms, both views) | **56 cells moved, 53 TOWARD, 0 AWAY, 0 MOVED-WRONG**; 3 SIDEWAYS whose distance to golden is measured UNCHANGED (§6). |
| the WIDE boundary (4678 arms, both views) | **MOVED_ARMS 4, RC_DIFFS 0** — three are this pass's own arms (the positive control); the fourth is `r10uvm59repro/a1_witness.sv`, r10uvm59's own reduction of this very statement, **2 cells, both TOWARD**. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this worktree's own pristine sweep reproduced the brief
exactly — **BuildUVMPkg default and testflags, 29 cmp lines, 1 head each,
`head_pris_BuildUVMPkg.{default,testflags}.cmp` byte-identical to each other**:

```
LHS: <null>
RHS:
decompile:
io_decl: (alias_name), id:86640, line:14091:46, endln:14091:56
|vpiParent:
\_function: (uvm_pkg::uvm_registry_common::set_type_alias), id:86639, line:14091:3
|vpiDirection:1
|vpiName:alias_name
```

`LHS: <null>` with a full RHS is `BaseClass.h`'s **SINGULAR** `SafeCompare`
(`:191-193`) — the MIRROR form — so the object the judge stopped on lives in
OUR database. `ct165own.cpp` (r10uvm164's mirror owner-finder, `GetByVpiType`,
the generated kind-agnostic edge accessor, so no field is named by hand) scans
every edge of OURS that lands on the head and prints golden's same edge:

```
MIRROR REFERENCE SCAN — every edge of OURS that lands on the head, and golden's:
  ours   function(set_type_alias)@14091:3
      edge vpiType=28 (vector index 0)
      golden function(set_type_alias)… -> vector size 1, [0] = io_decl(alias_name)  SAME
  ours   ref_obj(alias_name)@14092:32
      edge vpiType=700 (singular)
      golden ref_obj(alias_name)@14092:32 -> singular io_decl(alias_name)           SAME
  ours   ref_obj(alias_name)@14098:35
      edge vpiType=700 (singular)
      golden NO COUNTERPART for the referrer                       <<<< THE EDGE
  ours   ref_typespec()
      edge vpiType=81 (singular)
      golden ref_typespec() -> singular io_decl(alias_name)                          SAME
```

Four edges land on the head; three agree. The failing one is **`vpiActual`
(700) of the `ref_obj alias_name` at `14098:35`** — golden has no `vpiActual`
there at all, and `ct165cen` says so on both sides:

```
golden  CAS|G|CTX=arg|CAST=none|HOME=function@class_defn|ref_obj|alias_name|14092:32|BOUND
golden  CAS|G|CTX=arg|CAST=none|HOME=function@class_defn|ref_obj|alias_name|14098:35|BARE
ours    CAS|O|…|alias_name|14092:32|BOUND
ours    CAS|O|…|alias_name|14098:35|BOUND          <<<< WE OVER-BIND
```

The source — `uvm_registry.svh:594-603`, flattened into `uvm_pkg.sv` at
`14091-14100`:

```systemverilog
14091:  static function void set_type_alias(string alias_name);
14092:     m__type_aliases.push_back(alias_name);                     // golden BINDS
14093:     m__type_aliases.sort();
14094:     if (uvm_pkg::get_core_state() != UVM_CORE_UNINITIALIZED) begin
14095:        uvm_factory factory = uvm_factory::get();
14096:        Tregistry rgtry = Tregistry::get();
14097:        if (factory.is_type_registered(rgtry)) begin
14098:           factory.set_type_alias(alias_name,rgtry);            // golden BARE
```

---

## 2. THE BRIEF'S FRAMING IS REFUTED BY MEASUREMENT — THERE IS NO MISSING WINDOW

The brief read this head as a **bind window** that closes at `14098` and not at
`14092`, and asked which of the two differences carries the rule — the
RECEIVER'S KIND (a class property at `:14092`, a local handle at `:14098`) or
the STATEMENT'S NESTING (top level vs two `if` bodies down). **Neither: the
ordinary path is already exact on both axes, and this cell never went through
it.**

`g165_a_sep.sv` is the separator arm the brief asked for, and it is the whole
refutation. One in-body class method holds the SAME call, with the SAME formal
as its bare argument, at every crossing of receiver kind × depth: a class
property through a BUILT-IN method (`push_back`/`push_front`), a LOCAL handle,
a class-PROPERTY handle, a STATIC path (`Cls::meth`), an INSTANCE property, a
BLOCK-local handle and `this.`, each at depth 0, 1 and 2; plus the non-static
twin. Against its own Surelog golden, in both views:

> **`uhdm-cmp` reads 0 lines / 0 heads for arm A under the PRISTINE binary and
> under the PATCHED binary alike. The arm does not move in the wide boundary
> gate either.**

Golden's own answer, read off that arm: the discriminator is **DEPTH, and only
depth** (§ `controlBodyNoBind28`, already decoded and already implemented) —

```
   a01 28:27 push_back on a class property   d0  BOUND      a11 36:30  d1  BARE
   a02 29:20 stamp on a LOCAL handle         d0  BOUND      a12 37:23  d1  BARE
   a03 30:24 stamp on a PROPERTY handle      d0  BOUND      a13 38:27  d1  BARE
   a05 32:28 push_front on a class property  d0  BOUND      a21 46:33  d2  BARE
   a31 61:27 push_back on an INSTANCE prop   d0  BOUND      a22 47:26  d2  BARE
   a32 62:24 stamp on an INSTANCE property   d0  BOUND      a23 48:26  d2  BARE
   a34 64:21 stamp on a LOCAL handle         d0  BOUND      a24 49:30  d2  BARE
   a33 63:29 through `this.`                 d0  BARE       a41-a44    d1  BARE
```

— independently of the receiver, with `this.<prop>.m(x)` bare even at depth 0
because it is a `hier_path` (§ 5's own rule). The three STATIC-PATH cells
(a04/a14/a25, `Ledger165::brand(mark)`) carry no argument cell at all on either
side: both producers collapse a `::`-qualified call to a bare `ref_obj` named
`Ledger165::brand` and drop the actual, at every depth. **Our emitter
reproduces all of it, cell for cell.** So the head is not a window our emitter
lacks.

### WHAT IT ACTUALLY IS

`uvm_registry_common` is a **PARAMETERIZED** class whose `Tregistry` defaults
to `int`, so in the DEFAULT SPECIALIZATION `factory.set_type_alias(alias_name,
rgtry)` hands an `int` where `uvm_factory::set_type_alias` wants a
`uvm_object_wrapper`. slang **rejects the statement** (diagnostics are
suppressed inside a generic class body, which is why the file still compiles at
all) and hands back a `StatementKind::Invalid`. § `droppedCall14`'s
re-emitter — `emitDroppedCall14`, `StmtEmit.cpp` — rebuilds the call from the
SYNTAX, and its statement-position arm ends with

```cpp
args->push_back(emitDroppedArg14(…, mfc, prefix, netMap, /*bind=*/true));
```

whose bind is `currentSubSym->find(name)` + `netMap` lookup, **with no gate of
any kind**. Its own comment names the window it means to reproduce — *"the same
`ClassArgBind12` window a valid class-method call opens"* — and that window is
**TOP-LEVEL ONLY**: § `controlBodyNoBind28` shuts it for an in-body class
method inside any conditional or loop body. The re-emitter reproduced the
window's ADD and not its DEPTH gate.

The sharpest single control is `g165_b_home.sv` **h13** — `pelt.keep(tag_nm)`,
a WELL-TYPED call written in the very same `if` body as the dropped one:
**golden BARE, pristine BARE, patched BARE.** The valid path was never wrong
here. Only the recovery path was.

**Surelog never learns that slang rejected anything.** It compiles the
statement like any other, so the golden value of this argument is
§ `classArgBind12`'s and § `controlBodyNoBind28`'s, verbatim — the same two
laws, already decoded from `CompileHelper::bindVariable`
(`CompileStmt.cpp:3089-3149`, which walks the `pexpr`'s `VpiParent` chain, and
`compileConditionalStmt`'s `CompileStmt.cpp:1321`, which compiles an `if` arm
with a parent that is still null).

---

## 3. THE LAW

> **§ `droppedCallArgTakesTheOrdinaryWindow165`** — *a DROPPED call's arguments
> bind exactly where a VALID call's arguments bind, and nowhere else. The gate
> is § `controlBodyNoBind28`'s own, verbatim:*
> `curSubClassScope9 && !curSubOob9 && ctrlBodyDepth28 > 0` → **no bind**.

DIRECTION: **SUPPRESS** (remove a `vpiActual` we minted). No object is created,
destroyed or reshaped; the OBJ / VAR / CNT / TYP census families move 0 lines
everywhere.

Each conjunct is a measured cell that fails without it (`g165_b_home.sv`, DEF
view, ONE Surelog golden, both binaries):

* **`ctrlBodyDepth28 > 0`** — h01 (depth 0, formal) is golden-BOUND and stays
  BOUND; h14 (depth 2, the corpus shape) is golden-BARE and moves. A plain
  `begin` (h07), a NAMED block (h21) and a `fork` arm (h22) raise no depth and
  keep binding, exactly as golden has them.
* **`!curSubOob9`** — h61/h62, an OUT-OF-BODY definition of the same method:
  golden **BINDS at depth 0 AND at depth 1**, on both binaries. *A depth-only
  gate would have taken h62 AWAY.*
* **`curSubClassScope9`** — § 28's own home test. A dropped call can only arise
  where slang suppresses its diagnostics, i.e. inside a generic class body, so
  this conjunct is **inert** and is written for exactness with the law it
  mirrors rather than for a cell of its own. It is named as inert here rather
  than presented as if a cell forced it.

**No extra term is invented.** A `$unit`-scope generic class needs none: arm C
u01/u02 (depth 0) are golden-BOUND and stay bound, u03 (depth 1) is golden-BARE
and moves — `unitSubNoBind9` has no cell here. § 57's same-depth unnamed-block
carve-out is not reproduced at this position, and the VERIFIER measured exactly
why (r10v165repro, arm `v165_b_shadow.sv`, corrected from this pass's own first
wording): the bind is `currentSubSym->find`, which resolves in the SUBROUTINE's
scope, so a block local golden binds is normally invisible to it (b_blk d1 and
b_blk0 d0: golden BOUND, both binaries BARE — R-blklocal, a residue neither
binary owns). It is NOT true that `find` never reaches a block-local NAME: when
the block local SHADOWS a formal (`s_shad` / `s_shad2`), `find` succeeds and
returns the FORMAL, so the pristine binary emitted a `vpiActual` there —
pointing at the formal's `io_decl` while golden points at the block's
`string_var`. The pristine cell was therefore already WRONG, not right, and the
patch replaces one wrong value with a missing one (SIDEWAYS on the judge, never
AWAY). See `tools/probe/r10v165repro/README.md` § `shadowedBlockLocal165v`.

**There is no symbol half, and that is measured.** A class PROPERTY (arm C
f05/f15), a PACKAGE variable (f06/f16), a class PARAMETER (f09) and a DOTTED
PAIR `a.b` (f07/f08/f17) are golden-BARE and were ALREADY bare in the pristine
binary — `emitDroppedArg14` never bound them. A conjunct with no cell behind it
would be a hedge, so there is none.

---

## 4. THE CHANGE

`include/UhdmExporter.h` — the law, its Surelog citations, the gate, the corpus
head and every measured arm cell (72 lines of comment, no code).

`src/StmtEmit.cpp` — the same three lines at **two** sites, because there are
two re-emitters of the SAME statement object and they owe the same gate:

```cpp
const bool argBind165 =
    !(curSubClassScope9 && !curSubOob9 && ctrlBodyDepth28 > 0);
…  emitDroppedArg14(…, mfc, prefix, netMap, /*bind=*/argBind165)
```

1. `emitDroppedCall14`'s **statement-position** arm — § `droppedCall14` itself;
2. `emitDroppedIdxCall26`'s statement-position arm — § `droppedIdxRecvCall26`,
   the SUBSCRIPTED-receiver spelling of the same object (its own comment: *"this
   is § droppedCall14's statement object with the BASE as the prefix"*). It has
   its own cell: `g165_d_notmove.sv` **n11** `m_bank[cog].absent(tag_nm)` at
   depth 0 is golden-BOUND and stays BOUND, **n12** at depth 1 is golden-BARE
   and moves. Fixing one and not the other would have left the sibling wrong.

The **EXPRESSION-position** arms of both (`bind = false`) are untouched, and
that is measured: arm C f21/f22/f23 (assignment RHS, `if` condition) and
f41/f42 (return operand) are BARE on both sides before and after.

**`src/` moves by 24 inserted lines and 2 deleted — the two `/*bind=*/true`
argument lines. `include/` gains 72 comment lines and no code.**

---

## 5. THE PREDICTION, MADE FROM PRISTINE DATABASES BEFORE ANY PATCHED ONE EXISTED

`ct165pred.cpp` reads ONE **PRISTINE** database and names every cell the law
can move. Its six conditions are read off the database itself: a BOUND
reference; a DIRECT element of a `method_func_call`'s `Tf_call_args`
(§ `droppedCall14` accepts only plain identifiers and plain dotted pairs as
actuals, so its refs are never nested in an operation); that call in STATEMENT
position (its `VpiParent` holds statements); an enclosing subroutine that is an
IN-BODY class method (its own span inside its class's span); CONTROL-BODY DEPTH
> 0 counted on the parent chain, with `begin` / `named_begin` / `fork`
deliberately NOT counted; and an ACTUAL listed **directly** on that subroutine
(`Io_decls()` / `Variables()`, by POINTER) — which is exactly what
`currentSubSym->find` can reach, and what makes the prediction EXACT rather
than an upper bound: the ordinary path's own gate leaves no other way for a
call argument to be BOUND at depth > 0 in an in-body class method.

```
surelog     -- databases=956   rows-with-cells=11  restore-fail=0
            -- PRED cells: 2   INERT-OOB: 24687  INERT-D0: 6222  INERT-BLK: 335
            -- MOVER ROW: default/BuildUVMPkg-bf853d43
            -- MOVER ROW: testflags/BuildUVMPkg-bf853d43
uhdm2rtlil  -- databases=1358  rows-with-cells=0   restore-fail=0
            -- PRED cells: 0
```

**THE OUTCOME:** `byteverify` reported **exactly those two rows** plus the
Scoreboard coin, and **0 / 1358** on uhdm2rtlil. No unpredicted mover in either
corpus.

The three INERT buckets are worth their own line, because they are the cells an
un-discriminating gate would have taken AWAY:

* **INERT-D0, 6222 cells** — call arguments bound at depth 0. That is
  § `droppedCall14`'s own documented population (the 133 SeqDriver
  `UVM_*_IMP` macro bodies whose whole body is one `imp.method(arg);`) plus
  every valid call's top-level argument. Golden binds them; they do not move.
* **INERT-OOB, 24687 cells** — bound arguments at depth > 0 whose subroutine is
  not an in-body class method: package free functions, module functions,
  processes, and OUT-OF-BODY class methods. Golden binds all of them
  (arm B h61/h62 measures the out-of-body half directly); the `!curSubOob9` and
  `curSubClassScope9` conjuncts leave every one untouched.
* **INERT-BLK, 335 cells** — the actual is not listed directly on the
  subroutine (§ 57's unnamed-block carve-out and the like); unreachable from
  this position and unmoved.

---

## 6. THE GRID — 4 ARMS, BOTH VIEWS, ONE SURELOG GOLDEN EACH

`grid165.sh` builds each arm with Surelog and with BOTH binaries in the `def`
and `elab` views, echoing every command WITH ITS BINARY PATH into `cmds.txt`
and recording every rc (an rc=139 segfault must never read as a result;
there are none — every rc is 0). `ct165cen` censuses six families: REF (every
reference and the `vpiActual` it carries, keyed by the FULL parent chain), TYP,
VAR, CNT, OBJ — reproduced from r10v161's verifier so the must-not-move check
is the same one — and this pass's own **ARG** (POSITION × RECEIVER × DEPTH ×
HOME). `score165.py` joins them **as multisets**.

| arm | what it measures | REF golden vs PRISTINE (def) | REF golden vs PATCHED (def) | cells moved (def) |
|---|---|---|---|---|
| **A** `g165_a_sep.sv` | THE SEPARATOR: one in-body class method, the SAME call with the SAME formal, over receiver kinds (built-in on a class property, local handle, property handle, static path, instance property, block local, `this.`) × depths 0/1/2, static and non-static | `uhdm-cmp` **0 lines / 0 heads** | **0 / 0** | **0** |
| **B** `g165_b_home.sv` | the HOME and POSITION matrix for a DROPPED call: static method, non-static method, task, constructor, OUT-OF-BODY definition, module-homed class; depth 0 / plain begin / named block / fork arm / if / else / nested if / while / for / case item / repeat | REF 33 | REF **9** | **12 cells, all TOWARD** |
| **C** `g165_c_forms.sv` | the ARGUMENT FORMS (bare formal, second formal, body local, two formals in one call, class property, package variable, class parameter, dotted pair) at depth 0 and depth 1; the `$unit` generic class; the EXPRESSION-position and RETURN-position twins; the corpus statement in miniature | REF 14 | REF **0** | **7 cells, all TOWARD** |
| **D** `g165_d_notmove.sv` | the MUST-STAY matrix: § `droppedCall14`'s own population (a whole body that is one dropped call), every transparent carrier at depth 0, § `droppedIdxRecvCall26`'s SUBSCRIPTED receiver at depth 0 and 1, and every control carrier at depth 1 (if / else / while / do-while / repeat / for / foreach / case item), each without a `begin` | REF 22 | REF **4** | **9 cells, all TOWARD** |

**56 cells moved across the four arms and both views; 53 TOWARD; AWAY 0;
MOVED-WRONG 0; NO-GOLDEN 0.** The `VAR`, `CNT`, `OBJ` and `TYP` families are
**0 lines moved on every arm in both views**.

**THE 3 SIDEWAYS CELLS, named and measured.** In the ELAB view of a package our
database holds the generic class body TWICE at the same span with the same
parent chain where golden holds it once (a PRE-EXISTING ONLY-OURS duplicate).
On three such keys the patch turns one of our two copies BARE, so the key's
value multiset changes without matching golden's. `score165.py` prints the
per-key distance for exactly this reason, and it is **unchanged**:

```
elab SIDEWAYS ref_obj|tag_nm|78:25|…/function:meth/class_defn:InBody165/…
     G={BOUND:1}  pris={BOUND:2}  pat={BARE:1, BOUND:1}   dist pris=1 pat=1
```

Two on arm B (78:25, 84:25), one on arm D (31:31). Each arm's ELAB distance to
golden nonetheless **falls**: arm B 95 → 75, arm C 36 → 22, arm D 56 → 40.

**THE TWO ARMS WHOSE def cmp LINE COUNT RISES (29 → 102)** — arms B and D. The
PRISTINE head on both is this pass's own over-bind (`LHS: <null> / RHS:
io_decl(tag_nm)`) and it is GONE; the NEW head is a NAMED-BLOCK PREFIX residue
of a different law (`named_begin (…::run::hnb165)` / `(…::carriers::nblk165)`),
and it is PRE-EXISTING: the ONLY difference between the pristine and the
patched database of either arm is the removal of `vpiActual` edges (24 and 18
dump lines, order-blind and indent-blind, ALL of them removals), so those
`named_begin` objects are byte-identical under both binaries. Arm C is the arm
that CLEARS: def 29 / 1 head → **0 / 0**.

---

## 7. THE CORPUS CENSUS

`CENSUS.r10uvm165.txt` — the two moved databases, five families, multiset
distance to golden:

| family | golden-vs-PRISTINE | golden-vs-PATCHED | PRISTINE-vs-PATCHED |
|---|---|---|---|
| REF | 2532 | **2530** | **2** |
| TYP | 1292 | 1292 | 0 |
| VAR | 266 | 266 | 0 |
| CNT | 88 | 88 | 0 |
| OBJ | 19729 | 19729 | 0 |

identical on `default` and on `testflags`. REF moves by exactly 2 multiset
lines (the wrong value out, the right value in) = **ONE cell, TOWARD**.

`ARGCENSUS.r10uvm165.txt` — the wide one the brief asked for: **every call
argument in the nine UVM databases × both modes** (BuildUVMPkg / MiniAmiq /
SeqDriver / SimpleUVM × default and testflags, plus Scoreboard/default;
Scoreboard/testflags is `SLANG_REJECT` and has no database — `census165.sh`
prints SKIP-NOFILE and COUNTS it), keyed by POSITION × RECEIVER × DEPTH × HOME
against BOUND/BARE on both sides, with both one-sided sets.

```
golden-vs-ours DISAGREEING CELLS   pristine 320  ->  patched 318
  cells FIXED:
    default.BuildUVMPkg    POS=stmt|RECV=prefix|D=2|HOME=function@class_defn
                           ref_obj|alias_name|14098:35  golden=BARE ours=BOUND
    testflags.BuildUVMPkg  (the same cell)
  cells INTRODUCED: none
ONLY-GOLDEN keys 24072 -> 24070    ONLY-OURS keys 24053 -> 24051
```

The other 318 disagreements are other laws' residues — overwhelmingly
`POS=expr|RECV=hierpath` cells (§ 52's and § 107's populations) — and every one
of them is byte-for-byte what it was.

---

## 8. THE BOUNDARY

`bound165.sh` over a COPY of the whole probe tree — top level AND
subdirectories, both views, both binaries, every child `</dev/null`, the file
list on fd 3, scratch keyed on the RELATIVE path, `PROCESSED` asserted against
`LISTED`.

```
LISTED=4678 PROCESSED=4678 PRODUCED_DBS=4522 MOVED_ARMS=4 RC_DIFFS=0
```

Three movers are this pass's own arms — the POSITIVE CONTROL: a gate reporting
zero movers over them cannot see. (`g165_a_sep.sv` does **not** move, and that
is the point of §2.)

The ONE arm outside this pass is **`r10uvm59repro/a1_witness.sv`** — r10uvm59's
own reduction of this very corpus statement (`set_type_alias` passing
`alias_name` to a call inside an `if` body). Censused against ITS OWN Surelog
golden: **def 4 → 2, elab 14 → 12, 2 cells, BOTH TOWARD.**

No earlier pass's arm moved: not r10uvm161's or r10uvm164's committed arms, not
the module-function control `v161_d_break.sv`, not buvm14's, uvm77-79's,
uvm82-91's, uvm84/85's or sd8-12's.

---

## 9. R0 — THE NEXT HEAD ON THIS ROW

BuildUVMPkg default and testflags, **60 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** (`head_pat_BuildUVMPkg.default.cmp`). The head is a NEW
OBJECT, and the pass's old head is gone:

```
LHS: constant: , id:2991, line:8504:47, endln:8504:67   |vpiDecompile:3 |INT:3  |vpiConstType:7
RHS: constant: , id:2939, line:8504:47, endln:8504:67   |vpiDecompile:3 |UINT:3 |vpiConstType:9
     (both under \_param_assign @8504:26, both with
      vpiTypespec -> ref_typespec(uvm_pkg) -> enum_typespec(uvm_pkg::uvm_core_state) @8490)
```

`uvm_pkg.sv:8504` —

```systemverilog
8489: typedef enum { UVM_CORE_UNINITIALIZED, …, UVM_CORE_INITIALIZED, … } uvm_core_state;
8504: parameter uvm_core_state UVM_CORE_POST_INIT = UVM_CORE_INITIALIZED;
```

An **ENUM-TYPED PACKAGE PARAMETER folded to its enum constant's value**: golden
mints a SIGNED constant (`INT:3`, `vpiConstType:7` = `vpiIntConst`), we mint an
unsigned one (`UINT:3`, `vpiConstType:9` = `vpiUIntConst`). Same value, same
decompile, same typespec chain — only the CONSTANT KIND differs, and
`constant::Compare`
(`~/git-repos/UHDM/build/generated/src/constant.cpp:58-71`) tests exactly one
field of its own, `VpiConstType`, so 7 vs 9 is the whole head. The other rows are unmoved: SeqDriver and SimpleUVM stay at 82 (r10uvm164's
R0, the queue-typed local in a parameterized class), MiniAmiq at 106,
Scoreboard/default at 95, Earlgrey at 34, Rggen/default CMP_EQUAL.

### RESIDUES THIS PASS DOES NOT OWN

- **R-modcls** — a generic class homed in a MODULE: arm B `ModCls165` (h71/h72).
  Golden emits its body (binding at depth 0, bare at depth 1); **we emit no
  cells there at all** in either view. An ONLY-GOLDEN gap of 5 census keys,
  identical before and after — nothing for this law to move.
- **R-elabdup** — in the ELAB view of a package our database holds a generic
  class body TWICE at the same span with the same parent chain where golden
  holds it once. §6's three SIDEWAYS cells sit on that duplicate; the distance
  to golden is unchanged.
- **R-namedblkpfx** — a NAMED block's argument reference is named
  `<block>::<formal>` on one side and not the other; it is the head arms B and
  D fall back to after this pass clears theirs, and it is byte-identical under
  both binaries.
- **R-hierpathargs** — the 318 remaining golden-vs-ours ARG disagreements in
  the nine UVM databases, overwhelmingly `POS=expr|RECV=hierpath`; §§ 52 / 107's
  populations, untouched.

---

## 10. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct165own.cpp` | the MIRROR owner-finder for an `LHS: <null>` head (r10uvm164's, unchanged), plus the whole-function reference listing of §1. |
| `ct165cen.cpp` | the census. r10uvm164's five families (REF / TYP / VAR / CNT / OBJ) and its CAS family reproduced verbatim so the must-not-move check is the same one, plus this pass's **ARG** family — every call argument keyed by POSITION × RECEIVER × DEPTH × HOME. |
| `ct165pred.cpp` | the a-priori predictor of §5. |
| `score165.py` | the cell scorer. MULTISET, never a dict (an elab package holds the class body twice at one span), and it prints the PER-KEY DISTANCE for any key whose two sides hold different numbers of objects. |
| `cencount165.py` | the corpus ARG cross-tab of §7 (multiset join; both one-sided sets; cell-level disagreements by name). |
| `grid165.sh` | the arm driver (both views, both binaries, every command with its binary PATH, every rc recorded). |
| `census165.sh` | the corpus census driver (golden read out of each row's own `cmds.txt`; SKIP-NOFILE counted). |
| `predsweep165.sh` | the predictor sweep (RESTORE_FAIL counted). |
| `bound165.sh` | the wide boundary gate. |
| `g165_a_sep.sv` | arm A — the separator, and §2's refutation. |
| `g165_b_home.sv` | arm B — the home and position matrix. |
| `g165_c_forms.sv` | arm C — the argument forms, `$unit`, the expression twin, the corpus miniature. |
| `g165_d_notmove.sv` | arm D — the must-stay matrix and the subscripted receiver. |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the seven named rows' heads, before and after. |
| `GRID` / `CENSUS` / `ARGCENSUS` / `PREDICT` / `PRED.surelog` / `BOUNDARY` / `GATES`.r10uvm165.txt | the measurements. |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | copies of the campaign gate scripts, so `canaudit.sh` runs from this directory. |
