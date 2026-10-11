#!/bin/bash
# r11u282 grid.sh <binary> <case dir>...: one line per case-view (views d and e):
#   <case dir> <view> rc=<exit code> cmp=<uhdm-cmp lines> <strict verdict> md5=<database md5>
# Fail-closed on $FENCED (case.sh refuses fenced paths); runs 3 case-views at a time.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid.sh: FENCED unset" >&2; exit 2; }
H=$(dirname "$(realpath "$0")")
bin=$1; shift
for d in "$@"; do for v in d e; do echo "$d $v"; done; done |
  xargs -P 3 -L 1 bash -c 'echo "$0 $1 $(bash '"$H"'/case.sh "$0" '"$bin"' "$1" 5)"' | sort
