#!/bin/bash
c=$1; p=$(/tmp/v11u424_drv/run1.sh $c /tmp/v11u424_bin/pristine p | cut -d' ' -f2-); l=$(/tmp/v11u424_drv/run1.sh $c /tmp/v11u424_bin/law l | cut -d' ' -f2-)
echo "$(echo $c | sed 's|/tmp/wt_v11u424/tools/probe/||') | P $p | L $l"
