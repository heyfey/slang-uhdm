#!/bin/bash
# v11u267 vgrid.sh <out> <case dir>... : every case in both views on: P (pristine), L (law), F (law + the verifier's
# refinement), F with R11V267_OFF (must give L's bytes), F with R11U267_OFF (must give P's bytes), and F with each
# switch off. One line per case-view-configuration carrying rc= and the case.sh fields. Binaries from $B.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U267_CAFOLDPARENT_OFF R11U267_GENREPLPARENT_OFF R11U267_TDDIMNET_OFF R11U267_QUALPATCONN_OFF R11V267_DLYREF_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c VOFF $B/fix R11V267_OFF=1 | sed 's/^/VOFF /' >> $out
    EL=$el bash $D/case.sh $c OFF $B/fix R11U267_OFF=1 | sed 's/^/OFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
