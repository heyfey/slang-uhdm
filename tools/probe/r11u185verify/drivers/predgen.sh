#!/bin/bash
# predgen.sh <HEAD sweep workdir> <out>: predgen over every corpus row-mode database and every probe database of the
# HEAD (law.bin) sweep, the fenced rows excluded by word boundary (fail-closed without the four names).
set -u; : "${FENCED:?FENCED unset}"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
W=$1; O=$2; re=$(echo $FENCED | sed 's/ /|/g')
( cd $W && find surelog uhdm2rtlil -name slang.uhdm; find probe -name '*.uhdm' ! -name 'golden*' ) | grep -Evw "($re)" | sort > $O.list
echo "listed $(wc -l < $O.list) fenced_excluded $( (cd $W && find surelog uhdm2rtlil -name slang.uhdm) | grep -Ecw "($re)")"
(cd $W && xargs -P3 -n20 /tmp/r11u185_bin/predgen < $O.list) | sort > $O
echo "predicted: $(wc -l < $O) databases ($(date '+%F %T'))"
