#!/usr/bin/env bash
# r10uvm92 — for every arm the BOUNDARY GATE reported as MOVED, run SURELOG on
# the same source and decide the ONLY question that matters: did the cell move
# TOWARD golden or AWAY from it?  MEASUREMENT-ONLY; LHS is ALWAYS golden.
#   usage: bmove92.sh <bound workdir> [<bound report>]
# Prints, per moved arm, the three-way hier_path table (three92.sh's) and a
# per-arm FIXED / BROKE count.  A single BROKE is a pristine-right ->
# patched-wrong cell and must be read, not summarised.
set -u
WD=${1:-/tmp/r10uvm92_bound}
REP=${2:-/tmp/r10uvm92_BOUND.txt}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
tf=0; tb=0; n=0
for b in $(grep '^MOVED ' "$REP" | awk '{print $2}'); do
  d=$WD/$b
  [ -d "$d" ] || { echo "MISSING $b"; continue; }
  src=$(ls "$d"/*.sv 2>/dev/null | head -1)
  [ -n "$src" ] || { echo "NOSRC $b"; continue; }
  ( cd "$d" && "$SURELOG" -parse -nocache "$(basename "$src")" >surelog.log 2>&1 </dev/null )
  [ -f "$d/slpp_all/surelog.uhdm" ] || { echo "SURELOG_NOOUT $b"; continue; }
  n=$((n+1))
  echo "===== $b"
  out=$(CEN=${CEN:-/tmp/r10uvm92_ct92cen} \
        "$(dirname "$0")/three92.sh" "$d" 2>&1)
  echo "$out" | grep -E 'FIXED|BROKE|STILL|^--'
  f=$(echo "$out" | sed -n 's/.*FIXED=\([0-9]*\).*/\1/p'); tf=$((tf + ${f:-0}))
  x=$(echo "$out" | sed -n 's/.*BROKE=\([0-9]*\).*/\1/p'); tb=$((tb + ${x:-0}))
done
echo "---- moved arms measured=$n  TOTAL FIXED=$tf  TOTAL BROKE=$tb"
