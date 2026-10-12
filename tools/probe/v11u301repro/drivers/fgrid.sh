#!/bin/bash
# v11u301 fgrid.sh <out> <case dir>...: every case in both views on P (pristine), L (law), F (fix = law + the
# verifier's refinements), FV (fix + R11V301_OFF: must equal L), FU (fix + R11U301_OFF: must equal P) and the fix with
# each refinement switch off; one line per case-view-configuration with rc= (case.sh). Binaries from $B (pristine,
# law, fix). Source env.sh first (fail-closed on $FENCED).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
FIX=${FIX:-$B/fix}; for b in $B/pristine $B/law $FIX; do [ -x "$b" ] || { echo "fgrid.sh: binary not executable: $b" >&2; exit 2; }; done
out=$1; shift; : > $out
for c in "$@"; do for el in 0 1; do
  EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
  EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
  EL=$el bash $D/case.sh $c F $FIX | sed 's/^/F /' >> $out
  EL=$el bash $D/case.sh $c FV $FIX R11V301_OFF=1 | sed 's/^/FV /' >> $out
  EL=$el bash $D/case.sh $c FU $FIX R11U301_OFF=1 | sed 's/^/FU /' >> $out
  for sw in R11V301_CALLTOP_OFF R11V301_CASTWQUAL_OFF R11V301_XZLEAD_OFF; do EL=$el bash $D/case.sh $c $sw $FIX $sw=1 | sed "s/^/$sw /" >> $out; done
done; done
