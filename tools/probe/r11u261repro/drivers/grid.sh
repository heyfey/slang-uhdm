#!/bin/bash
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# r11u261 grid.sh <out> <case dir>... : every case in both views on the configurations below; one line per
# case-view-configuration carrying the exit code (rc=) and the case.sh fields. Binaries from $B (pristine, law).
# Configurations: P (pristine), L (law), OFF (law + R11U261_OFF), and the law with each switch off.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U261_SYSARGTS_OFF R11U261_QSELNAME_OFF R11U261_GENBIRTH_OFF R11U261_PSCONNARR_OFF R11U261_GRP54ORDER_OFF R11U261_CLSIMPORDER_OFF ${R261_EXTRA_SW:-}"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c OFF $B/law R11U261_OFF=1 | sed 's/^/OFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/law $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
