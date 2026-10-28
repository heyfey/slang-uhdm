#!/bin/bash
# cenprobe.sh <binary> <case rel>: run the binary on one probe case with the 455 trace; print key, rc, firings, moved vs control
B=$1; rel=$2; key=${rel//\//__}
[ -x "$B" ] || { echo "nobin"; exit 2; }
d=${PROBE_ROOT:-/home/heyfey/git-repos/slang-uhdm/tests/probe}/$rel
o=/tmp/r11u455_cen/probe/$key.uhdm; rm -f $o
td=/tmp/r11u455_cen/trp/$key; rm -rf $td; mkdir -p $td
(cd $d && R11U455_TRACE=$td timeout 300 $B dut.sv --single-unit --nobuiltin -o $o > /dev/null 2>&1); rc=$?
n=$(cat $td/* 2>/dev/null | grep -c '^OOBPKGCLONE'); 
c=${CTL_ROOT:-/tmp/intr11u452/probe}/$key.uhdm
if [ -f $c ] && [ -f $o ]; then cmp -s $c $o && m=same || m=MOVED; else m=nocontrol; fi
echo "$rel rc=$rc fire=$n $m"
