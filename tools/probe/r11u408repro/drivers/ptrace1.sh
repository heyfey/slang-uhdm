#!/bin/bash
# ptrace1.sh <dut.sv relpath>: run the law binary with trace on one probe case
f=$1; k=$(echo "$f" | tr '/' '_'); t=/tmp/r11u408_ptrace/$k; mkdir -p $t
cd /tmp/wt_r11u408/$(dirname $f) && R11U408_TRACE=$t timeout 120 /tmp/r11u408_bin/w5.bin dut.sv --single-unit --nobuiltin -o $t/o.uhdm > /dev/null 2>&1
rm -f $t/o.uhdm
