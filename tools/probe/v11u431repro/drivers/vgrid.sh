#!/bin/bash
# vgrid.sh <verified binary> <casedir>...: one line per case: the verified reading, verified == law?,
# R11V431_OFF on the verified binary == law?, R11U431_OFF on the verified binary == pristine?
# (law tag l and pristine tag p from grid.sh runs of the same case dir)
R=$(cd $(dirname $0)/.. && pwd); V=$1; shift; O=/tmp/v11u431_scr/out
[ -x "$V" ] || { echo "missing $V"; exit 2; }
for c in "$@"; do
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); g=$(echo $key | sed 's|_cases_|/|; s|_|/|')
  v=$(bash $R/drivers/run1.sh $c $V v | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $V w R11V431_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $V x R11U431_OFF=1 >/dev/null
  m(){ md5sum < $O/$key/$1/ours.uhdm 2>/dev/null | cut -c1-8; cat $O/$key/$1/rc 2>/dev/null; }
  echo "$g | verified $v | v==law $([ "$(m v)" = "$(m l)" ] && echo same || echo DIFF) | R11V431_OFF==law $([ "$(m w)" = "$(m l)" ] && echo same || echo DIFF) | R11U431_OFF==pristine $([ "$(m x)" = "$(m p)" ] && echo same || echo DIFF)"
done
