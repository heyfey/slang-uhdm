#!/bin/bash
# dist.sh <case dir> <tag>: normalized dump diff line count golden vs ours
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no dump"; exit 2; }
c=$(cd $1 && pwd); h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
g=/tmp/v11u453_scr/gold/$h/slpp_all/surelog.uhdm; o=/tmp/v11u453_scr/out/$key/$2/ours.uhdm
diff <($D $g 2>/dev/null | sed 's/id:[0-9]*//g; s|/[^ ]*/||g') <($D $o 2>/dev/null | sed 's/id:[0-9]*//g; s|/[^ ]*/||g') | grep -c '^[<>]'
