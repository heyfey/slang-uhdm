# r10earl51 — ADVERSARIAL VERIFICATION (v51)

Verdict: **LAND**. Every headline number reproduced bit-for-bit from independently
configured and built binaries; the law survived seven new adversarial arms; no
cell that the pristine binary got RIGHT is got WRONG by the patched one.

Worktrees `/tmp/wt_v51` (patched) and `/tmp/wt_v51pris` (pristine), both fresh at
4e3ca19, built Release with gcc-toolset-14, `-j 2`, md5 taken separately.

    patched   329fc208b0545f863fcd46f47facaca5
    pristine  a554402b367aeb786bef648638b94e35

byte-identical to the implementer's, from a build this verifier configured itself.

## 1. Numbers reproduced

| claim | verifier's measurement |
|---|---|
| goldens 23 PASS / 0 FAIL both binaries, `/bin/false` 0/23 | reproduced |
| u2r 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both modes both binaries | reproduced (4 sweeps) |
| `ct8rows` u2r testflags vs committed baseline, PRISTINE FIRST | 0 differing rows (pris), 0 (pat); default pris-vs-pat 0 |
| `ct8rows` surelog 1588 rows vs committed | 0 differing rows (pris), 0 (pat) |
| byteverify u2r 1358 paths | **0 movers**; SELFCHECK 1357/1358, SELFCHECK1 = 1 |
| byteverify surelog 953 paths | **1 mover**; SELFCHECK 952/953, SELFCHECK1 = 2 |
| Earlgrey_0_1/default md5 flip | `3d1f57715d76` → `ed708d6cb37c`, **exactly** the reported pair |
| Earlgrey byte-determinism | 2 further independent runs per binary, md5 stable per binary |
| whole-database delta | ONE hunk at line 1221835, `constant UINT:2 sz=2` → `operation , line:42:27` |
| DEF view (1..1196437) md5 | `c69245ac103c` on BOTH — the reported value |
| census 16424 rows/side | pristine **98** → patched **97**, ENTERED **0**, LEFT: `work@sram2tlul 42:10-42:53` |
| head 52 lines/1 head → CLEARED, new head | 52 → 64; new head is the `param_assign` at `67:29` under `work@top_earlgrey.u_rv_core_ibex`, golden `INT:-1 vpiConstType:7` vs ours `BIN:1 decompile 1'b1` — as reported |
| boundary arms | **70 arms, identical=70 differing=0 no_output=0** over r10earl38/45/46/47/48/**49**/**50**repro, re-run from a verifier-owned driver (`vbnd51.sh`) |
| canaries / ctcan2 / canaudit | ok=8 (u2r) ok=52 (surelog) changed=0; ctcan2 ok=1 / ok=58 changed=0; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| InterfaceModPort, BlackParrotComplex, YosysOldOr, SVSwitch | byte-identical, both modes, checked by name |

Two corrections to the record, neither a measurement defect:

* **the Scoreboard "second mover" did not appear here.** In this verifier's sweep
  both binaries produced `b3d565c6db10` for `surelog/default/Scoreboard`, so the
  surelog corpus shows exactly ONE mover, the predicted one. That is independent
  support for the implementer's nondeterminism attribution — and the stronger
  form of it, since the clean run is the one that had to be produced.
* **`CENSUS_PREDICT51.txt` mis-sums its own table**: it lists the span-end-column
  family as `gpio 56/58/79/81` **and** `prim_packer 183` — five cells — but counts
  four, and so predicts `97 → 96`. The measured figures are `98 → 97`, i.e. the
  README's numbers. The prediction file is left UNEDITED on purpose: a prediction
  rewritten after the fact is not a prediction.

## 2. Breaking the law — 7 new arms, ~100 cell readings

`v1..v7_earl51.sv`, read with `vcell51.sh` (golden = real Surelog, one read
position per cell, three columns: golden / pristine / patched).

**No cell anywhere went pristine-RIGHT → patched-WRONG.**

| arm | axis | result |
|---|---|---|
| `v1` | cast in every syntactic position: parenthesised, binary operand, ternary branch, concat operand, nested cast, `$signed`, `$unsigned`, `signed'()`, cast of an expression | 2 FIXED, 0 regressions, **1 under-fire (V-R1)** |
| `v2` | Lhs shapes: part-select OF a member, bit-select OF a member, concat Lhs, member through an ARRAY ELEMENT, UNION member, nested member, generate-block struct | 4 FIXED, 0 regressions |
| `v3` | cast target: package param / module param / localparam / literal / computed width, typedef, enum, packed struct, `int`, `logic` | 10 FIXED, 0 regressions, **1 refutation (V-R2)** |
| `v4` | positions that are NOT a cont-assign rhs: param initializer, range bound, port connection, procedural `always_comb` member assign, plus a DELAYED cont_assign | 3 FIXED; whole-dump delta is exactly 3 hunks, ALL elab cont_assign — the other positions are byte-identical |
| `v5` | over-fire hunt: enum-typed member, typed assignment pattern, `$clog2` operand, REAL operand, ternary operand, same-width literal, net operand, INOUT struct port | 8 FIXED, 0 regressions |
| `v6` | def-view / share axis: module with NO parameters, explicit `wire` struct, plain var struct, two instance views | 3 FIXED × 2 views, 0 regressions |
| `v7` | generate-for body, instantiated INTERFACE, instance ARRAY | 2 FIXED × 2 views, 0 regressions |

Load-bearing negative results — cells where golden FOLDS and the patch correctly
does **not** fire:

* `$signed(LPD)`, `$unsigned(LPD)` and **`signed'(LPD)`** on a member Lhs all fold
  in golden. The implementer's narrow `syntax->kind == CastExpression` test is
  what keeps `signed'()` out; a looser "is a Conversion" test would have been a
  three-cell REGRESSION. Measured, not argued.
* a cast used as a BINARY OPERAND (`SZW'(LPD) | 4'h1`) or as a TERNARY BRANCH on a
  member Lhs folds in golden, and the patch does not fire — the rule really is
  rooted at the rhs, not anywhere inside it.

Structural review, which is why the DEF fence is not luck: `skipGeneralFold` is
read at exactly one site whose only effect is `rhs = (topView && …) ? … : nullptr`,
and the two other guarded sites are already `topView`-gated. The def view cannot
move. Measured too: DEF view byte-identical on all 11 arms and on Earlgrey.

`--single-unit` (the mode Earlgrey itself is compiled in) re-run on `i3`, `v1`,
`v5`: the pristine-vs-patched delta is the SAME cell count as in default mode
(2, 2, 8 cells), with nothing extra.

## 3. Residues this verification adds

* **V-R1 — parenthesised cast is missed.** `assign tl.c1 = (SZW'(LPD));` on a
  member Lhs: golden keeps the operation, we still fold (`v1` line 44; the net
  twin at line 55 folds in golden, so the parens matter only on the member side).
  Slang hands the ConversionExpression a `ParenthesizedExpressionSyntax`, so the
  `syntax->kind == CastExpression` test does not see it. The one-line fix is the
  unwrap idiom already used at `ExprEmit.cpp:2274`. NOT landed: the shape is
  unreachable in both corpora (the law fires ONCE, and that cell is unparenthesised),
  so landing it would add production surface that no gate can falsify.
* **V-R2 — the law's second clause has a counterexample.** "the very same cast on
  a whole-signal Lhs folds too" is true for SIZE casts and ENUM casts but FALSE for
  a TYPEDEF type cast: `assign n1 = v3p::nib_t'(LPD);` on a plain NET Lhs keeps the
  operation in golden (`v3` line 54). Both binaries fold it, so this is
  pre-existing and unmoved — and a candidate law for a later pass.
* **V-R3 — a concat containing a cast folds in golden and not in ours**, on BOTH a
  member and a net Lhs (`v1` lines 47 / 58, `{2'b01, 2'(LP2)}`): the opposite
  direction from this pass, caused by the `paramConcat` rule. Pre-existing.
* **V-R4 — converting a cell to `operation` can expose a DEEPER residue.** In `v3`
  the arm's cmp depth went 52 → 122 lines because the operation we now emit drags
  its typespec into the comparison and the typespec NAME residue
  (`v3p::nib_t` vs `nib_t`) is what cmp then reports. No corpus row moved
  (gates 3/4 are 0/0), but head DEPTH is not a distance and this is why.

## 4. Files

`v1..v7_earl51.sv` — the adversarial arms.
`vcell51.sh` — golden/pristine/patched cell reader (fatal on a missing dump, and
it re-runs Surelog for BOTH binaries and REQUIRES the two goldens to agree, so a
nondeterministic golden cannot silently make a reading meaningless).
`vbnd51.sh` — boundary re-run over all SEVEN boundary directories, arm count
printed per directory so an empty list is visible.
`vsweep51.sh` — the four sweeps for ONE binary, sequential, `--jobs 2`, binary
read back out of each sweep's own `cmds.txt`.
