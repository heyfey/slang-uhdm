#!/bin/bash
# switches.sh <out> <casedir>...: md5 of pristine, law, R11U489_OFF and each switch alone on the law binary
O=$1; shift; : > $O
P=/tmp/v11u489_bin/pristine; B=/tmp/v11u489_bin/law
SW="R11U489_OFF R11U489_UNBOUNDED_OFF R11U489_UNBOUNDEDDEP_OFF R11U489_BITNEG_OFF R11U489_DPUINT_OFF R11U489_ADDSIZE_OFF R11U489_OVSIZED_OFF"
for c in "$@"; do
  c=$(realpath $c); W=/tmp/v11u489_sw$c; mkdir -p $W
  run(){ rm -f $W/o.uhdm; (cd $c && env $1 "$2" dut.sv --single-unit --nobuiltin -o $W/o.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $W/o.uhdm | cut -c1-8)"; }
  line="$c pri=$(run X=1 $P) law=$(run X=1 $B)"
  for s in $SW; do line="$line ${s#R11U489_}=$(run $s=1 $B)"; done
  echo "$line" >> $O
done
