#!/bin/bash
# (v11u256) vgrid.sh <out> <case dir>...: every case in both views on pristine (P), the law (L), the fix (FIX), the
# fix with R11V256_OFF (VOFF: must give the law's bytes) and the fix with R11U256_OFF (UOFF: must give pristine's);
# case.sh lines, exit codes included. Binaries from $B (pristine, law, fix).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c FIX $B/fix | sed 's/^/FIX /' >> $out
    EL=$el bash $D/case.sh $c VOFF $B/fix R11V256_OFF=1 | sed 's/^/VOFF /' >> $out
    EL=$el bash $D/case.sh $c UOFF $B/fix R11U256_OFF=1 | sed 's/^/UOFF /' >> $out
  done
done
