#!/bin/bash
# r11u58 SHAPE LISTER driver — the three-way element-size table for a grid arm.
# usage: shape58.sh <armdir>   (needs gold.base/ours.base/ours.pat dumps)
set -u
D=${1:?arm}
H=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for v in uhdmallPackages uhdmtopPackages; do
  echo "== $(basename $D) $v"
  for t in "gold.base GOLD" "ours.base PRIS" "ours.pat PAT "; do
    set -- $t
    [ -f $D/$1.dump ] || continue
    printf '   %s ' "$2"
    python3 $H/sz58.py $D/$1.dump $v | tr '\n' '|'
    echo
  done
done
