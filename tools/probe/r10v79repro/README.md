# r10v79 — adversarial verification of r10earl79 (§ dimExprBoundFold79)

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's
report reproduces BIT-FOR-BIT — both binaries rebuilt from source to the
claimed md5s, both corpora swept, movers with identical hashes, head logs
byte-identical to the committed evidence. One class of **pristine-right →
patched-wrong on legal SV** survived their arms; it is fixed here
(§ dimExprLeafBoundInit79v) and the fix changes **no corpus byte**.

Ship `/tmp/r10earl79.verified.patch`.

## What reproduced, bit for bit

| claim | verifier's own measurement |
|---|---|
| pristine md5 `9e72c49c…` | rebuilt from `0f3eb2b`: identical, and identical to the main tree's binary |
| patched md5 `30e9ec1d…` | rebuilt from the patch: identical |
| Earlgrey 36 → 64 cmp lines, one head, both modes | reproduced; head logs byte-identical to `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp` |
| the head is a DIFFERENT OBJECT | before: `constant` @126:32 under an `operation`; after: `constant` @12:40 under a `param_assign` |
| u2r 679/50/2 both modes, 0 differing rows | reproduced against the committed baseline AND my own pristine sweep |
| surelog 0 differing rows over 1588, no row converted | reproduced; `results/*.csv` untouched |
| movers 0/1358 and 2/956 | reproduced with IDENTICAL hashes; both predicted by name first |
| census 96 differing cells → 0 | reproduced with my own `dimscan79`/`dimjoin79` on both Earlgrey modes |
| grids g2 504 / g3 120 / g4 84, earl74 g1 30, va2_v74 186 | reproduced under the implementer's binary AND the verified one |
| WIDE 3530/6756/14/290, DIR 12 differing | reproduced and EXTENDED to `.v`: 3598/6892/14/290 and 1525/2780/12/258 |
| `g22.sv` is not this law | reproduced with the neutral `R10E79_OFF=1` binary; the law claims 0 cells there |
| `r10uvm75/76/v109` are the order coin | reproduced: 0 lines once both dumps are sorted; 0 cells claimed |

Numbers and method: `GATES_V79.txt`, `ARMS_V79.txt`, `PREDICT_MOVERS.txt`,
`BOUNDARY_{WIDE,DIR}.{tally,diff,signal}`.

## The defect, and why their arms could not see it

`dimRedCt79`'s NAME leaf answered by re-walking `getInitializer()->syntax` and
**re-resolving its identifiers in the parameter's own scope**. For an
*overridden* parameter that syntax is the override actual, which was written in
the **instantiating** scope. When the instantiated body happens to declare the
same name, the re-lookup finds the wrong symbol and the leaf contributes the
wrong encoding.

It is invisible unless three things line up at once, which is why it needed a
purpose-built arm:

1. the dimension must be an EXPRESSION (`[Z+1]`), so the law fires at all;
2. the override actual must be a NAME that resolves DIFFERENTLY inside the
   child — a shadow (`va6`, `va8`, `va9`) or an unresolvable one (`va5`);
3. **pristine must already be right**, which needs `w0 == 64`. For an
   expression bound `dimPar26` is null, so `wide26`/`ovrNarrow26`/`tsStamp26`
   are all false and pristine's size is `w0`, the bound expression's own bound
   type width — 32 for an ordinary int-flavoured expression. Only a 64-bit
   operand (`longint Z`, or a `64'd1` literal) lifts it, and then the ONLY
   field left to move is `VpiConstType`.

`va8_v79.sv` puts all three together and measures golden `UINT:`/64, pristine
`UINT:`/64 (exact), implementer `INT:`/64 (broken). `va9_v79.sv` breaks it
through a compound override `.Z(UU+1)`. `va7_v79.sv` sweeps the whole 64-bit
family that condition 3 needs, and both binaries score 0 there — the shape is
right, only the shadowed resolution is wrong.

## The fix

`dimRedCtExpr79` — the same operator table, read off the **bound initializer
expression** instead of its syntax. The binder already recorded the resolved
`Symbol&`, so no scope is guessed and the class cannot recur. Same answers,
same abstentions (0), same `vpiUIntConst` fallbacks; `'0`/`'1` stay refused
exactly as the syntax table refuses `UnbasedUnsizedLiteralExpression`.

A first cut kept the syntax walk's depth-8 budget and abstained on
r10vearl74's three-hop derivation chain, scoring `va2_v74` 162 instead of 186.
**Earl74's own committed grid caught that, not the corpus** — the corpus does
not contain the shape. The budget is now 32 (a derivation-chain length, not a
syntax depth) and the based-literal decode is hoisted into `vecBaseCt79` so a
literal leaf costs no recursion level.

The verified binary's Earlgrey databases are **byte-identical** to the
implementer's, so the fix closes a class the corpus does not exercise without
disturbing a single landed cell.

## Instruments

`strict79.py` (per-key |G−O| vs |G−Q|, judge half, spans tallied separately),
`broke79.py` (**the verdict question**: any key pristine got right that the
patch does not?), `vwide79v.sh` / `vdir79v.sh` (boundaries over `.sv` **and**
`.v`, fd-3 list, children `</dev/null`, `PROCESSED` asserted, rc per cell),
`va1..va9_v79.sv` (homes / shapes / size-form control / instance arrays /
cross-scope / shadow / 64-bit / the regression / compound override).

**A trap this pass paid for.** `ls "$d"/*.sv "$d"/*.v` returns NON-ZERO when
*either* glob misses, so the per-directory driver silently skipped every
directory holding only `.sv` — 32 of 6100 cells ran before the
`PROCESSED == LISTED` assertion caught it. Count the files; never let `ls`
with two globs be a boundary's guard.

## Residues the verifier adds (measured, ranked)

- **R-A. The interface DEFINITION-listing over-fold.** Golden leaves an
  interface def-view unpacked dimension bound UNFOLDED (`ref_obj:N`,
  `sys_func_call:$clog2` under the `vpiSubOp`); we fold it to a constant.
  PRE-EXISTING in pristine — this law only changes which wrong constant it is,
  and cannot reach golden because the SHAPE is wrong. 4 declarations × 3 in
  `va1_v79.sv`; the elaborated instances of the same interface all go exactly
  to golden. This is the whole of `va1`'s residual 63.
- **R-B. `[A+B]` where A and B are MODULE PARAMETERS is golden 64, not 32.**
  The implementer's R1 refuses the unprovable add-max and cites earl74's
  `localparam int A/B` witness at 32. `va2_v79.sv` measures the other half:
  with `parameter int unsigned A, B` golden is **64**. The operand size is a
  function of how the parameter's own value got sized, so R1's fix needs the
  parameter's stored size — the same design-final walk
  § dimBoundInheritsParamEnc74 already owns.
- **R-C. `[int'(N)+1]`** (a cast INSIDE an add, as opposed to the implementer's
  R3 cast at the top) abstains and stays at 32 where golden is 64.
- **R-D. The ranged both-bounds unpacked dim's encoding**, in BOTH directions:
  `[N+1:2]` and `[N+1:N-4]` give golden `UINT:` on the LEFT bound and
  `[2:N+1]` golden `UINT:` on the RIGHT, where we give `INT:`. Untouched by
  this law (the range form never reaches `sizeSyn`); 3 shapes × 3 instances in
  `va2_v79.sv`. This is the implementer's R6 with the mirror bound added.
- **R-E. Raw allocation numbers reach a decompile.** `r10buvm22repro/g22.sv`
  renders `UINT:22416825` where the pristine binary renders `UINT:22408601` —
  a pointer-derived value, so ANY binary-size change moves it. earl74's R5;
  it will keep firing the boundary on every future pass until it is fixed.
