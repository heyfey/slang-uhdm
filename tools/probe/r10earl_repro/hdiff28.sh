#!/bin/bash
# hdiff19.sh <censusA.txt> <censusB.txt> -- head diff of two r10earl4h runs.
# METRIC HYGIENE (pass 17): the failLhs/failRhs lines are part of the metric —
# a law can move heads onto a different object with every `HEAD ... r=n` line
# byte-identical.
grep -E '^  HEAD|head\(s\)|^== |^    fail' "$1" | sed -E 's#/[^ ]*/##g' \
  > /tmp/r10earl28_hA.txt
grep -E '^  HEAD|head\(s\)|^== |^    fail' "$2" | sed -E 's#/[^ ]*/##g' \
  > /tmp/r10earl28_hB.txt
echo "--- heads + first failing pair"
diff /tmp/r10earl28_hA.txt /tmp/r10earl28_hB.txt
echo "--- head lines only"
grep -E '^  HEAD|head\(s\)|^== ' "$1" > /tmp/r10earl28_hA2.txt
grep -E '^  HEAD|head\(s\)|^== ' "$2" > /tmp/r10earl28_hB2.txt
diff /tmp/r10earl28_hA2.txt /tmp/r10earl28_hB2.txt
echo "(rc=$?)"
