# r10vearl99 — the adversarial verification of r10earl99 (§ `caTernaryArmPatternFlatten99`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of the pass reproduces
bit-for-bit, including both binary md5s. Two **pristine-right → patched-wrong**
cells were convicted on legal SystemVerilog outside the corpus, both fixed here,
both with **zero corpus reach**: the verified binary's databases are
**byte-identical to the shipped candidate's over all 956 surelog and all 1358
uhdm2rtlil databases**. Ship `/tmp/r10earl99.verified.patch`.

The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance
judge; everything in this directory is **MEASUREMENT ONLY**.

---

## 1. Reproduction of the pass, from scratch

Fresh worktrees at `1f9906a`, both binaries rebuilt by the verifier, frozen
`chmod 555` at immutable paths of the **same length**:

| binary | md5 | implementer's claim |
|---|---|---|
| pristine `1f9906a` | `100987bc8d76f2052aa842d7c65c5110` | `100987bc8d76` ✓ |
| `1f9906a` + `r10earl99.patch` | `a93e0f469c1a6444f06c1c41676ef617` | `a93e0f469c1a` ✓ |

Patch: 3156 lines, md5 `551903050d1713834e2302ed5dda2db7`, applies clean on a
fresh `1f9906a` (rc 0, **0 conflict markers**, 38 entries) **and** on main HEAD
`06e1accb` (rc 0, 0 conflicts). Surface = `include/UhdmExporter.h` +
`src/ExprEmit.cpp` + `src/ModuleEmit.cpp` (+143/−20) and
`tools/probe/r10earl99repro/` only; `results/*.csv` untouched; the four
slang-fenced names appear 0/0/0/0.

**Reproduced exactly** (`GATES.r10vearl99.txt` carries the full battery):
heads 31/1 → 31/1 and 36/1 → 26594/1 with a NEW head OBJECT; surelog histogram
471/10 + 466/9 unchanged; u2r 679/50/2 both modes; `ct8rows` PASS on all five
comparisons; canaries `ok=52` / `ok=8`; `canaudit` audited=29 UNCOVERED=0
FENCE-BREACH=0; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`; the Earlgrey
census (calibration golden-vs-golden **0** on 783 183 / 1 061 095 keys)
TO-GOLDEN 4/2, **AWAY-GOLDEN 0/0**, ADDED 1/1, REMOVED 0/4, with **neither
one-sided key set moving by a single key** and every changed key's candidate
multiset equal to golden's.

The **decoded model is correct, read verbatim from the sources**:
`UHDM templates/ExprEval.cpp:759-765` (`flattenPatternAssignments` recursing a
`vpiConditionOp` into `ops[1]`/`ops[2]` and returning),
`Surelog CompileHelper.cpp:5069-5075` (the verbatim twin in
`expandPatternAssignment`), `UHDM templates/NumUtils.cpp:97-104`
(`getMask` saturating at 64 bits), `CompileHelper.cpp:5250-5265` (`adjustOpSize`
stamps, then the shift ≥ 64 returns from the whole function),
`ExprEval.cpp:899-916` (the per-member `VpiSize()==-1` arm).

Two corrections to the write-up, both measured:

* **`byteverify` finds THREE surelog movers, not two.** The third is
  `default/Scoreboard`, which RESUME §9 names as a ~50/50 coin. Attributed
  order-blind: the sorted, path-normalised dumps differ by **0 lines** and the
  unsorted ones by **92** — the documented `svunit_pkg` `vpiTaskFunc` order
  flip. Not a law mover, but a report that says "2 movers and NOTHING ELSE"
  will not reproduce; say "2 law movers plus the coin".
* **R0-testflags is sharper than stated.** It is not "a surplus `struct_var`":
  ours lists `…u_pad.fifo_rdata` **TWICE** in `vpiVariables` (16 entries vs
  golden's 16 → **18**), and golden carries the same object at the same span
  as a `struct_net` under `vpiNet`, not as a variable at all. The failing test
  is the `Variables` vector size, 16 vs 18.

---

## 2. What broke, and how

The law widens a flatten carrier that already existed. Three shapes of *member
value* reach the flatten branch for the first time through a `? :`, and two of
them were being mis-emitted there **before** this pass as well — the direct
carrier already had the same holes, so widening the reach turned two
pristine-CORRECT cells into patched-WRONG ones on ordinary SystemVerilog.
Neither is reachable from either corpus, which is exactly why the pass's own
census and `byteverify` are clean and why only a wide adversarial grid finds
them.

### § `patFlatEnumDecompileRenderV99` — an enum-constant member value

`v99_enum2.sv`, one 6-bit enum, one member of a cont_assign pattern, golden
first, **both carriers, both views**:

| enum member | golden | pristine (ternary) | shipped (ternary) |
|---|---|---|---|
| `Eb = 6'b000111` | BIN, dec `6'b000111` | same | same |
| `Eh = 6'h5` | HEX, dec `6'h5` | same | same |
| `Ed = 6'd3` | INT:3, dec **`3`** | dec `3` ✓ | dec **`6'd3`** ✗ |
| `Ei` (implicit) | INT:4, dec `4` | same | same |
| `Eu = 9` | UINT:9, dec `9` | same | same |

`VpiDecompile` **is** read by `constant::Compare`. The qualified package-enum
fold (`src/ExprEmit.cpp:14635`) copies the shared `enum_const`'s decompile
verbatim; UHDM's `Value::decompiledValue()` re-renders `<size>'<base><digits>`
for **BIN / HEX / OCT only** and prints a decimal value **plain** — the law is
already written out in this repo at `ParamEmit`'s `srlgOvRender`
(`src/ParamEmit.cpp:3198-3206`). So only a **based-decimal** enum member was
wrong, and the direct carrier had been wrong about it since it landed.

**Fix:** inside the flatten's own operand loop, re-render the decompile of an
enum-constant member value from its value encoding. Fenced there: the fold site
itself feeds every qualified package enum read in a module and is not this
pass's population.

**Result:** `v99_enum2.sv` goes from **1 head to `uhdm-cmp` EQUAL in BOTH
views**, on the pristine binary's own shape (the DIRECT, already-landed
carrier) as well as the new one.

### § `patFlatWalkStopsAtNestedPatternV99` — a nested pattern operand

`CompileHelper.cpp:5250-5253` runs `get_uvalue` — which sets `invalidValue` on
an assignment-pattern operation — **before** `adjustOpSize`, and returns from
the whole function right after the stamp. So a nested pattern operand **is**
sized and **nothing after it is**. slang's `tryEval` values a packed nested
pattern happily, so § `patFlatAdjustStopsAtUnvaluable27`'s evaluator test
walked straight past it. Golden, LHS first:

```
v99_nest.sv    '{s1:'{..}, s2:'{..}, c8:d}
   golden  sizes s1's op ONLY (8)
   ours    sized s1, s2 AND the ref_obj d
v99_nest2.sv   '{w4:'1, mid:'{..}, w8:d, w2:2'h1}
   golden  sizes w4 (4) and mid (8), leaves d unsized
   ours    sized d too
```

**Fix:** break the size walk after stamping an operand whose value is an
assignment pattern. The break is placed **after** the size assignment, because
§ 27's own witness (`qi27`'s `be_i`) shows a `ref_obj` that stops the walk still
keeps its stamp.

### Both fixes are +77 lines in `src/ExprEmit.cpp` and nothing else.

---

## 3. What the fixes cost — nothing

* `byteverify SELFCHECK=1`, **verified vs the shipped candidate**:
  `MOVERS 0 / 956` (surelog) and `MOVERS 0 / 1358` (uhdm2rtlil). The two
  corrections change **no database in either corpus**, so every number in §1 —
  heads, census, histograms, canaries, protected DBs — is preserved by
  construction and was re-measured to confirm it.
* Wide boundary, verified vs pristine: **the same 32 differing files, the same
  tally, the same symmetric rc histogram** as candidate vs pristine.
* The pass's own five arms score identically on both binaries, `g4_neg99`
  included (the negative control stays byte-identical).

---

## 4. The adversarial grid

`GRID.r10vearl99.txt` carries the table. 12 arms × 2 views, scored with the
**pass's own arbiter** (`r10earl99repro/ct99cen` + `reg99.py`, whose payload is
exactly the Compare-visible fields), covering:

* every unbased-literal face `'1 '0 'x 'z` × tagged / positional / `default:` /
  nested / replicated members;
* widths 1 / 4 / 32 / 64 / **65** / 128 / a parameterized width / a width from
  an instance override; signed members; a member typed by a typedef and by an
  enum;
* packed and unpacked structs, packed and unpacked arrays, a union, a struct of
  structs;
* an ordinary (procedural) assignment, a continuous assign, a port connection,
  a condition, a concat, a replication, a function argument, a case item, a
  parameter default;
* homes: module / submodule (**3 instances of one span**) / generate scope /
  package function / class method / interface;
* both plain and `-elabuhdm` views on every one.

**SHIPPED: TO-GOLDEN 111, AWAY-GOLDEN 15. VERIFIED: TO-GOLDEN 124,
AWAY-GOLDEN 0.**

Negative controls that must NOT move and do not: a pattern in the ternary's
**condition** position, a pattern under an arm's **arithmetic**
(`v99_faces.sv` `f_cond` / `f_arith`), a procedural pattern, a packed-array
pattern target, `v99_mask.sv` (a direct pattern whose elaborated RHS is shared
from the def view, so the flatten never sees it — **byte-identical on both
binaries**).

---

## 5. Ranked residues the verifier measured and did NOT take

* **R1 — A PARAMETERIZED MEMBER WIDTH TAKES `getMask(1)`, NOT `getMask(W)`.**
  `v99_width.sv` `sub99 #(.W)` `'{pw:'1, q4:'0}`, golden first, on the two
  instances: `pw` is **UINT:1, decompile `1`, at VpiSize 8** (W=8) and
  **UINT:1 at VpiSize 32** (W=32). Surelog's `ExprEval::size` cannot resolve
  the parameterized member on the unelaborated typespec, so the flatten's mask
  is `getMask(1) = 1` and `adjustOpSize` supplies the real width afterwards.
  We write `getMask(W)` = 255 / 4294967295. Pristine was wrong here too (BIN
  `'1`), and the patch fixes VpiConstType and VpiSize while leaving the value
  wrong — **1 of 3 Compare fields still wrong instead of 2**, so it scores
  STILL-WRONG, not AWAY. Its own law, its own census. Reaches the landed
  DIRECT carrier as well. **0 corpus cells** (byteverify: nothing but Earlgrey
  moves).
* **R2 — the pass's own R1/R2/R3** (positional-pattern arm → `adjustUnsized`;
  a nested pattern's inner members not re-typed; a function argument's literal
  → `adjustSize`'s logic arm) are confirmed present and unchanged by the
  corrections; `v99_faces.sv` `f_pos` / `f_nest` and `v99_ctx.sv` `o_arg`
  reproduce them.
* **R3 — a fully-constant direct-carrier pattern never reaches the flatten.**
  `v99_mask.sv` / `v99_mask2.sv` `d_direct`: when the elaborated cont_assign
  RHS is share-with-def cloned, `emitExpr`'s pattern case runs **once**, in the
  def view, with `flat=0` (`R10E27_PATDBG=1` prints 6 lines for 6 CAs and only
  the ternary ones get a `reemit=1` pass). Golden flattens those too
  (`v99_mask3.sv` line 9 golden: UINT `18446744073709551615` at size 65 where
  we leave `'1`). A real, pre-existing gap the ternary law does not touch —
  and the reason `r10earl61repro/v7_v61.sv`'s `>64` `default:'1` cells do NOT
  appear in the wide boundary.
* **R4 — the g22 / l154_noenum LAYOUT artifact** re-confirmed independently:
  the differing cells are `22548185` vs `22552281` (delta exactly 4096) on an
  associative-array typedef's range bound, and **golden carries neither** —
  `grep -c` on golden's dump is 0. Both binaries equidistant. r10uvm154 §7.
* **R5 — the 14 symmetric probe segfaults** (rc 139, 14 per side) are
  pre-existing and `byteverify` proves none is a mover.

---

## 6. What is in this directory

| file | what |
|---|---|
| `v99arm.sh` | the arm driver: BOTH frozen binaries, one source, one view, golden + both dumps, official cmp head depth per side, workdir-normalised |
| `v99_*.sv` | the 12 adversarial arms (faces / widths / types / contexts / homes / masks / enums / nests) |
| `v99lines.py` | a fast whole-dump 3-way line screen — a SCREEN, never the arbiter; the arbiter is `r10earl99repro/ct99cen` + `reg99.py` |
| `GRID.r10vearl99.txt` | the arm table, scored with the arbiter |
| `GATES.r10vearl99.txt` | the full battery, all 11 gates, three binaries |
| `BOUNDARY_WIDE.*` | the wide boundary, shipped and verified, tally + diff + rc-by-side |
