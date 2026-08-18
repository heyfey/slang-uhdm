#!/usr/bin/env bash
# r10buvm23repro/fence23.sh — THE FENCE, enumerated from the PRISTINE databases
# BEFORE the code: every database in a sweep workdir that carries the shape this
# pass touches, i.e. a method-call RECEIVER PATH whose written text puts a `.`
# INSIDE A BRACKET PAIR.  MEASUREMENT ONLY.
#
# Two independent detectors, both read off the database rather than the source:
#   BOGUS   an object whose VpiName contains `[`, `]`, `(` or `)` — the fossil a
#           TEXT split leaves behind (`m_streams[ro`, `get_name()]`).  A
#           `hier_path` legitimately carries brackets in its name and is
#           excluded; every other kind is a defect.
#   DOTIDX  a `hier_path` whose own VpiName carries a `.` INSIDE a bracket pair
#           — our raw-text rendering of an index golden decompiles to nothing.
#
#   fence23.sh <workdir> <r10buvm23cen binary> <out prefix>
set -u
W=$1; CEN=$2; OUT=$3
: > "$OUT.bogus.txt"; : > "$OUT.dotidx.txt"; : > "$OUT.dbs.txt"
n=0
while IFS= read -r db; do
  n=$((n+1))
  tag=$(dirname "${db#$W/}")
  "$CEN" "$db" "$tag" 2>/dev/null | awk -F'\t' -v t="$tag" '
    $2=="BOGUS" && $3!="hier_path" { print t"\t"$0 >> "'"$OUT"'.bogus.txt"; next }
    $2=="HP" {
      # a `.` at bracket depth > 0 inside the NAME
      nmv=$6; d=0
      for (i=1;i<=length(nmv);i++) {
        c=substr(nmv,i,1)
        if (c=="[") d++
        else if (c=="]") { if (d>0) d-- }
        else if (c=="." && d>0) { print t"\t"$0 >> "'"$OUT"'.dotidx.txt"; break }
      }
    }'
done < <(find "$W" -name slang.uhdm | sort)
echo "SCANNED $n databases"
awk -F'\t' '{print $1}' "$OUT.bogus.txt"  | sort -u > "$OUT.bogus.dbs"
awk -F'\t' '{print $1}' "$OUT.dotidx.txt" | sort -u > "$OUT.dotidx.dbs"
echo "BOGUS  rows $(wc -l < "$OUT.bogus.txt")  in $(wc -l < "$OUT.bogus.dbs") databases"
echo "DOTIDX rows $(wc -l < "$OUT.dotidx.txt") in $(wc -l < "$OUT.dotidx.dbs") databases"
sort -u "$OUT.bogus.dbs" "$OUT.dotidx.dbs" > "$OUT.dbs.txt"
echo "UNION $(wc -l < "$OUT.dbs.txt") databases"
cat "$OUT.dbs.txt"
