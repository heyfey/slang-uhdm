#!/usr/bin/env bash
# r10uvm156 — MOVER PREDICTOR.  Runs ct156cen over every OURS database in a
# verify_golden workdir and names the DBs holding a cell § 156 will move.
# MEASUREMENT ONLY, and it reads PRISTINE databases only.
set -u
WD=${1:?workdir}; OUT=${2:?outfile}; CEN=${CEN:?set CEN}
: > "$OUT"
find "$WD" -name slang.uhdm -print0 | while IFS= read -r -d '' f; do
  d=$(dirname "$f")
  n=$(basename "$d")
  mode=$(basename "$(dirname "$d")")
  "$CEN" "$f" --tag="$mode/$n" 2>/dev/null | awk '/ role=return /' >> "$OUT"
done
echo "rows=$(grep -c . "$OUT"; true)"
