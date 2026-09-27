#!/bin/bash
# probemovers.sh <probe-wd-A> <probe-wd-B>: path-normalised dump comparison of every probe database (tests/probe
# cases only; no corpus source or database is read). Prints MOVER <case> and a count.
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
A=$1; B=$2; n=0; m=0
for f in $(cd $A && ls *.uhdm); do
  n=$((n+1))
  a=$($UHDM_DUMP $A/$f 2>/dev/null | sed -e '1d' -e 's#/tmp/wt_v11u184[a-z]*/#W/#g' | md5sum)
  b=$($UHDM_DUMP $B/$f 2>/dev/null | sed -e '1d' -e 's#/tmp/wt_v11u184[a-z]*/#W/#g' | md5sum)
  [ "$a" = "$b" ] || { m=$((m+1)); echo "MOVER $f"; }
done
echo "probe movers=$m of $n"
