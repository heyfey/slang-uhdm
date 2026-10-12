#!/bin/bash
# v11u291 controls.sh <out> <repro dir>...: every case dir under the named tools/probe dirs in both views on
# pristine, law and fix ($B). The path list is built and filtered by $FENCED (word boundary) before any case is
# opened; case.sh refuses a fenced path again. Export B and S.
D=$(cd "$(dirname "$0")/../../r11u291repro/drivers" && pwd); . "$D/env.sh" || exit 2
H=$(cd "$D/../.." && pwd); out=$1; shift
for d in "$@"; do find $H/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$FENCE_RE" > $out.list
while read c; do for el in 0 1; do for t in pristine law fix; do echo "$el $c $t $B/$t"; done; done; done < $out.list |
  xargs -P 4 -L 1 bash -c 'EL=$0 '"$D"'/case.sh $1 $2 $3' > $out
