#!/bin/bash
# bcensus_run.sh <pairs.tsv> <out.tsv> <mode>: the (b) census on both sides of every pair (3 at a time).
# Columns: side corpus/mode/test mode skipped_listings objects_skipped never_compared_named never_compared_anon first_via_ref_named
P=$1; OUT=$2; M=$3
awk -F'\t' '{print "golden\t"$1"/"$2"/"$3"\t"$4; print "ours\t"$1"/"$2"/"$3"\t"$5}' "$P" |
  xargs -P 3 -d '\n' -I{} bash -c 'IFS=$'"'"'\t'"'"' read s k f <<< "{}"; [ "$f" = "-" ] && exit 0; echo -e "$s\t$(/tmp/r11u129_bin/bcensus_g "$f" '"$M"' "$k")"' > "$OUT"
wc -l < "$OUT"
