#!/usr/bin/env bash
# r10earl66 — FENCE SCAN: every OUR database in a sweep workdir that carries an
# ELAB port-High_conn ref_obj -> enum_const (the cells § elabConnEnumConstFold66
# would fold).  MEASUREMENT ONLY.  usage: fencescan.sh <workdir> <out>
set -u
CEN=${TSCEN66:?}
W=$1; OUT=$2
: > "$OUT"
find "$W" -name slang.uhdm | sort | while read -r db; do
  n=$("$CEN" "$db" 2>/dev/null | awk '$2=="ELAB" && $4 ~ /^HC/ && /actual=enum_const/' | wc -l)
  [ "$n" -gt 0 ] && echo "$n $db" >> "$OUT"
done
sort -rn "$OUT" | head -40
echo "ROWS_WITH_CELLS $(wc -l < "$OUT")"
