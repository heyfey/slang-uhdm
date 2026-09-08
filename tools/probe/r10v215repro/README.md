# r10v215 — ADVERSARIAL VERIFICATION of r10uvm215 (`§ modportNeedsSimplePort215`)

**VERDICT: ACCEPT-WITH-FIX.** The law is real, decoded correctly, and every
headline number in the implementer's report reproduces **bit for bit** on
binaries this verifier built itself. One conjunct of the patch — the
**port-view FALLBACK** — was decoded ONLY from Surelog runs that **ERRORED**,
and on a Surelog run with **ZERO errors** it is measurably **wrong**: it takes
a design where the PRISTINE binary matched golden's modport counts EXACTLY and
pushes them away. Fixed in three lines; ship `/tmp/r10uvm215.verified.patch`.

**MEASUREMENT ONLY.** Nothing here is an acceptance judge; the official
`uhdm-cmp` and `scripts/verify_golden.py` are. slang was NOT patched;
`results/*.csv` were READ ONLY; `GOLDEN_DEFER` stayed unset; no fenced test was
dispatched. **LHS is ALWAYS golden.**

| | |
|---|---|
| BASE | `b7eb7ff3`, own worktrees `/tmp/wt_v215pris` / `/tmp/wt_v215` / `/tmp/wt_v215fix` |
| pristine | md5 `49b83611ebc24e7155c5e62e6c8e23e2` — **byte-identical to the main tree's `build/slang-uhdm`** and to the implementer's pristine |
| implementer's patched | md5 `5c5c3503c01fc9a957f4099deb0ba401` — **reproduced exactly**, 22 585 672 bytes (pristine 22 589 768: the 4096-byte SHRINK the implementer's false-mover argument rests on) |
| verifier-fixed | md5 `967765e2f329aadd3dc15abdb9543676` |
| surface of the fix | `src/ModuleEmit.cpp` + `include/UhdmExporter.h`, one defaulted `bool` parameter and one clause |

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Built both binaries, exported `SLANG_UHDM` per binary, audited **every**
`cmds.txt` by binary PATH (1573 + 1462 per workdir; the only `slang:` path in
each is the intended frozen binary — no main-tree binary anywhere).

* goldens **23 PASS / 0 FAIL** on both, `/bin/false` **0 PASS / 23 FAIL**;
* uhdm2rtlil **679 / 50 / 2** in BOTH modes on BOTH binaries; `ct8rows` PASS
  against the committed baseline and patched-vs-pristine; `byteverify`
  **MOVERS 0 / 1358**, SELFCHECK 1357/1358;
* surelog **475 CMP_EQUAL + 6 CMP_NOTEQUAL (default)** and **469 + 6
  (testflags)** on BOTH binaries — **NO ROW CONVERTED**; `ct8rows`
  patched-vs-pristine **0 differing rows over 1588**;
* the one row moving against the COMMITTED csv is `Earlgrey_0_1,testflags`,
  status **CMP_EQUAL on both sides**, dump column only — **and it moves on the
  PRISTINE binary too**, so it is environmental, not the patch. (It also makes
  `canaries.sh` read `ok=51 changed=1` here rather than the implementer's
  `ok=52 changed=0`; the CHANGED row is that same Earlgrey dump column, on both
  binaries. Named, not summarised.)
* surelog `byteverify` **MOVERS 2 / 956** — `SeqDriver` default and testflags,
  the two the implementer PREDICTED BY NAME. Attributed ORDER-BLIND (sorted,
  path-normalised dumps): **12 differing lines each, every one a `<`
  pristine-only line**, and all twelve belong to the two `mon_mp` modport
  objects (`\_modport: (mon_mp)` ×2, `|vpiModport:` ×2, `|vpiName:mon_mp` ×2,
  `|vpiParent:` ×2, `|vpiInterface:` ×1, the two `interface_inst` owner lines).
  **Nothing added.** (Scoreboard/default did not flip in this run — it is the
  coin; the implementer saw it flip, which is the same reading.)
* heads: pristine **SeqDriver ×2 = 209 cmp lines / 1 head**, `LHS: <null>` with
  RHS `interface_inst work@adpcm_if id:291911` — exactly the reported shape.
  Patched: **1 327 330 lines / 1 head**, head object `module_inst work@top_tb`
  (`testbench.sv:210`), `mon_mp` appears **0** times in the log, and the
  golden/ours top-level `|vpiNet:` counts are **448 / 382 = 2 × 224 / 2 × 191**
  — R0 confirmed. MiniAmiq ×2 unchanged at 838/1.
* the seven protected CMP_EQUAL row-modes (`SimpleUVM` ×2, `BuildUVMPkg` ×2,
  `Earlgrey_0_1` ×2, `Scoreboard`/default): **0 cmp lines, 0 heads, judge
  rc = 0 on both binaries**, and none is a byte mover.
* protected databases: **20 / 20 SAME**, `InterfaceModPort` byte-identical in
  both modes, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. `ctcan2` PASS
  ×3, `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
* the implementer's own five grid arms, re-scored here with a stronger pairing
  (below), reproduce their published cells exactly: A **10/10 → 0/0**, B
  **3/9 → 3/1**, C parse **7/15 → 0/0**, C elab **6/22 → 0/8**, D **0/0 → 0/0**
  (and `d_muststay`'s databases are BYTE-IDENTICAL on the two binaries),
  E **2/4 → 0/0**.

## 2. TWO METHOD DEFECTS IN THE IMPLEMENTER'S GRID

**(a) THE "elab" COLUMN DID NOT ELABORATE OUR SIDE.** `grid215.sh` passes
`-elabuhdm` to Surelog only; our binary is invoked identically in both columns
(`"$BIN" "$b.sv" -o ours.uhdm`), so the published "elab" column scores
golden-elab against our **def** database. `verify_golden.py:369-370` maps
`-elabuhdm` to `--elabuhdm` on our side. Not a false green — the modport census
of our def and elab databases is IDENTICAL on those arms (measured) — but the
column tests half of what it says. `gridv215.sh`/`gridfix215.sh` here pass
`--elabuhdm` to both sides, and every published cell survives.

**(b) THE FALLBACK CONJUNCT WAS DECODED FROM ERRORED SURELOG RUNS.** Arm
`c_topology` — the ONLY arm that decoded the port-view fallback — ran Surelog
at **rc=4 in both views**. The recorded `rc_surelog=4` is in the committed
transcript; the README calls it "one REAL Surelog golden each" and never
mentions it. The error is
`[ERR:CP0317] Undefined type "c1_if.mpc"`: Surelog cannot resolve a port whose
type names a modport it never entered into `m_modportSignalMap` — the same map
whose emptiness IS this pass's law. So the cells that taught the fallback are
Surelog **error-recovery** databases. (`e_virtual` elab is rc=4 as well.)
That is not automatically disqualifying — `verify_golden.py` marks
`SURELOG_FAIL` only when NO database is produced, so an errored-but-produced
database IS the golden the corpus is judged against — but it means the conjunct
was never tested on an input Surelog accepts.

## 3. THE BREAK: A GENERIC INTERFACE PORT, SURELOG rc = 0

`armsv215/v1_generic.sv` — `module v1_sub (interface p);` with three
connections to one interface that has `mpc (clocking cb)`, `mpa (input clk)`
and `mpb (output d)`:

```
  v1_sub s_c (.p(i1.mpc));   // connection names the CLOCKING-ONLY modport
  v1_sub s_a (.p(i1.mpa));   // control: a minted modport
  v1_sub s_p (.p(i1));       // control: plain
```

Surelog compiles it with **`[ ERROR ] : 0`**. On the generic road
`ModuleEmit.cpp` ~9465 takes `connModport` from the CONNECTION
(`conn.second->name`), so the patch's fallback fires — and golden does the
opposite of what arm C taught: **golden gives `s_c.p` a bare `logic_net` and no
`interface_inst` at all**, so golden's whole design contains

| object | golden | pristine | implementer's patched | verifier-fixed |
|---|---|---|---|---|
| `\_modport: (mpa)` | **11** | **11** | 13 | **11** |
| `\_modport: (mpb)` | **8** | **8** | 10 | **8** |
| `\_modport: (mpc)` | 0 | 6 | 0 | 0 |
| `interface_inst (work@top.s_c.p)` | 0 | 6 | 8 | 4 |

**The pristine binary matched golden EXACTLY on `mpa` and `mpb`; the patch
moves both away.** Whole-dump signed-distance scorer (`dumpcen215v.py`):
patched **AWAY=24**, and `ONLY-GOLDEN` grows 37 → 39. The 24 lines are exactly
the manufactured `mpa`/`mpb` objects in the `s_c.p` view with their `io_decl`s,
names, directions and `vpiExpr`s.

## 4. THE FIX — `§ modportNeedsSimplePortNoGenericFallback215v`

**THE FALLBACK BELONGS TO THE DECLARED MODPORT-QUALIFIED PORT ALONE.** One
defaulted `bool connModportFromConn` marks the generic road at the single call
site that can take a modport name from a CONNECTION rather than from a port
DECLARATION (`ModuleEmit.cpp` ~9465 — the other six `emitInterfaceInstance`
call sites pass either `ip.modport` or nothing), and the fallback's
`connMinted215` seed reads it. On that road the existing connected-modport
filter simply matches nothing, so the view lists NOTHING — which is as close to
golden's "no view at all" as this pass can get without touching the
pre-existing decision to emit the view.

| | patched | fixed |
|---|---|---|
| v1_generic parse, whole-dump | AWAY **24** / TOWARD 25 | AWAY **2** / TOWARD 33 |
| v1_generic elab, whole-dump | AWAY **24** / TOWARD 20 | AWAY **2** / TOWARD 28 |
| v1_generic modport census `ONLY-OURS` | 2 | **1** (pristine 5) |
| every OTHER arm-view scored here (28 of 30) | — | **databases BYTE-IDENTICAL to the patched binary** |
| the WIDE BOUNDARY, patched vs fixed, 5514 arms both views | — | **MOVED_ARMS=4, RC_DIFFS=0**: `v1_generic.sv` (this verifier's own arm, the positive control) plus the three STATIC-ADDRESS false movers |

The residual **AWAY=2** is one line, `\_interface_inst: work@v1_if
(work@top.i1)` — golden 18, pristine 19, patched 15, fixed 15: a knock-on of
the MAIN gate (the dropped modports also carried `Interface_inst`
back-pointers), not of the fallback. Recorded as R2 below.

## 5. THE ADVERSARIAL GRID (10 new arms × 2 views, one REAL golden each)

`gridfix215.sh` builds THREE of our databases per arm-view — pristine, patched,
fixed — against ONE golden, and scores both the modport census
(`ct215mpcen` + `cen215.py`, golden-vs-golden CALIBRATED NULL in all 20
arm-views) and the whole-dump signed-distance metric. Every rc is recorded; no
arm produced a rc change on any binary (no hidden 139).

| arm | face (the brief's list) | census pris → pat → fix | verdict |
|---|---|---|---|
| `v1_generic` | generic `interface p` port bound to a clocking-only modport, **Surelog rc=0** | 0/5 → 0/2 → **0/1** | **THE BREAK**, fixed |
| `v2_onealt` | the fallback at **N=1** surviving modport (grid C had only N=0 and N=2) | 1/6 → **0/0** → 0/0 | law holds |
| `v3_tfport` | an **import-only** modport as a port qualifier | 1/6 → **0/0** → 0/0 | law holds |
| `v4_array` | **interface instance ARRAYS**, element ports and a whole-array `p[2]` port | 2/9 → **1/2** → 1/2 | law holds |
| `v5_nested` | **top / nested / never-instantiated**, interface inside an interface | 4/8 → **3/1** → 3/1 | law holds (R1 residue) |
| `v6_hier` | a **hierarchical read through** the dropped modport (`i1.mpc.cb.frame`) | 0/3 → **0/0** → 0/0 | no dangling reference |
| `v7_mult` | **1, 2 and 3 instances** of clocking-only-modport interfaces at once | 9/9 → **0/0** → 0/0 | law holds |
| `v8_mixed` | the `InterfaceModPort` canary's literal `modport MEM (clocking cb, input clock)` beside `import+simple`, `export+simple`, `clocking+import`, `ref`, `.P(expr)` | 0/3 → **0/0** → 0/0 | **only the all-non-simple modport drops** |
| `v9_bind` | a **BOUND** interface (`bind v9_dut v9_if b_if()`), two target instances | 2/7 → **2/2** → 2/2 | law holds |
| `v10_dropall` | **every** modport dropped on an instantiated, plainly port-connected, hierarchically read interface | 7/21 → **0/0** → 0/0 | no null-vector crash |

## 6. RESIDUES (ranked)

* **R0** — the pass's own R0 stands and is confirmed: SeqDriver ×2 now stop on
  `module_inst work@top_tb`, `vpiNet` vector size **golden 224 / ours 191**.
* **R1** — an interface that instantiates an interface is missing entirely
  (`v5_nested`, and the implementer's arm B b4): 3 ONLY-GOLDEN rows both views,
  PRE-EXISTING and untouched by patch or fix.
* **R2** — dropping a modport also drops its `Interface_inst` back-pointer, so
  a design that keeps other modports can UNDER-produce the owner
  `interface_inst` line (v1_generic: golden 18, pristine 19, patched/fixed 15).
  2 whole-dump lines on a synthetic arm; the object-level census is strictly
  better after the law. Not a judge-visible field on any corpus row.
* **R3** — `c_topology` parse keeps 5 whole-dump lines AWAY (`|vpiActual:` ×3,
  `|vpiInterface:` ×2) on both patched and fixed: the LowConn bindings the
  dropped def-view modports used to carry. Its census is **0/0**, and the
  golden concerned is an error-recovery database.
* **R4** — the elaborated port view is doubled (the implementer's R2), 8
  ONLY-OURS rows on arm C elab; PRE-EXISTING, and the law shrinks it 22 → 8.

## 7. FILES

| file | what it is |
|---|---|
| `armsv215/*.sv`, `armsv215b/*.sv` | the ten adversarial arms |
| `gridv215.sh` | the two-binary grid with the view pairing corrected |
| `gridfix215.sh` | the THREE-binary grid (pristine / patched / fixed) |
| `dumpcen215v.py` | the whole-dump SIGNED-DISTANCE scorer — the instrument that sees a regression the modport census cannot |
| `GRIDV.txt`, `GRIDIMP.txt`, `GRIDFIX.txt`, `GRIDFIXIMP.txt`, `GRIDB.txt` | the transcripts |
| `GATES.r10v215.txt`, `BOUNDARY.r10v215.txt` | the gate and boundary transcripts |

## 8. THE WIDE BOUNDARY, BOTH DIRECTIONS

`bound215.sh` over a COPY of the whole probe tree, both views, every rc
recorded. **LISTED 5514 = PROCESSED 5514, RC_DIFFS 0** on both runs.

* **pristine vs the implementer's patched: MOVED_ARMS = 12** — the
  implementer's 8, reproduced name for name (four of its own `grid215` arms
  with `d_muststay.sv` correctly NOT moving, `r10v125repro/arms/v7_recv.sv`
  which the law fixes, and the three static-address false movers), plus this
  verifier's four then-new arms.
* **patched vs fixed: MOVED_ARMS = 4** — `armsv215/v1_generic.sv`, this
  verifier's own arm and the positive control, plus the same three false
  movers. The fix's semantic footprint over 5514 arms is exactly the one arm
  it was written for.
* The static-address false mover is convicted independently here:
  `r10uvm154repro/l154_noenum.sv` contains `interface`/`modport` **zero**
  times, and its whole-dump difference is ONE constant — `22744825` pristine,
  `22740729` patched, **`22744825` again on the fixed binary** (whose size,
  22 589 784, is back above the page boundary) — 4096 apart, at dump line 679,
  **below** the `\_weaklyReferenced:` marker at line 646.
* 17 arms in the tree segfault under `--elabuhdm` on **all three** binaries
  (symmetric, RC_DIFFS 0): pre-existing at BASE, not this pass.
* The 17 `r10uvm213repro`/`r10uvm214repro` arms are in the listing and moved on
  neither run.
