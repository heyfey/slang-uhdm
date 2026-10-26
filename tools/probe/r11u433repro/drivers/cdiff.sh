#!/bin/bash
# cdiff.sh <casedir> <tag>: id-stripped, path-normalized uhdm-dump diff of a run1.sh output against its golden
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no uhdm-dump"; exit 1; }
c=$(cd $1 && pwd); t=$2
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
n(){ $D $1 2>/dev/null | sed '1d; s|file:[^,]*/|file:|g; s|vpiDefFile:.*|vpiDefFile|; s|, id:[0-9]*||g; s|id:[0-9]*||g'; }
diff <(n /tmp/r11u433_scr/gold/$h/slpp_all/surelog.uhdm) <(n /tmp/r11u433_scr/out/$key/$t/ours.uhdm)
