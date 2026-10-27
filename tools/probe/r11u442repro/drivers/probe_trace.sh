#!/bin/bash
# probe_trace.sh <binary> <tracedir> <case rel path>: run one probe case (check_probe.py's command) with R11U442_TRACE
B=$1; T=$2; f=$3; d=$(dirname /home/heyfey/git-repos/slang-uhdm/$f); k=$(echo $f | tr / _)
[ -x "$B" ] || exit 2
mkdir -p $T /tmp/r11u442_scr/pout
(cd $d && R11U442_TRACE=$T timeout 120 $B dut.sv --single-unit --nobuiltin -o /tmp/r11u442_scr/pout/$k.uhdm >/dev/null 2>&1 </dev/null); rm -f /tmp/r11u442_scr/pout/$k.uhdm
