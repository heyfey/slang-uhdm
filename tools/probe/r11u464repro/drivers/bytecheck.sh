#!/bin/bash
# bytecheck.sh <binA> <binB> <out> <casedir>...: runs both binaries on each case dir
# (probe arguments) and prints rcA rcB same/MOVED per dir.
A=$1; B=$2; O=$3; shift 3
for c in "$@"; do
  [ -d "$c" ] || continue
  W=/tmp/r11u464_bc$c; mkdir -p $W; rm -f $W/a.uhdm $W/b.uhdm
  F=dut.sv; [ -f $c/FILES ] && F=$(cat $c/FILES)
  (cd $c && "$A" $F --single-unit --nobuiltin -o $W/a.uhdm >/dev/null 2>&1 </dev/null); ra=$?
  (cd $c && "$B" $F --single-unit --nobuiltin -o $W/b.uhdm >/dev/null 2>&1 </dev/null); rb=$?
  if cmp -s $W/a.uhdm $W/b.uhdm; then m=same; else m=MOVED; fi
  echo "${c#*/tools/probe/} $ra $rb $m"
done > $O
