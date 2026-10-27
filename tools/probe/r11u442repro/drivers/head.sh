#!/bin/bash
# head.sh <casedir> <tag> [skip] [up]: uhdm-cmp's failing pair (golden, ours) via cmphead
c=$(cd $1 && pwd) || exit 1; t=$2
H=/tmp/r11u442_tools/cmphead; [ -x $H ] || { echo "no cmphead"; exit 1; }
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
$H /tmp/r11u442_scr/gold/$h/slpp_all/surelog.uhdm /tmp/r11u442_scr/out/$key/$t/ours.uhdm ${3:-0} ${4:-0}
