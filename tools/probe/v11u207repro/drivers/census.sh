#!/bin/bash
# v11u207: the firing census (the mover PREDICTION, run and frozen before the law sweep), the r11u207 method: the
# law binary ($SLANG_UHDM) runs every corpus row-mode but the four fenced tests (--filter built from the FENCED= line
# of the MAIN repository's tools/probe/r11u107repro/canaudit.sh; fail closed), every probe case and every downstream
# lane with R11U207_TRACE=<dir> (every r11u207 law and the v11u207 refinement write one line per firing).  The harness
# scripts are this worktree's (= 3668bf30's).   usage: census.sh <workdir> <trace dir> <out prefix>
set -eu; W=$1; TR=$2; O=$3; HERE=$(cd "$(dirname "$0")" && pwd)
MAIN="$(cd "$(git -C "$HERE" rev-parse --path-format=absolute --git-common-dir)/.." && pwd)"
WT="$(git -C "$HERE" rev-parse --show-toplevel)"
FENCED="$(grep -m1 '^FENCED=' "$MAIN/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "census: fence unreadable" >&2; exit 3; }
[ -x "${SLANG_UHDM:-}" ] || { echo "census: SLANG_UHDM unset" >&2; exit 3; }
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
mkdir -p "$TR" "$W"; export R11U207_TRACE="$TR"
cd "$WT"
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
python3 scripts/check_probe.py --jobs 3 --out $O.probe.csv --workdir $W/probe > $O.probe.log 2>&1 || true
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
python3 scripts/downstream_uhdm2rtlil.py --jobs 3 --filter "$NEG" --workdir $W/downstream --out $O.ds.csv > $O.ds.log 2>&1 || true
echo CENSUS_DONE
