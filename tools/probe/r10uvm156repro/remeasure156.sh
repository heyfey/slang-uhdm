#!/usr/bin/env bash
# r10uvm156 — RE-MEASURE every boundary mover against GOLDEN.  For each arm
# named on stdin (relative path under the arm copy) it builds golden with
# Surelog in BOTH views, builds both binaries, and scores every class_typespec
# cell with score156.py (RIGHT/WRONG) and away156.py (the AWAY column).
# MEASUREMENT ONLY; LHS IS ALWAYS GOLDEN.
#   usage: PRIS=.. PATCHED=.. remeasure156.sh <arm-root> <outdir> < list
set -u
SRC=$(readlink -f "${1:?arm root}"); OUT=$(readlink -f "${2:?outdir}"); mkdir -p "$OUT"
HERE=$(cd "$(dirname "$0")" && pwd)
while IFS= read -r rel <&3; do
  f=$SRC/$rel; [ -f "$f" ] || { echo "MISSING $rel"; continue; }
  key=$(echo "$rel" | tr '/' '_'); D=$OUT/$key; mkdir -p "$D"
  PRIS=$PRIS PATCHED=$PATCHED bash "$HERE/arm156.sh" "$f" "$D" > "$D/arm.log" 2>&1
  for h in "$(dirname "$f")"/*.svh; do [ -f "$h" ] && cp "$h" "$D/"; done
  for v in "g o q def" "ge oe qe elab"; do
    set -- $v
    [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] && [ -f "$D/$3.uhdm" ] || { echo "NODB $rel/$4"; continue; }
    "$HERE/ct156cen" "$D/$1.uhdm" --tag=G > "$D/cen.$4.G.txt"
    "$HERE/ct156cen" "$D/$2.uhdm" --tag=O > "$D/cen.$4.O.txt"
    "$HERE/ct156cen" "$D/$3.uhdm" --tag=Q > "$D/cen.$4.Q.txt"
    python3 "$HERE/score156.py" "$D/cen.$4.G.txt" "$D/cen.$4.O.txt" "$D/cen.$4.Q.txt" "$rel/$4"
    python3 "$HERE/away156.py"  "$D/cen.$4.G.txt" "$D/cen.$4.O.txt" "$D/cen.$4.Q.txt" "$rel/$4"
  done
done 3< /dev/stdin
