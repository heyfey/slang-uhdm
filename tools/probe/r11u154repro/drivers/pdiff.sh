#!/bin/bash
# pdiff.sh <rel> <wdA> <wdB> [max]: strict first records of a probe case in two sweep workdirs
source /tmp/r11u154_env.sh
rel=$1; g=$(cd /tmp/wt_r11u154 && python3 tools/probe/r11u154repro/drivers/pgold.py $rel)
f=$(echo $rel | sed 's#/#__#g').uhdm
for w in $2 $3; do echo "-- $w"; /tmp/r11u154_bin/strictcmp --max ${4:-3} $g $w/probe/$f 2>&1 | paste - - - | sed 's/\t\t*/ /g' | cut -c1-240; done
