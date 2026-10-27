#!/bin/bash
# cmp.sh <casedir> <tag>: uhdm-cmp of golden vs ours output for the tag
c=$(cd $1 && pwd); t=$2
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp /tmp/v11u442_scr/gold/$h/slpp_all/surelog.uhdm /tmp/v11u442_scr/out/$key/$t/ours.uhdm 2>&1
