#!/bin/bash
# cenprobe.sh <binary> <case rel>: run one probe case traced; print rel, rc, 457 firings
B=$1; rel=$2; key=${rel//\//__}
[ -x "$B" ] || { echo "nobin"; exit 2; }
d=/home/heyfey/git-repos/slang-uhdm/tests/probe/$rel
o=/tmp/r11u457_cen/probe/$key.uhdm; rm -f $o
td=/tmp/r11u457_cen/tr/$key; rm -rf $td; mkdir -p $td
(cd $d && R11U457_TRACE=$td timeout 300 $B dut.sv --single-unit --nobuiltin -o $o > /dev/null 2>&1); rc=$?
n=$(cat $td/* 2>/dev/null | grep -v '^OUT' | grep -v '_ABSTAIN' | wc -l)
a=$(cat $td/* 2>/dev/null | grep -c '_ABSTAIN')
c=/tmp/intr11u455/probe/$key.uhdm
if [ -f $c ] && [ -f $o ]; then cmp -s $c $o && m=same || m=MOVED; else m=nocontrol; fi
echo "$rel rc=$rc fire=$n abstain=$a $m"
