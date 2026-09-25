#!/bin/bash
# ctx.sh <golden.uhdm> <ours.uhdm> [max] [k]: differing strict records with ancestors
g=$1; o=$2; m=${3:-3}; k=${4:-0}
T=$(mktemp -d /tmp/r11u154_ctx.XXXX)
/tmp/r11u154_bin/strictcmp --max $m --dump-a $T/a --dump-b $T/b $g $o > $T/out 2>&1
tail -1 $T/out
for n in $(grep -o "^#[0-9]*" $T/out | tr -d '#'); do python3 $(dirname $0)/anc.py $T/a $T/b $n $k | cut -c1-${W:-400}; echo; done
rm -rf $T
