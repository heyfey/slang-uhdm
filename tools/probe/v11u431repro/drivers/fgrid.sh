#!/bin/bash
# fgrid.sh <casedir>...: the final grid, one line per case dir:
#   case | law | pristine | law | verified | R11U431_OFF(verified)==pristine | R11V431_OFF(verified)==law | own switch
# binaries /tmp/v11u431_pris, /tmp/v11u431_law, /tmp/v11u431_ver2 (frozen); a case's law is its first line
# '// § <law>'; a law case's own switch gives pristine's bytes, a refinement case's own switch the law's
R=$(cd $(dirname $0)/.. && pwd); O=/tmp/v11u431_scr/out
P=/tmp/v11u431_pris/slang-uhdm; L=/tmp/v11u431_law/slang-uhdm; V=/tmp/v11u431_ver2/slang-uhdm
for b in $P $L $V; do [ -x $b ] || { echo "missing $b"; exit 2; }; done
for c in "$@"; do
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=$(awk -v l=$law '$1==l{print $2}' $R/drivers/switches.txt)
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2- | sed 's/ md5=.*//')
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2- | sed 's/ md5=.*//')
  v=$(bash $R/drivers/run1.sh $c $V v | cut -d' ' -f2- | sed 's/ md5=.*//')
  bash $R/drivers/run1.sh $c $V x R11U431_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $V w R11V431_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $V s ${sw:-R11U431_NONE}=1 >/dev/null
  m(){ echo "$(md5sum < $O/$key/$1/ours.uhdm 2>/dev/null | cut -c1-12) $(cat $O/$key/$1/rc 2>/dev/null)"; }
  case "$sw" in R11V431_*) ref=l;; *) ref=p;; esac
  dp=$(bash $R/drivers/dist.sh $c p); dv=$(bash $R/drivers/dist.sh $c v)
  echo "$key | $law | pristine $p dist=$dp | law $l | verified $v dist=$dv | v==law $([ "$(m v)" = "$(m l)" ] && echo same || echo DIFF) | U_OFF==p $([ "$(m x)" = "$(m p)" ] && echo same || echo DIFF) | V_OFF==law $([ "$(m w)" = "$(m l)" ] && echo same || echo DIFF) | ${sw:-none}==$ref $([ "$(m s)" = "$(m $ref)" ] && echo same || echo DIFF)"
done
