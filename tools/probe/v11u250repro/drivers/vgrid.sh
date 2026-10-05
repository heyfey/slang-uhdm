#!/bin/bash
# (v11u250) vgrid.sh <outfile>: every case under cases/ in both views on pristine, law, fix, fix + R11V250_OFF,
# fix + R11U250_OFF and fix + each R11V250 switch; one case.sh line per run (exit code included).
# Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vgrid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
SW="R11V250_PCWOTHER_OFF R11V250_KWDECL_OFF R11V250_QUALKEY_OFF"
for c in $(cd $H && ls -d cases/*/* | sort); do
  for el in 0 1; do
    for t in pristine law fix; do EL=$el $H/drivers/case.sh $H/$c $t $B/$t.bin >> $out; done
    EL=$el $H/drivers/case.sh $H/$c fixVOFF $B/fix.bin R11V250_OFF=1 >> $out
    EL=$el $H/drivers/case.sh $H/$c fixUOFF $B/fix.bin R11U250_OFF=1 >> $out
    for s in $SW; do EL=$el $H/drivers/case.sh $H/$c "fix-$s" $B/fix.bin $s=1 >> $out; done
  done
done
