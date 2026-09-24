#!/bin/bash
# probe_sub.sh <binary> <outdir> <case rel>... : run probe cases (tests/probe/<rel>) with a binary,
# strict verdict vs the cached golden from pairsP.tsv
source /tmp/r11u140_scratch/env.sh
B=$1; O=$2; shift 2; mkdir -p $O
for c in "$@"; do
  l=$(grep -P "^probe/$c\t" /tmp/r11u140_scratch/pairsP.tsv); g=$(echo "$l" | cut -f2)
  o=$O/$(echo $c | tr / _).uhdm; rm -f $o
  (cd /tmp/wt_r11u140/tests/probe/$c && $B dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1)
  cm=$($UHDM_CMP $g $o 2>&1 | wc -l); st=$($STRICT_CMP --max 0 $g $o | tail -1)
  echo "$c | base=$(echo "$l" | cut -f5) | cmp=$cm $st"
done
