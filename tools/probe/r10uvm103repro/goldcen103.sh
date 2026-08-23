#!/usr/bin/env bash
# r10uvm103repro/goldcen103.sh — CALIBRATE GOLDEN-VS-GOLDEN FIRST.  Runs the
# census over every GOLDEN database a sweep workdir names in its own cmds.txt
# (the cache DIRECTORY is turned into .../golden.uhdm; handing uhdm-cmp or the
# census a directory measures nothing) and reports how many `HPCALL POS=STMT`
# rows golden itself holds — the fossil this pass's predictor is keyed on.
#
#   goldcen103.sh <sweep workdir> <cen bin> <out.tsv>
set -u
WD=${1:?workdir}; CEN=${2:?cen}; OUT=${3:?out}
: > "$OUT.paths"
find "$WD" -name cmds.txt -print0 | xargs -0 -r sed -n 's#.*golden cache hit \(/[^)]*\).*#\1/golden.uhdm#p' | LC_ALL=C sort -u > "$OUT.paths"
echo "distinct goldens: $(wc -l < "$OUT.paths")"
: > "$OUT"
xargs -a "$OUT.paths" -r -P "${JOBS:-3}" -I{} bash -c '
  f="$1"; [ -f "$f" ] || { echo "MISSING $f" >&2; exit 0; }
  "'"$CEN"'" "$f" "$(basename "$(dirname "$f")")" 2>/dev/null | grep -P "\tHPCALL\t" || true
' _ {} >> "$OUT"
echo "HPCALL rows total : $(wc -l < "$OUT")"
echo "HPCALL POS=STMT   : $(grep -cP 'POS=STMT' "$OUT" || true)"
