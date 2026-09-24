#!/bin/bash
# case.sh <case dir with dut.sv> <slang binary> <tag>  -> one verdict line
source /tmp/r11u137_env.sh
d=$(realpath "$1"); bin=$2; tag=$3
w=/tmp/r11u137_casesE/$(echo "$d" | md5sum | cut -c1-12); mkdir -p $w
echo "$d" > $w/dir
if [ ! -s $w/golden.uhdm ] || [ -n "$(find $d -newer $w/golden.uhdm -type f 2>/dev/null)" ]; then
  rm -rf $w/sl $w/golden.uhdm; mkdir -p $w/sl
  (cd $d && $SURELOG -parse -elabuhdm -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/sl >/dev/null 2>&1)
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null
fi
rm -f $w/$tag.uhdm
(cd $d && $bin dut.sv --single-unit --nobuiltin --elabuhdm -o $w/$tag.uhdm >/dev/null 2>$w/$tag.err); rc=$?
cmpn=$($UHDM_CMP $w/golden.uhdm $w/$tag.uhdm 2>&1 | wc -l)
st=$($STRICT_CMP --max 20 --dump-a $w/g.rec --dump-b $w/$tag.rec $w/golden.uhdm $w/$tag.uhdm 2>&1 > $w/$tag.strict; tail -1 $w/$tag.strict)
fl=$(grep '^fields' $w/$tag.strict)
echo "$(basename $d) rc=$rc cmp=$cmpn $st | $fl  [$w]"
