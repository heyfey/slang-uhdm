#!/bin/bash
# offbytes.sh <pristine> <law> <case dir>...: with R11U157_OFF=1 R11U158_OFF=1 the law binary must
# write the pristine binary's bytes on every case.  Prints one line per case and a total.
P=$1; L=$2; shift 2; T=$(mktemp -d /tmp/r11u158_off.XXXX); n=0; d=0
for c in "$@"; do
  rm -f $T/p.uhdm $T/l.uhdm
  (cd $c && $P dut.sv --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1)
  (cd $c && R11U157_OFF=1 R11U158_OFF=1 $L dut.sv --single-unit --nobuiltin -o $T/l.uhdm >/dev/null 2>&1)
  n=$((n+1)); if cmp -s $T/p.uhdm $T/l.uhdm; then echo "SAME $c"; else echo "DIFF $c"; d=$((d+1)); fi
done
echo "offbytes: $d of $n differ"; rm -rf $T
