#!/bin/bash
# bytes.sh <case dir>: fix.bin under switches vs pris/law bytes
d=$(realpath $1); w=/tmp/v11u125_bytes/$(echo $d | md5sum | cut -c1-12); mkdir -p $w; cd $d
run(){ rm -f $w/$1.uhdm; env $2 /tmp/v11u125_bin/$3.bin dut.sv --single-unit --nobuiltin -o $w/$1.uhdm >/dev/null 2>&1; }
run p X=1 pris; run l X=1 law; run f X=1 fix; run fo R11U125_OFF=1 fix; run fv "R11V125_INCINFOCOL_OFF=1 R11V125_BAREDEF_OFF=1" fix
a=$(cmp -s $w/fo.uhdm $w/p.uhdm && echo OFF=pris || echo OFF!=pris)
b=$(cmp -s $w/fv.uhdm $w/l.uhdm && echo VOFF=law || echo VOFF!=law)
c=$(cmp -s $w/f.uhdm $w/l.uhdm && echo fix=law || echo fix!=law)
echo "$1 $a $b $c"
