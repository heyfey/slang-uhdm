# r10uvm70 — `§ implicitRetSigningIsIntVar70`: the 54-line head **CLEARED on all THREE target rows**, and the brief's own reading of the flag is **REFUTED** — `vpiSigned:1` does not mean *signed*, it means *a signing keyword was WRITTEN*

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines — whole ROW, dump column included — **0 differing ROWS** on
both.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**.
`SimpleUVM/default`, `SimpleUVM/testflags` and `Scoreboard/default` each sat at
**54** cmp lines on the identical head
`int_var (uvm_pkg::uvm_tr_stream::get_recorders) @371:13-371:21` whose two
divergences were the object CLASS (`int_var` vs our `logic_var`) and a missing
`|vpiSigned:1`. All three now sit at **593** cmp lines on a head in a different
family and a different file — golden `LHS: <null>` against our
`function (uvm_pkg::uvm_objection::new) @127:3`, a **task_func VECTOR ENTRY**
we mint and golden does not. `54 → 593` is **HEAD DEPTH, not distance**: the
head OBJECT changed, so the old divergence is gone. The new head is
byte-identical across all three rows (§6.4).

**THIRD LINE, and it is the finding worth more than the patch. THE BRIEF ASKED
THE RIGHT QUESTION AND ITS FIRST ANSWER WAS WRONG.** The brief wrote:

> "Surelog appears to map a bare-signing implicit return type to `int_var` and
> stamp `vpiSigned:1` **regardless of the keyword's direction** (or the flag
> means *signing was written* — decode, don't assume)."

The second reading is the true one, and the grid decides it in one cell.
`function unsigned f_bare_u;` (arm a1, `8:12-8:20`) is stamped `vpiSigned:1`
in golden. There is no sense in which that variable is signed. Meanwhile
`function int unsigned f_int_u;` (a1 `49:12-49:24`) — where the SAME keyword
sits on an EXPLICIT base — carries **no flag at all** on either side. So the
flag is not a property of the resulting type and not a property of the keyword
either: **it records that a signing keyword was written on a type that had no
base**, and the emitter's old gate asked `retType.isSigned()`, which is exactly
the question golden does not ask.

That mis-reading had already cost three of the family's four cells:

| written | old arm | golden | old ours |
|---|---|---|---|
| `function unsigned f;` | missed (`isSigned()` false) | `int_var` + `vpiSigned:1` | `logic_var` |
| `function signed f;` | missed (`ct` is not a PackedArray) | `int_var` + `vpiSigned:1` | `logic_var` |
| `function unsigned [3:0] f;` | missed (`isSigned()` false) | `int_var` + `vpiSigned:1` | `logic_var` |
| `function signed [3:0] f;` | **hit** | `int_var` + `vpiSigned:1` | `int_var` + `vpiSigned:1` |

One of four. The pre-existing arm was not wrong, it was **a quarter of a law**.

Base **19730ce**. Worktree `/tmp/wt_r10uvm70`; pristine control worktree
`/tmp/wt_r10uvm70pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print
`19730ce655fe913bbd12a503d5ef9599e09225f3`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 19730ce) | `d90af4f662bab7e66f24bfe6258a8f9b` | my own build of the base commit |
| **SHIPPED (patched)** | **`839793c33f4ec8c3d4dcc130fc3e5168`** | every number below was measured on THIS binary |

BUILD DIRS (absolute): `/tmp/wt_r10uvm70/build`, `/tmp/wt_r10uvm70pris/build`,
both `-j 2`. `[100%] Linking CXX executable slang-uhdm` → `[100%] Built target
slang_uhdm` was read before any md5 was taken; every md5 was asserted in its own
command against `^[0-9a-f]{32}$`. **The control is anchored twice**: the MAIN
TREE's `build/slang-uhdm` at `HEAD == 19730ce` is *also*
`d90af4f662bab7e66f24bfe6258a8f9b`, i.e. my pristine build reproduces the
committed binary byte for byte. `git stash` was never used. `results/*.csv` were
only ever READ. slang was not patched. `GOLDEN_DEFER` was left **UNSET** (echoed
as `[UNSET]` at every sweep launch). The four slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched — `canaudit.sh` proves it mechanically (FENCE-BREACH=0).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and in every script
in this directory.

---

## 0. THE LAW

### § implicitRetSigningIsIntVar70

*A subroutine's RETURN variable whose return type is written as an **IMPLICIT
base type** — no type keyword at all — carrying a **WRITTEN SIGNING KEYWORD** is
an **`int_var` stamped `vpiSigned:1`**. This holds in **both directions**
(`unsigned` exactly as `signed`) and **with or without a packed range**, and at
**every factory that mints a return variable**: the ordinary in-body one
(in-class method, out-of-body `extern` body, package-homed and module-homed
function), the PURE VIRTUAL prototype, the DPI-IMPORT prototype and
`drainFuncRet`'s per-reference body local. The flag records that **a signing
keyword was written on a type that had no base**, NOT that the type is signed.
An implicit type with **no** signing (`function f;`, `function [3:0] f;`) keeps
its old object; an **explicit** base carrying a signing keyword (`logic signed`,
`reg signed`, `bit unsigned`, `int unsigned`) is not an implicit type at all and
is untouched. The **TYPESPEC** stays a `logic_typespec` and was already correct —
golden's own object disagrees with itself here, and that disagreement is the
shape's fingerprint.*

```
uvm-1.2/src/base/uvm_tr_stream.svh
371    function unsigned get_recorders(ref uvm_recorder q[$]);   <- the head
uvm-1.2/src/base/uvm_tr_database.svh
186    function unsigned get_streams(ref uvm_tr_stream q[$]);    <- its sibling,
                                                                   found by the
                                                                   census, not
                                                                   by the brief
```

**These two lines are the ENTIRE `function <signing>` population of uvm-1.2**
(§1.3), and the census found the second one before a line of code was written —
which is exactly what the brief's "golden SimpleUVM may hold MORE bare-signing
cells than this one" warned to look for.

### Where this sits in the signedness family the campaign has now decoded five times

| carrier | law | keys on |
| --- | --- | --- |
| module- / class-scope variable | `namedTy9` (r10c15, `makeVar`) | the type **AS WRITTEN** |
| `array_var` | `§ arrayVarSignedWritten8` (r10oth8) | the ELEMENT type **AS WRITTEN** |
| array ELEMENT typespec | `§ arrayElemTsSignedParented9` (r10oth9) | the element type **RESOLVED** |
| subroutine/statement-scope atom variable | `§ atomVarSignedWritten68` (r10uvm68) | the type **AS WRITTEN** |
| **implicit-base RETURN variable** | **`§ implicitRetSigningIsIntVar70`** | **whether a signing keyword was WRITTEN — not its direction** |

The first four all ask *what type is this*. This one asks *what did the author
type*, and it is the first member of the family for which the answer is
independent of the type entirely.

### STATED GATE == CODE GATE — read off the source, not the comment

ONE predicate, `implicitRetWrittenSigning70`, in `src/EmitHelpers.h`, consumed
at **4 call sites**, all of them return-variable factories:

```bash
grep -n  "implicitRetSigningIsIntVar70" src/EmitHelpers.h src/TaskFuncEmit.cpp src/ModuleEmit.cpp
grep -c  "implicitRetWrittenSigning70(" src/EmitHelpers.h src/TaskFuncEmit.cpp src/ModuleEmit.cpp
#   src/EmitHelpers.h:1     (the definition)
#   src/TaskFuncEmit.cpp:3  src/ModuleEmit.cpp:1   (the 4 sites)
```

The code gate is **exactly two tests**, in this order, and nothing else:

```cpp
if (!rs || rs->kind != syntax::SyntaxKind::ImplicitType)   // (1) NO base type written
    return false;
return rs->as<syntax::ImplicitTypeSyntax>().signing.valid();  // (2) a signing keyword IS written
```

and the arm it gates, inside `makeReturnVar`:

```cpp
if (implicitWrittenSigning70) {
    auto* v = s.MakeInt_var();
    v->VpiSigned(true);
    return v;
}
```

* **(1) is the whole fence against the explicit-base cells.** `logic unsigned`,
  `reg signed`, `bit unsigned`, `int unsigned`, `int signed` are
  `IntegerTypeSyntax`, never `ImplicitType`, so they cannot reach the arm — and
  a1's five explicit-base cells (`32`, `35`, `38`, `41`, `44`) plus the three
  atom cells (`49`, `52`, `55`) are all `EQ` before AND after (§2.1).
* **(2) is what makes `function f;` and `function [3:0] f;` safe.** Both are
  `ImplicitType` with an INVALID signing token; a1 cells `24` (a location-less
  bare return var) and `27` are `EQ` before and after.
* **There is deliberately NO type test in the arm.** The old text had two
  (`ct.kind == PackedArrayType` and `retType.isSigned()`) and each of them
  silently dropped a real cell. An `ImplicitTypeSyntax` with a signing token can
  only produce a logic scalar or a packed array of logic, so a type test can add
  nothing but another way to be wrong.
* **`VpiSigned(true)` on a freshly-minted `int_var`** — `vpiSigned` is a plain
  bool with no unset state and the dump prints it only when true.

### The four sites, each with the arm cell that demands it

| # | file | what mints the return var | arm cell |
|---|---|---|---|
| 1 | `src/TaskFuncEmit.cpp` (~3008) | THE ordinary return var: in-class method, out-of-body `extern` body, package free function, module function | a3 `16:14` `get_recorders`, `24:14` `get_signed`, `29:14` `get_ranged`, `52:12` `holder3::ex_u`, `59:12` `pk_u`; a1 `8`, `11`, `16`, `19` |
| 2 | `src/TaskFuncEmit.cpp` (~2940) | DPI-IMPORT prototype's synthesized return var | a4 `18:27` — **ZERO population, and golden emits no object here at all** (§5.2) |
| 3 | `src/TaskFuncEmit.cpp` (~2402) | PURE VIRTUAL prototype's synthesized return var | a4 `12:27` `pv_u`, `13:27` `pv_s` |
| 4 | `src/ModuleEmit.cpp` (~20622) | `drainFuncRet`'s per-reference body local | a4 `25:12` `selfref_u`, `29:12` `selfref_s` |

**Site 3 is the one a "just widen the existing arm" patch would have missed**:
the pure-virtual factory did not pass the flag at all, because a prototype has
no `FunctionDeclarationSyntax` and therefore no `returnTypeSyntax(sub)`. Its
return-type syntax had to be **hoisted above the factory call** — the block that
computes `prsyn` is byte-for-byte the one that used to sit *after* it; only its
position moved. Arm a4's `pv_u`/`pv_s` are the cells that caught it.

### COLLISION CHECK — one FENCE, one ADJACENCY, no collision

* **`§ atomVarSignedWritten68`** (`clearNamedAtomSigned68`, 7 sites) is the
  brief's named boundary and it **cannot fire on this shape**: its first test is
  `declared.kind == SymbolKind::TypeAlias`, and an implicit type reached by no
  NAME is a `ScalarType` or a `PackedArrayType`, never a `TypeAlias`. The two
  laws are the OPPOSITE directions of the same field on disjoint populations —
  68 CLEARS the flag where a NAME was written, 70 SETS it where a SIGNING
  KEYWORD was written on no type at all. Measured, not argued:
  `b68fence.sh` re-runs **all six** of 68's arms through both binaries and every
  one of the six databases is **byte-identical** (§4.1).
* **`§ retLocalPkgRangeBind67`** owns package-homed return-var RANGE binds via
  `tfTypeScope`, set *before* the return type is compiled; site 4 here chooses
  the object's CLASS at the factory. Different field, no shared state.
* **`makeReturnVar` is ALSO the element-reg factory** (six other call sites in
  `TypeEmit` / `TaskFuncEmit` / `ParamEmit` / `StmtEmit`), and uvm68's lesson —
  *gate post-factory* — is honoured differently here and deliberately so: the
  new parameter **defaults to `false`**, so all six element-reg sites are
  unchanged by construction. There is nothing to gate post-factory because
  nothing else can turn the arm on.
* **Live passes.** `r10sd3` shares `TaskFuncEmit.cpp`: my three hunks there are
  at ~2402, ~2940 and ~3008 (return-variable factories); `r10sd3`'s territory is
  the `vpiInstance` `class_defn` purge in `ParamEmit`/`TaskFuncEmit`.
  `r10earl41` is in `TypeEmit`/`ExprEmit`, which this patch does not touch at
  all. `ModuleEmit.cpp` is touched at ~20622 only. Narrow hunks, no overlap
  observed.

---

## 1. THE CENSUS, BOTH SIDES, SPAN-KEYED — RUN FIRST, BEFORE ANY CODE

### 1.1 The shape has a fingerprint: the object DISAGREES WITH ITS OWN TYPESPEC

`ct70pop.py` censuses every VARIABLE object of one side by
(kind × ACTUAL typespec kind × `vpiSigned`) and names the rows where the two
kinds disagree. On the SimpleUVM/default GOLDEN dump (1 140 700 content lines,
`sed 1d`), 7 118 variable objects:

```
var kind           actual typespec          signed   count  agreement
...
int_var            int_typespec             -          414
int_var            int_typespec             1          596
int_var            logic_typespec           1            2   MISMATCH   <- THE SHAPE
...
logic_var          logic_typespec           -           18
logic_var          event_typespec           -            2   MISMATCH
class_var          struct_typespec          -            4   MISMATCH
class_var          unsupported_typespec     -           28   MISMATCH
---- MISMATCHED objects: 36
```

`int_var` + `logic_typespec` + `vpiSigned:1` occurs **exactly twice**, and the
`--list` names both:

```
int_var  logic_typespec  signed=1  uvm_pkg::uvm_tr_database::get_streams    186:13-186:21
int_var  logic_typespec  signed=1  uvm_pkg::uvm_tr_stream::get_recorders    371:13-371:21
```

The brief named one of these. **The census found the other**, and it is in the
same file family and the same shape — `function unsigned get_streams(ref
uvm_tr_stream q[$]);`.

### 1.2 The same census on OURS: the shape has ZERO instances

`ct70pop.py` on our pristine dumps for all **seven** UVM databases returns **no
`int_var`/`logic_typespec` row at all**. Instead each holds two `logic_var`
objects at exactly those spans:

```
$ grep -cE '\\_logic_var: \(uvm_pkg::uvm_tr_(stream::get_recorders|database::get_streams)\)' o_*.dump
o_Scoreboard.default   4        o_SimpleUVM.default    4
o_SeqDriver.default    4        o_SimpleUVM.testflags  4
o_SeqDriver.testflags  4        o_BuildUVMPkg.*        0   <- see below
```

`4` is **2 objects × 2 dump prints** (the full print plus the `ref_typespec`'s
back-print) — an object is not a dump occurrence.

**BuildUVMPkg reads 0 and that is not an absence.** It compiles a single
pre-elaborated `uvm_pkg.sv`, so the same two declarations live at
`23504:13` (`get_streams`) and `24195:13` (`get_recorders`). Its golden carries
the same two `int_var`/`logic_typespec` objects and ours the same two
`logic_var`s. **A grep keyed on the head's line numbers would have reported
BuildUVMPkg as out of population and predicted 5 movers instead of 7.**

### 1.3 The census-PREDICTION, made before any sweep ran

The shape is decidable from SOURCE, so the mover set was predicted by name
first. Over **both corpora** (`Surelog/tests`, `Surelog/third_party/tests`,
`uhdm2rtlil/test`):

```bash
grep -rlnE "function[[:space:]]+(automatic[[:space:]]+|static[[:space:]]+)?(signed|unsigned)([[:space:]]|\[)" ...
```

finds **five** non-UVM files, and **every one of them writes `signed [N:0]`** —
the single cell the old arm already handled:

| file | line |
|---|---|
| `uhdm2rtlil/test/const_func/dut.sv` | `function signed [31:0] negate;` |
| `uhdm2rtlil/test/func_tern_hint/dut.sv` | `function automatic signed [3:0] dunk;` |
| `Surelog/tests/StringRange/dut.sv` | `function signed [31:0] negate;` |
| `third_party/tests/Verilator/t_math_signed.v` | `function signed [15:0] copy_signed;` |
| `third_party/tests/Yosys*/asicworld/…v2k_reg.v` | `function signed [7:0] adder;` |

and the UVM tree contributes exactly the two `function unsigned` lines of §0.

**PREDICTION (recorded before the byte verifier ran): 7 movers on the surelog
corpus — SimpleUVM ×2 modes, Scoreboard/default, SeqDriver ×2 modes,
BuildUVMPkg ×2 modes (Scoreboard/testflags is `SLANG_REJECT` and has no
database) — and 0 on uhdm2rtlil.** §6.5 is what the sweep produced.

---

## 2. THE GRID, CELL FOR CELL

Four arms, run through BOTH binaries. `KEY=sp` keys each cell on its SOURCE SPAN
alone, so a KIND change stays ONE cell and is reported `DIFFERKIND`; `NAMERE=`
scopes the table to the arm's own scope, because Surelog synthesizes
`builtin.sv` in the CWD and its `std::` objects land on line numbers that
COLLIDE with the arm's (the first run of this table reported
`int_var@24:14-24:17`, a span the arm source does not contain).

### 2.1 arm a1 — the RETURN-TYPE grid (module-homed functions)

`G` = golden, `O` = ours. **CONTROL** is the pristine binary, **FINAL** the
patched one.

| line | written | golden | ours CONTROL | ours FINAL |
|---|---|---|---|---|
| 8 | `function unsigned f;` | `int_var` `signed=1` `logic_ts` | `logic_var` `-` **DIFFERKIND** | `int_var` `signed=1` **EQ** |
| 11 | `function signed f;` | `int_var` `signed=1` `logic_ts` | `logic_var` `-` **DIFFERKIND** | `int_var` `signed=1` **EQ** |
| 16 | `function unsigned [3:0] f;` | `int_var` `signed=1` `logic_ts` | `logic_var` `-` **DIFFERKIND** | `int_var` `signed=1` **EQ** |
| 19 | `function signed [3:0] f;` | `int_var` `signed=1` `logic_ts` | `int_var` `signed=1` EQ | `int_var` `signed=1` EQ |
| 24 | `function f;` | `logic_var` `-` no span, no ts | EQ | EQ |
| 27 | `function [3:0] f;` | `logic_var` `-` `logic_ts` | EQ | EQ |
| 32 | `function logic unsigned f;` | `logic_var` `-` `logic_ts` | EQ | EQ |
| 35 | `function logic signed f;` | `logic_var` `-` `logic_ts` | EQ | EQ |
| 38 | `function logic unsigned [3:0] f;` | `logic_var` `-` `logic_ts` | EQ | EQ |
| 41 | `function bit unsigned f;` | `bit_var` `-` `bit_ts` | EQ | EQ |
| 44 | `function reg signed f;` | `logic_var` `-` `logic_ts` | EQ | EQ |
| 49 | `function int unsigned f;` | `int_var` **`-`** `int_ts` | EQ | EQ |
| 52 | `function int signed f;` | `int_var` `signed=1` `int_ts` | EQ (+span residue R7) | EQ (+span residue R7) |
| 55 | `function byte unsigned f;` | `byte_var` `-` `byte_ts` | EQ | EQ |
| 60 | `function int f;` | `int_var` `signed=1` `int_ts` | EQ | EQ |
| 63 | `function logic f;` | `logic_var` `-` `logic_ts` | EQ | EQ |

`cells=17 EQ=13 DIFFERKIND=3` → `cells=17 EQ=16 DIFFERKIND=0`. **`a1_ret` goes
from `CMP_FAIL` at 54 cmp lines to `PASS_CMP`, 0 heads.**

**Read row 35 against row 11 and row 49 against row 8.** `logic signed` gets
NO flag while bare `signed` gets one; `int unsigned` gets NO flag while bare
`unsigned` gets one. Neither the keyword's presence nor its direction explains
that on its own — only "signing written on a type with no base" does.

### 2.2 arm a3 — the head's OWN shape: class method in a package

| line | written | golden | CONTROL | FINAL |
|---|---|---|---|---|
| 16 | `function unsigned get_recorders(ref rec3 q[$]);` | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 24 | `function signed get_signed(...)` | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 29 | `function unsigned [7:0] get_ranged();` | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 34 | `function get_implicit();` | `logic_var` `-` no span | EQ | EQ |
| 39 | `function logic unsigned get_lg_u();` | `logic_var` `-` | EQ | EQ |
| 52 | `function unsigned holder3::ex_u();` (out-of-body) | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 59 | `function unsigned pk_u();` (package free fn) | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 44 | `var unsigned prop_u;` (class PROPERTY) | `int_var` `-` **`int_ts`** | `logic_var` DIFFERKIND | DIFFERKIND — **R2, untouched** |
| 45 | `var signed prop_s;` (class PROPERTY) | `int_var` `-` **`int_ts`** | `logic_var` DIFFERKIND | DIFFERKIND — **R2, untouched** |
| 49 | `extern function unsigned ex_u();` (prototype) | `int_var` `1` `logic_ts` @`49:21` | ours emits it at the BODY's span | **R3, untouched** |
| 53 | `var unsigned exl_u;` (body local) | *golden emits NO object* | ours emits one | **R4, untouched** |

`cells=16 EQ=7 DIFFERKIND=7` → `cells=16 EQ=12 DIFFERKIND=2`.

**The class-PROPERTY cells (44/45) are the pass's second refutation and the
reason the law says RETURN VARIABLE and not VARIABLE.** Golden's property object
is an `int_var` with an **`int_typespec`** and **NO `vpiSigned`** — a *different*
answer to the same spelling, agreeing with itself where the return variable does
not. A law stated as "implicit + signing → int_var + vpiSigned" would have
stamped a flag golden omits AND left the typespec wrong. Ranked R2.

### 2.3 arm a4 — the OTHER three return-var factories

| line | written | golden | CONTROL | FINAL |
|---|---|---|---|---|
| 12 | `pure virtual function unsigned pv_u();` | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 13 | `pure virtual function signed pv_s();` | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 15 | `pure virtual function int pv_int();` | `int_var` `1` `int_ts` | EQ | EQ |
| 25 | `function unsigned selfref_u;` (drainFuncRet) | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 29 | `function signed selfref_s;` (drainFuncRet) | `int_var` `1` `logic_ts` | `logic_var` DIFFERKIND | **EQ** |
| 33 | `function int selfref_i;` | `int_var` `1` `int_ts` | EQ | EQ |
| 19 | `import "DPI-C" function int dpi_int();` | `int_var` `1` `int_ts` | EQ | EQ |
| 18 | `import "DPI-C" function unsigned dpi_u();` | *golden emits NO Return var* | ours emits a `logic_var` | ours emits an `int_var` — **R5** |
| 14 | `pure virtual function pv_imp();` | `logic_var`, no span | ours spans `14:36` | **R6, untouched** |

`cells=10 EQ=3 DIFFERKIND=4` → `cells=10 EQ=7 DIFFERKIND=0`.

### 2.4 arm a2 — the SITE axis, and it is the patch's NEGATIVE control

Module ports, module-scope variables, subroutine formals, body locals and block
locals, all with the same spelling. **Not one cell moved**, and the arm's
dump-diff content is **205 before and 205 after**:

| line | written | golden | CONTROL | FINAL |
|---|---|---|---|---|
| 13 | `var unsigned mv_u;` (module scope) | `logic_var` `-` | EQ | EQ |
| 14 | `var signed mv_s;` (module scope) | `logic_var` **`-`** | `logic_var` **`signed=1`** DIFFER | DIFFER — **R1, untouched** |
| 15 | `var unsigned [3:0] mv_ur;` | `logic_var` `-` | EQ | EQ |
| 16 | `logic unsigned mv_lg_u;` | `logic_var` `-` | EQ | EQ |
| 26–28, 31, 40 | `var unsigned/signed` body & block locals, task local | *golden emits NO object* | ours emits one | **R4, untouched** |

**Row 14 is the mirror image of this pass's law and it is deliberately left
alone.** At MODULE scope golden gives an implicit-plus-signing variable a
`logic_var` with NO flag in BOTH directions, while we over-stamp the `signed`
spelling. Same syntax, different scope, opposite answer — which is precisely why
the law is scoped to the RETURN VARIABLE and why widening it to `makeVar` would
have been a regression dressed as a generalisation. Ranked R1.

---

## 3. WHAT THE LAW DELIBERATELY DOES NOT DO

* It does not touch the **typespec**. Golden's `logic_typespec` at `371:13` is
  what we already emit, and the brief's instruction ("do not disturb it") is
  honoured structurally: the patch only chooses the variable's class and sets
  one bool.
* It does not touch **module-scope variables, class properties, formals, ports,
  body locals or block locals** (§2.2, §2.4). Every one of those was measured,
  and three of them (R1, R2, R4) go a DIFFERENT way from this law.
* It does not touch **element regs**. `makeReturnVar` is also the element-reg
  factory at six other call sites; the new parameter defaults to `false`, so
  those sites are unchanged by construction rather than by a guard that could
  drift.

---

## 4. THE BOUNDARY THE BRIEF NAMED

### 4.1 `§ atomVarSignedWritten68` — measured, not argued

`b68fence.sh` runs **all six** of `r10uvm68repro`'s arms (`a1_scope`,
`a2_atom`, `a3_flavour`, `a4_typaram`, `a5_proto`, `a6_tdarray`) through the
CONTROL and the FINAL binary and compares OUR databases to each other:

```
CTL=d90af4f662bab7e66f24bfe6258a8f9b  FIN=839793c33f4ec8c3d4dcc130fc3e5168
  a1_scope:    OURS-DUMP-IDENTICAL (68's arm untouched)
  a2_atom:     OURS-DUMP-IDENTICAL
  a3_flavour:  OURS-DUMP-IDENTICAL
  a4_typaram:  OURS-DUMP-IDENTICAL
  a5_proto:    OURS-DUMP-IDENTICAL
  a6_tdarray:  OURS-DUMP-IDENTICAL
---- arms=6  MOVED=0
PASS: § atomVarSignedWritten68's a1-a6 all byte-identical.
```

**A trap this check walked into and now encodes.** The first run reported ALL
SIX as MOVED. `uhdm-dump` prints `file:<absolute path>`, the two runs use
different workdirs, and the payload was identical in every one — the diff
content counts (179/251/154/20/344/237) were the same on both sides. The script
normalises the workdir out before comparing and says why in its header. A check
that cannot tell a path from a payload is worse than no check.

### 4.2 The structural reason the fence cannot be breached

`clearNamedAtomSigned68`'s first test is
`declared.kind != SymbolKind::TypeAlias → return`. This law's population is an
IMPLICIT type reached through NO name, which slang models as a `ScalarType` or a
`PackedArrayType`. The two predicates are disjoint by construction, and they run
in a fixed order at three of the four sites (factory first, `clear…68` second) —
so even a hypothetical overlap would resolve to 68's answer, not this one's.

---

## 5. NARROWNESS: the sites where the law fires into a KNOWN residue

### 5.1 The DPI-IMPORT prototype (site 2)

Golden emits **no Return variable at all** for
`import "DPI-C" function unsigned dpi_u();` (a4 cell `18:27`, golden side
empty). We emit one, and we did before this pass too. The law changes that
object's CLASS from `logic_var` to `int_var`; it does not create it and does not
remove it. **Neither corpus contains the spelling**, so it moves no byte
anywhere (§6.5 accounts for every mover). It is gated here rather than left
inconsistent so that all four callers of the factory state the same predicate —
and it is written down here rather than discovered later.

### 5.2 What a narrower patch would have looked like

Gating only site 1 would have cleared the head and left `pv_u` / `selfref_u`
disagreeing with their own declarations. Gating the factory unconditionally
would have reached six element-reg call sites the brief fences. The chosen shape
— an explicit, default-`false` parameter consumed at exactly the four
return-variable factories — is the only one that is both complete and inert
elsewhere.

---

## 6. THE FIVE GATES, each with the number measured on the FINAL binary

### GATE 1 — BUILD

`cmake --build build -j 2` → `[100%] Linking CXX executable slang-uhdm` /
`[100%] Built target slang_uhdm`, read before any md5 was taken. Then, in a
SEPARATE command:

```
PRISTINE=d90af4f662bab7e66f24bfe6258a8f9b
FINAL=839793c33f4ec8c3d4dcc130fc3e5168
OK: BINARY md5 CHANGED d90af4f662bab7e66f24bfe6258a8f9b -> 839793c33f4ec8c3d4dcc130fc3e5168
32-hex OK
```

Validity anchor, printed before any edit: the main tree's `build/slang-uhdm` at
`HEAD == 19730ce` is **also** `d90af4f662bab7e66f24bfe6258a8f9b`.

### GATE 2 — GOLDENS

`tests/check_goldens.sh` on the FINAL binary: **23 PASS / 0 FAIL**.
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

`default` **469 CMP_EQUAL / 11 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT /
25 SURELOG_FAIL; `testflags` **465 CMP_EQUAL / 8 CMP_NOTEQUAL** / 5 DEFERRED /
286 SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE /
1 TIMEOUT / 1 NO_UHDM. Dump column 225 match (default) / 165 match (testflags),
244 / 300 differ. Every figure equals the expected one. WHOLE-ROW judge:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` was left UNSET: the 5 memory-giant tests read `DEFERRED` in both
modes, exactly as the baseline does.

### 6.4 THE HEAD, before and after, on all four UVM tests

`rowheads.sh` on the pristine and the final workdir. LHS is ALWAYS golden.

| row | CONTROL cmp lines | head object (CONTROL) | FINAL cmp lines | head object (FINAL) |
|---|---|---|---|---|
| **SimpleUVM/default** | **54** | `int_var (…get_recorders) @371:13` vs our `logic_var` | **593** | `LHS:<null>` vs our `function (uvm_pkg::uvm_objection::new) @127:3` |
| **SimpleUVM/testflags** | **54** | *same* | **593** | *same* |
| **Scoreboard/default** | **54** | *same* | **593** | *same* |
| SeqDriver/default | 1414877 | `LHS:<null>` vs our `package uvm_pkg @28:1` | 1414881 | **same head object** |
| SeqDriver/testflags | 1414877 | *same* | 1414881 | *same* |
| BuildUVMPkg/default | 58 | `ref_obj (…uvm_deferred_init) @14107:7` | 58 | **unchanged** |
| BuildUVMPkg/testflags | 58 | *same* | 58 | **unchanged** |

* **All three target rows CLEARED.** The head object changed family and file;
  `54 → 593` is head DEPTH. The new head is byte-identical across the three rows
  (its first 12 lines `cmp` equal pairwise), and it is a **task_func VECTOR
  ENTRY** (`LHS: <null>` against an object we mint) — the shape the standing
  rules call out.
* **SeqDriver did NOT regress.** Its head is the same `package uvm_pkg` object
  as before (pass 2's `§ instanceIsNeverAClassDefn2` head, still open); +4 lines
  is the decompile of that one head printing the two objects that changed class,
  twice each.
* **BuildUVMPkg is unmoved at 58**: its two population objects sit BEHIND a
  `hier_path` head that this pass does not touch. Its database still moves
  (§6.5) — a head is not a distance.

### GATE 5 — BYTE VERIFIER, both corpora, BOTH modes, vs the PRISTINE 19730ce workdir I built

`SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched-wd> <pristine-wd>`:

```
surelog / both modes:
  databases: patched=953 pristine=953
  PATH_SETS_IDENTICAL (953 paths)
  MOVERS: 7 / 953
  SELFCHECK: 952 / 953 flagged        SELFCHECK1: 8

uhdm2rtlil / testflags:
  databases: patched=679 pristine=679
  PATH_SETS_IDENTICAL (679 paths)
  MOVERS: 0 / 679
  SELFCHECK: 678 / 679 flagged        SELFCHECK1: 1
```

Both negative controls fire on both corpora (`SELFCHECK1`'s 8 = the 7 real
movers plus the one corrupted file).

#### 6.5.1 THE MOVERS WERE PREDICTED BY NAME BEFORE THE SWEEP RAN

§1.3's prediction was **7 on surelog and 0 on uhdm2rtlil**, named:
`default/{SimpleUVM, Scoreboard, SeqDriver, BuildUVMPkg}` and
`testflags/{SimpleUVM, SeqDriver, BuildUVMPkg}` — `Scoreboard/testflags` is
`SLANG_REJECT` and has no database. **The sweep produced exactly those seven and
nothing else.**

#### 6.5.2 SIZE-DELTA, 3 REPS ON BOTH BINARIES — and one mover where the size law is NOT ENOUGH

| mover | patched | pristine | delta |
|---|---|---|---|
| default/SimpleUVM | 11118641 | 11118646 | **−5** |
| default/SeqDriver | 17962370 | 17962372 | **−2** |
| default/BuildUVMPkg | 11097331 | 11097319 | **+12** |
| testflags/SimpleUVM | 11118953 | 11118958 | **−5** |
| testflags/SeqDriver | 17962809 | 17962804 | **+5** |
| testflags/BuildUVMPkg | 11097331 | 11097319 | **+12** |
| **default/Scoreboard** | 11122938 | 11122938 | **0** ← read on |

`detcheck.sh`, 3 reps, BOTH binaries:

| test | PRISTINE | FINAL |
|---|---|---|
| SimpleUVM/default | **1 distinct hash**, bytes 11118646 ×3 | **1 distinct hash**, bytes 11118641 ×3 |
| Scoreboard/default | **2 distinct hashes**, bytes **11122938 ×3** | **3 distinct hashes**, bytes **11122938 ×3** |

**SimpleUVM is fully deterministic on both binaries**, so its −5 is a clean,
unambiguous real mover.

**Scoreboard/default is the interesting one, and it is a correction to the way
this campaign words its own rule.** It is NONDETERMINISTIC on BOTH binaries
(the pre-existing emitter nondeterminism already in MEMORY.md), its size is
**STABLE at 11122938 within each binary and IDENTICAL between them**, so the
standing shorthand *"same-size = flake, size-delta = real"* classifies it as a
**flake — and it is not one.** The change here swaps one object class for
another in a Cap'n Proto arena and sets a bool that already had storage, so a
zero byte-delta is exactly what it should produce. **The size test is NECESSARY,
NOT SUFFICIENT**: a size delta proves a mover real, a zero size delta proves
nothing either way, and the authority in that case is the per-shape content
analysis below — which names Scoreboard's two changed objects individually and
gives it the same `gain=10` as its six siblings.

#### 6.5.3 MOVERS PER-SHAPE vs GOLDEN BY MULTISET, ADDED and REMOVED SEPARATELY

`mv70.sh` on each mover; LHS is ALWAYS golden. **All seven are identical**:

| mover | msdist pristine | msdist patched | **gain** | ADDED | REMOVED |
|---|---|---|---|---|---|
| default/SimpleUVM | 143558 | 143548 | **10** | 6 | 4 |
| default/Scoreboard | 133908 | 133898 | **10** | 6 | 4 |
| default/SeqDriver | 365670 | 365660 | **10** | 6 | 4 |
| default/BuildUVMPkg | 80150 | 80140 | **10** | 6 | 4 |
| testflags/SimpleUVM | 143554 | 143544 | **10** | 6 | 4 |
| testflags/SeqDriver | 365670 | 365660 | **10** | 6 | 4 |
| testflags/BuildUVMPkg | 80150 | 80140 | **10** | 6 | 4 |

**Every mover moves TOWARD golden; not one regresses.** The shapes are the
law's own population and nothing else:

```
-- ADDED shapes (instances)
   2   |vpiSigned:1
   1   \_int_var: (uvm_pkg::uvm_tr_stream::get_recorders)      (full print)
   1       \_int_var: (uvm_pkg::uvm_tr_stream::get_recorders)  (ref_typespec back-print)
   1   \_int_var: (uvm_pkg::uvm_tr_database::get_streams)
   1       \_int_var: (uvm_pkg::uvm_tr_database::get_streams)
-- REMOVED shapes (instances)
   1   \_logic_var: (uvm_pkg::uvm_tr_stream::get_recorders)
   1       \_logic_var: (uvm_pkg::uvm_tr_stream::get_recorders)
   1   \_logic_var: (uvm_pkg::uvm_tr_database::get_streams)
   1       \_logic_var: (uvm_pkg::uvm_tr_database::get_streams)
```

`mv70.sh` prints **ADD-ONLY FALSIFIED** on every mover and that is **CORRECT and
EXPECTED**: this law RE-CLASSES an object, so every `int_var` line added has a
`logic_var` line removed underneath it. A pass claiming add-only would have been
refuted by this instrument.

**AN INSTRUMENT DEFECT FOUND AND FIXED BEFORE LANDING.** `mv1.sh`, inherited
from `r10sd1` via `r10uvm69`, printed its shape listing with ONE ROW PER DELTA
ENTRY and then `uniq -c`'d the normalised texts, so the count column meant
"distinct delta entries carrying this text", not instances. On these movers the
header said `ADDED line instances=6` while the listing's counts summed to **5**,
because `|vpiSigned:1` moved by **+2 in a single entry** and printed as `1`. A
shape table whose numbers do not reconcile with the total above it is precisely
how "N lines added" becomes "N different shapes" in a write-up. `mv70.sh` now
expands each entry's multiplicity and the table reconciles (2+1+1+1+1 = 6).

#### 6.5.4 THE PER-OBJECT CHECK — our census now EQUALS golden's

`ct70pop.py` on the PATCHED SimpleUVM/default database:

```
int_var   logic_typespec   signed=1        2   MISMATCH
  int_var  logic_typespec  signed=1  uvm_pkg::uvm_tr_database::get_streams   186:13-186:21
  int_var  logic_typespec  signed=1  uvm_pkg::uvm_tr_stream::get_recorders   371:13-371:21
```

Same kinds, same typespec, same flag, same spans, same fullnames as golden's
census in §1.1 — **cell for cell**. Our `logic_var`/`logic_typespec` population
falls from 18 to 16 by exactly those two objects.

---

## 7. RESIDUES, RANKED

| # | residue | evidence | why not this pass |
|---|---|---|---|
| **R1** | module-scope `var signed x;` — golden `logic_var` with NO `vpiSigned`, ours stamps `1`. An OVER-fire, opposite direction to this law | a2 `14:18-14:22`, DIFFER before and after | different scope, different answer; a `makeVar` change with no UVM population and real corpus reach |
| **R2** | class PROPERTY `var unsigned/signed p;` — golden `int_var` + **`int_typespec`** + NO flag; ours `logic_var` + `logic_typespec` | a3 `44:18`, `45:18` | needs the TYPESPEC to move too, which the brief fences; zero UVM population |
| **R3** | `extern function unsigned f();` PROTOTYPE return var carries the BODY's span, not the prototype's | a3 `49:21` golden vs ours at `52:12` | span-only; the CLASS is now right at both |
| **R4** | `var <implicit+signing> x;` as a subroutine / block / task LOCAL — golden emits NO variable object, we emit one | a2 `26,27,28,31,40`; a3 `53` | an over-emit, not a mis-class; larger surface than this head |
| **R5** | DPI-IMPORT prototype with an implicit-signing return — golden emits no Return var, we do (now an `int_var`) | a4 `18:27` | zero population in either corpus; §5.1 |
| **R6** | fully-implicit `pure virtual function f();` return var is spanless in golden, spanned in ours | a4 `14:36` | span-only, pre-existing |
| **R7** | `function int signed f;` return var spans `int` in ours, `int signed` in golden — while `int unsigned` agrees | a1 `52:12-52:15` vs `52:12-52:22` | span-only; `uhdm-cmp` does not compare locations, so it cannot reach a head |
| **R8** | the new head on the three target rows: we mint a `function (uvm_pkg::uvm_objection::new)` task_func vector entry golden does not have | §6.4 | the NEXT head, stated so the next pass starts mid-thought |

---

## 8. THE CANARIES

```
canaries.sh  (surelog csv) : ok=52 changed=0 absent=0 unknown-names=7
    InterfaceModPort    default/testflags  OK  CMP_EQUAL/differ     <- BY NAME
    BlackParrotComplex  default/testflags  OK  CMP_EQUAL/differ     <- BY NAME
    SimpleUVM/SeqDriver/BuildUVMPkg  both modes  OK  CMP_NOTEQUAL
    Scoreboard          default OK CMP_NOTEQUAL / testflags OK SLANG_REJECT
canaries.sh  (u2r csv)     : ok=8  changed=0 absent=0
ctcan2.sh  EXPECT_UNKNOWN=1 (surelog): ok=58 changed=0 absent=0 unknown=1   PASS
ctcan2.sh  EXPECT_UNKNOWN=6 (u2r)    : ok=1  changed=0 absent=0 unknown=6   PASS
canaudit.sh: audited=29  UNCOVERED=0  FENCE-BREACH=0                        PASS
b68fence.sh: arms=6  MOVED=0                                                PASS
```

Both `ctcan2` expectations are the MODE-MATCHED ones the script's own header
records (1 on a surelog csv, 6 on a uhdm2rtlil csv), and the baseline was read
FIRST in both cases. The four slang-fenced tests appear in no driver in this
directory.

---

## 9. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm70repro
# the grid, either binary
SLANG_UHDM=<bin> ./ct70arm.sh a1_ret.sv  /tmp/x_a1 && \
  KEY=sp NAMERE='^work@a1\.'      python3 ct70cells.py /tmp/x_a1/g.dump /tmp/x_a1/o.dump
SLANG_UHDM=<bin> ./ct70arm.sh a2_site.sv /tmp/x_a2 && \
  KEY=sp NAMERE='^work@a2\.'      python3 ct70cells.py /tmp/x_a2/g.dump /tmp/x_a2/o.dump
SLANG_UHDM=<bin> ./ct70arm.sh a3_cls.sv  /tmp/x_a3 && \
  KEY=sp NAMERE='^(work@)?p3'     python3 ct70cells.py /tmp/x_a3/g.dump /tmp/x_a3/o.dump
SLANG_UHDM=<bin> ./ct70arm.sh a4_proto.sv /tmp/x_a4 && \
  KEY=sp NAMERE='^(p4::|work@a4)' python3 ct70cells.py /tmp/x_a4/g.dump /tmp/x_a4/o.dump
# the population census, ONE SIDE per run
python3 ct70pop.py <dump>            # add --list for every mismatched object
# the boundary the brief names
./b68fence.sh <ctrl-bin> <final-bin>
# the head on the target rows
./rowheads.sh <verify_golden workdir> <outdir> SimpleUVM Scoreboard SeqDriver BuildUVMPkg
```
