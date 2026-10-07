#!/bin/bash
# v11u273 vgrid.sh <out> <case dir>... : every case in both views on P (pristine), L (law), F (fix = law + the
# verifier's refinements), F with R11V273_OFF (must equal L), F with R11U273_OFF (must equal P), and F with each
# single switch off. One case.sh line per case-view-configuration, carrying the exit code (rc=). Binaries from $B.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U273_TPSTRUCTNET_OFF R11U273_RETLITSHARE_OFF R11U273_PARAMVALSHARE_OFF R11V273_DLYREF_OFF R11V273_TPVARKEEP_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F ${FIXBIN:-$B/fix} | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c VOFF ${FIXBIN:-$B/fix} R11V273_OFF=1 | sed 's/^/VOFF /' >> $out
    EL=$el bash $D/case.sh $c UOFF ${FIXBIN:-$B/fix} R11U273_OFF=1 | sed 's/^/UOFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} ${FIXBIN:-$B/fix} $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
