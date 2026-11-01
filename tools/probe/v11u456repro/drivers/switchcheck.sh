#!/bin/bash
# switch check: for each case dir, run ver with env X, compare with reference binary output
source /tmp/v11u456_env.sh
V=/tmp/v11u456_bin/ver
for c in "$@"; do
  c=$(realpath $c); W=/tmp/v11u456_sw$c; mkdir -p $W
  rm -f $W/*.uhdm
  (cd $c; $PRI dut.sv -o $W/pri.uhdm >/dev/null 2>&1; $LAW dut.sv -o $W/law.uhdm >/dev/null 2>&1
   R11U456_OFF=1 $V dut.sv -o $W/uoff.uhdm >/dev/null 2>&1; echo -n "" 
   R11V456_OFF=1 $V dut.sv -o $W/voff.uhdm >/dev/null 2>&1
   R11V456_LVSHADOW_OFF=1 $V dut.sv -o $W/lvoff.uhdm >/dev/null 2>&1)
  a=$(cmp -s $W/pri.uhdm $W/uoff.uhdm && echo U=pri || echo U!=pri)
  b=$(cmp -s $W/law.uhdm $W/voff.uhdm && echo V=law || echo V!=law)
  d=$(cmp -s $W/law.uhdm $W/lvoff.uhdm && echo LV=law || echo LV!=law)
  echo "${c#*/probe/} $a $b $d"
done
