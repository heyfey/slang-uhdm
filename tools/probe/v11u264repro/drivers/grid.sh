#!/bin/bash
# (v11u264: from r11u264repro/drivers/grid.sh, extended to the verifier's binaries)
# v11u264 grid.sh <out> <case dir>... : every case in both views on the configurations below, one line per
# case-view-configuration carrying the exit code (rc=) and the case.sh fields. Binaries from $B.
# Configurations: P (pristine), L (the implementer's law binary), F (the verified binary: law + refinements),
# OFF (F + R11U264_OFF: must give P's bytes), VOFF (F + R11V264_OFF: must give L's bytes), then F with each
# switch in $SW off (the law that moves a case back).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="${SW:-R11U264_CTORCOPY_OFF R11U264_CALVTRAILIDX_OFF R11U264_REFSIGNTS_OFF R11U264_QUALSHADOW_OFF R11U264_IPSPARENEND_OFF R11U264_IPSOPCHAIN_OFF R11U264_PLAINIPSOWN_OFF R11V264_SRCKIND_OFF R11V264_QSPKGTD_OFF R11V264_QSGENREAD_OFF}"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c OFF $B/fix R11U264_OFF=1 | sed 's/^/OFF /' >> $out
    EL=$el bash $D/case.sh $c VOFF $B/fix R11V264_OFF=1 | sed 's/^/VOFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
