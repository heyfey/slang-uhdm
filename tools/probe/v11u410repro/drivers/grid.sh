#!/bin/bash
# grid.sh <law binary> <pristine binary> <verified binary>: one line per case dir:
#   case | pristine | law | verified | R11U410_OFF(law) == pristine | own switch(law) == pristine | R11V410_OFF(verified) == law
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2; V=$3
declare -A SW=( [VQ]=R11U410_CLSQMULTI_OFF [VU]=R11U410_BOUNDEDQTD_OFF
  [VY]=R11U410_DYNTDALIAS_OFF [VV]=R11U410_MODVIFTD_OFF [VG]=R11U410_GENLPNOTS_OFF [VP]=R11U410_PARENCASTNAME_OFF
  [VS]=R11U410_STRUCTBITS_OFF [VM]=R11U410_MACROINCCOL_OFF [VB]=R11U410_CLSBASEDLIT_OFF [VC]=R11U410_UNITCLSPROPALIAS_OFF
  [VA]=R11U410_UNITALIASCHAIN_OFF [VO]=R11U410_OOBUNITCLSTD_OFF [VD]=R11U410_CLSDIMREF_OFF )
m5(){ md5sum < $1/ours.uhdm 2>/dev/null | cut -c1-8; }
for c in $(ls -d $R/cases/*/* | sort); do
  g=$(basename $(dirname $c)); n=$(basename $c)
  bash $R/drivers/gold.sh $c
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  v=$(bash $R/drivers/run1.sh $c $V v | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U410_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s ${SW[$g]}=1 >/dev/null
  bash $R/drivers/run1.sh $c $V vo R11V410_OFF=1 >/dev/null
  same(){ [ "$(m5 $c/out_$1)" = "$(m5 $c/out_$2)" ] && [ "$(cat $c/out_$1/rc)" = "$(cat $c/out_$2/rc)" ] && echo same || echo DIFF; }
  echo "$g/$n | pristine $p | law $l | verified $v | R11U410_OFF $(same o p) | ${SW[$g]} $(same s p) | R11V410_OFF $(same vo l)"
done
