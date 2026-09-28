#!/bin/bash
# r11u193: one corpus row (both modes) through the harness with one binary and extra environment switches;
# prints the csv rows; databases land in ${R193_ROWS:-/tmp/r11u193_rows}/<tag>/<row>/<corpus>/<mode>/.
# usage: rowrun.sh <bin name in $R193_BIN> <corpus> <row> <tag> [VAR=1 ...]  (refuses the fenced names)
. "$(dirname "$0")/env.sh" || exit 3
B=$1; C=$2; R=$3; T=$4; shift 4
for f in $FENCED; do [ "$R" = "$f" ] && { echo "rowrun.sh: fenced row refused" >&2; exit 3; }; done
W=${R193_ROWS:-/tmp/r11u193_rows}/$T/$R; rm -rf $W; mkdir -p $W
cd "$R193_REPO" && env "$@" SLANG_UHDM=$R193_BIN/$B python3 scripts/verify_golden.py --corpus $C --mode both --jobs 2 --filter "^$R\$" --out $W/o.csv --workdir $W/$C > $W/log 2>&1
grep -v '^name,' $W/o.csv | sed "s/^/$T /"
