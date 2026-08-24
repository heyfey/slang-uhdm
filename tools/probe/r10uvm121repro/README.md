# r10uvm121 — § `thisSuperNewAssignEmpty121` — **A `this`/`super`-ROOTED `= new` ASSIGNMENT THAT SURVIVES ITS SLOT IS *EMPTY*: SURELOG COMPILES NEITHER SIDE OF IT** — the 13-line SimpleUVM ×2 / Scoreboard/default / BuildUVMPkg ×2 head **CLEARED**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY** (the copies in this worktree) and **nothing
was promoted** — **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `9e04993` |
| production surface | `src/ExprEmit.cpp` ONLY — one new file-static predicate and one early return at the `MakeAssignment` site (113 lines, comment included) |
| probe surface | `tools/probe/r10uvm121repro/` only |
| pristine binary | md5 `0939d5a31f760a196a231823eb75ad7f` |
| patched binary | md5 `ca06e73aebcf65fc3b26f5d623a377b2` |

## 0. THE HEADLINE

| row | mode | pristine cmp lines / heads | patched |
|---|---|---|---|
| **SimpleUVM** | default | **13 / 1** | **148 / 1** (a NEW head — §7 R0) |
| **SimpleUVM** | testflags | **13 / 1** | **148 / 1** |
| **Scoreboard** | default | **13 / 1** | **148 / 1** |
| **BuildUVMPkg** | default | **13 / 1** | **148 / 1** |
| **BuildUVMPkg** | testflags | **13 / 1** | **148 / 1** |
| SeqDriver | default / testflags | 50 / 1 | 50 / 1 — head byte-identical, 4 cells moved BELOW it |
| MiniAmiq | default / testflags | 50 / 1 | 50 / 1 — ditto |
| Earlgrey_0_1 | default / testflags | 36 / 1 | 36 / 1 unchanged |
| Rggen | default | 0 / 0 (CMP_EQUAL) | 0 / 0 |

(counts are DEPTH, not distance: the new 148-line head is an object the judge
only now reaches.)

| | |
|---|---|
| corpus rows changed | **0**, both corpora, both modes (status AND dump column) |
| byte movers | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — **exactly the a-priori prediction, by name** |
| the head's family, 12 UVM row-modes | **OURS-FULL 26 → 0**, AWAY 0, every other census column byte-identical |
| purpose-built golden `g121_a.sv` | pristine 13 cmp lines / 1 head → patched **0 / 0, `uhdm-cmp` rc 0 (EQUAL)**; 21 TO-GOLDEN, **0 AWAY-GOLDEN** |
| goldens | 23 PASS / 0 FAIL (and 0/23 with `SLANG_UHDM=/bin/false`) |

## 1. THE HEAD, AND THE OWNER, CONFIRMED FROM `BaseClass.h` + THE GENERATED `Compare` FIRST

Re-measured on this pass's OWN pristine build (`rowheads.sh`,
`raw/rowheads.pristine.txt`): five row-modes, 13 lines, **one head**, and the
same object in all five.

```
LHS: <null>
RHS:
decompile:
method_func_call: (new), id:33168
|vpiParent:
\_assignment: , id:33164, line:658:4, endln:658:28
|vpiName:new
```

`LHS: <null>` with a full RHS is the **SINGULAR** `SafeCompare` overload's
mirror arm (`~/.local/include/uhdm/BaseClass.h:193-195`,
`lhs == nullptr && rhs != nullptr` sets `m_failedRhs` only).  It names the
VALUE — the object OURS points at — and hides the owner.

**THE OWNER, read off BOTH `uhdm-dump`s** (`raw/OWNER.SimpleUVM.default.txt`):

```
OWNER   assignment @658:4-658:28
        vpiParent  begin (uvm_pkg::uvm_mem_mam::new)
        home       function (uvm_pkg::uvm_mem_mam::new) @653:1-659:17
        views      the DEF copy of package uvm_pkg, and the ELAB copy reached
                   through work@env < uvm_env < uvm_component < uvm_pkg
FIELD   assignment::Rhs
```

`assignment::Compare` (`~/git-repos/UHDM/build/generated/src/assignment.cpp:106-117`)
reads `VpiOpType`, `VpiBlocking`, **`Rhs`**, then `Lhs`.  Both sides carry
`vpiOpType 82` and `vpiBlocking 1`, so the walk stops at `Rhs` — and **`Lhs` is
null on golden too**, which is why the law below must empty BOTH slots and not
just the one the head names.

```
GOLDEN                                   OURS (pristine)
\_assignment: , 658:4-658:28             \_assignment: , 658:4-658:28
  |vpiParent: \_begin(…uvm_mem_mam::new)   |vpiParent: \_begin(…uvm_mem_mam::new)
  |vpiOpType:82                            |vpiOpType:82
  |vpiBlocking:1                           |vpiBlocking:1
                                           |vpiRhs:  \_method_func_call: (new)
                                           |vpiLhs:  \_hier_path: (this.default_alloc)
                                                       |vpiActual \_ref_obj: (this)
                                                       |vpiActual \_ref_obj: (…::default_alloc)
```

**THE FILE LINE 658 BELONGS TO.**  `uvm-1.2 src/reg/uvm_mem_mam.svh:653-659`,
reached through `uvm_pkg.sv` (`--single-unit`) — and, for `BuildUVMPkg`, the
same construct at `1800.2-2017-1.0/pp_output/uvm_pkg.sv:70583`:

```systemverilog
function uvm_mem_mam::new(string      name,                    // :653
                      uvm_mem_mam_cfg cfg,
                      uvm_mem mem = null);
   this.cfg           = cfg;                                   // :656  agrees
   this.memory        = mem;                                   // :657  agrees
   this.default_alloc = new;                                   // :658  <- THE HEAD
endfunction: new
```

## 2. WHY GOLDEN HOLDS NULL THERE — DECODED FROM SURELOG, FILE AND LINE

Not a dropped call (buvm26's family), not a re-parent: **Surelog compiles
nothing at all for this statement, because its compiler matched none of its own
three arms.**

`grammar/SV3_1aParser.g4:2310`:

```
blocking_assignment
  : variable_lvalue ASSIGN_OP delay_or_event_control expression
  | nonrange_variable_lvalue ASSIGN_OP dynamic_array_new
  | (implicit_class_handle DOT | class_scope | package_scope)? (
      identifier | hierarchical_identifier ) select ASSIGN_OP class_new
  | operator_assignment
  ;
```

`CompileStmt.cpp:241` hands `fC->Child(paBlocking_assignment)` to
`CompileHelper::compileBlockingAssignment` (`CompileHelper.cpp:4456`), whose
entire body is a three-way `if` on that node:

```cpp
Variable_lvalue = fC->Child(Operator_assignment);
if      (Type(Variable_lvalue)     == paHierarchical_identifier
      || Type(Variable_lvalue)     == slStringConst)      { …lhs_rf, rhs_rf… }
else if (Type(Variable_lvalue)     == paVariable_lvalue)  { …lhs_rf, rhs_rf… }
else if (Type(Operator_assignment) == paHierarchical_identifier) {   //  = new …
                                                            …lhs_rf, fcall… }
…
if (AssignOp_Assign) assign->VpiOpType(getVpiOpType(Type(AssignOp_Assign)));
else                 assign->VpiOpType(vpiAssignmentOp);            // 82
if (blocking)        assign->VpiBlocking(true);
assign->Lhs(lhs_rf);          // BOTH STILL nullptr
assign->Rhs(rhs_rf);
```

When the optional `implicit_class_handle DOT` prefix is written, the child of
`paBlocking_assignment` is that prefix node — neither a
`paHierarchical_identifier` nor a `paVariable_lvalue` — so all three arms miss
and the routine falls out of its own bottom with `lhs_rf == rhs_rf == nullptr`.
**The empty assignment is not a decision anywhere in Surelog; it is the tail of
a function that matched nothing.**

REPRODUCED IN A 20-LINE FILE, one mutation apart (`g121_a.sv` cells a02/a06):

| written | golden |
|---|---|
| `this.margin = new;` | `assignment` with vpiOpType 82, vpiBlocking 1, **no Lhs, no Rhs** |
| `verso = new;` (the same class property, bare spelling) | `assignment` with `Rhs = method_func_call(new)` and `Lhs = ref_obj` under a `hier_path` |

## 3. THE LAW

> **§ `thisSuperNewAssignEmpty121`** — *an assignment written*
> `<this|super>[.<name>]… = new` / `= new(…)` / `= new <expr>` / `= new[…]`
> *carries `vpiOpType` 82 and `vpiBlocking` 1 and **nothing else**: no `vpiLhs`
> and no `vpiRhs`.  Whether that object is APPENDED to its statement list is a
> separate question and stays exactly where § `thisSuperNewAssignNoStmt3`
> answered it.*

The two laws are the two halves of ONE producer fact.  § 3's own comment
already states it — "Surelog does not drop the construct — it builds an
assignment with NEITHER vpiLhs NOR vpiRhs … and then whether that object
survives depends ENTIRELY on the slot it lands in" — and lists the KEPT slots.
§ 3 modelled the LIST-APPEND half; nothing modelled the OBJECT half, so in
every KEPT slot we emitted a fully populated assignment where golden's is
empty.  A class CONSTRUCTOR'S OWN statement list is the corpus's KEPT slot, and
`uvm_mem_mam::new` is the corpus's only site.

### The golden grid (`GRID.txt`, arms `g121_a.sv` and `g121_b.sv`)

Names, orders and shapes in the two arms are deliberately unrelated to each
other and to the law's vocabulary, so an arm cannot agree by accident.

`g121_a.sv` — **THE KEPT SLOTS**, 78 lines, and the whole head in one file: its
pristine `uhdm-cmp` head is the 13-line corpus head verbatim (a different span),
and patched the arm is **CMP_EQUAL (rc 0, 0 lines)**.

| cell | written | slot | pristine → patched |
|---|---|---|---|
| a02 | `this.margin = new;` | ctor's own list | full → **empty** = golden |
| a03 | `this.gutter = new(3);` | ctor's own list | full → **empty** |
| a04 | `this.folio = new();` | ctor's own list | full → **empty** |
| a05 | `this.recto = new this.margin;` | ctor's own list | full → **empty** |
| a08 | `this.colophon = new;` | sole branch of an `if` | full → **empty** |
| a09 | `this.incipit = new(4);` | sole body of a `while` | full → **empty** |
| a10 | `this.explicit_h = new;` | sole body of a `foreach` | full → **empty** |
| a11 | `this.rubric = new;` | a `case_item`'s statement | full → **empty** |
| a15 | `super.gutter = new;` | derived ctor's own list | full → **empty** |
| a16 | `this.scrape = new(2);` | derived ctor's own list | full → **empty** |
| **a01** | `leaf = width;` | ctor's own list | CONTROL, unchanged |
| **a06** | `verso = new;` (bare property) | ctor's own list | CONTROL, unchanged |
| **a07** | `this.leaf = width + 1;` | ctor's own list | CONTROL, unchanged |
| **a12** | `quire = new;` | sole `if` branch | CONTROL, unchanged |
| **a13** | `this.leaf = k;` | sole `if` branch | CONTROL, unchanged |
| **a14** | `this.margin = new;` | plain `begin` list | ABSENT on BOTH sides — § 3's family, untouched |

`g121_b.sv` — **THE FENCE**: the slots § 3 DROPS (b01 begin-list, b03 whole
function body, b04 `new[4]`, b05 a `fork` arm, b06 a NAMED begin, b10/b11 this.
with a select) are absent from BOTH sides before and after, and the `::`-scoped
prefixes and controls are scored beside them.

Scores (`score121.py`, golden vs pristine vs patched, per view):

| arm | ALREADY-RIGHT | TO-GOLDEN | **AWAY-GOLDEN** | STILL-WRONG | CHANGED-STILL-WRONG |
|---|---|---|---|---|---|
| `g121_a` kept-slot grid | 19 | **21** | **0** | 0 | 0 |
| `g121_b` fence + residues | 10 | **1** (b07, the sole body of a `for` — a KEPT slot § 3's list does not name) | **0** | 4 (§7 R-scope121) | 1 (§7 R-copy121) |

## 4. THE FIX

`src/ExprEmit.cpp`, at the `MakeAssignment` site of the `AssignmentExpression`
arm — after the op type, blocking flag, parent and span are stamped and before
either side is emitted:

```cpp
if (thisSuperNewAssignEmpty121(ae))
    return asn;
```

`thisSuperNewAssignEmpty121` reads the **SYNTAX**, exactly as § 3 and
§ `dynArrayNewLvalueBase110` do, because an IMPLICIT class-property reference is
a `MemberAccess` on an implicit `this` in slang's bound AST — the AST cannot
tell `verso` from `this.verso` at all.  RHS half: the written node is a
`NewClassExpression`, `NewArrayExpression` or `CopyClassExpression`.  LHS half:
the lvalue is a `ScopedName` whose leftmost root is a `ThisHandle` or a
`SuperHandle`.  Compound (`+=`) and non-blocking (`<=`) assignments are refused
up front: they are different grammar alternatives and neither can carry a
`class_new`.

**Neither side is EMITTED, not emitted-then-dropped.**  That is deliberate and
it is what golden does: `compileBlockingAssignment` never compiled either
expression, so no reference from this statement ever reached Surelog's
late-binding pool either (the mechanism §§ 107/109 decode).  Emitting and
discarding would have left two orphan objects in the serializer for every cell.

The RHS half lists `CopyClassExpression` where § 3's does not — § 3 was written
from the SVSwitch `new[…]`/`new()` cells and never measured the copy form, and
`g121_a` a05 says golden empties `this.recto = new this.margin;` exactly like
the other three.  The two predicates are deliberately NOT merged while the
corpus still has open DIFF rows (RESUME §9's no-premature-extraction rule); each
names the other in its comment.

## 5. EVIDENCE AND GATES

* **`PREDICTION.txt` — the mover set NAMED A PRIORI, from PRISTINE databases,
  before the patched sweep ran.**  `pred121.cpp` (`predall121.sh`) evaluates the
  UHDM signature of every object the law will empty over **2314 pristine
  databases** (956 surelog + 1358 uhdm2rtlil) and names **9 movers**, 26 cells,
  all one source site:

  | database | cells |
  |---|---|
  | `SimpleUVM` default, testflags | 2 each |
  | `Scoreboard` default | 2 |
  | `BuildUVMPkg` default, testflags | 2 each |
  | `MiniAmiq` default, testflags | 4 each (`uvm_pkg` ×2 + `svaunit_pkg` ×2) |
  | `SeqDriver` default, testflags | 4 each (`uvm_pkg` ×2 + `adpcm_pkg` ×2) |
  | uhdm2rtlil, all 1358 | **0** |

  `byteverify.sh SELFCHECK=1` then measured **MOVERS 9 / 956** and **0 / 1358** —
  the identical set, by name, no more and no less.

  The predictor's one blind spot is stated in its own header and closed by
  source inventory: a `super.`-rooted cell leaves the PRISTINE emitter with a
  bare `ref_obj` Lhs indistinguishable from an ordinary `x = new()` (arm a15).
  A grep of both corpora and every UVM tree finds **ZERO `super.<name> = new`
  sites**, so the `EXACT` column is complete, not merely tight.  The seven
  `this.<…> = new` sites the same grep finds outside the head are all accounted
  for: `uvm_vreg.svh:779` and the Tnoc/SVSwitch/ariane sites are § 3 DROP slots
  (no object is built on either side), and `uvm_reg_backdoor.svh:271` /
  `rggen_backdoor_pkg.sv:34` are subscripted lvalues that are not `ScopedName`
  roots and that neither law reaches.

* **`ATTRIBUTION.txt` — order-blind.**  Scoreboard/default is a ~50/50 COIN
  (RESUME §9), so every mover's dumps are path-normalised **and SORTED** before
  the diff.  All nine movers: **added = 0**.  Removed = 42 lines (2 cells) or 84
  (4 cells), and every removed line is one of
  `\_assignment: , line:658:4, endln:658:28` (the two occurrences the Rhs/Lhs
  sub-prints added), `\_method_func_call: (new)`,
  `\_hier_path: (this.default_alloc)`, `\_ref_obj: (this)`,
  `\_ref_obj: (…::uvm_mem_mam::new::default_alloc)` and their
  `vpiRhs`/`vpiLhs`/`vpiName`/`vpiFullName`/`vpiActual`/`vpiParent` labels.
  **Nothing else moved in any of the nine.**

* **`CENSUS.pristine.txt` / `CENSUS.patched.txt` — the one-sided sets are
  PRIMARY** (uvm109's lesson: a pass that REMOVES objects must score them
  explicitly).  `ct121cen.cpp` prints one row per REACHABLE `assignment` — view,
  root container, owner chain, span, Rhs and Lhs kind|name — with the vpiParent
  chain required to terminate at the design (uvm97's lesson).  `cen121.py`
  multiset-joins the two and classifies ONE-SIDED CELLS BEFORE any `<null>`
  test.  Over the 12 measured UVM row-modes:

  | | pristine | patched |
  |---|---|---|
  | SAME | 123 697 | 123 697 |
  | **OURS-FULL** (golden empty, we hold something) | **26** | **0** |
  | EMPTY-BOTH | 0 | **26** |
  | GOLD-FULL | 0 | 0 |
  | DIFF | 16 | 16 |
  | **ONLY-GOLDEN** (a cell we do not emit at all) | 808 | **808** |
  | **ONLY-OURS** (a SURPLUS assignment) | 892 | **892** |

  Every column except the two the law owns is byte-identical, row-mode by
  row-mode — so no surplus object was created and no golden cell was lost.

* **`GRID.txt`** — the two purpose-built goldens, scored per view: 22 TO-GOLDEN,
  **0 AWAY-GOLDEN**, and `g121_a` reaches `uhdm-cmp` rc 0.

* **`GATES.txt`** — the whole landing battery.

* **`BOUNDARY.txt` + `BOUNDARY.acquittal.txt`** — `bound121.sh` over a COPY of
  the WHOLE probe tree (3712 `.sv`/`.v` arms, NO path filter), four
  combinations: file/def `DIFFER=10`, dir/def 10, file/elab 10, dir/elab 9,
  `PROCESSED == LISTED` in all four, every reject SYMMETRIC, the slang-fenced
  four never dispatched (`fenced121.sh` reads the list out of `canaudit.sh` and
  only a COUNT is printed).  Every differing arm is acquitted:
  * FIVE are the emitter's ORDER nondeterminism, and that is MEASURED, not
    asserted — their order-blind diff is **0 lines**, and the r10uvm75repro dir
    arm compiled FOUR TIMES WITH THE ONE PRISTINE BINARY gives four different
    dumps and four IDENTICAL sorted dumps.
  * FIVE are this law's own family (r10svs3repro is § 3's own probe directory;
    plus § covergroupNewCall7's `this.cg4 = new;` arm, § dynArrayNewLvalueBase110's
    `this.`/`super.` fence arm, and r10uvm85repro's `this.h = new;`).  Scored on
    DISTINCT REACHABLE OBJECTS (ct121cen, not dump prints) against their own
    Surelog golden, in BOTH views: **SAME unchanged in all 20 arm-views,
    OURS-FULL → 0, ONLY-GOLDEN unchanged, ONLY-OURS unchanged or SMALLER**
    (a4_ctorspan elab 4→3, v2_copy elab 8→4, g121_b elab 16→7).

* **`raw/`** — the pristine and patched heads, `rowheads` both ways, and the
  owner subtree on both sides.

Gate battery (all green, `GATES.txt`):

| gate | result |
|---|---|
| build both, md5s | pristine `0939d5a3…`, patched `ca06e73a…` |
| `tests/check_goldens.sh` | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL |
| uhdm2rtlil, both modes, vs committed baseline AND vs own pristine | **PASS — every row byte-identical** (679/50/2 unchanged) |
| surelog, both modes, vs committed baseline AND vs own pristine | **PASS — every row byte-identical**; 937 CMP_EQUAL / 19 CMP_NOTEQUAL, unchanged |
| `byteverify SELFCHECK=1` | 9/956 (predicted, by name) · 0/1358 · SELFCHECK 955/956 and 1357/1358 flagged |
| `canaries.sh` | ok=52 changed=0 (surelog) · ok=8 changed=0 (uhdm2rtlil) |
| `ctcan2.sh` | PASS both corpora |
| `canaudit.sh` | audited=29 UNCOVERED=0 **FENCE-BREACH=0** |
| protected DBs by md5 | `InterfaceModPort` `BlackParrotComplex` `YosysOldOr` byte-identical · `SVSwitch` `4842211c4030` · `YosysVerx` `6ccda350c24a` |

## 6. INSTRUMENTS (measurement only; the official `uhdm-cmp` is the judge)

* `ct121cen.cpp` — the reachable-`assignment` census (view / root / owner chain /
  span / Rhs / Lhs).  Build:
  `g++ -O2 -std=c++17 ct121cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct121cen`
* `cen121.py` — the multiset join, ONE-SIDED SETS FIRST.
* `cenall121.sh` — the census over every row-mode of a workdir.
* `pred121.cpp` + `predall121.sh` — the a-priori mover predictor (EXACT / WIDE).
* `attrib121.sh` — order-blind mover attribution (sorted, path-normalised).
* `armcen121.py` / `score121.py` / `grid121.sh` — the purpose-built-golden
  census, scorer and driver (Surelog + both binaries + `uhdm-cmp` per arm).
* `bound121.sh` + `fenced121.sh` — the boundary gate and its fence.
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` / `ct8rows.sh` / `byteverify.sh` /
  `rowheads.sh` — the standard gates, copied for this pass.

## 7. RESIDUES

* **R0 (the NEXT head — SimpleUVM both modes, Scoreboard/default and
  BuildUVMPkg both modes, 148 lines, one object).**
  `uvm-1.2 src/reg/uvm_reg_model.svh:105`
  ``typedef bit [`UVM_REG_CVR_WIDTH-1:0] uvm_reg_cvr_t ;`` — the ELABORATED
  package's copy of the typedef's `bit_typespec`.  Golden's is named
  **`uvm_reg_cvr_t`** (UNQUALIFIED), carries a **`vpiTypedefAlias`**
  `ref_typespec` whose `vpiActual` is the DEF-view `uvm_pkg::uvm_reg_cvr_t`, and
  its range LEFT bound is a **FOLDED `constant INT:31`**; ours is named
  `uvm_pkg::uvm_reg_cvr_t`, has **no `Typedef_alias`**, and its left bound is an
  UNFOLDED `operation` (`vpiOpType 11`) over `32` and `1`.
  `typespec::Compare` walks `Typedef_alias` BEFORE `Instance` (RESUME §9), which
  is why the alias is what the head names.  Two facts, possibly one law.
  (`raw/head_pat_default_SimpleUVM.cmp`.)
* **R-scope121 (`g121_b` b08/b09, 4 cells, 0 corpus cells).**  The OTHER two
  written prefixes of the same grammar alternative — `class_scope`
  (`Taper::shared_wick = new;`) and `package_scope` (`tallow::free_wick = new;`)
  — miss `compileBlockingAssignment`'s three arms for exactly the same reason,
  and golden emits **no statement at all** for them in a plain function's list.
  We emit a populated assignment, pristine and patched alike.  Fixing them means
  widening § `thisSuperNewAssignNoStmt3`'s DROP half (a statement-list SIZE
  change), not this pass's object half, and the corpus census finds **0** such
  cells; § `dynArrayNewLvalueBase110`'s R-static110 is the same family seen from
  the `new[…]` side.  Left exactly as it is.
* **R-copy121 (`g121_b` b02, 1 cell, 0 corpus cells).**  `this.douse = new this.snuff;`
  as an element of a plain `begin` list: golden omits the statement, § 3's
  predicate does not list `CopyClassExpression` on its RHS half, so we still
  append it — now as an EMPTY assignment instead of a populated one, which is
  strictly closer but still a surplus list element.  The one-line widening of
  § 3 is a LIST-SIZE change with 0 corpus cells behind it and is deliberately
  not taken here.
* **R-ctorshift121 (measured, not modelled here).**  A class constructor whose
  port list is EMPTY (`function new();`, in-body or out-of-body) loses its FIRST
  body statement in golden — the § `constructorBodyElementShift27` mechanism.
  It is why every constructor cell in `g121_a`/`g121_b` is written WITH a port
  list: without one the first cell of each arm would not have been measured at
  all.  § 27 already owns this and both sides agree at the corpus sites.
* **R-tf111 / R-buvm111 and the other carried DIFF/ONLY-G/ONLY-O columns of §5's
  census** — 16 DIFF, 808 ONLY-GOLDEN, 892 ONLY-OURS over the 12 row-modes,
  byte-identical before and after this pass.
