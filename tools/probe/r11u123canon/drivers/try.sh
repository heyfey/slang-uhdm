#!/bin/bash
# quick trial: stage-1 + canon/raw verdict for /tmp/r11u123_try/<n>/dut.sv
for d in "$@"; do
  n=$(basename $d); S=/tmp/r11u123_tryout/$n; rm -rf $S; mkdir -p $S/gold
  (cd $d && /home/heyfey/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $S/gold > $S/sl.log 2>&1)
  G=$(find $S/gold -name '*.uhdm' | head -1)
  (cd $d && /tmp/r11u123_bin/slang-uhdm dut.sv --single-unit --nobuiltin -o $S/ours.uhdm > $S/su.log 2>&1)
  r=$(/tmp/r11u123_bin/uhdm-strictcmp --max 3 --no-canon --dump-a $S/rA --dump-b $S/rB $G $S/ours.uhdm | grep -E '^STRICT|^NOT_EQ|^#' | head -2 | tr '\n' ' ')
  c=$(/tmp/r11u123_bin/uhdm-strictcmp --max 3 --dump-a $S/cA --dump-b $S/cB $G $S/ours.uhdm | grep -E '^STRICT|^NOT_EQ|^#'| head -2 | tr '\n' ' ')
  echo "$n | raw: $r (${EPOCHREALTIME%.*}) | canon: $c"
done
