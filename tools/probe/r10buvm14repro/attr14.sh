#!/usr/bin/env bash
# r10buvm14repro/attr14.sh — WHOLE-DUMP ATTRIBUTION for ONE pair of databases.
#
#   usage: attr14.sh <pristine.uhdm> <patched.uhdm>
#
# Prints every changed dump LINE KIND with a count, insertions vs deletions, and
# the raw diff head.  This is the instrument that sees what the hier_path census
# CANNOT: a STATEMENT-position call emits a bare `method_func_call` and NO
# hier_path at all, so arm cells S1/S2 are invisible to grid14 and only a
# whole-dump diff can prove they did not move.  "An arm agreeing is not an arm
# testing."
#
# Object IDs are NOT in the dump; absolute paths ARE, and both dumps are taken
# in the same directory, so no normalisation is needed beyond dropping the
# header line.
set -u
A=${1:?pristine.uhdm}
B=${2:?patched.uhdm}
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
[ -s "$A" ] && [ -s "$B" ] || { echo "FATAL: missing database"; exit 3; }
"$D" "$A" | tail -n +2 > /tmp/r10buvm14_attr_a.txt
"$D" "$B" | tail -n +2 > /tmp/r10buvm14_attr_b.txt
ins=$(diff /tmp/r10buvm14_attr_a.txt /tmp/r10buvm14_attr_b.txt | grep -c '^>' || true)
del=$(diff /tmp/r10buvm14_attr_a.txt /tmp/r10buvm14_attr_b.txt | grep -c '^<' || true)
echo "dump lines: pristine=$(wc -l < /tmp/r10buvm14_attr_a.txt) patched=$(wc -l < /tmp/r10buvm14_attr_b.txt)"
echo "diff sides: deletions=$del insertions=$ins"
echo "---- changed LINE KINDS (the token after the marker), with counts"
diff /tmp/r10buvm14_attr_a.txt /tmp/r10buvm14_attr_b.txt | grep -E '^[<>]' |
  sed -E 's/^([<>]) +//; s/^\\_//; s/^\|//; s/:.*//; s/ .*//' |
  sort | uniq -c | sort -rn
echo "---- SOURCE LINES touched (over the WHOLE diff, not the printed head)"
diff /tmp/r10buvm14_attr_a.txt /tmp/r10buvm14_attr_b.txt | grep -E '^[<>]' |
  grep -oE 'line:[0-9]+' | sort | uniq -c | sort -rn
echo "---- diff (first 60 lines)"
diff /tmp/r10buvm14_attr_a.txt /tmp/r10buvm14_attr_b.txt | head -60
