#!/bin/bash
# (r11u246) gridp.sh <outfile> [jobs]: grid.sh's runs, one case per job (xargs -P), the per-case lines concatenated in
# case order.  Same lines as grid.sh (pristine, law, law + R11U246_OFF, law + each switch; both views; exit codes).
# Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "gridp.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; J=${2:-3}; T=$S/gridp.$$; mkdir -p $T
SW=$(grep -m1 '^SW=' $H/drivers/grid.sh | sed 's/^SW=//; s/"//g')
export H T SW LAWBIN=${LAWBIN:-$B/law}
one() {
  c=$1; f=$T/$(echo $c | tr / _); : > $f
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine >> $f
    EL=$el $H/drivers/case.sh $H/$c law $LAWBIN >> $f
    EL=$el $H/drivers/case.sh $H/$c lawOFF $LAWBIN R11U246_OFF=1 >> $f
    for s in $SW; do EL=$el $H/drivers/case.sh $H/$c "law-$s" $LAWBIN $s=1 >> $f; done
  done
}
export -f one
(cd $H && ls -d cases/*/* | sort) | xargs -P $J -I{} bash -c 'one {}'
: > $out
for c in $(cd $H && ls -d cases/*/* | sort); do cat $T/$(echo $c | tr / _) >> $out; done
rm -rf $T
