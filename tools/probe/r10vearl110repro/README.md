# r10vearl110 — ADVERSARIAL VERIFICATION of r10earl110 — **ACCEPT-WITH-FIX**

**MEASUREMENT-ONLY probes.** The official `uhdm-cmp` and `scripts/verify_golden.py`
are the sole authorities. slang was **NOT** patched; `results/*.csv` were **READ
ONLY**; **nothing was promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched and are named
only inside `canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `6949e136` |
| pristine binary | md5 `75b85b861d89b7b7f270284613553218`, built by the VERIFIER from its own worktree at a clean `6949e136`, frozen `chmod 555` |
| implementer's patched binary | md5 `63c01ddb4d5fe0bf7fe3ff6b32f94e04`, rebuilt by the VERIFIER from `/tmp/r10earl110.patch`, frozen |
| **verified binary (this dir's fix)** | md5 `9ca576c398b84d08a6c9ebe77cc159a5`, frozen |
| production surface | `src/ExprEmit.cpp` ONLY |

---

## VERDICT — ACCEPT-WITH-FIX

Every headline number in the implementer's report **reproduced bit for bit** on
binaries the verifier built itself. The law is real, correctly decoded from
Surelog's source, and the head it clears is the head it claims.

But the report's central safety claim — *"**AWAY is impossible by
construction**"* — is **FALSE**, and arm `v6_away` convicts it with **3 AWAY
cells in each of two views on ordinary, legal SV**. The verifier fixed it,
re-ran the whole battery, and ships `/tmp/r10earl110.verified.patch`.

### what reproduced, exactly

| claim | verifier's own measurement |
|---|---|
| pristine md5 `75b85b86…`, patched `63c01ddb…` | **both reproduced to the digit** from a fresh `6949e136` worktree |
| patch applies clean on a FRESH `6949e136` | `apply rc=0`, 0 conflict markers, **44 paths**, fence 0/0/0/0 |
| goldens 23/0, `/bin/false` 0/23 | **23/0** pristine, patched and fixed; **0/23** negative control |
| u2r both modes 679/50/2, ct8rows 0 rows | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, ct8rows **PASS** vs committed baseline and vs own pristine, both modes |
| surelog 1588 rows, ct8rows 0 rows | **PASS** vs `results/golden_surelog.csv` AND vs own pristine. No row converted. |
| **head 176 → 17, one head** | **REPRODUCED**; `HEAD_AFTER_Earlgrey_testflags.cmp` and `HEAD_BEFORE_…` are **BYTE-IDENTICAL** to the verifier's own logs |
| Earlgrey/default 31 lines, cmp log byte-identical | reproduced |
| 11 of 12 row cmp logs byte-identical | reproduced; the twelfth is the target |
| grid TOGOLD 36 / AWAY 0 / MOVEDWRONG 2 / STILLWRONG 38 / SAME_AGREE 18 | **reproduced cell for cell** by an INDEPENDENT scorer (`vscore.py`, no shared code with `score110.py`) |
| byteverify surelog movers = the two Earlgrey DBs | **2 movers / 956**, both predicted by name. The verifier's run produced **no third mover** — independently corroborating that the implementer's `SeqDriver/default` was the documented coin, not their law |
| byteverify u2r 0 / 1358 | reproduced |
| canaries ok=52 / ok=8 changed=0; ctcan2 PASS ×2; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | reproduced |
| SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, three named DBs SAME | reproduced **to the digit** |
| WIDE BOUNDARY 4921/4921, identical 9444, DIFFERING 18, ASYMMETRIC 0 | **reproduced exactly**, same 18 files |
| the `g22`/`l154_noenum` 4096 layout artefact | reproduced: `22593273` → `22597369`, delta **exactly 4096** |
| foreign arms TOGOLD 1 / AWAY 0 / MOVEDWRONG 0 each | reproduced in all six arm-views |
| every `cmds.txt` audited by binary path | **1523/1523** surelog and **1458/1458** u2r name the verifier's own frozen binary; **zero** name the main tree |

---

## THE BREAK — § `hpSelHalfOpParamFold110` folded a leaf Surelog SPELLS

### the refuted reasoning

The report argues:

> *AT LEAST ONE LEAF MUST ACTUALLY FOLD. … a half with no folding parameter in
> it returns `ok=false` and the pre-existing rendering runs BYTE FOR BYTE, so
> the gate can only ever fire on a cell that was ALREADY WRONG (it displayed an
> identifier where golden displays a value). AWAY is impossible by
> construction.*

That is a **non-sequitur**. "A leaf folds" means *our* `selWidthParamFold`
**can** fold it — not that **golden** folds it. The two sets are not equal, and
the gap is an AWAY whenever the source text already happens to equal what golden
renders.

### the leaf golden does NOT fold

Arm `v5_value` cell `e1` measured it first, and `v6_away` isolates it:

> **A parameter DECLARED INSIDE THE GENERATE BLOCK is SPELLED by Surelog, not
> folded** — exactly like the genvar the law already excludes. A MODULE-scope or
> PACKAGE-scope parameter, elaborated before the scope was entered, prints its
> VALUE.

```systemverilog
localparam int unsigned MOD = 9;         // module scope  -> golden FOLDS
for (genvar z = 0; z < NCH; z++) begin : blk_w
  localparam int unsigned INNER = 4;     // gen-block scope -> golden SPELLS
  assign w1 = chan[z].fld[0+:(8 - INNER)];
  assign w4 = chan[z].fld[0+:(MOD - INNER)];
```

golden `-elabuhdm` **and** `-parse`, both views:

| cell | source half | golden | PRISTINE | implementer's PATCH | verdict |
|---|---|---|---|---|---|
| `w1` | `(8 - INNER)` | `8 - INNER` | **`8 - INNER`** ✅ | `8 - 4` ❌ | **AWAY** |
| `w2` | `(8 - INNER)-:3` | `8 - INNER-:3` | **`8 - INNER-:3`** ✅ | `8 - 4-:3` ❌ | **AWAY** |
| `w3` | `(2 * INNER)` | `2 * INNER` | **`2 * INNER`** ✅ | `2 * 4` ❌ | **AWAY** |
| `w4` | `(MOD - INNER)` | `9 - INNER` | `MOD - INNER` | `9 - 4` | MOVEDWRONG |

The pristine binary prints the **raw source text**, so wherever the author wrote
the constant leaf as a literal with `prettyPrint`'s own spacing, **pristine was
already exactly right** and the patch makes it wrong. `AWAY_PROOF.txt` is that
scoring against the implementer's own binary: **AWAY=3 in each view.**

### THE FIX (`src/ExprEmit.cpp`, inside `renderHalf110`'s NamedValue arm)

Mirror the genvar test one line up: walk the parameter symbol's parent scopes
and, if a `GenerateBlock`/`GenerateBlockArray` is reached before an
`InstanceBody`/`Package`/`CompilationUnit`/`Subroutine`, render the **name** and
do **not** set `folded110`. The scope-walk idiom is the one already used at
`src/TypeEmit.cpp:1538` and `:9890`.

Fail-closed: with no *foldable* leaf left, the half returns `ok=false` and the
pre-existing rendering runs byte for byte.

### what the fix costs and buys

| | |
|---|---|
| **AWAY** | `v6_away` **3 → 0** in both views; those three cells now **SAME_AGREE** with golden |
| **bonus wins** | `v6` `w4` and `v5` `e1`/`e8` convert **TO GOLDEN** (`9 - INNER`, `9 + INNER * 2 - 11`): golden's real rule is now matched, not merely avoided. `v6` TOGOLD 2 → 3, `v5` TOGOLD 4 → 6 |
| **cost on the implementer's arms** | **ZERO** — all six score identically to their committed `GRID` |
| **cost on the corpus** | **ZERO** — `byteverify` fixed-vs-implementer-patched is **0 movers / 956** (SELFCHECK 955/956 proves the comparator was live) |
| **the head** | **unchanged**: 176 → 17, one head, log **byte-identical** to the committed `HEAD_AFTER` |

---

## THE VERIFIER'S GRID — 30 arm-views, independent scorer

`vcalib.sh` builds each arm's golden TWICE in two directories and scores the
censuses against each other: **156 cells, 0 DIFF** (`CALIB.r10vearl110.txt`). Only
then does `vrun.sh` score three ways.

| set | views | TOGOLD | **AWAY** | MOVEDWRONG | STILLWRONG | SAME_AGREE | ONESIDED |
|---|---|---|---|---|---|---|---|
| the verifier's 6 arms | 12 | 38 | **0** | 10 | 34 | 8 | 6 |
| the implementer's 6 arms | 12 | 36 | **0** | 2 | 38 | 18 | 4 |
| 3 foreign converting arms | 6 | 6 | **0** | 0 | 22 | 102 | 18 |
| **totals** | **30** | **80** | **0** | **12** | **94** | **128** | **28** |

The implementer's row is their committed `GRID` **cell for cell** — 36 / 0 / 2 /
38 / 18 — reproduced by a scorer that shares no code with theirs.

### the faces the verifier added (none of them in the implementer's grid)

| arm | face | result |
|---|---|---|
| `v1_scope` | procedural blocks INSIDE a depth-1 gen scope (`always_comb`, `initial`, `always_ff`), a function body in one, a **case generate**, a **`for` inside an `if`** (the nesting order `g6 v9` never tried), an unnamed block, an **instance port connection** | case-generate **TOGOLD**; everything else inert. **AWAY 0** |
| `v2_modnest` | a child module with its OWN depth-1 generate, instantiated INSIDE a depth-1 generate of the parent (elaborated depth 2, per-instance depth 1) — the prime AWAY hypothesis against `genDepth110`'s `break` at `module_inst` | **TOGOLD.** Surelog's axis really is **per-instance** depth. The break rule is **CORRECT** |
| `v3_shape` | interface arrays vs struct arrays vs plain arrays; member steps **one and two deep**; `+:` / `-:` / `[l:r]` / bit-select tails; genvar / constant / **expression** receiver indices; a non-array receiver | 6 TOGOLD, **AWAY 0** |
| `v4_pair` | **the same path written in a module scope AND a gen scope in ONE design**, plus 1 / 2 / 3 instances at different parameter values (the Earlgrey 40/18/1 shape) | module copy **inert**, gen copies **TOGOLD ×2**. The scope gate holds |
| `v5_value` | value-SPELLING faces: negative, based-literal, multi-digit, derived, package, mixed precedence, redundant parens | 6 TOGOLD; found the based-literal and gen-local residues |
| `v6_away` | **the AWAY construction** | **3 AWAY on the implementer's binary; 0 on the fixed one** |

---

## GATES on the FIXED binary — ALL GREEN

| gate | result |
|---|---|
| **1 build** | pristine `75b85b86…`, implementer `63c01ddb…`, **fixed `9ca576c398b84d08a6c9ebe77cc159a5`**; all frozen `chmod 555` before any sweep; every `cmds.txt` audited by binary PATH |
| **2 goldens** | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** |
| **3 uhdm2rtlil** | both modes **679 / 50 / 2**; ct8rows **PASS** vs committed baseline and vs own pristine |
| **4 surelog** | 1588 rows; ct8rows **PASS** vs `results/golden_surelog.csv` and vs own pristine. **NO ROW CONVERTED** |
| **5 byteverify** | `SELFCHECK=1`: u2r **0 / 1358**; surelog **2 / 956**, both `Earlgrey_0_1/{default,testflags}`, **predicted by name before the sweep ran** |
| canaries | surelog **ok=52 changed=0**; u2r **ok=8 changed=0**; ctcan2 **PASS ×2**; canaudit **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | `InterfaceModPort` `BlackParrotComplex` `YosysOldOr` **SAME**; `SVSwitch` **`4842211c4030`**; `YosysVerx` **`6ccda350c24a`** |
| heads | 176 → **17**, one head; **11 of 12** row cmp logs byte-identical |
| **wide boundary** | `LISTED=4921 PROCESSED=4921 identical=9444 DIFFERING=18`, **ASYMMETRIC rc rows 0**; the same 18 files as the implementer, **no new differing file** |

---

## RESIDUES the verifier measured (ranked)

* **V-R1 — `§ elabHierSelWidthFold` folds a BARE gen-block-local width.**
  `v6` `w7`: `chan[z].fld[0+:INNER]` — golden keeps `INNER`, we print `4`, on
  **both** binaries. **PRE-EXISTING**, and it is the same distinguisher this fix
  adds one level up, so the two sites now disagree. Highest-value follow-up:
  the fix is already decoded and measured here.
* **V-R2 — a BASED-literal-valued parameter renders in DECIMAL.** `v5` `e3`/`e6`:
  `localparam logic [7:0] LB = 8'hA` → golden `8'hA - 9`, ours `10 - 9`.
  `prettyPrint` prints a constant's **`VpiDecompile`**, which keeps the based
  spelling; `selWidthParamFold` yields the decimal value. So the law's "at its
  VALUE" is really "at its **DECOMPILE**". MOVEDWRONG, never AWAY. Zero corpus cells.
* **V-R3 — `always_comb` / `always_ff` inside a depth-1 gen scope.** `v1` cells
  at `28:30` and `39:46`: golden **folds** (`0+:9 - 3`), the law does not fire.
  A missed conversion, not a regression. Note `initial` at `33:26` does **not**
  fold in golden — the procedural axis is finer than "depth 1" and needs its own arm.
* **V-R4 — an instance PORT CONNECTION at depth 1 is a different law.** `v1`
  `69:32`: golden folds the width **to its value** *and* folds the genvar index
  (`chan[0].fld[0+:6]`), which neither this law nor `prettyPrint` spacing explains.
* **V-R5 — the stray `(` on a non-array receiver.** `v1` `23:20`/`45:22`, `v3`
  `47:25`/`49:25`: `flat.fld[0+:(RA - RB]`. Pre-existing on both binaries; the
  implementer's R7 names it. Visible on function arguments too.
* **V-R6 — a width half is never operator-spaced when nothing folds.** `v2`
  `33:23`, `v4` `21:23`: golden `SA - SB`, ours `SA-SB`, both binaries. The
  implementer's R5, and `v4` shows it is the **module-scope** copy of the corpus
  head — so it has real population.
* **V-R7 — `§ elabHierSelWidthFold` folds a bare param width at MODULE scope
  where golden keeps it symbolic.** `v4` `22:23`: golden `chan[0].fld[QA - 1-:QB]`,
  ours `[QA - 1-:1]`/`[QA - 1-:2]`. Pre-existing, both binaries; the scope gate
  this pass measured for the *arithmetic* half is missing from the *bare* one.
* **V-R8 — the interface-array receiver never enters this builder.** `v3`
  `39:25`: golden `ifa[k].wline[0+:9 - 3]`, ours symbolic on both binaries, and
  we additionally emit a `ref_obj:ifa[k]` element vector golden never emits
  (a `Path_elems` shape difference). The implementer's `g4` saw the same.

## R0 — unchanged, and independently confirmed

`Earlgrey_0_1/testflags`, **17 lines, one head**, singular field with `RHS <null>`:
golden's `ref_typespec (work@top_earlgrey.u_xbar_main.u_sm1_17)` on the folded
`STIDW` width `constant` at `tlul_socket_m1.sv:105:61-105:66`, pointing at the
`int_typespec` at `73:14-73:26`. The verifier's own head log is **byte-identical**
to the committed `HEAD_AFTER_Earlgrey_testflags.cmp`.

## FILE MAP

| file | what it is |
|---|---|
| `v1_scope.sv` … `v6_away.sv` | the verifier's six arms |
| `vrun.sh`, `vscore.py` | the independent three-way driver and scorer (no shared code with `score110.py`) |
| `vcalib.sh`, `CALIB.r10vearl110.txt` | golden-vs-golden calibration, 156 cells 0 DIFF |
| `GRID.r10vearl110.txt` | all 30 arm-views on the FIXED binary |
| `AWAY_PROOF.txt` | `v6_away` scored against the IMPLEMENTER's unfixed binary — AWAY=3 per view |
| `BOUNDARY_WIDE.*` | the verifier's own wide boundary over the whole probe tree |
