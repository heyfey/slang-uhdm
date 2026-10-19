#!/bin/bash
# run1.sh <casedir> <binary> <tag> [ENV=VAL...]: golden (cached by text) + ours + cmp + strictcmp
c=$1; B=$2; t=$3; shift 3
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=${SC:-/tmp/wt_v11u408/build/uhdm-strictcmp}
[ -x "$SC" ] || { echo "no strictcmp"; exit 1; }
h=$(md5sum $c/dut.sv | cut -c1-12)
gd=/tmp/v11u408_gold/$h
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then
  mkdir -p $gd; cp $c/dut.sv $gd/dut.sv
  (cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1)
fi
o=/tmp/v11u408_out/$c/$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
rc=$(cat $o/rc)
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then echo "$c $t rc=$rc NOGOLDEN"; exit; fi
if [ ! -s $o/ours.uhdm ]; then echo "$c $t rc=$rc NOUHDM"; exit; fi
n=$($CMP $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | wc -l)
s=$($SC $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | tail -1)
echo "$c $t rc=$rc cmp=$n $s md5=$(md5sum < $o/ours.uhdm | cut -c1-8)"
