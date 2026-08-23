# r10buvm27 — § `binOpLeftmostSelectBits27` — **THE 76-LINE BuildUVMPkg HEAD CLEARED**

**IMPLEMENTER VERDICT: ACCEPT.** The 76-line `BuildUVMPkg` head clears in both
modes (76 → 32 cmp lines). The row stays `CMP_NOTEQUAL` at a new 32-line head;
**no corpus row converts and no baseline was edited** — but **this pass's own
arm `g27_a0_head.sv` PASSES the official `uhdm-cmp` in BOTH views** where
pristine fails with a 76-line head, and that is said out loud in §6.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY** (the copies in this
worktree) and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `4c36d4b` |
| worktree | `/tmp/wt_r10buvm27` |
| pristine binary | md5 `e9a8db733bb9a47e21953a189e23696e` |
| patched binary | md5 `1f1aeb7efc0e9d743d3ace3c07f71f13` |
| production surface | `src/ExprEmit.cpp` ONLY — one static predicate + one substitution, and eight call sites re-pointed at it |
| probe surface | `tools/probe/r10buvm27repro/` only |
| deliverable | `/tmp/r10buvm27.patch`, applies clean on a FRESH `4c36d4b` |

## 0. THE HEADLINE

| | pristine | patched |
|---|---|---|
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **76 / 76** | **32 / 32** |
| `uhdm-cmp` heads (`grep -c '^LHS:'`) | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp md5, both modes byte-identical | `0f7013a40fb6e761208de1ca0fee3c2d` (buvm26's pin, hit exactly) | `c8959ae94a5c768e14dc450e000e3426` |
| head object | a `constant UINT:8` vs our `sys_func_call ($bits)` at uvm_pkg.sv:58066 | a `constant UINT:0` vs our `constant UINT:32` at uvm_pkg.sv:58248 (**R0**) |
| corpus census `FOLD_G_KEEP_O`, surelog | **2** | **0** |
| surelog sweep | 937 `CMP_EQUAL` / 19 `CMP_NOTEQUAL` | 937 / 19 — **unchanged**, 0 differing rows |
| u2r sweep, both modes | 679 / 50 / 2 | 679 / 50 / 2 — 0 differing rows, **0 byte movers / 1358** |
| byte movers, surelog | — | **3 / 956**: the 2 PREDICTED BY NAME + the documented Scoreboard COIN |

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG

The pristine log is 76 lines `2>&1`, `grep -c '^LHS:'` = 1, and the two modes
are byte-identical. Source: `1800.2-2017-1.0/src/tlm2/uvm_tlm2_generic_payload.svh`
lines 445-449 and 503, expanded into `pp_output/uvm_pkg.sv:58066` inside
`function bit uvm_tlm_generic_payload::do_compare(uvm_object rhs, uvm_comparer comparer)`:

```systemverilog
`define m_uvm_tlm_fast_compare_int(VALUE,RADIX,NAME="")                      \
  ...                                                                        \
     void'(comparer.compare_field_int(name , VALUE, gp.VALUE,                \
                                      $bits(VALUE), RADIX));                 \
  ...
   `m_uvm_tlm_fast_compare_int(m_data[i] & be, UVM_HEX, ...)   // :503

  rand byte unsigned m_data [];      // the class property
  byte unsigned be;                  // the loop-body local
```

```
LHS golden  constant: , line:58066:84, endln:58066:105
              |vpiParent: \_method_func_call: (compare_field_int) @58066:24-41
              |vpiDecompile:8 |vpiSize:64 |UINT:8 |vpiConstType:9
RHS ours     sys_func_call: ($bits), line:58066:84, endln:58066:105
              |vpiParent: \_method_func_call: (compare_field_int)
              |vpiArgument: \_operation: @58066:90-104  |vpiOpType:28
                  |vpiOperand: bit_select (…do_compare::m_data) @58066:97-98
                                 |vpiIndex: ref_obj (…do_compare::i)
                  |vpiOperand: ref_obj (…do_compare::be) @58066:102-104
```

**THE SLOT AND THE FIELD, from the generated sources.**
`method_func_call::Compare`
(`~/git-repos/UHDM/build/generated/src/method_func_call.cpp`) delegates to
`tf_call::Compare`, whose order is `Scope`, then **`Tf_call_args` as a
VECTOR**, then `VpiName`. Both sides carry FOUR call arguments, so the vector
overload compares element-wise and reaches element **3** (0-based) — the
`$bits(...)` slot. `BaseClass::Compare` tests **`VpiType`** before any name or
per-kind field, and `vpiConstant` vs `vpiSysFuncCall` differs there, so the
walk stops immediately: this is the SINGULAR overload, `m_failedLhs` = golden's
constant, `m_failedRhs` = our call. 76 lines = the DEPTH of the two decompiled
objects (each printed twice).

**THE COPIES, MEASURED.** One object per database, in both modes — and the
head lives in the **1800.2 tree only**. The five uvm-1.2 row-modes (SeqDriver,
SimpleUVM, Scoreboard, MiniAmiq and their siblings) DO carry a
`uvm_tlm_generic_payload::do_compare` — 96 census rows name that scope in
SeqDriver's golden alone — but uvm-1.2 writes the byte loop WITHOUT the
`m_uvm_tlm_fast_compare_int` macro
(`uvm-1.2/src/tlm2/uvm_tlm2_generic_payload.svh:465`:
`do_compare = ((m_data[i] & lhs_be) == (gp.m_data[i] & rhs_be));`), so there is
no `$bits` at that site at all. That is why the corpus census below finds the
disagreement in **exactly two databases**, both `BuildUVMPkg`, and why clearing
it moves those two and nothing else.

## 2. THE LAW

> **`CompileHelper::compileBits` types an EXPRESSION argument by its LEFTMOST
> OPERAND, and only when that operand carries a SELECT.**
>
> Surelog's `compileBits` (`CompileExpression.cpp:4663-4724`) never looks at
> the argument as an expression. Its default branch takes exactly **three
> `Child()` hops** from the argument `Expression` node and hands whatever lands
> there to `getTypespec`:
>
> ```cpp
> NodeId Primary         = fC->Child(Expression);
> NodeId Primary_literal = fC->Child(Primary);
> if (Type(Primary_literal) == paConcatenation)        { ...concat branch... }
> else if (Type(Primary_literal) == paComplex_func_call) typeSpecId = Primary_literal;
> else                          typeSpecId = fC->Child(Primary_literal);
> ```
>
> Surelog's parse tree (`surelog -d ast`, reproduced in `AST.r10buvm27.txt`
> from `ast27.sv`) makes those three hops land on a **different node kind per
> written shape**, because a BINARY expression's first child is the LEFT
> OPERAND'S OWN `Expression` node — one level deeper than a bare argument:
>
> | written | hop1 | hop2 | hop3 = `typeSpecId` | golden |
> |---|---|---|---|---|
> | `x` | Primary | Primary_literal | **StringConst(x)** | FOLD |
> | `x[i]` / `x.m` | Primary | **Complex_func_call** | (hop2 taken) | FOLD |
> | `x op y` | Expression | Primary | Primary_literal | **KEEP** |
> | `x[i] op y` | Expression | Primary | **Complex_func_call** | **FOLD** |
> | `3'd1 op y` | Expression | Primary | Primary_literal | KEEP |
> | `(x[i]) op y` | Expression | Primary | Primary_literal | KEEP |
> | `~x[i] op y` | (unary; never reaches a Complex_func_call) | | | KEEP |
> | `x[i] op y op z` | Expression | Expression | Primary | KEEP |
> | `{x[i], y}` | Primary | Concatenation | (concat branch) | KEEP |
>
> `getTypespec`'s `paComplex_func_call` arm then compiles that leftmost operand
> and takes its **ROOT NAME's** typespec — the SAME answer §
> `bitsSelectIgnoredRootBits95` already transcribes for a bare
> `$bits(<select chain>)`. So **`$bits(m_data[i] & be)` IS `$bits(m_data[i])`**:
> golden's 8 is `byte m_data[]`'s root width (an unsized dimension counts as
> ONE), not the 8-bit width of the bit-and — and `$bits(pk4[i] & be)` over
> `logic [7:0] pk4 [4]` is golden's **32**, which no expression-width rule
> would ever produce.

Two consequences worth naming, because both are golden cells and both are
counter-intuitive:

* `$bits(be & m_data[i])` — the SAME operands, the other way round — **keeps**
  the call: hop3 lands on a `Primary_literal` and `getTypespec` has no arm for
  it (grid cell b17).
* `$bits(m_data[i] & be & be)` **keeps**: `&` is left-associative, so the
  leftmost operand is itself a binary `Expression` and the walk lands one level
  short (grid cell b18).

**THE REFUTED ALTERNATIVE.** The obvious model — "Surelog folds the
EXPRESSION's own bit width" — is wrong twice over, and the grid separates it.
`Bits(<any*>)` bottoms out in `UHDM::ExprEval::size`, whose `uhdmoperation`
case sums operands **only for `vpiConcatOp`** and otherwise returns **0**
without setting `invalidValue`. If that road were taken the head would be a
`constant UINT:0`, not `UINT:8`. It is not taken: `getTypespec` finds a
typespec first, and `m_elabMode`'s `isFullySpecified` bump is what turns
`Reduce::No` into `Reduce::Yes` for exactly those cells (which is also why the
out-of-block twin, § `bitsOutOfBlockNoReduce95`, folds none of them).

## 3. THE GOLDEN GRIDS, RUN BEFORE ANY CODE

| grid | cells | what it pins |
|---|---|---|
| `g27_a_leftmost.sv` | 31 | leftmost-operand shape in a class method: bare name / select / member / literal-left / literal-right / unary / paren / ternary / concat / replication / call / enum / real / string / comparison / logical / shift / multiply — 20 different written shapes over 10 declarations |
| `g27_b_shapes.sv` | 53 candidate spans | 28 leftmost-operand shapes **x** class in-block, class **out-of-block**, package function, module `initial`, `cont_assign`, `localparam` init, `parameter` init, `if` condition, index position and **call argument** — plus four single-argument twins so the substitution can be read against the rule it substitutes into |
| `g27_a0_head.sv` | 1 | the corpus head in 34 lines |
| `ast27.sv` | — | the parse-tree ground truth (`AST.r10buvm27.txt`) |

The grids are deliberately not self-confirming. Every folding cell carries a
different width (8 / 32 / 48 / 4 / 3), the shapes that must NOT move sit beside
the ones that must, the same shape is asked in six homes, and the
value-distinguishing pair (`dyn[i] & v32` → 8, `v32[3] & be` → 32) rules out
"the wider operand" and "the expression's own width" at once.

### The golden answers (grid `g27_b_shapes.sv`, class in-block, DEF)

| cell | written | golden |
|---|---|---|
| b01 | `dyn[i] & be` (`byte dyn[]`) | **8** |
| b02 / b03 | `q[i] & be` (`byte q[$]`) / `aa["k"] & be` (`byte aa[string]`) | **8** / **8** |
| b04 | `pk4[i] & be` (`logic [7:0] pk4 [4]`) | **32** |
| b05 | `md[i][1] & be` (`logic [7:0] md [2][3]`) | **48** |
| b06 / b07 / b08 | `v32[3] & be` / `v32[7:0] & be` / `v32[i+:4] & be` | **32** / **32** / **32** |
| b09 / b10 | `sp.hi & be` / `ou.in.b & be` | **4** / **3** |
| b16 | `dyn[i] & v32` | **8** (the LEFT operand, not the wider one) |
| b21 / b22 / b23 | `dyn[i] + be` / `dyn[i] == be` / `dyn[i] ? be : be` | **8** / **8** / **8** |
| b25 | `dyn[i][0] & be` | **8** |
| b11 / b12 | `this.b8 & be` / `hnd.b8 & be` | KEEP / KEEP |
| b13 / b14 / b15 | `ee & be` / `st.len() & be` / `f(1) & be` | KEEP |
| b17 / b18 / b19 / b20 | `be & dyn[i]` / `dyn[i] & be & be` / `(dyn[i]) & be` / `~dyn[i] & be` | KEEP |
| b24 / b26 / b27 / b28 | `{dyn[i], be}` / `sp.hi[1] & be` / `rr + 1.0` / `tt & be` | KEEP |
| o01 | the same `dyn[i] & be` written **OUT OF BLOCK** | KEEP (§ `bitsOutOfBlockNoReduce95`) |
| k01 / k02 | package function | KEEP in the DEF package listing, FOLD in the TOP listing |
| m01…m11 | cont_assign / localparam / parameter / initial / if-cond / index | FOLD, same values |
| p01…p04 | **call argument** / `$display` argument / concat operand / ternary operand | **8** each |

Every position and every home behaves exactly like the single-argument rule
already does. **The substitution is the whole law.**

## 4. THE CORPUS CENSUS, GOLDEN vs OURS, MADE BEFORE THE PATCH

`ct27cen` is uvm95's `ct95cen` plus one column: for a call whose first argument
is an `operation`, the **sub-shape** `operation[op<VpiOpType>/<first operand
kind>]`. That column IS the mover predictor (§5). `join27.py` joins golden
against ours on the SPAN (our expression objects carry an EMPTY `VpiFile`, so
the file travels as an attribute, never as key) and compares only the JUDGED
shape — kind and folded value.

| | surelog 956 DBs | | uhdm2rtlil 1358 DBs | |
|---|---|---|---|---|
| | pristine | patched | pristine | patched |
| SAME | 917 | **919** | 214 | 214 |
| **FOLD_G_KEEP_O** | **2** | **0** | 0 | 0 |
| KEEP_G_FOLD_O | 15 | 15 | 0 | 0 |
| VALUE | 4 | 4 | 0 | 0 |
| OTHER | 246 | 246 | 2 | 2 |
| OUT_OF_SCOPE_DIFF | 17687 | 17687 | 1070 | 1070 |

The **2** `FOLD_G_KEEP_O` cells were the head and nothing else:

```
FOLD_G_KEEP_O  default_BuildUVMPkg    58066:84-58066:105  G=CONST:8  O=CALL:$bits
FOLD_G_KEEP_O  testflags_BuildUVMPkg  58066:84-58066:105  G=CONST:8  O=CALL:$bits
```

They are gone; every other column is byte-unchanged. The 15
`KEEP_G_FOLD_O` are uvm95's R3 (the out-of-block over-fire, deliberately not
shipped there or here) and the 4 `VALUE` are uvm95's R7 — **which is this
pass's new R0**.

**THE FENCE.** Every `$bits`/`$size`/`$clog2` cell of the whole `uhdm2rtlil`
corpus already agreed before this pass and still agrees after it (0/0/0 in both
directions, both modes). The two u2r rows that *carry* a type query over an
expression are `BitsCallOnExpression` (`$bits(~dr_q)`, a UNARY) and
`for_loop_nonconst_bound` (`$clog2(<binary>)`), both `CMP_EQUAL`, both outside
the rule by construction. In the surelog corpus the one non-head cell is
`BitsInGenBlock`'s `$bits({a, b, c})` — a CONCATENATION (`op33`), a `CMP_EQUAL`
row in both modes, and a different branch of `compileBits` entirely.

## 5. THE MOVER PREDICTION, MADE FROM THE PRISTINE DATABASES

Full text in `PREDICT.r10buvm27.txt`. Predicted from the sub-shape column
alone, before the patched sweeps ran:

* surelog → `default/BuildUVMPkg-bf853d43`, `testflags/BuildUVMPkg-bf853d43`;
* uhdm2rtlil → **none**.

Observed: surelog `MOVERS 3 / 956` — the two predicted, **plus**
`default/Scoreboard-59431470`, the documented ~50/50 `svunit_pkg`
`vpiTaskFunc`-order coin: 92 raw dump lines, **ORDER-BLIND diff 0 lines**.
uhdm2rtlil `0 / 1358`. The two predicted movers' whole-dump diff is **32 lines
each, order-blind 32** — one `sys_func_call ($bits)` subtree replaced by one
`constant UINT:8`, and nothing else.

## 6. THE ARMS — BOTH VIEWS, `BROKE = 0` EVERYWHERE

| arm | view | cells | ALREADY-OK | FIXED | **BROKE** | STILL |
|---|---|---|---|---|---|---|
| `g27_a0_head.sv` | def | 1 | 0 | **1** | **0** | 0 |
| `g27_a0_head.sv` | elab | 1 | 0 | **1** | **0** | 0 |
| `g27_a_leftmost.sv` | def | 31 | 26 | **3** | **0** | 2 |
| `g27_b_shapes.sv` | def | 53 | 18 | **27** | **0** | 8 |
| `g27_b_shapes.sv` | elab | 53 | 18 | **27** | **0** | 8 |
| `r10v95repro/v95_b6_exprargs.sv` | def | 20 | 9 | **3** | **0** | 8 |
| `r10v95repro/v95_b6_exprargs.sv` | elab | 20 | 7 | **3** | **0** | 10 |

**`g27_a0_head.sv` CONVERTS — SAID LOUDLY.** Pristine: `CMP_FAIL`, 1 head,
**76 cmp lines — the same count as the corpus head**. Patched: **`PASS_CMP`, 0
heads**, in **both** `def` and `-elabuhdm`. **No `results/*.csv` row was
touched and no corpus row converted.**

`v95_b6_exprargs.sv` is **another pass's adversarial arm** (uvm95's verifier),
found by the wide boundary gate, not written here — three of its cells
(`$bits(bd[0] & be)` → 8, `$bits(ba[1] & be)` → 24, `$bits(bd[0] + 1)` → 8)
move TO golden and none moves away.

The `STILL` cells are all pre-existing and named in §8: the dotted-member road
(6 cells), the concatenation over-fire (2), and a `$bits(<type>)` span (1).

## 7. THE PATCH

`src/ExprEmit.cpp` and nothing else.

* **`binOpLeftmostSelect27(arg)`** — a static predicate returning the leftmost
  operand of a `BinaryOp`/`ConditionalOp` argument when Surelog's three-hop
  walk would reach a `Complex_func_call`, and null otherwise. Two guards, each
  a golden cell:
  * the operand must carry **at least one SELECT** (`ElementSelect` /
    `RangeSelect` over a simple name, via uvm95's `selChainRoot95`) — a bare
    name on the left lands on a `Primary_literal` and keeps (cell b17);
  * the operand must **START AT THE ARGUMENT'S OWN FIRST CHARACTER** — any
    wrapper node (a parenthesis, a cast, a unary, a nested binary) inserts a
    level and pushes the walk off the `Complex_func_call`. slang's AST makes
    parentheses transparent, so the SOURCE OFFSET is what carries the
    distinction (cells b18/b19/b20).
* **the substitution** — one new local, `bitsArg27`, initialised to the written
  argument and re-pointed at the leftmost operand when the predicate fires.
  The eight places in the `$bits` decision that read `call.arguments()[0]` now
  read `bitsArg27`, so **the whole existing machinery runs on the leftmost
  operand**: Surelog's def-compile fold test (`srlgBitsFoldArg`), the class
  property rule (§ `bitsOwnClassPropFold61`), the package-copy gate, the
  root-width VALUE (§ `bitsSelectIgnoredRootBits95`) and the keep half. That is
  literally what `compileBits` does, and it is why every home and every
  position in §3 comes out right without a single extra gate.

Gated on `name == "$bits"`: `$size` compiles through the same `compileBits`
with `sizeMode`, whose every arm ends in a surviving `sys_func_call`, and
`$clog2`/`$high`/`$low`/`$left`/`$right` are different Surelog functions
altogether.

STATED GATE == CODE GATE: the same predicate that opens the fold supplies the
width, through `bitsRootWidth95Applies(bitsArg27, …)`, which is unconditionally
reached for every cell the substitution creates (its `Owns` half returns true
for any `ElementSelect`/`RangeSelect`, which is exactly what the substitution
guarantees). slang's own root-context `tryEval` of the whole `$bits(<binary>)`
— which would answer the bit-and's 8 where golden answers `pk4`'s 32 — is
never consulted for these cells.

## 8. NEW R0 AND RESIDUES

**R0 — the new `BuildUVMPkg` head**, both modes, **32 lines**, one head, cmp
logs byte-identical between modes (md5 `c8959ae94a5c768e14dc450e000e3426`), at
`uvm_pkg.sv:58248` (and `:58283`) inside `uvm_tlm_generic_payload`:

```
LHS golden  constant: , line:58248:20, endln:58248:36
              |vpiParent: \_method_func_call: (new) @58248:15-47
              |vpiDecompile:0 |vpiSize:64 |UINT:0 |vpiConstType:9
RHS ours     constant: , line:58248:20, endln:58248:36
              |vpiDecompile:32 |vpiSize:64 |UINT:32 |vpiConstType:9
```

This is **uvm95's R7 promoted to head**: a `new [ $bits(<enum member>) ]` size
expression, where Surelog resolves **nothing** inside a dynamic-array `new[]`
size and mints **0**, while we fold the enum's 32. It is a pure VALUE head (the
kinds already agree), it is the whole of the census's `VALUE` column (4 cells =
2 spans x 2 modes), it was byte-unchanged by this pass, and it is now the
cheapest cell in the family: the question is a single one — *which contexts
does `compileBits` refuse outright*, and `new[]`'s size argument is one of
them. Decode `CompileHelper`'s `paDynamic_array_new` arm and the `Reduce` flag
it hands the size expression (buvm16's § `newArrayArgNoBind16` already owns the
neighbouring bind question), then gate the refusal.

**Residues this pass measured and deliberately left**

* **R-DOTTED — a DOTTED leftmost operand (and its single-argument twin).**
  `$bits(sp.hi & be)` is golden's **4** and `$bits(ou.in.b & be)` golden's
  **3**; we keep the call, because our single-argument `$bits(sp.hi)` keeps it
  too (uvm95's **R2**, unchanged). The substitution routes the dotted shape
  into exactly the same road, so fixing R2 fixes both at once — **6 arm cells
  (b09, b10, t09, t10, m04, m08), corpus population 0**. This is now the
  cheapest `$bits` residue after R0: golden's road is
  `paComplex_func_call → compileExpression → hier_path → decodeHierPath`, which
  resolves struct members but not a mid-path select (§
  `bitsSelectThenMember95` already models the second half).
* **R-CONCATOVER — `$bits({<select>, <name>})` over-fires.** Golden KEEPS
  `$bits({dyn[i], be})` where we fold to 16 (grid cell b24; `$bits({2{pw}})`
  is the same shape, grid `g27_a_leftmost` c21). `compileBits`' concatenation
  branch has NO `paComplex_func_call` arm, so a select inside a concat element
  reaches a `StringConst` by a different depth and the whole fold collapses.
  **2 arm cells + 8 pre-existing cells in `v95_b6_exprargs`, corpus population
  0** (BitsInGenBlock's concat agrees on both sides). PRE-EXISTING and
  byte-unchanged.
* **R-CONSTPARENT — the folded constant has no `vpiParent`.** Golden's
  `constant` at 58066 carries `|vpiParent: \_method_func_call`; ours carries
  none, because the emitter parents a folded constant only under an
  `operation` / `bit_select` / `case_item` parent. **No generated `Compare`
  reads `VpiParent`**, so `uhdm-cmp` cannot see it and the head still clears —
  it is a dump-only residue, and changing the parenting rule would touch every
  folded constant in both corpora, so it was refused.
* **R-BITSSPAN — the span of a KEPT `$bits`** (uvm95's R5): golden's surviving
  `sys_func_call` wears a name-only span, ours spans the whole call
  (`g27_b_shapes` line 77, `$bits(byte)` out of block: golden `77:9-77:14`,
  ours `77:9-77:20`). `uhdm-cmp` reads neither. Unchanged.
* **§ `bitsOutOfBlockNoReduce95` (uvm95's R3) — still 15 corpus cells, still
  not shipped.** This pass CONFIRMS the law on its own out-of-block twin
  (`g27_b_shapes` o01/o02/o03: the in-block `dyn[i] & be` folds, the
  out-of-block one keeps, and `$bits(byte)` folds in the TOP package copy while
  keeping in the DEF copy). The per-copy split is still undecoded and it is
  still a wash to ship un-split.
* **buvm26's queue, RE-RANKED** (nothing this pass measured moved any of them):
  1. **R-LITARG / R-TRAILMEM** — the dropped-call family's cheapest cells.
     R-TRAILMEM is the more urgent half: on the VALID path
     `as29[nm].self29().v` gives us a **NULL `Rhs`**, which is worse than a
     shape mismatch.
  2. **R-G22RANGE** — `TaskFuncEmit.cpp:3403`'s associative-array return
     typedef reaching an unchecked `FixedSizeUnpackedArrayType` cast at
     `TypeEmit.cpp:10359`. It is the **boundary polluter**: it tracks the
     BINARY, not any law, so every future boundary gate pays for it. Now that
     this pass's boundary came back with 8 movers all attributable, fixing
     R-G22RANGE is what keeps that true cheaply.
  3. **R-2SUB** — a two-subscript receiver; one residue in two places.
  4. **buvm25's loop-variable residues**, `init_sequence_library`'s `i` first
     (`int_var` where golden has `array_var` — § `foreachPkgClassArrayVar25`'s
     own rule applied to a non-class element type).

## 9. REPRODUCE

```sh
g++ -O2 -std=c++17 ct27cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10buvm27_ct27cen
./cen27.sh <sweep workdir root> <censusdir>        # golden + ours, every row-mode
python3 join27.py <censusdir> [--verbose]          # SAME / FOLD_G_KEEP_O / KEEP_G_FOLD_O / VALUE
PRI=… PAT=… MODE=def  ./three27.sh g27_a0_head.sv  # ALREADY-OK / FIXED / BROKE / STILL
PRI=… PAT=… MODE=elab ./three27.sh g27_b_shapes.sv
PRI=… PAT=… ROOT=<a COPY of tools/probe> ./bound27.sh          # BOTH views, .sv AND .v
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <pat wd> <pris wd>
UHDM_CMP=~/git-repos/UHDM/build/bin/uhdm-cmp ./rowheads.sh <wd> <outdir> \
    SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./pins27.sh <pat wd> <pris wd> ; bash canaudit.sh canaries.sh ctcan2.sh
surelog -parse -nocache -d ast ast27.sv            # the parse-tree ground truth
```
