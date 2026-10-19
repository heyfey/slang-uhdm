#!/bin/bash
# rc.sh <casedir> <binary> [ENV=..]: golden (probe recipe) + ours; one line with rc
. /tmp/v11u403_scr/env.sh
d=$(readlink -f $1); B=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
o=/tmp/v11u403_scr/cw/$(echo $d | md5sum | cut -c1-12); mkdir -p $o
if [ ! -s $o/golden.uhdm ] || [ $d/dut.sv -nt $o/golden.uhdm ]; then
  rm -rf $o/sl $o/golden.uhdm; mkdir -p $o/sl
  (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $o/sl > $o/sl.log 2>&1)
  cp $o/sl/slpp_all/surelog.uhdm $o/golden.uhdm 2>/dev/null || { echo "$d SURELOG_FAIL"; exit; }
fi
tag=$(basename $B)
rm -f $o/$tag.uhdm
(cd $d && env "$@" timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/$tag.uhdm > $o/$tag.log 2>&1); rc=$?
[ -s $o/$tag.uhdm ] || { echo "rc=$rc SLANG_FAIL $(grep -m1 -i 'error\|unsupported' $o/$tag.log)"; exit; }
n=$($UHDM_CMP $o/golden.uhdm $o/$tag.uhdm 2>&1 | wc -l)
st=$($SC $o/golden.uhdm $o/$tag.uhdm 2>&1 | tail -1)
echo "rc=$rc cmp=$n strict=$st"
