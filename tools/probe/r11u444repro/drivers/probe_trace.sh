#!/bin/bash
# probe_trace.sh <binary> <tracedir>: runs the binary with R11U444_TRACE on every tests/probe case
# (dut.sv --single-unit --nobuiltin, as check_probe.py does) and prints the firing count.
B=$1; T=$2; [ -x "$B" ] || exit 2; mkdir -p $T /tmp/r11u444_scr/ptr
find /tmp/wt_r11u444/tests/probe -name dut.sv | grep -v -F -f /tmp/r11u444_scratch/fenced.txt > /tmp/r11u444_scr/ptr/list
one(){ d=$(dirname $1); k=$(echo $d | sed 's|/|_|g'); (cd $d && R11U444_TRACE=$2 timeout 300 $3 dut.sv --single-unit --nobuiltin -o /tmp/r11u444_scr/ptr/$k.uhdm >/dev/null 2>&1 </dev/null); rm -f /tmp/r11u444_scr/ptr/$k.uhdm; }
export -f one
xargs -a /tmp/r11u444_scr/ptr/list -P 3 -I{} bash -c 'one "$@"' _ {} $T $B
echo "cases $(wc -l < /tmp/r11u444_scr/ptr/list) tracefiles $(ls $T | wc -l) firings $(cat $T/* 2>/dev/null | grep -vc '^OUT ')"
