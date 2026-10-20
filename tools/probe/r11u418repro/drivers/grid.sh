#!/bin/bash
# grid.sh <law binary> <pristine binary>: one line per case dir:
#   case | pristine reading | law reading | R11U418_OFF == pristine | own switch == pristine
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2
declare -A SW=( [KN]=R11U418_KEPTTDNAMES_OFF [PS]=R11U418_PSBOUNDREF_OFF [GG]=R11U418_GENGATENET_OFF
  [UG]=R11U418_UNNAMEDGATETERM_OFF [CT]=R11U418_CLSTPUNITTD_OFF [BS]=R11U418_TDMOVEBITSEL_OFF
  [IF]=R11U418_IFCFILEIMP_OFF [TN]=R11U418_THISFIRSTMOD_OFF [HN]=R11U418_HOISTFIRSTMOD_OFF
  [MP]=R11U418_MPIMPLNETTYPE_OFF [UV]=R11U418_UNITVARNET_OFF )
O=/tmp/r11u418_scr/out
for c in $(find $R/cases -mindepth 2 -maxdepth 2 -type d | sort); do
  g=$(basename $(dirname $c)); n=$(basename $c); sw=${SW[$g]}; key=${g}_$n
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U418_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s $sw=1 >/dev/null
  mp=$(md5sum < $O/$key/p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $O/$key/o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $O/$key/s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  echo "$g/$n | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
