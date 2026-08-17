# r10rgg7 — THE GOLDEN GRID for § genIfUnvaluedFuncParam7

63 cells, `gen_grid.py`, every one run against **REAL SURELOG** (`-parse dut.sv
-mt 0 -mp 0`, verify_golden.py's `default` argv for a one-source test) and
against both slang-uhdm binaries.  `armscan.py` reads WHICH ARM each side
elaborated; `score.py` joins the three sides; `verdict.py` classifies
order-blind.

Both arms of every cell are named **`g_reduce`**, exactly as `rggen_or_reducer`
names them, and are told apart by CONTENT (`a_mark` / `b_mark` / a `leaf`
instance) — never by the scope name.

## The verdict

```
DEF   OK      63          (no cell emits a gen scope in the DEF listing, both sides)
ELAB  FIXED   37
ELAB  OK      45
TOTAL rows=145  BROKEN=0   MISSING-SIDE rows=0
```

Base agreed with golden on 45 of 82 ELAB rows; patched agrees on **82 of 82**.

## What each family decided

| family | cells | golden's arm | reading |
|---|---|---|---|
| `p_pat_n{1..25}` a POISONING const function over a PLAIN VALUED pattern array — no saturated write-back anywhere | 7 | **ELSE** at every N (N=1 agrees with slang anyway) | the refused reduction, NOT the r10rgg2/r10rgg5 saturated regime, is the discriminator |
| `s_sat_n{1,2,4,5,8,20,25}` the full Rggen `get_sub_n_list` + `get_next_n` pair | 7 | ELSE | same answer, so the sat machinery adds nothing to this law |
| `m_sat_*` 2 and 13 instances, orders 25/2, 2/25, 25/25, 20/25 | 5 | ELSE at every instance | instance count is not an axis |
| `k_*_gt1 / ne1 / bare` | 6 | ELSE | **it is the CONDITION that is FALSE**: `NEXT != 1` and a bare `if (NEXT)` would both be TRUE if the identifier merely read 0 |
| `k_*_eq1 / lt1 / eq0` | 6 | ELSE (slang agrees) | no separation, but no break either |
| `a_*_{for,inst}` arm holds a generate-for / a real `leaf` instance | 4 | ELSE | the arm's CONTENT is irrelevant |
| `p_chain_n8` `NEXT = RAW + 0` | 1 | ELSE | the valuelessness is TRANSITIVE through a parameter read |
| `x_argchain_n8` `NEXT = addup(RAW)`, `addup` FOLDS | 1 | ELSE | ...and through the ARGUMENT of a folding call |
| `x_pkgfunc_n8` the refused function lives in a PACKAGE | 1 | ELSE | reach is not limited to the module body |
| `p_noarg_n8` refused function with NO argument | 1 | ELSE | — |
| `y_declparam_n8` function body declares a LOCALPARAM | 1 | ELSE | the `subroutineDeclaresParam` bail counts |
| `y_unevalarg_n8` argument `$floor` (outside ExprEval's system-call repertoire) | 1 | ELSE | the `unevalArg` bail counts |
| **`y_mdpacked_n8`** a MULTIDIM PACKED parameter whose function FOLDS | 1 | **slang's arm (A)** | *** the `packedDimCount >= 2` clause — which ALSO keeps the Rhs symbolic — must be EXCLUDED from the predicate.  Surelog still HAS the value; it just never rewrites the Rhs object. |
| CONTROLS `c_plain / c_fold / c_clog2 / c_ownN / c_pkg` at N ∈ {1,2,8,25}, `m_plain_8_2`, `m_fold_8_2` | 22 | slang's arm, every one | a parameter Surelog CAN value keeps slang's arm; `c_fold` is the one that matters most — a `func_call` Rhs PER SE does not make a condition false, the REFUSED reduction does |

## The traps this grid paid for

* `a_pat_inst`'s first form instantiated `sub` itself in the if arm.  In the
  pattern family `NEXT` does not shrink with `N`, so that is an infinitely
  recursive instantiation: slang produced **no database at all** (`NOSLANG`,
  printed and COUNTED by `run_grid.sh`) while Surelog produced one.  The arm now
  instantiates a separate `leaf` module.
* `armscan.py` exits 3 on a dump with zero `sub` instances and `score.py` counts
  MISSING-SIDE rows, so a cell that measures nothing can never read as
  agreement.
* The sat family is written with **symbolic `N`** (`bit [N-1:0][15:0]`, `i < N`),
  exactly as `rggen_or_reducer` writes it, so one definition serves instances of
  different N; the pattern family keeps literal counts because its `'{...}`
  initialiser has a fixed element count.
