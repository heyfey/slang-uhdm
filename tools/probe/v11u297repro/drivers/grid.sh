#!/bin/bash
# (r11u297: copied from r11u295repro/drivers)
# (r11u295: copied from r11u293repro/drivers)
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
# (r11u289: copied from r11u287repro/drivers)
# (r11u287: copied from r11u285repro/drivers)
# (r11u285: copied from r11u283repro/drivers)
# (r11u283: copied from r11u281repro/drivers)
# (r11u281: copied from r11u279repro/drivers)
# (r11u279: copied from r11u277repro/drivers)
# (r11u277: copied from r11u275repro/drivers)
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
# r11u297 grid.sh <out> <case dir>... : every case in both views on the configurations below; one line per
# case-view-configuration carrying the exit code (rc=) and the case.sh fields. Binaries from $B (pristine, law).
# Configurations: P (pristine), L (law), OFF (law + R11U297_OFF), and the law with each switch off.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="${SW:-R11U297_VARINITTSEND_OFF R11U297_VARINITSPAN_OFF R11U297_NESTNOSHELL_OFF}"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L ${LAWBIN:-$B/law} | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c OFF ${LAWBIN:-$B/law} R11U297_OFF=1 | sed 's/^/OFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} ${LAWBIN:-$B/law} $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
