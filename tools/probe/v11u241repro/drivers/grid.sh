#!/bin/bash
# (v11u241: from r11u241repro/drivers/grid.sh) grid.sh <outfile> [case-glob]: every case under cases/ in both views on
# pristine, law, law + R11U241_OFF and law + each switch (+ $FIXBIN and its switches when exported); one line per run,
# case.sh's line with rc=. Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
SW="R11U241_TPDEFLOC_OFF R11U241_TPDEFCLSNAME_OFF R11U241_CLONEARRTS_OFF R11U241_CLONEAGGLOC_OFF R11U241_CLONEAGGCOPY_OFF R11U241_CLONEAGGMEMB_OFF"
one() { c=$1
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine
    EL=$el $H/drivers/case.sh $H/$c law $B/law
    EL=$el $H/drivers/case.sh $H/$c lawOFF $B/law R11U241_OFF=1
    for s in $SW; do EL=$el $H/drivers/case.sh $H/$c "law-$s" $B/law $s=1; done
    if [ -n "$FIXBIN" ]; then
      EL=$el $H/drivers/case.sh $H/$c fix $FIXBIN
      for s in $FIXSW; do EL=$el $H/drivers/case.sh $H/$c "fix-$s" $FIXBIN $s=1; done
    fi
  done > $S/grid_$(echo $c | tr / _).part
}
export -f one; export H FIXBIN FIXSW SW
cd $H && ls -d cases/${2:-*}/* | sort | xargs -P 3 -I{} bash -c 'one {}'
for c in $(cd $H && ls -d cases/${2:-*}/* | sort); do cat $S/grid_$(echo $c | tr / _).part; done > $out
