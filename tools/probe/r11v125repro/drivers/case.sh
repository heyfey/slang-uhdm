#!/bin/bash
# v11u125_case.sh <case dir>: golden (pinned Surelog, probe args) vs pris + law; cmp lines, strict verdict per binary
source /tmp/v11u125_env.sh
d=$(realpath "$1")
w=/tmp/v11u125_cw/$(echo "$d" | md5sum | cut -c1-12); mkdir -p $w
if [ ! -s $w/golden.uhdm ] || [ -n "$(find $d -newer $w/golden.uhdm -type f)" ]; then
  rm -rf $w/sl $w/golden.uhdm; mkdir -p $w/sl
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/sl >/dev/null 2>&1)
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null
fi
out=""
for t in ${BINS:-pris law}; do
  rm -f $w/$t.uhdm $w/$t.rec $w/g.rec
  (cd $d && env $EXTRA /tmp/v11u125_bin/$t.bin dut.sv --single-unit --nobuiltin -o $w/$t.uhdm >/dev/null 2>$w/$t.err); rc=$?
  cmpn=$($UHDM_CMP $w/golden.uhdm $w/$t.uhdm 2>&1 | wc -l)
  st=$(/tmp/v11u125_bin/uhdm-strictcmp --max 20 --dump-a $w/g.rec --dump-b $w/$t.rec $w/golden.uhdm $w/$t.uhdm 2>&1 | tail -n 1)
  cp $w/g.rec $w/g.keep 2>/dev/null
  out="$out | $t rc=$rc cmp=$cmpn $st"
done
same=$(cmp -s $w/pris.uhdm $w/law.uhdm && echo SAMEBYTES || echo moved)
echo "$(basename $(dirname $d))/$(basename $d)$out | $same [$w]"
