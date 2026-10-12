#!/bin/bash
# v11u298 away1.sh <case dir> <view> <binA> <binB> [ENV=1 for B]: chain-keyed away census of B against A on one
# case-view (golden from case.sh's cache). Fail-closed on $FENCED (case.sh, awaychain.py).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "away1.sh: FENCED unset" >&2; exit 2; }
[ -x "$SCX" ] || { echo "away1.sh: SCX unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); d=$(realpath $1); v=$2; A=$3; B=$4; E=$5
T=$(mktemp -d /tmp/v11u298_aw.XXXXXX)
KEEP=$T/p.uhdm bash $H/case.sh $d $A $v > /dev/null
if [ -n "$E" ]; then env $E KEEP=$T/l.uhdm bash $H/case.sh $d $B $v > /dev/null; else KEEP=$T/l.uhdm bash $H/case.sh $d $B $v > /dev/null; fi
h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
echo "$(basename $d) $v $(python3 $H/awaychain.py ${R298_GOLD:-/tmp/v11u298_gold}/$h/g.uhdm $T/p.uhdm $T/l.uhdm | head -1)"
rm -rf $T
