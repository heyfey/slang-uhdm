#!/bin/bash
# switches.sh <law binary> <pristine binary> <casedir>...: per case dir, the md5 of
# pristine, law, R11U450_OFF and each law switch alone; flags which switches
# restore pristine bytes.
D=$(dirname $0); L=$1; P=$2; shift 2
SW="OWNCOPYSPAN IDXPSBIND VARSELBIND FWLISTEDQUAL ARRELEMHOME IFCBODYTRANS IFCPORTNET IFCFIXWALK IFCGRPORDER CLSASSOCVECIDX"
for c in "$@"; do
  [ -d "$c" ] || continue
  k=$(echo $c | sed 's|.*/cases/||')
  mp=$($D/run1.sh $c $P sw_p | sed 's/.*md5=//')
  ml=$($D/run1.sh $c $L sw_l | sed 's/.*md5=//')
  mo=$($D/run1.sh $c $L sw_off R11U450_OFF=1 | sed 's/.*md5=//')
  r="$k pristine=$mp law=$ml OFF=$([ "$mo" = "$mp" ] && echo pristine || echo DIFF)"
  if [ "$ml" != "$mp" ]; then
    rest=""
    for s in $SW; do
      m=$($D/run1.sh $c $L sw_$s R11U450_${s}_OFF=1 | sed 's/.*md5=//')
      [ "$m" = "$mp" ] && rest="$rest $s"
      [ "$m" != "$ml" ] && [ "$m" != "$mp" ] && rest="$rest ($s:partial)"
    done
    r="$r restores:${rest:- none-alone}"
  fi
  echo "$r"
done
