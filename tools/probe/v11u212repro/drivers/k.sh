#!/bin/bash
# k.sh <casedir...>: both views: law vs fix1 vs fix1+R11V212_OFF(==law bytes?)
. $(dirname "$0")/env.sh || exit 3
v() { echo "$1" | awk '{for(i=1;i<=NF;i++){if($i~/^cmp=/)c=$i; if($i~/^strict=/)s=substr($i,8); if($i~/^rc=/)r=$i} if($3~/FAIL/)s=$3; print c"/"s"/"r}'; }
for c in "$@"; do for el in 0 1; do
 l=$(EL=$el bash $(dirname "$0")/case.sh $c law.bin $B/law.bin)
 f=$(EL=$el bash $(dirname "$0")/case.sh $c ${FIXB:-fix1}.bin $B/${FIXB:-fix1}.bin)
 o=$(EL=$el bash $(dirname "$0")/case.sh $c fixoff $B/${FIXB:-fix1}.bin R11V212_OFF=1)
 a=$(EL=$el bash $(dirname "$0")/case.sh $c fixalloff $B/${FIXB:-fix1}.bin R11V212_OFF=1 R11U212_OFF=1)
 p=$(EL=$el bash $(dirname "$0")/case.sh $c pristine.bin $B/pristine.bin)
 m() { echo "$1"|grep -o 'md5=[0-9a-f]*'; }
 echo "$(echo $l|awk '{print $1}')	P:$(v "$p")	L:$(v "$l")	F:$(v "$f")	$([ "$(m "$l")" = "$(m "$f")" ] && echo F=L || echo F!=L)	$([ "$(m "$l")" = "$(m "$o")" ] && echo VOFF=law || echo VOFF=DIFF)	$([ "$(m "$p")" = "$(m "$a")" ] && echo ALLOFF=pris || echo ALLOFF=DIFF)"
done; done
