#!/bin/bash
# grid.sh <law binary> <pristine binary> : one line per case dir:
#   case | pristine reading | law reading | R11U414_OFF == pristine | own switch == pristine
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2
declare -A SW=( [VM]=R11U414_VARINITMASK_OFF [CA]=R11U414_CLASSARRELEM_OFF [CH]=R11U414_CHANDLEPROP_OFF
  [WC]=R11U414_CLSWILDCARDIDX_OFF [FT]=R11U414_FWDTDTWIN_OFF [TA]=R11U414_ARGALIASTWIN_OFF
  [IT]=R11U414_IFCLSARG_OFF [RT]=R11U414_REALTIME_OFF [SD]=R11U414_MEMBERDEFAULT_OFF
  [AI]=R11U414_ARRSTRINIT_OFF [CI]=R11U414_CLSPROPBINOP_OFF [RM]=R11U414_RANDMEMBER_OFF )
for c in $(ls -d $R/cases/*/* | sort); do
  g=$(basename $(dirname $c)); n=$(basename $c); sw=${SW[$g]}
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/offrun.sh $c $L o 0 R11U414_OFF=1
  bash $R/drivers/offrun.sh $c $L s 0 $sw=1
  mp=$(md5sum < $c/out_p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $c/out_o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $c/out_s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $c/out_o/rc); rs=$(cat $c/out_s/rc); rp=$(cat $c/out_p/rc)
  echo "$g/$n | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
