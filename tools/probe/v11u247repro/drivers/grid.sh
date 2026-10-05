#!/bin/bash
# (v11u247) grid.sh <outfile> [case-glob]: every case under cases/ in both views on pristine, law, law + R11U247_OFF
# and law + each switch (FIXBIN set: also the fix binary, fix + R11V247_OFF, fix + R11U247_OFF); one line per run
# (case.sh's line, exit code included). Needs drivers/env.sh sourced ($B, $S, $FENCED). Runs cases 4-wide.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; glob=${2:-*/*}; : > $out
SW="R11U247_HOMEVARDUP_OFF R11U247_HOMEARRTS_OFF R11U247_PUREFORMAL_OFF R11U247_TPKWELEM_OFF R11U247_KWELEM_OFF R11U247_ELEMALIAS_OFF"
one() {
  c=$1; el=$2; o=$3
  {
  EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine.bin
  EL=$el $H/drivers/case.sh $H/$c law $B/law.bin
  EL=$el $H/drivers/case.sh $H/$c lawOFF $B/law.bin R11U247_OFF=1
  for s in $SW; do EL=$el $H/drivers/case.sh $H/$c "law-$s" $B/law.bin $s=1; done
  if [ -n "$FIXBIN" ]; then
    EL=$el $H/drivers/case.sh $H/$c fix $FIXBIN
    EL=$el $H/drivers/case.sh $H/$c fixVOFF $FIXBIN R11V247_OFF=1
    EL=$el $H/drivers/case.sh $H/$c fixUOFF $FIXBIN R11U247_OFF=1
  fi
  } > $o
}
export -f one; export H SW FIXBIN
tmp=$(mktemp -d /tmp/v11u247_gridtmp.XXXX)
i=0
for c in $(cd $H && ls -d cases/$glob | sort); do for el in 0 1; do
  i=$((i+1)); one $c $el $tmp/$(printf %05d $i) &
  while [ $(jobs -r | wc -l) -ge 4 ]; do wait -n; done
done; done; wait
cat $tmp/* > $out; rm -rf $tmp
