#!/bin/bash
# v11u252repro controls.sh <outfile> <repro dir>...: the byte controls on pristine, law and fix (case.sh lines, exit
# codes included). Paths are listed first and filtered by $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "controls.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do for t in ${CTL_BINS:-pristine law fix}; do echo "$el $c $t $B/$t.bin"; done; done; done |
  xargs -P ${CTL_JOBS:-3} -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3' >> $out
