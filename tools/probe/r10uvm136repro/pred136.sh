#!/usr/bin/env bash
# r10uvm136 — THE A-PRIORI MOVER PREDICTOR.  Runs cen136 over every OURS
# database in a verify_golden workdir and prints every class-property cell whose
# VARIABLE CLASS is bit_var / logic_var while the typespec it binds is a
# struct / union / packed_array typespec — exactly the population the law
# rewrites.  Computed from PRISTINE databases only; nothing here reads the
# patched build, so the prediction is made BEFORE the patched sweep runs.
#
#   usage: CEN136=.. pred136.sh <workdir> <out.tsv>
# prints   <mode>/<test> \t <count>   for every database with a nonzero count,
# and a TOTAL line.  LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY.
set -u
WD=${1:?workdir}; OUT=${2:?out}
CEN=${CEN136:?set CEN136}
: > "$OUT"
n=0
# fd 3 for the list (a stdin list is swallowed by the first child).
find "$WD" -name slang.uhdm | sort > "$OUT.list"
while read -r f <&3; do
  d=$(dirname "$f"); rel=${d#$WD/}
  "$CEN" "$f" 2>/dev/null |
    awk -F'\t' -v R="$rel" '
      $1=="CELL" || $1=="ELEM" {
        split($4,v,"|"); split($5,t,"|");
        if ((v[1]=="bit_var" || v[1]=="logic_var") &&
            (t[1]=="struct_typespec" || t[1]=="union_typespec" ||
             t[1]=="packed_array_typespec"))
          print R "\t" $1 "\t" $2 "\t" v[2] "\t" v[1] "\t" t[1] "\t" t[2];
      }' >> "$OUT"
  n=$((n+1))
done 3< "$OUT.list"
echo "DBS_SCANNED=$n"
echo "CELLS=$(wc -l < "$OUT")"
cut -f1 "$OUT" | sort -u | sed 's/^/DB /'
echo "DBS_WITH_CELLS=$(cut -f1 "$OUT" | sort -u | wc -l)"
