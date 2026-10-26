#!/bin/bash
# heads.sh <workroot> <list>: per row, uhdm-cmp line count + lhsPath + first LHS object line
C=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
[ -x "$C" ] || exit 1
while read p; do
  d=$1/${p%.sv}
  g=$d/slpp_all/surelog.uhdm
  [ -f $g ] || g=$(grep -o 'cache hit [^)]*' $d/cmds.txt 2>/dev/null | cut -d' ' -f3)/golden.uhdm
  out=$($C $g $d/slang.uhdm 2>&1)
  n=$(echo "$out" | wc -l)
  lp=$(echo "$out" | grep -m1 '^lhsPath' | cut -c1-220)
  o=$(echo "$out" | sed -n 3p | cut -c1-120)
  echo "$p | $n | $o | $lp"
done < $2
