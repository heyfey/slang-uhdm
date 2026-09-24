#!/bin/bash
# sw.sh <case dir> : pristine vs fix2 with R11U124_OFF=1 ; law vs fix2 with R11V124_QSPANPHYS_OFF+R11V124_AGGRNGBRACE_OFF
c=$1; o=/tmp/v11u124_sw/$(echo $c | sed 's#/#_#g'); mkdir -p $o
cd $c
/tmp/v11u124_bin/pris.bin dut.sv --single-unit --nobuiltin -o $o/p.uhdm >/dev/null 2>&1
/tmp/v11u124_bin/law.bin dut.sv --single-unit --nobuiltin -o $o/l.uhdm >/dev/null 2>&1
R11U124_OFF=1 /tmp/v11u124_bin/fix2.bin dut.sv --single-unit --nobuiltin -o $o/off.uhdm >/dev/null 2>&1
R11V124_QSPANPHYS_OFF=1 R11V124_AGGRNGBRACE_OFF=1 /tmp/v11u124_bin/fix2.bin dut.sv --single-unit --nobuiltin -o $o/voff.uhdm >/dev/null 2>&1
/tmp/v11u124_bin/fix2.bin dut.sv --single-unit --nobuiltin -o $o/f.uhdm >/dev/null 2>&1
a=$(cmp -s $o/p.uhdm $o/off.uhdm && echo OFF=PRIS || echo OFF!=PRIS)
b=$(cmp -s $o/l.uhdm $o/voff.uhdm && echo VOFF=LAW || echo VOFF!=LAW)
d=$(cmp -s $o/l.uhdm $o/f.uhdm && echo FIX=LAW || echo FIX!=LAW)
echo "$c $a $b $d"
