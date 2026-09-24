#!/bin/bash
# case.sh <case dir with dut.sv>  -> one line: name  P[rc cmp strict]  L[rc cmp strict]
source /tmp/v11u134_env.sh
SC=/tmp/v11u134_bin/strictcmp
d=$(realpath "$1")
w=/tmp/v11u134_cases/$(echo "$d" | md5sum | cut -c1-12); mkdir -p $w
echo "$d" > $w/dir
if [ ! -s $w/golden.uhdm ] || [ -n "$(find $d -newer $w/golden.uhdm -type f 2>/dev/null)" ]; then
  rm -rf $w/sl $w/golden.uhdm; mkdir -p $w/sl
  (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/sl >/dev/null 2>&1 </dev/null)
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null
fi
out=""
for tag in P L; do
  bin=/tmp/v11u134_bin/pris; [ $tag = L ] && bin=/tmp/v11u134_bin/law
  rm -f $w/$tag.uhdm
  (cd $d && env $EXTRA timeout 300 $bin dut.sv --single-unit --nobuiltin -o $w/$tag.uhdm >/dev/null 2>$w/$tag.err </dev/null); rc=$?
  if [ ! -s $w/golden.uhdm ]; then out="$out $tag[rc=$rc NOGOLDEN]"; continue; fi
  cmpn=$($UHDM_CMP $w/golden.uhdm $w/$tag.uhdm 2>&1 | wc -l)
  st=$($SC --max 20 --dump-a $w/g.rec --dump-b $w/$tag.rec $w/golden.uhdm $w/$tag.uhdm 2>&1 | tail -n 1)
  out="$out $tag[rc=$rc cmp=$cmpn $st]"
done
m=same; cmp -s $w/P.uhdm $w/L.uhdm || m=moved
echo "$(basename $(dirname $d))/$(basename $d)$out $m [$w]"
