#!/bin/bash
# ctlmd5.sh <dut.sv path relative to tools/probe> : exit code and md5 of the pristine and the law binary's output
# (binaries /tmp/r11u411_bin/pristine and /tmp/r11u411_bin/$LAWBIN, default final2)
f=$1; d=/tmp/wt_r11u411/tools/probe/$(dirname $f); t=$(echo $f | md5sum | cut -c1-12); L=${LAWBIN:-final2}; out="$f"
for b in pristine $L; do
 o=/tmp/r11u411_scr/m_${b}_$t.uhdm; rm -f $o
 (cd $d && timeout 120 /tmp/r11u411_bin/$b $(basename $f) --single-unit --nobuiltin -o $o >/dev/null 2>&1); rc=$?
 out="$out $rc $(md5sum < $o 2>/dev/null | cut -c1-10)"; rm -f $o
done
echo "$out"
