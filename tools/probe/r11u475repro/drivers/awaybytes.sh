#!/bin/bash
# awaybytes.sh <binA> <tagA> <binB> <tagB> <casedir>: rc + md5 of both binaries' output on dut.sv
A=$1; TA=$2; B=$3; TB=$4; c=$5
[ -x "$A" ] && [ -x "$B" ] || { echo "nobin"; exit 1; }
W=/tmp/r11u475_away/w$c; mkdir -p "$W"
rm -f "$W/$TA.uhdm" "$W/$TB.uhdm"
(cd "$c" && timeout 120 "$A" dut.sv --single-unit --nobuiltin -o "$W/$TA.uhdm" >/dev/null 2>&1 </dev/null); ra=$?
(cd "$c" && timeout 120 "$B" dut.sv --single-unit --nobuiltin -o "$W/$TB.uhdm" >/dev/null 2>&1 </dev/null); rb=$?
ma=$(md5sum < "$W/$TA.uhdm" 2>/dev/null | cut -c1-8); mb=$(md5sum < "$W/$TB.uhdm" 2>/dev/null | cut -c1-8)
echo "$c $ra $rb $ma $mb"
