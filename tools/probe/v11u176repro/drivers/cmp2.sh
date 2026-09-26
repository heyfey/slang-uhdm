#!/bin/bash
# cmp2.sh <case> <tagA> <tagB>: first record, objects, order-blind distance for two runs of one case
C=$(echo $1 | sed 's|/|__|g'); D=/tmp/v11u176_scr/caseout
for t in $2 $3; do
  O=$D/$C.$t
  [ -f $O/strict.txt ] || { echo "$t: no strict"; continue; }
  first=$(grep -m1 '^#' $O/strict.txt)
  ob=$(comm -3 <(cut -f2- $O/a.rec | sort) <(cut -f2- $O/b.rec | sort) | wc -l)
  echo "$t: cmplines=$(wc -l < $O/cmp.txt) first=[$first] $(grep '^objects' $O/strict.txt) orderblind=$ob $(tail -1 $O/strict.txt)"
done
