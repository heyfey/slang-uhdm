#!/bin/bash
# grid.sh <law binary> <pristine binary> <casedir>...: one line per case dir:
#   case | law | pristine reading | law reading | R11U438_OFF == pristine | the case's own switch == pristine
# The law of a case is its first line '// § <law>'; its switch is read from drivers/switches.txt.
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2; shift 2
O=/tmp/v11u438_scr/out
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); g=$(basename $(dirname $c)); n=$(basename $c); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=$(awk -v l=$law '$1==l{print $2}' $R/drivers/switches.txt)
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U438_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s ${sw:-R11U438_NONE}=1 >/dev/null
  mp=$(md5sum < $O/$key/p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $O/$key/o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $O/$key/s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  echo "$g/$n | $law | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
