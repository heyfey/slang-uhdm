#!/bin/bash
# dist2.sh <casedir> <tag...>: dump distance golden vs run1 outputs
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo nodump; exit 1; }
c=$1; shift
k=${c#/tmp/wt_v11u424/tools/probe/}
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); g=/tmp/v11u424_scr/gold/$h/slpp_all/surelog.uhdm
W=/tmp/v11u424_scr/dd_$$; mkdir -p $W
nd(){ timeout 600 $D $1 2>/dev/null | grep -v -E '^(design: |Instance tree|=====|DESIGN|\|uhdmall|\|uhdmtop)' | sed -E 's|/[^ ,]*/||g' | grep -v 'Restored design'; }
nd $g > $W/g.txt
out="$k"
for t in "$@"; do nd /tmp/v11u424_scr/out/$key/$t/ours.uhdm > $W/$t.txt
  seq=$(diff $W/g.txt $W/$t.txt | grep -c '^[<>]')
  ms=$(python3 -c "
import collections
a=collections.Counter(open('$W/g.txt').read().split('\n'));b=collections.Counter(open('$W/$t.txt').read().split('\n'))
print(sum(((a-b)+(b-a)).values()))")
  out="$out $t:seq=$seq,ms=$ms"; done
echo $out; rm -rf $W
