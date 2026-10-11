#!/bin/bash
# v11u286 awaygrid.sh <gridA.txt> <gridB.txt> <binA> <binB>: chain-keyed away census (drivers/awaychain.py, records of
# $SCX = strictcmp_x with the raw full name) on every case-view whose md5 differs between the two grid files
# (A = the reference binary, B = the candidate). Fail-closed on $FENCED through env.sh / case.sh / awaychain.py.
HERE=$(cd "$(dirname "$0")" && pwd); source "$HERE/env.sh" || exit 3
export S=${S:-/tmp/v11u286_s}
export SCX=${SCX:-$VB/strictcmp_x}; [ -x "$SCX" ] || { echo "awaygrid.sh: SCX" >&2; exit 2; }
A=$1; B=$2; PA=$3; PB=$4; T=/tmp/v11u286_away.$$; mkdir -p $T
paste -d'|' "$A" "$B" | awk -F'|' '{n=split($1,a," "); m=split($2,b," "); if (a[n]!=b[m]) print a[1], a[2]}' | while read -r c v; do
  d=$HERE/../$c; rm -f $T/p.uhdm $T/l.uhdm
  KEEP=$T/p.uhdm bash $HERE/case.sh $d $PA $v > /dev/null; KEEP=$T/l.uhdm bash $HERE/case.sh $d $PB $v > /dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  echo "$c $v $(python3 $HERE/awaychain.py ${V286_GOLD:-/tmp/v11u286_gold}/$h/g.uhdm $T/p.uhdm $T/l.uhdm | head -1)"
done
rm -rf $T
