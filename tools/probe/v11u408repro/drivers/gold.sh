#!/bin/bash
c=$1; SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
h=$(md5sum $c/dut.sv | cut -c1-12); gd=/tmp/v11u408_gold/$h
[ -f $gd/slpp_all/surelog.uhdm ] && exit 0
mkdir -p $gd; cp $c/dut.sv $gd/dut.sv
(cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1; echo "$c $?")
