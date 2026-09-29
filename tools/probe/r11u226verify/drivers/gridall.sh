#!/bin/bash
# gridall.sh <outdir> <casedir>...: drivers/grid.py on every case in both views, three cases at a time; one file per
# case-view under <outdir> (<family>_<case>[_el].txt).  Fail-closed on $FENCED (env.sh, grid.py, case.sh).
source "$(dirname "$0")/env.sh" || exit 2
O=$1; shift; mkdir -p $O
D=$(cd "$(dirname "$0")" && pwd)
for c in "$@"; do c=$(realpath $c); n=$(echo $c | sed 's#.*/cases/##; s#/#_#g')
  echo "$c $n ''"; echo "$c ${n}_el --el"; done | xargs -P ${P:-3} -L 1 bash -c 'python3 '"$D"'/grid.py $2 $0 > '"$O"'/$1.txt 2>&1'
