#!/bin/bash
# (v11u238) grid.sh <outfile> [case-glob]: every case (default: this pass's fresh cases/*/*) in both views on pristine, the
# implementer's law binary (alone and under R11U238_OFF and each R11U238_* switch) and the fixed binary (alone, under
# R11U238_OFF, R11V238_OFF and each R11V238_* switch); one line per run (drivers/case.sh's line, exit code included).
# Needs drivers/env.sh sourced ($B, $S, $FENCED). Binaries: $B/pristine, $B/law, $B/fix (FIXBIN overrides). CASEROOT
# overrides the case root (e.g. the implementer's r11u238repro).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); CR=${CASEROOT:-$H}; out=$1; : > $out; G=${2:-*/*}; FX=${FIXBIN:-$B/fix}
SW="R11U238_PROPSTRTS_OFF R11U238_FLATLOCALREFTS_OFF R11U238_CLONEFORINC_OFF R11U238_CLONEFORINCCLS_OFF R11U238_CLONEPROPARR_OFF"
VSW="R11V238_PKGLISTING_OFF R11V238_INSTSHADOW_OFF"
for c in $(cd $CR && ls -d cases/$G | sort); do
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $CR/$c pristine $B/pristine >> $out
    EL=$el $H/drivers/case.sh $CR/$c law $B/law >> $out
    EL=$el $H/drivers/case.sh $CR/$c lawOFF $B/law R11U238_OFF=1 >> $out
    for s in $SW; do EL=$el $H/drivers/case.sh $CR/$c "law-$s" $B/law $s=1 >> $out; done
    EL=$el $H/drivers/case.sh $CR/$c fix $FX >> $out
    EL=$el $H/drivers/case.sh $CR/$c fixOFF $FX R11U238_OFF=1 >> $out
    EL=$el $H/drivers/case.sh $CR/$c fixVOFF $FX R11V238_OFF=1 >> $out
    for s in $VSW; do EL=$el $H/drivers/case.sh $CR/$c "fix-$s" $FX $s=1 >> $out; done
  done
done
