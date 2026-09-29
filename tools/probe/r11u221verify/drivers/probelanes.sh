#!/bin/bash
# probelanes.sh <sweep A> <sweep B>: byte movers between two gate sweeps over the probe databases (<wd>/probe/*.uhdm, the
# tests/probe cases: no corpus source) and the downstream slang-lane databases (<wd>/downstream/<test>/slang.uhdm; a
# path naming a fenced test is dropped before it is opened: fail-closed on $FENCED from drivers/env.sh).  Path sets are
# asserted equal; prints MOVER lines and counts.
source "$(dirname "$0")/env.sh" || exit 2
A=$1; B=$2
for k in probe downstream; do
  if [ $k = probe ]; then la=$(cd $A/probe && ls *.uhdm | sort); lb=$(cd $B/probe && ls *.uhdm | sort)
  else la=$(cd $A/downstream && ls -d */ | tr -d / | grep -vP "$FENCE_RE" | sort); lb=$(cd $B/downstream && ls -d */ | tr -d / | grep -vP "$FENCE_RE" | sort); fi
  [ "$la" = "$lb" ] || { echo "$k PATH_SETS_DIFFER"; continue; }
  n=0; m=0
  for p in $la; do
    if [ $k = probe ]; then fa=$A/probe/$p; fb=$B/probe/$p; else fa=$A/downstream/$p/slang.uhdm; fb=$B/downstream/$p/slang.uhdm; fi
    [ -f $fa ] || [ -f $fb ] || continue
    n=$((n+1)); cmp -s $fa $fb 2>/dev/null || { echo "MOVER $k $p"; m=$((m+1)); }
  done
  echo "$k: compared=$n movers=$m"
done
