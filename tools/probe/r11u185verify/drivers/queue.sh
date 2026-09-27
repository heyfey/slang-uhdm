#!/bin/bash
# queue.sh: the composition and process sweeps (tests/sweep.sh --jobs 3, probe + surelog + uhdm2rtlil), two at a
# time, each named /tmp/r11u185_sw<X> (same length) with its state wrapper; see README section 1 for the states.
D=/tmp/wt_r11u185/tools/probe/r11u185verify/drivers; B=/tmp/r11u185_bin
run2() { bash $D/sweep.sh $B/$1 /tmp/r11u185_sw$2 "probe surelog uhdm2rtlil" & bash $D/sweep.sh $B/$3 /tmp/r11u185_sw$4 "probe surelog uhdm2rtlil"; wait; }
until grep -q SWEEP_RC /tmp/r11u185_sw6.log 2>/dev/null && grep -q SWEEP_RC /tmp/r11u185_sw8.log 2>/dev/null; do sleep 30; done
run2 preoff.sh P st80a.sh R
run2 st804.sh S wide.sh W
run2 others.sh Q off175F.sh F
run2 off175E.sh E st72.sh 7
run2 st5e.sh 5 pre.bin X
echo QUEUE_DONE > /tmp/r11u185_queue.done
