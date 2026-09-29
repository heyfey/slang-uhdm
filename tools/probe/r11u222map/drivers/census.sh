#!/bin/bash
# r11u222map (map 13's census.sh, re-based on the r11u218 law binary): the firing census (the mover PREDICTION, run
# before the gate sweep). The law binary runs every corpus row-mode except the four fenced tests (--filter built from
# the FENCED= line of r11u107repro/canaudit.sh; fail closed) and every probe case, with R11U218_TRACE=<dir>; each
# firing process writes `OUT <db path>` then one `<law> <detail>` line per firing.
# usage: census.sh <workdir> <trace dir> <out prefix>     env: SLANG_UHDM (the law binary), CJOBS (default 3)
set -eu; WD=$1; TR=$2; O=$3; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FENCED="$(grep -m1 '^FENCED=' "$HERE/../../r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "census: fence unreadable" >&2; exit 3; }
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR" "$WD"; export R11U218_TRACE="$TR"; J=${CJOBS:-3}
cd "$REPO"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs $J --filter "$NEG" --out $O.sl.csv --workdir $WD/surelog > $O.sl.log 2>&1 || true
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs $J --filter "$NEG" --out $O.u2r.csv --workdir $WD/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs $J --out $O.probe.csv --workdir $WD/probe > $O.probe.log 2>&1 || true
echo CENSUS_DONE
