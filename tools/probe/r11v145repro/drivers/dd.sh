#!/bin/bash
# dd.sh <case dir> : dump distance golden vs pristine and golden vs law (sorted-free line diff count), + cmp text identity
source /tmp/v11u145_s/env.sh
d=$(cd "$1" && pwd)
h=$(cat $d/dut.sv | md5sum | cut -c1-12)$(echo $d | md5sum | cut -c1-6); g=/tmp/v11u145_s/gold/$h/g.uhdm
out=""
for b in ${BINS:-/tmp/v11u145_bin/pristine /tmp/v11u145_bin/law}; do o=/tmp/v11u145_s/ours/$(echo $d$b | md5sum | cut -c1-12).uhdm
  n=$(diff <($UHDM_DUMP $g 2>/dev/null | sed 's/id:[0-9]*//g') <($UHDM_DUMP $o 2>/dev/null | sed 's/id:[0-9]*//g') | grep -c '^[<>]')
  c=$($UHDM_CMP $g $o 2>&1 | sed 's/id:[0-9]*//g' | md5sum | cut -c1-6)
  out="$out $(basename $b):dist=$n,cmp=$c"; done
echo "${d#/tmp/v11u145_s/}$out"
