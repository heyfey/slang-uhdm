#!/bin/bash
# offbytes.sh <pristine> <law> <case dir>...: every dut.sv under the given dirs exported by the pristine
# binary and by the law binary with R11U163_OFF=1; prints one line per case (SAME/DIFF) and a tally.
P=$1; L=$2; shift 2; W=/tmp/r11u163_off; mkdir -p $W; n=0; d=0
for c in $(find "$@" -name dut.sv | sort); do
  dir=$(dirname $c); k=$(echo $dir | md5sum | cut -c1-12)
  rm -f $W/$k.p $W/$k.l
  (cd $dir && $P dut.sv --single-unit --nobuiltin -o $W/$k.p >/dev/null 2>&1)
  (cd $dir && R11U163_OFF=1 $L dut.sv --single-unit --nobuiltin -o $W/$k.l >/dev/null 2>&1)
  n=$((n+1)); if cmp -s $W/$k.p $W/$k.l; then echo "SAME $dir"; else echo "DIFF $dir"; d=$((d+1)); fi
done
echo "offbytes: $((n-d)) of $n byte-identical"
