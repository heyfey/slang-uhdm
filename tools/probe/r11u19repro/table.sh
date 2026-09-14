#!/usr/bin/env bash
# r11u19 GRID TABLE: per arm, BOTH rcs, the OFFICIAL uhdm-cmp verdict and the
# CA-SHAPE census (shape.py) for the pristine and the law binary.
# NOTE the shape census prints [DIFF] for a cell whose ONLY difference is
# golden's `vpiParent` (the ternary clone) — no generated Compare reads
# VpiParent, so read CMP_* as the verdict and the census as the cell list.
set -u
GRID=${GRID:-/tmp/r11u19_grid}
SH=${SH:-$(dirname "${BASH_SOURCE[0]}")/shape.py}
printf "%-38s %-9s %-18s %-18s %-9s %-9s\n" ARM GOLDEN_RC CMP_PRIS CMP_LAW CEN_PRIS CEN_LAW
for a in $(ls -d $GRID/[a-z][0-9]* | xargs -n1 basename | sort -V); do
  g=$(awk -F= '/golden_rc/{print $2}' $GRID/$a/rc.pris.txt 2>/dev/null | head -1)
  cp=NODB; cl=NODB; xp=NODB; xl=NODB
  for t in pris law; do
    v="$(grep "^$a " $GRID/GRID.$t.txt 2>/dev/null | tail -1)"
    r=$(echo "$v" | grep -o 'cmp_rc=[^ ]*'); n=$(echo "$v" | grep -o 'cmplines=[^ ]*')
    o=$(echo "$v" | grep -o 'ours_rc=[^ ]*')
    [ $t = pris ] && cp="$o/$r/$n" || cl="$o/$r/$n"
  done
  [ -f $GRID/$a/gold.pris.dump ] && [ -f $GRID/$a/ours.pris.dump ] && xp=$(python3 $SH $GRID/$a/gold.pris.dump $GRID/$a/ours.pris.dump | tail -1 | sed 's/DIFFERING CA SHAPES: //; s/ of /\//')
  [ -f $GRID/$a/gold.law.dump ] && [ -f $GRID/$a/ours.law.dump ] && xl=$(python3 $SH $GRID/$a/gold.law.dump $GRID/$a/ours.law.dump | tail -1 | sed 's/DIFFERING CA SHAPES: //; s/ of /\//')
  printf "%-38s %-9s %-18s %-18s %-9s %-9s\n" "$a" "$g" "$cp" "$cl" "$xp" "$xl"
done
