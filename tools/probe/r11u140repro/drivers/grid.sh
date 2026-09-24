#!/bin/bash
# grid.sh <law binary> <case dir>... : each case on pristine and law: rc, cmp lines, strict verdict
source /tmp/r11u140_scratch/env.sh
D=$(dirname $(realpath $0))
L=$1; shift
for c in "$@"; do
  c=${c%/}
  p=$($D/run_case.sh $c /tmp/r11u140_bin/pristine /tmp/r11u140_x/out_p | cut -d' ' -f2-)
  l=$($D/run_case.sh $c $L /tmp/r11u140_x/out_l | cut -d' ' -f2-)
  n=$(echo $c | sed 's#.*/r11u140repro/##; s#.*/tools/probe/##; s#.*/tests/probe/##')
  s=SAME; [ "$p" != "$l" ] && s=MOVED
  echo "$n | P: $p | L: $l | $s"
done
