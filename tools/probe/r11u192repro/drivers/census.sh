#!/bin/bash
# r11u192 (after r11u187): the firing census = the mover PREDICTION, run BEFORE the law gate sweep.  The law binary (SLANG_UHDM) runs
# every corpus row-mode except the four fenced tests (--filter built from the FENCED= line of
# r11u107repro/canaudit.sh; fail closed), every tests/probe case (also fence-filtered), and the downstream slang lane,
# with R11U183_TRACE=<dir> (the r11u183 laws' file trace: `OUT <db>` then one law per firing) and R11U187_TRACE=<dir>
# (this pass's laws, same format).  usage: census.sh <workdir> <trace dir> <out prefix>
set -eu; W=$1; TR=$2; O=$3; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
source $HERE/env.sh
NEG="^(?!.*\\b($(echo $FENCED | tr ' ' '|'))\\b)"
: "${SLANG_UHDM:?}"
mkdir -p "$TR" "$W"; export R11U183_TRACE="$TR" R11U187_TRACE="$TR" R11U192_TRACE="$TR"
cd "$REPO"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs 3 --filter "$NEG" --workdir $W/probe --out $O.probe.csv > $O.probe.log 2>&1 || true
echo CENSUS_DONE
