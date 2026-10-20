#!/bin/bash
# dir.sh <casedir> [tagA tagB]: multiset distance (comm -3 over sorted, id/path-stripped dumps) golden vs tagA and tagB outputs
source /tmp/v11u418_env.sh
c=$(cd $1 && pwd); A=${2:-p}; B=${3:-l}
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); k=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
G=/tmp/v11u418_scr/gold/$h/slpp_all/surelog.uhdm
norm(){ $UHDM_DUMP $1 2>/dev/null | sed 1d | sed 's/id:[0-9]*//g;s|file:[^ ,]*||g;s|/tmp/[^ ,]*/||g' | LC_ALL=C sort; }
g=$(mktemp); norm $G > $g
da=$(LC_ALL=C comm -3 $g <(norm /tmp/v11u418_scr/out/$k/$A/ours.uhdm) | wc -l)
db=$(LC_ALL=C comm -3 $g <(norm /tmp/v11u418_scr/out/$k/$B/ours.uhdm) | wc -l)
rm -f $g; v=same; [ $db -lt $da ] && v=toward; [ $db -gt $da ] && v=AWAY
echo "$k $A=$da $B=$db $v"
