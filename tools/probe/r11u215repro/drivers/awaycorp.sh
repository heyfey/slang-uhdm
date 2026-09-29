#!/bin/bash
# r11u215: order-blind AWAY-moved-record census of corpus movers (map 12's method, v11u202's away.py): for every mover
# listed as <corpus>/<mode>/<test-dir> relative to the sweep workdirs, the golden records present in the pristine
# database and absent from the law database (LOST) and the reverse (GAINED).  Fence fail-closed (env.sh).
# usage: awaycorp.sh <pristine sweep wd> <law sweep wd> <mover list> <outdir>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
P=$1; L=$2; M=$3; O=$4; mkdir -p $O
while read -r p; do
  t0=$(basename $p | sed 's/-[0-9a-f]*$//'); for f in $FENCED; do [ "$t0" = "$f" ] && { echo "$p FENCED refused"; continue 2; }; done
  g=$(grep -o 'golden cache [a-z]* [^)]*' $P/$p/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
  t=$O/$(echo $p | tr '/' '_'); mkdir -p $t
  echo "$p $(SCMP=$SCMP python3 $HERE/away.py $gu $P/$p/slang.uhdm $L/$p/slang.uhdm $t v > $t/away.txt; head -1 $t/away.txt)"
done < $M
