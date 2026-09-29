#!/bin/bash
# r11u219: the downstream lanes whose slang database moved between two downstream sweeps, and whether their RTLIL
# (every *.il of the slang lane) is byte-identical. Fail-closed on $FENCED (a lane naming a fenced test is skipped
# unread). usage: dslanes.sh <sweep wd A> <sweep wd B>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
A=$1; Bw=$2; n=0; sk=0; mv=0
for d in $Bw/downstream/*/; do t=$(basename $d)
  if echo "$t" | grep -Pq "$FENCE_RE"; then sk=$((sk+1)); continue; fi
  n=$((n+1)); a=$A/downstream/$t/slang.uhdm; b=$d/slang.uhdm
  [ -f $a ] || [ -f $b ] || continue
  if ! cmp -s $a $b; then mv=$((mv+1)); il="il-identical"
    for f in $(cd $d && find . -name '*.il' | sort); do cmp -s $A/downstream/$t/$f $d/$f || il="il-DIFFER($f)"; done
    echo "LANE_MOVED $t $il"; fi
done
echo "# lanes compared $n, fenced skipped unread $sk, slang databases moved $mv"
