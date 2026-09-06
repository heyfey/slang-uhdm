# r10uvm167 — § `shellCallKeepsItsSyntax167` — **A CALL THAT REACHES THE EMITTER AS THE SALVAGED CHILD OF A BAD-EXPRESSION SHELL HAS NO `syntax` OF ITS OWN, AND EVERY WRITTEN-ARGUMENT DECODER THEN LISTS THE CALLEE'S DEFAULTED FORMALS** — the SeqDriver ×2 + SimpleUVM ×2 **338-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW WAS CONVERTED**. `GOLDEN_DEFER` was never set.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `11bff799` |
| worktree | `/tmp/wt_r10uvm167` |
| pristine binary | md5 `e4b0ad2eaaa961655ca6db50502e4928`, built from a clean `11bff799` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `4e483ba954976cc5b68a417184b72470`, frozen `chmod 555` before any sweep |
| production surface | `src/EmitHelpers.h` (**+73 / −12**: the guard, the ONE accessor, and three decoders re-pointed at it), `src/ExprEmit.cpp` (**+43 / −4**: the ONE site that arms the guard, and the second inline reader) |
| probe surface | `tools/probe/r10uvm167repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **338** | **50** | 1 — a **NEW head**, a different object (§7) |
| **SimpleUVM default / testflags** | **338** | **17** | 1 — a **different** new head (§7) |
| Scoreboard default | 95 | 95 | 1 unchanged |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged |
| BuildUVMPkg default / testflags | 29 | 29 | 1 unchanged |
| Earlgrey_0_1 default / testflags | 34 | 34 | 1 unchanged |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes; the surelog status histogram is IDENTICAL (`CMP_NOTEQUAL` stays 10 default / 9 testflags) and uhdm2rtlil stays `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2` in both modes | |
| byte movers | — | **7 / 956** surelog, **every one PREDICTED BY NAME**; **0 / 1358** uhdm2rtlil | |
| the family census (9 UVM row-modes, both views) | — | **14 CALL cells + 28 ARG cells moved, ALL TOWARD; 0 AWAY, 0 RESHAPE-AWAY, 0 WRONG, 0 ORPHAN** | |
| the grid (4 arms, both views) | — | **CALL 52 TOWARD / ARG 106 TOWARD / OBJ 76 TOWARD; 0 AWAY, 0 RESHAPE-AWAY** on CALL and ARG in every arm | |
| the WIDE boundary (4689 arms, both views) | — | **4 moved arms, RC_DIFFS 0**; 3 are this pass's own grid (the positive control), the 4th is `r10v103repro/arms/v103_c5_slots.sv` — this law's own population — which the JUDGE takes from 176 / 208 cmp lines to **0, CMP_EQUAL in both views** | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size. `head_pris_SeqDriver.default.cmp` (338 lines) is the head the
brief named; `head_pat_SeqDriver.default.cmp` (50) and
`head_pat_SimpleUVM.default.cmp` (17) are the new ones.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduced the brief exactly —
SeqDriver ×2 **and** SimpleUVM ×2, **338 cmp lines, 1 head, ONE object on four
row-modes**. (Scoreboard/default read 95 rather than 145 on both binaries: that
row is RESUME §9's ~50/50 COIN and both faces are pristine.)

From `head_pris_SeqDriver.default.cmp` — uvm-1.2 `base/uvm_misc.svh:720`, inside
`uvm_utils#(TYPE,FIELD)::get_config`:

```systemverilog
comp.uvm_report_fatal( "GET_CFG_TYPE_FAIL",                      // :720
                  {"set_config_object with field name ",FIELD,
                  " is not of type '",TYPE::type_name,"'"},
                  UVM_NONE , `uvm_file , `uvm_line );            // :723
```

Golden lists the **FIVE WRITTEN** arguments. We listed **SEVEN** — the same five
plus two constants at `uvm_report_object.svh` `236:33` (`""`) and `237:37` (`0`),
which are `uvm_report_object::uvm_report_fatal`'s own formal defaults for
`context_name` and `report_enabled_checked`.

## 2. QUESTION 1 — THE JUDGE, DECODED FIRST

`method_func_call::Compare`
(`~/git-repos/UHDM/build/generated/src/method_func_call.cpp:80-97`) delegates
FIRST to `basetype_t::Compare`, which is `tf_call::Compare`
(`tf_call.cpp:87-102`), and that runs, in this order:

```cpp
  if ((r = SafeCompare(lhs->Scope(), rhs->Scope(), context)) != 0) return r;                 // :94
  if ((r = SafeCompare(lhs, lhs->Tf_call_args(), rhs, rhs->Tf_call_args(), context)) != 0)   // :95
      return r;
  if ((r = lhs->VpiName().compare(rhs->VpiName())) != 0) { … }                               // :96
```

Line `:95` is the **VECTOR** `SafeCompare` (`BaseClass.h:201-208`), and its size
arm is the whole answer:

```cpp
  if ((lhs != nullptr) && (rhs != nullptr)) {
      int32_t r = 0;
      if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) {
          context->m_failedLhs = lhs_obj;      // the OWNER
          context->m_failedRhs = rhs_obj;      // the OWNER
          return 1;
      }
      for (size_t i = 0, n = lhs->size(); i < n; ++i)   //  <-- NEVER REACHED
          if ((r = SafeCompare(lhs->at(i), rhs->at(i), context)) != 0) return r;
```

Three facts fall out, and every one of them matters:

* **NEITHER SIDE IS WALKED.** The size test short-circuits BEFORE the per-element
  loop, so the judge stops at the CALL, not at any argument. "Which side does
  Compare walk first" has no answer here — it walks neither.
* **A SIZE MISMATCH IS NOT A SINGULAR NULL.** The singular overload
  (`:187-197`) names ONE side and prints `LHS: <null>` / `RHS: <null>`; this arm
  sets `m_failedLhs` **and** `m_failedRhs` to the SAME OWNER OBJECT, one from
  each database, which is why the head prints BOTH sides in full and why the
  count is 338 — the head object's decompile, twice, for a call whose argument
  list is five and seven expressions deep.
* **`VpiName` AND `Scope` ARE NOT EVIDENCE.** `Scope` was compared and agreed;
  `VpiName` sits AFTER the vector and was never reached. Only the vector SIZE
  is on the record.

`5 - 7` in `size_t` wraps and truncates to `-2`; the arm returns `1` regardless
of direction, so the head does not tell you WHICH side is longer. The census
does (§4).

## 3. QUESTION 2 — SURELOG'S LISTING RULE, ON EVERY FACE, BEFORE A FILTER WAS WRITTEN

Read off Surelog goldens built by `grid167.sh`
(`-parse -nocache -nowritecache -noprecompiledcache -d coveruhdm [-elabuhdm]`),
every command echoed with its binary PATH into the arm's own `cmds.txt` and
every rc recorded. `g167_a_shell.sv` and `g167_b_spell.sv` each carry every face
TWICE — once inside a bad-expression shell (`sh_*`) and once with a bindable
argument in its place (`cl_*`) — so the shell is the only variable.

| face | formals | written | **golden lists** |
|---|---|---|---|
| method, positional, trailing defaults | 5 | 5 / 3 / 2 | **5 / 3 / 2** |
| method TASK, positional | 3 | 1 / 2 | **1 / 2** |
| method, NAMED, a MIDDLE formal skipped (`.a(x), .c(9)`) | 3 | 2 | **2** — written only |
| method, NAMED, REORDERED (`.c(x), .a(1)`) | 3 | 2 | **2** — in WRITTEN order |
| method, MIXED positional + named | 3 | 2 | **2** |
| ALL formals defaulted, EMPTY PARENS `all167()` | 2 | 0 | **0** |
| CONSTRUCTOR `new(x)` with trailing defaults | 2 | 1 | **1** |
| `this.` / `super.` method call | 2 | 1 | **1** |
| written argument TEXTUALLY EQUAL to its default (`mid167(x,3,0)`, `all167(1,2)`) | 3 / 2 | 3 / 2 | **3 / 2** — a written actual is written |
| WRITTEN-BUT-EMPTY slot `pf167(x, 2, )` | 3 | 3 | **3** — the empty slot IS a listed argument, holding Surelog's own `INT:0` |
| **RECEIVER-LESS `func_call`, NAMED (`pf167(.a(x), .c(9))`)** | 3 | 2 | **3 — ONE SLOT PER FORMAL**, the unwritten one a LOC-LESS `INT:0` |
| **RECEIVER-LESS in-class BARE call, NAMED (`im167(.c(x), .a(1))`)** | 3 | 2 | **3 — the same**, in FORMAL order |
| receiver-less `func_call` / `task_call`, POSITIONAL | 3 / 2 | 1 | **1** |
| `Rcv167::st167(x)` — a `::`-SCOPED static call | 2 | 1 | **no tf_call at all** — golden emits one bare `ref_obj` named `Rcv167::st167` |

> **DOES GOLDEN EVER LIST AN UNWRITTEN ARGUMENT? YES — ON EXACTLY ONE FACE.**
> A **RECEIVER-LESS `func_call` / `task_call` written with NAMED association**
> gets ONE `vpiArgument` PER FORMAL, in FORMAL order, with a LOC-LESS
> `INT:0` placeholder standing for every formal the call site did not write.
> That is § `namedTfArgsFormalSlots4` (r10buvm4), re-measured here from scratch,
> and it is the whole AWAY column: a filter that shortened THAT face would go
> short of golden. Every other face lists the WRITTEN actuals and nothing else.
>
> And the SHELL IS INVISIBLE TO GOLDEN. Every `sh_*` cell above equals its
> `cl_*` twin, in both views. Surelog binds nothing through `::`, so it compiles
> a call whose argument fails to bind exactly as it compiles a clean one — which
> is what makes the defect ENTIRELY ours.

## 4. QUESTION 3 — THE DISCRIMINATOR, AND WHY IT WAS MISSING

### 4.1 The slang mechanism, read not guessed

`CallExpression::bindArgs`
(`slang/source/ast/expressions/CallExpression.cpp:214-280`) walks the FORMALS,
not the written actuals. A formal with no written actual takes

```cpp
        else {
            expr = formal->getDefaultValue();          // :259
```

and **any** bad argument poisons the whole call:

```cpp
            bad |= expr->bad();                        // :277
```

`fromArgs` then mints the call and throws the SHELL over it:

```cpp
    auto result = comp.emplace<CallExpression>(&symbol, symbol.getReturnType(), thisClass,
                                               boundArgs.copy(comp), context.getLocation(), range);
    if (bad)
        return badExpr(comp, result);                  // :316-319
```

`badExpr` is `alloc.emplace<InvalidExpression>(expr, ErrorType::Instance)`
(`Expression.cpp:1609-1611`) — it does not touch the child. Back in
`Expression::create`, the `InvocationExpression` arm stamps the syntax on
whatever came back:

```cpp
        case SyntaxKind::InvocationExpression:
            result = &CallExpression::fromSyntax(compilation, syntax.as<…>(), nullptr, context);
            if (result->syntax) return *result;         // :872-881
            break;
        …
    result->syntax = &syntax;                           // :1002   <-- the SHELL, not the call
```

**So the CallExpression the emitter finally emits — § `invalidShellKeepsStmtPos103`
unwraps it at `ExprEmit.cpp:31980` — carries `syntax == nullptr`.** Every
written-argument decoder in the emitter starts from
`call.syntax->as_if<InvocationExpressionSyntax>()`, gets `nullptr`, and falls
back to `call.arguments().size()` — the BOUND list, defaults and all.

### 4.2 The discriminator is SYNTACTIC PRESENCE, and it is the shell's own syntax

The shell's `syntax` **IS** the call's `InvocationExpressionSyntax`. Handing it
back restores the exact question every existing decoder was measured on:
`writtenCallArgs16` counts the WRITTEN parameters, `emptyArgSlots24` finds the
written-but-empty ones, `writtenArgsInOrder4` remaps a named METHOD call into
written order, and `namedTfSlots4` gives a named BARE call its formal-slot shape.

A value or span test would have been wrong twice over, and the grid proves both
halves: `g167_a_shell.sv`'s `sh_eqdef` writes `mid167(x, 3, 0)` and
`all167(1, 2)` — arguments textually **equal to their defaults** — and golden
lists all three and both; `g167_b_spell.sv`'s `sh_trailing_empty` writes
`pf167(x, 2, )`, where golden's third slot is `INT:0` **at the empty slot's own
span**, not the formal's default `5` at the declaration.

### 4.3 THE CORPUS'S OWN SHELL TRIGGER, isolated in 0.85 s

`comp.uvm_report_fatal(…)` at `uvm_misc.svh:720` is shelled by ONE of its five
written arguments: `TYPE::type_name`, a `::`-scoped read through the type
parameter of a generic class's DEFAULT specialization (`TYPE` defaults to `int`,
slang looks `type_name` up in `int`, finds nothing, and inside a generic class
its diagnostics are suppressed). Bisected on a scratch COPY of the uvm-1.2 tree
compiled alone (`uvm_pkg.sv`, 0.85 s per run):

| the argument list at :720-723 | our N |
|---|---|
| as written | **7** |
| `` `uvm_file `` / `` `uvm_line `` replaced by literals | 7 — **not the macros** |
| the concatenation replaced by `"aaa"` | **5** |
| `{"aa ",FIELD}` — a type-parameter VALUE | **5** |
| `{"aa ",TYPE::type_name}` — a type-parameter SCOPE | **7** |

and reproduced in a 16-line package (`{"aa ",T167::type_name}` → 7;
`{"aa ",T167::foo}` → 7; `{"aa ",FLD167}` → 5; `"plain"` → 5).

## 5. THE LAW

> **§ `shellCallKeepsItsSyntax167`** — *a `CallExpression` that reaches the
> emitter as the salvaged CHILD of an `InvalidExpression` shell carries no
> `syntax` of its own; the SHELL holds the call's `InvocationExpressionSyntax`.
> Hand it back, keyed on the exact child pointer, and every written-argument
> decoder answers exactly what it would have answered had slang not wrapped the
> call: the vpiArgument list is the arguments WRITTEN AT THE CALL SITE, an
> unwritten formal contributes nothing, a written-but-empty slot contributes
> Surelog's `INT:0`, and a receiver-less NAMED call keeps its one-slot-per-formal
> shape.*

### 5.1 STATED GATE == CODE GATE

**ONE FILTER**, and it is an ACCESSOR, not a trimmer:

```cpp
// src/EmitHelpers.h
inline const slang::ast::Expression*                shellCall167 = nullptr;
inline const syntax::InvocationExpressionSyntax*    shellInv167  = nullptr;
struct ShellCallSyntax167 { … RAII save/restore … };

inline const syntax::InvocationExpressionSyntax* callInvocation167(
    const CallExpression& call) {
    if (call.syntax)
        return call.syntax->as_if<syntax::InvocationExpressionSyntax>();
    return (static_cast<const slang::ast::Expression*>(&call) == shellCall167)
               ? shellInv167 : nullptr;
}
```

**It is IDENTICAL to the expression it replaces whenever the call has a syntax
node of its own**, so nothing off the shell can move — which is what makes
`g167_d_decline.sv` byte-identical on the two binaries in both views.

**THE ONE SITE THAT ARMS IT** — `src/ExprEmit.cpp:31980`, inside
§ `invalidShellKeepsStmtPos103`'s child unwrap, the only place a shell is opened:

```cpp
    ShellCallSyntax167 sh167(
        (iv2.child->kind == ExpressionKind::Call && !iv2.child->syntax) ? iv2.child : nullptr,
        expr.syntax ? expr.syntax->as_if<syntax::InvocationExpressionSyntax>() : nullptr);
    auto* r103 = emitExpr(*iv2.child, parent, prefix, netMap);
```

Keyed on the **EXACT CHILD POINTER**, so a syntax-less call nested inside one of
THIS call's own arguments can never read it; scoped to the unwrap alone; and
inert unless the shell's syntax really is an invocation (a paren-less call
wrapped in a shell reads `nullptr` and is untouched). The emitter is
single-threaded (`grep -rn 'std::thread|#pragma omp|std::async' src/ include/`
is empty), so one guard object with RAII restore is re-entrant-safe.

**THE FOUR READERS**, all of which start from the same accessor now:

| reader | law | what it decides |
|---|---|---|
| `writtenCallArgs16` (EmitHelpers.h) | § `writtenCallArgs16` | how many arguments were written |
| `callArgList24` (EmitHelpers.h) | § `emptyArgSlotIntZero24` | which written slots were left EMPTY |
| `writtenArgsInOrder4` (EmitHelpers.h) | § `namedMethodArgsWritten4` | a named METHOD call's written order |
| `namedTfSlots4` (EmitHelpers.h) | § `namedTfArgsFormalSlots4` | a named BARE call's one-slot-per-formal shape |
| the inline copy at `ExprEmit.cpp:22220` | the RECEIVER-LESS `func_call` / `task_call` arm | `nWritten9` + `namedArgs9` |

**THE SECOND READER IS WHY THIS IS NOT A ONE-LINE PASS.** The receiver-less
`func_call` / `task_call` arm re-implements § `writtenCallArgs16` INLINE and read
`expr.syntax` directly, so a first cut that fixed only the EmitHelpers accessor
left every bare call inside a shell listing the callee's defaults — grid arm B's
`sh_pkg_pos` / `sh_in_pos` / `sh_pkg_task` / `sh_in_task`, golden 1, ours 3.
Re-pointing it is deliberately the **WHOLE BLOCK, not the count alone**: the same
block sets `namedArgs9` and feeds `namedTfSlots4`, and a shelled NAMED bare call
must take the FORMAL-SLOT shape golden gives it (§3) rather than the positional
trim — trimming it would have been the pass's only possible AWAY move.

### 5.2 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| `call.syntax` present → identical expression | **FIRES, everywhere** | `g167_d_decline.sv` is BYTE-IDENTICAL in both views; 949 of 956 surelog and all 1358 uhdm2rtlil databases are byte-identical |
| the shell arm, METHOD face | **FIRES — this is the head** | `uvm_report_fatal`@720:14 and `uvm_report_warning`@725:14 in 7 databases |
| the shell arm, RECEIVER-LESS face | **UNEXERCISED on the corpus** | grid arm B `sh_pkg_pos` / `sh_in_pos` / `sh_pkg_task` / `sh_in_task` are its only coverage. Stated rather than hidden |
| the shell arm, NAMED faces | **UNEXERCISED on the corpus** | arm B `sh_pkg_named` / `sh_in_named` (bare, formal slots) and `sh_meth_named` / `sh_meth_mixed` (method, written order) |
| the shell arm, EMPTY SLOT | **UNEXERCISED on the corpus** | arm B `sh_trailing_empty` and the BOUNDARY's own `r10v103repro/arms/v103_c5_slots.sv` |
| the exact-pointer key | — | arm A's `sh_all` writes `comp.all167() + comp.mid167(T::type_name)`: two calls in one expression, one shelled and one not, and both come out golden's |
| the "not an invocation" abstain | — | arm A `sh_static` (`Rcv167::st167(x)`): golden emits no call at all, ours keeps its pre-existing `func_call` (residue R1) |

## 6. THE MEASUREMENTS

### 6.1 QUESTION 4 — THE CENSUS, and THE PREDICTION MADE FIRST — `PREDICT.r10uvm167.txt`

`predsweep167.sh` censused **956 surelog** and **1358 uhdm2rtlil** databases
against their Surelog goldens with the PRISTINE binary only, and reported both
directions: **OURS-LONGER** (the law's bucket) and **GOLDEN-LONGER** (the AWAY
column). A cell whose two sides differ in COPY COUNT is a listing residue, not a
vector one, and is excluded.

```
surelog     TRUE vector-size cells, OURS LONGER    14  (7 databases, 2 each)
            TRUE vector-size cells, GOLDEN LONGER   0
uhdm2rtlil  either direction                        0
```

**PREDICTION, BY NAME:** `default/{MiniAmiq, Scoreboard, SeqDriver, SimpleUVM}`
and `testflags/{MiniAmiq, SeqDriver, SimpleUVM}` — seven databases, two cells
each, `uvm_report_fatal`@720:14-720:30 and `uvm_report_warning`@725:14-725:32,
`G=[5] O=[7]` in every one. Nothing else in either corpus. BuildUVMPkg moves
nothing: its `uvm_pkg` (the 1800.2 pp_output) carries no `uvm_utils` class.

*A first cut predicted from OUR databases ALONE — flagging any call carrying an
argument located outside the caller's subroutine, which is what a defaulted
formal's clone always is. It over-predicted by three orders of magnitude (22605
cells across 9 databases) because uvm-1.2 is built on MACROS and a macro-expanded
`$display` argument is legitimately located in another file. That mode is kept
as `ct167cen --pred` and is NOT the prediction of record.*

### 6.2 MEASURED — `byteverify.sh SELFCHECK=1`, both corpora — `GATES.r10uvm167.txt`

```
surelog     PATH_SETS_IDENTICAL (956)   MOVERS 7 / 956   SELFCHECK 955/956 flagged
uhdm2rtlil  PATH_SETS_IDENTICAL (1358)  MOVERS 0 / 1358  SELFCHECK 1357/1358 flagged
```

**Seven movers, seven predictions, no residue either way.** Every one attributed
ORDER-BLIND (`attrib167.sh`: both databases dumped, the workdir path normalised
away, both sides sorted) — `MOVERS.r10uvm167.txt`:

**30 differing lines each, EVERY ONE A DELETION, and not one line outside the
law**: the four defaulted-formal constants (two per call, two calls per database)
with their `vpiParent` / `vpiArgument` / `vpiDecompile` / value / `vpiConstType`
lines. **`default/Scoreboard-59431470` is RESUME §9's ~50/50 COIN** and is
attributed the same way: 30 differing lines out of 1,100,372 — the
`svunit_pkg` `vpiTaskFunc` order flip did not land this run.

### 6.3 THE FAMILY CENSUS — `CENSUS.r10uvm167.txt`

Nine UVM row-modes (Scoreboard/testflags has no golden), golden vs PRISTINE vs
PATCHED, keyed on `(RUN, kind, name, span, home, prefix-kind)` with the ARGUMENT
VECTOR SIZE as the cell's VALUE:

```
CALL   TOWARD 14   RESHAPE-TOWARD 0   AWAY 0   RESHAPE-AWAY 0   WRONG 0   ORPHAN 0   STILL 160202
ARG    TOWARD 28   RESHAPE-TOWARD 0   AWAY 0   RESHAPE-AWAY 0   WRONG 0   ORPHAN 0   STILL 322094
```

They are exactly the fourteen predicted, and the 28 ARG rows are the two removed
slots of each: `#5 constant 236:33 ""` and `#6 constant 237:37 0` on
`uvm_report_fatal`, `#5 constant 171:36 ""` and `#6 constant 172:39 0` on
`uvm_report_warning`. Every other cell of every one of the nine is unmoved.

**A SCORING TRAP WORTH RECORDING.** A first cut of `score167.py` kept `N=` INSIDE
the cell key. A call whose vector goes 7 → 5 then reads as one cell DELETED and
one INSERTED, and arm A scored `4 AWAY + 4 TOWARD` on the same four objects. The
argument-vector size is what this pass MOVES, so it is the cell's VALUE, not part
of its identity. (`ARG|` and `OBJ|` rows carry no value: they are pure identity
multisets.) The RUN tag stays in every key — r10uvm166 §6's rule, because merging
the DEF-view and ELAB-view databases into one multiset manufactures phantoms.

### 6.4 QUESTION 6 — THE GRID — `GRID.r10uvm167.txt`

```
                       CALL                       ARG                        OBJ
g167_a_shell     TOWARD 18  AWAY 0  ORPHAN 4  TOWARD 48  AWAY 0        TOWARD 26  AWAY 0
g167_b_spell     TOWARD 14  AWAY 0  ORPHAN 0  TOWARD 38  AWAY 0        TOWARD 29  W/A 3
g167_c_homes     TOWARD 20  AWAY 0  ORPHAN 0  TOWARD 20  AWAY 0        TOWARD 21  W/A 1
g167_d_decline   TOWARD  0  AWAY 0  ORPHAN 0  TOWARD  0  AWAY 0        TOWARD  0  AWAY 0
-- CALL+ARG: MOVED-TOWARD 158, MOVED-WRONG/AWAY 0, in every arm and both views
```

and **THE JUDGE on every arm** (`armjudge167.sh`, `uhdm-cmp` golden-vs-pristine
and golden-vs-patched, both views):

| arm | def pris → pat | elab pris → pat |
|---|---|---|
| `g167_a_shell` | 210 → **38** | 218 → **38** |
| `g167_b_spell` | 88 → **0** (CMP_EQUAL) | 166 → **0** (CMP_EQUAL) |
| `g167_c_homes` | 120 → **17** | 128 → **17** |
| `g167_d_decline` | 0 → 0 | 0 → 0 |

**The axes.** Call KINDS: function / task / method function / method task /
receiver-less bare / package free function / static (`Class::m`) / `this.` /
`super.` / constructor `new`. DEFAULT POSITIONS: one trailing, two trailing, a
MIDDLE one reached by named association, ALL of them. SPELLINGS: positional /
named / mixed / reordered named / empty parens / a written-but-empty slot /
written-equals-default. HOMES: package class (static and instance methods),
MODULE, INTERFACE, PROGRAM, and — in arm C — a SECOND shell mechanism
(`nosuch167::val` inside an uninstantiated generate branch), so the law is not
secretly keyed on the generic class the corpus happens to use. Both views
everywhere.

**`g167_d_decline.sv` IS THE NEGATIVE CONTROL AND IT IS A REAL ONE.** Surelog
compiles `Pc8`-style units for it — `grid167.sh` prints the unit list, r10uvm166
§4.4's trap — and it carries ordinary positional calls with trailing defaults,
written-equals-default calls, calls with NO defaults and NO formals, a NAMED
receiver-less call (the AWAY face), BUILT-IN methods (whose receiver is
`arguments()[0]`, so a written-count trim would eat the receiver), SYSTEM calls,
tasks, and written-but-empty slots. Its two databases are **BYTE-IDENTICAL on the
two binaries in both views**, and its cmp against golden is 0 lines on both.

The three OBJ `WRONG`/`AWAY` cells in arms B and C are loc-less, home-less
AGGREGATES — `constant||0:0-0:0|<none>`, `ref_typespec||0:0-0:0`,
`param_assign` — where my key collapses every anonymous object of a kind into one
cell. They are OBJECT SHARING, not content: golden reuses ONE `INT:0` placeholder
across seven slots and we mint six for eight, and the UHDM elaborator clones one
`parameter`/`param_assign` per bound argument. **No generated `Compare` reads
`VpiParent`, so sharing versus copying is invisible to the judge** (RESUME §9) —
and the judge agrees: arm B goes to **0 cmp lines in both views** with those
cells present. The ARG rows, which ARE what the judge walks, match golden slot
for slot.

**Arm A's four `ORPHAN` cells** are cells GOLDEN HAS NO OBJECT FOR:
`func_call st167`@101:14 (golden emits § `staticScopedCall12`'s bare `ref_obj`
`Rcv167::st167`, no call at all — residue R1) and `method_func_call vm167`@106:50
with `SPELL=none` (golden's `super.` call carries a `constant "super"` prefix,
ours none — § 84/85's pre-existing residue, which the SPELL key separates). Both
went from listing 2 arguments to listing 1, which is the written count; neither
has a golden vector to be away from.

### 6.5 THE WIDE BOUNDARY — `BOUNDARY.r10uvm167.txt`

`bound167.sh` over a COPY of the WHOLE `tools/probe` tree — top level AND
subdirectories, both views, both binaries, children `</dev/null`, the file list
on fd 3, PROCESSED asserted against LISTED, scratch keyed on the RELATIVE path:

```
LISTED=4689 PROCESSED=4689 PRODUCED_DBS=4533 MOVED_ARMS=4 RC_DIFFS=0
```

Three of the four are this pass's own grid arms — the positive control that
proves the gate can see — and `g167_d_decline.sv` is byte-identical, which is
what it exists to be. **The one foreign arm is
`r10v103repro/arms/v103_c5_slots.sv`, the verifier arm of
§ `invalidShellKeepsStmtPos103` — this law's own population**, a call inside a
bad-expression shell with EMPTY ARGUMENT SLOTS. Re-measured against a Surelog
golden built for it: `CALL 2 TOWARD / ARG 8 TOWARD / OBJ 6 TOWARD, 0 AWAY`, and
the JUDGE takes it from **176 (def) / 208 (elab) cmp lines to ZERO — CMP_EQUAL in
both views**. (Its two ARG cells scored `WRONG` are the same elaborated-view
COPY-COUNT residue described above; their content is golden's.)

## 7. GATES — `GATES.r10uvm167.txt`

All eight green. Goldens **23 PASS / 0 FAIL** on both binaries and **0 PASS /
23 FAIL** with `SLANG_UHDM=/bin/false`; uhdm2rtlil **679 / 50 / 2** in BOTH
modes; the surelog status histogram IDENTICAL to pristine; `ct8rows` PASS
against the committed baselines AND against this pass's own pristine sweeps,
status and dump columns, both corpora, both modes; **no row converted**; canaries
`ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS ×2; `canaudit audited=29
UNCOVERED=0 FENCE-BREACH=0`; the five protected databases byte-identical with the
**SVSwitch `4842211c4030`** and **YosysVerx `6ccda350c24a`** pins held in both
modes.

**THE SHIPPED PATCH WAS REBUILT FROM A FRESH `11bff799` WORKTREE** — `git apply`
of `/tmp/r10uvm167.patch` onto a clean checkout, `cmake --build -j 2` — and the
result is **BIT-IDENTICAL** to the swept patched binary (md5
`4e483ba954976cc5b68a417184b72470`), 23/23 goldens on it. Every gate above
therefore stands for the shipped source, not for a worktree state.

**Every `cmds.txt` was audited BY BINARY PATH** (not by the string `slang-uhdm`,
which also matches the goldens cache): 1523 surelog + 1458 uhdm2rtlil invocations
per binary, every one naming that binary's frozen `/tmp/r10uvm167_bin/*.bin`;
**zero** main-tree and zero worktree-`build/` leakage, on both sweeps.

## 8. RESIDUES AND R0

**R0 — TWO NEW HEADS, and they are DIFFERENT objects on the two rows.**

* **SeqDriver ×2, 50 lines** (`head_pat_SeqDriver.default.cmp`) — a
  **`VpiType`** mismatch, `BaseClass::Compare`'s FIRST test, which is why both
  sides print in full. `adpcm_pkg::uvm_revision_string`'s body
  (`return uvm_revision;` at `34:10-34:22`): golden FOLDS the reference to its
  VALUE — a `constant "UVM.1.2"`, `vpiSize:56`, carrying a
  `ref_typespec (adpcm_pkg::uvm_revision_string)` onto a `string_typespec` at
  `31:11` — where we keep a `ref_obj (…::uvm_revision)` bound through
  `vpiActual` to the constant at `31:33`. **R0: a package function returning a
  package-scope `const string` parameter folds to the parameter's VALUE, with
  the function's own return typespec on it.**
* **SimpleUVM ×2, 17 lines** (`head_pat_SimpleUVM.default.cmp`) — `LHS: <null>`,
  the SINGULAR `SafeCompare` mirror (`BaseClass.h:193-195`), so the object named
  is OURS and the field is one golden leaves UNSET: a `ref_typespec` hanging off
  `ref_obj (uvm_pkg::uvm_is_match::s)` at `403:24`, bound to a `string_typespec`
  at `23:50`. **R0: a reference to a STRING formal argument inside a package
  function carries NO `vpiTypespec` in golden.**

**RESIDUES this pass measured and deliberately did NOT move:**

* **R1 — a `::`-SCOPED STATIC CALL INSIDE A SHELL.** `g167_a_shell` `sh_static`
  (`Rcv167::st167(T167::type_name)`): golden emits § `staticScopedCall12`'s
  single bare `ref_obj` named `Rcv167::st167` and NO call at all; we emit a
  `func_call`. § `typeParamScopedCallRef59` already owns this object but is
  gated on an `InvalidExpression` with **NO child** (`ExprEmit.cpp:2126`), and a
  shell around a real call HAS one, so it abstains. This pass took the call's
  argument list from 2 to 1 (the written count) and left the KIND alone: it is
  arm A's residual head, 38 cmp lines in both views.
* **R2 — the `super.` call's PREFIX.** `g167_a_shell` `sh_this`: golden's
  `super.vm167(x)` carries a `constant "super"` as `vpiPrefix`; ours carries
  none. § 84/85's territory, unchanged and untouched.
* **R3 — the ELABORATED LISTING'S COPY COUNT.** Several grid cells have golden
  listing a generic-class body twice and us three times (arm A) or golden once
  and us twice (arm B, `v103_c5_slots`). It is a listing residue that predates
  this pass, it moves no cell's argument vector, and the judge reaches none of
  it (arm B and `v103_c5_slots` both go to 0 cmp lines with it present).
* **R4 — the § `namedTfArgsFormalSlots4` PLACEHOLDER IS SHARED IN GOLDEN.**
  Golden mints ONE loc-less `INT:0` and hangs it on several slots; we mint one
  per slot. No generated `Compare` reads `VpiParent`, so the judge cannot see it
  (RESUME §9), and arm B is CMP_EQUAL with the difference present.
* **R5 — TWO `$warning` CELLS IN `testflags/Earlgrey_0_1`** where GOLDEN lists
  the call TWICE and we once (`dm_csrs.sv:637:12`, `dm_sba.sv:168:18`). Found by
  the prediction sweep while populating the AWAY column; it is a LISTING-count
  residue on a SYSTEM call, a kind this law never touches, and Earlgrey_0_1 is
  byte-identical on the two binaries.
* **the MACRO-BUFFER SPAN on the head's own arguments.** Our `` `uvm_file ``
  constant is spanned `723:47, endln:51:5` where golden has `723:38-723:116` — a
  cross-macro-buffer `SourceLocation` of exactly the kind RESUME §9 warns about.
  `Compare` reads no span, and the head cleared with it still there.

## 9. HOW TO REPRODUCE

```bash
# the census tool
g++ -O2 -std=c++17 ct167cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct167cen

# one grid arm, both views, on two binaries, then score it and judge it
bash grid167.sh g167_a_shell.sv <pristine> <patched> <workdir> <ct167cen>
python3 score167.py <workdir>/cen.g.txt <workdir>/cen.a.txt <workdir>/cen.b.txt --fam CALL --list
bash armjudge167.sh <workdir>

# the a-priori prediction, from PRISTINE databases + the Surelog goldens only
CEN=<ct167cen> bash predsweep167.sh <pristine verify_golden workdir> pred.tsv

# the family census over the nine UVM row-modes
CEN=<ct167cen> SCORE=score167.py bash census167.sh <pris wd> <pat wd> <outdir> \
    SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg

# one mover, attributed ORDER-BLIND (mandatory for default/Scoreboard, the coin)
bash attrib167.sh <pris wd> <pat wd> default/SeqDriver-32af76aa

# the wide boundary gate
PRIS=<pristine> PATCHED=<patched> bash bound167.sh <copy of tools/probe> <outdir>

# the heads
bash rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
    BuildUVMPkg Earlgrey_0_1 Rggen
```
