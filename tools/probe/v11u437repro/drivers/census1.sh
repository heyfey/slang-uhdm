#!/bin/bash
# census1.sh <rel dut.sv path under tools/probe> : run pristine and law, compare bytes + rc
rel=$1; src=/tmp/wt_v11u437/tools/probe/$rel; dir=$(dirname $src)
key=$(echo $rel | tr '/' '_'); w=/tmp/v11u437_census/$key; mkdir -p $w
for b in pristine law; do
  [ -x /tmp/v11u437_bin/$b ] || { echo "MISSING $b"; exit 2; }
  rm -f $w/$b.uhdm
  (cd $dir && timeout 300 /tmp/v11u437_bin/$b dut.sv --single-unit --nobuiltin -o $w/$b.uhdm >/dev/null 2>&1 </dev/null); echo $? > $w/$b.rc
done
if cmp -s $w/pristine.uhdm $w/law.uhdm && cmp -s $w/pristine.rc $w/law.rc; then echo "SAME $rel $(cat $w/law.rc)"; rm -f $w/*.uhdm; else echo "MOVER $rel $(cat $w/pristine.rc) $(cat $w/law.rc)"; fi
