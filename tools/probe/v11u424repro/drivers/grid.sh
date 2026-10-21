#!/bin/bash
# grid.sh <casedir>...: pristine vs law vs R11U424_OFF vs own switch
L=/tmp/v11u424_bin/law; P=/tmp/v11u424_bin/pristine; R=/tmp/wt_v11u424/tools/probe/r11u424repro/drivers/switches.txt
O=/tmp/v11u424_scr/out
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || { echo "SKIP $c"; continue; }
  c=$(cd $c && pwd); key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
  law=$(head -1 $c/dut.sv | sed 's|^// § *||; s| .*||'); sw=$(awk -v l=$law '$1==l{print $2}' $R)
  p=$(/tmp/v11u424_drv/run1.sh $c $P p | cut -d' ' -f2-)
  l=$(/tmp/v11u424_drv/run1.sh $c $L l | cut -d' ' -f2-)
  /tmp/v11u424_drv/run1.sh $c $L o R11U424_OFF=1 >/dev/null
  /tmp/v11u424_drv/run1.sh $c $L s ${sw:-R11U424_NONE}=1 >/dev/null
  m(){ [ -f $O/$key/$1/ours.uhdm ] && md5sum < $O/$key/$1/ours.uhdm | cut -c1-8; }
  mp=$(m p); mo=$(m o); ms=$(m s); ro=$(cat $O/$key/o/rc); rs=$(cat $O/$key/s/rc); rp=$(cat $O/$key/p/rc)
  echo "$(echo $key|tr _ /) | $law | pristine $p | law $l | OFF $([ "$mo" = "$mp" ] && [ "$ro" = "$rp" ] && echo same || echo DIFF) | $sw $([ "$ms" = "$mp" ] && [ "$rs" = "$rp" ] && echo same || echo DIFF)"
done
