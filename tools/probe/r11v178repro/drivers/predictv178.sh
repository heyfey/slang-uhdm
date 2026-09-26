#!/bin/bash
# predictv178.sh <law sweep workdir> <out>: predictv178 over every corpus row-mode database and every probe
# database of the r11u178 LAW sweep, fenced rows excluded by word boundary (fail closed without $FENCED).
set -u; : "${FENCED:?FENCED unset}"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
W=$1; O=$2; re=$(echo $FENCED | sed 's/ /|/g')
( cd $W && find surelog uhdm2rtlil -name slang.uhdm; find probe -name '*.uhdm' ! -name 'golden*' ) | sort > $O.all
grep -Evw "($re)" $O.all > $O.list
echo "listed $(wc -l < $O.list) fenced_excluded $(( $(wc -l < $O.all) - $(wc -l < $O.list) ))"
(cd $W && xargs -P3 -n20 /tmp/v11u178_bin/predictv178 < $O.list) | sort > $O
echo "predicted: $(awk '$2!="-"' $O | wc -l) of $(wc -l < $O)"
