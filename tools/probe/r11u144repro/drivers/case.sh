#!/bin/bash
# case.sh <case dir with dut.sv> <slang binary> <tag> [elab] -> one verdict line
# Surelog: -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 [-elabuhdm]; ours: dut.sv --single-unit --nobuiltin [--elabuhdm]
# Needs SURELOG, UHDM_CMP, STRICT_CMP exported.
d=$(realpath "$1"); bin=$2; tag=$3; ex=$4
w=${CASE_WORK:-/tmp/r11u144_cases}/$(echo "$d$ex" | md5sum | cut -c1-12); mkdir -p $w
echo "$d" > $w/dir
sfl=""; ofl=""; [ "$ex" = elab ] && { sfl=-elabuhdm; ofl=--elabuhdm; }
if [ ! -s $w/golden.uhdm ] || [ -n "$(find $d -newer $w/golden.uhdm -type f 2>/dev/null)" ]; then
  rm -rf $w/sl $w/golden.uhdm; mkdir -p $w/sl
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 $sfl -o $w/sl >/dev/null 2>&1)
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null
fi
rm -f $w/$tag.uhdm
(cd $d && $bin dut.sv --single-unit --nobuiltin $ofl -o $w/$tag.uhdm >/dev/null 2>$w/$tag.err); rc=$?
cmpn=$($UHDM_CMP $w/golden.uhdm $w/$tag.uhdm 2>&1 | wc -l)
$STRICT_CMP --max 20 --dump-a $w/g.rec --dump-b $w/$tag.rec $w/golden.uhdm $w/$tag.uhdm > $w/$tag.strict 2>&1
st=$(tail -1 $w/$tag.strict)
echo "$(basename $(dirname $d))/$(basename $d) rc=$rc cmp=$cmpn $st md5=$(md5sum < $w/$tag.uhdm | cut -c1-12)"
