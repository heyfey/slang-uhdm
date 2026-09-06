#!/usr/bin/env bash
# r10uvm180 — the nine-UVM-row-mode census driver.
#   cen180.sh <ct180cen> <cen180score.py> <pristine-wd/sl> <patched-wd/sl> <outdir>
# For every row-mode named below it finds the golden the harness used (read out
# of that run's own cmds.txt, never guessed), runs ct180cen golden-vs-pristine
# and golden-vs-patched, and scores the join.  MEASUREMENT ONLY.
set -u
CEN=${1:?ct180cen}; SCORE=${2:?cen180score.py}; PRE=${3:?}; PAT=${4:?}; OUT=${5:?}
mkdir -p "$OUT"
ROWS="SeqDriver MiniAmiq SimpleUVM Scoreboard BuildUVMPkg"
for mode in default testflags; do
  for r in $ROWS; do
    d=$(ls -d "$PRE/$mode/$r"-* 2>/dev/null | head -1) || true
    [ -n "${d:-}" ] || { echo "SKIP-NODIR $mode/$r"; continue; }
    dp=$(ls -d "$PAT/$mode/$r"-* 2>/dev/null | head -1) || true
    [ -n "${dp:-}" ] || { echo "SKIP-NODIR-PAT $mode/$r"; continue; }
    g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || { echo "SKIP-NOGOLD $mode/$r"; continue; }
    [ -f "$d/slang.uhdm" ] && [ -f "$dp/slang.uhdm" ] || { echo "SKIP-NODB $mode/$r"; continue; }
    "$CEN" "$g/golden.uhdm" "$d/slang.uhdm"  > "$OUT/cen.$r.$mode.pris.txt" 2>&1
    "$CEN" "$g/golden.uhdm" "$dp/slang.uhdm" > "$OUT/cen.$r.$mode.pat.txt"  2>&1
    python3 "$SCORE" "$OUT/cen.$r.$mode.pris.txt" "$OUT/cen.$r.$mode.pat.txt" \
        "$r/$mode" > "$OUT/score.$r.$mode.txt" 2>&1
    tail -1 "$OUT/score.$r.$mode.txt"
  done
done
