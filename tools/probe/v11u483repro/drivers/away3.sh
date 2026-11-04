#!/bin/bash
# away3.sh <list-of-case-dirs> <out>: rc + md5 per dir on pristine, law and verified (no golden)
L=$1; O=$2; : > $O
P=/tmp/v11u483_bin/pristine; A=/tmp/v11u483_bin/law; V=/tmp/v11u483_bin/ver
for b in $P $A $V; do [ -x $b ] || exit 1; done
while read -r c <&3; do
  [ -f "$c/dut.sv" ] || continue
  W=/tmp/v11u483_away$c; mkdir -p "$W"; rm -f $W/p.uhdm $W/a.uhdm $W/v.uhdm
  (cd "$c" && timeout 300 $P dut.sv --single-unit --nobuiltin -o $W/p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd "$c" && timeout 300 $A dut.sv --single-unit --nobuiltin -o $W/a.uhdm >/dev/null 2>&1 </dev/null); ra=$?
  (cd "$c" && timeout 300 $V dut.sv --single-unit --nobuiltin -o $W/v.uhdm >/dev/null 2>&1 </dev/null); rv=$?
  mp=$(md5sum < $W/p.uhdm 2>/dev/null | cut -c1-8); ma=$(md5sum < $W/a.uhdm 2>/dev/null | cut -c1-8); mv=$(md5sum < $W/v.uhdm 2>/dev/null | cut -c1-8)
  echo "${c#/home/heyfey/git-repos/slang-uhdm/tools/probe/} rc=$rp/$ra/$rv PL=$([ "$mp" = "$ma" ] && echo same || echo MOVED) LV=$([ "$ma" = "$mv" ] && echo same || echo MOVED)" >> $O
done 3< "$L"
