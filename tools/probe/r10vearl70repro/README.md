# r10vearl70: independent verification and subtraction recut

Verifier verdict: **ACCEPT-WITH-FIX** at base
`efb12c5a4f60d79d538c6f92c68bb3125eaad404`.

The official `uhdm-cmp` remains the acceptance judge.  The depth-keyed census
and grid scorer are diagnostics calibrated golden-vs-golden before use.

## Independent rebuild and target

The verifier created two fresh worktrees at the pinned base, applied
`r10earl70.patch` only to the patched one, configured both independently, and
built each with `-j 2`.  The frozen pristine binary was
`7c3806fb1091b41a13b4e9017b6cb64a`; the inherited candidate was
`560d2e1af44deabc08f684b49ac8cb3f`; the verifier recut was
`0c87d36d077b34cb516e14d82afbbe29`.

The pristine official comparator result was 50 lines and one head in each
Earlgrey mode at `flash_phy_rd.sv:143:22-143:31`: golden keeps the located
`BankAddrW` ref bound to a fresh locless enum constant, while pristine folds it
to `UINT:16` with an int typespec.  The recut produces 46 lines and one head in
each mode, byte-identical comparator logs to the inherited candidate.  The new
R0 is the deliberately unclaimed direct right bound `LsbAddrBit` at
`143:34-143:44`: golden ref/enum constant versus our `UINT:1`/int typespec.

## Finding and production fix

The inherited guard accepted every immediate operation parent.  `v3_ops70.sv`
crosses arithmetic, shifts, bitwise operators, comparisons, conditional,
unary operators, casts, nested expressions, aliases, and both parameter
positions.  In the elaborated view the inherited candidate produced 32
MOVED-WRONG cells: 16 under XOR, eight under unary plus, and eight under
bitwise negation.  These are duplicate elaborated refs later rebound to the
importing module parameter where golden folds the corresponding copies.

The production guard is therefore recut to `vpiSubOp`.  This is the smallest
measured slice that clears the corpus head.  `v4_sub70.sv` then crosses both
operand orders, both range-bound positions, nested subtraction, and positive
and negative enclosing results: 64 TO-GOLDEN cells in each view, zero
AWAY-GOLDEN and zero MOVED-WRONG.  The recut also makes the broad operator
counterexample regression-free, retaining only its 24 subtraction cells per
view.

## Grid

The implementer grids were regenerated from source with fresh Surelog,
pristine, and recut databases.  Their exact results are unchanged:

| arm | plain TO-GOLDEN | elab TO-GOLDEN | away/wrong |
|---|---:|---:|---:|
| `g1_earl70.sv` | 64 | 64 | 0 |
| `g2_earl70.sv` | 48 | 48 | 0 |
| `g3_enc70.sv` | 88 | 88 | 0 |

The verifier arms vary qualified/unqualified package symbols, package
parameters and localparams, module parameters and locals as refusals, direct
versus operation bounds, left and right range positions, indexed selects,
generate-for/if/case/nesting, legal instance arrays, signed and unsigned
types, based and expression encodings, unary/binary/cast/conditional forms,
and both ordinary and elaborated output views:

| arm | inherited plain/elab | recut plain/elab | away/wrong after recut |
|---|---:|---:|---:|
| `v1_axes70.sv` | 80 / 80 | 40 / 40 | 0 |
| `v2_encoding70.sv` | 240 / 240 | 120 / 120 | 0 |
| `v3_ops70.sv` | 216 / 216 plus 32 elab wrong | 24 / 24 | 0 |
| `v4_sub70.sv` | 64 / 64 | 64 / 64 | 0 |

Compiling all four verifier arms as one unit yields 5,027 diagnostic cells in
the plain view and 7,795 in the elaborated view.  Both views have exactly 248
TO-GOLDEN cells and zero away/wrong, proving that the arms do not become a
self-confirming set only when compiled separately.

## Corpus census and movers

The independently regenerated corpus census exactly reproduces the candidate
headline:

| mode | cells | STILL-RIGHT | STILL-WRONG | TO-GOLDEN | away/wrong |
|---|---:|---:|---:|---:|---:|
| default | 531489 | 508206 | 23251 | 32 | 0 |
| testflags | 811229 | 770377 | 40820 | 32 | 0 |

Golden-vs-golden calibrations were 521,401 and 799,038 cells respectively,
all STILL-RIGHT.  The predicted and observed Surelog movers were exactly:

- `default/Earlgrey_0_1-71da2fd7/slang.uhdm`
- `testflags/Earlgrey_0_1-71da2fd7/slang.uhdm`

Path sets were identical: two movers among 956 Surelog paths, zero among 1,358
uhdm2rtlil paths.  Comparator negative controls flagged 955/956 and
1,357/1,358 paths.

## Full gates

- Surelog: 1,588 rows, every status/dump field byte-identical to the committed
  baseline.  Default has 470 equal comparable rows and 11 unequal rows;
  testflags has 466 equal comparable rows and nine unequal rows.
- uhdm2rtlil: 731 rows per mode, 679/679 comparable rows official-CMP equal in
  both modes, and committed-baseline parity exact.
- Golden dumps: 23/23 pass; `/bin/false` produces 23/23 failures.
- Named canaries: Surelog 52 unchanged and uhdm2rtlil eight unchanged.
  Supplementary canaries: 58 and one unchanged.  The clean-directory coverage
  audit reports 29 protected names/families, zero uncovered, zero fence
  breaches.  No fenced test was dispatched.
- Protected database rows have zero byte movers.  External pins remain
  `SVSwitch=4842211c40304b44fbb046201ec0287e` and
  `YosysVerx=6ccda350c24a83cebc9ca4a7b6e505cf` in both modes.

## Exhaustive boundary

The boundary scripts were changed only to permit a verifier-owned `STAGE`
override; their default paths remain unchanged.

| walk | listed/processed | identical | differing | no output | signals |
|---|---:|---:|---:|---:|---:|
| every `.sv` file | 3158 / 3158 | 6032 | 14 | 270 | 20 symmetric |
| every unique directory | 1450 / 1450 | 2659 | 8 | 233 | 10 symmetric |

The 14 file differences are exactly g1/g2/g3 and v1/v2/v3/v4 in both views.
The eight directory differences are the implementer and verifier reproducer
directories in both views plus `r10uvm75repro` and `r10uvm76repro` in both
views.  The four UVM differences are pre-existing ordering only: sorted
normalised dumps compare byte-identically.  The verifier reproducer directory
was scored as one unit against fresh golden databases as described above.
Every signal event is symmetric between pristine and recut; there is no new
crash, timeout, no-output cell, or non-golden substantive mover.

## Reproduction

Use the implementer tools in `../r10earl70repro/` to build `tscen70.cpp`, run
`earl70.sh`, `runarm70.sh`, `armscore70.sh`, `cen70.sh`, `nospan70.sh`, the
row/byte/canary gates, and the two boundary drivers.  This directory supplies
the four adversarial SystemVerilog arms and the verifier's decoded result.
