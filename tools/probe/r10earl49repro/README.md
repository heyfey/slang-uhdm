# r10earl49 — § caOperandScanRead49

**THE HEADLINE: the 66-line Earlgrey_0_1/default head is CLEARED with EXACTLY
ONE moved cell in a 4.65-million-line database, and the brief's premise —
"golden whole-folds the range expression" — is REFUTED.** There is no range
fold anywhere in this pass. Golden's `UINT:31` is not the module's range
expression reduced; it is a *different typespec object altogether*, minted by
`CompileHelper::setRange` when UHDM's reducer resolves the parameter's NAME.
Which reads reach that resolver is the whole question, and the answer is not a
read *shape* — it is an ordered walk over the top-level operation's operands.

---

## R0 — what the 66-line head actually was

`uhdm-cmp` reported

```
LHS: constant, id:967126, |UINT:31          (no span, no parent)
RHS: operation, id:59152, line:15:20, endln:15:36, vpiOpType:11
       vpiParent: range, line:15:19, endln:15:39
```

and the brief read that as a whole-expression range fold at
`sram2tlul.sv:15`, `parameter logic [top_pkg::TL_AW-1:0] TlBaseAddr = 'h0`.

It is not. Both sides carry the *same* `logic_typespec@15:13-15:39` with the
*same* unfolded `vpiOpType:11` range — in the DEF view, in the elaborated
`vpiParameter` listing, and in the weak tail. The divergence is one edge:

```
module_inst work@sram2tlul
  vpiParamAssign -> param_assign 15:40-15:56
    vpiRhs -> constant 15:53-15:56 (32'h0)
      vpiTypespec -> ref_typespec (work@sram2tlul)
        vpiActual -> GOLDEN: logic_typespec, NO SPAN, range = [UINT:31 : UINT:0]
                     OURS:   logic_typespec, 15:13-15:39, range = operation(op 11)
```

Golden hands that constant a **fresh loc-less `logic_typespec`**; we hand it
the parameter's shared, located declaration typespec, whose range is still the
symbolic `top_pkg::TL_AW-1`. `typespec::Compare` walks into the range, sees
`constant(31)` against `operation(-)`, and that is the head.

We already mint exactly that object — `makeBareVecParamTs` — for 43 other
elaborated cells in this very database. The bug was never the fold. It was the
predicate that decides *when*.

---

## THE LAW

> **§ caOperandScanRead49.** A parameter's ELABORATED `param_assign` Rhs
> constant takes Surelog's loc-less bare typespec exactly when UHDM's reducer
> resolves that parameter's NAME while reducing a continuous assign's Rhs, and
> the reducer resolves names by an **ordered walk over the operands of one
> operation**, not by descending the expression:
>
> * walk the top-level operation's operands **in source order**;
> * a **bare name** operand (`uhdmref_obj`) is *resolved* — and a resolved name
>   with a constant value is REWRITTEN; a bare name **without** one (a net, a
>   variable) **STOPS the walk** at that position;
> * a nested **operation**, a **call**, a **bit-select**, a **hier-path** and a
>   **constant** are **stepped over** — neither resolved nor stopping;
> * anything else — notably a **part-select** — **STOPS the walk**;
> * if nothing stopped the walk, the reducer then reduces the operands, which
>   runs the whole procedure again on each nested operation — **except for a
>   ternary, which reduces its CONDITION and then, only if the condition
>   folded, exactly ONE branch: the taken one.**

Transcribed from `UHDM::ExprEval::reduceExpr`,
`UHDM/templates/ExprEval.cpp:3014` (the `constantOperands` pre-scan), `:3763`
(the `vpiConditionOp` arm's `if (invalidValue) break;`), `:3250` / `:1638` (the
binary and comparison arms, which reduce *both* operands unconditionally), and
`Surelog/src/DesignCompile/CompileExpression.cpp:960` — where `getValue`'s
`instance->getComplexValue(name)` arm calls
`setRange(constant, val, compileDesign)`, i.e. `CompileHelper.cpp:5417`, the
function that builds the loc-less `logic_typespec` with the folded
`[lr:rr]` as bare UINT constants.

The Earlgrey witness is the C1 cell of the grid below, `sram2tlul.sv:44`:

```systemverilog
assign tl_o.a_address = TlBaseAddr | {{(top_pkg::TL_AW-SramAw-SRAM_DWB){1'b0}},
                                      mem_addr,{(SRAM_DWB){1'b0}}};
```

`TlBaseAddr` is operand 0 and it is a bare name, so golden resolves and
rewrites it before ever reaching the concat.

---

## THE GRID — 44 golden cells, all predicted

Every cell below is `parameter logic [W-1:0] X = 'h0` (except where noted),
read in exactly ONE position, measured against real Surelog
(`arm49.sh`, `grid49.py`).

### `c1_earl49.sv` — the read-position truth table

| cell | read position | golden | pristine | patched |
|---|---|---|---|---|
| C1 | `C1 \| {…,n[3:0]}` — bare name is operand 0 | BARE | LOCATED ✗ | **BARE ✓** |
| C2 | `C2 & n` | BARE | LOCATED ✗ | **BARE ✓** |
| C3 | `C3 + n` | BARE | LOCATED ✗ | **BARE ✓** |
| C4 | `(C4==n) ? n : '0` | LOCATED | LOCATED | LOCATED ✓ |
| C5 | `n & C5` — the net stops the walk *first* | LOCATED | LOCATED | LOCATED ✓ |
| C6 | `{C6[3:0], n[W-5:0]}` — part-select operand | LOCATED | BARE ✗ | BARE ✗ (residue R1) |
| C7 | `always_comb r7 = C7 \| n` | LOCATED | LOCATED | LOCATED ✓ |
| C8 | `c ? C8 : n` | LOCATED | LOCATED | LOCATED ✓ |
| C9 | read only as an instance override | LOCATED | LOCATED | LOCATED ✓ |
| C10 | never read | LOCATED | LOCATED | LOCATED ✓ |
| C11 | `C11[W-1:0]` is the whole Rhs | BARE | BARE | BARE ✓ |
| C12 | `C12[k] \| n[k]` in a for-generate | BARE | BARE | BARE ✓ |

### `d1_earl49.sv` — how far the walk goes

| cell | expression | golden | pristine | patched |
|---|---|---|---|---|
| D1a/D1b | `(D1a+D1b) & n` | LOCATED | LOCATED | LOCATED ✓ |
| D2 | `~D2 & n` | LOCATED | LOCATED | LOCATED ✓ |
| D3 | `{D3[3:0],28'b0} & n` | LOCATED | BARE ✗ | BARE ✗ (R1) |
| D5 | `D5 & n & m` = `(D5&n) & m` — `m` stops it | LOCATED | LOCATED | LOCATED ✓ |
| D6 | `n & D6 & m` | LOCATED | LOCATED | LOCATED ✓ |
| D9a | `D9a & n & D9b` = `(D9a&n) & D9b` | BARE | LOCATED ✗ | **BARE ✓** |
| D9b | …nothing stopped the outer walk, so it RECURSES | BARE | LOCATED ✗ | **BARE ✓** |
| R1 | ranged UNTYPED `R1 & n` | BARE | LOCATED ✗ | **BARE ✓** |
| R2 | untyped sized literal `R2 & n` | BARE | LOCATED ✗ | **BARE ✓** |

`D5` vs `D9a` is the pair that proves the recursion is real *and* gated: the
same three-operand chain, and the only difference is whether the outer walk
was stopped by a net before it could recurse.

### `e1_earl49.sv` — where the law REFUTES its predecessor

| cell | expression | golden | pristine | patched |
|---|---|---|---|---|
| E1 | `(n\|m) ? E1 : n` | BARE | **LOCATED ✗** | **BARE ✓** |
| E2 | `(n\|m) ? n : E2` | LOCATED | LOCATED | LOCATED ✓ |
| E3a/E3b | `(n\|m) ? E3a : E3b` | BARE | BARE | BARE ✓ |
| E4/E4b | `cn ? E4 : E4b` — bare-NET condition | LOCATED | **BARE ✗** | **LOCATED ✓** |
| E5 | `E5 ? n : m` | BARE | BARE | BARE ✓ |
| E6 | `$clog2(E6) & n` — a call is stepped over | LOCATED | LOCATED | LOCATED ✓ |
| E7 | `E7[3:0] & n` — part-select operand | LOCATED | BARE ✗ | BARE ✗ (R1) |
| E8 | `32'h1 & E8` — a constant is stepped over | BARE | BARE | BARE ✓ |
| E9 | `n[0] ? E9 : m` — a bit-select is stepped over | BARE | **LOCATED ✗** | **BARE ✓** |

**E1 and E4 refute § caTernOperandRead1 in BOTH directions.** That model said
a ternary reaches its branches only when *both* fold (E1 has one net branch —
golden says BARE anyway) and reaches them regardless of the condition's shape
(E4's condition is a bare net — golden says LOCATED). Neither survives. The
operand walk gets both right for the same reason it gets everything else
right: the walk is positional and it stops at the first unresolvable bare name.

### `b1_earl49.sv` / `b2_earl49.sv` — the bound source is NOT a discriminator

The same six read shapes with the packed range's bound taken from the module's
own parameter (`b1`, `[W-1:0]`) and from a **package** parameter (`b2`,
`[b2p::W-1:0]`) return **identical** answers on both sides, cell for cell.
This kills the first hypothesis this pass formed — that `top_pkg::TL_AW`
being package-scoped is what made sram2tlul special — before a line of code
was written.

### `f1_earl49.sv` — the ternary fence, both halves confirmed by golden

Transcribed from `prim_filter_ctr.sv:54-56`, the Earlgrey shape that the
FIRST cut of this law over-fired on:

| cell | condition | golden | pristine | patched |
|---|---|---|---|---|
| CYCLESM1 | `(filter_i != filter_q)` — two VARIABLES, never folds | LOCATED | LOCATED | LOCATED ✓ |
| TAKEN | `(Cycles > 0)` — folds, so the taken branch IS entered | BARE | **LOCATED ✗** | **BARE ✓** |

`TAKEN` is a second independent fix: it shows the taken-branch recursion is
not merely a guard bolted on to suppress an over-fire — golden really does
enter that branch, and the pristine binary really did miss it.

---

## THE CENSUS PREDICTION, AND HOW IT CAUGHT THE OVER-FIRE

`CENSUS_PREDICT.txt` was written from the PRISTINE pair before the patched
Earlgrey run, off `census49.py`'s span-keyed census of all 10 194 golden /
10 197 ours elaborated `param_assign` Rhs typespec cells. It predicted:

> EXACTLY ONE cell moves — `work@sram2tlul` TlBaseAddr, LOCATED → BARE — and
> no other; the DEF view stays byte-identical; the md5 flips.

The FIRST cut of the law (recursion into every operation operand) measured
**33** moved cells, and re-censusing the patched dump took the design-wide
disagreement count from **79 to 141**. The 32 extra were one family —
`work@top_earlgrey.u_gpio.gen_filter[0..31].filter`, i.e. every instance of
`prim_filter_ctr`, all of them NEW over-fires. The prediction did exactly the
job it exists for: it is what turned "the head cleared, ship it" into "the
head cleared and I broke 32 cells". The `vpiConditionOp` arm was read out of
UHDM's source, fenced by `f1_earl49.sv`, and the re-measurement landed on the
prediction:

| | pristine | first cut | landed |
|---|---|---|---|
| moved cells in Earlgrey/default | — | 33 | **1** |
| golden-vs-ours census disagreements | 79 | 141 | **77** |
| cells that ENTERED the disagreement set | — | 32 | **0** |

---

## Files

| file | what it is |
|---|---|
| `earl49.sh` | one Earlgrey_0_1/default run → `{slang.uhdm, o.dump, cmp.log}` |
| `arm49.sh` | one probe arm, real Surelog on the LHS |
| `census49.py` | span-keyed census of every elaborated `param_assign` Rhs typespec |
| `grid49.py` | per-parameter BARE/LOCATED reader for an arm dump |
| `{b1,b2,c1,d1,e1,f1}_earl49.sv` | the 44-cell grid |
| `a1_earl49.sv` | the REFUTED first hypothesis (package-scoped bound), kept as the R2 residue witness |
| `g1_earl49.sv` | the R3 residue fence: an EXPLICIT-CAST operand takes the classifier's conservative `Stop` exit where UHDM steps over a `vpiCastOp`. Measured cost on the two shapes it can reach: **none** — `W'(G1) & G2` folds whole (both operands constant) so the `tryEval` arm harvests both, and `W'(G3) & n` is LOCATED on both sides because the net stops UHDM's walk anyway. The gap only bites on `W'(G) & P & n`, which no corpus row exhibits. |
| `CENSUS_PREDICT.txt` | the prediction, written before the patched run |
| `sweeps49.sh` `byteverify49.sh` `ct8rows.sh` `canaries.sh` `canaudit.sh` `ctcan2.sh` `bndarms49.sh` `msdist.sh` `shapes49.sh` | the gate harness, carried forward |

## Reproduce

```sh
git worktree add /tmp/wt_r10earl49 <base>
cmake -S /tmp/wt_r10earl49 -B /tmp/wt_r10earl49/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build /tmp/wt_r10earl49/build -j 2
cd /tmp/wt_r10earl49/tools/probe/r10earl49repro
SLANG_UHDM=/tmp/wt_r10earl49/build/slang-uhdm ./earl49.sh /tmp/r10earl49_wd
for a in b1 b2 c1 d1 e1 f1; do
  SLANG_UHDM=/tmp/wt_r10earl49/build/slang-uhdm ./arm49.sh ${a}_earl49.sv /tmp/arm_$a
  paste <(python3 grid49.py /tmp/arm_$a/g.dump) <(python3 grid49.py /tmp/arm_$a/o.dump)
done
```
