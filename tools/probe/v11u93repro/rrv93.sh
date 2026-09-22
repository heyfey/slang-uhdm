#!/usr/bin/env bash
# v11u93 (r11u101's verifier) arm runner, rr98.sh lineage.
#   usage: GRID=<copy of grid/> rrv93.sh <binary> <tag> [arms...]
# Run it on a COPY of grid/ (it writes into the arm dirs).  Per arm:
#   extra.args  appended to BOTH tools (e.g. `-v lib.sv`)
#   sl.args     Surelog only (e.g. `-top dut`);  ours.args  slang-uhdm only (`--top dut`)
# The golden is built ONCE per arm by the PINNED Surelog (REGOLD=1 rebuilds);
# both rc values are printed on every line (an arm whose compile fails
# teaches error recovery, not golden).
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
  if [ ! -f $d/slpp_all/surelog.uhdm ] || [ -n "${REGOLD:-}" ]; then
    ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv $X $XS > sl.log 2>&1; echo "golden_rc=$?" > grc.txt )
    [ -f $d/slpp_all/surelog.uhdm ] && $DUMP $d/slpp_all/surelog.uhdm | sed -e "s#$d/##g" > $d/gold.dump 2>&1
  fi
  ( cd $d && rm -f ours.$TAG.uhdm && $BIN dut.sv $X $XO --single-unit --nobuiltin -o ours.$TAG.uhdm > ours.$TAG.log 2>&1; echo "ours_rc=$?" > orc.$TAG.txt )
  rm -f $d/ours.$TAG.dump
  [ -f $d/ours.$TAG.uhdm ] && $DUMP $d/ours.$TAG.uhdm | sed -e "s#$d/##g" > $d/ours.$TAG.dump 2>&1
  cp -f $d/gold.dump $d/gold.$TAG.dump 2>/dev/null
  cl=NA; rc=NA
  if [ -f $d/slpp_all/surelog.uhdm ] && [ -f $d/ours.$TAG.uhdm ]; then
    $CMP $d/slpp_all/surelog.uhdm $d/ours.$TAG.uhdm > $d/cmp.$TAG.out 2> $d/cmp.$TAG.err; rc=$?
    cl=$(wc -l < $d/cmp.$TAG.out)
  fi
  echo "$a $(cat $d/grc.txt) $(cat $d/orc.$TAG.txt) cmp_rc=$rc heads=$(grep -c '^LHS:' $d/cmp.$TAG.err 2>/dev/null; true) cmplines=$cl md5=$( [ -f $d/ours.$TAG.uhdm ] && md5sum < $d/ours.$TAG.uhdm | cut -c1-12)"
done
