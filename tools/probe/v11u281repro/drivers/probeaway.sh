#!/bin/bash
# v11u281 probeaway.sh <list of probe database names> <dirA> <dirB>: order-blind and chain-keyed away census of each
# probe database (dirA = before, dirB = after) against its cached golden (scripts/check_probe.cache_dir); fail-closed.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2; export SCMP=$STRICT_CMP SCX=$B/strictcmp_x; [ -x "$SCX" ] || exit 2
while read -r n; do
  echo "$n" | grep -qwE "$FENCE_RE" && { echo "$n FENCED-refused"; continue; }
  rel=$(echo ${n%.uhdm} | sed 's#__#/#g')
  g=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import check_probe as cp, os; print(os.path.join(cp.cache_dir('$rel'),'golden.uhdm'))")
  t=$(mktemp -d /tmp/v11u281_aw.XXXX)
  a=$(python3 $D/away.py $g $2/$n $3/$n $t 2>&1 | tail -1); c=$(python3 $D/awaychain.py $g $2/$n $3/$n 2>&1 | head -1)
  echo "$rel | $a | $c"; rm -rf $t
done < "$1"
