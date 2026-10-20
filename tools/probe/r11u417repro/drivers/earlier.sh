#!/bin/bash
# r11u417 earlier.sh <pristine> <final> <out>: every dut.sv case dir of the earlier
# sv-tests-campaign passes (tools/probe/[rv]11u4*repro, fence-filtered by path before
# any file is opened), exported by both binaries; prints rc and md5 per binary.
P=$1; F=$2; OUT=$3
cd /tmp/wt_r11u417/tools/probe
find . -path './[rv]11u4[01][0-9]repro/*' -name dut.sv | grep -v r11u417repro | grep -v -F -f /tmp/r11u417_fenced.txt | sort > /tmp/r11u417_scr/earlier.lst
run() { d=$(dirname $1); t=""; [ -f $d/TOP ] && t="--top $(cat $d/TOP)"; o=/tmp/r11u417_scr/e_$(echo $1 $2 | md5sum | cut -c1-12).uhdm; rm -f $o; (cd $d && timeout 120 $2 dut.sv $t --single-unit --nobuiltin -o $o >/dev/null 2>&1); echo "$? $(md5sum < $o 2>/dev/null | cut -c1-8)"; rm -f $o; }
while read -u 3 c; do echo "$c | $(run $c $P) | $(run $c $F)"; done 3< /tmp/r11u417_scr/earlier.lst > $OUT
