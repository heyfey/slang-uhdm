#!/bin/bash
# away.sh <list-of-case-dirs> <binA> <binB> <out>: rc + md5 of both binaries per dir (no golden)
L=$1; A=$2; B=$3; O=$4; : > $O
while read -r c <&3; do
  [ -d "$c" ] || continue
  W=/tmp/r11u483_away$c; mkdir -p "$W"
  rm -f $W/a.uhdm $W/b.uhdm
  (cd "$c" && "$A" dut.sv --single-unit --nobuiltin -o $W/a.uhdm >/dev/null 2>&1 </dev/null); ra=$?
  (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o $W/b.uhdm >/dev/null 2>&1 </dev/null); rb=$?
  ma=$(md5sum < $W/a.uhdm 2>/dev/null | cut -c1-8); mb=$(md5sum < $W/b.uhdm 2>/dev/null | cut -c1-8)
  echo "${c#/home/heyfey/git-repos/slang-uhdm/tools/probe/} rcA=$ra rcB=$rb $([ "$ma" = "$mb" ] && echo same || echo MOVED)" >> $O
done 3< "$L"
