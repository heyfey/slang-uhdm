#!/usr/bin/env bash
# r10uvm98 — run pred98 over a whole verify_golden workdir of OUR PRISTINE
# databases and name every (mode, test) that CAN move.  MEASUREMENT ONLY.
#   ./predict98.sh <workdir>
set -u
WD=${1:?workdir}
PRED=${PRED:-/tmp/r10uvm98_pred98}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
n=0; hit=0
for d in "$WD"/*/*/; do
  O="$d/slang.uhdm"; [ -f "$O" ] || continue
  n=$((n+1))
  c=$("$PRED" "$O" 2>/dev/null | sed -n 's/^CANMOVE //p')
  [ -z "$c" ] && c=0
  if [ "$c" != 0 ]; then
    hit=$((hit+1))
    echo "CANMOVE $c  $(basename "$(dirname "$d")")/$(basename "$d")"
  fi
done
echo "PREDICT: $hit / $n databases can move"
