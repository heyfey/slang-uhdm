#!/bin/bash
# grid.sh <law binary> <pristine binary> [casedir...]: one line per case dir:
#   case | pristine reading | law reading | R11U414_OFF == pristine bytes+rc | own switch == pristine bytes+rc
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2; shift 2
declare -A SW=( [VV]=R11U414_VARINITMASK_OFF [VC]=R11U414_CLASSARRELEM_OFF [VH]=R11U414_CHANDLEPROP_OFF
  [VW]=R11U414_CLSWILDCARDIDX_OFF [VF]=R11U414_FWDTDTWIN_OFF [VA]=R11U414_ARGALIASTWIN_OFF
  [VI]=R11U414_IFCLSARG_OFF [VR]=R11U414_REALTIME_OFF [VS]=R11U414_MEMBERDEFAULT_OFF
  [VB]=R11U414_ARRSTRINIT_OFF [VP]=R11U414_CLSPROPBINOP_OFF [VQ]=R11U414_RANDMEMBER_OFF )
cases="$@"; [ -z "$cases" ] && cases=$(ls -d $R/cases/*/* | sort)
for c in $cases; do
  g=$(basename $(dirname $c)); n=$(basename $c); sw=${SW[$g]}
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U414_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s $sw=1 >/dev/null
  mp=$(md5sum < $c/out_p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $c/out_o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $c/out_s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $c/out_o/rc); rs=$(cat $c/out_s/rc); rp=$(cat $c/out_p/rc)
  echo "$g/$n | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
