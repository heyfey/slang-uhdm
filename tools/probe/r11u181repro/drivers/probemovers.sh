#!/bin/bash
# probemovers.sh <law sweep> <pristine sweep> <prediction file>: byte movers among the probe databases of two gate
# sweeps (same case set), each checked against the pristine prediction (predict181.sh).  Probe cases are not
# corpus tests (no fence applies), but the predictor list was fence-filtered anyway.
L=$1; P=$2; PR=$3
n=0; m=0; unp=0
for f in $(cd $P/probe && ls *.uhdm | grep -v golden); do
  n=$((n+1))
  if ! cmp -s $P/probe/$f $L/probe/$f; then
    m=$((m+1)); pr=$(grep "^probe/$f " $PR | awk '{print $2}')
    [ -z "$pr" -o "$pr" = "-" ] && { unp=$((unp+1)); pr="UNPREDICTED"; }
    echo "MOVER $f $pr"
  fi
done
echo "probe databases=$n movers=$m unpredicted=$unp predicted_total=$(grep '^probe/' $PR | awk '$2!="-"' | wc -l)"
