#!/bin/bash
# dist.sh <casedir> <tag>: sorted path-normalized dump distance (diff lines) of run1 output vs golden
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 1
c=$(cd $1 && pwd); t=$2
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
n(){ $D $1 2>/dev/null | sed '1d; s|file:[^,]*/|file:|g; s|vpiDefFile:.*|vpiDefFile|; s|id:[0-9]*||g' | sort; }
diff <(n /tmp/v11u431_scr/gold/$h/slpp_all/surelog.uhdm) <(n /tmp/v11u431_scr/out/$key/$t/ours.uhdm) | grep -c '^[<>]'
