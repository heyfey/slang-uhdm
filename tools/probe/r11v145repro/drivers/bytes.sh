#!/bin/bash
# bytes.sh <case dir abs> : run pristine and law, print md5s + rc
d=$1; k=$(echo $d | md5sum | cut -c1-12); o=/tmp/v11u145_s/bc; mkdir -p $o
r=""
for b in pristine law; do f=$o/$k.$b.uhdm; rm -f $f; (cd $d && timeout 120 /tmp/v11u145_bin/$b dut.sv --single-unit --nobuiltin -o $f >/dev/null 2>&1 </dev/null); rc=$?; m=$( [ -f $f ] && md5sum < $f | cut -c1-10 || echo NONE); r="$r $b:rc=$rc:$m"; done
echo "$d$r"
