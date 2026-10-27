#!/bin/bash
# usage: census.sh <list of dut.sv paths relative to the main tree> <out.tsv>
# runs law and verified (traced) on a copy of each case dir; prints rc and md5 per binary
R=/home/heyfey/git-repos/slang-uhdm; W=/tmp/v11u441_cen
: > $2
while read f; do
  src=$R/$(dirname $f); k=$(echo $(dirname $f) | tr / _); d=$W/$k
  rm -rf $d; mkdir -p $d; cp -r $src/. $d/ 2>/dev/null
  line=$(dirname $f)
  for n in law verified; do
    rm -f $d/o_$n.uhdm; mkdir -p $d/tr_$n
    (cd $d && R11U441_TRACE=$d/tr_$n timeout 300 /tmp/v11u441_bin/$n dut.sv --single-unit --nobuiltin -o o_$n.uhdm >/dev/null 2>&1 </dev/null); rc=$?
    line="$line	$n:rc=$rc md5=$(md5sum < $d/o_$n.uhdm 2>/dev/null | cut -c1-8) tr=$(cat $d/tr_$n/* 2>/dev/null | grep -c 441v)"
  done
  echo "$line" >> $2
done < $1
