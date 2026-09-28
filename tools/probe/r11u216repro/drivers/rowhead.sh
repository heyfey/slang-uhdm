#!/bin/bash
# rowhead.sh <sweep workdir> <corpus> <mode> <row> [max] : the strict records of one row-mode (golden from the cache the
# sweep's cmds.txt names, ours the sweep's slang.uhdm).  Fence: refuses a fenced row name (drivers/env.sh, fail closed).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
wd=$1; co=$2; mo=$3; row=$4; mx=${5:-12}
echo "$row" | grep -qwE "$FENCE_RE" && { echo "rowhead: fenced row refused" >&2; exit 2; }
d=$(ls -d $wd/$co/$mo/$row-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "no dir"; exit 1; }
k=$(grep -o 'cache hit [^)]*' $d/cmds.txt | cut -d' ' -f3); g=$(find $k -name '*.uhdm' | head -1)
$STRICT_CMP --max $mx ${DUMPS:+--dump-a $DUMPS.a --dump-b $DUMPS.b} $g $d/slang.uhdm
