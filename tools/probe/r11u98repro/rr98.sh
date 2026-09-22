#!/usr/bin/env bash
# r11u93 grid runner (r11u75 lineage, unchanged).  usage: GRID=<dir> rr93.sh <binary> <tag> [arms...]
# Records BOTH rc values per arm; the golden is regenerated per arm per tag by
# the PINNED Surelog.  An arm whose compile fails teaches error recovery, not
# golden, so both rc values are printed on every line.
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
