#!/bin/bash
# v11u298 grid3.sh <pristine> <law> <fix> <out> [<case dir glob under cases/>]: every case dir in both views, one line
# per case-view and label: pristine, law, law+R11U298_OFF, each law switch, fix, fix+R11V298_OFF, fix+R11U298_OFF and
# each refinement switch.  `<case> <view> <label> rc=.. cmp=.. <strict> md5=..`.  Fail-closed on $FENCED (case.sh).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid3.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); C=${CB:-$(cd "$H/../cases" && pwd)}
P=$1; L=$2; F=$3; O=$4
{ for d in $(cd $C && ls -d ${GRIDGLOB:-*/*/} | sed 's#/$##'); do for v in d e; do
    echo "$d $v pristine $P -"; echo "$d $v law $L -"; echo "$d $v law+R11U298_OFF $L R11U298_OFF"
    for sw in R11U298_NESTCASTTP_OFF R11U298_QBTERN_OFF R11U298_CLSTPOBJ_OFF R11U298_CLSTPOOB_OFF; do echo "$d $v law+$sw $L $sw"; done
    echo "$d $v fix $F -"; echo "$d $v fix+R11V298_OFF $F R11V298_OFF"; echo "$d $v fix+R11U298_OFF $F R11U298_OFF"
    for sw in R11V298_CASITE_OFF R11V298_NESTCLS_OFF; do echo "$d $v fix+$sw $F $sw"; done
  done; done; } | xargs -P 3 -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
