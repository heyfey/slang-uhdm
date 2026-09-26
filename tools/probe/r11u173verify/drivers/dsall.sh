#!/bin/bash
# dsall.sh <state> <out>: the downstream verdict of every case under the state (drivers/dscase.py), three groups at a time.
source /tmp/wt_r11u173/tools/probe/r11u173verify/drivers/env.sh || exit 2
cd /tmp/wt_r11u173/tools/probe/r11u173verify
for g in $(ls cases); do echo $g; done | xargs -P 3 -I{} sh -c "python3 drivers/dscase.py $1 cases/{}/* > /tmp/r11u173_scr/ds_$1_{}.txt 2>&1"
cat /tmp/r11u173_scr/ds_$1_*.txt | sort > $2
