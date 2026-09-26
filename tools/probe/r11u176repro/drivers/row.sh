#!/bin/bash
# row.sh <binary> <tag> <corpus> <mode> <exact test name> [max] : run one row-mode with verify_golden.py into
# /tmp/r11u176_rows/<tag>/<corpus>/..., then print the strict comparator's first records (golden A vs ours B)
set -u
. /tmp/wt_r11u176/tools/probe/r11u176repro/drivers/env.sh
BIN=$1 TAG=$2 CORP=$3 MODE=$4 NAME=$5 MAX=${6:-12}
for f in $FENCED; do [ "$NAME" = "$f" ] && { echo "fenced row refused"; exit 3; }; done
W=/tmp/r11u176_rows/$TAG/$CORP; mkdir -p $W
cd /tmp/wt_r11u176 && SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus $CORP --mode $MODE --jobs 1 \
  --out $W/$NAME.$MODE.csv --workdir $W/wd --filter "^${NAME}\$" > $W/$NAME.$MODE.log 2>&1
tail -1 $W/$NAME.$MODE.csv
D=$(dirname $(grep -l "$BIN" $(find $W/wd -path "*$NAME*" -name cmds.txt) | grep "/$MODE/\|$MODE" | head -1) 2>/dev/null)
[ -z "$D" ] && D=$(dirname $(find $W/wd -path "*/$NAME/*" -name cmds.txt | head -1))
echo "dir=$D"
G=$(grep -o 'golden cache hit [^)]*' $D/cmds.txt | awk '{print $4}'); G=$(ls $G/*.uhdm 2>/dev/null | head -1)
[ -z "$G" ] && G=$(find $D -name '*.uhdm' ! -name slang.uhdm | head -1)
echo "golden=$G"
$STRICT_CMP --max $MAX --dump-a $D/a.rec --dump-b $D/b.rec $G $D/slang.uhdm
