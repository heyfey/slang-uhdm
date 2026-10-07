#!/bin/bash
# v11u278 runset.sh <out.txt> <label> <binary> <case dir>...: every case dir in both views on one
# binary (env passed through, e.g. a switch), one line per case-view with its exit code:
# <case> <view> <label> rc=.. cmp=.. <strict verdict> md5=..  Fail-closed on $FENCED (case.sh refuses fenced paths).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "runset.sh: FENCED unset" >&2; exit 2; }
out=$1; lab=$2; bin=$3; shift 3
C=$(dirname $(realpath $0))/case.sh
: > $out
for d in "$@"; do
  n=$(realpath $d | sed 's#.*/tools/probe/##')
  for v in d e; do echo "$n $v $lab $($C $d $bin $v)" >> $out; done
done
