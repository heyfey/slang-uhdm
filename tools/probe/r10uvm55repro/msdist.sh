#!/bin/bash
# VERIFIER instrument: RESYNC-IMMUNE dump distance.
#
# `diff -u | grep -c '^[-+]'` is an LCS measure: when diff picks a different
# alignment the count can move by thousands with almost no content change (this
# is what pass 55 reports for SeqDriver, +5187 while our file grew 95 lines).
# This instrument does not use an alignment at all: it compares the MULTISET of
# dump lines (content, whitespace-normalised at the left edge kept intact) and
# reports  sum over distinct lines of |count_golden - count_ours|.
#
#   usage: msdist.sh <g.dump> <o.dump>
#
# Both inputs must already have uhdm-dump's FIRST LINE (the database path)
# stripped — wdump.sh does that with `sed '1d'`.  The number printed here has NO
# +2 bias and NO diff header lines in it at all.
# GUARD: an empty or missing input is exit 6, never a distance of 0.
set -u
G=${1:?golden dump}
O=${2:?ours dump}
for f in "$G" "$O"; do
  [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
done
T=$(mktemp -d)
sort "$G" | uniq -c | awk '{c=$1; $1=""; print c"\t"$0}' > "$T/g.cnt"
sort "$O" | uniq -c | awk '{c=$1; $1=""; print c"\t"$0}' > "$T/o.cnt"
awk -F'\t' '
  FNR==NR { g[$2]=$1; next }
  { o[$2]=$1 }
  END {
    for (k in g) { d = g[k] - (k in o ? o[k] : 0); if (d>0) gonly += d }
    for (k in o) { d = o[k] - (k in g ? g[k] : 0); if (d>0) oonly += d }
    printf "golden-only line instances: %d\n", gonly+0
    printf "ours-only   line instances: %d\n", oonly+0
    printf "MULTISET DISTANCE (sum |dg-do|): %d\n", gonly+oonly
  }' "$T/g.cnt" "$T/o.cnt"
echo "g lines=$(wc -l < "$G")  o lines=$(wc -l < "$O")"
rm -rf "$T"
