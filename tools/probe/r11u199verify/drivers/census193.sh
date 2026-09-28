#!/bin/bash
# (r11u199: adapted from r11u192repro/drivers/census.sh) census193.sh <workdir> <trace dir> <out prefix>: the HEAD
# binary ($LAW) with R11U193_TRACE=<dir> and R11U192_TRACE=<dir> (the firing traces of passes 193 and 192: `OUT <db>` then `<law> <detail>` per firing) over
# every corpus row-mode except the four fenced tests (--filter built from $FENCED; fail closed), every tests/probe case
# and nothing else.  The trace of § caUnsizedRhsClonePerInst193 bounds where this pass's clone refinements can act
# (they run only inside that law's drain): the input of predict199.py, run BEFORE the fix sweep.
set -eu; W=$1; TR=$2; O=$3; HERE=$(cd "$(dirname "$0")" && pwd)
source $HERE/env.sh
NEG="^(?!.*\\b($(echo $FENCED | tr ' ' '|'))\\b)"
export SLANG_UHDM=$LAW
mkdir -p "$TR" "$W"; export R11U193_TRACE="$TR" R11U192_TRACE="$TR"
cd "$R199_ROOT"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs 3 --filter "$NEG" --workdir $W/probe --out $O.probe.csv > $O.probe.log 2>&1 || true
echo CENSUS_DONE >> $O.done
