#!/bin/bash
# chain.sh: the composition sweeps, one after another (never two at once): 133 off, 137 off (+139 +v137), both, all three
# (+141), 141 off. Probe + both corpora; the all-off one adds the downstream stage.
D=$(dirname $0)
$D/sweep.sh 33 "R11U133_OFF" "probe surelog uhdm2rtlil"
$D/sweep.sh 37 "R11U137_OFF R11U139_OFF R11V137_OFF" "probe surelog uhdm2rtlil"
$D/sweep.sh 3B "R11U133_OFF R11U137_OFF R11U139_OFF R11V137_OFF" "probe surelog uhdm2rtlil"
$D/sweep.sh A3 "R11U133_OFF R11V141_OFF R11U137_OFF R11U139_OFF R11V137_OFF" "probe surelog uhdm2rtlil downstream"
$D/sweep.sh 41 "R11V141_OFF" "probe surelog uhdm2rtlil"
echo CHAIN_DONE > /tmp/r11u143_chain.done
