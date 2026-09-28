#!/bin/bash
# r11u204 (adapted from v11u198repro/drivers/census.sh): the firing census of the LANDED laws on law.bin (HEAD) with the r11u196, r11u191 and r11u198 traces, for the process check of
# the committed predictions of passes 196 and 198.  $LAW runs every corpus row-mode except the four fenced tests (--filter built
# from $FENCED, drivers/env.sh, fail closed), every probe case and every downstream lane, with R11U196_TRACE, R11U191_TRACE and R11U198_TRACE=<dir>;
# each process writes `OUT <db path>` then `<law> <detail>` per firing.   usage: census.sh <workdir> <trace dir> <prefix>
source "$(dirname "$0")/env.sh" || exit 2
set -u; W=$1; TR=$2; O=$3
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR" "$W"; export R11U196_TRACE="$TR" R11U191_TRACE="$TR" R11U198_TRACE="$TR" SLANG_UHDM=$LAW
cd "$R204_ROOT"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs 3 --out $O.probe.csv --workdir $W/probe > $O.probe.log 2>&1 || true
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
python3 scripts/downstream_uhdm2rtlil.py --jobs 3 --filter "$NEG" --workdir $W/downstream --out $O.ds.csv > $O.ds.log 2>&1 || true
echo CENSUS_DONE
