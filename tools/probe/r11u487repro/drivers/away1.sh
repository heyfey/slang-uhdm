#!/bin/bash
# away1.sh <binA> <binB> <reldir under tools/probe>: rc + md5 of both binaries' output (outputs deleted first)
P=/tmp/wt_r11u487/tools/probe
d=$3; c=$P/$d; W=${AWAYW:-/tmp/r11u487_away}/$d; mkdir -p $W
F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
r=""
for t in A B; do B=$1; [ $t = B ] && B=$2
  rm -f $W/$t.uhdm; (cd $c && timeout 120 "$B" $F --single-unit --nobuiltin -o $W/$t.uhdm >/dev/null 2>&1 </dev/null); rc=$?
  m=$( [ -f $W/$t.uhdm ] && md5sum < $W/$t.uhdm | cut -c1-8 || echo none)
  r="$r $rc:$m"
done
echo "$d$r"
