#!/bin/bash
# heads.sh <workroot> <list> <out>
W=$1; L=$2; O=$3; : > $O
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
[ -x "$CMP" ] || exit 9
while read -r p <&3; do
  d=$W/${p%.sv}; g=$(/tmp/r11u421_bin/gold.sh $d)
  [ -f "$g" ] && [ -f $d/slang.uhdm ] || { echo "$p | NOFILE" >> $O; continue; }
  timeout 600 $CMP $g $d/slang.uhdm > /tmp/r11u421_cmp.tmp 2>&1 </dev/null
  n=$(wc -l < /tmp/r11u421_cmp.tmp)
  echo "$p | $n | $(head -4 /tmp/r11u421_cmp.tmp | tr '\n' ' ' | cut -c1-400)" >> $O
done 3< $L
