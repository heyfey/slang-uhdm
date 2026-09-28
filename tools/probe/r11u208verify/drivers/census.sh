#!/bin/bash
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# r11u204 (adapted from v11u198repro/drivers/census.sh): the firing census of the fix binary (the mover PREDICTION,
# run and frozen before the fix sweep).  $FIX runs every corpus row-mode except the four fenced tests (--filter built
# from $FENCED, drivers/env.sh, fail closed), every probe case and every downstream lane, with R11V204_TRACE=<dir>;
# each process writes `OUT <db path>` then `<law> <detail>` per firing.   usage: census.sh <workdir> <trace dir> <prefix>
source "$(dirname "$0")/env.sh" || exit 2
set -u; W=$1; TR=$2; O=$3
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR" "$W"; export R11V204_TRACE="$TR" SLANG_UHDM=$FIX
cd "$R208_ROOT"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs 3 --out $O.probe.csv --workdir $W/probe > $O.probe.log 2>&1 || true
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
python3 scripts/downstream_uhdm2rtlil.py --jobs 3 --filter "$NEG" --workdir $W/downstream --out $O.ds.csv > $O.ds.log 2>&1 || true
echo CENSUS_DONE
