#!/bin/bash
# r11u196: the firing census (the mover PREDICTION, run before the law gate sweep).  The law binary runs every corpus
# row-mode except the four fenced tests (--filter built from $FENCED by env.sh, fail closed) and every probe case, with
# R11U191_TRACE and R11U196_TRACE set; each process writes `OUT <db path>` then one line per firing.
# usage: census.sh <workdir> <trace dir>      env: R196_BIN; runs $R196_BIN/law.bin
set -u; . "$(dirname "$0")/env.sh" || exit 3
W=$1; TR=$2; rm -rf "$W" "$TR"; mkdir -p "$TR/191" "$TR/196" "$W"
export R11U191_TRACE="$TR/191" R11U196_TRACE="$TR/196" SLANG_UHDM=$R196_BIN/law.bin
cd "$R196_REPO"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEGFENCE" --out $W/sl.csv --workdir $W/surelog > $W/sl.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEGFENCE" --out $W/u2r.csv --workdir $W/uhdm2rtlil > $W/u2r.log 2>&1
python3 scripts/check_probe.py --jobs 3 --out $W/probe.csv --workdir $W/probe > $W/probe.log 2>&1
echo CENSUS_DONE >> $W/sl.log
