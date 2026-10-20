#!/bin/bash
# away.sh <casedir>: line-multiset distance to golden (uhdm-dump, sorted, diff lines) for the p and l
# outputs, plus the strictcmp first field and differing-object count for each.
c=$(cd $1 && pwd)
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12); g=/tmp/v11u416_scr/gold/$h/slpp_all/surelog.uhdm
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g'); O=/tmp/v11u416_scr/out/$key
norm(){ $DUMP $1 2>/dev/null | sed 's/, id:[0-9]*//; s/^[ |]*//' | grep -v -e 'design: (unnamed)' | sort; }
norm $g > /tmp/v11u416_scr/a_g.txt
out="$key"
for t in p l; do
  [ -s $O/$t/ours.uhdm ] || { out="$out | $t NOUHDM"; continue; }
  norm $O/$t/ours.uhdm > /tmp/v11u416_scr/a_$t.txt
  d=$(diff /tmp/v11u416_scr/a_g.txt /tmp/v11u416_scr/a_$t.txt | grep -c '^[<>]')
  s=$($SC --no-canon $g $O/$t/ours.uhdm 2>&1 | tail -1)
  out="$out | $t dist=$d [$s]"
done
echo "$out"
