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
| `results/golden_surelog.csv`, `results/golden_uhdm2rtlil.csv` | the committed scoreboards: one row per test and mode (`name,mode,status,detail,blocked_by,strict`) | 1596 + 1742 rows |
| `results/gate_uhdm2rtlil.csv` | the uhdm2rtlil testflags rows alone (the older gate) | 871 rows |
| `tests/probe/<pass>/<grid>/<arm>/dut.sv` | the probe-arm regression set, judged by uhdm-cmp against cached Surelog goldens (see tests/probe/README.md) | 2833 arms |
| `tools/probe/` | per-pass evidence (READMEs, scripts, measurements, and the arms that still judge NOT_EQUAL) | |

Two modes per test. In `default` mode both tools get only the sources. In
`testflags` mode Surelog gets the test's own command line and slang-uhdm gets
its translation. A row is `CMP_EQUAL` when `uhdm-cmp` finds no difference
between the two databases. The `strict` column then reports
`tools/uhdm-strictcmp`'s verdict on that pair: it runs uhdm-cmp's own
comparison first (so nothing uhdm-cmp rejects can pass) and then walks both
databases in the same order comparing the fields uhdm-cmp never reads (name,
definition name, full name, file basename, the four span fields, decompile,
size, value, constant type, child order); `equal`, or
`differ:<first differing field>(<objects differing>)`. It is a measurement
today and the intended equality of the gate once the corpus reaches zero.
Typespec identity (Surelog copies a typespec per use where we share one
object) is canonicalised by the walk, together with the full names inside
such a copy, and is outside the strict contract, see GOLDEN_EQUIVALENCE.md.

## The law index

Every exporter rule is a law, `§ name` with the name ending in its pass
number, named in the source at its sites, in the pass README under
`tools/probe/<pass>/` and in the landing commit. `tests/LAWS.csv` and
`tests/LAWS.md` map every law back to its pass, its commits on this
branch, its source files and switches, its arms under `tests/probe/` and
`tools/probe/`, and the corpus tests its title and commits name.
`tests/ARMS.csv` maps every arm under `tests/probe/` to its laws and says
how the attribution was made: the arm's own text, a README row naming the
arm, the README section whose heading names a law, or only the pass's law
set. Anchors are names, never line numbers: `grep -n '§ <law>' src
include` finds a law's sites at any commit, and a switch is an environment
variable name. `scripts/law_index.py` generates the three files, and the
sweep fails when they are stale, so every landing regenerates them.

## Setup

    git submodule update --init --recursive           # the corpora, slang, and Surelog's UHDM + capnproto
    cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j 4   # slang-uhdm (slang + UHDM in-tree)
    make -C third_party/Surelog release               # the producer: build/bin/surelog, build/third_party/UHDM/bin/uhdm-{cmp,dump}

The judge (`uhdm-cmp`) and the dumper are taken from the Surelog submodule's
build tree first, then from this tree's own build of the same UHDM commit
(`build/third_party/Surelog/third_party/UHDM/bin`), then from `PATH`.

If Surelog and UHDM are already built elsewhere, point at them instead of
building the submodule:

    export SURELOG=/path/to/surelog UHDM_CMP=/path/to/uhdm-cmp UHDM_DUMP=/path/to/uhdm-dump

The variables `SLANG_UHDM`, `SURELOG_ROOT` and `UHDM2RTLIL_TESTS` override
the other locations the same way.

## Running

    tests/sweep.sh                     # probe arms, both corpora in both modes, then the downstream gate
    tests/sweep.sh --corpus probe      # the 2833 probe arms alone (about 15 s once their goldens are cached)
    tests/sweep.sh --corpus uhdm2rtlil --filter '^ibex'

`tests/sweep.sh` exits 1 when any probe arm is not EQUAL, any corpus row's
status moved away from `CMP_EQUAL`, or any downstream verdict is not IDENTICAL
(or SLANG_REJECT, or the verdict recorded in `results/downstream_uhdm2rtlil.csv`).
Do not commit on a nonzero exit.
It prints the status histogram per mode, every changed row, and how many
producer runs were served from the golden cache.

Direct harness use:

    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out out.csv --workdir /tmp/wd
    python3 scripts/compare_results.py out.csv results/golden_surelog.csv

## The downstream gate (uhdm2rtlil)

`scripts/downstream_uhdm2rtlil.py` proves that slang-uhdm's database drives
the downstream consumer to the same result as Surelog's. For every
uhdm2rtlil test two lanes run uhdm2rtlil's own flow (`read_uhdm` through the
Yosys plugin, RTLIL before and after `hierarchy`/`proc`/`opt`, `synth`, the
gate-level netlist): one from the database uhdm2rtlil's own Surelog writes
(its flags, cached in the golden cache), one from slang-uhdm's. The verdict
per test is IDENTICAL (same Yosys status and byte-identical RTLIL and
netlist), EQUIVALENT (texts differ but uhdm2rtlil's `test_equivalence.sh`
proves the netlists equivalent), DIVERGENT, STATUS_DIFF, SLANG_REJECT (the
allowed exception) or SURELOG_FAIL (no reference). Every test must be
IDENTICAL or SLANG_REJECT; `results/downstream_uhdm2rtlil.csv` records the
verdicts and any reviewed exception.

It needs the downstream toolchain built once inside the submodule:

    cd third_party/uhdm2rtlil && git submodule update --init --recursive
    make CPU_CORES=4          # its Yosys fork (out/current/bin/yosys), its Surelog, build/uhdm2rtlil.so

(`YOSYS`, `UHDM2RTLIL_PLUGIN`, `UHDM2RTLIL_SURELOG` and `UHDM2RTLIL_ROOT`
override the locations. The Yosys fork needs bison 3.6 or newer; without
tcl, readline, libffi or zlib headers configure its build with the matching
`-DYOSYS_WITHOUT_*=ON` options before running make.)

    tests/sweep.sh --corpus downstream
    python3 scripts/downstream_uhdm2rtlil.py --out out.csv --baseline results/downstream_uhdm2rtlil.csv

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
