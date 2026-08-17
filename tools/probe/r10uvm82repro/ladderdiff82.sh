#!/usr/bin/env bash
# r10uvm82/ladderdiff82.sh — the BEFORE/AFTER ladder table this pass reports.
#
#   usage: ladderdiff82.sh <lad_BEFORE_dir> <lad_AFTER_dir>
#
# Prints, per row: total rungs, the rungs of THIS pass's family
# (`parameter|VpiImported|O-EMPTY`), and the AFTER row's new top families with
# the rung index of each (the "R0" the brief asks for).
#
# GUARD: a row present in one directory and not the other is reported MISSING and
# counted; a ladder with no RUNG line is NO_RUNGS and counted.  A run that lined
# nothing up must never read as "the family cleared".
set -u
B=${1:?before dir}; A=${2:?after dir}
[ -d "$B" ] && [ -d "$A" ] || { echo "FATAL: need two directories"; exit 3; }
FAM='parameter|VpiImported|O-EMPTY'
miss=0; rows=0
printf "%-28s %8s %8s   %8s %8s   %s\n" ROW B_RUNGS B_FAM A_RUNGS A_FAM VERDICT
for f in "$B"/ladder_*.txt; do
  n=$(basename "$f"); g="$A/$n"
  if [ ! -f "$g" ]; then printf "%-28s %8s %8s   %8s %8s   %s\n" "${n%.txt}" - - - - MISSING-AFTER; miss=$((miss+1)); continue; fi
  br=$(grep -c '^RUNG' "$f" || true); ar=$(grep -c '^RUNG' "$g" || true)
  if [ "$br" -eq 0 ] || [ "$ar" -eq 0 ]; then printf "%-28s %8s %8s   %8s %8s   %s\n" "${n%.txt}" "$br" - "$ar" - NO_RUNGS; miss=$((miss+1)); continue; fi
  bf=$(grep -Fc "FAM=$FAM" "$f" || true); af=$(grep -Fc "FAM=$FAM" "$g" || true)
  v=OK; [ "$af" -eq 0 ] && [ "$bf" -gt 0 ] && v=FAMILY-CLEARED
  [ "$bf" -eq 0 ] && [ "$af" -eq 0 ] && v=NEGATIVE-CONTROL
  [ "$af" -gt 0 ] && v="FAMILY-STILL-FIRING($af)"
  printf "%-28s %8s %8s   %8s %8s   %s\n" "${n%.txt}" "$br" "$bf" "$ar" "$af" "$v"
  rows=$((rows+1))
done
echo "-- rows=$rows problems=$miss"
echo
for f in "$A"/ladder_*.txt; do
  echo "== AFTER $(basename "${f%.txt}")  top families (first rung in brackets)"
  grep '^RUNG' "$f" |
    sed -E 's/^RUNG\t([0-9]+)\t.*\tFAM=([^\t]*).*/\2\t\1/' |
    awk -F'\t' '{c[$1]++; if(!($1 in f)) f[$1]=$2} END{for(k in c) printf "%6d  [R%s]  %s\n", c[k], f[k], k}' |
    sort -rn | head -6
done
[ "$rows" -gt 0 ]
