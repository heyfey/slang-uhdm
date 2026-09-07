#!/usr/bin/env bash
# r10uvm195repro/cen195.sh — THE CORPUS CENSUS over the nine UVM row-modes.
# MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.  LHS is ALWAYS
# golden, RHS is ALWAYS ours.
#
#   CEN=<ct195cen> cen195.sh <pristine workdir> <patched workdir> <outdir>
#
# For each named row it censuses GOLDEN (read out of the row's OWN cmds.txt, so
# the wrong golden cannot be compared), the PRISTINE database and the PATCHED
# one, and scores the multiset join with score195.py.  The GOLDEN-vs-GOLDEN
# calibration runs FIRST (RESUME §9): golden scored against itself must read
# every column 0 but AGREE.
set -u
WP=${1:?pristine workdir}; WQ=${2:?patched workdir}; OUT=${3:?outdir}
CEN=${CEN:?set CEN to the built ct195cen}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
ROWS="SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg"
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
      printf "%-12s %-9s rc=%s/%s/%s rows=%s " "$n" "$mode" "$grc" "$arc" "$brc" \
             "$(grep -c '^LIST|' "$OUT/$n.$mode.g.txt"; true)"
      python3 "$HERE/score195.py" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.a.txt" "$OUT/$n.$mode.b.txt"
    done
  done
done
