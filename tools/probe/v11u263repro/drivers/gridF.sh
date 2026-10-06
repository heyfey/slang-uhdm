#!/bin/bash
# (v11u263) gridF.sh <out> <case dir>...: every case in both views on: P (pristine), L (law), F (fix = law + the
# verifier's refinement), VOFF (fix + R11V263_OFF: the law's bytes), UOFF (fix + R11U263_OFF: pristine's bytes), and
# the fix with each switch off. One line per case-view-configuration with rc=. Binaries from $B (pristine, law, fix).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U263_GENLPRANGE_OFF R11U263_GENIFPORT_OFF R11U263_DOTSELBASE_OFF R11U263_DOTOPRHS_OFF R11V263_SELCLONE_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c VOFF $B/fix R11V263_OFF=1 | sed 's/^/VOFF /' >> $out
    EL=$el bash $D/case.sh $c UOFF $B/fix R11U263_OFF=1 | sed 's/^/UOFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
