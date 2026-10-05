#!/bin/bash
# (r11u237: copied from r11u231repro/drivers/rowhead.sh.)
# rowhead.sh <workdir> <out dir> <corpus/mode/Row ...>: uhdm-strictcmp (records dumped) of each named row-mode's
# database in a harness workdir against its cached golden (read from cmds.txt); prints the first differing records.
# Fail-closed on $FENCED: a fenced row is refused.
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$H/env.sh" || exit 2
w=$1; o=$2; shift 2; mkdir -p $o
for r in "$@"; do
  echo "$r" | grep -Eq "$FENCE_RE" && { echo "rowhead: fenced row refused" >&2; continue; }
  d=$(ls -d $w/${r}-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "$r NODIR"; continue; }
  g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  t=$(echo $r | tr / _)
  timeout 2400 $STRICT_CMP --dump-a $o/$t.a.rec --dump-b $o/$t.b.rec $g $d/slang.uhdm > $o/$t.strict 2>&1
  echo "== $r: $(tail -1 $o/$t.strict)"; grep -A2 '^#' $o/$t.strict | head -${N:-9}
done
