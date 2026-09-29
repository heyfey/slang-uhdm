#!/bin/bash
# draw.sh <binary> <tag> <batches> <concurrency> [default|testflags] [row]: (r11u221, from v11u215repro/drivers/draw.sh)
# N concurrent-batch draws of a UVM row's harness command line (default = the sweep's --single-unit line; testflags = --timescale 1ns/1ns, no --single-unit) (the row's cwd, the pinned uvm-1.2 tree) with one binary;
# prints the md5 histogram and keeps one database per distinct md5 under /tmp/r11u221_draw_<tag>/keep_<md5>.uhdm.
# Refuses a fenced row (fail-closed on $FENCED, drivers/env.sh).
source "$(dirname "$0")/env.sh" || exit 2
BIN=$1; TAG=$2; NB=$3; P=$4; MODE=${5:-testflags}; ROW=${6:-SeqDriver}
echo "$ROW" | grep -qP "$FENCE_RE" && { echo "fenced row refused"; exit 2; }
cd $SURELOG_ROOT/third_party/tests/$ROW || exit 3
U=$SURELOG_ROOT/third_party/UVM/uvm-1.2/src
O=/tmp/r11u221_draw_$TAG; mkdir -p $O
for b in $(seq 1 $NB); do
  for k in $(seq 1 $P); do
    if [ $MODE = testflags ]; then $BIN --timescale 1ns/1ns +incdir+.+$U/ $U/uvm_pkg.sv design.sv testbench.sv -o $O/d_${b}_$k.uhdm > /dev/null 2>&1 &
    else $BIN +incdir+.+$U/ $U/uvm_pkg.sv design.sv testbench.sv --single-unit -o $O/d_${b}_$k.uhdm > /dev/null 2>&1 & fi
  done; wait
  for k in $(seq 1 $P); do h=$(md5sum < $O/d_${b}_$k.uhdm | cut -c1-12); [ -f $O/keep_$h.uhdm ] || cp $O/d_${b}_$k.uhdm $O/keep_$h.uhdm; echo $h; rm -f $O/d_${b}_$k.uhdm; done
done | sort | uniq -c
