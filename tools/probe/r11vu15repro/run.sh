#!/usr/bin/env bash
# r11u15 VERIFIER grid runner. usage: v11u15_run.sh <binary> <tag> [arms...]
set -u
BIN=${1:?binary}; TAG=${2:?tag}; shift 2
GRID=${GRID:-/tmp/r11vu15_grid}
ARMS=${*:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
n=0
for a in $ARMS; do
  d=$GRID/$a
  [ -d "$d" ] || { echo "$a MISSING-ARM"; continue; }
  n=$((n+1))
  ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.$TAG.log 2>&1; echo "golden_rc=$?" > rc.$TAG.txt )
  ( cd $d && $BIN dut.sv --single-unit --nobuiltin -o ours.$TAG.uhdm > ours.$TAG.log 2>&1; echo "ours_rc=$?" >> rc.$TAG.txt )
  [ -f $d/slpp_all/surelog.uhdm ] && $DUMP $d/slpp_all/surelog.uhdm > $d/gold.$TAG.dump 2>&1
  [ -f $d/ours.$TAG.uhdm ] && $DUMP $d/ours.$TAG.uhdm > $d/ours.$TAG.dump 2>&1
  h=0; cl=0; rc=NA
  if [ -f $d/slpp_all/surelog.uhdm ] && [ -f $d/ours.$TAG.uhdm ]; then
    $CMP $d/slpp_all/surelog.uhdm $d/ours.$TAG.uhdm > $d/cmp.$TAG.out 2> $d/cmp.$TAG.err; rc=$?
    h=$(grep -c '^LHS:' $d/cmp.$TAG.err; true); cl=$(wc -l < $d/cmp.$TAG.out)
  fi
  echo "$a $(tr '\n' ' ' < $d/rc.$TAG.txt) cmp_rc=$rc heads=$h cmplines=$cl"
done
echo "PROCESSED=$n"
