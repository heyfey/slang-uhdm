#!/bin/bash
# (v11u249) vgrid.sh <outfile> [tags...]: every case under v11u249repro/cases in both views on pristine, law and
# law + R11U249_OFF (and, with SW=1, law + each switch), three in parallel; one case.sh line per run, exit code
# included. Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vgrid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
SWS="R11U249_WHOLEARRTD_OFF R11U249_CLSTDARRPATH_OFF R11U249_UNITDYNTD_OFF R11U249_MODDYNTD_OFF R11U249_DYNNETTYPE_OFF R11U249_MODFOLD_OFF R11U249_UNITUNION_OFF"
for c in $(cd $H && ls -d ${CASES:-cases/*/*} | sort); do for el in 0 1; do
  echo "$el $H/$c pristine $B/pristine.bin"
  echo "$el $H/$c law $B/law.bin"
  echo "$el $H/$c lawOFF $B/law.bin R11U249_OFF=1"
  [ "${SW:-0}" = 1 ] && for s in $SWS; do echo "$el $H/$c law-$s $B/law.bin $s=1"; done
  [ -n "$FIXBIN" ] && { echo "$el $H/$c fix $FIXBIN"; echo "$el $H/$c fixOFF $FIXBIN R11V249_OFF=1"; }
done; done | xargs -P 3 -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh "$@"' >> $out
