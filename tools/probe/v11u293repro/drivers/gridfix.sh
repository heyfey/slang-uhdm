#!/bin/bash
# (v11u293) gridfix.sh <out> <case dir>... : every case in both views on P (pristine), L (the implementer's law),
# F (the verified fix), FV (fix + R11V293_OFF, expected = L), FU (fix + R11U293_OFF, expected = P) and the fix with
# each switch off; one line per case-view-configuration carrying the exit code (rc=). Binaries from $B.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
SW="R11U293_CLONERETSEL_OFF R11U293_CLSARRDIMEND_OFF R11U293_HOISTELEMSPAN_OFF R11U293_IFFIRSTREF_OFF R11U293_IFLOWFIRST_OFF R11U293_PVNDAPARENT_OFF R11V293_PVTSUNSTORED_OFF"
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FV $B/fix R11V293_OFF=1 | sed 's/^/FV /' >> $out
    EL=$el bash $D/case.sh $c FU $B/fix R11U293_OFF=1 | sed 's/^/FU /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c $sw $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
