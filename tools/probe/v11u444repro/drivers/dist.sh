#!/bin/bash
# dist.sh <casedir> <tag>: dump distance (diff line count of uhdm-dump golden vs ours, ids stripped)
c=$(cd $1 && pwd); t=$2
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
g=/tmp/v11u444_scr/gold/$h/slpp_all/surelog.uhdm; o=/tmp/v11u444_scr/out/$key/$t/ours.uhdm
[ -f $g ] && [ -f $o ] || { echo NA; exit; }
norm(){ $DUMP $1 2>/dev/null | sed 's/, id:[0-9]*//; s|file:[^,]*/|file:|; s|\(vpi[A-Za-z]*File\):.*/|\1:|' | tail -n +2; }
diff <(norm $g) <(norm $o) | grep -c '^[<>]'
