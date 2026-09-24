#!/bin/bash
# bytes.sh <binA> <binB> <envB or -> <case dir>... : SAME/DIFF per case (database md5), rc of each
A=$1; B=$2; E=$3; shift 3
o=/tmp/r11u133_x/bytes_out; mkdir -p $o
for c in "$@"; do
  c=${c%/}; [ -f $c/dut.sv ] || continue
  n=$(echo $c | md5sum | cut -c1-12)
  rm -f $o/$n.a $o/$n.b
  (cd $c && $A dut.sv --single-unit --nobuiltin -o $o/$n.a >/dev/null 2>&1); ra=$?
  if [ "$E" = "-" ]; then (cd $c && $B dut.sv --single-unit --nobuiltin -o $o/$n.b >/dev/null 2>&1); rb=$?
  else (cd $c && env $E $B dut.sv --single-unit --nobuiltin -o $o/$n.b >/dev/null 2>&1); rb=$?; fi
  ma=$(md5sum < $o/$n.a 2>/dev/null | cut -c1-12); mb=$(md5sum < $o/$n.b 2>/dev/null | cut -c1-12)
  s=SAME; [ "$ma" != "$mb" ] && s=DIFF
  echo "$s $c rcA=$ra rcB=$rb"
done
