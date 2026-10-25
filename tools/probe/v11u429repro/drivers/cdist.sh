#!/bin/bash
# cdist.sh <casedir> <tagA> <tagB>: order-blind sorted uhdm-dump distance to golden (paths and ids normalized)
UD=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$UD" ] || { echo no-dump; exit 1; }
c=$(cd $1 && pwd); h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); O=/tmp/v11u429_scr/out/$key
T=$(mktemp -d /tmp/v11u429_scr/dd.XXXX)
norm(){ $UD $1 2>/dev/null | tail -n +2 | sed -E 's#/[^ ,]*/([^/ ,]+\.(sv|v|svh|vh))#\1#g; s#, id:[0-9]+##g' | sort; }
norm /tmp/v11u429_scr/gold/$h/slpp_all/surelog.uhdm > $T/g; norm $O/$2/ours.uhdm > $T/a; norm $O/$3/ours.uhdm > $T/b
a=$(diff $T/g $T/a | grep -c '^[<>]'); b=$(diff $T/g $T/b | grep -c '^[<>]'); ab=$(diff $T/a $T/b | grep -c '^[<>]')
v=SAME; [ $b -lt $a ] && v=TOWARD; [ $b -gt $a ] && v=AWAY
echo "$key $2=$a $3=$b moved=$ab $v"; rm -rf $T
