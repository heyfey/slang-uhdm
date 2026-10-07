#!/bin/bash
# v11u285 grid.sh <out> <case dir>...: every case in both views on pristine (P), the law (L), the law with
# R11U285_OFF (OFF) and the law with each R11U285 switch off; one line per case-view-configuration from
# tools/probe/r11u285repro/drivers/case.sh, every line carrying rc=. NOSW=1 skips the per-switch lines.
# Needs B (frozen binaries: pristine, law, uhdm-strictcmp) and S (scratch) exported; env.sh reads $FENCED fail-closed.
D=$(cd "$(dirname "$0")" && pwd); R=$(cd "$D/../../r11u285repro/drivers" && pwd)
. "$R/env.sh" || exit 2
out=$1; shift; : > $out
SW="R11U285_CLSIMPTDSHARE_OFF R11U285_IMPHPNAME_OFF R11U285_CLONEMEMBNAME_OFF R11U285_CLONEMEMBTYPE_OFF"
for c in "$@"; do for el in 0 1; do
  EL=$el bash $R/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
  EL=$el bash $R/case.sh $c L $B/law | sed 's/^/L /' >> $out
  EL=$el bash $R/case.sh $c OFF $B/law R11U285_OFF=1 | sed 's/^/OFF /' >> $out
  [ -n "${NOSW:-}" ] || for sw in $SW; do EL=$el bash $R/case.sh $c $sw $B/law $sw=1 | sed "s/^/$sw /" >> $out; done
done; done
