#!/bin/bash
# (v11u253: copied from r11u253repro/drivers)
# (r11u253: copied from r11u251repro/drivers)
# (r11u251: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247: copied from r11u244repro/drivers)
# (r11u244: copied from r11u242repro/drivers)
# (r11u242: copied from r11u240repro/drivers; r11u244, r11u249, r11u251, r11u253: the switches of this pass)
# grid.sh <outfile>: every case under cases/ in both views on pristine, law, law + R11U244_OFF and law + each
# switch; one line per run (case.sh's line, exit code included). Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
SW="R11U253_MINTHOME_OFF R11U253_TFITEMOWN_OFF R11U253_HOMEARRELAB_OFF R11U253_TFFIXARRTS_OFF R11U253_FORMALTS_OFF"
for c in $(cd $H && ls -d cases/*/* | sort); do
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine >> $out
    EL=$el $H/drivers/case.sh $H/$c law ${LAWBIN:-$B/law} >> $out
    EL=$el $H/drivers/case.sh $H/$c lawOFF ${LAWBIN:-$B/law} R11U253_OFF=1 >> $out
    for s in $SW; do EL=$el $H/drivers/case.sh $H/$c "law-$s" ${LAWBIN:-$B/law} $s=1 >> $out; done
  done
done
