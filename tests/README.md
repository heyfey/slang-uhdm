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
| `results/golden_probe.csv` | the committed probe baseline: one row per probe case (`case,status,detail,strict`) | 31943 rows |
| `results/golden_svtests.csv` | the committed sv-tests baseline: one row per test of the chipsalliance sv-tests suite (`case,status,detail,strict`; see the sv-tests stage below) | 2346 rows |
| `results/downstream_uhdm2rtlil.csv` | the downstream verdicts (see the downstream gate below) | 871 rows |
| `results/gate_uhdm2rtlil.csv` | the uhdm2rtlil testflags rows alone (the older gate) | 871 rows |
| `tests/probe/<pass>/<grid>/<case>/dut.sv` | the probe-case regression set, judged by uhdm-cmp and uhdm-strictcmp against cached Surelog goldens (see tests/probe/README.md) | 31943 cases |
| `tools/probe/` | per-pass evidence (READMEs, scripts, measurements, and the cases that still judge NOT_EQUAL) | |

Two modes per test. In `default` mode both tools get only the sources. In
`testflags` mode Surelog gets the test's own command line and slang-uhdm gets
its translation.

**The gate's equality is strict (since 2026-09-24).** A row is `CMP_EQUAL`
only when `uhdm-cmp` finds no difference between the two databases AND
`tools/uhdm-strictcmp` reads them `STRICT_EQUAL`. The strict comparator runs
uhdm-cmp's own comparison first (so nothing uhdm-cmp rejects can pass) and
then walks both databases in the same order comparing the fields uhdm-cmp
never reads (name, definition name, full name, file basename, the four span
fields, decompile, size, value, constant type, child order). The `strict`
column holds its verdict on every pair uhdm-cmp reads equal: `equal`, or
`differ:<first differing field>(<objects differing>)` (`differ:stage1`,
`timeout`). Typespec identity (Surelog copies a typespec per use where we
share one object) is canonicalised by the walk, together with the full names
and spans inside such a copy, and is outside the strict contract (the
identity residue is zero), see GOLDEN_EQUIVALENCE.md.

The statuses, best first:

| status | meaning |
|---|---|
| `CMP_EQUAL` (probe: `EQUAL`) | uhdm-cmp equal and strict-equal |
| `STRICT_NOTEQUAL` | uhdm-cmp equal, not strict-equal; the strict verdict is in `detail` and `strict` |
| `CMP_NOTEQUAL` (probe: `NOT_EQUAL`) | uhdm-cmp reads a difference |
| `SLANG_REJECT`, `SURELOG_FAIL`, `NO_UHDM`, `NO_DATABASE`, `UNTRANSLATABLE`, `TIMEOUT`, `DEFERRED` (probe: `SLANG_FAIL`, `SURELOG_FAIL`, `TIMEOUT`) | no comparison |

The `STRICT_NOTEQUAL` rows of the baselines are the explicit residue of the
strict gate: the fail list of `tools/probe/r11u132map` (`fail_list.csv`,
`probe_fail_list.csv`) names each one's first differing object and the
emitter site that writes it. The gate stays red only on a regression
against them, exactly as the uhdm-cmp gate works.

## The law index

Every exporter rule is a law, `§ name` with the name ending in its pass
number, named in the source at its sites, in the pass README under
`tools/probe/<pass>/` and in the landing commit. `tests/LAWS.md` records the
map between laws, cases and commits: one entry per law with its commits,
its pass, its switches, its source files, its corpus tests, and its cases
by name in the gate (`tests/probe/`) and in the evidence (`tools/probe/`).
`scripts/law_index.py` generates it (`--law <name>` and `--case <dir>`
print one entry), and the sweep fails when it is stale.

How the map stays current while fixes land and cases move:

- Name the law in the commit message as `§ name`; the commits column is
  read from `git log`.
- Give every case dir under `tests/probe/` a `LAW` file (one law name per
  line), or name the law in the case's first line as `// § name`. A case
  moved from `tools/probe/` keeps its pass in its path; give it its `LAW`
  file when you move it. `scripts/law_index.py --stamp` writes the file
  wherever the pass README already determines the law.
- Run `python3 scripts/law_index.py` before committing a change to a law,
  a case or a README, and commit `tests/LAWS.md` with it.

Anchors are names, never line numbers: `grep -n '§ <law>' src include`
finds a law's sites at any commit, and a switch is an environment variable
name.

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

    tests/sweep.sh                     # probe cases, both corpora in both modes, the downstream gate, then sv-tests
    tests/sweep.sh --corpus probe      # the 31943 probe cases alone (about ten minutes at three jobs once their goldens are cached)
    tests/sweep.sh --corpus svtests    # the sv-tests stage alone
    tests/sweep.sh --corpus uhdm2rtlil --filter '^ibex'

`tests/sweep.sh` exits 1 on a regression in any stage, or when any downstream
verdict is not IDENTICAL or the verdict recorded in
`results/downstream_uhdm2rtlil.csv`. The probe stage writes
`<workdir>/probe.csv` and each corpus stage `<workdir>/<corpus>.csv`;
`scripts/compare_results.py` joins each against its baseline
(`results/golden_probe.csv`, `results/golden_surelog.csv`,
`results/golden_uhdm2rtlil.csv`) and reads, per row:

- REGRESSION (exit 1): a row that leaves `CMP_EQUAL`; a `STRICT_NOTEQUAL` row
  whose status is no longer judge-equal; a row absent from the baseline (a
  new case or test) that is not `CMP_EQUAL` / `EQUAL`; a baseline row the run
  did not produce (a test or case that was not run, a probe case whose
  `dut.sv` is gone, a test the harness lost to an exception), except the rows
  the run's `--filter` excludes (`compare_results.py --filter REGEX`, matched
  as the harness matches it: on the test name, or the case path); a row of
  mode `harness` (verify_golden.py's record of an exception); a key listed
  twice in either csv; and in the probe stage any case uhdm-cmp does not read
  equal.
- CONVERSION: a row that enters `CMP_EQUAL`.
- CHANGE: any other status change, and a `STRICT_NOTEQUAL` row whose strict
  verdict changed, printed `old -> new` with the count delta when the first
  field is the same (`differ:line(30) -> differ:line(31) [line +1]`), so a
  larger residue on the same field is visible.

A pair is judge-equal only when the strict comparator agrees: its stage 1 is
uhdm-cmp's own Compare, so a pair it rejects there is `CMP_NOTEQUAL`
(`NOT_EQUAL`) whatever the binary at `UHDM_CMP` said, and `equal` needs the
comparator's own `STRICT_EQUAL` line (another binary at `STRICT_CMP`, such as
uhdm-cmp, which exits 0 on these arguments, reads nothing equal).

Do not commit on a nonzero exit.
It prints the status histogram per mode, every changed row, and how many
producer runs were served from the golden cache.

Direct harness use:

    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out out.csv --workdir /tmp/wd
    python3 scripts/compare_results.py out.csv results/golden_surelog.csv
    python3 scripts/check_probe.py --jobs 3 --out probe.csv --workdir /tmp/pw
    python3 scripts/compare_results.py probe.csv results/golden_probe.csv
    python3 scripts/check_svtests.py --jobs 3 --out svtests.csv --workdir /tmp/sw   # compares against results/golden_svtests.csv itself
    # a filtered run: give the compare the same REGEX, or every other baseline row fails as not run
    python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --out f.csv --filter '^ibex'
    python3 scripts/compare_results.py f.csv results/golden_uhdm2rtlil.csv --filter '^ibex'

## The downstream gate (uhdm2rtlil)

`scripts/downstream_uhdm2rtlil.py` proves that slang-uhdm's database drives
the downstream consumer to the same result as Surelog's. For every
uhdm2rtlil test two lanes run uhdm2rtlil's own flow (`read_uhdm` through the
Yosys plugin, RTLIL before and after `hierarchy`/`proc`/`opt`, `synth`, the
gate-level netlist): one from the database uhdm2rtlil's own Surelog writes
(its flags, cached in the golden cache), one from slang-uhdm's. The verdict
per test is IDENTICAL (same Yosys status and byte-identical RTLIL and
netlist), EQUIVALENT (texts differ but uhdm2rtlil's `test_equivalence.sh`
proves the netlists equivalent), DIVERGENT, STATUS_DIFF, SLANG_REJECT or
SURELOG_FAIL (no reference). Every test must be IDENTICAL or the verdict
`results/downstream_uhdm2rtlil.csv` records for it (a reviewed exception, or
a recorded SLANG_REJECT): a row that leaves IDENTICAL for SLANG_REJECT fails,
since the downstream command line (`-DSYNTHESIS`) can reach a rejection the
corpus stages never see, and so does a baseline test the run did not produce
(within `--filter`).

It needs the downstream toolchain built once inside the submodule:

    cd third_party/uhdm2rtlil && git submodule update --init --recursive
    make CPU_CORES=4          # its Yosys fork (out/current/bin/yosys), its Surelog, build/uhdm2rtlil.so

(`YOSYS`, `UHDM2RTLIL_PLUGIN`, `UHDM2RTLIL_SURELOG` and `UHDM2RTLIL_ROOT`
override the locations. The Yosys fork needs bison 3.6 or newer; without
tcl, readline, libffi or zlib headers configure its build with the matching
`-DYOSYS_WITHOUT_*=ON` options before running make.)

    tests/sweep.sh --corpus downstream
    python3 scripts/downstream_uhdm2rtlil.py --out out.csv --baseline results/downstream_uhdm2rtlil.csv

## The sv-tests stage

Since 2026-10-15 the fifth stage runs the chipsalliance
[sv-tests](https://github.com/chipsalliance/sv-tests) suite: every test
listed in `results/golden_svtests.csv` (2346 tests, every `tests/**/*.sv` of
the checkout at `579f6484`) is run by `scripts/check_svtests.py` through
`scripts/svtests/svtests_matrix.py`: the test header is parsed as sv-tests'
own runner parses it; Surelog runs with sv-tests' Surelog recipe minus
`-noelab` (an unelaborated database is never comparable), its golden served
from the shared cache after the first build; slang-uhdm runs on the same
sources with the same include paths, defines and top; both tools read
Surelog's bundled UVM (`third_party/Surelog/third_party/UVM/1800.2-2017-1.0`)
for the `uvm` tag; then `uhdm-cmp` and `uhdm-strictcmp` judge the pair. The
checkout is not a submodule: it lives next to this repository
(`../sv-tests`, or `SVTESTS_ROOT=`), is read-only to the campaign, and when it
is absent the stage is skipped.

The statuses: `EQUAL` (both accept, uhdm-cmp equal and strict-equal),
`STRICT_NOTEQUAL` (both accept, uhdm-cmp equal, the strict verdict in `strict`),
`DIFFERENT` (both accept, uhdm-cmp not equal), `SLANG_ONLY`, `SURELOG_ONLY`,
`BOTH_REJECT`, `SLANG_CRASH`, `SURELOG_CRASH`, `TIMEOUT`. The two goals of the
campaign (user 2026-10-15) order them: what slang accepts, slang-uhdm must
accept (a row leaving an accepting status for `SURELOG_ONLY`, `BOTH_REJECT` or
`SLANG_CRASH` is a REGRESSION); both-accepted pairs converge (`EQUAL` >
`STRICT_NOTEQUAL` > `DIFFERENT`, a step down a REGRESSION, a step up a
CONVERSION). Any other move is a CHANGE and is printed. The baseline at the
convergence stop (2026-11-04) reads EQUAL 1937, DIFFERENT 3, SURELOG_ONLY 75,
BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1: every
both-accepted row is EQUAL except the three known exceptions
`generated/hdlconv_std2017/hdlconvertor_std2017_p733.sv`, `..._p737.sv` and
`generated/tnoc/tnoc.sv`, Surelog artefacts the exporter does not copy (user
decision 2026-11-02). A landing promotes a conversion with
`check_svtests.py --write` or by copying the sweep's `svtests.csv` over the
baseline after a gate that read only the intended conversions.

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
A probe case's key also holds its text (every file of the case dir but
`LAW`): the corpora are pinned submodules, but a case can be edited in place,
and it must not be judged against the golden of its old text.
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

A landing promotes a row by re-baselining it: a `STRICT_NOTEQUAL` row that
the landing's sweep reads `CMP_EQUAL` is a CONVERSION, and the landing commits
the row as `CMP_EQUAL` (empty detail, strict `equal`) in the same commit,
likewise a probe case in `results/golden_probe.csv`. `check_probe.py --out`
writes that file's exact shape and order, so on a clean run the sweep's
`<workdir>/probe.csv` is byte-identical to the baseline, and re-baselining the
probe is `cp <workdir>/probe.csv results/golden_probe.csv` after a gate that
read only the intended conversions and changes. A `STRICT_NOTEQUAL` row
whose strict verdict changed (a CHANGE) is re-baselined with its new verdict
when the landing explains it. The baselines are written with LF line endings
(the scoreboards were CRLF before 2026-09-24, which broke the canary scripts'
last-column reads).
