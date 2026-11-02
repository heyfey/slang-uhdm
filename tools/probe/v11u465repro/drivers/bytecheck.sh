#!/bin/bash
# bytecheck.sh <list of case dirs>: pristine vs verified exit code and md5 of ours (no golden)
while read c; do
  W=/tmp/v11u465_bc$c; mkdir -p $W; o=""
  for b in pristine verified; do rm -f $W/$b.uhdm; (cd $c && /tmp/v11u465_bin/$b dut.sv --single-unit --nobuiltin -o $W/$b.uhdm > $W/$b.log 2>&1 </dev/null); r=$?; o="$o $b:rc=$r:$( [ -f $W/$b.uhdm ] && md5sum < $W/$b.uhdm | cut -c1-8)"; done
  echo "$c$o"
done
