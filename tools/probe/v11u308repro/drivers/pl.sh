#!/bin/bash
# r11u308 pl.sh <pristine> <law> <out> <case dir>...: every case dir in both views on both binaries, one line
# per case-view: `<case> <view> P <rc cmp verdict> | L <rc cmp verdict> [MOVE]` (md5s compared).  Fail-closed
# on $FENCED (env.sh, case.sh).
H=$(cd "$(dirname "$0")" && pwd)
source "$H/env.sh" || exit 2
P=$1; L=$2; O=$3; shift 3
for d in "$@"; do for v in d e; do echo "$d $v"; done; done | xargs -P 3 -L 1 bash -c '
  p=$(bash '"$H"'/case.sh $0 '"$P"' $1 5); l=$(bash '"$H"'/case.sh $0 '"$L"' $1 5)
  pm=${p##*md5=}; lm=${l##*md5=}; m=""; [ "$pm" != "$lm" ] && m=MOVE
  echo "$0 $1 P ${p% md5=*} | L ${l% md5=*} $m"' | sort > $O
wc -l < $O
