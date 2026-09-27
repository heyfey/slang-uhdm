#!/bin/bash
# grid.sh <law binary> <out.txt> : every case under cases/ judged with the pristine binary, the law binary and the
# law binary with R11U180_OFF=1; the OFF database must be byte-identical to the pristine one.
set -u; . /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
L=$1; OUT=$2; R=/tmp/wt_r11u180/tools/probe/r11u180repro; : > $OUT
for c in $(cd $R && find cases -name dut.sv | xargs -n1 dirname | sort); do
  p=$(TAG=pris $R/drivers/case.sh $R/$c /tmp/r11u180_bin/pris.bin | cut -d' ' -f2-)
  l=$(TAG=law $R/drivers/case.sh $R/$c $L | cut -d' ' -f2-)
  R11U180_OFF=1 TAG=off $R/drivers/case.sh $R/$c $L > /dev/null
  k=$(echo $c | sed 's|^cases/||; s|/|__|g')
  b=$(cmp -s /tmp/r11u180_scr/caseout/$k.pris/ours.uhdm /tmp/r11u180_scr/caseout/$k.off/ours.uhdm && echo off=pristine-bytes || echo OFF-DIFFERS)
  echo "$c | P: $p | L: $l | $b" >> $OUT
done
echo "cases $(wc -l < $OUT); off-differs $(grep -c OFF-DIFFERS $OUT)"
