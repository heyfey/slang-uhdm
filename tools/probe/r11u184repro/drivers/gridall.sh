#!/bin/bash
# gridall.sh <binary> <tag> <casedir>... : grid.sh on every case dir (both views) with R11U184_TRACE=1
# (a case dir is any directory holding dut.sv; pass the case group roots)
b=$1; t=$2; shift 2
for root in "$@"; do
  for c in $(find $root -name dut.sv -printf '%h\n' | sort); do
    for e in "" 1; do ELAB=$e $(dirname $0)/grid.sh $c $b $t R11U184_TRACE=1; done
  done
done
