#!/bin/bash
# v11u285 pairs.sh <grid.txt>: for every moving case-view no single switch returns to pristine's bytes, the law
# with each PAIR of the R11U285 switches off; prints the pairs that give pristine's md5. Needs B, S; fail-closed.
D=$(cd "$(dirname "$0")" && pwd); R=$(cd "$D/../../r11u285repro/drivers" && pwd)
. "$R/env.sh" || exit 2
SW=(R11U285_CLSIMPTDSHARE_OFF R11U285_IMPHPNAME_OFF R11U285_CLONEMEMBNAME_OFF R11U285_CLONEMEMBTYPE_OFF)
for cv in $(python3 $D/gsum.py $1 | awk '/back:NONE/{print $1}'); do
  el=0; c=$cv; case $cv in *_el) el=1; c=${cv%_el};; esac
  pm=$(awk -v k="$cv" '$1=="P" && $2==k {for(i=3;i<=NF;i++) if ($i ~ /^md5=/) print substr($i,5)}' $1)
  ok=""
  for ((i=0;i<4;i++)); do for ((j=i+1;j<4;j++)); do
    m=$(EL=$el bash $R/case.sh $D/../cases/$c PAIR $B/law ${SW[i]}=1 ${SW[j]}=1 | sed 's/.*md5=//')
    [ "$m" = "$pm" ] && ok="$ok ${SW[i]#R11U285_}+${SW[j]#R11U285_}"
  done; done
  echo "$cv:${ok:- NO_PAIR}"
done
