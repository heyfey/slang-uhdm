# r10rgg2 — § compoundLitWriteBackSat2: THE RGGEN WALL, BROKEN

BASE `5c132aa`.  Target: `default:Rggen`'s official `uhdm-cmp` head — ladder
rung 1, the Surelog constant-evaluation SIDE EFFECT that r10rgg1 named,
mechanised and deliberately did not ship.

**RESULT.  Rung 1 is GONE.**  The head moves off
`rggen_or_reducer.sv:30:22` (golden `UINT:0`, ours `UINT:1`) and the ladder goes
**70 → 69 rungs, FIXPOINT**, with the ONLY family change
`constant|VpiDecompile|DIGITS-ONLY` 8 → 7 and no new family.  The whole-corpus
database delta is **TWO FIELD LINES ON ONE OBJECT**.

**Rggen does NOT pass `uhdm-cmp`, and this pass says so up front.**  Rung 1 was
one of 70; the new R0 is a different family entirely (§ 6).

---

## 1. THE MECHANISM (transcribed, then MEASURED on 60+ purpose-built cells)

`UHDM/templates/ExprEval.cpp::setValueInInstance` (~5021, opType tail ~5397):

```cpp
rhsexp = reduceExpr(st->Rhs());        // the tree's OWN object
valUI  = get_uvalue(rhsexp);           // read BEFORE any write
constant *c = any_cast<constant *>(rhsexp);   // === that object
prevRhs = the param_assign holding the Lhs's current value
if (opType == vpiAddOp) c->VpiValue("UINT:" + (valUI + get_uvalue(prevRhs)));
...then a fresh param_assign for the Lhs is pushed with Rhs = c
```

The Rhs literal is overwritten **and** becomes the variable's value object, so
from the second execution on `prev == val` and `a += <lit>` **doubles the
literal**, wrapping at 2^64 (`get_uvalue` does NOT mask by `VpiSize` — see § 3).

### Per-evaluation closed form, verified cell by cell (`b1_rgg2.sv`, `d1_rgg2.sv`)

With `v` = the accumulator's value at the first execution and `I` = executions
of the statement in one evaluation:

| operator | law | golden, measured |
|---|---|---|
| `+=` | `L := (L + v)`, then DOUBLES `I-1` times | I=1→1, 2→2, 3→4, 5→16, 20→524288, 64→0*, 65→0 |
| `-=` | `L := (v - L)`, then **0** from the 2nd execution | 1x→`INT:-2`, 3x→`INT:0` |
| `*=` | `L := (v * L)`, then SQUARES | 1x(v=3)→`INT:6`, 2x→`INT:36` |
| `/=` | `L := (v / L)`, then **1** from the 2nd execution | 2x(v=100)→`INT:1` |
| `%=`, `<<=` | **NO arm exists** → the literal is UNTOUCHED | `2` and `1` as written |

\* the 64-iteration cell reads 0 because of the fold-result re-encode (§ 3), not
because the arithmetic masked: the raw value there is 2^63.

Two `+=` literals on one accumulator interleave exactly as the aliasing
predicts: `a += 1; a += 3;` three times gives golden **14** and **23**, and the
model gives 14 and 23.

### The three SHAPE GATES, each pinned by its own negative cell

| shape | golden | why |
|---|---|---|
| `p[0] += 1` (SELECT Lhs) | literal UNTOUCHED | the bit_select arm REBUILDS `c` before the opType tail |
| `a += K` (parameter Rhs), `a += (1+1)` | literals UNTOUCHED | `c` is a FRESH reduce product |
| `if (n > 100) a += 1` not taken | literal UNTOUCHED | 0 executions |

`a += 4'd1` (a SIZED literal) mutates exactly like the unsized one — there is no
per-size mask.

## 2. THE EVALUATION-COUNT SCHEDULE — MEASURED, AND THEN **REFUTED**

The brief asked for the schedule as a closed form.  `a1_rgg2.sv` measures it
directly with a COUNTER body (`int a; a = 1; a += 1;` — the init literal is a
different object and a plain assign takes no op arm, so every evaluation does
`L := L + 1` and the literal READS `1 + E`):

| cell | shape | E measured |
|---|---|---|
| c1 | 1 instance, 1 call site | **1** |
| c2 | 2 instances, same parametrization | **2** |
| c3 | 2 instances, DIFFERENT parametrizations | **2** |
| c4 | module NEVER instantiated | **0** — there is NO def-view evaluation |
| c5 | 1 instance, TWO localparams calling it | **2** |
| c6 | 1 instance, the localparam READ seven times | **1** — reads do not re-evaluate |
| c7 | 3 instances from a generate-for | **3** |
| c8 | instance ARRAY of 3 | **3** |
| c9 | PACKAGE function + package localparam | **2**, and on the SECOND of the package's two body copies (the def copy stays as written) |
| g1 | nested one module deep | **1** |
| g2 | instance in an UNTAKEN generate branch | **0** |
| g3 | the const-called function calls it TWICE | **2** — CALLS, not sites |
| g4 | the localparam sits inside a `generate` block | **2** |
| g5 | INTERFACE, 1 instance | **1** |
| g6 | localparam + an `always_comb` call | **1** — the non-constant call does not evaluate |
| g8 | 5 instances | **5** |

So `E = instances x const-eval CALLS` — **for a localparam whose value is
demanded once**.  And that is where the model dies.  `vsweep_run.sh` takes the
SAME `rggen_or_reducer` body, ONE instance, and only changes which localparams
consume `SUB_N_LIST`:

| variant (N=25) | golden literal | evaluations implied |
|---|---|---|
| v1 `SUB_N_LIST` alone | `UINT:1` | **0** |
| v2 + an unused `OFFSET_LIST` localparam | `UINT:1` | **0** |
| v3 + an `int`-typed `NEXT_N` localparam | `UINT:72057594037927936` = 2^56 | **51** |
| v4 + `logic [NEXT_N-1:0] next_data` | 2^56 | 51 |
| v6 the full module | 2^56 | 51 |

and at N=20 the same ladder reads `1, 1, 2^44, 0, 0, 0`.

**VERDICT: the evaluation count is NOT a function of the source.**  It is
demand-driven parameter resolution inside Surelog — adding ONE UNUSED
`int` localparam takes the count from 0 to 51.  The brief's premise (a schedule
derivable from call sites / instances / iteration counts) is **REFUTED**, and no
amount of arm work would have produced it.  Only regimes whose value is
**evaluation-count-INDEPENDENT** can be shipped, and there are exactly two.

## 3. THE FOLD-RESULT RE-ENCODE (measured; deliberately NOT shipped)

When the literal is ALSO the object the fold RETURNS (the accumulator is the
function's return variable and this statement is its last writer), the constant
is additionally restamped: `VpiSize` := the **LOCALPARAM's** declared width and
the value truncated to it.  `c1_rgg2.sv` separates the three candidate widths:

| cell | accumulator | localparam | golden |
|---|---|---|---|
| e32 | `int` | `int` | `UINT:2147483648` size **32** |
| e33 | `int` | `int` | `UINT:0` size 32 (2^32 truncated) |
| e64 | `longint` | `longint` | `UINT:9223372036854775808` size **64** |
| e17 | `shortint` | `shortint` | `UINT:0` size **16** |
| e9 | `bit [7:0]` | `bit [7:0]` | `UINT:0` size **8** |
| ew | `int` | `logic [99:0]` | `UINT:4294967296` size **100** |
| el | `int` | `longint` | `UINT:4294967296` size **64** |

so the width is the PARAMETER's, not the accumulator's and not the return
type's.  `b1_rgg2` cell `dtwo` proves the "returned object" clause: of the two
literals, the one that ends up holding `a` gets size 32 and the other keeps 64.
**Rggen's literal is never the returned object** (`get_sub_n_list` returns
`list`), which is exactly why golden's head keeps `vpiSize:64` and
`vpiConstType:9` — and why this pass touches value and decompile only.

This also **corrects two claim errors in `r10rggen9repro/README`**: the
arithmetic is NOT "masked at the literal's own VpiSize" (it wraps at 2^64 and is
re-encoded at the PARAMETER's width, and only for the returned object), and the
64-iteration prediction there (2^63) is right about the arithmetic while the
README's "for64 -> 0" is the re-encode, not a wrap.

## 4. THE LAW

> **§ compoundLitWriteBackSat2.**  A statement-level compound assignment with a
> WHOLE-VARIABLE Lhs and an integer-LITERAL Rhs, inside a function Surelog
> CONSTANT-EVALUATES (called from a parameter initializer in the same
> definition), carries the value Surelog's evaluator left on the literal, not
> the one the source wrote.  Two regimes are count-independent and only they are
> claimed:
>
> **(1) SETTLED, exponent 0.**  Every evaluation executes the statement at most
> once, so `L := L + v` with `v` held in a DIFFERENT object leaves `L`
> unchanged for ANY evaluation count.  Nothing is emitted — the written literal
> is already golden.  *This is why `FuncInModule` and `LogicArrayParam`, which
> hold `get_sub_n_list` VERBATIM at N=4, are `CMP_EQUAL` today and stay so: at
> N=4 the `while` runs exactly once.*
>
> **(2) SATURATED.**  Replaying the corrupted evaluation once per elaborated
> instance, carrying the literal's state, drives an ARRAY SELECT INDEX PAST ITS
> BOUND.  The parameter's fold is then BROKEN, every consumer re-demands it,
> every re-run doubles the literal again, and uint64 doubling reaches the
> **FIXPOINT 0** — which is stable, because with the accumulator pinned at 0 the
> evaluation is well behaved again (`0 + 0 = 0`, index 0 always in range).
> Claimed only when the definition has **>= 2** elaborated instances and only
> for the literal the runaway index was ALIASED to.
>
> Everything else BAILS and keeps the written literal.

> **AMENDMENT (r10vrgg2, the adversarial verifier).**  Regime (2) as written
> above is NOT SUFFICIENT: `escape ∧ >= 2 instances` fires on designs Surelog
> never folds, and 13 legal-SV cells went pristine-right -> patched-wrong (the
> v1 shape at two instances, an unrelated `int` localparam, `$display`, a
> packed-array copy, an `always_comb` call, a second literal, a narrow index, a
> sized literal, a package function).  The shipped regime is now additionally
> gated on the escaping parameter being **DEMANDED** in the measured consumer
> shape — a SCALAR-typed parameter of the same body whose initializer CALLS a
> function with it as an argument (Rggen's own
> `localparam int NEXT_N = get_next_n(SUB_N_LIST)`).  See
> `tools/probe/r10vrgg2repro/README.md` + `GRID.txt` for the 40-cell grid; the
> Rggen database is unchanged to the byte.

Implementation: `SrlgWriteBack` + `computeCompoundWriteBack()` in
`src/ParamEmit.cpp` (a replay of ExprEval's `evalStmt` over the modelled
subset, with Surelog's dropped out-of-range writes and INVALIDATING
out-of-range reads), a `map<SyntaxNode*, uint64_t>` in the exporter, and a
12-line consult at the compound-assignment Rhs in `src/ExprEmit.cpp`.  Keying on
the literal's **syntax** is what makes one entry serve the def view and every
instance copy — golden has ONE shared object.

## 5. THE GRIDS — golden = real Surelog, base and patched side by side

`real/run_real.sh` — the REAL `rggen_or_reducer.sv` at controlled multiplicity:

| cell | golden | base | patched | |
|---|---|---|---|---|
| e2 1x N=2 | `UINT:1` | `UINT:1` | `UINT:1` | ✓ |
| e20 1x N=20 | `UINT:0` | `UINT:1` ✗ | `UINT:0` | **FIXED** |
| e25x2 2x N=25 | `UINT:0` | `UINT:1` ✗ | `UINT:0` | **FIXED** |
| efull 1x25 + 11x2 + 1x20 (= Rggen) | `UINT:0` | `UINT:1` ✗ | `UINT:0` | **FIXED** |
| **e25 1x N=25** | **2^56** | `UINT:1` ✗ | `UINT:0` ✗ | **RESIDUE (§ 7.1)** |

`vsweep_run.sh` — 12 cells: v1/v2 at both N are golden `UINT:1` and stay
`UINT:1` (the law correctly does not fire); v6_n20 is **FIXED** to `UINT:0`;
v6_n25 hits the same over-saturation residue; v3/v4/v5 (6 cells) are the
count-dependent regime and are **NOT CLAIMED** — they keep the written literal,
which is what they already did.

`a1_rgg2` / `b1_rgg2` / `c1_rgg2` / `d1_rgg2` (60+ read positions): the two
binaries' databases are **BYTE-IDENTICAL**.  Not one of those cells escapes an
array bound with >= 2 instances, so the law provably does not reach them.

**There is NO pristine-right → patched-wrong cell anywhere in the five grids.**

## 6. THE NEW R0 — a different family, characterized for the next pass

```
LHS golden: constant  rggen_register_if.sv:10:10-10:23  vpiDecompile:15  INT:15  ct=7
RHS ours  : constant                  :10:10-10:23      vpiDecompile:7   INT:7   ct=7
   parent chain: range < logic_typespec < logic_var(address)
                 < interface_inst(register_if[0]) < u_adapter < u_block_0 < work@rggen
```

`block_0.sv:148` writes `rggen_register_if #(8, 32, 64) register_if[25]();`, and
`rggen_register_if` declares `logic [ADDRESS_WIDTH-1:0] address` with
`ADDRESS_WIDTH = 16` by default.  Golden's member range is **15** — the
interface's OWN DEFAULT — while ours is **7**, the positional override.  Rung 2
is the same law one member over (`value`: golden 31 = `BUS_WIDTH` default 32-1,
ours 63 = the `VALUE_WIDTH` override 64-1).  So the next Rggen pass is:
**a POSITIONAL parameter override on an INTERFACE ARRAY does not reach the
interface's own member declaration ranges in golden.**  7 rungs of the ladder's
`constant|VpiDecompile|DIGITS-ONLY` family sit there, and `rggen_apb_if.sv:7` is
the third site.

## 7. RANKED RESIDUES

1. **Over-saturation at ONE instance.**  `real/e25` and `vsweep/v6_n25`: golden
   leaves a FINITE 2^56 (51 demand-driven re-runs) and the law emits 0.  Fixing
   it needs the count, which § 2 proves is not derivable.  Not a corpus shape —
   the corpus's only escaping design (Rggen) has 13 instances and saturates.
2. **The count-dependent settled regime (`vsweep` v3/v4/v5, `d1` h8/h16/h20,
   `b1` d2/d3/d5/d20/dtwo/…).**  Golden's exact answers are all measured and
   tabulated here; we keep the written literal.  Same blocker.
3. **The fold-result re-encode (§ 3) is not implemented.**  It needs the value
   first, and the value needs the count.  Where it applies, both `vpiSize` and
   the value differ from golden today; this pass changes neither.
4. **`-=`'s saturated fixpoint is 0 too, but `INT`-encoded.**  The code
   deliberately refuses to claim it until a corpus row needs it.
5. **Our instance count for `rggen_or_reducer` is 17, golden's tree has 13** —
   slang folds `NEXT_N` CORRECTLY and therefore elaborates the recursive
   `u_reducer` chain that Surelog's corrupted fold never built.  Irrelevant to
   the saturated regime (only `>= 2` is read) but it would matter to any future
   count model.
