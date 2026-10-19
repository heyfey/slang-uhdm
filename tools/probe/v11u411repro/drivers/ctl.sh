#!/bin/bash
# ctl.sh <dut.sv rel>: law vs verified exit code + bytes
d=$(dirname /tmp/wt_v11u411/tools/probe/$1); t=$(echo $1 | md5sum | cut -c1-12)
r(){ rm -f /tmp/v11u411_scr/c_$2_$t.uhdm; (cd $d && /tmp/v11u411_bin/$1 dut.sv --single-unit --nobuiltin -o /tmp/v11u411_scr/c_$2_$t.uhdm >/dev/null 2>&1); echo "$? $(md5sum < /tmp/v11u411_scr/c_$2_$t.uhdm 2>/dev/null | cut -c1-8)"; }
a=$(r law L); b=$(r verified V); rm -f /tmp/v11u411_scr/c_?_$t.uhdm
[ "$a" = "$b" ] && echo "SAME $1 $a" || echo "DIFF $1 $a -> $b"
