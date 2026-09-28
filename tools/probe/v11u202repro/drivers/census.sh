#!/bin/bash
# v11u202: the firing census (mover PREDICTION for the v11u202 refinements, run BEFORE the v2 gate sweep).
# The binary under test runs every corpus row-mode except the four fenced tests (--filter from $FENCED, fail closed) and every
# probe case with R11U200_TRACE / R11U202_TRACE; each process writes `OUT <db path>` then one law name per firing.
# usage: census.sh <workdir> <trace dir> <out prefix>   env: SLANG_UHDM
set -eu; source "$(dirname "$0")/env.sh"; W=$1; TR=$2; O=$3
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR" "$W"; export R11U200_TRACE="$TR" R11U202_TRACE="$TR"
cd "$V202_REPO"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs 3 --out $O.probe.csv --workdir $W/probe > $O.probe.log 2>&1 || true
echo CENSUS_DONE
