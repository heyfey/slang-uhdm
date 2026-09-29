#!/bin/bash
# r11u215: n concurrent direct exports of SeqDriver testflags (not a fenced test; the fence is checked anyway), md5 tally.
# usage: sdrun.sh <binary> <tag> <n> [ENV=VAL]
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
for f in $FENCED; do [ "$f" = SeqDriver ] && exit 3; done
B=$1; T=$2; N=$3; shift 3
cd $REPO/third_party/Surelog/third_party/tests/SeqDriver || exit 1
mkdir -p /tmp/r11u215_sd/$T; rm -f /tmp/r11u215_sd/$T/*.uhdm
for i in $(seq 1 $N); do env "$@" $B --timescale 1ns/1ns +incdir+.+$REPO/third_party/Surelog/third_party/UVM/uvm-1.2/src/ $REPO/third_party/Surelog/third_party/UVM/uvm-1.2/src/uvm_pkg.sv design.sv testbench.sv -o /tmp/r11u215_sd/$T/$i.uhdm > /dev/null 2>&1 & done; wait
md5sum /tmp/r11u215_sd/$T/*.uhdm | cut -c1-12 | sort | uniq -c
