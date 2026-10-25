#!/bin/bash
# acmp.sh <absdir> [args...]: pristine vs law11 on dut.sv in an absolute dir (outputs in scratch), trace count
c=$1; shift; k=$(echo $c | tr / _); o=/tmp/r11u430_pc/$k; rm -rf $o; mkdir -p $o/tr
B=${LAWBIN:-/tmp/r11u430_bin/law11}; P=/tmp/r11u430_bin/pristine
[ -x "$B" ] && [ -x "$P" ] || exit 2
(cd $c && timeout 300 $P dut.sv "$@" -o $o/p.uhdm >/dev/null 2>&1; echo $? > $o/prc)
(cd $c && R11U430_TRACE=$o/tr timeout 300 $B dut.sv "$@" -o $o/l.uhdm >/dev/null 2>&1; echo $? > $o/lrc)
mp=$(md5sum < $o/p.uhdm 2>/dev/null | cut -c1-8); ml=$(md5sum < $o/l.uhdm 2>/dev/null | cut -c1-8)
echo "$c prc=$(cat $o/prc) lrc=$(cat $o/lrc) $([ "$mp" = "$ml" ] && echo SAME || echo DIFF) fires=$(cat $o/tr/* 2>/dev/null | grep -vc '^OUT') $(cat $o/tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort | uniq -c | tr '\n' ' ')"
