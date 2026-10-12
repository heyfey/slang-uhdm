#!/bin/bash
# (r11u305: rewritten from r11u287repro/drivers/gridpairs.sh)
# r11u305 gridpairs.sh <grid.txt> <out>: for every moving case-view no single switch returns to pristine's bytes
# (gridsum305.py's `restored by: -`), the law with each PAIR of this pass's switches off; prints the pairs that give
# P's md5 (and, when no pair does, the triples).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
SW=(R11U305_UDPMPPATH_OFF R11U305_IFUNSIZED_OFF R11U305_IFSPLITFILL_OFF R11U305_WIRESCOPEDEND_OFF R11U305_PVHDRPORTDECL_OFF R11U305_PVBODYFIRSTNDA_OFF R11U305_PVPORTLOC_OFF R11U305_IFPLAINLHS_OFF R11U305_SCOPEDTDMEM_OFF)
N=${#SW[@]}
: > $2
for cv in $(python3 $D/gridsum305.py $1 | awk '/MOVES/ && /restored by: -$/{print $1}'); do
  el=0; c=$cv; case $cv in *_el) el=1; c=${cv%_el};; esac
  pm=$(awk -v k="$cv" '$1=="P" && $2==k {for(i=3;i<=NF;i++) if ($i ~ /^md5=/) print substr($i,5)}' $1)
  ok=""
  for ((i=0;i<N;i++)); do for ((j=i+1;j<N;j++)); do
    m=$(EL=$el bash $D/case.sh $D/../cases/$c PAIR $B/law ${SW[i]}=1 ${SW[j]}=1 | sed 's/.*md5=//')
    [ "$m" = "$pm" ] && ok="$ok ${SW[i]#R11U305_}+${SW[j]#R11U305_}"
  done; done
  if [ -z "$ok" ]; then
    for ((i=0;i<N;i++)); do for ((j=i+1;j<N;j++)); do for ((k=j+1;k<N;k++)); do
      m=$(EL=$el bash $D/case.sh $D/../cases/$c TRIPLE $B/law ${SW[i]}=1 ${SW[j]}=1 ${SW[k]}=1 | sed 's/.*md5=//')
      [ "$m" = "$pm" ] && ok="$ok ${SW[i]#R11U305_}+${SW[j]#R11U305_}+${SW[k]#R11U305_}"
    done; done; done
  fi
  echo "$cv P=$pm pairs:${ok:- NONE}" >> $2
done
