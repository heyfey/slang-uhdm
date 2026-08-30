# r10vearl102 — ADVERSARIAL VERIFICATION of r10earl102 (§ `elabRhsArrayTsSubBoundFolds102`)

**VERDICT: ACCEPT `/tmp/r10earl102.patch` UNCHANGED.** Every headline number
reproduced bit-for-bit from binaries built here; ten fresh adversarial arms over
the bound-face × home × declaration-kind × view matrix produced **zero**
pristine-right → patched-wrong cells. No `.verified.patch` was needed.

Everything in this directory is **MEASUREMENT ONLY**. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

* BASE `091da09`, branch `auto5h`. Verifier worktrees built independently.
* Pristine md5 `2eaa7a60ddb4894e841d4255ec147fa1` (= r10earl101's landed md5,
  so the base is confirmed), patched `6842c35d388cd6458aafc87ceefd6896` — both
  identical to the implementer's. Both frozen `chmod 555` before any sweep.
* `git diff` vs `091da09` in the verifier's own patched worktree regenerates the
  delivered patch **byte-identically** (md5 `ee15f5f7b4ce8ef7bcacf71a02ade60e`).

## What was re-measured, not carried forward

| gate | verifier's own reading |
|---|---|
| goldens patched / pristine / negative | 23/0, 23/0, 0/23 |
| u2r both modes, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| `ct8rows` u2r tf vs committed baseline, tf+def vs own pristine | PASS, PASS, PASS |
| `byteverify SELFCHECK=1` u2r | MOVERS **0 / 1358**, PATH_SETS_IDENTICAL |
| surelog both modes | 471/10 + 466/9, histograms identical binary to binary |
| surelog rows vs committed baseline and vs own pristine | **0 differing rows over 1588** (row-level diff, both) |
| `byteverify SELFCHECK=1` surelog | MOVERS **2 / 956** — the two predicted Earlgrey databases and nothing else (no Scoreboard coin in this run) |
| `rowheads.sh` | Earlgrey 58/62 → **34/34**, both mode logs BYTE-IDENTICAL; SeqDriver 29, SimpleUVM 29, Scoreboard/default 145, MiniAmiq 106, BuildUVMPkg 321, Rggen 0 — unchanged |
| canaries / ctcan2 / canaudit | ok=52 and ok=8 changed=0; PASS ×2; audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected pins | all SAME; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` |
| `cmds.txt` audit BY BINARY PATH | 1458 of 1462 u2r and 1523 of 1573 surelog per side name the frozen pass binaries; **0 of 3035 per side name the main-tree binary** |
| `GOLDEN_DEFER` | unset throughout (explicitly unset in every sweep) |
| Earlgrey determinism | `default` byte-identical over three independent runs on the patched binary (`2ea0cb924f32`) — the mover is real, not a nondeterminism artifact |

**Whole-dump attribution, re-done:** default 191 changed lines (189 law lines +
2 lines that carry the workdir directory name), testflags 207. **Zero** changed
lines outside the nine `pinmux_pkg.sv:20` cells — `work@top_earlgrey.u_pinmux`
and `…u_pinmux.gen_wkup_detect[0..7].i_pinmux_wkup`, one `ref_obj NStraps`
fullname each.

**Head decode, re-done from the pristine cmp log:** `range::Compare` reaches the
RIGHT bound because the LEFT is equal; golden `constant 20:32-20:39` INT:1 / 64
/ ct 7, ours `operation 20:32-20:41` op11(`ref_obj NStraps`, UINT:1 / ct 9). The
58-vs-62 split is exactly the two `vpiActual` lines testflags adds to that
`ref_obj`. The NEW head is golden `int_typespec UINT:1` vs our
`logic_typespec [31:0]`, and its owner was located independently in the
patched dump at `module_inst work@top_earlgrey.u_pinmux > param_assign
53:56-54:59 > Rhs constant 54:22-54:59 > Typespec` — the implementer's R0.

## The wide boundary, run by the verifier

`vwide102_worker.sh` over a COPY of the whole `tools/probe` tree plus these ten
arms: **4627 sources** at any depth, both views, both frozen binaries,
workdir-normalised `uhdm-dump` byte-compare, list on fd 3, children `</dev/null`.

```
PROCESSED = LISTED = 4627    identical 8860   DIFFERING 22   no_output 372
rc by side:  A rc=0 8509  rc=3 358  rc=4 373  rc=139 14
             B rc=0 8509  rc=3 358  rc=4 373  rc=139 14      (symmetric)
```

The 22 are the pass's own `g1/g2/g3/g5/g6` × 2 views and this verifier's
`v1/v2/v3/v5/v7/v8` × 2 views. **`g4_neg102` — the `param_array_wildcard`
shape — does not move, and NO earlier-pass arm moves at all.** The moving arms
are the gate's positive control.

## The adversarial arms (`GRID` / `REGRESSION` files)

Scored with this directory's OWN census (`vcen102.py`): every range bound in the
dump, keyed by the owner chain + the RANGE's span + side, payload
**compare-visible only** (kind, opType, size, constType, decompile, value, and a
`ref_obj`'s name and Actual). `vwrong102.py` then asks the only question that
matters: *is any key right on pristine and wrong on patched?*

**Over all 16 arms × 2 views (10 mine + the pass's 6, rescored independently):
`REGRESSED 0`.** `g4_neg102` moves nothing in either view.

| arm | face | result |
|---|---|---|
| `v1_concat102` | **CONCAT init** (`unpArrConcatTs9` — the OTHER trigger of the same call site, absent from the pass's own arms) on a package parameter and localparam, beside module twins | TO-GOLDEN 3 / AWAY 0 per view; the module twins do not move |
| `v2_dims102` | 2 and 3 dimensions; subtract on the LEFT, on the RIGHT and on BOTH bounds; mixed | TO-GOLDEN 10 / AWAY 0 per view |
| `v3_xpkg102` | package array sized by a package LOCALPARAM; by ANOTHER package's parameter (bare-imported ident and `pkg::N`) | TO-GOLDEN 2 / AWAY 0; the cross-package cells were already golden and are untouched |
| `v4_forms102` | bare `N`, `N+1`, `N*2`, `$clog2(N)`, `$bits(t)-1`, a literal, a nested select `SEL[0]`, `N-M`, `(N-1)`, the SIZE spelling `[N]` | **nothing moves** — none reaches the guarded arm |
| `v5_home102` | interface / class / gen-scope / parameterized module with two overrides / three instances of one span | TO-GOLDEN on the package half; the module-, interface-, class- and gen-scope-owned arrays do not move |
| `v6_neg102` | associative, queue and dynamic dims, the PACKED twin, array vars and nets, a package array typedef | **nothing moves** |
| `v7_kind102` | parameter / localparam / typed / `'{default:}` / replicated `'{N{7}}` / unsized-literal / scalar `bit` | TO-GOLDEN 5 / AWAY 0 per view |
| `v8_mix102` | **the discriminator, re-measured independently**: MODULE and INTERFACE arrays sized by a PACKAGE parameter | golden holds `op11(UINT:3 @32, UINT:1)` there and the patch leaves them alone — the array's OWN home is the discriminator, confirmed |
| `v9_scope102` | `$unit`-scope array parameter; instance ARRAY `u[0:2]`; generate-for span ×3; a package array reached with no import | TO-GOLDEN on every instance and gen copy |
| `va_mixdim102` | **size dim and range dim in ONE declaration** (both `mkBound` paths inside one `makeUnpackedArrayParamTs` call); EXPLICIT `import pkg::NAME`; two instance levels | TO-GOLDEN 3 / AWAY 0; the SIZE dim of the mixed declaration is untouched |

## Residues the verifier measured

* **R1 (the pass's own R1, confirmed).** A MODULE / INTERFACE / CLASS / gen-scope
  unpacked-array parameter's `[0:N-1]` bound is FOLDED BY US and SYMBOLIC in
  golden on the parameter's own `Ranges` and `array_typespec`, both views. It is
  the largest residue in these arms (33 of 114 keys still wrong in `v2`) and it
  is corpus-null. Its exact mirror.
* **R2 / R3 (confirmed).** A package DEF listing folds forms golden keeps in
  syntax; and for the non-subtract forms golden's ELAB encoding is `UINT` at the
  sizing parameter's own width (`v4` `F_BARE`: golden UINT:4 / size 32, ours
  INT:4 / size 64) — which is exactly why the guard is restricted to
  `SubtractExpression`.
* **R4 — NEW, found by this verifier.** `$unit`-scope unpacked-array parameters
  are not emitted by us at all: `v9_scope102:6` `parameter int UARR [0:UN-1]`
  has a golden `parameter(UARR)` with both bounds folded and **no row on our
  side in either view**. Present identically on both binaries; its own law.
* **R5.** Object-count (sharing) differences at these array_typespecs — golden
  prints 18 copies where we print 11 in `v5` — are not compare-visible and are
  identical before and after.
* **R6.** The 14 rc=139 boundary segfaults are symmetric side for side and
  pre-existing (earl82 R6 … earl101 R5).

## Files

| file | what |
|---|---|
| `v1..v9`, `va_*102.sv` | the ten adversarial arms |
| `vgrid102.sh` | arm driver: Surelog golden + one binary, cmp lines and heads, list on fd 3 |
| `vcen102.py` | the independent dump census (compare-visible payload, owner-chain + range-span key) |
| `vscore102.py` | 3-way golden × pristine × patched multiset join |
| `vwrong102.py` | the regression question: keys right on pristine and wrong on patched |
| `vwide102_worker.sh` | the 4627-source wide boundary worker |
| `GRID.r10vearl102.txt` | the per-arm 3-way score |
| `REGRESSION.r10vearl102.txt` | `REGRESSED 0` on all 16 arms × 2 views |
| `BOUNDARY_WIDE.r10vearl102.txt` | the boundary tally, DIFFERING list and per-side rc |
