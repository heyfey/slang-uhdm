#!/bin/bash
# head.sh <casedir> <tag>: uhdm-cmp head lines of the case's golden vs ours (run1.sh output <tag>)
c=$(cd $1 && pwd); D=$(dirname $0); g=$($D/goldpath.sh $c)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
[ -x "$UHDM_CMP" ] || { echo "no UHDM_CMP"; exit 2; }
$UHDM_CMP $g /tmp/r11u452_scr/out/$key/$2/ours.uhdm 2>&1 | head -${N:-30}
