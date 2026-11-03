#!/bin/bash
# away1.sh <absdir>: run pristine and law on one case dir, print rc+md5 of each
c=$1; W=/tmp/v11u472_away$c; mkdir -p $W
F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
out="$c"
for b in pristine law; do
  rm -f $W/$b.uhdm
  (cd $c && timeout 120 /tmp/v11u472_bin/$b $F --single-unit --nobuiltin -o $W/$b.uhdm > $W/$b.log 2>&1 </dev/null); rc=$?
  m=$( [ -f $W/$b.uhdm ] && md5sum < $W/$b.uhdm | cut -c1-12 || echo none)
  out="$out $b:$rc:$m"
done
echo "$out"
