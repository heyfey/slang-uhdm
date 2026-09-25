#!/bin/bash
# pcells.sh <off sweep> <on sweep> <probe case>...: per-field cell classification (cells.py) of a probe case
# between two gate sweeps, against its cached golden.
source $(dirname $0)/env.sh
for c in "${@:3}"; do
  k=$(echo $c | sed 's#/#__#g'); t=/tmp/r11u170_tmp/pc/$k; mkdir -p $t
  g=$(cd /tmp/wt_r11u170 && python3 -c "import sys; sys.path.insert(0,'scripts'); import check_probe as cp; print(cp.cache_dir('$c'))")/golden.uhdm
  $STRICT_CMP --max 100000 $g $1/probe/$k.uhdm > $t/off.strict; $STRICT_CMP --max 100000 $g $2/probe/$k.uhdm > $t/on.strict
  echo "$c: $(python3 $(dirname $0)/cells.py $t on off | head -1) | off: $(grep -o 'objects_differing.*' $t/off.strict) on: $(grep -o 'objects_differing.*' $t/on.strict)"
done
