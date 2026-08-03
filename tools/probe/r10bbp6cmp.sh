#!/bin/bash
# r10bbp6cmp: project the whole-design fold census onto (key -> dims) and report
# ONLY the keys present in BOTH sides with DIFFERENT dims (a real fold
# divergence), separately from keys missing on one side (a materialization
# residue).  Multiset-safe: identical keys are counted, not joined.
G=${1:-/tmp/r10bbp6_ga.txt}
S=${2:-/tmp/r10bbp6_sa.txt}
awk '{n=index($0," dims="); k=substr($0,1,n-1); d=substr($0,n+6); print k"\t"d}' "$G" | sort | uniq -c | sed 's/^ *//' > /tmp/r10bbp6_gk.tsv
awk '{n=index($0," dims="); k=substr($0,1,n-1); d=substr($0,n+6); print k"\t"d}' "$S" | sort | uniq -c | sed 's/^ *//' > /tmp/r10bbp6_sk.tsv
cut -f1 /tmp/r10bbp6_gk.tsv | sed 's/^[0-9]* //' | sort -u > /tmp/r10bbp6_gkeys
cut -f1 /tmp/r10bbp6_sk.tsv | sed 's/^[0-9]* //' | sort -u > /tmp/r10bbp6_skeys
comm -12 /tmp/r10bbp6_gkeys /tmp/r10bbp6_skeys > /tmp/r10bbp6_both
echo "== FOLD DIVERGENCE (key on both sides, dims differ) =="
while IFS= read -r k; do
  a=$(awk -F'\t' -v k="$k" '{sub(/^[0-9]+ /,"",$1); if ($1==k) print $2}' /tmp/r10bbp6_gk.tsv | sort | tr '\n' ' ')
  b=$(awk -F'\t' -v k="$k" '{sub(/^[0-9]+ /,"",$1); if ($1==k) print $2}' /tmp/r10bbp6_sk.tsv | sort | tr '\n' ' ')
  [ "$a" = "$b" ] || echo "G[$a] S[$b]  $k"
done < /tmp/r10bbp6_both
echo "== KEYS ONLY IN GOLDEN =="
comm -23 /tmp/r10bbp6_gkeys /tmp/r10bbp6_skeys | wc -l
echo "== KEYS ONLY IN OURS =="
comm -13 /tmp/r10bbp6_gkeys /tmp/r10bbp6_skeys | wc -l
