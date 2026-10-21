#!/bin/bash
# dist.sh <casedir> <tag>...: sorted-line dump distance golden vs each tag's output (run1.sh outputs)
c=$(cd $1 && pwd); shift
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 2
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); gd=/tmp/v11u428_scr/gold/$h
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
norm() { sed -E "s/\\bid:[0-9]+/id:_/g; s#file:[^ ,]*/#file:#g; s#^[^ ]*/([^/ ]*: Restored)#\\1#" ; }
$D $gd/slpp_all/surelog.uhdm 2>/dev/null | norm | sort > /tmp/v11u428_scr/g_$key.sorted
out="$(basename $(dirname $c))/$(basename $c)"
for t in "$@"; do o=/tmp/v11u428_scr/out/$key/$t
  $D $o/ours.uhdm 2>/dev/null | norm > $o/o.dump; sort $o/o.dump > $o/o.sorted
  n=$(comm -3 /tmp/v11u428_scr/g_$key.sorted $o/o.sorted | wc -l); out="$out $t=$n"; done
echo "$out"
