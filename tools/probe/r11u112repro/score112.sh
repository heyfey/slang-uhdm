#!/bin/bash
# score112.sh <grid-out-root> <tagA> <tagB>: per arm/form holding gold.uhdm, <tagA>.uhdm and
# <tagB>.uhdm, dump all three (uhdm-dump, path-normalised by cells112.py) and score per cell
# A->B against golden (TO / AWAY / MOVED-WRONG).  Prints only arms whose databases differ.
R=${1:?root}; A=${2:?tagA}; B=${3:?tagB}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
HERE=$(cd "$(dirname "$0")" && pwd)
for g in $(find "$R" -name gold.uhdm | sort); do
  d=$(dirname "$g"); [ -f "$d/$A.uhdm" ] && [ -f "$d/$B.uhdm" ] || continue
  cmp -s "$d/$A.uhdm" "$d/$B.uhdm" && continue
  for t in gold $A $B; do [ -s "$d/$t.dump" ] || timeout 300 $DUMP "$d/$t.uhdm" > "$d/$t.dump" 2>&1; done
  echo "${d#$R/} $(python3 "$HERE/cells112.py" "$d/gold.dump" "$d/$A.dump" "$d/$B.dump") cmpA=$(wc -l < "$d/$A.cmp" 2>/dev/null) cmpB=$(wc -l < "$d/$B.cmp" 2>/dev/null)"
done
