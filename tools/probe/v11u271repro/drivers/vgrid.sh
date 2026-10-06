#!/bin/bash
# v11u271 vgrid.sh <out> <case dir>... : every case in both views on P (pristine), L (law), F (fix = law + the
# verifier's refinement), FV (fix + R11V271_OFF: must be L's bytes), FOFF (fix + R11U271_OFF: must be P's bytes) and
# F with each switch off. One line per case-view-configuration with its exit code (case.sh fields). Binaries from
# $B (pristine, law, fix). Uses r11u271repro/drivers/case.sh (fail-closed on $FENCED).
D=$(cd "$(dirname "$0")/../../r11u271repro/drivers" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U271_TPUSESHARE_OFF R11U271_TPFORMALSHARE_OFF R11U271_NDACONSTLHS_OFF R11U271_NDAIMPENUM_OFF R11V271_LAWLHSTS_OFF R11V271_MODCLASS_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FV $B/fix R11V271_OFF=1 | sed 's/^/FV /' >> $out
    EL=$el bash $D/case.sh $c FOFF $B/fix R11U271_OFF=1 | sed 's/^/FOFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c F_$sw $B/fix $sw=1 | sed "s/^/F_$sw /" >> $out; done
  done
done
