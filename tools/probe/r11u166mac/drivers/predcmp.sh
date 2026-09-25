#!/bin/bash
# predcmp.sh <byteverify surelog.txt> <byteverify uhdm2rtlil.txt> <predict surelog.tsv> <predict uhdm2rtlil.tsv>
#   movers vs predicted rows (name|mode): prints movers not predicted (must be empty) and the predicted count.
set -u
mv=$(mktemp); pr=$(mktemp)
for f in "$1" "$2"; do grep '^MOVER ' "$f" | awk '{print $2}' | sed 's|^\./||;s|-[0-9a-f]*/slang.uhdm||' | awk -F/ '{print $2"|"$1}'; done | sort -u > "$mv"
cat "$3" "$4" | awk -F'\t' 'NF==3 && $3!="-" && $3!="NODIR"{print $1"|"$2}' | sort -u > "$pr"
echo "movers=$(wc -l < "$mv") predicted=$(wc -l < "$pr") movers_predicted=$(comm -12 "$mv" "$pr" | wc -l)"
echo "MOVERS NOT PREDICTED:"; comm -23 "$mv" "$pr"
rm -f "$mv" "$pr"
