#!/bin/bash
# v11u207 (from r11u207repro): strict records of one corpus row-mode from a sweep workdir: rowhead.sh <sweep wd> <surelog|uhdm2rtlil> <mode> <test> [max]
# golden = the cache entry cmds.txt names; refuses the four fenced tests (FENCED= line of r11u107repro/canaudit.sh).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
W=$1 C=$2 M=$3 T=$4 N=${5:-20}
for f in $FENCED; do [ "$T" = "$f" ] && { echo "rowhead: fenced test refused" >&2; exit 3; }; done
d=$(ls -d $W/$C/$M/$T-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "no dir"; exit 1; }
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
[ -z "$gu" ] && gu=$(find $d -name 'surelog*.uhdm' -o -name '*.uhdm' ! -name slang.uhdm | head -1)
o=/tmp/v11u207_rows/$(basename $W)/$C/$M/$T; mkdir -p $o
$SCMP --max $N --dump-a $o/a.rec --dump-b $o/b.rec "$gu" $d/slang.uhdm > $o/strict.txt 2>&1
echo "$T/$M golden=$gu"; cat $o/strict.txt
