#!/bin/bash
# v11u283 fixgrid.sh <out> <case dir>...: every case in both views on P (pristine), L (law), F (fix),
# FV (fix + R11V283_OFF, must equal L) and FU (fix + R11U283_OFF, must equal P); one line each with rc=.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FV $B/fix R11V283_OFF=1 | sed 's/^/FV /' >> $out
    EL=$el bash $D/case.sh $c FU $B/fix R11U283_OFF=1 | sed 's/^/FU /' >> $out
  done
done
