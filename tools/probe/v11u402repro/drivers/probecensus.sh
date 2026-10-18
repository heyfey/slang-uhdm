#!/bin/bash
# probecensus.sh <binary> <outdir> : run every fence-filtered tests/probe case with R11U402_TRACE, print the firing laws per case
L=$1; O=$2; mkdir -p $O
one(){ f=$1; L=$2; O=$3; d=/tmp/wt_v11u402/$(dirname $f); k=$(dirname $f | tr / _); t=$O/t_$k; rm -rf $t; mkdir -p $t
  (cd $d && R11U402_TRACE=$t timeout 300 $L dut.sv --single-unit --nobuiltin -o $O/x_$k.uhdm > /dev/null 2>&1; echo $? > $t/rc); rm -f $O/x_$k.uhdm
  fz=$(cat $t/*.402 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s(%s) ", $2, $1}'); echo "$(dirname $f) | rc=$(cat $t/rc) | ${fz:--}"; rm -rf $t; }
export -f one
cat /tmp/v11u402_probedirs | xargs -P 3 -I{} bash -c "one {} $L $O"
