---
name: land-change
description: "How the master integrates a verified slang-uhdm fix into the main tree: apply, build, full gate, byte comparison against the control sweep, promotion of converted rows, law index, one commit with explicit paths, control rotation, scratch pruning. Use for every landing and for any commit that touches src/, results/ or tests/probe/."
---

# Landing a change

One patch at a time, from the main tree at HEAD, every step a gate: stop at
the first red. Job counts are the defaults of AGENTS.md; the user's prompt
overrides them.

## 1. Apply

    git status --short | grep -v '^??'                 # must be empty; remove stray ?? files first
    P=/tmp/r11u<N>.verified.patch                       # or r11u<N>.patch when the verifier changed nothing
    git apply -3 $P && git reset -q                     # --3way STAGES; unstage so the commit takes explicit paths
    grep -c '<<<<<<<' $(git diff --name-only -- src include) # 0

Audit the patch: fence scan (every file of the patch, names from the
`FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`, count 0); no edits
under `results/`; no `.uhdm`, no `.patch`, no header under `src/` other than
the two in `src/law/`; the surface is production files plus
`tools/probe/r11u<N>repro/`, `tools/probe/v11u<N>repro/` and the cases moved
into `tests/probe/`.

## 2. Build and freeze

    cmake --build build -j 2 2>&1 | grep -E ' error |Built target slang_uhdm$'
    md5sum build/slang-uhdm; cp build/slang-uhdm /tmp/land<N>.bin; chmod 555 /tmp/land<N>.bin

A header change rebuilds everything; wait for `Built target`. Never build
while a sweep runs.

## 3. Gate

    SLANG_UHDM=/tmp/land<N>.bin tests/sweep.sh --jobs 3 --workdir /tmp/int<N> > /tmp/int<N>.log 2>&1; echo rc=$?
    grep -E 'regressions=|CONVERSION|REGRESSION|CHANGE' /tmp/int<N>.log
    python3 scripts/law_index.py --check

Required: rc 0, `regressions=0` on all five stages, downstream unchanged, the
CONVERSION and CHANGE lines exactly the pass's predicted movers. Then compare
bytes against the control (the previous landing's sweep directory):

    for c in surelog uhdm2rtlil downstream; do bash tools/probe/r10oth4repro/byteverify.sh /tmp/int<N>/$c /tmp/<control>/$c | tail -n 2; done

Every mover must be one the pass predicted by name. An unpredicted mover is
attributed before anything lands: `uhdm-dump` both databases, strip the work
directory path, sort (order-blind), diff. Scoreboard/default flips order
between runs and is attributed only this way. Re-run the largest rows three
times from their `cmds.txt` command; all hashes agree.

## 4. Promote and index

- Converted Surelog or uhdm2rtlil rows: edit the exact row in
  `results/golden_*.csv` (`CMP_EQUAL`, empty detail, strict `equal`).
- Probe: `cp /tmp/int<N>/probe.csv results/golden_probe.csv`; sv-tests:
  `check_svtests.py --write` or copy the sweep's csv.
- `python3 scripts/accounting.py --md` (GOLDEN_EQUIVALENCE.md §3.3),
  `python3 scripts/law_index.py` (tests/LAWS.md).
- Documents the landing implies (counts in README.md's table or
  tests/README.md) change in the same commit. Documentation-only work may be
  its own commit.

## 5. Commit with explicit paths

    git add -- src/<files> tests/LAWS.md results/<changed csvs> tools/probe/r11u<N>repro tools/probe/v11u<N>repro tests/probe/r11u<N>repro tests/probe/v11u<N>repro <docs>
    git commit -F <message file>
    git status --porcelain | wc -l            # 0

Never `git add -A`, never `git stash`. The message: a subject naming the pass
and its laws; the decoded rule with Surelog file:line; durable measurements
(rows converted, cases, movers, "gate clean" in one line); residues; the
evidence pointer (`tools/probe/r11u<N>repro/README.md`). No `/tmp` paths, no
md5s, no worktree or rotation notes, no "(user DATE)" tags. Project
attribution trailers as the user's instructions state.

## 6. Rotate and prune

- The landing's sweep directory becomes the control for the next landing;
  remove the previous control.
- Remove the pass's worktrees (`git worktree remove --force`, `git worktree prune`).
- Prune `/tmp` by an explicit list of this pass's files (never a glob that
  can reach another live pass or a deliverable; copy deliverables to the
  scratchpad first). Never prune the golden cache.
- Refill the agent slot with the next pass at the new HEAD.
