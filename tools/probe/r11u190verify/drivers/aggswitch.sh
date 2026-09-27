#!/bin/bash
# aggswitch.sh <out>: § tfArgAggSwitchSplit180's switch matrix on the pass-176 coupling cases (v11u176repro CM,
# r11u176repro PQ) and this directory's aggregate cases (G, W), both views: law.bin under each of the three pass-176
# switches the admission reads (R11U176_QUALFORMAL_OFF, R11U176_CLSMETHOD_OFF, R11U176_DEFTOPSPLIT_OFF) and none, each
# with and without R11U180_AGGSWITCH_OFF.  Prints per case-mode and switch: SAME when AGGSWITCH_OFF writes the same
# bytes, else both strict verdicts.  Cases only; fail-closed on $FENCED through case.sh.
source /tmp/wt_r11u190/tools/probe/r11u190verify/drivers/env.sh || exit 2
cd /tmp/wt_r11u190/tools/probe
L=$(ls -d ../../tools/probe/v11u176repro/cases/CM/* ../../tools/probe/r11u176repro/cases/PQ/* r11u190verify/cases/G/* r11u190verify/cases/W/* 2>/dev/null)
for c in $L; do for el in 0 1; do for sw in NONE R11U176_QUALFORMAL_OFF R11U176_CLSMETHOD_OFF R11U176_DEFTOPSPLIT_OFF; do
  e=(); [ $sw != NONE ] && e=($sw=1)
  a=$(EL=$el bash r11u190verify/drivers/case.sh $c agg_$sw $LAW "${e[@]}")
  b=$(EL=$el bash r11u190verify/drivers/case.sh $c aggX_$sw $LAW "${e[@]}" R11U180_AGGSWITCH_OFF=1)
  ma=$(echo "$a" | grep -o 'md5=[0-9a-f]*'); mb=$(echo "$b" | grep -o 'md5=[0-9a-f]*')
  sa=$(echo "$a" | grep -o 'strict=[^ ]*'); sb=$(echo "$b" | grep -o 'strict=[^ ]*')
  echo "$(echo "$a" | cut -d' ' -f1) $sw $([ "$ma" = "$mb" ] && echo SAME || echo "DIFF split:$sa coupled:$sb")"
done; done; done > $1
echo "cells=$(wc -l < $1) differ=$(grep -c DIFF $1)"
