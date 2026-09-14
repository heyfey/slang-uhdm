#!/usr/bin/env bash
# r11u25 — the GOLDEN side of the grid only (no dependency on our build).
set -u
GRID=${GRID:-/tmp/r11u25_grid}
SL=${SL:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${*:-$(ls -d $GRID/[a-z][0-9]* | xargs -n1 basename | sort -V)}
for a in $ARMS; do
  d=$GRID/$a
  ( cd $d && rm -rf slpp_all && $SL -parse -nobuiltin -nocache -sv dut.sv > sl.g.log 2>&1; echo "golden_rc=$?" > rc.g.txt )
  if [ -f $d/slpp_all/surelog.uhdm ]; then $DUMP $d/slpp_all/surelog.uhdm > $d/gold.dump 2>&1; fi
  echo "$a $(cat $d/rc.g.txt) gold=$([ -f $d/slpp_all/surelog.uhdm ] && echo yes || echo NO)"
done
