#!/bin/bash
# v11u274 vgrid.sh <out.txt> <pristine bin> <law bin> <fix bin> <case dir>...: every case dir in both views on
# pristine, the implementer's law, the verifier's fix, the fix with R11V274_OFF (must be the law's bytes), the fix
# with R11U274_OFF (must be pristine's bytes) and the fix with each switch off.  One line per run with its exit code.
# Fail-closed on $FENCED (case.sh refuses a fenced path).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "vgrid.sh: FENCED unset" >&2; exit 2; }
out=$1; P=$2; L=$3; X=$4; shift 4
C=$(dirname $(realpath $0))/case.sh
SW="R11U274_PKGNETDIMEND_OFF R11U274_MEMREADCOPY_OFF R11U274_LOTSNESTGEN_OFF R11U274_PKGUNARYSPAN_OFF ${V11U274_SW:-R11V274_PKDKW_OFF R11V274_SIGNEND_OFF}"
: > $out
for d in "$@"; do
  n=$(echo $d | sed 's#.*/tools/probe/##; s#.*/v11u274_scr/repro/#v11u274repro/#')
  for v in d e; do
    echo "$n $v pristine $($C $d $P $v)" >> $out
    echo "$n $v law $($C $d $L $v)" >> $out
    echo "$n $v fix $($C $d $X $v)" >> $out
    echo "$n $v fix+R11V274_OFF $(R11V274_OFF=1 $C $d $X $v)" >> $out
    echo "$n $v fix+R11U274_OFF $(R11U274_OFF=1 $C $d $X $v)" >> $out
    for s in $SW; do echo "$n $v fix+$s $(env $s=1 $C $d $X $v)" >> $out; done
  done
done
