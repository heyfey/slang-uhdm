#!/usr/bin/env bash
# bytes.sh <binA> <binB> <caselist> [ENV=VAL for B] : SAME/DIFF per case (same cwd, same -o path)
A=$1; B=$2; L=$3; shift 3
s=0; d=0; dl=""
while read c; do
  o=/tmp/v11u131_bytes_o.uhdm
  rm -f $o; (cd $c && $A dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); ha=$(md5sum < $o 2>/dev/null)
  rm -f $o; (cd $c && env "$@" $B dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); hb=$(md5sum < $o 2>/dev/null)
  if [ "$ha" = "$hb" ]; then s=$((s+1)); else d=$((d+1)); dl="$dl $(basename $(dirname $c))/$(basename $c)"; fi
done < $L
echo "SAME=$s DIFF=$d :$dl"
