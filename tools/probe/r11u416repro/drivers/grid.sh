#!/bin/bash
# grid.sh <law binary> <pristine binary>: one line per case dir:
#   case | pristine reading | law reading | R11U416_OFF == pristine | own switch == pristine
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2
declare -A SW=( [PB]=R11U416_PASTEBLANKSTART_OFF [UO]=R11U416_UNITTFORDER_OFF [DC]=R11U416_DEFGENCONNSEL_OFF
  [LD]=R11U416_LINEDIRECTIVE_OFF [GC]=R11U416_GENCASEPROC_OFF )
O=/tmp/r11u416_scr/out
for c in $(ls -d $R/cases/*/* | sort); do
  g=$(basename $(dirname $c)); n=$(basename $c); sw=${SW[$g]}; key=${g}_$n
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U416_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s $sw=1 >/dev/null
  mp=$(md5sum < $O/$key/p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $O/$key/o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $O/$key/s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  echo "$g/$n | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
