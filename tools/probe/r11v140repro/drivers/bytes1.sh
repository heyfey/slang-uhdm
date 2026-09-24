#!/usr/bin/env bash
# bytes1.sh <rel dut.sv under tools/probe>: pris vs ver1 vs law bytes
f=$1; d=$(dirname $f); k=$(echo $d | tr '/' '_'); o=/tmp/v11u140_scratch/ctl_out; mkdir -p $o
for b in pris law ver1; do rm -f $o/$k.$b.uhdm; (cd /tmp/wt_v11u140/tools/probe/$d && /tmp/v11u140_bin/$b dut.sv --single-unit --nobuiltin -o $o/$k.$b.uhdm >/dev/null 2>&1; echo $? > $o/$k.$b.rc); done
pl=SAME; cmp -s $o/$k.pris.uhdm $o/$k.law.uhdm || pl=MOVED
lv=SAME; cmp -s $o/$k.law.uhdm $o/$k.ver1.uhdm || lv=MOVED
echo "$d P-L=$pl L-V=$lv rc=$(cat $o/$k.pris.rc),$(cat $o/$k.law.rc),$(cat $o/$k.ver1.rc)"
