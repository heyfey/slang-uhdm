#!/bin/bash
# v11u276 grid3.sh <out.txt> <pristine bin> <law bin> <fix bin> <case dir>...: every case dir in both views on
# pristine, the law (r11u276's binary), the fix (law + the verifier's refinement), the fix with R11V276_OFF (must give
# the law's bytes), with R11U276_OFF (must give pristine's) and with each switch off.  One line per run:
# <case> <view> <variant> rc=.. cmp=.. <verdict> md5=..  (the exit code on every line).  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid3.sh: FENCED unset" >&2; exit 2; }
out=$1; P=$2; L=$3; F=$4; shift 4
C=$(dirname $(realpath $0))/case.sh
SW="R11U276_CACALLRHS_OFF R11U276_RHSOWNTS_OFF R11U276_REDUCEKIND_OFF R11V276_CALLOPARG_OFF R11V276_EQUIVOP_OFF"
: > $out
for d in "$@"; do
  n=$(echo $d | sed 's#.*/tools/probe/##')
  for v in d e; do
    echo "$n $v pristine $($C $d $P $v)" >> $out
    echo "$n $v law $($C $d $L $v)" >> $out
    echo "$n $v fix $($C $d $F $v)" >> $out
    echo "$n $v fix+R11V276_OFF $(R11V276_OFF=1 $C $d $F $v)" >> $out
    echo "$n $v fix+R11U276_OFF $(R11U276_OFF=1 $C $d $F $v)" >> $out
    for s in $SW; do echo "$n $v fix+$s $(env $s=1 $C $d $F $v)" >> $out; done
  done
done
