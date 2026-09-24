#!/bin/bash
# case.sh <case dir with dut.sv> <slang binary> <outtag>  -> strictcmp verdict line; records in <dir>/.r125/
source /tmp/r11u125_scratch/env.sh
d=$(realpath "$1"); bin=$2; tag=$3
w=/tmp/r11u125_cases/$(echo "$d" | md5sum | cut -c1-12); mkdir -p $w
if [ ! -s $w/golden.uhdm ] || [ "$d/dut.sv" -nt $w/golden.uhdm ]; then
  rm -rf $w/sl; mkdir -p $w/sl
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/sl >/dev/null 2>&1)
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null
fi
rm -f $w/$tag.uhdm
(cd $d && $bin dut.sv --single-unit --nobuiltin -o $w/$tag.uhdm >/dev/null 2>$w/$tag.err); rc=$?
cmpn=$($UHDM_CMP $w/golden.uhdm $w/$tag.uhdm 2>&1 | wc -l)
st=$(/tmp/r11u125_bin/strictcmp.bin --max 20 --dump-a $w/g.rec --dump-b $w/$tag.rec $w/golden.uhdm $w/$tag.uhdm 2>&1 | tail -1)
echo "$(basename $d) rc=$rc cmp=$cmpn $st  [$w]"
