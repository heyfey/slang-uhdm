#!/bin/bash
# v11u255 nondet.sh <n> <case dir>...: n sequential draws per case, view and configuration (pristine, law with
# R11U255_OFF, law); prints the hash histogram of each. Fail-closed on $FENCED.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
n=$1; shift
for c in "$@"; do
  echo "$c" | grep -qwE "$FENCE_RE" && { echo "$c FENCED-REFUSED"; continue; }
  for v in "" --elabuhdm; do
    for cfg in "pristine X=1" "law R11U255_OFF=1" "law X=1"; do set -- $cfg
      h=$(for i in $(seq $n); do o=$S/nd_$$.uhdm; rm -f $o; (cd $c && env $2 $B/$1 dut.sv --single-unit --nobuiltin $v -o $o >/dev/null 2>&1); md5sum < $o | cut -c1-8; done | sort | uniq -c | tr '\n' ' ')
      echo "$(basename $c) ${v:-def} $1/$2: $h"
    done
  done
done
