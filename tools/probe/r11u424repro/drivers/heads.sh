#!/bin/bash
# heads.sh <workroot> <out>: uhdm-cmp line count + first lines for every kept pair
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
W=$1; O=$2; : > $O
find $W -name cmds.txt | sort | while read c; do
  d=$(dirname $c); g=$(grep -o 'golden cache hit [^)]*' $c | awk '{print $4}'); G=$g/golden.uhdm; [ -n "$g" ] || G=$d/slpp_all/surelog.uhdm
  [ -f $d/slang.uhdm ] && [ -f $G ] || continue
  timeout 600 $CMP $G $d/slang.uhdm > $d/cmp.txt 2>&1
  n=$(wc -l < $d/cmp.txt); h=$(sed -n '1,5p' $d/cmp.txt | tr '\n' ' ' | cut -c1-230)
  echo "${d#$W/} | $n | $h" >> $O
done
