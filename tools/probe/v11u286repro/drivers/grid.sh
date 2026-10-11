#!/bin/bash
# v11u286 grid.sh <label> <binary> [env assignments...]: every case dir under cases/ in both views, one line per
# case-view: <case> <view> <label> rc=.. cmp=.. <strict verdict> md5=..  (fail-closed on $FENCED through case.sh)
HERE=$(cd "$(dirname "$0")" && pwd); source "$HERE/env.sh" || exit 3
L=$1; B=$2; shift 2
for d in $(cd "$HERE/.." && ls -d ${PAT:-cases/*/*/} | sort); do for v in d e; do
  echo "${d%/} $v $L $(env "$@" bash "$HERE/case.sh" "$HERE/../$d" "$B" $v)"
done; done
