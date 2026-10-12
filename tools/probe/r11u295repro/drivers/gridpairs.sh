#!/bin/bash
# (r11u295: copied from r11u293repro/drivers)
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
# r11u287 gridpairs.sh <grid.txt> <out>: for every moving case-view no single switch returns to pristine's bytes
# (gridsum285.py's NONE), the law with each PAIR of this pass's switches off; prints the pairs that give P's md5.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
SW=(R11U287_IFARRINTTS_OFF R11U287_DEFGENSELNAME_OFF R11U287_PVRECVBODYTS_OFF R11U287_GENCASHARE_OFF R11U287_PVFLATTS_OFF R11U287_EVALKEEP_OFF)
: > $2
for cv in $(python3 $D/gridsum285.py $1 | awk '/ by NONE$/{print $1}'); do
  el=0; c=$cv; case $cv in *_el) el=1; c=${cv%_el};; esac
  pm=$(awk -v k="$cv" '$1=="P" && $2==k {for(i=3;i<=NF;i++) if ($i ~ /^md5=/) print substr($i,5)}' $1)
  ok=""
  for ((i=0;i<4;i++)); do for ((j=i+1;j<4;j++)); do
    m=$(EL=$el bash $D/case.sh $D/../cases/$c PAIR $B/law ${SW[i]}=1 ${SW[j]}=1 | sed 's/.*md5=//')
    [ "$m" = "$pm" ] && ok="$ok ${SW[i]}+${SW[j]}"
  done; done
  echo "$cv P=$pm pairs:${ok:- NONE}" >> $2
done
