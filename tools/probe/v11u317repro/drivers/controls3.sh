#!/bin/bash
# v11u317 controls3.sh <out> <tools/probe dir>... : every case dir (dut.sv or dut.v) under the given tools/probe dirs in
# both views on pristine, law and fix (case.sh lines, exit codes included), CTLJOBS at a time. The path list is built
# first and filtered by $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "controls3.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c pristine $B/pristine"; echo "$el $c law $B/law"; echo "$el $c fix $B/fix"; done; done |
  xargs -P ${CTLJOBS:-3} -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3' >> $out
