# r10earl79 — § dimExprBoundFold79: an EXPRESSION-form unpacked array dimension folds the way `ExprEval::reduceExpr` folds

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `0f3eb2b`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl78 named as R0 — 36 cmp lines, one head,
byte-identical in both modes — is CLEARED in both modes.**

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_default.cmp` / `HEAD_BEFORE_testflags.cmp` are the verbatim
pristine logs from my own build of `0f3eb2b` in my own worktree; that build is
**byte-identical to the main tree's binary** (same md5), and the two logs
reproduce r10earl78's committed `HEAD_AFTER_*.cmp` **byte for byte**, so this
pass starts on exactly the object earl78 named.

```
tlul_socket_1n.sv:126     tlul_pkg::tl_h2d_t   tl_u_o [N+1];
                                                       ^ col 32

LHS (golden)  constant 126:32-126:33   RHS (ours)  constant 126:32-126:35
  |vpiParent -> operation 126:32-126:35  |vpiParent -> operation 126:32-126:35
  |vpiDecompile:3                        |vpiDecompile:3
  |vpiSize:64                            |vpiSize:32     <-- THE HEAD
  |UINT:3                                |UINT:3
  |vpiConstType:9                        |vpiConstType:9
```

**Which arm.** `expr::Compare` (`UHDM/build/generated/src/expr.cpp:83-102`)
reads `VpiDecompile` first — `"3" == "3"` — then `VpiSize`: **64 != 32**, and
no typespec is ever reached. `constant::Compare`'s own `VpiConstType` row is
below that and never runs. Both sides are non-null constants, so
`BaseClass.h`'s `(lhs != nullptr) && (rhs != nullptr)` arm names both.

**Which object.** The `[N+1]` unpacked dimension of an `array_var` in
`tlul_socket_1n`, present in every instantiation of that module.

---

## 2. The law

**§ dimExprBoundFold79 — a size-form unpacked dimension whose size is WRITTEN
AS AN EXPRESSION is folded by `ExprEval::reduceExpr` rather than substituted
from a stored `Value`: it carries the `vpiConstType` / value tag that
reduce gives its TOP OPERATOR, the `VpiSize` that operator's own arm stamps
(64 on every claimed arm except `vpiAddOp`, which takes the MAX of its
operands' sizes), and the span of the expression's FIRST CHILD. A size written
as a bare NAME or a LITERAL is NOT this law's — it is
§ dimBoundInheritsParamEnc74's, untouched.**

### Decoded from Surelog

`CompileHelper::compileRanges`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:4038-4155`)
rewrites `[E]` into `[0 : E-1]`: a bare `UINT:0`/64 left bound and a `vpiSubOp`
over `compileExpression(<size syntax>, …, reduce)` and a loc-less `INT:1`/64.

* when `E` **names a parameter**, that call lands in
  `CompileHelper::getValue` (same file, `:966-981`) and the bound is minted
  from the instance's stored `Value` — the same object
  `NetlistElaboration::elab_parameters_` (`NetlistElaboration.cpp:429-432`)
  stamps into the parameter's `param_assign`. That is
  § dimBoundInheritsParamEnc74 and this pass does not touch it.
* when `E` **is an expression**, the call goes down the ordinary
  `compileExpression` operation path, which ends in `ExprEval::reduceExpr`
  (`CompileExpression.cpp:4288`). `reduceExpr` mints the result straight off
  the arithmetic — `VpiSize(64)` on every arm — and re-spans it with
  `populateCoreMembers(child, child, result)` on the expression node's FIRST
  CHILD. **Nothing runs `CompileHelper::adjustSize` over that constant**,
  which is why the 64 survives where the size-form-name arms carry a declared
  width.

The per-operator encoding is `reduceExpr`'s own table, the one r10rgg14's
`srlgRedCt14` and r10earl73's `ovRedIsInt73` already model.

### Measured on golden

`g2_dimexpr79.sv` (17 operator rows × 6 homes × 3 instantiations),
`g3_ops79.sv` (16 compound/leaf rows × 2 instantiations) and
`g4_names79.sv` (8 name/system-call rows × 2 instantiations), all built with
`arm79.sh` and censused with `rngcen79`. LHS is always golden.

| written dimension | golden bound |
|---|---|
| `[N+1]` `[N&7]` `[N\|8]` `[N<<1]` `[N>>1]` `[$clog2(N)]` `[$clog2(N)+1]` `[$bits(int)+N]` `[gi+2]` `[1+2]` | `UINT:` ct 9, **size 64** |
| `[LA+1]` (`localparam int LA = N+1`), `[LL+1]` (`= 6`), `[pk::PP+1]` (`= 8`) | `UINT:` ct 9, size 64 |
| `[N-1]` `[N*2]` `[N/2]` `[N%7]` `[2**N]` `[N*M]` `[-(0-N)]` | **`INT:` ct 7**, size 64 |
| `[(N*2)+1]` `[N*2+1]` `[(N+1)*2]` `[N+8'd2]` | `INT:` ct 7, size 64 |
| `[LM+1]` (`localparam int LM = N*2`), `[pk::PM+1]` (`= 4*2`, qualified AND wildcard-imported) | `INT:` ct 7, size 64 |
| `[N]` `[7]` `[(N)]` — **the control** | § dimBoundInheritsParamEnc74's, unchanged |

and the SPAN is the LEFT OPERAND's in every binary row (`(N*2)+1` claims
`(N*2)`, parens included; `N*2+1` claims `N*2`; `pk::PM+1` claims `pk::PM`;
`(N+1)` claims the inner `N`), the OPERATOR TOKEN's in the unary row, and the
whole expression's for a `$` call.

Every home answers identically: a module-body `array_var`, a `wire`
`array_net`, an output PORT's elaborated `array_net`, a GEN-SCOPE local
(both iterations), the second and third instance of the same module with a
different override of `N`, and both dims of `[N+1][N*2]`.

### The SIZE is not a constant 64 — and that is what the boundary caught

Every arm of `ExprEval::reduceExpr` this law claims hardcodes `VpiSize(64)`
**except two**: `vpiAddOp`/`vpiPlusOp` takes `max(expr0->VpiSize(),
expr1->VpiSize())` (`UHDM/templates/ExprEval.cpp:3191`, `:3205`, `:3219` — the
unsigned, signed and real arms alike) and unary `vpiMinusOp` takes the
operand's own size (`:3318`).

r10earl74's committed grid `g1_dims74.sv` carries the witness, in one module
with `localparam int A = 256; localparam int B = 2;`:

| row | golden |
|---|---|
| `w_mul [A * B]` | `INT:512` size **64** |
| `w_sub [A - B]` | `INT:254` size **64** |
| `w_div [A / B]` | `INT:128` size **64** |
| `w_shl [B << 2]` | `UINT:8` size **64** |
| `w_clog [$clog2(A)]` | `UINT:8` size **64** |
| **`w_add [A + B]`** | `UINT:258` size **32** |

32 is exactly `max(32, 32)` — both `A` and `B` reduce at their own declared
`int` width. A first cut of this law wrote 64 unconditionally and moved those
three cells **AWAY from golden on an earlier pass's committed arm**; the WIDE
BOUNDARY is what convicted it, and `dimRedSz79` is the fix. A REDUCED NAME's
size is the parameter's own stored one — § dimBoundInheritsParamEnc74's
business, deliberately not modelled here — so `dimRedSz79` ABSTAINS on a name
and the ADD arm answers only when the OTHER operand is provably 64. The corpus
head `[N+1]` is claimed (the bare decimal `1` reduces at 64, so the max is 64
whatever `N` is); `[A + B]`, `[N + M]` and `[N + 8'd2]` are REFUSED.

### Refused, each with the golden measurement that says why

| shape | golden | why refused |
|---|---|---|
| `[A+B]`, `[N+M]`, `[N+8'd2]` | 32 / 64 / 64 | the ADD `max` rule cannot be proved without the parameter's stored size (R1) |
| `[N^1]` | keeps `operation` op 30, **unfolded** | `reduceExpr` has no `vpiBitXorOp` row (r10vrgg14's `a16`). We over-fold it today; this law does not deepen that. |
| `[int'(N*2)]` | `UINT:` ct 9, **EMPTY** `VpiDecompile` | |
| `[unsigned'(N*2)]` | `INT:` ct 7, decompile `6`, span the INNER `N` | one Conversion node, two answers — r10earl73's abstention, reproduced |
| `[(N>2)?4:2]` | `UINT:` ct 9 spanned at the TAKEN BRANCH | a different producer |
| `[f4(N)]` (user function) | `UINT:` ct 9 size 64 | one measured cell; a user function's return type is arbitrary |
| `[+N]` unary plus | golden does not fold it | `reduceExpr`'s `vpiPlusOp` shares the `vpiAddOp` body, which is guarded by `operands.size() == 2` |
| `[N]`, `[(N)]`, `[7]` | § dimBoundInheritsParamEnc74 | `dimExprShape79` strips parens and then refuses `IdentifierName`/`ScopedName`/literals |

### The two populations are DISJOINT, and the disjointness is MEASURED

`dimjoin79.py` splits every size-form dimension bound by a property only the
databases carry: golden re-spans an EXPRESSION fold at the expression's first
child, so **golden's span is a strict prefix of ours** exactly when the size
was written as an expression; for a bare name or a literal both sides span the
same token. Over the whole corpus the join is exact — `GOLDEN_ONLY_KEYS=0`,
`OURS_ONLY_KEYS=0`, `UNMATCHED=0` on both corpora — and (`CENSUS.txt`):

| | EXPR cells | of which DIFFER | NAME cells | of which DIFFER |
|---|---:|---:|---:|---:|
| Earlgrey_0_1 / default, PRISTINE | **48** | **48** (`VpiSize` only) | 663 | **0** |
| Earlgrey_0_1 / testflags, PRISTINE | **48** | **48** (`VpiSize` only) | 705 | **0** |
| surelog corpus, 956 databases, PRISTINE | 96 | 96 | 1964 | 0 |
| uhdm2rtlil corpus, 1358 databases, PRISTINE | **0** | 0 | 390 | 0 |

so § dimBoundInheritsParamEnc74's population is 2,354 cells corpus-wide and
**every one of them already agrees with golden**, while this law's population
is 96 cells, all in the two Earlgrey databases, every one disagreeing in
`VpiSize` and only `VpiSize`.

**After the patch: 2,450 size-form dimension-bound cells across both corpora,
0 differing.** (The patched census reports the cells as `NAME` because the
classifier keys `EXPR` on golden's span being a strict prefix of ours and the
patched spans now EQUAL golden's — Earlgrey/default 711 cells all agree,
Earlgrey/testflags 753 cells all agree.)

---

## 2b. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 36 cmp lines, 1 head | **64 cmp lines, 1 head, A DIFFERENT OBJECT** |
| Earlgrey_0_1 / testflags | 36 cmp lines, 1 head | **64 cmp lines, 1 head, the same object** |

The line count goes UP because the head OBJECT changed and the new one carries
a `ref_typespec`; the old head is gone. The new head is
`prim_fifo_sync.sv:12`'s `param_assign` Rhs, golden `vpiDecompile:4'h0` vs ours
`32'h0` — a based-literal override actual's decompile WIDTH, an entirely
different family (`PREDICT_R0.txt` decodes it). Both modes stay byte-identical
to each other. Every other named row's head is unchanged (`GATES.txt`).

Earlgrey dimension-bound census: **48 cells TO-GOLDEN per mode, 0 AWAY-GOLDEN,
0 MOVED-WRONG, 0 still differing.**

Grid (`GRID_SCORE.txt`), judge fields only:

| arm | TO-GOLDEN | AWAY | MOVED-WRONG |
|---|---:|---:|---:|
| `g2_dimexpr79.sv` | **504** | 0 | 0 |
| `g3_ops79.sv` | **120** | 0 | 0 |
| `g4_names79.sv` | **84** | 0 | 0 |
| `r10earl74repro/g1_dims74.sv` (an earlier pass's grid) | **30** | 0 | 0 |
| `r10vearl74repro/va2_v74.sv` (its verifier's arm) | **186** | 0 | 0 |

---

## 3. What the patch does

`src/TypeEmit.cpp`, `buildUnpackedRanges`, the size-form arm, plus three new
helpers in the same file:

* `dimExprShape79` — is the written size one of the claimed expression shapes?
* `dimRedCt79` — `reduceExpr`'s per-operator constant type, or **0 to abstain**.
* `dimFoldSpan79` — the first-child span.

When (and only when) `dimExprShape79` accepts and `dimRedCt79` does not
abstain, the bound constant takes `VpiSize(64)`, the `INT:`/`UINT:` tag of the
returned constant type, that constant type, and the first-child span. Every
other arm — § dimFoldOverriddenParam23, § dimFoldOverrideChainWidth26,
§ dimFoldReducedTypedWidth26, § dimFoldTsQualifiedOrSignedModPar26,
§ dimBoundInheritsParamEnc74 — is byte-for-byte as it was.

**`dimRedCt79` is a deliberate SECOND COPY of `srlgRedCt14`'s table, not a call
into it.** The two differ in exactly one row, and both rows are measured: a
NAME leaf reduces to `vpiUIntConst` inside a folded INDEX (r10rgg14's grid) and
to ITS OWN INITIALIZER's encoding inside a dimension bound (`[LM+1]` INT,
`[LA+1]` UINT). Merging them would move every r10rgg14 index fold in both
corpora. RESUME §9's "no premature helper extraction until 0 NE" applies.

`dimRedSz79` is the size half and it is the reason the claim is narrower than
the operator table: the law fires only when `dimExprShape79` accepts,
`dimRedCt79` does not abstain, AND `dimRedSz79` proves 64.

**Two traces.** `R10E23_DIMDBG=1` gains an `expr=<ct>` field;
`R10E79_CELLDBG=1` prints one line per claimed cell. **`R10E79_OFF=1` is the
A/B gate**: it computes and traces the law and then throws the answer away, so
the same binary is a NEUTRAL control — it is byte-identical to the pristine
binary on all four arms, which is how `r10buvm22repro/g22.sv`'s boundary mover
was convicted as NOT this law's.

---

## 3b. Gates

All green — `GATES.txt` has every number. In one line: both binaries built
`-j 2` and frozen `chmod 555` before any sweep, every `cmds.txt` audited by
binary PATH (1,458 + 1,523 per sweep, all one path); goldens 23/0 on both
binaries and 0/23 on `/bin/false`; uhdm2rtlil **679/50/2 in both modes with 0
differing rows** against the committed baseline AND against my own pristine
sweep; surelog **0 differing rows over 1588** with an identical nine-way status
histogram — **no row converted, `results/*.csv` not edited**; byte movers
**0/1358** and **2/956**, the two being exactly the Earlgrey databases
PREDICTED BY NAME from the pristine census before the patched sweep ran;
52 + 8 canary rows unchanged, both supplementary canary suites PASS,
`canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0; all five protected databases
byte-identical with `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on
their pins.

## 3c. Boundary

`ARMS.txt` adjudicates every moved arm.

- **WIDE, per file**: `PROCESSED=3530 identical=6756 DIFFERING=14 no_output=290`
- **DIR, per directory**: `PROCESSED=1517 identical=2770 DIFFERING=12 no_output=252`

Every `rc=139` in `BOUNDARY_WIDE.signal` pairs side A with side B — the same
14 pre-existing segfaults on both binaries, no new crash and no new timeout.

## 4. Reproduction

```
g++ -O2 -std=c++17 <rngcen79|dimscan79>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <name>
```

* `RNGCEN79=… PRIS=… PATCHED=… ./arm79.sh <arm.sv> <dir>` — build one arm with
  Surelog and all three binaries (pristine / patched / NEUTRAL), both views,
  census each.
* `score79.py <g.rg> <o.rg> <q.rg>` — the 3-way scorer. **It scores the JUDGE
  HALF only** (everything before ` || SPANS:`); the span tally is printed
  separately and never scored — earl78's rule, and earl60's lesson that a
  span-carrying payload hides a real flip.
* `dimscan79 <db>` — every size-form unpacked dimension bound with its
  judge-visible fields and its span; `dimjoin79.py <g.dim> <o.dim> [--cells]`
  — the EXPR/NAME split and the per-field disagreement tally.
* `DIMSCAN79=… DIMJOIN79=… ./fencescan79.sh <sweep-workdir> <out-prefix>` —
  the corpus census AND the mover prediction. It reads ONLY databases a sweep
  has already produced (golden from the cache path in each test's own
  `cmds.txt`), so it **dispatches nothing** and no test — fenced or otherwise
  — is ever run by it. `FENCED=` lists only.
* `rowheads.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`,
  `canaudit.sh` — the sweep gates.
* `PATCHED_BIN=… PRISTINE_BIN=… PROBE_ROOT=… vwide79.sh <filelist> <out>` and
  `vdir79.sh <dirlist> <out>` — the exhaustive boundary (list on fd 3,
  children `</dev/null`, `PROCESSED` asserted).

No integration, commit, main-tree edit, `results/` edit, stash or fenced-test
dispatch belongs to this pass.

---

## VERIFIER AMENDMENT (r10v79)

The law, the operator table, the size model, the refusals and every
measurement above stand as written and were reproduced bit for bit. One
IMPLEMENTATION detail changed: `dimRedCt79`'s NAME leaf no longer re-walks
`getInitializer()->syntax` re-resolving identifiers in the parameter's own
scope — for an OVERRIDDEN parameter that syntax is the override actual, written
in the INSTANTIATING scope, and a same-named declaration in the instantiated
body captured the re-lookup. It now walks the BOUND initializer expression
(`dimRedCtExpr79`, § dimExprLeafBoundInit79v), which carries the resolved
symbol. Same answers on every cell in both corpora — the Earlgrey databases are
byte-identical either way. See `tools/probe/r10v79repro/README.md`.
