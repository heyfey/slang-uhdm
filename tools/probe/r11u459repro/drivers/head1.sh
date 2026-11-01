#!/bin/bash
# head1.sh <case dir> <tag>: first difference summary: strict verdict line, lhsPath tail, first object line
D=$(dirname $0)
c=$(cd $1 && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
o=/tmp/r11u459_scr/out/$key/$2/ours.uhdm; g=$($D/goldpath.sh $c)
[ -f $o ] && [ -f $g ] || { echo "$key NOFILE"; exit; }
out=$(/tmp/r11u459_bin/strictcmp $g $o 2>&1)
v=$(echo "$out" | tail -1)
p=$(echo "$out" | grep -m1 '^lhsPath' | sed 's/lhsPath: //' | awk -F' > ' '{n=NF; s=$(n-2)" > "$(n-1)" > "$n; print s}')
f=$(echo "$out" | grep -m1 -A1 '^decompile:' | tail -1 | cut -c1-90)
h=$(echo "$out" | grep -m2 -E '^  [AB]:' | tr '\t' ' ' | tr '\n' '|' | cut -c1-200)
echo "$key | $v | $p | $f | $h"
