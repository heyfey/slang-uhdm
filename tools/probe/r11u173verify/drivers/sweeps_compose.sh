#!/bin/bash
# sweeps_compose.sh: the composition sweeps, one after the other (workdir names all the same length):
#   swA = both landings off (full, downstream included), sw4 = pass 164 landing off, sw7 = pass 167 landing off,
#   swZ = both landings + r11u170's refinements off, swP = the d8cfd83a build (probe + corpora).
D=/tmp/wt_r11u173/tools/probe/r11u173verify/drivers
bash $D/sweep.sh /tmp/r11u173_bin/alloff.sh /tmp/r11u173_swA
bash $D/sweep.sh /tmp/r11u173_bin/off164.sh /tmp/r11u173_sw4 "probe surelog uhdm2rtlil"
bash $D/sweep.sh /tmp/r11u173_bin/off167.sh /tmp/r11u173_sw7 "probe surelog uhdm2rtlil"
bash $D/sweep.sh /tmp/r11u173_bin/alloff170.sh /tmp/r11u173_swZ "probe surelog uhdm2rtlil"
bash $D/sweep.sh /tmp/r11u173_bin/pre.bin /tmp/r11u173_swP "probe surelog uhdm2rtlil"
