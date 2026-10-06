#!/bin/bash
# (v11u262: adapted from r11u262repro/drivers/controls.sh: three binaries, pristine, law and fix)
# controls.sh <out> <repro dir>...: every case of the named tools/probe repro dirs in both views on $B/pristine,
# $B/law and $B/fix (case.sh lines, exit codes included), three in parallel. Paths are listed first and filtered by
# $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "controls.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c pristine $B/pristine"; echo "$el $c law $B/law"; echo "$el $c fix $B/fix"; done; done |
  xargs -P 3 -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3' >> $out
