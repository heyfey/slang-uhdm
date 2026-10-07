#!/bin/bash
# v11u278 vgrid.sh <out.txt> <pristine bin> <law bin> <fix bin> <case dir>...: every case dir in both views on
# pristine, the r11u278 law, the verifier's fix, the fix + R11V278_OFF (must give the law's bytes), the fix +
# R11U278_OFF (must give pristine's), the fix + R11V278_OVRTPREF_OFF and the fix + each of the four law switches.
# One line per run, every line with its exit code: <case> <view> <variant> rc=.. cmp=.. <verdict> md5=..
# Fail-closed on $FENCED (case.sh refuses a fenced path).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "vgrid.sh: FENCED unset" >&2; exit 2; }
out=$1; P=$2; L=$3; X=$4; shift 4
C=$(dirname $(realpath $0))/case.sh
SW="R11V278_OVRTPREF_OFF R11U278_TRAILVARSEL_OFF R11U278_PKGQUALRHS_OFF R11U278_BODYCHAIN_OFF R11U278_IFACETP_OFF"
: > $out
for d in "$@"; do
  n=$(realpath $d | sed 's#.*/tools/probe/##')
  for v in d e; do
    echo "$n $v pristine $($C $d $P $v)" >> $out
    echo "$n $v law $($C $d $L $v)" >> $out
    echo "$n $v fix $($C $d $X $v)" >> $out
    echo "$n $v fix+R11V278_OFF $(R11V278_OFF=1 $C $d $X $v)" >> $out
    echo "$n $v fix+R11U278_OFF $(R11U278_OFF=1 $C $d $X $v)" >> $out
    for s in $SW; do echo "$n $v fix+$s $(env $s=1 $C $d $X $v)" >> $out; done
  done
done
