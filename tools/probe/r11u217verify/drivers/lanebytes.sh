#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208) lanebytes.sh <sweep A> <sweep B>: byte comparison of the probe databases (<W>/probe/*.uhdm) and of the
# downstream slang-lane databases (<W>/downstream/<test>/slang*/*.uhdm) of two gate sweeps; paths naming a fenced test
# are dropped by word boundary BEFORE any file is opened (fail-closed on $FENCED, drivers/env.sh).  Prints per lane
# the number of databases, the fenced paths skipped and the movers (at most 20 named).
source "$(dirname "$0")/env.sh" || exit 2
A=$1; B=$2
for lane in probe downstream; do
  la=$(mktemp /tmp/r11u217_lbA.XXXX); lb=$(mktemp /tmp/r11u217_lbB.XXXX)
  for W in $A $B; do
    o=$la; [ $W = $B ] && o=$lb
    (cd $W/$lane && if [ $lane = probe ]; then find . -name '*.uhdm'; else find . -path '*slang*' -name '*.uhdm'; fi) | sort > $o.all
    grep -vP "$FENCE_RE" $o.all > $o.list; echo "$(( $(wc -l < $o.all) - $(wc -l < $o.list) ))" > $o.skip
    (cd $W/$lane && xargs -r md5sum < $o.list) > $o
  done
  n=$(wc -l < $la); m=$(diff $la $lb | grep -c '^<')
  echo "$lane databases=$n fenced_skipped=$(cat $la.skip) movers=$m $(diff $la $lb | grep '^<' | awk '{print $3}' | head -20 | tr '\n' ' ')"
  rm -f $la $lb $la.* $lb.*
done
