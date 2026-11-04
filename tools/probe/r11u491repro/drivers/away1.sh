#!/bin/bash
# away1.sh <dir relative to /tmp/wt_r11u491> <lawbin>: rc and md5 of pristine and law
p=$1; L=$2; d=/tmp/wt_r11u491/$p; W=/tmp/r11u491_away/$p; mkdir -p "$W"
[ -x "$L" ] || exit 1
F=dut.sv; [ -f "$d/FILES" ] && F=$(cat "$d/FILES")
for t in a b; do
  bin=/tmp/r11u491_bin/pristine; [ $t = b ] && bin=$L
  rm -f "$W/$t.uhdm"; (cd "$d" && timeout 300 "$bin" $F --single-unit --nobuiltin -o "$W/$t.uhdm" > "$W/$t.log" 2>&1 </dev/null); eval rc$t=$?
  eval m$t=$(md5sum < "$W/$t.uhdm" 2>/dev/null | cut -c1-8)
done
echo "$p rcA=$rca rcB=$rcb $([ "$ma" = "$mb" ] && echo same || echo MOVED)"
