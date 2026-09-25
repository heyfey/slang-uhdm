#!/bin/bash
# swcheck.sh <binary>: for every law-sweep mover row (u2r) and probe mover, run <binary> under each switch set and
# compare with the pristine sweep database (P) and the law sweep database (L).
B=$1; U=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
for mode in default testflags; do for t in FunctionParam SelectGivenBySelectOnParameterInFunction func_local_array SumOfParametersInNestedForLoops LocalParamInNestedForLoops simple_package; do
  d=$(ls -d /tmp/r11u148_swP/uhdm2rtlil/$mode/$t-*); r=$(basename $d)
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *[^ ]* //; s/ -o .*//')
  line="$mode/$t"
  for sw in NONE R11U148_OFF R11U148_E_OFF R11U148_E2_OFF R11U148_I_OFF; do
    o=/tmp/r11u148_sw.uhdm; rm -f $o
    if [ $sw = NONE ]; then (cd $U/$t && $B $args -o $o >/dev/null 2>&1); else (cd $U/$t && env $sw=1 $B $args -o $o >/dev/null 2>&1); fi
    v=$(cmp -s $o $d/slang.uhdm && echo P || (cmp -s $o /tmp/r11u148_swL/uhdm2rtlil/$mode/$r/slang.uhdm && echo L || echo X))
    line="$line $sw=$v"
  done
  echo $line
done; done
for rel in r10v200repro/v200_5_modmat r11v48repro/vc1 r11v48repro/vc2; do
  f=$(echo $rel | sed 's#/#__#').uhdm; line="probe/$rel"
  for sw in NONE R11U148_OFF R11U148_E_OFF R11U148_E2_OFF R11U148_I_OFF; do
    o=/tmp/r11u148_sw.uhdm; rm -f $o
    if [ $sw = NONE ]; then (cd /tmp/wt_r11u148/tests/probe/$rel && $B dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); else (cd /tmp/wt_r11u148/tests/probe/$rel && env $sw=1 $B dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); fi
    v=$(cmp -s $o /tmp/r11u148_swP/probe/$f && echo P || (cmp -s $o /tmp/r11u148_swL/probe/$f && echo L || echo X))
    line="$line $sw=$v"
  done
  echo $line
done
