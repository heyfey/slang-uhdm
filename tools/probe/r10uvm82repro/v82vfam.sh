#!/usr/bin/env bash
# r10uvm82 VERIFIER: per-ladder family tallies + the pass's own family, and the
# NEW-FAMILY scan (a family present AFTER and absent BEFORE = suspect).
set -u
B=${1:?before dir}; A=${2:?after dir}
printf "%-26s %7s %7s %7s %7s %s\n" LADDER RUNG_B RUNG_A FAM82_B FAM82_A IMPORTED_ANY_A
for f in "$B"/ladder_*.txt; do
  n=$(basename "$f" .txt); g="$A/$n.txt"
  [ -f "$g" ] || { printf "%-26s %7s %7s %7s %7s %s\n" "$n" "$(grep -c '^RUNG' $f)" "MISSING" - - -; continue; }
  rb=$(grep -c '^RUNG' "$f"); ra=$(grep -c '^RUNG' "$g")
  fb=$(grep -c 'FAM=parameter|VpiImported|O-EMPTY' "$f" || true)
  fa=$(grep -c 'FAM=parameter|VpiImported|O-EMPTY' "$g" || true)
  ia=$(grep -c 'FIELD=VpiImported' "$g" || true)
  printf "%-26s %7s %7s %7s %7s %s\n" "$n" "$rb" "$ra" "$fb" "$fa" "$ia"
done
echo
echo "== NEW FAMILIES (in AFTER, absent from the SAME row's BEFORE) =="
for f in "$B"/ladder_*.txt; do
  n=$(basename "$f" .txt); g="$A/$n.txt"; [ -f "$g" ] || continue
  grep -o 'FAM=[^	]*' "$f" | sort -u > /tmp/v82_fb.$$
  grep -o 'FAM=[^	]*' "$g" | sort -u > /tmp/v82_fa.$$
  nn=$(comm -13 /tmp/v82_fb.$$ /tmp/v82_fa.$$)
  gone=$(comm -23 /tmp/v82_fb.$$ /tmp/v82_fa.$$ | wc -l)
  echo "-- $n  families_gone=$gone families_new=$(echo "$nn" | grep -c FAM= || true)"
  [ -n "$nn" ] && echo "$nn" | sed 's/^/     NEW /'
  rm -f /tmp/v82_fb.$$ /tmp/v82_fa.$$
done
