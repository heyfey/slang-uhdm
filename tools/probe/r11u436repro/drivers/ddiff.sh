#!/bin/bash
# ddiff.sh <casedir> <tag>: id-stripped dump diff golden vs ours output for the tag
c=$(cd $1 && pwd); t=$2; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
norm(){ $D $1 2>/dev/null | sed 's/, id:[0-9]*//; s|file:[^,]*/|file:|' | tail -n +2; }
diff <(norm /tmp/r11u436_scr/gold/$h/slpp_all/surelog.uhdm) <(norm /tmp/r11u436_scr/out/$key/$t/ours.uhdm)
