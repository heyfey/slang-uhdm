#!/bin/bash
# judge.sh <case dir> : the case against its pinned-Surelog golden with the pristine and the final binary (case.sh),
# plus the law tags the final binary fires (R11U171_TRACE); one line.
set -u; c=$1; D=$(dirname $(readlink -f $0))
p=$(TAG=jp OUT=/tmp/r11u171_scr/judge bash $D/case.sh $c /tmp/r11u171_bin/pris.bin | cut -d' ' -f2-)
f=$(TAG=jf OUT=/tmp/r11u171_scr/judge bash $D/case.sh $c /tmp/r11u171_bin/final.bin | cut -d' ' -f2-)
tags=$(cd $c && R11U171_TRACE=1 /tmp/r11u171_bin/final.bin dut.sv --single-unit --nobuiltin -o /tmp/r11u171_scr/judge/t.$$.uhdm 2>&1 >/dev/null </dev/null | grep -o '^R11U171 [A-Z]*' | sort -u | awk '{printf "%s ", $2}'; rm -f /tmp/r11u171_scr/judge/t.$$.uhdm)
echo "$c | P: $p | F: $f | tags: $tags"
