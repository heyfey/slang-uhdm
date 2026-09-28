#!/bin/bash
# queue2.sh: after queue.sh, the process-check sweeps: the 1eeff71d state (pass 184's pristine base, for predict184)
# and pass 186's firing census in its integration state.
D=$(cd "$(dirname "$0")" && pwd); source $D/env.sh || exit 2
until [ -e /tmp/r11u194_queue.done ]; do sleep 30; done
bash $D/sweep.sh $R194_BIN/s1eef.sh /tmp/r11u194_swE "probe surelog uhdm2rtlil" & bash $D/census186.sh /tmp/r11u194_cen186 > /tmp/r11u194_cen186.log 2>&1; wait
echo QUEUE2_DONE > /tmp/r11u194_queue2.done
