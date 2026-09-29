#!/bin/bash
# lanebytes2.sh <lane dir>... : for a downstream lane (<wd>/downstream/<test> or a dscase work dir), byte comparison of
# the Surelog lane's and the slang lane's RTLIL / netlist (surelog/<t>{_nohier.il,.il,_synth.v} vs slanguh/...), the
# raw bytes and the harness's own same() (scripts/downstream_uhdm2rtlil.py).  Fail-closed on $FENCED.
source "$(dirname "$0")/env.sh" || exit 2
for W in "$@"; do
  echo "$W" | grep -qP "$FENCE_RE" && { echo "fenced refused"; continue; }
  t=$(basename $W)
  for s in _nohier.il .il _synth.v; do
    a=$W/surelog/$t$s; b=$W/slanguh/$t$s
    raw=$(cmp -s $a $b && echo BYTES_IDENTICAL || echo BYTES_DIFFER)
    k=$(case $s in _nohier.il) echo nohier;; .il) echo il;; *) echo synth;; esac)
    h=$(cd $R221_ROOT/scripts && python3 -c "import downstream_uhdm2rtlil as d; print('same' if d.same('$a','$b','$k') else 'NOT_SAME')" 2>/dev/null)
    echo "$W $t$s $raw harness:$h"
  done
done
