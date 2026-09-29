#!/bin/bash
# vgrid.sh <tag> <binary> [ENV=VAL ...] : every case under cases/ in both views, 3 jobs; one line per case-view.
H=$(cd "$(dirname "$0")" && pwd); . $H/env.sh || exit 2
tag=$1; bin=$2; shift 2
find $H/../cases -name dut.sv | sort | while read f; do d=$(dirname $f); echo "0 $d"; echo "1 $d"; done |
  xargs -P 3 -L 1 bash -c 'EL=$0 '$H'/vcase.sh $1 '$tag' '$bin' '"$*"' </dev/null'
