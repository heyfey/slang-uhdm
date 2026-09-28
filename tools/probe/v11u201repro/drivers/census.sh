#!/bin/bash
# v11u201: the firing census of the refined binary (the mover PREDICTION, run before the law sweep): every corpus
# row-mode except the four fenced tests (--filter built from $FENCED; fail closed), every probe case and every
# downstream lane, with R11U201_TRACE (the r11u201 laws and the v11u201 refinements) and R11U200_TRACE.
# usage: census.sh <workdir> <trace dir> <out prefix>   env: SLANG_UHDM (the binary under census)
set -u; W=$1; TR=$2; O=$3
. "$(cd "$(dirname "$0")" && pwd)/env.sh" || exit 3
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR" "$W"; export R11U201_TRACE="$TR" R11U200_TRACE="$TR"
cd "$REPO"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1
python3 scripts/check_probe.py --jobs 3 --out $O.probe.csv --workdir $W/probe > $O.probe.log 2>&1
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1
python3 scripts/downstream_uhdm2rtlil.py --jobs 3 --filter "$NEG" --workdir $W/downstream --out $O.ds.csv > $O.ds.log 2>&1
echo CENSUS_DONE
