#!/usr/bin/env bash
# r10vbuvm29 — run every arm (mine AND the implementer's) three-way in BOTH
# views and print one line per arm-view plus a whole-dump pris-vs-pat delta.
set -u
PRI=${PRI:?}; PAT=${PAT:?}
VWD=${VWD:-/tmp/vbuvm29_arms}
for src in "$@"; do
  for m in def elab; do
    out=$(PRI=$PRI PAT=$PAT MODE=$m VWD=$VWD ./vthree29.sh "$src" 2>&1)
    b=$(basename "$src" .sv)
    w=$VWD/${b}_${m}
    echo "$out" | grep -E 'rc=|cmplines|NO-' | sed 's/^/  /'
    if [ -f "$w/PRI.dump" ] && [ -f "$w/PAT.dump" ]; then
      d=$(diff "$w/PRI.dump" "$w/PAT.dump" | grep -cE '^[<>]'; true)
      echo "  $b/$m DUMPDELTA_PRIS_PAT=$d"
      if [ -f "$w/G.dump" ]; then
        echo -n "  $b/$m "; python3 vnorm29.py "$w/G.dump" "$w/PRI.dump" "$w/PAT.dump"
      fi
    fi
  done
done
