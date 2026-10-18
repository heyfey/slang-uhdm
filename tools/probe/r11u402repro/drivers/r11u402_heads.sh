#!/bin/bash
# usage: heads.sh <csv> <workroot> : first LHS object of uhdm-cmp per DIFFERENT row
. /tmp/r11u402_env.sh
python3 -c "
import csv,sys
for x in csv.DictReader(open('$1')):
    if x['agreement']=='DIFFERENT': print(x['path'])" | while read p; do
  d=$2/${p%.sv}; g=$(/tmp/r11u402_pair.sh $d)
  h=$(timeout 300 $UHDM_CMP $g $d/slang.uhdm 2>&1 | sed -n 3p | sed -E 's/, id:[0-9]+//; s/file:[^,]*, //')
  echo "$p|$h"
done
