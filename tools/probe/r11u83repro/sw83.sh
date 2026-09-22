#!/usr/bin/env bash
# r11u83 SWITCH LEDGER.  usage: GRID=<dir> sw83.sh <pristine-bin> <patched-bin>
# For every arm, dumps the patched binary under each switch setting and counts
# the lines differing from the PRISTINE binary's own dump of the same arm.
# `R11U83_OFF=1` must read 0 on every arm; each single switch must return
# exactly its own law's arms to 0 and leave the others at the patched reading.
set -u
PRIS=${1:?pristine}; PATCHB=${2:?patched}
GRID=${GRID:?set GRID}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${*:3}; ARMS=${ARMS:-$(ls -d $GRID/*/ | xargs -n1 basename | sort -V)}
for a in $ARMS; do
  d=$GRID/$a; [ -f "$d/dut.sv" ] || continue
  ( cd $d && $PRIS dut.sv --single-unit --nobuiltin -o sw.pris.uhdm >/dev/null 2>&1 )
  $DUMP $d/sw.pris.uhdm | sed -e "s#$d/##g" -e "1s#^sw[.][a-z]*[.]uhdm:#DB:#" > $d/sw.pris.dump 2>&1
  line="$a"
  for sw in NONE R11U83_OFF R11U83_IFHOIST_OFF R11U83_IFCAFOLD_OFF; do
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
