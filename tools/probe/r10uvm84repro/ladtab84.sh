#!/usr/bin/env bash
# r10uvm84 — build the LADDERS artifact from two rowladders.sh output dirs.
# MEASUREMENT-ONLY: ctladder is not an acceptance judge; uhdm-cmp is.
#
#   usage: ladtab84.sh <before-dir> <after-dir> <before-log> <after-log> <calib-log>
#
# Prints, per row: BEFORE/AFTER rung totals and the R1 (head) FAMILY on each side —
# R1 is the rung the OFFICIAL uhdm-cmp head corresponds to — plus the per-row count
# of THIS PASS's family and of the family that becomes the new head.
set -u
B=${1:?before dir}; A=${2:?after dir}; BL=${3:?before log}; AL=${4:?after log}; CL=${5:?calib log}
echo "== calib (golden-vs-golden must give ZERO rungs)"; cat "$CL"
echo; echo "== BEFORE"; cat "$BL"
echo; echo "== AFTER";  cat "$AL"
echo
printf "\n%-30s %8s %8s %7s   %s\n" ROW B_RUNGS A_RUNGS DELTA VERDICT
for f in "$B"/ladder_*.txt; do
  n=$(basename "$f" .txt); g="$A/$n.txt"
  [ -f "$g" ] || { printf "%-30s %8s %8s %7s   %s\n" "$n" "$(grep -c '^RUNG' "$f")" - - MISSING-AFTER; continue; }
  b=$(grep -c '^RUNG' "$f"); a=$(grep -c '^RUNG' "$g")
  v=SAME; [ "$a" -lt "$b" ] && v=FEWER; [ "$a" -gt "$b" ] && v=MORE
  printf "%-30s %8s %8s %7s   %s\n" "$n" "$b" "$a" "$((a-b))" "$v"
done
echo
echo "== R1 (the OFFICIAL head, which is ladder rung 1) BEFORE -> AFTER"
for f in "$B"/ladder_*.txt; do
  n=$(basename "$f" .txt); g="$A/$n.txt"
  echo "-- $n"
  sed -n '/^RUNG\t1\t/{s/.*\(KINDL=[^\t]*\).*\(FAM=[^\t]*\).*/   BEFORE R1 \1  \2/p;}' "$f" | head -1
  sed -n '/^RUNG\t1\t/{n;s/^   L  /   BEFORE L  /p;}' "$f" | head -1
  [ -f "$g" ] && sed -n '/^RUNG\t1\t/{s/.*\(KINDL=[^\t]*\).*\(FAM=[^\t]*\).*/   AFTER  R1 \1  \2/p;}' "$g" | head -1
  [ -f "$g" ] && sed -n '/^RUNG\t1\t/{n;s/^   L  /   AFTER  L  /p;}' "$g" | head -1
done
echo
echo "== the TWO families, per row (rungs, not objects: the ladder masks containers)"
printf "%-30s %14s %14s %14s %14s\n" ROW MINE_BEFORE MINE_AFTER R0_BEFORE R0_AFTER
for f in "$B"/ladder_*.txt; do
  n=$(basename "$f" .txt); g="$A/$n.txt"
  mb=$(grep -c 'FAM=constant|VpiType|KIND:constant>hier_path' "$f"; true)
  rb=$(grep -c 'FAM=method_func_call|VpiName|TEXT:this|' "$f"; true)
  ma=-; ra=-
  if [ -f "$g" ]; then
    ma=$(grep -c 'FAM=constant|VpiType|KIND:constant>hier_path' "$g"; true)
    ra=$(grep -c 'FAM=method_func_call|VpiName|TEXT:this|' "$g"; true)
  fi
  printf "%-30s %14s %14s %14s %14s\n" "$n" "$mb" "$ma" "$rb" "$ra"
done
