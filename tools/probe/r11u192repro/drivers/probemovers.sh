#!/bin/bash
# probemovers.sh <swA> <swB>: the probe databases (probe/<case>.uhdm) that differ between two gate sweeps, fence-refusing
# (a case path naming a fenced test is skipped and counted), with the path-set assertion.
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
A=$1; B=$2
la=$(cd $A/probe && ls *.uhdm | sort); lb=$(cd $B/probe && ls *.uhdm | sort)
[ "$la" = "$lb" ] || { echo "PATH_SETS_DIFFER"; exit 4; }
n=0; m=0; s=0
for p in $la; do
  if echo "$p" | grep -qP "$FENCED_RE"; then s=$((s+1)); continue; fi
  n=$((n+1)); cmp -s $A/probe/$p $B/probe/$p || { m=$((m+1)); echo "MOVER ${p%.uhdm}"; }
done
echo "probe databases=$n movers=$m fenced_skipped=$s"
