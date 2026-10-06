#!/bin/bash
# v11u269 awaycorpchain.sh <wdA> <wdB> <moverlist> : the chain-keyed and flat away census (drivers/awaychain.py,
# raw-full-name records of $SCX) of corpus movers between two sweep workdirs (A = before, B = after), each mover a
# line `surelog/<mode>/<test>-<hash>`; the golden from A's cmds.txt. Fail-closed on $FENCED, refused before opening.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
export SCX=${SCX:-$B/strictcmp_x}; [ -x "$SCX" ] || { echo "awaycorpchain.sh: SCX not executable" >&2; exit 2; }
A=$1; Bw=$2; M=$3
while read -r p; do
  echo "$p" | grep -qwE "$FENCE_RE" && { echo "$p FENCED-REFUSED"; continue; }
  g=$(grep -o 'golden cache [a-z]* [^)]*' $A/$p/cmds.txt | awk '{print $4}')/golden.uhdm
  echo "$p $(python3 $D/awaychain.py $g $A/$p/slang.uhdm $Bw/$p/slang.uhdm | head -1)"
done < $M
