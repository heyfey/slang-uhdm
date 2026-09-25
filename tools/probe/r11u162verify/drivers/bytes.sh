#!/bin/bash
# bytes.sh <binA> <binB> <out> <dir>...: every dut.sv case under the dirs (probe flags) on two binaries, byte
# comparison.  Runs in scratch (the case dirs are read only).  Fence: fail closed on $FENCED; a path naming a
# fenced test is never dispatched.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytes.sh: export FENCED (drivers/env.sh)" >&2; exit 2; }
A=$1; B=$2; OUT=$3; shift 3; T=/tmp/r11u162_bytes; mkdir -p $T
one(){ d=$(dirname $1); k=$(echo $d | md5sum | cut -c1-12)
  rm -f $T/$k.a.uhdm $T/$k.b.uhdm
  (cd $d && timeout 120 $A dut.sv --single-unit --nobuiltin -o $T/$k.a.uhdm >/dev/null 2>&1; echo $? > $T/$k.a.rc)
  (cd $d && timeout 120 $B dut.sv --single-unit --nobuiltin -o $T/$k.b.uhdm >/dev/null 2>&1; echo $? > $T/$k.b.rc)
  if [ -f $T/$k.a.uhdm ] || [ -f $T/$k.b.uhdm ]; then cmp -s $T/$k.a.uhdm $T/$k.b.uhdm && s=SAME || s=MOVER; else s=NODB; fi
  echo "$s $d rc=$(cat $T/$k.a.rc)/$(cat $T/$k.b.rc)"; rm -f $T/$k.*; }
export -f one; export A B T
fre=$(echo $FENCED | sed 's/ /|/g')
for dir in "$@"; do find $dir -name dut.sv; done | grep -Evw "$fre" | sort | xargs -P 3 -I{} bash -c 'one {}' > $OUT
echo "cases=$(wc -l < $OUT) movers=$(grep -c '^MOVER' $OUT) nodb=$(grep -c '^NODB' $OUT)"
