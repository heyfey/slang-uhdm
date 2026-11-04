# CONVERGENCE PLAYBOOK — read this FIRST, before HANDOFF.md

> **2026-08-17: START WITH `RESUME.md`** (canonical operator manual + `scripts/resume_survey.sh` for the live state). This file's METHOD is current; its numbers are phase-1 history.

This document governs HOW to run the convergence campaign. HANDOFF.md records
WHERE we are. If you read only one thing before working, read this.

Phase 1 (uhdm2rtlil 0 DIFF) is done. The current target is **phase 2**:
both corpora, both modes, all cmp-equal — see GOLDEN_EQUIVALENCE.md for that
target, the decisions behind it, current status, and how to run it. The gates
and method below still bind.

## Mission and posture

- The goal is **0 DIFF, then 0 CMP_ONLY**. Nothing less. Byte-identity with
  Surelog for every corpus test.
- In an autonomous block ("work for the next N hours"), the session ends when
  the user ends it — **never at a "natural stopping point"**. There is no such
  point: the survey loop below always produces a next action.
- **Risk is a gate to run, not a reason to stop.** The cost of a failed
  experiment is one `git checkout` + rebuild (~3 minutes). The cost of NOT
  running it is a lost distinguisher and a stalled campaign. Never decline an
  experiment because it "touches a core path" or "seems entangled" — implement
  it, gate it, and let goldens + corpus + the class-change join answer.
- Every label like "hard", "quirky", "entangled", "subtler than modeled" is
  **provisional**: it means the distinguisher has not been found YET. Surelog
  is deterministic — for every behavioral difference between two tests, a
  concrete distinguishing property exists in their source or context. Your job
  is to find it, not to catalog the difficulty.

## Proof this works (case studies from sessions 12–13)

Every one of these was first declared blocked/risky/reverted — and then cracked
by finding the distinguisher. Internalize the pattern:

| "Blocked" item | Failed rule | The actual distinguisher |
|---|---|---|
| makeReturnVar packed_array_var (regressed BitSelectPartSelectInFunction) | "element isPackedArray" | element is a **TypeAlias** (`word[1:0]`) vs plain vector (`logic [1:0]`) |
| gen_for vs gen_region (regressed gen_test6 golden) | "all for-generates → gen_for" | **inline** `for (genvar c=...)` → gen_for; separate `genvar i;` → gen_region |
| anonymous-union struct_net (regressed union_simple) | "anonymous → net" | initially wrong; later resolved via per-case SL modeling (struct_var for array-of-struct containers etc.) |
| pkg nested-struct TOP form (regressed BitsCallOnStructMember) | "nested container → single-prefix dot" | nested container **AND the package is wildcard-imported**; qualified-only use keeps the doubled form |
| struct-param cluster (5+ failed attempts, "3 stacked blockers") | folding / sharing guesses | decoded SL's **3-object model** from the cmp dump: def→shared typedef ts, elab op→module-scoped clone, elab param→instance clone with scoped members |
| DUMP_MATCH + CMP_FAIL on gen_for ("impossible") | — | uhdm-cmp compares fields the dump prints identically: SL fills **plural** VpiForInitStmts but **singular** VpiForIncStmt (found with cmptool, see below) |
| genvar CA ref (MemoryPort) | kept the ref | elab gen CA folds the **genvar** to its iteration value; **written** localparams don't |
| package typedef order (regressed local_nested after 5Level fix) | "name-sorted everywhere" | **create in source order** (intra-pkg refs resolve), **list name-sorted** |

The pattern: a regression on test X while helping test Y is the single most
informative experiment you can run. X and Y differ in exactly the property
your rule is missing. `diff` the two DUTs. The difference IS the gate.

## The main loop (repeat until the block ends)

1. **SURVEY** — refresh the DIFF ladder and first-divergence kinds:
   ```sh
   awk -F, '$2=="DIFF" && $3 ~ /DUMP_DIFF/ { n=$3; sub(/.*DUMP_DIFF /,"",n); sub(/ .*/,"",n); print n","$1 }' \
       results/baseline_auto.csv | sort -n | head -40
   # for each: WORK=$SP/<tag>_$d ./scripts/converge.sh $T/$d/dut.sv ; then read
   # the FIRST object kind on each side of cmp.log:
   #   LHS kind -> RHS kind   (LHS = Surelog, RHS = ours)
   ```
   Tally the (LHS→RHS) pairs. Clusters (same pair across several tests) are
   the highest-leverage targets. Re-survey after every few commits — fixes
   cascade and re-shape the ladder.

2. **PICK** the highest-frequency pattern, or the next layer of a test you
   already decoded. Prefer DIFF over CMP_ONLY always (cmp = semantics;
   CMP_ONLY = byte-cosmetics — see "Priorities" below).

3. **DECODE before coding.** Print Surelog's actual structure — never guess:
   - `cmp.log` first: it names the exact first divergence (LHS/RHS decompile).
   - grep the SL dump for every occurrence of the object with context
     (`grep -n -A6 "struct_typespec: (name)"`), both views (allModules =
     def, topModules = elab), and the weak tail
     (`awk '/weaklyReferenced/{f=1} f&&/^\\_/'`).
   - Count invisible things: `vpiInstance` occurrences, object multiplicity,
     parent chains.
   - **DIRECTION DISCIPLINE**: in every diff, `-` = Surelog/golden, `+` =
     ours. Say it explicitly in your analysis every time — this was misread
     repeatedly and each misread cost a full wasted edit-build-test cycle.

4. **IMPLEMENT the smallest change that transcribes the observation.** The
   attempts that landed were transcriptions of observed SL structure; the ones
   that failed were guesses.

5. **SPOT-TEST** the representative test AND the known-sensitive neighbors
   (tests that share the touched mechanism — previous PASSes in the same
   family, the goldens).

6. **GATE** (exact recipe below). The gate decides, not intuition.

7. **COMMIT or REFINE**:
   - Gate clean → `cp results/<x>.csv results/baseline_auto.csv`, commit with
     mechanism-explaining message, continue immediately.
   - Demotion → the demoted test names the missing distinguisher: diff its
     DUT against the helped test's DUT, add the gate condition, loop to 5.
     **Revert-and-refine, never revert-and-abandon**: a revert without a
     written distinguisher-hypothesis and a follow-up attempt is a failure.

8. **LOG the mechanism** (not just the tally) in HANDOFF.md, then go to 1.
   Docs happen ALONGSIDE work, never INSTEAD of it.

## Priorities (user-set, explicit)

1. **DIFF → anything better** (real semantic bugs; uhdm-cmp fails).
2. **cmp-advance** inside a still-DIFF test (first divergence moves deeper).
3. **CMP_ONLY → PASS** (byte polish; still real progress).
4. Dump-line reductions on DIFF tests.

Dump-line GROWTH on a still-DIFF test is FINE when cmp advances. The only
hard constraints: goldens 23/23, no PASS→anything, no CMP_ONLY→DIFF.

## Debugging techniques, ranked

1. **cmp.log** (LHS/RHS first divergence). Fix, re-run, repeat — a DIFF test
   converges by LAYERS. Do not estimate difficulty from dump-diff size:
   StructParameter's "101 hopeless lines" decomposed into 3 clean rules.
2. **Decode SL structure** (step 3 above).
3. **Pairwise DUT diff** for distinguisher hunting. Recurring distinguishers
   that actually resolved items here: inline vs separate declaration; wildcard
   vs qualified package use; param-type vs signal-type use; pattern vs cast vs
   literal vs ref RHS; flat vs nested/array-of-struct members; def vs elab
   view; package vs module scope; typedef'd vs anonymous type; single vs
   multiple importers/instances.
4. **DUMP_MATCH + CMP_FAIL → uhdm-strictcmp.** `build/uhdm-strictcmp <golden> <ours>` runs uhdm-cmp's own Compare first and prints the failing pair with its parent-chain path (`lhsPath:`/`rhsPath:`), then, when stage 1 is equal, the first differing judge-blind field per object and a per-field tally. It replaced tools/cmptool (2026-09-24).
5. **SafeCompare semantics** (for reading cmp.log): "RHS: <null>" = ours lacks
   an object SL has at that slot (singular-field SafeCompare with rhs null
   sets only m_failedLhs). Vector size mismatches set both sides to the
   CONTAINERS.

## The gate (exact recipe)

```sh
# build (in the background; a result from a stale binary is not a result)
cmake --build build -j 2 > /tmp/build.log 2>&1; tail -1 /tmp/build.log; md5sum build/slang-uhdm
# quick gate (a few tests, both corpora, both modes)
tests/sweep.sh --filter '^Assign' | tail -3      # regressions=0
# probe cases vs their baseline (strict since 2026-09-24: EQUAL = uhdm-cmp AND
# uhdm-strictcmp equal; STRICT_NOTEQUAL cases are the recorded residue)
python3 scripts/check_probe.py --jobs 3 --workdir /tmp/pw --out /tmp/pw/probe.csv
python3 scripts/compare_results.py /tmp/pw/probe.csv results/golden_probe.csv   # regressions=0
# the full gate (all five stages, about an hour): probe, surelog, uhdm2rtlil, downstream, sv-tests
tests/sweep.sh --jobs 3 --workdir /tmp/<sweepdir>   # rc 0; regressions=0 on every compare line; downstream unchanged
```
A regression (a row leaving CMP_EQUAL/EQUAL, or a downstream row leaving
IDENTICAL) means refine or revert+refine. A conversion (STRICT_NOTEQUAL ->
CMP_EQUAL) is promoted into `results/golden_*.csv` by the landing commit,
with the law index regenerated (`python3 scripts/law_index.py`).

Every landing that names a law (`§ name`), adds an case or a pass README
regenerates the law index and commits it with the landing:
`python3 scripts/law_index.py` (tests/LAWS.md; the sweep fails on a stale
index). The index is how a law maps back to its cases, its
commits and its corpus tests once the cases have left `tools/probe/`.

## Rotation policy (per-LAYER, never per-session)

If one layer of one test resists after ~3–4 attempts **without new evidence
appearing**, rotate — to the NEXT DIFF test or cluster, never to a summary or
a pause. Record the decoded state + next hypothesis in HANDOFF first (30
seconds), so the next visit resumes mid-thought. Multiple session-12 items
were cracked on the second or third visit precisely because the decoded state
was written down.

## Anti-patterns (named, banned)

- **"This looks risky, so I'll document it instead."** → Run the gate. The
  gate measures blast radius; you don't.
- **"I've reached a natural stopping point / harvested the tractable items."**
  → False. Re-survey; the ladder re-shapes after every fix. Sessions 12–13
  "exhausted" the ladder three times and then fixed 25 more real bugs.
- **"Want me to continue?" / settling into a milestone summary mid-block.**
  → In an autonomous block the answer is always yes. Commit the milestone in
  one command and take the next survey item in the same breath.
- **"The rule is subtler than modeled"** with no follow-up hypothesis. →
  Subtler = a distinguisher exists that you haven't diffed out yet.
- **Estimating difficulty from dump-diff size.** → Layers, not lines.
- **Editing before decoding** (guessing at SL's model). → Transcribe, don't
  guess.
- **Trusting results from a timed-out build.** → `Built target` or it didn't
  happen.
- **Re-running the same failed experiment verbatim.** → Each retry must embed
  a new observation.

## Session mechanics

- Scratch per test: `WORK=$SCRATCHPAD/<tag>_<test> ./scripts/converge.sh ...`
- Corpus gates run in background while you probe/decode the next item.
- Commit messages explain the MECHANISM (they are the campaign's memory).
- HANDOFF.md gets mechanisms and open-item decoded-state; tallies are
  secondary.
- Trailer: `Co-Authored-By: Claude <model> <noreply@anthropic.com>`.
