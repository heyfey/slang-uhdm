#!/bin/bash
# head.sh <casedir> <tag>: the uhdm-cmp head (first 40 lines) of a case's run1.sh output against its golden
c=$(cd $1 && pwd); t=$2
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
[ -x "$CMP" ] || { echo "no uhdm-cmp"; exit 1; }
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
$CMP /tmp/r11u433_scr/gold/$h/slpp_all/surelog.uhdm /tmp/r11u433_scr/out/$key/$t/ours.uhdm 2>&1 | head -${3:-40}
