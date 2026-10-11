#!/bin/bash
# v11u287 controls.sh <dirlist> <out>: every case of the listed tools/probe dirs in both views on pris, law and fix.
# The path list is built first and filtered by $FENCED (word boundary) before any case is opened.
H=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$H/../../../.." && pwd); D=$REPO/tools/probe/r11u287repro/drivers
. $D/env.sh || exit 2
[ "$(echo $FENCED | wc -w)" = 4 ] || exit 2
fre=$(echo $FENCED | tr ' ' '|')
for d in $(cat $1); do find $REPO/tools/probe/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c P $B/pris"; echo "$el $c L $B/law"; echo "$el $c F $B/fix"; done; done |
  xargs -P ${P:-3} -L 1 bash -c 'EL=$0 '"$D"'/case.sh $1 $2 $3' > $2 2>&1
