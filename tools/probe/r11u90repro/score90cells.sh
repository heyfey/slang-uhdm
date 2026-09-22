#!/usr/bin/env bash
# r11u88 PER-CELL TOTALS over the whole grid.  usage: GRID=<dir> score88cells.sh <tagA> <tagB>
set -u
GRID=${GRID:?set GRID}
HERE=$(cd "$(dirname "$0")" && pwd)
for t in "$1" "$2"; do
  m=0; d=0; g=0; o=0; u=0
  for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
    r=$(python3 $HERE/cacell90.py $GRID/$a/gold.$t.dump $GRID/$a/ours.$t.dump 2>/dev/null | tail -1)
    [ -z "$r" ] && continue
    m=$((m+$(echo "$r"|sed 's/.*MATCH=\([0-9]*\).*/\1/')))
    d=$((d+$(echo "$r"|sed 's/.*DIFF=\([0-9]*\).*/\1/')))
    g=$((g+$(echo "$r"|sed 's/.*GOLD-ONLY=\([0-9]*\).*/\1/')))
    o=$((o+$(echo "$r"|sed 's/.*OURS-ONLY=\([0-9]*\).*/\1/')))
    u=$((u+$(echo "$r"|sed 's/.*UNSCORED=\([0-9]*\).*/\1/')))
  done
  echo "$t MATCH=$m DIFF=$d GOLD-ONLY=$g OURS-ONLY=$o UNSCORED=$u"
done
