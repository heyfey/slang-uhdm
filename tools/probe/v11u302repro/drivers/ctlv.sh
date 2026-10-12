#!/bin/bash
# v11u302 ctlv.sh <path list of dut.sv relative to tools/probe> <out> <bin>...: byte controls; the path list is filtered
# again by $FENCED (word boundary) before any file is opened; both views of each case dir on every binary, one line
# `<case> <view> <binary basename> rc=.. cmp=.. <strict> md5=..` per case-view and binary.
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2; T=$(cd "$H/../.." && pwd)
LST=$1; O=$2; shift 2
grep -vP "$FENCERE" $LST | sed 's#/dut.sv$##' | while read -r d; do for v in d e; do for b in "$@"; do echo "$d $v $b"; done; done; done |
  xargs -P ${NP:-3} -L 1 bash -c 'echo "$0 $1 $(basename $2) $(bash '"$H"'/case.sh '"$T"'/$0 $2 $1 5)"' | sort > $O
wc -l < $O
