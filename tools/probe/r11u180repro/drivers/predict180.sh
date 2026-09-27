#!/bin/bash
# predict180.sh <pristine sweep workdir> <out.txt>: run predict180 on every corpus row-mode database and
# every probe database of the PRISTINE sweep, excluding the slang-fenced rows by word boundary (fail closed).
set -u; . /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
[ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
W=$1; O=$2; re=$(echo $FENCED | sed 's/ /|/g')
( cd $W && find surelog uhdm2rtlil -name slang.uhdm; find probe -name '*.uhdm' ) | grep -Evw "($re)" | sort > $O.list
echo "listed $(wc -l < $O.list) fenced_excluded $( (cd $W && find surelog uhdm2rtlil -name slang.uhdm) | grep -Ecw "($re)")"
(cd $W && xargs -P3 -n20 /tmp/r11u180_bin/predict180 < $O.list) | sort > $O
echo "predicted: $(awk '$2!="-"' $O | wc -l) of $(wc -l < $O)"
