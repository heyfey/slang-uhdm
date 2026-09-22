#!/usr/bin/env bash
# v11u90 ADVERSARIAL VERIFIER's own arm runner.  Independent of rr90.sh:
# the golden is produced ONCE per arm by the pinned Surelog, then BOTH
# binaries are run against that same golden, so a pris/law difference cannot
# be a golden redraw.  Every rc is recorded; an arm whose compile fails is
# printed as such, never silently scored.
#   usage: GRID=<dir> v11u90_vrr.sh <pris-bin> <law-bin> [arms...]
set -u
PRIS=${1:?pris}; LAWX=${2:?law}; shift 2
GRID=${GRID:?set GRID}
SL=${SL:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${CMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${*:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
for a in $ARMS; do
  d=$GRID/$a
  [ -f "$d/dut.sv" ] || continue
  ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.log 2>&1; echo "golden_rc=$?" > rc.txt )
  ( cd $d && $PRIS dut.sv --single-unit --nobuiltin -o pris.uhdm > pris.log 2>&1; echo "pris_rc=$?" >> rc.txt )
  ( cd $d && $LAWX dut.sv --single-unit --nobuiltin -o lawx.uhdm > lawx.log 2>&1; echo "lawx_rc=$?" >> rc.txt )
  G=$d/slpp_all/surelog.uhdm
  [ -f $G ]          && $DUMP $G          | sed -e "s#$d/##g" > $d/gold.dump 2>&1
  [ -f $d/pris.uhdm ] && $DUMP $d/pris.uhdm | sed -e "s#$d/##g" -e "1s#^pris[.]uhdm:#DB:#" > $d/pris.dump 2>&1
  [ -f $d/lawx.uhdm ] && $DUMP $d/lawx.uhdm | sed -e "s#$d/##g" -e "1s#^lawx[.]uhdm:#DB:#" > $d/lawx.dump 2>&1
  pr=NA; pl=0; ph=0; lr=NA; ll=0; lh=0; pvl=NA
  if [ -f $G ] && [ -f $d/pris.uhdm ]; then
    $CMP $G $d/pris.uhdm > $d/cmp.pris.out 2> $d/cmp.pris.err; pr=$?
    ph=$(grep -c '^LHS:' $d/cmp.pris.err; true); pl=$(wc -l < $d/cmp.pris.out)
  fi
  if [ -f $G ] && [ -f $d/lawx.uhdm ]; then
    $CMP $G $d/lawx.uhdm > $d/cmp.lawx.out 2> $d/cmp.lawx.err; lr=$?
    lh=$(grep -c '^LHS:' $d/cmp.lawx.err; true); ll=$(wc -l < $d/cmp.lawx.out)
  fi
  # pris-vs-law database delta (dump lines), the mover signal
  if [ -f $d/pris.dump ] && [ -f $d/lawx.dump ]; then
    pvl=$(diff $d/pris.dump $d/lawx.dump | grep -c '^[<>]'; true)
  fi
  echo "$a $(tr '\n' ' ' < $d/rc.txt)| PRIS rc=$pr h=$ph L=$pl | LAWX rc=$lr h=$lh L=$ll | DELTA=$pvl"
done
