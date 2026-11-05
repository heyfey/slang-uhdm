---
name: claim-equal
description: "How to claim that a slang-uhdm test, probe case or baseline row is EQUAL to Surelog's golden, and how to promote it. Use before stating any equality result or editing results/*.csv."
---

# Claiming EQUAL

A test is EQUAL when the pinned Surelog's database and slang-uhdm's database
for the same sources compare equal under **both** comparators, measured by
the gate against the committed baseline. Nothing else is a claim: not a dump
diff, not one comparator, not a run of a stale binary, not a number copied
from a brief.

Job counts below are the defaults of AGENTS.md; the user's prompt overrides them.

## 1. Build the binary you measure

    cmake --build build -j 2 2>&1 | grep -E ' error |Built target slang_uhdm$'   # "Built target" or it did not build
    md5sum build/slang-uhdm
    cp build/slang-uhdm /tmp/<tag>.bin && chmod 555 /tmp/<tag>.bin && export SLANG_UHDM=/tmp/<tag>.bin

`verify_golden.py` and `tests/sweep.sh` default `SLANG_UHDM` to the main-tree
binary. Export it per binary, and after a run confirm the path in a row's
`<workdir>/<corpus>/<mode>/<Test>-*/cmds.txt` (match the full path; the word
`slang-uhdm` also matches the golden cache directory).

## 2. Judge one pair by hand

    G=<golden>.uhdm; O=<ours>.uhdm              # the golden is golden.uhdm in the cache dir named on line 1 of cmds.txt
    $UHDM_CMP $G $O; echo rc=$?                  # rc 0 = uhdm-cmp equal; the first divergence goes to STDERR
    build/uhdm-strictcmp $G $O | tail -n 3       # must print STRICT_EQUAL

Order is fixed: golden first, ours second (LHS is always Surelog). A pair is
EQUAL only when uhdm-cmp returns 0 **and** the strict comparator prints
`STRICT_EQUAL`. uhdm-cmp equal with a strict difference is `STRICT_NOTEQUAL`,
counted as not equal. For a single-file case, `WORK=<dir> scripts/converge.sh
<case>/dut.sv` runs both tools and leaves `cmp.log`, `surelog.dump`,
`slang.dump` and `dump.diff` in `<dir>`; it does not run the strict comparator.

## 3. Measure through the harness, not by hand

One test or a few (give the compare the same filter, or every other row reads
as not run):

    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out /tmp/w/sl.csv --workdir /tmp/w/sl --filter '^Name$'
    python3 scripts/compare_results.py /tmp/w/sl.csv results/golden_surelog.csv --filter '^Name$'
    python3 scripts/check_probe.py --jobs 3 --out /tmp/w/probe.csv --workdir /tmp/w/p --filter 'r11u492repro'
    python3 scripts/compare_results.py /tmp/w/probe.csv results/golden_probe.csv --filter 'r11u492repro'
    python3 scripts/check_svtests.py --jobs 3 --out /tmp/w/sv.csv --workdir /tmp/w/sv --filter 'tnoc'

The compare prints REGRESSION, CONVERSION and CHANGE rows and ends with
`regressions=N conversions=N changes=N`. Only a CONVERSION line names a test
you may claim.

## 4. Run the full gate before any claim that lands

    tests/sweep.sh --jobs 3 --workdir /tmp/<tag> > /tmp/<tag>.log 2>&1; echo rc=$?
    grep -E 'regressions=|CONVERSION|REGRESSION|CHANGE' /tmp/<tag>.log

Required: exit 0, `regressions=0` on every stage, the downstream stage
unchanged, and the CONVERSION lines exactly the rows you claim, no others. A
CHANGE on a row you did not predict is a finding to explain, not noise. The
sweep takes about an hour at three jobs once the goldens are cached.

Negative control (the gate can see a bad binary):

    SLANG_UHDM=/bin/false tests/sweep.sh --filter '^Assign' | tail -n 1     # must NOT read regressions=0

Determinism: run the largest rows (MiniAmiq, SeqDriver) three more times
from their `cmds.txt` command with `-o` redirected; all four `.uhdm` md5s must
agree. Scoreboard/default is known to flip order between runs; attribute it
only by sorted dumps.

Goldens come from the cache (AGENTS.md, Golden cache): a sweep builds any
missing golden itself, and the cmds.txt line 1 says `golden cache hit` or
names the build. Never hand-copy a `.uhdm` as a golden and never commit one.

## 5. Promote

A conversion is promoted in the landing commit, never before (the full
procedure is the land-change skill):

- Surelog or uhdm2rtlil row: edit that exact row in `results/golden_surelog.csv`
  or `results/golden_uhdm2rtlil.csv` to `CMP_EQUAL`, empty detail, strict `equal`.
- Probe: `cp /tmp/<tag>/probe.csv results/golden_probe.csv` (the harness writes
  the baseline's exact shape and order; on a clean run the two files are
  byte-identical, so the diff of a promotion is the promoted rows alone).
- sv-tests: `python3 scripts/check_svtests.py --write ...` or copy the sweep's
  `svtests.csv` over `results/golden_svtests.csv`.
- Then `python3 scripts/accounting.py --md` to refresh GOLDEN_EQUIVALENCE.md §3.3,
  `python3 scripts/law_index.py` for tests/LAWS.md, and commit all of it with the fix.

Never edit a baseline row for any other reason. A row leaving EQUAL is a
regression to fix, not a baseline to update. Exceptions decided by the user
are recorded in tests/README.md and README.md (the four fenced tests, Tnoc,
stamped_gen_param, three sv-tests rows); do not add to that list.

## What is not a claim

- "The dumps match": uhdm-cmp reads fields the dump prints identically
  (plural vs singular containers), and the strict comparator reads fields the
  dump does not print.
- "uhdm-cmp passes": the gate is strict since 2026-09-24.
- A result from a binary whose build printed no `Built target`, or from a
  sweep whose `cmds.txt` names a different binary.
- A count from a filtered compare without the same `--filter`.
- Any number about a fenced test (tests/FENCED.md) other than its csv row.

## Gotchas that cost passes

- `uhdm-cmp` writes the head to stderr: `2>/dev/null` makes every head read empty.
- `verify_golden.py` records a segfault (rc 139) as `SLANG_REJECT` with the last
  warning as detail. Record rc in your own case runs.
- A partly written dump reads like a result: re-read until byte-stable.
- `grep -c` with zero matches exits 1 and kills a `set -e` chain.
- The default and testflags goldens of one test are different cache entries.
