#!/bin/bash
# grid.sh <case dir> [tag=binary[:ENV=VAL]] ...: one case in both views through r11u223repro's case.sh (golden cached
# by content under $S/g; uhdm-cmp; uhdm-strictcmp), one line per tag and view.  Default tags: pris=pristine,
# law=law, fix2=fix2, fix2v=fix2:R11V223_OFF=1, fix2off=fix2:R11U223_OFF=1.
. "$(dirname "$0")/env.sh" || exit 3
export S=${S:-/tmp/v11u223_s}
CS=$REPO/tools/probe/r11u223repro/drivers/case.sh
c=$1; shift; T=("$@"); [ ${#T[@]} = 0 ] && T=(pris=pristine law=law fix2=fix2 fix2v=fix2:R11V223_OFF=1 fix2off=fix2:R11U223_OFF=1)
for el in 0 1; do for t in "${T[@]}"; do
  tag=${t%%=*}; rest=${t#*=}; bin=${rest%%:*}; ev=; [ "$rest" != "$bin" ] && ev=${rest#*:}
  EL=$el bash $CS $c $tag $B/$bin $ev
done; done
