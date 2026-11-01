#!/bin/bash
# switchcheck.sh <law binary> <casedir>...: per case the pristine md5, the law md5,
# and the md5 under R11U461_OFF and under each law's own switch.
D=$(dirname $0); L=$1; shift
P=/tmp/v11u461_bin/pristine
for c in "$@"; do
  k=$(echo $c | sed 's|.*/cases/||')
  p=$($D/run1.sh $c $P sw_pris | sed 's/.*md5=//')
  l=$($D/run1.sh $c $L sw_law | sed 's/.*md5=//')
  o=$($D/run1.sh $c $L sw_off R11U461_OFF=1 | sed 's/.*md5=//')
  a=$($D/run1.sh $c $L sw_a R11U461_UNIONCLONE_OFF=1 | sed 's/.*md5=//')
  b=$($D/run1.sh $c $L sw_b R11U461_NESTEDAGG_OFF=1 | sed 's/.*md5=//')
  echo "$k pris=$p law=$l OFF=$o UNIONCLONE_OFF=$a NESTEDAGG_OFF=$b $([ "$o" = "$p" ] && echo OFF_PRISTINE || echo OFF_DIFFERS)"
done
