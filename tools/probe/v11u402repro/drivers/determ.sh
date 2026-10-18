#!/bin/bash
# determ.sh <binary> : three concurrent draws per row-mode, one md5 per draw (cmds.txt of the refined sweep, run in the test's source dir)
. /tmp/v11u402_env.sh
B=$1; O=/tmp/v11u402_det; mkdir -p $O
for rm in default/Earlgrey_0_1 testflags/Earlgrey_0_1 default/MiniAmiq testflags/SeqDriver; do
  c=$(ls -d /tmp/v11u402_wdF/surelog/$rm-*/cmds.txt 2>/dev/null | head -1); name=${rm#*/}
  sl=$(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -name "$name.sl" | head -1); src=$(dirname $sl)
  cmd=$(grep '^slang:' $c | sed 's/^slang: *//'); rest=$(echo "$cmd" | cut -d' ' -f2-)
  for i in 1 2 3; do r=$(echo "$rest" | sed "s#-o [^ ]*#-o $O/$(echo $rm|tr / _)_$i.uhdm#"); (cd $src && timeout 1200 $B $r > /dev/null 2>&1) & done; wait
  echo "$rm $(md5sum $O/$(echo $rm|tr / _)_*.uhdm | awk '{print $1}' | sort | uniq -c | tr '\n' ' ') sweep=$(md5sum $(dirname $c)/slang.uhdm | cut -c1-32)"
done
