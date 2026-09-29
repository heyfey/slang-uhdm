#!/bin/bash
# r11u225: the byte movers between two gate sweeps (corpus databases and probe databases), fail-closed on $FENCED:
# a corpus row-mode directory whose name holds a fenced name is skipped unread (counted).
# usage: movers.sh <sweep wd A> <sweep wd B>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
A=$1; Bw=$2; sk=0; n=0
for c in surelog uhdm2rtlil; do for d in $Bw/$c/*/*/; do rel=${d#$Bw/}
  if echo "$rel" | grep -Pq "$FENCE_RE"; then sk=$((sk+1)); continue; fi
  n=$((n+1)); a=$A/$rel/slang.uhdm; b=$d/slang.uhdm
  if [ -f $a ] || [ -f $b ]; then cmp -s $a $b || echo "MOVER $rel"; fi
done; done
np=0; for f in $Bw/probe/*.uhdm; do np=$((np+1)); cmp -s $f $A/probe/$(basename $f) || echo "PMOVER $(basename $f .uhdm | sed 's#__#/#g')"; done
echo "# corpus row-mode dirs compared $n, fenced skipped unread $sk, probe databases $np"
