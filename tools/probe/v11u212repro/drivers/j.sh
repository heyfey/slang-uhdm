#!/bin/bash
# j.sh <casedir...>: both views, pristine vs law vs law+OFF
. $(dirname "$0")/env.sh || exit 3
for c in "$@"; do for el in 0 1; do
 p=$(EL=$el bash $(dirname "$0")/case.sh $c pristine.bin $B/pristine.bin)
 l=$(EL=$el bash $(dirname "$0")/case.sh $c law.bin $B/law.bin)
 o=$(EL=$el bash $(dirname "$0")/case.sh $c off $B/law.bin R11U212_OFF=1)
 pm=$(echo "$p"|grep -o 'md5=[0-9a-f]*'); om=$(echo "$o"|grep -o 'md5=[0-9a-f]*'); lm=$(echo "$l"|grep -o 'md5=[0-9a-f]*')
 v() { echo "$1" | awk '{for(i=1;i<=NF;i++){if($i~/^cmp=/)c=$i; if($i~/^strict=/)s=substr($i,8); if($i~/^rc=/)r=$i} if($3~/FAIL/)s=$3; print c"/"s"/"r}'; }
 echo "$(echo $p|awk '{print $1}')	P:$(v "$p")	L:$(v "$l")	$([ "$pm" = "$lm" ] && echo SAME || echo MOVED)	$([ "$pm" = "$om" ] && echo OFF=pris || echo OFF=DIFF)"
done; done
