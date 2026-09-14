# r11v29 — adversarial verification of r11u29 (the full not-equal triage)

MEASUREMENT ONLY.  No production file is touched here either.  The judge is the
official `uhdm-cmp`.

**VERDICT: ACCEPT-WITH-FIX.**  Everything r11u29 measured reproduces; two of the
things it *concluded* do not.  The corrected report is
`tools/probe/r11u29repro/TRIAGE.md` (patched in place, with every change marked
`CORRECTED (r11v29)`), and `tools/probe/r11u29repro/CLUSTERS.tsv` carries the
corrected per-row assignment.

---

## 1. What was re-measured, independently

| | |
|---|---|
| worktree | `/tmp/wt_v11u29` at `d24291a2`, fresh |
| binary | **configured and built from source** (`-j 2`, Release, gcc-toolset-14, `slang_DIR`/`UHDM_DIR` at `~/.local`) — md5 `62547ac98ebcfdeb522171dc946d50ad`, which **is the pin**.  r11u29 copied the main-tree binary instead of building; this verifier did the build it skipped, so the shortcut is now evidenced, not assumed.  Frozen `chmod 555`, exported as `SLANG_UHDM`; all 1742 uhdm2rtlil `cmds.txt` name that path and no other. |
| sweeps | own workdirs, `--jobs 2`: uhdm2rtlil both modes, surelog both modes, plus a second `--filter` sweep for the coin family |
| heads | the committed `r10uvm67repro/rowheads.sh`, ONE head per run, `grep -c '^LHS:'` |

`evidence/build_md5.txt`, `evidence/sweep_agreement.txt`.

**The sweeps reproduce the read-only baselines row for row**: uhdm2rtlil
768/36/67 in both modes, surelog 469/14 + 465/12; **0 rows differ in status**
against `results/golden_uhdm2rtlil.csv` and `results/golden_surelog.csv`, and the
`CMP_NOTEQUAL` name×mode sets are identical.  `results/*.csv` was read only.

---

## 2. What HOLDS (re-derived, not re-read)

* **The faces.**  r11u29's own `facediff.py`, run over MY `.cmp` files, produces
  `faces.key.txt` and `faces.full.txt` that differ from r11u29's committed ones
  by **0 lines**, on both corpora — all 92 rows.  The `rowheads` tables (cmp-line
  counts and head counts) likewise differ by 0 lines.
  `evidence/faces_identity.txt`.
* **The row set.**  92 rows / 47 tests: 72 uhdm2rtlil (36 tests × 2 modes) + 20
  surelog (11 tests; `Rggen` and `Scoreboard` default only).
* **The fence.**  The fence list was rebuilt independently from a committed
  driver's own `FENCED=` line.  26 − 6 = 20 surelog rows survive; the 3 excluded
  test names are EXACT members of the fence list (exact string equality, so no
  superstring over-exclusion), one fenced test is no longer not-equal at this
  base, and the fenced names appear **0 times** in r11u29's patch and 0 times in
  the corrected probe tree.  No fenced test was dispatched by either pass.
  `evidence/fence_check.txt`.
* **The positive control.**  Four known-EQUAL rows (`1DUnpackedArray`,
  `2DeclarationsInFor`; `1364_2005`, `AllBinding`) read 0 cmp lines / 0 heads with
  `cmp rc=0`; every triaged row reads exactly 1 head.  The only two SKIP-NOFILE
  rows are `Rggen/testflags` and `Scoreboard/testflags`, neither a not-equal row.
* **Mode identity.**  Re-measured: uhdm2rtlil 38 IDBLIND-SAME / 0 MODE-SPLIT,
  surelog 11 IDBLIND-SAME / 2 ONE-MODE-ONLY / 0 MODE-SPLIT.  One face per test
  does serve both modes.
* **The coin family.**  Stable across **three** independent database builds
  (r11u29's, this verifier's full sweep, this verifier's second `--filter`
  sweep): every coin row reports the same head id-blind.
  `evidence/coin_and_reread.txt`.
* **K1's shared-head claim, exactly as quoted.**  All five id+location-blind heads
  md5 `0c1a52351c31`; four identical with ids alone blinded (`75555f9dd8f9`),
  `BuildUVMPkg` differing only in the line number.  `evidence/K1_shared_head.txt`.
* **The cited sites and residues.**  `src/TypeEmit.cpp:16986-16987` (the refuted
  `op 95 with [x, a, b, ...]` comment and the `valueRanges` loop); zero
  `OpenRangeExpression` hits in `src/`; `src/EmitHelpers.h:858/860/566`;
  `src/TypeEmit.cpp:20233`; `nets.cpp:277` really is
  `lhs->VpiNetType() - rhs->VpiNetType()`; `r11u27repro/README.md:407/434/441`
  are R0/R4/R6; `r11v26repro/README.md:56` is the pattern-typing sentence.
  The K7 owner claim checks out in the golden dump: the nameless `ref_typespec`
  is the `vpiTypespec` of the opType-75 `operation` that is the `vpiRhs` of the
  `param_assign` for `localparam bus_t B`.
* **`--nobuiltin`.**  The three `ibex_*` rows' own `cmds.txt` contain no
  `nobuiltin`, and `scripts/verify_golden.py` adds it only when the golden's
  Surelog argv carries `-nobuiltin`; every head here came from a harness-built
  database, never a hand run.  Nothing to apply.
* **Hygiene.**  r11u29's patch is 35 files, probe-directory only, 0 production
  files, applies clean at `d24291a2`.  Its drivers take their workdir as an
  argument, hard-code no other pass's path (`owners.sh`'s `TSINST` default is its
  own pass scratch and is env-overridable), and no script removes anything.

---

## 3. What DOES NOT hold — correction 1: K2's footprint bound

r11u29's #2 dispatch target rests on: *"A depth-keyed census over the five
designs, calibrated golden-vs-golden to 0 disagreements first, isolates the whole
footprint — 10 nets, and nothing else in any of the five databases."*

The committed evidence file lists exactly those 10 `DISAGREE` lines and **drops
each golden-vs-ours summary line**.  Re-run unfiltered — r11u29's own
`nettype_census.py`, this verifier's own dumps — the instrument says:

```
gen_scope_numports              calib 0   golden vs ours: rows golden=77 ours=103 disagree=30
packed_array_reset_loop         calib 0   golden vs ours: rows golden=16 ours=16  disagree=3
param_name_collision_typeparam  calib 0   golden vs ours: rows golden=60 ours=63  disagree=4
latch_packed_enum_loop          calib 0   golden vs ours: rows golden=8  ours=8   disagree=1
arb_idx_cast                    calib 0   golden vs ours: rows golden=12 ours=12  disagree=1
```

**39 disagreements, of which 10 are the claimed `vpiNetType` face.**  The
calibration really is clean on all five — that half of the claim stands.

The 29 extra rows are not a depth-key artifact.  For the SAME declaration,
Surelog's ELABORATED view carries a `packed_array_var` (of `logic_var` /
`enum_var` elements) where we carry a `logic_net`:

```
golden  \_packed_array_var: (work@tb.t.gen_cut[0].i_tc_sram_wrapper.wdata_i), line:23:34
ours    \_logic_net:        (work@tb.t.gen_cut[0].i_tc_sram_wrapper.wdata_i), line:23:34
```

Four of the five designs are like that — `gen_scope_numports`,
`param_name_collision_typeparam`, `packed_array_reset_loop`, `arb_idx_cast`; only
`latch_packed_enum_loop` agrees on the object kind.  The emitter's own comment
already states both halves of the law for the dimension-less case
(`src/EmitHelpers.h:563-565`: "def-view net with no net type + type-param default
typespec; **elab-view logic_var**").  r11u29's suspected law names only the
def-view `vpiNetType` half.

**Consequence for dispatch:** K2 is still 5 tests / 10 rows at the head, but an
implement pass that clears only the stamp will move the head in four of the five
designs rather than convert the test.  The footprint bound is withdrawn and the
law is restated in two halves in the corrected TRIAGE §2 and §4.

`evidence/K2_census_unfiltered.txt`, `evidence/K2_elabview_objectkind.txt`.

---

## 4. What DOES NOT hold — correction 2: six rows do not carry their
## cluster's claimed face

Each head below was re-read in full and quoted id-blind in
`evidence/splits.txt`.

| row | cluster it was in | the cluster's CLAIMED face | what its head actually is |
|---|---|---|---|
| `port_chained_type_param` | K4 | golden's array typespec carries the written dimension, ours is the bare element | golden's head has **no `vpiRange` at all** — a chained override resolves to golden's `struct_typespec` (3 members) against our `logic_typespec` |
| `genvar_pow_index` | K3 | the fold DECISION (golden keeps where we fold, or folds where we keep) | **nothing is folded on either side**; golden's `gen_for` condition has 2 operands, ours 1 — the `$unsigned(genvar)` operand is absent |
| `StructParamPatternInitCast` | K3 | the fold DECISION | the mirror null — our `constant 32'd64` has **no `vpiParent`**; an orphan over-emission |
| `StructParamFuncBodyFieldCompare` | K6 | "same value, **same context**, `vpiSize` differs" | the context differs: golden's constant hangs off an `operation`, ours off a kept `sys_func_call ($unsigned)` golden dropped.  Two faces stacked |
| `packed_array_struct` | K8 | a constant's ENCODING **at equal size** | the encodings AGREE (`BIN` ct3); only `vpiSize` differs, and as UNSIZED (−1) vs SIZED (168) |
| `dyn_field_select` + `struct_member_expr_index` | K11 | one `hier_path` face | two different judged fields — `Path_elems` (same `VpiName`) versus `VpiName` text (same element kinds).  A shared object KIND is not a shared FACE; **K11 dissolves** |

Two further caveats, recorded in the corrected TRIAGE rather than as splits
because the head face there really is shared:

* **K7** is a shared OBJECT (the `vpiOpType:75` operation), not a shared FIELD:
  2 rows are the missing `vpiTypespec`, 1 is the extra `vpiSize`, and
  `cfg_func_width_loop` carries no `vpiTypespec` on either side.  The cited
  landed law reaches 2 of the 3.
* **K12**'s head face is shared, but `packed_struct_array_fifo` carries further
  OURS-ONLY distinguishers under the same head (two extra
  `packed_array_typespec`s; a `ref_obj` golden names
  `…FifoDepth.ADDR_DEPTH` against our `…ADDR_DEPTH`), so the phantom-net law
  alone will not convert it.

---

## 5. The corrected ranked table

| rank | cluster | tests | rows |
|---|---|---|---|
| 1 | K1 — an `inside` value range is one `vpiListOp` operand | 5 | 9 |
| 2 | K2 — `vpiNetType` (+ the elab-view object kind) on a named-type declaration | 5 | 10 |
| 3 | K4 — a type parameter's actual type loses its dimension | 4 | 8 |
| 4 | K5 — the fold DECISION at a range bound | 4 | 8 |
| 5 | K3 — the fold DECISION away from a range | 3 | 6 |
| 6 | K6 — a folded constant's SIZE under a range, 32 vs 64 | 3 | 6 |
| 7 | K7 — how an assignment-pattern operation is stamped | 3 | 6 |
| 8 | K8 — a folded constant's ENCODING at equal size | 2 | 4 |
| 9 | K9 — a named-type declaration's missing `ref_typespec` | 2 | 4 |
| 10 | K10 — an interface ARRAY element absent | 2 | 3 |
| 11 | K12 — a phantom def-view net | 2 | 4 |
| — | S — singletons | 12 | 24 |

35 clustered tests + 12 singletons = 47; 68 + 24 = 92 rows.

**Top three, corrected:** K1 (unchanged and the strongest), K2 (same rank, law
restated in two halves, census first), **K4** (promoted over K5 at equal
tests-per-fix: one direction, no counter-arm, four heads that read line for line
alike).  K5+K6+K3 together are the largest surface — 10 tests on one reducer
decision, with two opposing directions and an unknown distinguisher — and belong
after a census, not in the first three.

---

## 6. Files

* `evidence/build_md5.txt` — the from-source build and the `cmds.txt` audit.
* `evidence/sweep_agreement.txt` — the sweeps, the baseline agreement, the
  positive control, the head counts.
* `evidence/faces_identity.txt` — 0-line face diff against r11u29, both corpora.
* `evidence/K1_shared_head.txt` — the md5s, and the `uvm_domain.svh` line
  correction (199 in `uvm-1.2`, not 194).
* `evidence/K2_census_unfiltered.txt` — the census as the instrument prints it.
* `evidence/K2_elabview_objectkind.txt` — what the 29 extra rows are.
* `evidence/splits.txt` — every split's head, quoted id-blind side by side.
* `evidence/coin_and_reread.txt` — three-build coin stability, long-head re-read.
* `evidence/fence_check.txt` — counts only; no fenced name is spelled.
* `verify.sh` — the whole verification, re-runnable from a pristine tree.
