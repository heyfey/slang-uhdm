#!/bin/bash
# gridall.sh [--el] <out>: every case of cases/ through grid.py (states ON / own switches / landing / ALLOFF /
# ALLOFF170 / PRE), three at a time.
source /tmp/wt_r11u173/tools/probe/r11u173verify/drivers/env.sh || exit 2
cd /tmp/wt_r11u173/tools/probe/r11u173verify
EL=""; [ "$1" = --el ] && { EL=--el; shift; }
find cases -name dut.sv -printf '%h\n' | sort | xargs -P 3 -n 1 python3 drivers/grid.py $EL > $1 2>&1
echo "cases: $(grep -c '^RESULT.* ALLOFF ' $1) + NOGOLD $(grep -c NOGOLD $1)" >> $1
