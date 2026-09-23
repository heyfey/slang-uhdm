#!/bin/bash
# usage: cmp7.sh <sweep-root> <outdir> <regex>
R=$1; O=$2; RX=$3; mkdir -p $O
for d in $(find $R -name slang.uhdm -printf '%h\n' | grep -E "$RX" | sort); do
  g=$(grep -o 'cache hit [^)]*' $d/cmds.txt | awk '{print $3}')/golden.uhdm
  k=$(echo $d | sed "s#$R/##; s#/#_#g")
  ~/git-repos/UHDM/build/bin/uhdm-cmp $g $d/slang.uhdm > $O/$k.cmp 2>&1
  echo "$k lines=$(wc -l < $O/$k.cmp) heads=$(grep -c '^LHS:' $O/$k.cmp; true)"
done
