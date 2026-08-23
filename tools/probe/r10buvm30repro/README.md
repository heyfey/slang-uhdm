# r10buvm30 — § `negLitPkgRetFoldNested30`

**Base commit `0726167`.  The head this pass was given: BuildUVMPkg, both
modes, 42 cmp lines (head-object decompile DEPTH), one head, byte-identical
logs — and Scoreboard/default's own 42-line head, the same statement in the
other UVM tree.  Both are CLEARED.**

```
BuildUVMPkg  default    42 -> 46     (head_pris_BuildUVMPkg.cmp -> head_pat_BuildUVMPkg.cmp)
BuildUVMPkg  testflags  42 -> 46     (log byte-identical to default, before and after)
Scoreboard   default    42 -> 565    (head_pris_default_Scoreboard.cmp -> head_pat_default_Scoreboard.cmp)
```

The pristine head, LHS = golden:

```
LHS  constant : @32186:23-32186:24 |vpiDecompile:-1 |vpiSize:64 |INT:-1 |vpiConstType:7
RHS  operation: @32186:23-32186:25 |vpiOpType:1
     \_constant: @32186:24-32186:25 |vpiDecompile:1 |vpiSize:64 |UINT:1 |vpiConstType:9
```

`uvm_pkg.sv:32186` is `uvm_transaction::is_active`:
`return (end_time == -1);`.  Scoreboard's is the SAME function in the uvm-1.2
tree (`uvm_transaction.svh`, line 529 of the single-unit compile).

---

## 1. THE DECODED MODEL

`FunctorCompilePackage` (Surelog `src/DesignCompile/CompilePackage.cpp:63/68`)
compiles every package **twice**: the elaborated `Package` with `Reduce::Yes`
(UhdmWriter puts it in `design.TopPackages`) and its `getUnElabPackage()` twin
with `Reduce::No` (`AllPackages`).  A MODULE, a `$unit` FileContent and a CLASS
BODY all hardcode `Reduce::No`.

Inside such a body, `compileFunction`/`compileTask` (`CompileStmt.cpp:2493` and
`:2538`) pass the inherited `reduce` to the subroutine's **top-level**
statements only — every compound statement (`paSeq_block`, if, for, while, do,
case, fork) recurses with a hardcoded `Reduce::No` — and inside `compileStmt`
only the `paRETURN` arm (`CompileStmt.cpp:838`) threads that `reduce` into
`compileExpression`.  That window is exactly § `pkgRetFoldHome86`'s
(r10uvm86) and § `pkgRetTopExpr8`'s (r10buvm8); this pass adds nothing to it.

**What this pass adds is DEPTH.**  `compileExpression` runs
`ExprEval::reduceExpr` on its result at the END OF EVERY CALL
(`CompileExpression.cpp:3648`), and an operation's operands, a call's
arguments and a select's index are each built by a RECURSIVE
`compileExpression` carrying the SAME `reduce`.  So the fold reaches a
`-<literal>` **at any depth of the returned expression**, not only one that IS
the whole returned expression — which is all § `negLitPkgRetFold86` modelled,
and why `return -1;` already folded while `return (end_time == -1);` did not.

`ExprEval::reduceExpr`'s `vpiMinusOp` arm (UHDM `templates/ExprEval.cpp:3307`)
mints `INT:<-v>`, `VpiDecompile` the same text, `VpiSize` = **the operand
constant's own size**, `VpiConstType` `vpiIntConst` (7) — and gives it NO
location, so `compileExpression`'s tail (`:3658`,
`populateCoreMembers(parent, parent, result)` with a null `child`) stamps it
with the **`paUnary_Minus` node's own span: the minus token alone**.

### § `negLitPkgRetFoldNested30`

> In the ELABORATED (`uhdmtopPackages`) copy of a package-homed subroutine —
> the package's own function/task, an OUT-OF-BODY class-method definition
> written at package scope, or any wildcard-import clone of either, in the
> view test § `pkgRetFoldHome86` already computes — a `return` statement that
> is a DIRECT statement of the body has **every unary MINUS over an integer
> literal inside its expression, at any depth, replaced by ONE constant**:
> span = the minus token alone, `vpiSize` = the literal's own size,
> `vpiValue`/`vpiDecompile` = `-<the literal's raw bit pattern read as an
> UNSIGNED decimal>`, `vpiConstType` = 7, and no typespec.  The constant takes
> the slot the operation held and that slot's ordinary parenting.
> TWO fences: a minus DIRECTLY under another minus is not folded (golden folds
> the pair into one POSITIVE constant), and nothing **anywhere inside a
> `func_call`'s argument subtree** is folded (where golden's unqualified call
> survives, it keeps every minus operation in its arguments).

---

## 2. WHAT WAS MEASURED, AND ON WHAT

Seven purpose-built goldens (`g30_*.sv`), run through Surelog, the pristine
binary and the patched binary by `arms30.sh`; `retcmp30.py` renders every
`uhdmtopPackages` return-expression subtree with the fields `Compare` reads
plus `vpiParent`/`vpiTypespec` presence.

| arm | what it separates | MOVED | golden-diff pris -> pat |
|---|---|---|---|
| `g30_a_shapes` | 26 written shapes in NON-return statements (assign, if, case, concat, index, ternary, call arg, …) | **0** | **0 -> 0** (already golden; the CONTROL) |
| `g30_b_context` | return at body top level vs inside `if`/`begin`; in-body method; package function; module function | 3 | 3 -> **0** |
| `g30_c_nested` | the minus at every DEPTH of a returned expression, in every literal spelling | 36 | 51 -> 17 |
| `g30_d_parent` | the folded constant's PARENT and TYPESPEC, each against a written-literal control in the same slot | 24 | 32 -> 10 |
| `g30_e_calls` | user/method/system call arguments | 24 | 26 -> 10 |
| `g30_f_callshapes` | `$clog2`/`$bits`/`$countones`/cast/`inside`/replication | 21 | 39 -> 32 |
| `g30_g_callfence` | the `func_call` fence: package fn, automatic fn, unqualified method, static method | **0** | 12 -> 12 |
| `g30_h_argdepth` | a minus NESTED inside a call argument (`meth(1 + -1)`) — the fence's DEPTH | 3 | 5 -> 4 |

Every arm's distance to golden is NON-INCREASING (0→0, 3→0, 51→17, 32→10,
26→10, 39→32, 12→12, 5→4): no arm cell moves away.
`g30_a_shapes` is the fence that matters most: with 26 minus-over-literal
sites written OUTSIDE a return, the patched binary moves NOTHING and stays
byte-identical to golden.

### The written shapes that fold (all measured on golden, `g30_c_nested`)

| written | folded constant |
|---|---|
| `-1` | `INT:-1` sz 64 ct 7, span = the `-` |
| `- 1` (space) | `INT:-1` sz 64 — span is still the `-` alone |
| `-(1)` | `INT:-1` sz 64 |
| `-'d1` (unsized based) | `INT:-1` **sz -1** |
| `-8'd3` | `INT:-3` sz 8 |
| `-4'sd8` | `INT:-8` sz 4, and the literal's `int_typespec` does NOT survive |
| `-32'hFFFFFFFF` | `INT:-4294967295` sz 32 |
| `-1.5` | `REAL:-1.500000` sz 64 ct 2 — golden folds it, we do NOT (residue R4) |
| `-PP` / `-LP` / `-E0` (parameter, localparam, enum const) | NOT a constant operand at all — golden keeps `ref_obj` under the operation, in both views |
| `~1`, `+1`, `1+2` | not this law (`+1` golden keeps as an operation; `~1` and `1+2` are general folds, residue R2) |

### The positions that fold

`(m == -1)`, `m == -1` without parentheses, `((m + (-1)) * 2)`,
`{-1, 1}`, `m ? -1 : 1`, `arr[-1]`, `this.meth(-1)`, `$sformatf("%0d", -1)`,
`$countones(-1)`, `(m == -1) ? -3 : -4` — every one of them, with the
constant taking that slot's ordinary parenting (parented under the
`==`/ternary operation, the `bit_select`, the `method_func_call` and the
`sys_func_call`; UNPARENTED under a concatenation and as the return root,
exactly as a written literal is there — `g30_d_parent` pairs each with its
`t_plainlit_*` control).

### The positions that DO NOT fold

* **inside `if`, `else`, an explicit `begin/end`** — `g30_b_context`'s
  `oob_in_if` / `oob_in_begin`: both package views keep the operation, and
  only the return at the body's own top level folds.  (In BuildUVMPkg's own
  golden this is not academic: 194 distinct unary-minus-over-a-constant
  operations survive unfolded, and exactly ONE constant is folded.)
* **anything inside a `func_call`'s ARGUMENT SUBTREE** — `g30_e_calls`
  `u_call`/`u_mix`, `g30_g_callfence` `n_meth`/`n_smeth`: where golden's
  unqualified call SURVIVES it keeps the whole minus operation, while
  `this.meth(-1)` (a `method_func_call`) and `$countones(-1)` fold theirs.
  The fence is on the SUBTREE, not the direct argument: `g30_h_argdepth`
  `d_nested` (`meth(1 + -1)`) shows golden keeping the minus one level down
  inside the argument too, so the gate walks the `vpiParent` chain up to the
  enclosing `return_stmt`/subroutine and refuses if it passes through a
  `func_call`.  FENCED.
* **directly under another minus** — `-(-1)`: reduceExpr folds the inner
  constant and then the outer minus over it, so golden holds ONE POSITIVE
  constant at the outer minus token.  FENCED (residue R1).

---

## 3. THE CHANGE

* `include/UhdmExporter.h` — `pkgRetFoldExpr30`, the window flag, with the
  mechanism written out.
* `src/EmitHelpers.h` — `isNegLitFoldShape30()`, the written shape, so a
  caller that treats DIRECT LITERAL operands specially sees the fold.
* `src/StmtEmit.cpp` (`StatementKind::Return`) — set the flag around the
  return expression's emission, under the SAME `pkgRetFoldHome86` +
  direct-statement-of-the-body test § 86 uses.
* `src/ExprEmit.cpp` (`ExpressionKind::UnaryOp`) — the fold, plus the
  concatenation arm's literal-slot test.

No other production file is touched.

---

## 4. GATES AND REACH

All green; NO row converted, nothing promoted, `results/*.csv` untouched.

* goldens 23/0, `/bin/false` 0/23; uhdm2rtlil 679/50/2 in both modes;
  surelog 937 CMP_EQUAL / 19 CMP_NOTEQUAL — every histogram identical to this
  pass's own pristine sweep, `ct8rows` PASS against the committed baselines
  AND against the pass's own pristine CSVs.
* **byteverify MOVERS 9 / 956** (surelog) and **0 / 1358** (uhdm2rtlil).  The
  nine were PREDICTED BY NAME from the pristine databases before the sweep ran
  (`PREDICT.r10buvm30.txt`), and the order-blind attribution shows 13 sorted-
  dump lines per database — 39 where the site has three import-clone copies —
  every one of them the ONE folded site (`MOVERS.r10buvm30.txt`,
  `ATTR.r10buvm30.txt`).
* **wide boundary gate**: 3424 arms x 2 binaries x DEF/ELAB, PROCESSED
  asserted, MOVED 14 — twelve are this pass's own arms and two are
  `r10uvm86repro/g86_a2_ctx.sv`, whose two sites both move TO GOLDEN
  (`BOUNDARY.r10buvm30.txt`).
* **REACH** (`CENSUS.r10buvm30.txt`): golden folds a negation in a package
  section in 21 surelog tests; sixteen are SLANG_REJECT on both sides, and the
  five that remain are exactly the five whose pristine databases hold any
  package-section minus operation.  Over those ten databases golden holds 34
  such constants, our pristine held 15, our patched holds **32 — golden's
  whole set except the two in Scoreboard/testflags, where we produce no
  database at all — with ZERO minted that golden does not have.**  The whole
  uhdm2rtlil corpus (1458 databases) holds no package-section row of any kind
  on either side.

---

## 5. RESIDUES

* **R1 — `-(-<literal>)`.**  Golden folds the pair into one POSITIVE constant
  at the OUTER minus token; we keep both operations.  Fenced out here so the
  cell does not move without reaching golden.  Zero corpus witnesses.
* **R2 — the enclosing expression golden EVALUATES WHOLE.**  `$signed(-1)`,
  `$unsigned(-1)`, `$clog2(-1)`, `$bits(-1)`, `int'(-1)`, `{2{-1}}`, `1 + 2`,
  `~1`, and a call to a package/automatic function (`pkgf(-1)`): golden holds
  ONE constant where we hold the whole call/cast/operation.  Surelog folded
  the operand there TOO and then folded the enclosing expression on top; this
  pass models only the first half, so our object differs from golden in
  `VpiType` at the ENCLOSING object and the operand below it is never reached
  by `Compare` either way.  This is § 86's own R3 family, one level larger.
* **R3 — the folded constant's `vpiParent` at a CALL argument.**  Golden
  parents it to the `method_func_call` / `sys_func_call`; our literal policy
  parents a constant only under an `operation`, `bit_select`, `case_item` or
  `immediate_assert`, so ours is unparented there — exactly as our WRITTEN
  literals already are in the same slot (`g30_f_callshapes` `k_sform`).
  DUMP-ONLY: no generated `Compare` reads `VpiParent`.  The same residue is
  already recorded at `mockupThisConst84` (ExprEmit.cpp).
* **R4 — a REAL operand.**  `-1.5` folds in golden to `REAL:-1.500000` sz 64
  ct 2 by `reduceExpr`'s second branch.  Left as measured, not modelled:
  zero corpus witnesses and a different formatting rule (this is § 86's R2).
