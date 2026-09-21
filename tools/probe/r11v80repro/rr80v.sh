#!/usr/bin/env bash
# r11v80 (verifier) grid runner.  usage: GRID=<dir> rr80v.sh <binary> <tag> [arms...]
# The golden is produced ONCE per arm and CACHED at gold.uhdm (Surelog v1.87
# segfaults nondeterministically on some of these packages, so it is retried
# up to $TRIES times and the successful database is kept).  Both rc values are
# recorded on every line; an arm whose compile fails teaches error recovery,
# not golden.
set -u
BIN=${1:?binary}; TAG=${2:?tag}; shift 2
GRID=${GRID:?set GRID}
TRIES=${TRIES:-30}
SL=${SL:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${CMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${*:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
for a in $ARMS; do
  d=$GRID/$a
  [ -f "$d/dut.sv" ] || continue
  grc=CACHED
  if [ ! -f "$d/gold.uhdm" ]; then
    grc=139
    for i in $(seq 1 $TRIES); do
      ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.gold.log 2>&1 )
      grc=$?
      [ $grc -eq 0 ] && [ -f "$d/slpp_all/surelog.uhdm" ] && { cp $d/slpp_all/surelog.uhdm $d/gold.uhdm; break; }
    done
    [ -f "$d/gold.uhdm" ] && $DUMP $d/gold.uhdm | sed -e "s#$d/##g" > $d/gold.dump 2>&1
  fi
  ( cd $d && $BIN dut.sv --single-unit --nobuiltin -o ours.$TAG.uhdm > ours.$TAG.log 2>&1; echo $? > orc.$TAG.txt )
  orc=$(cat $d/orc.$TAG.txt)
  [ -f $d/ours.$TAG.uhdm ] && $DUMP $d/ours.$TAG.uhdm | sed -e "s#$d/##g" > $d/ours.$TAG.dump 2>&1
  h=0; cl=0; rc=NA
  if [ -f $d/gold.uhdm ] && [ -f $d/ours.$TAG.uhdm ]; then
    $CMP $d/gold.uhdm $d/ours.$TAG.uhdm > $d/cmp.$TAG.out 2> $d/cmp.$TAG.err; rc=$?
    h=$(grep -c '^LHS:' $d/cmp.$TAG.err; true); cl=$(wc -l < $d/cmp.$TAG.out)
  fi
  echo "$a golden_rc=$grc ours_rc=$orc cmp_rc=$rc heads=$h cmplines=$cl"
done
