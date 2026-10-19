#!/bin/bash
# rc.sh <casedir> [binary]: golden (probe recipe) + ours, uhdm-cmp + strictcmp; prints one line
. /tmp/r11u403_scr/env.sh
d=$(readlink -f $1); B=${2:-$SLANG_UHDM}
o=/tmp/r11u403_scr/cw/$(echo $d | md5sum | cut -c1-12); mkdir -p $o
if [ ! -s $o/golden.uhdm ] || [ $d/dut.sv -nt $o/golden.uhdm ]; then
  rm -rf $o/sl; mkdir -p $o/sl
  (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $o/sl > $o/sl.log 2>&1)
  cp $o/sl/slpp_all/surelog.uhdm $o/golden.uhdm 2>/dev/null || { echo "$1 SURELOG_FAIL"; exit; }
fi
rm -f $o/ours.uhdm
(cd $d && timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1); rc=$?
[ -s $o/ours.uhdm ] || { echo "$1 rc=$rc SLANG_FAIL $(grep -m1 -i 'error\|unsupported' $o/ours.log)"; exit; }
n=$($UHDM_CMP $o/golden.uhdm $o/ours.uhdm 2>&1 | wc -l)
st=$($SC $o/golden.uhdm $o/ours.uhdm 2>&1 | tail -1)
echo "$1 rc=$rc cmp=$n strict=$st"
