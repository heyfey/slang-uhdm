#!/bin/bash
# r11u206: the strict head of one row-mode of a sweep workdir (the sweep's own golden and database, no rerun).
# usage: rowhead.sh <sweep workdir> <corpus> <mode> <test> [max]   (fence fail-closed: refuses the four FENCED names)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
W=$1 C=$2 M=$3 T=$4 N=${5:-20}
for f in $FENCED; do [ "$T" = "$f" ] && { echo "rowhead: fenced test refused" >&2; exit 3; }; done
D=$(ls -d $W/$C/$M/$T-* 2>/dev/null | head -1); [ -n "$D" ] || { echo "rowhead: no sweep dir"; exit 1; }
g=$(grep -o 'golden cache [a-z]* [^)]*' $D/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
[ -n "$gu" ] || gu=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
$SCMP --max $N ${DUMPS:+--dump-a $DUMPS.a --dump-b $DUMPS.b} $gu $D/slang.uhdm
