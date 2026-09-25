#!/bin/bash
# offbytes.sh <pristine bin> <law bin>: with R11U154_OFF=1 the law binary must write the pristine bytes on every case
D=$(cd "$(dirname "$0")" && pwd); R=$(dirname $D); P=$1; L=$2; T=$(mktemp -d /tmp/r11u154_offb.XXXX); n=0; bad=0
for d in $(find $R -mindepth 2 -maxdepth 2 -type d ! -path '*/drivers*' ! -path '*/evidence*' | sort); do
  n=$((n+1)); (cd $d && $P dut.sv --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1; R11U154_OFF=1 $L dut.sv --single-unit --nobuiltin -o $T/l.uhdm >/dev/null 2>&1)
  if ! cmp -s $T/p.uhdm $T/l.uhdm; then echo "DIFF $d"; bad=$((bad+1)); fi; rm -f $T/p.uhdm $T/l.uhdm
done; rm -rf $T; echo "offbytes: $((n-bad)) of $n cases byte-identical to pristine under R11U154_OFF=1"
