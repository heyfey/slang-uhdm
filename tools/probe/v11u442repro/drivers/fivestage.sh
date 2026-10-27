#!/bin/bash
# usage: fivestage.sh <binary> <workdir> <tracedir>: one full five-stage sweep, trace on.
# The four corpus stages through the worktree's tests/sweep.sh; the sv-tests stage through the main
# tree's scripts/check_svtests.py (a worktree has an empty UVM submodule; scripts/ equal to the base),
# baseline the worktree's results/golden_svtests.csv, into the same workdir.
cd /tmp/wt_v11u442 || exit 1
source /tmp/v11u442_env.sh
export SLANG_UHDM=$1 SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
for v in "$SURELOG" "$UHDM_CMP" "$UHDM_DUMP" "$SLANG_UHDM"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
export R11U442_TRACE=$3; mkdir -p $3
/tmp/v11u442_scr/quiet.sh
date; tests/sweep.sh --jobs 3 --workdir $2 --corpus "probe surelog uhdm2rtlil downstream" > $2.log 2>&1; echo "sweep rc=$?" >> $2.log; date
/tmp/v11u442_scr/quiet.sh
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $2/svtests --out $2/svtests.csv --svtests $SVTESTS_ROOT --baseline /tmp/wt_v11u442/results/golden_svtests.csv > $2/svtests.log 2>&1; echo "svtests stage rc=$?" >> $2/svtests.log; date
