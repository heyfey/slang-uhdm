#!/bin/bash
# hdiff17.sh <censusA.txt> <censusB.txt> -- head diff of two r10earl4h runs.
# METRIC HYGIENE (pass 17): comparing only the `HEAD <name> r=<n>` lines HIDES
# an ADVANCE — § pkgBoundMintTsTopInstance17 moved four heads off the
# missing-instance pointer onto an unrelated residue and every r stayed 1, so
# the head-only diff printed nothing.  The failLhs/failRhs lines are part of
# the metric; the head-only view is kept as a second, coarser section.
grep -E '^  HEAD|head\(s\)|^== |^    fail' "$1" | sed -E 's#/[^ ]*/##g' \
  > /tmp/r10earl17_hA.txt
grep -E '^  HEAD|head\(s\)|^== |^    fail' "$2" | sed -E 's#/[^ ]*/##g' \
  > /tmp/r10earl17_hB.txt
echo "--- heads + first failing pair"
diff /tmp/r10earl17_hA.txt /tmp/r10earl17_hB.txt
echo "--- head lines only"
grep -E '^  HEAD|head\(s\)|^== ' "$1" > /tmp/r10earl17_hA2.txt
grep -E '^  HEAD|head\(s\)|^== ' "$2" > /tmp/r10earl17_hB2.txt
diff /tmp/r10earl17_hA2.txt /tmp/r10earl17_hB2.txt
echo "(rc=$?)"
