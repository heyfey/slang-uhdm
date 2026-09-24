#!/bin/bash
# v11u144_case.sh <case dir> <bin> <tag> [elab]  -> rc, uhdm-cmp lines, strict verdict, md5
source /tmp/v11u144_env.sh
d=$(realpath "$1"); bin=$2; tag=$3; ex=$4
w=/tmp/v11u144_cw/$(echo "$d$ex" | md5sum | cut -c1-12); mkdir -p $w; echo "$d" > $w/dir
sfl=""; ofl=""; [ "$ex" = elab ] && { sfl=-elabuhdm; ofl=--elabuhdm; }
if [ ! -s $w/golden.uhdm ] || [ -n "$(find $d -newer $w/golden.uhdm -type f 2>/dev/null)" ]; then
  rm -rf $w/sl $w/golden.uhdm; mkdir -p $w/sl
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 $sfl -o $w/sl >$w/sl.log 2>&1); echo $? > $w/sl.rc
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null
fi
rm -f $w/$tag.uhdm
(cd $d && env $CASE_ENV $bin dut.sv --single-unit --nobuiltin $ofl -o $w/$tag.uhdm >/dev/null 2>$w/$tag.err); rc=$?
cmpn=$($UHDM_CMP $w/golden.uhdm $w/$tag.uhdm 2>&1 | wc -l)
$STRICT_CMP --max 20 --dump-a $w/g.rec --dump-b $w/$tag.rec $w/golden.uhdm $w/$tag.uhdm > $w/$tag.strict 2>&1
st=$(tail -1 $w/$tag.strict)
echo "$(basename $(dirname $d))/$(basename $d)$ex slrc=$(cat $w/sl.rc) rc=$rc cmp=$cmpn $st md5=$(md5sum < $w/$tag.uhdm | cut -c1-12) w=$w"
