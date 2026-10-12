#!/bin/bash
# v11u303 gridf.sh <out> <case dir>... : every case in both views; one line per case-view-configuration with the exit
# code (rc=) and the case.sh fields. Binaries from $B (pristine, law, fix). Configurations: P (pristine), L (law),
# F (fix), OFF (fix + R11U303_OFF), VOFF (fix + R11V303_OFF), and the fix with each law and refinement switch off.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U303_SELBASETRIM_OFF R11U303_BOUNDSYSCLONE_OFF R11U303_SYSARGNAME_OFF R11U303_MODARRSELNAME_OFF R11U303_MODARRIPSSPAN_OFF R11U303_GENCAENUMSPAN_OFF R11U303_GENNDASEL_OFF R11U303_GENNDAOP_OFF R11U303_CLSPARAMTD_OFF R11U303_IFTERNFILL_OFF R11V303_ENUMSELQUAL_OFF R11V303_NDASELCONST_OFF R11V303_IFFILLIDX_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c OFF $B/fix R11U303_OFF=1 | sed 's/^/OFF /' >> $out
    EL=$el bash $D/case.sh $c VOFF $B/fix R11V303_OFF=1 | sed 's/^/VOFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
