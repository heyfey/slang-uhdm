#!/bin/bash
# (r11u247: copied from r11u244repro/drivers)
# (r11u244: copied from r11u242repro/drivers)
# (r11u242: copied from r11u240repro/drivers; r11u244: the switches of this pass)
# grid.sh <outfile>: every case under cases/ in both views on pristine, law, law + R11U244_OFF and law + each
# switch; one line per run (case.sh's line, exit code included). Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
SW="R11U247_HOMEVARDUP_OFF R11U247_HOMEARRTS_OFF R11U247_PUREFORMAL_OFF R11U247_TPKWELEM_OFF R11U247_KWELEM_OFF R11U247_ELEMALIAS_OFF"
for c in $(cd $H && ls -d cases/*/* | sort); do
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine.bin >> $out
    EL=$el $H/drivers/case.sh $H/$c law ${LAWBIN:-$B/law.bin} >> $out
    EL=$el $H/drivers/case.sh $H/$c lawOFF ${LAWBIN:-$B/law.bin} R11U247_OFF=1 >> $out
    for s in $SW; do EL=$el $H/drivers/case.sh $H/$c "law-$s" ${LAWBIN:-$B/law.bin} $s=1 >> $out; done
  done
done
