#!/bin/bash
# v11u295 controls_pf.sh <out> <tools/probe dir>... : every case of the given repro dirs in both views on pristine (P)
# and the verified fix binary (F) (case.sh lines, exit codes included), CTLJOBS in parallel. Paths are listed first and
# filtered by $FENCED (word boundary) before any case is opened. Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$B" ] || { echo "controls_pf.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c P $B/pristine"; echo "$el $c F ${FIXBIN:-$B/fix}"; done; done |
  xargs -P ${CTLJOBS:-3} -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3 | sed "s/^/$2 /"' >> $out
