#!/bin/bash
# away census: pristine vs verified, bytes + rc, per dir
OUT=/tmp/v11u485_away_out.txt; : > $OUT
R=/home/heyfey/git-repos/slang-uhdm/tools/probe
while read d; do
  c=$R/${d#./}; F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  W=/tmp/v11u485_aw/${d#./}; mkdir -p $W
  line="$d"
  for t in pristine verified; do
    rm -f $W/$t.uhdm; (cd $c && timeout 120 /tmp/v11u485_bin/$t $F --single-unit --nobuiltin -o $W/$t.uhdm >/dev/null 2>&1 </dev/null); rc=$?
    line="$line $t:rc=$rc:$(md5sum < $W/$t.uhdm 2>/dev/null | cut -c1-8)"
  done
  echo "$line" >> $OUT
done < /tmp/v11u485_away_list.txt
echo DONE >> $OUT
