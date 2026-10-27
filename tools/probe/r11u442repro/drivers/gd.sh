#!/bin/bash
# gd.sh <casedir> [tag]: normalized dump of the cached golden (no tag) or of ours for <tag>
c=$(cd $1 && pwd); D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
if [ -z "$2" ]; then f=/tmp/r11u442_scr/gold/$h/slpp_all/surelog.uhdm; else f=/tmp/r11u442_scr/out/$key/$2/ours.uhdm; fi
$D $f 2>/dev/null | sed 's/, id:[0-9]*//; s|file:[^,]*/|file:|' | tail -n +2
