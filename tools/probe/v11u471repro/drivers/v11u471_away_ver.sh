#!/bin/bash
# away census: pristine vs law on earlier case dirs (dut.sv), md5 + rc; movers listed
out=/tmp/v11u471_away_ver.txt; : > $out
for rp in r11u469 v11u469 r11u467 v11u467 r11u465 v11u465 r11u463 v11u463 r11u461 v11u461 r11u458 v11u458 r11u457 v11u457 r11u453 v11u453 r11u451 v11u451; do
  for f in $(find /tmp/wt_v11u471/tools/probe/${rp}repro -name dut.sv 2>/dev/null | sort); do
    d=$(dirname $f)
    a=/tmp/v11u471_aw_a.uhdm; b=/tmp/v11u471_aw_b.uhdm; rm -f $a $b
    (cd $d && timeout 120 /tmp/v11u471_bin/law dut.sv --single-unit --nobuiltin -o $a >/dev/null 2>&1); ra=$?
    (cd $d && timeout 120 /tmp/v11u471_bin/verified dut.sv --single-unit --nobuiltin -o $b >/dev/null 2>&1); rb=$?
    if [ $ra != $rb ]; then echo "RCMOVE ${d#/tmp/wt_v11u471/tools/probe/} $ra->$rb" >> $out
    elif cmp -s $a $b; then echo "SAME ${d#/tmp/wt_v11u471/tools/probe/} rc=$ra" >> $out
    else echo "MOVER ${d#/tmp/wt_v11u471/tools/probe/} rc=$ra" >> $out; fi
  done
done
awk '{print $1}' $out | sort | uniq -c
