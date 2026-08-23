#!/bin/bash
set -u
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CT=${CT:?control workdir}
NW=${NW:?fresh workdir}
OUT=${OUT:-/tmp/v102_attr}; mkdir -p $OUT
norm(){ sed -e '1d' -e 's/, id:[0-9]*//g' -e 's/\bid:[0-9]*//g' -e "s#$CT##g" -e "s#$NW##g"; }
for rel in "$@"; do
  p=$CT/$rel/slang.uhdm; n=$NW/$rel/slang.uhdm
  [ -f "$p" ] && [ -f "$n" ] || { echo "MISS $rel"; continue; }
  $D "$p" | norm | sort > $OUT/$(echo $rel|tr / _).pris.srt
  $D "$n" | norm | sort > $OUT/$(echo $rel|tr / _).ship.srt
  a=$OUT/$(echo $rel|tr / _).pris.srt; b=$OUT/$(echo $rel|tr / _).ship.srt
  echo "=== $rel  order-blind diff lines: $(diff $a $b | grep -c '^[<>]' ; true)"
  diff $a $b | grep '^[<>]' | sed 's/^\(.\) *//' | sort | uniq -c | sort -rn | head -12
done
