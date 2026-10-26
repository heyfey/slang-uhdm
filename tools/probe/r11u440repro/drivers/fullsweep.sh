#!/bin/bash
# usage: fullsweep.sh <binary> <workdir> <tracedir>: the one full five-stage sweep on the final law binary, trace on.
# The four corpus stages through the worktree's tests/sweep.sh; the sv-tests stage through the main
# tree's scripts/check_svtests.py (a worktree has no UVM tree), into the same workdir.
cd /tmp/wt_r11u440 || exit 1
source /tmp/r11u440_env.sh
export SLANG_UHDM=$1 SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
for v in "$SURELOG" "$UHDM_CMP" "$UHDM_DUMP" "$SLANG_UHDM"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
export R11U440_TRACE=$3; mkdir -p $3
bash /tmp/wt_r11u440/tools/probe/r11u440repro/drivers/quiet.sh
date; tests/sweep.sh --jobs 3 --workdir $2 --corpus "probe surelog uhdm2rtlil downstream" > $2.log 2>&1; echo "sweep rc=$?" >> $2.log; date
bash /tmp/wt_r11u440/tools/probe/r11u440repro/drivers/quiet.sh
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $2/svtests --out $2/svtests.csv --svtests $SVTESTS_ROOT --baseline /tmp/wt_r11u440/results/golden_svtests.csv > $2/svtests.log 2>&1; echo "svtests stage rc=$?" >> $2/svtests.log; date
