#!/bin/bash
# v11u284 away.sh <gsum output> <pristine bin> <law bin> [cases root]: the chain-keyed away census
# (tools/probe/r11u272repro/drivers/awaychain.py with $SCX = strictcmp_x) on every MOVE line: golden, pristine and
# law databases of the case-view.  Fail-closed on $FENCED; record cache under $S.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "away.sh: FENCED unset" >&2; exit 2; }
[ -x "$SCX" ] && [ -n "$S" ] || { echo "away.sh: SCX/S unset" >&2; exit 2; }
G=$1; P=$2; L=$3; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd); CR=${4:-$HERE/../cases}
AW=$REPO/tools/probe/r11u272repro/drivers/awaychain.py
T=$S/away.$$; mkdir -p $T
grep '^MOVE' $G | while read -r _ c v _; do
  d=$CR/$c
  rm -f $T/p.uhdm $T/l.uhdm
  KEEP=$T/p.uhdm bash $HERE/case.sh $d $P $v > /dev/null; KEEP=$T/l.uhdm bash $HERE/case.sh $d $L $v > /dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  g=${V284_GOLD:-/tmp/v11u284_gold}/$h/g.uhdm
  echo "$c $v $(python3 $AW $g $T/p.uhdm $T/l.uhdm | tr '\n' ' ' | cut -c1-600)"
done
rm -rf $T
