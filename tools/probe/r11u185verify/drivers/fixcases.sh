#!/bin/bash
# fixcases.sh <out> [dir...]: every case (both modes) exported by fix.bin (tag fix) and, under R11V185_OFF=1 (tag fixoff),
# compared byte for byte with law.bin's on.uhdm; prints MOVER / SAME per case-mode and the fixoff identity.  Cases
# only (this directory's cases/ or the given case dirs); fail-closed on $FENCED through case.sh.
source /tmp/wt_r11u185/tools/probe/r11u185verify/drivers/env.sh || exit 2
cd /tmp/wt_r11u185/tools/probe/r11u185verify
L=${@:2}; [ -z "$L" ] && L=$(find cases -mindepth 2 -maxdepth 2 -type d | sort)
for c in $L; do for el in 0 1; do
  a=$(EL=$el bash drivers/case.sh $c fix $FIX); b=$(EL=$el bash drivers/case.sh $c fixoff $FIX R11V185_OFF=1)
  o=$(EL=$el bash drivers/case.sh $c on $LAW)
  m() { echo "$1" | grep -o 'md5=[0-9a-f]*'; }
  echo "${c#cases/}$([ $el = 1 ] && echo _el) $( [ "$(m "$a")" = "$(m "$o")" ] && echo SAME || echo MOVER) fixoff==law:$( [ "$(m "$b")" = "$(m "$o")" ] && echo YES || echo NO) | on: ${o#* on } | fix: ${a#* fix }"
done; done > $1
echo "movers=$(grep -c ' MOVER ' $1) same=$(grep -c ' SAME ' $1) fixoff_law_identical=$(grep -c 'fixoff==law:YES' $1)"
