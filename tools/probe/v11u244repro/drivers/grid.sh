#!/bin/bash
# (v11u244) grid.sh <outfile> <casesroot> [lawbin]: every case under <casesroot>/*/* in both views on pristine ($B/pristine),
# the law, the law + R11U244_OFF and the law + each switch; one case.sh line per run (exit code included).
# Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); out=$1; root=$2; LB=${3:-$B/law}; : > $out
SW="R11U244_BLKELEMCOPY_OFF R11U244_BLKFIXARRTS_OFF R11U244_NEWARRPARENT_OFF R11U244_HPIDXTRAIL_OFF R11U244_LVIPSCHAIN_OFF R11U244_INVBLKLOC_OFF R11U244_METHNAMELOC_OFF ${EXTRA_SW:-}"
for c in $(cd $root && ls -d */* | sort); do
  for el in 0 1; do
    EL=$el $H/case.sh $root/$c pristine $B/pristine >> $out
    EL=$el $H/case.sh $root/$c law $LB >> $out
    EL=$el $H/case.sh $root/$c lawOFF $LB R11U244_OFF=1 >> $out
    for s in $SW; do EL=$el $H/case.sh $root/$c "law-$s" $LB $s=1 >> $out; done
  done
done
