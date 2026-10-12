#!/bin/bash
# v11u302 gridv.sh <cases root> <pristine> <law> <fix> <out>: every case dir <root>/*/* in both views, one line per
# case-view and label `<case> <view> <label> rc=.. cmp=.. <strict verdict> md5=..`; labels pristine, law, fix,
# fix+R11U302_OFF, fix+R11V302_OFF, fix+R11V302_LITVAL_OFF, fix+R11V302_SOLEWRITER_OFF.  Fail-closed on $FENCED (case.sh).
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
C=$(cd "$1" && pwd); P=$2; L=$3; F=$4; O=$5
{ for d in $(cd $C && ls -d */* | grep -vwE "$(echo $FENCED | tr ' ' '|')"); do for v in d e; do
    echo "$d $v pristine $P -"; echo "$d $v law $L -"; echo "$d $v fix $F -"
    for sw in R11U302_OFF R11V302_OFF R11V302_LITVAL_OFF R11V302_SOLEWRITER_OFF; do echo "$d $v fix+$sw $F $sw"; done
  done; done; } | xargs -P 4 -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
