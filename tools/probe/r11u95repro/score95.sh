#!/usr/bin/env bash
# r11u95 PER-ARM SCORE, three instruments.  usage: GRID=<dir> score95.sh <tag>
#   cacell95.py  — the per-CELL arbiter (cont_assign cells; blind to this
#                  pass's vectors, run so the neighbours stay scored)
#   netcell95.py — per NET entry and per holder ORDER
#   subtree95.py — per PROCESS / TASK-FUNC / CLASS entry (this pass's own)
set -u
GRID=${GRID:?set GRID}
HERE=$(cd "$(dirname "$0")" && pwd)
T=${1:?tag}
tc=0; tg=0; to=0; td=0; so=0
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  g=$GRID/$a/gold.$T.dump; o=$GRID/$a/ours.$T.dump
  [ -f "$g" ] && [ -f "$o" ] || { echo "$a NO-DUMP"; continue; }
  c=$(python3 $HERE/cacell95.py  "$g" "$o" 2>/dev/null | tail -1)
  n=$(python3 $HERE/netcell95.py "$g" "$o" 2>/dev/null | tail -1)
  s=$(python3 $HERE/subtree95.py "$g" "$o" 2>/dev/null | tail -1)
  echo "$a | $c | $n | $s"
  set -- $s
  td=$((td+$(echo "$s" | sed 's/.*MATCH=\([0-9]*\).*/\1/')))
  tg=$((tg+$(echo "$s" | sed 's/.*GOLD-ONLY=\([0-9]*\).*/\1/')))
  to=$((to+$(echo "$s" | sed 's/.*OURS-ONLY=\([0-9]*\).*/\1/')))
  so=$((so+$(echo "$s" | sed 's/.*ORDER-DIFF=\([0-9]*\)$/\1/')))
  tc=$((tc+1))
done
echo "TOTAL arms=$tc SUBTREE MATCH=$td GOLD-ONLY=$tg OURS-ONLY=$to ORDER-DIFF=$so"
