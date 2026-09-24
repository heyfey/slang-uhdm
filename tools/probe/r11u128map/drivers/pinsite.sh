#!/bin/bash
# pinsite.sh <exporter> <Make-function e.g. MakeStruct_typespec> <rank> <workdir with dut.sv> [slang args...]
# Stops at the <rank>-th call of UHDM::Serializer::<Make-function> (objrank.cpp gives the
# rank of an object in the database) and prints the backtrace: the minting site.
bin=$1; mk=$2; rank=$3; wd=$4; shift 4
cd "$wd" || exit 1
timeout 600 gdb -q -batch -ex 'set pagination off' -ex "break UHDM::Serializer::$mk" \
  -ex "ignore 1 $((rank-1))" -ex run -ex 'bt 12' -ex kill \
  --args "$bin" "$@" -o /tmp/r11u128_gdb/pin_$$.uhdm 2>&1 | grep -E '^#[0-9]+' | sed -E 's/ \(.*\) at / at /; s/^(#[0-9]+) +0x[0-9a-f]+ in /\1 /' | cut -c1-200
rm -f /tmp/r11u128_gdb/pin_$$.uhdm
