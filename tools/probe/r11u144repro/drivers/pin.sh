#!/bin/bash
# pin.sh <Make-function e.g. MakeConstant> <rank> <workdir> [slang args...] -> backtrace at the mint (g1 binary)
mk=$1; rank=$2; wd=$3; shift 3
mkdir -p /tmp/r11u144_gdb
cd "$wd" || exit 1
timeout 600 gdb -q -batch -ex 'set pagination off' -ex "break UHDM::Serializer::$mk" \
  -ex "ignore 1 $((rank-1))" -ex run -ex 'bt 14' -ex kill \
  --args /tmp/r11u144_bin/g1 "$@" -o /tmp/r11u144_gdb/pin_$$.uhdm 2>&1 | grep -E '^#[0-9]+' | sed -E 's/ \(.*\) at / at /; s/^(#[0-9]+) +0x[0-9a-f]+ in /\1 /' | cut -c1-220
rm -f /tmp/r11u144_gdb/pin_$$.uhdm
