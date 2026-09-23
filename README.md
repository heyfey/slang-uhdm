# slang-uhdm

SystemVerilog → UHDM exporter built on [slang](https://github.com/MikePopoloski/slang).
Produces `.uhdm` databases **structurally identical to Surelog's** folded
output, so slang can drive UHDM consumers (uhdm2rtlil, synlig, sv-pathfinder)
as a drop-in replacement for `surelog -parse`.

    slang-uhdm -f design.f -o design.uhdm     # accepts the full slang CLI

## Compatibility contract

A `.uhdm` file only interops with the exact UHDM commit that wrote it.
The pins are the submodules under `third_party/`:

| Component | Where | Pin | Role |
|---|---|---|---|
| Surelog | `third_party/Surelog` | v1.87 (`0445655e`) | reference producer and test suites |
| UHDM | `third_party/Surelog/third_party/UHDM` | as Surelog pins it (`c7562484`, 1.87) | linked library, schema, `uhdm-cmp` / `uhdm-dump` |
| slang | `third_party/slang` | `7d61e0ad1` (11.0.473) | frontend library |

`slang-uhdm --version` prints the slang and UHDM versions a binary was
built with, including the UHDM commit.

## Build

    git submodule update --init --recursive       # slang, Surelog, and Surelog's UHDM + capnproto
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j 4

That builds slang and UHDM in-tree from the submodules. To link installed
packages instead (`cmake --install` of slang and UHDM to a prefix):

    cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON -DCMAKE_PREFIX_PATH=$HOME/.local

The producer for the test sweep is built separately inside the Surelog
submodule; see tests/README.md.

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
