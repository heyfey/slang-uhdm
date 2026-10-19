#!/bin/bash
# grid.sh <law binary> <pristine binary> : one line per case dir:
#   case | pristine reading | law reading | R11U410_OFF md5 == pristine md5 | own switch md5 == pristine md5
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2
declare -A SW=( [QM]=R11U410_CLSQMULTI_OFF [QU]=R11U410_QBOUNDUNTYPED_OFF [AQ]=R11U410_BOUNDEDQTD_OFF
  [YA]=R11U410_DYNTDALIAS_OFF [VF]=R11U410_MODVIFTD_OFF [GP]=R11U410_GENLPNOTS_OFF [PC]=R11U410_PARENCASTNAME_OFF
  [SB]=R11U410_STRUCTBITS_OFF [MI]=R11U410_MACROINCCOL_OFF [CB]=R11U410_CLSBASEDLIT_OFF [CU]=R11U410_UNITCLSPROPALIAS_OFF
  [TA]=R11U410_UNITALIASCHAIN_OFF [OT]=R11U410_OOBUNITCLSTD_OFF [PD]=R11U410_CLSDIMREF_OFF )
for c in $(ls -d $R/cases/*/* | sort); do
  g=$(basename $(dirname $c)); n=$(basename $c)
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/offrun.sh $c $L o R11U410_OFF=1
  bash $R/drivers/offrun.sh $c $L s ${SW[$g]}=1
  mp=$(md5sum < $c/out_p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $c/out_o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $c/out_s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $c/out_o/rc); rs=$(cat $c/out_s/rc); rp=$(cat $c/out_p/rc)
  echo "$g/$n | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | ${SW[$g]} $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
