#!/bin/bash
# r11u419 earlier.sh <list of dut.sv paths relative to tools/probe> <out>: pristine vs final exit code and bytes
# (an optional TOP file beside the case names the top for both runs)
P=/tmp/r11u419_bin/pristine; F=/tmp/r11u419_bin/final2; B=/tmp/wt_r11u419/tools/probe
one() { c=$(dirname $1); d=$B/$c; t=""; [ -f $d/TOP ] && t="--top $(cat $d/TOP)"; k=$(echo $c | md5sum | cut -c1-12)
  (cd $d && timeout 120 $P dut.sv $t --single-unit --nobuiltin -o /tmp/r11u419_ea_${k}p.uhdm >/dev/null 2>&1); rp=$?
  (cd $d && timeout 120 $F dut.sv $t --single-unit --nobuiltin -o /tmp/r11u419_ea_${k}f.uhdm >/dev/null 2>&1); rf=$?
  s=same; cmp -s /tmp/r11u419_ea_${k}p.uhdm /tmp/r11u419_ea_${k}f.uhdm || s=MOVED; [ $rp = $rf ] || s="$s RC $rp->$rf"
  echo "$c $s"; rm -f /tmp/r11u419_ea_${k}?.uhdm; }
export -f one; export P F B
xargs -a $1 -P 3 -I{} bash -c 'one {}' > $2
