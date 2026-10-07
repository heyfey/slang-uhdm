#!/bin/bash
# v11u281 vaway.sh <grid summary> [tagA tagB] (default P L): order-blind (away.py) and chain-keyed (awaychain.py) census on every MOVE line,
# pristine P.uhdm vs law L.uhdm under $S/g/<case-view>; fail-closed on $FENCED through env.sh and the helpers.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2; export SCMP=$STRICT_CMP SCX=$B/strictcmp_x; [ -x "$SCX" ] || exit 2
TA=${2:-P}; TB=${3:-L}
grep "^MOVE" "$1" | awk '{print $2}' | while read cv; do
  w=$S/g/$cv; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1); [ -s "$g" ] || { echo "$cv NOGOLD"; continue; }
  t=$(mktemp -d /tmp/v11u281_aw.XXXX)
  a=$(python3 $D/away.py $g $w/$TA.uhdm $w/$TB.uhdm $t 2>&1 | tail -1); c=$(python3 $D/awaychain.py $g $w/$TA.uhdm $w/$TB.uhdm 2>&1 | head -1)
  echo "$cv | $a | $c"; rm -rf $t
done
