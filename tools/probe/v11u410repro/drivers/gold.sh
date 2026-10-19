#!/bin/bash
# gold.sh <casedir>: build the Surelog golden into the cache
c=$1; SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
h=$(cat $(ls -d $c/* | grep -v '/out_' | sort) | md5sum | cut -c1-12); gd=/tmp/v11u410_s/gold/$h
[ -f $gd/slpp_all/surelog.uhdm ] && exit 0
mkdir -p $gd; for x in $(ls -d $c/* | grep -v '/out_'); do cp $x $gd/; done
(cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1)
