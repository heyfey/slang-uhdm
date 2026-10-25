#!/bin/bash
# grid.sh <law> <pristine> <verified> <casedir>...: one line per case dir:
#   case | law | pristine | law | verified | R11U432_OFF==pristine | own switch==pristine | R11V432_OFF on verified==law
# The law of a case is its first line '// § <law>'; its switch is read from drivers/switches.txt.
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2; V=$3; shift 3
O=/tmp/v11u432_scr/out
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); g=$(basename $(dirname $c)); n=$(basename $c); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=$(awk -v l=$law '$1==l{print $2}' $R/drivers/switches.txt)
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  v=$(bash $R/drivers/run1.sh $c $V v | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U432_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s ${sw:-R11U432_NONE}=1 >/dev/null
  bash $R/drivers/run1.sh $c $V w R11V432_OFF=1 >/dev/null
  m(){ md5sum < $O/$key/$1/ours.uhdm 2>/dev/null | cut -c1-8; }
  r(){ cat $O/$key/$1/rc; }
  echo "$g/$n | $law | pristine $p | law $l | ver $v | OFF $([ "$(m o)" = "$(m p)" ] && [ "$(r o)" = "$(r p)" ] && echo same || echo DIFF) | $sw $([ "$(m s)" = "$(m p)" ] && [ "$(r s)" = "$(r p)" ] && echo same || echo DIFF) | VOFF $([ "$(m w)" = "$(m l)" ] && [ "$(r w)" = "$(r l)" ] && echo law || echo DIFF) | ver $([ "$(m v)" = "$(m l)" ] && echo =law || echo '!=law')"
done
