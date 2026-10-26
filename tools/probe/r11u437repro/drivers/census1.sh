#!/bin/bash
# census1.sh <rel dut.sv path under tools/probe> : run pristine and law3, compare bytes + rc
rel=$1; src=/tmp/wt_r11u437/tools/probe/$rel; dir=$(dirname $src)
key=$(echo $rel | tr '/' '_'); w=/tmp/r11u437_census/$key; mkdir -p $w
for b in pristine law3; do
  rm -f $w/$b.uhdm
  (cd $dir && timeout 300 /tmp/r11u437_bin/$b dut.sv --single-unit --nobuiltin -o $w/$b.uhdm >/dev/null 2>&1 </dev/null); echo $? > $w/$b.rc
done
# databases embed no workdir-specific path beyond the source dir (same for both)
if cmp -s $w/pristine.uhdm $w/law3.uhdm && cmp -s $w/pristine.rc $w/law3.rc; then echo "SAME $rel $(cat $w/law3.rc)"; else echo "MOVER $rel $(cat $w/pristine.rc) $(cat $w/law3.rc)"; fi
