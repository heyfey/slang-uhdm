#!/bin/bash
# dist.sh <casedir> <tag>: dump distance golden vs ours (diff lines of id-stripped, path-normalized dumps; unsorted and sorted)
c=$(cd $1 && pwd); t=$2; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
norm(){ $D $1 2>/dev/null | sed 's/, id:[0-9]*//; s|file:[^,]*/|file:|; s|\(vpi[A-Za-z]*File\):.*/|\1:|' | tail -n +2; }
g=/tmp/v11u440_scr/gold/$h/slpp_all/surelog.uhdm; o=/tmp/v11u440_scr/out/$key/$t/ours.uhdm
u=$(diff <(norm $g) <(norm $o) | grep -c '^[<>]'); s=$(diff <(norm $g | sort) <(norm $o | sort) | grep -c '^[<>]')
echo "$key $t unsorted=$u sorted=$s"
