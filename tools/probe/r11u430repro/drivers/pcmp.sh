#!/bin/bash
# pcmp.sh <casedir(rel to wt)> : run pristine and law binary, print md5s and trace hits
c=$1; W=/tmp/wt_r11u430; k=$(echo $c | tr / _); o=/tmp/r11u430_pc/$k; rm -rf $o; mkdir -p $o/tr
B=${LAWBIN:-/tmp/r11u430_bin/law12}
[ -x "$B" ] || exit 2
(cd $W/$c && timeout 300 /tmp/r11u430_bin/pristine dut.sv --single-unit --nobuiltin -o $o/p.uhdm >/dev/null 2>&1; echo $? > $o/prc)
(cd $W/$c && R11U430_TRACE=$o/tr timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/l.uhdm >/dev/null 2>&1; echo $? > $o/lrc)
mp=$(md5sum < $o/p.uhdm 2>/dev/null | cut -c1-8); ml=$(md5sum < $o/l.uhdm 2>/dev/null | cut -c1-8)
n=$(cat $o/tr/* 2>/dev/null | grep -vc '^OUT')
echo "$c prc=$(cat $o/prc) lrc=$(cat $o/lrc) $([ "$mp" = "$ml" ] && echo SAME || echo DIFF) fires=$n"
