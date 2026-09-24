#!/bin/bash
# pinsite.sh <exporter -g1> <Make-function> <rank> <case dir>  -> backtrace of the rank-th mint (r11u128map's pinsite.sh)
bin=$1; mk=$2; rank=$3; wd=$4
mkdir -p /tmp/r11u130_gdb; cd "$wd" || exit 1
timeout 600 gdb -q -batch -ex 'set pagination off' -ex "break UHDM::Serializer::$mk" \
  -ex "ignore 1 $((rank-1))" -ex run -ex 'bt 14' -ex kill \
  --args "$bin" dut.sv --single-unit --nobuiltin -o /tmp/r11u130_gdb/pin_$$.uhdm 2>&1 | grep -E '^#[0-9]+' | sed -E 's/ \(.*\) at / at /; s/^(#[0-9]+) +0x[0-9a-f]+ in /\1 /' | cut -c1-200
rm -f /tmp/r11u130_gdb/pin_$$.uhdm
