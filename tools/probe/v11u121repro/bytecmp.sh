#!/usr/bin/env bash
# usage: bytecmp.sh <binA> <binB> <listfile of arm dirs> <scratch> [envB]
# both forms; prints DIFF lines and a summary; rc recorded
A=$1; B=$2; L=$3; S=$4; E=${5:-X=1}; mkdir -p $S
same=0; diff=0; n=0
while read -r a <&3; do
  for f in pr ds; do
    n=$((n+1)); fl=""; [ $f = ds ] && fl=-DSYNTHESIS
    oa=$S/a.uhdm; ob=$S/b.uhdm; rm -f $oa $ob
    (cd $a && $A $fl dut.sv --single-unit --nobuiltin -o $oa >/dev/null 2>&1 </dev/null); ra=$?
    (cd $a && env $E $B $fl dut.sv --single-unit --nobuiltin -o $ob >/dev/null 2>&1 </dev/null); rb=$?
    if [ "$ra" = "$rb" ] && cmp -s $oa $ob; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $a $f rc=$ra/$rb"; fi
  done
done 3< $L
echo "PROCESSED=$n SAME=$same DIFF=$diff"
