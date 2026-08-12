# r10uvm59 — the head **CLEARED AND ADVANCED** on BOTH BuildUVMPkg rows, and **MY BRIEF'S WEAKEST LINK — "I HAVE NOT VERIFIED WHAT OUR SIDE EMITS AT 14104" — WAS MEASURED FIRST AND CAME BACK *CONFIRMED*, NOT REFUTED**

**FIRST LINE, as the brief demands.** `BuildUVMPkg` **DID NOT CONVERT**: it is
`CMP_NOTEQUAL` in both modes before and after, and the surelog scoreboard is
**unchanged at 467/13 (default) + 463/10 (testflags)**, `0` differing ROWS
against the committed baseline.  What DID happen is that its head **cleared and
advanced in both modes** (15 → **58** cmp lines, 1 head throughout):

```
BuildUVMPkg,default,CMP_NOTEQUAL,decompile:,,
BuildUVMPkg,testflags,CMP_NOTEQUAL,decompile:,,
```

(both rows quoted verbatim from `/tmp/r10uvm59/g4/sl.csv`, and byte-identical to
`results/golden_surelog.csv` lines 170-171 — which is the definition of "no
conversion", so the conversion-adjusted gate numbers do **not** apply.)

The briefed head is **gone**, on both rows, and the object it named is now
present with **every compared field equal**:

| shape (indentation stripped, `grep -Fxc`) | golden | pristine | FINAL |
|---|---|---|---|
| `\_ref_obj: (uvm_pkg::uvm_registry_common::__deferred_init::Tregistry::get), line:14104:24, endln:14104:35` | **1** | 0 | **1** |

ONE law landed — **§ typeParamScopedCallRef59** — **7 byte movers** (the same
seven UVM row-modes pass 58 moved), **109 ADDED line instances, 0 REMOVED**,
**every distinct object shape covered by golden, 0 real OVER-FIRES**, and the
NEGATIVE-CONTROL arm's database **byte-identical** before and after.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**  `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `arm59.sh` prints that it did on every run.

Base **81b8e0c**.  Worktree `.claude/worktrees/r10uvm59`; pristine control
worktree `.claude/worktrees/r10uvm59pris`, configured and built by me at the same
commit.  `git -C .claude/worktrees/r10uvm59 rev-parse HEAD` and the same for
`…pris` both print `81b8e0c0f3dc63a2aa935fbda8f3196c1d6292f4`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 81b8e0c) | `7922a457a58565ff014f9c440b585eb6` | my own build of 81b8e0c — **byte-identical to the main tree's `build/slang-uhdm`**, which is what makes it a valid control |
| v1 (one call site, + a temporary instrument) | `1681b2c0cd4a27d3da7e690cb434db48` | the arm-measurement binary; **never gated, never shipped** |
| **FINAL (shipped)** | **`167d5696053b4b58b4e85c9cf168fcd5`** | every gate number below was measured on THIS binary |

`git stash` was never used.  `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **READ ONLY** — row counts are
lines-minus-one because `wc -l` counts the header.  The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched (`canaudit.sh`: FENCE-BREACH=0).  `GOLDEN_DEFER` left at default:
**5 DEFERRED** in both surelog modes, as in the baseline.

**ONE OPS SLIP, DISCLOSED.** My first edit of `src/ExprEmit.cpp` went to the MAIN
TREE instead of my worktree.  It was caught within minutes by the md5 assertion
(the worktree relinked to a byte-identical binary, which is impossible for a real
edit), moved to the worktree with `git apply`, and the main tree restored with
`git checkout -- src/ExprEmit.cpp`.  `git show 81b8e0c:src/ExprEmit.cpp | md5sum`
and `md5sum src/ExprEmit.cpp` in the main tree both read
`415efa3b4bc01fdb16f86e87da171c8d`, and the main tree's `build/slang-uhdm` was
never rebuilt (mtime 07:36, md5 `7922a457…` = the pristine control).  No gate ran
against a contaminated tree.

---

## 0. THE LAW, in a form a future pass can grep for

**§ typeParamScopedCallRef59** — *a `::`-scoped reference **slang REFUSED TO
BIND** is golden's SAME bare unbound `ref_obj` that § staticScopedCall12 already
builds for the bound case: `vpiName` = **FIRST written segment** `::` **FINAL
identifier**, `vpiFullName` = the caller's prefix joined to that, span = the
scoped name's start **up to (NOT including) the final identifier** — the
qualifier `Tregistry::` alone — no `vpiActual`, and **everything hung off the
reference DROPPED** (the arguments, a `.member` chain, a select, and a nested
type-parameter call used as an argument).*

* **DIRECTION**: **ADD ONLY.** It turns a `return nullptr` into an object.  It
  reshapes nothing and deletes nothing — measured: **0 REMOVED line instances**
  across all 7 movers.
* **PREDICATE**: `invalidScopedNameSyntax59` (`src/ExprEmit.cpp` ~506).
* **STATED GATE == CODE GATE.**  Read off the source, not the comment, four
  conjuncts and nothing else:
  1. `e.kind == ExpressionKind::Invalid`;
  2. `!e.as<InvalidExpression>().child` — a child means slang salvaged a
     sub-expression and the plain unwrap / § droppedCall14 own it;
  3. `scopedChainRootName48(e.syntax)` returns non-null — i.e. the syntax, after
     unwrapping parentheses, invocations, element selects and DOT-separated
     scoped names, roots in a **`::`-separated** `ScopedName`;
  4. `splitScopedName12` succeeds on it (two identifier segments).
* **OBJECT BUILDER**: `UhdmExporter::invalidScopedCallRef59` (`src/ExprEmit.cpp`
  ~673) — field for field the same object as § staticScopedCall12's tail.
* **TWO CALL SITES, both of which returned `nullptr` before it**:
  * `src/ExprEmit.cpp` ~15657, the `case ExpressionKind::Invalid` arm, placed
    **after** the child unwrap, **after** § droppedCall14 and **after**
    § invalidNewCallFromSyntax55, immediately **before**
    `noteUnsupportedAt("expression kind: Invalid")`;
  * `src/UhdmExporter.cpp` ~623, `emitClassPropInit29`, placed **before** its
    `if (ic.kind != ExpressionKind::Call) return;` — the early return that made
    § classPropScopedCallIsRefObj29 unreachable for an unbound qualifier.
* `grep -rn 'typeParamScopedCallRef59\|invalidScopedNameSyntax59\|invalidScopedCallRef59' include/ src/`
  → **11 hits across 3 files**.

### The decoded slang mechanism (read, not guessed)

`<Tparam>::<method>(...)` inside a generic class's **DEFAULT** specialization is
unresolvable by construction: UVM writes
`class uvm_registry_common #(type Tregistry=int, type Tcreator=int, …)`, so slang
looks `get` up in `int`, finds nothing, and returns `badExpr` — an
`InvalidExpression` with a **NULL child**, an **EMPTY** `sourceRange`, and the
original syntax still attached (`Expression::create`'s tail
`result->syntax = &syntax;`).  Inside a generic class slang's diagnostics are
suppressed, so the database still builds and the loss is **silent**.  This is the
same failure mode § invalidNewCallFromSyntax55 decoded for `x = new()`, at a
different construct.

Surelog resolves **nothing** through `::`: its class_scope arm yields the bare
`ref_obj` whatever the qualifier turns out to be.  **So the whole difference is
the BIND**, and the law's only job is to reach the same object from the SYNTAX.

### Why the gate is NOT "the qualifier is a type parameter"

Because golden does not care, and neither does slang's failure.  The gate keyed on
the SYNTAX rather than on the qualifier is a **measurement result**, not a
convenience:

* arm **a4** — golden emits the identical object for **all nine** bindings a type
  parameter can take, and our side already got the **two** that slang binds
  right through § staticScopedCall12 (§3.3);
* arm **a3 S3** — a type parameter bound to a class that **HAS** the method is
  golden `ref_obj Tcreator::get` **and ours**, pristine and final alike (§3.2);
* so a qualifier test would have to enumerate exactly the set slang fails on,
  which is the set this predicate already **is**.

---

## 1. THE BRIEF'S WEAKEST LINK, MEASURED FIRST — **CONFIRMED**

The brief said: *"`RHS: <null>` CAN BE A SafeCompare ARTEFACT … your first
measurement should confirm or refute it."*  It was **confirmed**: the object is
genuinely absent, and the census is span-keyed on both sides with the whole
subtree printed.

`\_assignment: , line:14104:16, endln:14104:40`, **field list at its own child
depth** (`rhsown59.py`, the committed prover):

```
object @14104:16   field under test: vpiRhs
   g.dump        vpiRhs=YES  fields=['vpiParent','vpiOpType','vpiBlocking','vpiRhs','vpiLhs']
   o_pris.dump   vpiRhs=NO   fields=['vpiParent','vpiOpType','vpiBlocking','vpiLhs']
   o_v2.dump     vpiRhs=YES  fields=['vpiParent','vpiOpType','vpiBlocking','vpiRhs','vpiLhs']
```

and the whole-database name census, which is the stronger statement:

| | golden | pristine |
|---|---|---|
| lines containing `Tregistry::get` in the BuildUVMPkg dump | **15** | **0** |
| objects at `line:14104:24` (either kind) | **1** | **0** |

**Nothing on our side named `Tregistry::get` existed anywhere in the design.**
The assignment carried a `vpiLhs` and no `vpiRhs` at all.  Not a one-sided vector
element, not a SafeCompare artefact — a missing object.  Recorded plainly because
the brief was right to demand it be checked and the campaign has twice been
burned by the opposite finding.

### 1.1 What the pp-source line actually is, read before anything was built

`third_party/UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv:14104`, columns counted
mechanically:

```
     Tregistry rgtry = Tregistry::get();
     ^col 6    ^16   ^22 ^24      ^35
```

so golden's span `14104:24 … 14104:35` is **`Tregistry::` and nothing else** —
start of the qualifier through one past the `::`, which is the column the final
identifier `get` starts at.  Every measured cell in every arm agrees to the
character (§3).

### 1.2 The FIVE corpus sites, and the ONE that is blocked by somebody else's bug

`class uvm_registry_common` writes the shape five times.  Per-shape `grep -Fxc`,
indentation stripped:

| pp line | source | golden | pristine | FINAL |
|---|---|---|---|---|
| 14073 | `factory.set_type_override_by_type(Tregistry::get(),…)` ARGUMENT | 1 | 0 | **1** |
| 14088 | `factory.set_inst_override_by_type(Tregistry::get(),…)` ARGUMENT | 1 | 0 | **1** |
| 14096 | `Tregistry rgtry = Tregistry::get();` in a NESTED `begin` | 1 | 0 | **0** |
| 14104 | `Tregistry rgtry = Tregistry::get();` static fn — **THE HEAD** | 1 | 0 | **1** |
| 14120 | `Tregistry rgtry = Tregistry::get();` virtual fn | 1 | 0 | **1** |

**14096 is NOT this law's failure and I predicted it before measuring it.**  Its
enclosing `if`-branch `begin` loses **both** of its declarations on our side —
including the CONCRETE `uvm_factory factory = uvm_factory::get();` one line above,
which this law never touches.  Golden's inner `begin @14094:63-14100:9` lists two
`vpiVariables` and three `vpiStmt`; ours lists **zero variables and one
statement**.  Arm `a1_witness`'s `set_type_alias` cell reproduces it exactly (both
its cells missing, concrete and type-parameter alike) and it is residue **R2**.

Two more 1800.2 sites the brief did not name, both now correct:

| pp line | source | golden | pristine | FINAL |
|---|---|---|---|---|
| 14058 | `obj = Tcreator::create_by_type( Tregistry::get(), …)` — the brief's NESTED cell | 1 | 0 | **1** |
| 61837 | `t = BUSTYPE::type_id::create("t");` — **THREE** segments | 1 | 0 | **1** |

61837's golden name is **`BUSTYPE::create`** — the middle segment `type_id`
DROPPED — spanning `61837:11-29` = `BUSTYPE::type_id::`.  That is
§ splitScopedName12's documented behaviour and it needed no new code.

---

## 2. THE GRID, CELL FOR CELL

Every cell measured with the control binary and again with the FINAL binary, by
`cells59.py`, which keys on `(UHDM class, fullname, span)` and **counts
multiplicities** (an object is not a dump occurrence).  Golden is always argv[1].

### 2.1 POSITION (arm `a2_position`) — thirteen positions of ONE spelling

golden emits the SAME object in **every** one of them.

| cell | source | golden object + span | ours PRE | ours FINAL |
|---|---|---|---|---|
| P1 assignment RHS | `Tregistry a = Tregistry::get();` | `ref_obj Tregistry::get` @43:21-32 | **ABSENT** | **=golden** |
| P2 bare STATEMENT | `Tregistry::get();` | @49:7-18 | ABSENT | **=golden** |
| P3 `if` CONDITION | `if (Tregistry::get() != null)` | @54:11-22 | ABSENT | **=golden** |
| P4 call ARGUMENT | `f.note(Tregistry::get(), nm)` | @61:14-25, parented at `method_func_call note` | ABSENT | **=golden** |
| P5 **NESTED** | `Tcreator::create_by_type(Tregistry::get(), nm)` | **ONE** `ref_obj Tcreator::create_by_type` @66:21-31 — **the inner call is GONE in golden too** | ABSENT | **=golden** |
| P6 RETURN | `return Tregistry::get();` | @72:14-25 | ABSENT | **=golden** |
| P7 binary OPERAND | `bit b = (Tregistry::get() != null);` | @77:16-27 | ABSENT | **=golden** |
| P8 **NO PARENS** | `Tregistry a = Tregistry::sprop;` | `ref_obj Tregistry::sprop` @83:21-32 — same span rule | ABSENT | **=golden** |
| P9 **WITH ARGS** | `Tregistry::getn(1, "a")` | `ref_obj Tregistry::getn` @89:21-32, **args dropped** | ABSENT | **=golden** |
| P10 CHAIN off the call | `Tregistry::get().ok()` | **ONE** `ref_obj Tregistry::get` @95:15-26 | ABSENT | **=golden** |
| P11 FOR body | inside `for (int i…)` | @102:23-34 | ABSENT | **=golden** |
| P12 **CLASS PROPERTY init** | `Tregistry m_prop = Tregistry::get();` | @108:24-35, `vpiExpr` of the property's `int_var`, fullname `…::m_prop::Tregistry::get` | ABSENT | **=golden** |
| P13 INSTANCE method | non-static | @112:21-32 | ABSENT | **=golden** |

`cells59.py`: **13 differing cells → 0 differing cells.**  P12 is the cell that
forced the **second call site**: it is emitted by `emitClassPropInit29`, not by
`emitExpr`, and after the first binary it was the arm's only remaining head.

### 2.2 SCOPE (arm `a3_scope`) — **the discriminator**

| cell | qualifier is | golden | ours PRE | ours FINAL |
|---|---|---|---|---|
| S1 | a CONCRETE class | `ref_obj base59::get` @53:18-26 | **=golden** | =golden |
| **S2** | a **TYPE PARAMETER** with no such method | `ref_obj Tregistry::get` @59:21-32 | **ABSENT** | **=golden** |
| **S3** | a **TYPE PARAMETER bound to a class that HAS it** | `ref_obj Tcreator::get` @65:20-30 | **=golden** | =golden |
| S4 | a TYPEDEF ALIAS to a class | `ref_obj alias59::get` @71:18-27 | =golden | =golden |
| S5 | a **PACKAGE** | `func_call p59a3::pf59` **with its arguments** | =golden | =golden |
| S6 | THREE segments through a type parameter | **UNMEASURABLE** — `p59a3::Tregistry::get()` is a slang HARD ERROR ("no member named 'Tregistry' in package 'p59a3'") and rejects the whole design.  Recorded, not hidden. |
| S8 | an **EXTERN / out-of-body** static method | `func_call extern59::eget` (§ classScopeCallOfOutOfBodyMethodIsFuncCall26) | =golden | =golden |

**S3 is the cell that fixes the law's shape.**  Golden's `ref_obj` does not depend
on the binding, and the bound half was already right, so the gate must be "slang
failed", not "the qualifier is a type parameter".  **This arm is now CMP EQUAL:
15 cmp lines / 1 head → 0 / 0.**  (Its two remaining `cells59.py` rows are the
`extern59::eget` prototype-vs-definition return-var duplication — pass 58's
residue R5, pre-existing, `int_var@39:28` golden 2 / ours 0 in both binaries.)

### 2.3 BINDING (arm `a4_bind`) — nine bindings, one golden shape

| `type T =` | golden | ours PRE | ours FINAL |
|---|---|---|---|
| B1 `int` | `ref_obj T::get` @47:13-16 | ABSENT | **=golden** |
| B2 `string` | =same shape | ABSENT | **=golden** |
| B3 `bit` | =same shape | ABSENT | **=golden** |
| B4 a virtual class WITHOUT the method | =same shape | ABSENT | **=golden** |
| **B5** a class WITH a static `get` | =same shape | **=golden** (slang binds) | =golden |
| B6 a class with a NON-static `get` | =same shape | ABSENT | **=golden** |
| **B7** a PARAMETERISED class with `get` | =same shape | **=golden** (slang binds) | =golden |
| B8 `type T` **NO DEFAULT** | `ref_obj T::get` @103:13-16 | ABSENT | **ABSENT** |
| B9 chained `type U = T` | `ref_obj U::get` @111:13-16 | ABSENT | **=golden** |

**7 differing cells → 1.**  **B8 is not reachable by any expression law**: our
side emits **no `p59a4::b8` class_defn at all** (`grep -c 'p59a4::b8' o.dump` = 0
against golden's 20+ lines) — a generic class whose type parameter has no default
has no default specialization for slang to compile.  That is pass 58's residue R2
family and it is filed here as **R4**.

### 2.4 VIEW / SPECIALIZATION (arm `v1_elab`) — the law is neither view- nor specialization-scoped

A module specialises the generic with a binding that HAS the method, so an
elaborated view exists.  Golden emits **exactly one** listing of each method's
reference — there is no elaborated cell that could disagree, so the gate needs no
view test.  **1 differing cell → 0.**

**MEASURED AND RECORDED**: a specialization with a NON-CLASS binding
(`w59#(int)` where the body writes `T::get()`) is a slang **HARD ERROR** —
`unknown class or package 'T'` — and rejects the whole design.  That is exactly
why the corpus population is the **DEFAULT specialization** and nothing else: an
explicit non-class specialization would never have built.

### 2.5 THE NEGATIVE CONTROL (arm `v3_negctl`) — **BYTE-IDENTICAL**

Eleven cells, not one type parameter among them: concrete class static method,
typedef alias, package function, class static property, package enum constant,
package parameter, extern out-of-body method, a `::` LVALUE, a `::`-rooted
`.member` chain, an indexed `::` lvalue, and a chain rooted at a `::` CALL — every
one owned by § staticScopedCall12 / § staticScopedRef12 /
§ staticScopedChainDrops48 / § staticScopedLvalueBad48 / § …26.

```
pristine ours.uhdm  9c3514334d39041275db0c1b6e52fd82
FINAL    ours.uhdm  9c3514334d39041275db0c1b6e52fd82
o.dump   cmp -s     v3_negctl DUMP BYTE-IDENTICAL: PASS
```

Under `cells59.py … '::(get|getn|sprop|create_by_type|eget|pf59)\b'` its 3
differing rows are identical on both binaries and all pre-existing (the wider
`'::'` pattern shows 8, also identical on both binaries): the `extern59::eget`
duplication again, a static unpacked-array class property we do not support
("class property type: FixedSizeUnpackedArrayType"), a package-parameter ref, and
cell **c11**
(`base59::get().inst(2)` — golden collapses a chain rooted at a `::` CALL to one
`ref_obj`, we emit `method_func_call inst`; residue **R3**, and § staticScopedChainDrops48's
`scopedChainDropBase48` cannot reach it because it requires the chain root to be a
`NamedValue`).

### 2.6 THE CONFOUND, ISOLATED AND NAMED (arm `v2_lonedecl`)

A subroutine body that is a **LONE VariableDeclaration** is dropped wholesale by
our emitter (`noteUnsupportedAt("statement kind: VariableDeclaration")`),
**whatever** the initializer is.  It is why `a2`/`a3` append a trailing
`m_flag = 1;` to every body, and it is stated in both arms' header comments so a
future reader does not mistake the workaround for the axis.

| cell | body | golden | ours PRE | ours FINAL |
|---|---|---|---|---|
| L2 | lone decl, TYPE-PARAM `::` init | `ref_obj T::get` | ABSENT | **ABSENT** |
| L3 | lone decl, CONCRETE `::` init | `ref_obj hasget59::get` | ABSENT | **ABSENT** |
| L4b | + trailing statement, type-param | `ref_obj T::get` | ABSENT | **=golden** |
| L4c | + trailing statement, concrete | `ref_obj hasget59::get` | =golden | =golden |

**3 differing cells → 2**, and the two that remain are the two the lone-decl drop
blocks — **L3 among them, which this law never touches**.  That asymmetry is the
proof the residue is independent, and it is the same mechanism as R2 (14096).

---

## 3. THE FIVE GATES, each with the number measured on `167d5696…`

### GATE 1 — BUILD

```
BUILD DIR (absolute): /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm59/build
link lines ('Linking CXX executable slang-uhdm'): 1
compiler errors (' error:'):                      0
worktree HEAD: 81b8e0c0f3dc63a2aa935fbda8f3196c1d6292f4
pristine HEAD: 81b8e0c0f3dc63a2aa935fbda8f3196c1d6292f4
```

The md5 assertion ran as a **SEPARATE command**, with the baseline validated as
32 hex characters first (a malformed baseline is exit 9):

```
BASELINE md5 is 32 hex: OK
CONTROL(pristine 81b8e0c) = 7922a457a58565ff014f9c440b585eb6
FINAL                     = 167d5696053b4b58b4e85c9cf168fcd5
MD5 CHANGED: PASS
```

### GATE 2 — GOLDENS

```
./tests/check_goldens.sh                rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/…         rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match      183 differ        52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv -> 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default   225 match / 242 differ / 327 blank
           testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv -> 0 differing ROWS (0 diff row-sides)
baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
PASS: every row byte-identical to the committed baseline
```

**BuildUVMPkg did NOT convert** — see the first line of this document.  My
PRISTINE sweeps of both corpora reproduce the committed baselines exactly (0
differing ROWS each), which is what makes gate 5's byte comparison meaningful.

### GATE 5 — BYTE VERIFIER, both corpora, vs my own pristine 81b8e0c build

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
             SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 injected)
```

The 7 movers are exactly the UVM rows that produce a database:
`{SimpleUVM, BuildUVMPkg, SeqDriver} × {default, testflags}` + `Scoreboard,default`.

### Heads, before and after (`rowheads.sh`, `grep -c '^LHS:'` at column 0)

| test | mode | cmp lines | heads | verdict |
|---|---|---|---|---|
| **BuildUVMPkg** | **default** | 15 → **58** | 1 | **CLEARED AND ADVANCED** |
| **BuildUVMPkg** | **testflags** | 15 → **58** | 1 | **CLEARED AND ADVANCED** |
| SimpleUVM | default / testflags | 50 → 50 | 1 | head UNCHANGED — `.cmp` **byte-identical**; this row moved BYTES, not its head |
| Scoreboard | default | 50 → 50 | 1 | same |
| Scoreboard | testflags | — | — | SKIP-NOFILE (`SLANG_REJECT`, no database — reported, not hidden) |
| SeqDriver | default / testflags | 85 → 85 | 1 | same |

BuildUVMPkg's **new** head, both modes, is a **different law's**:

```
LHS golden  ref_obj (uvm_pkg::uvm_registry_common::__deferred_init::uvm_pkg::uvm_deferred_init)
            line:14107:7, endln:14107:16   vpiName:uvm_pkg::uvm_deferred_init
RHS ours    hier_path (uvm_pkg::uvm_deferred_init.push_back) line:14107:7-14107:50
```

`uvm_pkg::uvm_deferred_init.push_back(rgtry);` — a **package-variable `::`-rooted
chain whose tail is a BUILT-IN queue method**.  § staticScopedChainDrops48 owns
that shape and cannot reach it: `scopedChainDropBase48` returns `nullptr` for a
`Call` with no `thisClass()`, which is exactly what slang gives a built-in array
method.  Filed as **R1**, the highest-value next target.

---

## 4. EVERY MOVER ATTRIBUTED, PER SHAPE, AGAINST GOLDEN

`tools/probe/r10uvm58repro/mv58.sh` **reused unchanged** (it takes every changed
dump line as a multiset delta with indentation stripped and looks each distinct
shape up in golden with a per-shape `grep -Fxc`; ADDED and REMOVED separately;
`SELFCHECK=1` injects a fabricated shape per mover that must read OVER-FIRE).

```
movers=7   ADDED instances=109   REMOVED instances=0
OVER-FIRE shapes=9  UNDER-FIRE shapes=0
SELFCHECK PASS: the injected shape was reported OVER-FIRE on every mover
```

**9 OVER-FIRE = 7 fabricated (one per mover) + 2 real, and both real ones are the
bare field line `|vpiRhs:` on the two BuildUVMPkg rows.**  That is the artefact
pass 58 recorded on `|vpiSigned:1` and its rule applies verbatim: **NEVER
ATTRIBUTE A BARE FIELD LINE** — it has no owner once indentation is stripped, so
its multiplicity is a whole-database aggregate.  Our side already carried a
**pre-existing surplus** there (golden 7491 / ours 7553 before the patch), which
is why +4 correct additions read as "too many".

**The per-owner proof, with the committed prover `rhsown59.py`**, at each of the
four BuildUVMPkg assignments that gained a `vpiRhs`:

| assignment span | golden | pristine | FINAL |
|---|---|---|---|
| `14058:5` | vpiRhs **YES** | vpiRhs **NO** | vpiRhs **YES** |
| `14104:16` | YES | NO | YES |
| `14120:16` | YES | NO | YES |
| `61837:7` | YES | NO | YES |

Every one of the four is at an owner golden also gives a `vpiRhs`, and none
existed before.  Nothing else in the database gained one.

### 4.1 Every distinct OBJECT shape added, with golden's own count

BuildUVMPkg (identical in both modes, 37 ADDED line instances each):

| shape | golden | ours FINAL | verdict |
|---|---|---|---|
| `\_ref_obj: (…uvm_registry_common::create::Tcreator::create_by_type), line:14058:11, endln:14058:21` | 1 | 1 | covered |
| `\_ref_obj: (…__deferred_init::Tregistry::get), line:14104:24, endln:14104:35` | 1 | 1 | covered |
| `\_ref_obj: (…initialize::Tregistry::get), line:14120:24, endln:14120:35` | 1 | 1 | covered |
| `\_ref_obj: (…set_inst_override::Tregistry::get), line:14088:39, endln:14088:50` | 1 | 1 | covered |
| `\_ref_obj: (…set_type_override::Tregistry::get), line:14073:39, endln:14073:50` | 1 | 1 | covered |
| `\_ref_obj: (…uvm_reg_predictor::type_name::BUSTYPE::create), line:61837:11, endln:61837:29` | 1 | 1 | covered |
| `|vpiName:Tregistry::get` | 5 | 4 | covered |
| the six matching `|vpiFullName:` lines | 1 each | 1 each | covered |
| `\_assignment:` at 14058:5 / 14104:16 / 14120:16 / 61837:7 | 3 each | 3 each | covered |
| `\_method_func_call: (set_type_override_by_type), line:14073:13, endln:14073:38` and its `set_inst_override_by_type` twin | 5 each | 4 each | covered |

SimpleUVM / Scoreboard / SeqDriver (7 ADDED line instances each, identical set):

| shape | golden | ours FINAL | verdict |
|---|---|---|---|
| `\_ref_obj: (uvm_pkg::uvm_reg_predictor::get_type_name::BUSTYPE::create), line:120:11, endln:120:29` | 1 | 1 | covered |
| `|vpiName:BUSTYPE::create` | 1 | 1 | covered |
| `|vpiFullName:uvm_pkg::uvm_reg_predictor::get_type_name::BUSTYPE::create` | 1 | 1 | covered |
| `\_assignment: , line:120:7, endln:120:40` | 3 | 3 | covered |

**0 REMOVED line instances on any mover** — the law only adds.

### 4.2 BuildUVMPkg whole-database distance

`msdist.sh` @7c7eaa6 (the whitespace-aware fixed one; its md5 in my worktree is
`7c0d46b5da124cfe37d27eddc95eb7e7`, identical to `git show 7c7eaa6:` and to
`git show 81b8e0c:`):

| | pristine | FINAL |
|---|---|---|
| golden-only line instances | 53726 | **53703** |
| ours-only line instances | 28649 | 28662 |
| **MULTISET DISTANCE** | **82375** | **82365** |
| dump lines (golden 1101386) | 1076309 | 1076345 |

---

## 5. THE MOVER PREDICTION — **MADE, THEN REFUTED BY MY OWN MEASUREMENT, THEN CORRECTED**

The brief asked for a source census FIRST and a check at gate 5.  I did both, and
the first census was **WRONG**.

**PREDICTION 1 (wrong): "only the two BuildUVMPkg rows move; SimpleUVM /
Scoreboard / SeqDriver are uvm-1.2 and may not carry this shape."**  I built it
by grepping uvm-1.2 for a **hand-written list** of type-parameter names
(`T|Tregistry|Tcreator|T1|T2|CB|BASE|IMP|REQ|RSP|ITEM|DO`), which found 7 uses,
all of them in comments or already-binding.  **Gate 5 measured 7 movers, not 2.**

**WHY IT WAS WRONG, and the corrected method.** The name list was a guess.  The
right census enumerates the type-parameter names from the SOURCE
(`grep -rhoE '#\(\s*type \w+|,\s*type \w+'` → `BASE BEFORE BUSTYPE CB IF IMP KEY
NODE PORT REQ RSP RSP_IMP ST STRUCTURE T T1 T2 TYPE`, **18** names) and then greps
for those.  `BUSTYPE` — the one that moved three rows — **was not in my list at
all.**  Re-run properly, uvm-1.2 has **18** `<typeparam>::` sites:

| site | why it does / does not move |
|---|---|
| `reg/uvm_reg_predictor.svh:120` `BUSTYPE::type_id::create("t")` | **THE MOVER**, 1 object per uvm-1.2 row |
| `seq/uvm_sequence_library.svh:617,710,721` `REQ::get_type()` | slang **BINDS** (`REQ`'s default `uvm_sequence_item` has `get_type`) — § staticScopedCall12 already; verified equal on both sides at pp lines 56732/56865/56881 |
| `base/uvm_factory.svh:595,625,640`; `base/uvm_misc.svh:663,674,722,727`; `base/uvm_callback.svh:1107` | **COMMENTS** (`//|` doc blocks, a `/****` block).  Verified: pp line 27708 has no object on either side |
| `macros/uvm_sequence_defines.svh:358,396,397,402,407,411` | macro **BODIES**; no invocation in these tests reaches them (no such object appears in any mover's delta) |

**Corrected prediction: 1 added object per uvm-1.2 row, 6 per 1800.2 row.
MEASURED: exactly that** (§4.1).  The corrected census is the method a future
pass should copy; the name list is the mistake it should not.

---

## 6. CANARIES

| check | corpus | result |
|---|---|---|
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=6` | uhdm2rtlil | ok=1 **changed=0 absent=0** unknown-patterns=6 → PASS |
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=1` | surelog | ok=58 **changed=0 absent=0** unknown-patterns=1 → PASS |
| **`tools/probe/r10uvm52repro/canaries.sh`** (named explicitly — six files share that basename) | uhdm2rtlil | ok=8 **changed=0 absent=0** unknown-names=25 (expected for a u2r csv) |
| **`tools/probe/r10uvm52repro/canaries.sh`** | surelog | ok=52 **changed=0 absent=0** unknown-names=7 (the u2r-only canaries) |
| `r10uvm55repro/canaudit.sh` | static | audited=29 **UNCOVERED=0 FENCE-BREACH=0** → PASS |

BY NAME, on the surelog csv (from `canaries.sh`'s own per-row output):

```
InterfaceModPort    default   OK  CMP_EQUAL/differ     InterfaceModPort    testflags OK  CMP_EQUAL/differ
BlackParrotComplex  default   OK  CMP_EQUAL/differ     BlackParrotComplex  testflags OK  CMP_EQUAL/differ
ClassTypeParam      default   OK  CMP_EQUAL/differ     ClassParamAsParam   default   OK  CMP_EQUAL/differ
SVSwitch            default   OK  CMP_NOTEQUAL/        Earlgrey_0_1        default   OK  CMP_NOTEQUAL/
BuildUVMPkg         default   OK  CMP_NOTEQUAL/        BuildUVMPkg         testflags OK  CMP_NOTEQUAL/
SimpleUVM           default   OK  CMP_NOTEQUAL/        Scoreboard          testflags OK  SLANG_REJECT/
```

`ClassTypeParam` and `ClassParamAsParam` are worth naming again: they are the two
canaries whose *subject* is a type parameter, and neither appears in any mover row
— because neither writes a `::`-scoped reference through one.

---

## 7. RANKED RESIDUE

| # | residue | measured reach | why not here |
|---|---|---|---|
| **R1** | **BuildUVMPkg's NEW head**: a package-variable `::`-rooted chain whose tail is a **BUILT-IN** queue method — `uvm_pkg::uvm_deferred_init.push_back(rgtry)`.  Golden collapses it to ONE `ref_obj uvm_pkg::uvm_deferred_init`@14107:7-16; we emit a `hier_path`.  § staticScopedChainDrops48's `scopedChainDropBase48` bails on a `Call` with no `thisClass()`, which is what slang gives a built-in array method | the head on 2 of 7 UVM row-modes | a DIFFERENT law (chain collapse), and widening `scopedChainDropBase48` to built-in calls needs its own arm set |
| **R2** | a **NESTED `begin`'s DECLARATIONS** are dropped wholesale — golden's inner `begin@14094:63` lists 2 `vpiVariables` + 3 `vpiStmt`, ours 0 + 1.  Independent of the qualifier: the CONCRETE `uvm_factory factory = uvm_factory::get();` is lost too | corpus site 14096; arm `a1_witness::set_type_alias` (BOTH cells) | a STATEMENT-level law, not an expression one |
| **R3** | a `::`-rooted chain whose ROOT IS A CALL — `base59::get().inst(2)`: golden ONE `ref_obj base59::get`, ours `method_func_call inst`.  Same family as R1, concrete flavour | arm `v3_negctl` c11 | pre-existing; `scopedChainDropBase48` requires a `NamedValue` root |
| **R4** | a subroutine body that is a **LONE VariableDeclaration** is dropped wholesale ("statement kind: VariableDeclaration"), whatever the initializer | arm `v2_lonedecl` L1/L2/L3; **it is the mechanism that blocks corpus site 14096 too** | its own pass; it needs the `begin`-wrapper rules of StmtEmit's `StatementList` arm re-measured for a body with no non-declaration statement |
| **R5** | a **CONCATENATION containing an unbindable operand loses ALL its operands**: pp 14061 `msg = {"…", Tcreator::base_type_name(), " of type '", Tregistry::type_name, …}` — golden 4 operands including both type-parameter refs, ours an `operation` opType 33 with **zero** `vpiOperand`.  Pre-existing and byte-identical across this pass | 1 BuildUVMPkg site, 2 golden objects | the whole concatenation is slang-`Invalid`, so its operands are never visited; emitting a ref_obj *instead of* the operation would be wrong (golden keeps the operation) |
| **R6** | a class with `type T` and **NO DEFAULT** produces **no class_defn at all** on our side | arm `a4_bind` B8 | pass 58's residue R2, unchanged |
| **R7** | `extern`/out-of-body static method: golden **TWO** return vars (prototype + definition), we emit one | arms `a3_scope`, `v3_negctl` (`extern59::eget`) | pass 58's residue R5, unchanged |
| **R8** | a call in **STATEMENT** position whose ARGUMENT slang could not bind takes the **EXPRESSION** shape: the `Invalid` arm clears `callStmtContext` before unwrapping the child, so `factory.set_type_override_by_type(Tregistry::get(),…)` is a `hier_path` where golden has a `method_func_call` + `vpiPrefix`.  **PRE-EXISTING and NOT CAUSED BY THIS PASS** — per-shape on arm a1, `hier_path: (factory.note), line:43:7, endln:43:19` reads **pristine 3 / FINAL 3** (unchanged); the sibling `method_func_call: (note), line:43:15, endln:43:19` goes 2 → 3 only because the NEW argument's `vpiParent` line prints its parent once more.  Unmasked as the arms' new head only because the argument now exists | corpus 14073, 14088; arms `a1_witness` (its new head), `a2_position` (its new head) | a RESHAPE of an existing object, and the brief's boundary is the ref_obj and its assignment context — ONE head per run |
| **R9** | the per-type-parameter **SHARED TYPESPEC** — ours `int_typespec@14104:6-15` where golden shares `int_typespec@14031:45-48`, the `type Tregistry=int` default token | visible at every cell in every arm | pass 58's residue R1, fully decoded there; **uhdm-cmp cannot see it** (`vpiLineNo`/`vpiColumnNo` blacklisted) |

---

## 8. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `a1_witness.sv` | the corpus witness reduced to 68 lines: the head's own position, the ARGUMENT position, a virtual method, a nested `begin`, each next to the CONCRETE spelling as an in-arm control |
| `a2_position.sv` | axis: **thirteen POSITIONS** of one spelling, plus the parens / args / nested / chain cells |
| `a3_scope.sv` | axis: **what the qualifier IS** — the discriminator arm (S3 is the cell that shaped the gate) |
| `a4_bind.sv` | axis: **nine BINDINGS** a type parameter can take |
| `v1_elab.sv` | axis: **def vs elab view** and specialization; records the slang HARD ERROR that defines the population |
| `v2_lonedecl.sv` | the CONFOUND isolated: a lone-declaration body, with and without a trailing statement, type-param and concrete |
| `v3_negctl.sv` | **THE NEGATIVE CONTROL** — eleven `::` cells, no type parameters; its database must stay byte-identical |
| `arm59.sh` | one arm's golden + ours + dumps + cmp; prints the slang path and md5, existence-checks all four tools, `sed 1d` on both dumps, missing database = exit 6 |
| `cells59.py` | THE CELL TABLE: `(UHDM class, fullname, span)` with multiplicities, golden always argv[1], `--all` to print equal cells too |
| `rhsown59.py` | THE PER-OWNER FIELD PROVER — the answer to `mv58.sh`'s bare-field-line artefact; fields at an object's OWN CHILD DEPTH, over golden/pristine/patched together |

Reused **unchanged**: `r10uvm58repro/mv58.sh`, `r10uvm55repro/{rowheads.sh,msdist.sh,canaudit.sh}`,
`r10oth6repro/byteverify.sh`, `r10oth7repro/ctcan2.sh`, `r10oth8repro/ct8rows.sh`,
`r10uvm52repro/canaries.sh`.  `scripts/verify_golden.py` and
`tests/check_goldens.sh` were **not modified**.

---

## 9. BOUNDARIES AND PRIOR ART — NO COLLISION

| adjacent law | how this pass treats it |
|---|---|
| § typeParamRetIsRefVar58 (just landed) | **UNTOUCHED.** It makes `Tregistry rgtry` a `ref_var`; this law fills in that assignment's missing `vpiRhs`.  The two are the LHS and the RHS of the same statement and neither changes the other's object — `\_ref_var: (…__deferred_init::rgtry), line:14104:16, endln:14104:21` reads **golden 4 / pristine 4 / FINAL 4** (four dump occurrences: the `vpiVariables` listing on the function, on the `begin`, the assignment's `vpiLhs`, and the `ref_typespec`'s back-reference) |
| § invalidNewCallFromSyntax55 | **UNTOUCHED and deliberately ordered after it.** Its predicate keys on `NewClassExpression`, mine on a `::`-scoped name — mutually exclusive syntax kinds.  Placed after it so a `new` can never reach this arm |
| § classMethodRetNameNoBind56 / § retNameNewLhsNoBind56 (design-final drops) | **UNTOUCHED.** Neither is a `::`-scoped reference and neither names an `Invalid` expression |
| § staticScopedCall12 | **NOT REWRITTEN.** This law builds the SAME object for the case that arm cannot see (slang bound nothing), and arm a3 S3 / a4 B5+B7 prove its cells are unchanged |
| § classPropScopedCallIsRefObj29 | **NOT REWRITTEN.** Its `ic.kind == ExpressionKind::Call` gate stays; the new call site sits BEFORE the early return that made it unreachable |
| r10svs4 (SVSwitch hier_path index-presence) | not touched; `SVSwitch` reads OK/unchanged in `canaries.sh` |
| r10earl30 (vpiConstType on folded constants) | not touched; no constant is created or modified by this pass, and `Earlgrey_0_1` reads OK/unchanged |
