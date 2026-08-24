# r10v118 — ADVERSARIAL VERIFICATION of r10uvm118 (§ implicitStrConcatNoCast118)

**VERDICT: ACCEPT WITH FIX.** Ship `/tmp/r10uvm118.verified.patch`.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge. **BASE
`9ac2763`.** `results/*.csv` was READ ONLY and is untouched; **no row was
converted**; `GOLDEN_DEFER` stayed unset.

Every headline number in the implementer's report was reproduced from scratch —
own worktrees, own builds, own frozen binaries, own controls. `GATES.r10v118.txt`
has all of them. One defect was found on legal SystemVerilog and fixed here.

---

## 1. What reproduced, bit for bit

* **Both binary md5s.** The pristine rebuild of `9ac2763` gives
  `b815e9f51e1d2009ab5307f874dde17a`, the patched build gives
  `de4c7d9344b65013d2cb8b68aa913ba8` — the implementer's exact claims. The patch
  applies `git apply -3` clean on a fresh `9ac2763` and regenerates to a `git
  diff` identical modulo `index` lines. Surface is `src/ExprEmit.cpp` plus the
  pass's own repro dir; 0 `results/*.csv` edits; 0 fenced-name mentions.
* **The head decode.** `expr::Compare`
  (`UHDM/build/generated/src/expr.cpp`) reaches `SafeCompare(Typespec())`
  before `operation::Compare` looks at `VpiOpType` — read out of the generated
  sources here, not carried forward. So a **surplus `vpiCastOp` operation**
  reports as a bare `ref_typespec` mismatch with the `LHS: <null>` spelling of
  the singular `SafeCompare` overload. Confirmed.
* **The heads.** SimpleUVM ×2 and Scoreboard/default **17 → 76** (one head
  each, the count is the new head object's decompile depth); SeqDriver ×2 /
  MiniAmiq ×2 / BuildUVMPkg ×2 stay 56 on the same object; Earlgrey_0_1 32/36
  and Rggen/default 0 unchanged. All six committed `HEAD_{BEFORE,AFTER}*.cmp`
  logs reproduce byte-for-byte modulo arena `id:` numbers.
* **The census.** Rebuilt from the verifier's own databases: golden = ours in
  all nine UVM row-modes, **OURS-ONLY 0 / GOLDEN-ONLY 0**, `BOTH-SAME`
  29/57/40/55/41 and `MOVED-WRONG` 8/14/8/13/7 unchanged
  (`CENSUS_FIXED.r10v118.txt`). Cast-operation totals land exactly on golden's
  37/71/48/68/48.
* **The mover set, predicted independently.** `vpred.sh` uses a **broader**
  fingerprint than the implementer's (no parent constraint), run on the 956
  **pristine** databases only. It names 9 databases / 87 cells — and the measured
  `byteverify` mover set is exactly those nine, by name, with **0/1358** on
  uhdm2rtlil. Order-blind attribution: **ADDED = 0 in all nine**.
* **Every gate.** Goldens 23/0 on all three binaries and 0/23 on `/bin/false`;
  uhdm2rtlil 679/50/2 both modes with 0 differing rows; surelog 0 differing rows
  over 1588 with identical 5-way/9-way histograms; every `cmds.txt` audited **by
  binary path** (1523/1573 and 1458/1462, **0 naming the main-tree binary**);
  canaries 52+8, both ctcan2 suites PASS, canaudit audited=29 UNCOVERED=0
  FENCE-BREACH=0; protected databases byte-identical with `SVSwitch
  4842211c4030` and `YosysVerx 6ccda350c24a` on their pins.

## 2. The law is sound — and it is the MECHANISM, not the home

Verified independently at the slang source. `ConcatenationExpression::fromSyntax`
(`source/ast/expressions/OperatorExpressions.cpp:1967-1985`) wraps a
non-string operand of a string-bearing concatenation in
`ConversionExpression::makeImplicit(..., getStringType(),
ConversionKind::Explicit, ...)`, and `makeImplicit`
(`ConversionExpression.cpp:442`) never assigns `result->syntax`. On **legal**
SystemVerilog that wrap is reached only when `Expression::isImplicitString()`
(`source/ast/Expression.cpp:669-711`) holds — otherwise slang errors
`ConcatWithStringInt` — which bounds the population to exactly:
StringLiteral, UnaryOp, BinaryOp, ConditionalOp, Concatenation, Replication,
ValueRange, MinTypMax, and an implicit-string parameter NamedValue.

`v118_a1_homes.sv` measures **13 stamp homes × 9 operand kinds**, with
deliberately unpatterned names/numbers/case, including four homes and four
operand kinds the implementer's arms do not cover (static method, constructor,
interface, program; unary op, binary op, concat-inside-ternary,
implicit-string parameter). **Golden emits zero `vpiCastOp` in every one of the
thirteen homes, macro-expanded or not**, and the patched binary matches golden
on 163 of 166 operations with `OURS-ONLY 0`. The 3 residual golden-only cells
are an interface `always_comb` that is golden-only in **pristine** too.

`v118_a2_contexts.sv` adds the positions: case expression, case item, foreach
body, call argument, default argument, return, output-port driver,
timing-controlled statement, delayed statement, assertion action block, plus
param-init and plain integral concat as never-stamp controls. All correct, and a
written `Sobriquet'(x)` cast through a **package typedef** is kept on golden's
exact span.

`v118_a5_checker.sv` **refutes** the other slang site that mints
`ConversionKind::Explicit` (`MiscExpressions.cpp:1349`, a checker formal): zero
cast operations on every side, patched cmp lines identical to pristine.

## 3. THE DEFECT — the fence names one syntax kind; a written `'` has two

**§ implicitStrConcatNoCast118 says a cast operation exists in golden iff a `'`
was written. The patch's fence spells that as
`effCastSyn->kind != syntax::SyntaxKind::CastExpression` — but slang has a
SECOND syntax kind for a written `'`.**

`ConversionExpression::fromSyntax(const SignedCastExpressionSyntax&)`
(`ConversionExpression.cpp:409-440`) also produces `ConversionKind::Explicit`,
and for the **const cast** (`syntax.signing.kind == TokenKind::ConstKeyword`) it
sets `result->type = operand.type`. So `const'(<string expr>)` is an Explicit
conversion whose `type->isString()` is TRUE and whose `expr.syntax->kind` is
`SignedCastExpression`, **not** `CastExpression`. `signed'` / `unsigned'` cannot
reach it (they force an integral type), so the hole is exactly `const'` on a
string-typed operand.

Measured on purpose-built golden (`v118_a4_constcast.sv`, one statement
`Placard = {Placard, const'(Placard), "!"};`):

| | the concat | the cast operation |
|---|---|---|
| golden | `OPT=33 NOPS=3 SPAN=8:15-8:46` | **`OPT=67 NOPS=1 SPAN=8:25-8:40`** |
| pristine | same | `OPT=67 NOPS=0 SPAN=8:25-8:40` |
| **patched** | same | **nothing — the operation is GONE** |
| **fixed** | same | `OPT=67 NOPS=0 SPAN=8:25-8:40` |

**Surelog does mint the operation.** It additionally reports
`ERR:UH0705 Unsupported data type "…Const_type…"` for the cast's *typespec*, and
emits the `vpiCastOp` with no typespec — so golden has the object and the
unfenced law removed it. `v118_a3_written_fences.sv` shows the same thing twice
over, in a package function and in a module `initial`: cast counts golden 22 /
pristine 19 / **patched 19 but two spans WRONG** (`11:21-11:34` and
`26:23-26:37` missing), and the official `uhdm-cmp` line counts go
6152/6454 (pristine) → 6122/6414 (patched) → **6152/6454 (fixed)**.

This contradicts the pass's own one-sidedness claim (`GOLDEN-ONLY = 0`,
`ADDED = 0`) rather than merely grazing it, so it is fixed here.

### The fix (`src/ExprEmit.cpp`, +21/−4, all but two lines comment)

The `SignedCastExpression` exclusion is attached to **this law's disjunct only**,
never to the shared fence, so the pre-existing string-literal rule keeps the
answer it has always given for `const'("abc")`:

```c++
const bool writtenSignCast118 =
    effCastSyn &&
    effCastSyn->kind == syntax::SyntaxKind::SignedCastExpression;
if (expr.type && expr.type->isString() &&
    (stripImplicitConv(conv.operand()).kind == ExpressionKind::StringLiteral ||
     (conv.conversionKind == ConversionKind::Explicit &&
      !writtenSignCast118)) &&
    (!effCastSyn ||
     effCastSyn->kind != syntax::SyntaxKind::CastExpression))
    return emitExpr(stripImplicitConv(conv.operand()), parent, prefix, netMap);
```

It restores **exactly pristine's behaviour** on the one spelling the fence
missed, and can therefore only ever un-remove. Measured: it is
**corpus-invisible** (`const'` occurs in no `.sv`/`.v` source of either corpus —
the only 13 grep hits are `.log` and `.py` files) and **arm-invisible** — a
per-file boundary of **fixed vs patched** over all 3662 probe sources × 2 views
reports `PROCESSED=3662 = LISTED, DIFFERING=0`, and `byteverify` fixed-vs-patched
is 0/956 and 0/1358. The whole gate battery was re-run on the fixed binary and
is green (`GATES.r10v118.txt` §§2–7).

## 4. A boundary arm the pass did not run, and what it found

The implementer's boundary is per-FILE only. A **per-DIRECTORY** arm (every
`.sv`/`.v` in one directory compiled together, 1538 directories) reports **10
directories differing byte-wise** — the pass's own plus `r10uvm117repro`,
`r10uvm75repro`, `r10uvm76repro`, `r10v109repro`, `r10v117repro`.

**All nine non-own cells are ORDER-BLIND IDENTICAL** (added=0 removed=0): pure
`vpiTaskFunc` list order flips, identical names and spans. Proved to be
per-invocation nondeterminism and not the patch — the **same pristine binary**
run four times on `r10uvm75repro` produces **four distinct dumps**, all
order-blind identical to each other. Read order-blind, only the pass's own
directory moves.

**The lesson for the next pass: a per-directory boundary's raw byte compare is
unusable on a multi-package directory. It must be read order-blind, or it
manufactures five phantom movers.** `vwide.sh` runs both arms; score the
per-directory one with sorted dumps.

The gate was proved able to see: a known mover placed **three directories deep**
is found (2 of 2 cells) while earl75's `g1_gsproc75.sv` in that same deep
directory and earl72's two arms in a sibling directory stay identical
(`BOUNDARY_POS.*`).

## 5. Residues, ranked

* **R0 — the next head, unchanged from the implementer's, and confirmed.**
  `uvm_sequence_library.svh:778`'s `seq_or_item.randomize() with {…}`: our
  `hier_path` `VpiName` is `seq_or_item.randomize` where golden's is
  `seq_or_item`; golden's `method_func_call(randomize)` carries
  `vpiWith → constraint` and is span-less where ours has neither and runs to
  `778:9`. `hier_path::Compare` reads `VpiName` before `Path_elems`, so the name
  text is reached first. 76 cmp lines, one head, the same object in all three
  cleared row-modes.
* **R1 — `const'(<string>)`'s operand.** With the fix we emit the `vpiCastOp`
  golden has, but with **`NOPS=0`** where golden has 1: slang models `const'` as
  a type-transparent conversion (`isConstCast`) and our operand emission yields
  `expression kind: Invalid`. Corpus-invisible; purpose-built golden already
  written (`v118_a4_constcast.sv`). Two cells on `v118_a3_written_fences.sv`.
* **R2 — the implementer's R1, confirmed on the verifier's own arm.** A written
  `string'(v)`'s cast target is `string_typespec` in golden and
  `integer_typespec` in ours (1 `MOVED-WRONG` cell on `v118_a2_contexts.sv`
  as well, under the package-typedef spelling).
* **R3 — the cast-typespec NAME population**, the census's `MOVED-WRONG` column
  (8/14/8/13/7 per row-mode, identical before and after): golden
  `uvm_reg_data_t` vs our `uvm_pkg::uvm_reg_data_t`. MEMORY's
  "naming is context-dependent" dead-end applies — it needs its own split.
* **R4 — the interface `always_comb` gap.** `v118_a1_homes.sv:57` — golden emits
  an `assignment` + concat + `===` operation for an interface `always_comb`
  string concatenation and we emit nothing at all. Pre-existing (golden-only in
  pristine too), 3 cells, outside this law.

## 6. Instruments

`varm.sh` (one arm, Surelog golden + three frozen binaries, both views, rc per
child, cast counts and official-cmp line/head counts), `vwide.sh` (per-file AND
per-directory boundary, fd-3 list, `</dev/null`, rc per cell, relative-path
scratch, PROCESSED asserted), `vpred.sh` (parent-unconstrained a-priori mover
predictor over pristine databases — it named this mover set exactly),
`vjoin.py` (multiset join with a configurable key that prints the OURS-EXTRA and
GOLD-EXTRA rows, not just the totals), and the five arms.
