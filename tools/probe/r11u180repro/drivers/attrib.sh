#!/bin/bash
# attrib.sh <law binary> <movers list (corpus/mode/<test>-<hash>/slang.uhdm lines)> <out.txt> : re-run each corpus
# mover's recorded slang-uhdm command line (from the sweep's cmds.txt, binary swapped) in its test directory with
# R11U180_TRACE=1 and list the r11u180 laws that fire (a fenced name is refused, fail closed).
set -u; . /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
L=$1; LIST=$2; OUT=$3; SW=${SWEEP:-/tmp/r11u180_swB}; : > $OUT
while read -r p; do
  corp=$(echo $p | cut -d/ -f1); mode=$(echo $p | cut -d/ -f2); tn=$(echo $p | cut -d/ -f3 | sed 's/-[0-9a-f]*$//')
  for f in $FENCED; do [ "$tn" = "$f" ] && { echo "$p FENCED-REFUSED" >> $OUT; continue 2; }; done
  dir=$(cd /tmp/wt_r11u180 && python3 -c "
import sys; sys.path.insert(0,'scripts'); import verify_golden as vg
t = vg.discover_surelog('^$tn\$') if '$corp'=='surelog' else vg.discover_uhdm2rtlil('^$tn\$')
print(t['$tn'][0])")
  args=$(grep '^slang:' $SW/$p | head -1 | sed 's/^slang: *[^ ]* //; s/ -o .*$//')
  o=/tmp/r11u180_scr/attrib.uhdm; rm -f $o
  laws=$(cd $dir && eval R11U180_TRACE=1 $L $args -o $o 2>&1 >/dev/null | grep '^R11U180 ' | awk '{print $2}' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')
  echo "$p ${laws:-(no r11u180 firing)}" >> $OUT
done < $LIST
cat $OUT
