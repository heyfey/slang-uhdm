#!/bin/bash
# § ifaceDefNetTypespecIsTheModuleRule224 — GRID SCORER.
# For every arm compiled by grid224.sh into <outdir>, joins golden.dump against
# ours.dump on the DEFINITION/ELABORATION net rosters (holder kind, holder view,
# section, net name) and prints the CELLS WRONG.  It reads the dumps the grid
# driver produced; it does NOT build databases itself, so it can never score a
# binary it did not measure.
set -u
OUT=${1:?outdir}
H=$(cd "$(dirname "$0")" && pwd)
tot=0
for d in "$OUT"/*/; do
  n=$(basename "$d")
  if [ ! -f "$d/golden.dump" ] || [ ! -f "$d/ours.dump" ]; then
    echo "ARM $n  MISSING-DUMP (golden=$([ -f "$d/golden.dump" ] && echo y || echo n) ours=$([ -f "$d/ours.dump" ] && echo y || echo n))"
    tot=$((tot+1000)); continue
  fi
  o=$(python3 "$H/netcen224.py" --cmp "$d/golden.dump" "$d/ours.dump" "ARM $n ")
  echo "$o"
  c=$(echo "$o" | sed -n 's/.*cells_wrong=\([0-9]*\).*/\1/p' | head -1)
  tot=$((tot+${c:-0}))
done
echo "-- GRID CELLS WRONG TOTAL = $tot"
