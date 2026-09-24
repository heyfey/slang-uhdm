#!/bin/bash
d=$(dirname $(realpath "$1")); k=$(echo "$d" | md5sum | cut -c1-12); w=/tmp/v11u134_scr/ctl/$k; mkdir -p $w; echo $d > $w/dir
for b in pris law; do rm -f $w/$b.uhdm; (cd $d && timeout 300 /tmp/v11u134_bin/$b dut.sv --single-unit --nobuiltin -o $w/$b.uhdm >/dev/null 2>&1 </dev/null); echo $? > $w/$b.rc; done
if cmp -s $w/pris.uhdm $w/law.uhdm; then echo "same $1"; else echo "MOVED $1 rc=$(cat $w/pris.rc)/$(cat $w/law.rc)"; fi
