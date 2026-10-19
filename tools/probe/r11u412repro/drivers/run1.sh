#!/bin/bash
# run1.sh <casedir> <slang-uhdm binary> <outtag>: golden (cached per case text) + ours + cmp + strictcmp
c=$1; B=$2; t=$3
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/tmp/wt_r11u412/build/uhdm-strictcmp
h=$(cat $(ls -d $c/* | grep -v '/out_' | sort) | md5sum | cut -c1-12)
gd=/tmp/r11u412_scr/gold/$h
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then
  mkdir -p $gd; for x in $(ls -d $c/* | grep -v '/out_'); do cp $x $gd/; done
  (cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1)
fi
o=$c/out_$t; rm -rf $o; mkdir -p $o
(cd $c && timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
rc=$(cat $o/rc)
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then echo "$c rc=$rc NOGOLDEN"; exit; fi
if [ ! -s $o/ours.uhdm ]; then echo "$c rc=$rc NOUHDM"; exit; fi
n=$($CMP $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | wc -l)
s=$($SC $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | tail -1)
echo "$c rc=$rc cmp=$n $s md5=$(md5sum < $o/ours.uhdm | cut -c1-8)"
