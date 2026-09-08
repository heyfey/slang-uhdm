#!/usr/bin/env bash
# r10uvm216 — THE CORPUS CENSUS DRIVER.  MEASUREMENT ONLY; `uhdm-cmp` is the
# sole acceptance judge and this script never judges a row.
#
# For every row named on the command line (or every row in the predictor's FIRE
# list), it joins the row's GOLDEN database against the row's own database in a
# sweep workdir, with `ct216cen` + `cen216.py`, and prints the one-line summary
# plus every differing cell.  LHS is ALWAYS golden.
#
# The golden path is read out of the row's own `cmds.txt` (`(golden cache hit
# <dir>)`), which is the ONLY authority for which cache entry a row used —
# SeqDriver's default and testflags goldens are DIFFERENT entries (RESUME §9).
#
# The census is CALIBRATED golden-vs-golden first in every cell; a non-null
# calibration is counted and reported, because a census that cannot read zero
# on identical inputs scores nothing.
#
# usage: CEN=<ct216cen> ./cen216.sh <sweep-workdir> <out> [<rowdir-glob> ...]
set -u
CEN=${CEN:?path to ct216cen}
HERE=$(cd "$(dirname "$0")" && pwd)
WD=${1:?sweep workdir}; OUT=${2:?out}; shift 2
[ -x "$CEN" ] || { echo "FATAL: no ct216cen $CEN"; exit 3; }
: > "$OUT"
n=0; nog=0; calib=0; diff=0
for pat in "$@"; do
  while IFS= read -r d; do
    [ -f "$d/slang.uhdm" ] || continue
    row=$(basename "$d"); mode=$(basename "$(dirname "$d")")
    g=$(sed -n 's/.*golden cache hit \([^)]*\).*/\1/p' "$d/cmds.txt")/golden.uhdm
    n=$((n+1))
    if [ ! -f "$g" ]; then
      echo "ROW $row $mode golden=NO -- NOT SCORED" >> "$OUT"; nog=$((nog+1)); continue
    fi
    "$CEN" "$g" > "$d/.g216.kc" 2>/dev/null
    "$CEN" "$d/slang.uhdm" > "$d/.o216.kc" 2>/dev/null
    cal=$(python3 "$HERE/cen216.py" "$d/.g216.kc" "$d/.g216.kc" --only-diff | tail -1)
    case "$cal" in *"ONLY-GOLDEN=0 ONLY-OURS=0") : ;; *) calib=$((calib+1)) ;; esac
    sum=$(python3 "$HERE/cen216.py" "$d/.g216.kc" "$d/.o216.kc" --only-diff | tail -1)
    echo "ROW $row $mode CALIB[$cal] $sum" >> "$OUT"
    case "$sum" in *"ONLY-GOLDEN=0 ONLY-OURS=0") : ;; *) diff=$((diff+1)) ;; esac
    python3 "$HERE/cen216.py" "$d/.g216.kc" "$d/.o216.kc" --only-diff \
      | grep -v '^--' | sed "s|^|CELL $row $mode |" >> "$OUT"
  done < <(find "$WD" -mindepth 2 -maxdepth 2 -type d -name "$pat" | sort)
done
echo "-- ROWS-SCORED=$n NO-GOLDEN=$nog CALIB-NONNULL=$calib ROWS-DIFFERING=$diff" >> "$OUT"
tail -1 "$OUT"
