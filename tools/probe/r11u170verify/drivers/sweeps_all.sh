#!/bin/bash
# The composition sweeps, one after another (never two at once): A = the three landings off (full gate),
# P = the pre-landing build 0f607463 (probe + corpora), 8/0/3 = one landing off at a time (probe + corpora).
D=/tmp/wt_r11u170/tools/probe/r11u170verify/drivers
$D/sweep.sh /tmp/r11u170_bin/alloff.sh /tmp/r11u170_swA
$D/sweep.sh /tmp/r11u170_bin/pre.bin   /tmp/r11u170_swP "probe surelog uhdm2rtlil"
$D/sweep.sh /tmp/r11u170_bin/off158.sh /tmp/r11u170_sw8 "probe surelog uhdm2rtlil"
$D/sweep.sh /tmp/r11u170_bin/off160.sh /tmp/r11u170_sw0 "probe surelog uhdm2rtlil"
$D/sweep.sh /tmp/r11u170_bin/off163.sh /tmp/r11u170_sw3 "probe surelog uhdm2rtlil"
echo ALLDONE > /tmp/r11u170_sweeps.done
