#!/bin/bash
# grid.sh <law> <pristine> <casedir>...: case | law | pristine | law | R11U426_OFF==pristine | own switch==pristine
# (when a verified binary is given as VER=<bin>: also the verified reading and R11V426_OFF==law)
R=$(cd $(dirname $0)/.. && pwd); L=$1; P=$2; shift 2
O=/tmp/v11u426_scr/out
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); g=$(basename $(dirname $c))/$(basename $c)
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=$(awk -v l=$law '$1==l{print $2}' $R/drivers/switches.txt)
  p=$(bash $R/drivers/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(bash $R/drivers/run1.sh $c $L l | cut -d' ' -f2-)
  bash $R/drivers/run1.sh $c $L o R11U426_OFF=1 >/dev/null
  bash $R/drivers/run1.sh $c $L s ${sw:-R11U426_NONE}=1 >/dev/null
  mp=$(md5sum < $O/$key/p/ours.uhdm 2>/dev/null | cut -c1-8); mo=$(md5sum < $O/$key/o/ours.uhdm 2>/dev/null | cut -c1-8); ms=$(md5sum < $O/$key/s/ours.uhdm 2>/dev/null | cut -c1-8)
  ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  ex=""
  if [ -n "$VER" ]; then
    v=$(bash $R/drivers/run1.sh $c $VER v | cut -d' ' -f2-)
    bash $R/drivers/run1.sh $c $VER vo R11V426_OFF=1 >/dev/null
    ml=$(md5sum < $O/$key/l/ours.uhdm 2>/dev/null | cut -c1-8); mvo=$(md5sum < $O/$key/vo/ours.uhdm 2>/dev/null | cut -c1-8)
    ex=" | verified $v | R11V426_OFF $([ "$mvo" = "$ml" ] && echo law || echo DIFF)"
  fi
  echo "$g | $law | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)$ex"
done
