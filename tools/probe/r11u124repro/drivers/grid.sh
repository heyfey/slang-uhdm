#!/usr/bin/env bash
# grid.sh <grid dir> <binary> <outdir> — run_case.sh over every case dir
# (containing dut.sv) under the grid, 3 at a time; prints one line per case.
set -u
g=$1; bin=$2; out=$3
d=$(dirname "$(realpath "$0")")
find "$g" -name dut.sv -printf '%h\n' | sort | xargs -P3 -I{} "$d/run_case.sh" {} "$bin" "$out" | sort
