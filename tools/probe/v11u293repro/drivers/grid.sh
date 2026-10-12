#!/bin/bash
# (v11u293) grid.sh <out> <case dir>... : every case in both views on P (pristine), L (law, or $LAWBIN), OFF (law +
# R11U293_OFF) and, when $SWITCHES is set, the law with each switch off; one line per case-view-configuration carrying
# the exit code (rc=) and the case.sh fields. Binaries from $B. Fail-closed on $FENCED (env.sh, case.sh).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L ${LAWBIN:-$B/law} | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c OFF ${LAWBIN:-$B/law} R11U293_OFF=1 | sed 's/^/OFF /' >> $out
    for sw in $SWITCHES; do EL=$el bash $D/case.sh $c ${sw} ${LAWBIN:-$B/law} $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
