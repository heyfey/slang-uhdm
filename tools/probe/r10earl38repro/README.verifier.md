# r10earl38 — ADVERSARIAL VERIFIER REPORT

## VERDICT: **PASS**

The law is true, the head is cleared, and **every substantive number in the
implementer's report reproduced exactly** from binaries I built myself. Two
reported *canary/gate row counts* did not reproduce; both are traced to a
**stale committed baseline** that is provably independent of this patch
(pristine and patched CSVs are byte-identical), so they are reported as
findings against the baseline, not against the patch. One narrowing of the
grid's `REGRESSIONS 0` column and one new residue are recorded below.

**Base used: `49475c9` (fresh worktrees I created).** Note that repo HEAD has
since moved to **`73dc976`** — see V9/V10.

| binary | md5 | claimed | base |
|---|---|---|---|
| PRISTINE `/tmp/wt_e38xpris` | `dfc46cad6152aa06c368d3c63729a128` | same | `49475c9`, `git status` empty |
| PATCHED `/tmp/wt_e38x` | `d2d5f35fba29af8a46a58a91c9c951fd` | same | `49475c9` + patch only |

Both md5s reproduced **bit-for-bit** from my own `cmake` configure + build, so
every number below is a re-measurement. Marker check: `grep -c
genChainBranchScopeThreads38` = 1 patched / 0 pristine.

---

## 1. THE LAW — INDEPENDENTLY CONFIRMED, INCLUDING THE BRIEF'S REFUTATION

I read the source before the report. `padring.sv:92–137`:

```
 92   for (genvar k = 0; k < NMioPads; k++) begin : gen_mio_pads   <- ENCLOSING GEN SCOPE
 93     if (ConnectMioIn[k] && ConnectMioOut[k]) begin : gen_mio_inout      <- `if`  (served)
103     end else if (ConnectMioOut[k]) begin : gen_mio_output               <- 1st `else if`
115     end else if (ConnectMioIn[k]) begin : gen_mio_input                <- 2nd `else if`  == THE HEAD
126       logic unused_out, unused_oe;
129     end else begin : gen_mio_tie_off                                   <- final `else`
130       logic unused_out, unused_oe;
131       logic [AttrDw-1:0] unused_attr;
```

`cat -A` on line 126 confirms 6 spaces + `logic ` → `unused_out` at **col 13**,
`unused_oe` at **col 25**. **The brief's framing is REFUTED exactly as the
implementer says**: columns 13/25 are the two DECLARATORS, there is no
initialiser anywhere, and the assignments at 127/128 are separate continuous
assigns. Not a decl-init, not an unused-lint `assign`, not § 66's mirror.

I traced the mechanism in the pristine source (`ModuleEmit.cpp:26253` `findNested`,
`26279` the else-clause recursion) and it is exactly as stated: `findNested` on an
`IfGenerate` clause returns null (no `GenerateBlock` member's syntax IS the
clause), the recursion then re-enters with `astBlock == nullptr`, and `findNested`'s
own `!astBlock` arm searches **`body.members()`** — right for a module-level chain,
null for one inside `gen_mio_pads`. The arm `a1_chain.sv`'s `gen_w3` is faithfully
placed at padring's own 2nd-`else if` position.

**STATED GATE == CODE GATE**: I diffed § 0's quoted before/after against the
patch hunk — character-identical. Production surface: `src/ModuleEmit.cpp` **32/5
only**; `git apply --numstat` shows no other production file, and the code hunk
contains exactly 1 marker and **zero** mentions of §§ 66/37/33/15/1 (those appear
in `README.md` prose only).

---

## 2. FIVE GATES, RE-MEASURED

**GATE 1 — BUILD. GREEN.** Absolute paths; waited for `[100%] Built target
slang_uhdm` on both (`slang_uhdm_obj_lib` at 77% correctly ignored); `error:` = 0
both; md5s asserted separately and 32-hex-checked; both bases grep-asserted to
`49475c9…`; pristine tree dirty-line count 0.

**GATE 2 — GOLDENS. GREEN.** `SLANG_UHDM` **exported first** every time.
Patched **23/0**; pristine **23/0**; `/bin/false` → **0/23** (rc 1), so the
harness is live.

**GATE 3 — u2r. GREEN on substance; one stated number NOT reproducible.**
Both modes **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** ✓.
Testflags dump column **496 match / 183 differ / 52** ✓ (default is 492/187/52).
`ct8rows` whole-row vs the committed baseline = **104 rows, not 0** → see **V8**.
The decisive check is green: **the pristine and patched u2r CSVs are BYTE-IDENTICAL**,
and a status-only row diff is **0**.

**GATE 4 — surelog. GREEN.** default **467/13**, testflags **463/10**,
SURELOG_FAIL **25/23**, DEFERRED **5/5** ✓. `ct8rows` vs
`git show 49475c9:results/golden_surelog.csv` → **0 differing rows**, and both the
status and dump histograms are byte-identical baseline→fresh. Pristine's
histograms equal patched's in both modes ✓.

**GATE 5 — BYTE VERIFIER, both corpora both modes. GREEN.**

| corpus | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|
| surelog | **2 / 953** — `Earlgrey_0_1/default` (the target) + `Scoreboard/default` | 952/953 | 3 (= 1 corruption + 2 movers) |
| uhdm2rtlil | **0 / 1358** | 1357/1358 | 1 |

`PATH_SETS_IDENTICAL` on both. **1 real mover in 2311 databases.**

**CANARIES.** surelog `canaries.sh` **ok=52 changed=0 absent=0** ✓ (unknown-names=7,
the documented u2r-only set). `ctcan2` surelog `EXPECT_UNKNOWN=1` → **ok=58
changed=0 PASS**; u2r `EXPECT_UNKNOWN=6` → **ok=2 changed=0 PASS** (report says
ok=1; changed=0 either way). `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**
— but only when run from *this* pass's directory: the auditor scans
`dirname $0`, so running another pass's copy reports 4 breaches from that pass's
sibling `README.verifier.md`. **This file deliberately does not name the four
never-dispatch tests, so the audit stays clean here.**
u2r `canaries.sh` reads **ok=14 changed=2** (report says 8/0/0); both changed rows
are `paramod_genscope_child` `CMP_EQUAL/differ → CMP_EQUAL/match` and are
**identical in pristine** → V8, not the patch.
`InterfaceModPort`, `BlackParrotComplex`, `Earlgrey_0_1` checked BY NAME in both
modes: base = pristine = patched, unchanged.

---

## 3. THE HEADLINE AND THE ACCOUNTING — EVERY NUMBER EXACT

| claim | measured |
|---|---|
| cmp lines 596 → 17 | **596 → 17** (rc 255 both; heads 1 → 1) |
| pristine head | `named_begin: (work@padring.gen_mio_pads.gen_mio_input), id:128975` ✓ the brief's target |
| patched head (R1) | `LHS <null>` / `RHS ref_typespec (work@prim_prince.p_fwd_d64.data_state_round)`, 17 lines ✓ |
| dump lines pristine | **4 654 959** ✓ |
| whole-design delta | **0 removed / 260 added / 6 hunks** ✓ |
| anchors | every anchored added line at padring.sv **126/130/131/178/182/183** ✓; 0 other `line:` values |
| prediction (pre-build) | **10 statement objects across 4 block names** ✓ — `gen_{mio,dio}_{input,tie_off}` = **2+3+2+3** ✓ |
| post-patch census | **0 objects missing across 0 block names** ✓ |
| other-reason blocks | `hmac`, `hmac_core`, `ibex_multdiv_fast`, `ibex_multdiv_slow`, golden==ours, unchanged ✓ (R5) |
| multiset vs golden | **309261 → 309009 (−252)** ✓ |
| per-shape closure | **131 changed shapes, 110 to exact golden parity**, `SUM|g−o| 20190 → |g−p| 19938`, Δ **252** = the whole-design delta — **closes to the unit** ✓ |
| the 2 shapes moving away | `\|UINT:1\` (g2746 o2757 p2759) and `\|vpiDecompile:1\` (g2682 o2691 p2693) — **already surplus in pristine** ✓ |

Independent cross-check the report does not make: golden-only instances fall
**238875 → 238619 (−256)** while ours-only rises **70386 → 70390 (+4)**;
256 + 4 = **260** = the added lines. The 260 lines decompose exactly.

### GRID, cell for cell

| arm | names / DEF rows | measured |
|---|---|---|
| `a1_chain.sv` | **34 / 44** ✓ | **15 blocks / 38 statement objects** missing in pristine, **0** after ✓; `CMP_FAIL 280 → PASS_CMP` ✓; multiset **924 → 122** ✓ |
| `a2_fence.sv` | **58 / 61** ✓ | multiset **1698 → 849** ✓; cmp head 17 lines before and after, **byte-identical `cmp.log`** ✓ |

**Separating pair holds exactly.** In pristine, `gen_m3` (module level) is
**absent from the missing list** while `gen_w3` (same chain position, same
declaration, inside `for (genvar …)`) is **missing 2**. Fences that held in
pristine and were untouched: `gen_y2` (plain `else`, clause is a `GenerateBlock`),
`gen_z1`, `gen_p`, `gen_m1…m4`, `gen_w1`, `gen_d1`, `gen_x1`.
**No empty product cells in a1**: all 34 block names carry ≥1 golden statement;
0 blocks are 0-vs-0.

### F-claims

* **F1** ✓ `findNested`'s written law is false outside module level — confirmed by reading it.
* **F3** ✓ answered opposite to § 66: `a1 gen_d3` (written init `logic d3_init = 1'b0;`) golden 4 / pristine 0 / **patched 4**.
* **F4** ✓ EXACT: `blkcen38.py -v def` = **3321** rows, `-v all` = **5553**, golden dump has **190** `|uhdmallModules:` markers. The § 4 fence I ran uses the view-agnostic form (5553).
* **F5** ✓ **the strongest cell in the pass.** `a2` `gen_f1` `ref_typespec` counts, GOLD/PRIS/PAT: served `F1A_I` 1/1/1, `F1A_K` 1/1/1, `F1A_V` 1/1/1, untyped `F1A_U` **0/1/1** (pre-existing surplus, untouched); newly reached `F1B_I` 1/0/**1**, `F1B_K` 1/0/**1**, `F1B_V` 1/0/**1**, `F1C_I` 1/0/**1** (all to golden parity) and untyped `F1B_U` 0/0/**1**, `F1C_U` 0/0/**1**. The type policy in newly reached branches is **provably golden's**, and the only surplus is the one the served position already had.
* **F6** ✓ **proven harder than claimed.** Five pristine-binary runs of `Scoreboard` gave **two** md5s (`d24170f7…` ×4, `814cba97…` ×1) — and `814cba9780b8` is *exactly the md5 byteverify attributed to the PATCHED side*. `cmp` confirms **pristine run 2 is BYTE-IDENTICAL to the patched sweep's database**. Both states: 1 094 789 lines, **multiset distance 0**. The mover is pre-existing nondeterminism, not the patch.
* **F7/R6** ✓ `pred38.py` not used as a fence; R6 confirmed at V4.

---

## 4. MY OWN FINDINGS

**V1 — MONOTONE, proven stronger than the report argues.** The safety claim is
argued from `astBlock` being null at module level. I tested it directly instead:
across **four** corpora/arms, **not one dump line shape ever decreases in count**
pristine→patched.

| corpus | shapes DECREASED | line instances ADDED |
|---|---|---|
| Earlgrey_0_1 | **0** | 260 |
| a1_chain | **0** | 908 |
| a2_fence | **0** | 1037 |
| v1_outside (mine) | **0** | 358 |

The patch is **purely additive**; it never replaces a scope it had already found.

**V2 — the law reaches FURTHER than either grid measured (positive).** My arm
`v1_outside.sv` adds shapes the implementer's README names as untested. DEF-census
GOLD/PRIS/PAT:

* **bare-item `else` clause (no `begin`/`end`)** — `gen_b` **6 / 2 / 6 → FIXED**. The
  `kind == IfGenerate` conjunct fires on the chain link, and slang's implicit
  `GenerateBlock` for the bare item is then found in `astBlock`. Not in either grid.
* **chain inside a case-generate item inside a gen-for** — `gen_c0b`, `gen_c0c`,
  `gen_cdb`, `gen_cdc` all 0 → **2 = golden** (the deepest nesting tested).
* **chain in a submodule** — `sub38.gen_s.gen_s2` and `gen_s3` **2 / 0 / 2 → FIXED**.
* **type policy again** — `gen_h2` (package-**qualified** `vp38::vp_t`) 3/1/**3 FIXED**,
  while `gen_h3` (bare **wildcard-imported** `vp_t`) is **1/1/1** on both sides: the
  newly reached branch correctly does **not** stmt-ify it, matching golden.

**V3 — NEW RESIDUE (ranked R0 below): an `else if` chain inside an INTERFACE
definition is not reached at all.** `iface38.gen_i` / `gen_i1` / `gen_i2` / `gen_i3`
are **GOLD 2 / PRIS 0 / PAT 0** — and `gen_i2` has **0 lines in our dump against 15
in golden**. Even the *served* `if` block (`gen_i1`) is 0, so this is a larger,
separate defect: we emit **no DEF-view generate listing for interface bodies**.
Not a regression (0 before, 0 after), but it is precisely the shape the
implementer's own § 3 flagged and it is the cheapest un-owned target adjacent to
this law.

**V4 — the over-fire fences hold on the untested shapes.** `gen_u1…gen_u3`
(chain whose enclosing gen-if is **uninstantiated**): golden 0, pristine 0,
**patched 0** — the patch does not start emitting for uninstantiated blocks.
`gen_g1…gen_g3` under `generate…endgenerate`: **no census row on either side**
(golden itself emits nothing for `gen_g1`) — **R6's mutual abstention confirmed
independently**, and the patch does not disturb it.

**V5 — NARROWING of the grid's `REGRESSIONS 0` column.** That column is computed
on the DEF census (statement counts), which is **blind to weak-tail
multiplicity**. On the dump multiset, `a1` has **473 changed shapes: 447 toward
golden, 445 to exact parity, 15 unchanged, 11 AWAY** — and **7 of the 11 were
EXACTLY RIGHT in pristine**:

```
g=8 o=8 p=12   \_range: , line:124:13, endln:124:21
g=4 o=4 p=6    \_logic_typespec: , line:124:7, endln:124:21   (and 4 more at 124/125/50)
g=4 o=4 p=6    \_integer_typespec: , line:125:7, endln:125:14
g=4 o=4 p=6    \_logic_typespec: , line:50:7, endln:50:12
```

This is **R4** (one weak-tail typespec per *declarator*, where golden shares one
per declared *type*). **I verified the mechanism is pre-existing, per the
implementer's own instruction**: in *served* positions untouched by the patch,
pristine already over-mints — line 83 `gen_y1` g3/o4, line 85 `gen_y2` g5/o8,
line 91 `gen_z1` g3/o4, line 148 g2/o4, line 160 `gen_p` g6/o10 (all PRIS == PAT).
So **no new defect class** — but the honest grid row reads *"0 census regressions;
11 weak-tail shapes move away, 7 from exact"*, not *"0 REGRESSIONS"*.
Net is overwhelmingly positive: `a1 SUM|g−o| 1034 → |g−p| 54`; whole-design only
2 shapes move away.

**V6 — INSTRUMENT CAVEAT, extending F4/F7.** `cenpred38.sh` **double-counts
R2-renamed blocks.** Golden keys a case-generate item block by its **bare label**
and we key it by the **full scoped path**, so a newly-*correct* block is reported
BOTH as `MISSING` on golden's key AND as surplus on ours. In my `v1_outside` arm
this manufactured **4 false "regressions"** (`gen_c0b/c0c/cdb/cdc`, all actually
fixed). Proof it is naming only — the statement lists are character-identical:

```
golden : def gen_f3a0                              n=2  assignment@101:17-101:23[f3a0_x] assignment@101:25-101:31[f3a0_y]
ours   : def work@fence38.gen_f3.gen_f3a.gen_f3a0  n=2  assignment@101:17-101:23[f3a0_x] assignment@101:25-101:31[f3a0_y]
```

This **vindicates** the report's `a2` claim "0 statements STILL WRONG": all 11
residual a2 `MISSING` names are this artifact. (The report says 9 names; 9 are
leaf case-items and 2 are their parents — `gen_f6c0`, `gen_f6cd`. Framing, not
error.) The Earlgrey run is unaffected — no case-generate chain is among the movers.

**V7 — A FINDING I RAISED AND THEN RETRACTED, recorded because the method
matters.** Diffing `/tmp/wt_r10uvm67` against `49475c9` showed **5** `ModuleEmit.cpp`
hunks, two of them *inside* `emitDefGenStmts`, apparently contradicting the
boundary claim. That was a **BASE MISMATCH**: that worktree is checked out at
`00b7fda` (r10uvm66, *before* earl37), so the diff was showing earl37 being
"removed". Its **own** diff is **one** hunk, `@@ -20789` in `drainFuncRet`, with
**zero** hits for `emitDefGenStmts` / `findNested` / `elseClause`. **The boundary
claim HOLDS.** (This is the campaign's own recorded lesson — check each tree's
BASE before attributing any delta.)

**V8 — GATE 3's stated `ct8rows 0 rows` is NOT reproducible; the committed u2r
baseline is STALE.** 104 whole rows differ, and **none is this patch** (pristine
and patched CSVs byte-identical; status-only diff 0):

* **100 rows** — `SLANG_REJECT` *detail* text only: baseline has `dut.sv:12:11: error: …`,
  every current binary emits `/home/heyfey/git-repos/uhdm2rtlil/test/DpiChandle/dut.sv:12:11: …`.
  I reproduced the absolute form with the **main-tree** binary too, so this is a
  slang diagnostic-path change that predates this pass.
* **4 rows** — dump column `differ → match` for `ParameterSizeOfInstance` and
  `paramod_genscope_child`. **Not a flake**: stable `match` in **6/6** runs across
  both binaries. An improvement landed earlier and never refreshed into
  `results/golden_uhdm2rtlil.csv`.

Recommendation: refresh `results/golden_uhdm2rtlil.csv` (read-only to me) in a
dedicated bookkeeping step, or restate gate 3 as the status-only projection plus
the pristine-vs-patched byte identity. This is **not** a reason to hold the patch.

**V9 — HEAD HAS MOVED; re-gate before landing.** Base is `49475c9`, but repo HEAD
is now **`73dc976`** (`97f6f90` r10svs15 + `73dc976` r10yoo1 landed after the patch
was cut). `git apply --check` is **clean at `73dc976`** and the hunks are far apart
(`@@ -21352/-21400` vs this pass's `@@ -26279`), so there is no textual conflict.
But `results/golden_surelog.csv` now carries **4 promoted rows** (`SVSwitch`×2,
`YosysOldOr`×2), so a sweep at HEAD reads **469/11 + 465/8**, not 467/13 + 463/10.
Either land quoting the `49475c9` numbers exactly as measured here, or re-run
gates 3–5 at `73dc976`.

**V10 — the disclosed main-tree contamination is RESOLVED and the disclosure was
accurate.** The foreign uncommitted edits to `include/UhdmExporter.h`,
`src/ModuleEmit.cpp`, `src/UhdmExporter.cpp` were **r10svs15's**, and they landed
as `97f6f90` (same three files). The main tree now has **0** uncommitted
production edits; `scripts/`, `results/`, `tests/` are unmodified; there is no
`r10earl38repro` in the main tree. Note `r10svs15` is therefore **no longer a live
pass**. Every gate above passed `SLANG_UHDM` explicitly to my own binary.

**PRIOR-PASS ARMS HOLD.** With workdir-path and id normalisation (the documented
cross-workdir `file:` trap — my first reading falsely showed all four "changed"):
earl37 `a1_pact.sv`, `a2_fence.sv`, `v1_stamp.sv`, `v2_esc.sv` — **ours
byte-identical**, all four `cmp.log`s held. earl36 `a1_bound.sv`,
`a2_noimport.sv`, `a3v_gaps.sv` — **all HELD**.

---

## 5. RANKED RESIDUES

* **R0 (NEW, mine) — `else if` chain inside an INTERFACE gets no DEF-view generate
  listing at all.** `iface38.gen_i{,1,2,3}` GOLD 2 / PRIS 0 / PAT 0; `gen_i2`
  absent from our dump entirely (0 vs 15 lines). Wider than § 38 (the *served*
  branch is empty too), so it is a separate law in the same emitter. Witness in
  place at `v1_outside.sv`. **Cheapest next target.**
* **R1 — the NEW HEAD**: surplus `ref_typespec` on a function-local ref,
  `prim_prince.sv:91`, **17 cmp lines** — the shallowest head this design has had.
  A function-body family.
* **R2 — case-generate item block fullname**: golden = bare label (`gen_f3a0`),
  ours = full scoped path. Pre-existing, statement lists character-identical,
  9 leaf + 2 parent cells ready in `a2_fence.sv` and 8 more in `v1_outside.sv`.
  Also the cause of V6's instrument unsoundness — fixing it repairs the census too.
* **R3 — UNTYPED gen localparam** gets a `ref_typespec` from us, none from golden.
  Quantified at F5: exactly 3 cells (`F1A_U` served, `F1B_U`/`F1C_U` newly reached).
  One-conjunct fix, a2's cmp head.
* **R4 — weak-tail declaration-typespec duplication** (one per declarator vs
  golden's one per declared type). cmp-invisible; scales with declarations
  emitted; now the dominant residual surplus (V5). 7 a1 shapes and 2 Earlgrey
  shapes sit on it.
* **R5 — the four OTHER-REASON blocks** `hmac`, `hmac_core`, `ibex_multdiv_fast`,
  `ibex_multdiv_slow`: 12 census rows, one-character END-COLUMN shortfalls on
  procedural `assignment`s. Byte-identical across this patch. Well fenced.
* **R6 — `generate…endgenerate` around a gen-for**: agreed abstention, confirmed
  independently at V4 (golden emits nothing either). A future widening must not
  disturb it.
* **R7 (ops) — `results/golden_uhdm2rtlil.csv` is stale** in 100 `SLANG_REJECT`
  detail rows and 4 dump-column rows (V8). Costs every pass a false 104-row
  reading on gate 3.

---

## 6. WHAT I CHANGED

Nothing in production. I added one verifier arm,
**`tools/probe/r10earl38repro/v1_outside.sv`** (the V2/V3/V4 cells), and replaced
the implementer's empty verifier slot with this report. `src/ModuleEmit.cpp`
remains **32/5**. Sweep workdirs and multi-GB dumps deleted.
