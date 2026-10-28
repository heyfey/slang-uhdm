#!/bin/bash
# switches.sh <law binary>: per case dir, the md5 under pristine, the law, R11U451_OFF and each law's own switch
D=$(cd $(dirname $0)/.. && pwd); B=$1
P=/tmp/r11u451_bin/pristine
SW="R11U451_DIAMONDVARS_OFF R11U451_DIAMONDPA_OFF R11U451_LEFTNET_OFF R11U451_NESTREAD_OFF R11U451_TASKVAL_OFF"
m(){ echo "$1" | sed 's/.*md5=//'; }
for c in $(cd $D && ls -d cases/*/* | sort); do
  k=$(echo $c | sed 's|cases/||')
  p=$(bash $D/drivers/run1.sh $D/$c $P pris); l=$(bash $D/drivers/run1.sh $D/$c $B law)
  o=$(bash $D/drivers/run1.sh $D/$c $B off R11U451_OFF=1)
  line="$k pris=$(m "$p") law=$(m "$l") off=$( [ "$(m "$o")" = "$(m "$p")" ] && echo P || echo X)"
  for s in $SW; do r=$(bash $D/drivers/run1.sh $D/$c $B sw $s=1); x=$(m "$r"); t=${s#R11U451_}; t=${t%_OFF}
    if [ "$x" = "$(m "$l")" ]; then v=L; elif [ "$x" = "$(m "$p")" ]; then v=P; else v=M; fi; line="$line $t=$v"; done
  echo "$line"
done
