#!/bin/bash
# grid.sh <dir of cases> <binP> <binL>  -> per case: P verdict | L verdict
d=$1; P=$2; L=$3
ls -d $d/*/ | xargs -P 3 -I{} bash -c '/tmp/r11u134_scr/case.sh {} '$P' P >/dev/null; /tmp/r11u134_scr/case.sh {} '$L' L > /dev/null' 
for c in $(ls -d $d/*/); do
  w=/tmp/r11u134_cases/$(echo "$(realpath $c)" | md5sum | cut -c1-12)
  source /tmp/r11u134_env.sh
  vp=$($STRICT_CMP --max 0 $w/golden.uhdm $w/P.uhdm 2>&1| tail -1); cp_=$($UHDM_CMP $w/golden.uhdm $w/P.uhdm 2>&1 | wc -l)
  vl=$($STRICT_CMP --max 0 $w/golden.uhdm $w/L.uhdm 2>&1| tail -1); cl=$($UHDM_CMP $w/golden.uhdm $w/L.uhdm 2>&1 | wc -l)
  fp=$($STRICT_CMP --max 0 $w/golden.uhdm $w/P.uhdm 2>&1| grep '^fields' ); fl=$($STRICT_CMP --max 0 $w/golden.uhdm $w/L.uhdm 2>&1| grep '^fields')
  same=$(cmp -s $w/P.uhdm $w/L.uhdm && echo same || echo moved)
  printf "%s\tP[cmp=%s %s %s]\tL[cmp=%s %s %s]\t%s\n" $(basename $c) $cp_ "$vp" "$fp" $cl "$vl" "$fl" $same
done
