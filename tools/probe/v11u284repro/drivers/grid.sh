#!/bin/bash
# v11u284 grid.sh <pristine bin> <law bin> <out> [SWITCH ...]: every case dir under cases/ (or $GRIDGLOB) in both
# views, one line per case-view and label: `<case> <view> <label> rc=.. cmp=.. <strict verdict> md5=..`.  Labels:
# pristine, law, law+R11U284_OFF and law+<SWITCH> for each extra argument.  Fail-closed on $FENCED (case.sh).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "$H/../cases" && pwd)
P=$1; L=$2; O=$3; shift 3
{ for d in $(cd $C && ls -d ${GRIDGLOB:-*/*/} | sed 's#/$##'); do for v in d e; do
    echo "$d $v pristine $P -"
    echo "$d $v law $L -"
    echo "$d $v law+R11U284_OFF $L R11U284_OFF"
    for sw in "$@"; do echo "$d $v law+$sw $L $sw"; done
  done; done; } | xargs -P 3 -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
