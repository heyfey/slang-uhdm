#!/usr/bin/env bash
# r10uvm198repro/cen198.sh — THE CORPUS CENSUS over the UVM row-modes.
# MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.  LHS is ALWAYS
# golden, RHS is ALWAYS ours.
#
#   CEN=<ct198cen> cen198.sh <pristine workdir> <patched workdir> <outdir>
#
# For each named row it censuses GOLDEN (read out of the row's OWN cmds.txt, so
# the wrong golden can never be compared), the PRISTINE database and the PATCHED
# one, and scores the multiset join with score198.py.  The GOLDEN-vs-GOLDEN
# calibration runs FIRST (RESUME §9): golden scored against itself must read
# every mover column 0.
#
# Pass the SAME workdir twice to census a PRISTINE-ONLY sweep (the b column then
# repeats the a column and every mover column is 0 by construction — the
# baseline reading, not a result).
set -u
WP=${1:?pristine workdir}; WQ=${2:?patched workdir}; OUT=${3:?outdir}
CEN=${CEN:?set CEN to the built ct198cen}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
ROWS=${ROWS:-"SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg"}
for n in $ROWS; do
  for mode in default testflags; do
    for d in "$WP/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      P="$d/slang.uhdm"; Q="$WQ/$mode/$b/slang.uhdm"
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        echo "SKIP-NOFILE $n $mode (g=${G:-none})"; continue
      fi
      "$CEN" "$G" g > "$OUT/$n.$mode.g.txt"; grc=$?
      "$CEN" "$P" a > "$OUT/$n.$mode.a.txt"; arc=$?
      "$CEN" "$Q" b > "$OUT/$n.$mode.b.txt"; brc=$?
      printf "%-12s %-9s rc=%s/%s/%s cells=%s " "$n" "$mode" "$grc" "$arc" "$brc" \
             "$(grep -c '^CEN|' "$OUT/$n.$mode.g.txt"; true)"
      python3 "$HERE/score198.py" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.a.txt" \
              "$OUT/$n.$mode.b.txt"
      # the CALIBRATION: golden against itself, every mover column 0
      printf "%-12s %-9s GOLDEN-vs-GOLDEN " "$n" "$mode"
      python3 "$HERE/score198.py" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.g.txt" \
              "$OUT/$n.$mode.g.txt"
    done
  done
done
