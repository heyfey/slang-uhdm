#!/bin/bash
# run1.sh <casedir> <slang-uhdm binary> <outtag> [ENV=VAL ...]: golden (cached per case text)
# + ours + uhdm-cmp line count + uhdm-strictcmp verdict; outputs under /tmp/r11u416_scr/out
c=$(cd $1 && pwd); B=$2; t=$3; shift 3
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=${STRICTCMP:-/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp}
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
gd=/tmp/r11u416_scr/gold/$h
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then
  mkdir -p $gd; cp $c/* $gd/
  (cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1)
fi
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
o=/tmp/r11u416_scr/out/$key/$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
rc=$(cat $o/rc)
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then echo "$key rc=$rc NOGOLDEN"; exit; fi
if [ ! -s $o/ours.uhdm ]; then echo "$key rc=$rc NOUHDM"; exit; fi
n=$($CMP $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | wc -l)
s=$($SC $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | tail -1)
echo "$key rc=$rc cmp=$n $s md5=$(md5sum < $o/ours.uhdm | cut -c1-8)"
