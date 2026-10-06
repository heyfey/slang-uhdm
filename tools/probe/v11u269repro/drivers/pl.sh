#!/bin/bash
# v11u269 pl.sh <out> <case dir>... : pristine and law (and $PL_EXTRA "TAG:BIN[:ENV=VAL]" configs) on every case in both
# views; one line per case-view-configuration with the exit code (case.sh fields). Binaries from $B.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    for x in ${PL_EXTRA:-}; do t=${x%%:*}; r=${x#*:}; b=${r%%:*}; e=; [ "$b" != "$r" ] && e=${r#*:}
      EL=$el bash $D/case.sh $c $t $B/$b $e | sed "s/^/$t /" >> $out; done
  done
done
