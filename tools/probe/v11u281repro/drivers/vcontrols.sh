#!/bin/bash
# v11u281 vcontrols.sh <out> <repro dir name>...: every case dir (dut.sv / dut.v) under the named tools/probe repro
# dirs in both views on pristine, law and the verifier's fix (case.sh lines, exit codes included), three in parallel.
# The path list is built first and filtered by $FENCED (word boundary) before any case is opened.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
P=$(cd "$D/../.." && pwd); out=$1; shift; : > $out
for d in "$@"; do find $P/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$FENCE_RE" |
  while read c; do for el in 0 1; do for t in pristine law fix; do echo "$el $c $t $B/$t"; done; done; done |
  xargs -P 3 -L 1 bash -c 'EL=$0 '"$D"'/case.sh $1 $2 $3' >> $out
