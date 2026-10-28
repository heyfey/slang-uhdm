#!/bin/bash
# sw.sh <casedir> <SWITCH...>: law with R11U450_OFF and with each named switch; compare to pristine md5
c=$1; shift
key=$(cd $c && pwd | sed "s|.*/tools/probe/||; s|/|_|g")
p=$(awk '{print $NF}' <(/tmp/v11u450_drv/run1.sh $c /tmp/v11u450_bin/pristine pris) | sed 's/md5=//')
l=$(md5sum < /tmp/v11u450_scr/out/$key/law/ours.uhdm 2>/dev/null | cut -c1-8)
o=$(/tmp/v11u450_drv/run1.sh $c /tmp/v11u450_bin/law off R11U450_OFF=1 | sed 's/.*md5=//')
r="$(echo $c | sed 's|.*/cases/||') pris=$p law=$l OFF=$([ "$o" = "$p" ] && echo pristine || echo DIFF:$o)"
[ "$p" = "$l" ] && { echo "$r (no move)"; exit; }
for s in "$@"; do
  x=$(/tmp/v11u450_drv/run1.sh $c /tmp/v11u450_bin/law sw_$s R11U450_${s}_OFF=1 | sed 's/.*md5=//')
  if [ "$x" = "$p" ]; then r="$r $s:restores"; elif [ "$x" = "$l" ]; then r="$r $s:inert"; else r="$r $s:partial"; fi
done
echo "$r"
