#!/bin/bash
# (r11u240: copied from r11u238repro/drivers, switches of this pass)
# grid.sh <outfile>: every case under cases/ in both views on pristine, law, law + R11U240_OFF and law + each
# switch; one line per run (case.sh's line, exit code included). Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
SW="R11U240_POOLORDER_OFF R11U240_IMPARRELEM_OFF"
for c in $(cd $H && ls -d cases/*/* | sort); do
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine >> $out
    EL=$el $H/drivers/case.sh $H/$c law ${LAWBIN:-$B/law} >> $out
    EL=$el $H/drivers/case.sh $H/$c lawOFF ${LAWBIN:-$B/law} R11U240_OFF=1 >> $out
    for s in $SW; do EL=$el $H/drivers/case.sh $H/$c "law-$s" ${LAWBIN:-$B/law} $s=1 >> $out; done
  done
done
