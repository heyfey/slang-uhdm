#!/bin/bash
# earlier.sh <listfile>: per earlier case dir, pristine vs verified md5 and exit code (files.lst when present, else dut.sv)
source /tmp/wt_v11u460/tools/probe/v11u460repro/drivers/env.sh || exit 1
O=/tmp/v11u460_earlier; mkdir -p $O
while read c; do
  [ -d "$c" ] || continue
  if [ -f "$c/files.lst" ]; then F=$(cat "$c/files.lst" | tr '\n' ' '); else F=dut.sv; fi
  k=$(echo "$c" | md5sum | cut -c1-12)
  r(){ rm -f $O/$k.$1.uhdm; (cd "$c" && $2 $F -o $O/$k.$1.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $O/$k.$1.uhdm 2>/dev/null | cut -c1-8)"; }
  p=$(r p $PRIS); v=$(r v $VER)
  echo "$c pris=$p ver=$v $([ "$p" = "$v" ] && echo SAME || echo MOVED)"
done < "$1"
