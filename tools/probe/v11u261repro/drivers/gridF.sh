#!/bin/bash
# v11u261 gridF.sh <out> <case dir>... : every case in both views on P (pristine), L (law), F (law + the verifier's
# fix), FOFF (F with R11V261_OFF: must give L's bytes), FUOFF (F with R11U261_OFF: must give P's bytes) and F with
# each R11V261_* switch off. One line per case-view-configuration with rc= and the case.sh fields.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FOFF $B/fix R11V261_OFF=1 | sed 's/^/FOFF /' >> $out
    EL=$el bash $D/case.sh $c FUOFF $B/fix R11U261_OFF=1 | sed 's/^/FUOFF /' >> $out
    for sw in R11V261_QSELPARAM_OFF; do EL=$el bash $D/case.sh $c $sw $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
