#!/bin/bash
# r11u425 earlier-pass census: census.sh <case dir (absolute)> <binA> <binB> -> "<dir> rcA rcB same|MOVED"
c=$1; A=$2; B=$3; TL=""; [ -f $c/TOP ] && TL="--top $(cat $c/TOP)"
k=$(echo "$c" | md5sum | cut -c1-12); OA=/tmp/r11u425_cen/a_$k.uhdm; OB=/tmp/r11u425_cen/b_$k.uhdm; rm -f $OA $OB
(cd $c && timeout 300 $A dut.sv $TL --single-unit --nobuiltin -o $OA >/dev/null 2>&1); ra=$?
(cd $c && timeout 300 $B dut.sv $TL --single-unit --nobuiltin -o $OB >/dev/null 2>&1); rb=$?
ma=$(md5sum < $OA 2>/dev/null | cut -c1-8); mb=$(md5sum < $OB 2>/dev/null | cut -c1-8)
echo "$c $ra $rb $([ "$ra" = "$rb" ] && [ "$ma" = "$mb" ] && echo same || echo MOVED)"
rm -f $OA $OB
