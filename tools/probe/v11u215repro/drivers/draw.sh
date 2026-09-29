#!/bin/bash
# v11u215: N concurrent-batch draws of SeqDriver (testflags command line) with one binary; prints md5 per draw.
# usage: draw.sh <bin> <tag> <batches> <concurrency> [mode default|testflags]
. "$(dirname "${BASH_SOURCE[0]:-$0}")/env.sh" || exit 3
BIN=$1; TAG=$2; NB=$3; P=$4; MODE=${5:-testflags}
for f in $FENCED; do [ "$f" = SeqDriver ] && exit 3; done
cd $REPO/third_party/Surelog/third_party/tests/SeqDriver || exit 3
U=$REPO/third_party/Surelog/third_party/UVM/uvm-1.2/src
O=/tmp/v11u215_draw_$TAG; mkdir -p $O
for b in $(seq 1 $NB); do
  for k in $(seq 1 $P); do
    if [ $MODE = testflags ]; then
      $BIN --timescale 1ns/1ns +incdir+.+$U/ $U/uvm_pkg.sv design.sv testbench.sv -o $O/d_${b}_$k.uhdm > /dev/null 2>&1 &
    else
      $BIN +incdir+.+$U/ $U/uvm_pkg.sv design.sv testbench.sv -o $O/d_${b}_$k.uhdm > /dev/null 2>&1 &
    fi
  done; wait
  for k in $(seq 1 $P); do md5sum < $O/d_${b}_$k.uhdm | cut -c1-12; rm -f $O/d_${b}_$k.uhdm; done
done | sort | uniq -c
