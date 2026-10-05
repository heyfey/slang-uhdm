#!/bin/bash
# (r11u243) heads.sh <verify_golden workdir> <name> [...]: per row-mode the strict comparator's first differing record
# (golden from the row's own cmds.txt) and the objects line. Fail-closed on $FENCED; a fenced name is refused.
[ -n "$FENCED" ] && [ -x "$STRICT_CMP" ] || { echo "heads.sh: source drivers/env.sh" >&2; exit 2; }
WD=$1; shift
for n in "$@"; do
  for f in $FENCED; do [ "$f" = "$n" ] && { echo "heads.sh: fenced name refused" >&2; exit 2; }; done
  for m in default testflags; do for d in $WD/$m/$n-*/; do
    [ -f $d/slang.uhdm ] || continue
    g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | sed 's/golden cache hit //')/golden.uhdm
    [ -f "$g" ] || { echo "$n/$m NOGOLDEN"; continue; }
    o=$($STRICT_CMP --max 1 "$g" $d/slang.uhdm 2>&1)
    echo "$n/$m $(echo "$o" | grep -m1 '^#') | $(echo "$o" | grep -m1 '^objects') | $(echo "$o" | tail -1)"
  done; done
done
