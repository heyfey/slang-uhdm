#!/bin/bash
# After the composition sweeps: the two type-parameter laws off one at a time (probe + corpora), to decide
# which of § elabTpDefaultDefNamed163 / § tpUseBindsDefDefault160 is verdict-redundant on the gate.
until [ -f /tmp/r11u170_sweeps.done ]; do sleep 20; done
D=/tmp/wt_r11u170/tools/probe/r11u170verify/drivers
$D/sweep.sh /tmp/r11u170_bin/offTPDEFNAME.sh /tmp/r11u170_swN "probe surelog uhdm2rtlil"
$D/sweep.sh /tmp/r11u170_bin/offTPUSEDEF.sh  /tmp/r11u170_swU "probe surelog uhdm2rtlil"
echo done > /tmp/r11u170_sweeps_tp.done
