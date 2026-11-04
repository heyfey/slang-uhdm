#!/bin/bash
# away1.sh <dir relative to worktree>: rc and md5 of pristine and law
p=$1; d=/tmp/wt_v11u489/$p; W=/tmp/v11u489_away/$p; mkdir -p "$W"
F=dut.sv; [ -f "$d/FILES" ] && F=$(cat "$d/FILES")
for t in a b; do
  bin=/tmp/v11u489_bin/pristine; [ $t = b ] && bin=/tmp/v11u489_bin/law
  rm -f "$W/$t.uhdm"; (cd "$d" && timeout 300 "$bin" $F --single-unit --nobuiltin -o "$W/$t.uhdm" > "$W/$t.log" 2>&1 </dev/null); eval rc$t=$?
  eval m$t=$(md5sum < "$W/$t.uhdm" 2>/dev/null | cut -c1-8)
done
echo "$p rcA=$rca rcB=$rcb $([ "$ma" = "$mb" ] && echo same || echo MOVED)"
