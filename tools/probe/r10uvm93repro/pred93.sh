#!/usr/bin/env bash
# r10uvm93 mover PREDICTION — from the PRISTINE databases only (no patched
# binary involved).  For every candidate row, count the constants whose
# vpiDecompile is a built-in integral TYPE KEYWORD (the shape this pass
# rewrites) and the ones whose decompile is any other bare identifier reached
# through a streaming slice.  A row with 0 such cells CANNOT move.
set -u
CTL=${CTL:?control workdir}
LIST=${LIST:?file of <mode>/<row-dir> lines}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
while read -r r; do
  f="$CTL/$r/slang.uhdm"
  [ -f "$f" ] || { echo "SKIP-NOFILE $r"; continue; }
  n=$("$DUMP" "$f" 2>/dev/null | grep -cE '^ *\|vpiDecompile:(byte|shortint|int|longint|integer|time|bit|logic|reg|realtime|real|shortreal)$'; true)
  echo "$n $r"
done < "$LIST"
