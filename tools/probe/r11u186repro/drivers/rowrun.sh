#!/bin/bash
# r11u186: one corpus row (both modes) through the harness with one binary and extra environment switches;
# prints the csv rows; the databases land in /tmp/r11u186_rows/<tag>/<row>/<corpus>/<mode>/ (uvmdist.sh reads that root).  usage: rowrun.sh <bin name> <corpus> <row> <tag> [VAR=1 ...]  (refuses the fenced names)
. /tmp/wt_r11u186/tools/probe/r11u186repro/drivers/env.sh || exit 3
B=$1; C=$2; R=$3; T=$4; shift 4
for f in $FENCED; do [ "$R" = "$f" ] && { echo "rowrun.sh: fenced row refused" >&2; exit 3; }; done
W=/tmp/r11u186_rows/$T/$R; rm -rf $W; mkdir -p $W
cd /tmp/wt_r11u186 && env "$@" SLANG_UHDM=/tmp/r11u186_bin/$B python3 scripts/verify_golden.py --corpus $C --mode both --jobs 2 --filter "^$R\$" --out $W/o.csv --workdir $W/$C > $W/log 2>&1
grep -v '^name,' $W/o.csv | sed "s/^/$T /"
