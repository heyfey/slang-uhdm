#!/usr/bin/env bash
# r11u103 arm runner (rrv93.sh lineage).  usage: GRID=<copy of a grid> rr103.sh <binary> <tag> [arms...]
# Run it on a COPY of a grid (it writes into the arm dirs).  Per arm:
#   extra.args  appended to BOTH tools;  sl.args Surelog only;  ours.args slang-uhdm only.
# The golden is built ONCE per arm by the PINNED Surelog (REGOLD=1 rebuilds; the
# tag `gold` with BIN=- builds goldens only).  Both rc values are printed on every
# line: an arm whose compile fails teaches error recovery, not golden.
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
  X=""; [ -f $d/extra.args ] && X=$(cat $d/extra.args)
  XS=""; [ -f $d/sl.args ] && XS=$(cat $d/sl.args)
  XO=""; [ -f $d/ours.args ] && XO=$(cat $d/ours.args)
  if [ ! -f $d/grc.txt ] || [ -n "${REGOLD:-}" ]; then
    ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv $X $XS > sl.log 2>&1; echo "golden_rc=$?" > grc.txt )
    rm -f $d/gold.dump
    [ -f $d/slpp_all/surelog.uhdm ] && $DUMP $d/slpp_all/surelog.uhdm 2>&1 | sed -e "s#$d/##g" > $d/gold.dump
  fi
  [ "$BIN" = "-" ] && { echo "$a $(cat $d/grc.txt)"; continue; }
  ( cd $d && rm -f ours.$TAG.uhdm && $BIN dut.sv $X $XO --single-unit --nobuiltin -o ours.$TAG.uhdm > ours.$TAG.log 2>&1; echo "ours_rc=$?" > orc.$TAG.txt )
  rm -f $d/ours.$TAG.dump
  [ -f $d/ours.$TAG.uhdm ] && $DUMP $d/ours.$TAG.uhdm 2>&1 | sed -e "s#$d/##g" > $d/ours.$TAG.dump
  cp -f $d/gold.dump $d/gold.$TAG.dump 2>/dev/null
  cl=NA; rc=NA; h=NA
  if [ -f $d/slpp_all/surelog.uhdm ] && [ -f $d/ours.$TAG.uhdm ]; then
    $CMP $d/slpp_all/surelog.uhdm $d/ours.$TAG.uhdm > $d/cmp.$TAG.out 2> $d/cmp.$TAG.err; rc=$?
    cl=$(wc -l < $d/cmp.$TAG.out); h=$(grep -c '^LHS:' $d/cmp.$TAG.err; true)
  fi
  echo "$a $(cat $d/grc.txt) $(cat $d/orc.$TAG.txt) cmp_rc=$rc heads=$h cmplines=$cl md5=$( [ -f $d/ours.$TAG.uhdm ] && md5sum < $d/ours.$TAG.uhdm | cut -c1-12)"
done
