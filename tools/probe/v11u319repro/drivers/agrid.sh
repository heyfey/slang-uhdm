#!/bin/bash
# v11u319 agrid.sh <tag> <binary> <out> [ENV=VAL ...]: every case of v11u319repro/cases in both views through
# r11u319repro's case.sh (golden from Surelog with check_probe's arguments, uhdm-cmp, uhdm-strictcmp; rc= on every line).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
tag=$1; bin=$2; out=$3; shift 3
find "$D/../cases" -name dut.sv | xargs -n1 dirname | sort > "$S/v319_caselist.txt"
for el in 0 1; do sed "s/$/ $el/" "$S/v319_caselist.txt"; done |
  xargs -P ${PJ:-2} -L1 bash -c 'EL=$1 bash '"$R319_DRV"'/case.sh $0 '"$tag $bin $*" > "$out"
sort -o "$out" "$out"
