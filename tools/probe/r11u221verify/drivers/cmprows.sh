#!/bin/bash
# cmprows.sh <sweep workdir> <corpus/mode/row>...: gate (5): uhdm-cmp line count of each named row-mode's database
# against the golden its cmds.txt names.  Refuses a fenced row (fail-closed on $FENCED, drivers/env.sh).
source "$(dirname "$0")/env.sh" || exit 2
W=$1; shift
for r in "$@"; do
  echo "$r" | grep -qP "$FENCE_RE" && { echo "$r fenced: refused"; continue; }
  d=$(ls -d $W/$r-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || { echo "$r no database"; continue; }
  g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  echo "$W $r uhdm-cmp lines=$($UHDM_CMP $g $d/slang.uhdm 2>&1 | wc -l)"
done
