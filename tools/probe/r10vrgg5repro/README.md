# r10vrgg5 — adversarial verification of r10rgg5 / § satArrArgFirstElem5

**MEASUREMENT-ONLY directory**, plus the ONE production fix this verification
forced. The official `uhdm-cmp` remains the sole acceptance judge. BASE `39d8bb3`.

## Verdict

**ACCEPT WITH A MANDATORY FIX (shipped here).** Every headline number in the
implementer's report reproduced bit-for-bit, including both binary md5s. But the
law as shipped was **pristine-right → patched-wrong on three legal-SV shapes**
(12 dump objects), because `SrlgWriteBack` stops at the escape while Surelog's
evaluator runs the body to completion. The fix is a four-clause shape gate in
`wbReturnedArraySym`; with it the 32-cell grid comes back **byte-identical** to
the shipped patch's, the Rggen database is **byte-identical** to the shipped
patch's, and the three breaks are gone.

## What reproduced, bit-for-bit

| claim | implementer | verifier |
|---|---|---|
| base binary md5 | `c12479be81b3f9d27e3ac3d1c65385fc` | same |
| patched binary md5 | `86c714f4d3d9f2918a7cef833e719d84` | same |
| Rggen head cmp lines | 64 → 17, 1 head | same |
| ladder rungs | 61 → 60 FIXPOINT, one family `constant\|VpiDecompile\|DIGITS-ONLY` 1→0 | same |
| 32-cell grid raw | — | **byte-identical** re-run |
| grid verdict | FIXED 52 / BROKEN 0 / MOVED-WRONG 38 / STILL 23 / OK 23 | same |
| Rggen census | DEFICIT 26 → 12, FIXED 14 | same |
| Rggen dump delta | 134 line-sides, 24 constants, 19 sizes (13× 32→400, 2× 80, 2× 112, 2× 320) | same |
| u2r / surelog gates | 679/50/2; 0 ct8rows over 1588 and 1462 | same |
| byteverify | u2r 0/1358; surelog 2/955 | same |
| Scoreboard mover = nondeterminism | 3 base runs, 2 md5s | **5 base runs, 2 md5s**, one of them the "patched" db |

`GATES.txt` has every leg's numbers.

## The defect, and the three cells that prove it

See `GRID.txt`. In one line: `SrlgWriteBack` sets `invalid` at the runaway index
and abandons the body, so `arrState()` returns the array **as it was at the
escape**. Golden does not stop there — `v4_single` shows Surelog carrying a write
that happens *after* the escape into the returned array. Cells:

* `v4_single.sv` — a second local array written only after the escaping loop, and
  the single `return`: golden 9, base 9 (**right**), shipped patch **0**.
* `v3_retlast.sv` — the same body plus an unreachable earlier `return list;`: the
  first-return scan picks the wrong array; golden 9, base 9, shipped patch **4**.
* `v8_postzero.sv` — one array, re-`'0`ed and rewritten at index 0 after the loop:
  golden 10, base 10 (**right**), shipped patch **4**.
* `v7_post.sv`, `v6_revamb.sv` — same mechanism, base already wrong (moved-wrong).
* `v5_retlist.sv` — the price of the stronger gate: one FIXED reading given up.

## The width / order claim survived every attack

`w1_wrap.sv`, `w2_wrap2.sv`, `w3_genloop.sv` put the reducer instances in orders
the 32-cell grid did not contain — one nested a level deeper than its sibling,
the mirror of that, and a generate-for with `N = 9, 25, 2`. Golden's shared width
followed **our `getRoot()` DFS order** in all three (32 / 400 / 144), never the
widest instance. `w1`/`w2` are net FIXES.

## Argument shapes the law must not touch

`x1_argshapes.sv` carries, in a body that IS in the saturated regime, a literal
actual (`h(4)`), a scalar-localparam actual (`h(K)`), the escaping parameter at
call depth 2 (`get_next_n(id(SUB_N_LIST))`) and a packed-array COPY of it
(`get_next_n(COPY)`). Base == patched == fixed on every one of them. It also
independently re-proves the count wall: with those extra consumers golden moves
both N=25 instances from E0=4 to **Z=3**, so the shipped law is wrong there —
but so is base, so nothing regresses.

## Files

| file | what |
|---|---|
| `v3..v8`, `w1..w3`, `x1` | the cells (`run1.sh` self-contained, `run2.sh` adds the real `rggen_or_reducer.sv`) |
| `argc.py` | r10rgg5's `argconst.py` with the callee name parameterised |
| `GRID.txt` | the measured tables, the defect, the fix, the ranked residues |
| `GATES.txt` | every gate leg, every mover named and attributed |
| `HEAD_{BASE,FIXED}_default_Rggen.cmp` | the official `uhdm-cmp` head, both sides |
| `ladder_{BASE,FIXED}_default_Rggen.txt` | the measurement-only ladders (61 → 60) |
| `BOUNDARY.txt`, `FOLDBND.txt` | rgg2 / vrgg2 / fold-law boundaries, BASE vs FIXED |
| `VERDICT_rgg5grid_with_fix.txt` | the r10rgg5 32-cell verdict with the fix in |

## Guards these drivers carry

* `run1.sh`/`run2.sh` print `NO-DATABASE` and `NO-CALL` and count them; `argc.py`
  exits 3 on a dump with zero calls, so a vanished object reads as a missing line
  and never as agreement.
* The scoring join classifies a key present on only one side as GOLD-ONLY /
  OURS-ONLY instead of folding a shape divergence into the value verdict.
* The Scoreboard attribution was re-derived from FIVE runs of the BASE binary
  alone, not from the implementer's note.
* Every boundary arm was re-run with its POSITIVE CONTROL on (`CTRL=1`):
  rgg2byte 12/12, foldbnd 47/47.
