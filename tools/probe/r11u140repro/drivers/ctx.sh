#!/bin/bash
# ctx.sh <golden> <ours> [max] [k]: differing records with ancestors
g=$1; o=$2; m=${3:-3}; k=${4:-0}
T=$(mktemp -d /tmp/r11u140_ctx.XXXX)
/tmp/r11u140_bin/uhdm-strictcmp --max $m --dump-a $T/a --dump-b $T/b $g $o > $T/out
tail -1 $T/out
for n in $(grep -o "^#[0-9]*" $T/out | tr -d '#'); do python3 /tmp/r11u140_scratch/anc.py $T/a $T/b $n $k; echo; done
rm -rf $T
