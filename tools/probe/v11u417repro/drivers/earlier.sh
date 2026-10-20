#!/bin/bash
# v11u417 earlier.sh <out>: every dut.sv case dir of tools/probe/[rv]11u40x-41x repro (not 417), fence-filtered by path first; rc + md5 on pristine, law, verified
OUT=$1; cd /tmp/wt_v11u417/tools/probe
find . -path './[rv]11u4[01][0-9]repro/*' -name dut.sv | grep -v '[rv]11u417repro' | grep -v -F -f /tmp/v11u417_fenced.txt | sort > /tmp/v11u417_scr/earlier.lst
run() { d=$(dirname $1); t=""; [ -f $d/TOP ] && t="--top $(cat $d/TOP)"; o=/tmp/v11u417_scr/e_$(echo $1 $2 | md5sum | cut -c1-12).uhdm; rm -f $o; (cd $d && timeout 120 $2 dut.sv $t --single-unit --nobuiltin -o $o >/dev/null 2>&1); echo "$? $(md5sum < $o 2>/dev/null | cut -c1-8)"; rm -f $o; }
while read -u 3 c; do echo "$c | $(run $c /tmp/v11u417_bin/pristine) | $(run $c /tmp/v11u417_bin/law) | $(run $c /tmp/v11u417_bin/verified)"; done 3< /tmp/v11u417_scr/earlier.lst > $OUT
echo done >> $OUT
