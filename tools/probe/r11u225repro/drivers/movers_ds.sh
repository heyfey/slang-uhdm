#!/bin/bash
# r11u225: the byte movers among the downstream slang lanes of two gate sweeps (fail-closed on $FENCED, word boundary).
# usage: movers_ds.sh <sweep wd A> <sweep wd B>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
A=$1; Bw=$2; n=0; sk=0; nd=0
for d in $Bw/downstream/*/; do t=$(basename $d)
  if echo "$t" | grep -Pq "$FENCE_RE"; then sk=$((sk+1)); continue; fi
  a=$A/downstream/$t/slang.uhdm; b=$d/slang.uhdm
  if [ ! -f $a ] && [ ! -f $b ]; then nd=$((nd+1)); continue; fi
  n=$((n+1)); cmp -s $a $b || echo "DMOVER downstream/$t"
done
echo "# downstream lanes compared $n (both sweeps wrote a database), no database in either $nd, fenced skipped unread $sk"
