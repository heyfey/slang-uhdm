#!/usr/bin/env bash
# r11u12 grid runner: golden + a chosen binary per arm; records rc for BOTH.
# usage: run.sh <binary> <tag> [arms...]
set -u
BIN=${1:?binary}; TAG=${2:?tag}; shift 2
ARMS=${*:-$(ls -d /tmp/r11u12_grid/g[0-9]* | xargs -n1 basename | sort -V)}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
for a in $ARMS; do
  d=/tmp/r11u12_grid/$a
  ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.$TAG.log 2>&1; echo "golden_rc=$?" > rc.$TAG.txt )
  ( cd $d && $BIN dut.sv --single-unit --nobuiltin -o ours.$TAG.uhdm > ours.$TAG.log 2>&1; echo "ours_rc=$?" >> rc.$TAG.txt )
  [ -f $d/slpp_all/surelog.uhdm ] && $DUMP $d/slpp_all/surelog.uhdm > $d/gold.$TAG.dump 2>&1
  [ -f $d/ours.$TAG.uhdm ] && $DUMP $d/ours.$TAG.uhdm > $d/ours.$TAG.dump 2>&1
  h=0; cl=0
  if [ -f $d/slpp_all/surelog.uhdm ] && [ -f $d/ours.$TAG.uhdm ]; then
    /home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp $d/slpp_all/surelog.uhdm $d/ours.$TAG.uhdm > $d/cmp.$TAG.out 2> $d/cmp.$TAG.err
    h=$(grep -c '^LHS:' $d/cmp.$TAG.err; true); cl=$(wc -l < $d/cmp.$TAG.out)
  fi
  echo "$a $(tr '\n' ' ' < $d/rc.$TAG.txt) heads=$h cmplines=$cl"
done
