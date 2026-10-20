#!/bin/bash
# dist.sh <casedir> <tag>...: normalized dump diff lines vs golden for each tag
c=$(cd $1 && pwd); shift
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); g=/tmp/v11u420_scr/gold/$h/slpp_all/surelog.uhdm
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
norm(){ timeout 120 $D $1 2>/dev/null | sed 1d | sed 's/id:[0-9]*//g;s|/tmp/[^ ,]*/||g;s|/home/[^ ,]*/||g' ; }
norm $g > /tmp/v11u420_scr/out/$key/gold.dump
out="$key"
for t in "$@"; do norm /tmp/v11u420_scr/out/$key/$t/ours.uhdm > /tmp/v11u420_scr/out/$key/$t.dump
 n=$(diff /tmp/v11u420_scr/out/$key/gold.dump /tmp/v11u420_scr/out/$key/$t.dump | grep -c '^[<>]'); out="$out $t=$n"; done
echo $out
