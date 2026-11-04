#!/bin/bash
# away2.sh <list> <out> <binA> <binB>: rc + md5 per dir on two binaries (no golden)
L=$1; O=$2; A=$3; B=$4; : > $O
for b in $A $B; do [ -x $b ] || exit 1; done
while read -r c <&3; do
  [ -f "$c/dut.sv" ] || continue
  W=/tmp/v11u483_away2$c; mkdir -p "$W"; rm -f $W/a.uhdm $W/b.uhdm
  (cd "$c" && timeout 300 $A dut.sv --single-unit --nobuiltin -o $W/a.uhdm >/dev/null 2>&1 </dev/null); ra=$?
  (cd "$c" && timeout 300 $B dut.sv --single-unit --nobuiltin -o $W/b.uhdm >/dev/null 2>&1 </dev/null); rb=$?
  ma=$(md5sum < $W/a.uhdm 2>/dev/null | cut -c1-8); mb=$(md5sum < $W/b.uhdm 2>/dev/null | cut -c1-8)
  echo "${c#/home/heyfey/git-repos/slang-uhdm/tools/probe/} rc=$ra/$rb $([ "$ma" = "$mb" ] && echo same || echo MOVED)" >> $O
done 3< "$L"
