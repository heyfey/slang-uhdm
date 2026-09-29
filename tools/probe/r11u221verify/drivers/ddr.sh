#!/bin/bash
# ddr.sh <case-view under $GW> <tagA> <tagB> [full]: (r11u221) the id-stripped uhdm-dump diff of two databases of one case
# view of this directory's grid (tag `gold` = the case's golden), cut at the unreachable `\_weaklyReferenced` tail unless
# a fourth argument is given.  Reads only this directory's grid outputs (fail-closed on $FENCED all the same).
source "$(dirname "$0")/env.sh" || exit 2
GW=${GW:-/tmp/r11u221_g}; w=$GW/$1; a=$2; b=$3; T=/tmp/r11u221_ddr; mkdir -p $T
echo "$w" | grep -qP "$FENCE_RE" && { echo "fenced refused"; exit 2; }
f() { if [ $1 = gold ]; then ls $w/gold_*/golden.uhdm; else echo $w/$1.uhdm; fi; }
$UHDM_DUMP $(f $a) 2>&1 | sed 's/, id:[0-9]*//; s/id:[0-9]*//' | grep -v 'Restored design' > $T/A.txt
$UHDM_DUMP $(f $b) 2>&1 | sed 's/, id:[0-9]*//; s/id:[0-9]*//' | grep -v 'Restored design' > $T/B.txt
[ -z "$4" ] && sed -i '/^\\_weaklyReferenced/,$d' $T/A.txt $T/B.txt
diff $T/A.txt $T/B.txt
