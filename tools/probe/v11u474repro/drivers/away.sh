#!/bin/bash
# away.sh <listfile> <out>: for each earlier case dir (absolute, fence-filtered list) the exit code and md5 of
# ours on pristine, law and verified; three jobs
one(){ d=$1; F=dut.sv; [ -f "$d/FILES" ] && F=$(cat "$d/FILES"); r=""; for b in pristine law verified; do o=/tmp/v11u474_aw/$(echo $d | md5sum | cut -c1-12).$b.uhdm; rm -f $o; (cd $d && /tmp/v11u474_bin/$b $F --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null); rc=$?; r="$r $b=$rc:$(md5sum < $o 2>/dev/null | cut -c1-8)"; done; echo "$d$r"; }
export -f one; mkdir -p /tmp/v11u474_aw
xargs -P 3 -I{} bash -c 'one {}' < $1 > $2
