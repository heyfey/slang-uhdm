#!/bin/bash
# heads.sh <sweep wd> <row>...: first strict records of the named surelog rows (both modes), golden from the row's
# cmds.txt. Refuses a fenced row (fail-closed on $FENCED); reads only the named rows' directories.
[ "$(echo $FENCED | wc -w)" = 4 ] && [ -x "$STRICT_CMP" ] || { echo "heads.sh: source drivers/env.sh" >&2; exit 2; }
W=$1; shift
for r in "$@"; do
  for f in $FENCED; do [ "$f" = "$r" ] && { echo "heads.sh: fenced row refused" >&2; exit 2; }; done
  for m in default testflags; do
    d=$(ls -d $W/surelog/$m/$r-*/ 2>/dev/null | head -1); [ -n "$d" ] && [ -s $d/slang.uhdm ] || { echo "$r/$m no database"; continue; }
    g=$(grep -oE 'golden cache hit \S+\)' $d/cmds.txt | head -1 | sed 's/golden cache hit //; s/)$//')/golden.uhdm
    [ -s "$g" ] || g=$(grep -oE '/\S*slang-uhdm-goldens/[0-9a-f]+' $d/cmds.txt | head -1)/golden.uhdm
    echo "== $r/$m"; $STRICT_CMP --max 2 $g $d/slang.uhdm | grep -A2 '^#' | head -3; $STRICT_CMP --max 1 $g $d/slang.uhdm | grep objects
  done
done
