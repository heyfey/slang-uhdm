#!/bin/bash
# switches.sh <lawbin> <pristinebin> <out>: per case, md5 of the output under
# pristine, the law, R11U487_OFF=1 and each law switch alone (rc recorded).
source $(dirname "$0")/env.sh || exit 1
L=$1; P=$2; O=$3; : > $O
SW="R11U487_CAFOLDTS_OFF R11U487_CAFOLDVAL_OFF R11U487_CAFOLDGROW_OFF R11U487_DEPPREDP_OFF R11U487_BAREOVREF64_OFF R11U487_DPMASK_OFF"
for c in $(find $(dirname "$0")/../cases -mindepth 2 -maxdepth 2 -type d | sort); do
  c=$(realpath $c); W=/tmp/r11u487_sw$c; mkdir -p $W
  run(){ rm -f $W/o.uhdm; (cd $c && env $2 "$1" dut.sv --single-unit --nobuiltin -o $W/o.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $W/o.uhdm | cut -c1-8)"; }
  p=$(run $P X=1); l=$(run $L X=1); off=$(run $L R11U487_OFF=1)
  line="${c#*/cases/} pristine=$p law=$l OFF=$( [ "$off" = "$p" ] && echo pristine || echo DIFF:$off)"
  for s in $SW; do r=$(run $L $s=1); [ "$r" = "$l" ] && v=law || { [ "$r" = "$p" ] && v=PRISTINE || v=OTHER:$r; }; line="$line ${s#R11U487_}=$v"; done
  echo "$line" >> $O
done
