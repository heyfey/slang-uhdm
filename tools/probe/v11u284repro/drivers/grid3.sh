#!/bin/bash
# v11u284 grid3.sh <pristine> <law> <fix> <out> [cases root]: every case dir in both views under labels pristine,
# law, fix, fix+R11U284_OFF, fix+R11V284_OFF, fix+R11V284_ALIASSCOPE_OFF, fix+R11V284_ORPHANSIB_OFF; one line per
# case-view and label with rc, uhdm-cmp lines, strict verdict and md5.  Fail-closed on $FENCED (case.sh).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid3.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "${5:-$H/../cases}" && pwd)
P=$1; L=$2; F=$3; O=$4
{ for d in $(cd $C && ls -d ${GRIDGLOB:-*/*/} | sed 's#/$##'); do for v in d e; do
    echo "$d $v pristine $P -"; echo "$d $v law $L -"; echo "$d $v fix $F -"
    for sw in R11U284_OFF R11V284_OFF R11V284_ALIASSCOPE_OFF R11V284_ORPHANSIB_OFF; do echo "$d $v fix+$sw $F $sw"; done
  done; done; } | xargs -P 3 -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
