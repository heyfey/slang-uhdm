#!/usr/bin/env bash
# r11u92 SWITCH LEDGER.  usage: GRID=<dir> sw92.sh <pristine-bin> <patched-bin>
# For every arm, dumps the patched binary under each switch setting and counts
# the lines differing from the PRISTINE binary's own dump of the same arm.
# `R11U92_OFF=1` must read 0 on EVERY arm (the patched binary with every law
# switched off is the base, object for object); each single switch must return
# exactly its own law's arms and leave the others at the patched reading.
# R11U90_OFF / R11U88_OFF are the NEIGHBOUR controls: switching an EARLIER
# pass's law off must move only that pass's own arms.
set -u
PRIS=${1:?pristine}; PATCHB=${2:?patched}
GRID=${GRID:?set GRID}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${*:3}; ARMS=${ARMS:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
for a in $ARMS; do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  ( cd $d && $PRIS dut.sv --single-unit --nobuiltin -o sw.pris.uhdm >/dev/null 2>&1 )
  [ -f $d/sw.pris.uhdm ] || { echo "$a SLANG_REJECT"; continue; }
  $DUMP $d/sw.pris.uhdm | sed -e "s#$d/##g" -e "1s#^sw[.][a-z]*[.]uhdm:#DB:#" > $d/sw.pris.dump 2>&1
  line="$a"
  for sw in NONE R11U92_OFF R11U92_PROGCELL_OFF R11U92_STRPORTORD_OFF R11U92_STRPORTANCH_OFF R11U92_STRPORTTYPE_OFF R11U92_STRPORTLOW_OFF R11U92_STRPORTINIT_OFF R11U90_OFF R11U88_OFF; do
    if [ "$sw" = NONE ]; then
      ( cd $d && $PATCHB dut.sv --single-unit --nobuiltin -o sw.x.uhdm >/dev/null 2>&1 )
    else
      ( cd $d && env $sw=1 $PATCHB dut.sv --single-unit --nobuiltin -o sw.x.uhdm >/dev/null 2>&1 )
    fi
    $DUMP $d/sw.x.uhdm | sed -e "s#$d/##g" -e "1s#^sw[.][a-z]*[.]uhdm:#DB:#" > $d/sw.x.dump 2>&1
    n=$(diff $d/sw.pris.dump $d/sw.x.dump | grep -c '^[<>]'; true)
    line="$line $sw=$n"
  done
  echo "$line"
done
