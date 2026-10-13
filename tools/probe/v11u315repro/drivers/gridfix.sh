#!/bin/bash
# v11u315 gridfix.sh <out> <case dir>...: every case in both views on P (pristine), LAW (the implementer's law), L (the
# verifier's fix), OFF (fix + R11U315_OFF), VOFF (fix + R11V315_OFF) and the fix with each switch off; one line per
# case-view-configuration with the exit code (rc=) and the case.sh fields. Binaries from $B (pristine, law, fix).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U315_OPSEL_OFF R11U315_CALLARG_OFF R11U315_IFLEAFDEF_OFF R11U315_CASTTSNAME_OFF R11U315_DEFGENTERNSYS_OFF R11U315_GENCALLUNBIND_OFF R11V315_GENLOCALBIND_OFF"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c LAW $B/law | sed 's/^/LAW /' >> $out
    EL=$el bash $D/case.sh $c L $B/fix | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c OFF $B/fix R11U315_OFF=1 | sed 's/^/OFF /' >> $out
    EL=$el bash $D/case.sh $c VOFF $B/fix R11V315_OFF=1 | sed 's/^/VOFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/fix $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
