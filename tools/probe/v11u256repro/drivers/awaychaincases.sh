#!/bin/bash
# (v11u256) awaychaincases.sh <A tag> <B tag> <case-view>...: the CHAIN-keyed away census (drivers/awaychain.py over
# drivers/awayrows.py's keys, the variant comparator $SCX) of case-views from the case.sh store
# ($S/g/<case>[_el]/{gold_*/golden.uhdm,<A>.uhdm,<B>.uhdm}). Needs drivers/env.sh sourced.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
A=$1; Bt=$2; shift 2
export SCX=${SCX:-$B/strictcmp_x}; [ -x "$SCX" ] || { echo "awaychaincases.sh: SCX not executable" >&2; exit 2; }
for cv in "$@"; do
  w=$S/g/$cv; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1)
  [ -s "$g" ] || { echo "$cv NO-GOLDEN"; continue; }
  echo "$cv $(python3 $D/awaychain.py $g $w/$A.uhdm $w/$Bt.uhdm 2>&1 | head -1)"
done
