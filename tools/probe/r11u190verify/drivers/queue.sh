#!/bin/bash
# queue.sh: the composition and process sweeps (tests/sweep.sh --jobs 3, probe + surelog + uhdm2rtlil), two at a
# time, each named /tmp/r11u190_sw<X> (same length) with its state wrapper (README section 1).
D=/tmp/wt_r11u190/tools/probe/r11u190verify/drivers; B=/tmp/r11u190_bin
run2() { bash $D/sweep.sh $B/$1 /tmp/r11u190_sw$2 "probe surelog uhdm2rtlil" & bash $D/sweep.sh $B/$3 /tmp/r11u190_sw$4 "probe surelog uhdm2rtlil"; wait; }
until grep -q SWEEP_RC /tmp/r11u190_swH.log 2>/dev/null && grep -q SWEEP_RC /tmp/r11u190_swA.log 2>/dev/null; do sleep 30; done
run2 off180.sh 0 off181.sh 1
run2 off184.sh 4 off184x181.sh 5
run2 wide.sh W wideon.sh O
run2 s804.sh P s1eef.sh E
run2 sa3a.sh T s80a.sh 8
echo QUEUE_DONE > /tmp/r11u190_queue.done
