#!/bin/bash
# ndiff.sh <golden.uhdm> <ours.uhdm> [tag]: path-normalized uhdm-dump diff
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no uhdm-dump"; exit 1; }
t=${3:-x}
$D $1 2>&1 | sed '1d; s|file:[^,]*/|file:|g' > /tmp/r11u431_scr/nd_${t}_g.txt
$D $2 2>&1 | sed '1d; s|file:[^,]*/|file:|g' > /tmp/r11u431_scr/nd_${t}_o.txt
diff /tmp/r11u431_scr/nd_${t}_g.txt /tmp/r11u431_scr/nd_${t}_o.txt
