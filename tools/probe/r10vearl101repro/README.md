# r10vearl101repro — adversarial verification of r10earl101 (§ elabVecPortTdElemBare101)

Assembled at the master from the verifier's scratch (13 arms x 2 views, its controls, head logs and measurement texts);
the verifier shipped no patch (verdict ACCEPT, the implementer's patch unchanged). The text below is the verifier's final report, verbatim.

---

**VERDICT: ACCEPT** — `/tmp/r10earl101.patch` ships unchanged. No `.verified.patch` (no pristine-right→patched-wrong case survived 13 adversarial arms × 2 views, 2314 corpus databases and a 4626-file wide boundary).

## 1. Bit-for-bit reproduction

Both binaries built here from fresh worktrees at `01603ea` (`-j 2`, md5 separate, frozen `chmod 555`):

| | measured md5 | claimed |
|---|---|---|
| pristine | `12ca2375a6526d77e8495b267b8c83d8` | `12ca2375a652` ✓ |
| patched | `2eaa7a60ddb4894e841d4255ec147fa1` | `2eaa7a60ddb4` ✓ |

Patch applies to a fresh `01603ea` under plain `git apply --check` (no 3-way needed); surface is `src/TypeEmit.cpp` + `tools/probe/r10earl101repro/` only; fence check 0/0/0/0.

`rowheads.sh`: **Earlgrey_0_1 132/132 → 58 (default) / 62 (testflags), 1 head throughout**; SeqDriver 29, SimpleUVM 29, Scoreboard-def 145, MiniAmiq 106, BuildUVMPkg 321, Rggen-def 0 — all unchanged. Head decoded here from my own cmp logs: before = `logic_typespec (sha_word_t)` id 462455 failing on `VpiName` (typespec::Compare's first field); after = R0 exactly as `PREDICT_R0.txt` names it — `pinmux_pkg.sv:20`, golden `constant 20:32-20:39 INT:1 vpiConstType:7` vs our `operation vpiOpType:11` with `ref_obj NStraps` + `constant 1`.

## 2. Gates, all re-run

Goldens **23/0** on each binary (`SLANG_UHDM` exported per binary), `/bin/false` **0/23**. Status histograms identical pristine↔patched (surelog 471/283/25/10/5 and 466/284/23/9/5/3/2/1/1; u2r **679/50/2** both modes both binaries). `ct8rows` **PASS on 7 comparisons**, `results/*.csv` untouched, **no row converts**. `cmds.txt` audited by binary path: **6070 files, 0 main-tree**. Canaries `ok=52`/`ok=8` changed=0, ctcan2 PASS×2, canaudit **audited=29 UNCOVERED=0 FENCE-BREACH=0**. Pins hold (`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`; other three SAME both modes).

`byteverify SELFCHECK=1`: u2r **0/1358**; surelog **3/956** — the two predicted Earlgrey rows plus `default/Scoreboard`, which is the documented coin: raw normalised dump diff **92 lines**, **order-blind diff 0 lines**. `PATH_SETS_IDENTICAL` both corpora.

## 3. Corpus census, rebuilt from scratch

| | DBs | BOTH-SAME | ONLY-GOLDEN | ONLY-OURS |
|---|---|---|---|---|
| u2r pristine → patched | 1358 | 7040 → **7040** | 48 → **48** | 46 → **46** |
| surelog pristine → patched | 956 | 120327 → **120329** | 9608 → **9606** | 14765 → **14763** |

u2r is bit-identical before/after (zero population; its only one-sided `ts>e` rows are 6 `enum_typespec` cells per mode in `VarPassedTo2Submodules`). The surelog delta is **exactly two paired rows removed, nothing added** — the `u_sha2 PORT digest ts>e` cell, once per mode. The law's population now **matches golden exactly corpus-wide**: `E|PORT|BARE` golden 2 / ours 0→**2**, `E|PORT|QUAL` golden 2 / ours 4→**2**, `D|PORT|QUAL` 4/4 untouched; every other bucket byte-identical.

## 4. Breaking the law — 13 arms × 2 views, **TO-GOLDEN 81 · AWAY-GOLDEN 0 · ADDED 0 · REMOVED 0**

Program port · re-export (`export p::t;`) · same typedef name in two packages both directions · module-local shadow + local-of-package · **bind** + generate-loop · 3-deep chain + instance array + 3 instances of one span · interface + modport + interface array · non-port sites (class property, struct member, function return, nested typedef, gen-scope decl, cast, parameter type, net, variable) · 8 typedef kinds × 4 import forms · **top module's own port** and a never-instantiated top · orphan def entry beside 3 elaborated copies · parameterized module with two specializations + generate-if + `$unit` import. One head on every cell; `uhdm-cmp` line count unchanged on every cell. `v8_sites101` and `v10_neg101` produce **byte-identical databases** on both binaries in both views.

Three measured facts worth keeping:
- **The D/E split is golden's own.** `v11_toponly101`: golden's `D` entry keeps `p11v101::t_t`, its `E` top instance spells `t_t`; patched reproduces both, pristine gets `E` wrong.
- **The alias-of-an-alias is the one counterexample to "elaborated ⇒ bare"** — golden keeps `p9v101::aa_t` qualified in the `E` view — and `aliasOfAlias` correctly keeps it out of `pkgScalarTd`. Enum/struct elements likewise qualified in golden and untouched.
- **`AllPrograms` is not in `defRoots101`** (`src/TypeEmit.cpp:8939`), so `elabOwned101` (`src/TypeEmit.cpp:8948`) would classify a program's DEF listing port as ELAB. Inert today: our emitter gives a program port no `vpiTypespec` at all (measured in both views on `v1_prog101`), so `pt18->Typespec()` is null and the law never fires.

## 5. Wide boundary (4626 files = the pass's 4613 + my 13 arms)

`PROCESSED = LISTED = 4626`; `identical 8840 · DIFFERING 40 · no_output 372`; rc symmetric side for side (`0:8507/8507, 3:358/358, 4:373/373, 139:14/14`). **40 of 40 attributed, zero unattributed**: 22 = my firing arms (positive control), 10 = the pass's, 2 = `g1_portkind77`, 2 = `g1_elemdims88`, 2 = `g22.sv`, 2 = `l154_noenum.sv`. Every must-stay control directory — `r10earl100/96/97/95repro`, `r10uvm140/98/97/112/114repro`, `r10earl59/60repro` — has **0 differing cells**.

Arithmetic reconciliation with the pass's own boundary: `8835 + 4 = 8839` and `19 + 22 = 41`; I measure `8840 / 40`, i.e. **exactly one cell that differed for the pass is identical here** — `r10vrgg3repro/xi_iface_param_type/dut.sv` (elab). That independently confirms its R4: a nondeterminism, not a law effect.

Each attributed non-arm cell re-scored against a Surelog golden built here: `g1_portkind77` cmp **18747→18747** / **20668→20668**, `g1_elemdims88` **334→334**, `g22` **1719→1719**, `l154_noenum` **8→8** — head logs **byte-identical**, census **0/0/0/0** on all four.

## 6. Corrections to the implementer's report (neither changes the verdict)

- **`r10earl88repro/g1_elemdims88.sv` is mis-attributed as "id numbers only".** The law *does* fire there: 56 dump lines, `p88::v8_t`→`v8_t` at 28 element sites across `u_drv`/`u_und`/`g88[0..1].u_gen`. It belongs to the `g1_portkind77` family — golden's `i_v8_d1`/`o_v8_d1` carry only a `ts` key and no `ts>e` at all, so the move is equidistant and judge-invisible (verified independently above).
- **The per-cell cmp-line numbers do not reproduce.** The report quotes 37725 / 43533 / 8753 / 816; a standard golden-vs-ours `uhdm-cmp` gives 18747–20668 / 334 / 1719 / 8. The invariant they were quoted for (unchanged before↔after) reproduces in every case; the numbers themselves should not be carried forward.

## 7. Ranked residues

1. **V-R1 — `design->AllPrograms()` missing from `defRoots101`.** Latent misclassification of a program's DEF listing port; zero population today (no `vpiTypespec` on program ports) and zero corpus movement. `ct101cen.cpp` shares the blind spot (it never emits a program's ports), so a future regression there would be census-invisible — cover it by dump inspection or add `AllPrograms` to both.
2. **R2 (pass's) — `pkg::vec_t [N:0]` scoped ports.** Golden emits a *scalar* typespec with no wrapper; we mint wrapper+element. Confirmed on `g1_portkind77`, `g1_elemdims88` and my `v9_kinds101`/`v11_second101`. Judge-invisible because our wrapper's `VpiName` is empty and `typespec::Compare` stops there. Its own law.
3. **R1 (pass's) — the same `digest`'s elaborated NET binds the wrapper where golden binds the scalar.** Corpus population `E|NET|QUAL golden=0 ours=2`, identical on both binaries. Judge-invisible today (`nets::Compare` never reads `Typespec()`).
4. **V-R3 — the census payload carries the span**, which no generated `Compare` reads. That can only split rows, never hide a name flip: `AWAY-GOLDEN 0` is sound, `TO-GOLDEN` is a lower bound.
5. **R3/R5 (pass's) — non-port element sites; the pre-existing rc=139 segfaults** (14/14 symmetric side for side here).

**R0 confirmed, both modes, one object:** `pinmux_pkg.sv:20`, `parameter int MioStrapPos [0:NStraps-1]` — golden folds `NStraps-1` to a constant stamped at the identifier's span; we keep the symbolic `operation`. `range::Compare` reads `Left_expr`/`Right_expr`, so the head is the expression's kind.

**Artifacts** (all absolute): frozen binaries `/tmp/v101_pris.bin`, `/tmp/v101_lawA.bin`; sweeps `/tmp/v101_wdp` (pristine), `/tmp/v101_wda` (patched); scratch `/tmp/v101_scratch`; boundary stage `/tmp/v101_widest`. Verifier evidence dir `/tmp/wt_v101/tools/probe/r10v101repro/` (README.md, GATES_V101.txt, ARM_V101.txt, BOUNDARY_V101.*, CEN_*_v101.txt, 13 arms, varm101.sh), shipped as **`/tmp/r10v101repro.patch`** (1463 lines, probe-dir only, fence-clean) for the master to `git add` alongside the landing.