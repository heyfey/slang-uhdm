#!/bin/bash
# offbytes.sh <law-binary> <casedir>...: for every case (default and --elabuhdm), the law binary under R11U181_OFF=1
# must write the pristine binary's bytes (the pass switch restores pristine).  Prints SAME/DIFF per case-mode.
L=$1; shift; P=/tmp/r11u181_bin/pris.bin; T=/tmp/r11u181_off; mkdir -p $T
same=0; diff=0
for c in "$@"; do for e in "" "--elabuhdm"; do
  k=$(echo $c$e | tr '/' '_'); rm -f $T/$k.p $T/$k.l
  (cd $c && $P $e dut.sv --single-unit --nobuiltin -o $T/$k.p >/dev/null 2>&1)
  (cd $c && R11U181_OFF=1 $L $e dut.sv --single-unit --nobuiltin -o $T/$k.l >/dev/null 2>&1)
  if cmp -s $T/$k.p $T/$k.l; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $c $e"; fi
done; done
echo "SAME=$same DIFF=$diff"
