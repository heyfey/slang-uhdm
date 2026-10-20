#!/bin/bash
# r11u419 predict.sh <out>: pvscan over every control database (fence-filtered path list first)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; [ -x $D ] || exit 1
H=$(dirname $(readlink -f $0)); OUT=$1; L=/tmp/r11u419_pred.lst
find /tmp/intr11u417/probe /tmp/intr11u417/surelog /tmp/intr11u417/uhdm2rtlil -name '*.uhdm' > $L.all
grep -v -F -f /tmp/r11u419_fenced.txt $L.all > $L
echo "listed $(wc -l < $L.all) kept $(wc -l < $L)" > $OUT.meta
one() { f=$1; t=/tmp/r11u419_pd_$(echo $f | md5sum | cut -c1-10).dump; timeout 900 $D $f > $t 2>/dev/null; python3 $H/pvscan.py $t | sed "s|^|$f |"; rm -f $t; }
export -f one; export D H
xargs -a $L -P 3 -I{} bash -c 'one {}' > $OUT
echo "processed $(wc -l < $L)" >> $OUT.meta
