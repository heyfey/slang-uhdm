#!/bin/bash
# r11u29repro/survey.sh — the whole triage, reproducible from a pristine tree.
#
# WHAT IT DOES, in the order the report's numbers were made:
#   1. runs the official uhdm-cmp on every CMP_NOTEQUAL row of a corpus (one
#      head per run, `grep -c '^LHS:'`) through the committed rowheads.sh;
#   2. proves, per row, that the default and testflags heads are the SAME head
#      id-blind (so one face serves both modes) — or prints MODE-SPLIT;
#   3. decodes each head to its FACE (facediff.py) and writes the id-blind
#      quoted head beside it;
#   4. runs the positive control: two known-EQUAL rows must read 0 heads.
#
# NOTHING HERE IS A GATE.  The judge is uhdm-cmp; this only reads it.
#
#   usage: survey.sh <workdir> <baseline.csv> <outdir> [<fenced-list-file>]
#     <workdir>       a verify_golden.py workdir holding default/ and testflags/
#     <baseline.csv>  results/golden_<corpus>.csv (READ-ONLY)
#     <fenced-list>   one name per line; those rows are EXCLUDED (never spelled
#                     in this script — build the file from a committed driver)
set -u
WD=${1:?workdir}; BASE=${2:?baseline csv}; OUT=${3:?outdir}; FENCED=${4:-}
HERE=$(cd "$(dirname "$0")" && pwd)
RH=$HERE/../r10uvm67repro/rowheads.sh
[ -f "$RH" ] || { echo "FATAL: no rowheads.sh at $RH"; exit 3; }
mkdir -p "$OUT/cmp"

NAMES=$(awk -F, 'NR>1 && $3=="CMP_NOTEQUAL"{print $1}' "$BASE" | sort -u)
if [ -n "$FENCED" ]; then
  NAMES=$(printf '%s\n' "$NAMES" | grep -vFf "$FENCED" || true)
fi
echo "rows: $(printf '%s\n' "$NAMES" | grep -c .)"

# the two positive-control rows: the FIRST two CMP_EQUAL names of the baseline.
CTL=$(awk -F, 'NR>1 && $3=="CMP_EQUAL"{print $1}' "$BASE" | sort -u | head -2)

bash "$RH" "$WD" "$OUT/cmp" $NAMES $CTL > "$OUT/rowheads.txt" 2>&1
echo "-- rowheads -> $OUT/rowheads.txt"

# mode identity, id-blind
: > "$OUT/mode_identity.txt"
for f in "$OUT"/cmp/*.default.cmp; do
  n=$(basename "$f" .default.cmp)
  t="$OUT/cmp/$n.testflags.cmp"
  if [ ! -f "$t" ]; then echo "$n ONE-MODE-ONLY" >> "$OUT/mode_identity.txt"; continue; fi
  if diff -q <(sed -E 's/id:[0-9]+/id:#/g' "$f") \
             <(sed -E 's/id:[0-9]+/id:#/g' "$t") >/dev/null; then
    echo "$n IDBLIND-SAME" >> "$OUT/mode_identity.txt"
  else
    echo "$n MODE-SPLIT" >> "$OUT/mode_identity.txt"
  fi
done
echo "-- mode identity -> $OUT/mode_identity.txt  (MODE-SPLIT rows: $(grep -c MODE-SPLIT "$OUT/mode_identity.txt" || true))"

python3 "$HERE/facediff.py" --key "$OUT"/cmp/*.cmp > "$OUT/faces.key.txt"
python3 "$HERE/facediff.py"       "$OUT"/cmp/*.cmp > "$OUT/faces.full.txt"
python3 "$HERE/decode_heads.py"   "$OUT"/cmp/*.cmp > "$OUT/faces.csv"
echo "-- faces -> $OUT/faces.key.txt $OUT/faces.full.txt $OUT/faces.csv"

echo "== POSITIVE CONTROL (known-equal rows must read 0 heads):"
for c in $CTL; do grep "^$c " "$OUT/rowheads.txt"; done
