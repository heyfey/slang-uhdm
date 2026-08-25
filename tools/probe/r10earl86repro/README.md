# r10earl86 — § `elabParamOpSubtreeFold86` + § `srlgReduceOpFold86` + § `valueRangeImplicitSigning86`

**THE `Earlgrey_0_1` DEFAULT HEAD CLEARED** (`flash_erase_ctrl.sv:42`
`BankAddrMask`, the shift amount `(PagesBitWidth + WordsBitWidth)`), with
`Earlgrey_0_1` **testflags** and every other named row **byte-identical**.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `aef5007`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED** (`Earlgrey_0_1` stays `CMP_NOTEQUAL` in
both modes; its default head is cleared, the design has more — see
`PREDICT_R0.txt`). slang was **NOT** patched. Production surface:
**`src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `include/UhdmExporter.h` only**, and
the diff is **purely additive** (733 inserted lines, 0 deleted) except for the
one-token widening of earl85's typespec-presence guard.

Kill switch: `R10E86_OFF=1` restores the pre-pass fold path exactly. It is the
neutral binary the Earlgrey A/B attribution scores against (Earlgrey is never
whole-dump diffed — its dump is >1 GB).

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_Earlgrey_default.cmp` is the verbatim pristine log from this
pass's own build of `aef5007`; it is **byte-identical** to the master's
`/tmp/earlgrey_head_default_aef5007.cmp`, so this pass starts on exactly the
object r10earl85 named as R0.

```systemverilog
// hw/ip/flash_ctrl/rtl/flash_erase_ctrl.sv:42, in
// top_earlgrey.u_flash_ctrl.u_flash_erase_ctrl
localparam logic[AddrW-1:0] BankAddrMask =
    ~(('h1 << (PagesBitWidth + WordsBitWidth)) - 1'b1);
```

| | LHS (golden) | RHS (ours, pristine) |
|---|---|---|
| the shift's AMOUNT | `constant` 42:57-42:70 | `operation` 42:57-42:86 |
| | `vpiDecompile:16` `vpiSize:32` | `vpiOpType:24` (`vpiAddOp`) |
| | `UINT:16` `vpiConstType:9` | two `constant UINT:8 vpiSize:32 ct 9` |
| its `vpiTypespec` | **absent** | on EACH operand: `ref_typespec -> int_typespec` |

`PagesBitWidth` and `WordsBitWidth` are `localparam int … = $clog2(…)`, both 8;
42:57-42:70 is the span of **`PagesBitWidth` alone** — the LEFT operand — and
42:57-42:86 is the span of the whole `PagesBitWidth + WordsBitWidth`.

**Which field.** `expr::Compare`
(`~/git-repos/UHDM/build/generated/src/expr.cpp:83`) runs
`BaseClass::Compare` first, and that compares **`VpiType`** — `vpiConstant`
against `vpiOperation`. So the head is the KIND of that operand, and the
`vpiTypespec` on the two leaves is the SECOND disagreement behind it.

---

## 2. Question 1 — DECODING SURELOG: how the bail leaves the tree

§ `srlgUnsizedBasedShiftBail85` (r10earl85) already models WHY the tree
survives: `'h1` is a Surelog `constant` with `VpiSize() == -1`, and
`ExprEval::reduceExpr`'s shift arms (`UHDM/templates/ExprEval.cpp:3050` and
`:3137`) open with

```c++
expr *arg0 = reduceExpr(operands[0], invalidValue, inst, pexpr, muteError);
if (arg0 && arg0->UhdmType() == uhdmconstant)
    if (((constant *)arg0)->VpiSize() == -1) invalidValue = true;
```

so `CompileExpression.cpp:3647-3655`

```c++
if (any *tmp = reduceExpr(result, invalidValue, ...)) { if (!invalidValue) result = tmp; }
```

keeps the ORIGINAL operation.

**What earl85 did not model is that this tail runs at EVERY RECURSION LEVEL.**
`compileExpression`'s `paExpression` / `paConstant_expression` arm
(`CompileExpression.cpp:2276-2407`) compiles each operand with its own
`compileExpression` call, and that call reduces its own result before
returning it. So by the time the bailing shift sees its amount,
`(PagesBitWidth + WordsBitWidth)` has ALREADY been folded — nothing in THAT
subtree is size(-1); the bail is at the shift ABOVE it.

### The two producers, and the typespec-presence split

| | who folds it | typespec | span |
|---|---|---|---|
| a BARE IDENTIFIER operand | `compileExpression`'s identifier arm (`:2852` / `:3004-3018`) | mints a bare **signed `int_typespec`** exactly when `CompileHelper::valueRange` captured signedness | the identifier's own |
| an OPERAND SUBTREE | `ExprEval::reduceExpr`'s per-operator arms | **NONE, ever** — the arms set VpiValue / VpiDecompile / VpiSize / VpiConstType and nothing else | see below |

That is the whole answer to "why does the folded sub-expression carry no
typespec where earl85's bare leaf does": they are **two different producers**.

### Where the folded constant's span comes from

A `reduceExpr` constant is minted with no location, so `compileExpression`'s
tail stamps it:

```c++
if (result && (result->VpiLineNo() == 0)) {
    if (child) fC->populateCoreMembers(child, child, result);
    else       fC->populateCoreMembers(parent, parent, result);
}
```

with `child = fC->Child(parent)` (`CompileExpression.cpp:1599`) — the **FIRST
CHILD** of the expression node. Measured on golden, one localparam per row,
every row read as the amount of a bailing `'h1 << …`:

| subexpression | golden's fold span | which node that is |
|---|---|---|
| `(P + W)` | span of `P` | the left operand |
| `(P + W + 1)` | span of `P + W` | the left operand SUBTREE |
| `((P + W) * 1)` | span of `(P + W)` | the left operand **with its parentheses** |
| `(((P + W) * 1) - 2)` | span of `((P + W) * 1)` | ditto, one level up |
| `($clog2(P) + W)` | span of `$clog2(P)` | ditto |
| `(-P)` `(~LW)` `(!Z)` `(&LW)` | span of `-` `~` `!` `&` | the **operator token** (a unary node's first child) |
| `(~&LW)` `(~\|LW)` `(~^LW)` | span of `~&` `~\|` `~^` | the two-character operator token |

`g1_ops86.sv` and `g2_leaves86.sv` are those measurements; every cell is in
`ARMS.r10earl86.txt`.

### The ternary is NOT a reduceExpr arm

`reduceExpr`'s `vpiConditionOp` arm (`ExprEval.cpp:3763`) would mint
`INT:` at size 64. Golden does **not** do that: measured, `((P > W) ? P : W)`
folds to `UINT:8 vpiSize:32 ct 9 + int_typespec` at the span of `P` — i.e. to
the TAKEN ARM's own compiled object. The producer is
`CompileExpression.cpp:2289-2306`, which short-circuits the whole ternary when
`reduce == Reduce::Yes` and the compiled CONDITION is a `uhdmconstant`:

```c++
if ((reduce == Reduce::Yes) && (opL->UhdmType() == uhdmconstant)) {
    int64_t cond = eval.get_value(invalidValue, (expr *)opL);
    if (cond) { result = compileExpression(<true arm>, ...); break; }
    else      { result = compileExpression(<false arm>, ...); break; }
}
```

The operation node is never built, so the result keeps the arm's span AND its
typespec. `g1_ops86.sv` rows `t_cnd` / `t_cn2` (condition true / false) are the
two halves.

---

## 3. Question 2 — THE CENSUS, both corpora

`pacen86.cpp` reads a `.uhdm` **DIRECTLY** (never a whole-dump diff — Earlgrey's
dump is >1 GB; earl61's direct-reader pattern) and enumerates **EVERY**
`param_assign`. It extends earl85's `pacen85` with the field that pass could
not see: **`TREE=`**, a PREORDER linearization of the WHOLE Rhs — one group per
node carrying `kind : opType : VpiSize : VpiValue : VpiConstType :
VpiDecompile : VpiName : typespecKind : typespecSigned`. earl85's payload
stopped at the FIRST operand of the top operation, which is exactly why its
own grid reported `STILL 0` on a row whose leaf typespec was missing (§ 6
below). **No span is in the scored payload** (earl60/earl69: a span-carrying
payload hid a real Instance flip); `--spans` adds them as a separate diagnostic
column that `score86.py` strips before scoring.

### The corpus census, PRISTINE (`aef5007`) vs golden

| | uhdm2rtlil (1358 DBs read, 504 hold a `param_assign`) | surelog (956 DBs read, 461 hold one) |
|---|---|---|
| cells joined BOTH-SAME | 68 714 | 45 441 |
| **FAMILY-SUBFOLD** — golden folded an operand subtree we kept | **0** | **1** |
| FAMILY-OPKEPT (earl85's R3) | 0 | 2 |
| FAMILY-OVSTAMP (earl85's R1) | 0 | 16 |
| OTHER-DIFF | 6 | 1824 |
| **GATE-REACHABLE** — ours: an `operation` Rhs carrying a size(-1) constant | **2** (both `VIEW=DEF`) | **117** (115 DEF, **2 ELAB**) |

The law is ELAB-only, so **the whole reachable population is TWO rows**, both
`Earlgrey_0_1` **default**: `flash_erase_ctrl.sv:41 PageAddrMask` (whose shift
amount is a BARE identifier earl85 already folded — no operand subtree, must
not move) and `:42 BankAddrMask` — **the head, and the census's ONE
FAMILY-SUBFOLD cell.** `Earlgrey_0_1` testflags holds NO gate-reachable ELAB
row: its `BankAddrMask` Rhs is already `INT:65535` size 64 on both sides
(`UHDM::UhdmAdjuster` has reduced it — that test's command line carries
`-elabuhdm`). Full listings: `CENSUS.before.*` / `CENSUS.after.*`.

---

## 4. The laws

### § `srlgReduceOpFold86` (`src/ExprEmit.cpp`)

`UHDM::ExprEval::reduceExpr`'s per-operator arms, transcribed — earl73's
encoder tables, read off the arms themselves and confirmed cell by cell on
`g1_ops86.sv`:

| operator | value tag | `vpiSize` | `vpiConstType` |
|---|---|---|---|
| `<<` `>>` (arith and logical) | `UINT` | 64 | `vpiUIntConst` |
| — and they **BAIL** when `operands[0]` is size(-1) — rule (1) |
| `+` (binary) | `UINT` unless EITHER reduced operand is `vpiIntConst`/`vpiDecConst`/`vpiStringConst`/`vpiRealConst`, then `INT` | **`max(sz0, sz1)`** | 9 / 7 |
| `-` `*` `%` `**` `/` | `INT` | 64 | `vpiIntConst` |
| `-` (unary) | `INT` | the OPERAND's `VpiSize` | `vpiIntConst` |
| `&` `\|` `&&` `\|\|` | `UINT` | 64 | `vpiUIntConst` |
| `!` | `UINT` | 64 | `vpiUIntConst` |
| `~` (unary) | `UINT`, masked to the operand's **typespec** size when it has one, else its `VpiSize` | that same size | `vpiUIntConst` |
| `&` `~&` `\|` `~\|` `^` `~^` (unary reductions) | `UINT` | 64 | `vpiUIntConst` |
| `<` `<=` `>` `>=` `==` `!=` | `BIN` | 1 | `vpiBinaryConst` |
| `^` `~^` (**binary**) | **no arm in `reduceExpr` at all** — golden keeps the operation |

The reduction loops' BOUNDS are transcribed as they stand, bugs included:
`vpiUnaryAndOp` walks the operand's own `VpiSize`, `vpiUnaryNandOp` and
`vpiUnaryOrOp` stop at 32, the other three at 64. `get_value` / `get_uvalue`
(`ExprEval.cpp:1946` / `:2057`) are transcribed too, including `ltrim`, the
`VpiSize() > 64` refusals on BIN/HEX/OCT, `parseIntLenient` for `UINT:` in the
signed reader and strict `parseUint64` in the unsigned one (so `get_uvalue` on
`INT:-3` FAILS, as it does there), and the X/Z `parseBinary` failure that is
rule (2) of § `srlgUnbasedReduceBail`.

### § `elabParamOpSubtreeFold86` (`src/ExprEmit.cpp`, hooked in `src/ParamEmit.cpp`)

Walks the emitted operation tree and the slang expression that produced it in
parallel, folds every maximal operand subtree that does not itself bail, and
stamps the constant with the span `populateCoreMembers(child, child, result)`
gives it: the LEFT operand's own syntax node **including its parentheses** for
a binary operator, the OPERATOR TOKEN for a unary one. A parenthesised operand
carries the paren node as its slang `syntax`, so the walk unwraps parens on the
NODE and never on `.left`. It runs immediately after
§ `elabParamOpLeafValueFold85`, which must go first: these arms read the
operands' `VpiSize`/`VpiConstType`, and the leaf fold is what puts them there.

**Refused, each with the measurement that says why:**

* the **ROOT** of the bail-kept tree (depth 0) — Surelog's abstention IS on
  that node, so refusing it is a fence, not a model gap;
* an operand that is not a `constant` after the recursion (Surelog's
  `constantOperands` guard) — this is what leaves `s_clg` (`$clog2(P) + W`)
  alone: our ELAB copy holds a `sys_func_call` there where golden's
  `compileClog2` already returned a constant (R4);
* real / string / time / scalar operands and any value string the transcribed
  readers cannot parse — `g4_neg86.sv` `n_unx` (`'x + P`), golden and ours both
  unfolded;
* `/` or `%` by zero — `g4_neg86.sv` `n_dv0` / `n_md0`, golden keeps the
  operation;
* a comparison with a size(-1) operand: `reduceCompOp` RESIZES it in place
  (`ExprEval.cpp:1657-1661`) and that mutation is not modelled;
* **THE CONCAT FENCE** — anything under a `vpiConcatOp` / `vpiMultiConcatOp` /
  `vpiAssignmentPatternOp` carrier. Measured, not assumed:
  `CompileHelper::reorderAssignmentPattern` (`CompileExpression.cpp:5887-5960`)
  REVERSES a concat's operands against a descending target range, which this
  pass does not model — `g3_anc86.sv` arm `a_cat`
  (`{('h1 << W), (P + W)}` into a `logic[16:0]`) has golden's operands in the
  OPPOSITE order from ours, so folding inside it would move a cell that is
  wrong for a DIFFERENT reason. `a_cat` and `a_rep` stay byte-identical to
  pristine instead.

### § `valueRangeImplicitSigning86` (`src/ExprEmit.cpp`) — ONE TOKEN WIDER

`CompileHelper::valueRange` (`Surelog/src/DesignCompile/CompileHelper.cpp:5380-5398`)
reads `VpiSigned` off the **COMPILED TYPESPEC**, and its switch has exactly
three arms — `logic_typespec`, `bit_typespec`, `int_typespec`. earl85
transcribed that as a question about slang's DECLARED TYPE SYNTAX and refused
every `ImplicitType`. That is right for an untyped `localparam X = 4` (Surelog
compiles it to an **unsigned** `int_typespec`; golden's leaf carries no
typespec) and **wrong** for `localparam signed [7:0] X = 11`, whose type syntax
is also implicit but whose compiled typespec is an `int_typespec` **with
`VpiSigned`** — in golden and in our own database alike (`uhdm-dump`:
`int_typespec 19:14 |vpiSigned:1` under `parameter work@leaf85.L_SLOG` on both
sides). The distinguisher is the one token that decides that `VpiSigned`: an
explicit `signed` keyword. Measured on the eight-row appendix of
`g2_leaves86.sv`, reading each leaf through a `^` carrier golden never folds:

| declaration | golden leaf typespec | pristine | patched |
|---|---|---|---|
| `signed [7:0]` | `int_typespec` signed | *(none)* | **`int_typespec` signed** |
| `signed` | `int_typespec` signed | *(none)* | **`int_typespec` signed** |
| `unsigned [7:0]` | *(none)* | *(none)* | *(none)* |
| untyped | *(none)* | *(none)* | *(none)* |
| `logic [7:0]` | *(none)* | *(none)* | *(none)* |
| `int` | `int_typespec` signed | same | same |
| `logic signed [7:0]` | `int_typespec` signed | same | same |
| `bit signed [7:0]` | `int_typespec` signed | same | same |

Two cells WRONG->RIGHT, none moved wrong. Without it the `~` arm above would
have folded `~SG` at the wrong width (`ExprEval`'s `vpiBitNegOp` sizes through
the operand's typespec), which is how the gap was found: the FIRST patched run
scored `WRONG->OTHER 1` on `g2_leaves86.sv` row `v_ngSG`, and the fix removed
it rather than explaining it away.

---

## 5. The grids

Every arm is built by `arm86.sh` with **Surelog** (golden) and with the TWO
FROZEN binaries; every child gets `</dev/null` and its rc is recorded.
`score86.py` joins the three `pacen86` row files as a MULTISET on the key and
buckets every cell, scoring TWO payloads: JUDGE (the fields a generated
`Compare` reads, spans stripped) and FULL (the same rows WITH spans, diagnosis
only). **Both payloads give the same bucket counts on every arm**, which is the
statement that the spans landed where golden puts them.

| arm | what it varies | JUDGE score |
|---|---|---|
| `g1_ops86.sv` | 11 binary + 6 unary + 4 three-operand + 3 nesting-depth + 1 sys-call subexpressions, all as the amount of a bailing `'h1 << …`; operators `+ - * / % << >> & \| ^ ** && \|\| < ==`, unary `- ! ~ & \| ^`, ternary both ways | SAME 44 **W2R 27** R2W 0 W2O 0 STILL 1 |
| `g2_leaves86.sv` | 14 leaf kinds under `~`, 5 under unary `-`, 3 two-character reductions, 16 `+` rows crossing every declared type and literal form, 3 parenthesised left operands, + the 16-row implicit-signing appendix | SAME 109 **W2R 51** R2W 0 W2O 0 STILL 2 |
| `g3_anc86.sv` | 9 BAILING-ANCESTOR shapes (shift amount / bare shift / sibling of the shift / under `~` only / concat / replication / ternary taken and untaken / three levels deep) x homes (module body, gen-if, gen-for) x **3 INSTANCES** x a PACKAGE home | SAME 37 **W2R 18** R2W 0 W2O 0 STILL 20 |
| `g4_neg86.sv` | the negative controls: no bail at all, an operator with no `reduceExpr` arm (`^`, `~^`), a subtree that itself bails, a non-parameter operand, `/0` and `%0`, concat and replication subtrees, `'1` and `'x` operands | SAME 30 **W2R 2** R2W 0 W2O 0 STILL 4 |
| `g5_leaf85copy86.sv` | r10earl85's OWN leaf grid, re-scored (the regression arm for § `valueRangeImplicitSigning86`) | SAME 61 **W2R 2** R2W 0 W2O 0 STILL 1 |

**RIGHT->WRONG 0 and WRONG->OTHER 0 in every arm; 100 cells WRONG->RIGHT.**
`DEF`-view rows are byte-identical to golden in every arm before and after (37,
58, and the rest) — the law is ELAB-only and the DEF listing keeps its
references, as golden's does.

`g4_neg86.sv`'s two WRONG->RIGHT rows are the file's own surprises, kept and
relabelled rather than hidden: `n_sig` (`$bits(sig) + W`) and `n_unb`
(`'1 + P`) are shapes golden DOES fold — `$bits` is already a constant in our
ELAB copy, and `'1` is only size(-1), which trips rule (1) at a SHIFT and
nowhere else — so both land on golden. The rows that must not move
(`n_xor`, `n_xnr`, `n_nsh`, `n_nin`, `n_dv0`, `n_md0`, `n_unx`, `n_ful`,
`n_dec`, `n_cat`, `n_rpl`, `n_pln`) all stayed byte-identical to pristine.

Every arm was ALSO built with `-elabuhdm` / `--elabuhdm` (the post-adjuster
view), and the law holds there too:

| arm, ELAB view | JUDGE score |
|---|---|
| `g1_ops86.sv` | SAME 71 **W2R 1** R2W 0 W2O 0 STILL 0 |
| `g2_leaves86.sv` | SAME 144 **W2R 16** R2W 0 W2O 0 STILL 2 |
| `g3_anc86.sv` | SAME 57 W2R 0 R2W 0 W2O 0 STILL 30 |
| `g4_neg86.sv` | SAME 31 **W2R 1** R2W 0 W2O 0 STILL 4 |
| `g5_leaf85copy86.sv` | SAME 64 W2R 0 R2W 0 W2O 0 STILL 0 |

Most cells collapse to a single constant under `UHDM::UhdmAdjuster` in that
view, which is exactly why the `Earlgrey_0_1` **testflags** database holds no
cell for this law: its command line carries `-elabuhdm`, the adjuster has
already reduced `BankAddrMask` to `INT:65535` size 64 on BOTH sides, and the
head there is a different object entirely.

The STILL-WRONG rows are NAMED residues (pristine == patched, both != golden),
not moves — see § 8: `g1` `s_clg` is R4; `g2`'s two are the
`logic signed [7:0]` / `bit signed [7:0]` DECLARATION rows (R5); `g3`'s 20 are
`a_cat`/`a_rep` x3 (the concat fence, R3), `g_add`/`g_mul`/`f_add` x12 (R2) and
`pk_add`/`pk_mul` (R1); `g4`'s 4 are earl85's R2 (`n_ful`/`n_dec`) and two
pre-existing concat cells; `g5`'s 1 is earl85's own declared non-claim (a
package-QUALIFIED leaf). `g3`'s ONLY-GOLDEN 12 is a pre-existing structural
difference — golden emits gen-scope `param_assign` copies under a
`gen_scope_array` with no enclosing `module_inst`, which we do not — and it is
identical in both binaries.

---

## 6. The instrument lesson this pass paid for

earl85's `g2_leaf85.sv` reported `W2R 18 / STILL 0`, and one of its eighteen
rows (`r06`, `localparam signed[7:0]`) was **wrong on both sides the whole
time**: its leaf constant was missing golden's `int_typespec`. The census could
not see it because `pacen85`'s payload carried only the FIRST operand of the
top operation, and that leaf sits one level below. `pacen86`'s `TREE=` payload
— the WHOLE Rhs, preorder, judge-fields only — is what made it visible, and
re-running earl85's own grid file under it (`g5_leaf85copy86.sv`) is what
turned it into a fix. **A payload that stops at a fixed depth is blind below
that depth; linearise the whole tree.**


---

## 7. The gates — all green (`GATES.r10earl86.txt` has the full battery)

Both binaries were FROZEN at immutable paths (`chmod 555`) before any sweep and
every `cmds.txt` was audited BY BINARY PATH:
`pristine e36cb36103acbc3c2e44797ddc81a745`, `patched
774b905631bc3746deb00824309b2566`.

* golden dumps **23 PASS / 0 FAIL** on both binaries, `/bin/false` **0 / 23**
  (negative control);
* uhdm2rtlil, **both modes** vs the committed baseline AND vs this pass's own
  pristine: **0 differing ROWS** (status AND dump column); byte movers
  **0 / 1358**; status histogram `CMP_EQUAL 679 / SLANG_REJECT 50 /
  SURELOG_FAIL 2` unchanged;
* surelog, **both modes** vs the committed baseline AND vs this pass's own
  pristine: **0 differing ROWS / 1588**, both status histograms unchanged.
  **NO ROW CONVERTED** — `results/*.csv` untouched;
* byte movers **2 / 956**, and both are `Earlgrey_0_1`:
  * `default` — **PREDICTED BY NAME** from the pristine census before any
    patched sweep was read;
  * `testflags` — NOT predicted, and attributed two ways rather than assumed:
    `R10E86_OFF=1` reproduces the pristine file **byte for byte**, and
    `uhdm-cmp <pristine> <patched>` on the pair **exits 0 with 0 lines** — the
    delta is orphaned pre-adjuster objects and is INVISIBLE TO THE JUDGE
    (`OURS_vs_OURS_testflags.cmp` is empty). The same cross-compare on the
    `default` pair prints **exactly one head, 90 lines**: the head cell and
    nothing else (`OURS_vs_OURS_default.cmp`);
* canaries `ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS/PASS; `canaudit`
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`; `InterfaceModPort` /
  `BlackParrotComplex` / `YosysOldOr` byte-identical in both modes,
  `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` pins matched.

### The heads

| test | mode | before | after |
|---|---|---|---|
| `Earlgrey_0_1` | **default** | 90 lines, 1 head | **150 lines, 1 head — the head object is GONE** |
| `Earlgrey_0_1` | testflags | 150 lines, 1 head | 150 lines, 1 head (unchanged modulo ids) |
| SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg / Rggen | both | 17 / 124 / 124 / 17 / 54 / 0 | identical |

Counts are DEPTH, not distance. The two Earlgrey modes now sit on the SAME
object again — r10earl85's R1, `flash_erase_ctrl.sv:12:18 PagesPerBank`,
`vpiOverriden`.

### The corpus re-score, fixed universe (surelog)

| | before | after |
|---|---|---|
| BOTH-SAME | 45 441 | **45 442** |
| **FAMILY-SUBFOLD** | **1** | **0** |
| FAMILY-OPKEPT | 2 | 2 (R6) |
| FAMILY-OVSTAMP | 16 | 16 (R1) |
| TREE-OTHER / OTHER-DIFF | 0 / 1824 | 0 / 1824 |
| ONLY-GOLDEN / ONLY-OURS | 8898 / 9628 | 8898 / 9628 |

Per-cell 3-way: **WRONG->RIGHT 1, RIGHT->WRONG 0, WRONG->OTHER 0.**
**MOVED-WRONG 0 / AWAY 0.** uhdm2rtlil is unchanged in every bucket.

---

## 7b. The wide boundary — the gate that convicts what the corpus cannot

`vwide86.sh` over a COPY of `tools/probe` at ANY depth, both views, both frozen
binaries, workdir-normalised whole-dump byte compare; the file list is read on
**fd 3**, children get `</dev/null`, and **PROCESSED is asserted equal to
LISTED**.

```
PROCESSED=3857 (== LISTED)  identical=7403  DIFFERING=17  no_output=294
rc histogram: rc=0 14194   rc=3 560   rc=4 646   rc=139 28
```

All 17 are accounted for and **eight are NOT this pass's own arms**:

* **9** — this pass's five arms across both views (the law's cells);
* **3** — `r10earl85repro`'s OWN arms, another author's files, scored against
  GOLDEN: `g2_earl85.sv` **W2R 1 / R2W 0 / W2O 0**, `g3_ov85.sv` **W2R 1 / R2W
  0 / W2O 0**, and `g2_leaf85.sv` (= this pass's `g5`) **W2R 2 / R2W 0 / W2O 0**;
* **3** — `r10v85repro`'s VERIFIER arms, a third author's files:
  `va1_unary85.sv` (both views) **W2R 1 / R2W 0 / W2O 0** and `va4_leaf85.sv`
  **W2R 2 / R2W 0 / W2O 0**;
* **2** — `r10buvm22repro/g22.sv`, and **NOT this law**: `R10E86_OFF=1`
  reproduces the **PATCHED** hash (`5ccebbb303ab`), not the pristine one
  (`7e3297df76df`). That is earl84's R5 / earl85's §7 — a database value
  derived from an address that tracks the binary's code layout — reproduced
  here from a THIRD binary pair.

The 28 `rc=139` are 14 files x 2 sides, SYMMETRIC under both binaries and
pre-existing (earl82 R6 / earl83 R6 / earl84 R6 / earl85 R5); a boundary walk
that does not say so reads as if it had compared them.

---

## 8. Residues

Ranked, with arm and corpus cell counts, in `PREDICT_R0.txt`: **R1** the
materialized-import `vpiOverriden` stamp (16 corpus cells, and the new R0),
**R2** the gen-scope home never reaching the bail at all (12 arm cells, 0
corpus — the cheapest next widening), **R3** the concat fence, **R4** a
`$clog2` operand left as a `sys_func_call`, **R5** the
`logic signed`/`bit signed` declaration typespec kind, **R6** the
assignment-pattern override actual on a scalar formal, **R7** the package home,
**R8** earl85's own two declared non-claims.

## 9. The files

| file | what it is |
|---|---|
| `pacen86.cpp` | the direct-reader `param_assign` census, with the whole Rhs tree in the payload (build line in its header) |
| `cen86.sh` / `cencount86.py` | the corpus census driver and its classifier |
| `arm86.sh` / `score86.py` | one arm, three databases; the 3-way multiset scorer (JUDGE and FULL payloads) |
| `g1_ops86.sv` .. `g5_leaf85copy86.sv` | the grids (§ 5) |
| `vwide86.sh` | the wide boundary walk |
| `BOUNDARY_WIDE.notes` | what every one of the 17 differing files is |
| `HEAD_BEFORE_*` / `HEAD_AFTER_*` | the verbatim `uhdm-cmp` head logs |
| `OURS_vs_OURS_*.cmp` | the official judge run on our PRISTINE against our PATCHED Earlgrey databases — the testflags attribution |
| `CENSUS.before.*` / `CENSUS.after.*` | the corpus census, pristine and patched |
| `ARMS.r10earl86.txt` | every arm scored, both payloads, every bucket |
| `GATES.r10earl86.txt` | the full gate battery |
| `PREDICT_R0.txt` | the mover prediction, what actually moved, the new head and the ranked residues |
| `BOUNDARY_WIDE.*` | tally / rc histogram / differing list |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | copies of the shared gate scripts, so this directory runs standalone |
