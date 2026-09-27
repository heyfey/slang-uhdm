#!/bin/bash
# head.sh <workdir> <corpus> <mode> <test> [max]: the strict records of one row-mode of a rows.sh / sweep workdir
# (golden from the cache entry its cmds.txt names). Refuses a fenced test.
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
W=$1; co=$2; mo=$3; te=$4; mx=${5:-20}
if echo "$te" | grep -qP "$FENCED_RE"; then echo "FENCE refuse"; exit 4; fi
d=$(ls -d $W/$co/$mo/$te-* 2>/dev/null | head -1); [ -z "$d" ] && d=$(ls -d $W/$co/$te-*/$mo 2>/dev/null | head -1)
g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p;s/.*golden cache store \(.*\))/\1/p' $d/cmds.txt | head -1)/golden.uhdm
$STRICT_CMP --max $mx --dump-a /tmp/r11u187_head.a --dump-b /tmp/r11u187_head.b $g $d/slang.uhdm
