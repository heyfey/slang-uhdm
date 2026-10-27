#!/bin/bash
# grid3.sh <pristine> <law> <verified> <casedir>...: per case: the three readings (rc, uhdm-cmp lines,
# strict verdict), then R11U442_OFF on the verified binary == pristine bytes+rc, R11V442_OFF == law bytes+rc
R=$(cd $(dirname $0)/.. && pwd); P=$1; L=$2; W=$3; shift 3; O=/tmp/v11u442_scr/out
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-); l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-); v=$(bash $R/drivers/run1.sh $c $W v | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $W o R11U442_OFF=1 >/dev/null; bash $R/drivers/run1.sh $c $W vo R11V442_OFF=1 >/dev/null
  m(){ echo "$(md5sum < $O/$key/$1/ours.uhdm 2>/dev/null | cut -c1-8)$(cat $O/$key/$1/rc)"; }
  echo "$key | pristine $p | law $l | verified $v | R11U442_OFF $([ "$(m o)" = "$(m p)" ] && echo =pristine || echo DIFF) | R11V442_OFF $([ "$(m vo)" = "$(m l)" ] && echo =law || echo DIFF)"
done
