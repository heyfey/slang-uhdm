#!/bin/bash
# v11u280 away.sh <pristine bin> <law bin> <case dir> <view>...: the chain-keyed away census
# (tools/probe/r11u272repro/drivers/awaychain.py over $SCX records) on one case dir per pair of
# arguments: golden, pristine and law databases.  Fail-closed on $FENCED; needs $SCX and $S.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "away.sh: FENCED unset" >&2; exit 2; }
[ -x "$SCX" ] && [ -n "$S" ] || { echo "away.sh: SCX/S unset" >&2; exit 2; }
P=$1; L=$2; shift 2; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
AW=$REPO/tools/probe/r11u272repro/drivers/awaychain.py
T=$S/away_$$; mkdir -p $T
while [ $# -ge 2 ]; do
  d=$(realpath $1); v=$2; shift 2
  rm -f $T/p.uhdm $T/l.uhdm
  KEEP=$T/p.uhdm $HERE/case.sh $d $P $v > /dev/null; KEEP=$T/l.uhdm $HERE/case.sh $d $L $v > /dev/null
  h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
  g=${V280_GOLD:-/tmp/v11u280_gold}/$h/g.uhdm
  echo "$(echo $d | sed 's#.*/tools/probe/##') $v $(python3 $AW $g $T/p.uhdm $T/l.uhdm | tr '\n' ' ' | cut -c1-600)"
done
rm -rf $T
