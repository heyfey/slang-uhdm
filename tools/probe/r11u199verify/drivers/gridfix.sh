#!/bin/bash
# gridfix.sh <out tag> [--el]: grid.py with the FIX binary as ON (every state is fix.bin under switches; GW=/tmp/r11u199_gF)
source "$(dirname "$0")/env.sh" || exit 2
cd $R199_DIR; t=$1; shift
LAW=$FIX GW=/tmp/r11u199_gF python3 drivers/grid.py "$@" $(find cases -name dut.sv -printf '%h\n' | sort) > evidence/grid/gridfix_$t.txt 2>&1
echo "GRID_DONE rc=$?" >> evidence/grid/gridfix_$t.txt
