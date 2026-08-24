# r10v80 — ADVERSARIAL VERIFICATION of r10earl80 (§ ovHopOverriddenKeepsValue80)

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
**BASE `08918a1`.** `results/*.csv` READ ONLY, untouched, no row converted.

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's
report reproduced bit-for-bit from binaries I built myself. One delivered-state
defect found and fixed by me (`canaudit.sh` exited 6 on the delivered
directory — see §5). One new residue named. No regression on legal SV.

---

## 1. What I rebuilt, and the identity of the two binaries

Two fresh worktrees at `08918a1` (`/tmp/wt_v80pris` pristine, `/tmp/wt_v80`
patched), configured and built `-j 2`, md5 taken separately, then FROZEN
(`chmod 555`) at immutable paths before any sweep:

| | md5 | matches implementer |
|---|---|---|
| pristine | `f00c80b5d81b496f56f6cb3ec1f270b3` | yes |
| patched  | `d25629a1bbfe4c85699721f097caced8` | yes |

`/tmp/r10earl80.patch` (md5 `d4955c6a00ca0bf2d76e10d8cac687d5`) applied to a
fresh `08918a1` with `git apply --whitespace=error`, rc 0, surface
`src/ParamEmit.cpp` + `tools/probe/r10earl80repro/` only.

Every `cmds.txt` in every sweep workdir was audited BY BINARY PATH:
surelog 1573 files / 1523 binary lines each side, uhdm2rtlil 1462 / 1458 each
side, **100 % the frozen binary, zero main-tree leakage.**

## 2. The five gates, re-measured

| gate | pristine | patched |
|---|---|---|
| (2) `check_goldens.sh` | PASS 23 / FAIL 0 | PASS 23 / FAIL 0 |
| (2) negative control `SLANG_UHDM=/bin/false` | — | PASS 0 / FAIL 23 |
| (3) uhdm2rtlil, both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | identical |
| (3) `ct8rows` vs the committed baseline | PASS | PASS |
| (3) the two mode CSVs, pristine vs patched | — | **byte-identical** |
| (4) surelog, both modes | 937 CMP_EQUAL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 1 NO_UHDM / 567 SLANG_REJECT / 48 SURELOG_FAIL / 1 TIMEOUT / 2 UNTRANSLATABLE | identical |
| (4) `ct8rows` vs the committed baseline | PASS, 0 differing rows / 1588 | PASS, 0 differing rows / 1588 |
| (4) the whole surelog CSV, pristine vs patched | — | **byte-identical** |
| (5) `byteverify SELFCHECK=1`, surelog | — | **MOVERS 2 / 956** (selfcheck 955/956) |
| (5) `byteverify SELFCHECK=1`, uhdm2rtlil | — | **MOVERS 0 / 1358** (selfcheck 1357/1358) |

No row converted; `Earlgrey_0_1` stays CMP_NOTEQUAL in both modes.

**Movers predicted BY NAME from PRISTINE databases before the patched sweep.**
`fencescan80.sh` (reads databases, dispatches nothing) with a span-augmented
census over all 956 pristine surelog DBs and all 1358 pristine u2r DBs:
`DECOMPILE-WIDTH` totals **168** on the surelog corpus and **0** on u2r, and
all 168 live in exactly `default/Earlgrey_0_1-71da2fd7` (84) and
`testflags/Earlgrey_0_1-71da2fd7` (84).  The measured mover set is exactly
those two databases.  `FENCESCAN_*.verifier.txt`.

## 3. Heads and canaries

`rowheads.sh` on my own sweep workdirs:

| row | pristine | patched |
|---|---|---|
| Earlgrey_0_1 / default | 64 / 1 | **32 / 1** |
| Earlgrey_0_1 / testflags | 64 / 1 | **36 / 1** |
| SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg, Rggen | — | every `uhdm-cmp` log **byte-identical** |

My pristine and patched Earlgrey cmp logs are **byte-identical to the
implementer's committed `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp`**, all four.
The new head is the one `PREDICT_R0.txt` names: the `bit_select` index at
`tlul_socket_1n.sv:215`, golden `constant UINT:2 size 64`, ours `ref_obj N`
(the testflags `ref_obj` carries a `vpiActual`, which is the 32-vs-36 line
difference).

Canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2`
PASS on both corpora.

## 4. Breaking the law — 12,500+ scored cells on shapes the pass did not use

Six arms of my own (`vgen80.py` generates v1–v4; v5 and v6 hand-written),
built with Surelog for golden and with BOTH frozen binaries in BOTH views,
censused by `vpacen80` (the pass's direct `.uhdm` reader plus a SPAN-PRESENCE
flag) and scored by `vsc80.py` — key = (VpiParent chain, Lhs name), payload =
the judge-read constant fields ONLY, **no span**, multiset join; span presence
scored on its own axis because golden's constant on this head is loc-less.

* **v1_width80** — 13 literal spellings (`4'h2 8'h2 4'd2 4'b10 4'o7 'h2 '0 '1
  4'sh2 64'hFFFF 2 32'hDEADBEEF 3'b101`) x 8 declared intermediate types
  (incl. `bit`, `byte`, `logic signed [3:0]`, implicit/untyped) x 3 homes
  (declared default / written at the instantiation / top localparam) x
  **THREE hops** (the pass's own grids stop at two).
* **v2_mid80** — the intermediate types VARIED ALONG the chain: 12 (M1,M2,M3)
  combinations x 6 sources x 3 homes.
* **v3_home80** — module scope, **gen-for**, **gen-if**, the **else** arm,
  **nested generate**, an **interface** and a **program**.
* **v4_shape80** — **package parameters** (qualified and imported), localparam
  hops of five types, overrides written as an **expression** / a **plain
  decimal** / a **based literal** / a concatenation / a shift / a ternary,
  and 1–3 instances of one module with **two different overrides**.
* **v5_edge80** — **positional (unnamed) overrides**, a **defparam**, the top
  module's own parameters passed down, `'0` / `'1`, a 64-bit literal into a
  4-bit formal, three instances two of which share an override.
* **v6cell/v6_macro80.sv** — a default that arrives through a **macro defined
  in an included header** (the `isOverriddenParam` macro-buffer trap).

| arm | cells (per view) | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | span moved |
|---|---|---|---|---|---|
| v1_width80 | 5408 | 396 | **0** | **0** | 0 |
| v2_mid80 | 3744 | 622 | **0** | **0** | 0 |
| v3_home80 | 360 | 132 | **0** | **0** | 0 |
| v4_shape80 | 264 | 66 | **0** | **0** | 0 |
| v5_edge80 | 134 | 42 | **0** | 4 (see below) | 0 |
| v6_macro80 | 58 | 24 | **0** | **0** | 0 |

Identical in the DEF and the ELAB view, cell for cell.  `ARITY-CHANGED=0` and
`KEY-MISSING-*` unchanged everywhere, so nothing was created or dropped.

**The A/B gate is neutral.** `R10E80_OFF=1` on the PATCHED binary reproduces
the PRISTINE census **byte-for-byte** on all six arms and both views, so every
difference above is this law's and nothing else's.

**The pass's own two grids reproduce exactly.**  Rebuilt against Surelog
golden from my own frozen binaries and rescored with BOTH scorers:
`g1_hops80.sv` 1728 cells, pristine differ **484**, patched **254**,
**TO-GOLDEN 230 / AWAY 0 / MOVED-WRONG 0**; `g2_mask80.sv` 1440 cells,
**428 -> 224**, **TO-GOLDEN 204 / AWAY 0 / MOVED-WRONG 0** — the report's table
to the cell.  My own census, which also carries the DEF-listing cells the
pass's key drops (3840 and 3200 cells), gives the same movement and
`AWAY-GOLDEN 0 / MOVED-WRONG 0 / span untouched`.

**v2 proves the law is bidirectional**: 622 cells move, and they move in BOTH
directions — e.g. `4'h2` through a NON-overridden `int` hop must WIDEN to
`32'h2` (pristine wrote `4'h2`, golden and patched write `32'h2`), while the
same literal through an OVERRIDDEN `bit [7:0]` hop must STAY `4'h2`.  A rule
that simply "stopped re-rendering" would fail half of them.

**The 4 MOVED-WRONG cells are a `defparam`, and they are not a regression.**
`defparam u_dp0.B = 4'h5`: golden reads `UINT:5 dec=5` at every hop; the
PRISTINE binary already loses the defparam one hop on and reads
`HEX:1 dec=32'h1` (B's *declared default*), and the patched binary reads
`HEX:1 dec=4'h1`.  Both are wrong, in `VpiConstType`, `VpiValue` AND
`VpiDecompile`, so the judge's verdict on the cell is unchanged; the patch
only changed which wrong decompile width it carries.  Ranked as a residue.

## 5. THE DEFECT I FOUND AND FIXED — `canaudit.sh` exited 6 as delivered

The implementer reported `canaudit UNCOVERED=0 FENCE-BREACH=0`.  Run on the
delivered directory it reports **`UNCOVERED=0 FENCE-BREACH=4` and exits 6**:
`GATES.txt:83` and `ARMS.txt:53` each spelled all four slang-fenced test names
on a `FENCED=` line.  `canaudit.sh` (byte-identical to pass 79's — the
implementer did not weaken it) excludes only `README*.md` and itself from that
grep, so two of the pass's own evidence files were the breach.  Nothing was
ever dispatched — the finding is about the artifact text, not about a run.

**Fix (mine, in `/tmp/r10earl80.verified.patch`):** both lines now point at
`canaudit.sh` as the only copy of the list in that directory.  Re-run:
`audited=29 UNCOVERED=0 FENCE-BREACH=0`, exit 0.  No production file touched,
so no gate needed re-running.

## 6. Boundaries — wider than the pass's own

A COPY of the whole `tools/probe` tree (plus my six arms), **`.sv` AND `.v`**,
no path filter, at any depth, both views, both frozen binaries, workdir-
normalised whole-dump byte compare; file list on fd 3, children `</dev/null`,
`PROCESSED` asserted against the list length, `rc` recorded per cell.

```
WIDE     PROCESSED=3642 (LISTED 3642) identical=6972 DIFFERING=22 no_output=290
PER-DIR  PROCESSED=1532 (LISTED 1532) identical=2793 DIFFERING=11 no_output=260
```

The WIDE 22 are eleven files x two views: my six arms (positive controls —
proof the walk can see), the pass's `g1_hops80.sv` / `g2_mask80.sv`, and
`qb28.sv`, `qc28.sv`, `v3_pos64.sv`, `v7_inst64.sv`.  Each of the last four
was rebuilt against Surelog golden and scored in BOTH views: **qb28
TO-GOLDEN 2, qc28 4, v3_pos64 2, v7_inst64 3, AWAY-GOLDEN 0, MOVED-WRONG 0** —
the implementer's numbers exactly.  The 68 `.v` files, which the pass's own
walk did not cover, contributed **zero** differences.

The PER-DIR 11 are my `r10v80repro` (positive control), `r10v64repro`
(**TO-GOLDEN 5 / AWAY 0 / MOVED-WRONG 0** over the 1052-cell whole-directory
unit, both views) and four directories that are **emitter nondeterminism,
proved rather than asserted** (`NONDETERMINISM.txt`): three runs of EACH binary
in EACH view give raw dump hashes that differ run-to-run *within the pristine
binary alone*, while the ORDER-BLIND (sorted) dump hash is **identical across
all six runs** for all eight (directory x view) combinations, and the
`param_assign` census is identical in every run.

Every `rc>128` line — 14 in the wide walk, 6 in the per-directory walk — fires
on **both** sides, A and B.  Pre-existing segfaults, not this pass's.

## 7. The corpus census, independently

`Earlgrey_0_1`, both modes, whole-database `param_assign` census with a
Compare-visible payload and a separate span axis:

```
default    CELLS=28655  UNCHANGED-EQ=28473  UNCHANGED-NE=98
           TO-GOLDEN=84  AWAY-GOLDEN=0  MOVED-WRONG=0   span: all UNCHANGED
testflags  CELLS=36735  UNCHANGED-EQ=36553  UNCHANGED-NE=98
           TO-GOLDEN=84  AWAY-GOLDEN=0  MOVED-WRONG=0   span: all UNCHANGED
```

182 -> 98 differing cells in both modes; the `DECOMPILE-WIDTH` family goes
84 -> 0 and **the other ten families are unchanged cell for cell**.  The
pristine and patched key sets are identical and the sorted censuses differ in
exactly 84 lines per mode.

## 8. Residues I measured (ranked; all pre-existing, none introduced)

From v1_width80's OVR/LP homes, per (source spelling, home), cells still
disagreeing with golden after the patch — 64 cells per family:

| shape | ovr | lp | what golden wants |
|---|---|---|---|
| **`'h2` — an UNSIZED BASED literal** | **64/64** | **64/64** | `ct=5 HEX:2 dec='h2` at EVERY hop, hop 0 included; we mint `ct=9 UINT:2 dec=2`. The producer is wrong before any hop runs — the biggest single residue in the grid and, unlike the `'0` family, wrong at the ORIGIN. |
| `'0` unbased-unsized | 50/64 | 16/64 | `ct=3 BIN:0 dec='b0 size 32`; we write `4'b0`/`32'b0` at the declared width. This is the fence the pass installed (`!o8.dec.empty()`) and its own R1. |
| `'1` unbased-unsized | 20/64 | 20/64 | `UINT:4294967295` (32-bit all-ones); we mask to the formal (`UINT:15` into `bit [3:0]`). |
| `4'd2` | 2/64 | 0/64 | a narrow decimal residue |
| `4'o7`, `3'b101`, `4'sh2`, `64'hFFFF`, `32'hDEADBEEF` | 0/64 | 0–6/64 | DECL-home only, i.e. NOT this law's shape |

Plus: **`defparam` values are not propagated down an override chain** (v5;
golden `UINT:5` at every hop, we read the declared default). Pre-existing.

## 9. Reproducing

```bash
python3 vgen80.py <outdir>                 # regenerate v1..v4
g++ -O2 -std=c++17 vpacen80.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o vpacen80
python3 vsc80.py golden.pa pristine.pa patched.pa       # 3-way, span axis apart
PATCHED_BIN=.. PRISTINE_BIN=.. PROBE_ROOT=.. STAGE=.. bash vwide_v80.sh list out
PATCHED_BIN=.. PRISTINE_BIN=.. PROBE_ROOT=.. STAGE=.. bash vdir_v80.sh  list out
bash nd80.sh <probe-dir> plain|elab 3      # the nondeterminism adjudicator
```
