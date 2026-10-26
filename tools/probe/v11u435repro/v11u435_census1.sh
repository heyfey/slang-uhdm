#!/bin/bash
# one case dir (relative to tools/probe): rc and md5 on pristine, law, verified
d=$1; c=/tmp/wt_v11u435/tools/probe/$d; o=/tmp/v11u435_cen/$(echo $d | tr '/' '_'); mkdir -p $o
line="$d"
for b in pris law ver; do
  B=/tmp/v11u435_$b.bin; [ -x "$B" ] || { echo "$d NOBIN"; exit; }
  rm -f $o/$b.uhdm
  (cd $c && timeout 300 $B dut.sv --single-unit --nobuiltin -o $o/$b.uhdm >/dev/null 2>&1 </dev/null); rc=$?
  m=$(md5sum < $o/$b.uhdm 2>/dev/null | cut -c1-10); line="$line $b:$rc:${m:-none}"
done
echo "$line"
