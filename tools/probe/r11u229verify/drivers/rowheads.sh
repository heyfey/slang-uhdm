#!/bin/bash
# r11u229: rowheads.sh <sweep wd> <row>...: the first strict record(s) of each row-mode of a gate sweep (uhdm-strictcmp
# --max 2 on the golden named in cmds.txt against slang.uhdm).  A fenced row is refused unread.
source "$(dirname "$0")/env.sh" || exit 2
W=$1; shift
for t in "$@"; do
  echo "$t" | grep -Eqw "$(echo $FENCED | tr ' ' '|')" && { echo "$t fenced refused"; continue; }
  for c in surelog uhdm2rtlil; do for m in default testflags; do
    d=$(ls -d $W/$c/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] && [ -s $d/slang.uhdm ] || continue
    g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | head -1 | awk '{print $4}')/golden.uhdm
    [ -s "$g" ] || g=$(grep -o '/[^ ]*slang-uhdm-goldens/[0-9a-f]*' $d/cmds.txt | head -1)/golden.uhdm
    echo "== $c $m $t"; "$STRICT_CMP" --max 2 "$g" $d/slang.uhdm 2>&1 | grep -A2 '^#' | head -6; "$STRICT_CMP" --max 1 "$g" $d/slang.uhdm 2>&1 | tail -1
  done; done
done
