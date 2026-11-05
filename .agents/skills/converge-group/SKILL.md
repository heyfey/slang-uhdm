---
name: converge-group
description: "How to drive a group of not-equal slang-uhdm tests to EQUAL: census the first divergences, cluster them, pick the highest-leverage cluster, fix with a golden grid, verify adversarially, land one patch at a time, repeat until the group reads zero or every remainder is a named residue. Use for a suite, a corpus family or a new release matrix."
---

# Converging a group of tests

One test converges by layers; a group converges by clusters. The method that
closed the Surelog suite, the uhdm2rtlil suite, the probe set and sv-tests
(passes 1 to 491) is below. It assumes `fix-one-test` for each law and
`claim-equal` for each claim.

## 1. Census the group

Run the stage and collect the first divergence of every not-equal row:

    tests/sweep.sh --corpus <stage> --jobs 3 --workdir /tmp/c           # or the harness with --filter
    awk -F, '$3!="CMP_EQUAL" && $3!="EQUAL"' /tmp/c/<stage>.csv | cut -d, -f1-4 | sort -t, -k3

For each `CMP_NOTEQUAL` / `DIFFERENT` / `NOT_EQUAL` row read the head of
`cmp.log` (uhdm-cmp's stderr in the row directory) as a pair `LHS kind -> RHS
kind` plus the owner's kind. For each `STRICT_NOTEQUAL` row the `strict`
column already names the first differing field and count
(`differ:line(7)`). Tally the pairs and fields across the group. The strict
column of the baseline is a census you get for free:

    cut -d, -f4 results/golden_probe.csv | sed 's/(.*//' | sort | uniq -c | sort -rn

Calibrate any scorer golden-versus-golden first (must read 0).

## 2. Pick the cluster

Rank by rows per fix: the same (LHS kind, RHS kind) pair across many rows is
one law; a single huge row is many laws. Prefer `CMP_NOTEQUAL` (semantics)
over `STRICT_NOTEQUAL` (names, spans, decompile text), and a cluster over a
singleton. Re-census after every few landings: fixes cascade and the ranking
changes.

## 3. Find the distinguisher

Inside the cluster, pair a row that is equal with one that is not and shares
the mechanism, and `diff` their sources. Distinguishers that have resolved
clusters here: inline versus separate declaration; wildcard versus qualified
package use; parameter-type versus signal-type use; pattern versus cast versus
literal versus reference on the right-hand side; flat versus nested member;
definition versus elaborated view; package versus module scope; typedef'd
versus anonymous type; one versus several importers or instances; a typedef
alias versus a plain vector of the same shape. The difference between the two
sources **is** the predicate. Then build the golden grid over those axes
(fix-one-test §4) and land the law (§5 to §7).

## 4. Run passes as implementer plus adversarial verifier

Every landing of the campaign ran as two agents, each in its own worktree at
the same base commit:

- **Implementer** (`tools/probe/r11u<N>repro/`): decodes the head from the
  pristine cmp log itself, censuses the cluster, decodes the law from
  Surelog's source, measures it on a golden grid, implements the smallest
  switched change, predicts the movers by name, runs the full gate, delivers
  a patch against the base and a README whose final text is the numbers.
- **Verifier** (`tools/probe/v11u<N>repro/`, the verify-pass skill): rebuilds both binaries, reproduces
  every headline number, then tries to break the law with cases along axes
  the implementer did not vary (orders, names, scopes, contexts; a grid that
  names everything `a_t`, `b_t` over `A`, `B` is self-confirming). Any
  pristine-right, patched-wrong cell on legal SystemVerilog the verifier fixes
  (minimal, switched), re-runs the full battery, and ships the verified
  patch. About half of all landings needed such a fix; several caught
  segfaults on legal SystemVerilog that no gate would have shown.
- **Master** integrates one patch at a time on the main tree (the land-change
  skill): apply, build, full gate, promotions, law index, one commit, then
  the next patch. Agent baselines are often stale: only main-tree gates count.

As many passes at a time as AGENTS.md's resource defaults allow (the user's
prompt overrides); a brief states the base commit, the pass
number, the target rows with their head lines verbatim, the suspected
mechanism as a question, the neighbouring laws by name so the pass does not
fight them, and the deliverable. Pass a model and effort explicitly to every
agent you spawn.

## 5. Refine, rotate, never pause

- A regression on row X while helping row Y is the most informative result a
  pass can produce: X and Y differ in the property the predicate lacks. Add
  the condition and re-gate. A revert without a written distinguisher
  hypothesis and a follow-up attempt is a failure.
- After three or four attempts on one layer with no new evidence, rotate to
  the next cluster, after writing the decoded state and the next hypothesis
  in the pass README. Several clusters were cracked on the second visit
  because that state was written down.
- Labels such as "hard", "quirky" and "entangled" are provisional. Surelog is
  deterministic: for every behavioural difference between two rows a concrete
  property of their source or context exists. Find it or record it as a
  residue with its first differing object; never as a difficulty.
- Risk is a gate to run, not a reason to stop: a failed experiment costs one
  checkout and a rebuild.

## 6. Done means zero or named

The group is converged when every row both tools compile is EQUAL, except
rows the user decided to leave (recorded in tests/README.md and README.md:
the four fenced tests, Tnoc, stamped_gen_param, and three sv-tests rows).
Everything short of that is a residue: a row or case named in the pass README
and in tests/LAWS.md under the law that reaches it, with its first differing
object. Residue cases stay under `tools/probe/<pass>repro/`; none may occur
in a corpus without being counted.

Report progress as the gate reports it (`python3 scripts/accounting.py --md`,
the compare lines of the last sweep), never as an estimate. Rate is
`git log --since='24 hours ago' --oneline | wc -l`.

## Anti-patterns, named

- Editing before decoding (guessing Surelog's model).
- Estimating difficulty from dump-diff size.
- Trusting a timed-out build, a stale baseline, or a brief's framing.
- Re-running the same failed experiment verbatim.
- Declaring "a natural stopping point" in an autonomous block: re-census instead.
- A census keyed on a slot rather than on identity (blind below the slot).
- Counting the weaklyReferenced tail, or attributing Scoreboard/default order flips to a law.
