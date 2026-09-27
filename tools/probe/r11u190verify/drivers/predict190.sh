#!/bin/bash
# predict190.sh <HEAD sweep workdir> <out>: predict190 over every corpus row-mode database and every probe database of
# the HEAD (law.bin) sweep, the fenced rows excluded by word boundary (fail-closed without the four names).
source /tmp/wt_r11u190/tools/probe/r11u190verify/drivers/env.sh || exit 3
set -u; : "${FENCED:?FENCED unset}"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
W=$1; O=$2; re=$(echo $FENCED | sed 's/ /|/g')
( cd $W && find surelog uhdm2rtlil -name slang.uhdm; find probe -name '*.uhdm' ! -name 'golden*' ) | grep -Evw "($re)" | sort > $O.list
echo "listed $(wc -l < $O.list) fenced_excluded $( (cd $W && find surelog uhdm2rtlil -name slang.uhdm) | grep -Ecw "($re)")"
(cd $W && xargs -P3 -n20 /tmp/r11u190_bin/predict190 < $O.list) | sort > $O
echo "predicted: $(awk '$2!="-"' $O | wc -l) of $(wc -l < $O) ($(date '+%F %T'))"
