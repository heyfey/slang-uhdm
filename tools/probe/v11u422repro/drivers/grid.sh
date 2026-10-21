#!/bin/bash
# grid.sh <law binary> <pristine binary> <casedir>...: one line per case dir:
#   case | law | pristine reading | law reading | R11U422_OFF == pristine | the case's own switch == pristine
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2; shift 2
declare -A SW=( [arrayElemConcatConnWhole422]=R11U422_ELEMCONCAT_OFF [arrayBcastConcatBound422]=R11U422_BCASTBIND_OFF
  [arrayBcastConcatOneBit422]=R11U422_BCASTONEBIT_OFF [arrayElemReplCountFold422]=R11U422_REPLCOUNT_OFF
  [unnamedUdpInstName422]=R11U422_UNNAMEDUDP_OFF [specifyRefNoDefNet422]=R11U422_SPECIFYNET_OFF
  [strNetRefMintsNet422]=R11U422_STRNETMINT_OFF [derivedClassFullNameOrder422]=R11U422_DERIVEDORDER_OFF
  [unitChandleTd422]=R11U422_UNITCHANDLETD_OFF [classChandleTdPropBareLogicVar422]=R11U422_CHANDLETDPROP_OFF )
O=/tmp/v11u422_scr/out
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); g=$(basename $(dirname $c)); n=$(basename $c); key=${g}_$n
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=${SW[$law]}
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U422_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s $sw=1 >/dev/null
  mp=$(md5sum < $O/$key/p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $O/$key/o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $O/$key/s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  echo "$g/$n | $law | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
