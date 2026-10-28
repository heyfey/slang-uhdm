#!/bin/bash
D=/tmp/wt_r11u453/tools/probe/r11u453repro/drivers
c=$1
a=$($D/run1.sh $c /tmp/r11u453_bin/pristine p | cut -d' ' -f2-)
b=$($D/run1.sh $c /tmp/r11u453_bin/law14 l14 | cut -d' ' -f2-)
[ "${a##*md5=}" = "${b##*md5=}" ] && m=same || m=MOVED
echo "$c | $a | $b | $m"
