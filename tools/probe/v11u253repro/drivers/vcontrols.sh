#!/bin/bash
# (v11u253; from r11u253repro/drivers/controls.sh) vcontrols.sh <outfile> <repro dir>...: every case (dut.sv / dut.v dir)
# of the named tools/probe repro dirs in both views on pristine and law (case.sh lines, exit codes included), three in
# parallel. Paths are listed first and filtered by $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vcontrols.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); P=$(cd "$H/../.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $P/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c pristine $B/pristine"; echo "$el $c law ${LAWBIN:-$B/law}"; done; done |
  xargs -P 3 -L 1 bash -c 'EL=$0 '"$H"'/case.sh $1 $2 $3' >> $out
