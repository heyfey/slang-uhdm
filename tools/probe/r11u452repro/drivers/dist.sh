#!/bin/bash
# dist.sh <golden.uhdm> <ours.uhdm>: dump distance (changed lines of the path-normalized uhdm-dump diff)
[ -x "$UHDM_DUMP" ] || { echo "no UHDM_DUMP"; exit 2; }
n(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's#file:[^,]*,##; s#/[^ ,)]*/##g'; }
diff <(n $1) <(n $2) | grep -c '^[<>]'
