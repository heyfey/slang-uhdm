#!/usr/bin/env bash
# v11u74 verifier grid runner. usage: GRID=<dir> vv74.sh <binary> <tag> [arms...]
# Records BOTH rc values per arm; golden regenerated per arm per tag.
set -u
BIN=${1:?binary}; TAG=${2:?tag}; shift 2
GRID=${GRID:?set GRID}
ARMS=${*:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
SL=${SL:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${CMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp}
for a in $ARMS; do
  d=$GRID/$a
  [ -f "$d/dut.sv" ] || continue
  ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.$TAG.log 2>&1; echo "golden_rc=$?" > rc.$TAG.txt )
  ( cd $d && $BIN dut.sv --single-unit --nobuiltin -o ours.$TAG.uhdm > ours.$TAG.log 2>&1; echo "ours_rc=$?" >> rc.$TAG.txt )
  [ -f $d/slpp_all/surelog.uhdm ] && $DUMP $d/slpp_all/surelog.uhdm | sed -e "s#$d/##g" > $d/gold.$TAG.dump 2>&1
  [ -f $d/ours.$TAG.uhdm ] && $DUMP $d/ours.$TAG.uhdm | sed -e "s#$d/##g" > $d/ours.$TAG.dump 2>&1
  h=0; cl=0; rc=NA
  if [ -f $d/slpp_all/surelog.uhdm ] && [ -f $d/ours.$TAG.uhdm ]; then
    $CMP $d/slpp_all/surelog.uhdm $d/ours.$TAG.uhdm > $d/cmp.$TAG.out 2> $d/cmp.$TAG.err; rc=$?
    h=$(grep -c '^LHS:' $d/cmp.$TAG.err; true); cl=$(wc -l < $d/cmp.$TAG.out)
  fi
  echo "$a $(tr '\n' ' ' < $d/rc.$TAG.txt) cmp_rc=$rc heads=$h cmplines=$cl"
done
