#!/bin/bash
# r10uvm44 — WHICH listing objects still take a DIRECT container reference.
# listdirect.sh counts; this prints the rows, ours and golden side by side, so
# the residue can be attributed to a KIND (a fan-in count cannot answer a WHO
# question, and a COUNT cannot answer a WHICH question either).
#   usage: ldrows.sh <tag> [test]
set -u
TAG=${1:?}
ONLY=${2:-}
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  [ -n "$ONLY" ] && [ "$ONLY" != "$T" ] && continue
  G=/tmp/r10uvm44_r10uvm42tw_g_$T.txt
  O=/tmp/r10uvm44_r10uvm42tw_${TAG}_$T.txt
  for W in g o; do
    F=$G; L=golden
    [ "$W" = o ] && { F=$O; L="ours($TAG)"; }
    [ -s "$F" ] || continue
    echo "=== $T $L"
    grep 'LISTED' "$F" | grep -P '\| [0-9]+x(array_typespec|constant)\b'
  done
done
