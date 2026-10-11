#!/bin/bash
# v11u289 controls.sh <out> <tools/probe repro dir>...: every case in both views on pristine, law and fix
# (case.sh lines, exit codes included), three in parallel. Paths are listed first and filtered by $FENCED (word
# boundary) before any case is opened. Binaries: $B/pristine, $B/law, $FIXBIN.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$B" ] && [ -x "$FIXBIN" ] || { echo "controls.sh: source drivers/env.sh, export FIXBIN" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c P $B/pristine"; echo "$el $c L $B/law"; echo "$el $c F $FIXBIN"; done; done |
  xargs -P 3 -L 1 bash -c 'EL=$0 bash '"$H"'/drivers/case.sh $1 $2 $3 | sed "s/^/$2 /"' >> $out
