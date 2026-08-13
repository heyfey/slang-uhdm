# r10buvm1 — § scopedBuiltinRecvIsChain1 + § scopedRootFromStmtSyntax1: BuildUVMPkg's shared head is CLEARED on BOTH rows, 58 → 17 cmp lines

**FIRST LINE, as the brief demands: the head DID clear.** The
`LHS: ref_obj (uvm_pkg::uvm_deferred_init) / RHS: hier_path
(uvm_pkg::uvm_deferred_init.push_back)` head is gone from BuildUVMPkg in **both**
modes, and both rows fall **58 → 17 cmp lines**. The new head is a different
family entirely (a `time_var`'s default-value `constant`, `uvm_root.svh`
line 38677). Neither row converts — BuildUVMPkg stays `CMP_NOTEQUAL` in both
modes — and every gate below reads **0 differing rows** against the committed
baselines.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`~/.local/bin/uhdm-cmp` and every driver here passes `(golden.uhdm, ours.uhdm)`
in that order.

Base commit **ba7d1ef**, branch `auto5h`, own worktree `/tmp/wt_r10buvm1` with a
PRISTINE ba7d1ef twin at `/tmp/wt_r10buvm1pris` configured and built from source
in this pass.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine ba7d1ef) | `eb2d9506c9c64c69afc90c16c3f49d08` | **byte-identical to the main-tree `build/slang-uhdm`**, which is what makes it a valid control |
| FINAL (gated, shipped) | `a47cc37f3b67efd8374d4cf77458af33` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **read only**; row counts come
from `ct8rows.sh`'s lines-minus-one, never from `wc -l`.

---

## 0. THE LAW, in the form a future pass can grep for

TWO § markers, one predicate and one lookup, THREE call sites — all six
occurrences live in `src/ExprEmit.cpp`
(`grep -n 'scopedBuiltinRecvIsChain1\|scopedRootFromStmtSyntax1' src`); the
header carries only the defaulted `base1` parameter the second marker needs:

### § scopedBuiltinRecvIsChain1

> **A BUILT-IN method call is a CHAIN STEP over its receiver, exactly like a user
> class-method call.** slang hands a user method its receiver in `thisClass()`
> but a BUILT-IN one (`q.push_back(x)`, `s.itoa(n)`, `arr.size()`,
> `q.sum() with (...)`, `h.randomize()`) in **`arguments()[0]`**, leaving
> `thisClass()` NULL — the same shape a FREE function call has. So
> § staticScopedChainDrops48's walk, which bailed on `!thisClass()`, could reach
> a user method's `::`-scoped receiver and never a built-in's.
>
> The receiver is `arguments()[0]` **IF AND ONLY IF** the call `isSystemCall()`
> and its subroutine name does **NOT** start with `$`. A real system
> task/function (`$display`, `$bits`, `$size`, `$cast`) is also a
> `SystemSubroutine` with a null `thisClass()`, and ITS `arguments()[0]` is an
> ordinary ARGUMENT.

### § scopedRootFromStmtSyntax1

> **The chain's written `::` is recovered from the enclosing STATEMENT's syntax
> when the expression carries no syntax pointer of its own.** slang leaves an
> invocation's `Expression` with a NULL `syntax` (`Expression::create` refuses to
> overwrite it — the fact § droppedCall14's `findDroppedCallAt14` already lives
> on), and a CHAINED base sub-expression has none either. `stmtSyntax14` — set
> for EVERY statement, not only rejected ones — plus the base's own
> `sourceRange.start()` identifies the `::` ScopedName uniquely: inside one
> statement no two `::` names start on the same column.

Neither marker changes what the collapse EMITS. The object is
§ staticScopedChainDrops48's own: a bare `ref_obj` named FIRST-written-segment
`::` FINAL-identifier, spanned from the scoped name's start **up to (not
including) the final identifier** — the qualifier alone — with the method, the
`.member` tail, the select and the whole argument list DISCARDED.

**STATED GATE == CODE GATE.** The stated gate for the new chain step is
`isSystemCall() && !name.empty() && name[0] != '$' && !arguments().empty()`.
The code gate is `builtinMethodRecv1(ce)`, whose entire body is those four tests
and a `return ce.arguments()[0]`. There is no fifth clause anywhere. The stated
gate for the lookup is "the chain's own syntax first, the statement's syntax
second"; the code gate is `scopedChainRoot1`, whose entire body is those two
lookups in that order. Both halves of § staticScopedChainDrops48 — the predicate
that decides and the builder that mints — call the SAME `scopedChainRoot1`, so
they can never split a different `::`.

**Sites** — `src/ExprEmit.cpp` (`builtinMethodRecv1`, `scopedRootAt1`,
`scopedChainRoot1`, the one line in `scopedChainDropBase48`'s Call arm, the one
line at its `ns48` lookup, the one line in `scopedChainDropRef48`),
`include/UhdmExporter.h` (one defaulted parameter on
`scopedChainDropRef48`). **DIRECTION IN THE CODE: ADD-ONLY** — every changed
line can only turn a `return nullptr` into a collapse; no existing collapse
changes shape, name or span. **DIRECTION IN THE DATABASE: REPLACE** — a collapse
by construction DELETES the call object and its arguments, so `mv1.sh` prints
`ADD-ONLY FALSIFIED` on both movers (3 lines added, 18 removed) and that is the
law working, not a defect. The two directions are different claims and this
pass makes both explicitly rather than letting the code claim cover the data.

---

## 1. THE CENSUS, both sides, span-keyed, BEFORE any code

`uhdm-cmp(golden, ours)` on BuildUVMPkg/default at ba7d1ef: **58 lines, 1 head**,
and the head is the whole finding.

```
LHS: ref_obj (uvm_pkg::uvm_registry_common::__deferred_init::uvm_pkg::uvm_deferred_init)
     line:14107:7, endln:14107:16   parent = begin @14106:63-14108:9
     vpiName    uvm_pkg::uvm_deferred_init
     vpiFullName uvm_pkg::uvm_registry_common::__deferred_init::uvm_pkg::uvm_deferred_init
     — NO vpiActual, NO call object, NO argument

RHS: hier_path (uvm_pkg::uvm_deferred_init.push_back) line:14107:7, endln:14107:50
     vpiActual ref_obj (uvm_pkg::uvm_deferred_init) 14107:7-33
     vpiActual method_func_call (push_back) 14107:34-43
               vpiArgument ref_obj rgtry 14107:44-49
```

The written source (`third_party/UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv`,
one TAB + five spaces of indent) is

```
14107:\t     uvm_pkg::uvm_deferred_init.push_back(rgtry);
```

### 1.1 THE SPAN, decoded off golden and not derived

`14107:7-14107:16` is **nine columns**, and with the tab counted as one column
`uvm_pkg` occupies 7-13, `::` 14-15 and `uvm_deferred_init` STARTS at 16. So

> **the span runs from the scoped name's first column up to (not including) the
> column the FINAL identifier starts on** — the qualifier `uvm_pkg::` alone.

Two independent golden calibrations in the same database confirm it and refute
the two competing readings:

| golden object | source | span | what the span covers |
|---|---|---|---|
| `ref_obj this_super_type::m_t_inst` @27601 | `if(this_super_type::m_t_inst.m_typename == "")` | 8-25 | `this_super_type::` (`m_t_inst` starts at 25) |
| `ref_obj uvm_typeid_base::typeid_map` @27605 | `s_obj = uvm_typeid_base::typeid_map[m_s_typeid];` | 13-30 | `uvm_typeid_base::` (`typeid_map` starts at 30) |
| `func_call uvm_pkg::get_core_state` @14106 | `if (uvm_pkg::get_core_state() == ...)` | 10-17 | `uvm_pkg` **without** the `::` |

The third row is the refutation that matters: a `::`-scoped **CALL** spans the
package NAME only, a `::`-scoped **REF** spans the name AND the `::`. A pass
that read the span off the call would have been one column short on every cell.

### 1.2 WE ALREADY MATCHED THE SAME LAW ONE LINE OVER

`uvm_typeid_base::typeid_map` @27605 and `this_super_type::m_t_inst` @27601 are
**byte-identical between golden and ours in the pristine dump**, span included.
§ staticScopedChainDrops48 already owned that collapse for a `.member` tail and
a select; the head is the SAME law with a `.method(...)` tail, and it stood only
because a built-in method's receiver was unreachable.

### 1.3 THE CORPUS POPULATION IS ONE STATEMENT

`grep -nE '[A-Za-z_]\w*::[A-Za-z_]\w*\s*\.' pp_output/uvm_pkg.sv` finds
**exactly one** statement-position scoped method call in the whole 45k-line
design — line 14107 — plus the three `this_*_type::m_t_inst.m_typename` member
chains we already match. The head is a population of ONE, and the other three
UVM designs (`SimpleUVM`, `Scoreboard`, `SeqDriver`, all uvm-1.2) do **not**
contain it: uvm-1.2's `uvm_registry.svh` has no `uvm_registry_common` and no
`__deferred_init` (`grep -c __deferred_init` = **0**). **The brief's
"shared-fix multi-row family" hypothesis is REFUTED**: this cell exists only in
1800.2-2017-1.0, i.e. only in BuildUVMPkg.

---

## 2. THE FIRST LAW THIS PASS WROTE, AND ITS REFUTATION

After §1 the obvious law was "**a built-in method on a `::`-scoped receiver
collapses**", and one line of code implemented it (`builtinMethodRecv1` in the
walk). It **cleared every arm cell** — a1 went 9 differing cells to 7, a2 9 to 6,
a4 4 to 1 — and **left the corpus head EXACTLY where it was, byte for byte.**

That is the measurement that produced the second marker, and it took three arms
to corner:

| hypothesis for why the head did not move | arm | verdict |
|---|---|---|
| it is inside a CLASS, not a free function | a2 H1 (static method of a plain class in the package) | **REFUTED** — collapses |
| it is inside a GENERIC class's default specialization | a4 N2/N3 (`gen4#(type T=int)`) | **REFUTED** — collapses |
| slang never BOUND the call, so there is no CallExpression syntax to read | a5 Q1 vs Q2 | **CONFIRMED** |

`a5` is the head in miniature: `Tregistry rgtry;` in the default specialization
is an **`int`**, `uvm_deferred_init` is a queue of `uvm_object_wrapper` handles,
so `push_back(rgtry)` is a type error, slang rejects it, and the statement
reaches the emitter with **no syntax pointer anywhere on the expression**. Q2 is
the identical statement with an argument the default specialization accepts and
it collapsed under the one-line law. **One character of type difference between
Q1 and Q2 is the entire discriminator**, and no amount of staring at the corpus
would have shown it — the arm did.

---

## 3. THE GRID, cell for cell, golden vs CONTROL vs FINAL

Five arms, one `.sv` each, driven by `ct1arm.sh` and read by `cells.py`, which
keys on the SOURCE LINE (each cell is one written statement) and prints both
sides' object shapes. `SPANBLIND=1` re-reads the same cells with every span
erased, because "the object kind and name now reach golden but the span does
not" is a DIFFERENT finding from "the object is still wrong", and one number
cannot say which.

| arm | what it grids | differing cells CTRL → FINAL | SPAN-BLIND CTRL → FINAL |
|---|---|---|---|
| `a1_scope.sv` | receiver scope × method kind × position (incl. the parens-less cell) | 10 → **8** | 6 → **0** |
| `a2_pkgspan.sv` | inside vs outside the declaring package; bare vs chain vs lvalue | 9 → **6** | 8 → **3** |
| `a3_overfire.sv` | the OVER-FIRE guard | 9 → 9 | 6 → **1** |
| `a4_generic.sv` | plain vs generic class | 4 → **1** | 4 → **1** |
| `a5_unbound.sv` | bound vs slang-REJECTED call (the head) | 5 → **3** | 5 → 3 |
| **total** | | **37 → 27** | **29 → 8** |

**Every cell this law owns reaches golden in SHAPE.** Every cell still differing
does so for one of three reasons named in §6, none of them this law's.

### 3.1 `a1_scope.sv` — RECEIVER SCOPE × METHOD KIND × POSITION

| line | written | receiver | method | position | GOLDEN | OURS CTRL | OURS FINAL |
|---|---|---|---|---|---|---|---|
| 47 | `p1::pq.push_back(1);` | pkg var, `::` | built-in | stmt | `ref_obj p1::pq` @5-9 | `method_func_call` + prefix | **shape agrees** (span-only, R1) |
| 48 | `p1::pobj.touch(2);` | pkg var, `::` | **user** | stmt | `ref_obj p1::pobj` @5-9 | `ref_obj` @5-13 | unchanged (span-only, R1) |
| 49 | `p1::pstr.itoa(3);` | pkg var, `::` | built-in (string) | stmt | `ref_obj p1::pstr` @5-9 | `method_func_call` | **shape agrees** (span-only, R1) |
| 50-55 | `pq/pobj/mq/mobj/lq/lobj.<m>(...)` | UNSCOPED, 3 scopes × 2 method kinds | — | stmt | method shape KEPT | agrees | **agrees** |
| 56 | `cobj1::sq.push_back(10);` | class static, `::` | built-in | stmt | `ref_obj cobj1::sq` @5-12 | `method_func_call` | **AGREES EXACTLY** |
| 57 | `cobj1::sh.touch(11);` | class static, `::` | user | stmt | `ref_obj` @5-12 | agrees | **agrees** |
| 59 | `x = p1::pq.size();` | pkg var, `::` | built-in | **expr** | `ref_obj p1::pq` @9-13 | `hier_path` | **shape agrees** (span-only, R1) |
| 60 | `x += p1::pobj.peek();` | pkg var, `::` | user | expr | `ref_obj` @10-14 | `ref_obj` @10-18 | unchanged (span-only, R1) |
| 61-63 | `pq/mq/lq.size()` | UNSCOPED | built-in | expr | `hier_path` KEPT | agrees | **agrees** |
| 64 | `x += cobj1::sq.size();` | class static, `::` | built-in | expr | `ref_obj` @10-17 | `hier_path` | **AGREES EXACTLY** |
| 65 | `x += cobj1::sh.peek();` | class static, `::` | user | expr | `ref_obj` @10-17 | agrees | **agrees** |
| 67 | `x += p1::pq[0];` | pkg var, `::` | select | expr | `ref_obj` @10-14 | `ref_obj` @10-16 | unchanged (span-only, R1) |
| 68 | `x += p1::pobj.v;` | pkg var, `::` | `.member` | expr | `ref_obj` @10-14 | `ref_obj` @10-18 | unchanged (span-only, R1) |
| 69 | `x += cobj1::sh.v;` | class static, `::` | `.member` | expr | `ref_obj` @10-17 | agrees | **agrees** |
| **71** | `x += p1::pq.size;` | pkg var, `::` | **parens-less** built-in | expr | `ref_obj p1::pq` @10-14 | `hier_path` + `ref_obj p1::pq` + `ref_obj size` (r10svs2's shape) | **`ref_obj p1::pq` @10-16 — shape agrees**, span-only R1. SEE §7 |

**GOLDEN'S COLUMN DEPENDS ONLY ON THE `::`.** Position does not matter here
(statement and expression collapse alike), the receiver TYPE does not matter
(queue, string, dyn array, assoc array, class handle, enum all collapse when
scoped), and the method KIND does not matter (built-in and user alike). What
matters is whether the receiver is written through a `::` scope. Six UNSCOPED
control cells (50-55, 61-63) keep their method shape on both sides in both
builds — **the law cannot reach an unscoped receiver.**

### 3.2 `a2_pkgspan.sv` — INSIDE vs OUTSIDE the declaring package

| cell | written | where | GOLDEN | OURS CTRL | OURS FINAL |
|---|---|---|---|---|---|
| **H1** | `p2::pq.push_back(7);` | static method of a PLAIN class **inside** the pkg | `ref_obj p2::pq` @7-11, **UNBOUND** | `method_func_call` | **AGREES EXACTLY** |
| H2 | `p2::pcnt = 8;` | lvalue, inside the pkg | `ref_obj p2::@@BAD_SYMBOL@@` @7-15 | `ref_obj pcnt` @7-15 | unchanged — R2 |
| H3 | `y = p2::pcnt;` | BARE read, inside the pkg | `ref_obj p2::pcnt` @11-15 | `ref_obj pcnt` @11-19 | unchanged — R2 |
| **H4** | `y += p2::pq.size();` | chain read, inside the pkg | `ref_obj p2::pq` @12-16 | `hier_path` | **AGREES EXACTLY** |
| H5 | `y = p2::pcnt;` | BARE read, package free function | `ref_obj p2::pcnt` @9-13 | `ref_obj pcnt` @9-17 | unchanged — R2 |
| **H6** | `p2::pq.push_back(9);` | chain stmt, package free function | `ref_obj p2::pq` @5-9, **BOUND** | `method_func_call` | **AGREES EXACTLY** |
| K1 | `y = p2::pcnt;` | BARE read, OUTSIDE | `ref_obj` @9-13 | `ref_obj` @9-17 | unchanged — R1 |
| K2 | `p2::pcnt = 5;` | lvalue, OUTSIDE | `ref_obj p2::@@BAD_SYMBOL@@` @5-13 (WHOLE lvalue) | agrees | **agrees** |
| K3 | `y += p2::pq.size();` | chain read, OUTSIDE | `ref_obj` @10-14 | `hier_path` | **shape agrees** (span-only, R1) |
| K4 | `p2::pq.push_back(6);` | chain stmt, OUTSIDE | `ref_obj` @5-9 | `method_func_call` | **shape agrees** (span-only, R1) |
| K5 | `y += p2::inner2::hget();` | three-segment scoped call | `ref_obj p2::hget` @10-22 | agrees | **agrees** |

Two findings the corpus alone could not give:

* **K2 proves the LVALUE keeps the WHOLE span** (`p2::pcnt`, 5-13) while every
  READ takes the qualifier alone. § staticScopedLvalueBad48 is therefore
  untouched by anything in R1, and any future span fix must gate on `!inLhs`.
* **H1 is UNBOUND and H6 is BOUND** on the same statement text: golden gives the
  collapsed ref a `vpiActual` from a package free function and NOT from inside a
  class method. Our object is unbound in both, which is why H1 agrees exactly
  and H6 agrees only in the cell view — see R4.

### 3.3 `a3_overfire.sv` — THE OVER-FIRE GUARD

Every cell is a `SystemSubroutine` with a null `thisClass()` and a `::`-scoped
expression at argument 0, or a `::`-rooted receiver whose SYMBOL KIND
§ staticScopedChainDrops48 excludes.

| line | written | must the law fire? | GOLDEN | OURS CTRL | OURS FINAL |
|---|---|---|---|---|---|
| 30 | `$display("%0d", p3::pq.size());` | on the ARGUMENT, not the `$display` | `sys_func_call` KEPT + `ref_obj p3::pq` @21-25 | `sys_func_call` + `hier_path` | **`$display` intact, argument collapsed** |
| 31 | `$display("%0d", p3::PARR[0]);` | **NO** (package PARAMETER) | `bit_select p3::PARR` | agrees | **agrees — no over-fire** |
| 32 | `y = $bits(p3::pq);` | **NO** (no chain) | `ref_obj` @15-19 | `ref_obj` @15-21 | unchanged — R1 |
| 34 | `s = p3::E1.name();` | **NO** (package ENUM CONSTANT) | golden FOLDS to `constant` | `hier_path` | **unchanged — no over-fire**, R3 |
| 35 | `y += $size(p3::PARR);` | **NO** | `ref_obj` @16-20 | `ref_obj` @16-24 | unchanged — R1 |
| 37-38 | `lq.push_back(1); y += lq.size();` | **NO** (unscoped) | method shape | agrees | **agrees** |
| 40 | `lq.push_back(p3::pq[0]);` | on the ARGUMENT only | `method_func_call` KEPT + `ref_obj` @18-22 | + `ref_obj` @18-24 | **method intact**, span-only R1 |
| 42 | `y += p3::pq.sum() with (item);` | YES | `ref_obj` @10-14 | `hier_path` + `with` operand | **shape agrees** (span-only, R1) |
| 44 | `p3::parr3.delete();` | YES | `ref_obj` @5-9 | `method_func_call` | **shape agrees** (span-only, R1) |
| 46 | `y += p3::pstr3.len();` | YES | `ref_obj` @10-14 | `hier_path` | **shape agrees** (span-only, R1) |
| 48 | `if (p3::pobj3.randomize())` | YES | `ref_obj` @9-13 | `ref_obj` @9-18 | **shape agrees** (span-only, R1) |

**No `$`-named call moved anywhere, in any cell, in either direction.** Line 42
is a bonus the second marker bought: a `with`-clause array method carries syntax
`scopedChainRootName48` cannot walk, and the statement-syntax recovery reaches
it; golden collapses it too.

### 3.4 `a4_generic.sv` — the generic-class axis (4 differing → **1**)

N1 (plain class), N2 (generic class default specialization, statement) and N3
(generic class, expression) all collapse and all AGREE EXACTLY after the change.
N4 (`y += p4::cnt4;`, a BARE qualified read inside the declaring package) is
untouched — R2.

### 3.5 `a5_unbound.sv` — THE HEAD IN MINIATURE (4 differing → 3, and Q1 is one of the two that cleared)

| cell | written | GOLDEN | OURS CTRL | OURS FINAL |
|---|---|---|---|---|
| **Q1** | `p5::dq5.push_back(rgtry);` (rgtry is the DEFAULT `int`; dq5 is a `w5[$]`) | `ref_obj p5::dq5` @7-11, unbound | `hier_path p5::dq5.push_back` @7-31 | **`ref_obj p5::dq5` @7-11 — EXACT** |
| **Q2** | `p5::dq5.push_back(good);` (argument the default spec accepts) | `ref_obj p5::dq5` @7-11 | `method_func_call` | **AGREES EXACTLY** |
| Q3 | `y = p5::dq5.size();` | `ref_obj` | `hier_path` | **agrees** |
| 31/41 | `Tregistry rgtry;` | `ref_var` alone | `+ int_typespec` | unchanged — R5 |

Q1's remaining cell-level `*` is the enclosing `begin` block, which golden
locates (`@7-32`) and we leave LOC-LESS — R6, and NOT this law's object.

---

## 4. THE FIVE GATES

### GATE 1 — BUILD

`cmake --build build -j 2` in `/tmp/wt_r10buvm1` → `[100%] Linking CXX
executable slang-uhdm` / `[100%] Built target slang_uhdm`, exit 0, **0
`error:` lines**. Then, in a SEPARATE command before any sweep:

```
eb2d9506c9c64c69afc90c16c3f49d08  /tmp/wt_r10buvm1pris/build/slang-uhdm
a47cc37f3b67efd8374d4cf77458af33  /tmp/wt_r10buvm1/build/slang-uhdm
```

both 32-hex, and CHANGED. The control's validity anchor, printed before any
edit: the pristine worktree build and the main-tree `build/slang-uhdm` are BOTH
`eb2d9506c9c64c69afc90c16c3f49d08`.

### GATE 2 — GOLDENS

`SLANG_UHDM=<final> tests/check_goldens.sh`: **23 PASS / 0 FAIL**.
NEGATIVE CONTROL `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the control
fires.

### GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump column
**496 match / 183 differ / 52 blank**. WHOLE-ROW judge (`ct8rows.sh`) against
the committed baseline:

```
baseline: 732 lines = 731 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both`, `--jobs 2`

**679/50/2 is gate 3; this is gate 4.** `default` **469 CMP_EQUAL /
11 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL;
`testflags` **465 CMP_EQUAL / 8 CMP_NOTEQUAL** / 5 DEFERRED / 286 SLANG_REJECT /
23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM.
Dump column match 225 (default) / 165 (testflags), differ 244 / 300.
**Every figure equals the expected one.** WHOLE-ROW judge:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` was left UNSET: the 5 memory-giant tests read `DEFERRED` in both
modes, exactly as the baseline does. Both sweeps' `cmds.txt` were re-read and
assert the intended binary (`sweeps.sh`).

### GATE 5 — BYTE VERIFIER, both corpora, against the PRISTINE ba7d1ef workdir built in this pass

`SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched-wd> <pristine-wd>`:

```
uhdm2rtlil/testflags:
  databases: patched=679 pristine=679
  PATH_SETS_IDENTICAL (679 paths)
  MOVERS: 0 / 679
  SELFCHECK: 678 / 679 flagged        SELFCHECK1: 1

surelog/both:
  databases: patched=953 pristine=953
  PATH_SETS_IDENTICAL (953 paths)
  MOVER ./default/BuildUVMPkg-bf853d43/slang.uhdm
  MOVER ./default/Scoreboard-59431470/slang.uhdm
  MOVER ./testflags/BuildUVMPkg-bf853d43/slang.uhdm
  MOVERS: 3 / 953
  SELFCHECK: 952 / 953 flagged        SELFCHECK1: 4
```

Both negative controls fire on both corpora (`SELFCHECK1`'s 4 = the 3 flagged
movers plus the corrupted one).

#### 4.5.1 THE MOVERS WERE PREDICTED FROM THE PRISTINE SIDE ALONE, BEFORE THE SWEEP WAS JUDGED

`predict.sh` (rule frozen in the script, and its own header records the
predictor this pass CAUGHT LYING — see `README.verifier.md` §0.1). It scans the
PRISTINE dumps only and names a database a mover iff it holds an uncollapsed
`::`-rooted chain in either of the two shapes this emitter produces:

```
uhdm2rtlil (679 pristine databases scanned):  PREDICTED MOVERS: 0
surelog    (953 pristine databases scanned):  PREDICTED MOVERS: 2
  PREDICT default/BuildUVMPkg-bf853d43    exprForm=1 stmtForm=0
  PREDICT testflags/BuildUVMPkg-bf853d43  exprForm=1 stmtForm=0
```

**The prediction and the byte verifier agree BY NAME on both corpora**: 0 and 0
on uhdm2rtlil, and on surelog exactly the two BuildUVMPkg databases — the third
flagged file is the flake proved in §4.5.2. `exprForm=1 stmtForm=0` also says
WHICH half of the law fires: the corpus head is the EXPRESSION shape, and the
statement shape has zero corpus population (the whole reason arm a3 exists).

#### 4.5.2 ONE OF THE THREE FLAGGED MOVERS IS A FLAKE, AND IT IS PROVED, NOT ASSUMED

`Scoreboard/default` has **delta 0 bytes** (11122848 both sides). Under the
standing law *same-size = flake, size-delta = real* that is already enough, but
`detcheck.sh` settles it far more strongly:

| binary | Scoreboard/default, 3 reps | distinct hashes | bytes |
|---|---|---|---|
| PRISTINE | `b2c22219bcb9a912`, `e491d2f7ff6c2322`, `11762b18ac03db81` | **3** | 11122848 (all three) |
| FINAL | `e491d2f7ff6c2322`, `b2c22219bcb9a912`, `b2c22219bcb9a912` | **2** | 11122848 (all three) |

**The two binaries' hash SETS OVERLAP** — `b2c22219bcb9a912` and
`e491d2f7ff6c2322` were each produced by BOTH binaries. A patched run emitted a
database BYTE-IDENTICAL to a pristine run, which no real change can do. This is
the pre-existing emitter nondeterminism already on record in MEMORY.md
(SourceLocation compares across macro buffers flip per run), untouched here.

**BuildUVMPkg is the opposite reading, equally proved:** `detcheck.sh` gives
**1 distinct hash in 3 reps on BOTH binaries** — fully deterministic — at
**11097200 (pristine) vs 11097278 (final)**, a stable **+78 bytes**. The sweep's
own files carry the same +78 (11097258 → 11097336).

**REAL MOVERS: 2** — BuildUVMPkg in both modes. Nothing else in either corpus.

#### 4.5.3 MOVERS PER-SHAPE vs GOLDEN BY MULTISET, ADDED and REMOVED SEPARATELY

`mv1.sh` per mover. LHS is ALWAYS golden.

| mover | msdist pristine | msdist patched | **gain** | ADDED | REMOVED |
|---|---|---|---|---|---|
| default/BuildUVMPkg | 79950 | 79935 | **15** | 3 | 18 |
| testflags/BuildUVMPkg | 79950 | 79935 | **15** | 3 | 18 |

**Both movers move TOWARD golden.** The ADDED line TEXTS are EXHAUSTIVELY the
law's own object, and the three-way count says our side was BELOW golden on
every one:

```
[\_ref_obj: (uvm_pkg::uvm_registry_common::__deferred_init::uvm_pkg::uvm_deferred_init), line:14107:7, endln:14107:16]
                                        golden=1  pristine=0  patched=1
[|vpiFullName:uvm_pkg::uvm_registry_common::__deferred_init::uvm_pkg::uvm_deferred_init]
                                        golden=1  pristine=0  patched=1
[|vpiName:uvm_pkg::uvm_deferred_init]   golden=1  pristine=0  patched=1
```

**Three added lines, three exact golden matches, zero unattributed names.** The
18 REMOVED lines are exhaustively the `hier_path`, its two `vpiActual` children,
the `method_func_call push_back`, its `vpiArgument ref_obj rgtry` and their
`vpiParent`/`vpiName`/`vpiFullName` lines — i.e. precisely the objects golden
does not hold. `mv1.sh` prints **ADD-ONLY FALSIFIED** and that is CORRECT here:
a collapse deletes by definition (see §0).

### 4.6 CANARIES

| check | result |
|---|---|
| `r10uvm52repro/canaries.sh` (the brief's NAMED script), surelog | `ok=52 changed=0 absent=0` |
| `r10uvm52repro/canaries.sh`, u2r | `ok=8 changed=0 absent=0` |
| this dir's `canaries.sh`, surelog / u2r | `ok=52 / ok=8`, `changed=0 absent=0` |
| `ctcan2.sh` surelog, **EXPECT_UNKNOWN=1**, baseline FIRST | `ok=58 changed=0 absent=0 unknown-patterns=1` PASS |
| `ctcan2.sh` u2r, **EXPECT_UNKNOWN=6**, baseline FIRST | `ok=1 changed=0 absent=0 unknown-patterns=6` PASS |
| `canaudit.sh` (run on THIS dir's drivers) | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |

BY NAME, both quoted from the CSVs:

```
InterfaceModPort    base: default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
InterfaceModPort    new : default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
BlackParrotComplex  base: default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
BlackParrotComplex  new : default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
```

Both are `CMP_EQUAL/differ` rows, and a `differ` dump column is BLIND inside the
database. Gate 5 closes it: neither test is among the 3 flagged movers, so both
databases are BYTE-IDENTICAL between pristine and patched in both modes.

The four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by NO driver in this directory — asserted
mechanically by `canaudit.sh`, not by inspection.

---

## 5. THE HEAD, BEFORE AND AFTER

| row | CONTROL (pristine) | FINAL | head identity |
|---|---|---|---|
| **BuildUVMPkg / default** | **58** cmp lines, 1 head | **17**, 1 head | **CHANGED** — was the `ref_obj`/`hier_path` cell at 14107, now a `constant` under `time_var uvm_pkg::uvm_root::phase_timeout` at 38677:23-28 (`RHS: <null>`) |
| **BuildUVMPkg / testflags** | **58**, 1 head | **17**, 1 head | same as default |
| SimpleUVM / default | 54, 1 head | 54, 1 head | head file byte-identical (`diff` clean) |
| SimpleUVM / testflags | 54, 1 head | 54, 1 head | head file byte-identical (`diff` clean) |
| Scoreboard / default | 54, 1 head | 54, 1 head | head file byte-identical (`diff` clean) |
| Scoreboard / testflags | `SLANG_REJECT` at baseline (`use of undeclared identifier 'my_scoreboard'`), no database | same | — |
| SeqDriver / default | 1414877, 1 head | 1414877, 1 head | head file byte-identical (`diff` clean) — still `LHS: <null> / RHS: package uvm_pkg` |
| SeqDriver / testflags | 1414877, 1 head | 1414877, 1 head | head file byte-identical (`diff` clean) |

**THE NEW BuildUVMPkg HEAD, quoted:**

```
LHS: constant: , line:38677:23, endln:38677:28
     |vpiParent: \_time_var: (uvm_pkg::uvm_root::phase_timeout), line:38677:7, endln:38677:20
     |vpiSize:64  |UINT:9200000000000000  |vpiConstType:9
RHS: <null>
```

A `time_var`'s DEFAULT-VALUE constant (`time phase_timeout = `UVM_DEFAULT_TIMEOUT;`)
that we do not emit at all — a different family, and the next target on this row.

---

## 6. RANKED RESIDUES

**R1 — § pkgQualifiedRefQualifierSpan: the package-qualified reference's SPAN.**
Golden spans a `pkg::name` reference over the QUALIFIER ALONE — `p1::`, ending at
the column the final identifier starts on, exactly as § staticScopedRef12 already
does for the CLASS half — and we span the WHOLE written name. Fully decoded and
ready to implement; deliberately NOT landed here because it is a SECOND law with
a much wider blast radius than this pass's head needs, and the head does not
require it (the corpus site is written INSIDE its declaring package, where
`isPkgQualifiedVarRef`'s `pkgViewVarObjs9` gate sends it to
`scopedChainDropRef48`, which already spans the qualifier).

* **Measured population**: a1 cells 47/48/49/59/60/67/68/**71**, a2 K1/K3/K4,
  a3 30/32/35/40/42/44/46/48 — **18 cells**, every one a span-only difference,
  and after this pass they are the ONLY differences left in a1 (span-blind 0).
  **Corpus population: ZERO measured** — gate 5's byte verifier moves nothing
  outside BuildUVMPkg and `predict.sh` names no other database, so R1 is
  arm-visible and corpus-silent TODAY.
* **Direction**: SHRINK the span.
* **Sites**: at least TWO. `isPkgQualifiedVarRef`'s builder
  (`ExprEmit.cpp`, `setLoc(qr9, expr.sourceRange)`) covers the Variable cells;
  a3 cell 35 (`$size(p3::PARR)`, a package PARAMETER) proves a SECOND path mints
  the same wrong span for non-Variable symbols.
* **Gate the next pass must carry**: a2 **K2** — the ASSIGNMENT TARGET keeps the
  WHOLE span (`p2::@@BAD_SYMBOL@@` @5-13) and must not move, so the fix is
  `!inLhs`-gated.
* **Chain interaction**: for a chain whose base has no syntax, the span must come
  from `scopedChainRoot1`, not from the base's `sourceRange`.

**R2 — the BARE qualified read INSIDE the declaring package** (a2 H2/H3/H5,
a4 N4). Golden names it `p2::pcnt` and spans the qualifier; we name it `pcnt`
and span the whole. This is `isPkgQualifiedVarRef`'s `pkgViewVarObjs9` gate,
already documented as a deliberate residue by § staticScopedChainDrops48's own
comment (t67c G6) and left alone here for the same reason. **NAME**, not span,
is the primary defect, and MEMORY.md's naming-is-context-dependent note applies.

**R3 — `p3::E1.name()`, a package ENUM CONSTANT with a built-in method**
(a3 cell 34). Golden **FOLDS** it to a `constant`; we emit a `hier_path`. The
collapse correctly does NOT fire (the symbol is an `EnumValue`, not a
`Variable`), so this pass neither helps nor harms it. Direction: REPLACE with a
folded constant. Zero corpus population measured.

**R4 — the collapsed ref's BINDING.** Golden binds the collapsed `ref_obj`
(`vpiActual`) from a package FREE function (a2 H6) and from a module function
(a2 K4, a1) but NOT from inside a class method (a2 H1, and the corpus head).
We are unbound in all of them. Invisible on the corpus head (which is the
unbound case) and on every cell where our unbound object is what golden holds;
visible as an extra golden `vpiActual` line on H6/K3/K4. Belongs with R1.

**R5 — `Tregistry rgtry;` carries an extra `int_typespec`** (a5 lines 31/41)
where golden's `ref_var` has none: an unspecialized type parameter's local
should not be typed by the parameter's DEFAULT. Adjacent to the head's cell,
owned by nothing here.

**R6 — the LOC-LESS `begin`** of a class method whose body slang rejected
(a5 line 32, and the corpus head's parent block). Golden locates it over the
statement span; we emit it without a location.

---

## 7. BOUNDARIES AND COLLISIONS

* **§ retNameRecvCollapse69 (ExprEmit, landed 7576076) — NO BREACH, and its a3
  arm's cells are re-measured here.** That law owns the RETURN-NAME receiver
  collapse and fires on receivers that name the ENCLOSING FUNCTION. This law
  fires only on receivers written through a `::` SCOPE. The two predicates
  cannot both accept one receiver: a return-name receiver is a bare identifier
  with no `::`, so `scopedChainRoot1` returns null for every cell uvm69 owns,
  and a `::`-scoped receiver is never the enclosing function's return variable.
  Its a3 arm measured 6 NON-return-var receiver kinds where golden KEEPS the
  method shape in EXPRESSION position; **this pass's a1 lines 50-55 and 61-63
  reproduce that result on unscoped receivers in BOTH positions and agree with
  golden on every one**, control and final alike. THE RECONCILIATION the brief
  asked for: statement-vs-expression is NOT this law's axis at all — the `::` is
  — and that is why the two laws' populations are disjoint.
* **§ parensLessCallIsPathRefObj / § parensLessFuncRefIsRefObj (r10svs2) —
  COLLISION, REPORTED, and GOLDEN IS ON THIS PASS'S SIDE.** a1 cell **71**
  (`x += p1::pq.size;`) is the parens-less spelling on a `::`-SCOPED receiver,
  and it **CHANGED**:

  | | objects emitted for a1:71 |
  |---|---|
  | GOLDEN | `ref_obj p1::pq` @10-14 — ONE object |
  | CONTROL (r10svs2's shape) | `hier_path p1::pq.size` @10-21 + `ref_obj p1::pq` @10-16 + `ref_obj size` @17-21 — THREE objects |
  | FINAL | `ref_obj p1::pq` @10-16 — ONE object |

  r10svs2's law says a parens-less built-in is not a call and its last path
  element is a ref_obj named for the METHOD. That is measured on UNSCOPED
  receivers, and on a `::`-scoped one golden drops the whole tail instead —
  § staticScopedChainDrops48 outranks the parens question there. The change is
  therefore a MOVE TOWARD GOLDEN (3 objects → 1, golden has 1), reached through
  § scopedRootFromStmtSyntax1 (the parens-less form's expression carries no
  syntax pointer either). **It is reported as a collision rather than claimed
  clean because it does alter what r10svs2's arm would measure on a scoped
  receiver.** Zero corpus population: the parens-less scoped form emits a
  `hier_path` named `X::Y.Z`, which is exactly `predict.sh`'s `exprForm` rule,
  and that rule names NO database outside BuildUVMPkg across all 1632 databases
  of the two corpora; gate 5's mover list agrees. No r10svs2 driver name is used
  by this pass.
* **§ retNameLocalInstIsHomeNotClass3 (ModuleEmit drainFuncRet ~20876) —
  NOT TOUCHED.** No `vpiInstance` is written anywhere in this diff.
* **§ staticScopedChainDrops48 / § staticScopedRef12 / § staticScopedLvalueBad48
  — EXTENDED, NOT RESPELLED.** The object built for every previously-collapsing
  cell is unchanged in kind, name, span and binding: the two new markers only
  widen WHICH expressions reach the existing builder. a1 cells 56/57/64/65/69 and
  a2 K2/K5 are the arm's proof.
* **§ droppedCall14 — ADJACENT, NOT TOUCHED.** It owns the syntax re-emission of
  a REJECTED statement, and its `stmtSyntax14` member is READ (never written) by
  § scopedRootFromStmtSyntax1. Its own shape check (`droppedCallShape14`)
  requires an IdentifierName receiver and so never saw the corpus head, which is
  `::`-rooted.
* **LIVE PASSES — `ExprEmit.cpp` is SHARED with r10earl41; MEASURED, NOT
  ASSUMED.** At the end of this pass the MAIN tree carried r10earl41's
  work-in-progress. Its `ExprEmit.cpp` hunks (`git diff -U0 --stat`) are
  **one 46-line insertion at line ~342** — immediately after
  `isPkgQualifiedVarRef` — and a group at **~12468-12992**. This pass's hunks are
  three new static functions plus three one-line edits inside the
  § staticScopedChainDrops48 block at **~637-850**, and one argument at its call
  site at **~4267**. **The two sets do not overlap and share no context line**,
  which is why `/tmp/r10buvm1.patch` applies clean to ba7d1ef and will rebase
  over r10earl41 without conflict. **But note for R1's future implementer:
  r10earl41 is editing right at `isPkgQualifiedVarRef`, which is R1's FIRST
  site — re-read that function before touching its `setLoc`.**
  **r10uvm70** works in ModuleEmit/TaskFuncEmit/EmitHelpers — no overlap.
* **THE MAIN-TREE BINARY HAS MOVED SINCE THIS PASS'S ANCHOR.** When the control
  was validated, `~/git-repos/slang-uhdm/build/slang-uhdm` was
  `eb2d9506c9c64c69afc90c16c3f49d08`, byte-identical to the pristine ba7d1ef
  build. By the end of the pass another live agent had rebuilt it to
  `d8ca12914c36904a8565bf68e9b5d074`. **A future reader re-running
  `md5sum build/slang-uhdm` in the main tree will NOT reproduce the anchor**;
  the anchor is reproducible only by building ba7d1ef from source, which is what
  `/tmp/wt_r10buvm1pris` is. Both worktrees are deliberately LEFT IN PLACE so
  the two md5s in the table above can be re-checked; the four sweep WORKDIRS
  were deleted.

---

## 8. REFUTATIONS, stated plainly

1. **The brief's "shared-fix multi-row family" is FALSE.** The cell exists only
   in UVM 1800.2-2017-1.0; uvm-1.2 (SimpleUVM, Scoreboard, SeqDriver, UVMSwitch,
   UVMNestedSeq) has no `uvm_registry_common` and no `__deferred_init` at all
   (§1.3). BuildUVMPkg's two rows are the entire population.
2. **The brief's "is this specific to BUILT-IN methods?" answer is NO.** Golden
   collapses a USER class method on a scoped receiver identically (a1 cells 48,
   57, 60, 65) — and we already did too. Built-in vs user is a defect of OUR
   walk, not a property of golden's law.
3. **"To package-var receivers?" — NO.** A CLASS-scoped static (a1 56/64) and a
   type-parameter scope collapse the same way. The discriminator is the written
   `::`, not what it names.
4. **"Statement vs expression position" — NOT THE AXIS.** a1's expression cells
   59/60/64/65/67/68 collapse exactly like its statement cells. That is the
   reconciliation with § retNameRecvCollapse69's a3 arm: those cells had no `::`
   and are owned by a different law entirely.
5. **"Does the span equal the RECEIVER IDENTIFIER text?" — NO.** It is the
   QUALIFIER, `uvm_pkg::`, ending where the final identifier starts (§1.1). A
   `::`-scoped CALL spans one column less (the package name without the `::`),
   which is why the two must be measured separately.
6. **"Is the argument truly dropped?" — YES**, and so is the method name, in
   every one of the 14 collapsing arm cells and in golden's head.
7. **This pass's own first law — "a built-in method on a `::` receiver
   collapses" — is INSUFFICIENT.** It fixed every arm cell and moved the corpus
   head by zero bytes (§2). A pass that had shipped after the arms went green
   would have reported a cleared head that was still there.
