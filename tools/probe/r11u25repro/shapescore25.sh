#!/usr/bin/env bash
# r11u25 — the per-CELL verdict beside the uhdm-cmp rc: an arm AGREEING at rc 0
# is not an arm TESTING the law, so every arm is also scored on the SHAPE
# LISTER's cont_assign cells (golden vs pristine vs law).
set -u
GRID=${GRID:-/tmp/r11u25_grid}
C=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/carhs25.py
conv=0; reg=0; still=0; same=0
for a in $(ls -d $GRID/[a-z][0-9]* | xargs -n1 basename | sort -V); do
  d=$GRID/$a
  python3 $C $d/gold.dump      | sort > $d/.g.cells
  python3 $C $d/ours.pris.dump | sort > $d/.p.cells
  python3 $C $d/ours.law.dump  | sort > $d/.l.cells
  dp=$(diff -q $d/.g.cells $d/.p.cells >/dev/null && echo 0 || echo 1)
  dl=$(diff -q $d/.g.cells $d/.l.cells >/dev/null && echo 0 || echo 1)
  dpl=$(diff -q $d/.p.cells $d/.l.cells >/dev/null && echo 0 || echo 1)
  if   [ $dp = 1 ] && [ $dl = 0 ]; then v=CELL-CONVERT;  conv=$((conv+1))
  elif [ $dp = 0 ] && [ $dl = 1 ]; then v=CELL-REGRESS;  reg=$((reg+1))
  elif [ $dpl = 1 ];               then v=MOVED-STILL-DIFF; still=$((still+1))
  else v=CELL-SAME; same=$((same+1)); fi
  echo "$a $v"
done
echo "## CELL-CONVERT=$conv CELL-REGRESS=$reg MOVED-STILL-DIFF=$still CELL-SAME=$same"
