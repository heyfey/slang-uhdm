#!/bin/bash
# ddist.sh <casedir> <name>... : path-normalized dump distance to golden (u=unsorted, s=sorted)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; [ -x $D ] || { echo no dump; exit 2; }
d=$(readlink -f $1); shift
norm(){ $D $1 2>/dev/null | sed 1d | sed "s#$d/##g; s#, id:[0-9]*##g" ; }
[ -s $d/golden/slpp_all/surelog.uhdm ] || { echo "$(basename $(dirname $d))/$(basename $d) nogolden"; exit 0; }
norm $d/golden/slpp_all/surelog.uhdm > $d/gdump.txt
out="$(basename $(dirname $d))/$(basename $d)"
for n in "$@"; do norm $d/out_$n.uhdm > $d/dump_$n.txt; u=$(diff $d/gdump.txt $d/dump_$n.txt | grep -c '^[<>]'); s=$(diff <(sort $d/gdump.txt) <(sort $d/dump_$n.txt) | grep -c '^[<>]'); out="$out $n:u=$u,s=$s"; done
echo "$out"
