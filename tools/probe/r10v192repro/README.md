**VERDICT: ACCEPT.** `/tmp/r10uvm192.patch` stands unchanged — no `.verified.patch` shipped, because no adversarial arm produced pristine-right → patched-wrong on legal SV.

## Every headline number reproduced bit-for-bit

I built both binaries myself from clean `6ee26f73` worktrees (`/tmp/wt_v192pris`, `/tmp/wt_v192`), froze them `chmod 555` at `/tmp/v192_bin/{pris,pat}.bin` **before** any sweep, and exported `SLANG_UHDM` explicitly per binary.

| claim | my measurement |
|---|---|
| pristine md5 `2b2aa40f9a4ceee88eda2e4ea249e19e` | **identical** |
| patched md5 `305893f7c07f44a90a61eb96230f2f3c` | **identical** |
| head BuildUVMPkg **300 → 31**, ONE head, both modes | identical; the two patched cmp logs are byte-identical (`d18aa1f83dcf`); pristine DB `f3744d2da5c0` → patched `c187864f28a6`, both modes |
| every other row unchanged | SeqDriver 55/55, SimpleUVM 664681, Scoreboard/default **95**, MiniAmiq 55/55, Earlgrey 31/92, Rggen 0 |
| movers **9/956** sl, **0/1358** u2r, all predicted BY NAME | identical, same 9 names, same cell counts (13/6/6/6/6 + 13/6/6/6); `PATH_SETS_IDENTICAL`, SELFCHECK 955/956 and 1357/1358 |
| census TO-GOLDEN **68** / AWAY **0** / MOVED-WRONG **0** / MISSED **0** | identical; AGREE 129 994 → **130 062**, golden-only 23 403 → 23 335, `moves-left=0` in all nine |
| grids TO-GOLDEN **40** / AWAY 0 / MW 0 | identical (10+10+6+14) |
| boundary RC_DIFFS 0; the 17 non-192 movers score **122** TO-GOLDEN / 0 / 0 | identical, arm by arm (18+16+6+12+2+2+2+2+4+2+6+4+2+6+30+4+4 = 122), the 2+3 abstentions unchanged under both binaries |
| floor 33 families MOVED = 0 | confirmed by name, including `r10uvm185repro/grid185/g185_{a..e}`, `r10uvm190repro/grid190/g190_{a,b,c}` + `probe0`, `r10uvm170repro/g170_{a..e}` |

Independent decode checks: `ct192own`'s **TWIN TEST** confirms we list `get` and `uvm_root::get` on **both** sides (the brief's "golden lists twice, we list once" framing is refuted), and its **DESCENT TEST** names `func_call::Function` (vpiType 20, singular) at `uvm_pkg.sv:9855` as the edge that reproduces the head. `ct192view` reproduces the view map to the object (DEF 979/927-qualified/0 class_defns; ELAB 52/0/327) on golden and ours alike. I re-read `CompileHelper::getTaskFunc` ([CompileExpression.cpp:349](../../git-repos/Surelog/src/DesignCompile/CompileExpression.cpp#L349)) and `UhdmWriter::writePackage` ([UhdmWriter.cpp:1237](../../git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp#L1237), called at [:4944](../../git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp#L4944) elaborated and [:4979](../../git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp#L4979) un-elaborated) — the decode is exact, and `dest_classes` comes from `pack->getClassDefinitions()`, empty on the un-elab copy, which is why one rule prints as two bindings.

Gates: goldens **23/0** on both binaries, negative control **0/23**; `ct8rows` **PASS ×7** (0 differing rows over 1588, 731, 731 — baseline-vs-pristine, baseline-vs-patched and pristine-vs-patched, status **and** dump column, status histograms identical so no rc=139 masquerade moved); canaries `ok=52`/`ok=8` `changed=0`; `ctcan2` PASS ×2; `canaudit` PASS `audited=29 UNCOVERED=0 FENCE-BREACH=0`; all 10 protected DBs SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. Every `cmds.txt` audited by PATH: 1573+1573+1462+1462 files, **zero** lines naming any binary but the frozen one. `results/*.csv` untouched, `GOLDEN_DEFER` unset, fence scan 0 outside `canaudit.sh`. The patch applies **plain** (`git apply --check` rc 0) on a fresh `6ee26f73`, on `9c358cda`, and on the current main-tree `cc77bafe`; production hunks are identical under plain and 3-way apply.

**The strongest structural fact, which the implementer did not state:** the production diff is `16+/0-`, `181+/0-`, `6+/0-` — **203 added lines and ZERO deletions**. No existing law, fence or code path is modified; the pass is purely additive.

## Breaking the law — 6 new arms, real Surelog goldens, both views

`/tmp/v192_scratch/arms/v192_{a_import,b_collide,c_pkgname,d_free,e_scopes,f_ctor}.sv`, run through the pass's own `grid192.sh`/`score192.py`. All six DIFFER in both views, so the law fires in all six.

| arm | face tested | verdict | agree def / elab |
|---|---|---|---|
| `a_import` | explicit-item `import P::Cls` vs wildcard, transitive `export`+import chain | TO-GOLDEN 8, AWAY 0, MW 0 | 1→5, 6→10 |
| `d_free` | free package function **and task** vs a class method of the same name, called bare / package-qualified / class-qualified | TO-GOLDEN 6, AWAY 0, MW 0 | 9→12, 24→27 |
| `e_scopes` | module / interface / program callers, a class declared **in a module** with an out-of-body method, in-body vs extern | TO-GOLDEN 2, AWAY 0, MW 0 | 1→2, 3→4 |
| `f_ctor` | out-of-body `new`, `super.new`, virtual out-of-body methods, derived-class static inheritance | TO-GOLDEN 4, AWAY 0, MW 0 | 8→10, 18→20 |
| `b_collide` | an importer that **also declares its own class of the imported name** | 6 MOVED-WRONG — **scorer artifact**, see below | 0→3, 3→6 |
| `c_pkgname` | a **class whose name equals a package name** | 3 MOVED-WRONG — **the one real gap** | 0→0, 2→2 |

No arm's agreement count fell. Subroutine-object (`SUB`) counts are identical pristine vs patched in every arm and every view — **the listing is untouched**, so "a method golden lists once stays listed once" holds by construction, and the three binaries agree with golden on the DEF side in all six arms.

**`b_collide` is not a wrong binding.** `deltaP` wildcard-imports `alphaP` *and* declares its own `Same`. Golden's `deltaP` DEF listing holds 3 entries (only alphaP's clone `Same::val`@8); ours holds 4 (that clone **and** deltaP's own `Same::val`@50). The patched face string is byte-identical to golden's — `function|Same::val|package|deltaP` — and only the census key's listing-size column differs (4 vs 3), which is what the scorer counts as MOVED-WRONG. That is the implementer's R1 multiplicity residue reading through the key, and agreement went **up** in both views.

**`c_pkgname` is the real gap, and it is not a regression.** `getTaskFunc` tries `design->getPackage(head)` **before** the component scan, so with `package Twin` and `class Twin` in `hostP`, golden binds `function|m|package|Twin` (and `task|mt|package|Twin`). Pristine binds `function|m|class_defn|Twin` — already wrong; the patch moves it to `function|Twin::m|package|hostP` — wrong differently. The compare-visible agree count is **flat** (def 0→0, elab 2→2), and the one ELAB cell where pristine already agreed is bound to a *package*-parented function, so fence 1 excludes it and the patch leaves it alone.

**Why no pristine-right → patched-wrong can exist.** Fence 1 only touches a call already bound to a CLASS_DEFN-parented method. For golden to be right there while the same view's listing carries an exact-named `C::m` entry, Surelog would have to have skipped its own component scan — which happens only through the package-name-first arm, i.e. exactly `c_pkgname`, where pristine is already wrong. Every other route leaves the fence abstaining: an in-body method puts no `C::m` in the listing; the ELAB view reparents and renames it into the class; a package-qualified spelling binds a package sub and fence 1 refuses. Confirmed empirically — `AWAY-GOLDEN = 0` across 118 corpus cells, 40 implementer grid cells, 122 boundary cells and my 27.

Determinism: the patched binary produced byte-identical BuildUVMPkg databases on 3 consecutive runs (so does pristine), so the `AllObjects()` iteration order does not reach the result — as the code structure implies (each call is re-pointed independently from a deterministic `Task_funcs` vector, and fence 3's ownership answer is a search-until-found boolean).

## Ranked residues

1. **R-A (new) — the law has no PACKAGE-NAME-FIRST term.** Before fence 4, abstain when the head segment of the written name is a package `VpiName` in the design that lists an entry named the tail segment. Strictly narrowing, mirrors [CompileExpression.cpp:353-371](../../git-repos/Surelog/src/DesignCompile/CompileExpression.cpp#L353) exactly, and costs zero corpus cells (the shape is absent from all 956+1358 pristine databases — predicted movers are unchanged). I did **not** ship it: it repairs no regression, and the standing rule scopes verifier fixes to pristine-right→patched-wrong.
2. **R-B (new) — fence 3's ownership test is O(AllObjects) per candidate cell.** 118 cells × ~1 M objects on BuildUVMPkg. Measured **1.25 s → 1.48 s (+18 %)**, three runs each, on the largest UVM database. One `class_defn name → package name` map built once per design removes it. No gate is near a timeout (the 1 TIMEOUT row in the surelog histogram is identical before and after).
3. **R0 (implementer's, confirmed exactly)** — the new BuildUVMPkg head: golden's `bit_select (uvm_pkg::uvm_packer::unpack_string::unpack_string)` id 72450 @22952:7-22952:23, `vpiIndex` the loop `i`, `RHS: <null>`, owner the `assignment` id 72448 above it. Both modes identical.
4. **R1 (confirmed, sharpened)** — wildcard-import clone multiplicity, now with a second witness: an importer that also owns a class of the imported name lists **both** copies where golden lists one. `SUB` counts pristine == patched everywhere, so this pass does not touch it.
5. **R2 (confirmed)** — the 2 + 3 abstentions in `v144_a_homes` / `vb32m1`, identical under both binaries.
6. **R3 (confirmed)** — slang refuses `function int Outer::Inner::spool();`, so that grid row is UNREACHABLE, not agreeing.
7. **R-C (new, documentation — fix before landing).** `tools/probe/r10uvm192repro/grid192/g192_c_home.sv` still carries the **refuted** callee-home reading in its header: *"the law must fire in hearthPkg's own bodies and NOWHERE ELSE"* and *"home is hearthPkg, this listing is forgePkg's, so the split must hold the cell still."* The README §5, the production comment and the measurement all say the opposite (the caller's home; golden binds forgePkg's own clone entry in `Bellows::ownCaller`). My `v192_b_collide` independently reproduces the caller-home result via `gammaP`. The committed evidence should not contradict itself.
8. **R-D (environment fact, not this pass's)** — 16 of the 5142 boundary arms segfault under `--elabuhdm` on **both** binaries (symmetric, `RC_DIFFS 0`), so the elab half of those 16 tests nothing.

Evidence: `/tmp/v192_bin/{pris,pat}.bin` (frozen), sweeps `/tmp/v192_wd/{pris,pat}_{sl,u2r}` + the 6 CSVs, `/tmp/v192_scratch/` (arms, censuses `cen_pris`/`cen_pat`, grids `G_*`/`g_*`, boundary `bnd_out/{LISTED,MOVERS}`, `PREDICT.{sl,u2r}.txt`, `bv_{sl,u2r}.txt`, `heads_{pris,pat}`, `own_pris.txt`). Worktrees `/tmp/wt_v192`, `/tmp/wt_v192pris` left in place for re-check.