#!/bin/bash
# (r11u319: copied from r11u317repro/drivers)
# (r11u317: copied from v11u315repro/drivers)
# (r11u315: copied from r11u313repro/drivers)
# (r11u313: copied from v11u311repro/drivers)
# (v11u311: copied from r11u311repro/drivers)
# (r11u311: copied from r11u309repro/drivers)
# (r11u309: copied from r11u307repro/drivers)
# (r11u307: copied from r11u305repro/drivers)
# (r11u305: copied from r11u303repro/drivers)
# (r11u303: copied from r11u301repro/drivers)
# (r11u299: copied from r11u297repro/drivers)
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
# r11u319 grid.sh (from r11u317) (from r11u315, r11u313) (from r11u311, r11u309, r11u307, r11u305) <out> <case dir>... : every case in both views on the configurations below; one line per
# case-view-configuration carrying the exit code (rc=) and the case.sh fields. Binaries from $B (pristine, law).
# Configurations: P (pristine), L (law), OFF (law + R11U317_OFF), and the law with each switch off.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="${SW:-R11U319_SYSIDXNAME_OFF R11U319_IFVSWHOLE_OFF R11U319_MODVSWHOLE_OFF R11U319_IFSELWHOLELEAF_OFF R11U319_MODSELWHOLELEAF_OFF R11U319_VSIDXLEAF_OFF R11U319_GENIFVSUNBIND_OFF R11U319_DEFGENSYSIDX_OFF R11U319_DEFGENVSIDX_OFF R11U319_DEFGENIDXTRIM_OFF R11U319_DEFGENMODPOW_OFF R11U319_MODIDXOP_OFF}"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L ${LAWBIN:-$B/law} | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c OFF ${LAWBIN:-$B/law} R11U319_OFF=1 | sed 's/^/OFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} ${LAWBIN:-$B/law} $sw=1 | sed "s/^/$sw /" >> $out; done
  done
done
