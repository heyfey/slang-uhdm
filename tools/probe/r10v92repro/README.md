# r10v92 — adversarial verification of r10earl92 (`§ elabCaTernaryArmInstall92`)

**VERDICT: ACCEPT-WITH-FIX.** The law is right, the head clears, every corpus
number reproduces bit-for-bit — and the shipped patch contained ONE
pristine-right → patched-wrong regression on legal SystemVerilog, with **zero
corpus cells**, which the corpus gates therefore could not see. The fix is 33
lines in the same predicate; ship `/tmp/r10earl92.verified.patch`.

Base `c366a17`, branch `auto5h`. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; every
instrument here is MEASUREMENT ONLY.

---

## 1. Reproduction of the implementer's headline numbers

Both binaries rebuilt from scratch in fresh worktrees, frozen `chmod 555`
before any sweep, every `cmds.txt` audited BY BINARY PATH.

| claim | implementer | verifier | |
|---|---|---|---|
| pristine md5 | `ab9cbe4ad906` | `ab9cbe4ad906` | SAME |
| patched md5 | `06a37a88d3f5` | `06a37a88d3f5` | SAME |
| goldens, both binaries | 23 PASS / 0 FAIL | 23 PASS / 0 FAIL | SAME |
| `/bin/false` negative control | 0 PASS / 23 FAIL | 0 PASS / 23 FAIL | SAME |
| u2r, both modes, both binaries | 679 / 50 / 2 | 679 / 50 / 2 | SAME |
| surelog, both binaries | 937 / 567 / 48 / 19 / 10 / 3 / 2 / 1 / 1 | identical | SAME |
| `ct8rows`, both corpora, both columns | 0 differing rows | 0 differing rows | SAME |
| `byteverify` u2r | 0 / 1358 | 0 / 1358 | SAME |
| `byteverify` surelog | 2 / 956 predicted | **3 / 956** — the 2 predicted **plus Scoreboard/default** | see below |
| `Earlgrey_0_1` head, default | 250 → 64, 1 head | 250 → 64, 1 head | SAME |
| `Earlgrey_0_1` head, testflags | 278 → 64, 1 head | 278 → 64, 1 head | SAME |
| the two modes' head logs identical | yes | yes | SAME |
| every `HEAD_{BEFORE,AFTER}` log | committed | byte-identical (paths normalised) | SAME |
| canaries / ctcan2 / canaudit | 52 / 8 / PASS / 29-0-0 | identical | SAME |
| protected DB pins | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | identical | SAME |

**The third surelog mover is the KNOWN COIN, not a missed one.**
`Scoreboard/default` moved in this verifier's run; the path-normalised
ORDER-BLIND dump diff (both dumps `sort`ed) is **0 lines**, so it is the
svunit_pkg `vpiTaskFunc` ordering coin RESUME §9 documents, not this law. The
implementer's run happened to land the same face twice; a null read there is
luck, not evidence, and neither reading changes the verdict.

`cmds.txt` audit: 1462 (u2r) + 1573 (surelog) per binary, **0 naming the
main-tree binary**, 1458 / 1523 naming the frozen path under test.

## 2. R0 re-decoded independently — CONFIRMED

`prim_lfsr.sv:39`, `parameter logic [LfsrDw-1:0] DefaultSeed = LfsrDw'(1)` in
`work@top_earlgrey.u_aes.aes_prng.aes_prng_lfsr` with `LfsrDw == 64`: golden
`UINT:0`, ours `UINT:1`, `vpiSize 64`, `vpiConstType 9`, every other field
matching. The mechanism is at `UHDM templates/ExprEval.cpp:4170` (the
`vpiCastOp` / `uhdminteger_typespec` branch):

```cpp
uint64_t mask = ((uint64_t)(1ULL << cast_to)) - 1ULL;   // cast_to == 64 -> UB
uint64_t res  = val0 & mask;                            // 1ULL<<64 == 1 on x86-64
```

so `mask` becomes 0 and `res` becomes 0. Golden is the spec, bugs included.

---

## 3. THE REGRESSION — `kindOf92` never walked an `ElementSelect`'s base

### 3.1 What breaks

```systemverilog
package mp;
  typedef struct packed { logic [3:0] m1; logic [3:0] m2; } st_t;
endpackage
module m1 #(parameter bit EN = 1) (input mp::st_t s, output logic y);
  assign y = EN ? s.m1[0] : 1'b0;
endmodule
```

The elaborated `cont_assign`'s `Rhs`, straight out of `uhdm-dump`:

| | Rhs |
|---|---|
| golden (real Surelog) | `operation … vpiOpType:32` — the ternary SURVIVES |
| pristine `c366a17` | `operation … vpiOpType:32` — **RIGHT** |
| patched (as shipped) | `hier_path: (s.m1[0])` — **WRONG** |

`cont_assign::Compare` reads `Rhs`, and `Rhs->UhdmType()` differs, so this is
compare-visible, not a naming or parenting residue.

### 3.2 Why

`kindOf92` maps `ExpressionKind::ElementSelect` to `OK92::Select`
**unconditionally**, while the `RangeSelect` arm right below it DOES walk to
its base. But `ExprEmit` mints a **`hier_path`**, not a `bit_select` or a
`var_select`, whenever an element-select chain bottoms out on a member or a
hierarchical reference — and a bare `hier_path` arm is one of the two shapes
the implementer's own README says REFUSES: `reduceExpr`'s `uhdmhier_path`
branch (`ExprEval.cpp:4721`) hands back `decodeHierPath(…, ReturnType::VALUE)`
== `nullptr` for a signal read, and `writeCont_assign`'s
`(invalidValue == false) && rhstmp` (`UhdmWriter.cpp:2153`) then refuses the
write-back entirely, so golden keeps the whole ternary. The fence was stated
correctly and implemented for the BARE `MemberAccess` / `HierarchicalValue`
form only; the selected form fell through it.

### 3.3 The mint, measured (`vs1_shapes.sv`, real Surelog, both views)

| arm | our mint | golden | patched |
|---|---|---|---|
| `mem[1]` | `bit_select` | installs the arm | correct |
| `w[3]` | `bit_select` | installs the arm | correct |
| `mem[1][0]` | `var_select` | installs the arm | correct |
| `mem2[0][1][0]` | `var_select` | installs the arm | correct |
| `w[7:4]` | `part_select` | **keeps the ternary** | correct (not whitelisted) |
| `s.a.m1[0]` | **`hier_path`** | **keeps the ternary** | **BROKE** |
| `u.arr[0]` | **`hier_path`** | **keeps the ternary** | **BROKE** |
| `u.mem[1][0]` | **`hier_path`** | **keeps the ternary** | **BROKE** |

### 3.4 The fix

`src/ModuleEmit.cpp`, inside `kindOf92`, +33/−1: the `ElementSelect` case now
walks its base chain exactly as the `RangeSelect` case does and returns
`OK92::HierPath` when it lands on a `MemberAccess` or a `HierarchicalValue`.
Nothing else changes. The operand GATE is unaffected — `hier_path` is on
`constantOperands`' whitelist just as `bit_select` and `var_select` are, so the
only behaviour that moves is the arm-INSTALL decision, and only for the three
shapes above.

### 3.5 Why the corpus could not catch it

`byteverify` FIXED-vs-PATCHED over the surelog corpus: **0 / 956 movers**;
over uhdm2rtlil: **0 / 1358**. The regression has **zero corpus cells**, so
every corpus gate, every census bucket and every head count is identical
before and after the fix. This is precisely the corpus-invisible class RESUME
§9 says only a purpose-built grid and the wide boundary convict.

---

## 4. The adversarial grid (`ARMS.r10v92.txt`)

24 arm-runs (12 sources × plain and `-elabuhdm`), each built with real Surelog
and with all THREE frozen binaries, censused with `ct92cen`, one line per
`cont_assign` cell, agreeing cells counted in the denominator.

```
                BROKE   FIXED   SAME   DIFF-UNMOVED   DIFF-MOVED
patched  (ship)    12      68     82             23            2
fixed    (this)     0      68     94             23            2
```

Faces measured, all against real Surelog:

* **conditions** — bare parameter (true and false), localparam, an expression
  of two parameters, `P == 2`, `$clog2(P)>2`, a package parameter, a user
  constant function, a package constant function, a string compare, a real
  compare, a 96-bit condition, an X-valued and a Z-valued constant, a genvar
  inside gen-for, a nested ternary, a `$countones` `ExprEval` does not
  implement, and a non-constant signal. **The last four keep the ternary in
  golden and in both our binaries** — the fences hold.
* **arms** — selects, concatenations, replications, casts, shifts, reductions,
  user `func_call`, `$signed`, `$clog2`, streaming, `inside`, an enum port
  read, assignment patterns, `'0`, `'1`, a string, an X constant, a
  non-constant bit index, an unpacked-localparam select, a 2-D localparam
  select, a nested ternary in either arm, and a ternary as an operand of a
  larger op.
* **Lhs / homes** — whole signal, net-decl-assign, procedural assign, an
  `always` block, an `initial` block, a function body, a port `High_conn`, a
  parameter initializer, an unpacked-array element; module, interface,
  gen-for, gen-if, named gen-block, a 3-deep chain, a `bind` instance, and
  three instantiations from ONE span with different overrides.
* both views, 1–3 instances, `defparam`-shaped overrides.

The two `DIFF-MOVED` cells (`v8_gen` `--elabuhdm`, and the earlier-pass
`f1_earl49` `taken_d`) are the pre-existing DUPLICATE-ELAB-COPY residue: golden
carries one DEF row and one ELAB row, we carry one DEF and TWO ELAB. After the
patch **both** of our elab copies carry golden's exact fingerprint where before
one carried the unfolded ternary — every moved row moved ONTO golden's value,
and the same cell scores a clean `FIXED` in the plain view. TOWARD-GOLDEN,
0 AWAY.

The 23 `DIFF-UNMOVED` cells are pre-existing residues the patch does not touch
(the poisoning-constant arm, the gen-for condition substitution, the
concat/member Lhs elab copies, the assignment-pattern arm).

---

## 5. Gates on the FIXED binary — all green

* goldens **23 PASS / 0 FAIL**; `/bin/false` **0 PASS / 23 FAIL**.
* u2r **679 / 50 / 2** both modes; `ct8rows` **0 differing rows** vs the
  committed baseline AND vs this verifier's own pristine sweep, status AND
  dump column. `byteverify` **0 / 1358**.
* surelog **937 / 567 / 48 / 19 CMP_NOTEQUAL / 10 / 3 / 2 / 1 / 1**; `ct8rows`
  **0 differing rows** over 1588 vs the committed baseline, vs the pristine
  sweep AND vs the patched sweep. **NO ROW CONVERTED**; `results/*.csv`
  untouched.
* `byteverify` surelog vs pristine: 3 / 956 — `default/Earlgrey_0_1-71da2fd7`
  and `testflags/Earlgrey_0_1-71da2fd7` (both PREDICTED, and byte-identical to
  the shipped patch's own movers) plus `default/Scoreboard-59431470`, whose
  order-blind dump diff is **0 lines** (the coin).
* `byteverify` surelog vs the SHIPPED patched sweep: **0 / 956** — the fix has
  no corpus footprint at all.
* `rowheads`: `Earlgrey_0_1` 250 → 64 / 278 → 64, 1 head each, the two modes'
  logs byte-identical; every other named row byte-identical before and after.
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS ×2;
  `canaudit.sh canaries.sh ctcan2.sh` **audited=29 UNCOVERED=0
  FENCE-BREACH=0**. Protected DBs `InterfaceModPort` / `BlackParrotComplex` /
  `YosysOldOr` SAME both modes; `SVSwitch 4842211c4030`;
  `YosysVerx 6ccda350c24a`.
* **A/B gate**: `R10E92_OFF=1` on the FIXED binary reproduces the PRISTINE
  database byte-for-byte on all 22 grid arm-runs (identical=22 differing=0).
* fence check on the final patch: each of the four slang-fenced test names
  appears in **0** files of the diff (this directory spells none of them; the
  check is the RESUME §6 `awk`, `grep -v canaudit`).

## 6. The wide boundary — FIXED vs PRISTINE

See `BOUNDARY_WIDE.*`. Every `.sv` / `.v` at any depth under a COPY of
`tools/probe` (the base tree + `r10earl92repro` + this directory's own arms),
both views, list on fd 3, children `</dev/null`, PROCESSED asserted, rc
recorded per side.

The differing set is re-scored against real Surelog in `ARMS.r10v92.txt`:
this pass's own arms, the four other `vpiConditionOp`-fold faces
(`r10earl49repro/f1_earl49.sv`, `r10earl50repro/{f1_earl49,h2_earl50,h4_earl50}.sv`
— **6 cells FIXED, 0 BROKE**), and `r10buvm22repro/g22.sv`, which the A/B gate
convicts as NOT this law: `R10E92_OFF=1` still differs from pristine by 24
lines while OFF-vs-ON is 0, and the differing lines are the
`UINT:22498969` / `UINT:22507193` code-layout-tracking garbage literal that
earl84 recorded as its R5.

## 7. Files

| file | what it is |
|---|---|
| `v1_selbase.sv` … `v10_extra.sv`, `vs1_shapes.sv`, `vm1_min.sv` | the adversarial grid |
| `vm1_min.sv` | the 6-line minimal reproduction of the regression |
| `vs1_shapes.sv` | the select-mint table of §3.3 |
| `varm3.sh` | one arm, FOUR producers (golden / pristine / patched / fixed), rc recorded |
| `cells3.py` | the per-cell four-way scorer |
| `ARMS.r10v92.txt` | the grid's full output |
| `BOUNDARY_WIDE.*` | the wide boundary, fixed vs pristine |
