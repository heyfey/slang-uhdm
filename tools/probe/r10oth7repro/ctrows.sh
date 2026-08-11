#!/usr/bin/env bash
# r10oth7 — the ROW GATE.  Whole-row diff of a fresh sweep CSV against the
# COMMITTED AUTHORITATIVE BASELINE, plus the per-mode status and dump
# histograms, plus the header/row arithmetic the campaign keeps getting wrong.
#
#   usage: ctrows.sh <new.csv> <committed-baseline.csv>
#
# `wc -l` on the baselines COUNTS THE HEADER: 732 lines = 731 rows, 1589 = 1588.
# This script prints ROWS, not lines, and says so.
#
# It NEVER writes to the baseline.  Both files are opened read-only.
set -u
NEW=${1:?new csv}
BASE=${2:?committed baseline csv}
[ -f "$NEW" ] || { echo "FATAL: missing $NEW"; exit 9; }
[ -f "$BASE" ] || { echo "FATAL: missing $BASE"; exit 9; }
nr=$(( $(wc -l < "$NEW") - 1 ))
br=$(( $(wc -l < "$BASE") - 1 ))
echo "rows: new=$nr baseline=$br  (lines are rows+1; the header is not a row)"
[ "$nr" -eq "$br" ] || echo "WARNING: ROW COUNT CHANGED"
echo "-- whole-row diff (status AND dump columns), sorted so order cannot fake it"
d=$(diff <(sort "$NEW") <(sort "$BASE") | grep -c '^[<>]')
echo "differing rows: $d"
if [ "$d" -ne 0 ]; then
  diff <(sort "$NEW") <(sort "$BASE") | grep '^[<>]' | head -40
fi
echo "-- per-mode status histogram (new sweep)"
for m in default testflags folded; do
  n=$(awk -F, -v m="$m" 'NR>1 && $2==m' "$NEW" | wc -l)
  [ "$n" -eq 0 ] && continue
  echo "  mode=$m rows=$n"
  awk -F, -v m="$m" 'NR>1 && $2==m {print "    status "$3}' "$NEW" | sort | uniq -c
  awk -F, -v m="$m" 'NR>1 && $2==m {print "    dump   "$NF}' "$NEW" | sort | uniq -c
done
[ "$d" -eq 0 ] || exit 1
