#!/bin/bash
# v11u290 gridv.sh <out> <case dir>...: every case in both views; one line per case-view-configuration with its exit
# code (rc=) and case.sh's fields. Configurations: P (pristine), L (law), F (fix), FV (fix + R11V290_OFF: the law's
# bytes), FU (fix + R11U290_OFF: pristine's bytes), then the fix with each law switch and each refinement switch off.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U290_PKGTDPACKED_OFF R11U290_UNITENUMSHARE_OFF R11U290_BASEIDXELEM_OFF R11U290_MISEVALSHARE_OFF R11U290_OVCLONECHAIN_OFF R11U290_OVFILE_OFF R11U290_SPLICEDECLTS_OFF R11U290_SPLICECHAIN_OFF R11U290_CONNBOUNDCHAIN_OFF R11U290_OVSPLICETOP_OFF R11V290_SHAREOPND_OFF R11V290_OVSIBOP_OFF R11V290_WRITERKIND_OFF R11V290_SPLICEOPND_OFF R11V290_SPLICESW_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FV $B/fix R11V290_OFF=1 | sed 's/^/FV /' >> $out
    EL=$el bash $D/case.sh $c FU $B/fix R11U290_OFF=1 | sed 's/^/FU /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c $sw $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
