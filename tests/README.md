# Tests

Everything here runs from a fresh clone. The two reference corpora and the
reference producer are git submodules, tool and corpus locations resolve
relative to this repository, and the producer's golden databases are cached
after the first run.

## What the repository holds

| path | what | count |
|---|---|---|
| `third_party/Surelog` | the pinned Surelog (v1.87): the producer binary once built, its `tests/` and `third_party/tests/` suites (one `<Name>.sl` command line per test) and `third_party/UVM` | 798 tests |
| `third_party/uhdm2rtlil` | the pinned uhdm2rtlil checkout; `test/<name>/dut.sv` (or `dut.v`, or a `project.f`) per test | 871 tests |
| `results/golden_surelog.csv`, `results/golden_uhdm2rtlil.csv` | the committed scoreboards: one row per test and mode (`name,mode,status,detail,blocked_by,dump`) | 1596 + 1742 rows |
| `results/gate_uhdm2rtlil.csv` | the uhdm2rtlil testflags rows alone (the older gate) | 871 rows |
| `tools/probe/` | per-pass evidence (grid arms, scripts, measurements); not run by any check | |

Two modes per test. In `default` mode both tools get only the sources. In
`testflags` mode Surelog gets the test's own command line and slang-uhdm gets
its translation. A row is `CMP_EQUAL` when `uhdm-cmp` finds no difference
between the two databases; the `dump` column says whether the dump text is
also byte-identical (`match`) or not (`differ`).

## Setup

    git submodule update --init                       # the two corpora (no recursion needed to run)
    # the producer: build Surelog once inside the submodule (needs its own submodules)
    git -C third_party/Surelog submodule update --init --recursive
    make -C third_party/Surelog release               # -> build/bin/surelog, build/third_party/UHDM/bin/uhdm-{cmp,dump}
    # slang-uhdm itself: see README.md "Build"

If Surelog and UHDM are already built elsewhere, point at them instead of
building the submodule:

    export SURELOG=/path/to/surelog UHDM_CMP=/path/to/uhdm-cmp UHDM_DUMP=/path/to/uhdm-dump

The variables `SLANG_UHDM`, `SURELOG_ROOT` and `UHDM2RTLIL_TESTS` override
the other locations the same way.

## Running

    tests/sweep.sh                     # both corpora, both modes, compared to results/golden_*.csv
    tests/sweep.sh --corpus uhdm2rtlil --filter '^ibex'

`tests/sweep.sh` exits 1 when any row's status moved away from `CMP_EQUAL`.
It prints the status histogram per mode, every changed row, and how many
producer runs were served from the golden cache.

Direct harness use:

    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out out.csv --workdir /tmp/wd
    python3 scripts/compare_results.py out.csv results/golden_surelog.csv

## The golden cache

Surelog's database for a test never changes while the producer and the
sources are pinned, so the harness builds each golden once and caches it under
`~/.cache/slang-uhdm-goldens` (`GOLDEN_CACHE=<dir>` relocates it,
`GOLDEN_CACHE=0` disables it). The cache key is Surelog's version line plus
the test directory and arguments spelled relative to the corpus roots, so the
same cache serves every clone on a machine and can be copied to another
machine. A test whose arguments reach outside its directory (`../ibex/rtl`,
the UVM trees) embeds its absolute source path in judged `__FILE__` strings,
so its golden is keyed per checkout location and rebuilt once per clone.
The first sweep on a machine takes about an hour at `--jobs 3`
because it runs the producer on every test. Later sweeps take a few minutes
per corpus. Failures are not cached unless `GOLDEN_CACHE_FAILURES=1`.

Six Surelog tests (`DEFERRED` rows) are skipped by default because their
golden generation exceeds this machine's memory or the timeout;
`GOLDEN_DEFER=0` runs them.

## Updating the scoreboards

`results/golden_*.csv` change only when a row's status changes on purpose (a
conversion or a deliberate fence). Edit the exact row, then regenerate the
`GOLDEN_EQUIVALENCE.md` table with `python3 scripts/accounting.py --md` in the
same commit.
