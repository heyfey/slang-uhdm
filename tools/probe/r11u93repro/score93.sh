#!/usr/bin/env bash
# r11u92 PER-ARM TOTALS: cells (cacell93.py) and net entries + holder ORDER
# (netcell93.py), for one tag.  usage: GRID=<dir> score92.sh <tag>
set -u
GRID=${GRID:?set GRID}
HERE=$(cd "$(dirname "$0")" && pwd)
T=${1:?tag}
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  g=$GRID/$a/gold.$T.dump; o=$GRID/$a/ours.$T.dump
  [ -f "$g" ] && [ -f "$o" ] || { echo "$a NO-DUMP"; continue; }
  c=$(python3 $HERE/cacell93.py  "$g" "$o" 2>/dev/null | tail -1)
  n=$(python3 $HERE/netcell93.py "$g" "$o" 2>/dev/null | tail -1)
  echo "$a | $c | $n"
done
