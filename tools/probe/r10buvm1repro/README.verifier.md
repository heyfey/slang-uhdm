# r10buvm1 — ADVERSARIAL VERIFIER RECORD

**THIS FILE IS THIS PASS'S**, and it is the VERIFIER's, not the implementer's.
Every number below was produced by a command run in this session, on binaries
**this verifier configured and built from source**, against sweeps **this
verifier ran**. Nothing was copied from the implementer's write-up; the
implementer's figures were used only as the predictions to be falsified.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

**VERDICT: PASS.** Every claimed number reproduced exactly — including the two
binary md5s, bit for bit, from an independent configure+build. Two findings are
recorded (F7, F8); neither is a defect in the shipped behaviour, and neither
blocks landing.

---

## 0. WHAT WAS BUILT AND WHERE

| binary | md5 | built by | from |
|---|---|---|---|
| CONTROL (pristine) | `eb2d9506c9c64c69afc90c16c3f49d08` | THIS VERIFIER | `/tmp/wt_vb1pris`, fresh worktree at **ba7d1ef**, no patch |
| FINAL (gated) | `a47cc37f3b67efd8374d4cf77458af33` | THIS VERIFIER | `/tmp/wt_vb1`, fresh worktree at **ba7d1ef** + `/tmp/r10buvm1.patch` |
| INSTRUMENT (probe only, never gated) | `6d2381d9025c5b0914eb4df6b3eb88ce` | THIS VERIFIER | `/tmp/wt_vb1dbg`, FINAL + two `VB1TRACE` `fprintf`s |

Both gated md5s are **byte-identical to the implementer's**. That is the
strongest single result here: two independent `cmake` configures and two
independent `-j 2` builds of the same tree produce the same bytes, so the
implementer's binaries were the binaries their gates describe.

The INSTRUMENT was proved inert before it was believed: run with the same `-o`
path as FINAL on BuildUVMPkg, `cmp` reports the two databases **byte-identical**
(`/tmp/vb1_dbg_buvm.uhdm` vs `/tmp/vb1_fin_buvm.uhdm`, 11097278 bytes each).

Patch: `/tmp/r10buvm1.patch`, md5 `f425e0049a516555c2a0d3dccdc3eb0e`, 2284 lines.
`git apply --check` clean against a **fresh ba7d1ef** worktree, and clean against
**current head 730f4bf** (r10uvm70 has landed since the brief was written), and
clean **on top of `/tmp/r10earl41.verified.patch`** — see F5.

---

## 1. THE FIVE GATES, RE-RUN FROM SCRATCH

### GATE 1 — BUILD
Two independent configures (`Release`, gcc-toolset-14, `CMAKE_PREFIX_PATH=~/.local`)
and two `cmake --build build -j 2`. Both reached `[100%] Built target
slang_uhdm`, both exit 0, both **0 `error:` lines**. md5s asserted in a
SEPARATE command after the link line, both 32-hex, and CHANGED. **REPRODUCED.**

### GATE 2 — GOLDENS
`SLANG_UHDM=<FINAL> tests/check_goldens.sh` → **23 PASS / 0 FAIL**.
`SLANG_UHDM=<CONTROL>` → 23 PASS. Negative control `SLANG_UHDM=/bin/false` →
**0 PASS / 23 FAIL**, so the harness can fail. **REPRODUCED.**

### GATE 3 — uhdm2rtlil / testflags / `--jobs 2`
Own `--out` and `--workdir`; `cmds.txt` re-read and asserts the intended binary
on every one of the four sweeps; `GOLDEN_DEFER` printed as `UNSET` before the
first sweep.

* FINAL: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump column
  **496 match / 183 differ / 52 blank**.
* `ct8rows.sh` vs the committed `results/gate_uhdm2rtlil.csv` (732 lines = 731
  ROWS): **0 differing ROWS (0 diff row-sides)**, both histograms identical.
* CONTROL sweep: same numbers, **0 differing ROWS**. **REPRODUCED.**

### GATE 4 — surelog / `--mode both` / `--jobs 2`
* FINAL `default`: 469 CMP_EQUAL / 11 CMP_NOTEQUAL / 5 DEFERRED / 284
  SLANG_REJECT / 25 SURELOG_FAIL.
* FINAL `testflags`: 465 CMP_EQUAL / 8 CMP_NOTEQUAL / 5 DEFERRED / 286
  SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT
  / 1 NO_UHDM.
* `ct8rows.sh` vs `results/golden_surelog.csv` (1589 lines = 1588 ROWS):
  **0 differing ROWS (0 diff row-sides)**. Dump histograms identical:
  default 225 match / 244 differ / 325 blank; testflags 165 / 300 / 329.
* CONTROL sweep: **0 differing ROWS** as well. **REPRODUCED, every figure.**

### GATE 5 — BYTE VERIFIER, both corpora, both modes, CENSUS-PREDICT FIRST

Prediction was computed from the **PRISTINE side alone** before the verifier was
judged:

```
predict.sh /tmp/vb1_wd_u2r_pris   ->  SCANNED: 679   PREDICTED MOVERS: 0
predict.sh /tmp/vb1_wd_sl_pris    ->  SCANNED: 953   PREDICTED MOVERS: 2
    PREDICT default/BuildUVMPkg-bf853d43    exprForm=1 stmtForm=0
    PREDICT testflags/BuildUVMPkg-bf853d43  exprForm=1 stmtForm=0
```

Then the verifier:

```
uhdm2rtlil/testflags: databases 679/679, PATH_SETS_IDENTICAL, MOVERS: 0 / 679
                      SELFCHECK 678/679 flagged      SELFCHECK1: 1
surelog/both:         databases 953/953, PATH_SETS_IDENTICAL, MOVERS: 3 / 953
                      MOVER ./default/BuildUVMPkg-bf853d43/slang.uhdm
                      MOVER ./default/Scoreboard-59431470/slang.uhdm
                      MOVER ./testflags/BuildUVMPkg-bf853d43/slang.uhdm
                      SELFCHECK 952/953 flagged      SELFCHECK1: 4
```

Both negative controls fire on both corpora. **The census predicted the movers
BY NAME on both corpora and agrees with the verifier.** **REPRODUCED.**

#### 1.5.1 THE SCOREBOARD FLAKE — RE-PROVED, NOT INHERITED

Size delta first, per the standing rule: BuildUVMPkg `+78` bytes in **both**
modes; `Scoreboard/default` **delta 0** (11122848 both sides). Then 3 reps per
binary, run from the test's own directory:

| test | binary | 3 reps | distinct hashes | bytes |
|---|---|---|---|---|
| Scoreboard/default | CONTROL | `b07ae13b024d0191`, `e491d2f7ff6c2322`, `e491d2f7ff6c2322` | **2** | 11122848 ×3 |
| Scoreboard/default | FINAL | `b07ae13b024d0191`, `b2c22219bcb9a912`, `b07ae13b024d0191` | **2** | 11122848 ×3 |
| BuildUVMPkg | CONTROL | `bb7a5e4de49388d1` ×3 | **1** | 11097258 ×3 |
| BuildUVMPkg | FINAL | `5231f09d51c93a13` ×3 | **1** | 11097336 ×3 |

`Scoreboard/default` is nondeterministic **on both binaries**, at a constant
byte size, and the hash sets OVERLAP (`b07ae13b024d0191` is produced by both).
This verifier's runs even produced a hash the implementer's runs did not — which
is itself the flake. BuildUVMPkg is deterministic on both binaries at a stable
`+78`. **The flake claim is INDEPENDENTLY PROVED, not accepted.**

---

## 2. THE HEAD — MEASURED ON BOTH SIDES, BOTH MODES

`rowheads.sh` on this verifier's own workdirs:

| test | mode | CONTROL cmp lines | FINAL cmp lines |
|---|---|---|---|
| **BuildUVMPkg** | default | **58** | **17** |
| **BuildUVMPkg** | testflags | **58** | **17** |
| SimpleUVM | default / testflags | 54 / 54 | 54 / 54 (head text byte-identical) |
| Scoreboard | default | 54 | 54 (head text byte-identical) |
| SeqDriver | default / testflags | 1414877 | 1414877 (head text byte-identical) |
| InterfaceModPort | default / testflags | 0 | 0 |
| BlackParrotComplex | default / testflags | 0 | 0 |

The CONTROL head text is **exactly the head the brief describes** — LHS
`ref_obj (…::__deferred_init::uvm_pkg::uvm_deferred_init)` @14107:7-14107:16
parented to the `begin`, RHS `hier_path (uvm_pkg::uvm_deferred_init.push_back)`
@14107:7-14107:50 with two `vpiActual` entries. It is **GONE** from the FINAL
database. The surviving head is a different family: a `constant`
`UINT:9200000000000000` under `time_var uvm_pkg::uvm_root::phase_timeout`
@38677, RHS `<null>`. **The head CLEARED on BOTH rows and the row ADVANCED.**

Per-shape movers, `mv1.sh` on golden / pristine / patched:

```
multiset distance to GOLDEN: pristine=79950  patched=79935  gain=15
ADDED line instances=3   REMOVED line instances=18   (never netted)
ADDED, all three, three-way counted:
  \_ref_obj: (…::__deferred_init::uvm_pkg::uvm_deferred_init), line:14107:7, endln:14107:16
                                                    golden=1 pristine=0 patched=1
  |vpiFullName:…__deferred_init::uvm_pkg::uvm_deferred_init  golden=1 pristine=0 patched=1
  |vpiName:uvm_pkg::uvm_deferred_init                       golden=1 pristine=0 patched=1
ADD-ONLY FALSIFIED (18 REMOVED) — which is the collapse working, and the
implementer says so in the same words.
```

**Zero unattributed names, and the added object carries golden's span EXACTLY
(14107:7-16).** The 18 REMOVED lines are exhaustively the dropped `hier_path`,
its two `vpiActual` children, the `method_func_call`, and the `rgtry` argument.

---

## 3. THE OVER-FIRE HUNT — WHAT THIS VERIFIER LOOKED FOR THAT THE PASS DID NOT

### 3.1 THE ONE NON-`$`, NON-METHOD SystemSubroutine: `randomize` — REFUTED, AND THE REASON IS NOT THE ONE THE LAW STATES

`builtinMethodRecv1`'s gate is `isSystemCall() && name[0] != '$' && !arguments().empty()`.
The stated law calls that "a BUILT-IN METHOD". It is not the same set. slang's
registration surface (`source/ast/builtins/*.cpp`,
`scripts/systemnames.txt`) contains **exactly one** name that is registered with
`addSystemSubroutine` (a PLAIN subroutine, no receiver) and does **not** start
with `$`: **`randomize`**, IEEE 18.12 scope randomize. Its `thisClass()` is
null, its name has no `$`, and its `arguments()[0]` is a **randomized variable,
not a receiver** — so it passes all four of the code gate's tests and the stated
law does not cover it.

Three probes were written for it (`v1_randomize.sv`, `v2_bare_rand.sv`,
`v3_combo.sv`), gridding `std::randomize(pkg::v)`, `std::randomize(pkg::cls::s)`,
the BARE `randomize(pkg::v)` form (where the call's OWN syntax has no `::`, so
§ scopedRootFromStmtSyntax1's statement fallback is the only lookup that can
run), and an unscoped control. `v3_combo.sv` puts a KNOWN mover
(`p3v::pq3.push_back(1)`) in the SAME file so a file-level difference cannot
explain a null result.

**Result: the known mover collapses; every `randomize` cell is byte-identical
between CONTROL and FINAL.** The INSTRUMENT says why:

```
VB1 BUILTINRECV name=push_back argkind=8      <- NamedValue, walk continues
VB1 BUILTINRECV name=randomize argkind=14     <- Assignment, walk STOPS
```

`ExpressionKind` 14 is **`Assignment`**: slang binds a scope-randomize argument
with `Expression::bindLValue`, which yields an `AssignmentExpression`, and
§ staticScopedChainDrops48's walk requires `NamedValue`. **The over-fire is
blocked STRUCTURALLY, not accidentally** — but by a guard the law's text never
names. Recorded as **F7** because a future pass that relaxes the `NamedValue`
requirement would silently open it.

### 3.2 THE `$` GUARD — PROVED LIVE, NOT ARGUED
Traced on `a3_overfire.sv`, which deliberately carries four `$`-named calls with
a `::`-scoped expression at argument 0: **0 `$`-named calls reach
`builtinMethodRecv1`'s return.** Independently, `sys_func_call` count in the a3
dump is **9 in both builds**. The cells that moved on a3 are lines 30, 42, 44,
46, 48 — and line 30's move is the `$display` **ARGUMENT** (`p3::pq.size()`)
collapsing while the `$display` itself survives intact, which is the law's own
claim. Lines 31, 32, 34, 35, 37, 38, 40 (the `$`-call and unscoped controls) did
**not** move in either direction.

### 3.3 THE WRONG-`::` RISK IN THE STATEMENT FALLBACK — PROBED, CLEAN
`scopedRootAt1` keys on the base's `SourceLocation` inside the enclosing
statement. If two `::` chains in ONE statement could ever report the same
location — which is what a macro used twice in one statement would do if slang
mapped both expansions to the macro DEFINITION — the walk would split the wrong
`::`. `v4_macro.sv` grids exactly that: one macro expanded twice in one
statement over DIFFERENT queues, twice over the SAME queue, and in statement
position. **Golden and ours agree on the emitted `p6::` name multiset exactly**
(3×`p6::q6` + 1×`p6::q6`, 1×`p6::r6` + 1×`p6::r6`), and the arm's distance to
golden falls 162 → 72. No mis-split.

### 3.4 IS § scopedRootFromStmtSyntax1 AN EMPTY PRODUCT? — NO, AND IT IS THE HALF THAT MOVES THE CORPUS
Traced on the real BuildUVMPkg run:

```
  26   VB1 ROOT own-syntax
   2   VB1 ROOT stmt-fallback HIT (wholeSyn=0)     <- the corpus head, read twice
12112  VB1 ROOT stmt-fallback miss
 138   VB1 ROOT none
2016   VB1 BUILTINRECV (472 size, 353 push_back, 275 exists, 204 delete, …)
```

The **only two** hits in the whole 45k-line design are the corpus head, and both
have `wholeSyn=0` — the expression carries NO syntax pointer, exactly as the
marker's decode says. Without the second marker the head cannot be reached at
all, which independently confirms the pass's own REFUTATION 6. On `a3` the
fallback also fires once with `wholeSyn=1` (the `sum() with (item)` cell, whose
`ArrayOrRandomizeMethodExpressionSyntax` `scopedChainRootName48` cannot walk) —
the "bonus" the README claims, confirmed.

### 3.5 A GENUINE EMPTY PRODUCT CELL — FOUND (F8)
`scopedChainDropRef48`'s new `base1` parameter is **defaulted to `nullptr` and
no caller ever passes null**: `grep -rn 'scopedChainDropRef48('` finds exactly
one call site (`ExprEmit.cpp:4270`), and it sits inside
`if (auto* cb48 = scopedChainDropBase48(expr))`, so `cb48` is non-null by
construction. Therefore the `:` arm of

```cpp
auto* ns48 = base1 ? scopedChainRoot1(e, *base1, stmtSyntax14)
                   : scopedChainRootName48(e.syntax);
```

is **UNREACHABLE**, and the header's defaulted parameter is dead. Not a defect
in shipped behaviour — but it is an arm of the code that the stated law does not
describe and that no gate can reach, and it is a landmine: a future caller that
passes `nullptr` silently gets the pre-pass, weaker lookup.

---

## 4. BOUNDARIES — EVERY ONE RUN, NOT ASSERTED

| boundary | how it was checked here | verdict |
|---|---|---|
| **§ retNameRecvCollapse69** (landed 7576076) — a1/a2/a3 + v1_gaps must hold | all four arms run on BOTH binaries | **ours byte-identical CONTROL vs FINAL in all four**; golden-vs-ours distance unchanged (1433 / 271 / 34 / 81). The reconciliation ("those cells have no `::`") is CONFIRMED empirically, not argued |
| **§ parensLessCallIsPathRefObj** (r10svs2) — the parens discriminator | **all 11** r10svs2 arms run on BOTH binaries (`s1`–`s7`, `w1`–`w4`) | **ours byte-identical in all 11**; distances unchanged. The implementer's self-reported "COLLISION" at a1 cell 71 is real (`x += p1::pq.size;` goes 3 objects → 1, and golden has 1) but it is a cell **the owning law never gridded** — a `::`-scoped receiver appears in none of its 11 arms. **NO FENCE BREACH.** Reported as a boundary interaction, correctly |
| **§ retNameLocalInstIsHomeNotClass3** (ba7d1ef, ModuleEmit) | patch touches no ModuleEmit line | untouched |
| **r10uvm70** (LANDED since the brief, head is now 730f4bf; EmitHelpers/ModuleEmit/TaskFuncEmit) | patch touches none of those files; `git apply --check` against **730f4bf** | **clean** |
| **r10earl41** (LIVE, shares `ExprEmit.cpp`) | `/tmp/r10earl41.verified.patch` applied to a fresh ba7d1ef, then this patch on top | **co-applies clean**; hunks at ~637-850 / ~4267 vs earl41's ~342 / ~12468-12992, no shared context |

CANARIES, all run on this verifier's own CSVs:

* `r10uvm52repro/canaries.sh` and this directory's: surelog **ok=52 changed=0
  absent=0**, u2r **ok=8 changed=0 absent=0**.
* `ctcan2.sh`: `EXPECT_UNKNOWN=1` on the surelog CSV → **ok=58, PASS**;
  `EXPECT_UNKNOWN=6` on the u2r CSV → **ok=1, PASS**. Both mode-matched, both
  with the baseline read FIRST.
* `canaudit.sh`: **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
* **InterfaceModPort** and **BlackParrotComplex** BY NAME: 0 cmp lines in both
  modes on both binaries, and neither is among the three flagged movers.

---

## 5. PATCH HYGIENE

* `git diff ba7d1ef` in the implementer's worktree touches **only**
  `include/UhdmExporter.h`, `src/ExprEmit.cpp` and `tools/probe/r10buvm1repro/`.
  No `results/*.csv`, no `tests/`, no `scripts/`, no other pass's probe dir.
* `README.verifier.md` is **THIS pass's** — distinct from `r10uvm69repro`'s and
  `r10svs2repro`'s, and its content names this pass's own instruments and the
  two it caught lying. (This file REPLACES it with the VERIFIER's record; the
  implementer's original text is preserved in `README.md` §§ 4–7.)
* Carried-forward scripts keep their origin headers (`r10uvm55repro/canaudit.sh`,
  `r10oth8`'s `ct8rows.sh`, `r10oth4`'s `byteverify.sh`). That is honest
  attribution, not staleness.
* `git stash` never used. `GOLDEN_DEFER` left UNSET and printed as such.

---

## 6. NUMBERED FINDINGS

**F1 — Both binary md5s reproduce bit for bit from an independent build.**
`cmake -S . -B build …; cmake --build build -j 2; md5sum build/slang-uhdm`
→ `eb2d9506…` (ba7d1ef pristine) and `a47cc37f…` (ba7d1ef + patch). Severity:
none — this is the strongest possible confirmation of gate 1.

**F2 — Every gate-3/4 figure and both row judges reproduce.**
`ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/vb1_u2r_patched.csv` and
`ct8rows.sh results/golden_surelog.csv /tmp/vb1_sl_patched.csv` → **0 differing
ROWS** each, all four histograms identical. Severity: none.

**F3 — The head cleared on both rows and the row advanced; the movers are fully
attributed.** `rowheads.sh` 58 → 17 ×2; `mv1.sh` gain 15, ADDED 3 / REMOVED 18,
all three ADDED texts golden=1/pristine=0/patched=1 with golden's exact span.
Severity: none.

**F4 — The Scoreboard flake is real and re-proved, not inherited.**
`detcheck.sh <bin> 3 …` from `third_party/tests/Scoreboard`: 2 distinct hashes
on EACH binary, constant 11122848 bytes, overlapping hash sets. BuildUVMPkg: 1
hash / 3 reps on each binary, stable +78. Severity: none.

**F5 — The base has moved: head is 730f4bf (r10uvm70 landed), not ba7d1ef.**
`git apply --check /tmp/r10buvm1.patch` is clean at ba7d1ef, at 730f4bf, and on
top of `/tmp/r10earl41.verified.patch`. The gates were run at ba7d1ef as the
brief specifies. Severity: **informational** — the landing commit will sit on
730f4bf, and no gate in this pass was run in that configuration. Textual
independence is proved; semantic independence is inferred from disjoint files
(uvm70 touches EmitHelpers/ModuleEmit/TaskFuncEmit only).

**F6 — All 15 boundary arms (4 × uvm69, 11 × svs2) are byte-identical between
CONTROL and FINAL.** Commands in §4. The reported a1-cell-71 collision does not
breach any arm the owning law measured. Severity: none — the implementer's
self-report was accurate and, if anything, understated the result.

**F7 — The code gate is BROADER than the stated law, and the guard that saves it
is unstated.** `builtinMethodRecv1` admits `randomize` (IEEE 18.12 scope
randomize), the one non-`$` PLAIN `SystemSubroutine` slang registers, whose
`arguments()[0]` is not a receiver. It is blocked only because slang binds that
argument as an `AssignmentExpression` (`ExpressionKind` 14) and the walk demands
`NamedValue` (8) — proved with `v1/v2/v3` probes plus the INSTRUMENT. Severity:
**latent**. No corpus or arm effect today; record it so a future relaxation of
the `NamedValue` test does not silently collapse `randomize(p::x)`. Suggested
one-line hardening for a later pass, NOT required now: exclude
`getSubroutineKind()`-less plain subroutines, or simply name `randomize` in
`builtinMethodRecv1`'s comment as the known non-method member of the gate.

**F8 — One genuine empty product cell: `scopedChainDropRef48`'s `base1`
default.** No caller passes null, so the `scopedChainRootName48(e.syntax)` arm of
the ternary and the header's defaulted parameter are unreachable.
`grep -rn 'scopedChainDropRef48(' src include` → one call site, inside
`if (auto* cb48 = …)`. Severity: **cosmetic / landmine**. Fix is to drop the
default and make `base1` a required reference.

---

## 7. RANKED RESIDUES (verifier's ranking)

**R1 — § pkgQualifiedRefQualifierSpan.** Golden spans a `pkg::name` READ over
the QUALIFIER ALONE; we span the whole written name whenever the collapse takes
the `isPkgQualifiedVarRef` re-emit branch. Verified live in a1 (line 47: golden
`@5-9`, ours `@5-11`) and a2/a3. **ZERO corpus population** — and the reason is
now decoded: the corpus cell is written INSIDE its declaring package, so
`isPkgQualifiedVarRef`'s `pkgViewVarObjs9` gate is false and the cell is built by
`scopedChainDropRef48`, which already spans the qualifier alone. That is why the
corpus object matches golden at `14107:7-16` while the arm cells do not. Must be
`!inLhs`-gated (a2 K2 keeps the whole span for an lvalue). Highest value, ≥2
sites.

**R2 — bare qualified read inside the declaring package** (`pkgViewVarObjs9`);
NAME, not span. a2 H2/H3/H5, a4 N4.

**R3 — `p3::E1.name()` folds to a constant in golden.** Enum-constant receiver;
a3 line 34. Distinct law.

**R4 — golden BINDS the collapsed ref from a package free function and NOT from
inside a class method** (a2 H6 vs H1). We emit unbound in both. Ungridded.

**R5 — `Tregistry rgtry;` gets a spurious `int_typespec`** (a5 31/41).

**R6 — loc-less `begin` for a rejected class-method body** (a5 Q1).

**R7 (NEW, verifier) — `scopedLvalueBadRef48` still reads
`scopedChainRootName48(whole.syntax)` alone**, so the predicate and the LVALUE
builder can now disagree: a chain whose `::` is only findable through
`stmtSyntax14` makes the predicate fire, enters the `inLhs` arm, gets `nullptr`
back and falls through to the switch. Output is unchanged from pristine in that
case (so it is not a regression), and no arm or corpus cell reaches it — an
invocation cannot be an assignment target — but the "both halves call the SAME
lookup" claim in the README covers the two halves of § staticScopedChainDrops48
and **not** this third half. Cheap to close: pass the base through here too.

**R8 (NEW, verifier) — F8's dead default.** Cosmetic.

---

## 8. WHAT THIS VERIFIER DID **NOT** CHECK

* **The landing configuration.** Every gate here ran at **ba7d1ef**, as the
  brief specifies. No gate was run at **730f4bf + this patch**, which is where it
  will actually land. Textual applicability is proved; behaviour there is not
  measured.
* **R1's fix**, R4's binding rule, and whether the surviving BuildUVMPkg head
  (the `time_var` constant) is one object or a family — the same three gaps the
  implementer names, and this verifier did not close them either.
* **Surelog itself.** Golden is taken as given throughout.
