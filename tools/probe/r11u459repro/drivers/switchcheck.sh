#!/bin/bash
# switchcheck.sh <law binary> <casedir>...: per case the pristine md5, the law md5,
# and the md5 under R11U459_OFF and under each law's own switch.
D=$(dirname $0); L=$1; shift
P=/tmp/r11u459_bin/pristine
for c in "$@"; do
  k=$(echo $c | sed 's|.*/cases/||')
  p=$($D/run1.sh $c $P sw_pris | sed 's/.*md5=//; s/.*rc=\([0-9]*\).*/rc\1/')
  l=$($D/run1.sh $c $L sw_law | sed 's/.*md5=//')
  o=$($D/run1.sh $c $L sw_off R11U459_OFF=1 | sed 's/.*md5=//')
  a=$($D/run1.sh $c $L sw_a R11U459_DEFFLIPRAW_OFF=1 | sed 's/.*md5=//')
  b=$($D/run1.sh $c $L sw_b R11U459_UNITTRANS_OFF=1 | sed 's/.*md5=//')
  z=$($D/run1.sh $c $L sw_c R11U459_ZEROENUMBITS_OFF=1 | sed 's/.*md5=//')
  echo "$k pris=$p law=$l OFF=$o DEFFLIPRAW_OFF=$a UNITTRANS_OFF=$b ZEROENUMBITS_OFF=$z $([ "$o" = "$p" ] && echo OFF_PRISTINE || echo OFF_DIFFERS)"
done
