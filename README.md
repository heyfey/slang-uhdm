# slang-uhdm

SystemVerilog → UHDM exporter built on [slang](https://github.com/MikePopoloski/slang).
Produces `.uhdm` databases **structurally identical to Surelog's** folded
output, so slang can drive UHDM consumers (uhdm2rtlil, synlig, sv-pathfinder)
as a drop-in replacement for `surelog -parse`.

    slang-uhdm -f design.f -o design.uhdm     # accepts the full slang CLI

## Compatibility contract

A `.uhdm` file only interops with the exact UHDM commit that wrote it.
This tree is pinned to:

| Component | Commit | Role |
|---|---|---|
| UHDM | `5523dfc` (v1.86-31) | linked library + schema |
| Surelog | `cbdbea458c` (v1.86-114) | reference producer (convergence oracle) |
| slang | master 2026-07 (v11.0-dev) | frontend library |

## Build

    git submodule update --init                       # third_party/Surelog + third_party/uhdm2rtlil (the test corpora)
    # once: install slang and UHDM packages (UHDM = third_party/Surelog/third_party/UHDM, the same pin)
    cmake --install <slang>/build   --prefix ~/.local
    cmake --install <UHDM>/build    --prefix ~/.local   # UHDM configured with CMAKE_INSTALL_PREFIX=~/.local
    # then
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/.local
    cmake --build build -j 4

## Status

Converging against the 710-test uhdm2rtlil corpus by byte-level identity
(`uhdm-dump` diff + `uhdm-cmp`): currently 36 PASS + 33 CMP_ONLY, 0 crashes.
See HANDOFF.md for the campaign state, PLAN.md for strategy, NOTES.md for
the catalog of Surelog output quirks this tool replicates.

## Testing

The reference corpora (Surelog's suites, 798 tests; uhdm2rtlil's, 871 tests)
are submodules, the producer is built from `third_party/Surelog`, and Surelog's
golden databases are cached after the first run. See tests/README.md.

    tests/sweep.sh                                # both corpora x both modes vs results/golden_*.csv (the gate)
    ./scripts/converge.sh <dut.sv>                # one-test dump-diff + cmp
    ./scripts/triage.sh out.csv                   # per-round priorities
