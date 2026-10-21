#!/bin/bash
# dd.sh <casedir> <tag>: path-normalized dump diff golden vs ours (tag output of run1.sh)
c=$(cd $1 && pwd); t=$2; DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
diff <($DUMP /tmp/r11u424_scr/gold/$h/slpp_all/surelog.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//; s|/[^ ]*/||' | grep -v '^design\|^Design') <($DUMP /tmp/r11u424_scr/out/$key/$t/ours.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//; s|/[^ ]*/||' | grep -v '^design\|^Design')
