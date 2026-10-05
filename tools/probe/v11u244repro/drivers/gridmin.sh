#!/bin/bash
# (v11u244) gridmin.sh <outfile> <casesroot> <fixbin>: every case in both views on pristine ($B/pristine), the
# implementer's law ($B/law), the fix binary, the fix + R11U244_OFF and the fix + R11V244_OFF; one case.sh line per run.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "gridmin.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); out=$1; root=$2; FB=$3; : > $out
for c in $(cd $root && ls -d */* | sort); do
  for el in 0 1; do
    EL=$el $H/case.sh $root/$c pristine $B/pristine >> $out
    EL=$el $H/case.sh $root/$c implaw $B/law >> $out
    EL=$el $H/case.sh $root/$c law $FB >> $out
    EL=$el $H/case.sh $root/$c lawOFF $FB R11U244_OFF=1 >> $out
    EL=$el $H/case.sh $root/$c law-R11V244_OFF $FB R11V244_OFF=1 >> $out
  done
done
