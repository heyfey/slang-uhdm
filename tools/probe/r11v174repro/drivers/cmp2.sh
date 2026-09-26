#!/bin/bash
# cmp2 <casedir> <binA> <binB> [ENV=..]: bytes of binA vs binB+env at the same output path
d=$1; a0=$2; b=$3; shift 3
k=$(echo $d$b | md5sum | cut -c1-12); o=/tmp/v11u174_off/$k.uhdm
cd $d || exit
rm -f $o; timeout 300 $a0 dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1; a=$( [ -s $o ] && md5sum < $o | cut -c1-12 || echo NODB)
rm -f $o; timeout 300 env "$@" $b dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1; c=$( [ -s $o ] && md5sum < $o | cut -c1-12 || echo NODB)
rm -f $o
if [ "$a" = "$c" ]; then [ $a = NODB ] && echo "NODB $d" || echo "SAME $d"; else echo "DIFF $d"; fi
