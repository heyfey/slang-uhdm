#!/bin/bash
# switches.sh <bin> <pristine> <out>: per case dir of this pass, md5 of pristine, the law, R11U489_OFF and each law switch alone
D=$(dirname "$(realpath "$0")"); B=$1; P=$2; O=$3; : > $O
SW="R11U489_OFF R11U489_UNBOUNDED_OFF R11U489_UNBOUNDEDDEP_OFF R11U489_BITNEG_OFF R11U489_DPUINT_OFF R11U489_ADDSIZE_OFF R11U489_OVSIZED_OFF"
for c in $(find $D/../cases -mindepth 2 -maxdepth 2 -type d | sort); do
  W=/tmp/r11u489_sw${c#*/cases}; mkdir -p $W
  run(){ rm -f $W/o.uhdm; (cd $c && env $1 "$2" dut.sv --single-unit --nobuiltin -o $W/o.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $W/o.uhdm | cut -c1-8)"; }
  line="${c#*/cases/} pri=$(run X=1 $P) law=$(run X=1 $B)"
  for s in $SW; do line="$line ${s#R11U489_}=$(run $s=1 $B)"; done
  echo "$line" >> $O
done
