#!/bin/bash
# r10uvm82/famtally.sh — MEASUREMENT-ONLY: the per-row family profile of a
# ctladder ladder file, and the rung index of the FIRST rung of each family
# (the "R0" of the row after a fix).
#
#   usage: famtally.sh <ladder.txt> [topN]
#
# GUARD: a file with no RUNG line prints NO_RUNGS and exits 6 — an empty ladder
# must never read as "no defects".
set -u
F=${1:?ladder.txt}
N=${2:-8}
[ -f "$F" ] || { echo "FATAL: no $F"; exit 3; }
r=$(grep -c '^RUNG' "$F" || true)
[ "$r" -gt 0 ] || { echo "NO_RUNGS in $F"; exit 6; }
echo "== $F   rungs=$r"
grep -m1 '^\[S\]' "$F" || echo "(no [S] summary line — row did not finish)"
echo "-- top $N families by rungs (first rung index in brackets)"
grep '^RUNG' "$F" |
  sed -E 's/^RUNG\t([0-9]+)\t.*\tFAM=([^\t]*).*/\2\t\1/' |
  awk -F'\t' '{c[$1]++; if(!($1 in f)) f[$1]=$2} END{for(k in c) printf "%6d  [R%s]  %s\n", c[k], f[k], k}' |
  sort -rn | head -"$N"
echo "-- rung 1 (the official uhdm-cmp head)"
grep -m1 -A3 '^RUNG	1	' "$F" | head -4
