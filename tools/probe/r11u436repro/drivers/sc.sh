#!/bin/bash
# sc.sh <casedir> <tag> [max]: uhdm-strictcmp of golden vs ours output for the tag
c=$(cd $1 && pwd); t=$2
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
/tmp/wt_r11u436/build/uhdm-strictcmp --max ${3:-6} /tmp/r11u436_scr/gold/$h/slpp_all/surelog.uhdm /tmp/r11u436_scr/out/$key/$t/ours.uhdm 2>&1
