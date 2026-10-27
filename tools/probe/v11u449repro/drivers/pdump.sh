#!/bin/bash
# pdump.sh <name>: path-normalized dump equality of one probe database, law sweep vs the master's control
[ -x "$UHDM_DUMP" ] || { echo "NOTOOL $1"; exit 2; }
n(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's#file:[^,]*,##g; s#/[^ ,)]*/##g'; }
cmp -s <(n /tmp/v11u449_swl/probe/$1) <(n /tmp/intr11u446/probe/$1) || echo "MOVER $1"
