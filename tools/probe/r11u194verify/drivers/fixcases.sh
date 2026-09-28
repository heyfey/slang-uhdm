#!/bin/bash
# fixcases.sh <out> <casedir>...: per case and view, the law binary (ON) and the fix binary (FIX), each with its
# strict verdict, uhdm-cmp lines and md5; FIX with R11V194_OFF=1 must write ON's bytes.  The golden cache is case.sh's.
source "$(dirname "$0")/env.sh" || exit 2
O=$1; shift
for c in "$@"; do for el in 0 1; do
  a=$(EL=$el bash $R194_DIR/drivers/case.sh $c on $LAW); b=$(EL=$el bash $R194_DIR/drivers/case.sh $c fix $FIX)
  o=$(EL=$el bash $R194_DIR/drivers/case.sh $c fixoff $FIX R11V194_OFF=1)
  echo "$a || $(echo $b | awk '{print $3,$5,$7}') || R11V194_OFF $(echo $o | awk '{print $NF}')"
done; done > $O
