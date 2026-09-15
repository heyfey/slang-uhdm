# r11v44 — adversarial verification of r11u44's SECOND FULL TRIAGE

Base `beb0c148` (`matrix-1.87`), own worktree, own scratch, own frozen binary,
own sweeps. MEASUREMENT ONLY; no production file is touched by either pass.

**VERDICT: ACCEPT-WITH-FIX.** Every number in the surveyor's report reproduced
independently. One cluster had to be SPLIT, and four statements had to be
corrected. The corrected `TRIAGE2.md` + `CLUSTERS.tsv` ship in
`/tmp/r11u44.verified.patch` alongside this directory.

---

## 1. What was re-measured, independently

Nothing was read out of the surveyor's workdirs. The binary was copied from the
main tree, md5-verified against the pin `68790dddaa8db9c045ceeef4330527ec`,
frozen `chmod 555`, exported as `SLANG_UHDM`; all 57 rows' `cmds.txt` name that
frozen path (`grep -ho … | sort | uniq -c` → `57 /tmp/v11u44_scratch/slang-uhdm`,
0 rows on any other binary). Both corpora were swept fresh, `--jobs 2`, both
modes, `--filter` built from the READ-ONLY baselines minus a FENCED list taken
from a committed driver's own `FENCED=` line.

| check | result |
|---|---|
| row set | 46 uhdm2rtlil `CMP_NOTEQUAL` + 11 surelog `CMP_NOTEQUAL` + `Rggen/testflags SURELOG_FAIL` — `diff` against the baseline CSVs is EMPTY |
| heads | ONE head per row on all 57 rows; `SKIP-NOFILE=1` (`Rggen/testflags`), `UNKNOWN-NAME=0` |
| cmp line counts | all 57 match the surveyor's `evidence/rowheads_*.txt` exactly (`diff` → SAME, both corpora) |
| head positive control | 8 rows over 4 known-`CMP_EQUAL` tests, **chosen differently from the surveyor's** (`struct_member_expr_index`, `iface_gen_delay`, `Chandle`, `PackStructVar`): 0 cmp lines / 0 heads / `rc=0` on every one |
| mode identity | 0 `MODE-SPLIT` across all 28 two-mode tests; `Rggen` one-mode-only |
| `NETDIST`, all 29 tests | every value reproduced to the unit, both corpora |
| mode identity, whole-dump | `GOLD_ONLY`/`OURS_ONLY` identical in `default` and `testflags` for all 23 uhdm2rtlil tests |
| converted / new | 47 tests not-equal at the first triage → 29 now: **18 converted, 0 new**, name for name |
| head-moved verdict | recomputed through the committed reader against the committed first-triage keys: exactly 9 `FACE-MOVED`, name for name the surveyor's nine, + `ibex_icache` face-same at 64 → 60 lines |
| fence | 0 occurrences of any `FENCED=` name anywhere in either probe directory or in any sweep CSV; the three fenced not-equal tests are in NO cluster |
| patch surface | `git status` outside `tools/probe/r11u44repro/`: **0**. No `results/*.csv` write, no `rm -rf`, no hard-coded other-pass path, no `/tmp/claude-1000` reference |

**Ops note for whoever re-runs this.** The main tree's `build/slang-uhdm` was
REBUILT partway through this verification (its md5 is no longer the pin, and
`src/ModuleEmit.cpp` is modified in the main tree for a later pass). Neither
pass's numbers are affected: both copied and md5-verified the pinned binary
BEFORE that, froze it `chmod 555`, and every row's `cmds.txt` — all 57 survey
rows and all 8 control rows — names the frozen copy, which still md5s to the pin.
But `survey2.sh` defaults `SLANG_UHDM_SRC` to `$REPO/build/slang-uhdm`, so a
re-run from the main tree will now trip the script's own
`FATAL: binary md5 … != pin` guard (the guard working as designed). Point
`SLANG_UHDM_SRC` at a pinned copy instead.

Pinned-source citations were checked line by line and all resolve:
`~/.local/include/uhdm/BaseClass.h:217` (the vector overload setting only
`m_failedLhs`), `logic_typespec.cpp:124` (the `Ranges` SafeCompare),
`typespec::Compare`'s `VpiName` → `Typedef_alias` → `Instance` order,
`rggen_register_if.sv:4` / `block_0.sv:147`, and all 18 landed-pass residue
`README.md:line` citations.

## 2. Shared-head claims, re-proved with an independently written blinder

`vblind.sh` here blinds ids and every source location, and blinds ONE design
name passed on the command line — it does not reuse the surveyor's blinder.

| claim | verdict |
|---|---|
| C1 `type_param_packed_dim` ≡ `type_param_override_elem_sel` | **IDENTICAL**, md5 `7df37b083205`, 47 blinded lines — and identical with NO design-name blinding at all, both designs being `dut`. Stronger than claimed. |
| C3 `cva6_struct_param_field` ≡ `StructParamFieldRange` (cross-corpus) | **IDENTICAL**, 166 blinded lines; the raw heads share even their arena ids |
| C6 `arb_idx_cast` ≡ `genvar_pow_index` | **IDENTICAL** once each design's own top name is blinded (`dut` / `genvar_pow_index`); the only diff before that is the name |
| C4 / C5 / C7 "NOT one head" | **DIFFERS** in all three — the surveyor was right not to claim a head |

C4's and C5's shared FACES were confirmed by reading both heads in full (C4:
both `LHS: <null>` on an ours-only `ref_typespec → int_typespec`, holders
`ref_obj` vs folded `constant`; C5: both `RHS: <null>` on a golden
`ref_typespec → struct_typespec`, owners op75 vs op67 — both owners located in
golden's own dump and confirmed there). C7's shared face (ours always `UINT`/ct9)
confirmed on both rows. C2's five members were each read in full and each is a
genuine constant-reduction disagreement.

`genvar_pow_index`'s conversion claim was verified line by line: its 15-line
`DISTANCE` is the 2-line instrument header plus **13 golden-only lines, every
one of them the `$unsigned` subtree, and zero ours-only lines**
(`evidence/genvar_pow_index.residue.txt`). C3's reach was verified the same way:
exactly 60 `it_t` lines in each of the three surelog diffs, totals 499 / 745 /
723, and the behind-head residue is C3's own face (ours-only
`struct_typespec: (it_t)`, `vpiName:it_t`, `it_t` leaking into member full names).

## 3. The corrections

**(a) C1 SPLIT — `port_chained_type_param` is not a member.** Its head is
golden `struct_typespec 2:32..2:38` (packed, three `typespec_member`s) against
our bare `logic_typespec 2:32..2:90` parented to
`type_parameter (work@dut.noc_req_t)` — an object-KIND mismatch, not C1's null
`Ranges` vector. Face keys: C1's two read `OURS-NULL:logic_typespec`, this reads
`struct_typespec G[…] O[<logic_typespec>…]`. The owner is the FIRST parameter's
anonymous-struct default at `dut.sv:2`, not the chained `req_t = noc_req_t` on
line 3 — which the surveyor's own `headctx.sh` printed correctly
(`side=LHS line:2:32 … SRC[dut.sv:2]`) and whose own `heads_raw/` copy matches
this pass's re-run byte for byte. The report's prose ("a fresh `logic_typespec
3:32..3:41`") was a transcription error against its own evidence. The cluster
rested on a residue written ten landings ago (`r11u31repro/README.md:300`
R0, "R0 closes both"), not on this survey's measurement.
→ C1 = 2 tests / 4 rows; singletons = 12 tests / 23 rows; totals unchanged at
29 / 57. The row belongs with C3's CONSTRUCT (an anonymous `struct packed {...}`
standing as a type default), one declaration-form over, and should ride with
C3's census rather than count as a C1 witness.
→ **Top three reordered**: C1 no longer has a test-count edge, so C3 (largest
reach, up to 4 tests / 8 rows) leads, C6 (only proved conversion) second, C1
third on law readiness.

**(b) "The other 20 heads are unchanged" → 19.** 29 tests − 10 (9 face-moved +
`ibex_icache` site-moved) = 19.

**(c) C2's direction tally "4 / 1" → "3 / 2".** `unsigned'(64)` IS written in
`StructParamFuncBodyFieldCompare/dut.sv:30` and golden is the side that reduces
it away — the same direction as `struct_param_pattern_packing`. The §2 detail
table was already right; only the summary cell miscounted. This strengthens the
report's own case for dispatching C2 last.

**(d) The `--nobuiltin` control is mis-cited.** `--nobuiltin` reaches the slang
argv only via `translate()`, which runs for `testflags`
(`verify_golden.py:683`) and `folded` (`:665`). The `default` arm rebuilds both
argvs from `location_args(parts)` (`:313`), which drops `-nobuiltin` from the
Surelog side too. So `default` runs with builtins on NEITHER side and
`testflags` with them suppressed on BOTH — each mode symmetric, each mode its
own golden cache entry keyed on the Surelog argv (`:83`). No number moves, and
the two modes agree throughout (0 `MODE-SPLIT`, identical `GOLD_ONLY`/`OURS_ONLY`
per mode on all 23 uhdm2rtlil tests), but the sentence must not be carried
forward as a control.

**(e) The distance calibration is narrower than stated.** All four of the
surveyor's control rows carry `dump=match` in the baseline, so the floor of 2 is
calibrated over BYTE-IDENTICAL pairs only. Two further `CMP_EQUAL` rows with
`dump=differ` read **26** and **17** through the same instrument, while two more
`dump=match` rows read the floor **2** (`evidence/control.txt`). The floor holds;
the inference "an equal row reads the floor" does not. `NETDIST` is a fidelity
axis, as §5 already says — a nonzero value never implies not-equal.

**(f) Minor, corrected in place.** `r11u37repro/README.md:360` R0 is refuted as
the HEAD only: its predicted content is still measurable behind the new head
(4 golden-only `…FifoDepth.ADDR_DEPTH` lines, 8 ours-only `packed_array_typespec`
lines). Blinded line counts are 47 (C1) and 166 (C3), not 46 and 164 — the
surveyor's `grep -c .` drops a blank line.

## 4. What was checked and found sound (no change)

Under-clustering was checked as well as over-clustering, by grouping all 29
heads by object kind. `const_cast_signext` is correctly NOT in C5 (its
`RHS: <null>` is the `Typedef_alias` edge on a typedef's own `logic_typespec`,
not a `vpiTypespec` on an operation). `ibex_pmp` and `packed_array_struct` are
correctly NOT in C7 (both are `vpiSize` faces at matching value and constType,
and their producers are unrelated — a wildcard-imported package parameter's
width vs an unbound fill's raw shape). `Rggen`'s decode was confirmed against
the sources: `rggen_register_if.sv:4` is `parameter int VALUE_WIDTH = BUS_WIDTH`
(default 32) and `block_0.sv:147` is `rggen_register_if #(8, 32, 64)
register_if[25]()`; golden's port view keeps 32, ours carries 64.

## 5. Files

* `README.md` — this verdict.
* `vblind.sh` — the independently written id/location/design-name blinder used
  for every shared-head re-proof.
* `evidence/rowheads_u2r.txt`, `evidence/rowheads_sl.txt` — this pass's own
  cmp-line + head counts for all 57 rows.
* `evidence/dd_u2r.txt`, `evidence/dd_u2r_tf.txt`, `evidence/dd_sl.txt` — this
  pass's own whole-dump distances, both u2r modes and surelog.
* `evidence/my_faces.key.txt` — this pass's own face key per row, the input to
  the independent head-moved verdict.
* `evidence/genvar_pow_index.residue.txt` — the 13-line proof behind the one
  conversion this triage can promise.
* `evidence/C1.type_param_packed_dim.cmp`,
  `evidence/C1split.port_chained_type_param.cmp` — the two heads the split turns
  on, side by side.
* `evidence/control.txt` — both positive controls on the verifier's own control
  rows, including the two `dump=differ` rows that narrow the distance
  calibration.
