#!/usr/bin/env bash
# r10uvm204repro/cen204.sh — THE CORPUS CENSUS over the UVM row-modes.
# MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.  LHS is ALWAYS
# golden, RHS is ALWAYS ours.
#
#   CEN=<ct204cen> cen204.sh <pristine workdir> <patched workdir> <outdir>
#
# For each named row it censuses GOLDEN (read out of the row's OWN cmds.txt, so
# the wrong golden can never be compared), the PRISTINE database and the PATCHED
# one, and scores the multiset join with score204.py.  The GOLDEN-vs-GOLDEN
# calibration runs FIRST (RESUME.md §9): golden scored against itself must read
# every mover column 0.
#
# A row whose golden, pristine or patched database is missing prints
# SKIP-NOFILE and is COUNTED — a census that reaches nothing must never read as
# perfection.
#
# Pass the SAME workdir twice to census a PRISTINE-ONLY sweep (the b column then
# repeats the a column and every mover column is 0 by construction — the
# baseline reading, not a result).
set -u
WP=${1:?pristine workdir}; WQ=${2:?patched workdir}; OUT=${3:?outdir}
CEN=${CEN:?set CEN to the built ct204cen}
HERE=$(cd "$(dirname "$0")" && pwd)
ROWSET=${ROWS:-"SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen"}
SCORE_ROWS=${SCORE_ROWS:-AG,AGALL}
mkdir -p "$OUT"
miss=0; done_=0
for n in $ROWSET; do
  for mode in default testflags; do
    for d in "$WP/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      P="$d/slang.uhdm"; Q="$WQ/$mode/$b/slang.uhdm"
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        echo "SKIP-NOFILE $n $mode (g=${G:-none} p=$([ -f "$P" ] && echo y || echo n) q=$([ -f "$Q" ] && echo y || echo n))"
        miss=$((miss+1)); continue
      fi
      "$CEN" "$G" g > "$OUT/$n.$mode.g.txt" 2>"$OUT/$n.$mode.g.err"; grc=$?
      "$CEN" "$P" a > "$OUT/$n.$mode.a.txt" 2>"$OUT/$n.$mode.a.err"; arc=$?
      "$CEN" "$Q" b > "$OUT/$n.$mode.b.txt" 2>"$OUT/$n.$mode.b.err"; brc=$?
      # the CALIBRATION FIRST (RESUME.md §9): golden against itself
      printf "%-12s %-9s GOLDEN-vs-GOLDEN " "$n" "$mode"
      python3 "$HERE/score204.py" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.g.txt" \
              "$OUT/$n.$mode.g.txt" --rows="$SCORE_ROWS"
      printf "%-12s %-9s rc=%s/%s/%s agrows=%s " "$n" "$mode" "$grc" "$arc" "$brc" \
             "$(grep -c '^AG|' "$OUT/$n.$mode.g.txt"; true)"
      python3 "$HERE/score204.py" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.a.txt" \
              "$OUT/$n.$mode.b.txt" --rows="$SCORE_ROWS"
      done_=$((done_+1))
    done
  done
done
echo "-- censused=$done_ SKIP-NOFILE=$miss"
