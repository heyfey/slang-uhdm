#!/usr/bin/env bash
set -u
BIN=${1:?}; CORPUS=${2:?}; TAG=${3:?}; REPO=${4:-/tmp/wt_v87}
OUT=/tmp/v87_${TAG}_${CORPUS}.csv
WD=/tmp/v87_wd_${TAG}_${CORPUS}
echo "GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}]"
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
export SLANG_UHDM="$BIN"
rm -rf "$WD"; mkdir -p "$WD"
python3 "$REPO/scripts/verify_golden.py" --corpus "$CORPUS" --mode both --jobs 2 --out "$OUT" --workdir "$WD" 2>&1 | tail -30
echo "-- cmds.txt binary check:"
grep -rhoE "[^ ]*slang-uhdm[^ ]*" "$WD" --include=cmds.txt | sort | uniq -c | head
echo "-- rows: $(($(wc -l < "$OUT") - 1))  OUT=$OUT WD=$WD"
