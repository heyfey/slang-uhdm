#!/bin/bash
# r11u307 gridpairs307.sh <grid.txt> <out>: for every moving case-view no single switch returns to pristine's bytes,
# the law with each PAIR of this pass's switches off; prints the pairs giving P's md5 (no pair: the triples).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
SW=(R11U307_NESTREPDEF_OFF R11U307_DEEPSTUB_OFF R11U307_POSUDP_OFF R11U307_DEFGENUDP_OFF R11U307_DEFGENORD_OFF R11U307_GENMODARR_OFF)
N=${#SW[@]}
: > $2
for cv in $(python3 $D/gridsum307.py $1 | awk '/^not single-switch:/{print $3}'); do
  el=0; c=$cv; case $cv in *_el) el=1; c=${cv%_el};; esac
  pm=$(awk -v k="$cv" '$1=="P" && $2==k {for(i=3;i<=NF;i++) if ($i ~ /^md5=/) print substr($i,5)}' $1)
  ok=""
  for ((i=0;i<N;i++)); do for ((j=i+1;j<N;j++)); do
    m=$(EL=$el bash $D/case.sh $D/../cases/$c PAIR $B/law ${SW[i]}=1 ${SW[j]}=1 | sed 's/.*md5=//')
    [ "$m" = "$pm" ] && ok="$ok ${SW[i]#R11U307_}+${SW[j]#R11U307_}"
  done; done
  if [ -z "$ok" ]; then
    for ((i=0;i<N;i++)); do for ((j=i+1;j<N;j++)); do for ((k=j+1;k<N;k++)); do
      m=$(EL=$el bash $D/case.sh $D/../cases/$c TRIPLE $B/law ${SW[i]}=1 ${SW[j]}=1 ${SW[k]}=1 | sed 's/.*md5=//')
      [ "$m" = "$pm" ] && ok="$ok ${SW[i]#R11U307_}+${SW[j]#R11U307_}+${SW[k]#R11U307_}"
    done; done; done
  fi
  echo "$cv restored by:${ok:- none}" >> $2
done
