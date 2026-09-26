#!/bin/bash
# row.sh <corpus/mode/Row-hash dir rel> <sweepA> <sweepB>: strict first record, objects, divergence, order-blind record distance (fence fail-closed)
source /tmp/v11u176_env.sh || exit 2
R=$1; for f in $FENCED; do echo "$R" | grep -qw "$f" && { echo "fenced refused"; exit 3; }; done
G=$(grep -o 'golden cache hit [^)]*' $2/$R/cmds.txt | awk '{print $4}')/$(ls $(grep -o 'golden cache hit [^)]*' $2/$R/cmds.txt | awk '{print $4}') | grep uhdm | head -1)
for W in $2 $3; do
  T=/tmp/v11u176_scr/rows/$(echo $R | tr '/' '_').$(basename $W); mkdir -p $T
  $STRICT_CMP --max 3 --dump-a $T/a.rec --dump-b $T/b.rec $G $W/$R/slang.uhdm > $T/strict.txt 2>&1
  div=$(grep -o 'walk diverged' $T/strict.txt | head -1)
  first=$(grep -m1 '^#' $T/strict.txt)
  ob=$(comm -3 <(cut -f2- $T/a.rec | sort) <(cut -f2- $T/b.rec | sort) | wc -l)
  last=$(grep '^#' $T/strict.txt | tail -1)
  echo "$(basename $W): first=[$first] $(grep '^objects' $T/strict.txt) ob=$ob $(tail -1 $T/strict.txt)"
done
