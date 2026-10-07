#!/bin/bash
# (v11u280: copied from r11u280repro/drivers)
# r11u280 grid.sh <out.txt> <pristine bin> <law bin> <case dir>...: every case dir in
# both views on pristine, the law, the law with R11U280_OFF and the law with each
# law's own switch off.  One line per run: <case> <view> <variant> rc=.. cmp=.. <verdict> md5=..
# (the exit code is on every line).  Fail-closed on $FENCED (case.sh refuses a fenced path).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid.sh: FENCED unset" >&2; exit 2; }
out=$1; P=$2; L=$3; shift 3
C=$(dirname $(realpath $0))/case.sh
SW=${R280_SW:?"grid.sh: R280_SW (the law switches) unset"}
: > $out
for d in "$@"; do
  n=$(echo $d | sed 's#.*/tools/probe/##')
  for v in d e; do
    echo "$n $v pristine $($C $d $P $v)" >> $out
    echo "$n $v law $($C $d $L $v)" >> $out
    echo "$n $v law+R11U280_OFF $(R11U280_OFF=1 $C $d $L $v)" >> $out
    for s in $SW; do echo "$n $v law+$s $(env $s=1 $C $d $L $v)" >> $out; done
  done
done
