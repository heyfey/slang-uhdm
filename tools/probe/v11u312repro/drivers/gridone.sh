#!/bin/bash
# v11u312 gridone.sh <casesroot> <label> <binary> <out> [ENVVAR]: every case dir under <casesroot>/*/* in both views
# with one binary (optionally one switch set to 1); one line per case-view: `<G/case> <view> <label> rc=.. cmp=.. <strict> md5=..`.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "gridone.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "$1" && pwd); lab=$2; B=$3; O=$4; sw=${5:--}
[ -x "$B" ] || { echo "gridone: binary" >&2; exit 2; }
for d in $(cd $C && ls -d ${GRIDGLOB:-*/*/} | sed 's#/$##'); do for v in d e; do echo "$d $v $lab $B $sw"; done; done |
 xargs -P ${GRIDJ:-2} -L 1 bash -c 'if [ "$4" != - ]; then export $4=1; fi; echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$C"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
