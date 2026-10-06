#!/bin/bash
# v11u268 grid3.sh <out> <case dir>... : every case in both views on P (pristine), L (law), F (fix),
# FV (fix + R11V268_OFF, must give L's bytes), FU (fix + R11U268_OFF, must give P's bytes) and the fix with
# each switch in $V268_SW off; one line per case-view-configuration carrying rc= and the case.sh fields.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FV $B/fix R11V268_OFF=1 | sed 's/^/FV /' >> $out
    EL=$el bash $D/case.sh $c FU $B/fix R11U268_OFF=1 | sed 's/^/FU /' >> $out
    for sw in $V268_SW; do EL=$el bash $D/case.sh $c ${sw} $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
