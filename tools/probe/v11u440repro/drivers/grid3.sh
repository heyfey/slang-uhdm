#!/bin/bash
# grid3.sh <casedir>...: pristine / law / verified readings per case, plus
#   R11V440_OFF, R11V440_ERRTSLOC_OFF and R11V440_LATERDECL_OFF on the verified binary == the law's bytes, R11U440_OFF == pristine's.
R=$(cd $(dirname $0)/.. && pwd); B=/tmp/v11u440_bin; O=/tmp/v11u440_scr/out
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); n=$(echo $c | sed 's|.*/cases/||')
  p=$(bash $R/drivers/run1.sh $c $B/pristine p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $B/law l | cut -d' ' -f2-)
  v=$(bash $R/drivers/run1.sh $c $B/verified v | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $B/verified vo R11V440_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $B/verified vs R11V440_ERRTSLOC_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $B/verified uo R11U440_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $B/verified vd R11V440_LATERDECL_OFF=1 >/dev/null
  m(){ md5sum < $O/$key/$1/ours.uhdm 2>/dev/null | cut -c1-8; }
  echo "$n | pristine $p | law $l | verified $v | R11V440_OFF $([ "$(m vo)" = "$(m l)" ] && echo =law || echo DIFF) | R11V440_ERRTSLOC_OFF $([ "$(m vs)" = "$(m l)" ] && echo =law || echo DIFF) | R11V440_LATERDECL_OFF $([ "$(m vd)" = "$(m l)" ] && echo =law || echo DIFF) | R11U440_OFF $([ "$(m uo)" = "$(m p)" ] && echo =pristine || echo DIFF)"
done
