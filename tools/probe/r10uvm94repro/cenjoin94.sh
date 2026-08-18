#!/usr/bin/env bash
# r10uvm94 — join every (golden, ours) census pair in an outdir and total the
# classes.  Prints one line per row-mode that is NOT all-SAME, then the total.
#   usage: cenjoin94.sh <cendir>
set -u
D=${1:?census dir}
T=$(mktemp /tmp/r10uvm94_join.XXXX)
for g in "$D"/*.g; do
  b=${g%.g}; o=$b.o
  [ -f "$o" ] || continue
  echo "$(basename "$b")  $(python3 "$(dirname "$0")/join94.py" "$g" "$o")"
done > "$T"
grep -v 'FIX=0  BREAK=0  STILL=0  UNMATCHED=0' "$T" || true
awk '{for(i=2;i<=NF;i++){split($i,a,"="); t[a[1]]+=a[2]}}
     END{printf "TOTAL over %d row-modes: SAME=%d FIX=%d BREAK=%d STILL=%d UNMATCHED=%d\n",
         NR,t["SAME"],t["FIX"],t["BREAK"],t["STILL"],t["UNMATCHED"]}' "$T"
rm -f "$T"
