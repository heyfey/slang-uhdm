#!/bin/bash
# sw.sh <case> -> OFF=pristine? and which single switches move it back
c=$1; d=$(cd $(dirname $0)/../grid && pwd)/$c
w=/tmp/v11u134_cases/$(echo "$d" | md5sum | cut -c1-12)
run(){ rm -f $w/X.uhdm; (cd $d && env "$@" /tmp/v11u134_bin/law dut.sv --single-unit --nobuiltin -o $w/X.uhdm >/dev/null 2>&1 </dev/null); }
run R11U134_OFF=1; off=$(cmp -s $w/X.uhdm $w/P.uhdm && echo off=pristine || echo off=DIFF)
cmp -s $w/P.uhdm $w/L.uhdm && { echo "$c unmoved $off"; exit; }
laws=""
for s in TDNETEND TDARRSHARE TDPARENT CAUNPARENT ANONMEMBER MEMUNION ELABNETALIAS TSREFCHAIN TSHPNAME SCOPEDPKGTD PKGCLONEBOUND; do
  run R11U134_${s}_OFF=1; cmp -s $w/X.uhdm $w/L.uhdm || laws="$laws $s"
done
echo "$c $off laws:$laws"
