#!/bin/bash
# usage: rowrun.sh <golden key> <row dir> <binname>  (runs the row's control slang line with /tmp/r11u447_bin/<binname> and XPERIMENT447_ADMIT=1)
key=${1:?}; dir=${2:?}; b=${3:?}
out=/tmp/r11u447_sv0/work/$dir/$b.uhdm
rm -f "$out"
cmd=$(sed -n 2p /tmp/r11u447_sv0/work/$dir/cmds.txt | sed "s/^slang: *//; s#/tmp/r11u447_bin/pristine#/tmp/r11u447_bin/$b#; s#-o [^ ]*slang.uhdm#-o $out#")
rc=$(cd /tmp/r11u447_sv0/work/$dir && XPERIMENT447_ADMIT=1 eval "$cmd" > $b.log 2>&1; echo $?)
echo "$dir $b rc=$rc $(/tmp/r11u447_bin/uhdm-strictcmp /home/heyfey/.cache/slang-uhdm-goldens/0445655ee703/$key/golden.uhdm $out 2>&1 | tail -1)"
