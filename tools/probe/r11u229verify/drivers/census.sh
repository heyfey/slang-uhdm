#!/bin/bash
# r11u229: census.sh <workdir> <trace dir>: the firing census of fix.bin's refinement: the full gate sweep (tests/sweep.sh
# --jobs 3: probe, surelog, uhdm2rtlil, downstream; the gate dispatches every row as it mandates, nothing here reads a
# fenced row) with SLANG_UHDM=$FIX and R11V229_TRACE=<trace dir>: one trace file per slang-uhdm process that fired
# (`<pid>.229`, first line `OUT <-o path>`).  drivers/predict.py turns the traces into the frozen prediction.
source "$(dirname "$0")/env.sh" || exit 2
[ -x "$FIX" ] || { echo "census.sh: FIX not executable" >&2; exit 2; }
W=$1; T=$2; rm -rf "$T"; mkdir -p "$T"
bash "$(dirname "$0")/sweep.sh" "$W" "$FIX" R11V229_TRACE="$T"
