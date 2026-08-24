#!/usr/bin/env bash
# r10earl81 — the SHAPE-SIDE corpus scan: how many port-High_conn bit_select
# INDEX slots does OUR emitter leave as a `ref_obj` in each database?  That is
# the set the new gate could fire on, INCLUDING the cells where golden already
# agrees with us — earl66's lesson: a census keyed on the shape you intend to
# CHANGE is blind to the rows you would change by ACCIDENT.
# MEASUREMENT ONLY: reads databases, dispatches nothing.  FENCED= lists only.
#   usage: SELCEN81=<bin> oursshape81.sh <sweep-workdir> <out.tsv>
set -u
CEN=${SELCEN81:?set SELCEN81}
WD=$(readlink -f "$1"); OUT=$(readlink -f "$2")
T=${TMPDIR:-/tmp}/r10earl81_os.$$; mkdir -p "$T"; : > "$OUT"
n=0
while IFS= read -r c; do
  d=$(dirname "$c"); ours="$d/slang.uhdm"; [ -f "$ours" ] || continue
  "$CEN" "$ours" 2>/dev/null > "$T/o.cen" || continue
  r=$(grep 'port(' "$T/o.cen" | grep -c 'k=bit_select s=idx .*|| K=ref_obj'; true)
  a=$(grep 'port(' "$T/o.cen" | grep -c 'k=bit_select s=idx'; true)
  printf '%s\t%s\t%s\n' "${d#$WD/}" "$r" "$a" >> "$OUT"; n=$((n+1))
done < <(find "$WD" -name cmds.txt | sort)
rm -rf "$T"
echo "SCANNED=$n"
awk -F'\t' '{r+=$2; a+=$3; if($2>0) k++} END{printf "OUR_REF_IDX_CELLS=%d  ALL_HIGHCONN_BITSEL_IDX=%d  DBs_WITH_A_REF=%d\n", r, a, k}' "$OUT"
sort -t$'\t' -k2 -nr "$OUT" | awk -F'\t' '$2>0' | head -40
