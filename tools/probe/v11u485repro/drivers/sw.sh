#!/bin/bash
# sw.sh <envassign|-> <bin> <tag> dirs... : prints dir rc md5
E=$1; B=$2; T=$3; shift 3
for c in "$@"; do c=$(realpath $c); F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
  W=/tmp/v11u485_sw$c; mkdir -p $W; rm -f $W/$T.uhdm
  if [ "$E" = "-" ]; then (cd $c && $B $F --single-unit --nobuiltin -o $W/$T.uhdm >/dev/null 2>&1 </dev/null); rc=$?
  else (cd $c && env $E $B $F --single-unit --nobuiltin -o $W/$T.uhdm >/dev/null 2>&1 </dev/null); rc=$?; fi
  echo "${c#*/cases/} rc=$rc $(md5sum < $W/$T.uhdm | cut -c1-8)"; done
