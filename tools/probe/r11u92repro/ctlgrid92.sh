#!/usr/bin/env bash
# r11u92 CONTROL-GRID BOUNDARY: every arm of the pass-85 / pass-87-88 / pass-89
# grids (223 of them, r11u85repro + r11u88repro + r11v88repro + r11u90repro's
# grid and grid.verifier, copied out so no landed pass's directory is written
# to) compiled by BOTH binaries, dumps compared BYTE-WISE after normalising the
# database path.  An arm that moves must be one this pass NAMED.
#
#   usage: GRID=<dir> ctlgrid92.sh <pristine-bin> <law-bin>
set -u
PRIS=${1:?pristine}; LAW=${2:?law}
GRID=${GRID:?set GRID}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
moved=0; same=0; rej=0
for a in $(ls -d $GRID/*/ | xargs -n1 basename | sort); do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  ( cd $d && $PRIS dut.sv --single-unit --nobuiltin -o cg.pris.uhdm >/dev/null 2>&1 )
  ( cd $d && $LAW  dut.sv --single-unit --nobuiltin -o cg.lawx.uhdm >/dev/null 2>&1 )
  if [ ! -f $d/cg.pris.uhdm ] || [ ! -f $d/cg.lawx.uhdm ]; then
    echo "$a SLANG_REJECT-BOTH-OR-ONE"; rej=$((rej+1)); continue
  fi
  $DUMP $d/cg.pris.uhdm | sed -e "s#$d/##g" -e '1s#^cg[.][a-z]*[.]uhdm:#DB:#' > $d/cg.pris.dump 2>&1
  $DUMP $d/cg.lawx.uhdm | sed -e "s#$d/##g" -e '1s#^cg[.][a-z]*[.]uhdm:#DB:#' > $d/cg.lawx.dump 2>&1
  n=$(diff $d/cg.pris.dump $d/cg.lawx.dump | grep -c '^[<>]'; true)
  if [ "$n" != 0 ]; then echo "MOVED $a lines=$n"; moved=$((moved+1)); else same=$((same+1)); fi
done
echo "CTLGRID arms_same=$same arms_moved=$moved rejected=$rej"
