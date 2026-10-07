#!/bin/bash
# (v11u275: copied from r11u275repro/drivers; case paths under v11u275repro/cases accepted)
# (r11u275: copied from r11u273repro/drivers)
# (r11u273: copied from r11u271repro/drivers)
# (r11u271: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# r11u275 grid.sh <out> <case dir>... : every case in both views on the configurations below; one line per
# case-view-configuration carrying the exit code (rc=) and the case.sh fields. Binaries from $B (pristine, law).
# Configurations: P (pristine), L (law), OFF (law + R11U275_OFF), and the law with each switch off.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U275_TPPATRESET_OFF R11U275_IMPNETDIMEND_OFF R11U275_IFGENUNBOUND_OFF R11U275_TFARRRANGEEND_OFF R11U275_TPVARINIT_OFF R11U275_DEFNETTPPAT_OFF ${R275_EXTRA_SW:-}"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c OFF $B/law R11U275_OFF=1 | sed 's/^/OFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/law $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
