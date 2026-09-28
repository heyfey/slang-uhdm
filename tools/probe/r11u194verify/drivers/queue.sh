#!/bin/bash
# (r11u194: adapted from r11u190verify/drivers/queue.sh) queue.sh: the gate sweep of HEAD (all four stages) and the
# composition / history sweeps (probe + surelog + uhdm2rtlil), two at a time, each /tmp/r11u194_sw<X> (same length)
# with its state wrapper (README section 1).
D=$(cd "$(dirname "$0")" && pwd); source $D/env.sh || exit 2; B=$R194_BIN
run2() { bash $D/sweep.sh $B/$1 /tmp/r11u194_sw$2 "${5:-probe surelog uhdm2rtlil}" & bash $D/sweep.sh $B/$3 /tmp/r11u194_sw$4 "probe surelog uhdm2rtlil"; wait; }
bash $D/sweep.sh $B/law.bin /tmp/r11u194_swH & bash $D/sweep.sh $B/alloff.sh /tmp/r11u194_swA "probe surelog uhdm2rtlil"; wait
run2 off184.sh 4 off186.sh 6
run2 off187.sh 7 off187T.sh T
run2 o187x183.sh B o187x186.sh C
run2 pre184.sh Q post184.sh R
run2 post186.sh S wide.sh W
bash $D/sweep.sh $B/wideon.sh /tmp/r11u194_swO "probe surelog uhdm2rtlil"
echo QUEUE_DONE > /tmp/r11u194_queue.done
