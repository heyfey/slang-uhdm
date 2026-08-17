#!/usr/bin/env bash
# r10earl51 — PER-SHAPE MULTISET MOVERS between two OURS dumps.
#
#   usage: shapes48.sh <pristine-o.dump> <patched-o.dump>
#
# Reports ADDED and REMOVED **separately** and **by MULTISET**, never by diff
# alignment (an LCS realignment can move thousands of lines with no content
# change -- see msdist.sh).  A "shape" is the dump line verbatim, indentation
# included: uhdm-dump's Earlgrey output carries no object ids, so the line IS
# the shape.  Both inputs must already have had line 1 (the database path)
# stripped.
#
# GUARD: an empty or missing input is exit 6, never "no movers".
set -u
A=${1:?pristine o.dump}
B=${2:?patched o.dump}
for f in "$A" "$B"; do
  [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
done
T=$(mktemp -d)
sort "$A" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/a.cnt"
sort "$B" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$T/b.cnt"
awk -F'\t' '
  FNR==NR { a[$2]=$1; next }
  { b[$2]=$1 }
  END {
    for (k in b) { d = b[k] - (k in a ? a[k] : 0);
                   if (d>0) { addS++; addI+=d; printf "ADDED   %6d  [%s]\n", d, k } }
    for (k in a) { d = a[k] - (k in b ? b[k] : 0);
                   if (d>0) { remS++; remI+=d; printf "REMOVED %6d  [%s]\n", d, k } }
    printf "ADDED shapes=%d instances=%d   REMOVED shapes=%d instances=%d   NET=%+d\n",
           addS+0, addI+0, remS+0, remI+0, (addI+0)-(remI+0)
  }' "$T/a.cnt" "$T/b.cnt"
echo "a lines=$(wc -l < "$A")  b lines=$(wc -l < "$B")"
rm -rf "$T"
