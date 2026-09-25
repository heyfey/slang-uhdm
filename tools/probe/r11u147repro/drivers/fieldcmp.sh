#!/bin/bash
# fieldcmp.sh <pristine wd> <law wd> <rows file: corpus/mode/test-hash per line>: per row, the strict
# comparator's whole-walk field tally (golden vs pristine, golden vs law) — every differing object counted.
P=$1; L=$2
while read -r r; do
  c=${r%%/*}; rest=${r#*/}; m=${rest%%/*}; t=${rest#*/}; t=${t%-*}
  gp=$($(dirname $0)/rowpaths.sh $P $c $m $t); gl=$($(dirname $0)/rowpaths.sh $L $c $m $t)
  fp=$(timeout 1800 /tmp/r11u147_bin/strictcmp --max 1 $gp 2>&1 | grep -o 'fields:.*' )
  fl=$(timeout 1800 /tmp/r11u147_bin/strictcmp --max 1 $gl 2>&1 | grep -o 'fields:.*' )
  echo "$c/$m/$t | pristine $fp | law $fl"
done < $3
