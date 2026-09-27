#!/bin/bash
# attrib.sh <binary> <sweep> <list of corpus/mode/test> <out> : rerun each row's recorded slang command with R11U180_TRACE=1
set -u; . /tmp/v11u180_scr/env.sh || exit 2
L=$1; SW=$2; LIST=$3; OUT=$4; : > $OUT
while read -r p; do
  corp=$(echo $p | cut -d/ -f1); mode=$(echo $p | cut -d/ -f2); tn=$(echo $p | cut -d/ -f3)
  for f in $FENCED; do [ "$tn" = "$f" ] && { echo "$p FENCED-REFUSED" >> $OUT; continue 2; }; done
  dir=$(cd /tmp/wt_v11u180 && python3 -c "
import sys; sys.path.insert(0,'scripts'); import verify_golden as vg
t = vg.discover_surelog('^$tn\$') if '$corp'=='surelog' else vg.discover_uhdm2rtlil('^$tn\$')
print(t['$tn'][0])")
  cf=$(ls $SW/$corp/$mode/$tn-*/cmds.txt | head -1)
  args=$(grep '^slang:' $cf | head -1 | sed 's/^slang: *[^ ]* //; s/ -o .*$//')
  o=/tmp/v11u180_scr/attrib_$$.uhdm; rm -f $o
  laws=$(cd $dir && eval R11U180_TRACE=1 $L $args -o $o 2>&1 >/dev/null | grep '^R11U180 ' | awk '{print $2}' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')
  echo "$p md5=$(md5sum < $o | cut -c1-12) ${laws:-(no r11u180 firing)}" >> $OUT
done < $LIST
cat $OUT
