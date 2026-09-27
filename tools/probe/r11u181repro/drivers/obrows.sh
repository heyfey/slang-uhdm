#!/bin/bash
# obrows.sh <pristine wd> <law wd> <corpus/mode/test>...: order-blind record distance to golden (strictcmp_x records,
# depth dropped, ours-not-in-golden + golden-not-in-ours) of both sweeps' databases, per row-mode. Fail-closed on $FENCED.
set -u; : "${FENCED:?FENCED unset}"; P=$1; L=$2; shift 2; T=/tmp/r11u181_obr; mkdir -p $T
for r in "$@"; do
  for f in $FENCED; do echo "$r" | grep -qw "$f" && { echo "$r fenced: refused"; continue 2; }; done
  out="$r"
  for W in $P $L; do d=$(ls -d $W/$r-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
    /tmp/r11u181_bin/uhdm-strictcmp --max 0 --dump-a $T/a --dump-b $T/b $g $d/slang.uhdm > /dev/null 2>&1
    out="$out $(python3 -c "
import collections,sys
a=collections.Counter('\t'.join(l.split('\t')[1:14]) for l in open('$T/a',errors='replace'))
b=collections.Counter('\t'.join(l.split('\t')[1:14]) for l in open('$T/b',errors='replace'))
x=sum((b-a).values()); y=sum((a-b).values()); print('%d+%d=%d' % (x,y,x+y))")"
  done; echo "$out"
done
