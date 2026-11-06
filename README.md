# slang-uhdm

A SystemVerilog to [UHDM](https://github.com/chipsalliance/UHDM) exporter built on [slang](https://github.com/MikePopoloski/slang).
It writes the same `.uhdm` database that [Surelog](https://github.com/chipsalliance/Surelog)
writes for the same sources, so any downstream UHDM consumer
([uhdm2rtlil](https://github.com/alainmarcel/uhdm2rtlil),
[sv-pathfinder](https://github.com/alainmarcel/sv-pathfinder)) can use slang
in place of `surelog -parse`.

    slang-uhdm -f design.f -o design.uhdm     # the full slang command line, plus -o

## Every result is verified

The claim: for every test slang and Surelog both compile, the two generated
databases are equal. "Equal" is measured, never asserted.

- **Surelog is the golden.** The pinned Surelog writes the reference
  database. Surelog, UHDM and slang are never patched.
- **Two comparators must agree.** `uhdm-cmp` (UHDM's own structural compare)
  and `uhdm-strictcmp` (ours), which also compares full names, file names,
  spans, decompiled text, sizes, values and child order. A pair is EQUAL only
  when both say so.
- **A gated baseline.** `tests/sweep.sh` runs five stages and fails on any row
  that leaves equality against the committed csvs in `results/`. Every commit
  of the campaign passed the full gate first.
- **Downstream proof.** uhdm2rtlil's Yosys plugin synthesizes Surelog's and
  slang-uhdm's database through the same flow; the netlists must be
  byte-identical or proven equivalent.

Details: [GOLDEN_EQUIVALENCE.md](GOLDEN_EQUIVALENCE.md), [tests/README.md](tests/README.md).

## Test status

| Suite | Total | Both compile | Equal | Rate |
|---|---|---|---|---|
| Surelog suite | 798 | 484 | 480 | 99.2% |
| uhdm2rtlil | 871 | 804 | 803 | 99.9% |
| sv-tests | 2346 | 1940 | 1937 | 99.8% |
| uhdm2rtlil downstream synthesis | 871 | 805 | 805 | 100% |
| probe cases, `uhdm-cmp` | 31979 | 31979 | 31979 | 100% |
| probe cases, strict | 31979 | 31979 | 29946 | 93.6% |

Not claimed:

- **Sources slang rejects.** slang-uhdm compiles what slang compiles. Tests
  Surelog accepts and slang diagnoses are out of scope (see tests/README.md
  for the counts).
- **Four fenced tests** where slang and Surelog evaluate a constant
  differently before the exporter runs ([tests/FENCED.md](tests/FENCED.md)).
- **Surelog's non-database output:** caching, logging, preprocessor dumps.

## Quick start

    git submodule update --init --recursive
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j 4
    build/slang-uhdm -f design.f -o design.uhdm

Database options beyond slang's: `--elabuhdm` (Surelog's `-elabuhdm`),
`--nobuiltin`, `--sverilog`, `--single-unit`.

To reproduce the verification: `make -C third_party/Surelog release`, then
`tests/sweep.sh`. The first run builds every golden and takes hours; later
runs take about an hour.

## Dependencies

Each slang-uhdm release is developed and verified against one set of tool
versions, pinned as submodules under `third_party/`. A `.uhdm` file interops
only with the UHDM version that wrote it (`slang-uhdm --version` prints it).

| slang-uhdm | [slang](https://github.com/MikePopoloski/slang) | [UHDM](https://github.com/chipsalliance/UHDM) | [Surelog](https://github.com/chipsalliance/Surelog) | [uhdm2rtlil](https://github.com/alainmarcel/uhdm2rtlil) |
|---|---|---|---|---|
| branch `slang-v12.0-surelog-v1.87-uhdm-v1.87-uhdm2rtlil-v0.68` (unreleased) | v12.0 | v1.87 | v1.87 | v0.68 |

slang is the compiler front end, UHDM the database library, Surelog the golden
producer and a test suite, uhdm2rtlil a test suite and the downstream consumer.
The default build compiles slang and UHDM in-tree from the submodules;
`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON` links packages installed at a prefix instead.

## Documentation

| Document | Content |
|---|---|
| [GOLDEN_EQUIVALENCE.md](GOLDEN_EQUIVALENCE.md) | the target, the two modes, the flag policy |
| [tests/README.md](tests/README.md) | the gate: stages, statuses, baselines, golden cache |
| [tests/LAWS.md](tests/LAWS.md) | every law, its pass, commits, switches and cases |
| [tests/FENCED.md](tests/FENCED.md) | the four fenced tests |
| [AGENTS.md](AGENTS.md), [.agents/skills/](.agents/skills/) | how agents work here: the rules, and the skills to claim EQUAL, fix one test, converge a group |

## License

MIT.
