# r10vearl95 — adversarial verification of r10earl95 (§ genCaParamFoldOneHopPool95)

**VERDICT: ACCEPT AS SHIPPED.** No production line changed. Every headline
number reproduces bit-for-bit from binaries the verifier built itself, and
nine fresh adversarial arms plus every committed arm the wide boundary moved
score **RIGHT→WRONG 0**.

BASE `d7c6e81`, branch `auto5h`. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; every
instrument here is MEASUREMENT ONLY.

## 1. What reproduced

Both binary md5s, the two Earlgrey mover hashes, the head counts (46→112 /
50→112), the census 32/0/0, the u2r 0-mover result, all four sweeps' status
histograms, both `ct8rows` 0-differing-row results, and the whole canary
battery. `GATES.r10vearl95.txt` carries the numbers.

Two independent confirmations the implementer could not give themselves:

* **the Scoreboard/default coin.** The verifier's own patched sweep produced
  **2** movers, not 3 — `default/Scoreboard` did not move at all. That is the
  coin landing the other way, measured on a different machine-run, and it
  settles the attribution without leaning on the citation.
* **`rc` symmetry on the wide boundary is exact**: `asymmetric_arms=0` over
  4296 sources × 2 views × 2 binaries. The implementer's lone `rc=127` was
  indeed a transient.

## 2. The law, re-derived on the verifier's own goldens

Nine fresh arms (`v95a`…`v95i`), each with three instantiations of one span
where the shape allows, both views, LHS always Surelog:

* **`v95a_ctx`** — module body / gen-if / **gen-case** / gen-for / nested.
  Golden treats a **case-generate block exactly like an if-generate block**:
  `gc1` (module localparam read from a case block, distance 1) FOLDS, `nn2`
  (distance 2) KEEPS. Depth 1 folds, depth 2 keeps, distance 0 keeps.
* **`v95b_homes`** — plain module, a 3-DEEP instance chain, an INTERFACE, an
  INSTANCE ARRAY, and a module instantiated INSIDE a gen scope. Depth 1 folds,
  depth 2 keeps in every home; the patched binary matches golden in all five.
* **`v95c_faces`** — ten select faces at depth 1 and again at depth 2: a
  localparam unpacked array of 168-/64-/32-/8-bit values and of ints, a packed
  parameter vector, a net, a variable, a struct array, a 2-D array; index
  shapes bare-param / param-op-param / literal / a NESTED select / a CALL;
  part-select bounds; an indexed part-select with a param BASE and a param
  WIDTH; a replication count beside a concat element. **The selected object
  never enters the decision** — r10earl94's candidate distinguisher stays
  refuted on an independent grid.
* **`v95d_defp`** — a DEFPARAM'd instance and PORT parameters.
* **`v95f_bind`** — a BIND instance elaborated into a foreign hierarchy.
* **`v95g_rec`** — a module that instantiates ITSELF inside its own generate
  scope, and a gen→inst→gen→inst→gen crossing. The census keys these at
  GDEPTH 2/3 because the parent chain crosses instance boundaries, and
  **golden folds there** — so the patch's `enclosingBody95(up95)==body95`
  guard is LOAD-BEARING: without it these cells would have gone
  RIGHT→WRONG. This arm is the independent re-proof of the regression the
  `genscope_cells` canary caught.
* **`v95h_survivor`** — an else arm that DOES collapse (§ genElseArmCollapse48).
  Its survivor reads a module parameter at **syntactic depth 2 / emitted depth
  1**: golden FOLDS and the patched binary still folds. A syntax-tree hop count
  would have refused here. **The emitted-hop clause is necessary and correct
  for the else-arm collapse**, proven on a golden the implementer did not write.
* **`v95e_collapse`, `v95i_unnamed`** — see §3.

## 3. THE ONE CORRECTION TO THE LAW'S STATEMENT (over-fold only, never a regression)

The law says the hop is counted **in the EMITTED tree**. That is right for the
§ genElseArmCollapse48 splice and **wrong for `genHoists9`**, and the two arms
that separate them are here:

```
v95i_unnamed / v95e_collapse, both measured on Surelog goldens

  (a) an UNNAMED block holding ONLY a named if-generate  -> HOISTED by both
      models.  golden: gen depth 1, and it KEEPS the ref_obj.
      ours (pristine AND patched): folded.        <- still wrong, R-A
  (d) an UNNAMED block holding a module INSTANCE too    -> Surelog splices,
      we keep the level.  golden: gen depth 1, KEEPS the ref.
      pristine folded; PATCHED keeps the ref.     <- fixed in substance
```

So Surelog's parameter pool follows the **elaborated instance tree**, in which
`reduceUnnamedBlocks_` has NOT yet run — an unnamed generate level is still a
hop even though it later disappears from the emitted model, whereas a collapsed
else arm was never elaborated as a level at all. The patch's formulation errs
only in the **over-fold** direction (an emitted distance is never larger than
the instance-tree distance), so it can leave a pre-existing wrong cell wrong and
can never turn a right cell wrong. **0 cells of this shape in either Earlgrey
database** (measured: 0 GDEPTH-1 elab cells where golden is a `ref_obj` and ours
a `constant`), consistent with the pass's corpus denominator.

**This matters for the NEXT pass.** R2 (the loop half) and the parent-gen-scope
fold below are *additive* rules; whoever writes them must count the hop in the
instance tree, not in `genEmitStack95`, or the hoisted shape will regress.

## 4. Residues the verifier measured

* **R-A — the unnamed-block hoist is not a pool hop for Surelog.** §3.
  0 corpus cells today; reproduced on `v95i_unnamed` (a) and
  `v95e_collapse` line 43.
* **R-B — golden FOLDS a PARENT GEN SCOPE's localparam one level down and we
  keep the ref, in BOTH binaries.** `v95a_ctx` rows 27 (`L1` read from `gi_b`)
  and 37 (`C1` read from a nested gen-if inside a case block),
  `v95e_collapse` rows 21/34, `v95i_unnamed` row 26. This is the FOLD half of
  the same one-hop law and it is a pure ADD — the pass's own `g3` rows 41/48/53
  record golden's behaviour but we do not yet reproduce it. Ranked first among
  the follow-ups because it is the direct complement of what landed.
* **R1 (the pass's) is correctly characterised.** Ours carries TWO copies of the
  pre-reduction operation at `prim_lfsr.sv:308:62-308:70` where golden carries
  ONE; the `part_select|308:62-308:72|lr` slot holds `constant[INT:63] #1` +
  `operation #1` on BOTH sides, so exactly one copy is judge-reachable and it is
  the copy that now matches golden (`ref_obj[LfsrDw|-@-]`). The surplus copy —
  the one wearing the bound `Actual_group` — is unreachable from any compared
  slot. Verified cell by cell, both instances, testflags.
* **R0 is pre-existing.** `ln95` prints `hmac_pkg::sha_word_t` in the PRISTINE
  Earlgrey database exactly as in the patched one.

## 5. Doc nit

`PREDICT_R0.txt` Part 1 says `surelog MOVERS 2 / 956` while `README.md` §5 and
`GATES.r10earl95.txt` say 3 (the two Earlgrey databases plus the Scoreboard
coin). Both are true of different runs — the verifier's own sweep measured 2 —
but the two committed files disagree on their face.

## 6. Ops note

`tools/probe/r10v95repro/` is ALREADY TAKEN by **UVM pass 95's** verifier
(commit `f5765f1`). This directory is `r10vearl95repro` for that reason.

## 7. Files

`ARMS.r10vearl95.txt` — 48 arm/view rows, RIGHT→WRONG 0 on every one.
`GATES.r10vearl95.txt` — the verifier's own gate battery.
`BOUNDARY_WIDE.*` — tally, rc histogram, rc by side, rc symmetry, diff list,
signals. `v95*.sv` — the nine adversarial arms. The scorers/censuses are the
pass's own instruments, copied so this directory runs standalone.
