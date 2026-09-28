#!/bin/bash
# gridall.sh <out tag> [--el] : grid.py over every case of this directory; output evidence/grid/grid_<tag>.txt
source "$(dirname "$0")/env.sh" || exit 2
cd $R199_DIR; t=$1; shift
python3 drivers/grid.py "$@" $(find cases -name dut.sv -printf '%h\n' | sort) > evidence/grid/grid_$t.txt 2>&1
echo "GRID_DONE rc=$?" >> evidence/grid/grid_$t.txt
