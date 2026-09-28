#!/bin/bash
# queue3.sh: after queue2.sh, the fix binary's gate sweep (all four stages), /tmp/r11u194_swF.
D=$(cd "$(dirname "$0")" && pwd); source $D/env.sh || exit 2
until [ -e /tmp/r11u194_queue2.done ]; do sleep 30; done
date > /tmp/r11u194_swF_start.txt
bash $D/sweep.sh $R194_BIN/fix.bin /tmp/r11u194_swF
echo QUEUE3_DONE > /tmp/r11u194_queue3.done
