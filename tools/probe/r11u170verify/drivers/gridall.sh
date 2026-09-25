#!/bin/bash
# gridall.sh [--el] <out>: every case of cases/ through grid.py (states ON / own switches / landing / ALLOFF / PRE).
source /tmp/wt_r11u170/tools/probe/r11u170verify/drivers/env.sh || exit 2
cd /tmp/wt_r11u170/tools/probe/r11u170verify
EL=""; [ "$1" = --el ] && { EL=--el; shift; }
find cases -name dut.sv -printf '%h\n' | grep -v '/ux/' | sort | xargs -P 3 -n 1 python3 drivers/grid.py $EL > $1 2>&1
echo "cases: $(grep -c '^RESULT.*ALLOFF ' $1) + NOGOLD $(grep -c NOGOLD $1)" >> $1
