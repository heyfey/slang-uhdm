#!/bin/bash
# switches.sh <grid root>  -> per case: law17 vs pristine bytes; R11U134_OFF=1 -> pristine?; which single switch moves it back
source /tmp/r11u134_env.sh
B=/tmp/r11u134_bin/law17; PB=/tmp/r11u134_bin/pris
SW="TDNETEND TDARRSHARE TDPARENT CAUNPARENT ANONMEMBER MEMUNION ELABNETALIAS TSREFCHAIN TSHPNAME SCOPEDPKGTD PKGCLONEBOUND"
for d in $(ls -d $1/*/*/ | sort); do
  d=$(realpath $d); w=/tmp/r11u134_scr/sw/$(echo $d | md5sum | cut -c1-12); mkdir -p $w
  (cd $d && rm -f $w/*.uhdm && $PB dut.sv --single-unit --nobuiltin -o $w/P.uhdm >/dev/null 2>&1; $B dut.sv --single-unit --nobuiltin -o $w/L.uhdm >/dev/null 2>&1; R11U134_OFF=1 $B dut.sv --single-unit --nobuiltin -o $w/O.uhdm >/dev/null 2>&1)
  [ -f $w/P.uhdm ] || { echo "$(basename $(dirname $d))/$(basename $d)	nodb"; continue; }
  moved=$(cmp -s $w/P.uhdm $w/L.uhdm && echo same || echo moved)
  off=$(cmp -s $w/P.uhdm $w/O.uhdm && echo pristine || echo DIFFERS)
  laws=""
  if [ $moved = moved ]; then
    for s in $SW; do (cd $d && rm -f $w/s.uhdm && env R11U134_${s}_OFF=1 $B dut.sv --single-unit --nobuiltin -o $w/s.uhdm >/dev/null 2>&1); cmp -s $w/s.uhdm $w/L.uhdm || laws="$laws $s"; done
  fi
  echo "$(basename $(dirname $d))/$(basename $d)	$moved	off=$off	laws:${laws:- -}"
done
