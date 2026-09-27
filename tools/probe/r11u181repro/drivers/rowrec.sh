#!/bin/bash
# rowrec.sh <sweep workdir> <corpus> <mode> <test> [max]: the strict records of one row-mode (golden A vs ours B).
# Refuses a fenced name (word boundary, $FENCED from env.sh).
set -u; : "${FENCED:?FENCED unset}"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
W=$1; C=$2; M=$3; N=$4; MAX=${5:-12}
echo "$N" | grep -Eqw "($(echo $FENCED | sed 's/ /|/g'))" && { echo "FENCED: refused"; exit 4; }
d=$(ls -d $W/$C/$M/$N-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "no row dir"; exit 5; }
g=$(sed -n 's/^surelog: *(golden cache hit \(.*\))$/\1/p' $d/cmds.txt)/golden.uhdm
[ -f "$g" ] || g=$(ls $d/*.uhdm | grep -v slang.uhdm | head -1)
/tmp/r11u181_bin/uhdm-strictcmp --max $MAX $g $d/slang.uhdm 2>&1 | tail -$((MAX*3+3))
