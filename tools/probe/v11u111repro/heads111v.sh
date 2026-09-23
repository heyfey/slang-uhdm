#!/bin/bash
# heads: <wd> <rowregex> -> per row/mode: lines heads + LHS/RHS head lines
W=${1:?wd}; RX=${2:?rowregex}; CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
for c in $(find $W -name cmds.txt | grep -E "/($RX)-[0-9a-f]+/cmds.txt" | sort); do d=$(dirname $c)
  g=$(grep -o 'cache hit [^)]*' $c | awk '{print $3}')/golden.uhdm
  [ -f $d/slang.uhdm ] || { echo "$d NOSLANG"; continue; }
  $CMP $g $d/slang.uhdm > $d/v111cmp.txt 2>&1
  echo "== ${d#$W/} lines=$(wc -l < $d/v111cmp.txt) heads=$(grep -c '^LHS:' $d/v111cmp.txt; true)"
done
