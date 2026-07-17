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

    # once: install slang and UHDM packages
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

    ./tests/check_goldens.sh                      # committed golden dumps
    ./scripts/converge.sh <dut.sv>                # one-test dump-diff + cmp
    ./scripts/run_corpus.sh <corpus> out.csv results/baseline.csv   # scoreboard + regression gate
    ./scripts/triage.sh out.csv                   # per-round priorities
