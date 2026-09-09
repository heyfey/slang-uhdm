#!/bin/bash
# § ifaceDefNetTypespecIsTheModuleRule224 — collect the A-PRIORI prediction.
#   usage: predcollect224.sh <predictor-log-dir> <outfile>
# Every PRED224 line names ONE def-view interface net the law would strip, with
# the row-mode read out of the -o path the harness chose.  Rows with no line are
# rows the law cannot reach.
set -u
LOG=${1:?logdir}
OUT=${2:?outfile}
: > "$OUT"
for f in "$LOG"/*.err; do
    [ -f "$f" ] || continue
    n=$(grep -c '^PRED224 ' "$f"; true)
    [ "$n" = 0 ] && continue
    row=$(basename "$f" .err)
    echo "HIT $row cells=$n" >> "$OUT"
    sed -n 's/^PRED224 /  CELL /p' "$f" | sed "s#^#  $row #" >> "$OUT"
done
echo "-- HIT-ROWS=$(grep -c '^HIT ' "$OUT"; true)  CELLS=$(grep -c '  CELL ' "$OUT"; true)" | tee -a "$OUT"
