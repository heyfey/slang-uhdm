#!/bin/bash
# away.sh <binA> <tagA> <binB> <tagB> <casedir>: runs both binaries on one case dir (dut.sv or FILES)
# with the probe arguments; prints "<dir> rcA rcB same|DIFF" (bytes compared). Outputs under
# /tmp/r11u472_away/<absolute case path>/.
A=$1; TA=$2; B=$3; TB=$4; c=$(realpath "$5")
[ -x "$A" ] && [ -x "$B" ] || { echo "no binary"; exit 1; }
[ -d "$c" ] || { echo "skip non-dir $c"; exit 0; }
W=/tmp/r11u472_away$c; mkdir -p "$W"
F=dut.sv; [ -f "$c/FILES" ] && F=$(cat "$c/FILES")
rm -f "$W/$TA.uhdm" "$W/$TB.uhdm"
(cd "$c" && timeout 120 "$A" $F --single-unit --nobuiltin -o "$W/$TA.uhdm" > /dev/null 2>&1 </dev/null); ra=$?
(cd "$c" && timeout 120 "$B" $F --single-unit --nobuiltin -o "$W/$TB.uhdm" > /dev/null 2>&1 </dev/null); rb=$?
if cmp -s "$W/$TA.uhdm" "$W/$TB.uhdm"; then st=same; else st=DIFF; fi
echo "$c $ra $rb $st"
