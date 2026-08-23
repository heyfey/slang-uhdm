#!/usr/bin/env bash
# r10buvm26repro/predsweep26.sh — run the § droppedIdxRecvCall26 predictor over
# EVERY row of a PRISTINE control workdir, golden against ours, and print the
# rows that carry the law's site.  MEASUREMENT ONLY.
#
#   predsweep26.sh <control-workdir> <cen-binary> <out-dir>
#
# The golden database is the one that row's own cmds.txt names (a cache hit or
# the row's slpp output), so the pairing can never drift.
set -u
W=$1; CEN=$2; OUT=$3
D=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
: > "$OUT/hits.txt"
: > "$OUT/scanned.txt"
for mode in default testflags; do
  [ -d "$W/$mode" ] || continue
  for d in "$W/$mode"/*/; do
    row=$(basename "$d")
    [ -f "$d/slang.uhdm" ] || continue
    [ -f "$d/cmds.txt" ]   || continue
    gcache=$(grep -o 'golden cache hit [^)]*' "$d/cmds.txt" | awk '{print $4}')
    g=""
    if [ -n "$gcache" ] && [ -f "$gcache/golden.uhdm" ]; then g="$gcache/golden.uhdm"; fi
    if [ -z "$g" ]; then
      g=$(ls "$d"/slpp_all/*.uhdm "$d"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    fi
    [ -n "$g" ] || continue
    echo "$mode $row" >> "$OUT/scanned.txt"
    "$CEN" "$g"           G > "$OUT/g.cen" 2>/dev/null
    "$CEN" "$d/slang.uhdm" O > "$OUT/o.cen" 2>/dev/null
    n=$(python3 "$D/predict26.py" "$OUT/g.cen" "$OUT/o.cen" | tee "$OUT/last.txt" \
        | awk '/PREDICTED MOVERS/{print $NF}')
    if [ "${n:-0}" != "0" ]; then
      echo "== $mode $row  movers=$n" >> "$OUT/hits.txt"
      grep '^  EXPR' "$OUT/last.txt" >> "$OUT/hits.txt"
    fi
  done
done
echo "scanned $(wc -l < "$OUT/scanned.txt") row-modes"
echo "rows with sites: $(grep -c '^== ' "$OUT/hits.txt" 2>/dev/null || echo 0)"
