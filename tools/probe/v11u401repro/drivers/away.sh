#!/bin/bash
# v11u401 away.sh <case> <view> [law env assignment]: chain-keyed away census golden/pristine/law of one case-view
H=$(cd "$(dirname "$0")" && pwd); source $H/env.sh; export R401_GOLD=/tmp/v11u401_gold R401_OUT=/tmp/v11u401_caseout
export SCX=$VB/strictcmp_x S=/tmp/v11u401_away; mkdir -p $S
c=$1; v=$2; t=$S/$(echo "$c$v$3$LAWBIN" | md5sum | cut -c1-12); rm -f $t.p $t.l
KEEP=$t.p bash $H/case.sh $H/../cases/$c $VB/slang-uhdm.pris $v >/dev/null
( [ -n "$3" ] && export $3; KEEP=$t.l bash $H/case.sh $H/../cases/$c ${LAWBIN:-$VB/slang-uhdm.law} $v >/dev/null )
h=$( (cd $H/../cases/$c && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
echo "$c $v $(python3 $H/awaychain.py $R401_GOLD/$h/g.uhdm $t.p $t.l)"
