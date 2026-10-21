#!/bin/bash
# dd.sh <casedir> <tag>: path-normalized dump diff golden vs ours (output of run1.sh under that tag)
c=$(cd $1 && pwd); t=$2; DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$DUMP" ] || { echo "MISSING $DUMP"; exit 9; }
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
diff <($DUMP /tmp/v11u426_scr/gold/$h/slpp_all/surelog.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//; s|/[^ ]*/||' | grep -v '^design\|^Design') <($DUMP /tmp/v11u426_scr/out/$key/$t/ours.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//; s|/[^ ]*/||' | grep -v '^design\|^Design')
