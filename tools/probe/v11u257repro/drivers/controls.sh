#!/bin/bash
# v11u257 controls.sh <out> <repro dir>...: every case of the named tools/probe repro dirs in both views on
# pristine (cP), law (cL) and fix (cF), three in parallel. The path list is built first and filtered by $FENCED
# (word boundary) before any case is opened.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
P=$(cd "$D/../.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $P/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c cP $B/pristine"; echo "$el $c cL $B/law"; echo "$el $c cF $B/fix"; done; done |
  xargs -P 3 -L 1 bash -c 'EL=$0 '"$R257_D"'/case.sh $1 $2 $3' >> $out
