#!/bin/bash
# v11u303 ctl3.sh <out> <repro dir>... : the byte controls on three binaries (P pristine, L law, F fix), both views,
# case.sh lines with exit codes; path lists filtered by $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "ctl3.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c P $B/pristine"; echo "$el $c L $B/law"; echo "$el $c F $B/fix"; done; done |
  xargs -P ${CTLJOBS:-3} -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3 | sed "s/^/$2 /"' >> $out
