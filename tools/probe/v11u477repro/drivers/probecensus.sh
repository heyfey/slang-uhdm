#!/bin/bash
# probecensus.sh <dirA> <dirB> <out>: per probe db, cmp bytes, else compare path-normalized uhdm-dump
source /tmp/v11u477_env.sh; [ -x "$UHDM_DUMP" ] || exit 1
A=$1; B=$2; O=$3; : > $O
for f in $(cd $A && ls *.uhdm); do
  if cmp -s $A/$f $B/$f; then echo "$f BYTES_SAME" >> $O; continue; fi
  if diff -q <($UHDM_DUMP $A/$f 2>/dev/null | sed -E '1d; s#/tmp/wt_v11u477/#REPO/#g; s#/home/heyfey/git-repos/slang-uhdm/#REPO/#g') <($UHDM_DUMP $B/$f 2>/dev/null | sed -E '1d; s#/tmp/wt_v11u477/#REPO/#g; s#/home/heyfey/git-repos/slang-uhdm/#REPO/#g') >/dev/null; then echo "$f DUMP_SAME" >> $O; else echo "$f DUMP_DIFF" >> $O; fi
done
# negative control: first db vs a different db
f1=$(cd $A && ls *.uhdm | head -1); f2=$(cd $A && ls *.uhdm | sed -n 2p)
diff -q <($UHDM_DUMP $A/$f1 2>/dev/null | sed '1d') <($UHDM_DUMP $B/$f2 2>/dev/null | sed '1d') >/dev/null && echo "NEGCTL SAME(bad)" >> $O || echo "NEGCTL DIFF(ok)" >> $O
