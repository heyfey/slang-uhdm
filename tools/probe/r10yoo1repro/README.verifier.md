# r10yoo1 — README.verifier.md (ADVERSARIAL VERIFIER, this pass)

**This file replaces the file of the same name that shipped inside
`/tmp/r10yoo1.patch`.** That file was written by the *implementer* and documents
GATE 5's instrument; it is r10yoo1's own content (not a carried-forward copy), so
it is not a hygiene breach — but it is not a verifier record either, and the
landing rule wants THIS pass's *verifier* record here. The implementer's text is
preserved in the patch history and its claims are all re-measured below.

Verifier worktrees (mine, both built by me from an absolute path):

| | worktree | HEAD | `git status --porcelain` | md5 |
|---|---|---|---|---|
| PRISTINE | `/tmp/wt_r10yoo1v_pris` | `97f6f906770b306d28674a8a3c129203f32cb7d3` | EMPTY | `5478b377271cf37d444e946449f63242` |
| SHIPPED | `/tmp/wt_r10yoo1v_ship` | same | `M src/ParamEmit.cpp` + probe dir | `bfac08131242f6e62e45408c78adba7f` |
| REFINED (mine) | `/tmp/wt_r10yoo1v_fix` | same | patch + my 12-line narrowing | `0eb9ca105e3206d9648fa643fdf17325` |

Both of the implementer's md5s reproduced **exactly**, from a fresh
`git worktree add --detach 97f6f90` + `git apply /tmp/r10yoo1.patch`
(`git apply --check` rc=0) + `cmake --build`: 0 lines matching `error:`,
`Linking CXX executable slang-uhdm` = 1 and `Built target slang_uhdm` = 1 in each
build log, each md5 asserted in its own command, each 32 hex.

---

## VERDICT: **PARTIAL**

Everything the pass claims about `YosysOldOr` and about the corpus is **true and
independently reproduced**: the head is gone, the row converts in both modes,
five gates are green, and the corpus blast radius is exactly two databases out of
2311. The reason this is not a PASS is F1:

> **`§ caTernOperandRead1` as coded is WIDER than the law it states and wider
> than golden.** It harvests every parameter name *anywhere inside* a folding
> condition or a folding branch pair, where golden only reaches a **whole name**.
> On a 26-cell purpose-built verifier grid the shipped binary **REGRESSES 9
> cells** that the pristine binary gets right — including the exact shape the
> pass itself filed as untested residue **R4**. A **12-line narrowing** (built,
> `0eb9ca105e3206d9648fa643fdf17325`) clears all 9, keeps every one of the pass's
> 14 arm conversions, and produces a **byte-identical `YosysOldOr` database and a
> byte-identical 1588-row surelog CSV**. Nothing in the pass's result depends on
> the over-fire.

Recommendation: **land with the narrowing** (§F1, diff quoted in full). Landing
without it writes a measurement into the codebase that golden refutes — the same
failure mode this pass correctly refuted at `src/ParamEmit.cpp:13984`.

---

## 1. EVERY CLAIMED NUMBER, RE-MEASURED

| claim | mine | |
|---|---|---|
| pristine md5 `5478b377…` / shipped `bfac0813…` | identical | ✓ |
| `git apply --check` on pristine `97f6f90` rc=0; only `src/ParamEmit.cpp` (+87/−7) + `tools/probe/r10yoo1repro/`; `results/` untouched | identical | ✓ |
| GATE 1 base marker: MOVER moves, CONTROLS A–D unmoved, no symbol row | reproduced on both binaries | ✓ |
| GATE 2 goldens 23/0 (rc 0) and `/bin/false` 0/23 (rc 1) | identical | ✓ |
| GATE 3 u2r `testflags` 679/50/2, dump 496/183/52, `ct8rows` **0 rows** vs `results/gate_uhdm2rtlil.csv` | identical (and `default` 679/50/2, dump 492/187/52) | ✓ |
| GATE 4 pristine surelog sweep **byte-identical** to `results/golden_surelog.csv` (0 of 1588 rows) | identical — the base control holds, and no `SURELOG_FAIL` detail row raced under two concurrent sweeps | ✓ |
| GATE 4 shipped surelog: `default` 468→**469**/12→**11**, `testflags` 464→**465**/9→**8**, every other bucket unchanged, **2 rows / 4 row-sides, all `YosysOldOr`** | identical | ✓ |
| dump histogram: default empty 326→325, differ 243→244; testflags 330→329, 299→300 | identical | ✓ |
| `uhdm-cmp` rc 255→0, 52 lines→0, both modes | identical (52/52 → 0/0) | ✓ |
| the two modes' databases are byte-identical, each binary | identical | ✓ |
| GATE 5 byte verifier u2r: **0 movers / 1358**, `SELFCHECK` 1357/1358, `SELFCHECK1`=1 | identical | ✓ |
| GATE 5 byte verifier surelog: 2 real movers / 953 | **3 flagged**; the third is `Scoreboard/default`, disposed of as the documented same-size flake — see F2 | ✓ with a correction |
| `msthree.sh` GOLD/PRIS/SHIP: **12 shapes moved, all toward golden, 6 exactly on golden** (`logic_typespec` 0→2 ×3 indents, `int_typespec@86:4-88:24` 6→4, `UINT:30` 9→11, `UINT:0` 2821→2823) | identical, row for row | ✓ |
| parameter-typespec census `385 EQ / 0 DIF` (the brief's localization refuted) | identical, both binaries | ✓ |
| `param_assign` Rhs-constant census `385 cells, 2 DIF` → `0 DIF` | identical | ✓ |
| census-predict upper bound 7 / 5 / 38 dirs ⇒ ≤100 databases; actual 2 | identical; `openmsp430` did not move | ✓ |
| arms: a1 26/0, a2 30/0, a3 18/12 (both binaries), a4 24/0, a5 21/3→24/0, a6 12/10→20/2, a7 7/3→10/0 | identical, cell for cell, on my own Surelog runs | ✓ |
| golden's answers y1 BARE·BARE, y3 BARE, y4 LOCATED, y5 LOCATED ×2, y2/y6/y7/y8 LOCATED, z1–z5 BARE, z6 LOCATED, k1/k2 BARE, k3 LOCATED (override fence) | identical | ✓ |
| the codebase's ablation row `whole name in a ternary condition → LOCATED` is **WRONG** | **CONFIRMED** by my own fresh Surelog runs of z5 *and* k1: golden = `logic_typespec@SPANLESS` | ✓ |
| canaries: `InterfaceModPort` + `BlackParrotComplex` by name ×4 unmoved; `canaries.sh` ok=50 changed=2 (both printed, both `YosysOldOr`); `ctcan2` PASS 1/6 mode-matched; `canaudit` 29/0/0 | identical | ✓ |
| R1/R2 (a3's 12 DIF, a6 z3 DEF ×2) pre-existing on both binaries | confirmed — identical cell lists on both binaries | ✓ |
| R3 `YosysOldOr` dump still `differ`, dominated by `begin`-block column spans | confirmed (`211:15` golden vs `211:19` ours, and 34621 diff sides total) | ✓ |
| GRID "166 cells — 22 CONVERGED, 144 HELD" | **does not reconcile** — see F3 | ✗ (bookkeeping) |
| R4 "nested foldable ternary branches untested against golden" | **now tested — golden says LOCATED and we say BARE**: R4 was not a gap, it was a defect. F1 | ✗ |

Commands (all run from a repo root with `SLANG_UHDM` exported first, absolute
paths, `--jobs 2`, own `--out`/`--workdir`, `GOLDEN_DEFER` unset):

```sh
git worktree add /tmp/wt_r10yoo1v_ship --detach 97f6f90 && cd /tmp/wt_r10yoo1v_ship && git apply /tmp/r10yoo1.patch
~/.local/bin/cmake -S /tmp/wt_r10yoo1v_ship -B /tmp/wt_r10yoo1v_ship/build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DCMAKE_PREFIX_PATH=/home/heyfey/.local
~/.local/bin/cmake --build /tmp/wt_r10yoo1v_ship/build -j 6
PA=/tmp/r10yoo1v_pa ./tools/probe/r10yoo1repro/basemark1.sh <each binary>
SLANG_UHDM=<bin> ./tests/check_goldens.sh                 # 23/0 ; /bin/false -> 0/23
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus surelog    --mode both --jobs 2 --out … --workdir …
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 --out … --workdir …
./tools/probe/r10yoo1repro/ct8rows.sh results/golden_surelog.csv    /tmp/r10yoo1v/sls.csv
SELFCHECK=1 SELFCHECK1=1 ./tools/probe/r10yoo1repro/byteverify.sh /tmp/r10yoo1v_wd_sls /tmp/r10yoo1v_wd_slp
./tools/probe/r10yoo1repro/msthree.sh <golden.uhdm> <pris slang.uhdm> <ship slang.uhdm>
PA=/tmp/r10yoo1v_pa ./tools/probe/r10yoo1repro/armrun.sh <arm>.v <binary>
```

---

## 2. FINDINGS

### F1 — **THE LAW OVER-FIRES: 9 REGRESSED CELLS, golden-refuted, and a 12-line fix that costs nothing**

`§ caTernOperandRead1` states "the CONDITION, when the condition folds" and
"BOTH BRANCHES, when both fold". What it *implements* is a **whole-subtree
visitor** on those operands (`harvest(*co.conditions[0].expr)`,
`harvest(co.left())`, `harvest(co.right())` — the pre-existing
`NamedValueExpression` visitor). Every arm the pass built puts a **bare whole
name** in those positions, so nothing in the pass's evidence distinguishes
"whole name" from "anywhere inside". Golden does.

Two verifier arms, landed here, run with all three binaries (`armrun.sh` +
`r10yoo1pa`, fresh Surelog, `default`-shape argv):

`v1_verifier.v` — 22 cells:

| cell | shape | GOLDEN | PRIS | SHIP | FIX |
|---|---|---|---|---|---|
| v1 P1 | `(P1 == 31'h7f800000) ? n1 : n2` — compound cond | LOCATED | LOCATED | **BARE ✗** | LOCATED |
| v2 A1 | `(A1 != 31'h0) ? n1 : n2` — witness population | LOCATED | LOCATED | **BARE ✗** | LOCATED |
| v3 B1,B2 | `nb ? (B1\|31'h1) : (B2\|31'h1)` — compound branches | LOCATED | LOCATED | **BARE ✗ ×2** | LOCATED |
| v4 C1–C4 | `nc ? (1'b1?C1:C2) : (1'b0?C3:C4)` — **nested FOLDABLE branches = R4** | LOCATED | LOCATED | **BARE ✗ ×4** | LOCATED |
| v5 D1,D2 | `wire [30:0] w5 = (n1\|n2) ? D2 : D1;` — net-decl assign | LOCATED | LOCATED | LOCATED | LOCATED |
| v6 E1 | `(E1 & ne) ? n1 : n2` — folds nowhere (control) | LOCATED | LOCATED | LOCATED | LOCATED |

`v2_verifier.v` — 4 cells:

| cell | shape | GOLDEN | PRIS | SHIP | FIX |
|---|---|---|---|---|---|
| w2 A1 (TOP) | `A1[0] ? n1 : n2`, untyped sized-literal | LOCATED | LOCATED | **BARE ✗** | LOCATED |
| w1 P1 (TOP) | `P1[0] ? n1 : n2`, ranged untyped | LOCATED | **BARE** | **BARE** | **BARE** |

```
CELLS 22  PRIS EQ 22 DIF 0   SHIP EQ 14 DIF 8   FIX EQ 22 DIF 0
CELLS  4  PRIS EQ  3 DIF 1   SHIP EQ  2 DIF 2   FIX EQ  3 DIF 1
```

**9 cells regress under the shipped patch.** (w1 is a *pre-existing* defect of
the older SELECT rule, present in all three binaries — filed R6 below.)

The narrowing — harvest a whole name only, exactly as the law's prose says:

```diff
+            auto harvestWhole = [&](const Expression& e) {
+                const Expression& s = stripImplicitConv(e);
+                if (s.kind != ExpressionKind::NamedValue)
+                    return;
+                auto& sym = s.as<NamedValueExpression>().symbol;
+                if (sym.kind == SymbolKind::Parameter)
+                    names.insert(sym.name);
+            };
             if (ctx.tryEval(*co.conditions[0].expr))
-                harvest(*co.conditions[0].expr);
+                harvestWhole(*co.conditions[0].expr);
             if (ctx.tryEval(co.left()) && ctx.tryEval(co.right())) {
-                harvest(co.left());
-                harvest(co.right());
+                harvestWhole(co.left());
+                harvestWhole(co.right());
             }
```

What it costs, **measured, not argued** (binary `0eb9ca105e3206d9648fa643fdf17325`):

* all 7 implementer arms: **identical verdicts to the shipped binary** — a5 24/0,
  a6 20/2, a7 10/0, a4 24/0, a1 26/0, a2 30/0, a3 18/12. Not one of the 14 arm
  conversions is lost.
* `YosysOldOr` still converts in **both** modes, and its database is
  **byte-identical to the shipped binary's** (`cmp -s`, md5 `d68e0796d62c`).
* a full `--mode both` surelog sweep with the refined binary is **byte-identical
  to the shipped sweep's 1588-row CSV** (`diff` = 0 sides), i.e. 469/11 + 465/8.
* byte verifier refined-vs-pristine: the same 2 real movers.
* `v1`/`v2`: 9 of 9 regressions gone; the one remaining DIF is the pre-existing
  R6.

The `v5` cell is worth keeping in mind for whoever lands this. Observed: the
shipped binary does **not** fire on `wire [30:0] w5 = (n1|n2) ? D2 : D1;`, so
slang's net-declaration initializer is not reaching the
`SymbolKind::ContinuousAssign` walk in `paramCaFoldRead` (inference from the
non-fire, not read out of slang) — and golden keeps that cell LOCATED, so the two
agree by luck of modelling rather than by design. Note the existing comment at
`:14025` says a net-declaration assignment "carries the same reduce" for a
**selected** name in the predicate; for a whole-name **branch** pair golden says
it does not.

### F2 — **THE `Scoreboard/default` FLAKE IS LIVE; the pass's "did not appear" was luck, not absence**

The implementer recorded that the documented same-size flake did not appear in
their byte-verifier run. In **my** run it did:

```
MOVER ./default/Scoreboard-59431470/slang.uhdm  patched=af5750bd30f9 pristine=5470021a5a2f
MOVERS: 3 / 953        SELFCHECK1 = 4  (= 1 corrupted + 3 flagged)
```

Both files are **11122503 bytes** — the "same size = flake" signature. Disposed
of by re-running the single test with each binary, twice, in its own workdir:

| binary | run 1 | run 2 |
|---|---|---|
| pristine | `af5750bd30f9…` | `af5750bd30f9…` |
| shipped | `5470021a5a2f…` | `814cba9780b8…` |
| refined | `d24170f7b1ea…` (sweep) | — |

**Five distinct md5s across six runs, on both sides of the patch**, and the
*pristine* sweep's value is one the *shipped* binary also produces. Status is
`CMP_NOTEQUAL` in every run. So: nondeterminism (the emitter-nondeterminism note
in MEMORY: `SourceLocation` compares across macro buffers flip under parallel
parse), **not** a mover, and the pass's "2 real movers / 2311" stands. The
lesson for the next verifier is that this canary must be *disambiguated*, not
observed: a run in which it happens to be stable proves nothing about the run in
which it is not.

### F3 — **THE GRID ARITHMETIC DOES NOT RECONCILE (bookkeeping only)**

`README.md` says "166 cells: the witness (6) plus seven arms" and "166 cells —
22 CONVERGED, 144 HELD". Measured: the seven arms are **166 cells by
themselves** (26+30+30+24+24+22+10), so with the witness the grid is **172**;
and the cells whose value actually changes between the two binaries are
**14** (a5 3, a6 8, a7 3 — counted by diffing the two censuses' `OURS` lines),
plus the witness's 2, i.e. **16 CONVERGED**, not 22. The rest: **142 HELD-EQ**
and **14 still-DIF** (a3's 12 + a6 z3's 2, identical on both binaries). No cell
regressed *within the pass's own grid* — that part is true, and F1 is a
regression outside it.

```sh
diff <(grep -A2 '^\(EQ\|DIF\)' arm_a6_overfire_pris.txt) \
     <(grep -A2 '^\(EQ\|DIF\)' arm_a6_overfire_ship.txt) | grep '^[<>]' | grep -c OURS   # 16 lines = 8 cells
```

### F4 — **EMPTY PRODUCT: 110 of the 166 arm cells cannot exercise the new code at all**

Hunted as the brief requires. No cell in the grid is *absent* (every arm's census
reports `MISSING-GOLDEN 0 MISSING-OURS 0`, and each arm's cell count equals
declarators × 2 views: a1 13×2, a2 15×2, a3 15×2, a4 12×2, a5 12×2, a6 11×2,
a7 5×2 — so no cell silently vanished, which is the failure mode that makes a
census read "all equal"). But **inertness** is the other half:

```sh
for a in a1_declcount a2_litform a3_declform a4_usage; do grep -c '^[[:space:]]*assign' $a.v; done   # 0 0 0 7
```

* **a1 (26), a2 (30), a3 (30) contain ZERO continuous assigns.** `paramCaFoldRead`
  returns false for all 86 cells under *any* widening of its read predicate; they
  cannot move for this law in either direction.
* **a4 (24)**: every cont-assign RHS folds as a whole (`assign o2 = 1'b1 ? T2 : T1`),
  so all 24 cells exercise the **pre-existing** `tryEval(rhs)` path, never the new
  arm. The pass says this itself in §6.6 — it is why a4 read 24/24 EQ on the
  pristine binary — but the cells are still counted in the "144 HELD" that reads
  as blast-radius evidence.

So the grid's live fence for `§ caTernOperandRead1` is **56 cells** (a5 24 + a6 22
+ a7 10), of which the *constraining* ones are y4, y5×2, y2, y6, y7×2, y8×2, z6,
z7×2, k3×2 = 14. The 110 inert cells are not worthless — they fence the
`makeParamTs`/typespec-minting change the pass first hypothesized and then
refuted — but they must not be read as evidence about the read predicate. My
`v1`/`v2` arms are 26 cells of which **26 are live**, and they found F1.

### F5 — **HYGIENE: clean, with one collision of kind**

* Patch applies to a pristine `97f6f90` (`git apply --check` rc=0); production
  reach is exactly `src/ParamEmit.cpp` +87/−7; no `include/` change; no new
  symbol (verified: the law's name occurs only in comments, `strings` would read 0
  on both binaries — the absence of a symbol row in `basemark1.sh` is correct and
  the marker is behavioural in both directions with four controls).
* `results/*.csv` untouched in every worktree (`git status --porcelain results/`
  empty); the two `YosysOldOr` rows are quoted before/after; the MASTER promotes.
* **`§ mergedPortDefRangeSymbolic` holds.** The patch touches no file it lives in
  (`src/ModuleEmit.cpp`, `include/UhdmExporter.h`), and its witness test
  `YosysOldOr` moves only in the improving direction (`CMP_NOTEQUAL` →
  `CMP_EQUAL`). The brief's guess that this head was that law's residue is
  refuted, as the pass says (§6.1): `86:4-88:24` is a three-**declarator**
  `parameter` statement, not a split port.
* **Live passes do not collide**: `r10earl38` touches `src/ModuleEmit.cpp` only;
  `r10uvm67` touches `src/ModuleEmit.cpp` + `src/TypeEmit.cpp`. Neither touches
  `src/ParamEmit.cpp`. No fenced test (`UnsignedParam`, `HierPathEval`,
  `FileLocalParam`, `TopParam`) is dispatched by any driver here (`canaudit` =
  0 breaches).
* **The one collision is this file**: the patch ships a `README.verifier.md` of
  its own. Its content *is* this pass's, so the landing rule is not breached in
  substance, but a verifier record written by the implementer cannot be the
  independent record the rule is asking for. This file replaces it.
* `msthree.sh` compares dumps from two different workdirs without `file:<workdir>`
  normalization. Checked rather than assumed: `grep -c r10yoo1v_wd` on the
  shipped dump = **0**, so no workdir path reaches a dump line and the 12-shape
  table is sound as printed.

---

## 3. RANKED RESIDUES (after this verification)

* **R0 (new, blocking-for-landing) — the over-fire of F1.** Fix built and
  measured; land it with the pass. Cells: compound folding condition, compound
  folding branch pair, nested folding branch pair, select-in-condition of an
  untyped sized-literal param.
* **R6 (new, pre-existing both binaries) — the SELECT rule over-fires on a RANGED
  untyped param.** `parameter [30:0] P1 = 31'h7f800000;` read as
  `assign o = P1[0] ? n1 : n2;` → golden `int_typespec@11:14-11:20 [UINT:30:UINT:0]`
  (LOCATED), we emit `logic_typespec@SPANLESS`. Arm `v2_verifier.v` cell w1, TOP
  view, DIF on **all three** binaries. This is the other half of the ablation
  table's disputed rows: the pass proved `whole name in a ternary condition →
  LOCATED` is wrong; w1 says `select in a ternary condition → bare` is *also*
  wrong, for the ranged population at least. Owner: `paramNameIsRead`'s
  `narrow`/`inGenCond` recursion at `src/ParamEmit.cpp:14019`.
* **R1** typed multi-declarator vector param DEF-view span extent
  (`@33:14-33:19` vs `@33:14-33:26`), 8 cells, pre-existing — confirmed
  identical on both binaries.
* **R2** signed untyped multi-declarator: golden `norange`, we add
  `[INT:30:INT:0]`, 6 cells, pre-existing — confirmed.
* **R3** `YosysOldOr` remains `dump: differ`: `begin`-block column spans
  (`work@or1200_alu` `211:15` vs `211:19`, and 34621 diff sides overall). A
  CMP_ONLY class; the six "toward golden but short" shapes in the msthree table
  are this gap.
* **R5** the corpus population of spanless-logic golden cells is counted, not
  audited. My independent re-scan of the whole golden cache reproduces the pass's
  numbers **exactly**: `DATABASES=3673 SPANLESS_LOGIC=847 RANGED_INT=54881
  LOADFAIL=0 TIMEOUTS_OR_CRASH=0` (`r10yoo1reach.cpp` over
  `~/.cache/slang-uhdm-goldens/*/golden.uhdm`).

## 4. WHAT THIS VERIFICATION DOES NOT COVER

* The 845 other spanless-logic golden cells, individually. Bounded, not audited.
* `SLANG_REJECT` tests (284/286 surelog, 50 u2r) emit no database and contribute
  no comparable path.
* Performance: not measured directly. The new `tryEval` calls are per
  cont-assign, only on RHSs that already failed to fold, and the result is cached
  per `InstanceBody`; the two full surelog sweeps ran concurrently and finished
  together, so no cost was visible at sweep granularity.
* `folded` mode (diagnostic only, out of the target) was not run.

## 5. WHAT TO LAND

Two options, both measured:

1. **`/tmp/r10yoo1.patch`** (md5 `642e15b142d1a11543e8c7b5c7fe09e7`) as shipped —
   converts `YosysOldOr`, five gates green, and carries the F1 over-fire.
2. **`/tmp/r10yoo1v_combined.patch`** (`git apply --check` rc=0 against a pristine
   `97f6f90`; its md5 is quoted in the verifier's report — it cannot be quoted
   here without the file containing its own hash) — the same patch **plus**
   the F1 narrowing, **plus** `v1_verifier.v` / `v2_verifier.v` (the 26 cells that
   found it), **plus** this file. Identical `YosysOldOr` database, identical
   1588-row surelog CSV, identical u2r CSV, 9 fewer golden-refuted cells.
   Recommended. If it is taken, the narrowing's comment should be rewritten from
   "VERIFIER EXPERIMENT" into the law's own fence, naming cells v1–v4 and w2.

Sweep workdirs (`/tmp/r10yoo1v_wd_*`) and per-arm temp dirs are deleted; the CSVs,
gate logs, arm censuses, the reach output and the refinement diff are kept under
`/tmp/r10yoo1v/`. The three worktrees are kept because the md5s above are only
checkable from them.
