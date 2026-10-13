#!/bin/bash
# v11u317 gridv.sh <out> <case dir>... : every case in both views on P (pristine), L (law), F (fix), OFF (fix +
# R11U317_OFF: pristine's bytes expected), VOFF (fix + R11V317_OFF: the law's bytes expected), the fix with each
# R11V317 switch off, and the fix with each R11U317 switch off. One line per case-view-configuration, rc= on each.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
FIXBIN=${FIXBIN:-$B/fix}
VSW="R11V317_SELIDXTRIM_OFF R11V317_ESCBASE_OFF R11V317_NESTCHAIN_OFF"
SW="R11U317_GENLOCALOP_OFF R11U317_GENSYSINNER_OFF R11U317_GENLOCALINNER_OFF R11U317_CASTIDXCHAIN_OFF R11U317_IDXSEL_OFF R11U317_VARSEL_OFF R11U317_VARSELLEAF_OFF R11U317_SELIDXCASTTS_OFF R11U317_MODIDXNEST_OFF R11U317_MODIDXNESTGEN_OFF R11U317_DEFGENSELIDX_OFF R11U317_DEFGENSYSINOP_OFF R11U317_DEFGENCASTIDX_OFF R11U317_MODVARSELLEAF_OFF R11U317_MODIPSBASE_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $FIXBIN | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c OFF $FIXBIN R11U317_OFF=1 | sed 's/^/OFF /' >> $out
    EL=$el bash $D/case.sh $c VOFF $FIXBIN R11V317_OFF=1 | sed 's/^/VOFF /' >> $out
    for sw in $VSW $SW; do EL=$el bash $D/case.sh $c F_$sw $FIXBIN $sw=1 | sed "s/^/F_$sw /" >> $out; done
  done
done
