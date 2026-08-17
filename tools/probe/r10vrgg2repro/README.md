# r10vrgg2 — r10rgg2's ADVERSARIAL VERIFIER: the schedule model BROKEN, and the gate FIXED

**VERDICT: ACCEPTED WITH A FIX.**  Every headline number in `r10rgg2`'s report
reproduces bit-for-bit from independently built binaries.  Its *law* then broke on
the first shape the brief asked for: **13 of 40 legal-SV cells go
pristine-right → patched-wrong**, because the shipped gate (`escape ∧ ≥ 2
elaborated instances`) is missing the necessary condition that Surelog folds the
parameter **at all**.  The fix is a 60-line **DEMAND GATE** in the same pre-pass.
It keeps every win (Rggen's database is **byte-identical** to the implementer's)
and gives all 13 cells back.

| binary | md5 | grid score /40 |
|---|---|---|
| BASE `5c132aa` | `8e90e5e318029d1336b1c447d9f8356e` | 24 |
| PATCHED (`/tmp/r10rgg2.patch`) | `a3be4c6ccd7aab268a5cd64ca89b31fb` | **20** |
| VERIFIED (`/tmp/r10rgg2.verified.patch`) | `c872259e5c5113959e3d0902271419eb` | **33** |

## 1. What reproduced (independent worktrees, fresh configure, `-j 2`)

Both of the implementer's binary md5s reproduced **exactly**, and so did every
gate number, every canary pin, the ladder, and the one-object dump delta.  The
implementer's schedule table (`a1_rgg2.sv`) was re-measured cell by cell against
real Surelog and is **correct**: E = 1, 2, 2, **0**, 2, 1, 3, 3, and the package
cell's two body copies really do read `1` and `3`.  Their §2 refutation of a
source-derivable count stands, and this pass adds a second, independent
refutation: four consumer shapes of ONE unchanged body at ONE instance count give
**2^38 / 2^44 / 2^50 / 2^56** (`GRID.txt`, cells z5 / z2 / z9 / z3).

## 2. The break

`vsweep` v1/v2 already measured Surelog evaluating the function **zero** times
when the escaping localparam's only consumers are a continuous assign or a
packed-array localparam — golden keeps the written literal there.  The shipped
law never reads that fact: it saturates on `escape ∧ ≥ 2 instances`, and the
instance count is not what decides whether the fold happens.  Instantiate the
**same v1 module twice** and the gate opens on a design Surelog never folds:

```
x1_v1x2_n25   golden UINT:1    base UINT:1 ✓    patched UINT:0 ✗
```

Thirteen such cells are tabulated in `GRID.txt`, including a sized literal whose
**const type** moved too (`DEC:1` → `UINT:0`) and a package function whose two
golden body copies both read `UINT:1`.

## 3. The fix — § compoundLitWriteBackSat2, the DEMAND GATE

> Amendment to regime (2).  The saturated fixpoint is claimed only when the
> escaping parameter is **DEMANDED** in the measured consumer shape: some
> parameter of the same body whose declared type is a **scalar** integral type
> (not a multi-element packed array — element width 1 is the discriminator, the
> same one the replay uses) has an initializer that **CALLS a function with the
> escaping parameter as an argument**.  That is Rggen's own
> `localparam int NEXT_N = get_next_n(SUB_N_LIST)`.  Without such a consumer
> Surelog never folds the parameter, the function is never executed, and the
> literal keeps what the source wrote.

`wbScalarish` + `wbDemanded` + one recorded `escSite` in
`ParamEmit.cpp::computeCompoundWriteBack`.  Consumer shapes that demand the fold
in some *other* way (a direct select, a declaration range, a generate condition)
leave golden a finite, non-derivable power of two, so they are **not claimed** and
keep the written literal exactly as the base binary did.

## 4. The battery, re-run whole on the VERIFIED binary

| gate | result |
|---|---|
| 1 build both `-j 2`, md5 separately | rc=0; base `8e90e5e3…`, verified `c872259e…` |
| 2 goldens / `/bin/false` | **23 / 0** and **0 / 23** |
| 3 uhdm2rtlil both modes both binaries | **679 / 50 / 2**; ct8rows **0/731**, **0/731**, **0/1462** |
| 4 surelog both modes both binaries | **0 differing ROWS / 1588**, three ways; `YosysVerx CMP_EQUAL,match` both modes; `FuncInModule` + `LogicArrayParam` `CMP_EQUAL` |
| 5 byteverify `SELFCHECK=1` | u2r **0 / 1358** (SC 1357); surelog **1 / 953** = `Rggen` only (SC 952) |
| ladder `default:Rggen` | **70 FIXPOINT → 69 FIXPOINT**, only `constant\|VpiDecompile\|DIGITS-ONLY` 8→7, no new family |
| official heads | 1 `^LHS:` before and after; R0 moves off `rggen_or_reducer.sv:30:22` to `rggen_register_if.sv:10:10` |
| boundary arms | 105 committed arms (earl38–53, rgg1, yos1) **byte-identical**; `a1/b1/c1/d1_rgg2` byte-identical across all THREE binaries; rgg1's `grid.sh` identical |

`Rggen`'s verified database is `3605f43ee469` — **the implementer's own patched
hash**, so the corpus win is preserved to the byte.  `Scoreboard` did **not** move
in this verifier's runs, consistent with their nondeterminism attribution.

## 5. Files

`gen_arms.py` writes all 40 cells (`dut.sv` + `top.sv` each); `run_arm.sh` takes
`BASE=`/`PAT=`/`FIX=` and prints the four columns, locating the cell with
`pos.py`; `GRID.txt` is the measured table with the full reading.

## 6. Residues, ranked

1. **Over-saturation on unmeasured consumer shapes** (`z2 z3 z5 z8 z9 z10`):
   golden leaves 2^38…2^56.  Needs the count.  Both binaries wrong; the verified
   one at least does not move the object.
2. **The other compound literals of a saturating body** are corrupted in golden
   too, and not to the fixpoint (`w5` INT:16, `w6` UINT:596).  Unclaimed.
3. **The count-dependent settled regime** and **the fold-result re-encode** —
   unchanged from the implementer's §7.2/§7.3.
4. **A package function's TWO body copies** disagree in golden when it is
   evaluated (a1 cell c9: `1` and `3`); the syntax-keyed stamp writes both.  No
   corpus row and no measured saturating cell exposes it (`wa_pkg_dem`'s golden
   has a single occurrence), but a saturating package function would put one
   object wrong.
5. `y5_sub` is legal SV that **slang** rejects (negative element select folded at
   compile time), so the `-=` fixpoint stays unmeasurable from our side.
