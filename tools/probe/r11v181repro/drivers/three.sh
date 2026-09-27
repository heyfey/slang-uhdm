#!/bin/bash
# three.sh <bin> <tag> <casedirs...>: run tag on both views, print strict + record movement P->tag and L->tag
b=$1; t=$2; shift 2
source $(dirname "${BASH_SOURCE[0]}")/env.sh
for c in "$@"; do for v in "" 1; do
  r=$(ELAB=$v /tmp/v11u181_grid.sh $c $b $t R11U181_TRACE=1)
  rel=$(echo "$r" | cut -d' ' -f1); w=/tmp/v11u181_g/$rel
  $STRICT_CMP --max 100000 $w/gold/golden.uhdm $w/$t.uhdm > $w/$t.full 2>&1
  [ -f $w/P.full ] || $STRICT_CMP --max 100000 $w/gold/golden.uhdm $w/P.uhdm > $w/P.full 2>&1
  [ -f $w/L.full ] || $STRICT_CMP --max 100000 $w/gold/golden.uhdm $w/L.uhdm > $w/L.full 2>&1
  same=$(cmp -s $w/P.dump $w/$t.dump && echo "=P" || (cmp -s $w/L.dump $w/$t.dump && echo "=L" || echo "new"))
  tr=$(grep -h 'R11U181 law V181' $w/$t.log 2>/dev/null | sed 's/R11U181 law //' | sort | uniq -c | awk '{printf "%s_%s:%s,",$2,$3,$1}')
  echo "$rel | $(echo "$r" | grep -o 'cmplines=[0-9]* strict=[^ ]*') | $same | P->$t $(python3 /tmp/v11u181_recmv.py $w/P.full $w/$t.full | head -1) | L->$t $(python3 /tmp/v11u181_recmv.py $w/L.full $w/$t.full | head -1) | $tr"
done; done
