#!/bin/bash
# (v11u269: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# v11u269: + the fix binary (F, FV = R11V269_OFF, FU = R11U269_OFF, R11V269_OPKIND_OFF).
# r11u269 grid.sh <out> <case dir>... : every case in both views on the configurations below; one line per
# case-view-configuration carrying the exit code (rc=) and the case.sh fields. Binaries from $B (pristine, law).
# Configurations: P (pristine), L (law), OFF (law + R11U269_OFF), and the law with each switch off.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U269_TOPARRELEM_OFF R11U269_TDCLONEDEEP_OFF R11U269_RETRANGEOWNPKG_OFF R11U269_SELOPFOLD_OFF R11U269_BINDUP_OFF ${R269_EXTRA_SW:-}"
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c OFF $B/law R11U269_OFF=1 | sed 's/^/OFF /' >> $out
    for sw in $SW; do EL=$el bash $D/case.sh $c ${sw} $B/law $sw=1 | sed "s/^/$sw /" >> $out; done
    # v11u269: the verifier's fix binary, with its refinement off (the law's bytes) and with R11U269_OFF (pristine)
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FV $B/fix R11V269_OFF=1 | sed 's/^/FV /' >> $out
    EL=$el bash $D/case.sh $c FU $B/fix R11U269_OFF=1 | sed 's/^/FU /' >> $out
    EL=$el bash $D/case.sh $c R11V269_OPKIND_OFF $B/fix R11V269_OPKIND_OFF=1 | sed 's/^/R11V269_OPKIND_OFF /' >> $out
  done
done
