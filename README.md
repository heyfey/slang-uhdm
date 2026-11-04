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
| UHDM | `third_party/Surelog/third_party/UHDM` | as Surelog pins it (`c756248`, v1.87) | linked library, schema, `uhdm-cmp` / `uhdm-dump` |
| slang | `third_party/slang` | `545f88b2e` (v12.0) | frontend library |

`slang-uhdm --version` prints the slang and UHDM versions a binary was
built with, including the UHDM commit. A build with
`-DSLANG_UHDM_USE_SYSTEM_DEPS=ON` links the UHDM installed at the prefix
instead of the submodule; the campaign's gate binaries were built that way
against UHDM `18837c1`, an earlier commit of the same v1.87 line (the
`bump-1.87` merge `c756248` changed no schema), and judge equal against
goldens written by the submodule's Surelog.

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

Converged on the strict gate (uhdm-cmp equal AND uhdm-strictcmp equal) and
stopped for the release cut on 2026-11-04 at `9889dcaad`: the sv-tests gate ALL CLEAN (EQUAL 1937 of 2346, STRICT_NOTEQUAL 0, DIFFERENT 3 = the known exceptions p733, p737, tnoc), surelog 954 of 954 comparable row-modes CMP_EQUAL (Tnoc d/t CMP_NOTEQUAL and the four fenced tests by decision), uhdm2rtlil 1606 of 1606 (stamped_gen_param d/t CMP_NOTEQUAL by decision), probe 29901 EQUAL + 2042 STRICT_NOTEQUAL of 31943, downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT of 871.
Every exporter rule is a law (`§ name`) decoded from Surelog's source; the
law index `tests/LAWS.md` maps each law to its pass, commits, source sites,
switches and probe cases. See SUPPORT_MATRIX.md for the pins and the measured
baseline, tests/README.md for the gate, RESUME.md for the operator manual of
the convergence campaign, GOLDEN_EQUIVALENCE.md for the target definition.
HANDOFF.md, PLAN.md and NOTES.md are historical logs of the first phases.

## Testing

The reference corpora (Surelog's suites, 798 tests; uhdm2rtlil's, 871 tests)
are submodules, the producer is built from `third_party/Surelog`, and Surelog's
golden databases are cached after the first run. The fifth stage runs the
chipsalliance sv-tests suite (2346 tests) from a checkout next to this
repository. See tests/README.md.

    tests/sweep.sh                                # the gate: 31943 probe cases, both corpora x both modes, downstream uhdm2rtlil, sv-tests
    ./scripts/converge.sh <dut.sv>                # one-test dump-diff + cmp
    ./scripts/triage.sh out.csv                   # per-round priorities
