#!/bin/bash
# bc1.sh <dir>: law vs ver1 bytes and exit codes
c=$1; [ -d "$c" ] || { echo "$c NODIR"; exit; }; W=/tmp/v11u464_bc$c; mkdir -p $W; rm -f $W/l.uhdm $W/v.uhdm
F=dut.sv; [ -f $c/FILES ] && F=$(cat $c/FILES)
(cd $c && timeout 300 /tmp/v11u464_bin/law $F --single-unit --nobuiltin -o $W/l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
(cd $c && timeout 300 /tmp/v11u464_bin/ver1 $F --single-unit --nobuiltin -o $W/v.uhdm >/dev/null 2>&1 </dev/null); rv=$?
if cmp -s $W/l.uhdm $W/v.uhdm; then m=same; else m=MOVED; fi
echo "$c $rl $rv $m"
