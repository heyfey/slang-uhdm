#!/bin/bash
# gridscore.sh <case dir>...  -> per case: uhdm-cmp lines and strict verdict + per-field counts, pristine vs law
source /tmp/r11u130_env.sh
D=$(dirname $0)
for d in "$@"; do
  a=$(bash $D/case.sh $d /tmp/r11u130_bin/pris.bin P | sed 's/ *\[.*//'); b=$(bash $D/case.sh $d /tmp/r11u130_bin/law.bin L | sed 's/ *\[.*//')
  w=/tmp/r11u130_cases/$(realpath $d | md5sum | cut -c1-12)
  fa=$($STRICT_CMP --max 0 $w/golden.uhdm $w/P.uhdm 2>/dev/null | grep '^fields' | sed 's/fields: //')
  fb=$($STRICT_CMP --max 0 $w/golden.uhdm $w/L.uhdm 2>/dev/null | grep '^fields' | sed 's/fields: //')
  echo "$(basename $(dirname $(realpath $d)))/$(basename $d) | P: ${a#* } {$fa} | L: ${b#* } {$fb}"
done
