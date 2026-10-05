#!/bin/bash
# (r11u255: copied from r11u253repro/drivers; two in parallel)
# (r11u253: copied from r11u251repro/drivers)
# (r11u251: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247; r11u253: frozen binary names, three in parallel) controls.sh <outfile> <repro dir>...: the byte controls — every case (dut.sv / dut.v dir) of the named
# tools/probe repro dirs in both views on pristine and law (case.sh lines, exit codes included), four in parallel.
# Paths are listed first and filtered by $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "controls.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c pristine $B/pristine"; echo "$el $c law ${LAWBIN:-$B/law}"; done; done |
  xargs -P 2 -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3' >> $out
