#!/bin/bash
# (r11u213) heads.sh <sweep workdir> <corpus> <mode> <row>...: the first strict records of a sweep row-mode
# (uhdm-strictcmp --max 3 on the golden named in the row's cmds.txt against the sweep's database).  Refuses a fenced
# row by word boundary (fail-closed on $FENCED, drivers/env.sh).
source "$(dirname "$0")/env.sh" || exit 2
W=$1; C=$2; M=$3; shift 3
for R in "$@"; do
  echo "$R" | grep -Pq "$FENCE_RE" && { echo "$R fenced: refused"; continue; }
  d=$(ls -d $W/$C/$M/$R-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || { echo "$C/$M/$R no database"; continue; }
  g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  echo "== $C/$M/$R"; $STRICT_CMP --max ${MAXR:-3} $g $d/slang.uhdm 2>&1 | grep -vE '^\s*$' | head -${HEADL:-14} | cut -c1-200 | sed 's/^/   /'
done
