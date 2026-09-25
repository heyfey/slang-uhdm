#!/bin/bash
# changecheck.sh <pristine wd> <law wd> <row...>: for each corpus row (corpus/mode/test) the strict comparator's
# first differing record and whole-walk summary on the pristine and on the law database.
P=$1; L=$2; shift 2
for r in "$@"; do c=${r%%/*}; m=$(echo $r | cut -d/ -f2); t=${r##*/}
  for w in $P $L; do set -- $($(dirname $0)/rowpaths.sh $w $c $m $t)
    out=$(/tmp/r11u147_bin/strictcmp --max 1 $1 $2 2>&1)
    echo "$r $(basename $w) first=$(echo "$out" | grep -m1 -o '^#[0-9]* [a-z]*') $(echo "$out" | grep -o 'objects_differing=.*')"
  done; done
