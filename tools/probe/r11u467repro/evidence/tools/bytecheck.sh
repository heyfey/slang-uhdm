#!/bin/bash
# bytecheck.sh <rel dut.sv under tools/probe>: pristine vs law1 bytes and exit codes
d=/home/heyfey/git-repos/slang-uhdm/tools/probe/$(dirname $1); o=/tmp/r11u467_bc/$(dirname $1); mkdir -p $o
rm -f $o/p.uhdm $o/l.uhdm
(cd $d && /tmp/r11u467_bin/pristine dut.sv --single-unit --nobuiltin -o $o/p.uhdm >/dev/null 2>&1); a=$?
(cd $d && /tmp/r11u467_bin/law1 dut.sv --single-unit --nobuiltin -o $o/l.uhdm >/dev/null 2>&1); b=$?
if [ $a != $b ]; then echo "RC $a->$b $1"; elif cmp -s $o/p.uhdm $o/l.uhdm; then echo "SAME rc=$a $1"; else echo "MOVE rc=$a $1"; fi
