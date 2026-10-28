#!/bin/bash
# probecen.sh <binary> <listfile> <outdir>: run each probe candidate (tests/probe relative dut path) the way
# check_probe.py does (cwd = case dir, dut.sv --single-unit --nobuiltin) with the § 450 trace, and
# byte-compare against the master's control database /tmp/intr11u449/probe/<rel>.uhdm
B=$1; L=$2; O=$3; P=${PROBE_ROOT:-/home/heyfey/git-repos/slang-uhdm/tests/probe}; C=/tmp/intr11u449/probe
[ -x "$B" ] || exit 2; mkdir -p $O/db $O/tr
exec 3<$L
while read -u 3 rel; do
  [ -n "$rel" ] || continue; d=$(dirname $rel); k=$(echo $d | sed 's|/|__|g')
  [ "$(basename $rel)" = dut.sv ] || { echo "$d SKIP-NOTDUT"; continue; }
  mkdir -p $O/tr/$k; rm -f $O/db/$k.uhdm
  (cd $P/$d && R11U450_TRACE=$O/tr/$k timeout 300 $B dut.sv --single-unit --nobuiltin -o $O/db/$k.uhdm > /dev/null 2>&1 </dev/null; echo $? > $O/db/$k.rc)
  if [ ! -f $C/$k.uhdm ]; then echo "$d rc=$(cat $O/db/$k.rc) NOCONTROL"; continue; fi
  if cmp -s $C/$k.uhdm $O/db/$k.uhdm; then m=same; else m=MOVED; fi
  echo "$d rc=$(cat $O/db/$k.rc) $m fires=$(cat $O/tr/$k/* 2>/dev/null | grep -vc '^OUT')"
done
