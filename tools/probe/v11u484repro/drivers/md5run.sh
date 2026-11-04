#!/bin/bash
# md5run.sh <bin> <dir>  (env passes through): prints dir rc md5
d=$1; b=$2; o=/tmp/v11u484_md5_$$_$RANDOM.uhdm; rm -f $o
(cd $d && $b dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null); rc=$?
echo "${d#/tmp/wt_v11u484/tools/probe/} $rc $(md5sum < $o 2>/dev/null | cut -c1-8)"; rm -f $o
