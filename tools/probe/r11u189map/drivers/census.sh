#!/bin/bash
# r11u189 (r11u183 census.sh reused at 2b97649e + the rebased patches): the firing census (the mover PREDICTION, run before the gate sweep).  The law binary runs every corpus
# row-mode except the four fenced tests (--filter built from the FENCED= line of r11u107repro/canaudit.sh; fail
# closed) with R11U183_TRACE=<dir>; each process writes `OUT <db path>` then one law name per firing.
# usage: census.sh <workdir> <trace dir> <out prefix>
set -eu; W=$1; TR=$2; O=$3; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FENCED="$(grep -m1 '^FENCED=' "$HERE/../../r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "census: fence unreadable" >&2; exit 3; }
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR"; export R11U183_TRACE="$TR"
cd "$REPO"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1
echo CENSUS_DONE
