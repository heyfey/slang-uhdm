#!/bin/bash
# v11u401 grid.sh <out> [SWITCH ...]: every case dir under cases/ (GRIDGLOB) in both views with the frozen
# pristine and law binaries, law+R11U401_OFF and law+<SWITCH>; one line per case-view and label with rc.
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "$H/../cases" && pwd); source $H/env.sh
export R401_GOLD=/tmp/v11u401_gold R401_OUT=/tmp/v11u401_caseout
P=$VB/slang-uhdm.pris; L=${LAWBIN:-$VB/slang-uhdm.law}; O=$1; shift
{ for d in $(cd $C && ls -d ${GRIDGLOB:-*/*/} | sed 's#/$##'); do for v in d e; do
    echo "$d $v pristine $P -"; echo "$d $v law $L -"; echo "$d $v law+R11U401_OFF $L R11U401_OFF"
    for sw in "$@"; do echo "$d $v law+$sw $L $sw"; done
  done; done; } | xargs -P 2 -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
