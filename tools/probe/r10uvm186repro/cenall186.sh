#!/usr/bin/env bash
# r10uvm186repro/cenall186.sh — the CORPUS CENSUS over named rows of two
# completed sweep workdirs (pristine and patched) and their OWN goldens.
# MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   cenall186.sh <pristine-wd> <patched-wd> <outdir> <name> [<name> ...]
#
# The golden is read out of the row's own `cmds.txt` (never guessed), a missing
# side is REPORTED rather than skipped, and the calibration run
# (golden-vs-golden) is printed FIRST so a key that splits cells the judge
# pairs is caught before any score is read (RESUME.md §9).
set -u
PRIS=${1:?pristine workdir}; PAT=${2:?patched workdir}; OUT=${3:?outdir}
shift 3
CEN=${CT186NEW:-/tmp/r10uvm186_bin/ct186new}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
: > "$OUT/summary.txt"
for n in "$@"; do
  for mode in default testflags; do
    for d in "$PRIS/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      row=$(basename "$d")
      P="$d/slang.uhdm"; Q="$PAT/$mode/$row/slang.uhdm"; C="$d/cmds.txt"
      G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        echo "SKIP-NOFILE $n $mode g=${G:-none} p=$P q=$Q" >> "$OUT/summary.txt"
        continue
      fi
      "$CEN" "$G" > "$OUT/$n.$mode.g.txt"
      "$CEN" "$P" > "$OUT/$n.$mode.a.txt"
      "$CEN" "$Q" > "$OUT/$n.$mode.b.txt"
      {
        echo "==== $n $mode  (rows g/a/b: $(tail -1 "$OUT/$n.$mode.g.txt" | awk '{print $2}')/$(tail -1 "$OUT/$n.$mode.a.txt" | awk '{print $2}')/$(tail -1 "$OUT/$n.$mode.b.txt" | awk '{print $2}'))"
        echo "-- CALIBRATION golden vs golden vs golden (every column must be 0 but UNTOUCHED):"
        python3 "$HERE/score186.py" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.g.txt" | head -8
        echo "-- SCORE golden / pristine / patched:"
        python3 "$HERE/score186.py" "$OUT/$n.$mode.g.txt" "$OUT/$n.$mode.a.txt" "$OUT/$n.$mode.b.txt"
      } >> "$OUT/summary.txt"
    done
  done
done
cat "$OUT/summary.txt"
