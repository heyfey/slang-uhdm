#!/bin/bash
# vgrid.sh <verified binary> [casedir...]: needs out_l (law) and out_p (pristine) from grid.sh;
#   case | verified reading | verified vs law bytes | R11V414_OFF == law bytes+rc | R11U414_OFF == pristine bytes+rc
R=$(cd $(dirname $0)/.. && pwd); V=$1; shift
cases="$@"; [ -z "$cases" ] && cases=$(ls -d $R/cases/*/* | sort)
for c in $cases; do
  g=$(basename $(dirname $c)); n=$(basename $c)
  v=$(bash $R/drivers/run1.sh $c $V v | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $V vo R11V414_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $V vu R11U414_OFF=1 >/dev/null
  m(){ md5sum < $c/out_$1/ours.uhdm 2>/dev/null | cut -c1-8; cat $c/out_$1/rc; }
  echo "$g/$n | verified $v | $([ "$(m v)" = "$(m l)" ] && echo law-bytes || echo MOVED) | R11V414_OFF $([ "$(m vo)" = "$(m l)" ] && echo same || echo DIFF) | R11U414_OFF $([ "$(m vu)" = "$(m p)" ] && echo same || echo DIFF)"
done
