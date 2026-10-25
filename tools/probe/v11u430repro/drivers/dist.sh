#!/bin/bash
# dist.sh <casedir> <tag>...: normalized uhdm-dump diff line count (golden vs ours) for each run tag of run1.sh
c=$(cd $1 && pwd); shift
DU=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$DU" ] || exit 2
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); gd=/tmp/v11u430_scr/gold/$h
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
norm() { sed -E "s/\\bid:[0-9]+/id:_/g; s#file:[^ ,]*/#file:#g; s#^[^ ]*/([^/ ]*: Restored)#\\1#" ; }
$DU $gd/slpp_all/surelog.uhdm 2>/dev/null | norm > /tmp/v11u430_scr/g_$key.dump
out="$key"
for t in "$@"; do o=/tmp/v11u430_scr/out/$key/$t
  $DU $o/ours.uhdm 2>/dev/null | norm > $o/o.dump
  out="$out $t=$(diff /tmp/v11u430_scr/g_$key.dump $o/o.dump | grep -c '^[<>]')"; done
echo $out
