#!/bin/bash
# usage: sw.sh <ENV assignment> <ref binary name in grid (out_<ref>.uhdm)>
envv=$1; ref=$2; same=0; diff=0; lst=""
for d in /tmp/v11u447_grid/*/; do
  [ -f $d/dut.sv ] || continue
  rm -f $d/sw.uhdm
  (cd $d && env $envv /tmp/v11u447_bin/ver dut.sv --single-unit --nobuiltin -o sw.uhdm >/dev/null 2>&1 </dev/null); rc=$?
  rrc=$(cd $d; [ -f out_$ref.uhdm ] && echo y)
  a=$(md5sum < $d/sw.uhdm 2>/dev/null); b=$(md5sum < $d/out_$ref.uhdm 2>/dev/null)
  if [ "$a" == "$b" ]; then same=$((same+1)); else diff=$((diff+1)); lst="$lst $(basename $d)"; fi
done
echo "$envv vs $ref: same=$same diff=$diff$lst"
