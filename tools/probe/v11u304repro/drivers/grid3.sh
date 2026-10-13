#!/bin/bash
# v11u304 grid3.sh <pristine> <law> <fix> <out> [SWITCH ...]: every case dir under cases/ (GRIDGLOB narrows) in both
# views on pristine, law, fix, fix+R11U304_OFF, fix+R11V304_OFF and fix+<SWITCH> for each extra argument; one line
# `<case> <view> <label> rc=.. cmp=.. <strict verdict> md5=..` each (case.sh).  Fail-closed on $FENCED (env.sh, case.sh).
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
C=$(cd "${CASES:-$H/../cases}" && pwd)  # CASES=<dir> grids another pass's case dirs
P=$1; L=$2; F=$3; O=$4; shift 4
{ for d in $(cd $C && ls -d ${GRIDGLOB:-*/*/} | sed 's#/$##'); do for v in d e; do
    echo "$d $v pristine $P -"; echo "$d $v law $L -"; echo "$d $v fix $F -"
    echo "$d $v fix+R11U304_OFF $F R11U304_OFF"; echo "$d $v fix+R11V304_OFF $F R11V304_OFF"
    for sw in "$@"; do echo "$d $v fix+$sw $F $sw"; done
  done; done; } | xargs -P 3 -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
