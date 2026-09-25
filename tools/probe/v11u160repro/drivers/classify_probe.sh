#!/bin/bash
# classify_probe.sh <pris_dir> <law_dir> <moverlist>
source $(dirname $0)/env.sh; cd /tmp/wt_v11u160
while read f; do
  rel=$(echo ${f%.uhdm} | sed 's#__#/#g')
  g=$(python3 -c "
import sys; sys.path.insert(0,'scripts'); import check_probe as cp, verify_golden as vg
print(vg.cache_load(cp.cache_dir('$rel'))[1])")
  echo "$rel: $(python3 $(dirname $0)/unmask.py $g $1/$f $2/$f | head -1)"
done < $3
