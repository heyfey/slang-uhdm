# r10uvm66 — § declInitWrittenNewNoStmt66: the briefed 262-line head **CLEARED on all THREE target rows** (262 → 33 cmp lines), 7 movers and every one predicted — and the pass's OWN removed-line instrument was WRONG, fired 24 false alarms, and was CORRECTED before any of its numbers were believed

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — with **0 differing
ROWS** on both.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**
(`SimpleUVM/default`, `SimpleUVM/testflags`, `Scoreboard/default`). All three
went from **262 cmp lines to 33**, and `grep -cF get_link` on all three fresh cmp
logs is **0**. The new head is a folded `constant`/`int_typespec` pair in
`uvm_pkg` at 410:30 — a different family, §6 residue 4.

**THIRD LINE, and it is the one this pass exists to record.** The brief told me
to census both blocks child-by-child span-keyed FIRST, and doing so answered the
whole pass in one command — but the instrument I then wrote to police the
*removal* direction was itself wrong. `mvrem66.sh`'s first rule was
`patched < golden ⇒ OVER-DELETE`; it flagged **24 rows on BuildUVMPkg alone** and
**every single one was a text ours was ALREADY SHORT OF BEFORE THE PATCH**, or an
artefact of the two-space INDENT LIFT a structural delete causes. Believing it
would have produced a false "this patch deletes past golden" verdict; fixing it
produced the three honest buckets (SURPLUS-ONLY / CROSSED / ALREADY-SHORT) and an
INDENT-BLIND keying, and it is the corrected instrument that shows the deletion
never crossed golden. **A delete-direction law needs a delete-direction
instrument, and mv65.sh's add-only one is not it.**

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `ct66arm.sh` and `rowheads.sh` print that they did on every run.

Base **3076437**. Worktree `/tmp/wt_r10uvm66`; pristine control worktree
`/tmp/wt_r10uvm66pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `3076437e5f47ab92f85712b8139cf5c41115b0da`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 3076437) | `c7f318688961a24d51d9a4d958bcf2ad` | my own build of the base commit |
| **SHIPPED (patched)** | **`a79347834ca32a31f144147b9734a469`** | every gate number below was measured on THIS binary |

The patched worktree's own **pre-patch** build came out byte-identical to the
control (`c7f318688961a24d51d9a4d958bcf2ad` from both trees) — a reproducibility
check that costs nothing and proves the two worktrees really start from the same
commit.

BUILD DIRS (absolute): `/tmp/wt_r10uvm66/build`, `/tmp/wt_r10uvm66pris/build`.
The link line (`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm`) was waited for and read before any md5 was taken; every md5 was
asserted in its own command and every one is 32 hex digits (asserted with an
explicit `^[0-9a-f]{32}$` match, not eyeballed). `git stash` was never used. The
four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched — `canaudit.sh` proves it mechanically
(FENCE-BREACH=0). `GOLDEN_DEFER` left **UNSET** (echoed as `[UNSET]` at every
sweep launch; **5 DEFERRED** in both surelog modes, as in the baseline). slang
was not patched. `results/*.csv` were only ever read.

**OPS NOTE, because it cost this pass 25 minutes.** This machine was at
`available: 0` of 15 GB when the pass started (other agents' `cc1plus`
processes). `make -j6` was OOM-killed with `c++: fatal error: Killed signal`, and
a second attempt at `-j2` was killed with **no message at all** — the build log
ended in `Error 2` with zero `error:` lines. A build that dies silently is not a
compile error; check `free` before reading the log.

---

## 0. THE LAW

### § declInitWrittenNewNoStmt66

*A local variable **DECLARATION** whose **WRITTEN initializer is a `new`
construction** — `= new`, `= new(...)` (class) or `= new[n]`, `= new[n](src)`
(dynamic array) — contributes **NO ELEMENT** to the enclosing Surelog statement
LIST, and the variable therefore keeps the enclosing **BLOCK** as its
`vpiParent` instead of re-parenting onto a declaration `assignment`. Every OTHER
initializer contributes a leading blocking `assignment` in declaration order and
**does** own the variable. The **class CONSTRUCTOR's own list is excluded** —
golden keeps the assignment there. The dropped element **still counts** toward
the body's `begin`-wrapper decision.*

```
251  static function uvm_cause_effect_link get_link(uvm_object lhs,
252                                                 uvm_object rhs,
253                                                 string name="ce_link");
254     uvm_cause_effect_link ce_link = new(name);      <- golden: NO statement
255     ce_link.set(lhs, rhs);                          <- golden Stmts[0]
256     return ce_link;                                 <- golden Stmts[1]
257  endfunction : get_link
```

* **DIRECTION: DELETE.** This is **not** an add-only law and is never described
  as one. Measured, not asserted: 1037–1643 REMOVED line instances per UVM
  database against 44–73 ADDED (§4). The ADDED lines are the *re-parenting* half:
  every one is a `\_begin:` back-reference that the variable now prints under.
* **All 48 distinct ADDED line texts land at EXACTLY golden's count** — 48
  exactly, 0 above, 0 still below (§4).
* `grep -rn 'declInitWrittenNewNoStmt66' src/ include/` → declared once, defined
  once, called from **two** sites — and the **third** site that builds the same
  object is deliberately NOT a call site (§0.2).

### STATED GATE == CODE GATE — read off the source, not the comment

| | |
|---|---|
| **the whole predicate** | `StmtEmit.cpp` `declInitWrittenNewNoStmt66(vs)`: `dt = vs.getDeclaredType()` (a `not_null<>`, nothing to check) · `isyn = dt->getInitializerSyntax()` · `!isyn → false` · `return isyn->kind == NewClassExpression \|\| isyn->kind == NewArrayExpression` |
| **call site 1 of 2** | `emitDeclStmt9`, the WRITTEN-block path: `if (declInitWrittenNewNoStmt66(vs)) return;` — **replacing** a pre-existing `init->kind == ExpressionKind::NewClass` clause that was ONE TERM SHORT |
| **call site 2 of 2** | the subroutine-BODY statement-list path: inside `for (auto* vsym : declVars)`, after `if (!init) continue;`, `if (declInitWrittenNewNoStmt66(*vsym)) continue;` |
| **NOT a call site** | `emitCtorBody27`'s `EK_BID` arm — the class constructor. Measured: a2 n01 |
| **not in the gate** | no variable-type test · no scope test · no slot test · no argument-list test · no `static`/`const`/`automatic`/`local` test · no LHS-spelling test (a declaration has none) · **no change to `initCount`/`eff9`, to the wrapper decision, or to the wrapper anchor** · no new state, no new counter, no new member |

**Why the gate reads the SYNTAX and not the bound expression kind.** It is the
same two `SyntaxKind`s § thisSuperNewAssignNoStmt3 reads on its RHS half, so the
two laws that split this family share one vocabulary and one spelling.
`NewCovergroupExpression` is deliberately excluded: no arm measured it and no
corpus site reaches it — the same exclusion, for the same stated reason, as § 3.
The syntax keying also fires on `= new` with **no parentheses at all** (a2 n09),
which is why no argument list is read.

### 0.1 The two laws that split this family, side by side

|  | § thisSuperNewAssignNoStmt3 | § declInitWrittenNewNoStmt66 |
|---|---|---|
| what is written | a **STATEMENT** `<this\|super>.… = new…;` | a **DECLARATION** `<type> v = new…;` |
| LHS term | the `this`/`super` KEYWORD is required | none — a declaration has no LHS to spell |
| RHS term | `NewArrayExpression` / `NewClassExpression` | the same two, on `getInitializerSyntax()` |
| bare local | `ce = new(name);` is **KEPT** (a1 m07) | `a1c ce = new(name);` is **DROPPED** (a1 m01) |
| constructor list | **KEPT** (its own slot exception) | **KEPT** (a2 n01) |

**a1 m07 is the cell that fixes the shape of both laws**: the SAME construction,
the SAME class, the SAME method — written once as a declaration initializer and
once as a statement over a bare local. Golden drops the first and keeps the
second. So this is not "a `new` assignment never becomes a statement", and it is
not a position law either: it is the DECLARATION.

### 0.2 The constructor exclusion is MEASURED, and a1 could not see it

a1's constructor cell (`a1ctor::new`, port-less) read **SAME on both sides for
the wrong reason**: § constructorBodyElementShift27 eats a port-less
constructor's first element whatever it is, so the declaration never reached any
statement list and golden emits no `class_var` for it at all (a1 Table B:
`-NOOBJ-`, keyed UNMEASURED). **a2 n01 gives the constructor a PORT LIST**, and
with the shift out of the way golden's answer is unambiguous:

```
45  function new(int seed);
46     a2c ce = new();      golden Stmts[0] = assignment@46:14-46:24, and
47     ce.set(seed, 2);     golden parents `ce` ON THAT ASSIGNMENT
48     fld = seed;
```

That is § 27's model (2) exactly — `compileClassConstructorDeclaration` has no
Rhs-less-assignment filter, and an initializer that compiles to nothing leaves
precisely such an assignment. a2 n01b (`int x = 5;` in the same constructor) is
the control. **Had I applied the law to all three sites, this cell would have
regressed.**

---

## 1. WHAT WAS MEASURED BEFORE ANY CODE WAS WRITTEN

### 1.1 The head, on my own pristine build

```
rowheads.sh /tmp/r10uvm66_ctl_wd …   SimpleUVM Scoreboard
  SimpleUVM   default     262 cmp lines  1 head
  SimpleUVM   testflags   262 cmp lines  1 head
  Scoreboard  default     262 cmp lines  1 head
  Scoreboard  testflags   SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
```

### 1.2 THE CENSUS OF BOTH BLOCKS, CHILD BY CHILD, SPAN-KEYED — the brief's first instruction, and it answered the pass

The brief said the block EXISTS on both sides and the difference is inside its
`Stmts`. **Correct, and it is two fields of one mechanism**, not one:

| `begin @255:7-255:29` child | GOLDEN | OURS (pristine) |
|---|---|---|
| `vpiParent` | `function @251:4-251:10` | identical |
| `vpiFullName` | `uvm_pkg::uvm_cause_effect_link::get_link` | identical |
| `vpiVariables[0]` | `class_var ce_link @254:29-254:36`, **`vpiParent` = the BEGIN** | same object, **`vpiParent` = `assignment @254:29-254:48`** |
| **`Stmts[0]`** | `method_func_call set @255:15-255:18` | **`assignment @254:29-254:48`** — opType 82, blocking, `Rhs` = `method_func_call (new)` with `ref_obj name`, `Lhs` = the `class_var` — **SURPLUS** |
| `Stmts[1]` | `return_stmt @256:7-256:13` | `method_func_call set @255:15-255:18` |
| `Stmts[2]` | — | `return_stmt @256:7-256:13` |

Everything else in the subtree — the `set` call's two `ref_obj` arguments and
their `io_decl` actuals, the `vpiPrefix` `ref_obj`, the `return_stmt`'s
`vpiCondition` — is **byte-identical**, spans included. Golden's `class_var`
carries **no `vpiExpr`**: the `new(name)` is not moved elsewhere, it is **gone**.

**Two fields, and a patch that fixed only one would have looked green on the
`Stmts` vector and left the variable parented on a deleted object.** That is why
`ct66cells.py` has TWO tables.

### 1.3 The head's SPAN is not at issue, and that was checked rather than assumed

Golden's `begin` and ours are both at `255:7-255:29`, and `255` is the *second*
source item. Our wrapper anchor (`sl.list[1]`) already agrees, in the
two-declaration case too (a1 m20: both sides `177:10-177:24`). The patch
therefore leaves the anchor code untouched, and no arm cell's span moved.

---

## 2. THE GRID, CELL FOR CELL

`ct66cells.py <g.dump> <o.dump>` builds two tables: **A** the ordered statement
list of every function/task body (`begin[a@s, b@s]`, so a surplus element shows
as an element and not as a count) and **B** the `vpiParent` of every variable
object. Traps encoded, each paid for earlier in this campaign: an object is not a
dump occurrence (kept at its fullest occurrence); own-child indent only;
subroutines and variables keyed by **kind+fullname, not by span**, so § 65
residue 3's function-span law cannot key a live cell UNMEASURED (the span is
printed in its own column so a disagreement is still SEEN); a key on one side
only is `-NOOBJ-`/UNMEASURED and never agreement.

`G` = golden. `pre` = ours `c7f31868…`. `post` = ours `a7934783…`.
**Every DIFF cell below moved DIFF→SAME. Across all four arms and the
whole-design audit, ZERO cells moved SAME→DIFF.**

### 2.1 Arm `a1_declinit.sv` — WHICH INITIALIZER? (24 cells)

| cell | source | G Stmts[0] | pre | post |
|---|---|---|---|---|
| **m01** | **the corpus shape: `a1c ce = new(name); ce.set(…); return ce;`** | `method_func_call@48:13` | `assignment@47:14` **extra** | **match** |
| m02 | `a1c ce = new();` + a call | `method_func_call@55:13` | extra | **match** |
| m03 | the decl+init is the WHOLE body | `-NONE-` | `-NONE-` | `-NONE-` |
| m04 | `int x = 5;` | `assignment@66:14` **KEPT** | same | same |
| m05 | `int x = lhs + 1;` | `assignment@72:14` **KEPT** | same | same |
| m06 | `a1c ce = m01_corpus(1,2,"x");` — a FUNCTION CALL | `assignment@78:14` **KEPT** | same | same |
| **m07** | **`a1c ce; ce = new(name);` — the same construction as a STATEMENT** | `assignment@89:10` **KEPT** | same | same |
| m08 | `int d[] = new[3];` — DYNAMIC ARRAY | `assignment@96:10` (`fld=1`) | extra | **match** |
| m09 | two `int` inits | both KEPT | same | same |
| m10 | declaration with NO initializer | (no element) | same | same |
| m11 | decl+init in an explicit `begin` | (already correct) | same | same |
| m12 | decl+init in a NAMED `begin` | `named_begin[method_func_call@128:16]` | same | same |
| m13 | a TASK | `method_func_call@135:13` | extra | **match** |
| m15 | `string s = "abc";` | KEPT | same | same |
| m16 | decl+init then ONLY a `return` | `[return_stmt@151:10]` | extra | **match** |
| m17 | `a1c ce = null;` | `assignment@156:14` **KEPT** | same | same |
| m18 | `int x = lhs;` | KEPT | same | same |
| m19 | decl+init then a `for` | KEPT + `for_stmt` | same | same |
| m20 | TWO `new` decls, then two calls | `[method_func_call@178, method_func_call@179]` | 2 extra | **match** |
| m21 | `int q[$] = {1,2};` — QUEUE from a concat | `assignment@184:14` **KEPT** | same | same |
| m22 | `automatic int x = 5;` | KEPT | same | same |
| m24 | PACKAGE free function | `method_func_call@216:10` | extra | **match** |
| m26 | MODULE task | `method_func_call@233:10` | extra | **match** |
| a1ctor | port-less constructor | **UNMEASURED** (masked by § 27) | — | — |

**m08 against m21 and m06/m17 is the whole type axis, in both directions**: a
dynamic array drops (`new[3]`) while a queue keeps (`{1,2}`), a class handle
drops (`new(name)`) while the SAME class handle keeps (`= m01(…)`, `= null`). So
neither `array_var` nor `class_var` is a term.

### 2.2 Arm `a2_slots.sv` — WHICH SLOTS, AND WHICH `new`? (26 cells)

| cell | source | G | pre | post |
|---|---|---|---|---|
| **n01** | **CONSTRUCTOR WITH A PORT LIST** | `assignment@46:14` **KEPT**, `ce` parented on it | same | **same — deliberately untouched** |
| n01b | the same constructor, `int x = 5;` | KEPT | same | same |
| **n02** | a WRITTEN `begin`, `int d[] = new[3];` | dropped | **extra** | **match** |
| n02b | a WRITTEN `begin`, `a2c ce = new();` | dropped | already correct | same |
| n03 | a module `initial`, `int d[] = new[3];` | dropped | **extra** | **match** |
| n04 | a module `initial`, `a2c ce = new();` | dropped | already correct | same |
| n05 | a `fork`'s inner block | dropped | already correct | same |
| n06 | a `for`-loop body block | dropped | already correct | same |
| n07 | body where EVERY element is a `new` decl | **`begin@128:10-128:24[]` — an EMPTY begin**, both locals parented on it | 2 extra | **match** |
| n08 | `int x = 5;` + `a2c q = new();`, no statement | `[assignment@133:14]` | extra | **match** |
| **n09** | **`a2c ce = new;` — NO PARENTHESES** | dropped | extra | **match** |
| **n10** | **`int d[] = new[3](src);` — the COPY form** | dropped | extra | **match** |
| n10b | `int d[] = new[3];` in a plain body | dropped | extra | **match** |
| n11 | an OUT-OF-BODY class method | dropped | extra | **match** |
| n12 | an INTERFACE-scope function | dropped | extra | **match** |
| n13 | a PROGRAM-scope function | dropped | extra | **match** |
| n14 | a PARAMETERIZED class handle `a2par#(8) h = new();` | dropped | extra | **match** |
| n15 | a TYPEDEF'd class handle | dropped | extra | **match** |
| n16 | a class PROPERTY `a2c h = new();` (control: not a list) | no statement | same | same |
| n17 | a module-scope variable (control) | no statement | same | same |
| n19 | a `$unit`-scope function | dropped | extra | **match** |
| n20 | an `always` block | dropped | already correct | same |
| n21 | a body whose sole element is a block holding only the decl | `begin@259:7-261:10[]` | same | same |
| n22 | a `while`-loop body block | dropped | already correct | same |
| n23 | a CASE-item block | dropped | already correct | same |
| n27 | a `new` decl then an `int` decl | `[assignment(int x), assignment(fld=x)]` — order preserved | extra | **match** |
| **n24** | **a TF-ITEM body (non-ANSI `input int a;`)** | `method_func_call@253:10` **BARE, no wrapper**, local parented on the TASK | wrapper + extra | **Table B match; Table A still DIFF — § 3 below** |

**n02/n03 are why the pre-existing clause was one term short.** They are the
DYNAMIC-ARRAY twins of the exact two cells the old `NewClass`-only comment cites
(`initial begin C d = new(); end` and SimpleConstraint's `frame_t frame =
new();`). Golden drops them; we kept them and re-parented the `array_var` onto
the surplus assignment.

### 2.3 Arm `a3_count.sv` — DOES A DROPPED ELEMENT STILL COUNT? (12 cells)

a2 produced two cells that no single "drop the element" rule explains: **n07**
(everything dropped → golden keeps an **EMPTY** wrapper, so the dropped element
COUNTED) and **n24** (tf-item body → golden takes **NO** wrapper, so it did
NOT). a3 exists to decide which, and **p03 decides it with a cell that contains
no `new` at all**:

| cell | body | G | post | verdict |
|---|---|---|---|---|
| p01 | 2 uninitialized BLOCK-item decls, no statement | `begin@42:10-42:16[]` | `-NONE-` | **DIFF — pre-existing, no `new`** |
| p02 | 2 uninitialized decls + 1 statement | `begin[assignment]` | same | SAME |
| p05 | 1 uninitialized decl + 1 statement | `begin[assignment]` | same | SAME |
| p10 | uninit decl + `new` decl, no statement | `begin@61:10-61:24[]` | extra → **match** | **DIFF→SAME** |
| p11 | `new` decl + 1 statement | `begin[assignment(fld=a)]` | extra → **match** | **DIFF→SAME** |
| **p03** | **TF-ITEM body, `int x = 5;` + 1 statement** | **`assignment@83:7` BARE — no wrapper, NO assignment for `int x = 5`, `x` parented on the TASK** | wrapper + extra | **DIFF, and NO `new` IS INVOLVED** |
| p04 | TF-ITEM body, 2 statements | `begin[2]` | same | SAME |
| p06 | TF-ITEM body, uninit decl + 1 statement | `assignment@97:7` BARE | same | SAME |
| p07 | TF-ITEM body, `int d[] = new[3];` + 1 statement | `assignment@104:7` BARE | wrapper + extra | Table B **match**, Table A DIFF |
| p08 | TF-ITEM body, `new` decl only | `begin@111:14-111:24[]` | `-NONE-` | DIFF — pre-existing |
| p09 | TF-ITEM body, `int x = 5;` only | `begin@117:14-117:27[]` | `-NONE-` | DIFF — **no `new`** |
| p12 | ANSI-ported task, `int x = 5;` + 1 statement | `begin[2]` | same | SAME |

**p03 and p09 carry no `new` and are already DIFF on the pristine binary**, so
the tf-item family (`§ tfItemDeclNoStmt`, unowned) is a **separate law**: a
`tf_item_declaration` never becomes a body statement at all, whatever its
initializer. n24 / p07 / p08 / p09's residual wrapper is that law's, not this
one's — and **that is exactly why `initCount`/`eff9` were left alone.** Gating
the count would have been an attempt to fix the tf-item law from inside this one,
and n07 (which needs the count kept) and p03 (which needs it dropped) cannot both
be satisfied by a count change. p01 is the same family's block-item cousin.

### 2.4 Arm `a4_memberexpr.sv` — the RESIDUE arm (9 cells)

Built only to make §6 residue 1 precise; it changes no gate. Every cell is
member-level (a class property or a package/module variable with a `new`
initializer), i.e. no statement list at all. **Result: `cmp heads=0, lines=0` —
the whole arm is CMP-EQUAL**, and both sides give `vpiExpr` to all **nine**
measured cells:

| cell | source | G | post |
|---|---|---|---|
| r01 | class property, `= new;` **no parens** (the UVM spelling) | `vpiExpr` YES | YES |
| r02 | class property, `= new()` **with parens** | YES | YES |
| r03 | `const` + no parens (the `uvm_transaction::events` spelling) | YES | YES |
| r04 | `static` + no parens | YES | YES |
| r05 | class property, `= new()` | YES | YES |
| r06 / r07 | PACKAGE-scope variable, no parens / with parens | YES / YES | YES / YES |
| r08 / r09 | MODULE-scope variable, no parens / with parens | YES / YES | YES / YES |

So the "written parentheses" hypothesis for residue 1 is **REFUTED** and the
simple member-level shapes already match; the SimpleUVM deficit is a narrower
shape still unisolated (§6.1).

### 2.5 Arm totals

| arm | pristine | shipped |
|---|---|---|
| `a1_declinit.sv` | A: SAME=39 **DIFF=8** · B: SAME=44 **DIFF=9** UNM=1 | A: SAME=47 **DIFF=0** · B: SAME=53 **DIFF=0** UNM=1 |
| `a2_slots.sv` | A: SAME=31 **DIFF=14** · B: SAME=47 **DIFF=15** | A: SAME=44 **DIFF=1** · B: SAME=62 **DIFF=0** |
| `a3_count.sv` | A: SAME=25 **DIFF=7** · B: SAME=21 **DIFF=6** | A: SAME=27 **DIFF=5** · B: SAME=24 **DIFF=3** |
| `a4_memberexpr.sv` | — | cmp heads=**0**, lines=**0** |

**50 cells moved DIFF→SAME across the three grids; 0 moved SAME→DIFF.** The 8
remaining DIFF cells are the tf-item / empty-wrapper family, and 4 of them
(p01, p03, p09, and n24's wrapper) contain no `new`.

### 2.6 THE REVERSE AUDIT — whole design, SimpleUVM, every subroutine and every variable

| | pristine | shipped |
|---|---|---|
| TABLE A (body signature) | SAME=2862 **DIFF=217** | SAME=2893 **DIFF=186** |
| TABLE B (variable vpiParent) | SAME=4825 **DIFF=620** UNM=101 | SAME=4843 **DIFF=602** UNM=101 |
| cells moved DIFF→SAME | — | **49** |
| cells moved SAME→DIFF | — | **0** |
| **OVER-FIRE** — golden parents a variable on a decl assignment, we do not | **0** | **0** |
| **UNDER-FIRE** — we parent one on an assignment, golden does not | **21** | **3** |

**The three residual under-fires are named, and none of them is a `new`:**

```
uvm_component.svh:3375  function void uvm_component::m_set_cl_verb;      <- NO PARENS -> tf-item body
  3381    static bit first = 1;                                  ordinary constant init
  3383    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();   a FUNCTION CALL init
uvm_component.svh:3462  function void uvm_component::m_set_cl_action;    <- NO PARENS -> tf-item body
  3467    static bit initialized = 0;                            ordinary constant init
```

All three are `§ tfItemDeclNoStmt` (arm a3 p03/p09), and **not one of them has a
`new` on the right**. Zero over-fire and zero under-fire *of this law* across
5,546 measured variable cells.

---

## 3. THE CENSUS-PREDICT, run BEFORE the verifier

`census66.py` scans SOURCE (block comments, line comments and string literals
stripped first) for every site the law can fire on: a declaration, inside a
procedural region, whose written initializer is a `new`. It is deliberately
independent of the patch. It excludes, each for a measured reason: a plain
assignment statement (one name token, no type — a1 m07's family), a member-level
declaration (a2 n16/n17), and a class CONSTRUCTOR's body (a2 n01). Its stated
bound: exact on distinct SOURCE SITES, a LOWER bound on dump-line movers, and it
cannot know whether a file's test compiles. `-v` prints every site and every
skip with its reason, so the classification is auditable rather than trusted —
run on a1 it prints 12 sites and skips a1ctor's with `skip(CONSTRUCTOR body)`.

**PREDICTION (uhdm2rtlil corpus): 0 sites in 0 files → 0 movers, both modes.**

**PREDICTION (UVM 1.2 sources): 61 sites in 19 files** — `uvm_reg.svh` 9,
`uvm_vreg.svh` 6, `uvm_resource_db.svh` 5, `uvm_mem.svh` 5, `uvm_reg_field.svh`
5, `uvm_resource.svh` 4, `uvm_links.svh` 3 (the head's file), `uvm_objection.svh`
3, `uvm_report_message.svh` 3, `uvm_reg_backdoor.svh` 3, and 9 more files.

**PREDICTION (the rest of the Surelog corpus): 220 sites in 58 files, across 17
test directories — and 16 of the 17 produce NO DATABASE.** Read off the
committed READ-ONLY baseline: `AmiqEth`, `Checker`, `Driver`, `ForLoopBind`,
`Ibex`, `Opentitan`, `OVMSwitch`, `SimpleClass1`, `SplitFile`, `Tnoc`,
`UnitAmiqEth`, `UnitClass`, `UVMSwitch` are `SLANG_REJECT` in both modes,
`Google` is `SLANG_REJECT`/`TIMEOUT`, and `ariane`/`black-parrot` are source
directory names with no test row of their own. The **one** site-bearing directory
that compiles is **`SimpleConstraint`** (`CMP_EQUAL`/`differ` both modes) — and
its single site is
`tests/SimpleConstraint/top.sv:51  initial begin frame_t frame = new();`, a
WRITTEN block with a class `new()`, **already covered by the pre-existing
clause → PREDICTED NOT TO MOVE.**

**BlackParrotComplex, checked BY NAME because it is a named canary:** its own
directory has **0 sites** and its `.sl` compiles only `dut.sv` (the two
`black-parrot/…/regression_non_blocking/cov_*.v` sites are not in its source
set) → **PREDICTED NOT TO MOVE.**

**PREDICTED MOVER SET, recorded before the byte verifier ran: 7 databases —**
`default/{BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM}` and
`testflags/{BuildUVMPkg, SeqDriver, SimpleUVM}` (Scoreboard/testflags is
SLANG_REJECT). Same set, and for the same reason, as r10uvm65's, whose
enumeration of the 28 UVM-referencing `.sl` files this pass reuses rather than
re-derives.

**THE VERIFIER FOUND EXACTLY THOSE 7, and 0 in u2r.** SimpleConstraint did not
move. BlackParrotComplex did not move.

---

## 4. THE MOVERS, PER SHAPE, BY MULTISET

All 7, `mv66.sh` (LHS always golden). **ADDED and REMOVED are never netted.**

| mover | multiset distance to golden, pristine → patched | ADDED | REMOVED |
|---|---|---|---|
| `default/BuildUVMPkg` | 81030 → 80345 (**gain 685**) | 44 | 1037 |
| `default/Scoreboard` | 134669 → 134025 (**gain 644**) | 49 | 1195 |
| `default/SeqDriver` | 367482 → 366876 (**gain 606**) | 73 | 1643 |
| `default/SimpleUVM` | 144362 → 143692 (**gain 670**) | 49 | 1211 |
| `testflags/BuildUVMPkg` | gain 685 | 44 | 1037 |
| `testflags/SeqDriver` | gain 606 | 73 | 1643 |
| `testflags/SimpleUVM` | 144358 → 143688 (gain 670) | 49 | 1211 |

**Every mover moves TOWARD golden.** SeqDriver's larger figures are the
PACKAGE-CLONE view (`package adpcm_pkg; import uvm_pkg::*;`), whose class-method
clones carry the same declarations again — one predicate on the shared body path
covers the def view, the elab view, the out-of-body hoist and the clone view from
one place.

### 4.1 The ADDED lines are the re-parenting half, and all 48 land EXACTLY on golden

`SimpleUVM/default`, all 48 distinct added texts: **48 landed at exactly golden's
count, 0 above golden, 0 still below.** Every one is a `\_begin:` header printed
as the variable's new `vpiParent` back-reference, e.g.

```
[        \_begin: (uvm_pkg::uvm_cause_effect_link::get_link), line:255:7, endln:255:29]  golden=1  pristine=0  patched=1
[      \_begin: (uvm_pkg::uvm_mem::do_read),  line:1686:4, endln:1686:30]                golden=2  pristine=1  patched=2
[      \_begin: (uvm_pkg::uvm_reg::do_read),  line:2402:4, endln:2402:30]                golden=6  pristine=5  patched=6
```

Nothing was minted that golden lacks, and nothing overshot.

### 4.2 THE REMOVED LINES — and the instrument that had to be fixed first

`mv65.sh` three-way-counts only ADDED texts, because § 65 was add-only. For a
DELETE the dangerous error is the mirror image — deleting PAST golden — so this
pass wrote `mvrem66.sh`. **Its first rule (`patched < golden ⇒ OVER-DELETE`) was
wrong and it fired 24 times on BuildUVMPkg alone.** Reading the rows showed two
distinct reasons, and both are now buckets in the script:

1. **ALREADY-SHORT.** e.g. `|vpiParent:` at one indent: golden 11599, pristine
   **11384**, patched 11380. Ours was already 215 short *before* the patch; a
   multiset cannot say whether the instance removed was the surplus one or a
   needed one, so this is **NOT DECIDABLE HERE** and is counted, never called a
   defect.
2. **THE INDENT LIFT.** Deleting an enclosing `assignment` raises every surviving
   descendant by two spaces. A verbatim-keyed multiset reads that ONE move as a
   removal at indent N+2 and an addition at indent N. mv65.sh's verbatim keying —
   correct for an add, where nothing moves — is **wrong for a structural
   delete**, so `mvrem66.sh` now reports an **INDENT-BLIND** keying as well and
   treats it as the authority.

| database | VERBATIM | INDENT-BLIND |
|---|---|---|
| `default/BuildUVMPkg` | 392 texts · SURPLUS-ONLY 361 (333 exactly golden) · CROSSED **11** · ALREADY-SHORT 20 | 176 texts · SURPLUS-ONLY 161 (148 exactly golden) · CROSSED **1** · ALREADY-SHORT 14 |
| `default/SimpleUVM` | 409 · 369 (345) · **18** · 22 | 186 · 162 (154) · **2** · 22 |
| `default/Scoreboard` | 407 · 366 (344) · **19** · 22 | 184 · 161 (154) · **2** · 21 |
| `default/SeqDriver` | 449 · 369 (353) · **28** · 52 | 214 · 176 (169) · **15** · 23 |

**Every surviving INDENT-BLIND crossing was then decomposed, and each is a
PRE-EXISTING deficit the patch does not touch.** Two families, both measured:

**(a) `\_method_func_call: (new)` / `|vpiName:new` / `|vpiConstType:6`.**
SimpleUVM `\_method_func_call: (new)`: golden 702, pristine 791, patched 693.
Split by the field the occurrence hangs under:

| field | golden | pristine | patched |
|---|---|---|---|
| `\|vpiRhs:` (a `new` as an assignment's Rhs) | 341 | 398 | **343** |
| `\|vpiParent:` (back-reference re-prints) | 320 | 362 | **319** |
| `\|vpiExpr:` (a `new` on a VARIABLE) | **41** | **31** | **31 — UNCHANGED** |

The Rhs population went from +57 surplus to **+2**; the whole −9 total is the
`vpiExpr` deficit of **10**, which the patch moves by **zero** and which was
previously *masked* by the +89 surplus. § 6 residue 1.

**(b) `\_ref_var:`/`\_class_var:` at `golden=8 pristine=8 patched=6`, SeqDriver
CLONE view only.** Decomposed the same way, for
`adpcm_pkg::uvm_reg::add_hdl_path::concat`:

| field | golden clone | pristine | patched |
|---|---|---|---|
| `\|vpiVariables:` | 4 | 4 | 4 |
| `\|vpiParent:` | **4** | **2** | **2 — UNCHANGED** |
| `\|vpiLhs:` (the surplus decl assignment) | **0** | 2 | **0** |

The patch removed exactly the 2 occurrences golden does not have; the 2-occurrence
`vpiParent` deficit **pre-dates it and is unchanged**. And the HOME view of the
same variable is now **exactly golden**: `uvm_pkg::uvm_reg::add_hdl_path::concat`
golden 12, pristine 14, patched **12**. § 6 residue 3.

**THE AUTHORITY ON WHETHER ANYTHING GOLDEN HAS WAS DELETED IS THE PER-OBJECT
AUDIT, NOT THE MULTISET: OVER-FIRE = 0 across 5,546 variable cells (§2.6), and
uhdm-cmp's head cleared.**

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

`/tmp/wt_r10uvm66/build` and `/tmp/wt_r10uvm66pris/build`, absolute.
`[100%] Linking CXX executable slang-uhdm` then `[100%] Built target slang_uhdm`
read before any measurement. md5s asserted in their own commands and matched
against `^[0-9a-f]{32}$`: control `c7f318688961a24d51d9a4d958bcf2ad`, shipped
`a79347834ca32a31f144147b9734a469`. Both worktrees at
`3076437e5f47ab92f85712b8139cf5c41115b0da`. Declared/defined/called check:
1 declaration, 1 definition, **2** call sites.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped> ./tests/check_goldens.sh   ->  PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh  ->  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--jobs 2`, own `--out`/`--workdir`

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
dump column:            match 496        differ 183         (blank) 52
ct8rows.sh vs results/gate_uhdm2rtlil.csv (testflags-only extract, 731 rows both sides):
  WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  PASS: every row byte-identical to the committed baseline
[default]   731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
            dump: match 492  differ 187  (blank) 52   (no committed baseline for this mode)
```

The default-mode rows are reported as ADDED by a naive whole-CSV comparison
because the committed baseline is testflags-only (731 rows, not 1462); the row
gate above was therefore run on a testflags-only extract, and the fact is stated
rather than hidden.

### GATE 4 — surelog, both modes, `--jobs 2`, `GOLDEN_DEFER` echoed `[UNSET]`

```
[default]   794 tests  CMP_EQUAL 467  CMP_NOTEQUAL 13  DEFERRED 5  SLANG_REJECT 284  SURELOG_FAIL 25
[testflags] 794 tests  CMP_EQUAL 463  CMP_NOTEQUAL 10  DEFERRED 5  SLANG_REJECT 286  SURELOG_FAIL 23
                       NO_DATABASE 3  UNTRANSLATABLE 2  TIMEOUT 1  NO_UHDM 1
ct8rows.sh vs results/golden_surelog.csv:
  1588 ROWS both sides · WHOLE-ROW diff: 0 differing ROWS
  per-mode STATUS histograms: identical    per-mode DUMP histograms: identical
    default   327 blank / 242 differ / 225 match      (baseline and fresh)
    testflags 331 blank / 298 differ / 165 match      (baseline and fresh)
  PASS: every row byte-identical to the committed baseline
```

The pristine control sweep produced the **same** histograms in both modes, so the
status figures are a property of the corpus and not of either binary.

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs the PRISTINE 3076437 I built

```
surelog  : PATH_SETS_IDENTICAL (953 paths)    MOVERS: 7 / 953
           SELFCHECK 952/953 flagged          SELFCHECK1 = 8  (= 7 real + 1 corrupted)
u2r      : PATH_SETS_IDENTICAL (1358 paths)   MOVERS: 0 / 1358
           SELFCHECK 1357/1358 flagged        SELFCHECK1 = 1  (= 0 real + 1 corrupted)
```

Both negative controls fire in both corpora, so "0 movers" in u2r is a
measurement and not a mis-wired driver. The 7 are the predicted set exactly.

### MULTI-STABILITY, and the size delta

`detcheck.sh`, `Scoreboard/default`, 3 runs each:

| binary | distinct sha256 | bytes (all runs) |
|---|---|---|
| pristine `c7f31868…` | **3** | 11 133 116 |
| shipped `a7934783…` | **2** | 11 122 503 |

The hash flake is **PRE-EXISTING and worse on the pristine binary** — the
campaign's known emitter nondeterminism (SourceLocation compares across macro
buffers under parallel parse). Per the standing rule, **same size = flake**: the
size is stable within each binary across all three runs, so nothing here was
introduced or fixed by this pass.

**The flake lands on exactly the UVM databases, which are exactly the 7 byte
movers — so the byte compare ALONE could not have established that the 7 are
real.** It does not have to: the movers are established by DUMP CONTENT (§4:
1037–1643 removed and 44–73 added line instances each, all 48 added texts at
golden's count), by the cleared `uhdm-cmp` head on three of them, and by the
per-object audit. The remaining 946 surelog and 1358 u2r databases are
byte-identical across the two binaries, which is also what shows the flake does
not reach them.

The size DELTA is stable and real: **−10 613 bytes** on Scoreboard, in the
expected direction for a DELETE law (and UHDM's packed capnp encoding means size
is not monotonic in content either way — the dump is the content authority).

### CANARIES

```
canaries.sh  vs surelog baseline : ok=52  changed=0  absent=0  unknown-names=7  (the u2r-only names)
canaries.sh  vs u2r baseline     : ok=8   changed=0  absent=0  unknown-names=25 (the surelog-only names)
ctcan2.sh EXPECT_UNKNOWN=1 (sl)  : ok=58  changed=0  absent=0  unknown-patterns=1   PASS
ctcan2.sh EXPECT_UNKNOWN=6 (u2r) : ok=1   changed=0  absent=0  unknown-patterns=6   PASS
canaudit.sh canaries.sh ctcan2.sh: audited=29  UNCOVERED=0  FENCE-BREACH=0        PASS
BY NAME InterfaceModPort    default CMP_EQUAL/differ  testflags CMP_EQUAL/differ  == baseline
BY NAME BlackParrotComplex  default CMP_EQUAL/differ  testflags CMP_EQUAL/differ  == baseline
BY NAME SimpleConstraint    default CMP_EQUAL/differ  testflags CMP_EQUAL/differ  == baseline (predicted §3)
BY NAME SVSwitch / ApbSlave / SeqDriver / BuildUVMPkg / SimpleUVM / Scoreboard    == baseline (canaries.sh rows)
```

Both canary scripts were run against **both** baselines, mode-matched, and the
expected-unknown counts were stated to the scripts rather than read back out.

---

## 6. RANKED RESIDUES

1. **`vpiExpr` on a variable whose initializer is a `new` — golden 41
   occurrences, ours 31, on SimpleUVM.** UNCHANGED by this pass (31 before, 31
   after) and previously masked by a surplus; it is what every remaining
   indent-blind `new`-family crossing decomposes to (§4.2a). Golden's 26 distinct
   owners are all member-level (`uvm_printer::knobs`, `uvm_comparer::scope`,
   `uvm_transaction::events`, `uvm_pkg::uvm_default_*_printer` and their
   `work@env` / `work@top` views), and all are written `= new;` with no
   parentheses. **But arm a4 REFUTES the parentheses hypothesis**: nine
   member-level cells, with and without parens, `const`, `static`, class-,
   package- and module-scope, are **all CMP-EQUAL with golden (0 heads)** and all
   carry `vpiExpr` on both sides. So the deficit is a narrower UVM-specific shape
   not yet isolated, and isolating it is the next investigation on this family.
2. **§ tfItemDeclNoStmt (unowned) — a `tf_item_declaration` never becomes a body
   statement, whatever its initializer.** Golden gives a TF-ITEM body (non-ANSI
   `input`, or a definition written with NO PARENTHESES at all) no declaration
   assignment, no wrapper `begin` when one statement survives, and parents the
   local on the SUBROUTINE. Measured on cells with **no `new` in them** (a3 p03,
   p09) and on the corpus itself: the 3 residual whole-design under-fires are
   `uvm_component::m_set_cl_verb` / `m_set_cl_action`, whose initializers are
   `= 1`, `= 0` and `= uvm_cmdline_processor::get_inst()`. Also owns a2 n24's and
   a3 p07/p08's residual wrapper.
3. **The PACKAGE-CLONE view lists a body local under 2 fewer `vpiParent`
   back-references than golden** (`adpcm_pkg::…::concat`, `…::cbs`: golden 4,
   ours 2, unchanged by this pass), while the HOME view is now exactly golden
   (12 = 12). SeqDriver only, 12 sites; § pkgCloneHierBind9's family.
4. **The new head on all three target rows** (33 cmp lines): a folded `constant`
   `115199` at `410:30-410:60` under a `param_assign`, with a
   `ref_typespec (uvm_pkg)` → `int_typespec @410:1-410:62`. A typespec/fold
   family, not a statement family. **It is pre-existing and was masked**: it lies
   nowhere near any object this patch touched.
5. **A body of only UNINITIALIZED block-item declarations gets an EMPTY `begin`
   in golden and none from us** (a3 p01: golden `begin@42:10-42:16[]`, ours
   `-NONE-`; and the tf-item twins p08/p09). No `new` involved; the current
   `eff9 == 0 → no wrapper` branch is the site, and touching it was explicitly
   out of scope here because n07 and p03 constrain the count in opposite
   directions (§2.3).
6. **186 remaining TABLE-A DIFF cells and 602 TABLE-B DIFF cells on SimpleUVM**,
   after 49 moved the right way and 0 the wrong way. Not triaged here; the two
   law-specific columns (OVER-FIRE, UNDER-FIRE) are 0 and 3.

---

## 7. REFUTATIONS, stated plainly

1. **MY OWN REMOVED-LINE INSTRUMENT WAS WRONG, AND IT WAS WRONG IN THE DIRECTION
   THAT WOULD HAVE CONDEMNED A CORRECT PATCH.** `mvrem66.sh` v1 flagged 24
   "OVER-DELETE" rows on BuildUVMPkg. Every one was either a text ours was
   already short of before the patch, or the two-space indent lift a structural
   delete causes. Fixed to three buckets plus an indent-blind keying before any
   of its numbers were used. mv65.sh's verbatim keying is correct for an ADD and
   wrong for a DELETE, and that had to be discovered rather than inherited.
2. **"§ thisSuperNewAssignNoStmt3 owns `new` assignments; this must be the same
   law."** Refuted by a1 m07, and it is why both laws exist: `ce = new(name);`
   written as a STATEMENT over a bare local is **KEPT** by golden, while
   `a1c ce = new(name);` written as a DECLARATION is **DROPPED**. § 3 needs a
   `this`/`super` LHS keyword; § 66 needs no LHS at all. Same RHS vocabulary,
   different laws.
3. **"Apply it at every site that builds a declaration assignment."** Refuted by
   a2 n01: a constructor **WITH A PORT LIST** (so § 27's element shift is out of
   the way) KEEPS the assignment in golden and parents the local on it. a1's
   port-less constructor cell agreed with us for the wrong reason and reads
   UNMEASURED. `emitCtorBody27`'s EK_BID arm is deliberately left alone.
4. **"The existing block-path clause already had this law."** It had *half* of
   it: `ExpressionKind::NewClass` only. a2 n02/n03 — the DYNAMIC-ARRAY twins of
   the exact two cells its own comment cites — show golden drops `new[3]` in a
   written `begin` and in a module `initial` too, while we kept it and re-parented
   the `array_var` onto the surplus assignment. One predicate now serves both
   forms from both sites.
5. **"It is a class-handle law" / "it is a `new[]` / dynamic-array law."** Both
   refuted, in both directions: a class handle from a function call (m06) or from
   `null` (m17) KEEPS its assignment; a queue from a concatenation (m21) keeps
   its own; a dynamic array from `new[3]` (m08, n10b) drops it. Neither the
   `class_var` nor the `array_var` is a term — the written `new` is.
6. **"The drop should also remove the element from the wrapper count."** Refuted
   by a2 n07: a body whose EVERY element is a `new`-initialized declaration keeps
   golden's wrapper and it is **EMPTY**, with both locals parented on it. And a3
   p03 shows the opposite constraint on tf-item bodies is a *different law* —
   with **no `new` in the cell at all** — so no count change can satisfy both.
   `initCount`/`eff9`/the anchor are untouched.
7. **"A `new` with no parentheses is a different construct."** Refuted: a2 n09
   (`a2c ce = new;`) drops exactly like `new()` and `new(arg)`. Reading the
   SyntaxKind rather than an argument list is what makes that free.
8. **"The remaining `\_method_func_call: (new)` deficit means we deleted a call
   golden keeps."** Refuted by decomposition (§4.2a): the `vpiRhs` population
   went from +57 surplus to +2, and the entire residual −9 is a **`vpiExpr`
   deficit of 10 that the patch does not move at all** (31 → 31). The multiset
   had been hiding it behind the surplus.
9. **"Residue 1 is the written parentheses at member level."** Refuted by my own
   arm a4: nine member-level cells with and without parens, `const` and `static`,
   in class, package and module scope, are **all CMP-EQUAL** and all carry
   `vpiExpr` on both sides. The hypothesis is dead; the residue is real and its
   discriminator is still unknown.

---

## 8. FILES

| file | what it is |
|---|---|
| `a1_declinit.sv` | 24 cells: WHICH INITIALIZER — `new`/`new()`/`new(arg)`/`new[n]` against int, string, expression, ref, function call, `null`, queue-concat, `automatic`; the statement-vs-declaration control (m07); two-decl and decl-then-return orders |
| `a2_slots.sv` | 26 cells: WHICH SLOT and WHICH `new` — the ported CONSTRUCTOR (n01), the dynamic-array twins of the pre-existing clause's own cells (n02/n03), no-parens and copy forms, all-dropped and mixed bodies, fork/for/while/case/initial/always, out-of-body, interface, program, `$unit`, parameterized and typedef'd handles, member-level controls, the tf-item body |
| `a3_count.sv` | 12 cells: DOES A DROPPED ELEMENT STILL COUNT — and p03/p09, which answer it with cells containing no `new` |
| `a4_memberexpr.sv` | 9 cells: the RESIDUE arm — member-level `new` initializers, with/without parens, `const`/`static`, class/package/module scope. Result: CMP-EQUAL, hypothesis refuted |
| `ct66arm.sh` | one-arm driver: golden + ours, `sed 1d` both dumps, cmp head DEPTH, dump-diff content, unsupported count |
| `ct66cells.py` | the grid: TABLE A ordered body statement list, TABLE B variable `vpiParent`; fullest occurrence, own-child indent, kind+fullname keys, `-NOOBJ-`/UNMEASURED |
| `census66.py` | the census-predict: source-only fire sites with comments/strings stripped, procedural-depth and constructor exclusions, `-v` audit mode, its own stated bound |
| `mv66.sh`, `msdist.sh` | per-shape movers: multiset distance, ADDED/REMOVED never netted, three-way count of every ADDED text |
| `mvrem66.sh` | **NEW this pass** — the three-way count of every REMOVED text, in three honest buckets (SURPLUS-ONLY / CROSSED / ALREADY-SHORT) under BOTH a verbatim and an INDENT-BLIND keying. Written because mv66.sh's add-only instrument cannot police a delete |
| `rowheads.sh` | cmp lines + head count for a named subset of a workdir |
| `ct8rows.sh` | the row gate: whole-ROW diff vs the committed baseline + status/dump histograms |
| `byteverify.sh`, `manifest.sh` | the byte verifier with both negative controls |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canaries and the audit of the canaries |
| `detcheck.sh` | determinism: N runs, distinct hashes, sizes |
