#!/bin/bash
# cdiff.sh <casedir> <tag> [n]: diff golden vs ours dump for a case run by run1.sh
c=$(cd $1 && pwd); t=$2; n=${3:-80}
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
gd=/tmp/r11u430_scr/gold/$h
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
o=/tmp/r11u430_scr/out/$key/$t
norm() { sed -E "s/\\bid:[0-9]+/id:_/g; s#file:[^ ,]*/#file:#g; s#^[^ ]*/([^/ ]*: Restored)#\\1#" ; }
$D $gd/slpp_all/surelog.uhdm 2>/dev/null | norm > $o/g.dump
$D $o/ours.uhdm 2>/dev/null | norm > $o/o.dump
diff $o/g.dump $o/o.dump | head -n $n
