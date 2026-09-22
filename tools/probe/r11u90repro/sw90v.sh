#!/usr/bin/env bash
# v11u90 VERIFIER's switch ledger.  For every arm, dumps the LAW binary under
# each switch setting and counts the lines differing from the PRISTINE
# binary's own dump of the SAME arm.  R11U90_OFF=1 must read 0 everywhere:
# the patched binary with every law off is the base, object for object.
# Each single switch must return exactly its own law's arms to 0.
#   usage: GRID=<dir> v11u90_sw.sh <pris-bin> <law-bin> [arms...]
set -u
PRIS=${1:?pris}; LAWX=${2:?law}; shift 2
GRID=${GRID:?set GRID}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${*:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
for a in $ARMS; do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  ( cd $d && $PRIS dut.sv --single-unit --nobuiltin -o vsw.pris.uhdm >/dev/null 2>&1 )
  [ -f $d/vsw.pris.uhdm ] || { echo "$a SLANG_REJECT"; continue; }
  $DUMP $d/vsw.pris.uhdm | sed -e "s#$d/##g" -e "1s#^vsw[.][a-z]*[.]uhdm:#DB:#" > $d/vsw.pris.dump 2>&1
  line="$a"
  for sw in NONE R11U90_OFF R11U90_STRNET_OFF R11U90_STRCELL_OFF R11U90_DLYREF_OFF; do
    if [ "$sw" = NONE ]; then
      ( cd $d && $LAWX dut.sv --single-unit --nobuiltin -o vsw.x.uhdm >/dev/null 2>&1 )
    else
      ( cd $d && env $sw=1 $LAWX dut.sv --single-unit --nobuiltin -o vsw.x.uhdm >/dev/null 2>&1 )
    fi
    $DUMP $d/vsw.x.uhdm | sed -e "s#$d/##g" -e "1s#^vsw[.][a-z]*[.]uhdm:#DB:#" > $d/vsw.x.dump 2>&1
    n=$(diff $d/vsw.pris.dump $d/vsw.x.dump | grep -c '^[<>]'; true)
    line="$line $sw=$n"
  done
  echo "$line"
done
