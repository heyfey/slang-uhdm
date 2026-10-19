#!/bin/bash
# ddiff.sh <casedir> <tag>: normalized dump diff golden vs ours
c=$1; t=$2
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
G=/tmp/r11u412_scr/gold/$(cat $(ls -d $c/* | grep -v '/out_' | sort) | md5sum | cut -c1-12)/slpp_all/surelog.uhdm
norm(){ sed -E 's/, id:[0-9]+//; s#file:[^,]*/##; s#[^ ]*/dut\.sv#dut.sv#g'; }
$D $G 2>/dev/null | norm > $c/out_$t/g.txt
$D $c/out_$t/ours.uhdm 2>/dev/null | norm > $c/out_$t/s.txt
diff $c/out_$t/g.txt $c/out_$t/s.txt
