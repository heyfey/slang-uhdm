#!/bin/bash
# v11u202: strict-record AWAY census of corpus movers. usage: awaycorp.sh <mirrorP> <mirrorX> <sweepdirP> <moverlist> <outdir>
source "$(dirname "$0")/env.sh" || exit 3
MP=$1; MX=$2; SP=$3; L=$4; O=$5; mkdir -p $O
while read -r p; do
  echo "$p" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
  g=$(grep -o 'golden cache [a-z]* [^)]*' $SP/$(dirname $p)/cmds.txt | awk '{print $4}'); gu=$(ls $g/*.uhdm 2>/dev/null | head -1)
  [ -z "$gu" ] && gu=$(find $g -name '*.uhdm' | head -1)
  t=$O/$(echo $p | tr '/' '_'); mkdir -p $t
  echo "$(dirname $p) $(python3 "$(dirname "$0")/away.py" $gu $MP/$p $MX/$p $t v > $t/away.txt; head -1 $t/away.txt)"
done < $L
