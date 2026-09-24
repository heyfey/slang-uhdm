#!/usr/bin/env bash
# probe_fd.sh <wdA> <wdB> <movers.txt>
A=$1; B=$2
cd /tmp/wt_v11u131pris
awk -F' :: ' '{print $1}' $3 | while read rel; do
  f=$(echo $rel | sed 's#/#__#g').uhdm
  g=$(python3 -c "import sys; sys.path.insert(0,'scripts'); import check_probe as cp, verify_golden as vg; print(vg.cache_load(cp.cache_dir('$rel'))[1])")
  echo "$rel $(python3 /tmp/v11u131_drv/firstdiff.py $g $A/probe/$f $B/probe/$f)"
done
