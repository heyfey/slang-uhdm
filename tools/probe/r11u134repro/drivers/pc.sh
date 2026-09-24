#!/bin/bash
# pc.sh <probe case rel path under tests/probe> <binA> <binB>  -> field tallies
d=/tmp/wt_r11u134/tests/probe/$1
source /tmp/r11u134_env.sh
for b in $2 $3; do /tmp/r11u134_scr/case.sh $d /tmp/r11u134_bin/$b $b >/dev/null; done
w=/tmp/r11u134_cases/$(echo "$(realpath $d)" | md5sum | cut -c1-12)
for b in $2 $3; do echo "$b: $($STRICT_CMP --max 0 $w/golden.uhdm $w/$b.uhdm | grep -E 'fields|STRICT' | tr '\n' ' ')"; done
echo "$w"
