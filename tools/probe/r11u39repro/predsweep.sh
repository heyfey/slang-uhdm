#!/bin/bash
# r11u39 — run ct39cen --pred over EVERY database in a verify_golden workdir and
# name the predicted movers.  MEASUREMENT ONLY.
#   usage: predsweep.sh <workdir> <out.txt>
# Every database is existence-checked and COUNTED: a driver that reaches nothing
# must never read as "no movers".  Each row records the probe's own rc.
set -u
WD=${1:?workdir}; OUT=${2:?out}
CEN=${CT39CEN:-/tmp/r11u39_bin/ct39cen}
[ -x "$CEN" ] || { echo "FATAL: no ct39cen at $CEN"; exit 3; }
: > "$OUT"
n=0; miss=0; fail=0
for f in "$WD"/*/*/slang.uhdm; do
  [ -f "$f" ] || { miss=$((miss+1)); continue; }
  d=$(dirname "$f"); mode=$(basename "$(dirname "$d")")
  tag="$(basename "$d")/$mode"
  "$CEN" --pred "$f" "$tag" >> "$OUT" 2>&1 || fail=$((fail+1))
  n=$((n+1))
done
echo "SWEPT databases=$n missing=$miss proberc_nonzero=$fail"
echo "PREDICTED MOVERS:"
grep -E '^PREDSUM .* MOVER-PREDICTED' "$OUT" || echo "  (none)"
echo "counts:"
echo "  databases with a predicted mover: $(grep -c 'MOVER-PREDICTED' "$OUT"; true)"
echo "  COMPOSITE cells: $(grep -c ' COMPOSITE ' "$OUT"; true)"
echo "  DROPPED   cells: $(grep -c ' DROPPED ' "$OUT"; true)"
echo "  ERASED    cells: $(grep -c ' ERASED ' "$OUT"; true)"
