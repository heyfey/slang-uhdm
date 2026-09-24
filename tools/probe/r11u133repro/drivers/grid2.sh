#!/bin/bash
# grid2.sh <law binary> <case dir>... : each case on pristine and law: rc, cmp lines, strict verdict
source /tmp/r11u133_env.sh
L=$1; shift
for c in "$@"; do
  c=${c%/}
  p=$(/tmp/r11u133_x/drv/run_case.sh $c /tmp/r11u133_bin/pristine /tmp/r11u133_x/out_p | cut -d' ' -f2-)
  l=$(/tmp/r11u133_x/drv/run_case.sh $c $L /tmp/r11u133_x/out_l | cut -d' ' -f2-)
  n=$(echo $c | sed 's#.*/cases/##; s#.*/tools/probe/##; s#.*/tests/probe/##')
  s=SAME; [ "$p" != "$l" ] && s=MOVED
  echo "$n | P: $p | L: $l | $s"
done
