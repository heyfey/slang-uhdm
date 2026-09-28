#!/bin/bash
# v11u195 firing census: SLANG_UHDM=<bin> census.sh <workdir> <trace dir> <out prefix>; fenced tests excluded fail-closed
set -eu; W=$1; TR=$2; O=$3
. "$(dirname "$(realpath "$0")")"/env.sh || exit 3
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR" "$W"; export R11U191_TRACE="$TR" R11U195_TRACE="$TR"
cd "$REPO"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs 3 --out $O.probe.csv --workdir $W/probe > $O.probe.log 2>&1 || true
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
echo CENSUS_DONE > $O.done
