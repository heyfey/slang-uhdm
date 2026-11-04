#!/bin/bash
# away.sh <listfile of dut.sv paths relative to the worktree> <binA> <binB> <out>:
# exit code and output md5 of both binaries per case dir (no golden).
L=$1; A=$2; B=$3; O=$4; : > $O
while read -r p <&3; do
  d=/tmp/wt_r11u487/$(dirname "$p"); W=/tmp/r11u487_away/$(dirname "$p"); mkdir -p "$W"
  F=dut.sv; [ -f "$d/FILES" ] && F=$(cat "$d/FILES")
  for t in a b; do
    bin=$A; [ $t = b ] && bin=$B
    rm -f "$W/$t.uhdm"; (cd "$d" && timeout 300 "$bin" $F --single-unit --nobuiltin -o "$W/$t.uhdm" > "$W/$t.log" 2>&1 </dev/null); eval rc$t=$?
    eval m$t=$(md5sum < "$W/$t.uhdm" 2>/dev/null | cut -c1-8)
  done
  echo "$(dirname "$p") rcA=$rca rcB=$rcb $([ "$ma" = "$mb" ] && echo same || echo MOVED)" >> $O
done 3< "$L"
